unit d2dPath;

interface
uses
 Classes
 ;

type

 Td2dCommonPath = class
 private
  f_SegmentsBuilt: Boolean;
  f_TotalLength: Single;
  procedure CalcTotalLength;
 protected
  f_Points: TList;
  f_Segments: Tlist;
  procedure AddSegment(aX1, aY1, aX2, aY2: Single);
  procedure ClearPoints;
  procedure ClearSegments;
  procedure DoRecalcSegments; virtual;
  procedure CheckSegments;
 public
  constructor Create;
  destructor Destroy; override;
  function AddPoint(const aX, aY: Single): Integer;
  procedure Clear;
  procedure Recalc;
  property TotalLength: Single read f_TotalLength;
 end;

 Td2dPathCursor = class
 private
  f_Path: Td2dCommonPath;
  f_Speed: Single;
 public
  constructor Create(aPath: Td2dCommonPath; aSpeed: Single);
 end;

implementation
uses
 SysUtils,
 Math,

 d2dTypes;

type
 //1 path segment descriptor
 Pd2dPathSegment = ^Td2dPathSegment;
 Td2dPathSegment = record
  X      : Single;
  Y      : Single;
  DX     : Single;
  DY     : Single;
  Len    : Single;
  Angle  : Single;
 end;

constructor Td2dCommonPath.Create;
begin
 inherited;
 f_Points := TList.Create;
 f_Segments := TList.Create;
 f_SegmentsBuilt := False;
 f_TotalLength := 0;
end;

destructor Td2dCommonPath.Destroy;
begin
 Clear;
 FreeAndNil(f_Points);
 FreeAndNil(f_Segments);
 inherited;
end;

function Td2dCommonPath.AddPoint(const aX, aY: Single): Integer;
var
 l_New: Pointer;
begin
 GetMem(l_New, SizeOf(Td2dPoint));
 Result := f_Points.Add(l_New);
 f_SegmentsBuilt := False;
end;

procedure Td2dCommonPath.AddSegment(aX1, aY1, aX2, aY2: Single);
var
 l_Seg: Pd2dPathSegment;
begin
 GetMem(l_Seg, SizeOf(Td2dPathSegment));
 with l_Seg^ do
 begin
  X := aX1;
  Y := aY2;
  DX := aX2-aX1;
  DY := aY2-aY1;
  Len := Sqrt(DX*DX+DY*DY);
  Angle := ArcCos(DY/Len);
  if DX < 0 then
   Angle := 2*Pi-Angle;
 end;
 f_Segments.Add(l_Seg);
end;

procedure Td2dCommonPath.CalcTotalLength;
var
 I: Integer;
begin
 f_TotalLength := 0;
 for I := 0 to Pred(f_Segments.Count) do
  f_TotalLength := f_TotalLength + Pd2dPathSegment(f_Segments[I]).Len;
end;

procedure Td2dCommonPath.ClearPoints;
var
 I : Integer;
begin
 for I := 0 to Pred(f_Points.Count) do
  FreeMem(f_Points.Items[I], SizeOf(Td2dPoint));
 f_Points.Clear;
 f_SegmentsBuilt := False;
end;

procedure Td2dCommonPath.ClearSegments;
var
 I : Integer;
begin
 for I := 0 to Pred(f_Segments.Count) do
  FreeMem(f_Segments.Items[I], SizeOf(Td2dPathSegment));
 f_Segments.Clear;
 f_SegmentsBuilt := False;
end;

procedure Td2dCommonPath.DoRecalcSegments;
var
 I: Integer;
 P1, P2: Pd2dPoint;
begin
 for I := 1 to Pred(f_Points.Count) do
 begin
  P1 := f_Points.Items[I-1];
  P2 := f_Points.Items[I];
  AddSegment(P1.X, P1.Y, P2.X, P2.Y);
 end;
end;

procedure Td2dCommonPath.CheckSegments;
begin
 if f_SegmentsBuilt then
  Exit;
 if f_Points.Count < 2 then
  Exit;
 ClearSegments;
 DoRecalcSegments;
 CalcTotalLength;
 f_SegmentsBuilt := True;
end;

procedure Td2dCommonPath.Clear;
begin
 ClearPoints;
 ClearSegments;
end;

procedure Td2dCommonPath.Recalc;
begin
 f_SegmentsBuilt := False;
 CheckSegments;
end;

constructor Td2dPathCursor.Create(aPath: Td2dCommonPath; aSpeed: Single);
begin
 inherited Create;
 f_Path := aPath;
 f_Speed := aSpeed;
end;

end.
