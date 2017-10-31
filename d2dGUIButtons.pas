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
unit d2dGUIButtons;

interface

uses
 d2dTypes,
 d2dInterfaces,
 d2dGUITypes,
 d2dGUI,
 d2dSprite,
 d2dFrames,
 d2dFont;

type 
 Td2dCustomButton = class(Td2dControl)
 private
  f_AutoFocus: Boolean;
  f_Fixed: Boolean;
  f_HasStates: Td2dButtonStates;
  f_OnTrigger: Td2dTriggerEvent;
  f_Pressed: Boolean;
  f_Trigger: Boolean;
  procedure DetectState(var theEvent: Td2dInputEvent);
  procedure pm_SetFixed(aFixed: Boolean);
 protected
  f_OnClick: Td2dNotifyEvent;
  f_State: Td2dButtonState;
  procedure DoClick;
  procedure pm_SetEnabled(const Value: Boolean); override;
  procedure pm_SetState(const Value: Td2dButtonState); virtual;
 public
  constructor Create(aX, aY: Single);
  procedure Click;
  procedure ProcessEvent(var theEvent: Td2dInputEvent); override;
  procedure Update; override;
  property OnClick: Td2dNotifyEvent read f_OnClick write f_OnClick;
  property Fixed: Boolean read f_Fixed write pm_SetFixed;
  property OnTrigger: Td2dTriggerEvent read f_OnTrigger write f_OnTrigger;
  property AutoFocus: Boolean read f_AutoFocus write f_AutoFocus default False;
  property HasStates: Td2dButtonStates read f_HasStates write f_HasStates;
  property State: Td2dButtonState read f_State write pm_SetState;
  property Trigger: Boolean read f_Trigger write f_Trigger;
 end;

 Td2dBitButton = class(Td2dCustomButton)
 private
  f_Sprite: Td2dMultiFrameSprite;
 protected
  function pm_GetHeight: Single; override;
  function pm_GetWidth: Single; override;
  procedure pm_SetState(const Value: Td2dButtonState); override;
 public
  constructor Create(aX, aY: Single; aTex: Id2dTexture; aTx, aTy, aWidth, aHeight: Integer);
  destructor Destroy; override;
  procedure Render; override;
 end;

 Id2dFramedButtonView = interface
 ['{C0BA7393-BAED-410C-B289-6539ED8A5758}']
  function pm_GetHeight: Single;
  function pm_GetMinWidth: Integer;
  function pm_GetStateColor(aState: Td2dButtonState): Td2dColor;
  procedure pm_SetStateColor(aState: Td2dButtonState; const Value: Td2dColor);
  function CalcWidth(aCaption: string): Integer;
  function CorrectCaption(const aCaption: string; aWidth: Integer): string;
  function CorrectCaptionEx(const aCaption: string; aWidth: Integer; const aObligatoryPart: string): string;
  procedure Render(aX, aY: Single; aCaption: string; aState: Td2dButtonState;
                   aPrecalcWidth: Integer = 0; aTextAlign: Td2dTextAlignType = ptLeftAligned);
  procedure CorrectWidth(var theWidth: Integer);
  property Height: Single read pm_GetHeight;
  property MinWidth: Integer read pm_GetMinWidth;
  property StateColor[aState: Td2dButtonState]: Td2dColor read pm_GetStateColor write pm_SetStateColor;
 end;

 Td2dFramedButtonView = class(TInterfacedObject, Id2dFramedButtonView)
 private
  f_StateColor: array[Td2dButtonState] of Td2dColor;
  f_Font: Id2dFont;
  f_StateFrames: array[Td2dButtonState] of Td2dHorizFrame;
  function pm_GetHeight: Single;
  function pm_GetMinWidth: Integer;
  function pm_GetStateColor(aState: Td2dButtonState): Td2dColor;
  procedure pm_SetStateColor(aState: Td2dButtonState; const Value: Td2dColor);
 public
  constructor Create(aTex: Id2dTexture;
                     aTx, aTy, aWidth, aHeight, aLeftCapW, aMidW: Integer;
                     aFont: Id2dFont);
  destructor Destroy; override;
  function CalcWidth(aCaption: string): Integer;
  function CorrectCaption(const aCaption: string; aWidth: Integer): string;
  function CorrectCaptionEx(const aCaption: string; aWidth: Integer; const aObligatoryPart: string): string;
  procedure Render(aX, aY: Single; aCaption: string; aState: Td2dButtonState;
                   aPrecalcWidth: Integer = 0; aTextAlign: Td2dTextAlignType = ptLeftAligned);
  procedure CorrectWidth(var theWidth: Integer);
  property Height: Single read pm_GetHeight;
  property MinWidth: Integer read pm_GetMinWidth;
  property StateColor[aState: Td2dButtonState]: Td2dColor read pm_GetStateColor write pm_SetStateColor;
 end;

 Td2dFramedTextButton = class(Td2dCustomButton)
 private
  f_AutoSize: Boolean;
  f_Caption: string;
  f_TextAlign: Td2dTextAlignType;
  f_View: Id2dFramedButtonView;
  f_Width: Integer;
  procedure pm_SetAutoSize(const Value: Boolean);
  procedure pm_SetCaption(const Value: string);
 protected
  function pm_GetHeight: Single; override;
  function pm_GetWidth: Single; override;
  procedure pm_SetWidth(const Value: Single); override;
  procedure RecalcWidth;
 public
  constructor Create(aX, aY: Single; aView: Id2dFramedButtonView; aCaption: string);
  procedure Render; override;
  property AutoSize: Boolean read f_AutoSize write pm_SetAutoSize;
  property Caption: string read f_Caption write pm_SetCaption;
  property TextAlign: Td2dTextAlignType read f_TextAlign write f_TextAlign;
 end;


