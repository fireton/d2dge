unit d2dFrames;

interface

uses
 d2dTypes,
 d2dInterfaces;

type
 Td2dHorizontalFrameParts = (hfpLeft, hfpMiddle, hfpRight);
 Td2dVerticalFrameParts   = (vfpTop, vfpMiddle, vfpBottom);

 Td2dHorizFrame = class
 private
  f_Height   : Integer;
  f_Quad     : array [Td2dHorizontalFrameParts] of Td2dQuad;
  f_Width    : array [Td2dHorizontalFrameParts] of Integer;
  f_MinWidth : Integer;
  function pm_GetLeftWidth: Integer;
  function pm_GetRightWidth: Integer;
 public
  constructor Create(const aTex: Id2dTexture; aLeft, aTop, aRight, aBottom, aLeftWidth, aMidWidth: Integer);
  procedure CorrectWidth(var theWidth: Integer; aToGreater: Boolean = True);
  procedure Render(aX, aY: Single; aWidth: Integer);
  function GetMidWidth(const aWidth: Integer): Integer;
  property Height: Integer read f_Height;
  property LeftWidth: Integer read pm_GetLeftWidth;
  property MinWidth: Integer read f_MinWidth;
  property RightWidth: Integer read pm_GetRightWidth;
 end;



 Td2dFrame = class
 private
  f_Quad   : array [Td2dHorizontalFrameParts, Td2dVerticalFrameParts] of Td2dQuad;
  f_Width  : array [Td2dHorizontalFrameParts] of Integer;
  f_Height : array [Td2dVerticalFrameParts] of Integer;
  f_MinWidth : Integer;
  f_MinHeight: Integer;
 public
  constructor Create(aTex: Id2dTexture; aLeft, aTop, aRight, aBottom,
                     aLeftWidth, aMidWidth, aTopHeight, aMidHeight: Integer);
 end;

implementation
uses
 Direct3D8,
 d2dCore;

constructor Td2dHorizFrame.Create(const aTex: Id2dTexture; aLeft, aTop, aRight, aBottom, aLeftWidth, aMidWidth: Integer);
var
 l_TexWidth: Single;
 l_TexHeight: Single;
 l_TY, l_BY: Single;
 l_LCX, l_LMX, l_RMX, l_RCX: Single;
 l_DXTex : IDirect3DTexture8;
begin
 inherited Create;
 f_Width[hfpLeft] := aLeftWidth;
 f_Width[hfpMiddle] := aMidWidth;
 f_MinWidth := aRight - aLeft;
 f_Width[hfpRight] := f_MinWidth - f_Width[hfpMiddle] - f_Width[hfpLeft];
 f_Height := aBottom - aTop;
 if aTex <> nil then
 begin
  l_TexWidth  := gD2DE.Texture_GetWidth(aTex);
  l_TexHeight := gD2DE.Texture_GetHeight(aTex);
  l_DXTex := aTex.DirectXTexture;
 end
 else
 begin
  l_TexWidth := 1.0;
  l_TexHeight := 1.0;
  l_DXTex := nil;
 end;
 // y-coords
 l_TY := aTop    / l_TexHeight; // top
 l_BY := aBottom / l_TexHeight; // bottom
 // x-coords
 l_LCX := aLeft   / l_TexWidth; // left cap x
 l_RCX := aRight  / l_TexWidth; // right cap x
 l_LMX := (aLeft + aLeftWidth) / l_TexWidth; // left middle x
 l_RMX := (aLeft + aLeftWidth + aMidWidth) / l_TexWidth; // right middle x

 // left cap quad
 with f_Quad[hfpLeft] do
 begin
  V[0].TX := l_LCX; V[0].TY := l_TY; V[0].Z := 0.5; V[0].Col := $FFFFFFFF;
  V[1].TX := l_LMX; V[1].TY := l_TY; V[1].Z := 0.5; V[1].Col := $FFFFFFFF;
  V[2].TX := l_LMX; V[2].TY := l_BY; V[2].Z := 0.5; V[2].Col := $FFFFFFFF;
  V[3].TX := l_LCX; V[3].TY := l_BY; V[3].Z := 0.5; V[3].Col := $FFFFFFFF;
  Blend := BLEND_DEFAULT;
  Tex := l_DXTex;
 end;

 // right cap quad
 with f_Quad[hfpRight] do
 begin
  V[0].TX := l_RMX; V[0].TY := l_TY; V[0].Z := 0.5; V[0].Col := $FFFFFFFF;
  V[1].TX := l_RCX; V[1].TY := l_TY; V[1].Z := 0.5; V[1].Col := $FFFFFFFF;
  V[2].TX := l_RCX; V[2].TY := l_BY; V[2].Z := 0.5; V[2].Col := $FFFFFFFF;
  V[3].TX := l_RMX; V[3].TY := l_BY; V[3].Z := 0.5; V[3].Col := $FFFFFFFF;
  Blend := BLEND_DEFAULT;
  Tex := l_DXTex;
 end;

 // middle quad
 with f_Quad[hfpMiddle] do
 begin
  V[0].TX := l_LMX; V[0].TY := l_TY; V[0].Z := 0.5; V[0].Col := $FFFFFFFF;
  V[1].TX := l_RMX; V[1].TY := l_TY; V[1].Z := 0.5; V[1].Col := $FFFFFFFF;
  V[2].TX := l_RMX; V[2].TY := l_BY; V[2].Z := 0.5; V[2].Col := $FFFFFFFF;
  V[3].TX := l_LMX; V[3].TY := l_BY; V[3].Z := 0.5; V[3].Col := $FFFFFFFF;
  Blend := BLEND_DEFAULT;
  Tex := l_DXTex;
 end;
