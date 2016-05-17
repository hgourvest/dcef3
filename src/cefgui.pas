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

unit cefgui;

{$I cef.inc}

interface

uses
  Classes, ceflib;

type
  TOnProcessMessageReceived = procedure(Sender: TObject; const browser: ICefBrowser;
    sourceProcess: TCefProcessId; const message: ICefProcessMessage; out Result: Boolean) of object;

  TOnLoadingStateChange = procedure(Sender: TObject; const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean) of object;
  TOnLoadStart = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame) of object;
  TOnLoadEnd = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer) of object;
  TOnLoadError = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
    const errorText, failedUrl: ustring) of object;

  TOnTakeFocus = procedure(Sender: TObject; const browser: ICefBrowser; next: Boolean) of object;
  TOnSetFocus = procedure(Sender: TObject; const browser: ICefBrowser; source: TCefFocusSource; out Result: Boolean) of object;
  TOnGotFocus = procedure(Sender: TObject; const browser: ICefBrowser) of object;

  TOnBeforeContextMenu = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const params: ICefContextMenuParams; const model: ICefMenuModel) of object;
  TOnContextMenuCommand = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const params: ICefContextMenuParams; commandId: Integer;
    eventFlags: TCefEventFlags; out Result: Boolean) of object;
  TOnContextMenuDismissed = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame) of object;

  TOnPreKeyEvent = procedure(Sender: TObject; const browser: ICefBrowser; const event: PCefKeyEvent;
    osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean; out Result: Boolean) of object;
  TOnKeyEvent = procedure(Sender: TObject; const browser: ICefBrowser; const event: PCefKeyEvent;
    osEvent: TCefEventHandle; out Result: Boolean) of object;

  TOnAddressChange = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const url: ustring) of object;
  TOnTitleChange = procedure(Sender: TObject; const browser: ICefBrowser; const title: ustring) of object;
  TOnFavIconUrlChange = procedure(Sender: TObject; const browser: ICefBrowser; const iconUrls: TStrings) of object;
  TOnFullScreenModeChange = procedure(Sender: TObject; const browser: ICefBrowser; fullscreen: Boolean) of object;
  TOnTooltip = procedure(Sender: TObject; const browser: ICefBrowser; var text: ustring; out Result: Boolean) of object;
  TOnStatusMessage = procedure(Sender: TObject; const browser: ICefBrowser; const value: ustring) of object;
  TOnConsoleMessage = procedure(Sender: TObject; const browser: ICefBrowser; const message, source: ustring; line: Integer; out Result: Boolean) of object;

  TOnBeforeDownload = procedure(Sender: TObject; const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
    const suggestedName: ustring; const callback: ICefBeforeDownloadCallback) of object;
  TOnDownloadUpdated = procedure(Sender: TObject; const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback) of object;

  TOnRequestGeolocationPermission = procedure(Sender: TObject; const browser: ICefBrowser;
    const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback; out Result: Boolean) of object;
  TOnCancelGeolocationPermission = procedure(Sender: TObject; const browser: ICefBrowser; requestId: Integer) of object;

  TOnJsdialog = procedure(Sender: TObject; const browser: ICefBrowser; const originUrl, acceptLang: ustring;
    dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
    callback: ICefJsDialogCallback; out suppressMessage: Boolean; out Result: Boolean) of object;
  TOnBeforeUnloadDialog = procedure(Sender: TObject; const browser: ICefBrowser;
    const messageText: ustring; isReload: Boolean;
    const callback: ICefJsDialogCallback; out Result: Boolean) of object;
  TOnResetDialogState = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnDialogClosed = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnBeforePopup = procedure(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
    targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
    var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
    var client: ICefClient; var settings: TCefBrowserSettings;
    var noJavascriptAccess: Boolean; out Result: Boolean) of object;

  TOnAfterCreated = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnBeforeClose = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnRunModal = procedure(Sender: TObject; const browser: ICefBrowser; out Result: Boolean) of object;
  TOnClose = procedure(Sender: TObject; const browser: ICefBrowser; out Result: Boolean) of object;

  TOnBeforeBrowse = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; isRedirect: Boolean; out Result: Boolean) of object;
  TOnOpenUrlFromTab = procedure(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
    userGesture: Boolean; out Result: Boolean) of Object;
  TOnBeforeResourceLoad = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; const callback: ICefRequestCallback; out Result: TCefReturnValue) of object;
  TOnGetResourceHandler = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; out Result: ICefResourceHandler) of object;
  TOnResourceRedirect = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; var newUrl: ustring) of object;
  TOnResourceResponse = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; const response: ICefResponse; out Result: Boolean) of Object;
  TOnGetResourceResponseFilter = procedure(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; const request: ICefRequest; const response: ICefResponse;
    out Result: ICefResponseFilter) of object;
  TOnResourceLoadComplete = procedure(Sender: TObject; const browser: ICefBrowser;
    const frame: ICefFrame; const request: ICefRequest; const response: ICefResponse;
    status: TCefUrlRequestStatus; receivedContentLength: Int64) of object;
  TOnGetAuthCredentials = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
    const callback: ICefAuthCallback; out Result: Boolean) of object;
  TOnQuotaRequest = procedure(Sender: TObject; const browser: ICefBrowser;
    const originUrl: ustring; newSize: Int64; const callback: ICefRequestCallback;
    out Result: Boolean) of object;
  TOnProtocolExecution = procedure(Sender: TObject; const browser: ICefBrowser;
    const url: ustring; out allowOsExecution: Boolean) of object;
  TOnCertificateError = procedure(Sender: TObject; const browser: ICefBrowser;
    certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
    const callback: ICefRequestCallback; out Result: Boolean) of Object;
  TOnPluginCrashed = procedure(Sender: TObject; const browser: ICefBrowser;
    const pluginPath: ustring) of object;
  TOnRenderViewReady = procedure(Sender: Tobject; const browser: ICefBrowser) of Object;
  TOnRenderProcessTerminated = procedure(Sender: TObject; const browser: ICefBrowser;
    status: TCefTerminationStatus) of object;

  TOnFileDialog = procedure(Sender: TObject; const browser: ICefBrowser;
    mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
    acceptFilters: TStrings; selectedAcceptFilter: Integer;
    const callback: ICefFileDialogCallback; out Result: Boolean) of Object;

  TOnGetRootScreenRect = procedure(Sender: TObject; const browser: ICefBrowser;
    rect: PCefRect; out Result: Boolean) of Object;
  TOnGetViewRect = procedure(Sender: TObject; const browser: ICefBrowser;
    rect: PCefRect; out Result: Boolean) of Object;
  TOnGetScreenPoint = procedure(Sender: TObject; const browser: ICefBrowser;
    viewX, viewY: Integer; screenX, screenY: PInteger; out Result: Boolean) of Object;
  TOnGetScreenInfo = procedure(Sender: TObject; const browser: ICefBrowser;
    screenInfo: PCefScreenInfo; Result: Boolean) of Object;
  TOnPopupShow = procedure(Sender: TObject; const browser: ICefBrowser;
    show: Boolean) of Object;
  TOnPopupSize = procedure(Sender: TObject; const browser: ICefBrowser;
    const rect: PCefRect) of Object;
  TOnPaint = procedure(Sender: TObject; const browser: ICefBrowser;
    kind: TCefPaintElementType; dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
    const buffer: Pointer; width, height: Integer) of Object;
  TOnCursorChange = procedure(Sender: TObject; const browser: ICefBrowser;
    cursor: TCefCursorHandle; cursorType: TCefCursorType;
    const customCursorInfo: PCefCursorInfo) of Object;
  TOnStartDragging = procedure(Sender: TObject; const browser: ICefBrowser;
    const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
   y: Integer; out Result: Boolean) of Object;
  TOnUpdateDragCursor = procedure(Sender: TObject; const browser: ICefBrowser;
    operation: TCefDragOperation) of Object;
  TOnScrollOffsetChanged = procedure(Sender: TObject; const browser: ICefBrowser; x, y: Double) of Object;

  TOnDragEnter = procedure(Sender: TObject; const browser: ICefBrowser;
    const dragData: ICefDragData; mask: TCefDragOperations; out Result: Boolean) of Object;
  TOnDraggableRegionsChanged = procedure(Sender: TObject; const browser: ICefBrowser;
    regionsCount: NativeUInt; regions: PCefDraggableRegionArray)of Object;

  TOnFindResult = procedure(Sender: TObject; const browser: ICefBrowser; identifier,
    count: Integer; const selectionRect: PCefRect; activeMatchOrdinal: Integer; finalUpdate: Boolean) of Object;

  TChromiumOptions = class(TPersistent)
  private
    FWindowlessFrameRate: Integer;
    FJavascript: TCefState;
    FJavascriptOpenWindows: TCefState;
    FJavascriptCloseWindows: TCefState;
    FJavascriptAccessClipboard: TCefState;
    FJavascriptDomPaste: TCefState;
    FCaretBrowsing: TCefState;
    FPlugins: TCefState;
    FUniversalAccessFromFileUrls: TCefState;
    FFileAccessFromFileUrls: TCefState;
    FWebSecurity: TCefState;
    FImageLoading: TCefState;
    FImageShrinkStandaloneToFit: TCefState;
    FTextAreaResize: TCefState;
    FTabToLinks: TCefState;
    FLocalStorage: TCefState;
    FDatabases: TCefState;
    FApplicationCache: TCefState;
    FWebgl: TCefState;
    FBackgroundColor: TCefColor;
    FAcceptLanguageList: ustring;
  public
    constructor Create; virtual;
  published
    property Javascript: TCefState read FJavascript write FJavascript default STATE_DEFAULT;
    property JavascriptOpenWindows: TCefState read FJavascriptOpenWindows write FJavascriptOpenWindows default STATE_DEFAULT;
    property JavascriptCloseWindows: TCefState read FJavascriptCloseWindows write FJavascriptCloseWindows default STATE_DEFAULT;
    property JavascriptAccessClipboard: TCefState read FJavascriptAccessClipboard write FJavascriptAccessClipboard default STATE_DEFAULT;
    property JavascriptDomPaste: TCefState read FJavascriptDomPaste write FJavascriptDomPaste default STATE_DEFAULT;
    property CaretBrowsing: TCefState read FCaretBrowsing write FCaretBrowsing default STATE_DEFAULT;
    property Plugins: TCefState read FPlugins write FPlugins default STATE_DEFAULT;
    property UniversalAccessFromFileUrls: TCefState read FUniversalAccessFromFileUrls write FUniversalAccessFromFileUrls default STATE_DEFAULT;
    property FileAccessFromFileUrls: TCefState read FFileAccessFromFileUrls write FFileAccessFromFileUrls default STATE_DEFAULT;
    property WebSecurity: TCefState read FWebSecurity write FWebSecurity default STATE_DEFAULT;
    property ImageLoading: TCefState read FImageLoading write FImageLoading default STATE_DEFAULT;
    property ImageShrinkStandaloneToFit: TCefState read FImageShrinkStandaloneToFit write FImageShrinkStandaloneToFit default STATE_DEFAULT;
    property TextAreaResize: TCefState read FTextAreaResize write FTextAreaResize default STATE_DEFAULT;
    property TabToLinks: TCefState read FTabToLinks write FTabToLinks default STATE_DEFAULT;
    property LocalStorage: TCefState read FLocalStorage write FLocalStorage default STATE_DEFAULT;
    property Databases: TCefState read FDatabases write FDatabases default STATE_DEFAULT;
    property ApplicationCache: TCefState read FApplicationCache write FApplicationCache default STATE_DEFAULT;
    property Webgl: TCefState read FWebgl write FWebgl default STATE_DEFAULT;
    property BackgroundColor: TCefColor read FBackgroundColor write FBackgroundColor default 0;
    property AcceptLanguageList: ustring read FAcceptLanguageList write FAcceptLanguageList;
    property WindowlessFrameRate: Integer read FWindowlessFrameRate write FWindowlessFrameRate default 30;
  end;

  TChromiumFontOptions = class(TPersistent)
  private
    FStandardFontFamily: ustring;
    FCursiveFontFamily: ustring;
    FSansSerifFontFamily: ustring;
    FMinimumLogicalFontSize: Integer;
    FFantasyFontFamily: ustring;
    FSerifFontFamily: ustring;
    FDefaultFixedFontSize: Integer;
    FDefaultFontSize: Integer;
    FRemoteFontsDisabled: TCefState;
    FFixedFontFamily: ustring;
    FMinimumFontSize: Integer;
  public
    constructor Create; virtual;
  published
    property StandardFontFamily: ustring read FStandardFontFamily;
    property FixedFontFamily: ustring read FFixedFontFamily write FFixedFontFamily;
    property SerifFontFamily: ustring read FSerifFontFamily write FSerifFontFamily;
    property SansSerifFontFamily: ustring read FSansSerifFontFamily write FSansSerifFontFamily;
    property CursiveFontFamily: ustring read FCursiveFontFamily write FCursiveFontFamily;
    property FantasyFontFamily: ustring read FFantasyFontFamily write FFantasyFontFamily;
    property DefaultFontSize: Integer read FDefaultFontSize write FDefaultFontSize default 0;
    property DefaultFixedFontSize: Integer read FDefaultFixedFontSize write FDefaultFixedFontSize default 0;
    property MinimumFontSize: Integer read FMinimumFontSize write FMinimumFontSize default 0;
    property MinimumLogicalFontSize: Integer read FMinimumLogicalFontSize write FMinimumLogicalFontSize default 0;
    property RemoteFonts: TCefState read FRemoteFontsDisabled write FRemoteFontsDisabled default STATE_DEFAULT;
  end;

  IChromiumEvents = interface
  ['{0C139DB1-0349-4D7F-8155-76FEA6A0126D}']
    procedure GetSettings(var settings: TCefBrowserSettings);
    function doOnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;

    procedure doOnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
    procedure doOnLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
    procedure doOnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure doOnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring);

    procedure doOnTakeFocus(const browser: ICefBrowser; next: Boolean);
    function doOnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean;
    procedure doOnGotFocus(const browser: ICefBrowser);

    procedure doOnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    function doOnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean;
    procedure doOnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame);

    function doOnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean;
    function doOnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean;

    procedure doOnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure doOnTitleChange(const browser: ICefBrowser; const title: ustring);
    procedure doOnFaviconUrlChange(const browser: ICefBrowser; iconUrls: TStrings);
    procedure doOnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean);
    function doOnTooltip(const browser: ICefBrowser; var text: ustring): Boolean;
    procedure doOnStatusMessage(const browser: ICefBrowser; const value: ustring);
    function doOnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean;

    function doOnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback): Boolean;
    procedure doOnCancelGeolocationPermission(const browser: ICefBrowser;
      requestId: Integer);

    procedure doOnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback);
    procedure doOnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback);

    function doOnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean;
    function doOnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean;
    procedure doOnResetDialogState(const browser: ICefBrowser);
    procedure doOnDialogClosed(const browser: ICefBrowser);

    function doOnBeforePopup(const browser: ICefBrowser;
      const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean;
    procedure doOnAfterCreated(const browser: ICefBrowser);
    procedure doOnBeforeClose(const browser: ICefBrowser);
    function doOnRunModal(const browser: ICefBrowser): Boolean;
    function doOnClose(const browser: ICefBrowser): Boolean;

    function doOnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean;
    function doOnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean;
    function doOnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue;
    function doOnGetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler;
    procedure doOnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring);
    function doOnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean;
    function doOnGetResourceResponseFilter(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): ICefResponseFilter;
    procedure doOnResourceLoadComplete(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse; status: TCefUrlRequestStatus;
      receivedContentLength: Int64);
    function doOnGetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean;
    function doOnQuotaRequest(const browser: ICefBrowser; const originUrl: ustring;
      newSize: Int64; const callback: ICefRequestCallback): Boolean;
    procedure doOnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean);
    function doOnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean;
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring);
    procedure doOnRenderViewReady(const browser: ICefBrowser);
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus);

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
  end;

  ICefClientHandler = interface
    ['{E76F6888-D9C3-4FCE-9C23-E89659820A36}']
    procedure Disconnect;
  end;

  TCustomClientHandler = class(TCefClientOwn, ICefClientHandler)
  private
    FEvents: IChromiumEvents;
    FLoadHandler: ICefLoadHandler;
    FFocusHandler: ICefFocusHandler;
    FContextMenuHandler: ICefContextMenuHandler;
    FDialogHandler: ICefDialogHandler;
    FKeyboardHandler: ICefKeyboardHandler;
    FDisplayHandler: ICefDisplayHandler;
    FDownloadHandler: ICefDownloadHandler;
    FGeolocationHandler: ICefGeolocationHandler;
    FJsDialogHandler: ICefJsDialogHandler;
    FLifeSpanHandler: ICefLifeSpanHandler;
    FRenderHandler: ICefRenderHandler;
    FRequestHandler: ICefRequestHandler;
    FDragHandler: ICefDragHandler;
    FFindHandler: ICefFindHandler;
  protected
    function GetContextMenuHandler: ICefContextMenuHandler; override;
    function GetDialogHandler: ICefDialogHandler; override;
    function GetDisplayHandler: ICefDisplayHandler; override;
    function GetDownloadHandler: ICefDownloadHandler; override;
    function GetDragHandler: ICefDragHandler; override;
    function GetFindHandler: ICefFindHandler; override;
    function GetFocusHandler: ICefFocusHandler; override;
    function GetGeolocationHandler: ICefGeolocationHandler; override;
    function GetJsdialogHandler: ICefJsdialogHandler; override;
    function GetKeyboardHandler: ICefKeyboardHandler; override;
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
    function GetRenderHandler: ICefRenderHandler; override;
    function GetLoadHandler: ICefLoadHandler; override;
    function GetRequestHandler: ICefRequestHandler; override;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; override;

    procedure Disconnect;
  public
    constructor Create(const events: IChromiumEvents; renderer: Boolean); reintroduce; virtual;
  end;

  TCustomClientHandlerClass = class of TCustomClientHandler;

  TCustomLoadHandler = class(TCefLoadHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean); override;
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); override;
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); override;
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomFocusHandler = class(TCefFocusHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnTakeFocus(const browser: ICefBrowser; next: Boolean); override;
    function OnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean; override;
    procedure OnGotFocus(const browser: ICefBrowser); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomContextMenuHandler = class(TCefContextMenuHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel); override;
    function OnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean; override;
    procedure OnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomDialogHandler = class(TCefDialogHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title: ustring; const defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer;
      const callback: ICefFileDialogCallback): Boolean; override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomKeyboardHandler = class(TCefKeyboardHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean; override;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean; override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomDisplayHandler = class(TCefDisplayHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring); override;
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring); override;
    procedure OnFaviconUrlChange(const browser: ICefBrowser; iconUrls: TStrings); override;
    procedure OnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean); override;
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; override;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring); override;
    function OnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean; override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomDownloadHandler = class(TCefDownloadHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback); override;
    procedure OnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomGeolocationHandler = class(TCefGeolocationHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback): Boolean; override;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser; requestId: Integer); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomJsDialogHandler = class(TCefJsDialogHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean; override;
    function OnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean; override;
    procedure OnResetDialogState(const browser: ICefBrowser); override;
    procedure OnDialogClosed(const browser: ICefBrowser); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomLifeSpanHandler = class(TCefLifeSpanHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean; var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean; override;
    procedure OnAfterCreated(const browser: ICefBrowser); override;
    procedure OnBeforeClose(const browser: ICefBrowser); override;
    function RunModal(const browser: ICefBrowser): Boolean; override;
    function DoClose(const browser: ICefBrowser): Boolean; override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomRequestHandler = class(TCefRequestHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean; override;
    function OnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean; override;
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue; override;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; override;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring); override;
    function OnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean; override;
    function GetResourceResponseFilter(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): ICefResponseFilter; override;
    procedure OnResourceLoadComplete(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse; status: TCefUrlRequestStatus;
      receivedContentLength: Int64); override;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; override;
    function OnQuotaRequest(const browser: ICefBrowser; const originUrl: ustring;
      newSize: Int64; const callback: ICefRequestCallback): Boolean; override;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean); override;
    function OnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean; override;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); override;
    procedure OnRenderViewReady(const browser: ICefBrowser); override;
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomRenderHandler = class(TCefRenderHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean; override;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean; override;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean; override;
    procedure OnPopupShow(const browser: ICefBrowser; show: Boolean); override;
    procedure OnPopupSize(const browser: ICefBrowser; const rect: PCefRect); override;
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer); override;
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      cursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo); override;
    function GetScreenInfo(const browser: ICefBrowser;
      screenInfo: PCefScreenInfo): Boolean; override;
    function OnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean; override;
    procedure OnUpdateDragCursor(const browser: ICefBrowser;
      operation: TCefDragOperation); override;
    procedure OnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomDragHandler = class(TCefDragHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnDragEnter(const browser: ICefBrowser;
      const dragData: ICefDragData; mask: TCefDragOperations): Boolean; override;
    procedure OnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomFindHandler = class(TCefFindHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnFindResult(const browser: ICefBrowser;
      identifier, count: Integer; const selectionRect: PCefRect;
      activeMatchOrdinal: Integer; finalUpdate: Boolean); override;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

implementation

{ TChromiumFontOptions }

constructor TChromiumFontOptions.Create;
begin
  FStandardFontFamily := '';
  FCursiveFontFamily := '';
  FSansSerifFontFamily := '';
  FMinimumLogicalFontSize := 0;
  FFantasyFontFamily := '';
  FSerifFontFamily := '';
  FDefaultFixedFontSize := 0;
  FDefaultFontSize := 0;
  FRemoteFontsDisabled := STATE_DEFAULT;
  FFixedFontFamily := '';
  FMinimumFontSize := 0;
end;

{ TCefCustomHandler }

constructor TCustomClientHandler.Create(const events: IChromiumEvents; renderer: Boolean);
begin
  inherited Create;
  FEvents := events;
 FLoadHandler := TCustomLoadHandler.Create(events);
  FFocusHandler := TCustomFocusHandler.Create(events);
  FContextMenuHandler := TCustomContextMenuHandler.Create(events);
  FDialogHandler := TCustomDialogHandler.Create(events);
  FKeyboardHandler := TCustomKeyboardHandler.Create(events);
  FDisplayHandler := TCustomDisplayHandler.Create(events);
  FDownloadHandler := TCustomDownloadHandler.Create(events);
  FGeolocationHandler := TCustomGeolocationHandler.Create(events);
  FJsDialogHandler := TCustomJsDialogHandler.Create(events);
  FLifeSpanHandler := TCustomLifeSpanHandler.Create(events);
  FRequestHandler := TCustomRequestHandler.Create(events);
  if renderer then
    FRenderHandler := TCustomRenderHandler.Create(events) else
    FRenderHandler := nil;
  FDragHandler := TCustomDragHandler.Create(events);
  FFindHandler := TCustomFindHandler.Create(events);
end;

procedure TCustomClientHandler.Disconnect;
begin
  FEvents := nil;
  FLoadHandler := nil;
  FFocusHandler := nil;
  FContextMenuHandler := nil;
  FDialogHandler := nil;
  FKeyboardHandler := nil;
  FDisplayHandler := nil;
  FDownloadHandler := nil;
  FGeolocationHandler := nil;
  FJsDialogHandler := nil;
  FLifeSpanHandler := nil;
  FRequestHandler := nil;
  FRenderHandler := nil;
  FDragHandler := nil;
  FFindHandler := nil;
end;

function TCustomClientHandler.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := FContextMenuHandler;
end;

function TCustomClientHandler.GetDialogHandler: ICefDialogHandler;
begin
  Result := FDialogHandler;
end;

function TCustomClientHandler.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := FDisplayHandler;
end;

function TCustomClientHandler.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := FDownloadHandler;
end;

function TCustomClientHandler.GetDragHandler: ICefDragHandler;
begin
  Result := FDragHandler;
end;

function TCustomClientHandler.GetFindHandler: ICefFindHandler;
begin
  Result := FFindHandler;
end;

function TCustomClientHandler.GetFocusHandler: ICefFocusHandler;
begin
  Result := FFocusHandler;
end;

function TCustomClientHandler.GetGeolocationHandler: ICefGeolocationHandler;
begin
  Result := FGeolocationHandler;
end;

function TCustomClientHandler.GetJsdialogHandler: ICefJsDialogHandler;
begin
  Result := FJsDialogHandler;
end;

function TCustomClientHandler.GetKeyboardHandler: ICefKeyboardHandler;
begin
  Result := FKeyboardHandler;
end;

function TCustomClientHandler.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpanHandler;
end;

function TCustomClientHandler.GetLoadHandler: ICefLoadHandler;
begin
  Result := FLoadHandler;
end;

function TCustomClientHandler.GetRenderHandler: ICefRenderHandler;
begin
  Result := FRenderHandler;
end;

function TCustomClientHandler.GetRequestHandler: ICefRequestHandler;
begin
  Result := FRequestHandler;
end;

function TCustomClientHandler.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  if Assigned(FEvents) then
    Result := FEvents.doOnProcessMessageReceived(browser, sourceProcess, message) else
    Result := False;
end;

{ TCustomLoadHandler }

constructor TCustomLoadHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomLoadHandler.OnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  FEvent.doOnLoadEnd(browser, frame, httpStatusCode);
end;

procedure TCustomLoadHandler.OnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText,
  failedUrl: ustring);
begin
  FEvent.doOnLoadError(browser, frame, errorCode, errorText, failedUrl);
end;

procedure TCustomLoadHandler.OnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin
  FEvent.doOnLoadingStateChange(browser, isLoading, canGoBack, canGoForward);
end;

procedure TCustomLoadHandler.OnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  FEvent.doOnLoadStart(browser, frame);
end;

{ TCustomFocusHandler }

constructor TCustomFocusHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomFocusHandler.OnGotFocus(const browser: ICefBrowser);
begin
  FEvent.doOnGotFocus(browser);
end;

function TCustomFocusHandler.OnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := FEvent.doOnSetFocus(browser, source);
end;

procedure TCustomFocusHandler.OnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin
  FEvent.doOnTakeFocus(browser, next);
end;

{ TCustomContextMenuHandler }

constructor TCustomContextMenuHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomContextMenuHandler.OnBeforeContextMenu(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  FEvent.doOnBeforeContextMenu(browser, frame, params, model);
end;

function TCustomContextMenuHandler.OnContextMenuCommand(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: TCefEventFlags): Boolean;
begin
  Result := FEvent.doOnContextMenuCommand(browser, frame, params, commandId,
    eventFlags);
end;

procedure TCustomContextMenuHandler.OnContextMenuDismissed(
  const browser: ICefBrowser; const frame: ICefFrame);
begin
  FEvent.doOnContextMenuDismissed(browser, frame);
end;

{ TCustomKeyboardHandler }

constructor TCustomKeyboardHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomKeyboardHandler.OnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin
  Result := FEvent.doOnKeyEvent(browser, event, osEvent);
end;

function TCustomKeyboardHandler.OnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := FEvent.doOnPreKeyEvent(browser, event, osEvent, isKeyboardShortcut);
end;

{ TCustomDisplayHandler }

constructor TCustomDisplayHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomDisplayHandler.OnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  FEvent.doOnAddressChange(browser, frame, url);
end;

function TCustomDisplayHandler.OnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := FEvent.doOnConsoleMessage(browser, message, source, line);
end;

procedure TCustomDisplayHandler.OnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin
  FEvent.doOnFaviconUrlChange(browser, iconUrls);
end;

procedure TCustomDisplayHandler.OnFullScreenModeChange(
  const browser: ICefBrowser; fullscreen: Boolean);
begin
  FEvent.doOnFullScreenModeChange(browser, fullscreen);
end;

procedure TCustomDisplayHandler.OnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin
  FEvent.doOnStatusMessage(browser, value);
end;

procedure TCustomDisplayHandler.OnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin
  FEvent.doOnTitleChange(browser, title);
end;

function TCustomDisplayHandler.OnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := FEvent.doOnTooltip(browser, text);
end;

{ TCustomDownloadHandler }

constructor TCustomDownloadHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomDownloadHandler.OnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin
  FEvent.doOnBeforeDownload(browser, downloadItem, suggestedName, callback);
end;

procedure TCustomDownloadHandler.OnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  FEvent.doOnDownloadUpdated(browser, downloadItem, callback);
end;

{ TCustomGeolocationHandler }

constructor TCustomGeolocationHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomGeolocationHandler.OnCancelGeolocationPermission(
  const browser: ICefBrowser; requestId: Integer);
begin
  FEvent.doOnCancelGeolocationPermission(browser, requestId);
end;

function TCustomGeolocationHandler.OnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := FEvent.doOnRequestGeolocationPermission(browser, requestingUrl, requestId, callback);
end;

{ TCustomJsDialogHandler }

constructor TCustomJsDialogHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomJsDialogHandler.OnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean;
  const callback: ICefJsDialogCallback): Boolean;
begin
  Result := FEvent.doOnBeforeUnloadDialog(browser, messageText, isReload, callback);
end;

procedure TCustomJsDialogHandler.OnDialogClosed(const browser: ICefBrowser);
begin
  FEvent.doOnDialogClosed(browser);
end;

function TCustomJsDialogHandler.OnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  Result := FEvent.doOnJsdialog(browser, originUrl, acceptLang, dialogType,
    messageText, defaultPromptText, callback, suppressMessage);
end;

procedure TCustomJsDialogHandler.OnResetDialogState(const browser: ICefBrowser);
begin
  FEvent.doOnResetDialogState(browser);
end;

{ TCustomLifeSpanHandler }

constructor TCustomLifeSpanHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomLifeSpanHandler.DoClose(const browser: ICefBrowser): Boolean;
begin
  Result := FEvent.doOnClose(browser);
end;

procedure TCustomLifeSpanHandler.OnAfterCreated(const browser: ICefBrowser);
begin
  FEvent.doOnAfterCreated(browser);
end;

procedure TCustomLifeSpanHandler.OnBeforeClose(const browser: ICefBrowser);
begin
  FEvent.doOnBeforeClose(browser);
end;


function TCustomLifeSpanHandler.OnBeforePopup(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean): Boolean;
begin
  Result := FEvent.doOnBeforePopup(browser, frame, targetUrl, targetFrameName,
    targetDisposition, userGesture, popupFeatures, windowInfo, client, settings,
    noJavascriptAccess);
end;

function TCustomLifeSpanHandler.RunModal(const browser: ICefBrowser): Boolean;
begin
  Result := FEvent.doOnRunModal(browser);
end;

{ TCustomRequestHandler }

constructor TCustomRequestHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomRequestHandler.GetAuthCredentials(const browser: ICefBrowser;
  const frame: ICefFrame; isProxy: Boolean; const host: ustring; port: Integer;
  const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  Result := FEvent.doOnGetAuthCredentials(browser, frame, isProxy, host, port,
    realm, scheme, callback);
end;

function TCustomRequestHandler.GetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  Result := FEvent.doOnGetResourceHandler(browser, frame, request);
end;

function TCustomRequestHandler.GetResourceResponseFilter(
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const response: ICefResponse): ICefResponseFilter;
begin
  Result := FEvent.doOnGetResourceResponseFilter(browser, frame, request, response);
end;

function TCustomRequestHandler.OnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := FEvent.doOnBeforeBrowse(browser, frame, request, isRedirect);
end;

function TCustomRequestHandler.OnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := FEvent.doOnBeforeResourceLoad(browser, frame, request, callback);
end;

function TCustomRequestHandler.OnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := FEvent.doOnCertificateError(browser, certError, requestUrl, sslInfo, callback);
end;

function TCustomRequestHandler.OnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  Result := FEvent.doOnOpenUrlFromTab(browser, frame, targetUrl, targetDisposition, userGesture);
end;

procedure TCustomRequestHandler.OnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  FEvent.doOnPluginCrashed(browser, pluginPath);
end;

procedure TCustomRequestHandler.OnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  FEvent.doOnProtocolExecution(browser, url, allowOsExecution);
end;

function TCustomRequestHandler.OnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := FEvent.doOnQuotaRequest(browser, originUrl, newSize, callback);
end;

procedure TCustomRequestHandler.OnRenderProcessTerminated(
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin
  FEvent.doOnRenderProcessTerminated(browser, status);
end;

procedure TCustomRequestHandler.OnRenderViewReady(const browser: ICefBrowser);
begin
  FEvent.doOnRenderViewReady(browser);
end;

procedure TCustomRequestHandler.OnResourceLoadComplete(
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const response: ICefResponse;
  status: TCefUrlRequestStatus; receivedContentLength: Int64);
begin
  FEvent.doOnResourceLoadComplete(browser, frame, request, response, status, receivedContentLength);
end;

procedure TCustomRequestHandler.OnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin
  FEvent.doOnResourceRedirect(browser, frame, request, newUrl);
end;

function TCustomRequestHandler.OnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := FEvent.doOnResourceResponse(browser, frame, request, response);
end;

{ TCustomDialogHandler }

constructor TCustomDialogHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomDialogHandler.OnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := FEvent.doOnFileDialog(browser, mode, title,
    defaultFilePath, acceptFilters, selectedAcceptFilter, callback)
end;

{ TCustomRenderHandler }

constructor TCustomRenderHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomRenderHandler.GetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := FEvent.doOnGetRootScreenRect(browser, rect);
end;

function TCustomRenderHandler.GetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := FEvent.doOnGetScreenInfo(browser, screenInfo);
end;

function TCustomRenderHandler.GetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := FEvent.doOnGetScreenPoint(browser, viewX, viewY, screenX, screenY);
end;

function TCustomRenderHandler.GetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := FEvent.doOnGetViewRect(browser, rect);
end;

procedure TCustomRenderHandler.OnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; cursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin
  FEvent.doOnCursorChange(browser, cursor, cursorType, customCursorInfo);
end;

procedure TCustomRenderHandler.OnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
begin
  FEvent.doOnPaint(browser, kind, dirtyRectsCount, dirtyRects, buffer, width, height);
end;

procedure TCustomRenderHandler.OnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin
  FEvent.doOnPopupShow(browser, show);
end;

procedure TCustomRenderHandler.OnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin
  FEvent.doOnPopupSize(browser, rect);
end;

procedure TCustomRenderHandler.OnScrollOffsetChanged(
  const browser: ICefBrowser; x, y: Double);
begin
  FEvent.doOnScrollOffsetChanged(browser, x, y);
end;

function TCustomRenderHandler.OnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := FEvent.doOnStartDragging(browser, dragData, allowedOps, x, y);
end;

procedure TCustomRenderHandler.OnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin
  FEvent.doOnUpdateDragCursor(browser, operation);
end;

{ TCustomDragHandler }

constructor TCustomDragHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

function TCustomDragHandler.OnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := FEvent.doOnDragEnter(browser, dragData, mask);
end;

procedure TCustomDragHandler.OnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin
  FEvent.doOnDraggableRegionsChanged(browser, regionsCount, regions);
end;

{ TChromiumOptions }

constructor TChromiumOptions.Create;
begin
  FWindowlessFrameRate := 30;
  FJavascript := STATE_DEFAULT;
  FJavascriptOpenWindows := STATE_DEFAULT;
  FJavascriptCloseWindows := STATE_DEFAULT;
  FJavascriptAccessClipboard := STATE_DEFAULT;
  FJavascriptDomPaste := STATE_DEFAULT;
  FCaretBrowsing := STATE_DEFAULT;
  FPlugins := STATE_DEFAULT;
  FUniversalAccessFromFileUrls := STATE_DEFAULT;
  FFileAccessFromFileUrls := STATE_DEFAULT;
  FWebSecurity := STATE_DEFAULT;
  FImageLoading := STATE_DEFAULT;
  FImageShrinkStandaloneToFit := STATE_DEFAULT;
  FTextAreaResize := STATE_DEFAULT;
  FTabToLinks := STATE_DEFAULT;
  FLocalStorage := STATE_DEFAULT;
  FDatabases := STATE_DEFAULT;
  FApplicationCache := STATE_DEFAULT;
  FWebgl := STATE_DEFAULT;
  FBackgroundColor := 0;
end;

{ TCustomFindHandler }

constructor TCustomFindHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvent := events;
end;

procedure TCustomFindHandler.OnFindResult(const browser: ICefBrowser;
  identifier, count: Integer; const selectionRect: PCefRect;
  activeMatchOrdinal: Integer; finalUpdate: Boolean);
begin
  FEvent.doOnFindResult(browser, identifier, count, selectionRect,
    activeMatchOrdinal, finalUpdate);
end;

end.
