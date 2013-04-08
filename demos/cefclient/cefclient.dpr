{$IFDEF FPC}
   {$MODE DELPHI}{$H+}
   {$APPTYPE GUI}
{$ENDIF}
{$I cef.inc}

program cefclient;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Classes,
  Windows,
  Messages,
  SysUtils,
  ceflib,
  ceffilescheme in '..\filescheme\ceffilescheme.pas';

type
  TCustomClient = class(TCefClientOwn)
  private
    FLifeSpan: ICefLifeSpanHandler;
    FLoad: ICefLoadHandler;
    FDisplay: ICefDisplayHandler;
  protected
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
    function GetLoadHandler: ICefLoadHandler; override;
    function GetDisplayHandler: ICefDisplayHandler; override;
  public
    constructor Create; override;
  end;

  TCustomLifeSpan = class(TCefLifeSpanHandlerOwn)
  protected
    procedure OnAfterCreated(const browser: ICefBrowser); override;
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring; var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean; override;
    procedure OnBeforeClose(const browser: ICefBrowser); override;
    function DoClose(const browser: ICefBrowser): Boolean; override;
  end;

  TCustomLoad = class(TCefLoadHandlerOwn)
  protected
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); override;
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame;
      httpStatusCode: Integer); override;
  end;

  TCustomDisplay = class(TCefDisplayHandlerOwn)
  protected
    procedure OnAddressChange(const browser: ICefBrowser;
      const frame: ICefFrame; const url: ustring); override;
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring); override;
  end;

type
{$IFDEF FPC}
  TWindowProc = LongInt;
{$ELSE}
  TWindowProc = Pointer;
  WNDPROC = Pointer;
{$ENDIF}

var
  Window : HWND;
  handl: ICefClient = nil;
  brows: ICefBrowser = nil;
  browserId: Integer = 0;
  navigateto: ustring = 'http://www.google.com';

  backWnd, forwardWnd, reloadWnd, stopWnd, editWnd: HWND;
  editWndOldProc: TWindowProc;
  isLoading, canGoBack, canGoForward: Boolean;

const
  MAX_LOADSTRING = 100;
  MAX_URL_LENGTH = 255;
  BUTTON_WIDTH = 72;
  URLBAR_HEIGHT = 24;

  IDC_NAV_BACK = 200;
  IDC_NAV_FORWARD = 201;
  IDC_NAV_RELOAD = 202;
  IDC_NAV_STOP = 203;

function CefWndProc(Wnd: HWND; message: UINT; wParam: Integer; lParam: Integer): Integer; stdcall;
var
  ps: PAINTSTRUCT;
  info: TCefWindowInfo;
  rect: TRect;
  hdwp: THandle;
  x: Integer;
  strPtr: array[0..MAX_URL_LENGTH-1] of WideChar;
  strLen, urloffset: Integer;
  setting: TCefBrowserSettings;
