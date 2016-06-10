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

unit ceffmx;

{$I cef.inc}

interface
uses
  SysUtils, System.UITypes, Classes,
{$ifdef MSWINDOWS}
  Messages, Windows,
{$endif}
{$ifdef DELPHI17_UP}
  FMX.Graphics,
{$endif}
  FMX.Types, FMX.Platform, FMX.Controls, System.Types, ceflib, cefgui;

type
  TCustomChromiumFMX = class(TControl, IChromiumEvents)
  private
    FHandler: ICefClient;
    FBrowser: ICefBrowser;
    FDefaultUrl: ustring;

    FOnProcessMessageReceived: TOnProcessMessageReceived;
    FOnLoadStart: TOnLoadStart;
    FOnLoadEnd: TOnLoadEnd;
    FOnLoadError: TOnLoadError;

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
    FOnFavIconUrlChange: TOnFavIconUrlChange;
    FOnFullScreenModeChange: TOnFullScreenModeChange;
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
    FOnDialogClosed: TOnDialogClosed;
    FOnBeforePopup: TOnBeforePopup;
    FOnAfterCreated: TOnAfterCreated;
    FOnBeforeClose: TOnBeforeClose;
    FOnRunModal: TOnRunModal;
    FOnClose: TOnClose;

    FOnBeforeBrowse: TOnBeforeBrowse;
    FOnOpenUrlFromTab: TOnOpenUrlFromTab;
    FOnBeforeResourceLoad: TOnBeforeResourceLoad;
    FOnGetResourceHandler: TOnGetResourceHandler;
    FOnResourceRedirect: TOnResourceRedirect;
    FOnResourceResponse: TOnResourceResponse;
    FOnGetAuthCredentials: TOnGetAuthCredentials;
    FOnQuotaRequest: TOnQuotaRequest;
    FOnProtocolExecution: TOnProtocolExecution;
    FOnCertificateError: TOnCertificateError;
    FOnPluginCrashed: TOnPluginCrashed;
    FOnRenderViewReady: TOnRenderViewReady;
    FOnRenderProcessTerminated: TOnRenderProcessTerminated;

    FOnFileDialog: TOnFileDialog;
    FOnDragEnter: TOnDragEnter;
    FOnDraggableRegionsChanged: TOnDraggableRegionsChanged;
    FOnFindResult: TOnFindResult;

    FOptions: TChromiumOptions;
    FDefaultEncoding: ustring;
    FFontOptions: TChromiumFontOptions;

    FBuffer: TBitmap;
{$ifdef DELPHI17_UP}
    FMouseWheelService: IFMXMouseService;
{$endif}
    procedure GetSettings(var settings: TCefBrowserSettings);
    procedure CreateBrowser;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure DialogKey(var Key: Word; Shift: TShiftState); override;

    procedure Loaded; override;
    procedure Resize; override;
    procedure DoEnter; override;
    procedure DoExit; override;

    function doOnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;

    procedure doOnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); virtual;
    procedure doOnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); virtual;
    procedure doOnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); virtual;

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
    procedure doOnFaviconUrlChange(const browser: ICefBrowser; iconUrls: TStrings); virtual;
    procedure doOnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean); virtual;
    function doOnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; virtual;
    procedure doOnStatusMessage(const browser: ICefBrowser; const value: ustring); virtual;
    function doOnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean; virtual;

    procedure doOnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback); virtual;
    procedure doOnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback); virtual;

    function doOnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback): Boolean; virtual;
    procedure doOnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer); virtual;

    function doOnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean; virtual;
    function doOnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean; virtual;
    procedure doOnResetDialogState(const browser: ICefBrowser); virtual;

    procedure doOnDialogClosed(const browser: ICefBrowser);

    function doOnBeforePopup(const browser: ICefBrowser;
      const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean; virtual;
    procedure doOnAfterCreated(const browser: ICefBrowser); virtual;
    procedure doOnBeforeClose(const browser: ICefBrowser); virtual;
    function doOnRunModal(const browser: ICefBrowser): Boolean; virtual;
    function doOnClose(const browser: ICefBrowser): Boolean; virtual;

    function doOnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean; virtual;
    function doOnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean; virtual;
    function doOnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue; virtual;
    function doOnGetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; virtual;
    procedure doOnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring); virtual;
    function doOnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean; virtual;
    function doOnGetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; virtual;
    function doOnQuotaRequest(const browser: ICefBrowser; const originUrl: ustring;
      newSize: Int64; const callback: ICefRequestCallback): Boolean; virtual;
    procedure doOnProtocolExecution(const browser: ICefBrowser;
      const url: ustring; out allowOsExecution: Boolean); virtual;
    function doOnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean; virtual;
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;
    procedure doOnRenderViewReady(const browser: ICefBrowser); virtual;
    function doOnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title, defaultFilePath: ustring; acceptFilters: TStrings;
      selectedAcceptFilter: Integer; const callback: ICefFileDialogCallback): Boolean;

    function doOnGetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function doOnGetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function doOnGetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean;
    function doOnGetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean;
    procedure doOnPopupShow(const browser: ICefBrowser; show: Boolean);
    procedure doOnPopupSize(const browser: ICefBrowser; const rect: PCefRect);
    procedure doOnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer);
    procedure doOnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      cursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo);
    function doOnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean;
    procedure doOnUpdateDragCursor(const browser: ICefBrowser; operation: TCefDragOperation);
    procedure doOnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double);

    function doOnDragEnter(const browser: ICefBrowser; const dragData: ICefDragData;
      mask: TCefDragOperations): Boolean;
    procedure doOnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray);

    procedure doOnFindResult(const browser: ICefBrowser; identifier, count: Integer;
      const selectionRect: PCefRect; activeMatchOrdinal: Integer; finalUpdate: Boolean);

    property OnProcessMessageReceived: TOnProcessMessageReceived read FOnProcessMessageReceived write FOnProcessMessageReceived;
    property OnLoadStart: TOnLoadStart read FOnLoadStart write FOnLoadStart;
    property OnLoadEnd: TOnLoadEnd read FOnLoadEnd write FOnLoadEnd;
    property OnLoadError: TOnLoadError read FOnLoadError write FOnLoadError;

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
    property OnFavIconUrlChange: TOnFavIconUrlChange read FOnFavIconUrlChange write FOnFavIconUrlChange;
    property OnFullScreenModeChange: TOnFullScreenModeChange read FOnFullScreenModeChange write FOnFullScreenModeChange;
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
    property OnDialogClosed: TOnDialogClosed read FOnDialogClosed write FOnDialogClosed;
    property OnBeforePopup: TOnBeforePopup read FOnBeforePopup write FOnBeforePopup;
    property OnAfterCreated: TOnAfterCreated read FOnAfterCreated write FOnAfterCreated;
    property OnBeforeClose: TOnBeforeClose read FOnBeforeClose write FOnBeforeClose;
    property OnRunModal: TOnRunModal read FOnRunModal write FOnRunModal;
    property OnClose: TOnClose read FOnClose write FOnClose;

    property OnBeforeBrowse: TOnBeforeBrowse read FOnBeforeBrowse write FOnBeforeBrowse;
    property OnOpenUrlFromTab: TOnOpenUrlFromTab read FOnOpenUrlFromTab write FOnOpenUrlFromTab;
    property OnBeforeResourceLoad: TOnBeforeResourceLoad read FOnBeforeResourceLoad write FOnBeforeResourceLoad;
    property OnGetResourceHandler: TOnGetResourceHandler read FOnGetResourceHandler write FOnGetResourceHandler;
    property OnResourceRedirect: TOnResourceRedirect read FOnResourceRedirect write FOnResourceRedirect;
    property OnResourceResponse: TOnResourceResponse read FOnResourceResponse write FOnResourceResponse;
    property OnGetAuthCredentials: TOnGetAuthCredentials read FOnGetAuthCredentials write FOnGetAuthCredentials;
    property OnQuotaRequest: TOnQuotaRequest read FOnQuotaRequest write FOnQuotaRequest;
    property OnProtocolExecution: TOnProtocolExecution read FOnProtocolExecution write FOnProtocolExecution;
    property OnCertificateError: TOnCertificateError read FOnCertificateError write FOnCertificateError;
    property OnPluginCrashed: TOnPluginCrashed read FOnPluginCrashed write FOnPluginCrashed;
    property OnRenderViewReady: TOnRenderViewReady read FOnRenderViewReady write FOnRenderViewReady;
    property OnRenderProcessTerminated: TOnRenderProcessTerminated read FOnRenderProcessTerminated write FOnRenderProcessTerminated;

    property OnFileDialog: TOnFileDialog read FOnFileDialog write FOnFileDialog;
    property OnDragEnter: TOnDragEnter read FOnDragEnter write FOnDragEnter;
    property OnDraggableRegionsChanged: TOnDraggableRegionsChanged read FOnDraggableRegionsChanged write FOnDraggableRegionsChanged;
    property OnFindResult: TOnFindResult read FOnFindResult write FOnFindResult;

    property DefaultUrl: ustring read FDefaultUrl write FDefaultUrl;
    property Options: TChromiumOptions read FOptions write FOptions;
    property FontOptions: TChromiumFontOptions read FFontOptions;
    property DefaultEncoding: ustring read FDefaultEncoding write FDefaultEncoding;
    property Browser: ICefBrowser read FBrowser;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load(const url: ustring);
    procedure ReCreateBrowser(const url: string);
  end;

  TChromiumFMX = class(TCustomChromiumFMX)
  public
    property Browser;
  published
    property Align;
    property Anchors;
    property DefaultUrl;
    property TabOrder;
    property Visible;

