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
unit d2dInterfaces;

interface
uses
 Types,
 Direct3D8,
 d2dTypes;

type
 Id2dTexture = interface
  ['{40AAA101-1A6D-4403-BF99-75DA1F195CA3}']
  function pm_GetDirectXTexture: IDirect3DTexture8;
  function pm_GetSrcPicHeight: Integer;
  function pm_GetSrcPicWidth: Integer;
  procedure pm_SetSrcPicHeight(const Value: Integer);
  procedure pm_SetSrcPicWidth(const Value: Integer);
  function IsOrphan: Boolean;
  property DirectXTexture: IDirect3DTexture8 read pm_GetDirectXTexture;
  property SrcPicHeight: Integer read pm_GetSrcPicHeight write pm_SetSrcPicHeight;
  property SrcPicWidth: Integer read pm_GetSrcPicWidth write pm_SetSrcPicWidth;
 end;
 
 Id2dFont = interface
  ['{07A0B812-9EE0-4196-9D4A-E67A889C65D9}']
  function pm_GetBlendMode: Integer;
  function pm_GetColor: Longword;
  procedure pm_SetBlendMode(const aValue: Integer);
  procedure pm_SetColor(const aValue: Longword);
  procedure DoSetBlendMode(aBlendMode: Integer);
  procedure DoSetColor(aColor: Td2dColor);
  function pm_GetHeight: Single;
  procedure CalcSize(const aStr: string; var theSize: Td2dPoint; aLength: Integer = MaxInt);
  function CalcStringBySize(const aStr: string; aWidth: Single; const aEllipsis: string = '...'): string;
  function CanRenderChar(aChar: Char): Boolean;
  function pm_GetID: string;
  function pm_GetSize: Single;
  procedure pm_SetID(const Value: string);
  procedure Render(aX, aY: Single; aStr: string);
  property BlendMode: Integer read pm_GetBlendMode write pm_SetBlendMode;
  property Color: Longword read pm_GetColor write pm_SetColor;
  property Height: Single read pm_GetHeight;
  property ID: string read pm_GetID write pm_SetID;
  property Size: Single read pm_GetSize;
 end;

 Id2dFontProvider = interface
  ['{4218D8D0-6544-435C-9B07-C25CEBD0AB16}']
  function GetByID(const anID: string): Id2dFont;
 end;

 Id2dPicture = interface
  ['{C5039CBF-F03C-4B4B-80C8-51B2A43E67EF}']
  function pm_GetHeight: Single;
  function pm_GetID: string;
  function pm_GetWidth: Single;
  procedure Render(const aX, aY: Single);
  property Height: Single read pm_GetHeight;
  property ID: string read pm_GetID;
  property Width: Single read pm_GetWidth;
 end;

 Id2dPictureProvider = interface
  ['{AC6FDDC7-7388-4CA9-A882-DB4B758FFAE2}']
  function GetByID(const anID: string): Id2dPicture;
 end;

 Id2dResourcePack = interface
  ['{319E44BB-6B66-4B84-9C4F-10339C8A383C}']
  function IndexOf(const aFileName: string): Integer;
  function Find(aWildCard: string; aFrom: Integer = 0): Integer;
  function Extract(I: integer; var aBuffer: Pointer; aSize: DWORD = 0): Boolean;
  function pm_GetCount: Integer;
  function pm_GetName(aIndex: Integer): AnsiString;
  function pm_GetSize(aIndex: Integer): LongWord;
  property Count: Integer read pm_GetCount;
  property Name[aIndex: Integer]: AnsiString read pm_GetName;
  property Size[aIndex: Integer]: LongWord read pm_GetSize;
 end;


implementation
end.