end;

procedure Td2dHorizFrame.CorrectWidth(var theWidth: Integer; aToGreater: Boolean = True);
var
 l_MW: Integer;
 l_Frac: Integer;
begin
 l_MW := theWidth - f_Width[hfpLeft] - f_Width[hfpRight];
 if l_MW < f_Width[hfpMiddle] then
 begin
  theWidth := f_MinWidth;
  Exit;
 end;
 l_Frac := l_MW mod f_Width[hfpMiddle];
 if l_Frac > 0 then
 begin
  if aToGreater then
   theWidth := theWidth - l_Frac + f_Width[hfpMiddle]
  else
   theWidth := theWidth - l_Frac;
 end;
end;

function Td2dHorizFrame.GetMidWidth(const aWidth: Integer): Integer;
begin
 Result := aWidth - f_Width[hfpLeft] - f_Width[hfpRight];
end;

function Td2dHorizFrame.pm_GetLeftWidth: Integer;
begin
 Result := f_Width[hfpLeft];
end;

function Td2dHorizFrame.pm_GetRightWidth: Integer;
begin
 Result := f_Width[hfpRight];
end;

procedure Td2dHorizFrame.Render(aX, aY: Single; aWidth: Integer);
var
 l_BottomY: Single;
 l_LeftM, l_RightM: Single;
 l_MiddlesCount: Integer;
 I: Integer;
begin
 CorrectWidth(aWidth);

 l_BottomY := aY + f_Height;
 l_LeftM   := aX + f_Width[hfpLeft];

 // render left cap
 with f_Quad[hfpLeft] do
 begin
  V[0].X := aX;      V[0].Y := aY;
  V[1].X := l_LeftM; V[1].Y := aY;
  V[2].X := l_LeftM; V[2].Y := l_BottomY;
  V[3].X := aX;      V[3].Y := l_BottomY;
 end;
 gD2DE.Gfx_RenderQuad(f_Quad[hfpLeft]);

 // render middle part
 l_MiddlesCount := (aWidth - f_Width[hfpLeft] - f_Width[hfpRight]) div f_Width[hfpMiddle];
 for I := 1 to l_MiddlesCount do
 begin
  l_RightM := l_LeftM + f_Width[hfpMiddle];
  with f_Quad[hfpMiddle] do
  begin
   V[0].X := l_LeftM;  V[0].Y := aY;
   V[1].X := l_RightM; V[1].Y := aY;
   V[2].X := l_RightM; V[2].Y := l_BottomY;
   V[3].X := l_LeftM;  V[3].Y := l_BottomY;
  end;
  gD2DE.Gfx_RenderQuad(f_Quad[hfpMiddle]);
  l_LeftM := l_RightM;
 end;

 // render right cap
 l_RightM := l_LeftM + f_Width[hfpRight];
 with f_Quad[hfpRight] do
 begin
  V[0].X := l_LeftM;  V[0].Y := aY;
  V[1].X := l_RightM; V[1].Y := aY;
  V[2].X := l_RightM; V[2].Y := l_BottomY;
  V[3].X := l_LeftM;  V[3].Y := l_BottomY;
 end;
 gD2DE.Gfx_RenderQuad(f_Quad[hfpRight]);
end;

constructor Td2dFrame.Create(aTex: Id2dTexture;
                             aLeft, aTop, aRight, aBottom, aLeftWidth,
                             aMidWidth, aTopHeight, aMidHeight: Integer);
begin
 inherited Create;
 f_Width[hfpLeft]   := aLeftWidth;
 f_Width[hfpMiddle] := aMidWidth;
 f_MinWidth         := (aRight - aLeft);
 f_Width[hfpRight]  := f_MinWidth - f_Width[hfpLeft] - f_Width[hfpMiddle];

 f_Height[vfpTop]    := aTopHeight;
 f_Height[vfpMiddle] := aMidHeight;
 f_MinHeight         := (aBottom - aTop);
 f_Height[vfpBottom] := f_MinHeight - f_Height[vfpTop] - f_Height[vfpMiddle];
end;


end.