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

unit d2dSimplePicture;

interface
uses
 d2dTypes,
 d2dInterfaces,
 d2dClasses,
 d2dSprite;

type
 Td2dSimplePicture = class(Td2dProtoObject, Id2dPicture)
 private
  f_ID: string;
  f_Sprite: Td2dSprite;
  function pm_GetHeight: Single;
  function pm_GetID: string;
  function pm_GetWidth: Single;
  procedure Render(const aX, aY: Single);
 protected
  procedure Cleanup; override;
 public
  class function Make(const anID: string; const aTex: Id2dTexture; aX, aY, aWidth, aHeight: Integer; aColor: Td2dColor): Id2dPicture;
 end;


implementation
uses
 SysUtils;

procedure Td2dSimplePicture.Cleanup;
begin
 FreeAndNil(f_Sprite);
 inherited;
end;

class function Td2dSimplePicture.Make(const anID: string; const aTex: Id2dTexture; aX, aY, aWidth, aHeight: Integer;
 aColor: Td2dColor): Id2dPicture;
var
 l_Pic: Td2dSimplePicture;
begin
 l_Pic := Td2dSimplePicture.Create;
 try
  l_Pic.f_ID := anID;
  l_Pic.f_Sprite := Td2dSprite.Create(aTex, aX, aY, aWidth, aHeight);
  l_Pic.f_Sprite.SetColor(aColor);
  Result := l_Pic;
 finally
  FreeAndNil(l_Pic);
 end;
end;

function Td2dSimplePicture.pm_GetHeight: Single;
begin
 Result := f_Sprite.Height;
end;

function Td2dSimplePicture.pm_GetID: string;
begin
 Result := f_ID;
end;

function Td2dSimplePicture.pm_GetWidth: Single;
begin
 Result := f_Sprite.Width;
end;

procedure Td2dSimplePicture.Render(const aX, aY: Single);
begin
 f_Sprite.Render(aX, aY);
end;

end.