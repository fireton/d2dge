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

unit d2dGUI;

interface
uses
 Contnrs,

 d2dTypes
 ;

type
 Td2dControl = class;

 Td2dGUI = class
 private
  f_BringFocusedToFront: Boolean;
  f_ROList: TObjectList; // render order
  f_Controls: TObjectList;
  f_FocusedControl: Td2dControl;
  procedure FindNextFocused(aCanReturnFocus: Boolean);
  procedure FindPrevFocused(aCanReturnFocus: Boolean);
  function pm_GetControls(Index: Integer): Td2dControl;
  function pm_GetCount: Integer;
  function pm_GetROControls(Index: Integer): Td2dControl;
  function pm_GetTopmostVisible: Td2dControl;
  procedure pm_SetFocusedControl(const Value: Td2dControl);
 protected
  procedure DeleteControl(aControl: Td2dControl);
  property ROControls[Index: Integer]: Td2dControl read pm_GetROControls;
 public
  constructor Create;
  destructor Destroy; override;
  procedure AddControl(aControl: Td2dControl);
  procedure BringToFront(const aControl: Td2dControl);
  procedure SendToBack(const aControl: Td2dControl);
  procedure CheckFocused;
  function ControlAtMouse: Td2dControl;
  procedure FocusNext;
  procedure FocusPrev;
  procedure FrameFunc(aDelta: Single); virtual;
  procedure ProcessEvent(var theEvent: Td2dInputEvent); virtual;
  procedure Render; virtual;
  property BringFocusedToFront: Boolean read f_BringFocusedToFront write f_BringFocusedToFront;
  property Controls[Index: Integer]: Td2dControl read pm_GetControls;
  property Count: Integer read pm_GetCount;
  property FocusedControl: Td2dControl read f_FocusedControl write pm_SetFocusedControl;
  property TopmostVisible: Td2dControl read pm_GetTopmostVisible;
 end;

 Td2dControl = class(TInterfacedObject)
 private
  f_CanBeFocused: Boolean;
  f_GUI: Td2dGUI;
  f_Tag: Integer;
  function pm_GetCanBeFocused: Boolean;
  function pm_GetFocused: Boolean;
  procedure pm_SetFocused(const Value: Boolean);
  procedure pm_SetX(const Value: Single);
  procedure pm_SetY(const Value: Single);
 protected
  f_Enabled: Boolean;
  f_Visible: Boolean;
  f_X: Single;
  f_Y: Single;
  function pm_GetHeight: Single; virtual;
  function pm_GetWidth: Single; virtual;
  procedure pm_SetEnabled(const Value: Boolean); virtual;
  procedure pm_SetHeight(const Value: Single); virtual;
  procedure pm_SetVisible(const Value: Boolean); virtual;
  procedure pm_SetWidth(const Value: Single); virtual;
 public
  constructor Create(aX, aY: Single);
  destructor Destroy; override;
  procedure FrameFunc(aDelta: Single); virtual;
  function IsMouseInControl: Boolean;
  function IsPointInControl(aX, aY: Single): Boolean; virtual;
  procedure ProcessEvent(var theEvent: Td2dInputEvent); virtual;
  procedure Render; virtual;
  procedure Update; virtual;
  property CanBeFocused: Boolean read pm_GetCanBeFocused write f_CanBeFocused;
  property Enabled: Boolean read f_Enabled write pm_SetEnabled;
  property Focused: Boolean read pm_GetFocused write pm_SetFocused;
  property Height: Single read pm_GetHeight write pm_SetHeight;
  property GUI: Td2dGUI read f_GUI;
  property Tag: Integer read f_Tag write f_Tag;
  property Visible: Boolean read f_Visible write pm_SetVisible;
  property Width: Single read pm_GetWidth write pm_SetWidth;
  property X: Single read f_X write pm_SetX;
  property Y: Single read f_Y write pm_SetY;
 end;

implementation
uses
 SysUtils,
 Classes,

 d2dCore,
 d2dUtils;


constructor Td2dControl.Create(aX, aY: Single);
begin
 inherited Create;
 f_X := aX;
 f_Y := aY;
 f_Enabled := True;
 f_Visible := True;
end;

destructor Td2dControl.Destroy;
begin
 if f_GUI <> nil then
  f_GUI.DeleteControl(Self);
 inherited;
end;

procedure Td2dControl.FrameFunc(aDelta: Single);
begin
 // does nothing in base class
end;

function Td2dControl.IsMouseInControl: Boolean;
begin
 if f_GUI = nil then
  Result := IsPointInControl(gD2DE.MouseX, gD2DE.MouseY)
 else
  Result := f_GUI.ControlAtMouse = Self; 
end;