{$ifdef DELPHI17_UP}
    property CanFocus default True;
    property CanParentFocus;
    property Height;
    property Padding;
    property Opacity;
    property Margins;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
{$endif}

    property OnProcessMessageReceived;
    property OnLoadStart;
    property OnLoadEnd;
    property OnLoadError;

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
    property OnFavIconUrlChange;
    property OnFullScreenModeChange;
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
    property OnDialogClosed;
    property OnBeforePopup;
    property OnAfterCreated;
    property OnBeforeClose;
    property OnRunModal;
    property OnClose;

    property OnBeforeBrowse;
    property OnOpenUrlFromTab;
    property OnBeforeResourceLoad;
    property OnGetResourceHandler;
    property OnResourceRedirect;
    property OnResourceResponse;
    property OnGetAuthCredentials;
    property OnQuotaRequest;
    property OnProtocolExecution;
    property OnCertificateError;
    property OnPluginCrashed;
    property OnRenderViewReady;
    property OnRenderProcessTerminated;

    property OnFileDialog;
    property OnDragEnter;
    property OnDraggableRegionsChanged;
    property OnFindResult;

    property Options;
    property FontOptions;
    property DefaultEncoding;
  end;


implementation
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}

var
  CefInstances: Integer = 0;
  CefTimer: UINT = 0;
{$ENDIF}

