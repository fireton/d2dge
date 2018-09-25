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

unit d2dGUIMenus;

interface
uses
 Contnrs,
 d2dTypes,
 d2dInterfaces,
 d2dGUI,
 d2dGUITypes;

type
 Td2dMenu = class;

 Td2dMenuItem = class
 private
  f_Caption: string;
  f_Checkable: Boolean;
  f_Checked: Boolean;
  f_Enabled: Boolean;
  f_OnClick: Td2dNotifyEvent;
  f_Items: TObjectList;
  f_Menu: Td2dMenu;
  f_Parent: Td2dMenuItem;
  f_Tag: Variant;
  function pm_GetChildren(Index: Integer): Td2dMenuItem;
  function pm_GetChildrenCount: Integer;
  function pm_GetEnabled: Boolean;
  function pm_GetHasChildren: Boolean;
  procedure pm_SetCaption(const Value: string);
 public
  constructor Create(aCaption: string);
  destructor Destroy; override;
  function AddChild(aChild: Td2dMenuItem): Integer;
  procedure Click;
  procedure ClearChildren(aFrom: Integer = 0);
  property Caption: string read f_Caption write pm_SetCaption;
  property Checkable: Boolean read f_Checkable write f_Checkable;
  property Checked: Boolean read f_Checked write f_Checked;
  property Children[Index: Integer]: Td2dMenuItem read pm_GetChildren;
  property ChildrenCount: Integer read pm_GetChildrenCount;
  property Enabled: Boolean read pm_GetEnabled write f_Enabled;
  property HasChildren: Boolean read pm_GetHasChildren;
  property Menu: Td2dMenu read f_Menu write f_Menu;
  property Parent: Td2dMenuItem read f_Parent write f_Parent;
  property Tag: Variant read f_Tag write f_Tag;
  property OnClick: Td2dNotifyEvent read f_OnClick write f_OnClick;
 end;

 Td2dMenu = class(Td2dControl)
 private
  f_Height: Single;
  f_MouseDown: Boolean;
  f_OwnItems: Boolean;
  f_PaneQuad: Td2dQuad;
  f_ParentMenu: Td2dMenu;
  f_Root: Td2dMenuItem;
  f_SelectedItem: Integer;
  f_SelectedQuad: Td2dQuad;
  f_Submenu: Td2dMenu;
  f_VisulalStyle: Td2dMenuVisualStyle;
  f_Width: Single;
  procedure CalcSelectionQuad;
  function IsSubmenuOpen: Boolean;
  function pm_GetItemHeight: Single;
  procedure pm_SetFont(const Value: Id2dFont);
  procedure pm_SetRoot(const Value: Td2dMenuItem);
  procedure pm_SetSelectedItem(const Value: Integer);
  procedure pm_SetSubmenu(const Value: Td2dMenu);
  procedure pm_SetVisulalStyle(const Value: Td2dMenuVisualStyle);
 protected
  f_Font: Id2dFont;
  procedure DoClick(aItemIdx: Integer);
  procedure OpenSubmenu(aIdx: Integer);
  function pm_GetHeight: Single; override;
  function pm_GetWidth: Single; override;
  property ItemHeight: Single read pm_GetItemHeight;
  property Submenu: Td2dMenu read f_Submenu write pm_SetSubmenu;
 public
  constructor Create(aFont: Id2dFont; aRoot: Td2dMenuItem = nil); overload;
  constructor Create(aFont: Id2dFont; aItems: array of Td2dMenuItem); overload;
  constructor Create(aParent: Td2dMenu; aItemIdx: Integer); overload;
  destructor Destroy; override;
  procedure Close(aGlobal: Boolean = False);
  function IsPointInControl(aX, aY: Single): Boolean; override;
  function ItemAtPoint(aX, aY: Single): Integer;
  procedure Popup(aX, aY: Single; aAlign: Td2dAlign = alTopLeft); overload;
  procedure Popup(const aRect: Td2dRect; aAlign: Td2dAlign = alTopLeft); overload;
  procedure ProcessEvent(var theEvent: Td2dInputEvent); override;
  procedure RecalcSize;
  procedure Render; override;
  procedure Update; override;
  property Font: Id2dFont read f_Font write pm_SetFont;
  property ParentMenu: Td2dMenu read f_ParentMenu;
  property Root: Td2dMenuItem read f_Root write pm_SetRoot;
  property SelectedItem: Integer read f_SelectedItem write pm_SetSelectedItem;
  property VisulalStyle: Td2dMenuVisualStyle read f_VisulalStyle write pm_SetVisulalStyle;
 end;

