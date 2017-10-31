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
unit d2dGUITextPane;

interface

uses
 Contnrs,
 
 d2dTypes,
 d2dInterfaces,
 d2dFormattedText,
 d2dDocRoot,
 d2dGUITypes,
 d2dGUI,
 d2dUtils;


type
 Td2dOnAddTextEvent = procedure(const aSender: TObject; const aText: string; aColor: Td2dColor; aParaType: Td2dTextAlignType) of object;

 Td2dTextPaneDocRoot = class(Td2dDocRoot)
 private
  f_TopVisible: Integer;
  f_VerticalShift: Single;
  f_VisibleHeight: Single;
  f_BottomVisible: Integer;
  procedure pm_SetVerticalShift(const Value: Single);
  procedure pm_SetVisibleHeight(const Value: Single);
 protected
  function GetBottomChild: Integer; override;
  function GetTopChild: Integer; override;
  function GetVerticalShift: Single; override;
 public
  constructor Create(aWidth: Single; aHeight: Single);
  procedure AddChild(aChild: Td2dCustomSlice); override;
  procedure Clear; override;
  procedure DeleteFrom(aIndex : Integer); override;
  procedure DoDraw(X, Y: Single); override;
  procedure RecalcBounds;
  property BottomVisible: Integer read f_BottomVisible;
  property TopVisible: Integer read f_TopVisible;
  property VerticalShift: Single read f_VerticalShift write pm_SetVerticalShift;
  property VisibleHeight: Single read f_VisibleHeight write pm_SetVisibleHeight;
 end;

