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
unit d2dStaticText;

interface
uses
 d2dTypes,
 d2dInterfaces,
 d2dFormattedText,
 d2dDocRoot;

type
 Td2dStaticText = class(TInterfacedObject, Id2dTextAddingTool)
 private
  f_Align: Td2dTextAlignType;
  f_AutoWidth: Boolean;
  f_TextColor: Td2dColor;
  f_Font: Id2dFont;
  f_Formatter: Td2dFormatter;
  f_Root: Td2dDocRoot;
  f_Text: string;
  f_LinkColor: Td2dColor;
  f_LinkHColor: Td2dColor;
  f_OnLinkClick: Td2dOnLinkClickEvent;
  f_TextSource: Td2dTextSource;
  f_X: Single;
  f_Y: Single;
  function pm_GetHeight: Single;
  function pm_GetLineSpacing: Single;
  function pm_GetParaSpacing: Single;
  function pm_GetWidth: Single;
  procedure pm_SetAlign(const Value: Td2dTextAlignType);
  procedure pm_SetTextColor(const Value: Td2dColor);
  procedure pm_SetFont(const Value: Id2dFont);
  procedure pm_SetLineSpacing(const Value: Single);
  procedure pm_SetParaSpacing(const Value: Single);
  procedure pm_SetText(const Value: string);
  procedure pm_SetWidth(const Value: Single);
  procedure ApplyColors;
  procedure ApplyFont;
  procedure ReFormat;
  procedure _ApplyChunkColors(const aChunk: Td2dCustomTextChunk);
  procedure _ApplyFontToChunk(const aChunk: Td2dCustomTextChunk);
  procedure _ApplySliceColors(const aSlice: Td2dCustomSlice);
  //
  procedure AddText(const aText: string);
  procedure AddLink(const aText, aTarget: string);
  procedure CheckAutowidth;
  function pm_GetLinksEnabled: Boolean;
  procedure pm_SetAutoWidth(const Value: Boolean);
  procedure pm_SetLinkColor(const Value: Td2dColor);
  procedure pm_SetLinkHColor(const Value: Td2dColor);
  procedure pm_SetLinksEnabled(const Value: Boolean);
  procedure pm_SetX(const Value: Single);
  procedure pm_SetY(const Value: Single);
  procedure RenewLinkState;
 public
  constructor Create(const aFont: Id2dFont; const aColor: Td2dColor);
  destructor Destroy; override;
  procedure EndText;
  procedure Render;
  procedure ProcessEvent(var theEvent: Td2dInputEvent);
  procedure StartText;
  property Align: Td2dTextAlignType read f_Align write pm_SetAlign;
  property AutoWidth: Boolean read f_AutoWidth write pm_SetAutoWidth;
  property TextColor: Td2dColor read f_TextColor write pm_SetTextColor;
  property Font: Id2dFont read f_Font write pm_SetFont;
  property Height: Single read pm_GetHeight;
  property LineSpacing: Single read pm_GetLineSpacing write pm_SetLineSpacing;
  property ParaSpacing: Single read pm_GetParaSpacing write pm_SetParaSpacing;
  property Text: string read f_Text write pm_SetText;
  property LinkColor: Td2dColor read f_LinkColor write pm_SetLinkColor;
  property LinkHColor: Td2dColor read f_LinkHColor write pm_SetLinkHColor;
  property LinksEnabled: Boolean read pm_GetLinksEnabled write pm_SetLinksEnabled;
  property Width: Single read pm_GetWidth write pm_SetWidth;
  property X: Single read f_X write pm_SetX;
  property Y: Single read f_Y write pm_SetY;
  property OnLinkClick: Td2dOnLinkClickEvent read f_OnLinkClick write f_OnLinkClick;
 end;

implementation
uses
 SysUtils,

 d2dCore,
 d2dUtils;

const
 c_BadLinkColor  = $FFB52929;
 c_BadLinkHColor = $FFFF3A3A;

