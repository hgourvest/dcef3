(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit cefvcl;

{$I cef.inc}

interface
uses
  Windows, Messages, Classes,
  cefgui, ceflib,
{$ifdef DELPHI16_UP}
  Vcl.Controls, Vcl.Graphics
{$else}
  Controls, Graphics
{$endif};

type
  TCustomChromium = class(TWinControl, IChromiumEvents)
  private
    FHandler: ICefClient;
    FBrowser: ICefBrowser;
    FBrowserId: Integer;
    FDefaultUrl: ustring;

    FOnProcessMessageReceived: TOnProcessMessageReceived;
    FOnLoadStart: TOnLoadStart;
    FOnLoadEnd: TOnLoadEnd;
    FOnLoadError: TOnLoadError;
    FOnRenderProcessTerminated: TOnRenderProcessTerminated;
    FOnPluginCrashed: TOnPluginCrashed;
    FOnTakeFocus: TOnTakeFocus;
    FOnSetFocus: TOnSetFocus;
    FOnGotFocus: TOnGotFocus;
    FOnBeforeContextMenu: TOnBeforeContextMenu;
    FOnContextMenuCommand: TOnContextMenuCommand;
    FOnContextMenuDismissed: TOnContextMenuDismissed;
    FOnPreKeyEvent: TOnPreKeyEvent;
    FOnKeyEvent: TOnKeyEvent;
    FOnLoadingStateChange: TOnLoadingStateChange;
    FOnAddressChange: TOnAddressChange;
    FOnTitleChange: TOnTitleChange;
    FOnTooltip: TOnTooltip;
    FOnStatusMessage: TOnStatusMessage;
    FOnConsoleMessage: TOnConsoleMessage;
    FOnBeforeDownload: TOnBeforeDownload;
    FOnDownloadUpdated: TOnDownloadUpdated;
    FOnRequestGeolocationPermission: TOnRequestGeolocationPermission;
    FOnCancelGeolocationPermission: TOnCancelGeolocationPermission;
    FOnJsdialog: TOnJsdialog;
    FOnBeforeUnloadDialog: TOnBeforeUnloadDialog;
    FOnResetDialogState: TOnResetDialogState;
    FOnBeforePopup: TOnBeforePopup;
    FOnAfterCreated: TOnAfterCreated;
    FOnBeforeClose: TOnBeforeClose;
    FOnRunModal: TOnRunModal;
    FOnClose: TOnClose;
    FOnBeforeResourceLoad: TOnBeforeResourceLoad;
    FOnGetResourceHandler: TOnGetResourceHandler;
    FOnResourceRedirect: TOnResourceRedirect;
    FOnGetAuthCredentials: TOnGetAuthCredentials;
    FOnGetCookieManager: TOnGetCookieManager;
    FOnProtocolExecution: TOnProtocolExecution;

    FOptions: TChromiumOptions;
    FUserStyleSheetLocation: ustring;
    FDefaultEncoding: ustring;
    FFontOptions: TChromiumFontOptions;

    procedure GetSettings(var settings: TCefBrowserSettings);
    procedure CreateBrowser;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure Loaded; override;
    procedure Resize; override;

    function doOnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;

    procedure doOnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); virtual;
    procedure doOnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); virtual;
    procedure doOnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); virtual;
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;

    procedure doOnTakeFocus(const browser: ICefBrowser; next: Boolean); virtual;
    function doOnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean; virtual;
    procedure doOnGotFocus(const browser: ICefBrowser); virtual;

    procedure doOnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel); virtual;
    function doOnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean; virtual;
    procedure doOnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame); virtual;

    function doOnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean; virtual;
    function doOnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean; virtual;

    procedure doOnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean); virtual;
    procedure doOnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring); virtual;
    procedure doOnTitleChange(const browser: ICefBrowser; const title: ustring); virtual;
    function doOnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; virtual;
    procedure doOnStatusMessage(const browser: ICefBrowser; const value: ustring; statusType: TCefHandlerStatusType); virtual;
    function doOnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean; virtual;

    procedure doOnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback); virtual;
    procedure doOnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback); virtual;

    procedure doOnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback); virtual;
    procedure doOnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer); virtual;

    function doOnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean; virtual;
    function doOnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean; virtual;
    procedure doOnResetDialogState(const browser: ICefBrowser); virtual;

    function doOnBeforePopup(const parentBrowser: ICefBrowser;
       var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
       var url: ustring; var client: ICefClient;
       var settings: TCefBrowserSettings): Boolean; virtual;
    procedure doOnAfterCreated(const browser: ICefBrowser); virtual;
    procedure doOnBeforeClose(const browser: ICefBrowser); virtual;
    function doOnRunModal(const browser: ICefBrowser): Boolean; virtual;
    function doOnClose(const browser: ICefBrowser): Boolean; virtual;

    function doOnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): Boolean; virtual;
    function doOnGetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; virtual;
    procedure doOnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const oldUrl: ustring; var newUrl: ustring); virtual;
    function doOnGetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; virtual;
    function doOnGetCookieManager(const browser: ICefBrowser; const mainUrl: ustring): ICefCookieManager; virtual;
    procedure doOnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean); virtual;

    property OnProcessMessageReceived: TOnProcessMessageReceived read FOnProcessMessageReceived write FOnProcessMessageReceived;
    property OnLoadStart: TOnLoadStart read FOnLoadStart write FOnLoadStart;
    property OnLoadEnd: TOnLoadEnd read FOnLoadEnd write FOnLoadEnd;
    property OnLoadError: TOnLoadError read FOnLoadError write FOnLoadError;
    property OnRenderProcessTerminated: TOnRenderProcessTerminated read FOnRenderProcessTerminated write FOnRenderProcessTerminated;
    property OnPluginCrashed: TOnPluginCrashed read FOnPluginCrashed write FOnPluginCrashed;
    property OnTakeFocus: TOnTakeFocus read FOnTakeFocus write FOnTakeFocus;
    property OnSetFocus: TOnSetFocus read FOnSetFocus write FOnSetFocus;
    property OnGotFocus: TOnGotFocus read FOnGotFocus write FOnGotFocus;
    property OnBeforeContextMenu: TOnBeforeContextMenu read FOnBeforeContextMenu write FOnBeforeContextMenu;
    property OnContextMenuCommand: TOnContextMenuCommand read FOnContextMenuCommand write FOnContextMenuCommand;
    property OnContextMenuDismissed: TOnContextMenuDismissed read FOnContextMenuDismissed write FOnContextMenuDismissed;
    property OnPreKeyEvent: TOnPreKeyEvent read FOnPreKeyEvent write FOnPreKeyEvent;
    property OnKeyEvent: TOnKeyEvent read FOnKeyEvent write FOnKeyEvent;
    property OnLoadingStateChange: TOnLoadingStateChange read FOnLoadingStateChange write FOnLoadingStateChange;
    property OnAddressChange: TOnAddressChange read FOnAddressChange write FOnAddressChange;
    property OnTitleChange: TOnTitleChange read FOnTitleChange write FOnTitleChange;
    property OnTooltip: TOnTooltip read FOnTooltip write FOnTooltip;
    property OnStatusMessage: TOnStatusMessage read FOnStatusMessage write FOnStatusMessage;
    property OnConsoleMessage: TOnConsoleMessage read FOnConsoleMessage write FOnConsoleMessage;
    property OnBeforeDownload: TOnBeforeDownload read FOnBeforeDownload write FOnBeforeDownload;
    property OnDownloadUpdated: TOnDownloadUpdated read FOnDownloadUpdated write FOnDownloadUpdated;
    property OnRequestGeolocationPermission: TOnRequestGeolocationPermission read FOnRequestGeolocationPermission write FOnRequestGeolocationPermission;
    property OnCancelGeolocationPermission: TOnCancelGeolocationPermission read FOnCancelGeolocationPermission write FOnCancelGeolocationPermission;
    property OnJsdialog: TOnJsdialog read FOnJsdialog write FOnJsdialog;
    property OnBeforeUnloadDialog: TOnBeforeUnloadDialog read FOnBeforeUnloadDialog write FOnBeforeUnloadDialog;
    property OnResetDialogState: TOnResetDialogState read FOnResetDialogState write FOnResetDialogState;
    property OnBeforePopup: TOnBeforePopup read FOnBeforePopup write FOnBeforePopup;
    property OnAfterCreated: TOnAfterCreated read FOnAfterCreated write FOnAfterCreated;
    property OnBeforeClose: TOnBeforeClose read FOnBeforeClose write FOnBeforeClose;
    property OnRunModal: TOnRunModal read FOnRunModal write FOnRunModal;
    property OnClose: TOnClose read FOnClose write FOnClose;
    property OnBeforeResourceLoad: TOnBeforeResourceLoad read FOnBeforeResourceLoad write FOnBeforeResourceLoad;
    property OnGetResourceHandler: TOnGetResourceHandler read FOnGetResourceHandler write FOnGetResourceHandler;
    property OnResourceRedirect: TOnResourceRedirect read FOnResourceRedirect write FOnResourceRedirect;
    property OnGetAuthCredentials: TOnGetAuthCredentials read FOnGetAuthCredentials write FOnGetAuthCredentials;
    property OnGetCookieManager: TOnGetCookieManager read FOnGetCookieManager write FOnGetCookieManager;
    property OnProtocolExecution: TOnProtocolExecution read FOnProtocolExecution write FOnProtocolExecution;

    property DefaultUrl: ustring read FDefaultUrl write FDefaultUrl;
    property Options: TChromiumOptions read FOptions write FOptions;
    property FontOptions: TChromiumFontOptions read FFontOptions;
    property DefaultEncoding: ustring read FDefaultEncoding write FDefaultEncoding;
    property UserStyleSheetLocation: ustring read FUserStyleSheetLocation write FUserStyleSheetLocation;
    property BrowserId: Integer read FBrowserId;
    property Browser: ICefBrowser read FBrowser;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load(const url: ustring);
    procedure ReCreateBrowser(const url: string);
  end;

  TChromium = class(TCustomChromium)
  public
    property BrowserId;
    property Browser;
  published
    property Color;
    property Constraints;
    property TabStop;
    property Align;
    property Anchors;
    property DefaultUrl;
    property TabOrder;
    property Visible;

    property OnProcessMessageReceived;
    property OnLoadStart;
    property OnLoadEnd;
    property OnLoadError;
    property OnRenderProcessTerminated;
    property OnPluginCrashed;
    property OnTakeFocus;
    property OnSetFocus;
    property OnGotFocus;
    property OnBeforeContextMenu;
    property OnContextMenuCommand;
    property OnContextMenuDismissed;
    property OnPreKeyEvent;
    property OnKeyEvent;
    property OnLoadingStateChange;
    property OnAddressChange;
    property OnTitleChange;
    property OnTooltip;
    property OnStatusMessage;
    property OnConsoleMessage;
    property OnBeforeDownload;
    property OnDownloadUpdated;
    property OnRequestGeolocationPermission;
    property OnCancelGeolocationPermission;
    property OnJsdialog;
    property OnBeforeUnloadDialog;
    property OnResetDialogState;
    property OnBeforePopup;
    property OnAfterCreated;
    property OnBeforeClose;
    property OnRunModal;
    property OnClose;
    property OnBeforeResourceLoad;
    property OnGetResourceHandler;
    property OnResourceRedirect;
    property OnGetAuthCredentials;
    property OnGetCookieManager;
    property OnProtocolExecution;

    property Options;
    property FontOptions;
    property DefaultEncoding;
    property UserStyleSheetLocation;
  end;