function D2DMenuDash: Td2dMenuItem;

function D2DIsAnyOpenMenu(const aGUI: Td2dGUI): Boolean;

const
 cDefaultMenuVisualStyle: Td2dMenuVisualStyle =
  (rBGColor        :$FFFFFFFF;
   rBorderColor    :$FFA0A0A0;
   rTextColor      :$FF000000;
   rHIndent        :2;
   rVIndent        :2;
   rSelectionColor :$FF0000A0;
   rSelectedColor  :$FFFFFFFF;
   rDisabledColor  :$FFC0C0C0;
  );


implementation
uses
 Classes,
 SysUtils,

 d2dCore,
 d2dUtils,
 d2dGUIUtils;

function D2DMenuDash: Td2dMenuItem;
begin
 Result := Td2dMenuItem.Create('-');
end;

constructor Td2dMenuItem.Create(aCaption: string);
begin
 inherited Create;
 f_Items := TObjectList.Create;
 f_Caption := aCaption;
 f_Enabled := True;
end;

destructor Td2dMenuItem.Destroy;
begin
 f_Items.Free;
 inherited;
end;

function Td2dMenuItem.AddChild(aChild: Td2dMenuItem): Integer;
begin
 Result := f_Items.Add(aChild);
 aChild.f_Parent := Self;
 if f_Menu <> nil then
  f_Menu.RecalcSize; 
end;

procedure Td2dMenuItem.ClearChildren(aFrom: Integer = 0);
begin
 if aFrom = 0 then
  f_Items.Clear
 else
  while f_Items.Count > aFrom do
   f_Items.Delete(f_Items.Count-1);
 if f_Menu <> nil then
  f_Menu.RecalcSize;  
end;

procedure Td2dMenuItem.Click;
begin
 if Enabled and  Assigned(f_OnClick) then
  f_OnClick(Self);
end;

function Td2dMenuItem.pm_GetChildren(Index: Integer): Td2dMenuItem;
begin
 Result := Td2dMenuItem(f_Items[Index]);
end;

function Td2dMenuItem.pm_GetChildrenCount: Integer;
begin
 Result := f_Items.Count;
end;

function Td2dMenuItem.pm_GetEnabled: Boolean;
begin
 Result := {Assigned(f_OnClick) and} f_Enabled;
end;

function Td2dMenuItem.pm_GetHasChildren: Boolean;
begin
 Result := (ChildrenCount > 0);
end;

procedure Td2dMenuItem.pm_SetCaption(const Value: string);
begin
 f_Caption := Value;
 if Menu <> nil then
  Menu.RecalcSize;
end;

constructor Td2dMenu.Create(aFont: Id2dFont; aRoot: Td2dMenuItem = nil);
begin
 inherited Create(0, 0);
 f_Font := aFont;
 if aRoot <> nil then
  Root := aRoot
 else
 begin
  Root := Td2dMenuItem.Create('');
  f_OwnItems := True;
 end;
 f_VisulalStyle := cDefaultMenuVisualStyle;
 f_Visible := False;
 CanBeFocused := True;
end;

constructor Td2dMenu.Create(aFont: Id2dFont; aItems: array of Td2dMenuItem);
var
 I: Integer;
 l_Root: Td2dMenuItem;
begin
 l_Root := Td2dMenuItem.Create('');
 for I := 0 to High(aItems) do
  l_Root.AddChild(aItems[I]);
 Create(aFont, l_Root);
 f_OwnItems := True; 
end;

constructor Td2dMenu.Create(aParent: Td2dMenu; aItemIdx: Integer);
begin
 Create(aParent.Font, aParent.Root.Children[aItemIdx]);
 f_ParentMenu := aParent;
 VisulalStyle := f_ParentMenu.VisulalStyle;
end;

destructor Td2dMenu.Destroy;
begin
 Submenu := nil;
 if f_OwnItems then
  f_Root.Free;
 inherited;
end;

procedure Td2dMenu.CalcSelectionQuad;
var
 l_Rect: Td2dRect;
begin
 if f_SelectedItem < 0 then
  Exit;
 l_Rect := D2DRect(X, Y + ItemHeight*SelectedItem, X + Width, Y + ItemHeight*(SelectedItem+1));
 f_SelectedQuad := D2DMakeFilledRectQuad(l_Rect, f_VisulalStyle.rSelectionColor);
