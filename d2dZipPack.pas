//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//---------------------------------------------------------------------------

// This unit based on SciZipFile unit by Patrik Spanel
// scilib@sendme.cz
// Written from scratch using InfoZip PKZip file specification application note
// ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip
// uses the Borland out of the box zlib

unit d2dZipPack;

interface

uses
 SysUtils,
 Types,
 Classes,
 zlib,

 d2dClasses,
 d2dInterfaces;

type

  TCommonFileHeader = packed record
    VersionNeededToExtract: WORD; //       2 bytes
    GeneralPurposeBitFlag: WORD; //        2 bytes
    CompressionMethod: WORD; //              2 bytes
    LastModFileTimeDate: DWORD; //             4 bytes
    Crc32: DWORD; //                          4 bytes
    CompressedSize: DWORD; //                 4 bytes
    UncompressedSize: DWORD; //               4 bytes
    FilenameLength: WORD; //                 2 bytes
    ExtraFieldLength: WORD; //              2 bytes
  end;

  TLocalFile = packed record
    LocalFileHeaderSignature: DWORD; //     4 bytes  (0x04034b50)
    CommonFileHeader: TCommonFileHeader; //
    filename: AnsiString; //variable size
    extrafield: AnsiString; //variable size
    FileOffset: DWORD;
  end;

  Td2dZipPack = class(Td2dProtoObject, Id2dResourcePack)
  private
    Files: array of TLocalFile;
    f_PackFileName: string;
    function pm_GetCount: Integer;
    function pm_GetName(aIndex: Integer): AnsiString;
    procedure LoadFromFile(const filename: string; aOffset: Integer);
    procedure LoadFromStream(const ZipFileStream: TStream);
    function pm_GetSize(Index: Integer): LongWord;
  public
    constructor Create(aPackFileName: string; aOffset: Integer = 0);
    function IndexOf(const aFileName: string): Integer;
    function Find(aWildCard: string; aFrom: Integer = 0): Integer;
    function Extract(I: integer; var aBuffer: Pointer; aSize: DWORD = 0): Boolean;
    class function Make(const aFilename: AnsiString): Id2dResourcePack;
    property Count: integer read pm_GetCount;
    property Name[Index: Integer]: string read pm_GetName;
    property Size[Index: Integer]: LongWord read pm_GetSize;
  end;

  EZipFileError    = class(Exception);
  EZipFileCRCError = class(Exception);

function ZipCRC32(const aBuffer: Pointer; aLength: DWORD): longword;

implementation
uses
 Windows,
 StrUtils,
 JclStrings;

const
 shlwapi = 'shlwapi.dll';

 UTF8ENCODEDFILENAME_FLAG = $0800;

function PathMatchSpec(aFile: PAnsiChar; aSpec: PAnsiChar): BOOL; stdcall; external shlwapi name 'PathMatchSpecA';

constructor Td2dZipPack.Create(aPackFileName: string; aOffset: Integer = 0);
begin
 inherited Create;
 f_PackFileName := aPackFileName;
 LoadFromFile(f_PackFileName, aOffset);
end;

function Td2dZipPack.Find(aWildCard: string; aFrom: Integer = 0): Integer;
var
 l_List: TStringList;
 I,J : Integer;
begin
 Result := -1;
 l_List := TStringList.Create;
 try
  StrToStrings(aWildCard, ';', l_List, False);
  if l_List.Count > 0 then
  begin
   for I := aFrom to Count-1 do
   begin
    for J := 0 to Pred(l_List.Count) do
    begin
     if PathMatchSpec(PAnsiChar(Files[I].filename), PAnsiChar(l_List[J])) then
     begin
      Result := I;
      Exit;
     end;
    end;
   end;
  end;
 finally
  l_List.Free;
 end;
end;

procedure Td2dZipPack.LoadFromStream(const ZipFileStream: TStream);
var
  n: integer;
  signature: DWORD;