implementation
uses
 d2dCore,
 d2dUtils;

constructor Td2dCustomButton.Create(aX, aY: Single);
begin
 inherited;
 CanBeFocused := True;
 f_HasStates := [bsNormal, bsDisabled, bsFocused, bsPressed];
end;

procedure Td2dCustomButton.Click;
begin
 if Trigger then
 begin
  Fixed := not Fixed;
  DoClick;
 end
 else
  DoClick;
 gD2DE.Input_TouchMousePos;
 //Update;
end;

procedure Td2dCustomButton.DetectState(var theEvent: Td2dInputEvent);
begin
 if not Enabled then
 begin
  State := bsDisabled;
  f_Pressed := False;
  Exit;
 end;

 if f_Fixed then
 begin
  State := bsPressed;
  Exit;
 end;

 if IsMouseInControl and not IsMouseMoveMasked(theEvent) then
 begin
  if f_Pressed then
   State := bsPressed
  else
  begin
   State := bsFocused;
   MaskMouseMove(theEvent);
  end;
 end
 else
  if Focused then
   State := bsFocused
  else
   State := bsNormal;
end;

procedure Td2dCustomButton.DoClick;
begin
 if Assigned(f_OnClick) then
  f_OnClick(Self);
end;

procedure Td2dCustomButton.Update;
begin
 gD2DE.Input_TouchMousePos;
end;

procedure Td2dCustomButton.pm_SetEnabled(const Value: Boolean);
begin
 inherited;
 if not f_Enabled then
 begin
  f_Pressed := False;
  Fixed := False;
  f_State := bsDisabled;
 end;
 Update;
end;

procedure Td2dCustomButton.pm_SetFixed(aFixed: Boolean);
begin
 if f_Trigger and (f_Fixed <> aFixed) then
 begin
  f_Fixed := aFixed;
  if Assigned(f_OnTrigger) then
   f_OnTrigger(f_Fixed);
 end;
end;

procedure Td2dCustomButton.pm_SetState(const Value: Td2dButtonState);
begin
 if Value in f_HasStates then
  f_State := Value;
end;

procedure Td2dCustomButton.ProcessEvent(var theEvent: Td2dInputEvent);
var
 l_InButton: Boolean;
 l_OldState: Td2dButtonState;
