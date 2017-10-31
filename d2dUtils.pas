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
unit d2dUtils;

interface
uses
 Classes,
 d2dTypes;

type
 Td2dFiler = class(TObject)
 protected
  f_Stream: TStream;
 public
  constructor Create(aStream: TStream);
  function ReadInteger: Integer;
  function ReadDouble: Double;
  function ReadString: string;
  function ReadBoolean: Boolean;
  function ReadSingle: Single;
  function ReadPoint: Td2dPoint;
  function ReadColor: Td2dColor;
  function ReadByte: Byte;
  procedure WriteInteger(aValue: Integer);
  procedure WriteDouble(aValue: Double);
  procedure WriteString(aString: string);
  procedure WriteBoolean(aValue: Boolean);
  procedure WriteSingle(aValue: Single);
  procedure WritePoint(aValue: Td2dPoint);
  procedure WriteColor(aValue: Td2dColor);
  procedure WriteByte(aValue: Byte);
  property Stream: TStream read f_Stream;
 end;

 Td2dBasicBlender = class
 private
  f_IsRunning: Boolean;
 protected
  procedure DoUpdate(aDelta: Single); virtual; abstract;
 public
  procedure Run; virtual;
  procedure Stop; virtual;
  procedure Update(aDelta: Single);
  procedure Save(aFiler: Td2dFiler); virtual;
  constructor Load(aFiler: Td2dFiler); virtual;
  property IsRunning: Boolean read f_IsRunning write f_IsRunning;
 end;

 Td2dColorBlender = class(Td2dBasicBlender)
 private
  f_Current: Td2dColor;
  f_Target: Td2dColor;
  f_CA, f_CR, f_CG, f_CB: Single;
  f_TA, f_TR, f_TG, f_TB: Single;
  f_SpeedA, f_SpeedR, f_SpeedG, f_SpeedB: Single;
 protected
  procedure DoUpdate(aDelta: Single); override;
 public
  constructor Create(const aTime: Single; const aStartColor, aTargetColor: Td2dColor);
  constructor Load(aFiler: Td2dFiler); override;
  procedure Save(aFiler: Td2dFiler); override;
  property Current: Td2dColor read f_Current;
  property Target: Td2dColor read f_Target;
 end;

 Td2dPositionBlender = class(Td2dBasicBlender)
 private
  f_Current: Td2dPoint;
  f_Target: Td2dPoint;
  f_Speed: Td2dPoint;
 protected
  procedure DoUpdate(aDelta: Single); override;
 public
  constructor Create(const aTime: Single; const aStartPos, aTargetPos: Td2dPoint);
  constructor Load(aFiler: Td2dFiler); override;
  procedure Save(aFiler: Td2dFiler); override;
  property Current: Td2dPoint read f_Current;
 end;

 Td2dSimpleBlender = class(Td2dBasicBlender)
 private
  f_Current: Single;
  f_Speed: Single;
  f_Target: Single;
 protected
  procedure DoUpdate(aDelta: Single); override;
 public
  constructor Create(const aTime: Single; const aStartValue, aTargetValue: Single);
  constructor Load(aFiler: Td2dFiler); override;
  procedure Save(aFiler: Td2dFiler); override;
  property Current: Single read f_Current;
 end;

 Td2dMemoryStream = class(TMemoryStream)
 public
  function ExtractMemory(theSize: PLongWord): Pointer;
 end;

procedure D2DRenderCross(aX, aY: Single; aSize: Integer = 4; aColor: Cardinal = $FFFF0000);

function D2DIsRectIntersected(const aR1, aR2: Td2dRect): Boolean;

function D2DIsPointInRect(const aX, aY: Single; const aRect: Td2dRect): Boolean; overload;
function D2DIsPointInRect(const aX, aY: Single; aLeft, aTop, aWidth, aHeight: Single): Boolean; overload;

function D2DMoveRect(const aRect: Td2dRect; aDX, aDY: Single): Td2dRect;

procedure D2DRenderRect(const aRect: Td2dRect; aColor: Cardinal; aZ: Single = 0);

function  D2DMakeFilledRectQuad(const aRect: Td2dRect; aColor: Cardinal): Td2dQuad;
procedure D2DRenderFilledRect(const aRect: Td2dRect; aColor: Cardinal);

function D2AttachZipPack(const aFilename: AnsiString): Boolean;


implementation
uses
 SysUtils,
 d2dCore,
 d2dInterfaces,
 d2dZipPack;

procedure D2DRenderCross(aX, aY: Single; aSize: Integer = 4; aColor: Cardinal = $FFFF0000);
begin
 gD2DE.Gfx_RenderLine(aX-aSize, aY-aSize, aX+aSize, aY+aSize, aColor, 1);
 gD2DE.Gfx_RenderLine(aX-aSize, aY+aSize, aX+aSize, aY-aSize, aColor, 1);