function getModifiers(Shift: TShiftState): TCefEventFlags;
begin
  Result := [];
  if ssShift in Shift then Include(Result, EVENTFLAG_SHIFT_DOWN);
  if ssAlt in Shift then Include(Result, EVENTFLAG_ALT_DOWN);
  if ssCtrl in Shift then Include(Result, EVENTFLAG_CONTROL_DOWN);
  if ssLeft in Shift then Include(Result, EVENTFLAG_LEFT_MOUSE_BUTTON);
  if ssRight in Shift then Include(Result, EVENTFLAG_RIGHT_MOUSE_BUTTON);
  if ssMiddle in Shift then Include(Result, EVENTFLAG_MIDDLE_MOUSE_BUTTON);
end;

function GetButton(Button: TMouseButton): TCefMouseButtonType;
begin
  case Button of
    TMouseButton.mbLeft: Result := MBT_LEFT;
    TMouseButton.mbRight: Result := MBT_RIGHT;
    TMouseButton.mbMiddle: Result := MBT_MIDDLE;
  else
    Result := MBT_LEFT;
  end;
end;

function ShiftStateToInt(Shift: TShiftState): Integer;
begin
  Result := 0;
{$ifdef MSWINDOWS}
  if ssShift in Shift then
    Result := Result or VK_SHIFT;
  if ssCtrl in Shift then
    Result := Result or VK_CONTROL;
  if ssAlt in Shift then
    Result := Result or $20000000;
{$endif}
end;

type
  TFMXClientHandler = class(TCustomClientHandler)
  public
    constructor Create(const crm: IChromiumEvents; renderer: Boolean); override;
    destructor Destroy; override;
  end;

{ TCustomChromiumFMX }

constructor TCustomChromiumFMX.Create(AOwner: TComponent);
begin
  inherited;
  CanFocus := True;

  if not (csDesigning in ComponentState) then
    FHandler := TFMXClientHandler.Create(Self, True);

  FBuffer := nil;

  FOptions := TChromiumOptions.Create;
  FFontOptions := TChromiumFontOptions.Create;

{$ifdef DELPHI17_UP}
  if TPlatformServices.Current.SupportsPlatformService(IFMXMouseService) then
    FMouseWheelService := TPlatformServices.Current.GetPlatformService(IFMXMouseService) as IFMXMouseService;
{$endif}

  FDefaultEncoding := '';
  FBrowser := nil;
end;

procedure TCustomChromiumFMX.CreateBrowser;
var
  info: TCefWindowInfo;
  settings: TCefBrowserSettings;
begin
  if not (csDesigning in ComponentState) then
  begin
    FillChar(info, SizeOf(info), 0);
{$ifdef MSWINDOWS}
    info.windowless_rendering_enabled := Ord(True);
{$endif}
{$ifdef MACOSX}
    info.m_bHidden := 1;
{$endif}
    FillChar(settings, SizeOf(TCefBrowserSettings), 0);
    settings.size := SizeOf(TCefBrowserSettings);
    GetSettings(settings);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    CefBrowserCreate(@info, FHandler.Wrap, FDefaultUrl, @FSettings, nil);
{$ELSE}
    FBrowser := CefBrowserHostCreateSync(@info, FHandler, '', @settings, nil);
{$ENDIF}
  end;
end;

