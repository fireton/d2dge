unit d2dSprite;

interface
uses
 d2dTypes,
 d2dInterfaces,
 d2dClasses;

type
 Td2dSprite = class(Td2dProtoObject)
 private
  procedure DoFlipX;
  procedure DoFlipY;
  function pm_GetBlendMode: Integer;
  function pm_GetHeight: Single;
  function pm_GetWidth: Single;
  procedure pm_SetBlendMode(const Value: Integer);
  procedure pm_SetFlipX(const Value: Boolean);
  procedure pm_SetFlipY(const Value: Boolean);
  procedure pm_SetHeight(const Value: Single);
  procedure pm_SetTexture(const Value: Id2dTexture);
  procedure pm_SetWidth(const Value: Single);
 protected
  f_FlipX: Boolean;
  f_FlipY: Boolean;
  f_Height: Single;
  f_HotX: Integer;
  f_HotY: Integer;
  f_Quad: Td2dQuad;
  f_Texture: Id2dTexture;
  f_TexX, f_TexY: Single;
  f_TexWidth, f_TexHeight: Single;
  f_Width: Single;
  function pm_GetValid: Boolean; virtual;
  procedure RecalcQuad;
 public
  constructor Create(aTex: Id2dTexture; aTexX, aTexY: Integer; aWidth, aHeight: Integer);
  procedure Render(const aX, aY: Single);
  procedure RenderEx(const aX, aY: Single; aRot: Single; aHScale: Single = 1; aVScale: Single = 0);
  procedure SetColor(aColor: Longword; aVertex: Integer = -1);
  procedure SetZ(aZ: Single; aVertex: Integer = -1);
  property BlendMode: Integer read pm_GetBlendMode write pm_SetBlendMode;
  property FlipX: Boolean read f_FlipX write pm_SetFlipX;
  property FlipY: Boolean read f_FlipY write pm_SetFlipY;
  property Height: Single read pm_GetHeight write pm_SetHeight;
  property HotX: Integer read f_HotX write f_HotX;
  property HotY: Integer read f_HotY write f_HotY;
  property Texture: Id2dTexture read f_Texture write pm_SetTexture;
  property Valid: Boolean read pm_GetValid;
  property Width: Single read pm_GetWidth write pm_SetWidth;
 end;

 Td2dMultiFrameSprite = class(Td2dSprite)
 private
  procedure pm_SetCurFrame(const Value: Integer);
 protected
  f_CurFrame: Integer;
  f_FramesCount: Integer;
 public
  constructor Create(aTex: Id2dTexture; aNFrames: Integer; aTx, aTy, aWidth, aHeight: Integer);
  property CurFrame: Integer read f_CurFrame write pm_SetCurFrame;
  property FramesCount: Integer read f_FramesCount;
 end;

 Td2dBaseAnimation = class(Td2dMultiFrameSprite)
 private
 protected
  f_Playing: Boolean;
  procedure DoUpdate(aDeltaTime: Single); virtual; abstract;
 public
  constructor Create(aTex: Id2dTexture; aNFrames: Integer; aTx, aTy, aWidth, aHeight: Integer);
  procedure Play; virtual;
  procedure Resume; virtual;
  procedure Stop; virtual;
  procedure Update(aDeltaTime: Single);
  property Playing: Boolean read f_Playing write f_Playing;
 end;

 Td2dLoopType = (lt_PingPong, lt_OverAgain);

 Td2dTimedAnimation = class(Td2dBaseAnimation)
 private
  f_DFrame: Integer;
  f_Looped: Boolean;
  f_LoopType: Td2dLoopType;
  f_Speed: Single;
  f_TimeSinceLastFrame: Double;
  function pm_GetReverse: Boolean;
  procedure pm_SetReverse(const aValue: Boolean);
 protected
  procedure DoUpdate(aDeltaTime: Single); override;
 public
  constructor Create(aTex: Id2dTexture; aNFrames: Integer; aTx, aTy, aWidth,
      aHeight: Integer);
  procedure Play; override;
  property Looped: Boolean read f_Looped write f_Looped;
  property LoopType: Td2dLoopType read f_LoopType write f_LoopType;
  property Reverse: Boolean read pm_GetReverse write pm_SetReverse;
  property Speed: Single read f_Speed write f_Speed;
  property TimeSinceLastFrame: Double read f_TimeSinceLastFrame write
      f_TimeSinceLastFrame;
 end;

 Td2dRectangle = class(Td2dSprite)
 protected
  function pm_GetValid: Boolean; override;
 public
  constructor Create(const aWidth, aHeight: Integer; const aColor: Td2dColor);
 end;

 

implementation
uses
 d2dCore;

