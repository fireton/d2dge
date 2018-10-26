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

unit d2dCore;

interface

uses
 Windows, Direct3D8, D3DX8, Classes, Contnrs,

 Dynamic_Bass,

 JclStringLists,

 d2dTypes,
 d2dInterfaces;

type
 Td2dCore = class
 private
  f_Active: Boolean;
  f_CurBlendMode: Integer;
  f_CurPrim: Integer;
  f_CurTarget: Pd2dRenderTarget;
  f_CurTexture: IDirect3DTexture8;
  f_Instance: Cardinal;
  f_Time0     : Cardinal; //
  f_Time0FPS  : Cardinal;
  f_FPSCount  : Cardinal; // FPS in current frame counter
  f_Time      : Double;   // Total time elapsed since start
  f_DeltaTime : Single;
  f_DeltaTicks: Cardinal;
  f_FixedDelta: Cardinal; // precalculated - if used fixed FPS rate
  f_LastTexGC : Cardinal; // last time then GC was performed

  f_AttachedPacks: IJclStringList;

  // private fields
  f_LogFileName: string;
  f_RectFS     : TRect;
  f_RectW      : TRect; // rect of window
  f_WHandle    : HWND;
  f_WStyleFS   : Longint;
  f_WStyleW    : Longint; // Window styles (for windowed and fullscreen)

  // Graphics
  f_D3DPP : D3DPRESENT_PARAMETERS;

  f_D3DPP_W    : D3DPRESENT_PARAMETERS;
  f_D3DPP_FS   : D3DPRESENT_PARAMETERS;

  f_D3D        : IDirect3D8;
  f_D3DDevice: IDirect3DDevice8;
  f_DontSuspend: Boolean;

  f_VB         : IDirect3DVertexBuffer8;
  f_IB         : IDirect3DIndexBuffer8;

  f_ScreenSurf : IDirect3DSurface8;
  f_ScreenDepth: IDirect3DSurface8;

  f_matView    : TD3DMatrix;
  f_matViewFS  : TD3DMatrix;
  f_matProj    : TD3DMatrix;

  f_Targets    : TList;
  f_Textures   : IJclStringList; // texture load cache
  f_SndSamples : TStringList;
  f_VertArray  : Pd2dVertexArray;

  // property fields
  f_ScreenWidth: LongWord;
  f_ScreenHeight: LongWord;
  f_Windowed: Boolean;
  f_WindowTitle: string;
  f_FixedFPS: Integer;
  f_FPS: LongWord;
  f_FSDX: Integer;
  f_FSDY: Integer;
  f_FSHeight: Integer;
  f_FSScale: Single;
  f_FSWidth: Integer;
  f_HideMouse: Boolean;
  f_InputEvents: TList;
  f_KeyChar: Integer;
  f_KeyCode: Integer;
  f_MidiDevice: Integer;
  f_MouseCaptured: Boolean;
  f_MouseOver: Boolean;
  f_MouseX: Single;
  f_MouseY: Single;
  f_MouseZ: Integer;
  f_Music: Byte;
  f_MusicData: Pointer;
  f_MusicFadeList: TObjectList;
  f_MusicHandle: DWORD;
  f_MusicLooped: Boolean;
  f_MusicMidiTempFile: string;
  f_MusicVolume: Byte;
  f_NextMusic: Td2dMusicRec;
  f_OnExit: Td2dExitEvent;
  f_OnFocusGain: Td2dSimpleEvent;
  f_OnFocusLost: Td2dSimpleEvent;
  f_OnFrame: Td2dFrameEvent;
  f_OnRender: Td2dSimpleEvent;
  f_PrimCount: LongWord;
  f_ScreenBPP: Byte;
  f_SoundMute: Boolean;
  f_SoundOn: Boolean;
  f_SoundSampleRate: Integer;
  f_TextureFilter: Boolean;
  f_UseZBuffer: Boolean;

  procedure AdjustWindow;
  procedure BassMusicStop(aChanel: Longword);
  procedure ClearQueue;
  procedure MakeEvent(aType: Integer; aKey: Integer; aScan: Integer; aFlags: Integer; aX, aY: Integer);
  procedure GfxDone;
  function GfxInit: Boolean;
  procedure ClearTargets;
  procedure FocusChange(const anActive: Boolean);
  procedure ForceAllMusicStop;
  procedure GfxRestore;
  {$IFDEF D2DGIF}
  function GIFasBMPLoad(aFileName: string; aSize: PLongword; aPackOnly: Boolean = False): Pointer;
  {$ENDIF}
  function InitLost: Boolean;
  function pm_GetMusicFadeList: TObjectList;
  procedure pm_SetFixedFPS(const Value: Integer);
  procedure pm_SetMusicVolume(const Value: Byte);
  procedure pm_SetScreenBPP(const Value: Byte);
  procedure pm_SetScreenHeight(const Value: LongWord);
  procedure pm_SetScreenWidth(const Value: LongWord);
  procedure pm_SetSoundMute(const Value: Boolean);
  procedure pm_SetTextureFilter(const Value: Boolean);
  procedure pm_SetUseZBuffer(const Value: Boolean);
  procedure pm_SetWindowed(const Value: Boolean);
  procedure pm_SetWindowTitle(const Value: string);
  procedure RenderBatch(aEndScene: Boolean = False);
  procedure SetBlendMode(aBlend: Longint);
  procedure SetProjectionMatrix(const aWidth, aHeight: Integer);
  procedure Snd_FreeSamplePrim(aIdx: Integer);
  procedure SoundSystemStart;
  procedure SoundSystemStop;
  procedure DoTextureCacheGarbageCollection;
  procedure GfxSetViewMatrix;
  procedure Input_SetMousePos(newX, newY: Integer);
  procedure pm_SetHideMouse(const Value: Boolean);
  property MusicFadeList: TObjectList read pm_GetMusicFadeList;
 protected
  procedure ReplayMIDI;
 public
  constructor Create(aWidth, aHeight: Integer; aWindowed: Boolean = True; aWindowTitle: string = '');
  destructor Destroy; override;
  procedure FlushPrimitives;
  function Gfx_BeginScene(aTarget: Pd2dRenderTarget = nil): Boolean;

  procedure Gfx_Clear(aColor: Longword);
  procedure Gfx_EndScene;
  procedure Gfx_RenderLine(const X1, Y1, X2, Y2: Single; const aColor: Longword; const Z: Single);
  procedure Gfx_RenderTriple(const aTriple: Td2dTriple);
  procedure Gfx_RenderQuad(const aQuad: Td2dQuad);
  procedure Gfx_SetClipping(aX: Integer = 0; aY: Integer = 0; aWidth: Integer = 0; aHeight: Integer = 0);
  procedure Gfx_SetTransform(const aX: Single = 0; const aY: Single = 0; const aDX: Single = 0; const aDY: Single = 0;
      const aRot: Single = 0; const aHScale: Single = 0; const aVScale: Single = 0);

  function Input_GetEvent(var anEvent: Td2dInputEvent): Boolean;
  function Input_GetKeyState(aKey: Integer): Boolean;
  procedure Input_TouchMousePos;

  function System_Start: Boolean;
  procedure System_Log(const aFormat: string; Args: array of TVarRec); overload;
  procedure System_Log(const aString: string); overload;
  procedure System_Run;
  procedure System_Shutdown;

  function Resource_AttachPack(const aName: string; const aPack: Id2dResourcePack): Boolean;
  procedure Resource_Free(aResource: Pointer);
  function Resource_Load(const aFileName: string; aSize: PLongword; aPackOnly: Boolean = False; aSilent: Boolean =
      False): Pointer;
  procedure Resource_RemoveAllPacks;
  procedure Resource_RemovePack(const aFileName: string);
  function Resource_CreateStream(aFilename: string; aPackOnly: Boolean = False): TStream;
  function Resource_Exists(aFileName: string; aPackOnly: Boolean = False): Boolean;
  function Resource_FindInPacks(aWildCard: string): string;

  function Target_Create(aWidth, aHeight: Integer; aZBuffer: Boolean = False): Pd2dRenderTarget;
  procedure Target_Free(aTarget: Pd2dRenderTarget);
  procedure Texture_ClearCache;

  function Texture_Create(const aWidth, aHeight: Integer): Id2dTexture;
  function Texture_GetWidth(aTex: IDirect3DTexture8): Integer; overload;
  function Texture_GetHeight(aTex: IDirect3DTexture8): Integer; overload;
  function Texture_GetWidth(aTex: Id2dTexture): Integer; overload;
  function Texture_GetHeight(aTex: Id2dTexture): Integer; overload;
  function Texture_FromMemory(const aData: Pointer; const aSize: LongWord; const aMipMap: Boolean = false): Id2dTexture;
  function Texture_Load(const aFileName: string; aPackOnly: Boolean = False;
      aUseCache: Boolean = True; const aMipMap: Boolean = False; aPicSize: PPoint = nil): Id2dTexture;
  procedure Texture_RemoveFromCache(aFileName: string); overload;
  procedure Texture_RemoveFromCache(const aTexture: Id2dTexture); overload;

  {
  function Snd_StreamLoad(aFilename: PChar): HSTREAM;
  function Snd_StreamPlay(aStream: HSTREAM; aLooped: Boolean = True; aVolume:
      Integer = -1): HCHANNEL;
  procedure Snd_ChannelStop(aChannel: HCHANNEL);
  procedure Snd_StreamFree(aStream: HSTREAM);
  }
  function Snd_PreLoadSample(aFileName: string; aPackOnly: Boolean = False): Integer;
  procedure Snd_PlaySample(aFilename: string; aVolume: Byte = 255; aLooped: Boolean = False; aPackOnly: Boolean = False);
  procedure Snd_FreeSample(aFilename: string);
  procedure Snd_FreeAll;

  procedure Music_StreamPlay(aFileName: string; aLooped: Boolean = True;
                             aFadeinTime: Longint =0; aPackOnly: Boolean = False);
  procedure Music_MIDIPlay(aFileName: string; aLooped: Boolean = True; aPackOnly: Boolean = False);
  procedure Music_MODPlay(aFileName: string; aLooped: Boolean = True; aFadeinTime: Longint = 0; aPackOnly: Boolean =
   False);
  procedure Music_Pause;
  procedure Music_Play(aFileName: string; aLooped: Boolean = True; aFadeinTime: Longint = 0; aPackOnly: Boolean = False);
  procedure Music_Resume;
  procedure Music_SetVolume(const aVolume: Byte; const aFadeTime: Longint = 0);
  procedure Music_Stop(aFadeoutTime: Longint = 0);
  function Music_IsPlaying: Boolean;
  procedure Snd_StopAll;
  procedure Snd_StopSample(aFilename: string);
  procedure System_SoundPause;
  procedure System_SoundResume;
  function Texture_CreatePrim(aData: Pointer; aSize: Longword; aMipMap: Boolean = False; aColorKey: Td2dColor = 0):
      Id2dTexture;

  property Active: Boolean read f_Active;
  property FixedFPS: Integer read f_FixedFPS write pm_SetFixedFPS;
  property OnFocusGain: Td2dSimpleEvent read f_OnFocusGain write f_OnFocusGain;
  property OnFocusLost: Td2dSimpleEvent read f_OnFocusLost write f_OnFocusLost;
  property DontSuspend: Boolean read f_DontSuspend write f_DontSuspend;
  property FPS: LongWord read f_FPS;
  property OnFrame: Td2dFrameEvent read f_OnFrame write f_OnFrame;
  property OnRender: Td2dSimpleEvent read f_OnRender write f_OnRender;
  //1 Hide mouse cursor
  property HideMouse: Boolean read f_HideMouse write pm_SetHideMouse;
  property KeyChar: Integer read f_KeyChar;
  property KeyCode: Integer read f_KeyCode;
  property MouseOver: Boolean read f_MouseOver;
  property MouseX: Single read f_MouseX;
  property MouseY: Single read f_MouseY;
  property MouseZ: Integer read f_MouseZ;
  property OnExit: Td2dExitEvent read f_OnExit write f_OnExit;
  property D3DDevice: IDirect3DDevice8 read f_D3DDevice;
  property LogFileName: string read f_LogFileName write f_LogFileName;
  property Music: Byte read f_Music;
  property MusicVolume: Byte read f_MusicVolume write pm_SetMusicVolume;
  property ScreenBPP: Byte read f_ScreenBPP write pm_SetScreenBPP;
  property ScreenHeight: LongWord read f_ScreenHeight write pm_SetScreenHeight;
  property ScreenWidth: LongWord read f_ScreenWidth write pm_SetScreenWidth;
  property SoundMute: Boolean read f_SoundMute write pm_SetSoundMute;
  property SoundOn: Boolean read f_SoundOn write f_SoundOn;
  property SoundSampleRate: Integer read f_SoundSampleRate write
      f_SoundSampleRate;
  property TextureFilter: Boolean read f_TextureFilter write pm_SetTextureFilter;
  property UseZBuffer: Boolean read f_UseZBuffer write pm_SetUseZBuffer;
  property WHandle: HWND read f_WHandle write f_WHandle;
  property Windowed: Boolean read f_Windowed write pm_SetWindowed;
  property WindowTitle: string read f_WindowTitle write pm_SetWindowTitle;
 end;