begin
  if Wnd = editWnd then
    case message of
    WM_CHAR:
      if (wParam = VK_RETURN) then
      begin
        // When the user hits the enter key load the URL
        FillChar(strPtr, SizeOf(strPtr), 0);
        PDWORD(@strPtr)^ := MAX_URL_LENGTH;
        strLen := SendMessageW(Wnd, EM_GETLINE, 0, Integer(@strPtr));
        if (strLen > 0) then
        begin
          strPtr[strLen] := #0;
          brows.MainFrame.LoadUrl(strPtr);
        end;
        Result := 0;
      end else
        Result := CallWindowProc(WNDPROC(editWndOldProc), Wnd, message, wParam, lParam);
    else
      Result := CallWindowProc(WNDPROC(editWndOldProc), Wnd, message, wParam, lParam);
    end else
    case message of
      WM_PAINT:
        begin
          BeginPaint(Wnd, ps);
          EndPaint(Wnd, ps);
          result := 0;
        end;
      WM_CREATE:
        begin
          handl := TCustomClient.Create;
          x := 0;
          GetClientRect(Wnd, rect);

          backWnd := CreateWindowW('BUTTON', 'Back',
                                 WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
                                 or WS_DISABLED, x, 0, BUTTON_WIDTH, URLBAR_HEIGHT,
                                 Wnd, IDC_NAV_BACK, HInstance, nil);
          Inc(x, BUTTON_WIDTH);

          forwardWnd := CreateWindowW('BUTTON', 'Forward',
                                    WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
                                    or WS_DISABLED, x, 0, BUTTON_WIDTH,
                                    URLBAR_HEIGHT, Wnd, IDC_NAV_FORWARD,
                                    HInstance, nil);
          Inc(x, BUTTON_WIDTH);

          reloadWnd := CreateWindowW('BUTTON', 'Reload',
                                   WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
                                   or WS_DISABLED, x, 0, BUTTON_WIDTH,
                                   URLBAR_HEIGHT, Wnd, IDC_NAV_RELOAD,
                                   HInstance, nil);
          Inc(x, BUTTON_WIDTH);

          stopWnd := CreateWindowW('BUTTON', 'Stop',
                                 WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON
                                 or WS_DISABLED, x, 0, BUTTON_WIDTH, URLBAR_HEIGHT,
                                 Wnd, IDC_NAV_STOP, HInstance, nil);
          Inc(x, BUTTON_WIDTH);

          editWnd := CreateWindowW('EDIT', nil,
                                 WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or
                                 ES_AUTOVSCROLL or ES_AUTOHSCROLL or WS_DISABLED,
                                 x, 0, rect.right - BUTTON_WIDTH * 4,
                                 URLBAR_HEIGHT, Wnd, 0, HInstance, nil);

          // Assign the edit window's WNDPROC to this function so that we can
          // capture the enter key
          editWndOldProc := TWindowProc(GetWindowLong(editWnd, GWL_WNDPROC));
          SetWindowLong(editWnd, GWL_WNDPROC, LongInt(@CefWndProc));

          FillChar(info, SizeOf(info), 0);
          Inc(rect.top, URLBAR_HEIGHT);
          info.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_TABSTOP;
          info.parent_window := Wnd;
          info.x := rect.left;
          info.y := rect.top;
          info.Width := rect.right - rect.left;
          info.Height := rect.bottom - rect.top;
          FillChar(setting, sizeof(setting), 0);
          setting.size := SizeOf(setting);
          CefBrowserHostCreate(@info, handl, navigateto, @setting);
          isLoading := False;
          canGoBack := False;
          canGoForward := False;
          SetTimer(Wnd, 1, 100, nil);
          result := 0;
        end;
      WM_TIMER:
        begin
          // Update the status of child windows
          EnableWindow(editWnd, True);
          EnableWindow(backWnd, canGoBack);
          EnableWindow(forwardWnd, canGoForward);
          EnableWindow(reloadWnd, not isLoading);
          EnableWindow(stopWnd, isLoading);
          Result := 0;
        end;
      WM_COMMAND:
        case LOWORD(wParam) of
          IDC_NAV_BACK:
            begin
              brows.GoBack;
              Result := 0;
            end;
          IDC_NAV_FORWARD:
            begin
              brows.GoForward;
              Result := 0;
            end;
          IDC_NAV_RELOAD:
            begin
              brows.Reload;
              Result := 0;
            end;
          IDC_NAV_STOP:
            begin
              brows.StopLoad;
              Result := 0;
            end;
        else
          result := DefWindowProc(Wnd, message, wParam, lParam);
        end;
      WM_DESTROY:
        begin
          brows := nil;
          PostQuitMessage(0);
          result := DefWindowProc(Wnd, message, wParam, lParam);
        end;
      WM_SETFOCUS:
        begin
          if brows <> nil then
            PostMessage(brows.Host.WindowHandle, WM_SETFOCUS, wParam, 0);
          Result := 0;
        end;
      WM_SIZE:
        begin
          if(brows <> nil) then
          begin
            // Resize the browser window and address bar to match the new frame
            // window size
            GetClientRect(Wnd, rect);
            Inc(rect.top, URLBAR_HEIGHT);
            urloffset := rect.left + BUTTON_WIDTH * 4;
            hdwp := BeginDeferWindowPos(1);
         		hdwp := DeferWindowPos(hdwp, editWnd, 0, urloffset, 0, rect.right - urloffset, URLBAR_HEIGHT, SWP_NOZORDER);
            hdwp := DeferWindowPos(hdwp, brows.Host.WindowHandle, 0, rect.left, rect.top,
              rect.right - rect.left, rect.bottom - rect.top, SWP_NOZORDER);
            EndDeferWindowPos(hdwp);
          end;
          result := DefWindowProc(Wnd, message, wParam, lParam);
        end;
      WM_CLOSE:
        begin
          if brows <> nil then
            brows.Host.ParentWindowWillClose;
          result := DefWindowProc(Wnd, message, wParam, lParam);
        end
     else
       result := DefWindowProc(Wnd, message, wParam, lParam);
     end;