implementation
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  uses
{$IFDEF DELPHI16_UP}
  Vcl.AppEvnts;
{$ELSE}
  AppEvnts;
{$ENDIF}

var
  CefInstances: Integer = 0;
  CefTimer: UINT = 0;
{$ENDIF}

type
  TVCLClientHandler = class(TCustomClientHandler)
  public
    constructor Create(const crm: IChromiumEvents); override;
    destructor Destroy; override;
  end;

{ TVCLClientHandler }

{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
var
  looping: Boolean = False;

procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: Pointer; dwTime: DWORD); stdcall;
begin
  if looping then Exit;
  if CefInstances > 0 then
  begin
    looping := True;
    try
      CefDoMessageLoopWork;
    finally
      looping := False;
    end;
  end;
end;
{$ENDIF}

constructor TVCLClientHandler.Create(const crm: IChromiumEvents);
begin
  inherited Create(crm);
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  if CefInstances = 0 then
    CefTimer := SetTimer(0, 0, 10, @TimerProc);
  InterlockedIncrement(CefInstances);
{$ENDIF}
end;

destructor TVCLClientHandler.Destroy;
begin
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  InterlockedDecrement(CefInstances);
  if CefInstances = 0 then
    KillTimer(0, CefTimer);
{$ENDIF}
  inherited;