type
 Td2dTextPane = class(Td2dControl)
 private
  f_CurScrollSpeed: Single;
  f_CurScrollDir  : Single;
  f_CursorOn: Boolean;
  f_CursorTime: Single;
  f_DocRoot: Td2dTextPaneDocRoot;
  f_FixedMorePosition: Single;
  f_Width    : Single;
  f_Height   : Single;
  f_TS       : Td2dTextSource;
  f_Formatter: Td2dFormatter;
  f_InputResult: string;
  f_PanningSpeed: Integer;
  f_State: Td2dTextPaneState;
  f_TargetShift: Single;
  f_MoreTargetShift: Single;
  f_OnAddText: Td2dOnAddTextEvent;
  f_OnEndInput: Td2dNotifyEvent;
  f_OnLinkClick: Td2dOnLinkClickEvent;
  f_OnStateChange: Td2dNotifyEvent;
  f_ScrollSpeed: Integer;
  f_StateBeforeScroll: Td2dTextPaneState;
  f_ParaPossiblyWithLinks: Integer;
  procedure CalcMoreTargetShift;
  procedure Format;
  procedure FormatAll;
  function pm_GetLastChunk: Td2dCustomTextChunk;
  function pm_GetLineSpacing: Single;
  function pm_GetLinksAllowed: Boolean;
  function pm_GetParaSpacing: Single;
  function pm_GetParaCount: Integer;
  function pm_GetScrollShift: Single;
  procedure pm_SetLineSpacing(const Value: Single);
  procedure pm_SetLinksAllowed(const Value: Boolean);
  procedure pm_SetParaSpacing(const Value: Single);
  procedure pm_SetScrollShift(const Value: Single);
  procedure _UnHighlightLink(const aLinkSlice: Td2dLinkSlice);
  procedure UnHighlightLinks;
  procedure _DeactivateLink(const aLinkSlice: Td2dLinkSlice);
 protected
  function IsSliceVisible(aSlice: Td2dCustomSlice): Boolean;
  procedure PageDown(aDelta: Single = 0);
  procedure PageUp(aDelta: Single = 0);
  function pm_GetHeight: Single; override;
  function pm_GetWidth: Single; override;
  procedure pm_SetHeight(const Value: Single); override;
  procedure pm_SetState(const Value: Td2dTextPaneState); virtual;
  procedure pm_SetWidth(const Value: Single); override;
  procedure Scroll(aDelta: Single); virtual;
  property DocRoot: Td2dTextPaneDocRoot read f_DocRoot;
  property LastChunk: Td2dCustomTextChunk read pm_GetLastChunk;
 public
  constructor Create(aX, aY, aWidth, aHeight: Single);
  destructor Destroy; override;
  procedure AddPara(aSlice: Td2dCustomSlice);
  procedure AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aParaType: Td2dTextAlignType);
  procedure AddPicture(const aPicture: Id2dPicture;aAlign: Td2dTextAlignType);
  procedure AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor, aHighLightColor: Td2dColor; aParaType: Td2dTextAlignType);
  procedure ClearAll; virtual;
  procedure ClearFromPara(aIdx: Integer);
  procedure DropLinks;
  procedure EndInput;
  procedure FixMorePosition;
  procedure FrameFunc(aDelta: Single); override;
  function GetHighlightedLinkText: string;
  function GetPara(aIdx: Integer): Td2dCustomSlice;
  procedure LoadText(const aFiler: Td2dFiler; aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
  procedure Render; override;
  procedure ScrollTo(aTargetShift: Single; aScrollSpeed: Single; aWithMore: Boolean = False);
  procedure ScrollToBottom;
  procedure ProcessEvent(var theEvent: Td2dInputEvent); override;
  procedure SaveText(const aFiler: Td2dFiler);
  procedure StartInput(aFont: Id2dFont; aColor: Td2dColor; aParaType: Td2dTextAlignType);
  property InputResult: string read f_InputResult;
  property OnEndInput: Td2dNotifyEvent read f_OnEndInput write f_OnEndInput;
  property OnAddText: Td2dOnAddTextEvent read f_OnAddText write f_OnAddText;
  property OnStateChange: Td2dNotifyEvent read f_OnStateChange write
      f_OnStateChange;
  property LineSpacing: Single read pm_GetLineSpacing write pm_SetLineSpacing;
  property OnLinkClick: Td2dOnLinkClickEvent read f_OnLinkClick write f_OnLinkClick;
  property LinksAllowed: Boolean read pm_GetLinksAllowed write pm_SetLinksAllowed;
  property ParaSpacing: Single read pm_GetParaSpacing write pm_SetParaSpacing;
  property ParaCount: Integer read pm_GetParaCount;
  property ScrollShift: Single read pm_GetScrollShift write pm_SetScrollShift;
  property PanningSpeed: Integer read f_PanningSpeed write f_PanningSpeed;
  property ScrollSpeed: Integer read f_ScrollSpeed write f_ScrollSpeed;
  property State: Td2dTextPaneState read f_State write pm_SetState;
 end;


implementation
uses
 d2dCore,
 Classes;

constructor Td2dTextPane.Create(aX, aY, aWidth, aHeight: Single);
begin
 inherited Create(aX, aY);
 CanBeFocused := True;
 f_Width := aWidth;
 f_Height := aHeight;
 f_TS := Td2dTextSource.Create;
 f_DocRoot := Td2dTextPaneDocRoot.Create(f_Width, f_Height);
 f_Formatter := Td2dFormatter.Create(f_TS, f_DocRoot);
 f_State := tpsIdle;
 f_PanningSpeed := 500;
 f_ScrollSpeed := 2500;
 f_FixedMorePosition := -1;
 f_MoreTargetShift := -1;
end;

destructor Td2dTextPane.Destroy;
begin
 f_Formatter.Free;
 f_DocRoot.Free;
 f_TS.Free;
 inherited;
end;

procedure Td2dTextPane.AddPara(aSlice: Td2dCustomSlice);
var
 l_Para: Td2dCustomSlice;
 l_NewTop: Single;
begin
 if f_DocRoot.ChildrenCount > 0 then
 begin
  l_Para := f_DocRoot.Children[f_DocRoot.ChildrenCount-1];
  l_NewTop := l_Para.Top + l_Para.Height + f_Formatter.FormatParams.rParaSpacing;
 end
 else
  l_NewTop := 0;
 aSlice.Top := l_NewTop; 
 f_DocRoot.AddChild(aSlice);
 f_DocRoot.RecalcHeight;
 f_DocRoot.DropLinkCache;
end;

procedure Td2dTextPane.AddText(const aText: string; const aFont: Id2dFont; aColor: Td2dColor; aParaType: Td2dTextAlignType);
begin
 f_TS.AddText(aText, aFont, aColor, aParaType);
 Format;
 if Assigned(f_OnAddText) then
  f_OnAddText(Self, aText, aColor, aParaType);
end;

procedure Td2dTextPane.AddPicture(const aPicture: Id2dPicture; aAlign: Td2dTextAlignType);
begin
 f_TS.AddPicture(aPicture, aAlign);
 Format;
end;

procedure Td2dTextPane.AddLink(const aText, aTarget: string; const aFont: Id2dFont; aColor, aLinkColor,
    aHighLightColor: Td2dColor; aParaType: Td2dTextAlignType);
begin
 f_TS.AddLink(aText, aTarget, aFont, aColor, aLinkColor, aHighLightColor, aParaType);
 Format;
 if Assigned(f_OnAddText) then
  f_OnAddText(Self, aText, aColor, aParaType);
end;

procedure Td2dTextPane.CalcMoreTargetShift;
var
 l_LastPara: Td2dUnionSlice;
 l_Line    : Td2dCustomSlice;
 I : Integer;
 l_NewShift: Single;
begin
 if f_FixedMorePosition > -1 then
 begin
  f_MoreTargetShift := f_FixedMorePosition;
  f_FixedMorePosition := -1;
 end
 else
 begin
  if f_DocRoot.Children[f_DocRoot.BottomVisible].SliceType = stUnion then
  begin
   l_LastPara := Td2dUnionSlice(f_DocRoot.Children[f_DocRoot.BottomVisible]);
   f_MoreTargetShift := l_LastPara.Top;
   I := l_LastPara.ChildrenCount - 1;
   while I > 0 do  // find target line to scroll to
   begin
    l_Line := l_LastPara.Children[I];
    l_NewShift := f_MoreTargetShift + l_Line.Top;
    if l_NewShift <= ScrollShift + f_DocRoot.VisibleHeight then
    begin
     f_MoreTargetShift := l_NewShift;
     Break;
    end;
    Dec(I);
   end;
   if f_MoreTargetShift = ScrollShift then
    f_MoreTargetShift := ScrollShift + Height;
  end
  else
   f_MoreTargetShift := f_DocRoot.Children[f_DocRoot.BottomVisible].Top;
 end;
 if f_MoreTargetShift > f_TargetShift then
  f_MoreTargetShift := -1; 
end;

procedure Td2dTextPane.ClearAll;
begin
 f_TS.Clear;
 f_DocRoot.Clear;
 f_DocRoot.RecalcHeight;
 f_Formatter.LastFormatted := 0;
 f_FixedMorePosition := -1;
 State := tpsIdle;
 f_StateBeforeScroll := tpsIdle;
 f_ParaPossiblyWithLinks := 0;
end;

procedure Td2dTextPane.ClearFromPara(aIdx: Integer);
begin
 f_DocRoot.DeleteFrom(aIdx);
 if f_TS.Count <= aIdx then
  f_Formatter.LastFormatted := f_TS.Count - 1
 else
  f_Formatter.LastFormatted := aIdx;
end;

procedure Td2dTextPane.DropLinks;
begin
 if f_TS.Count > 0 then
 begin
  f_TS.DropLinks(f_ParaPossiblyWithLinks);
  f_DocRoot.IterateLinks(_DeactivateLink, f_ParaPossiblyWithLinks);
  f_ParaPossiblyWithLinks := f_TS.Count - 1;
 end;
end;

procedure Td2dTextPane.EndInput;
begin
 f_InputResult := Td2dStringChunk(LastChunk).Text;
 f_TS.Paragraphs[f_TS.Count-1].ClosePara;
 State := tpsIdle;
 LinksAllowed := True;
 if Assigned(f_OnEndInput) then
  f_OnEndInput(Self);
end;

procedure Td2dTextPane.FixMorePosition;
begin
 f_FixedMorePosition := f_DocRoot.Height;
end;

procedure Td2dTextPane.Format;
begin
 f_Formatter.Format;
 f_DocRoot.ForceLinkAllowance;
 f_DocRoot.DropLinkCache;
 gD2DE.Input_TouchMousePos;
 //f_DocRoot.FindLinkHighlight(X, Y);
end;

procedure Td2dTextPane.FormatAll;
begin
 f_Formatter.ReformatAll;
 f_DocRoot.ForceLinkAllowance;
 f_DocRoot.DropLinkCache;
 gD2DE.Input_TouchMousePos;
 //f_DocRoot.FindLinkHighlight(X, Y);
end;

procedure Td2dTextPane.FrameFunc(aDelta: Single);
begin
 case State of
  tpsScrolling:
   begin
    Scroll(aDelta * f_CurScrollSpeed * f_CurScrollDir);
    if f_MoreTargetShift > -1 then
    begin
     if ScrollShift >= f_MoreTargetShift then
     begin
      ScrollShift := f_MoreTargetShift;
      State := tpsMore;
     end;
    end
    else
    begin
     if ((f_CurScrollDir > 0) and (ScrollShift > f_TargetShift)) or
        ((f_CurScrollDir < 0) and (ScrollShift < f_TargetShift)) then
     begin
      ScrollShift := f_TargetShift;
      State := f_StateBeforeScroll;
      f_DocRoot.DropLinkCache;
      gD2DE.Input_TouchMousePos;
     end;
    end;
   end;
  tpsInput:
   begin
    f_CursorTime := f_CursorTime + aDelta;
    if f_CursorTime > 0.5 then
    begin
     f_CursorOn := not f_CursorOn;
     f_CursorTime := 0.0;
    end;
   end;
 end;
end;

function Td2dTextPane.GetHighlightedLinkText: string;
begin
 if f_DocRoot.HighlightedLink = nil then
  Result := ''
 else
  Result := f_DocRoot.HighlightedLink.Slice.GetLinkText;
end;

function Td2dTextPane.GetPara(aIdx: Integer): Td2dCustomSlice;
begin
 Result := f_DocRoot.Children[aIdx];
end;

function Td2dTextPane.IsSliceVisible(aSlice: Td2dCustomSlice): Boolean;
var
 l_AbsTop: Single;
begin
 l_AbsTop := aSlice.AbsTop;
 Result := (l_AbsTop + aSlice.Height  > ScrollShift) and (l_AbsTop < ScrollShift + Height);
end;

procedure Td2dTextPane.LoadText(const aFiler: Td2dFiler; aFP: Id2dFontProvider; const aPP: Id2dPictureProvider);
var
 l_Shift: Single;
begin
 f_TS.Load(aFiler, aFP, aPP);
 FormatAll;
 l_Shift := f_DocRoot.Height - Height;
 if l_Shift > 0.0 then
  f_DocRoot.VerticalShift := l_Shift
 else
  f_DocRoot.VerticalShift := 0.0;

end;

procedure Td2dTextPane.PageDown(aDelta: Single = 0);
var
 l_ScrollPosition: Single;
 l_MaxDownPos: Single;
begin
 l_MaxDownPos := f_DocRoot.Height - Height;
 if (l_MaxDownPos < 0) or (ScrollShift = l_MaxDownPos) then
  Exit;
 if aDelta = 0 then
  aDelta := Height;
 l_ScrollPosition := ScrollShift + aDelta;
 if l_ScrollPosition > l_MaxDownPos then
  l_ScrollPosition := l_MaxDownPos;
 ScrollTo(l_ScrollPosition, ScrollSpeed);
end;

procedure Td2dTextPane.PageUp(aDelta: Single = 0);
var
 l_ScrollPosition: Single;
begin
 if ScrollShift = 0 then
  Exit;
 if aDelta = 0 then
  aDelta := Height;
 l_ScrollPosition := ScrollShift - aDelta;
 if l_ScrollPosition < 0 then
  l_ScrollPosition := 0;
 ScrollTo(l_ScrollPosition, ScrollSpeed);
end;

function Td2dTextPane.pm_GetHeight: Single;
begin
 Result := f_Height;
end;

function Td2dTextPane.pm_GetLastChunk: Td2dCustomTextChunk;
var
 l_Para: Td2dTextPara;
begin
 Result := nil;
 if f_TS.Count > 0 then
 begin
  l_Para := f_TS.Paragraphs[f_TS.Count-1];
  Result := l_Para.Chunks[l_Para.Count-1];
 end;
end;

function Td2dTextPane.pm_GetLineSpacing: Single;
begin
 Result := f_Formatter.FormatParams.rLineSpacing;
end;

function Td2dTextPane.pm_GetLinksAllowed: Boolean;
begin
 Result := f_DocRoot.LinksAllowed;
end;

function Td2dTextPane.pm_GetParaSpacing: Single;
begin
 Result := f_Formatter.FormatParams.rParaSpacing;
end;

function Td2dTextPane.pm_GetParaCount: Integer;
begin
 Result := f_DocRoot.ChildrenCount;
end;

function Td2dTextPane.pm_GetScrollShift: Single;
begin
 Result := f_DocRoot.VerticalShift;
end;

function Td2dTextPane.pm_GetWidth: Single;
begin
 Result := f_Width;
end;

procedure Td2dTextPane.pm_SetHeight(const Value: Single);
begin
 if f_Height <> Value then
 begin
  f_Height := Value;
  f_DocRoot.VisibleHeight := f_Height;
 end;
end;

procedure Td2dTextPane.pm_SetLineSpacing(const Value: Single);
var
 l_FP: Td2dFormatParamsRec;
begin
 l_FP := f_Formatter.FormatParams;
 l_FP.rLineSpacing := Value;
 f_Formatter.FormatParams := l_FP;
 f_Formatter.ReformatAll;
 if f_FixedMorePosition > -1 then
  FixMorePosition;
end;

procedure Td2dTextPane.pm_SetLinksAllowed(const Value: Boolean);
begin
 f_DocRoot.LinksAllowed := Value;
end;

procedure Td2dTextPane.pm_SetParaSpacing(const Value: Single);
var
 l_FP: Td2dFormatParamsRec;
begin
 l_FP := f_Formatter.FormatParams;
 l_FP.rParaSpacing := Value;
 f_Formatter.FormatParams := l_FP;
 f_Formatter.ReformatAll;
 if f_FixedMorePosition > -1 then
  FixMorePosition;
end;

procedure Td2dTextPane.pm_SetScrollShift(const Value: Single);
begin
 f_DocRoot.VerticalShift := Value;
end;

procedure Td2dTextPane.pm_SetState(const Value: Td2dTextPaneState);
begin
 if Value <> f_State then
 begin
  f_State := Value;
  if Assigned(f_OnStateChange) then
   f_OnStateChange(Self);
 end;
end;

procedure Td2dTextPane.pm_SetWidth(const Value: Single);
begin
 if f_Width <> Value then
 begin
  f_Width := Value;
  f_DocRoot.Width := f_Width;
  f_Formatter.ReformatAll;
  if f_FixedMorePosition > -1 then
   FixMorePosition;
 end;
end;

procedure Td2dTextPane.ProcessEvent(var theEvent: Td2dInputEvent);
var
 l_Chunk: Td2dStringChunk;
 l_Char: Char;
 l_Scroll: Single;
begin
 case State of
  tpsIdle      :
   begin
    if (theEvent.EventType = INPUT_KEYDOWN) then
    begin
     if theEvent.KeyCode = D2DK_PGUP then
     begin
      PageUp;
      Processed(theEvent);
     end;
     if theEvent.KeyCode = D2DK_PGDN then
     begin
      PageDown;
      Processed(theEvent);
     end;
    end;
    if (theEvent.EventType = INPUT_MOUSEWHEEL) then
    begin
     if theEvent.Flags and D2DINP_CTRL <> 0 then
      l_Scroll := 0
     else
      l_Scroll := 25;
     if theEvent.Wheel < 0 then
      PageDown(l_Scroll)
     else
      PageUp(l_Scroll);
     Processed(theEvent);
    end;
    if (theEvent.EventType = INPUT_MOUSEMOVE) then
     f_DocRoot.FindLinkHighlight(X, Y, theEvent);
    if (theEvent.EventType = INPUT_MBUTTONDOWN) and (theEvent.KeyCode = D2DK_LBUTTON) and (f_DocRoot.HighlightedLink <> nil) then
    begin
     if Assigned(f_OnLinkClick) then
      f_OnLinkClick(Self, D2DMoveRect(f_DocRoot.HighlightedLink.Rect, X, Y), f_DocRoot.HighlightedLink.Slice.Target);
     Processed(theEvent); 
    end;
   end;
  tpsScrolling : ;
  tpsMore      :
   begin
    if (theEvent.EventType = INPUT_KEYDOWN) or
       ((theEvent.EventType = INPUT_MBUTTONDOWN) and IsMouseInControl) then
    begin
     CalcMoreTargetShift;
     State := tpsScrolling;
     Processed(theEvent);
    end;
   end;
  tpsInput     :
   begin
    if (theEvent.EventType = INPUT_KEYDOWN) then
    begin
     l_Chunk := Td2dStringChunk(LastChunk);
     if theEvent.KeyCode = D2DK_BACKSPACE then
     begin
      if l_Chunk.Text <> '' then
       l_Chunk.Text := Copy(l_Chunk.Text, 1, Length(l_Chunk.Text)-1);
      Format;
      Processed(theEvent);
      Exit;
     end;
     if theEvent.KeyCode = D2DK_ENTER then
     begin
      EndInput;
      Processed(theEvent);
      Exit;
     end;
     l_Char := Char(theEvent.KeyChar);
     if (l_Char > #31) and (l_Chunk.Font.CanRenderChar(l_Char) or (l_Char = #32)) then // space is always allowed
      l_Chunk.Text := l_Chunk.Text + l_Char;
     Format;
     ScrollToBottom;
     Processed(theEvent);
    end;
   end;
 end;
end;

procedure Td2dTextPane.Render;
var
 l_Sl: Td2dCustomSlice;
 l_X : Single;
 l_Y : Single;
 l_Color: Td2dColor;
begin
 //D2DRenderRect(D2DRect(X,Y,X+Width,Y+Height), $FFFF0000);
 gD2DE.Gfx_SetClipping(Trunc(X), Trunc(Y), Trunc(Width+0.5), Trunc(Height+0.5));
 try
  f_DocRoot.Draw(X, Y);
  if (State = tpsInput) and f_CursorOn then
  begin
   l_Sl := f_DocRoot;
   while (l_Sl.SliceType = stUnion) do // getting last slice
    l_Sl := Td2dUnionSlice(l_Sl).Children[Td2dUnionSlice(l_Sl).ChildrenCount - 1];
   l_X := l_Sl.AbsLeft + l_Sl.Width + X + 1;
   l_Y := l_Sl.AbsTop - ScrollShift + Y + l_Sl.Height;
   l_Color := Td2dStringChunk(LastChunk).Color;
   gD2DE.Gfx_RenderLine(l_X, l_Y, l_X, l_Y - Td2dStringChunk(LastChunk).Font.Height, l_Color, 0);
  end;
 finally
  gD2DE.Gfx_SetClipping(0);
 end;
end;

procedure Td2dTextPane.SaveText(const aFiler: Td2dFiler);
begin
 f_TS.Save(aFiler);
end;

procedure Td2dTextPane.Scroll(aDelta: Single);
begin
 ScrollShift := ScrollShift + aDelta;
end;

procedure Td2dTextPane.ScrollTo(aTargetShift: Single; aScrollSpeed: Single; aWithMore: Boolean = False);
begin
 if not (State in [tpsIdle, tpsInput]) then
  Exit;
 if Abs(aTargetShift - ScrollShift) > 1.0 then
 begin
  f_TargetShift := aTargetShift;
  f_CurScrollSpeed := aScrollSpeed;
  if f_TargetShift > ScrollShift then
  begin
   f_CurScrollDir := 1.0;
   if aWithMore then
    CalcMoreTargetShift;
  end
  else
   f_CurScrollDir := -1.0;
  f_StateBeforeScroll := State;
  State := tpsScrolling;
  UnHighlightLinks;
 end;
end;

procedure Td2dTextPane.ScrollToBottom;
begin
 if f_DocRoot.Height - ScrollShift > Height then
  ScrollTo(f_DocRoot.Height - Height, f_PanningSpeed, True);
end;

procedure Td2dTextPane.StartInput(aFont: Id2dFont; aColor: Td2dColor; aParaType: Td2dTextAlignType);
var
 l_Para: Td2dTextPara;
 l_Chunk: Td2dStringChunk;
begin
 // add chunk
 if f_TS.Count > 0 then
 begin
  l_Para := f_TS.Paragraphs[f_TS.Count-1];
  if l_Para.IsClosed or (l_Para.ParaType <> aParaType) then
   l_Para := nil;
 end
 else
  l_Para := nil;
 if l_Para = nil then
  l_Para := f_TS.AddRawPara(aParaType);
 l_Chunk := Td2dStringChunk.Create('', aFont, aColor);
 l_Para.AddRawChunk(l_Chunk);
 Format;
 State := tpsInput;
 LinksAllowed := False;
end;

procedure Td2dTextPane.UnHighlightLinks;
begin
 f_DocRoot.IterateLinks(_UnHighlightLink, f_ParaPossiblyWithLinks);
 f_DocRoot.HighlightedLink := nil;
end;

procedure Td2dTextPane._DeactivateLink(const aLinkSlice: Td2dLinkSlice);
begin
 aLinkSlice.IsActive := False;
end;

procedure Td2dTextPane._UnHighlightLink(const aLinkSlice: Td2dLinkSlice);
begin
 aLinkSlice.IsHighlighted := False;
end;

constructor Td2dTextPaneDocRoot.Create(aWidth: Single; aHeight: Single);
begin
 inherited Create(aWidth);
 f_VisibleHeight := aHeight;
 f_TopVisible := -1;
 f_BottomVisible := -1;
end;

procedure Td2dTextPaneDocRoot.AddChild(aChild: Td2dCustomSlice);
begin
 inherited;
 RecalcBounds;
end;

procedure Td2dTextPaneDocRoot.Clear;
begin
 inherited Clear;
 f_TopVisible := -1;
 f_BottomVisible := -1;
 f_VerticalShift := 0;
end;

procedure Td2dTextPaneDocRoot.DeleteFrom(aIndex : Integer);
begin
 inherited;
 RecalcBounds;
end;

procedure Td2dTextPaneDocRoot.DoDraw(X, Y: Single);
var
 I  : Integer;
 l_Child: Td2dCustomSlice;
 l_Shift: Single;
begin
 if f_TopVisible >= 0 then
 begin
  l_Shift := Int(f_VerticalShift + 0.5); // round shift
  for I := f_TopVisible to f_BottomVisible do
  begin
   l_Child := Children[I];
   l_Child.Draw(X, Y - l_Shift);
  end;
 end;
end;

function Td2dTextPaneDocRoot.GetBottomChild: Integer;
begin
 Result := f_BottomVisible;
end;

function Td2dTextPaneDocRoot.GetTopChild: Integer;
begin
 Result := f_TopVisible;
end;

function Td2dTextPaneDocRoot.GetVerticalShift: Single;
begin
 Result := f_VerticalShift;
end;

procedure Td2dTextPaneDocRoot.pm_SetVerticalShift(const Value: Single);
begin
 if f_VerticalShift <> Value then
 begin
  f_VerticalShift := Value;
  RecalcBounds;
 end;
end;

procedure Td2dTextPaneDocRoot.pm_SetVisibleHeight(const Value: Single);
begin
 if f_VisibleHeight <> Value then
 begin
  f_VisibleHeight := Value;
  RecalcBounds;
 end;
end;

procedure Td2dTextPaneDocRoot.RecalcBounds;
var
 I  : Integer;
 l_Child: Td2dCustomSlice;
begin
 I := 0;
 f_TopVisible := -1;
 f_BottomVisible := -1;
 while (I < ChildrenCount) and ((f_TopVisible < 0) or (f_BottomVisible < 0)) do
 begin
  l_Child := Children[I];
  if (f_TopVisible < 0) and (l_Child.Top+l_Child.Height > f_VerticalShift) then
   f_TopVisible := I;
  if (l_Child.Top > f_VerticalShift + f_VisibleHeight) then
   f_BottomVisible := I - 1;
  Inc(I);
 end;
 if f_BottomVisible < 0 then
  f_BottomVisible := Pred(ChildrenCount);
end;

end.