end;


{ TCustomClient }

constructor TCustomClient.Create;
begin
  inherited;
  FLifeSpan := TCustomLifeSpan.Create;
  FLoad := TCustomLoad.Create;
  FDisplay := TCustomDisplay.Create;
end;

function TCustomClient.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := FDisplay;
end;

function TCustomClient.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpan;
end;

function TCustomClient.GetLoadHandler: ICefLoadHandler;
begin
  Result := FLoad;
end;

{ TCustomLifeSpan }

function TCustomLifeSpan.DoClose(const browser: ICefBrowser): Boolean;
begin
  if browser.Identifier = browserId then
  begin
    PostMessage(Window, WM_CLOSE, 0, 0);
    Result := True;
  end else
    Result := False;
end;

procedure TCustomLifeSpan.OnAfterCreated(const browser: ICefBrowser);
begin
  if not browser.IsPopup then
  begin
    // get the first browser
    brows := browser;
    browserId := brows.Identifier;
  end;
end;

procedure TCustomLifeSpan.OnBeforeClose(const browser: ICefBrowser);
begin
  if browser.Identifier = browserId then
    brows := nil;
end;

function TCustomLifeSpan.OnBeforePopup(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean): Boolean;
begin
  if targetUrl = 'about:blank' then
    result := False else
    begin
      Result := True;
      brows.MainFrame.LoadUrl(targetUrl);
    end;
end;

{ TCustomLoad }

procedure TCustomLoad.OnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if browser.Identifier = browserId then
    isLoading := False;
end;

procedure TCustomLoad.OnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if browser.Identifier = browserId then
  begin
    isLoading := True;
    canGoBack := browser.CanGoBack;
    canGoForward := browser.CanGoForward;
  end;
end;

{ TCustomDisplay }

procedure TCustomDisplay.OnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  if (browser.Identifier = browserId) and frame.IsMain then
    SetWindowTextW(editWnd, PWideChar(url));
end;

procedure TCustomDisplay.OnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin
  if browser.Identifier = browserId then
    SetWindowTextW(Window, PWideChar(title));
end;

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme('local', True, True, False);
end;

var
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  Msg      : TMsg;
{$ENDIF}
  wndClass : TWndClass;
begin
  //CefCache := 'cache';
  //navigateto := 'client://test/';
  //navigateto := 'local://c:\';

  CefOnRegisterCustomSchemes := RegisterSchemes;

  // multi process
  CefSingleProcess := False;
  if not CefLoadLibDefault then Exit;

  CefRegisterSchemeHandlerFactory('local', '', False, TFileScheme);

  try
    wndClass.style         := CS_HREDRAW or CS_VREDRAW;
    wndClass.lpfnWndProc   := @CefWndProc;
    wndClass.cbClsExtra    := 0;
    wndClass.cbWndExtra    := 0;
    wndClass.hInstance     := hInstance;
    wndClass.hIcon         := LoadIcon(0, IDI_APPLICATION);
    wndClass.hCursor       := LoadCursor(0, IDC_ARROW);
    wndClass.hbrBackground := 0;
    wndClass.lpszMenuName  := nil;
    wndClass.lpszClassName := 'chromium';

    RegisterClass(wndClass);

    Window := CreateWindow(
      'chromium',             // window class name
      'Chromium browser',     // window caption
      WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,    // window style
      Integer(CW_USEDEFAULT), // initial x position
      Integer(CW_USEDEFAULT), // initial y position
      Integer(CW_USEDEFAULT), // initial x size
      Integer(CW_USEDEFAULT), // initial y size
      0,                      // parent window handle
      0,                      // window menu handle
      hInstance,              // program instance handle
      nil);                   // creation parameters

    ShowWindow(Window, SW_SHOW);
    UpdateWindow(Window);

{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    CefRunMessageLoop;
{$ELSE}
    while(GetMessageW(msg, 0, 0, 0)) do
    begin
      TranslateMessage(msg);
      DispatchMessageW(msg);
    end;
{$ENDIF}
  finally
    handl := nil;
  end;
end.