begin
  n := 0;
  repeat
    signature := 0;
    ZipFileStream.Read(signature, 4);
    if   (ZipFileStream.Position =  ZipFileStream.Size) then exit;
  until signature = $04034B50;
  repeat
    begin
      if (signature = $04034B50) then
      begin
        inc(n);
        SetLength(Files, n);
        with Files[n - 1] do
        begin
          LocalFileHeaderSignature := signature;
          ZipFileStream.Read(CommonFileHeader, SizeOf(CommonFileHeader));
          SetLength(filename, CommonFileHeader.FilenameLength);
          ZipFileStream.Read(PChar(filename)^,
            CommonFileHeader.FilenameLength);
          filename := StringReplace(filename, '/', '\', [rfReplaceAll]);
          SetLength(extrafield, CommonFileHeader.ExtraFieldLength);
          ZipFileStream.Read(PChar(extrafield)^,
            CommonFileHeader.ExtraFieldLength);
          FileOffset := ZipFileStream.Position;
          if CommonFileHeader.GeneralPurposeBitFlag and UTF8ENCODEDFILENAME_FLAG <> 0 then
           filename := UTF8ToAnsi(filename)
          else
           OemToCharBuff(PAnsiChar(filename), PAnsiChar(filename), Length(filename));
          filename := AnsiLowerCase(filename);
          ZipFileStream.Seek(CommonFileHeader.CompressedSize, soFromCurrent);
        end;
      end;
    end;
    signature := 0;
    ZipFileStream.Read(signature, 4);
  until signature <> ($04034B50);
end;

procedure Td2dZipPack.LoadFromFile(const filename: string; aOffset: Integer);
var
  ZipFileStream: TFileStream;
begin
  ZipFileStream := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  try
   ZipFileStream.Position := aOffset;
   LoadFromStream(ZipFileStream);
  finally
   ZipFileStream.Free;
  end;
end;

function Td2dZipPack.Extract(I: integer; var aBuffer: Pointer; aSize: DWORD = 0): Boolean;
var
  Decompressor: TDecompressionStream;
  UncompressedStream: TMemoryStream;
  l_ZipFileStream   : TFileStream;
  ReadBytes: DWORD;
  LoadedCrc32: DWORD;
  l_CompMem: PByteArray;
begin
  Result := False;
  if (aSize > 0) and (aSize < Files[I].CommonFileHeader.UncompressedSize) then
   Exit;

  if (i < 0) or (i > High(Files)) then
    raise Exception.Create('Index out of range.');

  if Files[I].CommonFileHeader.CompressionMethod <> 0 then // if not "stored"
  begin
   UncompressedStream := TMemoryStream.Create;
   UncompressedStream.SetSize(Files[i].CommonFileHeader.CompressedSize+2);
   l_CompMem := PByteArray(UncompressedStream.Memory);
   //manufacture a 2 byte header for zlib; 4 byte footer is not required.
   l_CompMem[0] := $78;
   l_CompMem[1] := $9C;
   l_ZipFileStream := TFileStream.Create(f_PackFileName, fmOpenRead or fmShareDenyWrite);
   try
    l_ZipFileStream.Position := Files[I].FileOffset;
    l_ZipFileStream.Read(l_CompMem[2], Files[I].CommonFileHeader.CompressedSize);
   finally
    l_ZipFileStream.Free;
   end;
   UncompressedStream.Position := 0;
   try {+}
     Decompressor := TDecompressionStream.Create(UncompressedStream);
     try {+}
       if aSize = 0 then
        GetMem(aBuffer, Size[I]);
       ReadBytes := Decompressor.Read(aBuffer^, Size[I]);
       if ReadBytes <> Size[I] then
       begin
        if aSize = 0 then
         FreeMem(aBuffer);
        Exit;
       end;
     finally
       Decompressor.Free;
     end;
   finally
     UncompressedStream.Free;
   end;
  end
  else
  begin
   l_ZipFileStream := TFileStream.Create(f_PackFileName, fmOpenRead or fmShareDenyWrite);
   if aSize = 0 then
    GetMem(aBuffer, Size[I]);
   l_ZipFileStream.Position := Files[I].FileOffset;
   ReadBytes := l_ZipFileStream.Read(aBuffer^, Size[I]);
   if ReadBytes <> Size[I] then
   begin
    if aSize = 0 then
     FreeMem(aBuffer);
    Exit;
   end;
  end;

  LoadedCRC32 := ZipCRC32(aBuffer, ReadBytes);
  if LoadedCRC32 <> Files[i].CommonFileHeader.Crc32 then
    // - Result := '';
    raise EZipFileCRCError.CreateFmt('CRC Error in "%s".', [Files[i].filename]);
  Result := True;
end;

function Td2dZipPack.pm_GetCount: Integer;
begin
  Result := High(Files) + 1;
end;

function Td2dZipPack.pm_GetName(aIndex: Integer): AnsiString;
begin
  Result := Files[aIndex].Filename;
end;

function Td2dZipPack.IndexOf(const aFileName: string): Integer;
var
 I: Integer;
 l_Str: string;
begin
 Result := -1;
 I := 0;
 l_Str := AnsiLowerCase(aFileName);
 l_Str := StringReplace(l_Str, '/', '\', [rfReplaceAll]);
 while I < Count do
 begin
  if Name[I] = l_Str then
  begin
   Result := I;
   Exit;
  end;
  Inc(I);
 end;
end;

class function Td2dZipPack.Make(const aFilename: AnsiString): Id2dResourcePack;
var
 l_ZP: Td2dZipPack;
begin
 l_ZP := Td2dZipPack.Create(aFilename);
 try
  Result := l_ZP;
 finally
  FreeAndNil(l_ZP);
 end;
end;

function Td2dZipPack.pm_GetSize(Index: Integer): LongWord;
begin
 if (Index < 0) or (Index > High(Files)) then
  raise Exception.Create('Index out of range.');
 Result := Files[Index].CommonFileHeader.UncompressedSize;
end;

{ ZipCRC32 }

//calculates the zipfile CRC32 value from a string

function ZipCRC32(const aBuffer: Pointer; aLength: DWORD): longword;
const
  CRCtable: array[0..255] of DWORD = (
    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535,
    $9E6495A3, $0EDB8832, $79DCB8A4,
    $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064,
    $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856, $646BA8C0, $FD62F97A,
    $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1,
    $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF,
    $ABD13D59, $26D930AC, $51DE003A,
    $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, $2802B89E,
    $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106, $98D220BC,
    $EFD5102A, $71B18589, $06B6B51F,
    $9FBFE4A5, $E8B8D433, $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB,
    $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1,
    $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65, $4DB26158,
    $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846,
    $DA60B8D0, $44042D73, $33031DE5,
    $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525,
    $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B,
    $C0BA6CAD, $EDB88320, $9ABFB3B6,
    $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683, $E3630B12,
    $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344, $8708A3D2, $1E01F268,
    $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F,
    $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD,
    $48B2364B, $D80D2BDA, $AF0A1B4C,
    $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, $CB61B38C,
    $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE, $B2BD0B28, $2BB45A92,
    $5CB36A04, $C2D7FFA7, $B5D0CF31,
    $2CD99E8B, $5BDEAE1D, $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9,
    $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7,
    $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777, $88085AE6,
    $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354,
    $3903B3C2, $A7672661, $D06016F7,
    $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53,
    $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729,
    $23D967BF, $B3667A2E, $C4614AB8,
    $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);
var
  i: integer;
  l_Data: PByte;
begin
  result := $FFFFFFFF;
  l_Data := PByte(aBuffer);
  for i := 0 to aLength - 1 do
  begin
   result := (result shr 8) xor (CRCtable[byte(result) xor Ord(l_Data^)]);
   l_Data := PByte(Longword(l_Data)+1);
  end;
  result := result xor $FFFFFFFF;
end;
end.