destructor TCustomChromiumFMX.Destroy;
begin
  if FBrowser <> nil then
    FBrowser.StopLoad;

  if FHandler <> nil then
    (FHandler as ICefClientHandler).Disconnect;
  FHandler := nil;
  FBrowser := nil;
  FFontOptions.Free;
  FOptions.Free;
  if FBuffer <> nil then
    FBuffer.Free;
  inherited;
end;

procedure TCustomChromiumFMX.DialogKey(var Key: Word; Shift: TShiftState);
var
  event: TCefKeyEvent;
begin
  if (Browser <> nil) and (IsFocused) then
    begin
      FillChar(event, SizeOf(event), 0);
      event.kind := KEYEVENT_KEYDOWN;
      event.modifiers := getModifiers(Shift);
      event.windows_key_code := Key;
      Browser.Host.SendKeyEvent(@event);
      if Key = 9 then
        Key := 0;
    end;
end;

procedure TCustomChromiumFMX.DoEnter;
begin
  inherited;
  if (Browser <> nil) then
    Browser.Host.SendFocusEvent(True);
end;

procedure TCustomChromiumFMX.DoExit;
begin
  inherited;
  if (Browser <> nil) then
    Browser.Host.SendFocusEvent(False);
end;

procedure TCustomChromiumFMX.doOnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  if Assigned(FOnAddressChange) then
    FOnAddressChange(Self, browser, frame, url);
end;

procedure TCustomChromiumFMX.doOnAfterCreated(const browser: ICefBrowser);
begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  if (browser <> nil) and not browser.IsPopup then
    FBrowser := browser;
{$ENDIF}
  if Assigned(FOnAfterCreated) then
    FOnAfterCreated(Self, browser);
end;

function TCustomChromiumFMX.doOnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeBrowse) then
    FOnBeforeBrowse(Self, browser, frame, request, isRedirect, Result);
end;

procedure TCustomChromiumFMX.doOnBeforeClose(const browser: ICefBrowser);
begin
  if Assigned(FOnBeforeClose) then
    FOnBeforeClose(Self, browser);
end;

procedure TCustomChromiumFMX.doOnBeforeContextMenu(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  const model: ICefMenuModel);
begin
  if Assigned(FOnBeforeContextMenu) then
    FOnBeforeContextMenu(Self, browser, frame, params, model);
end;

procedure TCustomChromiumFMX.doOnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin
  if Assigned(FOnBeforeDownload) then
    FOnBeforeDownload(Self, browser, downloadItem, suggestedName, callback);
end;

function TCustomChromiumFMX.doOnBeforePopup(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforePopup) then
    FOnBeforePopup(Self, browser, frame, targetUrl, targetFrameName,
      targetDisposition, userGesture, popupFeatures, windowInfo, client,
      settings, noJavascriptAccess, Result);
end;

function TCustomChromiumFMX.doOnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := RV_CONTINUE;
  if Assigned(FOnBeforeResourceLoad) then
    FOnBeforeResourceLoad(Self, browser, frame, request, callback, Result);
end;

function TCustomChromiumFMX.doOnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean;
  const callback: ICefJsDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeUnloadDialog) then
    FOnBeforeUnloadDialog(Self, browser, messageText, isReload, callback, Result);
end;

procedure TCustomChromiumFMX.doOnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  if Assigned(FOnCancelGeolocationPermission) then
    FOnCancelGeolocationPermission(Self, browser, requestingUrl, requestId);
end;

function TCustomChromiumFMX.doOnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnCertificateError) then
    FOnCertificateError(Self, browser, certError, requestUrl, sslInfo, callback, Result);
end;

function TCustomChromiumFMX.doOnClose(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnClose) then
    FOnClose(Self, browser, Result);
end;

function TCustomChromiumFMX.doOnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, browser, message, source, line, Result);
end;

function TCustomChromiumFMX.doOnContextMenuCommand(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  commandId: Integer; eventFlags: TCefEventFlags): Boolean;
begin
  Result := False;
  if Assigned(FOnContextMenuCommand) then
    FOnContextMenuCommand(Self, browser, frame, params, commandId, eventFlags, Result);
end;

procedure TCustomChromiumFMX.doOnContextMenuDismissed(
  const browser: ICefBrowser; const frame: ICefFrame);
begin
  if Assigned(FOnContextMenuDismissed) then
    FOnContextMenuDismissed(Self, browser, frame);
end;

