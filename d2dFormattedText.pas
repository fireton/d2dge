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
unit d2dFormattedText;

interface
uses
 Classes,
 Contnrs,

 d2dTypes,
 d2dInterfaces,
 d2dUtils;

type
 Td2dCustomSlice = class;
 Td2dLinkSlice   = class;
 Td2dCustomTextChunk = class;

 Td2dLinkActionProc  = procedure(const aLinkSlice: Td2dLinkSlice) of object;
 Td2dSliceActionProc = procedure(const aSlice: Td2dCustomSlice) of object;
 Td2dChunkActionProc = procedure(const aChunk: Td2dCustomTextChunk) of object;
 Td2dOnLinkClickEvent = procedure(const aSender: TObject; const aRect: Td2dRect; const aTarget: string) of object;

 Td2dCustomTextChunk = class
 protected
  function pm_GetChunkType: Td2dTextChunkType; virtual;
 public
  procedure Save(aFiler: Td2dFiler); virtual;
  procedure Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider); virtual; abstract;
  property ChunkType: Td2dTextChunkType read pm_GetChunkType;
 end;

 Td2dTextPara = class
 private
  f_IsClosed: Boolean;
  f_List: TObjectList;
  f_ParaType: Td2dTextAlignType;
  function pm_GetChunks(Index: Integer): Td2dCustomTextChunk;
  function pm_GetCount: Integer;
  procedure _DropLink(const aChunk: Td2dCustomTextChunk);
 public
  constructor Create(aParaType: Td2dTextAlignType);
  destructor Destroy; override;
  procedure AddPicture(const aPicture: Id2dPicture; const anID: string = '');
  procedure AddRawChunk(aChunk: Td2dCustomTextChunk);
  procedure AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aForceNewChunk: Boolean = False);
  procedure AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor);
  procedure ClosePara;
  procedure DropLinks;
  procedure IterateChunks(anAction: Td2dChunkActionProc);
  procedure Save(aFiler: Td2dFiler);
  procedure Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
  property Chunks[Index: Integer]: Td2dCustomTextChunk read pm_GetChunks;
  property Count: Integer read pm_GetCount;
  property IsClosed: Boolean read f_IsClosed;
  property ParaType: Td2dTextAlignType read f_ParaType write f_ParaType;
 end;

 Td2dStringChunk = class(Td2dCustomTextChunk)
 private
  f_Font: Id2dFont;
 protected
  f_Color: Td2dColor;
  f_Text: string;
  function pm_GetChunkType: Td2dTextChunkType; override;
 public
  constructor Create(const aText: string; const aFont: Id2dFont; aColor: Td2dColor);
  procedure ConcatText(aText: string);
  procedure Save(aFiler: Td2dFiler); override;
  procedure Load(aFiler: Td2dFiler;  const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider); override;
  property Color: Td2dColor read f_Color write f_Color;
  property Font: Id2dFont read f_Font write f_Font;
  property Text: string read f_Text write f_Text;
 end;

 Td2dLinkChunk = class(Td2dStringChunk)
 private
  f_Active: Boolean;
  f_HighlightColor: Td2dColor;
  f_LinkColor: Td2dColor;
  f_Target: string;
 protected
  function pm_GetChunkType: Td2dTextChunkType; override;
 public
  constructor Create(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor);
  procedure Save(aFiler: Td2dFiler); override;
  procedure Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider); override;
  property Active: Boolean read f_Active write f_Active;
  property HighlightColor: Td2dColor read f_HighlightColor write f_HighlightColor;
  property LinkColor: Td2dColor read f_LinkColor write f_LinkColor;
  property Target: string read f_Target write f_Target;
 end;

 Td2dPictureChunk = class(Td2dCustomTextChunk)
 private
 protected
  f_Picture: Id2dPicture;
  function pm_GetChunkType: Td2dTextChunkType; override;
 public
  procedure Save(aFiler: Td2dFiler); override;
  procedure Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider); override;
  constructor Create(const aPicture: Id2dPicture; const anID: string);
  property Picture: Id2dPicture read f_Picture;
 end;

 Id2dTextAddingTool = interface
  ['{99660309-19E2-4131-8E67-88EDC936D269}']
  procedure AddText(const aText: string);
  procedure AddLink(const aText, aTarget: string);
 end;

 Td2dTextSource = class
 private
  f_ParaList: TObjectList;
  procedure AddTextOrLink(aIsLink: Boolean; const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor,
      aHighlightColor: Td2dColor; aParaType: Td2dTextAlignType);
  function pm_GetParagraphs(Index: Integer): Td2dTextPara;
  function pm_GetCount: Integer;
 public
  constructor Create;
  destructor Destroy; override;
  procedure Clear;
  procedure Save(aFiler: Td2dFiler);
  procedure Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
  function AddRawPara(aParaType: Td2dTextAlignType): Td2dTextPara;
  procedure AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aParaType: Td2dTextAlignType);
  procedure AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor;
      aParaType: Td2dTextAlignType);
  procedure AddPicture(aPicture: Id2dPicture; aAlign: Td2dTextAlignType);
  procedure DropLinks(aFrom: Integer = 0);
  procedure IterateChunks(anAction: Td2dChunkActionProc);
  property Paragraphs[Index: Integer]: Td2dTextPara read pm_GetParagraphs;
  property Count: Integer read pm_GetCount;
 end;

 // Слайс - единица форматированного текста
 Td2dCustomSlice = class
 private
  f_Left: Single;
  f_Parent: Td2dCustomSlice;
  f_Top: Single;
  function pm_GetAbsLeft: Single;
  function pm_GetAbsTop: Single;
 protected
  function pm_GetHeight: Single; virtual; abstract;
  function pm_GetWidth: Single; virtual; abstract;
  procedure DoDraw(X, Y: Single); virtual; abstract;
  function pm_GetSliceType: Td2dTextSliceType; virtual;
  procedure pm_SetWidth(const Value: Single); virtual; abstract;
 public
  procedure Draw(X, Y: Single);
  property AbsLeft: Single read pm_GetAbsLeft;
  property AbsTop: Single read pm_GetAbsTop;
  property Height: Single read pm_GetHeight;
  property Left: Single read f_Left write f_Left;
  property Parent: Td2dCustomSlice read f_Parent write f_Parent;
  property SliceType: Td2dTextSliceType read pm_GetSliceType;
  property Top: Single read f_Top write f_Top;
  property Width: Single read pm_GetWidth write pm_SetWidth;
 end;

 Td2dUnionSlice = class(Td2dCustomSlice)
 private
  f_ChList: TObjectList;
  f_Height: Single;
  f_Parent: Td2dUnionSlice;
  f_Width: Single;
  function pm_GetChildren(Index: Integer): Td2dCustomSlice;
  function pm_GetChildrenCount: Integer;
  function pm_GetChList: TObjectList;
 protected
  function pm_GetHeight: Single; override;
  function pm_GetSliceType: Td2dTextSliceType; override;
  function pm_GetWidth: Single; override;
  procedure pm_SetWidth(const Value: Single); override;
  property ChList: TObjectList read pm_GetChList;
 public
  constructor Create(aWidth: Single);
  destructor Destroy; override;
  procedure AddChild(aChild: Td2dCustomSlice); virtual;
  procedure Clear; virtual;
  procedure DeleteFrom(aIndex : Integer); virtual;
  procedure DoDraw(X, Y: Single); override;
  procedure IterateLeafSlices(anAction: Td2dSliceActionProc; aFrom: Integer = 0);
  procedure RecalcHeight;
  property Children[Index: Integer]: Td2dCustomSlice read pm_GetChildren;
  property ChildrenCount: Integer read pm_GetChildrenCount;
  property Parent: Td2dUnionSlice read f_Parent write f_Parent;
 end;

 Td2dTextSlice = class(Td2dCustomSlice)
 private
  f_Color: Td2dColor;
  f_Size : Td2dPoint;
  procedure CalcSize;
 protected
  f_Font: Id2dFont;
  f_Text : string;
  procedure DoDraw(X, Y: Single); override;
  function pm_GetHeight: Single; override;
  function pm_GetSliceType: Td2dTextSliceType; override;
  function pm_GetWidth: Single; override;
 public
  constructor Create(const aText: string; const aFont: Id2dFont; aColor: Td2dColor);
  property Color: Td2dColor read f_Color write f_Color;
 end;

 Td2dPictureSlice = class(Td2dCustomSlice)
 private
  f_Picture : Id2dPicture;
 protected
  function pm_GetHeight: Single; override;
  function pm_GetSliceType: Td2dTextSliceType; override;
  function pm_GetWidth: Single; override;
 public
  constructor Create(const aPicture: Id2dPicture);
  procedure DoDraw(X, Y: Single); override;
 end;

 Td2dFormatParamsRec = record
  rLineSpacing: Single;
  rParaSpacing: Single;
 end;

 // Formatter
 Td2dFormatter = class
 private
  f_Document: Td2dUnionSlice;
  f_FormatParams: Td2dFormatParamsRec;
  f_LastFormatted: Integer;
  f_TextSource: Td2dTextSource;
  procedure FormatFrom(aParaIndex: Integer);
  function FormatParagraph(aParaIdx: Integer): Td2dUnionSlice;
  procedure pm_SetLastFormatted(const Value: Integer);
 public
  constructor Create(aTS: Td2dTextSource; aDoc: Td2dUnionSlice);
  procedure Format;
  procedure ReformatAll;
  procedure UpdateFormat;
  property FormatParams: Td2dFormatParamsRec read f_FormatParams write f_FormatParams;
  property LastFormatted: Integer read f_LastFormatted write pm_SetLastFormatted;
 end;

 Td2dLinkSlice = class(Td2dTextSlice)
 private
  f_Allowed: Boolean;
  f_HighlightColor: Td2dColor;
  f_IsActive: Boolean;
  f_IsHighlighted: Boolean;
  f_LinkColor: Td2dColor;
  f_Next: Td2dLinkSlice;
  f_Prev: Td2dLinkSlice;
  f_Target: string;
 protected
  procedure DoDraw(X, Y: Single); override;
  function pm_GetSliceType: Td2dTextSliceType; override;
 public
  constructor Create(const aText, aTarget: string; const aFont: Id2dFont; aTextColor, aLinkColor, aHighlightColor: Td2dColor);
  function GetLinkText: string;
  procedure SpreadHighlight;
  property Allowed: Boolean read f_Allowed write f_Allowed;
  property HighlightColor: Td2dColor read f_HighlightColor write f_HighlightColor;
  property IsActive: Boolean read f_IsActive write f_IsActive;
  property IsHighlighted: Boolean read f_IsHighlighted write f_IsHighlighted;
  property LinkColor: Td2dColor read f_LinkColor write f_LinkColor;
  property Next: Td2dLinkSlice read f_Next write f_Next;
  property Prev: Td2dLinkSlice read f_Prev write f_Prev;
  property Target: string read f_Target write f_Target;
 end;

