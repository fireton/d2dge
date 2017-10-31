unit d2dDocRoot;

interface

uses
  Contnrs,

  d2dTypes,
  d2dFormattedText;

type
 Td2dLinkSliceCacheItem = class
 private
  f_Rect: Td2dRect;
  f_Slice: Td2dLinkSlice;
 public
  constructor Create(aRect: Td2dRect; const aSlice: Td2dLinkSlice);
  property Rect: Td2dRect read f_Rect write f_Rect;
  property Slice: Td2dLinkSlice read f_Slice write f_Slice;
 end;


type
 Td2dDocRoot = class(Td2dUnionSlice)
 private
  f_CurLinkAction: Td2dLinkActionProc;
  f_HighlightedLink: Td2dLinkSliceCacheItem;
  f_LinkCacheIsValid: Boolean;
  f_LinksAllowed: Boolean;
  f_LinksCache: TObjectList;
  procedure BuildLinkSliceCache;
  procedure pm_SetLinksAllowed(const Value: Boolean);
  procedure _AllowLinks(const aLinkSlice: Td2dLinkSlice);
  procedure _DisallowLinks(const aLinkSlice: Td2dLinkSlice);
  procedure _DropHighlight(const aLinkSlice: Td2dLinkSlice);
  procedure _LinkIteratorProc(const aSlice: Td2dCustomSlice);
 protected
  function GetTopChild: Integer; virtual;
  function GetBottomChild: Integer; virtual;
  function GetVerticalShift: Single; virtual;
 public
  constructor Create(aWidth: Single);
  destructor Destroy; override;
  procedure Clear; override;
  procedure DropLinkCache;
  procedure DropLinkHighlight;
  procedure FindLinkHighlight(const aX, aY: Single; var theEvent: Td2dInputEvent);
  procedure ForceLinkAllowance;
  procedure IterateLinks(anAction: Td2dLinkActionProc; aFrom: Integer = 0);
  property HighlightedLink: Td2dLinkSliceCacheItem read f_HighlightedLink write f_HighlightedLink;
  property LinksAllowed: Boolean read f_LinksAllowed write pm_SetLinksAllowed;
 end;

implementation
uses
 d2dCore,
 d2dUtils;

constructor Td2dDocRoot.Create(aWidth: Single);
begin
 inherited Create(aWidth);
 f_LinksAllowed := True;
 f_LinksCache := TObjectList.Create(True);
 f_LinkCacheIsValid := False;
end;

destructor Td2dDocRoot.Destroy;
begin
 inherited;
 f_LinksCache.Free;
end;

procedure Td2dDocRoot.BuildLinkSliceCache;
var
 I  : Integer;
 l_BottomVisible: Integer;
 l_Child: Td2dCustomSlice;
 l_Shift: Single;
 l_TopVisible: Integer;

 procedure ScanForLinkSlices(const aSlice: Td2dCustomSlice);
 var
  J: Integer;
  l_CI: Td2dLinkSliceCacheItem;
  l_R: Td2dRect;
  l_UC: Td2dUnionSlice;
 begin
  if aSlice.SliceType = stUnion then
  begin
   l_UC := Td2dUnionSlice(aSlice);
   for J := 0 to l_UC.ChildrenCount-1 do
    ScanForLinkSlices(l_UC.Children[J]);
  end
  else
   if aSlice.SliceType = stLink then
   begin
    l_R.Left := aSlice.AbsLeft;
    l_R.Top  := aSlice.AbsTop - l_Shift;
    l_R.Right := l_R.Left + aSlice.Width;
    l_R.Bottom := l_R.Top + aSlice.Height;
    l_CI := Td2dLinkSliceCacheItem.Create(l_R, aSlice as Td2dLinkSlice{(aSlice)});
    f_LinksCache.Add(l_CI);
   end;
 end;

begin
 f_LinksCache.Clear;
 l_TopVisible := GetTopChild;
 if l_TopVisible >= 0 then
 begin
  l_BottomVisible := GetBottomChild;
  l_Shift := Int(GetVerticalShift + 0.5); // round shift
  for I := l_TopVisible to l_BottomVisible do
  begin
   l_Child := Children[I];
   ScanForLinkSlices(l_Child);
  end;
 end;
 f_LinkCacheIsValid := True;
 f_HighlightedLink := nil;