constructor Td2dStaticText.Create(const aFont: Id2dFont; const aColor: Td2dColor);
begin
 inherited Create;
 f_TextSource := Td2dTextSource.Create;
 f_Root := Td2dDocRoot.Create(0);
 f_Formatter := Td2dFormatter.Create(f_TextSource, f_Root);
 f_TextColor := aColor;
 f_LinkColor := $FF0019FF;
 f_LinkHColor := $FF4F60FF;
 f_Font  := aFont;
 f_AutoWidth := True; 
end;

destructor Td2dStaticText.Destroy;
begin
 FreeAndNil(f_Formatter);
 FreeAndNil(f_TextSource);
 FreeAndNil(f_Root);
 inherited;
end;

procedure Td2dStaticText.AddLink(const aText, aTarget: string);
begin
 f_Text := f_Text + aText;
 if aTarget <> '' then
  f_TextSource.AddLink(aText, aTarget, f_Font, f_TextColor, f_LinkColor, f_LinkHColor, f_Align)
 else
  f_TextSource.AddLink(aText, aTarget, f_Font, f_TextColor, c_BadLinkColor, c_BadLinkHColor, f_Align)
end;

procedure Td2dStaticText.AddText(const aText: string);
begin
 f_Text := f_Text + aText;
 f_TextSource.AddText(aText, f_Font, f_TextColor, f_Align);
end;

procedure Td2dStaticText.ApplyColors;
begin
 f_TextSource.IterateChunks(_ApplyChunkColors);
 f_Root.IterateLeafSlices(_ApplySliceColors);
end;

procedure Td2dStaticText.ApplyFont;
begin
 f_TextSource.IterateChunks(_ApplyFontToChunk);
 ReFormat;
end;

procedure Td2dStaticText.CheckAutowidth;
var
 l_Size: Td2dPoint;
begin
 if f_AutoWidth then
 begin
  f_Font.CalcSize(f_Text, l_Size);
  f_Root.Width := l_Size.X;
 end;
end;

procedure Td2dStaticText.EndText;
begin
 CheckAutowidth;
 ReFormat;
end;

function Td2dStaticText.pm_GetHeight: Single;
begin
 Result := f_Root.Height;
end;

function Td2dStaticText.pm_GetLineSpacing: Single;
begin
 Result := f_Formatter.FormatParams.rLineSpacing;
end;

function Td2dStaticText.pm_GetLinksEnabled: Boolean;
begin
 Result := f_Root.LinksAllowed;
end;

function Td2dStaticText.pm_GetParaSpacing: Single;
begin
 Result := f_Formatter.FormatParams.rParaSpacing;
end;

function Td2dStaticText.pm_GetWidth: Single;
begin
 Result := f_Root.Width;
end;

procedure Td2dStaticText.pm_SetAlign(const Value: Td2dTextAlignType);
var
 I: Integer;
begin
 if f_Align <> Value then
 begin
  f_Align := Value;
  with f_TextSource do
   for I := 0 to Count - 1 do
    Paragraphs[I].ParaType := f_Align;
  ReFormat;
 end;
end;

procedure Td2dStaticText.pm_SetAutoWidth(const Value: Boolean);
begin
 f_AutoWidth := Value;
 if f_AutoWidth then
 begin
  CheckAutowidth;
  ReFormat;
 end;
end;

procedure Td2dStaticText.pm_SetTextColor(const Value: Td2dColor);
begin
 if f_TextColor <> Value then
 begin
  f_TextColor := Value;
  ApplyColors;
 end;
end;

procedure Td2dStaticText.pm_SetFont(const Value: Id2dFont);
begin
 if f_Font <> Value then
 begin
  f_Font := Value;
  ApplyFont;
 end;
end;

procedure Td2dStaticText.pm_SetLineSpacing(const Value: Single);
var
 l_FP: Td2dFormatParamsRec;
begin
 l_FP := f_Formatter.FormatParams;
 l_FP.rLineSpacing := Value;
 f_Formatter.FormatParams := l_FP;
 ReFormat;
end;

procedure Td2dStaticText.pm_SetParaSpacing(const Value: Single);
var
 l_FP: Td2dFormatParamsRec;
begin
 l_FP := f_Formatter.FormatParams;
 l_FP.rParaSpacing := Value;
 f_Formatter.FormatParams := l_FP;
 ReFormat;
end;