implementation
uses
 SysUtils,
 d2dCore,
 StrUtils;

type
 TChunkCursor = record
  rChunk: Integer;
  rPos  : Integer;
 end;

const
 csClosedPara = 'Параграф уже закрыт!';

type
 Td2dTextChunkClass = class of Td2dCustomTextChunk;

function TextChunkType2Class(const aType: Td2dTextChunkType): Td2dTextChunkClass;
begin
 case aType of
  ctText: Result    := Td2dStringChunk;
  ctLink: Result    := Td2dLinkChunk;
  ctPicture: Result := Td2dPictureChunk;
 else
  Result := nil;
 end;
end;

function d2dLoadChunk(const aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider): Td2dCustomTextChunk;
var
 l_CP: Td2dTextChunkType;
 l_ChunkClass: Td2dTextChunkClass;
begin
 l_CP := Td2dTextChunkType(aFiler.ReadByte);
 l_ChunkClass := TextChunkType2Class(l_CP);
 if l_ChunkClass <> nil then
 begin
  Result := l_ChunkClass.Create;
  Result.Load(aFiler, aFP, aPP);
 end
 else
  Result := nil;
end;


function Td2dCustomTextChunk.pm_GetChunkType: Td2dTextChunkType;
begin
 Result := ctUndefined;
