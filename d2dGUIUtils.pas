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
unit d2dGUIUtils;

interface
uses
 d2dTypes,
 d2dGUITypes;

// aMasterRect - is master rect which target rect is relative to
// aDim - dimensions (width and height) of the target rect
// returns the point of top left corner of the target rect
function D2DAlignRect(const aMasterRect: Td2dRect; const aDim: Td2dPoint; aAlign: Td2dAlign): Td2dPoint;
function D2DAlignToStr(const aAlign: Td2dAlign): string;
function D2DStrToAlign(aStr: string): Td2dAlign;


implementation
uses
 d2dCore, SysUtils;

const
 c_AlignString : array [Td2dAlign] of string = ('LT','LB','LC','RT','RB','RC','TL','TR','TC','BL','BR','BC');

function D2DAlignRect(const aMasterRect: Td2dRect; const aDim: Td2dPoint; aAlign: Td2dAlign): Td2dPoint;
var
 l_MasterHalf: Td2dPoint;
begin
 l_MasterHalf.X := (aMasterRect.Right - aMasterRect.Left)/2;
 l_MasterHalf.Y := (aMasterRect.Bottom - aMasterRect.Top)/2;
 // initial relocation
 case aAlign of
  alLeftTop, alLeftBottom, alLeftCenter       : Result.X := aMasterRect.Left - aDim.X - 1;
  alRightTop, alRightBottom, alRightCenter    : Result.X := aMasterRect.Right + 1;
  alTopLeft, alTopRight, alTopCenter          : Result.Y := aMasterRect.Top - aDim.Y - 1;
  alBottomLeft, alBottomRight, alBottomCenter : Result.Y := aMasterRect.Bottom + 1;
 end;
 case aAlign of
  alLeftTop, alRightTop       : Result.Y := aMasterRect.Top;
  alLeftBottom, alRightBottom : Result.Y := aMasterRect.Bottom - aDim.Y;
  alLeftCenter, alRightCenter : Result.Y := aMasterRect.Top + l_MasterHalf.Y - (aDim.Y/2);
  alTopLeft, alBottomLeft     : Result.X := aMasterRect.Left;
  alTopRight, alBottomRight   : Result.X := aMasterRect.Right - aDim.X;
  alTopCenter, alBottomCenter : Result.X := aMasterRect.Left + l_MasterHalf.X - (aDim.X/2);
 end;
 // now if we out of the screen because of MAIN relocation functor then we should flip result
 // i.e. if alRightTop is out of the right edge of screen we should make it alLeftTop
 if (aAlign in [alLeftTop, alLeftBottom, alLeftCenter]) and (Result.X < 0) then
  Result.X := aMasterRect.Right + 1;
 if (aAlign in [alRightTop, alRightBottom, alRightCenter]) and (Result.X + aDim.X > gD2DE.ScreenWidth) then
  Result.X := aMasterRect.Left - aDim.X - 1;
 if (aAlign in [alTopLeft, alTopRight, alTopCenter]) and (Result.Y < 0) then
  Result.Y := aMasterRect.Bottom + 1;
 if (aAlign in [alBottomLeft, alBottomRight, alBottomCenter]) and (Result.Y + aDim.Y > gD2DE.ScreenHeight) then
  Result.Y := aMasterRect.Top - aDim.Y - 1;
 // now is the final aligment by edges of the screen
 if Result.X + aDim.X > gD2DE.ScreenWidth then
  Result.X := gD2DE.ScreenWidth - aDim.X;
 if Result.X < 0 then
  Result.X := 0;
 if Result.Y + aDim.Y > gD2DE.ScreenHeight then
  Result.Y := gD2DE.ScreenHeight - aDim.Y;
 if Result.Y < 0 then
  Result.Y := 0;
 Result.X := Round(Result.X);
 Result.Y := Round(Result.Y);
end;


function D2DAlignToStr(const aAlign: Td2dAlign): string;
begin
 Result := c_AlignString[aAlign];
end;

function D2DStrToAlign(aStr: string): Td2dAlign;
var
 A: Td2dAlign;
begin
 Result := alTopLeft;
 aStr := UpperCase(aStr);
 for A := alLeftTop to alBottomCenter do
  if aStr = c_AlignString[A] then
  begin
   Result := A;
   Break;
  end;
end;

end.