end;

{ TCustomChromium }

constructor TCustomChromium.Create(AOwner: TComponent);
begin
  inherited;
  FDefaultUrl := 'about:blank';

  if not (csDesigning in ComponentState) then
    FHandler := TVCLClientHandler.Create(Self);

  FOptions := TChromiumOptions.Create;
  FFontOptions := TChromiumFontOptions.Create;

  FUserStyleSheetLocation := '';
  FDefaultEncoding := '';
  FBrowserId := 0;
  FBrowser := nil;
end;

procedure TCustomChromium.CreateBrowser;
var
  info: TCefWindowInfo;
  settings: TCefBrowserSettings;
  rect: TRect;
begin
  if not (csDesigning in ComponentState) then
  begin
    FillChar(info, SizeOf(info), 0);
    rect := GetClientRect;
    info.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_TABSTOP;
    info.parent_window := Handle;
    info.x := rect.left;
    info.y := rect.top;
    info.Width := rect.right - rect.left;
    info.Height := rect.bottom - rect.top;
    info.ex_style := 0;
    FillChar(settings, SizeOf(TCefBrowserSettings), 0);
    settings.size := SizeOf(TCefBrowserSettings);
    GetSettings(settings);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    CefBrowserCreate(@info, FHandler.Wrap, FDefaultUrl, @settings);
{$ELSE}
    FBrowser := CefBrowserHostCreateSync(@info, FHandler, '', @settings);
    FBrowserId := FBrowser.Identifier;
{$ENDIF}
  end;
