unit d2dTexture;

interface

uses
 Direct3D8,
 d2dInterfaces,
 d2dClasses;

type
 Td2dTexture = class(Td2dProtoObjectPrim, Id2dTexture)
 private
  f_DXTexture: IDirect3DTexture8;
  f_SrcPicHeight: Integer;
  f_SrcPicWidth: Integer;
 protected
  function pm_GetDirectXTexture: IDirect3DTexture8;
  function pm_GetSrcPicHeight: Integer;
  function pm_GetSrcPicWidth: Integer;
  procedure pm_SetSrcPicHeight(const Value: Integer);
  procedure pm_SetSrcPicWidth(const Value: Integer);
 public
  function IsOrphan: Boolean;
  class function Make(aDXTex: IDirect3DTexture8): Id2dTexture;
 end;

implementation

uses
 SysUtils,
 d2dCore;

function Td2dTexture.IsOrphan: Boolean;
var
 l_Count: Integer;
begin
 Result := True;
 if f_DXTexture <> nil then
 begin
  l_Count := f_DXTexture._AddRef;
  try
   Result := l_Count = 2;
  finally
   f_DXTexture._Release;
  end;
 end;
end;

class function Td2dTexture.Make(aDXTex: IDirect3DTexture8): Id2dTexture;
var
 l_Tex: Td2dTexture;
begin
 Result := nil;
 if aDXTex <> nil then
 begin
  l_Tex := Td2dTexture.Create;
  try
   l_Tex.f_DXTexture := aDXTex;
   Result := l_Tex;
  finally
   FreeAndNil(l_Tex);
  end;
 end;
end;

function Td2dTexture.pm_GetDirectXTexture: IDirect3DTexture8;
begin
 if Self <> nil then
  Result := f_DXTexture;
end;

function Td2dTexture.pm_GetSrcPicHeight: Integer;
begin
 if f_SrcPicHeight > 0 then
  Result := f_SrcPicHeight
 else
  Result := gD2DE.Texture_GetHeight(f_DXTexture);
end;

function Td2dTexture.pm_GetSrcPicWidth: Integer;
begin
 if f_SrcPicWidth > 0 then
  Result := f_SrcPicWidth
 else
  Result := gD2DE.Texture_GetWidth(f_DXTexture);
end;

procedure Td2dTexture.pm_SetSrcPicHeight(const Value: Integer);
begin
 f_SrcPicHeight := Value;
end;

procedure Td2dTexture.pm_SetSrcPicWidth(const Value: Integer);
begin
 f_SrcPicWidth := Value;
end;

end.