var
 gD2DE: Td2dCore = nil;

procedure D2DInit(aWidth, aHeight: Integer; aWindowed: Boolean = True; aWindowTitle: string = '');
procedure D2DDone;

implementation
uses
 Messages,
 MMSystem,
 SysUtils,
 {$IFDEF TRACE_STACK}
 JclDebug,
 {$ENDIF}
 Types,
 Math,

 d2dTexture

 {$IFDEF D2DGIF}
 ,Graphics
 ,GIFImage
 ,d2dUtils
 {$ENDIF}

 ;

const
 cWinClassName = 'D2DENGINE_WNDCLASS';
 c_TexGCThreshold = 10000; // 10 sec
 c_NoMouseCoord   = 5000000;

type
 Td2dMusicHolder = class
 public
  Chanel: Longword;
  Data  : Pointer;
  constructor Create(aChanel: Longword; aData: Pointer = nil);
  destructor Destroy; override;
 end;

function FormatID(aFormat: D3DFORMAT): Integer;
begin
 case aFormat of
		D3DFMT_R5G6B5:		Result := 1;
		D3DFMT_X1R5G5B5:	Result :=  2;
		D3DFMT_A1R5G5B5:	Result :=  3;
		D3DFMT_X8R8G8B8:	Result :=  4;
		D3DFMT_A8R8G8B8:	Result :=  5;
 else
		Result :=  0;
 end;
end;

function WindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
 l_X, l_Y: SmallInt;

 function IsRepeatFlag: Integer;
 begin
  if (lParam and $40000000) <> 0 then
   Result := D2DINP_REPEAT
  else
   Result := 0;
 end;
begin
 Result := 0;
 case Msg of
  WM_CREATE: Exit;

  WM_PAINT :
   if Assigned(gD2DE.f_OnRender) then
    gD2DE.f_OnRender();

  WM_DESTROY:
   begin
    PostQuitMessage(0);
    Exit;
   end;

  WM_ACTIVATEAPP:
   begin
			 if (Assigned(gD2DE.f_D3D) and gD2DE.Active) <> (wparam <> 0) then
     gD2DE.FocusChange(wparam <> 0);
    Exit;
   end;

  WM_SETCURSOR:
   begin
    if gD2DE.Active and (LongRec(lParam).Lo = HTCLIENT) and gD2DE.HideMouse then
     SetCursor(0)
    else
     SetCursor(LoadCursor(0, IDC_ARROW));
    {if gD2DE.Active and (LongRec(lParam).Lo = HTBOTTOMRIGHT) then
     SetCursor(LoadCursor(0, IDC_SIZENWSE));}
    Exit;
   end;

  WM_SYSKEYDOWN:
   if wParam = VK_F4 then
   begin
    if Assigned(gD2DE.f_OnExit) then
    begin
     if gD2DE.OnExit then
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);
    end
    else
     Result := DefWindowProc(hWnd, Msg, wParam, lParam);
    Exit;
   end
   else
   begin
    gD2DE.MakeEvent(INPUT_KEYDOWN, wParam, LongRec(lParam).Hi and $FF, IsRepeatFlag, c_NoMouseCoord, c_NoMouseCoord);
    Exit;
   end;

  WM_KEYDOWN:
   begin
    gD2DE.MakeEvent(INPUT_KEYDOWN, wParam, LongRec(lParam).Hi and $FF, IsRepeatFlag, c_NoMouseCoord, c_NoMouseCoord);
    {
    FillChar(l_MsgRec, SizeOf(TMsg), 0);
    l_MsgRec.hwnd := hWnd;
    l_MsgRec.message := WM_KEYDOWN;
    l_MsgRec.wParam := wParam;
    l_MsgRec.lParam := lParam;
    //TranslateMessage(l_MsgRec);
    }
    Exit;
   end;

  WM_SYSKEYUP:
   begin
    gD2DE.MakeEvent(INPUT_KEYUP, wParam, LongRec(lParam).Hi and $FF, 0, c_NoMouseCoord, c_NoMouseCoord);
    Exit;
   end;

  WM_KEYUP:
   begin
    gD2DE.MakeEvent(INPUT_KEYUP, wParam, LongRec(lParam).Hi and $FF, 0, c_NoMouseCoord, c_NoMouseCoord);
    Exit;
   end;

  WM_LBUTTONDOWN:
   begin
    SetFocus(gD2DE.f_WHandle);
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_LBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_MBUTTONDOWN:
   begin
    SetFocus(gD2DE.f_WHandle);
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_MBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_RBUTTONDOWN:
   begin
    SetFocus(gD2DE.f_WHandle);
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_RBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;

  WM_LBUTTONDBLCLK:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_LBUTTON, 0, D2DINP_REPEAT, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_MBUTTONDBLCLK:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_MBUTTON, 0, D2DINP_REPEAT, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_RBUTTONDBLCLK:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONDOWN, D2DK_RBUTTON, 0, D2DINP_REPEAT, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;

  WM_LBUTTONUP:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONUP, D2DK_LBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_MBUTTONUP:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONUP, D2DK_MBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;
  WM_RBUTTONUP:
   begin
    gD2DE.MakeEvent(INPUT_MBUTTONUP, D2DK_RBUTTON, 0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;

  WM_MOUSEMOVE:
   begin
    l_X := SmallInt(LongRec(lParam).Lo);
    l_Y := SmallInt(LongRec(lParam).Hi);
    //gD2DE.System_Log('MM: %d, %d', [l_X, l_Y]);
    gD2DE.Input_SetMousePos(l_X, l_Y);
    Exit;
   end;
  WM_MOUSEWHEEL:
   begin
    gD2DE.MakeEvent(INPUT_MOUSEWHEEL, SmallInt(LongRec(wParam).Hi) div 120,
       0, 0, SmallInt(LongRec(lParam).Lo), SmallInt(LongRec(lParam).Hi));
    Exit;
   end;

  WM_SYSCOMMAND:
   if wParam = SC_CLOSE then
   begin
    if Assigned(gD2DE.f_OnExit) then
    begin
     if gD2DE.OnExit then
     begin
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);
      gD2DE.f_Active := False;
     end;
    end
    else
    begin
     Result := DefWindowProc(hWnd, Msg, wParam, lParam);
     gD2DE.f_Active := False;
    end;
    Exit;
   end;

  MM_MCINOTIFY:
   begin
    if (wParam = MCI_NOTIFY_SUCCESSFUL) then
     if (gD2DE.f_MusicLooped) then
      gD2DE.ReplayMIDI
     else
      gD2DE.Music_Stop;
   end;
 end;

 Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;

procedure D2DInit(aWidth, aHeight: Integer; aWindowed: Boolean = True; aWindowTitle: string = '');
begin
 if gD2DE = nil then
  Td2dCore.Create(aWidth, aHeight, aWindowed, aWindowTitle);
end;

procedure D2DDone;
begin
 FreeAndNil(gD2DE);
end;

constructor Td2dCore.Create(aWidth, aHeight: Integer; aWindowed: Boolean = True; aWindowTitle: string = '');
begin
 inherited Create;
 f_ScreenWidth  := aWidth;
 f_ScreenHeight := aHeight;
 f_Windowed := aWindowed;
 f_Active := True;
 if aWindowTitle = '' then
  f_WindowTitle := 'Delphi 2D Engine Application'
 else
  f_WindowTitle := aWindowTitle; 
 f_FixedFPS := D2D_FPS_UNLIMITED;
 f_FixedDelta := 0;
 f_Instance := 0;
 f_WHandle := 0;
 f_ScreenBPP := 32;
 f_UseZBuffer := False;
 f_Targets := TList.Create;
 f_Textures := JclStringList;
 f_InputEvents := TList.Create;
 f_AttachedPacks := JclStringList;
 f_AttachedPacks.CaseSensitive := False;
 f_AttachedPacks.Sorted := True;
 f_SndSamples := TStringList.Create;
 f_TextureFilter := True;
 f_OnFocusGain := nil;
 f_OnFocusLost := nil;
 f_OnFrame := nil;
 f_OnRender := nil;
 f_CurTarget := nil;
 f_HideMouse := True;
 f_D3D := nil;
 f_D3DDevice := nil;
 f_SoundOn := True;
 f_SoundSampleRate := 44100;
 f_LogFileName := ChangeFileExt(ParamStr(0), '.log');
 gD2DE := Self;
 {$IFDEF TRACE_STACK}
 // Enable raw mode (default mode uses stack frames which aren't always generated by the compiler)
 Include(JclStackTrackingOptions, stRawMode);
 // Disable stack tracking in dynamically loaded modules (it makes stack tracking code a bit faster)
 Include(JclStackTrackingOptions, stStaticModuleList);
 // Initialize Exception tracking
 JclStartExceptionTracking;
 {$ENDIF}
end;

destructor Td2dCore.Destroy;
begin
 {$IFDEF TRACE_STACK}
 // Uninitialize Exception tracking
 JclStopExceptionTracking;
 {$ENDIF}
 ClearTargets;
 f_Targets.Free;
 Texture_ClearCache;
 ClearQueue;
 Resource_RemoveAllPacks;
 f_AttachedPacks := nil;
 f_SndSamples.Free;
 ForceAllMusicStop;
 FreeAndNil(f_MusicFadeList);
 f_Textures := nil;
 inherited;
end;

procedure Td2dCore.AdjustWindow;
var
 l_Rect  : TRect;
 l_Style : Longint;
begin
 if f_Windowed then
 begin
  l_Rect := f_RectW;
  l_Style := f_WStyleW;
 end
 else
 begin
  l_Rect := f_RectFS;
  l_Style := f_WStyleFS;
 end;
 SetWindowLong(f_WHandle, GWL_STYLE, l_Style);

 l_Style := GetWindowLong(f_WHandle, GWL_EXSTYLE);
 if f_Windowed then
 begin
  SetWindowLong(f_WHandle, GWL_EXSTYLE, l_Style and not WS_EX_TOPMOST);
  with l_Rect do
   SetWindowPos(f_WHandle, HWND_NOTOPMOST, Left, Top, Right-Left, Bottom-Top, SWP_FRAMECHANGED);
 end
 else
 begin
  SetWindowLong(f_WHandle, GWL_EXSTYLE, l_Style or WS_EX_TOPMOST);
  with l_Rect do
   SetWindowPos(f_WHandle, HWND_TOPMOST, Left, Top, Right-Left, Bottom-Top, SWP_FRAMECHANGED);
 end;
end;

procedure Td2dCore.BassMusicStop(aChanel: Longword);
var
 I: Integer;
 l_FH: Td2dMusicHolder;
begin
 if aChanel = f_MusicHandle then
 begin
  if f_Music = mp_Stream then
   Resource_Free(f_MusicData);
  f_MusicHandle := 0;
  f_Music := mp_None;
 end
 else
 if f_MusicFadeList <> nil then
 begin
  for I := 0 to MusicFadeList.Count - 1 do
  begin
   l_FH := Td2dMusicHolder(MusicFadeList[I]);
   if l_FH.Chanel = aChanel then
   begin
    MusicFadeList.Delete(I);
    Break;
   end;
  end;
 end;
 if f_NextMusic.rFileName <> '' then
 try
  with f_NextMusic do
   Music_Play(rFileName, rLooped, rFadeinTime, rPackOnly);
 finally
  f_NextMusic.rFileName := '';
 end;
end;

procedure Td2dCore.ClearQueue;
var
 I: Integer;
begin
 f_InputEvents.Pack;
 for I := 0 to f_InputEvents.Count - 1 do
  Dispose(Pd2dInputEvent(f_InputEvents.Items[I]));
 f_InputEvents.Clear;
 f_KeyCode := 0;
 f_KeyChar := 0;
 f_MouseZ := 0;
end;

procedure Td2dCore.MakeEvent(aType: Integer; aKey: Integer; aScan: Integer; aFlags: Integer; aX, aY: Integer);
var
 l_Event: Pd2dInputEvent;
 l_Pnt: TPoint;
 l_KbdState: TKeyboardState;