end;

procedure TCustomChromium.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  CreateBrowser;
end;

destructor TCustomChromium.Destroy;
begin
  if FBrowser <> nil then
    FBrowser.Host.ParentWindowWillClose;
  if FHandler <> nil then
    (FHandler as ICefClientHandler).Disconnect;
  FHandler := nil;
  FBrowser := nil;
  FFontOptions.Free;
  FOptions.Free;
  inherited;
end;

procedure TCustomChromium.GetSettings(var settings: TCefBrowserSettings);
begin
  Assert(settings.size >= SizeOf(settings));
  settings.standard_font_family := CefString(FFontOptions.StandardFontFamily);
  settings.fixed_font_family := CefString(FFontOptions.FixedFontFamily);
  settings.serif_font_family := CefString(FFontOptions.SerifFontFamily);
  settings.sans_serif_font_family := CefString(FFontOptions.SansSerifFontFamily);
  settings.cursive_font_family := CefString(FFontOptions.CursiveFontFamily);
  settings.fantasy_font_family := CefString(FFontOptions.FantasyFontFamily);
  settings.default_font_size := FFontOptions.DefaultFontSize;
  settings.default_fixed_font_size := FFontOptions.DefaultFixedFontSize;
  settings.minimum_font_size := FFontOptions.MinimumFontSize;
  settings.minimum_logical_font_size := FFontOptions.MinimumLogicalFontSize;
  settings.remote_fonts_disabled := FFontOptions.RemoteFontsDisabled;
  settings.default_encoding := CefString(DefaultEncoding);
  settings.user_style_sheet_location := CefString(UserStyleSheetLocation);

  settings.encoding_detector_enabled := FOptions.EncodingDetectorEnabled;
  settings.javascript_disabled := FOptions.JavascriptDisabled;
  settings.javascript_open_windows_disallowed := FOptions.JavascriptOpenWindowsDisallowed;
  settings.javascript_close_windows_disallowed := FOptions.JavascriptCloseWindowsDisallowed;
  settings.javascript_access_clipboard_disallowed := FOptions.JavascriptAccessClipboardDisallowed;
  settings.dom_paste_disabled := FOptions.DomPasteDisabled;
  settings.caret_browsing_enabled := FOptions.CaretBrowsingEnabled;
  settings.java_disabled := FOptions.JavaDisabled;
  settings.plugins_disabled := FOptions.PluginsDisabled;
  settings.universal_access_from_file_urls_allowed := FOptions.UniversalAccessFromFileUrlsAllowed;
  settings.file_access_from_file_urls_allowed := FOptions.FileAccessFromFileUrlsAllowed;
  settings.web_security_disabled := FOptions.WebSecurityDisabled;
  settings.xss_auditor_enabled := FOptions.XssAuditorEnabled;
  settings.image_load_disabled := FOptions.ImageLoadDisabled;
  settings.shrink_standalone_images_to_fit := FOptions.ShrinkStandaloneImagesToFit;
  settings.site_specific_quirks_disabled := FOptions.SiteSpecificQuirksDisabled;
  settings.text_area_resize_disabled := FOptions.TextAreaResizeDisabled;
  settings.page_cache_disabled := FOptions.PageCacheDisabled;
  settings.tab_to_links_disabled := FOptions.TabToLinksDisabled;
  settings.hyperlink_auditing_disabled := FOptions.HyperlinkAuditingDisabled;
  settings.user_style_sheet_enabled := FOptions.UserStyleSheetEnabled;
  settings.author_and_user_styles_disabled := FOptions.AuthorAndUserStylesDisabled;
  settings.local_storage_disabled := FOptions.LocalStorageDisabled;
  settings.databases_disabled := FOptions.DatabasesDisabled;
  settings.application_cache_disabled := FOptions.ApplicationCacheDisabled;
  settings.webgl_disabled := FOptions.WebglDisabled;
  settings.accelerated_compositing_disabled := FOptions.AcceleratedCompositingDisabled;
  settings.accelerated_layers_disabled := FOptions.AcceleratedLayersDisabled;
  settings.accelerated_2d_canvas_disabled := FOptions.Accelerated2dCanvasDisabled;
  settings.accelerated_painting_enabled := FOptions.AcceleratedPaintingEnabled;
  settings.accelerated_filters_enabled := FOptions.AcceleratedFiltersEnabled;
  settings.accelerated_plugins_disabled := FOptions.AcceleratedPluginsDisabled;
  settings.developer_tools_disabled := FOptions.DeveloperToolsDisabled;
  settings.fullscreen_enabled := FOptions.FullscreenEnabled;