constructor Td2dSprite.Create(aTex: Id2dTexture; aTexX, aTexY: Integer; aWidth, aHeight: Integer);
begin
 inherited Create;
 f_TexX := aTexX;
 f_TexY := aTexY;
 f_Width := aWidth;
 f_Height := aHeight;
 Texture := aTex;
 SetColor($FFFFFFFF);
end;

procedure Td2dSprite.DoFlipX;
var
 l_TX: Single;
 l_TY: Single;
begin
 with f_Quad do
 begin
  l_TX := V[0].TX; V[0].TX := V[1].TX; V[1].TX := l_TX;
  l_TY := V[0].TY; V[0].TY := V[1].TY; V[1].TY := l_TY;
  l_TX := V[3].TX; V[3].TX := V[2].TX; V[2].TX := l_TX;
  l_TY := V[3].TY; V[3].TY := V[2].TY; V[2].TY := l_TY;
 end;
end;

procedure Td2dSprite.DoFlipY;
var
 l_TX: Single;
 l_TY: Single;
begin
 with f_Quad do
 begin
  l_TX := V[0].TX; V[0].TX := V[3].TX; V[3].TX := l_TX;
  l_TY := V[0].TY; V[0].TY := V[3].TY; V[3].TY := l_TY;
  l_TX := V[1].TX; V[1].TX := V[2].TX; V[2].TX := l_TX;
  l_TY := V[1].TY; V[1].TY := V[2].TY; V[2].TY := l_TY;
 end;
end;

function Td2dSprite.pm_GetBlendMode: Integer;
begin
 Result := f_Quad.Blend;
end;

function Td2dSprite.pm_GetHeight: Single;
begin
 Result := f_Height;
end;

function Td2dSprite.pm_GetValid: Boolean;
begin
 Result := f_Texture <> nil;
end;

function Td2dSprite.pm_GetWidth: Single;
begin
 Result := f_Width;
end;

procedure Td2dSprite.pm_SetBlendMode(const Value: Integer);
begin
 f_Quad.Blend := Value;
end;

procedure Td2dSprite.pm_SetFlipX(const Value: Boolean);
begin
 if f_FlipX <> Value then
 begin
  DoFlipX;
  f_FlipX := not f_FlipX;
 end;
end;

procedure Td2dSprite.pm_SetFlipY(const Value: Boolean);
begin
 if f_FlipY <> Value then
 begin
  DoFlipY;
  f_FlipY := not f_FlipY;
 end;
end;

procedure Td2dSprite.pm_SetHeight(const Value: Single);
begin
 if Value <> f_Height then
 begin
  f_Height := Value;
  RecalcQuad;
 end; 
end;

procedure Td2dSprite.pm_SetTexture(const Value: Id2dTexture);
begin
 f_Texture := Value;
 RecalcQuad;
end;

procedure Td2dSprite.pm_SetWidth(const Value: Single);
begin
 if Value <> f_Width then
 begin
  f_Width := Value;
  RecalcQuad;
 end; 
end;

procedure Td2dSprite.RecalcQuad;
var
 l_TexX1, l_TexY1, l_TexX2, l_TexY2: Single;
begin
 if f_Texture <> nil then
 begin
  f_TexWidth  := gD2DE.Texture_GetWidth(f_Texture);
  f_TexHeight := gD2DE.Texture_GetHeight(f_Texture);
 end
 else
 begin
  f_TexWidth := 1.0;
  f_TexHeight := 1.0;
 end;

 if f_Texture <> nil then
  f_Quad.Tex := f_Texture.DirectXTexture
 else
  f_Quad.Tex := nil;  

 l_TexX1 := f_TexX / f_TexWidth;
 l_TexY1 := f_TexY / f_TexHeight;
 l_TexX2 := (f_TexX + f_Width) / f_TexWidth;
 l_TexY2 := (f_TexY + f_Height) / f_TexHeight;

 with f_Quad do
 begin
  V[0].TX := l_TexX1; V[0].TY := l_TexY1; V[0].Z := 0.5;
  V[1].TX := l_TexX2; V[1].TY := l_TexY1; V[1].Z := 0.5;
  V[2].TX := l_TexX2; V[2].TY := l_TexY2; V[2].Z := 0.5;
  V[3].TX := l_TexX1; V[3].TY := l_TexY2; V[3].Z := 0.5; 
  Blend := BLEND_DEFAULT;
 end;

 if f_FlipX then
  DoFlipX;
 if f_FlipY then
  DoFlipY; 
end;

procedure Td2dSprite.Render(const aX, aY: Single);
var
 l_X1, l_X2, l_Y1, l_Y2: Single;
