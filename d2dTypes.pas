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
unit d2dTypes;

interface
uses
 Direct3D8,
 Dynamic_Bass;//,
 //d2dClasses;

const
 D2DVersion = $0102;

 D2D_FPS_UNLIMITED =  0;
 D2D_FPS_VSYNC     = -1;

const
 VertexBufferSize = 4000;
 D3DFVF_D2DVERTEX = D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1;

 // Primitive types
 D2DPRIM_LINES		 = 2;
 D2DPRIM_TRIPLES	=	3;
 D2DPRIM_QUADS		 = 4;

 // Blending constants
	BLEND_COLORADD		  = 1;
	BLEND_COLORMUL		  = 0;
	BLEND_ALPHABLEND	 = 2;
	BLEND_ALPHAADD		  = 0;
	BLEND_ZWRITE		    = 4;
	BLEND_NOZWRITE		  = 0;

 BLEND_DEFAULT		  : Integer = BLEND_COLORMUL or BLEND_ALPHABLEND or BLEND_NOZWRITE;
 BLEND_DEFAULT_Z		: Integer = BLEND_COLORMUL or BLEND_ALPHABLEND or BLEND_ZWRITE;

const // input types
 INPUT_NONE        = 0;
 INPUT_KEYDOWN	    = 1;
 INPUT_KEYUP			    = 2;
 INPUT_MBUTTONDOWN	= 3;
 INPUT_MBUTTONUP		 = 4;
 INPUT_MOUSEMOVE		 = 5;
 INPUT_MOUSEWHEEL	 = 6;

const //Input Event flags
 D2DINP_SHIFT		    = 1;
 D2DINP_CTRL			    = 2;
 D2DINP_ALT			     = 4;
 D2DINP_CAPSLOCK		 = 8;
 D2DINP_SCROLLLOCK =	16;
 D2DINP_NUMLOCK		  = 32;
 D2DINP_REPEAT		   = 64;
 D2DINP_MASK       = 128; // used for masking of mouse events