begin
 {
 if not f_Enabled then
 begin
  State := bsDisabled;
  Exit;
 end;
 }
 if theEvent.EventType = INPUT_MOUSEMOVE then
 begin
  l_OldState := f_State;
  DetectState(theEvent);
  if f_AutoFocus and (l_OldState = bsNormal) and (f_State = bsFocused) then
   Focused := True;
  Exit;
 end;

 if Enabled then
 begin
  l_InButton := IsMouseInControl;

  if l_InButton and (theEvent.EventType = INPUT_MBUTTONDOWN) and (theEvent.KeyCode = D2DK_LBUTTON) then
  begin
   f_Pressed := True;
   State := bsPressed;
   Processed(theEvent);
  end;

  if (theEvent.EventType = INPUT_MBUTTONUP) and (theEvent.KeyCode = D2DK_LBUTTON) then
  begin
   if l_InButton and f_Pressed then
   begin
    Click;
    Processed(theEvent);
   end
   else
    State := bsNormal;
   f_Pressed := False;
  end;

  if Focused and (theEvent.EventType = INPUT_KEYDOWN) and
     ((theEvent.KeyCode = D2DK_ENTER) or (theEvent.KeyCode = D2DK_SPACE)) then
  begin
   Click;
   Processed(theEvent);
  end;
 end;
end;

constructor Td2dBitButton.Create(aX, aY: Single; aTex: Id2dTexture; aTx, aTy, aWidth, aHeight: Integer);
begin
 inherited Create(aX, aY);
 f_Sprite := Td2dMultiFrameSprite.Create(aTex, 4, aTx, aTy, aWidth, aHeight);
end;

destructor Td2dBitButton.Destroy;
begin
 f_Sprite.Free;
 inherited;
end;

function Td2dBitButton.pm_GetHeight: Single;
begin
 Result := f_Sprite.Height;
end;

function Td2dBitButton.pm_GetWidth: Single;
begin
 Result := f_Sprite.Width;
end;

procedure Td2dBitButton.pm_SetState(const Value: Td2dButtonState);
begin
 inherited;
 case f_State of
  bsNormal  : f_Sprite.CurFrame := 0;
  bsDisabled: f_Sprite.CurFrame := 1;
  bsFocused : f_Sprite.CurFrame := 2;
  bsPressed : f_Sprite.CurFrame := 3;
 end;
end;

procedure Td2dBitButton.Render;
begin
 f_Sprite.Render(f_X, f_Y);
end;

constructor Td2dFramedButtonView.Create(aTex: Id2dTexture;
                                        aTx, aTy, aWidth, aHeight, aLeftCapW, aMidW: Integer;
                                        aFont: Id2dFont);
var
 I : Td2dButtonState;
 l_Shift: Integer;
begin
 inherited Create;
 l_Shift := 0;
 for I := Low(Td2dButtonState) to High(Td2dButtonState) do
 begin
  f_StateFrames[I] := Td2dHorizFrame.Create(aTex, aTx + l_Shift, aTy, aTx + l_Shift + aWidth - 1, aTy + aHeight - 1,
                                            aLeftCapW, aMidW);
  f_StateColor[I] := $FF000000;                                          
  l_Shift := l_Shift + aWidth;
 end;
 f_Font := aFont;
end;

destructor Td2dFramedButtonView.Destroy;
var
 I: Td2dButtonState;
begin
 for I := Low(Td2dButtonState) to High(Td2dButtonState) do
  f_StateFrames[I].Free;
 inherited;
end;

function Td2dFramedButtonView.CalcWidth(aCaption: string): Integer;
var
 l_TextSize: Td2dPoint;
begin
 f_Font.CalcSize(aCaption, l_TextSize);
 Result := f_StateFrames[bsNormal].LeftWidth + Trunc(l_TextSize.X + 1) + f_StateFrames[bsNormal].RightWidth;
 CorrectWidth(Result);
end;

function Td2dFramedButtonView.CorrectCaption(const aCaption: string; aWidth: Integer): string;
begin
 Result := CorrectCaptionEx(aCaption, aWidth, '');
end;

function Td2dFramedButtonView.CorrectCaptionEx(const aCaption: string; aWidth: Integer; const aObligatoryPart: string): string;
var
 l_MaxTextWidth: Integer;
 l_Str: string;
 l_Size: Td2dPoint;