procedure TCustomChromiumFMX.doOnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; cursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin
  if not (csDestroying in ComponentState) and browser.IsSame(Self.Browser) then
  case cursorType of
    CT_POINTER: Self.Cursor := crArrow;
    CT_CROSS: Self.Cursor:= crCross;
    CT_HAND: Self.Cursor := crHandPoint;
    CT_IBEAM: Self.Cursor := crIBeam;
    CT_WAIT: Self.Cursor := crHourGlass;
    CT_HELP: Self.Cursor := crHelp;
    CT_EASTRESIZE: Self.Cursor := crSizeWE;
    CT_NORTHRESIZE: Self.Cursor := crSizeNS;
    CT_NORTHEASTRESIZE: Self.Cursor:= crSizeNESW;
    CT_NORTHWESTRESIZE: Self.Cursor:= crSizeNWSE;
    CT_SOUTHRESIZE: Self.Cursor:= crSizeNS;
    CT_SOUTHEASTRESIZE: Self.Cursor:= crSizeNWSE;
    CT_SOUTHWESTRESIZE: Self.Cursor:= crSizeNESW;
    CT_WESTRESIZE: Self.Cursor := crSizeWE;
    CT_NORTHSOUTHRESIZE: Self.Cursor:= crSizeNS;
    CT_EASTWESTRESIZE: Self.Cursor := crSizeWE;
    CT_NORTHEASTSOUTHWESTRESIZE: Self.Cursor:= crSizeNESW;
    CT_NORTHWESTSOUTHEASTRESIZE: Self.Cursor:= crSizeNWSE;
    CT_COLUMNRESIZE: Self.Cursor:= crHSplit;
    CT_ROWRESIZE: Self.Cursor:= crVSplit;
    CT_MOVE: Self.Cursor := crSizeAll;
    CT_PROGRESS: Self.Cursor := crAppStart;
    CT_NODROP: Self.Cursor:= crNo;
    CT_NONE: Self.Cursor:= crNone;
    CT_NOTALLOWED: Self.Cursor:= crNo;
  else
    Self.Cursor := crArrow;
  end;
end;

procedure TCustomChromiumFMX.doOnDialogClosed(const browser: ICefBrowser);
begin
  if Assigned(FOnDialogClosed) then
    FOnDialogClosed(Self, browser);
end;

procedure TCustomChromiumFMX.doOnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if Assigned(FOnDownloadUpdated) then
    FOnDownloadUpdated(Self, browser, downloadItem, callback);
end;

function TCustomChromiumFMX.doOnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := False;
  if Assigned(FOnDragEnter) then
    FOnDragEnter(Self, browser, dragData, mask, Result);
end;

procedure TCustomChromiumFMX.doOnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin
  if Assigned(FOnDraggableRegionsChanged) then
    FOnDraggableRegionsChanged(Self, browser, regionsCount, regions);
end;

procedure TCustomChromiumFMX.doOnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin
  if Assigned(FOnFavIconUrlChange) then
    FOnFavIconUrlChange(Self, browser, iconUrls);
end;

function TCustomChromiumFMX.doOnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnFileDialog) then
    FOnFileDialog(Self, browser, mode, title, defaultFilePath, acceptFilters,
      selectedAcceptFilter, callback, Result);
end;

procedure TCustomChromiumFMX.doOnFindResult(const browser: ICefBrowser;
  identifier, count: Integer; const selectionRect: PCefRect;
  activeMatchOrdinal: Integer; finalUpdate: Boolean);
begin
  if Assigned(FOnFindResult) then
    FOnFindResult(Self, browser, identifier, count, selectionRect,
      activeMatchOrdinal, finalUpdate);
end;

procedure TCustomChromiumFMX.doOnFullScreenModeChange(
  const browser: ICefBrowser; fullscreen: Boolean);
begin
  if Assigned(FOnFullScreenModeChange) then
    FOnFullScreenModeChange(Self, browser, fullscreen);
end;

function TCustomChromiumFMX.doOnGetAuthCredentials(const browser: ICefBrowser;
  const frame: ICefFrame; isProxy: Boolean; const host: ustring; port: Integer;
  const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnGetAuthCredentials) then
    FOnGetAuthCredentials(Self, browser, frame, isProxy, host,
      port, realm, scheme, callback, Result);
end;

function TCustomChromiumFMX.doOnGetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  if Assigned(FOnGetResourceHandler) then
    FOnGetResourceHandler(Self, browser, frame, request, Result) else
    Result := nil;
end;

function TCustomChromiumFMX.doOnGetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  if not (csDestroying in ComponentState)
    and Self.Browser.IsSame(browser)
    and (FBuffer <> nil) then
  begin
    rect.x := 0;
    rect.y := 0;
    rect.width := FBuffer.Width;
    rect.height := FBuffer.Height;
    Result := True;
  end else
    Result := False;
end;

function TCustomChromiumFMX.doOnGetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := False;
end;

function TCustomChromiumFMX.doOnGetScreenPoint(const browser: ICefBrowser;
  viewX, viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
end;

function TCustomChromiumFMX.doOnGetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  if not (csDestroying in ComponentState)
    and Self.Browser.IsSame(browser)
    and (FBuffer <> nil) then
  begin
    rect.x := 0;
    rect.y := 0;
    rect.width := FBuffer.Width;
    rect.height := FBuffer.Height;
    Result := True;
  end else
    Result := False;
end;

procedure TCustomChromiumFMX.doOnGotFocus(const browser: ICefBrowser);
begin
  if Assigned(FOnGotFocus) then
    FOnGotFocus(Self, browser)
end;

function TCustomChromiumFMX.doOnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnJsdialog) then
    FOnJsdialog(Self, browser, originUrl, acceptLang, dialogType,
      messageText, defaultPromptText, callback, suppressMessage, Result);
