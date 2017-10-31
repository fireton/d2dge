unit d2dFont;

interface

uses
 Windows,
 D3DX8,
 d2dTypes,
 d2dInterfaces,
 d2dSprite,

 SimpleXML;

type
 Td2dHGELetter = class(Td2dSprite)
 private
  f_KernPost: Single;
  f_KernPre: Single;
 public
  constructor Create(aTex: Id2dTexture; aTexX, aTexY: Integer;
                     aWidth, aHeight: Integer; aKernPre, aKernPost: Single);
  property KernPost: Single read f_KernPost write f_KernPost;
  property KernPre: Single read f_KernPre write f_KernPre;
 end;

 Td2dCustomFont = class(TInterfacedObject, Id2dFont)
 private
  f_BlendMode: Integer;
  f_Color: Longword;
  f_ID: string;
  function pm_GetBlendMode: Integer;
  function pm_GetColor: Longword;
  function pm_GetID: string;
  procedure pm_SetBlendMode(const aValue: Integer);
  procedure pm_SetColor(const aValue: Longword);
  procedure pm_SetID(const Value: string);
 protected
  procedure DoSetBlendMode(aBlendMode: Integer); virtual; abstract;
  procedure DoSetColor(aColor: Td2dColor); virtual; abstract;
  function pm_GetHeight: Single; virtual; abstract;
  function pm_GetSize: Single; virtual; abstract;
 public
  function CalcStringBySize(const aStr: string; aWidth: Single; const aEllipsis: string = '...'): string;
  procedure CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt); virtual; abstract;
  function CanRenderChar(aChar: Char): Boolean; virtual; abstract;
  procedure Render(aX, aY: Single; aStr: string); virtual; abstract;
  property BlendMode: Integer read pm_GetBlendMode write pm_SetBlendMode;
  property Color: Longword read pm_GetColor write pm_SetColor;
  property Height: Single read pm_GetHeight;
  property ID: string read pm_GetID write pm_SetID;
  property Size: Single read pm_GetSize;
 end;

 Td2dHGEFont = class(Td2dCustomFont)
 private
  f_Height: Single;
  f_Letters: array[#0..#255] of Td2dHGELetter;
  f_Scale: Single;
  f_Spacing: Single;
  f_Tracking: Single;
 protected
  procedure DoSetBlendMode(aBlendMode: Integer); override;
  procedure DoSetColor(aColor: Td2dColor); override;
  function pm_GetHeight: Single; override;
  function pm_GetSize: Single; override;
 public
  constructor Create(aFontFileName: string; aPackOnly: Boolean = False);
  destructor Destroy; override;
  procedure CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt); override;
  function CanRenderChar(aChar: Char): Boolean; override;
  procedure Render(aX, aY: Single; aStr: string); override;
  property Scale: Single read f_Scale write f_Scale;
  property Spacing: Single read f_Spacing write f_Spacing;
  property Tracking: Single read f_Tracking write f_Tracking;
 end;

 Td2dDXFont = class(TObject)
 private
  f_Bold: Boolean;
  f_Color: Longword;
  f_Typeface: string;
  f_Intf  : ID3DXFont;
  f_Italic: Boolean;
  f_Size: Integer;
  procedure pm_SetBold(const Value: Boolean);
  procedure pm_SetTypeface(const Value: string);
  procedure pm_SetItalic(const Value: Boolean);
  procedure pm_SetSize(const Value: Integer);
  procedure RecreateDXFont;
  property Italic: Boolean read f_Italic write pm_SetItalic;
 public
  constructor Create(aTypeface: string; aSize: Integer; aBold: Boolean = False);
  procedure Render(aString: string; aLeft, aTop, aRight, aBottom: Integer; aFlags: Longword = DT_TOP +
      DT_LEFT+DT_NOPREFIX);
  property Bold: Boolean read f_Bold write pm_SetBold;
  property Color: Longword read f_Color write f_Color;
  property Typeface: string read f_Typeface write pm_SetTypeface;
  property Size: Integer read f_Size write pm_SetSize;
 end;

 Td2dBMLetter = class(Td2dSprite)
 private
  f_XAdvance: Integer;
  f_XOffset : Integer;
  f_YOffset : Integer;
 public
  property XAdvance: Integer read f_XAdvance;
  property XOffset: Integer read f_XOffset;
  property YOffset: Integer read f_YOffset;
 end;

 Td2dBMFont = class(Td2dCustomFont)
 private
  f_FontHeight: Integer;
  f_FontSize: Integer;
  f_Letters: array[#33..#255] of Td2dBMLetter;
  f_SpaceAdv: Integer;
  procedure LoadFromXML(aXML: IXmlDocument);
  procedure Load(aFilename: string; aFromPack: Boolean);
 protected
  procedure DoSetBlendMode(aBlendMode: Integer); override;
  procedure DoSetColor(aColor: Td2dColor); override;
  function pm_GetHeight: Single; override;
  function pm_GetSize: Single; override;
 public
  constructor Create(const aFilename: string; aFromPack: Boolean = False);
  constructor CreateFromXML(aXML: IXmlDocument);
  destructor Destroy; override;
  procedure CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt); override;
  function CanRenderChar(aChar: Char): Boolean; override;
  procedure Render(aX, aY: Single; aStr: string); override;
 end;