procedure Td2dStaticText.pm_SetText(const Value: string);
begin
 if f_Text <> Value then
 begin
  StartText;
  try
   AddText(Value);
  finally
   EndText;
  end;
 end;
end;

procedure Td2dStaticText.pm_SetLinkColor(const Value: Td2dColor);
begin
 if f_LinkColor <> Value then
 begin
  f_LinkColor := Value;
  ApplyColors;
 end;
end;

procedure Td2dStaticText.pm_SetLinkHColor(const Value: Td2dColor);
begin
 if f_LinkHColor <> Value then
 begin
  f_LinkHColor := Value;
  ApplyColors;
 end;
end;

procedure Td2dStaticText.pm_SetLinksEnabled(const Value: Boolean);
begin
 if Value <> f_Root.LinksAllowed then
 begin
  f_Root.LinksAllowed := Value;
  f_Root.DropLinkHighlight;
  f_Root.DropLinkCache;
  if Value then
   gD2DE.Input_TouchMousePos;
 end;

end;

procedure Td2dStaticText.pm_SetWidth(const Value: Single);
begin
 if (not f_AutoWidth) and (Width <> Value) then
 begin
  f_Root.Width := Value;
  ReFormat;
 end; 
end;

procedure Td2dStaticText.pm_SetX(const Value: Single);
begin
 if f_X <> Value then
 begin
  f_X := Value;
  RenewLinkState;
 end;
end;

procedure Td2dStaticText.pm_SetY(const Value: Single);
begin
 if f_Y <> Value then
 begin
  f_Y := Value;
  RenewLinkState;
 end;
end;

procedure Td2dStaticText.ProcessEvent(var theEvent: Td2dInputEvent);
begin
 if (theEvent.EventType = INPUT_MOUSEMOVE) and LinksEnabled then
 begin
  f_Root.FindLinkHighlight(X, Y, theEvent);
 end;
 if (theEvent.EventType = INPUT_MBUTTONDOWN) and (theEvent.KeyCode = D2DK_LBUTTON) and (f_Root.HighlightedLink <> nil) then
 begin
  if Assigned(f_OnLinkClick) then
   f_OnLinkClick(Self, D2DMoveRect(f_Root.HighlightedLink.Rect, X, Y), f_Root.HighlightedLink.Slice.Target);
  Processed(theEvent);
 end;
end;

procedure Td2dStaticText.ReFormat;
begin
 f_Formatter.ReformatAll;
 f_Root.DropLinkCache;
 f_Root.ForceLinkAllowance;
end;

procedure Td2dStaticText.Render;
begin
 f_Root.Draw(f_X, f_Y);
end;

procedure Td2dStaticText.RenewLinkState;
begin
 f_Root.DropLinkCache;
 gD2DE.Input_TouchMousePos;
end;

procedure Td2dStaticText.StartText;
begin
 f_Root.Clear;
 f_TextSource.Clear;
 f_Text := '';
end;

procedure Td2dStaticText._ApplyChunkColors(const aChunk: Td2dCustomTextChunk);
begin
 if aChunk.ChunkType in [ctText, ctLink] then
 begin
  Td2dStringChunk(aChunk).Color := f_TextColor;
  if aChunk.ChunkType = ctLink then
  begin
   Td2dLinkChunk(aChunk).LinkColor := f_LinkColor;
   Td2dLinkChunk(aChunk).HighlightColor := f_LinkHColor;
  end;
 end;
end;

procedure Td2dStaticText._ApplyFontToChunk(const aChunk: Td2dCustomTextChunk);
begin
 if aChunk.ChunkType in [ctText, ctLink] then
 begin
  Td2dStringChunk(aChunk).Font := f_Font;
 end;
end;

procedure Td2dStaticText._ApplySliceColors(const aSlice: Td2dCustomSlice);
begin
 if aSlice.SliceType in [stText, stLink] then
 begin
  Td2dTextSlice(aSlice).Color := f_TextColor;
  if aSlice.SliceType = stLink then
  begin
   Td2dLinkSlice(aSlice).LinkColor := f_LinkColor;
   Td2dLinkSlice(aSlice).HighlightColor := f_LinkHColor;
  end;
 end;
end;

end.