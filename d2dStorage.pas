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
unit d2dStorage;

interface
uses
 Classes,
 IniFiles,
 Registry;

type
 Td2dSetupLocation = (slInifile, slRegistry);

 Id2dStorage = interface(IInterface)
 ['{839C0B95-962B-4379-8FE7-92BDB53BD125}']
  function  GetInteger(Key: PChar; aDefault: Integer): Integer;
  procedure SetInteger(Key: PChar; aValue: Integer);
  function  GetFloat(Key: PChar; aDefault: Double): Double;
  procedure SetFloat(Key: PChar; aValue: Double);
  function  GetString(Key: PChar; aDefault: string): string;
  procedure SetString(Key: PChar; aValue: string);
  function  GetBoolean(Key: PChar; aDefault: Boolean): Boolean;
  procedure SetBoolean(Key: PChar; aValue: Boolean);
  function  GetDateTime(Key: PChar; aDefault: TDateTime): TDateTime;
  procedure SetDateTime(Key: PChar; aValue: TDateTime);
  function  GetStorage(Key: PChar): Id2dStorage;
 end;

 Td2dSetupStorage = class(TInterfacedObject, Id2dStorage)
 private
  f_CurSection: string;
  f_Ini: TCustomIniFile;
  // Id2dStorage methods
  function GetBoolean(Key: PChar; aDefault: Boolean): Boolean;
  function GetDateTime(Key: PChar; aDefault: TDateTime): TDateTime;
  function GetFloat(Key: PChar; aDefault: Double): Double;
  function GetInteger(Key: PChar; aDefault: Integer): Integer;
  function GetString(Key: PChar; aDefault: string): string;
  procedure SetBoolean(Key: PChar; aValue: Boolean);
  procedure SetCurSection(const Value: string);
  procedure SetDateTime(Key: PChar; aValue: TDateTime);
  procedure SetFloat(Key: PChar; aValue: Double);
  procedure SetInteger(Key: PChar; aValue: Integer);
  procedure SetString(Key: PChar; aValue: string);
  function GetStorage(Key: PChar): Id2dStorage;
 public
  constructor Create(const aLocation: Td2dSetupLocation; aIniFileName,
      aIniSection: string);
  destructor Destroy; override;
  class function Make(const aLocation: Td2dSetupLocation; aIniFileName,
      aIniSection: string): Id2dStorage; overload;
  class function Make(const aStorage: Td2dSetupStorage; aIniSection: string): Id2dStorage; overload;
  property CurSection: string read f_CurSection write SetCurSection;
 end;

implementation
uses
 StrUtils, Variants;

function CRLF2Codes(const aString: string): string;
begin
 Result := AnsiReplaceStr(AnsiReplaceStr(aString, #10, '#10'), #13, '#13');
end;

function Codes2CRLF(const aString: string): string;
begin
 Result := AnsiReplaceStr(AnsiReplaceStr(aString, '#10', #10), '#13', #13);
end;

constructor Td2dSetupStorage.Create(const aLocation: Td2dSetupLocation;
    aIniFileName, aIniSection: string);
begin
 inherited Create;
 case aLocation of
  slInifile  : f_Ini := TIniFile.Create(aIniFileName);
  slRegistry : f_Ini := TRegistryIniFile.Create(aIniFileName);
 end; 
 f_CurSection := aIniSection;
end;

destructor Td2dSetupStorage.Destroy;
begin
 f_Ini.Free;
 inherited;
end;

class function Td2dSetupStorage.Make(const aLocation: Td2dSetupLocation;
    aIniFileName, aIniSection: string): Id2dStorage;
begin
 Result := Td2dSetupStorage.Create(aLocation, aIniFileName, aIniSection);
end;

function Td2dSetupStorage.GetBoolean(Key: PChar; aDefault: Boolean): Boolean;
begin
 Result := f_Ini.ReadBool(f_CurSection, Key, aDefault);
end;

function Td2dSetupStorage.GetDateTime(Key: PChar; aDefault: TDateTime): TDateTime;
begin
 Result := f_Ini.ReadDateTime(f_CurSection, Key, aDefault);
end;

function Td2dSetupStorage.GetFloat(Key: PChar; aDefault: Double): Double;
begin
 Result := f_Ini.ReadFloat(f_CurSection, Key, aDefault);
end;

function Td2dSetupStorage.GetInteger(Key: PChar; aDefault: Integer): Integer;
begin
 Result := f_Ini.ReadInteger(f_CurSection, Key, aDefault);
end;

function Td2dSetupStorage.GetStorage(Key: PChar): Id2dStorage;
begin
 Result := Td2dSetupStorage.Make(Self, f_CurSection + '.' + Key);
end;

function Td2dSetupStorage.GetString(Key: PChar; aDefault: string): string;
begin
 Result := Codes2CRLF(f_Ini.ReadString(f_CurSection, Key, aDefault));
end;

class function Td2dSetupStorage.Make(const aStorage: Td2dSetupStorage; aIniSection: string): Id2dStorage;
var
 l_Loc: Td2dSetupLocation;
begin
 if aStorage.f_Ini is TRegistryIniFile then
  l_Loc := slRegistry
 else
  l_Loc := slInifile;
 Result := Create(l_Loc, aStorage.f_Ini.FileName, aIniSection);
end;

procedure Td2dSetupStorage.SetBoolean(Key: PChar; aValue: Boolean);
begin
 f_Ini.WriteBool(f_CurSection, Key, aValue);
end;

procedure Td2dSetupStorage.SetCurSection(const Value: string);
begin
 if f_CurSection <> Value then
 begin
  f_CurSection := Value;
 end;
end;

procedure Td2dSetupStorage.SetDateTime(Key: PChar; aValue: TDateTime);
begin
 f_Ini.WriteDateTime(f_CurSection, Key, aValue);
end;

procedure Td2dSetupStorage.SetFloat(Key: PChar; aValue: Double);
begin
 f_Ini.WriteFloat(f_CurSection, Key, aValue);
end;

procedure Td2dSetupStorage.SetInteger(Key: PChar; aValue: Integer);
begin
 f_Ini.WriteInteger(f_CurSection, Key, aValue);
end;

procedure Td2dSetupStorage.SetString(Key: PChar; aValue: string);
begin
 f_Ini.WriteString(f_CurSection, Key, CRLF2Codes(aValue));
end;


end.