end;

function D2DIsPointInRect(const aX, aY: Single; aLeft, aTop, aWidth, aHeight: Single): Boolean;
begin
 Result := (aX >= aLeft) and (aX <= aLeft + aWidth) and (aY >= aTop) and (aY <= aTop + aHeight);
end;

function D2DIsPointInRect(const aX, aY: Single; const aRect: Td2dRect): Boolean;
begin
 Result := (aX >= aRect.Left) and (aX <= aRect.Right) and (aY >= aRect.Top) and (aY <= aRect.Bottom);
end;

function D2DIsRectIntersected(const aR1, aR2: Td2dRect): Boolean;
 
begin
 Result :=
   D2DIsPointInRect(aR1.Left, aR1.Top, aR2)
   or
   D2DIsPointInRect(aR1.Right, aR1.Top, aR2)
   or
   D2DIsPointInRect(aR1.Left, aR1.Bottom, aR2)
   or
   D2DIsPointInRect(aR1.Right, aR1.Bottom, aR2);
end;

procedure D2DRenderRect(const aRect: Td2dRect; aColor: Cardinal; aZ: Single = 0);
begin
 gD2DE.Gfx_RenderLine(aRect.Left, aRect.Top, aRect.Right, aRect.Top, aColor, aZ);
 gD2DE.Gfx_RenderLine(aRect.Right, aRect.Top, aRect.Right, aRect.Bottom, aColor, aZ);
 gD2DE.Gfx_RenderLine(aRect.Right, aRect.Bottom, aRect.Left, aRect.Bottom, aColor, aZ);
 // here goes the dirty trick
 if gD2DE.Windowed then
  gD2DE.Gfx_RenderLine(aRect.Left, aRect.Bottom, aRect.Left, aRect.Top-1, aColor, aZ)
 else
  gD2DE.Gfx_RenderLine(aRect.Left, aRect.Bottom, aRect.Left, aRect.Top, aColor, aZ);
end;

procedure D2DRenderFilledRect(const aRect: Td2dRect; aColor: Cardinal);
begin
 gD2DE.Gfx_RenderQuad(D2DMakeFilledRectQuad(aRect, aColor));
end;

function D2DMakeFilledRectQuad(const aRect: Td2dRect; aColor: Cardinal): Td2dQuad;
var
 I: Integer;
begin
 FillChar(Result, SizeOf(Td2dQuad), 0);
 with Result do
 begin
  Blend := BLEND_DEFAULT;
  for I := 0 to 3 do
   V[I].Col := aColor;
  Result.V[0].X := aRect.Left;  Result.V[0].Y := aRect.Top;
  Result.V[1].X := aRect.Right; Result.V[1].Y := aRect.Top;
  Result.V[2].X := aRect.Right; Result.V[2].Y := aRect.Bottom;
  Result.V[3].X := aRect.Left;  Result.V[3].Y := aRect.Bottom;
 end;
end;

constructor Td2dBasicBlender.Load(aFiler: Td2dFiler);
begin
 inherited Create;
 f_IsRunning := aFiler.ReadBoolean;
end;

procedure Td2dBasicBlender.Run;
begin
 f_IsRunning := True;
end;

procedure Td2dBasicBlender.Save(aFiler: Td2dFiler);
begin
 aFiler.WriteBoolean(f_IsRunning);
end;

procedure Td2dBasicBlender.Stop;
begin
 f_IsRunning := False;
end;

procedure Td2dBasicBlender.Update(aDelta: Single);
begin
 if f_IsRunning then
  DoUpdate(aDelta);
end;

constructor Td2dColorBlender.Create(const aTime: Single; const aStartColor, aTargetColor: Td2dColor);
var
 l_SA, l_SR, l_SG, l_SB: Byte;
 l_TA, l_TR, l_TG, l_TB: Byte;
begin
 inherited Create;
 f_Current := aStartColor;
 f_Target := aTargetColor;
 Color2ARGB(aStartColor, l_SA, l_SR, l_SG, l_SB);
 Color2ARGB(aTargetColor, l_TA, l_TR, l_TG, l_TB);
 f_CA := l_SA;
 f_CR := l_SR;
 f_CG := l_SG;
 f_CB := l_SB;
 f_TA := l_TA;
 f_TR := l_TR;
 f_TG := l_TG;
 f_TB := l_TB;
 f_SpeedA := (l_TA - l_SA) / aTime;
 f_SpeedR := (l_TR - l_SR) / aTime;
 f_SpeedG := (l_TG - l_SG) / aTime;
 f_SpeedB := (l_TB - l_SB) / aTime;