end;

procedure Td2dMenu.Close(aGlobal: Boolean = False);
begin
 Submenu := nil;
 if aGlobal and (ParentMenu <> nil) then
  ParentMenu.Close(True)
 else
  Visible := False;
end;

procedure Td2dMenu.DoClick(aItemIdx: Integer);
var
 l_Item: Td2dMenuItem;
begin
 l_Item := f_Root.Children[aItemIdx];
 if l_Item.Enabled then
 begin
  if l_Item.HasChildren then
   OpenSubmenu(aItemIdx)
  else
  begin
   if l_Item.Checkable then
    l_Item.Checked := not l_Item.Checked;
   Close(True);
   l_Item.Click;
  end;
 end;
end;

function Td2dMenu.IsPointInControl(aX, aY: Single): Boolean;
begin
 Result := D2DIsPointInRect(aX, aY, f_X, f_Y, Width, Height);
 if IsSubmenuOpen then
  Result := Result or Submenu.IsPointInControl(aX, aY);
end;

function Td2dMenu.IsSubmenuOpen: Boolean;
begin
 Result := (Submenu <> nil) and (Submenu.Visible);
end;

function Td2dMenu.ItemAtPoint(aX, aY: Single): Integer;
begin
 Result := -1;
 if IsPointInControl(aX, aY) then
 begin
  aY := aY - Y;
  Result := Trunc(aY / ItemHeight);
  if (Result > f_Root.ChildrenCount-1) or (f_Root.Children[Result].Caption = '-') then
   Result := -1;
 end;
end;

procedure Td2dMenu.OpenSubmenu(aIdx: Integer);
var
 l_SubX: Single;
 l_SubY: Single;
begin
 if f_Root.Children[aIdx].HasChildren and f_Root.Children[aIdx].Enabled then
 begin
  Submenu := Td2dMenu.Create(Self, aIdx);
  Submenu.RecalcSize;
  if X + Width + Submenu.Width < gD2DE.ScreenWidth then
   l_SubX := X + Width
  else
   l_SubX := X - Submenu.Width;
  l_SubY := Y + aIdx * ItemHeight;
  Submenu.Popup(l_SubX, l_SubY);
 end;
end;

function Td2dMenu.pm_GetHeight: Single;
begin
 Result := f_Height;
end;

function Td2dMenu.pm_GetItemHeight: Single;
begin
 Result := f_VisulalStyle.rVIndent*2 + f_Font.Height;
end;

function Td2dMenu.pm_GetWidth: Single;
begin
 Result := f_Width;
end;

procedure Td2dMenu.pm_SetFont(const Value: Id2dFont);
begin
 f_Font := Value;
 RecalcSize;
end;

procedure Td2dMenu.pm_SetRoot(const Value: Td2dMenuItem);
begin
 if (f_Root <> nil) and f_OwnItems then
  FreeAndNil(f_Root);
 f_Root := Value;
 f_Root.Menu := Self;
end;

procedure Td2dMenu.pm_SetSelectedItem(const Value: Integer);
begin
 if (Value >= -1) and (Value < f_Root.ChildrenCount) then
 begin
  f_SelectedItem := Value;
  CalcSelectionQuad;
 end;
end;

procedure Td2dMenu.pm_SetSubmenu(const Value: Td2dMenu);
begin
 if f_Submenu <> nil then
  FreeAndNil(f_Submenu);
 f_Submenu := Value;
end;

procedure Td2dMenu.pm_SetVisulalStyle(const Value: Td2dMenuVisualStyle);
begin
 f_VisulalStyle := Value;
 RecalcSize;
end;

procedure Td2dMenu.Popup(aX, aY: Single; aAlign: Td2dAlign = alTopLeft);
begin
 Popup(D2DRect(aX, aY, aX, aY), aAlign);
end;

procedure Td2dMenu.Popup(const aRect: Td2dRect; aAlign: Td2dAlign = alTopLeft);
var
 l_Selected: Integer;
 l_Pos : Td2dPoint;
begin
 Visible := True;
 Focused := True;
 RecalcSize;
 SelectedItem := 0;
 l_Pos := D2DAlignRect(aRect, D2DPoint(f_Width, f_Height), aAlign);
 f_X := l_Pos.X;
 f_Y := l_Pos.Y;
 Update;
 l_Selected := ItemAtPoint(gD2DE.MouseX, gD2DE.MouseY);
 if l_Selected >= 0 then
  SelectedItem := l_Selected;