implementation

uses
 Classes,
 SysUtils,
 StrUtils,

 d2dCore,
 d2dUtils;

constructor Td2dHGELetter.Create(aTex: Id2dTexture; aTexX, aTexY: Integer;
                              aWidth, aHeight: Integer; aKernPre, aKernPost: Single);
begin
 inherited Create(aTex, aTexX, aTexY, aWidth, aHeight);
 f_KernPost := aKernPost;
 f_KernPre := aKernPre;
end;

constructor Td2dHGEFont.Create(aFontFileName: string; aPackOnly: Boolean = False);
type
 TCharset = set of Char;
const
 cBitmapSig = 'Bitmap=';
 cCharSig   = 'Char=';
var
 l_Temp    : Pointer;
 l_DescSize: Longword;
 l_CurPos  : Integer;
 l_FontDesc: string;
 l_Tex     : Id2dTexture;
 l_TempStr: string;
 l_Char: Char;
 l_X, l_Y, l_W, l_H, l_Pre, l_Post: Integer;

 function ScanTo(aStopChars: TCharset): string;
 begin
  Result := '';
  while not ((l_CurPos > Length(l_FontDesc)) or (l_FontDesc[l_CurPos] in aStopChars)) do
  begin
   Result := Result + l_FontDesc[l_CurPos];
   Inc(l_CurPos);
  end;
 end;

 function GetNumber: Integer;
 var
  l_Tmp: string;
 begin
  l_Tmp := ScanTo([#10, #13, ',']);
  Result := StrToIntDef(l_Tmp, 0);
 end;

 function GetChar: Char;
 var
  l_Tmp : string;
  l_Code: Byte;
 begin
  if l_FontDesc[l_CurPos] = '"' then
  begin
   Inc(l_CurPos, 1);
   Result := l_FontDesc[l_CurPos];
   Inc(l_CurPos, 3);
  end
  else
  begin
   l_Tmp := Trim(ScanTo([',']));
   l_Code := StrToIntDef('$'+l_Tmp, 0);
   Result := Char(l_Code);
   Inc(l_CurPos, 1);
  end;
 end;

begin
 inherited Create;
 aFontFileName := StringReplace(aFontFileName, '/', '\', [rfReplaceAll]);
 f_Scale := 1.0;
 f_Tracking := 0.0;
 f_Spacing := 1.0;
 f_Height := 0.0;
 FillChar(f_Letters, SizeOf(f_Letters), 0);
 l_Temp := gD2DE.Resource_Load(aFontFileName, @l_DescSize, aPackOnly);
 if l_Temp <> nil then
 begin
  SetLength(l_FontDesc, l_DescSize);
  Move(l_Temp^, l_FontDesc[1], l_DescSize);
  FreeMem(l_Temp);

  l_CurPos := PosEx(cBitmapSig, l_FontDesc);
  if l_CurPos > 0 then
  begin
   Inc(l_CurPos, Length(cBitmapSig));
   l_TempStr := ScanTo([#13,#10]);
   if l_TempStr <> '' then
   begin
    l_TempStr := ExtractFilePath(aFontFileName) + l_TempStr;
    l_Tex := gD2DE.Texture_Load(PAnsiChar(l_TempStr), aPackOnly, False);
    if l_Tex <> nil then
    begin
     repeat
      l_CurPos := PosEx(cCharSig, l_FontDesc, l_CurPos);
      if l_CurPos > 0 then
      begin
       Inc(l_CurPos, Length(cCharSig));
       l_Char := GetChar;

       l_X := GetNumber; Inc(l_CurPos, 1);
       l_Y := GetNumber; Inc(l_CurPos, 1);
       l_W := GetNumber; Inc(l_CurPos, 1);
       l_H := GetNumber; Inc(l_CurPos, 1);
       l_Pre := GetNumber; Inc(l_CurPos, 1);
       l_Post := GetNumber;
       Assert(f_Letters[l_Char] = nil, 'Reassigning character in Td2dFont.Create');
       f_Letters[l_Char] := Td2dHGELetter.Create(l_Tex, l_X, l_Y, l_W, l_H, l_Pre, l_Post);
       if l_H > f_Height then
        f_Height := l_H;
      end;
     until (l_CurPos = 0) or (l_CurPos > Length(l_FontDesc));
    end;
   end;
  end;
 end;
 Color  := $FFFFFFFF;
 BlendMode := BLEND_DEFAULT;
end;

destructor Td2dHGEFont.Destroy;
var
 C: Char;
begin
 for C := #0 to #255 do
  if f_Letters[C] <> nil then
   FreeAndNil(f_Letters[C]);
 inherited;  
end;

procedure Td2dHGEFont.CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt);
var
 I: Integer;
 l_Char: Char;
 l_CurWidth : Single;
 l_MaxIdx: Integer;
begin
 theSize.X := 0;
 theSize.Y := f_Height * f_Scale;
 l_CurWidth := 0;
 I := 1;
 l_MaxIdx := aLength;
 if l_MaxIdx > Length(aStr) then
  l_MaxIdx := Length(aStr);
 while I <= l_MaxIdx do
 begin
  l_Char := aStr[I];
  if l_Char in [#10, #13] then
  begin
   theSize.Y := theSize.Y + (f_Height * f_Scale * f_Spacing);
   l_CurWidth := 0;
   while (I <= Length(aStr)) and (aStr[I] in [#10, #13]) do
    Inc(I);
   Continue;
  end
  else
  begin
   if not CanRenderChar(l_Char) then
    if l_Char = ' ' then
     l_CurWidth := l_CurWidth + f_Height/4*f_Scale
    else
     l_Char := '?';
   if CanRenderChar(l_Char) then
    with f_Letters[l_Char] do
     l_CurWidth := l_CurWidth + (KernPre + Width + KernPost + f_Tracking)*f_Scale;
   if l_CurWidth > theSize.X then
    theSize.X := l_CurWidth;
  end;
  Inc(I);
 end;
end;

function Td2dHGEFont.CanRenderChar(aChar: Char): Boolean;
begin
 Result := f_Letters[aChar] <> nil;
end;

procedure Td2dHGEFont.DoSetBlendMode(aBlendMode: Integer);
var
 C: Char;
begin
 for C := #0 to #255 do
  if f_Letters[C] <> nil then
   f_Letters[C].BlendMode := aBlendMode;
end;

procedure Td2dHGEFont.DoSetColor(aColor: Td2dColor);
var
 C: Char;
begin
 for C := #0 to #255 do
  if f_Letters[C] <> nil then
   f_Letters[C].SetColor(aColor);
end;

function Td2dHGEFont.pm_GetHeight: Single;
begin
 Result := f_Height;
end;

function Td2dHGEFont.pm_GetSize: Single;
begin
 Result := pm_GetHeight;
end;

procedure Td2dHGEFont.Render(aX, aY: Single; aStr: string);
var
 l_Char: Char;
 l_FX, l_FY  : Single;
 I: Integer;
begin
 l_FX := aX;
 l_FY := aY;
 I := 1;
 while I <= Length(aStr) do
 begin
  l_Char := aStr[I];
  if l_Char in [#10, #13] then
  begin
   l_FY := l_FY + Int(f_Height * f_Scale * f_Spacing);
   l_FX := aX;
   while (I <= Length(aStr)) and (aStr[I] in [#10, #13]) do
    Inc(I);
   Continue;
  end
  else
  begin
   if not CanRenderChar(l_Char) then
    if l_Char = ' ' then
     l_FX := l_FX + Int(f_Height/4*f_Scale)
    else
     l_Char := '?';
   if CanRenderChar(l_Char) then
    with f_Letters[l_Char] do
    begin
     l_FX := l_FX + Int(KernPre * f_Scale);
     RenderEx(l_FX, l_FY, 0.0, f_Scale);
     l_FX := l_FX + Int((Width + KernPost + f_Tracking)*f_Scale);
    end;
  end;
  Inc(I);
 end;
end;

constructor Td2dDXFont.Create(aTypeface: string; aSize: Integer; aBold: Boolean = False);
begin
 inherited Create;
 f_Typeface := aTypeface;
 f_Size := aSize;
 f_Bold := aBold;
 f_Color := $FFFFFFFF;
 RecreateDXFont;
end;

procedure Td2dDXFont.pm_SetBold(const Value: Boolean);
begin
 f_Bold := Value;
end;

procedure Td2dDXFont.pm_SetTypeface(const Value: string);
begin
 f_Typeface := Value;
end;

procedure Td2dDXFont.pm_SetItalic(const Value: Boolean);
begin
 f_Italic := Value;
end;

procedure Td2dDXFont.pm_SetSize(const Value: Integer);
begin
 f_Size := Value;
end;

procedure Td2dDXFont.RecreateDXFont;
var
 lf: TLogFont;
 l_N: Integer;
 I: Integer;
begin
 FillChar(lf, SizeOf(lf), 0);
 with lf do
 begin
  lfHeight := -f_Size;
  if f_Bold then
   lfWeight := FW_BOLD;
  if f_Italic then
   lfItalic := 1;
  lfCharSet := DEFAULT_CHARSET;
  lfOutPrecision := OUT_DEFAULT_PRECIS;
  lfClipPrecision := CLIP_DEFAULT_PRECIS;
  lfQuality := PROOF_QUALITY;
  lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
  l_N := Length(f_Typeface);
  if l_N > 31 then
   l_N := 31;
  for I := 1 to l_N do
   lfFaceName[I-1] := f_Typeface[I];
 end;
 f_Intf := nil;
 D3DXCreateFontIndirect(gD2DE.D3DDevice, lf, f_Intf);
end;

procedure Td2dDXFont.Render(aString: string; aLeft, aTop, aRight, aBottom: Integer; aFlags: Longword = DT_TOP +
    DT_LEFT+DT_NOPREFIX);
var
 l_Rect: TRect;
begin
 l_Rect := Rect(aLeft, aTop, aRight, aBottom);
 gD2DE.FlushPrimitives;
 f_Intf.DrawTextA(PChar(aString), Length(aString), l_Rect, aFlags, f_Color);
end;

function Td2dCustomFont.CalcStringBySize(const aStr: string; aWidth: Single; const aEllipsis: string = '...'): string;
var
 l_Len: Integer;
 l_Size: Td2dPoint;
begin
 Result := aStr;
 l_Len := Length(aStr);
 while True do
 begin
  CalcSize(Result, l_Size);
  if l_Size.X <= aWidth then
   Break;
  Dec(l_Len);
  if l_Len = 0 then
  begin
   Result := '';
   Break;
  end;
  Result := Copy(aStr, 1, l_Len) + aEllipsis;
 end;
end;

function Td2dCustomFont.pm_GetBlendMode: Integer;
begin
 Result := f_BlendMode;
end;

function Td2dCustomFont.pm_GetColor: Longword;
begin
 Result := f_Color;
end;

function Td2dCustomFont.pm_GetID: string;
begin
 Result := f_ID;
end;

procedure Td2dCustomFont.pm_SetBlendMode(const aValue: Integer);
begin
 if f_BlendMode <> aValue then
 begin
  f_BlendMode := aValue;
  DoSetBlendMode(aValue);
 end;
end;

procedure Td2dCustomFont.pm_SetColor(const aValue: Longword);
begin
 if f_Color <> aValue then
 begin
  f_Color := aValue;
  DoSetColor(aValue);
 end;
end;

procedure Td2dCustomFont.pm_SetID(const Value: string);
begin
 f_ID := Value;
end;

constructor Td2dBMFont.Create(const aFilename: string; aFromPack: Boolean = False);
begin
 inherited Create;
 Load(aFilename, aFromPack);
end;

constructor Td2dBMFont.CreateFromXML(aXML: IXmlDocument);
begin
 inherited Create;
 LoadFromXML(aXML);
end;

destructor Td2dBMFont.Destroy;
var
 C: Char;
begin
 for C := #33 to #255 do
  if f_Letters[C] <> nil then
   FreeAndNil(f_Letters[C]);
 inherited;  
end;

procedure Td2dBMFont.CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt);
var
 I: Integer;
 l_Char: Char;
 l_CurWidth : Single;
 l_MaxIdx: Integer;
begin
 theSize.X := 0;
 theSize.Y := f_FontHeight;
 l_CurWidth := 0;
 I := 1;
 l_MaxIdx := aLength;
 if l_MaxIdx > Length(aStr) then
  l_MaxIdx := Length(aStr);
 while I <= l_MaxIdx do
 begin
  l_Char := aStr[I];
  if l_Char in [#10, #13] then
  begin
   theSize.Y := theSize.Y + f_FontHeight;
   l_CurWidth := 0;
   while (I <= Length(aStr)) and (aStr[I] in [#10, #13]) do
    Inc(I);
   Continue;
  end
  else
   if l_Char in [#32, #160] then
    l_CurWidth := l_CurWidth + f_SpaceAdv
   else
   begin
    if not CanRenderChar(l_Char) then
     l_Char := '?';
    if CanRenderChar(l_Char) then
     with f_Letters[l_Char] do
      l_CurWidth := l_CurWidth + XAdvance;
   end;
   if l_CurWidth > theSize.X then
    theSize.X := l_CurWidth;
  Inc(I);
 end;
end;

function Td2dBMFont.CanRenderChar(aChar: Char): Boolean;
begin
 Result := (aChar in [#33..#255]) and (f_Letters[aChar] <> nil);
end;

procedure Td2dBMFont.DoSetBlendMode(aBlendMode: Integer);
var
 C: Char;
begin
 for C := #33 to #255 do
  if f_Letters[C] <> nil then
   f_Letters[C].BlendMode := aBlendMode;
end;

procedure Td2dBMFont.DoSetColor(aColor: Td2dColor);
var
 C: Char;
begin
 for C := #33 to #255 do
  if f_Letters[C] <> nil then
   f_Letters[C].SetColor(aColor);
end;

const
 cMaxBMPages = 100;

procedure Td2dBMFont.LoadFromXML(aXML: IXmlDocument);
var
 l_Tex: Id2dTexture;
 I: Integer;
 l_Node: IXmlNode;
 l_List: IXmlNodeList;
 l_Char: Char;
 l_Code: Integer;
 l_PNGData: string;
 //l_FS: TFileStream;
begin
 if (aXML <> nil) and (aXML.DocumentElement <> nil) then
 begin
  l_Node := aXML.DocumentElement.SelectSingleNode('properties');
  f_FontHeight := l_Node.GetIntAttr('lineheight');
  f_FontSize := l_Node.GetIntAttr('size');
  f_SpaceAdv := l_Node.GetIntAttr('space');

  l_Node := aXML.DocumentElement.SelectSingleNode('png');
  l_PNGData := Base64ToBin(l_Node.Text);
  {
  l_FS := TFileStream.Create('c:\temp\font.png', fmCreate);
  l_FS.Write(l_PNGData[1], Length(l_PNGData));
  FreeAndNil(l_FS);
  }
  l_Tex := gD2DE.Texture_FromMemory(@l_PNGData[1], Length(l_PNGData));

  l_List := aXML.DocumentElement.SelectSingleNode('letters').ChildNodes;
  for I := 0 to l_List.Count-1 do
  begin
   l_Node := l_List.Item[I];
   l_Code := l_Node.GetIntAttr('code');
   Assert((l_Code <= 255) and (l_Code > 32), 'Wrong charcode in BM Font!');
   l_Char := Char(l_Code);
   f_Letters[l_Char] := Td2dBMLetter.Create(l_Tex,
      l_Node.GetIntAttr('tx'), l_Node.GetIntAttr('ty'),
      l_Node.GetIntAttr('w'), l_Node.GetIntAttr('h'));
   f_Letters[l_Char].f_XOffset := l_Node.GetIntAttr('sx');
   f_Letters[l_Char].f_YOffset := l_Node.GetIntAttr('sy');
   f_Letters[l_Char].f_XAdvance := l_Node.GetIntAttr('adv');
  end;
 end;
end;

procedure Td2dBMFont.Load(aFilename: string; aFromPack: Boolean);
var
 l_XML: string;
 l_XMLLen: Longword;
 l_Temp: Pointer;
 l_Doc: IXmlDocument;
begin
 l_Temp := gD2DE.Resource_Load(aFilename, @l_XMLLen, aFromPack);
 if l_Temp <> nil then
 begin
  SetLength(l_XML, l_XMLLen);
  Move(l_Temp^, l_XML[1], l_XMLLen);
  gD2DE.Resource_Free(l_Temp);
  l_Doc := LoadXmlDocumentFromXML(l_XML);
  LoadFromXML(l_Doc);
 end;
end;

function Td2dBMFont.pm_GetHeight: Single;
begin
 Result := f_FontHeight;
end;

function Td2dBMFont.pm_GetSize: Single;
begin
 Result := f_FontSize;
end;

procedure Td2dBMFont.Render(aX, aY: Single; aStr: string);
var
 l_Char: Char;
 l_FX, l_FY  : Single;
 I: Integer;
begin
 l_FX := aX;
 l_FY := aY;
 I := 1;
 while I <= Length(aStr) do
 begin
  l_Char := aStr[I];

  if l_Char in [#10, #13] then
  begin
   l_FY := l_FY + f_FontHeight;
   l_FX := aX;
   while (I <= Length(aStr)) and (aStr[I] in [#10, #13]) do
    Inc(I);
   Continue;
  end
  else
  begin
   if l_Char in [#32, #160] then
    l_FX := l_FX + f_SpaceAdv
   else
   begin
    if not CanRenderChar(l_Char) then
     l_Char := '?';
    if CanRenderChar(l_Char) then
    begin
     with f_Letters[l_Char] do
     begin
      Render(l_FX + XOffset - 1, l_FY+YOffset - 1);
      //D2DRenderRect(D2DRect(l_FX + XOffset, l_FY, l_FX + XAdvance, l_FY + f_FontHeight), $FFFF0000);
      l_FX := l_FX + XAdvance;
     end;
    end
    else
     l_FX := l_FX + f_SpaceAdv;
   end;
  end;
  Inc(I);
 end;
end;

end.