end;

procedure Td2dCustomTextChunk.Save(aFiler: Td2dFiler);
begin
 aFiler.WriteByte(Ord(ChunkType));
end;

constructor Td2dStringChunk.Create(const aText: string; const aFont: Id2dFont; aColor: Td2dColor);
begin
 inherited Create;
 f_Text := aText;
 f_Font := aFont;
 f_Color := aColor;
end;

procedure Td2dStringChunk.ConcatText(aText: string);
begin
 f_Text := f_Text + aText;
end;

procedure Td2dStringChunk.Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
var
 l_FN: string;
begin
 l_FN := aFiler.ReadString;
 f_Font := aFP.GetByID(l_FN);
 f_Color := aFiler.ReadColor;
 f_Text := aFiler.ReadString;
end;

function Td2dStringChunk.pm_GetChunkType: Td2dTextChunkType;
begin
 Result := ctText;
end;

procedure Td2dStringChunk.Save(aFiler: Td2dFiler);
begin
 inherited;
 aFiler.WriteString(f_Font.ID);
 aFiler.WriteColor(f_Color);
 aFiler.WriteString(f_Text);
end;

constructor Td2dTextSource.Create;
begin
 inherited;
 f_ParaList := TObjectList.Create(True);
end;

destructor Td2dTextSource.Destroy;
begin
 f_ParaList.Free;
 inherited;
end;

procedure Td2dTextSource.AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor,
    aHighlightColor: Td2dColor; aParaType: Td2dTextAlignType);
begin
 AddTextOrLink(True, aText, aTarget, aFont, aColor, aLinkColor, aHighlightColor, aParaType);
end;

procedure Td2dTextSource.AddPicture(aPicture: Id2dPicture; aAlign: Td2dTextAlignType);
var
// l_Picture: Id2dPicture;
 l_Para: Td2dTextPara;
begin
 {
 if (aWidth = 0) then
  aWidth := gD2DE.Texture_GetWidth(aTex) - aTX;
 if (aHeight = 0) then
  aHeight := gD2DE.Texture_GetHeight(aTex) - aTY;
 if (aWidth < 1) or (aHeight < 1) then
  Exit;
 l_Picture := Id2dPicture.Create(aTex, aTX, aTY, aWidth, aHeight);
 l_Picture.SetColor(aColor);
 }
 if Count > 0 then
 begin
  l_Para := Paragraphs[Pred(Count)];
  if (l_Para.IsClosed) or (l_Para.ParaType <> aAlign) then
   l_Para := AddRawPara(aAlign);
 end
 else
  l_Para := AddRawPara(aAlign);
 l_Para.AddPicture(aPicture); 
end;

function Td2dTextSource.AddRawPara(aParaType: Td2dTextAlignType): Td2dTextPara;
begin
 Result := Td2dTextPara.Create(aParaType);
 f_ParaList.Add(Result);
end;

procedure Td2dTextSource.AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aParaType:
    Td2dTextAlignType);
begin
 AddTextOrLink(False, aText, '', aFont, aColor, 0, 0, aParaType);
end;

procedure Td2dTextSource.AddTextOrLink(aIsLink: Boolean; const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor;
   aParaType: Td2dTextAlignType);
var
 l_Para: Td2dTextPara;
 l_Pos: Integer;
 l_SubStr: string;
 l_Text  : string;

 procedure AddToPara(aStr: string; aDoClose: Boolean);
 begin
  if l_Para = nil then
   l_Para := AddRawPara(aParaType);
  if aIsLink then
   l_Para.AddLink(aStr, aTarget, aFont, aColor, aLinkColor, aHighlightColor)
  else
   l_Para.AddText(aStr, aFont, aColor);
  if aDoClose then
  begin
   l_Para.ClosePara;
   l_Para := nil;
  end;
 end;