begin
 New(l_Event);
 l_Event.EventType := aType;
 l_Event.KeyChar := 0;
 l_Event.KeyScan := aScan;

 if l_Pnt.X <> c_NoMouseCoord then
 begin
  l_Pnt.X := aX;
  l_Pnt.Y := aY;
 end
 else
 begin
  l_Pnt.X := Round(f_MouseX);
  l_Pnt.Y := Round(f_MouseY);
 end;

 GetKeyboardState(l_KbdState);

 if (aType = INPUT_KEYDOWN) or (aType = INPUT_KEYUP) then
  ToAscii(aKey, aScan, l_KbdState, @(l_Event^.KeyChar), 0);

 if aType = INPUT_MOUSEWHEEL then
 begin
  l_Event.KeyCode := 0;
  l_Event.Wheel := aKey;
  //ScreenToClient(f_WHandle, l_Pnt);
 end
 else
 begin
  l_Event.KeyCode := aKey;
  l_Event.Wheel := 0;
 end;

 if aType = INPUT_MBUTTONDOWN then
 begin
  SetCapture(f_WHandle);
  f_MouseCaptured := True;
 end;

 if aType = INPUT_MBUTTONUP then
 begin
  ReleaseCapture;
  Input_TouchMousePos;
  l_Pnt.X := Round(f_MouseX);
  l_Pnt.Y := Round(f_MouseY);
  f_MouseCaptured := False;
 end;

 if (l_KbdState[VK_SHIFT] and $80) <> 0 then
  aFlags := aFlags or D2DINP_SHIFT;

 if (l_KbdState[VK_CONTROL] and $80) <> 0 then
  aFlags := aFlags or D2DINP_CTRL;

 if (l_KbdState[VK_MENU] and $80) <> 0 then
  aFlags := aFlags or D2DINP_ALT;

 if (l_KbdState[VK_CAPITAL] and $80) <> 0 then
  aFlags := aFlags or D2DINP_CAPSLOCK;

 if (l_KbdState[VK_SCROLL] and $80) <> 0 then
  aFlags := aFlags or D2DINP_SCROLLLOCK;

 if (l_KbdState[VK_NUMLOCK] and $80) <> 0 then
  aFlags := aFlags or D2DINP_NUMLOCK;

 l_Event.Flags := aFlags;

 l_Event.X := l_Pnt.X;
 l_Event.Y := l_Pnt.Y;

 f_InputEvents.Add(l_Event);

 if (l_Event.EventType = INPUT_KEYDOWN) or (l_Event.EventType = INPUT_MBUTTONDOWN) then
 begin
  f_KeyCode := l_Event.KeyCode;
  f_KeyChar := l_Event.KeyChar;
 end
 else
  if l_Event.EventType = INPUT_MOUSEMOVE then
  begin
   f_MouseX := l_Event.X;
   f_MouseY := l_Event.Y;
  end
  else
   if l_Event.EventType = INPUT_MOUSEWHEEL then
    f_MouseZ := f_MouseZ + l_Event.Wheel;
end;

procedure Td2dCore.ClearTargets;
var
 I: Integer;
begin
 f_Targets.Pack;
 for I := 0 to f_Targets.Count - 1 do
  Dispose(Pd2dRenderTarget(f_Targets.Items[I]));
 f_Targets.Clear;
end;

procedure Td2dCore.ReplayMIDI;
begin
 if mciSendString('play d2dmidi from 0 notify', nil, 0, f_WHandle) = 0 then
  f_Music := mp_MIDI
 else
  Music_Stop;
end;

procedure Td2dCore.FlushPrimitives;
begin
 RenderBatch;
end;

procedure Td2dCore.FocusChange(const anActive: Boolean);
begin
 f_Active := anActive;
 if f_Active then
 begin
  GfxRestore;
  System_SoundResume;
  if Assigned(f_OnFocusGain) then
   f_OnFocusGain;
 end
 else
 begin
  ClearQueue;
  System_SoundPause;
  if Assigned(f_OnFocusLost) then
   f_OnFocusLost;
 end;
end;

procedure Td2dCore.GfxDone;
begin
 f_ScreenSurf  := nil;
 f_ScreenDepth := nil;
 ClearTargets;
 if Assigned(f_IB) then
 begin
  f_D3DDevice.SetIndices(nil, 0);
  f_IB := nil;
 end;

 if Assigned(f_VB) then
 begin
  if f_VertArray <> nil then
  begin
   f_VB.Unlock;
   f_VertArray := nil;
  end;
  f_D3DDevice.SetStreamSource(0, nil, SizeOf(Td2dVertex));
  f_VB := nil;
 end;

 if Assigned(f_D3DDevice) then
  f_D3DDevice := nil;

 if Assigned(f_D3D) then
  f_D3D := nil;
end;

function Td2dCore.GfxInit: Boolean;
const
 cModeNames: array [0..5] of string =
   ('UNKNOWN', 'R5G6B5', 'X1R5G5B5', 'A1R5G5B5', 'X8R8G8B8', 'A8R8G8B8');
var
 l_AdID : D3DADAPTER_IDENTIFIER8;
 l_DVer : array [1..2] of Word;
 l_Mode : D3DDISPLAYMODE;
 l_Tmp: TD3DMatrix;
 l_XScale, l_YScale: Single;

begin
 Result := False;
 // Creating DirectX8 interface...
 f_D3D := Direct3DCreate8(120);
 if f_D3D = nil then
 begin
  System_Log('Can''t create D3D interface');
  Exit;
 end;

 // Get adapter info
 f_D3D.GetAdapterIdentifier(D3DADAPTER_DEFAULT, D3DENUM_NO_WHQL_LEVEL, l_AdID);
 System_Log('D3D Driver : %s', [l_AdID.Driver]);
 System_Log('Description: %s', [l_AdID.Description]);
 Move(l_AdID.DriverVersion, l_DVer, SizeOf(Cardinal));
 System_Log('Version: %d.%d', [l_DVer[2], l_DVer[1]]);


 // Determine windowed mode presentation parameters
 if Failed(f_D3D.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, l_Mode)) or (l_Mode.Format = D3DFMT_UNKNOWN) then
 begin
  System_Log('Can''t determine desktop video mode');
  Exit;
 end;

 FillChar(f_D3DPP_W, SizeOf(f_D3DPP_W), 0);
 with f_D3DPP_W do
 begin
  BackBufferWidth  := f_ScreenWidth;
  BackBufferHeight := f_ScreenHeight;
  BackBufferFormat := l_Mode.Format;
  BackBufferCount  := 1;
  MultiSampleType  := D3DMULTISAMPLE_NONE;
  hDeviceWindow    := f_WHandle;
  Windowed         := True;
 end;

	if f_FixedFPS = D2D_FPS_VSYNC then
  f_D3DPP_W.SwapEffect := D3DSWAPEFFECT_COPY_VSYNC
	else
  f_D3DPP_W.SwapEffect := D3DSWAPEFFECT_COPY;

	if f_UseZBuffer then
 begin
  f_D3DPP_W.EnableAutoDepthStencil := True;
  f_D3DPP_W.AutoDepthStencilFormat := D3DFMT_D16;
 end;

 // Determine fullscreen mode presentation parameters
 FillChar(f_D3DPP_FS, SizeOf(f_D3DPP_W), 0);
 with f_D3DPP_FS do
 begin
  BackBufferWidth  := l_Mode.Width;
  BackBufferHeight := l_Mode.Height;
  BackBufferFormat := l_Mode.Format;
  BackBufferCount  := 1;
  MultiSampleType  := D3DMULTISAMPLE_NONE;
  hDeviceWindow    := f_WHandle;
  Windowed         := False;
  SwapEffect       := D3DSWAPEFFECT_FLIP;
  FullScreen_RefreshRateInHz := D3DPRESENT_RATE_DEFAULT;

  if f_FixedFPS = D2D_FPS_VSYNC then
   FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE
  else
   FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;

  if f_UseZBuffer then
  begin
   EnableAutoDepthStencil := True;
   AutoDepthStencilFormat := D3DFMT_D16;
  end;
 end; // with

 if f_Windowed then
  f_D3DPP := f_D3DPP_W
 else
  f_D3DPP := f_D3DPP_FS;

 // Create device
 if Failed(f_D3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, f_WHandle,
      D3DCREATE_HARDWARE_VERTEXPROCESSING or D3DCREATE_FPU_PRESERVE, f_D3DPP, f_D3DDevice)) then
 begin
  System_Log('The hardware vertex processing is not available. Switching to software one.');
  if Failed(f_D3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, f_WHandle,
      D3DCREATE_SOFTWARE_VERTEXPROCESSING or D3DCREATE_FPU_PRESERVE, f_D3DPP, f_D3DDevice)) then
  begin
   System_Log('Can''t create D3D device');
   Exit;
  end;
 end;

 AdjustWindow;

 System_Log('Mode: %d x %d x %s',[f_ScreenWidth, f_ScreenHeight,
    cModeNames[FormatID(f_D3DPP.BackBufferFormat)]]);

 SetProjectionMatrix(f_D3DPP.BackBufferWidth, f_D3DPP.BackBufferHeight);

 // preparing view matrix for fullscreen mode
 f_FSScale := 1;
 if (f_D3DPP_W.BackBufferWidth <> f_D3DPP_FS.BackBufferWidth) or (f_D3DPP_W.BackBufferHeight <> f_D3DPP_FS.BackBufferHeight) then
 begin
  l_XScale := f_D3DPP_FS.BackBufferWidth / f_D3DPP_W.BackBufferWidth;
  l_YScale := f_D3DPP_FS.BackBufferHeight / f_D3DPP_W.BackBufferHeight;
  if l_YScale < l_XScale then
  begin
   f_FSScale := l_YScale;
   f_FSWidth  := Trunc(f_D3DPP_W.BackBufferWidth * f_FSScale + 0.5);
   f_FSHeight := f_D3DPP_FS.BackBufferHeight;
   f_FSDX := (f_D3DPP_FS.BackBufferWidth - f_FSWidth) div 2;
   f_FSDY := 0;
  end
  else
  begin
   f_FSScale := l_XScale;
   f_FSWidth  := f_D3DPP_FS.BackBufferWidth;
   f_FSHeight := Trunc(f_D3DPP_W.BackBufferHeight * f_FSScale + 0.5);
   f_FSDX := 0;
   f_FSDY := (f_D3DPP_FS.BackBufferHeight - f_FSHeight) div 2;
  end;
  D3DXMatrixScaling(f_matViewFS, f_FSScale, f_FSScale, 1);
  D3DXMatrixTranslation(l_Tmp, f_FSDX, f_FSDY, 0);
  D3DXMatrixMultiply(f_MatViewFS, f_MatViewFS, l_Tmp);
 end
 else
  D3DXMatrixIdentity(f_matViewFS);

 GfxSetViewMatrix;

 if not InitLost then
  Exit;

 Gfx_Clear(0); 

 Result := True;
end;

procedure Td2dCore.GfxRestore;
begin
 if not Assigned(f_D3DDevice) then
  Exit;
 if f_D3DDevice.TestCooperativeLevel = D3DERR_DEVICELOST then    //<> D3DERR_DEVICENOTRESET then
  Exit;
 f_ScreenSurf := nil;
 f_ScreenDepth := nil;
 ClearTargets;

 if Assigned(f_IB) then
 begin
  f_D3DDevice.SetIndices(nil, 0);
  f_IB := nil;
 end;

 if Assigned(f_VB) then
 begin
  f_D3DDevice.SetStreamSource(0, nil, SizeOf(Td2dVertex));
  f_VB := nil;
 end;

 f_D3DDevice.Reset(f_D3DPP);
 InitLost;
end;

function Td2dCore.Gfx_BeginScene(aTarget: Pd2dRenderTarget = nil): Boolean;
var
 l_Surf, l_Depth : IDirect3DSurface8;
begin
 Result := False;
 if f_VertArray <> nil then
 begin
  System_Log('Gfx_BeginScene: Scene is already being rendered.');
  Exit;
 end;

 if aTarget <> f_CurTarget then
 begin
  if aTarget <> nil then
  begin
   aTarget.Tex.GetSurfaceLevel(0, l_Surf);
   l_Depth := aTarget.Depth;
  end
  else
  begin
   l_Surf := f_ScreenSurf;
   l_Depth := f_ScreenDepth;
  end;
  if Failed(f_D3DDevice.SetRenderTarget(l_Surf, l_Depth)) then
  begin
   System_Log('Gfx_BeginScene: Can''t set render target.');
   Exit;
  end;
  if aTarget <> nil then
  begin
   l_Surf := nil;
   if aTarget.Depth <> nil then
    f_D3DDevice.SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE)
   else
    f_D3DDevice.SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
   SetProjectionMatrix(aTarget.Width, aTarget.Height);
  end
  else
  begin
   if f_UseZBuffer then
    f_D3DDevice.SetRenderState(D3DRS_ZENABLE, D3DZB_TRUE)
   else
    f_D3DDevice.SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
   SetProjectionMatrix(f_ScreenWidth, f_ScreenHeight);
  end;
  f_D3DDevice.SetTransform(D3DTS_PROJECTION, f_matProj);
  GfxSetViewMatrix;
  f_D3DDevice.SetTransform(D3DTS_VIEW, f_matView);

  f_CurTarget := aTarget;
 end;

 f_D3DDevice.BeginScene;
 f_VB.Lock(0,0, PByte(f_VertArray), 0);

 Result := True;
end;