end;

function TCustomChromiumFMX.doOnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin
  Result := False;
  if Assigned(FOnKeyEvent) then
    FOnKeyEvent(Self, browser, event, osEvent, Result);
end;

procedure TCustomChromiumFMX.doOnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if Assigned(FOnLoadEnd) then
    FOnLoadEnd(Self, browser, frame, httpStatusCode);
end;

procedure TCustomChromiumFMX.doOnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText,
  failedUrl: ustring);
begin
  if Assigned(FOnLoadError) then
    FOnLoadError(Self, browser, frame, errorCode, errorText, failedUrl);
end;

procedure TCustomChromiumFMX.doOnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin
  if Assigned(FOnLoadingStateChange) then
    FOnLoadingStateChange(Self, browser, isLoading, canGoBack, canGoForward);
end;

procedure TCustomChromiumFMX.doOnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnLoadStart) then
    FOnLoadStart(Self, browser, frame);
end;

function TCustomChromiumFMX.doOnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  if Assigned(FOnOpenUrlFromTab) then
    FOnOpenUrlFromTab(Self, browser, frame, targetUrl, targetDisposition,
    userGesture, Result);
end;

procedure TCustomChromiumFMX.doOnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer;
  width, height: Integer);
{$ifdef DELPHI17_UP}
var
  wSrc : PByte;
  wOffset, i, j, c : Integer;
  wBitmapData: TBitmapData;
  wColor: TAlphaColor;
const
  _BytesPercolor : integer = 4;
begin
  if (FBuffer = nil)  then
    FBuffer := TBitmap.Create(Width, Height);

  if (FBuffer.Width = Width) and (FBuffer.Height = Height) and (dirtyRectsCount > 0)  then
  begin
    // Getting the bitmap data pointer
    FBuffer.Map(TMapAccess.ReadWrite, wBitmapData);
    try
      // for each rect
      for c := 0 to dirtyRectsCount - 1 do
      begin
        // loop on pixels
        for i := 0 to dirtyRects[c].height - 1 do
          for j := 0 to dirtyRects[c].width - 1 do
          begin
            wOffset := (((dirtyRects[c].y + i) * width) + dirtyRects[c].x + j) * _BytesPercolor; // calculate offset
            wSrc := @PByte(buffer)[wOffset];
            // move color value to firemonkey bitmap
            System.Move(wSrc^, wColor, _BytesPercolor);
            wBitmapData.SetPixel(dirtyRects[c].x + j , dirtyRects[c].y + i, wColor);
          end;
        // Update
        InvalidateRect(RectF(0, 0, width, height));
      end;
    finally
      FBuffer.Unmap(wBitmapData);
    end;
  end;
end;
{$else}
var
  src, dst: PByte;
  offset, i, {j,} w, c: Integer;
begin
  if csDestroying in ComponentState then Exit;

  if (FBuffer <> nil) and (FBuffer.Width = Width) and (FBuffer.Height = Height) then
//    begin
//      Move(buffer^, StartLine^, vw * vh * 4);
//      InvalidateRect(ClipRect);
//    end;
    with FBuffer do
    for c := 0 to dirtyRectsCount - 1 do
    begin
      w := Width * 4;
      offset := ((dirtyRects[c].y * Width) + dirtyRects[c].x) * 4;
      src := @PByte(buffer)[offset];
      dst := @PByte(StartLine)[offset];
      offset := dirtyRects[c].width * 4;
      for i := 0 to dirtyRects[c].height - 1 do
      begin
//        for j := 0 to offset div 4 do
//          PAlphaColorArray(dst)[j] := PAlphaColorArray(src)[j] or $FF000000;
        System.Move(src^, dst^, offset);
        Inc(dst, w);
        Inc(src, w);
      end;
      //InvalidateRect(ClipRect);
      InvalidateRect(RectF(dirtyRects[c].x, dirtyRects[c].y,
        dirtyRects[c].x + dirtyRects[c].width,  dirtyRects[c].y + dirtyRects[c].height));
    end;
end;
{$endif}

procedure TCustomChromiumFMX.doOnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  if Assigned(FOnPluginCrashed) then
    FOnPluginCrashed(Self, browser, pluginPath);
end;

procedure TCustomChromiumFMX.doOnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin

end;

procedure TCustomChromiumFMX.doOnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin

end;

function TCustomChromiumFMX.doOnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnPreKeyEvent) then
    FOnPreKeyEvent(Self, browser, event, osEvent, isKeyboardShortcut, Result);
end;