const //D2D Virtual-key codes

 D2DK_LBUTTON	= $01;
 D2DK_RBUTTON	= $02;
 D2DK_MBUTTON	= $04;

 D2DK_ESCAPE		  = $1B;
 D2DK_BACKSPACE	= $08;
 D2DK_TAB		     = $09;
 D2DK_ENTER		   = $0D;
 D2DK_SPACE		   = $20;

 D2DK_SHIFT		= $10;
 D2DK_CTRL		 = $11;
 D2DK_ALT		  = $12;

 D2DK_LWIN		= $5B;
 D2DK_RWIN		= $5C;
 D2DK_APPS		= $5D;

 D2DK_PAUSE		    = $13;
 D2DK_CAPSLOCK	  = $14;
 D2DK_NUMLOCK	   = $90;
 D2DK_SCROLLLOCK	= $91;

 D2DK_PGUP		  = $21;
 D2DK_PGDN		  = $22;
 D2DK_HOME		  = $24;
 D2DK_END		   = $23;
 D2DK_INSERT		= $2D;
 D2DK_DELETE		= $2E;

 D2DK_LEFT		 = $25;
 D2DK_UP			  = $26;
 D2DK_RIGHT		= $27;
 D2DK_DOWN		 = $28;

 D2DK_0			= $30;
 D2DK_1			= $31;
 D2DK_2			= $32;
 D2DK_3			= $33;
 D2DK_4			= $34;
 D2DK_5			= $35;
 D2DK_6			= $36;
 D2DK_7			= $37;
 D2DK_8			= $38;
 D2DK_9			= $39;

 D2DK_A			= $41;
 D2DK_B			= $42;
 D2DK_C			= $43;
 D2DK_D			= $44;
 D2DK_E			= $45;
 D2DK_F			= $46;
 D2DK_G			= $47;
 D2DK_H			= $48;
 D2DK_I			= $49;
 D2DK_J			= $4A;
 D2DK_K			= $4B;
 D2DK_L			= $4C;
 D2DK_M			= $4D;
 D2DK_N			= $4E;
 D2DK_O			= $4F;
 D2DK_P			= $50;
 D2DK_Q			= $51;
 D2DK_R			= $52;
 D2DK_S			= $53;
 D2DK_T			= $54;
 D2DK_U			= $55;
 D2DK_V			= $56;
 D2DK_W			= $57;
 D2DK_X			= $58;
 D2DK_Y			= $59;
 D2DK_Z			= $5A;

 D2DK_GRAVE		    = $C0;
 D2DK_MINUS		    = $BD;
 D2DK_EQUALS		   = $BB;
 D2DK_BACKSLASH	 = $DC;
 D2DK_LBRACKET	  = $DB;
 D2DK_RBRACKET	  = $DD;
 D2DK_SEMICOLON	 = $BA;
 D2DK_APOSTROPHE	= $DE;
 D2DK_COMMA		    = $BC;
 D2DK_PERIOD		   = $BE;
 D2DK_SLASH		    = $BF;

 D2DK_NUMPAD0	= $60;
 D2DK_NUMPAD1	= $61;
 D2DK_NUMPAD2	= $62;
 D2DK_NUMPAD3	= $63;
 D2DK_NUMPAD4	= $64;
 D2DK_NUMPAD5	= $65;
 D2DK_NUMPAD6	= $66;
 D2DK_NUMPAD7	= $67;
 D2DK_NUMPAD8	= $68;
 D2DK_NUMPAD9	= $69;

 D2DK_MULTIPLY	= $6A;
 D2DK_DIVIDE		 = $6F;
 D2DK_ADD		    = $6B;
 D2DK_SUBTRACT	= $6D;
 D2DK_DECIMAL	 = $6E;

 D2DK_F1			= $70;
 D2DK_F2			= $71;
 D2DK_F3			= $72;
 D2DK_F4			= $73;
 D2DK_F5			= $74;
 D2DK_F6			= $75;
 D2DK_F7			= $76;
 D2DK_F8			= $77;
 D2DK_F9			= $78;
 D2DK_F10		= $79;
 D2DK_F11		= $7A;
 D2DK_F12		= $7B;

 // Music playback constants
 mp_None   = 0;
 mp_MIDI   = 1;
 mp_Stream = 2;
 mp_Module = 3;

type
 Td2dColor = Longword;

 // Vertex
 Pd2dVertex = ^Td2dVertex;
 Td2dVertex = packed record
  X   : Single;   // Screen position
  Y   : Single;
  Z   : Single;   // Depth (0..1)
  Col : Longword; // color
  TX  : Single;   // texture coordinates
  TY  : Single;
 end;

 // Triple
 Pd2dTriple = ^Td2dTriple;
 Td2dTriple = packed record
  V     : array [0..2] of Td2dVertex;
  Tex   : IDirect3DTexture8;
  Blend : Integer;
 end;

 // Quad
 Pd2dQuad = ^Td2dQuad;
 Td2dQuad = packed record
  V     : array [0..3] of Td2dVertex;
  Tex   : IDirect3DTexture8;
  Blend : Integer;
 end;

 // Render target
 Pd2dRenderTarget = ^Td2dRenderTarget;
 Td2dRenderTarget = record
  Width  : Integer;
  Height : Integer;
  Tex    : IDirect3DTexture8;
  Depth  : IDirect3DSurface8;
 end;


 // input event
 Pd2dInputEvent = ^Td2dInputEvent;
 Td2dInputEvent = record
  EventType : Integer;
  KeyCode   : Integer;
  KeyScan   : Integer;
  Flags     : Integer;
  KeyChar: Integer;
  Wheel     : Integer;
  X         : Single;
  Y         : Single;
 end;

 Pd2dPoint = ^Td2dPoint;
 Td2dPoint = record
  X, Y : Single;
 end;

 Td2dRect = record
  Left, Right, Top, Bottom: Single;
 end;
 
 Pd2dVertexArray = ^Td2dVertexArray;
 Td2dVertexArray = array [0..VertexBufferSize-1] of Td2dVertex;

 Td2dSimpleEvent  = procedure () of object;
 Td2dNotifyEvent  = procedure (aSender: TObject) of object;
 Td2dTriggerEvent = procedure (aTrigger: Boolean) of object;
 Td2dFrameEvent   = procedure (aDelta: Single; var aFinish: Boolean) of object;
 Td2dExitEvent    = function (): Boolean of object;

 // Sound handlers (inherited from BASS)

 HMUSIC =   Dynamic_Bass.HMUSIC;       // MOD music handle
 HSAMPLE =  Dynamic_Bass.HSAMPLE;      // sample handle
 HCHANNEL = Dynamic_Bass.HCHANNEL;     // playing sample's channel handle
 HSTREAM =  Dynamic_Bass.HSTREAM;      // sample stream handle