procedure Td2dCore.Gfx_Clear(aColor: Longword);
begin
 if f_CurTarget <> nil then
 begin
  if f_CurTarget.Depth <> nil then
   f_D3DDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, aColor, 1.0, 0)
  else
   f_D3DDevice.Clear(0, nil, D3DCLEAR_TARGET, aColor, 1.0, 0);
 end
 else
 begin
  if f_UseZBuffer then
   f_D3DDevice.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, aColor, 1.0, 0)
  else
   f_D3DDevice.Clear(0, nil, D3DCLEAR_TARGET, aColor, 1.0, 0);
 end;
end;

procedure Td2dCore.Gfx_EndScene;
begin
 if f_VertArray = nil then
  Exit;
 RenderBatch(True);
 f_D3DDevice.EndScene;
 if f_CurTarget = nil then // if current target is screen then populate
  f_D3DDevice.Present(nil, nil, 0, nil);
 f_VertArray := nil; 
end;

procedure Td2dCore.Gfx_RenderLine(const X1, Y1, X2, Y2: Single; const aColor: Longword; const Z: Single);
var
 I: Integer;
begin
 if (f_CurPrim <> D2DPRIM_LINES) or (f_PrimCount >= VertexBufferSize div D2DPRIM_LINES) or (f_CurTexture <> nil) or
    (f_CurBlendMode <> BLEND_DEFAULT) then
 begin
  RenderBatch;
  f_CurPrim := D2DPRIM_LINES;
  if f_CurBlendMode <> BLEND_DEFAULT then
   SetBlendMode(BLEND_DEFAULT);
  if f_CurTexture <> nil then
  begin
   f_D3DDevice.SetTexture(0, nil);
   f_CurTexture := nil;
  end;
 end;
 I := f_PrimCount * D2DPRIM_LINES;
 with f_VertArray[I] do
 begin
  X := X1;
  Y := Y1;
  Z := Z;
  Col := aColor;
  TX :=  0; TY := 0;
 end;
 with f_VertArray[I+1] do
 begin
  X := X2;
  Y := Y2;
  Z := Z;
  Col := aColor;
  TX :=  0; TY := 0;
 end;
 Inc(f_PrimCount);
end;

procedure Td2dCore.Gfx_RenderTriple(const aTriple: Td2dTriple);
begin
 if (f_CurPrim <> D2DPRIM_TRIPLES) or (f_PrimCount >= VertexBufferSize div D2DPRIM_TRIPLES) or
    (f_CurTexture <> aTriple.Tex) or (f_CurBlendMode <> aTriple.Blend) then
 begin
  RenderBatch;
  f_CurPrim := D2DPRIM_TRIPLES;
  if f_CurBlendMode <> aTriple.Blend then
   SetBlendMode(aTriple.Blend);
  if f_CurTexture <> aTriple.Tex then
  begin
   f_D3DDevice.SetTexture(0, aTriple.Tex);
   f_CurTexture := aTriple.Tex;
  end;
 end;
 Move(aTriple.V, f_VertArray[f_PrimCount*D2DPRIM_TRIPLES], SizeOf(Td2dVertex)*D2DPRIM_TRIPLES);
 Inc(f_PrimCount);
end;

procedure Td2dCore.Gfx_RenderQuad(const aQuad: Td2dQuad);
begin
 if (f_CurPrim <> D2DPRIM_QUADS) or (f_PrimCount >= VertexBufferSize div D2DPRIM_QUADS) or
    (f_CurTexture <> aQuad.Tex) or (f_CurBlendMode <> aQuad.Blend) then
 begin
  RenderBatch;
  f_CurPrim := D2DPRIM_QUADS;
  if f_CurBlendMode <> aQuad.Blend then
   SetBlendMode(aQuad.Blend);
  if f_CurTexture <> aQuad.Tex then
  begin
   f_D3DDevice.SetTexture(0, aQuad.Tex);
   f_CurTexture := aQuad.Tex;
  end;
 end;
 Move(aQuad.V, f_VertArray[f_PrimCount*D2DPRIM_QUADS], SizeOf(Td2dVertex)*D2DPRIM_QUADS);
 Inc(f_PrimCount);
end;

procedure Td2dCore.Gfx_SetClipping(aX: Integer = 0; aY: Integer = 0; aWidth: Integer = 0; aHeight: Integer = 0);
var
 l_VP: D3DVIEWPORT8;
 l_ScrWidth, l_ScrHeight: Integer;
 l_Tmp: TD3DXMatrix;
 l_L: Single;
 l_R: Single;
 l_B: Single;
 l_T: Single;
begin
 if not Assigned(f_CurTarget) then
 begin
  if f_Windowed then
  begin
   l_ScrWidth := f_ScreenWidth;
   l_ScrHeight := f_ScreenHeight;
  end
  else
  begin
   l_ScrWidth := f_D3DPP_FS.BackBufferWidth;
   l_ScrHeight := f_D3DPP_FS.BackBufferHeight;
   aX := Round(aX * f_FSScale + f_FSDX);
   aY := Round(aY * f_FSScale + f_FSDY);
   aWidth := Round(aWidth * f_FSScale);
   aHeight := Round(aHeight * f_FSScale);
  end;
 end
 else
 begin
  l_ScrWidth := Texture_GetWidth(f_CurTarget.Tex);
  l_ScrHeight := Texture_GetHeight(f_CurTarget.Tex);
 end;

 if aWidth = 0 then
 begin
  l_VP.X := 0;
  l_VP.Y := 0;
  l_VP.Width := l_ScrWidth;
  l_VP.Height := l_ScrHeight;
  l_VP.MinZ := 0.0;
  l_VP.MaxZ := 1.0;
 end
 else
 begin
  if aX < 0 then
  begin
   aWidth := aWidth + aX;
   aX := 0;
  end;
  if aY < 0 then
  begin
   aHeight := aHeight + aY;
   aY := 0;
  end;

  if aX + aWidth > l_ScrWidth then
   aWidth := l_ScrWidth - aX;
  if aY + aHeight > l_ScrHeight then
   aHeight := l_ScrHeight - aY;

  with l_VP do
  begin
   X := aX;
   Y := aY;
   Width := aWidth;
   Height := aHeight;
   MinZ := 0.0;
   MaxZ := 1.0;
  end;
 end;

 RenderBatch;
 f_D3DDevice.SetViewport(l_VP);

 D3DXMatrixScaling(f_matProj, 1.0, -1.0, 1.0);
 D3DXMatrixTranslation(l_Tmp, -0.5{ * f_FSScale}, +0.5{ * f_FSScale}, 0.0);
 D3DXMatrixMultiply(f_matProj, f_matProj, l_Tmp);
 l_L := l_VP.X;
 l_R := l_VP.X+l_VP.Width;
 l_B := l_VP.Y+l_VP.Height;
 l_T := l_VP.Y;
 D3DXMatrixOrthoOffCenterLH(l_Tmp, l_L, l_R, -l_B, -l_T, l_VP.MinZ, l_VP.MaxZ);
 D3DXMatrixMultiply(f_matProj, f_matProj, l_Tmp);
 f_D3DDevice.SetTransform(D3DTS_PROJECTION, f_matProj);
end;

procedure Td2dCore.Gfx_SetTransform(const aX: Single = 0; const aY: Single = 0; const aDX: Single = 0; const aDY:
    Single = 0; const aRot: Single = 0; const aHScale: Single = 0; const aVScale: Single = 0);
var
 l_Tmp: TD3DXMatrix;
begin
 if aVScale = 0 then
  GfxSetViewMatrix// D3DXMatrixIdentity(f_matView)
 else
 begin
  D3DXMatrixTranslation(f_matView, -aX, -aY, 0.0);
		D3DXMatrixScaling(l_Tmp, aHScale, aVScale, 1.0);
		D3DXMatrixMultiply(f_matView, f_matView, l_Tmp);
		D3DXMatrixRotationZ(l_Tmp, -aRot);
		D3DXMatrixMultiply(f_matView, f_matView, l_Tmp);
		D3DXMatrixTranslation(l_Tmp, aX+aDX, aY+aDY, 0.0);
		D3DXMatrixMultiply(f_matView, f_matView, l_Tmp);
 end;
 RenderBatch;
 f_D3DDevice.SetTransform(D3DTS_VIEW, f_matView);
end;

function Td2dCore.InitLost: Boolean;
var
 I: Integer;
 l_Target: Pd2dRenderTarget;
 l_Index : PWord;
 N: Integer;
begin
 Result := False;
 f_ScreenSurf := nil;
 f_ScreenDepth := nil;
 f_D3DDevice.GetRenderTarget(f_ScreenSurf);
 f_D3DDevice.GetDepthStencilSurface(f_ScreenDepth);

 // Rebuild all render target surfaces
 for I := 0 to f_Targets.Count - 1 do
 begin
  l_Target := Pd2dRenderTarget(f_Targets.Items[I]);
  if Assigned(l_Target) then
  begin
   if l_Target.Tex <> nil then
    D3DXCreateTexture(f_D3DDevice, l_Target.Width, l_Target.Height, 1, D3DUSAGE_RENDERTARGET,
        f_D3DPP.BackBufferFormat, D3DPOOL_DEFAULT, l_Target.Tex);
   if l_Target.Depth <> nil then
    f_D3DDevice.CreateDepthStencilSurface(l_Target.Width, l_Target.Height,
						   D3DFMT_D16, D3DMULTISAMPLE_NONE, l_Target.Depth);
  end;
 end;

 // Create vertex buffer
 if Failed(f_D3DDevice.CreateVertexBuffer(VertexBufferSize*SizeOf(Td2dVertex),
                D3DUSAGE_WRITEONLY, D3DFVF_D2DVERTEX, D3DPOOL_DEFAULT, f_VB)) then
 begin
  System_Log('Can''t create D3D vertex buffer');
  Exit;
 end;

 f_D3DDevice.SetVertexShader(D3DFVF_D2DVERTEX);
	f_D3DDevice.SetStreamSource(0, f_VB, SizeOf(Td2dVertex));

 // Create and setup Index buffer
 if Failed(f_D3DDevice.CreateIndexBuffer(VertexBufferSize * 6 div 4 * SizeOf(Word),
               D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_DEFAULT, f_IB)) then
 begin
  System_Log('Can''t create D3D index buffer');
  Exit;
 end;

 if Failed(f_IB.Lock(0, 0, PByte(l_Index), 0)) then
 begin
  System_Log('Can''t lock index buffer');
  Exit;
 end;

 N := 0;
 for I := 0 to VertexBufferSize div 4 - 1 do
 begin
  l_Index^ := N; Longword(l_Index) := Longword(l_Index) + 2;
  l_Index^ := N+1; Longword(l_Index) := Longword(l_Index) + 2;
  l_Index^ := N+2; Longword(l_Index) := Longword(l_Index) + 2;
  l_Index^ := N+2; Longword(l_Index) := Longword(l_Index) + 2;
  l_Index^ := N+3; Longword(l_Index) := Longword(l_Index) + 2;
  l_Index^ := N; Longword(l_Index) := Longword(l_Index) + 2;
  N := N + 4;
 end;

 f_IB.Unlock;
 f_D3DDevice.SetIndices(f_IB, 0);

 // Set common render states

	//f_D3DDevice.SetRenderState( D3DRS_LASTPIXEL, 0 {FALSE });
	f_D3DDevice.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE);
	f_D3DDevice.SetRenderState( D3DRS_LIGHTING, 0);

	f_D3DDevice.SetRenderState( D3DRS_ALPHABLENDENABLE, 1);
	f_D3DDevice.SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
	f_D3DDevice.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );

	f_D3DDevice.SetRenderState( D3DRS_ALPHATESTENABLE, 1);
	f_D3DDevice.SetRenderState( D3DRS_ALPHAREF,        $01 );
	f_D3DDevice.SetRenderState( D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL );

	f_D3DDevice.SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_MODULATE );
	f_D3DDevice.SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	f_D3DDevice.SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );

	f_D3DDevice.SetTextureStageState( 0, D3DTSS_ALPHAOP,   D3DTOP_MODULATE );
	f_D3DDevice.SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
	f_D3DDevice.SetTextureStageState( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE );

	f_D3DDevice.SetTextureStageState(0, D3DTSS_MIPFILTER, D3DTEXF_POINT);

 //f_D3DDevice.SetTextureStageState(0, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP);
 //f_D3DDevice.SetTextureStageState(0, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP);

	if f_TextureFilter then
	begin
		f_D3DDevice.SetTextureStageState(0,D3DTSS_MAGFILTER,D3DTEXF_LINEAR);
		f_D3DDevice.SetTextureStageState(0,D3DTSS_MINFILTER,D3DTEXF_LINEAR);
	end
	else
	begin
		f_D3DDevice.SetTextureStageState(0,D3DTSS_MAGFILTER,D3DTEXF_POINT);
		f_D3DDevice.SetTextureStageState(0,D3DTSS_MINFILTER,D3DTEXF_POINT);
	end;

 f_PrimCount := 0;
 f_CurPrim   := D2DPRIM_QUADS;
 f_CurBlendMode := BLEND_DEFAULT;
 f_CurTexture := nil;
 f_VertArray := nil;

 f_D3DDevice.SetTransform(D3DTS_VIEW, f_matView);
	f_D3DDevice.SetTransform(D3DTS_PROJECTION, f_matProj);

 Result := True;