begin
 l_Text := aText;
 if Count > 0 then
 begin
  l_Para := Paragraphs[Pred(Count)];
  if (l_Para.IsClosed) or (l_Para.ParaType <> aParaType) then
   l_Para := nil;
 end
 else
  l_Para := nil;

 l_Pos := Pos(#13#10, l_Text);
 while l_Pos > 0 do
 begin
  l_SubStr := Copy(l_Text, 1, l_Pos-1);
  AddToPara(l_SubStr, True);
  Delete(l_Text, 1, l_Pos+1);
  l_Pos := Pos(#13#10, l_Text);
 end;
 if l_Text <> '' then
  AddToPara(l_Text, False);
end;

procedure Td2dTextSource.Clear;
begin
 f_ParaList.Clear;
end;

procedure Td2dTextSource.DropLinks(aFrom: Integer = 0);
var
 I: Integer;
begin
 for I := aFrom to Count - 1 do
  Paragraphs[I].DropLinks;
end;

procedure Td2dTextSource.IterateChunks(anAction: Td2dChunkActionProc);
var
 I: Integer;
begin
 for I := 0 to Count - 1 do
  Paragraphs[I].IterateChunks(anAction);
end;

procedure Td2dTextSource.Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
var
 I: Integer;
 l_Count: Integer;
 l_Para: Td2dTextPara;
begin
 Clear;
 l_Count := aFiler.ReadInteger;
 for I := 1 to l_Count do
 begin
  l_Para := Td2dTextPara.Create(ptLeftAligned);
  l_Para.Load(aFiler, aFP, aPP);
  f_ParaList.Add(l_Para);
 end;
end;

function Td2dTextSource.pm_GetParagraphs(Index: Integer): Td2dTextPara;
begin
 Result := Td2dTextPara(f_ParaList[Index]);
end;

function Td2dTextSource.pm_GetCount: Integer;
begin
 Result := f_ParaList.Count;
end;

procedure Td2dTextSource.Save(aFiler: Td2dFiler);
var
 I: Integer;
begin
 aFiler.WriteInteger(Count);
 for I := 0 to Count-1 do
  Paragraphs[I].Save(aFiler);
end;

constructor Td2dTextPara.Create(aParaType: Td2dTextAlignType);
begin
 inherited Create;
 f_ParaType := aParaType; 
 f_List := TObjectList.Create(True);
end;

destructor Td2dTextPara.Destroy;
begin
 f_List.Free;
 inherited;
end;

procedure Td2dTextPara.AddPicture(const aPicture: Id2dPicture; const anID: string = '');
var
 l_Chunk: Td2dPictureChunk;
begin
 l_Chunk := Td2dPictureChunk.Create(aPicture, anID);
 f_List.Add(l_Chunk)
end;

procedure Td2dTextPara.AddRawChunk(aChunk: Td2dCustomTextChunk);
begin
 Assert(not IsClosed, csClosedPara);
 f_List.Add(aChunk);
end;

procedure Td2dTextPara.AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aForceNewChunk: Boolean = False);
var
 l_Chunk: Td2dCustomTextChunk;
begin
 Assert(not IsClosed, csClosedPara);
 if f_List.Count > 0 then
 begin
  l_Chunk := Td2dCustomTextChunk(f_List[Pred(f_List.Count)]);
  if (not aForceNewChunk) and (l_Chunk.ChunkType = ctText) and
     (Td2dStringChunk(l_Chunk).Font = aFont) and
     (Td2dStringChunk(l_Chunk).Color = aColor) then
  begin
   Td2dStringChunk(l_Chunk).ConcatText(aText);
   Exit;
  end;
 end;
 l_Chunk := Td2dStringChunk.Create(aText, aFont, aColor);
 f_List.Add(l_Chunk);
end;

procedure Td2dTextPara.AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor);
var
 l_Chunk: Td2dCustomTextChunk;
begin
 Assert(not IsClosed, csClosedPara);
 l_Chunk := Td2dLinkChunk.Create(aText, aTarget, aFont, aColor, aLinkColor, aHighlightColor);
 f_List.Add(l_Chunk);
end;

procedure Td2dTextPara.ClosePara;
begin
 f_IsClosed := True;
end;

procedure Td2dTextPara.DropLinks;
begin
 IterateChunks(_DropLink);
end;

procedure Td2dTextPara._DropLink(const aChunk: Td2dCustomTextChunk);
begin
 if aChunk.ChunkType = ctLink then
  Td2dLinkChunk(aChunk).Active := False;
end;

procedure Td2dTextPara.IterateChunks(anAction: Td2dChunkActionProc);
var
 I: Integer;
begin
 for I := 0 to Count - 1 do
  anAction(Chunks[I]);
end;

procedure Td2dTextPara.Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
var
 I: Integer;
 l_Count: Integer;
 l_Chunk: Td2dCustomTextChunk;
begin
 f_List.Clear;
 f_ParaType := Td2dTextAlignType(aFiler.ReadByte);
 f_IsClosed := aFiler.ReadBoolean;
 l_Count := aFiler.ReadInteger;
 for I := 1 to l_Count do
 begin
  l_Chunk := d2dLoadChunk(aFiler, aFP, aPP); // фабрика
  if l_Chunk <> nil then
   f_List.Add(l_Chunk);
 end;
end;

function Td2dTextPara.pm_GetChunks(Index: Integer): Td2dCustomTextChunk;
begin
 Result := Td2dCustomTextChunk(f_List[Index]);
end;

function Td2dTextPara.pm_GetCount: Integer;
begin
 Result := f_List.Count;
end;

procedure Td2dTextPara.Save(aFiler: Td2dFiler);
var
 I: Integer;
begin
 aFiler.WriteByte(Ord(f_ParaType));
 aFiler.WriteBoolean(f_IsClosed);
 aFiler.WriteInteger(Count);
 for I := 0 to Count-1 do
  Chunks[I].Save(aFiler);
end;

constructor Td2dUnionSlice.Create(aWidth: Single);
begin
 inherited Create;
 f_Width := aWidth;
end;

destructor Td2dUnionSlice.Destroy;
begin
 if f_ChList <> nil then
  FreeAndNil(f_ChList);
 inherited;
end;

