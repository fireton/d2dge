unit d2dGIF;

interface
uses
 Windows,
 Classes,
 Graphics,
 d2dTypes,
 d2dSprite,
 GIFImage;

type
 Td2dGIFSprite = class(Td2dSprite)
 private
  f_GIF: TGIFImage;
  f_Painter: TGIFPainter;
  f_Bitmap: TBitmap;
  f_BmpIsSaved: Boolean;
  f_NeedToUpdateFrame: Boolean;
  f_SavedBmp: TMemoryStream;
  procedure DoOnPaint(aSender: TObject);
  function pm_GetAniSpeed: Integer;
  function pm_GetFrame: Integer;
  procedure pm_SetAniSpeed(const Value: Integer);
  procedure pm_SetFrame(const Value: Integer);
  procedure RenderFrame(aFrameNo: Integer);
  function SetupFrame: Boolean;
 protected
  procedure Cleanup; override;
 public
  constructor Create(aGIFFilename: string);
  procedure Start;
  procedure Stop;
  procedure Update(aDeltaTime: Single);
  property AniSpeed: Integer read pm_GetAniSpeed write pm_SetAniSpeed;
  property Frame: Integer read pm_GetFrame write pm_SetFrame;
 end;

implementation
uses
 SysUtils,
 Direct3D8,
 D3DX8,
 d2dInterfaces,
 d2dCore;

constructor Td2dGIFSprite.Create(aGIFFilename: string);
var
 l_Stream: TStream;
 l_Rect: TRect;
begin
 inherited Create(nil, 0, 0, 10, 10);
 aGIFFilename := StringReplace(aGIFFilename, '/', '\', [rfReplaceAll]);
 f_GIF := TGIFImage.Create;
 l_Stream := gD2DE.Resource_CreateStream(aGIFFilename);
 if l_Stream <> nil then
 begin
  try
   f_GIF.LoadFromStream(l_Stream);
  finally
   FreeAndNil(l_Stream);
  end;
  f_Width := f_GIF.Width;
  f_Height := f_GIF.Height;
  f_Bitmap := TBitmap.Create;
  f_Bitmap.Assign(f_GIF);
  f_Bitmap.PixelFormat := pf32bit;
  with f_Bitmap.Canvas.Brush do
  begin
   Color := $FF00FF;
   Style := bsSolid;
  end;
  l_Rect := Rect(0,0,f_GIF.Width, f_GIF.Height);
  f_Bitmap.Canvas.FillRect(l_Rect);
  if f_GIF.Images.Count > 1 then
  begin
   f_GIF.OnPaint := DoOnPaint;
   f_Painter := f_GIF.Paint(f_Bitmap.Canvas, l_Rect, GIFImageDefaultDrawOptions + [goLoopContinously]);
  end; 
  RenderFrame(0);
 end;
end;

procedure Td2dGIFSprite.Cleanup;
begin
 FreeAndNil(f_GIF);
 FreeAndNil(f_Bitmap);
 FreeAndNil(f_SavedBmp);
 inherited;
end;

procedure Td2dGIFSprite.DoOnPaint(aSender: TObject);
begin
 f_BmpIsSaved := False;
 f_NeedToUpdateFrame := True;
end;

function Td2dGIFSprite.pm_GetAniSpeed: Integer;
begin
 if f_Painter <> nil then
  Result := f_Painter.AnimationSpeed
 else
  Result := 0;
end;

function Td2dGIFSprite.pm_GetFrame: Integer;
begin
 if f_Painter <> nil then
  Result := f_Painter.ActiveImage
 else
  Result := 0;
end;

procedure Td2dGIFSprite.pm_SetAniSpeed(const Value: Integer);
var
 l_Frame: Integer;
begin
 if f_Painter <> nil then
 begin
  //l_Frame := Frame;
  f_Painter.AnimationSpeed := Value;
  //f_FrameToSet := l_Frame;
 end;
end;

procedure Td2dGIFSprite.pm_SetFrame(const Value: Integer);
var
 l_FrameNo: Integer;
begin
 if f_GIF.Images.Count > 0 then
 begin
  l_FrameNo := Abs(Value) mod f_GIF.Images.Count;
  if f_Painter <> nil then
   f_Painter.ActiveImage :=  l_FrameNo;
  RenderFrame(l_FrameNo);
 end;
end;

procedure Td2dGIFSprite.RenderFrame(aFrameNo: Integer);
var
 l_Rect: TRect;
begin
 with f_Bitmap.Canvas.Brush do
 begin
  Color := $FF00FF;
  Style := bsSolid;
 end;
 l_Rect := Rect(0,0,f_GIF.Width, f_GIF.Height);
 f_Bitmap.Canvas.FillRect(l_Rect);
 f_GIF.Images[aFrameNo].Draw(f_Bitmap.Canvas, l_Rect, True, False);
 f_BmpIsSaved := False;
 f_NeedToUpdateFrame := True;
end;

function Td2dGIFSprite.SetupFrame: Boolean;
var
 l_Tex   : Id2dTexture;
 l_Info : D3DXIMAGE_INFO;
begin
 if f_SavedBmp = nil then
  f_SavedBmp := TMemoryStream.Create;
 if not f_BmpIsSaved then
 begin
  f_SavedBmp.Clear;
  f_Bitmap.SaveToStream(f_SavedBmp);
  f_BmpIsSaved := True;
 end;
 l_Tex := gD2DE.Texture_CreatePrim(f_SavedBmp.Memory, f_SavedBmp.Size, False, $FFFF00FF);
 Result := l_Tex <> nil;
 if Result then
  Texture := l_Tex;
end;

procedure Td2dGIFSprite.Start;
begin
 if f_Painter <> nil then
  f_Painter.Start;
end;

procedure Td2dGIFSprite.Stop;
begin
 if f_Painter <> nil then
  f_Painter.Suspend;
end;

procedure Td2dGIFSprite.Update(aDeltaTime: Single);
begin
 if f_NeedToUpdateFrame then
 begin
  if SetupFrame then
   f_NeedToUpdateFrame := False;
 end;
end;

end.