end;

function Td2dCore.Input_GetEvent(var anEvent: Td2dInputEvent): Boolean;
begin
 Result := False;
 if f_InputEvents.Count > 0 then
 begin
  anEvent := Pd2dInputEvent(f_InputEvents.Items[0])^;
  Dispose(Pd2dInputEvent(f_InputEvents.Items[0]));
  f_InputEvents.Delete(0);
  Result := True;
 end;
end;

function Td2dCore.Input_GetKeyState(aKey: Integer): Boolean;
begin
 Result := f_Active and (GetAsyncKeyState(aKey) and $8000 <> 0);
end;

procedure Td2dCore.Input_SetMousePos(newX, newY: Integer);
var
 l_Pnt: TPoint;
begin
 if f_Windowed then
 begin
  l_Pnt.X := newX;
  l_Pnt.Y := newY;
 end
 else
 begin
  l_Pnt.X := Round((newX - f_FSDX) / f_FSScale);
  l_Pnt.Y := Round((newY - f_FSDY) / f_FSScale);
 end;
 //System_log('MM: %d, %d', [l_Pnt.X, l_Pnt.Y]);
 MakeEvent(INPUT_MOUSEMOVE, 0, 0, 0, l_Pnt.X, l_Pnt.Y);
end;

procedure StopMusicSync(handle: HSYNC; channel, data: DWORD; user: Pointer); stdcall;
begin
 gD2DE.BassMusicStop(channel);
end;

procedure FadeoutMusicSync(handle: HSYNC; channel, data: DWORD; user: Pointer); stdcall;
begin
 BASS_ChannelStop(channel);
end;

function Td2dCore.Texture_CreatePrim(aData: Pointer; aSize: Longword; aMipMap: Boolean = False;
                                     aColorKey: Td2dColor = 0): Id2dTexture;
var
 l_Fmt1, l_Fmt2: D3DFORMAT;
 l_MipLevel: Integer;
 l_Info : D3DXIMAGE_INFO;
 l_ResultTex: IDirect3DTexture8;
begin
 Result := nil;
 if PLongWord(aData)^ = $20534444 then // Compressed DDS format magic number
 begin
  l_Fmt1 := D3DFMT_UNKNOWN;
  l_Fmt2 := D3DFMT_A8R8G8B8;
 end
 else
 begin
  l_Fmt1 := D3DFMT_A8R8G8B8;
  l_Fmt2 := D3DFMT_UNKNOWN;
 end;

 if aMipMap then
  l_MipLevel := 1
 else
  l_MipLevel := 0;
 
 if Failed(D3DXCreateTextureFromFileInMemoryEx(
        f_D3DDevice, aData^, aSize, D3DX_DEFAULT, D3DX_DEFAULT, l_MipLevel,
        0, l_Fmt1, D3DPOOL_MANAGED, D3DX_FILTER_NONE, D3DX_DEFAULT, aColorKey, @l_Info,
        nil, l_ResultTex)) then
  D3DXCreateTextureFromFileInMemoryEx(
        f_D3DDevice, aData^, aSize, D3DX_DEFAULT, D3DX_DEFAULT, l_MipLevel,
        0, l_Fmt2, D3DPOOL_MANAGED, D3DX_FILTER_NONE, D3DX_DEFAULT, aColorKey, @l_Info,
        nil, l_ResultTex);
 if l_ResultTex <> nil then
  Result := Td2dTexture.Make(l_ResultTex);
end;

procedure Td2dCore.Music_MIDIPlay(aFileName: string; aLooped: Boolean = True; aPackOnly: Boolean = False);
var
 l_FS: TFileStream;
 TempPath, TempFile : array [0..MAX_PATH] of Char;
 l_Size: Longword;
 l_Str: string;
 l_MidiVolume: LongWord;
begin
 if f_Music <> mp_None then
  Music_Stop;
 f_MusicData := Resource_Load(aFileName, @l_Size, aPackOnly);
 if f_MusicData <> nil then
 begin
  try
   Windows.GetTempPath(MAX_PATH, TempPath);
   Windows.GetTempFileName(TempPath, 'bass', 0, TempFile);
   f_MusicMidiTempFile := TempFile;
   l_FS := TFileStream.Create(f_MusicMidiTempFile, fmCreate);
   try
    l_FS.WriteBuffer(f_MusicData^, l_Size);
   finally
    l_FS.Free;
   end;
   l_Str := Format('open sequencer!%s alias d2dmidi', [f_MusicMidiTempFile]);
   //l_Str := 'open sequencer!7.mid alias d2dmidi';
   if mciSendString(PChar(l_Str), nil, 0, 0) = 0 then
   begin
    f_MusicLooped := aLooped;
    l_MidiVolume := (f_MusicVolume shl 24) or (f_MusicVolume shl 8);
    midiOutSetVolume(f_MidiDevice, l_MidiVolume);
    ReplayMIDI;
   end
   else
    System_Log('Can''t play music (%s).', [aFileName]);
  finally
   Resource_Free(f_MusicData);
  end;
 end
 else
   System_Log('Can''t load music (%s).', [aFileName]);
end;

procedure Td2dCore.Music_MODPlay(aFileName: string; aLooped: Boolean = True; aFadeinTime: Longint = 0; aPackOnly:
    Boolean = False);
var
 l_Size: Longword;
 l_Flags: Cardinal;
begin
 if f_Music <> mp_None then
 begin
  if aFadeinTime < 0 then
  begin
   Music_Stop(-aFadeinTime);
   f_NextMusic := D2DMusicRec(aFileName, aLooped, -aFadeinTime, aPackOnly);
   Exit;
  end;
  Music_Stop(aFadeinTime);
 end;
 aFadeinTime := Abs(aFadeinTime);
 if BASS_Handle <> 0 then
 begin
  f_MusicData := Resource_Load(aFileName, @l_Size, aPackOnly);
  if f_MusicData <> nil then
  begin
   try
    l_Flags := BASS_MUSIC_AUTOFREE or BASS_MUSIC_SINCINTER or BASS_MUSIC_RAMPS or BASS_MUSIC_SURROUND2;
    if aLooped then
     l_Flags := l_Flags or BASS_MUSIC_LOOP;
    f_MusicHandle := BASS_MusicLoad(True, f_MusicData, 0, l_Size, l_Flags, 0);
    if f_MusicHandle <> 0 then
    begin
     BASS_ChannelSetSync(f_MusicHandle, BASS_SYNC_FREE or BASS_SYNC_MIXTIME or BASS_SYNC_ONETIME,
      0, StopMusicSync, nil);
     if aFadeinTime = 0 then
      BASS_ChannelSetAttribute(f_MusicHandle, BASS_ATTRIB_VOL, f_MusicVolume/255)
     else
     begin
      BASS_ChannelSetAttribute(f_MusicHandle, BASS_ATTRIB_VOL, 0);
      BASS_ChannelSlideAttribute(f_MusicHandle, BASS_ATTRIB_VOL, f_MusicVolume/255, aFadeinTime);
     end;
     BASS_ChannelPlay(f_MusicHandle, True);
     f_Music := mp_Module;
    end
    else
     System_Log('Can''t play music (%s).', [aFileName]);
   finally
    Resource_Free(f_MusicData);
   end;
  end
  else
   System_Log('Can''t load music (%s).', [aFileName]);
 end;
end;

procedure Td2dCore.Music_Play(aFileName: string; aLooped: Boolean = True; aFadeinTime: Longint = 0; aPackOnly: Boolean
 = False);
var
 l_Ext: string;
begin
 l_Ext := LowerCase(ExtractFileExt(aFileName));

 if (l_Ext = '.mid') or (l_Ext = '.midi') or (l_Ext = '.rmi') then
 begin
  Music_MIDIPlay(aFilename, aLooped, aPackOnly);
  Exit;
 end;

 if (l_Ext = '.wav') or (l_Ext = '.mp3') or (l_Ext = '.mp2') or (l_Ext = '.mp1') or (l_Ext = '.ogg') or
    (l_Ext = '.aiff') then
 begin
  Music_StreamPlay(aFilename, aLooped, aFadeinTime, aPackOnly);
  Exit;
 end;

 if (l_Ext = '.mo3') or (l_Ext = '.it') or (l_Ext = '.xm') or (l_Ext = '.s3m') or (l_Ext = '.mtm') or
    (l_Ext = '.mod') or (l_Ext = '.umx') then
 begin
  Music_MODPlay(aFilename, aLooped, aFadeinTime, aPackOnly);
  Exit;
 end;

 System_Log('Can''t recognize music type (%s).', [aFileName]);
end;

procedure Td2dCore.Music_Stop(aFadeoutTime: Longint = 0);
begin
 f_NextMusic.rFileName := ''; // подстраховка на случай если просто останавливается воспроизведение (чтобы никакой мусор там не мешался потом)
 case f_Music of
  mp_MIDI:
   begin
    mciSendString('close d2dmidi', nil, 0, 0);
    DeleteFile(f_MusicMidiTempFile);
    f_Music := mp_None;
   end;
  mp_Stream, mp_Module:
  begin
   if aFadeoutTime = 0 then
   begin
    BASS_ChannelStop(f_MusicHandle); // resources are freed through BASS sync event (see BassMusicStop)
    ForceAllMusicStop;
   end
   else
   begin
    BASS_ChannelSetSync(f_MusicHandle, BASS_SYNC_SLIDE or BASS_SYNC_MIXTIME or BASS_SYNC_ONETIME,
      0, FadeoutMusicSync, nil);
    BASS_ChannelSlideAttribute(f_MusicHandle, BASS_ATTRIB_VOL, 0, aFadeoutTime);
    if f_Music = mp_Stream then
     MusicFadeList.Add(Td2dMusicHolder.Create(f_MusicHandle, f_MusicData))
    else
     MusicFadeList.Add(Td2dMusicHolder.Create(f_MusicHandle));
    f_Music := mp_None;
    f_MusicHandle := 0;
   end;
  end;
 end;
end;

procedure Td2dCore.Music_StreamPlay(aFileName   : string;
                                    aLooped     : Boolean = True;
                                    aFadeinTime : Longint = 0;
                                    aPackOnly   : Boolean = False);
var
 l_Size: Longword;
 l_Flags: Cardinal;
begin
 if f_Music <> mp_None then
 begin
  if aFadeinTime < 0 then
  begin
   Music_Stop(-aFadeinTime);
   f_NextMusic := D2DMusicRec(aFileName, aLooped, -aFadeinTime, aPackOnly);
   Exit;
  end;
  Music_Stop(aFadeinTime);
 end;
 aFadeinTime := Abs(aFadeinTime);
 if BASS_Handle <> 0 then
 begin
  f_MusicData := Resource_Load(aFileName, @l_Size, aPackOnly);
  if f_MusicData <> nil then
  begin
   l_Flags := BASS_MUSIC_AUTOFREE;
   if aLooped then
    l_Flags := l_Flags or BASS_MUSIC_LOOP;
   f_MusicHandle := BASS_StreamCreateFile(True, f_MusicData, 0, l_Size, l_Flags);
   if f_MusicHandle <> 0 then
   begin
    BASS_ChannelSetSync(f_MusicHandle, BASS_SYNC_FREE or BASS_SYNC_MIXTIME or BASS_SYNC_ONETIME,
      0, StopMusicSync, nil);
    if aFadeinTime = 0 then
      BASS_ChannelSetAttribute(f_MusicHandle, BASS_ATTRIB_VOL, f_MusicVolume/255)
     else
     begin
      BASS_ChannelSetAttribute(f_MusicHandle, BASS_ATTRIB_VOL, 0);
      BASS_ChannelSlideAttribute(f_MusicHandle, BASS_ATTRIB_VOL, f_MusicVolume/255, aFadeinTime);
     end;
    BASS_ChannelPlay(f_MusicHandle, True);
    f_Music := mp_Stream;
   end
   else
   begin
    System_Log('Can''t play music (%s).', [aFileName]);
    Resource_Free(f_MusicData);
   end;
  end
  else
   System_Log('Can''t load music (%s).', [aFileName]);
 end;
end;

procedure Td2dCore.pm_SetFixedFPS(const Value: Integer);
begin
 if Assigned(f_VertArray) then
  Exit;
 if Assigned(f_D3DDevice) then
 begin
  if ((f_FixedFPS < 0) and (Value >= 0)) or ((f_FixedFPS >= 0) and (Value < 0)) then
  begin
   if Value = D2D_FPS_VSYNC then
   begin
    f_D3DPP_W.SwapEffect := D3DSWAPEFFECT_COPY_VSYNC;
    f_D3DPP_FS.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE;
   end
   else
   begin
    f_D3DPP_W.SwapEffect := D3DSWAPEFFECT_COPY;
    f_D3DPP_FS.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
   end;
   if Assigned(f_OnFocusLost) then
    f_OnFocusLost();
   GfxRestore;
   if Assigned(f_OnFocusGain) then
    f_OnFocusGain();
  end;
 end;
 f_FixedFPS := Value;
 if f_FixedFPS > 0 then
  f_FixedDelta := 1000 div Value
 else
  f_FixedDelta := 0;
