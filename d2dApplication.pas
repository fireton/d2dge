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
unit d2dApplication;

interface
uses
 Classes,
 d2dTypes;

type
 Td2dScene = class;

 Td2dSceneClass = class of Td2dScene;

 Td2dApplication = class
 private
  f_CurrentScene: string;
  f_CurrentSceneObj: Td2dScene;
  f_Finished: Boolean;
  f_Scenes: TStringList;
  procedure pm_SetCurrentScene(const Value: string);
 protected
  procedure FrameFunc(aDelta: Single; var theFinish: Boolean);
  function Init: Boolean; virtual;
  procedure LoadGlobalResources; virtual;
  procedure RenderFunc;
  procedure UnloadGlobalResources; virtual;
 public
  constructor Create(const aResWidth, aResHeight: Word; const aWindowed: Boolean = True; aTitle: string = '');
  destructor Destroy; override;
  procedure AddScene(aKey: string; aScene: Td2dScene);
  procedure Run;
  property CurrentScene: string read f_CurrentScene write pm_SetCurrentScene;
  property Finished: Boolean read f_Finished write f_Finished;
 end;

 Td2dScene = class
 private
  f_Application: Td2dApplication;
  f_Loaded: Boolean;
  f_Child : Td2dScene;
  f_Parent: Td2dScene;
  f_RunningAsChild: Boolean;
  function pm_GetHasRunningChild: Boolean;
 protected
  procedure DoLoad; virtual;
  procedure DoUnload; virtual;
  procedure Frame(aDelta: Single);
  procedure DoFrame(aDelta: Single); virtual;
  procedure ProcessEvent(var theEvent: Td2dInputEvent);
  procedure DoProcessEvent(var theEvent: Td2dInputEvent); virtual;
  procedure Render;
  procedure DoRender; virtual; abstract;
  procedure StartChild(const aScene: Td2dScene);
  procedure StopChild; // остановить выполнение дочерней сцены
  procedure StopAsChild;
  procedure BeforeStoppingChild; virtual;
  property HasRunningChild: Boolean read pm_GetHasRunningChild;
 public
  constructor Create(aApplication: Td2dApplication);
  destructor Destroy; override;
  procedure Load;
  procedure Unload;
  property Application: Td2dApplication read f_Application;
 end;

implementation
uses
 SysUtils,
 {$IFDEF TRACE_STACK}
 JclDebug,
 {$ENDIF}
 d2dCore;

constructor Td2dApplication.Create(const aResWidth, aResHeight: Word;
                                   const aWindowed: Boolean = True;
                                         aTitle: string = '');
begin
 inherited Create;
 f_Scenes := TStringList.Create;
 f_Scenes.Sorted := True;
 f_Scenes.CaseSensitive := False;
 f_Scenes.Duplicates := dupError;
 D2DInit(aResWidth, aResHeight, aWindowed, aTitle);
 f_Finished := False;
 gD2DE.OnFrame := FrameFunc;
 gD2DE.OnRender := RenderFunc;
end;

destructor Td2dApplication.Destroy;
begin
 f_Scenes.Free;
 D2DDone;
 inherited;
end;

procedure Td2dApplication.AddScene(aKey: string; aScene: Td2dScene);
begin
 f_Scenes.AddObject(aKey, aScene);
end;

procedure Td2dApplication.FrameFunc(aDelta: Single; var theFinish: Boolean);
var
 l_Ev: Td2dInputEvent;
begin
 if f_CurrentSceneObj <> nil then
 begin
  while gD2DE.Input_GetEvent(l_Ev) do
  begin
   f_CurrentSceneObj.ProcessEvent(l_Ev);
  end;
  f_CurrentSceneObj.Frame(aDelta);
 end;
 theFinish := f_Finished; 
end;

function Td2dApplication.Init: Boolean;
begin
 Result := True;
 // here we supposed to register scenes and initialize all needed data
end;

procedure Td2dApplication.LoadGlobalResources;
begin
 // here we load application-wide resources
end;

procedure Td2dApplication.pm_SetCurrentScene(const Value: string);
var
 l_Idx: Integer;