end;

procedure TCustomChromium.Load(const url: ustring);
var
  frm: ICefFrame;
begin
  HandleNeeded;
  if FBrowser <> nil then
  begin
    frm := FBrowser.MainFrame;
    if frm <> nil then
      frm.LoadUrl(url);
  end;
end;

procedure TCustomChromium.Loaded;
begin
  inherited;
  Load(FDefaultUrl);
end;

procedure TCustomChromium.ReCreateBrowser(const url: string);
begin
  if (FBrowser <> nil) {$IFNDEF FMX}and (FBrowserId <> 0){$ENDIF} then
  begin
    FBrowser.Host.ParentWindowWillClose;
    SendMessage(FBrowser.Host.WindowHandle, WM_CLOSE, 0, 0);
    SendMessage(FBrowser.Host.WindowHandle, WM_DESTROY, 0, 0);
    FBrowserId := 0;
    FBrowser := nil;

    CreateBrowser;
    Load(url);
  end;
end;

procedure TCustomChromium.Resize;
var
  brws: ICefBrowser;
  rect: TRect;
  hdwp: THandle;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    brws := FBrowser;
    if (brws <> nil) and (brws.Host.WindowHandle <> INVALID_HANDLE_VALUE) then
    begin
      rect := GetClientRect;
      hdwp := BeginDeferWindowPos(1);
      try
        hdwp := DeferWindowPos(hdwp, brws.Host.WindowHandle, 0,
          rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top,
          SWP_NOZORDER);
      finally
        EndDeferWindowPos(hdwp);
      end;
    end;
  end;
end;