end;

procedure Td2dCore.pm_SetMusicVolume(const Value: Byte);
begin
 Music_SetVolume(Value);
end;

procedure Td2dCore.pm_SetScreenBPP(const Value: Byte);
begin
 if not Assigned(f_D3DDevice) then
  f_ScreenBPP := Value;
end;

procedure Td2dCore.pm_SetScreenHeight(const Value: LongWord);
begin
 if not Assigned(f_D3DDevice) then
  f_ScreenHeight := Value;
end;

procedure Td2dCore.pm_SetScreenWidth(const Value: LongWord);
begin
 if not Assigned(f_D3DDevice) then
  f_ScreenWidth := Value;
end;

procedure Td2dCore.pm_SetTextureFilter(const Value: Boolean);
begin
 f_TextureFilter := Value;
 if Assigned(f_D3DDevice) then
 begin
  RenderBatch;
  if f_TextureFilter then
  begin
   f_D3DDevice.SetTextureStageState(0,D3DTSS_MAGFILTER,D3DTEXF_LINEAR);
   f_D3DDevice.SetTextureStageState(0,D3DTSS_MINFILTER,D3DTEXF_LINEAR);
  end
  else
  begin
   f_D3DDevice.SetTextureStageState(0,D3DTSS_MAGFILTER,D3DTEXF_POINT);
   f_D3DDevice.SetTextureStageState(0,D3DTSS_MINFILTER,D3DTEXF_POINT);
  end;
 end;
end;

procedure Td2dCore.pm_SetUseZBuffer(const Value: Boolean);
begin
 if not Assigned(f_D3DDevice) then
  f_UseZBuffer := Value;
end;

procedure Td2dCore.pm_SetWindowed(const Value: Boolean);
begin
 if Assigned(f_VertArray) then
  Exit;
 if Assigned(f_D3DDevice) and (Value <> f_Windowed) then
 begin
  if (f_D3DPP_W.BackBufferFormat = D3DFMT_UNKNOWN) or (f_D3DPP_W.BackBufferFormat = D3DFMT_UNKNOWN) then
   Exit;
  if Assigned(f_OnFocusLost) then
   f_OnFocusLost();
  if f_Windowed then
   GetWindowRect(f_WHandle, f_RectW);

  f_Windowed := Value;

  if f_Windowed then
   f_D3DPP := f_D3DPP_W
  else
   f_D3DPP := f_D3DPP_FS;

  if FormatID(f_D3DPP.BackBufferFormat) < 4 then
   f_ScreenBPP := 16
  else
   f_ScreenBPP := 32;  
  
  SetProjectionMatrix(f_D3DPP.BackBufferWidth, f_D3DPP.BackBufferHeight);
  GfxSetViewMatrix;
  GfxRestore;
  AdjustWindow;

  if Assigned(f_OnFocusGain) then
   f_OnFocusGain();
 end
 else
  f_Windowed := Value;
end;

procedure Td2dCore.pm_SetWindowTitle(const Value: string);
begin
 f_WindowTitle := Value;
 if f_WHandle <> 0 then
  SetWindowText(f_WHandle, PChar(f_WindowTitle));
end;

procedure Td2dCore.RenderBatch(aEndScene: Boolean = False);
begin
 if (f_PrimCount = 0) and not aEndScene then
  Exit;
 f_VB.Unlock;
 if f_PrimCount > 0 then
 begin
  case f_CurPrim of
   D2DPRIM_QUADS:
    f_D3DDevice.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, f_PrimCount shl 2, 0, f_PrimCount shl 1);

   D2DPRIM_TRIPLES:
    f_D3DDevice.DrawPrimitive(D3DPT_TRIANGLELIST, 0, f_PrimCount);

   D2DPRIM_LINES:
    f_D3DDevice.DrawPrimitive(D3DPT_LINELIST, 0, f_PrimCount);
  end;
 end;
 f_PrimCount := 0;
 if not aEndScene then
  f_VB.Lock(0,0, PByte(f_VertArray), 0);
end;

function Td2dCore.Resource_AttachPack(const aName: string; const aPack: Id2dResourcePack): Boolean;
var
 I: Integer;
begin
 Result := False;
 if f_AttachedPacks.Find(aName, I) then
 begin
  Result := True; // pack is already attached
  Exit;
 end;
 I := f_AttachedPacks.Add(aName);
 f_AttachedPacks.Interfaces[I] := aPack;
 Result := True;
end;

function Td2dCore.Resource_CreateStream(aFilename: string; aPackOnly: Boolean = False): TStream;
var
 l_Data: Pointer;
 l_Size: Longword;
begin
 Result := nil;
 if Resource_Exists(aFilename, aPackOnly) then
 begin
  l_Data := Resource_Load(aFilename, @l_Size, True, True);
  if l_Data <> nil then
  begin
   try
    Result := TMemoryStream.Create;
    with TMemoryStream(Result) do
    begin
     SetSize(l_Size);
     Move(l_Data^, Memory^, l_Size);
    end;
   finally
    Resource_Free(l_Data);
   end;
  end
  else
   Result := TFileStream.Create(aFilename, fmOpenRead);
 end;
end;

function Td2dCore.Resource_Exists(aFileName: string; aPackOnly: Boolean = False): Boolean;
var
 I: Integer;
 l_Pack: Id2dResourcePack;
begin
 Result := False;
 for I := 0 to f_AttachedPacks.Count - 1 do
 begin
  l_Pack := f_AttachedPacks.Interfaces[I] as Id2dResourcePack;
  if l_Pack.IndexOf(aFileName) >= 0 then
  begin
   Result := True;
   Exit;
  end;
 end;
 if not aPackOnly then
  Result := FileExists(aFileName);
end;

procedure Td2dCore.Resource_Free(aResource: Pointer);
begin
 if Assigned(aResource) then
  FreeMem(aResource);
end;

function Td2dCore.Resource_Load(const aFileName: string; aSize: PLongword; aPackOnly: Boolean = False; aSilent: Boolean = False): Pointer;
var
 I: Integer;
 l_Pack: Id2dResourcePack;
 l_Idx: Integer;
 l_FS: TFileStream;
begin
 Result := nil;
 // trying to find file in attached packs
 for I := 0 to f_AttachedPacks.Count - 1 do
 begin
  l_Pack := f_AttachedPacks.Interfaces[I] as Id2dResourcePack;
  l_Idx := l_Pack.IndexOf(aFileName);
  if l_Idx <> -1 then
  begin
   l_Pack.Extract(l_Idx, Result);
   if aSize <> nil then
    aSize^ := l_Pack.Size[l_Idx];
   Exit;
  end;
 end;
 if aPackOnly then
 begin
  if not aSilent then
   System_Log('Can''t find resource: %s', [aFileName]);
  Exit;
 end;
 // didn't found in packs - let's try to load from disk...
 if FileExists(aFileName) then
 begin
  l_FS := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
   GetMem(Result, l_FS.Size);
   l_FS.Read(Result^, l_FS.Size);
   if aSize <> nil then
    aSize^ := l_FS.Size;
  finally
   l_FS.Free;
  end;
 end
 else
  if not aSilent then
   System_Log('Can''t find resource: %s', [aFileName]);
end;

procedure Td2dCore.Resource_RemoveAllPacks;
begin
 f_AttachedPacks.Clear;
end;

procedure Td2dCore.Resource_RemovePack(const aFileName: string);
var
 I : Integer;
begin
 if f_AttachedPacks.Find(aFileName, I) then
  f_AttachedPacks.Delete(I);
end;

procedure Td2dCore.SetBlendMode(aBlend: Longint);
begin
 if (aBlend and BLEND_ALPHABLEND) <> (f_CurBlendMode and BLEND_ALPHABLEND) then
  if (aBlend and BLEND_ALPHABLEND) <> 0 then
   f_D3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA)
  else
   f_D3DDevice.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);

 if (aBlend and BLEND_ZWRITE) <> (f_CurBlendMode and BLEND_ZWRITE) then
  if (aBlend and BLEND_ZWRITE) <> 0 then
   f_D3DDevice.SetRenderState(D3DRS_ZWRITEENABLE, 1)
  else
   f_D3DDevice.SetRenderState(D3DRS_ZWRITEENABLE, 0);


 if (aBlend and BLEND_COLORADD) <> (f_CurBlendMode and BLEND_COLORADD) then
  if (aBlend and BLEND_COLORADD) <> 0 then
   f_D3DDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_ADD)
  else
   f_D3DDevice.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);

	f_CurBlendMode := aBlend;
end;

procedure Td2dCore.SetProjectionMatrix(const aWidth, aHeight: Integer);
var
 l_Temp: TD3DMatrix;
begin
 D3DXMatrixScaling(f_matProj, 1.0, -1.0, 1.0);
 D3DXMatrixTranslation(l_Temp, -0.5, aHeight+0.5, 0.0);
 D3DXMatrixMultiply(f_matProj, f_matProj, l_Temp);
 D3DXMatrixOrthoOffCenterLH(l_Temp, 0, aWidth, 0, aHeight, 0, 1.0);
 D3DXMatrixMultiply(f_matProj, f_matProj, l_Temp);
end;

procedure Td2dCore.Snd_FreeAll;
begin
 if BASS_Handle <> 0 then
 begin
  while f_SndSamples.Count > 0 do
   Snd_FreeSamplePrim(0);
 end
 else
  PlaySound(nil, 0, 0);
end;

procedure Td2dCore.Snd_FreeSample(aFilename: string);
var
 l_Idx: Integer;
begin
 if BASS_Handle <> 0 then
 begin
  l_Idx := f_SndSamples.IndexOf(LowerCase(aFilename));
  if l_Idx >= 0 then
   Snd_FreeSamplePrim(l_Idx);
 end;
end;

procedure Td2dCore.Snd_FreeSamplePrim(aIdx: Integer);
var
 l_Hnd: HSAMPLE;
begin
 if BASS_Handle <> 0 then
 begin
  l_Hnd := HSAMPLE(f_SndSamples.Objects[aIdx]);
  BASS_SampleStop(l_Hnd);
  BASS_SampleFree(l_Hnd);
  f_SndSamples.Delete(aIdx);
 end;
end;

procedure Td2dCore.Snd_PlaySample(aFilename: string; aVolume: Byte = 255;
                                  aLooped: Boolean = False; aPackOnly: Boolean = False);
var
 l_Idx: Integer;
 l_Ch: HCHANNEL;
 l_Data: Pointer;
 l_Size: LongWord;
begin
 if BASS_Handle <> 0 then
 begin
  l_Idx := Snd_PreLoadSample(aFilename);
  if l_Idx >= 0 then
  begin
   l_Ch := BASS_SampleGetChannel(HSAMPLE(f_SndSamples.Objects[l_Idx]), False);
   BASS_ChannelSetAttribute(l_Ch, BASS_ATTRIB_VOL, aVolume/255);
   if aLooped then
    BASS_ChannelFlags(l_Ch, BASS_SAMPLE_LOOP, BASS_SAMPLE_LOOP);
   BASS_ChannelPlay(l_Ch, True);
  end;
 end
 else
 begin
  l_Data := Resource_Load(aFilename, @l_Size);
  if l_Data <> nil then
  begin
   try
    PlaySound(PAnsiChar(l_Data), 0, SND_MEMORY or SND_SYNC or SND_NODEFAULT);
   finally
    Resource_Free(l_Data);
   end;
  end
  else
   System_Log('Can''t load sample (%s).', [aFilename]);
 end;
end;

function Td2dCore.Snd_PreLoadSample(aFileName: string; aPackOnly: Boolean = False): Integer;
var
 l_Data  : Pointer;
 l_Size  : Longword;
 l_Handle: HSAMPLE;
begin
 Result := -1;
 if BASS_Handle <> 0 then
 begin
  aFilename := LowerCase(aFilename);
  Result := f_SndSamples.IndexOf(aFilename);
  if Result < 0 then
  begin
   l_Data := Resource_Load(aFilename, @l_Size, aPackOnly);
   if l_Data = nil then
    System_Log('Can''t load sample (%s).', [aFilename])
   else
   begin
    l_Handle := BASS_SampleLoad(True, l_Data, 0, l_Size, 32, 0);
    if l_Handle = 0 then
     System_Log('Error loading sample (%s).', [aFilename])
    else
     Result := f_SndSamples.AddObject(aFilename, TObject(l_Handle));
    Resource_Free(l_Data);  
   end;
  end;
 end;
end;

const
 MOD_SWSYNTH = 7;