type // Formatted text types
 Td2dTextChunkType = (ctUndefined, ctText, ctLink, ctPicture, ctEOL);
 Td2dTextSliceType = (stUnknown, stText, stLink, stPicture, stUnion);
 Td2dTextAlignType = (ptLeftAligned, ptRightAligned, ptCentered);

function ARGB(A,R,G,B: Longword): Td2dColor;
procedure Color2ARGB(const aColor: Td2dColor; var A,R,G,B: Byte);

function D2DPoint(const aX, aY: Single): Td2dPoint;
function D2DRect(aX1, aY1, aX2, aY2: Single): Td2dRect;

procedure Processed(var theEvent: Td2dInputEvent);
function IsKeyboardEvent(const aEvent: Td2dInputEvent): Boolean;
function IsMouseEvent(const aEvent: Td2dInputEvent): Boolean;
function IsProcessed(const aEvent: Td2dInputEvent): Boolean;
function IsMouseMoveMasked(const aEvent: Td2dInputEvent): Boolean;
procedure MaskMouseMove(var theEvent: Td2dInputEvent);



implementation
uses
 SysUtils,
 d2dCore;

function ARGB(A,R,G,B: Longword): Td2dColor;
begin
 Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

procedure Processed(var theEvent: Td2dInputEvent);
begin
 FillChar(theEvent, SizeOf(Td2dInputEvent), 0);
end;

function IsKeyboardEvent(const aEvent: Td2dInputEvent): Boolean;
begin
 Result := (aEvent.EventType = INPUT_KEYDOWN) or (aEvent.EventType = INPUT_KEYUP);
end;

function IsMouseEvent(const aEvent: Td2dInputEvent): Boolean;
begin
 Result := aEvent.EventType in [INPUT_MBUTTONDOWN, INPUT_MBUTTONUP, INPUT_MOUSEMOVE, INPUT_MOUSEWHEEL];
end;

function IsProcessed(const aEvent: Td2dInputEvent): Boolean;
begin
 Result := aEvent.EventType = INPUT_NONE;
end;

procedure Color2ARGB(const aColor: Td2dColor; var A,R,G,B: Byte);
begin
 A := (aColor shr 24) and $FF;
 R := (aColor shr 16) and $FF;
 G := (aColor shr 8) and $FF;
 B := aColor and $FF;
end;

function D2DPoint(const aX, aY: Single): Td2dPoint;
begin
 Result.X := aX;
 Result.Y := aY;
end;

function D2DRect(aX1, aY1, aX2, aY2: Single): Td2dRect;
begin
 Result.Left := aX1;
 Result.Right := aX2;
 Result.Top := aY1;
 Result.Bottom := aY2;
end;

function IsMouseMoveMasked(const aEvent: Td2dInputEvent): Boolean;
begin
 Result := (aEvent.EventType = INPUT_MOUSEMOVE) and (aEvent.Flags and D2DINP_MASK <> 0);
end;

procedure MaskMouseMove(var theEvent: Td2dInputEvent);
begin
 if theEvent.EventType = INPUT_MOUSEMOVE then
  theEvent.Flags := theEvent.Flags or D2DINP_MASK;
end;

end.
