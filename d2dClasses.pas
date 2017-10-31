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
unit d2dClasses;

interface

type
 Td2dProtoObjectPrim = class(TObject, IInterface)
 private
  f_RefCount: Integer;
 protected
  function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  function _AddRef: Integer; stdcall;
  function _Release: Integer; stdcall;
 protected
  procedure Cleanup; virtual;
  procedure FreeInstance; override;
 public
  destructor Destroy; override;
  class function NewInstance: TObject; override;
  function Use: Pointer;
  property RefCount: Integer read f_RefCount;
 end;

 Td2dProtoObject = class(Td2dProtoObjectPrim)
 protected
  destructor Destroy;
 end;

implementation
{.$DEFINE LogRefCount}
uses
 Windows
{$IFDEF LogRefCount}
 ,d2dCore
{$ENDIF}
 ;

destructor Td2dProtoObjectPrim.Destroy;
begin
 if InterlockedDecrement(f_RefCount) = 0 then
 begin
  Inc(f_RefCount);
  try
   try
    Cleanup;
   finally
    inherited Destroy;
   end;
  finally
   Dec(f_RefCount);
  end;
 end;
end;

procedure Td2dProtoObjectPrim.Cleanup;
begin
 // empty in base class
end;

procedure Td2dProtoObjectPrim.FreeInstance;
begin
 if f_RefCount = 0 then
 begin
  {$IFDEF LogRefCount}
  gD2DE.System_Log('%s destroyed.', [ClassName]);
  {$ENDIF}
  inherited FreeInstance;
 end
end;

class function Td2dProtoObjectPrim.NewInstance: TObject;
begin
 Result := inherited NewInstance;
 {$IFDEF LogRefCount}
 gD2DE.System_Log('%s created.', [ClassName]);
 {$ENDIF}
 Td2dProtoObjectPrim(Result).Use;
end;

function Td2dProtoObjectPrim.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 if GetInterface(IID, Obj) then
  Result := 0
 else
  Result := E_NOINTERFACE;
end;

function Td2dProtoObjectPrim.Use: Pointer;
begin
 if Self <> nil then
  InterlockedIncrement(f_RefCount);
 Result := Self;
end;

function Td2dProtoObjectPrim._AddRef: Integer;
begin
 Use;
 Result := f_RefCount;
end;

function Td2dProtoObjectPrim._Release: Integer;
var
 l_RC: Integer;
begin
 l_RC := f_RefCount - 1;
 Free;
 Result := l_RC;
end;

destructor Td2dProtoObject.Destroy;
begin
 Assert(False, 'This should never happen!');
 inherited;
end;

end.