procedure MyCopyFile(aFrom, aTo: string);
var
 l_FSFrom, l_FSTo: TFileStream;
begin
 l_FSFrom := TFileStream.Create(aFrom, fmOpenRead);
 try
  l_FSTo := TFileStream.Create(aTo, fmCreate);
  try
   l_FSTo.CopyFrom(l_FSFrom, l_FSFrom.Size);
  finally
   l_FSTo.Free;
  end;
 finally
  l_FSFrom.Free;
 end;
end;

procedure Td2dCore.DoTextureCacheGarbageCollection;
var
 I: Integer;
 l_T: Id2dTexture;
begin
 if timeGetTime > f_LastTexGC + c_TexGCThreshold then
 begin
  for I := f_Textures.Count - 1 downto 0 do
  begin
   l_T := f_Textures.Interfaces[I] as Id2dTexture;
   if l_T.IsOrphan then
    f_Textures.Delete(I);
  end;
  f_LastTexGC := timeGetTime;
 end;
end;

procedure Td2dCore.ForceAllMusicStop;
var
 I: Integer;
begin
 if f_MusicFadeList <> nil then
 begin
  for I := f_MusicFadeList.Count - 1 downto 0 do
   BASS_ChannelStop(Td2dMusicHolder(f_MusicFadeList[I]).Chanel);
  while f_MusicFadeList.Count > 0 do
   Sleep(5);
 end;
end;

procedure Td2dCore.GfxSetViewMatrix;
begin
 if f_Windowed then
  D3DXMatrixIdentity(f_matView)
 else
  f_matView := f_matViewFS; 
end;

{$IFDEF D2DGIF}
function Td2dCore.GIFasBMPLoad(aFileName: string; aSize: PLongword; aPackOnly: Boolean = False): Pointer;
var
 l_Stream: TStream;
 l_GIF   : TGIFImage;
 l_Bmp   : TBitmap;
 l_Rect  : TRect;
 l_MemStream: Td2dMemoryStream;
begin
 Result := nil;
 aFileName := StringReplace(aFileName, '/', '\', [rfReplaceAll]);
 l_Stream := Resource_CreateStream(aFileName, aPackOnly);
 if l_Stream <> nil then
 begin
  l_GIF := TGIFImage.Create;
  try
   try
    l_GIF.LoadFromStream(l_Stream);
   finally
    FreeAndNil(l_Stream);
   end;
   l_Bmp := TBitmap.Create;
   try
    l_Bmp.Assign(l_GIF);
    l_Bmp.PixelFormat := pf32bit;
    with l_Bmp.Canvas.Brush do
    begin
     Color := $FF00FF;
     Style := bsSolid;
    end;
    l_Rect := Rect(0,0,l_GIF.Width, l_GIF.Height);
    l_Bmp.Canvas.FillRect(l_Rect);
    l_GIF.Images[0].Draw(l_Bmp.Canvas, l_Rect, True, False);
    l_MemStream := Td2dMemoryStream.Create;
    try
     l_Bmp.SaveToStream(l_MemStream);
     Result := l_MemStream.ExtractMemory(aSize);
    finally
     FreeAndNil(l_MemStream);
    end;
   finally
    FreeAndNil(l_Bmp);
   end;
  finally
   FreeAndNil(l_GIF);
  end;
 end;
end;
{$ENDIF}

procedure Td2dCore.Input_TouchMousePos;
begin
 //Input_SetMousePos(f_MouseX, f_MouseY);// - так нельзя, потому что перекидывает курсор в окно
 MakeEvent(INPUT_MOUSEMOVE, 0, 0, 0, Round(f_MouseX), Round(f_MouseY));
 //System_Log('TouchM: %d, %d', [Round(f_MouseX), Round(f_MouseY)]);
end;

function Td2dCore.Music_IsPlaying: Boolean;
var
 l_Str: array [0..100] of AnsiChar;
begin
 Result := False;
 if f_Music = mp_None then
  Exit;
 if f_Music = mp_MIDI then
 begin
  if mciSendString('status d2dmidi mode', l_Str, 100, 0) = 0 then
   Result := l_Str = 'playing';
 end
 else
  Result := BASS_ChannelIsActive(f_MusicHandle) = BASS_ACTIVE_PLAYING;
end;

procedure Td2dCore.Music_Pause;
begin
 if f_Music = mp_None then
  Exit;
 if f_Music = mp_MIDI then
 begin
  mciSendString('pause d2dmidi', nil, 0, 0);
 end
 else
  BASS_ChannelPause(f_MusicHandle);
end;

procedure Td2dCore.Music_Resume;
begin
 if f_Music = mp_None then
  Exit;
 if f_Music = mp_MIDI then
 begin
  mciSendString('play d2dmidi notify', nil, 0, f_WHandle);
 end
 else
  BASS_ChannelPlay(f_MusicHandle, False);
end;

procedure Td2dCore.Music_SetVolume(const aVolume: Byte; const aFadeTime: Longint = 0);
var
 l_MidiVolume: Longword;
begin
 case f_Music of
  mp_MIDI:
   begin
    l_MidiVolume := (aVolume shl 24) or (aVolume shl 8);
    midiOutSetVolume(f_MidiDevice, l_MidiVolume);
   end;
  mp_Stream, mp_Module:
   if aFadeTime = 0 then
    BASS_ChannelSetAttribute(f_MusicHandle, BASS_ATTRIB_VOL, aVolume/255)
   else
    BASS_ChannelSlideAttribute(f_MusicHandle, BASS_ATTRIB_VOL, aVolume/255, aFadeTime);
 end;
 f_MusicVolume := aVolume;
end;

function Td2dCore.pm_GetMusicFadeList: TObjectList;
begin
 if f_MusicFadeList = nil then
  f_MusicFadeList := TObjectList.Create(True);
 Result := f_MusicFadeList;
end;

procedure Td2dCore.pm_SetHideMouse(const Value: Boolean);
begin
 if f_HideMouse <> Value then
 begin
  f_HideMouse := Value;
  PostMessage(WHandle, WM_SETCURSOR, 0, HTCLIENT);
 end; 
end;

procedure Td2dCore.pm_SetSoundMute(const Value: Boolean);
var
 l_GVolume: Integer;
 l_MidiVolume: Longword;
begin
 if Value <> f_SoundMute then
 begin
  f_SoundMute := Value;
  if f_SoundMute then
   l_GVolume := 0
  else
   l_GVolume := 10000;
  BASS_SetConfig(BASS_CONFIG_GVOL_SAMPLE, l_GVolume);
  BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, l_GVolume);
  BASS_SetConfig(BASS_CONFIG_GVOL_MUSIC, l_GVolume);

  if Music = mp_MIDI then
  begin
   if f_SoundMute then
    midiOutSetVolume(f_MidiDevice, 0)
   else
   begin
    l_MidiVolume := (f_MusicVolume shl 24) or (f_MusicVolume shl 8);
    midiOutSetVolume(f_MidiDevice, l_MidiVolume);
   end; 
  end;
 end;
end;

function Td2dCore.Resource_FindInPacks(aWildCard: string): string;
var
 I : Integer;
 l_Idx: Integer;
 l_Pack: Id2dResourcePack;
begin
 Result := '';
 for I := 0 to f_AttachedPacks.Count-1 do
 begin
  l_Pack := f_AttachedPacks.Interfaces[I] as Id2dResourcePack;
  l_Idx := l_Pack.Find(aWildCard);
  if l_Idx >= 0 then
  begin
   Result := l_Pack.Name[l_Idx];
   Exit;
  end;
 end;
end;

procedure Td2dCore.Snd_StopAll;
var
 I: Integer;
begin
 if BASS_Handle <> 0 then
 begin
  for I := 0 to f_SndSamples.Count - 1 do
   BASS_SampleStop(HSAMPLE(f_SndSamples.Objects[I]));
 end
 else
  PlaySound(nil, 0, 0);
end;

procedure Td2dCore.Snd_StopSample(aFilename: string);
var
 l_Idx: Integer;
begin
 if BASS_Handle <> 0 then
 begin
  l_Idx := f_SndSamples.IndexOf(LowerCase(aFilename));
  if l_Idx >= 0 then
   BASS_SampleStop(HSAMPLE(f_SndSamples.Objects[l_Idx]));
 end;
end;

procedure Td2dCore.SoundSystemStart;
var
 l_DevInfo: BASS_DEVICEINFO;
 I: Integer;
 l_MidiOutCaps : TMidiOutCaps;
 l_BassDLL: string;