end;

procedure Td2dColorBlender.DoUpdate(aDelta: Single);
begin
 f_CA := f_CA + f_SpeedA * aDelta;
 f_CR := f_CR + f_SpeedR * aDelta;
 f_CG := f_CG + f_SpeedG * aDelta;
 f_CB := f_CB + f_SpeedB * aDelta;

 if ((f_SpeedA > 0) and (f_CA > f_TA)) or ((f_SpeedA < 0) and (f_CA < f_TA)) then
 begin
  f_CA := f_TA;
  f_SpeedA := 0;
 end;
 if ((f_SpeedR > 0) and (f_CR > f_TR)) or ((f_SpeedR < 0) and (f_CR < f_TR)) then
 begin
  f_CR := f_TR;
  f_SpeedR := 0;
 end;
 if ((f_SpeedG > 0) and (f_CG > f_TG)) or ((f_SpeedG < 0) and (f_CG < f_TG)) then
 begin
  f_CG := f_TG;
  f_SpeedG := 0;
 end;
 if ((f_SpeedB > 0) and (f_CB > f_TB)) or ((f_SpeedB < 0) and (f_CB < f_TB)) then
 begin
  f_CB := f_TB;
  f_SpeedB := 0;
 end;
 if (f_SpeedA = 0) and (f_SpeedR = 0) and (f_SpeedG = 0) and (f_SpeedB = 0) then
  Stop;
 if not IsRunning then
  f_Current := f_Target
 else
  f_Current := ARGB(Trunc(f_CA), Trunc(f_CR), Trunc(f_CG), Trunc(f_CB));
end;

constructor Td2dColorBlender.Load(aFiler: Td2dFiler);
begin
 inherited Load(aFiler);
 with aFiler do
 begin
  f_CA := ReadSingle;
  f_CR := ReadSingle;
  f_CG := ReadSingle;
  f_CB := ReadSingle;

  f_SpeedA := ReadSingle;
  f_SpeedR := ReadSingle;
  f_SpeedG := ReadSingle;
  f_SpeedB := ReadSingle;

  f_TA := ReadSingle;
  f_TR := ReadSingle;
  f_TG := ReadSingle;
  f_TB := ReadSingle;

  f_Current := ReadColor;
  f_Target  := ReadColor;
 end;
end;

procedure Td2dColorBlender.Save(aFiler: Td2dFiler);
begin
 inherited Save(aFiler);
 with aFiler do
 begin
  WriteSingle(f_CA);
  WriteSingle(f_CR);
  WriteSingle(f_CG);
  WriteSingle(f_CB);

  WriteSingle(f_SpeedA);
  WriteSingle(f_SpeedR);
  WriteSingle(f_SpeedG);
  WriteSingle(f_SpeedB);

  WriteSingle(f_TA);
  WriteSingle(f_TR);
  WriteSingle(f_TG);
  WriteSingle(f_TB);

  WriteColor(f_Current);
  WriteColor(f_Target);
 end;
end;

constructor Td2dPositionBlender.Create(const aTime: Single; const aStartPos, aTargetPos: Td2dPoint);
begin
 inherited Create;
 f_Current := aStartPos;
 f_Target := aTargetPos;
 f_Speed.X := (aTargetPos.X - aStartPos.X) / aTime;
 f_Speed.Y := (aTargetPos.Y - aStartPos.Y) / aTime;
end;

procedure Td2dPositionBlender.DoUpdate(aDelta: Single);
begin
 f_Current.X := f_Current.X + f_Speed.X * aDelta;
 f_Current.Y := f_Current.Y + f_Speed.Y * aDelta;

 if ((f_Speed.X > 0) and (f_Current.X > f_Target.X)) or
    ((f_Speed.X < 0) and (f_Current.X < f_Target.X)) then
 begin
  f_Current.X := f_Target.X;
  f_Speed.X := 0;
 end;
 if ((f_Speed.Y > 0) and (f_Current.Y > f_Target.Y)) or
    ((f_Speed.Y < 0) and (f_Current.Y < f_Target.Y)) then
 begin
  f_Current.Y := f_Target.Y;
  f_Speed.Y := 0;
 end;
 if (f_Speed.X = 0) and (f_Speed.Y = 0) then
  Stop;
end;

constructor Td2dPositionBlender.Load(aFiler: Td2dFiler);
begin
 inherited Load(aFiler);
 with aFiler do
 begin
  f_Speed   := ReadPoint;
  f_Current := ReadPoint;
  f_Target  := ReadPoint;
 end;
end;