begin
 if not Valid then
  Exit;
 l_X1 := aX - f_HotX;
 l_Y1 := aY - f_HotY;
 l_X2 := aX + f_Width - f_HotX;
 l_Y2 := aY + f_Height - f_HotY;
 with f_Quad do
 begin
  V[0].X := l_X1; V[0].Y := l_Y1;
  V[1].X := l_X2; V[1].Y := l_Y1;
  V[2].X := l_X2; V[2].Y := l_Y2;
  V[3].X := l_X1; V[3].Y := l_Y2;
 end;
 gD2DE.Gfx_RenderQuad(f_Quad);
end;

procedure Td2dSprite.RenderEx(const aX, aY: Single; aRot: Single; aHScale: Single = 1; aVScale: Single = 0);
var
 l_TX1, l_TX2, l_TY1, l_TY2: Single;
 l_Cos, l_Sin: Single;
begin
 if not Valid then
  Exit;
 if aVScale = 0 then
  aVScale := aHScale;
 l_TX1 := -f_HotX * aHScale;
 l_TY1 := -f_HotY * aVScale;
 l_TX2 := (f_Width - f_HotX)*aHScale;
 l_TY2 := (f_Height - f_HotY)*aVScale;

 if aRot <> 0.0 then
 begin
  l_Cos := Cos(aRot);
  l_Sin := Sin(aRot);

  with f_Quad do
  begin
   V[0].X := l_TX1*l_Cos - l_TY1*l_Sin + aX;
   V[0].Y := l_TX1*l_Sin + l_TY1*l_Cos + aY;

   V[1].X := l_TX2*l_Cos - l_TY1*l_Sin + aX;
   V[1].Y := l_TX2*l_Sin + l_TY1*l_Cos + aY;

   V[2].X := l_TX2*l_Cos - l_TY2*l_Sin + aX;
   V[2].Y := l_TX2*l_Sin + l_TY2*l_Cos + aY;

   V[3].X := l_TX1*l_Cos - l_TY2*l_Sin + aX;
   V[3].Y := l_TX1*l_Sin + l_TY2*l_Cos + aY;
  end;
 end
 else
 with f_Quad do
 begin
  V[0].X := l_TX1 + aX; V[0].Y := l_TY1 + aY;
  V[1].X := l_TX2 + aX; V[1].Y := l_TY1 + aY;
  V[2].X := l_TX2 + aX; V[2].Y := l_TY2 + aY;
  V[3].X := l_TX1 + aX; V[3].Y := l_TY2 + aY;
 end;
 gD2DE.Gfx_RenderQuad(f_Quad);
end;

procedure Td2dSprite.SetColor(aColor: Longword; aVertex: Integer = -1);
begin
 if (aVertex > -1) and (aVertex < 4) then
  f_Quad.V[aVertex].Col := aColor
 else
  with f_Quad do
  begin
   V[0].Col := aColor;
   V[1].Col := aColor;
   V[2].Col := aColor;
   V[3].Col := aColor;
  end;
end;

procedure Td2dSprite.SetZ(aZ: Single; aVertex: Integer = -1);
begin
 if (aVertex > -1) and (aVertex < 4) then
  f_Quad.V[aVertex].Z := aZ
 else
  with f_Quad do
  begin
   V[0].Z := aZ;
   V[1].Z := aZ;
   V[2].Z := aZ;
   V[3].Z := aZ;
  end;
end;

constructor Td2dBaseAnimation.Create(aTex: Id2dTexture; aNFrames: Integer; aTx, aTy, aWidth, aHeight: Integer);
begin
 inherited Create(aTex, aNFrames, aTx, aTy, aWidth, aHeight);
 f_Playing := False;
end;

procedure Td2dBaseAnimation.Play;
begin
 f_Playing := True;
end;

procedure Td2dBaseAnimation.Resume;
begin
 f_Playing := True;
end;

procedure Td2dBaseAnimation.Stop;
begin
 f_Playing := False;
end;

procedure Td2dBaseAnimation.Update(aDeltaTime: Single);
begin
 if f_Playing then
  DoUpdate(aDeltaTime);
end;

constructor Td2dTimedAnimation.Create(aTex: Id2dTexture; aNFrames: Integer;
    aTx, aTy, aWidth, aHeight: Integer);
begin
 inherited;
 f_Looped   := True;
 f_LoopType := lt_OverAgain;
 f_Speed    := 0.25;
 Reverse  := False;
end;

procedure Td2dTimedAnimation.DoUpdate(aDeltaTime: Single);
var
 l_IncFrames: Integer;
 l_TargetFrame: Integer;