begin
 // find MIDI device so we can manipulate volume
 f_MidiDevice := -1;
 for I := 0 to midiOutGetNumDevs - 1 do
 begin
   MidiOutGetDevCaps(I, @l_MidiOutCaps, SizeOf(l_MidiOutCaps));
   if (l_MidiOutCaps.wTechnology = MOD_SWSYNTH) then
   begin
     f_MidiDevice := I;
     Break;
   end;
 end;
 f_MusicVolume := 128;
 // Init BASS sound system
 if BASS_Handle <> 0 then // already started
  Exit;
 l_BassDLL := ExtractFilePath(ParamStr(0)) + 'bass.dll';
 if FileExists(l_BassDLL) then
 begin
  if Load_BASSDLL(l_BassDLL) then
  begin
   if HiWord(BASS_GetVersion) = BASSVERSION then
   begin
    if BASS_Init(-1, f_SoundSampleRate, 0, f_WHandle, nil) then
    begin
     BASS_GetDeviceInfo(1, l_DevInfo);
     System_Log(#13#10'Sound Device: %s', [l_DevInfo.name]);
     System_Log('Sample rate : %d'#13#10, [f_SoundSampleRate]);
    end
    else
    begin
     System_Log(#13#10'BASS init failed, so expect simplified (WAV and MIDI) sound'#13#10);
     Unload_BASSDLL;
    end;
   end
   else
   begin
    System_Log(#13#10'Incorrect BASS.DLL version'#13#10);
    Unload_BASSDLL;
   end;
  end
  else
   System_Log(#13#10'Error loading BASS.DLL, so expect simplified (WAV and MIDI) sound'#13#10);
 end
 else
  System_Log(#13#10'BASS.DLL not found, so expect simplified (WAV and MIDI) sound'#13#10);
end;

procedure Td2dCore.SoundSystemStop;
begin
 Music_Stop;
 if BASS_Handle <> 0 then
 begin
  Snd_FreeAll;
  BASS_Stop;
  BASS_Free;
  Unload_BASSDLL;
 end;
end;

function Td2dCore.System_Start: Boolean;
var
 l_Str: string;                                    
 l_WndClass: TWndClass;
 l_Width, l_Height: Integer;
 l_Icon: HICON;
begin
 Result := False;
 if FileExists(f_LogFileName) then
  DeleteFile(f_LogFileName);
 DateTimeToString(l_Str, 'dddddd, tt', Now);
 System_Log('%s', [l_Str]);
 System_Log('Delphi 2D engine starting...');
 System_Log('Engine version: %x.%x'#13#10, [D2DVersion shr 8, D2DVersion and $FF]);
 f_Instance := SysInit.HInstance;//GetModuleHandle(nil);
 // Register application window class
 with l_WndClass do
 begin
  style := CS_DBLCLKS or CS_OWNDC or CS_HREDRAW or CS_VREDRAW;
  lpfnWndProc	:= @WindowProc;
  cbClsExtra		:= 0;
  cbWndExtra		:= 0;
  hInstance		:= f_Instance;
  hCursor		:= LoadCursor(0, IDC_ARROW);
  hbrBackground	:= GetStockObject(BLACK_BRUSH);
  lpszMenuName	:= nil;
  lpszClassName	:= cWinClassName;
  hIcon := LoadIcon(0, IDI_APPLICATION);
 end;
 if Windows.RegisterClass(l_WndClass) = 0 then
 begin
  System_Log('Can''t register window class');
  Exit;
 end;

 l_Width  := f_ScreenWidth + GetSystemMetrics(SM_CXFIXEDFRAME)*2;
 l_Height := f_ScreenHeight + GetSystemMetrics(SM_CYFIXEDFRAME)*2 + GetSystemMetrics(SM_CYCAPTION);

 f_RectW.Left :=(GetSystemMetrics(SM_CXSCREEN)-l_Width) div 2;
 f_RectW.Top := (GetSystemMetrics(SM_CYSCREEN)-l_Height) div 2;
 f_RectW.Right := f_RectW.Left + l_Width;
 f_RectW.Bottom := f_RectW.Top + l_Height;
 f_WStyleW := WS_POPUP or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE{ or WS_THICKFRAME};

 f_RectFS.Left := 0;
 f_RectFS.Top := 0;   
 f_RectFS.Right := GetSystemMetrics(SM_CXSCREEN);
 f_RectFS.Bottom := GetSystemMetrics(SM_CYSCREEN);
 f_WStyleFS := WS_POPUP or WS_VISIBLE;

 if f_Windowed then
  f_WHandle := CreateWindowEx(0, cWinClassName, PChar(f_WindowTitle), Cardinal(f_WStyleW),
				f_RectW.left, f_RectW.top, f_RectW.right - f_RectW.left, f_RectW.bottom - f_RectW.top,
				0, 0, f_Instance, nil)
 else
  f_WHandle := CreateWindowEx(WS_EX_TOPMOST, cWinClassName, PChar(f_WindowTitle), Cardinal(f_WStyleFS),	0, 0, 0, 0,
				0, 0, f_Instance, nil);

 if f_WHandle = 0 then
 begin
  System_Log('Can''t create window...');
  Exit;
 end;

 ShowWindow(f_WHandle, SW_SHOW);               
 l_Icon := LoadIcon(MainInstance, 'MAINICON');
 SetClassLong(f_WHandle, GCL_HICON, l_Icon);
 SendMessage(f_WHandle, WM_SETICON, 1, l_Icon);
 timeBeginPeriod(1);
 Randomize;

 if not GfxInit then
 begin
  System_Shutdown;
  Exit;
 end;

 if f_SoundOn then
  SoundSystemStart;

 System_Log('Init done.'#13#10);

 f_FPS := 0;
 f_FPSCount := 0;
 f_Time := 0.0;
 f_FixedDelta := 0;

 f_Time0 := timeGetTime;
 f_Time0FPS := f_Time0;

 Result := True;
end;

procedure Td2dCore.System_Log(const aFormat: string; Args: array of TVarRec);
begin
 System_Log(Format(aFormat, Args));
end;

procedure Td2dCore.System_Log(const aString: string);
var
 l_FS: TFileStream;
const
 cCRLF: PChar = #13#10; 
begin
 try
  if FileExists(f_LogFileName) then
   l_FS := TFileStream.Create(f_LogFileName, fmOpenReadWrite or fmShareDenyNone)
  else
   l_FS := TFileStream.Create(f_LogFileName, fmCreate or fmShareDenyNone);
  try
   l_FS.Seek(0, soFromEnd);
   if aString <> '' then
    l_FS.Write((@aString[1])^, Length(aString));
   l_FS.Write(cCRLF^, 2); 
  finally
   FreeAndNil(l_FS);
  end;
 except
  // if log can't be written it should not brake the program
 end;
end;

procedure Td2dCore.System_Run;
var
 l_Msg: TMsg;
 l_Point: TPoint;
 l_Rect : TRect;
 l_Finish: Boolean;
begin
 if f_WHandle = 0 then
 begin
  System_Log('Engine was not started!');
  Exit;
 end;

 if not Assigned(f_OnFrame) then
 begin
  System_Log('Frame function is not assigned!');
  Exit;
 end;

 // MAIN LOOP
 l_Finish := False;
 while not l_Finish do
 begin
  // dispatch messages
  if PeekMessage(l_Msg, 0, 0, 0, PM_REMOVE) then
  begin
   if l_Msg.message = WM_QUIT then
    l_Finish := True;
   DispatchMessage(l_Msg);
   Continue;
  end;

  GetCursorPos(l_Point);
  GetClientRect(f_WHandle, l_Rect);
  MapWindowPoints(f_WHandle, 0, l_Rect, 2);
  f_MouseOver := f_MouseCaptured or (PtInRect(l_Rect, l_Point) and (WindowFromPoint(l_Point) = f_WHandle));
  if f_Active or f_DontSuspend then
  begin
   repeat
    f_DeltaTicks := timeGetTime - f_Time0;
    if f_DeltaTicks <= f_FixedDelta then
     Sleep(1);
   until f_DeltaTicks > f_FixedDelta;
   //if f_DeltaTicks >= f_FixedDelta then
   begin
    f_DeltaTime := f_DeltaTicks / 1000.0;

    // if delay was too big, count it as if where was no delay
    // (return from suspended state for instance)
    if f_DeltaTime > 0.2 then
					if f_FixedDelta > 0 then
      f_DeltaTime := f_FixedDelta / 1000.0
					else
      f_DeltaTime := 0.01;

				f_Time := f_Time + f_DeltaTime;

				f_Time0 := timeGetTime;

				if(f_Time0 - f_Time0FPS < 1000) then
     Inc(f_FPSCount)
				else
    begin
     f_FPS := f_FPSCount;
     f_FPSCount := 0;
     f_Time0FPS := f_Time0;
    end;

    f_OnFrame(f_DeltaTime, l_Finish);
    if Assigned(f_OnRender) then
     f_OnRender();
    // ClearQueue; - not really clear why clear all input events on render, but it gave some bugs so I disabled it
    {
				if (not f_Windowed) and (f_FixedFPS = D2D_FPS_VSYNC) then
     Sleep(1);
    }
   end;
   {
			else
    if (f_FixedDelta > 0) and (f_DeltaTicks+3 < f_FixedDelta) then
     Sleep(1);
   }
  end
  else
   Sleep(1);
  CheckSynchronize;
 end;
end;

procedure Td2dCore.System_Shutdown;
begin
 System_Log('Finishing...');
 timeEndPeriod(1);
 ClearQueue;
 GfxDone;
 if f_SoundOn then
  SoundSystemStop;

 if f_WHandle <> 0 then
 begin
  DestroyWindow(f_WHandle);
  f_WHandle := 0;
 end;
 if f_Instance <> 0 then
  Windows.UnregisterClass(cWinClassName, f_Instance);

 System_Log('The End.');
end;

procedure Td2dCore.System_SoundPause;
begin
 if BASS_Handle <> 0 then
  BASS_Pause;
 if f_Music = mp_MIDI then
  mciSendString('pause d2dmidi', nil, 0, 0);
end;

procedure Td2dCore.System_SoundResume;
begin
 if BASS_Handle <> 0 then
  BASS_Start;
 if f_Music = mp_MIDI then
  mciSendString('play d2dmidi notify', nil, 0, f_WHandle);
end;

function Td2dCore.Target_Create(aWidth, aHeight: Integer; aZBuffer: Boolean = False): Pd2dRenderTarget;
var
 l_Target: Pd2dRenderTarget;
 l_Desc  : D3DSURFACE_DESC;
begin
 Result := nil;
 New(l_Target);
 l_Target.Tex := nil;
 l_Target.Depth := nil;

 if Failed(D3DXCreateTexture(f_D3DDevice, aWidth, aHeight, 1, D3DUSAGE_RENDERTARGET, f_D3DPP.BackBufferFormat,
     D3DPOOL_DEFAULT, l_Target.Tex)) then
 begin
  System_Log('Can''t create render target texture');
  Dispose(l_Target);
  Exit;
 end;

 l_Target.Tex.GetLevelDesc(0, l_Desc);
 l_Target.Width := l_Desc.Width;
 l_Target.Height := l_Desc.Height;

 if aZBuffer then
 begin
  if Failed(f_D3DDevice.CreateDepthStencilSurface(aWidth, aHeight, D3DFMT_D16, D3DMULTISAMPLE_NONE,
       l_Target.Depth)) then
  begin
   System_Log('Can''t create render target depth buffer');
   Dispose(l_Target);
   Exit;
  end;    
 end;

 f_Targets.Add(l_Target);
 Result := l_Target;
end;

procedure Td2dCore.Target_Free(aTarget: Pd2dRenderTarget);
var
 l_Idx: Integer;
begin
 l_Idx := f_Targets.IndexOf(aTarget);
 if l_Idx >= 0 then
 begin
  Dispose(Pd2dRenderTarget(f_Targets.Items[l_Idx]));
  f_Targets.Delete(l_Idx);
 end;
end;

procedure Td2dCore.Texture_ClearCache;
begin
 f_Textures.Clear;
end;

function Td2dCore.Texture_Create(const aWidth, aHeight: Integer): Id2dTexture;
var
 l_Res: IDirect3DTexture8;
begin
 Result := nil;
 if Failed(D3DXCreateTexture(f_D3DDevice, aWidth, aHeight, 1, 0,
           D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, l_Res)) then
  System_Log('Can''t create texture')
 else
  Result := Td2dTexture.Make(l_Res); 
end;

function Td2dCore.Texture_GetWidth(aTex: IDirect3DTexture8): Integer;
var
 l_Desc: D3DSURFACE_DESC;
begin
 if Failed(aTex.GetLevelDesc(0, l_Desc)) then
  Result := 0
 else
  Result := l_Desc.Width;
end;

function Td2dCore.Texture_GetHeight(aTex: IDirect3DTexture8): Integer;
var
 l_Desc: D3DSURFACE_DESC;
begin
 if Failed(aTex.GetLevelDesc(0, l_Desc)) then
  Result := 0
 else
  Result := l_Desc.Height;
end;

function Td2dCore.Texture_Load(const aFileName: string; aPackOnly: Boolean = False; aUseCache: Boolean = True; const
    aMipMap: Boolean = False; aPicSize: PPoint = nil): Id2dTexture;
var
 l_Data: Pointer;
 l_Size: Longword;
 l_Idx: Integer;
 l_ImgInfo: TD3DXImageInfo;
 l_PicSize: TPoint;
 l_TH: Id2dTexture;
 {$IFDEF D2DGIF}
 l_IsGIF : Boolean;
 {$ENDIF}
begin
 Result := nil;
 if aUseCache then // check out in the cache
 begin
  l_Idx := f_Textures.IndexOf(LowerCase(aFileName));
  if l_Idx <> -1 then
  begin
   l_TH := f_Textures.Interfaces[l_Idx] as Id2dTexture;
   Result := l_TH;
   if aPicSize <> nil then
    aPicSize^ := Point(l_TH.SrcPicWidth, l_TH.SrcPicHeight);
   Exit; // found texture in the cache
  end;
 end;
 {$IFDEF D2DGIF}
 l_IsGIF := LowerCase(ExtractFileExt(aFileName)) = '.gif';
 if l_IsGIF then
  l_Data := GIFasBMPLoad(aFilename, @l_Size, aPackOnly)
 else
 {$ENDIF}
  l_Data := Resource_Load(aFileName, @l_Size, aPackOnly);
 if l_Data = nil then
 begin
  System_Log('Can''t load texture (%s)', [aFilename]);
  Exit;
 end;
 try
  D3DXGetImageInfoFromFileInMemory(l_Data^, l_Size, l_ImgInfo);
  l_PicSize.X := l_ImgInfo.Width;
  l_PicSize.Y := l_ImgInfo.Height;
  if aPicSize <> nil then
   aPicSize^ := l_PicSize;
  {$IFDEF D2DGIF}
  if l_IsGIF then
   Result := Texture_CreatePrim(l_Data, l_Size, aMipMap, $FFFF00FF)
  else
  {$ENDIF}
   Result := Texture_CreatePrim(l_Data, l_Size, aMipMap);
  if Result = nil then
   System_Log('Can''t create texture (%s)', [aFileName])
  else
  begin
   Result.SrcPicWidth  := l_PicSize.X;
   Result.SrcPicHeight := l_PicSize.Y;
   if aUseCache then
   begin
    l_Idx := f_Textures.Add(LowerCase(aFileName));
    f_Textures.Interfaces[l_Idx] := Result;
    DoTextureCacheGarbageCollection;
   end;
  end;
 finally
  FreeMem(l_Data);
 end;
end;

function Td2dCore.Texture_FromMemory(const aData: Pointer; const aSize: LongWord; const aMipMap: Boolean = false):
    Id2dTexture;
begin
 Result := Texture_CreatePrim(aData, aSize, aMipMap);
 if Result = nil then
  System_Log('Can''t create texture from memory');
end;

function Td2dCore.Texture_GetHeight(aTex: Id2dTexture): Integer;
begin
 if aTex <> nil then
  Result := Texture_GetHeight(aTex.DirectXTexture)
 else
  Result := 0;
end;

function Td2dCore.Texture_GetWidth(aTex: Id2dTexture): Integer;
begin
 if aTex <> nil then
  Result := Texture_GetWidth(aTex.DirectXTexture)
 else
  Result := 0;
end;

procedure Td2dCore.Texture_RemoveFromCache(aFileName: string);
var
 l_Idx: Integer;
begin
 l_Idx := f_Textures.IndexOf(LowerCase(aFileName));
 if l_Idx <> -1 then
  f_Textures.Delete(l_Idx);
end;

procedure Td2dCore.Texture_RemoveFromCache(const aTexture: Id2dTexture);
var
 I: Integer;
 l_Tex: Id2dTexture;
begin
 for I := 0 to f_Textures.Count-1 do
 begin
  l_Tex := f_Textures.Interfaces[I] as Id2dTexture;
  if l_Tex = aTexture then
  begin
   f_Textures.Delete(I);
   Exit;
  end;
 end;
end;

constructor Td2dMusicHolder.Create(aChanel: Longword; aData: Pointer = nil);
begin
 inherited Create;
 Chanel := aChanel;
 Data := aData;
end;

destructor Td2dMusicHolder.Destroy;
begin
 if Data <> nil then
  FreeMem(Data);
 inherited;
end;

end.