procedure Td2dPositionBlender.Save(aFiler: Td2dFiler);
begin
 inherited Save(aFiler);
 with aFiler do
 begin
  WritePoint(f_Speed);
  WritePoint(f_Current);
  WritePoint(f_Target);
 end;
end;

constructor Td2dSimpleBlender.Create(const aTime: Single; const aStartValue, aTargetValue: Single);
begin
 inherited Create;
 f_Current := aStartValue;
 f_Target := aTargetValue;
 f_Speed := (aTargetValue - aStartValue)/aTime;
end;

procedure Td2dSimpleBlender.DoUpdate(aDelta: Single);
begin
 f_Current := f_Current + aDelta * f_Speed;
 if ((f_Speed > 0) and (f_Current >= f_Target)) or ((f_Speed < 0) and (f_Current <= f_Target)) then
 begin
  f_Current := f_Target;
  Stop;
 end;
end;

constructor Td2dSimpleBlender.Load(aFiler: Td2dFiler);
begin
 inherited Load(aFiler);
 with aFiler do
 begin
  f_Speed   := ReadSingle;
  f_Current := ReadSingle;
  f_Target  := ReadSingle;
 end;
end;

procedure Td2dSimpleBlender.Save(aFiler: Td2dFiler);
begin
 inherited Save(aFiler);
 with aFiler do
 begin
  WriteSingle(f_Speed);
  WriteSingle(f_Current);
  WriteSingle(f_Target);
 end;
end;

constructor Td2dFiler.Create(aStream: TStream);
begin
 inherited Create;
 f_Stream := aStream;
end;

function Td2dFiler.ReadBoolean: Boolean;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Boolean));
end;

function Td2dFiler.ReadByte: Byte;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Byte));
end;

function Td2dFiler.ReadColor: Td2dColor;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Td2dColor));
end;

function Td2dFiler.ReadInteger: Integer;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Integer));
end;

function Td2dFiler.ReadDouble: Double;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Double));
end;

function Td2dFiler.ReadPoint: Td2dPoint;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Td2dPoint));
end;

function Td2dFiler.ReadSingle: Single;
begin
 f_Stream.ReadBuffer(Result, SizeOf(Single));
end;

function Td2dFiler.ReadString: string;
var
 l_Len: Cardinal;
begin
 Result := '';
 f_Stream.ReadBuffer(l_Len, SizeOf(Cardinal));
 if l_Len > 0 then
 begin
  SetLength(Result, l_Len);
  f_Stream.ReadBuffer(Result[1], l_Len);
 end;
end;

procedure Td2dFiler.WriteBoolean(aValue: Boolean);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Boolean));
end;

procedure Td2dFiler.WriteByte(aValue: Byte);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Byte));
end;

procedure Td2dFiler.WriteColor(aValue: Td2dColor);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Td2dColor));
end;

procedure Td2dFiler.WriteInteger(aValue: Integer);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Integer));
end;

procedure Td2dFiler.WriteDouble(aValue: Double);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Double));
end;

procedure Td2dFiler.WritePoint(aValue: Td2dPoint);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Td2dPoint));
end;

procedure Td2dFiler.WriteSingle(aValue: Single);
begin
 f_Stream.WriteBuffer(aValue, SizeOf(Single));
end;

procedure Td2dFiler.WriteString(aString: string);
var
 l_Len: Cardinal;
begin
 l_Len := Length(aString);
 f_Stream.WriteBuffer(l_Len, SizeOf(l_Len));
 if l_Len > 0 then
  f_Stream.Write(aString[1], l_Len);
end;

function Td2dMemoryStream.ExtractMemory(theSize: PLongWord): Pointer;
begin
 Result := GetMemory(Size);
 Move(Memory^, Result^, Size);
 if theSize <> nil then
  theSize^ := Size;
end;

function D2DMoveRect(const aRect: Td2dRect; aDX, aDY: Single): Td2dRect;
begin
 Result.Left := aRect.Left + aDX;
 Result.Top  := aRect.Top  + aDY;
 Result.Right := aRect.Right + aDX;
 Result.Bottom := aRect.Bottom + aDY;
end;

function D2AttachZipPack(const aFilename: AnsiString): Boolean;
var
 l_ZP: Id2dResourcePack;
begin
 Result := False;
 if not FileExists(aFileName) then
 begin
  gD2DE.System_Log('Can''t find resource pack: %s',[aFileName]);
  Exit;
 end;
 l_ZP := Td2dZipPack.Make(aFileName{, aOffset});
 if l_ZP.Count = 0 then
 begin
  gD2DE.System_Log('Corrupted resource pack: %s',[aFileName]);
  Exit;
 end;
 gD2DE.Resource_AttachPack(aFilename, l_ZP);
 Result := True;
end;



end.