procedure TCustomChromium.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        if (FBrowser <> nil) and (FBrowser.Host.WindowHandle <> 0) then
          PostMessage(FBrowser.Host.WindowHandle, WM_SETFOCUS, Message.WParam, 0);
        inherited WndProc(Message);
      end;
    WM_ERASEBKGND:
      if (csDesigning in ComponentState) or (FBrowser = nil) then
        inherited WndProc(Message);
    CM_WANTSPECIALKEY:
      if not (TWMKey(Message).CharCode in [VK_LEFT .. VK_DOWN]) then
        Message.Result := 1 else
        inherited WndProc(Message);
    WM_GETDLGCODE:
      Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
  else
    inherited WndProc(Message);
  end;
end;

function TCustomChromium.doOnClose(const browser: ICefBrowser): Boolean;
begin
  if Assigned(FOnClose) then
    FOnClose(Self, browser, Result) else
    Result := False;
end;

procedure TCustomChromium.doOnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  if Assigned(FOnAddressChange) then
    FOnAddressChange(Self, browser, frame, url);
end;

procedure TCustomChromium.doOnAfterCreated(const browser: ICefBrowser);
begin
  if Assigned(FOnAfterCreated) then
    FOnAfterCreated(Self, browser);
end;

procedure TCustomChromium.doOnBeforeClose(const browser: ICefBrowser);
begin
  if Assigned(FOnBeforeClose) then
    FOnBeforeClose(Self, browser);
end;

procedure TCustomChromium.doOnBeforeContextMenu(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  const model: ICefMenuModel);
begin
  if Assigned(FOnBeforeContextMenu) then
    FOnBeforeContextMenu(Self, browser, frame, params, model);
end;

procedure TCustomChromium.doOnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin
  if Assigned(FOnBeforeDownload) then
    FOnBeforeDownload(Self, browser, downloadItem, suggestedName, callback);
end;

function TCustomChromium.doOnBeforePopup(const parentBrowser: ICefBrowser;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var url: ustring; var client: ICefClient;
  var settings: TCefBrowserSettings): Boolean;
begin
  if Assigned(FOnBeforePopup) then
    FOnBeforePopup(Self, parentBrowser, popupFeatures,
      windowInfo, url, client, settings, Result) else
    Result := False;
end;

function TCustomChromium.doOnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): Boolean;
begin
  if Assigned(FOnBeforeResourceLoad) then
    FOnBeforeResourceLoad(Self, browser, frame, request, Result) else
    Result := False;
end;

function TCustomChromium.doOnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean;
  const callback: ICefJsDialogCallback): Boolean;
begin
  if Assigned(FOnBeforeUnloadDialog) then
    FOnBeforeUnloadDialog(Self, browser, messageText, isReload, callback, Result) else
  Result := False;
end;

procedure TCustomChromium.doOnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  if Assigned(FOnCancelGeolocationPermission) then
    FOnCancelGeolocationPermission(Self, browser, requestingUrl, requestId);
end;

function TCustomChromium.doOnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, browser, message, source, line, Result) else
    Result := False;
end;

function TCustomChromium.doOnContextMenuCommand(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  commandId: Integer; eventFlags: TCefEventFlags): Boolean;
begin
  if Assigned(FOnContextMenuCommand) then
    FOnContextMenuCommand(Self, browser, frame, params, commandId, eventFlags, Result) else
    Result := False;
end;

procedure TCustomChromium.doOnContextMenuDismissed(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnContextMenuDismissed) then
    FOnContextMenuDismissed(Self, browser, frame);
end;

procedure TCustomChromium.doOnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if Assigned(FOnDownloadUpdated) then
    FOnDownloadUpdated(Self, browser, downloadItem, callback);
end;

