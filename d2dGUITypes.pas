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
unit d2dGUITypes;

interface
uses
 d2dTypes;

type
 Td2dButtonState   = (bsNormal, bsDisabled, bsFocused, bsPressed);
 Td2dTextPaneState = (tpsIdle, tpsScrolling, tpsMore, tpsInput);

 Td2dButtonStates = set of Td2dButtonState;

 Td2dMenuVisualStyle = record
  rBGColor: Td2dColor;
  rBorderColor: Td2dColor;
  rTextColor: Td2dColor;
  rHIndent: Single;
  rVIndent: Single;
  rSelectionColor: Td2dColor;
  rSelectedColor: Td2dColor;
  rDisabledColor: Td2dColor;
 end;

 Td2dAlign = (alLeftTop,    alLeftBottom,  alLeftCenter,
              alRightTop,   alRightBottom, alRightCenter,
              alTopLeft,    alTopRight,    alTopCenter,
              alBottomLeft, alBottomRight, alBottomCenter);



implementation

end.