function Td2dControl.pm_GetFocused: Boolean;
begin
 Result := (f_GUI <> nil) and (f_GUI.FocusedControl = Self);
end;

function Td2dControl.pm_GetHeight: Single;
begin
 Result := 0;
end;

function Td2dControl.pm_GetWidth: Single;
begin
 Result := 0;
end;

procedure Td2dControl.pm_SetEnabled(const Value: Boolean);
begin
 f_Enabled := Value;
 if CanBeFocused and (GUI <> nil) then
  GUI.CheckFocused;
end;

procedure Td2dControl.pm_SetFocused(const Value: Boolean);
begin
 if Value then
 begin
  if (GUI <> nil) and Visible and Enabled and CanBeFocused then
   GUI.FocusedControl := Self;
 end
 else
  if (GUI <> nil) then
  begin
   GUI.FocusedControl := nil;
   GUI.CheckFocused;
  end;
end;

procedure Td2dControl.pm_SetHeight(const Value: Single);
begin
 // empty in base class 
end;

procedure Td2dControl.pm_SetVisible(const Value: Boolean);
begin
 f_Visible := Value;
 if CanBeFocused and (GUI <> nil) then
  GUI.CheckFocused;
end;

procedure Td2dControl.pm_SetWidth(const Value: Single);
begin
 // empty in base class
end;

function Td2dControl.IsPointInControl(aX, aY: Single): Boolean;
begin
 Result := D2DIsPointInRect(aX, aY, f_X, f_Y, Width, Height);
end;

function Td2dControl.pm_GetCanBeFocused: Boolean;
begin
 Result := f_CanBeFocused and (f_GUI <> nil);
end;

procedure Td2dControl.pm_SetX(const Value: Single);
begin
 f_X := Value;
 Update;
end;

procedure Td2dControl.pm_SetY(const Value: Single);
begin
 f_Y := Value;
 Update;
end;

procedure Td2dControl.ProcessEvent(var theEvent: Td2dInputEvent);
begin
 // empty in base class
end;

procedure Td2dControl.Render;
begin
 // empty in base class
end;

procedure Td2dControl.Update;
begin
 // empty in base class
end;

constructor Td2dGUI.Create;
begin
 inherited;
 f_Controls := TObjectList.Create;
 f_ROList := TObjectList.Create(False);
 f_BringFocusedToFront := True;
end;

destructor Td2dGUI.Destroy;
begin
 f_Controls.Free;
 f_ROList.Free;
 inherited;
end;

procedure Td2dGUI.AddControl(aControl: Td2dControl);
begin
 f_Controls.Add(aControl);
 f_ROList.Insert(0, aControl);
 aControl.f_GUI := Self;
 CheckFocused;
end;

procedure Td2dGUI.BringToFront(const aControl: Td2dControl);
var
 l_Idx: Integer;
begin
 l_Idx := f_ROList.IndexOf(FocusedControl);
 if l_Idx >= 0 then
  f_ROList.Move(l_Idx, 0);
end;

procedure Td2dGUI.SendToBack(const aControl: Td2dControl);
var
 l_Idx: Integer;
begin
 l_Idx := f_ROList.IndexOf(FocusedControl);
 if l_Idx >= 0 then
  f_ROList.Move(l_Idx, f_ROList.Count-1);
end;

procedure Td2dGUI.CheckFocused;
begin
 if (FocusedControl = nil) or (not FocusedControl.Visible) or (not FocusedControl.Enabled) then
  FindNextFocused(False);
end;

function Td2dGUI.ControlAtMouse: Td2dControl;
var
 I: Integer;
begin
 Result := nil;
 for I := 0 to Pred(Count) do
  if ROControls[I].Visible and ROControls[I].IsPointInControl(gD2DE.MouseX, gD2DE.MouseY) then
  begin
   Result := ROControls[I];
   Break;
  end;
end;

procedure Td2dGUI.DeleteControl(aControl: Td2dControl);
begin
 if FocusedControl = aControl then
  FocusedControl := nil;
 f_Controls.Extract(aControl);
 f_ROList.Remove(aControl);
 aControl.f_GUI := nil;
 CheckFocused;
end;

procedure Td2dGUI.FindNextFocused(aCanReturnFocus: Boolean);
var
 l_CIdx: Integer;
 l_OldFocused: Integer;
begin
 if Count = 0 then
  Exit;
 if FocusedControl = nil then
  l_CIdx := -1
 else
  l_CIdx := f_Controls.IndexOf(FocusedControl);
 l_OldFocused := l_CIdx;
 Inc(l_CIdx);
 while True do
 begin
  if l_CIdx = Count then
  begin
   if l_OldFocused = -1 then
    Exit;
   l_CIdx := 0;
  end;
  if l_CIdx = l_OldFocused then
  begin
   if not aCanReturnFocus then
    FocusedControl := nil;
   Break;
  end;
  with Controls[l_CIdx] do
   if Visible and Enabled and CanBeFocused then
    begin
     FocusedControl := Controls[l_CIdx];
     Break;
    end;
  Inc(l_CIdx);
 end;