function TCustomChromium.doOnGetAuthCredentials(const browser: ICefBrowser;
  const frame: ICefFrame; isProxy: Boolean; const host: ustring; port: Integer;
  const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  if Assigned(FOnGetAuthCredentials) then
    FOnGetAuthCredentials(Self, browser, frame, isProxy, host,
      port, realm, scheme, callback, Result) else
    Result := False;
end;

function TCustomChromium.doOnGetCookieManager(const browser: ICefBrowser;
  const mainUrl: ustring): ICefCookieManager;
begin
  if Assigned(FOnGetCookieManager) then
    FOnGetCookieManager(Self, browser, mainUrl, Result) else
    Result := nil;
end;

function TCustomChromium.doOnGetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  if Assigned(FOnGetResourceHandler) then
    FOnGetResourceHandler(Self, browser, frame, request, Result) else
    Result := nil;
end;

procedure TCustomChromium.doOnGotFocus(const browser: ICefBrowser);
begin
  if Assigned(FOnGotFocus) then
    FOnGotFocus(Self, browser)
end;

function TCustomChromium.doOnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  if Assigned(FOnJsdialog) then
    FOnJsdialog(Self, browser, originUrl, acceptLang, dialogType,
      messageText, defaultPromptText, callback, suppressMessage, Result) else
    Result := False;
end;

function TCustomChromium.doOnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin
  if Assigned(FOnKeyEvent) then
    FOnKeyEvent(Self, browser, event, osEvent, Result) else
    Result := False;
end;

procedure TCustomChromium.doOnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if Assigned(FOnLoadEnd) then
    FOnLoadEnd(Self, browser, frame, httpStatusCode);
end;

procedure TCustomChromium.doOnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText,
  failedUrl: ustring);
begin
  if Assigned(FOnLoadError) then
    FOnLoadError(Self, browser, frame, errorCode, errorText, failedUrl);
end;

procedure TCustomChromium.doOnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin
  if Assigned(FOnLoadingStateChange) then
    FOnLoadingStateChange(Self, browser, isLoading, canGoBack, canGoForward);
end;

procedure TCustomChromium.doOnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnLoadStart) then
    FOnLoadStart(Self, browser, frame);
end;

procedure TCustomChromium.doOnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  if Assigned(FOnPluginCrashed) then
    FOnPluginCrashed(Self, browser, pluginPath);
end;

function TCustomChromium.doOnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  if Assigned(FOnPreKeyEvent) then
    FOnPreKeyEvent(Self, browser, event, osEvent, isKeyboardShortcut, Result) else
    Result := False;
end;

function TCustomChromium.doOnProcessMessageReceived(const browser: ICefBrowser;
  sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  if Assigned(FOnProcessMessageReceived) then
    FOnProcessMessageReceived(Self, browser, sourceProcess, message, Result) else
    Result := False;
end;

procedure TCustomChromium.doOnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  if Assigned(FOnProtocolExecution) then
    FOnProtocolExecution(Self, browser, url, allowOsExecution);
end;

procedure TCustomChromium.doOnRenderProcessTerminated(const browser: ICefBrowser;
  status: TCefTerminationStatus);
begin
  if Assigned(FOnRenderProcessTerminated) then
    FOnRenderProcessTerminated(Self, browser, status);
end;

procedure TCustomChromium.doOnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback);
begin
  if Assigned(FOnRequestGeolocationPermission) then
    FOnRequestGeolocationPermission(Self, browser, requestingUrl, requestId, callback);
end;

procedure TCustomChromium.doOnResetDialogState(const browser: ICefBrowser);
begin
  if Assigned(FOnResetDialogState) then
    FOnResetDialogState(Self, browser);
end;

procedure TCustomChromium.doOnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const oldUrl: ustring; var newUrl: ustring);
begin
  if Assigned(FOnResourceRedirect) then
    FOnResourceRedirect(Self, browser, frame, oldUrl, newUrl);
end;

function TCustomChromium.doOnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, browser, source, Result) else
    Result := False;
end;

procedure TCustomChromium.doOnStatusMessage(const browser: ICefBrowser;
  const value: ustring; statusType: TCefHandlerStatusType);
begin
  if Assigned(FOnStatusMessage) then
    FOnStatusMessage(Self, browser, value, statusType);
end;

procedure TCustomChromium.doOnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin
  if Assigned(FOnTakeFocus) then
    FOnTakeFocus(Self, browser, next);
end;

procedure TCustomChromium.doOnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin
  if Assigned(FOnTitleChange) then
    FOnTitleChange(Self, browser, title);
end;

function TCustomChromium.doOnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  if Assigned(FOnTooltip) then
    FOnTooltip(Self, browser, text, Result) else
    Result := False;
end;

function TCustomChromium.doOnRunModal(const browser: ICefBrowser): Boolean;
begin
  if Assigned(FOnRunModal) then
    FOnRunModal(Self, browser, Result) else
    Result := False;
end;

end.