end;

procedure Td2dDocRoot.Clear;
begin
 DropLinkCache;
 inherited Clear;
end;

procedure Td2dDocRoot.DropLinkCache;
begin
 f_LinkCacheIsValid := False;
 f_HighlightedLink := nil;
 IterateLinks(_DropHighlight);
end;

procedure Td2dDocRoot.DropLinkHighlight;
begin
 if f_HighlightedLink <> nil then
 begin
  f_HighlightedLink.Slice.IsHighlighted := False;
  f_HighlightedLink.Slice.SpreadHighlight;
  f_HighlightedLink := nil;
 end;
end;

procedure Td2dDocRoot.FindLinkHighlight(const aX, aY: Single; var theEvent: Td2dInputEvent);
var
 I: Integer;
 l_CI: Td2dLinkSliceCacheItem;
begin
 if not f_LinkCacheIsValid then
  BuildLinkSliceCache;
 if f_HighlightedLink <> nil then
 begin
  if not D2DIsPointInRect(gD2DE.MouseX - aX, gD2DE.MouseY - aY, f_HighlightedLink.Rect) or IsMouseMoveMasked(theEvent) then
   DropLinkHighlight
  else
  begin
   MaskMouseMove(theEvent);
   Exit; // it's still highlighted
  end;
 end;

 if not IsMouseMoveMasked(theEvent) then
 begin
  for I := 0 to f_LinksCache.Count - 1 do
  begin
   l_CI := Td2dLinkSliceCacheItem(f_LinksCache.Items[I]);
   if D2DIsPointInRect(gD2DE.MouseX - aX, gD2DE.MouseY - aY, l_CI.Rect) and (l_CI.Slice.IsActive) then
   begin
    l_CI.Slice.IsHighlighted := True;
    l_CI.Slice.SpreadHighlight;
    f_HighlightedLink := l_CI;
    MaskMouseMove(theEvent);
    Break;
   end;
  end;
 end; // if not IsMouseMoveMasked(theEvent) then
end;

procedure Td2dDocRoot.ForceLinkAllowance;
begin
 if f_LinksAllowed then
  IterateLinks(_AllowLinks)
 else
  IterateLinks(_DisallowLinks);
end;

function Td2dDocRoot.GetTopChild: Integer;
begin
 if ChildrenCount = 0 then
  Result := -1
 else
  Result := 0; 
end;

function Td2dDocRoot.GetBottomChild: Integer;
begin
 Result := ChildrenCount - 1;
end;

function Td2dDocRoot.GetVerticalShift: Single;
begin
 Result := 0.0;
end;

procedure Td2dDocRoot.IterateLinks(anAction: Td2dLinkActionProc; aFrom: Integer = 0);
begin
 f_CurLinkAction := anAction;
 IterateLeafSlices(_LinkIteratorProc, aFrom);
end;

procedure Td2dDocRoot.pm_SetLinksAllowed(const Value: Boolean);
begin
 if f_LinksAllowed <> Value then
 begin
  f_LinksAllowed := Value;
  ForceLinkAllowance;
 end;
end;

procedure Td2dDocRoot._AllowLinks(const aLinkSlice: Td2dLinkSlice);
begin
 aLinkSlice.Allowed := True;
end;

procedure Td2dDocRoot._DisallowLinks(const aLinkSlice: Td2dLinkSlice);
begin
 aLinkSlice.Allowed := False;
end;

procedure Td2dDocRoot._DropHighlight(const aLinkSlice: Td2dLinkSlice);
begin
 aLinkSlice.IsHighlighted := False;
end;

procedure Td2dDocRoot._LinkIteratorProc(const aSlice: Td2dCustomSlice);
begin
 if aSlice.SliceType = stLink then
  f_CurLinkAction(Td2dLinkSlice(aSlice));
end;

constructor Td2dLinkSliceCacheItem.Create(aRect: Td2dRect; const aSlice: Td2dLinkSlice);
begin
 inherited Create;
 f_Rect := aRect;
 f_Slice := aSlice;
end;

end.