end;

procedure Td2dMenu.ProcessEvent(var theEvent: Td2dInputEvent);
var
 l_SelItem: Integer;
begin
 if IsSubmenuOpen then
  Submenu.ProcessEvent(theEvent);

 if IsMouseEvent(theEvent) then
 begin
  if D2DIsPointInRect(gD2DE.MouseX, gD2DE.MouseY, X, Y, Width, Height) then
  begin
   case theEvent.EventType of
    INPUT_MOUSEMOVE:
     begin
      SelectedItem := ItemAtPoint(gD2DE.MouseX, gD2DE.MouseY);
      // because menu is ALWAYS on top
      if IsPointInControl(gD2DE.MouseX, gD2DE.MouseY) then
       MaskMouseMove(theEvent);
     end;

    INPUT_MBUTTONDOWN:
     begin
      f_MouseDown := True;
      Processed(theEvent);
     end;

    INPUT_MBUTTONUP:
     begin
      if f_MouseDown then
      begin
       f_MouseDown := False;
       if SelectedItem >= 0 then
        DoClick(SelectedItem);
       Processed(theEvent);
      end;
     end;
   end;
  end
  else
  begin
   case theEvent.EventType of
    INPUT_MBUTTONDOWN:
    begin
     Close;
     Processed(theEvent); // закрытие меню - отдельное событие, клик не передаётся дальше
    end;
    INPUT_MBUTTONUP:
     f_MouseDown := False;
   end;
  end;
 end;

 if theEvent.EventType = INPUT_KEYDOWN then
 begin
  if (theEvent.KeyCode = D2DK_DOWN) and (SelectedItem < f_Root.ChildrenCount-1) then
  begin
   l_SelItem := SelectedItem + 1;
   while (f_Root.Children[l_SelItem].Caption = '-') and (l_SelItem < f_Root.ChildrenCount) do
    Inc(l_SelItem);
   if (f_Root.Children[l_SelItem].Caption <> '-') then
    SelectedItem := l_SelItem;
   Processed(theEvent);
  end;

  if (theEvent.KeyCode = D2DK_UP) and (SelectedItem > 0) then
  begin
   l_SelItem := SelectedItem - 1;
   while (f_Root.Children[l_SelItem].Caption = '-') and (l_SelItem < f_Root.ChildrenCount) do
    Dec(l_SelItem);
   if (f_Root.Children[l_SelItem].Caption <> '-') then
    SelectedItem := l_SelItem;
   Processed(theEvent);
  end;

  if (theEvent.KeyCode = D2DK_ENTER) then
  begin
   if SelectedItem >= 0 then
    DoClick(SelectedItem);
   Processed(theEvent);
  end;

  if (theEvent.KeyCode = D2DK_RIGHT) then
  begin
   if SelectedItem >= 0 then
    OpenSubmenu(SelectedItem);
   Processed(theEvent);
  end;

  if (theEvent.KeyCode = D2DK_LEFT) then
  begin
   if ParentMenu <> nil then
    Close;
   Processed(theEvent);
  end;

  if theEvent.KeyCode = D2DK_ESCAPE then
  begin
   Processed(theEvent);
   Close;
  end;
 end;
end;

procedure Td2dMenu.RecalcSize;
var
 I: Integer;
 l_ItemWidth: Single;
 l_LineSize: Td2dPoint;
begin
 f_Height := ItemHeight * f_Root.ChildrenCount;
 f_Width := 0;
 for I := 0 to Pred(f_Root.ChildrenCount) do
 begin
  f_Font.CalcSize(f_Root.Children[I].Caption, l_LineSize);
  l_ItemWidth := f_VisulalStyle.rHIndent*4 + f_Font.Height*2 + l_LineSize.X;
  if l_ItemWidth > f_Width then
   f_Width := l_ItemWidth;
 end;
 Update;
end;