function TCustomChromiumFMX.doOnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  Result := False;
  if Assigned(FOnProcessMessageReceived) then
    FOnProcessMessageReceived(Self, browser, sourceProcess, message, Result);
end;

procedure TCustomChromiumFMX.doOnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  if Assigned(FOnProtocolExecution) then
    FOnProtocolExecution(Self, browser, url, allowOsExecution);
end;

function TCustomChromiumFMX.doOnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnQuotaRequest) then
    FOnQuotaRequest(Self, browser, originUrl, newSize, callback, Result);
end;

procedure TCustomChromiumFMX.doOnRenderProcessTerminated(
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin
  if Assigned(FOnRenderProcessTerminated) then
    FOnRenderProcessTerminated(Self, browser, status);
end;

procedure TCustomChromiumFMX.doOnRenderViewReady(const browser: ICefBrowser);
begin
  if Assigned(FOnRenderViewReady) then
    FOnRenderViewReady(Self, browser);
end;

function TCustomChromiumFMX.doOnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnRequestGeolocationPermission) then
    FOnRequestGeolocationPermission(Self, browser, requestingUrl, requestId, callback, Result);
end;

procedure TCustomChromiumFMX.doOnResetDialogState(const browser: ICefBrowser);
begin
  if Assigned(FOnResetDialogState) then
    FOnResetDialogState(Self, browser);
end;

procedure TCustomChromiumFMX.doOnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin
  if Assigned(FOnResourceRedirect) then
    FOnResourceRedirect(Self, browser, frame, request, newUrl);
end;

function TCustomChromiumFMX.doOnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := False;
  if Assigned(FOnResourceResponse) then
    FOnResourceResponse(Self, browser, frame, request, response, Result);
end;

function TCustomChromiumFMX.doOnRunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnRunModal) then
    FOnRunModal(Self, browser, Result);
end;

procedure TCustomChromiumFMX.doOnScrollOffsetChanged(
  const browser: ICefBrowser; x, y: Double);
begin

end;

function TCustomChromiumFMX.doOnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := False;
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, browser, source, Result);
end;

function TCustomChromiumFMX.doOnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := False;
end;

procedure TCustomChromiumFMX.doOnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin
  if Assigned(FOnStatusMessage) then
    FOnStatusMessage(Self, browser, value);
end;

procedure TCustomChromiumFMX.doOnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin
  if Assigned(FOnTakeFocus) then
    FOnTakeFocus(Self, browser, next);
end;

procedure TCustomChromiumFMX.doOnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin
  if Assigned(FOnTitleChange) then
    FOnTitleChange(Self, browser, title);
end;

function TCustomChromiumFMX.doOnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnTooltip) then
    FOnTooltip(Self, browser, text, Result);
end;

procedure TCustomChromiumFMX.doOnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin

end;

procedure TCustomChromiumFMX.GetSettings(var settings: TCefBrowserSettings);
begin
  Assert(settings.size >= SizeOf(settings));
  settings.windowless_frame_rate := FOptions.WindowlessFrameRate;

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
  settings.remote_fonts := FFontOptions.RemoteFonts;
  settings.default_encoding := CefString(DefaultEncoding);

  settings.javascript := FOptions.Javascript;
  settings.javascript_open_windows := FOptions.JavascriptOpenWindows;
  settings.javascript_close_windows := FOptions.JavascriptCloseWindows;
  settings.javascript_access_clipboard := FOptions.JavascriptAccessClipboard;
  settings.javascript_dom_paste := FOptions.JavascriptDomPaste;
  settings.caret_browsing := FOptions.CaretBrowsing;
  settings.java := FOptions.Java;
  settings.plugins := FOptions.Plugins;
  settings.universal_access_from_file_urls := FOptions.UniversalAccessFromFileUrls;
  settings.file_access_from_file_urls := FOptions.FileAccessFromFileUrls;
  settings.web_security := FOptions.WebSecurity;
  settings.image_loading := FOptions.ImageLoading;
  settings.image_shrink_standalone_to_fit := FOptions.ImageShrinkStandaloneToFit;
  settings.text_area_resize := FOptions.TextAreaResize;
  settings.tab_to_links := FOptions.TabToLinks;
  settings.local_storage := FOptions.LocalStorage;
  settings.databases := FOptions.Databases;
  settings.application_cache := FOptions.ApplicationCache;
  settings.webgl := FOptions.Webgl;
  settings.background_color := FOptions.BackgroundColor;
  settings.accept_language_list := CefString(FOptions.AcceptLanguageList);
end;

procedure TCustomChromiumFMX.Load(const url: ustring);
var
  frm: ICefFrame;
begin
  if FBrowser <> nil then
  begin
    frm := FBrowser.MainFrame;
    if frm <> nil then
      frm.LoadUrl(url);
  end;
end;