begin
 if f_TimeSinceLastFrame < 0 then
  f_TimeSinceLastFrame := 0
 else
  f_TimeSinceLastFrame := f_TimeSinceLastFrame + aDeltaTime;

 l_IncFrames := Trunc(f_TimeSinceLastFrame / f_Speed);
 if l_IncFrames > 0 then
 begin
  f_TimeSinceLastFrame := f_TimeSinceLastFrame - (f_Speed * l_IncFrames);
  l_TargetFrame := f_CurFrame + (f_DFrame * l_IncFrames);
  if l_TargetFrame > f_FramesCount-1 then
  begin
   if f_Looped then
   begin
    if f_LoopType = lt_PingPong then
     begin
      f_DFrame := -1;
      l_TargetFrame := f_FramesCount + l_TargetFrame - 1;
     end;
   end
   else
   begin
    l_TargetFrame := f_FramesCount-1;
    f_Playing := False;
   end;
  end
  else
   if l_TargetFrame < 0 then
   begin
    if f_Looped then
    begin
     if f_LoopType = lt_PingPong then
      begin
       f_DFrame := 1;
       l_TargetFrame := -l_TargetFrame;
      end;
    end
    else
    begin
     l_TargetFrame := 0;
     f_Playing := False;
    end;
   end;
  CurFrame := l_TargetFrame;
 end;
end;

procedure Td2dTimedAnimation.pm_SetReverse(const aValue: Boolean);
begin
 if aValue then
  f_DFrame := -1
 else
  f_DFrame := 1;
end;

procedure Td2dTimedAnimation.Play;
begin
 inherited;
 f_TimeSinceLastFrame := -1;
 if Reverse then
  CurFrame := f_FramesCount-1
 else
  CurFrame := 0;
end;

function Td2dTimedAnimation.pm_GetReverse: Boolean;
begin
 Result := f_DFrame < 0;
end;

constructor Td2dMultiFrameSprite.Create(aTex: Id2dTexture; aNFrames: Integer; aTx, aTy, aWidth, aHeight: Integer);
begin
 inherited Create(aTex, aTx, aTy, aWidth, aHeight);
 f_FramesCount := aNFrames;
 f_CurFrame := 0;
end;

procedure Td2dMultiFrameSprite.pm_SetCurFrame(const Value: Integer);
var
 l_Tx1, l_Tx2, l_Ty1, l_Ty2: Single;
 l_CurFlipX, l_CurFlipY: Boolean;
 l_NumCols: Integer;
 l_TargetFrame: Integer;
begin
 if f_CurFrame <> Value then
 begin
  l_CurFlipX := f_FlipX;
  l_CurFlipY := f_FlipY;
  l_NumCols  := Trunc((f_Texture.SrcPicWidth - f_TexX) / f_Width);
  if l_NumCols <= 0 then
   l_NumCols := 1;
  l_TargetFrame := Value mod f_FramesCount;
  if l_TargetFrame < 0 then
   l_TargetFrame := f_FramesCount + l_TargetFrame;
  f_CurFrame := l_TargetFrame;

  l_Ty1 := f_TexY;
  l_Tx1 := f_TexX + l_TargetFrame * f_Width;
  if (l_Tx1 > f_Texture.SrcPicWidth - f_Width) then
  begin
   l_Tx1 := f_TexX + (l_TargetFrame mod l_NumCols) * f_Width;
   l_Ty1 := l_Ty1 + (l_TargetFrame div l_NumCols) * f_Height;
  end;

  l_Tx2 := l_Tx1 + f_Width;
  l_Ty2 := l_Ty1 + f_Height;

  l_Tx1 := l_Tx1 / f_TexWidth;
  l_Tx2 := l_Tx2 / f_TexWidth;
  l_Ty1 := l_Ty1 / f_TexHeight;
  l_Ty2 := l_Ty2 / f_TexHeight;

  with f_Quad do
  begin
   V[0].TX := l_Tx1; V[0].TY := l_Ty1;
   V[1].TX := l_Tx2; V[1].TY := l_Ty1;
   V[2].TX := l_Tx2; V[2].TY := l_Ty2;
   V[3].TX := l_Tx1; V[3].TY := l_Ty2;
  end;

  // restoring flips
  f_FlipX := False;
  f_FlipY := False;
  FlipX := l_CurFlipX;
  FlipY := l_CurFlipY;
 end;
end;

constructor Td2dRectangle.Create(const aWidth, aHeight: Integer; const aColor: Td2dColor);
begin
 inherited Create(nil, 0, 0, aWidth, aHeight);
 SetColor(aColor);
end;

function Td2dRectangle.pm_GetValid: Boolean;
begin
 Result := True;
end;

end.