procedure Td2dUnionSlice.AddChild(aChild: Td2dCustomSlice);
begin
 ChList.Add(aChild);
 aChild.Parent := Self;
end;

procedure Td2dUnionSlice.DoDraw(X, Y: Single);
var
 I  : Integer;
 l_Child: Td2dCustomSlice;
begin
 for I := 0 to Pred(ChildrenCount) do
 begin
   l_Child := Children[I];
   l_Child.Draw(X, Y);
  end;
end;

function Td2dUnionSlice.pm_GetChildren(Index: Integer): Td2dCustomSlice;
begin
 Result := Td2dCustomSlice(ChList[Index]);
end;

function Td2dUnionSlice.pm_GetChildrenCount: Integer;
begin
 if f_ChList = nil then
  Result := 0
 else
  Result := f_ChList.Count; 
end;

function Td2dUnionSlice.pm_GetChList: TObjectList;
begin
 if f_ChList = nil then
  f_ChList := TObjectList.Create(True);
 Result := f_ChList;
end;

function Td2dUnionSlice.pm_GetHeight: Single;
begin
 Result := f_Height;
end;

function Td2dUnionSlice.pm_GetWidth: Single;
begin
 Result := f_Width;
end;

procedure Td2dUnionSlice.RecalcHeight;
var
 I: Integer;
 l_Child: Td2dCustomSlice;
 l_FarPoint: Single;
begin
 f_Height := 0;
 for I := 0 to Pred(ChildrenCount) do
 begin
  l_Child := Children[I];
  l_FarPoint := l_Child.Top + l_Child.Height;
  if l_FarPoint > f_Height then
   f_Height := l_FarPoint;
 end;
end;

procedure Td2dUnionSlice.Clear;
var
 I: Integer;
begin
 if f_ChList <> nil then
 begin
  for I := 0 to Pred(ChildrenCount) do
  begin
   if Children[I].SliceType = stUnion then
    Td2dUnionSlice(Children[I]).Clear;
  end;
  f_ChList.Clear;
 end;
end;

procedure Td2dUnionSlice.DeleteFrom(aIndex : Integer);
var
 I: Integer;
begin
 for I := Pred(ChildrenCount) downto aIndex do
  ChList.Delete(I);
 RecalcHeight;
end;

procedure Td2dUnionSlice.IterateLeafSlices(anAction: Td2dSliceActionProc; aFrom: Integer = 0);

 procedure ScanForLinkSlices(const aSlice: Td2dCustomSlice);
 var
  J: Integer;
  l_UC: Td2dUnionSlice;
 begin
  if aSlice.SliceType = stUnion then
  begin
   l_UC := Td2dUnionSlice(aSlice);
   l_UC.IterateLeafSlices(anAction);
  end
  else
   anAction(aSlice);
 end;

var
 I: Integer;
begin
 for I := aFrom to ChildrenCount-1 do
  ScanForLinkSlices(Children[I]);
end;

function Td2dUnionSlice.pm_GetSliceType: Td2dTextSliceType;
begin
 Result := stUnion;
end;

procedure Td2dUnionSlice.pm_SetWidth(const Value: Single);
begin
 f_Width := Value;
end;

constructor Td2dTextSlice.Create(const aText: string; const aFont: Id2dFont; aColor: Td2dColor);
begin
 inherited Create;
 f_Text := aText;
 f_Font := aFont;
 f_Color := aColor;
end;

procedure Td2dTextSlice.CalcSize;
begin
 f_Font.CalcSize(f_Text, f_Size);
end;

procedure Td2dTextSlice.DoDraw(X, Y: Single);
begin
 f_Font.Color := f_Color;
 f_Font.Render(X, Y, f_Text);
 //D2DRenderRect(D2DRect(X, Y, X+Width, Y+Height), $FFFF0000);
end;

function Td2dTextSlice.pm_GetHeight: Single;
begin
 if f_Size.Y = 0 then
  CalcSize;
 Result := f_Size.Y;
end;

function Td2dTextSlice.pm_GetSliceType: Td2dTextSliceType;
begin
 Result := stText;
end;

function Td2dTextSlice.pm_GetWidth: Single;
begin
 if f_Size.X = 0 then
  CalcSize;
 Result := f_Size.X;
end;

constructor Td2dFormatter.Create(aTS: Td2dTextSource; aDoc: Td2dUnionSlice);
begin
 inherited Create;
 f_TextSource := aTS;
 f_Document := aDoc;
 f_LastFormatted := 0;
end;

procedure Td2dFormatter.Format;
begin
 FormatFrom(f_LastFormatted);
end;

procedure Td2dFormatter.FormatFrom(aParaIndex: Integer);
var
 I        : Integer;
 l_Para   : Td2dUnionSlice;
 l_CurTop : Single;
begin
 // first, delete paragraphs starting from aParaIndex
 f_Document.DeleteFrom(aParaIndex);
 if f_Document.ChildrenCount = 0 then
  l_CurTop := 0.0
 else
  with f_Document.Children[Pred(f_Document.ChildrenCount)] do
   l_CurTop := Top + Height + f_FormatParams.rParaSpacing;

 for I := aParaIndex to Pred(f_TextSource.Count) do
 begin
  l_Para := FormatParagraph(I);
  l_Para.Top := l_CurTop;
  l_CurTop := l_CurTop + l_Para.Height + f_FormatParams.rParaSpacing;
  f_Document.AddChild(l_Para);
 end;
 f_Document.RecalcHeight;
end;