procedure Td2dMenu.Render;
var
 l_TextLeft: Single;
 l_TextTop : Single;
 l_HalfFH: Single;
 I: Integer;
 l_TriLeft: Single;
 l_QuartFH: Single;
 l_CheckLeft: single;

 procedure RenderTriangle;
 var
  l_Tri: Td2dTriple;
 begin
  FillChar(l_Tri, SizeOf(l_Tri), 0);
  l_Tri.Blend := BLEND_DEFAULT;
  l_Tri.V[0].X := l_TriLeft;
  l_Tri.V[0].Y := l_TextTop + l_QuartFH;
  l_Tri.V[0].Col := f_Font.Color;

  l_Tri.V[1].X := l_TriLeft + l_QuartFH;
  l_Tri.V[1].Y := l_Tri.V[0].Y + l_QuartFH;
  l_Tri.V[1].Col := f_Font.Color;

  l_Tri.V[2].X := l_TriLeft;
  l_Tri.V[2].Y := l_Tri.V[0].Y + l_HalfFH;
  l_Tri.V[2].Col := f_Font.Color;
  gD2DE.Gfx_RenderTriple(l_Tri);
 end;

 procedure RenderCheck(aChecked: Boolean);
 var
  l_Rect: Td2dRect;
  l_CheckTop: Single;
 begin
  l_CheckTop := l_TextTop + l_QuartFH;
  l_Rect := D2DRect(l_CheckLeft, l_CheckTop, l_CheckLeft+l_HalfFH, l_CheckTop+l_HalfFH);
  D2DRenderRect(l_Rect, f_Font.Color);

  if aChecked then
  begin
   with l_Rect do
   begin
    Left := Left + 1.0; // why 1?! i don't know...
    Top := Top + 1.0;
    // here goes the dirty trick (can't understand yet why)
    if gD2DE.Windowed then
    begin
     Right := Right - 2.0;
     Bottom := Bottom - 2.0;
    end
    else
    begin
     Right := Right - 1.0;
     Bottom := Bottom - 1.0;
    end;
   end;
   D2DRenderFilledRect(l_Rect, f_Font.Color);
  end;
 end;


begin
 gD2DE.Gfx_RenderQuad(f_PaneQuad);
 if f_SelectedItem >= 0 then
  gD2DE.Gfx_RenderQuad(f_SelectedQuad);

 l_HalfFH := Round(Font.Height / 2);
 l_QuartFH := Round(Font.Height / 4);
 l_TextLeft := X + f_Font.Height + f_VisulalStyle.rHIndent*2;
 l_TriLeft := X + Width - f_VisulalStyle.rHIndent - l_HalfFH;
 l_CheckLeft := X + f_VisulalStyle.rHIndent+l_QuartFH;

 for I := 0 to Pred(f_Root.ChildrenCount) do
 begin
  l_TextTop := Y + ItemHeight*I + f_VisulalStyle.rVIndent;
  if f_Root.Children[I].Caption = '-' then
  begin
   l_TextTop := Int(l_TextTop + ItemHeight/2);
   gD2DE.Gfx_RenderLine(X + f_VisulalStyle.rHIndent + l_QuartFH, l_TextTop,
     X + Width - f_VisulalStyle.rHIndent - l_QuartFH, l_TextTop, f_VisulalStyle.rBorderColor, 0);
  end
  else
  begin
   if f_Root.Children[I].Enabled then
   begin
    if I = SelectedItem then
     f_Font.Color := f_VisulalStyle.rSelectedColor
    else
     f_Font.Color := f_VisulalStyle.rTextColor;
   end
   else
    f_Font.Color := f_VisulalStyle.rDisabledColor;
   f_Font.Render(l_TextLeft, l_TextTop, f_Root.Children[I].Caption);
   if f_Root.Children[I].HasChildren then
    RenderTriangle;
   if f_Root.Children[I].Checkable then
    RenderCheck(f_Root.Children[I].Checked);
  end;
 end;
 D2DRenderRect(D2DRect(X, Y, X+f_Width, Y+f_Height), f_VisulalStyle.rBorderColor);
 if IsSubmenuOpen then
  Submenu.Render;
end;

procedure Td2dMenu.Update;
begin
 if Assigned(GUI) and (not Focused) then
 begin
  Close;
  Exit;
 end;
 f_PaneQuad := D2DMakeFilledRectQuad(D2DRect(X, Y, X+f_Width, Y+f_Height), f_VisulalStyle.rBGColor);
 CalcSelectionQuad;
end;

function D2DIsAnyOpenMenu(const aGUI: Td2dGUI): Boolean;
var
 I: Integer;
 l_M: Td2dMenu;
begin
 Result := False;
 if Assigned(aGUI) then
  for I := 0 to aGUI.Count-1 do
  begin
   if (aGUI.Controls[I] is Td2dMenu) and Td2dMenu(aGUI.Controls[I]).Visible then
   begin
    Result := True;
    Break;
   end;
  end;
end;

end.