begin
 l_MaxTextWidth := aWidth - f_StateFrames[bsNormal].LeftWidth - f_StateFrames[bsNormal].RightWidth;
 f_Font.CalcSize(aCaption + aObligatoryPart, l_Size);
 if l_Size.X > l_MaxTextWidth then
 begin
  l_Str := aCaption;
  repeat
   SetLength(l_Str, Length(l_Str)-1);
   f_Font.CalcSize(l_Str + '...' + aObligatoryPart, l_Size);
  until (l_Size.X <= l_MaxTextWidth) or (l_Str = '');
  Result := l_Str + '...' + aObligatoryPart;
 end
 else
  Result := aCaption + aObligatoryPart;
end;

procedure Td2dFramedButtonView.CorrectWidth(var theWidth: Integer);
begin
 f_StateFrames[bsNormal].CorrectWidth(theWidth);
end;

function Td2dFramedButtonView.pm_GetHeight: Single;
begin
 Result := f_StateFrames[bsNormal].Height;
end;

function Td2dFramedButtonView.pm_GetMinWidth: Integer;
begin
 Result := f_StateFrames[bsNormal].MinWidth;
end;

function Td2dFramedButtonView.pm_GetStateColor(aState: Td2dButtonState): Td2dColor;
begin
 Result := f_StateColor[aState];
end;

procedure Td2dFramedButtonView.pm_SetStateColor(aState: Td2dButtonState; const Value: Td2dColor);
begin
 f_StateColor[aState] := Value;
end;

procedure Td2dFramedButtonView.Render(aX, aY: Single; aCaption: string; aState: Td2dButtonState;
                                      aPrecalcWidth: Integer = 0; aTextAlign: Td2dTextAlignType = ptLeftAligned);
var
 l_TextX: Single;
 l_TextY: Single;
 l_IntWidth: Integer;
 l_TextSize: Td2dPoint;
begin
 if aPrecalcWidth > 0 then
  l_IntWidth := aPrecalcWidth
 else
  l_IntWidth := CalcWidth(aCaption);
 f_StateFrames[aState].Render(aX, aY, l_IntWidth);
 f_Font.Color := f_StateColor[aState];
 l_TextX := aX + f_StateFrames[aState].LeftWidth;
 if aTextAlign <> ptLeftAligned then
 begin
  f_Font.CalcSize(aCaption, l_TextSize);
  case aTextAlign of
   ptRightAligned: l_TextX := l_TextX + f_StateFrames[aState].GetMidWidth(l_IntWidth) - Round(l_TextSize.X);
   ptCentered    : l_TextX := l_TextX + f_StateFrames[aState].GetMidWidth(l_IntWidth) div 2 - Round(l_TextSize.X) div 2; 
  end;
 end;
 l_TextY := aY + Int((f_StateFrames[aState].Height - f_Font.Size) / 2);
 f_Font.Render(l_TextX, l_TextY, aCaption);
end;

constructor Td2dFramedTextButton.Create(aX, aY: Single; aView: Id2dFramedButtonView; aCaption: string);
begin
 inherited Create(aX, aY);
 f_View := aView;
 f_AutoSize := True;
 f_TextAlign := ptLeftAligned;
 Caption := aCaption;
end;

function Td2dFramedTextButton.pm_GetHeight: Single;
begin
 Result := f_View.Height;
end;

function Td2dFramedTextButton.pm_GetWidth: Single;
begin
 Result := f_Width;
end;

procedure Td2dFramedTextButton.pm_SetAutoSize(const Value: Boolean);
begin
 f_AutoSize := Value;
 if f_AutoSize then
  RecalcWidth;
end;

procedure Td2dFramedTextButton.pm_SetCaption(const Value: string);
begin
 f_Caption := Value;
 if Autosize then
  RecalcWidth;
end;

procedure Td2dFramedTextButton.pm_SetWidth(const Value: Single);
begin
 f_AutoSize := False;
 f_Width := Round(Value);
 f_View.CorrectWidth(f_Width);
end;

procedure Td2dFramedTextButton.RecalcWidth;
begin
 f_Width := f_View.CalcWidth(f_Caption);
end;

procedure Td2dFramedTextButton.Render;
begin
 f_View.Render(X, Y, f_Caption, f_State, f_Width, f_TextAlign);
 //D2DRenderRect(D2DRect(X,Y,X+Width,Y+Height), $FFFF0000);
end;



end.