end;

procedure Td2dGUI.FindPrevFocused(aCanReturnFocus: Boolean);
var
 l_CIdx: Integer;
 l_OldFocused: Integer;
begin
 if Count = 0 then
  Exit;
 if FocusedControl = nil then
  l_CIdx := -1
 else
  l_CIdx := f_Controls.IndexOf(FocusedControl);
 l_OldFocused := l_CIdx;
 Dec(l_CIdx);
 while True do
 begin
  if l_CIdx = -1 then
  begin
   if l_OldFocused = -1 then
    Exit;
   l_CIdx := Count - 1;
  end;
  if l_CIdx = l_OldFocused then
  begin
   if not aCanReturnFocus then
    FocusedControl := nil;
   Break;
  end;
  with Controls[l_CIdx] do
   if Visible and Enabled and CanBeFocused then
    begin
     FocusedControl := Controls[l_CIdx];
     Break;
    end;
  Dec(l_CIdx);
 end;
end;

procedure Td2dGUI.FocusNext;
begin
 FindNextFocused(True);
end;

procedure Td2dGUI.FocusPrev;
begin
 FindPrevFocused(True);
end;

procedure Td2dGUI.FrameFunc(aDelta: Single);
var
 I: Integer;
begin
 for I := 0 to Pred(Count) do
  Controls[I].FrameFunc(aDelta);
end;

function Td2dGUI.pm_GetControls(Index: Integer): Td2dControl;
begin
 Result := f_Controls[Index] as Td2dControl;
end;

function Td2dGUI.pm_GetCount: Integer;
begin
 Result := f_Controls.Count;
end;

function Td2dGUI.pm_GetROControls(Index: Integer): Td2dControl;
begin
 Result := Td2dControl(f_ROList[Index]);
end;

function Td2dGUI.pm_GetTopmostVisible: Td2dControl;
var
 I: Integer;
begin
 Result := nil;
 for I := 0 to Pred(Count) do
  if ROControls[I].Visible then
  begin
   Result := ROControls[I];
   Break;
  end;
end;

procedure Td2dGUI.pm_SetFocusedControl(const Value: Td2dControl);
var
 l_OldFocused: Td2dControl;
begin
 if Value <> nil then
  if (f_Controls.IndexOf(Value) < 0) or
     (not Value.Visible) or (not Value.Enabled) or (not Value.CanBeFocused) then
   Exit;

 l_OldFocused :=  FocusedControl;

 f_FocusedControl := Value;

 if l_OldFocused <> nil then
  l_OldFocused.Update;

 if FocusedControl <> nil then
 begin
  if f_BringFocusedToFront then
   BringToFront(FocusedControl);
  FocusedControl.Update;
 end;
end;

procedure Td2dGUI.ProcessEvent(var theEvent: Td2dInputEvent);
var
 I: Integer;
 l_Control: Td2dControl;
begin
 if (theEvent.EventType = INPUT_KEYDOWN) and (theEvent.KeyCode = D2DK_TAB) then
 begin
  FocusNext;
  Processed(theEvent);
  Exit;
 end;

 // if there is focused control then let it handle keyboard events
 if IsKeyboardEvent(theEvent) then
 begin
  if (FocusedControl <> nil) then
   FocusedControl.ProcessEvent(theEvent);
  //Processed(theEvent);
  Exit;
 end;

 if (theEvent.EventType = INPUT_MBUTTONDOWN) and (theEvent.KeyCode = D2DK_LBUTTON) then
 begin
  l_Control := ControlAtMouse;
  if (l_Control <> nil) and (l_Control <> FocusedControl) then
   FocusedControl := l_Control; 
 end;

 if (FocusedControl <> nil) then
  FocusedControl.ProcessEvent(theEvent);

 for I := 0 to Pred(Count) do
 begin
  if IsProcessed(theEvent) then
   Break;
  l_Control := Controls[I];
  if l_Control.Visible and l_Control.Enabled and (l_Control <> FocusedControl) then
   l_Control.ProcessEvent(theEvent);
 end;
end;

procedure Td2dGUI.Render;
var
 I: Integer;
 l_Ctrl: Td2dControl;
begin
 for I := Pred(Count) downto 0 do
 begin
  l_Ctrl := ROControls[I];
  if l_Ctrl.Visible then
   l_Ctrl.Render;
 end;
end;

end.