function Td2dFormatter.FormatParagraph(aParaIdx: Integer): Td2dUnionSlice;
var
 l_Para         : Td2dTextPara;
 l_ParaSlice    : Td2dUnionSlice;
 l_Line         : Td2dUnionSlice;
 l_Start        : TChunkCursor;
 l_LastBreak    : TChunkCursor;
 l_LastNewBreak : TChunkCursor;
 l_NewBreak     : TChunkCursor;
 l_IsEnd : Boolean;
 l_CurPos: Td2dPoint;
 l_Slice : Td2dCustomSlice;
 I, J    : Integer;
 l_LWidth: Single;
 l_LastLinkChunk : Td2dLinkChunk;
 l_LastLinkSlice : Td2dLinkSlice;

 function CalcTextWidth(aChunk: Integer; aFrom, aTo: Integer): Single;
 var
  l_Str: string;
  l_Size: Td2dPoint;
 begin
  Assert(l_Para.Chunks[aChunk].ChunkType in [ctText, ctLink]);
  l_Str := Copy(Td2dStringChunk(l_Para.Chunks[aChunk]).Text, aFrom, aTo - aFrom + 1);
  Td2dStringChunk(l_Para.Chunks[aChunk]).Font.CalcSize(l_Str, l_Size);
  Result := l_Size.X;
 end;

 function CalcWidth(aFrom, aTo: TChunkCursor): Single;
 var
  l_From: TChunkCursor;
 begin
  Assert((aFrom.rChunk <= aTo.rChunk));
  Result := 0;
  l_From := aFrom;
  while l_From.rChunk < aTo.rChunk do
  begin
   case l_Para.Chunks[l_From.rChunk].ChunkType of
    ctText, ctLink : Result := Result + CalcTextWidth(l_From.rChunk, l_From.rPos, MaxInt);
    ctPicture      : Result := Result + Td2dPictureChunk(l_Para.Chunks[l_From.rChunk]).Picture.Width;
   end;
   Inc(l_From.rChunk);
   l_From.rPos := 1;
  end;
  case l_Para.Chunks[l_From.rChunk].ChunkType of
   ctText, ctLink  : Result := Result + CalcTextWidth(l_From.rChunk, l_From.rPos, aTo.rPos);
   ctPicture       : Result := Result + Td2dPictureChunk(l_Para.Chunks[l_From.rChunk]).Picture.Width;
  end;
 end;

 function IncChunkCursor(var theCur: TChunkCursor): Boolean;
 var
  l_Ch: Td2dCustomTextChunk;
  l_CC: TChunkCursor;
 begin
  l_CC := theCur;
  l_Ch := l_Para.Chunks[l_CC.rChunk];
  case l_Ch.ChunkType of
   ctText, ctLink:
    begin
     Inc(l_CC.rPos);
     if l_CC.rPos > Length(Td2dStringChunk(l_Ch).f_Text) then
     begin
      Inc(l_CC.rChunk);
      l_CC.rPos := 1;
     end;
    end;
   ctPicture:
    begin
     Inc(l_CC.rChunk);
     l_CC.rPos := 1;
    end;
  end;
  Result := l_CC.rChunk < l_Para.Count;
  if Result then
   theCur := l_CC;
 end;

 function ScanToNextBreak(var theCur: TChunkCursor): Boolean;
 var
  l_Text: string;
  l_Changed: Boolean;
 begin
  Result := False;
  // if current chunk is picture then break would be at the beginning of a next chunk
  if l_Para.Chunks[theCur.rChunk].ChunkType = ctPicture then
  begin
   if Pred(l_Para.Count) = theCur.rChunk then
    Result := True
   else
   begin
    Inc(theCur.rChunk);
    theCur.rPos := 1;
   end;
   Exit;
  end;
  l_Changed := False;
  while True do
  begin
   l_Text := Td2dStringChunk(l_Para.Chunks[theCur.rChunk]).Text;
   while theCur.rPos < Length(l_Text) do
   begin
    l_Changed := True;
    Inc(theCur.rPos);
    if l_Text[theCur.rPos] in [' ', '-'] then
     Exit;
   end;
   if Pred(l_Para.Count) = theCur.rChunk then
   begin
    Result := True; // it's
    Exit;
   end;
   if l_Para.Chunks[theCur.rChunk+1].ChunkType = ctPicture then
   begin
    if not l_Changed then
    begin
     Inc(theCur.rChunk);
     theCur.rPos := 1;
    end;
    Exit;
   end;
   Inc(theCur.rChunk);
   theCur.rPos := 1;
  end;
 end;

 function CompareCursors(const aCur1, aCur2: TChunkCursor): Integer;
 begin
  if aCur1.rChunk < aCur2.rChunk then
   Result := -1
  else
  if aCur1.rChunk > aCur2.rChunk then
   Result := 1
  else
  if aCur1.rPos < aCur2.rPos then
   Result := -1
  else
  if aCur1.rPos > aCur2.rPos then
   Result := 1
  else
   Result := 0;
 end;

 function FlushChunkToLine(const aLine: Td2dUnionSlice; const aCur: TChunkCursor; const aTo: Integer = MaxInt): Td2dCustomSlice;
 var
  l_Slice: Td2dCustomSlice;
  l_TC: Td2dStringChunk;
  l_LC: Td2dLinkChunk;
  l_LS: Td2dLinkSlice;
 begin
  l_Slice := nil;
  case l_Para.Chunks[aCur.rChunk].ChunkType of
   ctText:
    begin
     l_TC := Td2dStringChunk(l_Para.Chunks[aCur.rChunk]);
     l_Slice := Td2dTextSlice.Create(Copy(l_TC.Text, aCur.rPos, aTo-aCur.rPos+1), l_TC.Font, l_TC.Color);
     aLine.AddChild(l_Slice);
    end;
   ctLink:
    begin
     l_LC := Td2dLinkChunk(l_Para.Chunks[aCur.rChunk]);
     l_LS := Td2dLinkSlice.Create(Copy(l_LC.Text, aCur.rPos, aTo-aCur.rPos+1),
        l_LC.Target, l_LC.Font, l_LC.Color, l_LC.f_LinkColor, l_LC.f_HighlightColor);
     l_LS.IsActive := l_LC.Active;
     aLine.AddChild(l_LS);
     if (l_LC = l_LastLinkChunk) and (l_LastLinkSlice <> nil) then
     begin
      l_LastLinkSlice.Next := l_LS;
      l_LS.Prev := l_LastLinkSlice;
     end;
     l_LastLinkChunk := l_LC;
     l_LastLinkSlice := l_LS;
    end;
   ctPicture :
    begin
     l_Slice := Td2dPictureSlice.Create(Td2dPictureChunk(l_Para.Chunks[aCur.rChunk]).Picture);
     aLine.AddChild(l_Slice);
    end;
  end;
  Result := l_Slice;
 end;

 procedure FlushToLine(const aStart, aFinish: TChunkCursor);
 var
  l_Cur: TChunkCursor;
  l_Line: Td2dUnionSlice;
 begin
  l_Cur := aStart;
  l_Line := Td2dUnionSlice.Create(f_Document.Width);
  l_ParaSlice.AddChild(l_Line);
  while CompareCursors(l_Cur, aFinish) <= 0 do
  begin
   if l_Cur.rChunk < aFinish.rChunk then
   begin
    FlushChunkToLine(l_Line, l_Cur);
    Inc(l_Cur.rChunk);
    l_Cur.rPos := 1;
   end
   else
   begin
    FlushChunkToLine(l_Line, l_Cur, aFinish.rPos);
    Exit;
   end;
  end;
 end;

 function IsChunkAHugePicture(const aChunk: Td2dCustomTextChunk): Boolean;
 var
  l_PC: Td2dPictureChunk;
 begin
  Result := False;
  if (aChunk.ChunkType = ctPicture) then
  begin
   l_PC := Td2dPictureChunk(aChunk);
   Result := l_PC.Picture.Width > f_Document.Width;
  end;
 end;