procedure TCustomChromiumFMX.Loaded;
begin
  inherited;
  CreateBrowser;
  Resize;
  Load(FDefaultUrl);
end;

procedure TCustomChromiumFMX.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
var
  event: TCefMouseEvent;
begin
  SetFocus;
  if Browser <> nil then
  begin
    event.x := Round(X);
    event.y := Round(Y);
    event.modifiers := getModifiers(Shift);
    Browser.Host.SendMouseClickEvent(@event, GetButton(Button), False, 1);
  end;
end;

procedure TCustomChromiumFMX.MouseMove(Shift: TShiftState; X, Y: Single);
var
  event: TCefMouseEvent;
begin
  if (Browser <> nil) then
  begin
    event.x := Round(X);
    event.y := Round(Y);
    event.modifiers := getModifiers(Shift);
    Browser.Host.SendMouseMoveEvent(@event, not IsMouseOver);
  end;
end;

procedure TCustomChromiumFMX.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
var
  event: TCefMouseEvent;
begin
  if Browser <> nil then
  begin
    event.x := Round(X);
    event.y := Round(Y);
    event.modifiers := getModifiers(Shift);
    Browser.Host.SendMouseClickEvent(@event, GetButton(Button), True, 1);
  end;
end;

procedure TCustomChromiumFMX.MouseWheel(Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
var
  event: TCefMouseEvent;
begin
{$ifdef DELPHI17_UP}
  if (FMouseWheelService <> nil) AND (Browser <> nil) then
    with ScreenToLocal(FMouseWheelService.GetMousePos()).Round do
{$else}
  if Browser <> nil then
    with ScreenToLocal(Platform.GetMousePos).Round do
{$endif}
    begin
      event.x := X;
      event.y := Y;
      event.modifiers := getModifiers(Shift);
      Browser.Host.SendMouseWheelEvent(@event, 0, WheelDelta);
    end;
end;

procedure TCustomChromiumFMX.Paint;
var
  r: TRectF;
  i: Integer;
begin
 if FBuffer <> nil then
 begin
   FBuffer.Canvas.BeginScene;
   for i := 0 to Scene.GetUpdateRectsCount - 1 do
   begin
     r := Scene.GetUpdateRect(i);
     r.TopLeft := AbsoluteToLocal(r.TopLeft);
     r.BottomRight := AbsoluteToLocal(r.BottomRight);
     if IntersectRectF(r, r, ClipRect) then
       Canvas.DrawBitmap(FBuffer, r, r, 1, False);
   end;
   FBuffer.Canvas.EndScene;
 end;
end;

procedure TCustomChromiumFMX.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  event: TCefKeyEvent;
begin
  if (Browser <> nil) and IsFocused then
    if KeyChar <> #0 then
    begin
      FillChar(event, SizeOf(event), 0);
      event.kind := KEYEVENT_CHAR;
      event.modifiers := getModifiers(Shift);
      event.windows_key_code := Ord(KeyChar);
      Browser.Host.SendKeyEvent(@event)
    end else
    begin
      FillChar(event, SizeOf(event), 0);
      event.kind := KEYEVENT_RAWKEYDOWN;
      event.modifiers := getModifiers(Shift);
      event.windows_key_code := Key;
      Browser.Host.SendKeyEvent(@event)
    end;
end;

procedure TCustomChromiumFMX.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  event: TCefKeyEvent;
begin
  if (Browser <> nil) and IsFocused then
    if KeyChar = #0 then
    begin
      FillChar(event, SizeOf(event), 0);
      event.kind := KEYEVENT_KEYUP;
      event.modifiers := getModifiers(Shift);
      event.windows_key_code := Key;
      Browser.Host.SendKeyEvent(@event)
    end;
end;

procedure TCustomChromiumFMX.ReCreateBrowser(const url: string);
begin
  if (FBrowser <> nil) then
  begin
    FBrowser := nil;
    CreateBrowser;
    Load(url);
  end;
end;

procedure TCustomChromiumFMX.Resize;
var
  brws: ICefBrowser;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    brws := FBrowser;
    if (brws <> nil) then
    begin
      if FBuffer = nil then
        FBuffer := TBitmap.Create(Trunc(Width), Trunc(Height)) else
        FBuffer.SetSize(Trunc(Width), Trunc(Height));
      brws.Host.WasResized;
    end;
  end;
end;

{ TFMXClientHandler }

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

constructor TFMXClientHandler.Create(const crm: IChromiumEvents; renderer: Boolean);
begin
  inherited;
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  if CefInstances = 0 then
    CefTimer := SetTimer(0, 0, 10, @TimerProc);
  InterlockedIncrement(CefInstances);
{$ENDIF}
end;

destructor TFMXClientHandler.Destroy;
begin
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  InterlockedDecrement(CefInstances);
  if CefInstances = 0 then
    KillTimer(0, CefTimer);
{$ENDIF}
  inherited;
end;

end.
