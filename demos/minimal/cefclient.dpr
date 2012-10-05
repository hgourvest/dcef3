program cefclient;

uses
  Windows, Messages, ceflib;

type
  TCustomClient = class(TCefClientOwn)
  private
    FLifeSpan: ICefLifeSpanHandler;
  protected
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
  public
    constructor Create; override;
  end;

  TCustomLifeSpan = class(TCefLifeSpanHandlerOwn)
  protected
    procedure OnAfterCreated(const browser: ICefBrowser); override;
    procedure OnBeforeClose(const browser: ICefBrowser); override;
  end;

type
  TWindowProc = Pointer;
  WNDPROC = Pointer;

var
  Window: HWND;
  handl: ICefClient = nil;
  brows: ICefBrowser = nil;
  browserId: Integer = 0;
  navigateto: ustring = 'http://www.google.com';

function CefWndProc(Wnd: HWND; message: UINT; wParam: Integer; lParam: Integer): Integer; stdcall;
var
  ps: PAINTSTRUCT;
  info: TCefWindowInfo;
  rect: TRect;
  hdwp: THandle;
  setting: TCefBrowserSettings;
begin
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
        GetClientRect(Wnd, rect);
        FillChar(info, SizeOf(info), 0);
        info.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_TABSTOP;
        info.parent_window := Wnd;
        info.x := rect.left;
        info.y := rect.top;
        info.Width := rect.right - rect.left;
        info.Height := rect.bottom - rect.top;
        FillChar(setting, sizeof(setting), 0);
        setting.size := SizeOf(setting);
        CefBrowserHostCreateSync(@info, handl, navigateto, @setting);
        SetTimer(Wnd, 1, 100, nil);
        result := 0;
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
          hdwp := BeginDeferWindowPos(1);
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
end;

function TCustomClient.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpan;
end;

{ TCustomLifeSpan }

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

var
  wndClass : TWndClass;
begin
  // multi process
  CefSingleProcess := False;
  if not CefLoadLibDefault then Exit;
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
    wndClass.lpszClassName := 'cefapp';

    RegisterClass(wndClass);

    Window := CreateWindow(
      'cefapp',
      'CEF Application',
      WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,
      Integer(CW_USEDEFAULT),
      Integer(CW_USEDEFAULT),
      Integer(CW_USEDEFAULT),
      Integer(CW_USEDEFAULT),
      0,
      0,
      HInstance,
      nil);

    ShowWindow(Window, SW_SHOW);
    UpdateWindow(Window);
    CefRunMessageLoop;
  finally
    handl := nil;
  end;
end.