const
 cZeroPos: TChunkCursor = (rChunk:0;rPos:0);

begin
 l_LastLinkChunk := nil;
 l_Para := f_TextSource.Paragraphs[aParaIdx];
 l_ParaSlice := Td2dUnionSlice.Create(f_Document.Width);
 l_Start.rChunk := 0;
 l_Start.rPos   := 1;
 l_NewBreak := l_Start;
 l_LastBreak := cZeroPos;
 l_IsEnd := False;
 while not l_IsEnd do
 begin
  l_IsEnd := ScanToNextBreak(l_NewBreak);
  if (CalcWidth(l_Start, l_NewBreak) > f_Document.Width) and (CompareCursors(l_Start, l_NewBreak) <> 0) then
  begin
   // if width of newly found piece is wider than document width and
   // it is not the last char in paragraph then...
   if not IsChunkAHugePicture(l_Para.Chunks[l_Start.rChunk]) then
    l_IsEnd := False;
   if CompareCursors(l_Start, l_LastBreak) > 0 then // if first break gives too much width...
   begin
    l_NewBreak := l_Start; // let's break it
    l_LastNewBreak := l_NewBreak;
    IncChunkCursor(l_NewBreak);
    while (CalcWidth(l_Start, l_NewBreak) < f_Document.Width) do
    begin
     l_LastNewBreak := l_NewBreak;
     IncChunkCursor(l_NewBreak);
    end;
    l_NewBreak := l_LastNewBreak;
    l_LastBreak := l_NewBreak;
   end;
   FlushToLine(l_Start, l_LastBreak);
   l_Start := l_LastBreak;
   IncChunkCursor(l_Start);
   l_NewBreak := l_Start;
  end
  else
  begin
   if l_IsEnd then
    FlushToLine(l_Start, l_NewBreak);
   l_LastBreak := l_NewBreak;
  end;
 end;

 // arrange the data inside lines and lines themselves
 l_CurPos.Y := 0;
 for I := 0 to Pred(l_ParaSlice.ChildrenCount) do
 begin
  l_Line := Td2dUnionSlice(l_ParaSlice.Children[I]);
  l_Line.RecalcHeight;
  l_Line.Top := l_CurPos.Y;
  l_LWidth := 0;
  if l_Para.ParaType <> ptLeftAligned then
  begin
   // Calc the width of the line
   for J := 0 to Pred(l_Line.ChildrenCount) do
   begin
    l_Slice := l_Line.Children[J];
    l_LWidth := l_LWidth + l_Slice.Width;
   end;
   case l_Para.ParaType of
    ptRightAligned: l_CurPos.X := l_Line.Width - l_LWidth;
    ptCentered    : l_CurPos.X := Int((l_Line.Width - l_LWidth)/2 + 0.5); // pixel rounding
   end;
  end
  else
   l_CurPos.X := 0;

  // place slices
  for J := 0 to Pred(l_Line.ChildrenCount) do
  begin
   l_Slice := l_Line.Children[J];
   l_Slice.Top := l_Line.Height - l_Slice.Height;
   l_Slice.Left := l_CurPos.X;
   l_CurPos.X := l_CurPos.X + l_Slice.Width;
  end;
  l_CurPos.Y := l_CurPos.Y + l_Line.Height + f_FormatParams.rLineSpacing;
 end;
 l_ParaSlice.RecalcHeight;
 f_LastFormatted := aParaIdx;
 Result := l_ParaSlice;