begin
 if (f_CurrentSceneObj <> nil) and (gD2DE.D3DDevice <> nil) then
  f_CurrentSceneObj.Unload;

 l_Idx := f_Scenes.IndexOf(Value);
 if l_Idx >= 0 then
 begin
  f_CurrentSceneObj := Td2dScene(f_Scenes.Objects[l_Idx]);
  if gD2DE.D3DDevice <> nil then
   f_CurrentSceneObj.Load;
  f_CurrentScene := Value;
 end
 else
 begin
  gD2DE.System_Log('Can''t find scene "%s". Terminating application.', [Value]);
  f_Finished := True;
 end;
end;

procedure Td2dApplication.RenderFunc;
begin
 gD2DE.Gfx_BeginScene;
 try
  if f_CurrentSceneObj <> nil then
   f_CurrentSceneObj.Render
  else
   gD2DE.Gfx_Clear(0);
 finally
  gD2DE.Gfx_EndScene;
 end;
end;

procedure Td2dApplication.Run;
var
 I: Integer;
begin
 if not Init then
  Exit;
 if gD2DE.System_Start then
 begin
  try
   if f_Scenes.Count > 0 then
   begin
    LoadGlobalResources;
    try
     if f_CurrentSceneObj = nil then
      CurrentScene := f_Scenes[0]
     else
      f_CurrentSceneObj.Load; 
     try
      gD2DE.System_Run;
     except
      on E: Exception do
      begin
       gD2DE.System_Log('ОШИБКА: '+E.Message);
       {$IFDEF TRACE_STACK}
       l_List := TStringList.Create;
       try
        JclLastExceptStackListToStrings(l_List);
        gD2DE.System_Log(l_List.Text);
       finally
        FreeAndNil(l_List);
       end;
       {$ENDIF}
      end;
     end;
    finally
     for I := 0 to f_Scenes.Count-1 do
      f_Scenes.Objects[I].Free;
     f_Scenes.Clear;
     UnloadGlobalResources;
    end;
   end
   else
    gD2DE.System_Log('No scenes defined!');
  finally
   gD2DE.System_Shutdown;
  end;
 end;
end;

procedure Td2dApplication.UnloadGlobalResources;
begin
 // here we unload application-wide resources
end;

constructor Td2dScene.Create(aApplication: Td2dApplication);
begin
 inherited Create;
 f_Application := aApplication;
end;

destructor Td2dScene.Destroy;
begin
 StopChild;
 Unload;
 inherited;
end;

procedure Td2dScene.BeforeStoppingChild;
begin
 // does nothing in base class
end;

procedure Td2dScene.DoLoad;
begin
 // does nothing in base class
end;

procedure Td2dScene.DoUnload;
begin
 // does nothing in base class
end;

procedure Td2dScene.DoFrame(aDelta: Single);
begin
 // does nothing in base class
end;

procedure Td2dScene.Load;
begin
 if not f_Loaded then
 begin
  DoLoad;
  f_Loaded := True;
 end;
end;

procedure Td2dScene.DoProcessEvent(var theEvent: Td2dInputEvent);
begin
 // does nothing in base class
end;

procedure Td2dScene.Frame(aDelta: Single);
begin
 if HasRunningChild then
  f_Child.Frame(aDelta)
 else
  DoFrame(aDelta);
end;

function Td2dScene.pm_GetHasRunningChild: Boolean;
begin
 Result := f_Child <> nil;
end;

procedure Td2dScene.ProcessEvent(var theEvent: Td2dInputEvent);
begin
 if HasRunningChild then
 begin
  f_Child.ProcessEvent(theEvent);
  if not f_Child.f_RunningAsChild then
   StopChild;
 end
 else
  DoProcessEvent(theEvent);
end;

procedure Td2dScene.Render;
begin
 DoRender;
 if HasRunningChild then
  f_Child.Render;
end;

procedure Td2dScene.StartChild(const aScene: Td2dScene);
begin
 StopChild;
 f_Child := aScene;
 f_Child.f_Parent := Self;
 f_Child.f_RunningAsChild := True;
 f_Child.Load;
end;

procedure Td2dScene.StopAsChild;
begin
 if f_Parent <> nil then
  f_RunningAsChild := False;
end;

procedure Td2dScene.StopChild;
begin
 if HasRunningChild then
 begin
  BeforeStoppingChild;
  f_Child.Unload;
  f_Child.f_Parent := nil;
  f_Child := nil;
 end;
end;

procedure Td2dScene.Unload;
begin
 if f_Loaded then
 begin
  DoUnload;
  f_Loaded := False;
 end;
end;

end.