end;

procedure Td2dFormatter.pm_SetLastFormatted(const Value: Integer);
begin
 f_LastFormatted := Value;
 if f_LastFormatted < 0 then
  f_LastFormatted := 0;
end;

procedure Td2dFormatter.ReformatAll;
begin
 FormatFrom(0);
end;

procedure Td2dFormatter.UpdateFormat;
begin
 FormatFrom(f_LastFormatted);
end;

procedure Td2dCustomSlice.Draw(X, Y: Single);
begin
 DoDraw(X+Left, Y+Top);
end;

function Td2dCustomSlice.pm_GetAbsLeft: Single;
var
 l_Par: Td2dCustomSlice;
begin
 Result := Left;
 l_Par := f_Parent;
 while l_Par <> nil do
 begin
  Result := Result + l_Par.Left;
  l_Par := l_Par.Parent;
 end;
end;

function Td2dCustomSlice.pm_GetAbsTop: Single;
var
 l_Par: Td2dCustomSlice;
begin
 Result := Top;
 l_Par := f_Parent;
 while l_Par <> nil do
 begin
  Result := Result + l_Par.Top;
  l_Par := l_Par.Parent;
 end;
end;

function Td2dCustomSlice.pm_GetSliceType: Td2dTextSliceType;
begin
 Result := stUnknown;
end;

constructor Td2dPictureChunk.Create(const aPicture: Id2dPicture; const anID: string);
begin
 inherited Create;
 f_Picture := aPicture;
end;

procedure Td2dPictureChunk.Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
var
 l_ID: string;
begin
 l_ID := aFiler.ReadString;
 f_Picture := aPP.GetByID(l_ID);
end;

function Td2dPictureChunk.pm_GetChunkType: Td2dTextChunkType;
begin
 Result := ctPicture;
end;

procedure Td2dPictureChunk.Save(aFiler: Td2dFiler);
begin
 inherited;
 aFiler.WriteString(f_Picture.ID);
end;

constructor Td2dPictureSlice.Create(const aPicture: Id2dPicture);
begin
 inherited Create;
 f_Picture := aPicture;
end;

procedure Td2dPictureSlice.DoDraw(X, Y: Single);
begin
 f_Picture.Render(X, Y);
end;

function Td2dPictureSlice.pm_GetHeight: Single;
begin
 Result := f_Picture.Height;
end;

function Td2dPictureSlice.pm_GetSliceType: Td2dTextSliceType;
begin
 Result := stPicture;
end;

function Td2dPictureSlice.pm_GetWidth: Single;
begin
 Result := f_Picture.Width;
end;

constructor Td2dLinkSlice.Create(const aText, aTarget: string; const aFont: Id2dFont; aTextColor, aLinkColor, aHighlightColor: Td2dColor);
begin
 inherited Create(aText, aFont, aTextColor);
 f_Target := aTarget;
 f_LinkColor := aLinkColor;
 f_HighlightColor := aHighlightColor;
 f_IsActive := True;
 f_Allowed := True;
end;

procedure Td2dLinkSlice.DoDraw(X, Y: Single);
begin
 if f_Allowed and f_IsActive then
 begin
  if f_IsHighlighted then
   f_Font.Color := f_HighlightColor
  else
   f_Font.Color := f_LinkColor;
 end
 else
  f_Font.Color := f_Color;
 f_Font.Render(X, Y, f_Text);
end;

function Td2dLinkSlice.GetLinkText: string;
var
 l_Sibling: Td2dLinkSlice;
begin
 l_Sibling := Self;
 while l_Sibling.Prev <> nil do
  l_Sibling := l_Sibling.Prev;
 Result := '';
 repeat
  Result := Result + l_Sibling.f_Text;
  l_Sibling := l_Sibling.Next;
 until l_Sibling = nil;
end;

function Td2dLinkSlice.pm_GetSliceType: Td2dTextSliceType;
begin
 Result := stLink;
end;

procedure Td2dLinkSlice.SpreadHighlight;
var
 l_Sibling: Td2dLinkSlice;
begin
 l_Sibling := f_Prev;
 while l_Sibling <> nil do
 begin
  l_Sibling.IsHighlighted := IsHighlighted;
  l_Sibling := l_Sibling.Prev;
 end;
 l_Sibling := f_Next;
 while l_Sibling <> nil do
 begin
  l_Sibling.IsHighlighted := IsHighlighted;
  l_Sibling := l_Sibling.Next;
 end;
end;

constructor Td2dLinkChunk.Create(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighlightColor: Td2dColor);
begin
 inherited Create(aText, aFont, aColor);
 f_Target := aTarget;
 f_LinkColor := aLinkColor;
 f_HighlightColor := aHighlightColor;
 f_Active := True;
end;

procedure Td2dLinkChunk.Load(aFiler: Td2dFiler; const aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
begin
 inherited;
 f_Active := aFiler.ReadBoolean;
 f_HighlightColor := aFiler.ReadColor;
 f_LinkColor := aFiler.ReadColor;
 f_Target := aFiler.ReadString;
end;

function Td2dLinkChunk.pm_GetChunkType: Td2dTextChunkType;
begin
 Result := ctLink
end;

procedure Td2dLinkChunk.Save(aFiler: Td2dFiler);
begin
 inherited;
 aFiler.WriteBoolean(f_Active);
 aFiler.WriteColor(f_HighlightColor);
 aFiler.WriteColor(f_LinkColor);
 aFiler.WriteString(f_Target);
end;

end.
