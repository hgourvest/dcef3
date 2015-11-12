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
  TChromiumDevTools = class(TWinControl)
  private
    FSettings: TCefBrowserSettings;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure Resize; override;
  public
    procedure ShowDevTools(const browser: ICefBrowser; inspectElementAt: PCefPoint = nil);
    procedure CloseDevTools(const browser: ICefBrowser);
  published
    property Align;
    property Visible;
  end;

  TCustomChromium = class(TWinControl, IChromiumEvents)
  private
    FHandler: ICefClient;
    FBrowser: ICefBrowser;
    FBrowserId: Integer;
    FDefaultUrl: ustring;

    FSettings: TCefBrowserSettings;

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

    procedure GetSettings(var settings: TCefBrowserSettings);
  protected
    function GetClientHandler: ICefClient; virtual;
    procedure CreateBrowser; virtual;
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
    procedure doOnDialogClosed(const browser: ICefBrowser); virtual;

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
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue;
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
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;
    procedure doOnRenderViewReady(const browser: ICefBrowser); virtual;
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;

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
    property OnRenderProcessTerminated: TOnRenderProcessTerminated read FOnRenderProcessTerminated write FOnRenderProcessTerminated;
    property OnPluginCrashed: TOnPluginCrashed read FOnPluginCrashed write FOnPluginCrashed;
    property OnRenderViewReady: TOnRenderViewReady read FOnRenderViewReady write FOnRenderViewReady;

    property OnFileDialog: TOnFileDialog read FOnFileDialog write FOnFileDialog;
    property OnDragEnter: TOnDragEnter read FOnDragEnter write FOnDragEnter;
    property OnDraggableRegionsChanged: TOnDraggableRegionsChanged read FOnDraggableRegionsChanged write FOnDraggableRegionsChanged;
    property OnFindResult: TOnFindResult read FOnFindResult write FOnFindResult;

    property DefaultUrl: ustring read FDefaultUrl write FDefaultUrl;
    property Options: TChromiumOptions read FOptions write FOptions;
    property FontOptions: TChromiumFontOptions read FFontOptions;
    property DefaultEncoding: ustring read FDefaultEncoding write FDefaultEncoding;
    property BrowserId: Integer read FBrowserId;
    property Browser: ICefBrowser read FBrowser;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load(const url: ustring);
    procedure ReCreateBrowser(const url: string);
    procedure ShowDevTools(inspectElementAt: PCefPoint = nil);
    procedure CloseDevTools;
  end;

  TCustomChromiumOSR = class(TComponent, IChromiumEvents)
  private
    FHandler: ICefClient;
    FBrowser: ICefBrowser;
    FBrowserId: Integer;
    FDefaultUrl: ustring;

    FSettings: TCefBrowserSettings;

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

    FOnGetRootScreenRect: TOnGetRootScreenRect;
    FOnGetViewRect: TOnGetViewRect;
    FOnGetScreenPoint: TOnGetScreenPoint;
    FOnGetScreenInfo: TOnGetScreenInfo;
    FOnPopupShow: TOnPopupShow;
    FOnPopupSize: TOnPopupSize;
    FOnPaint: TOnPaint;
    FOnCursorChange: TOnCursorChange;
    FOnStartDragging: TOnStartDragging;
    FOnUpdateDragCursor: TOnUpdateDragCursor;
    FOnScrollOffsetChanged: TOnScrollOffsetChanged;

    FOnDragEnter: TOnDragEnter;
    FOnDraggableRegionsChanged: TOnDraggableRegionsChanged;
    FOnFindResult: TOnFindResult;

    FOptions: TChromiumOptions;
    FDefaultEncoding: ustring;
    FFontOptions: TChromiumFontOptions;
    FTransparentPainting: Boolean;

    procedure GetSettings(var settings: TCefBrowserSettings);
  protected
    procedure CreateBrowser; virtual;
    function GetClientHandler: ICefClient; virtual;
    procedure Loaded; override;

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

    procedure doOnDialogClosed(const browser: ICefBrowser); virtual;

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
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue;
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
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;
    procedure doOnRenderViewReady(const browser: ICefBrowser); virtual;
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;

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
    property OnGetRootScreenRect: TOnGetRootScreenRect read FOnGetRootScreenRect write FOnGetRootScreenRect;
    property OnGetViewRect: TOnGetViewRect read FOnGetViewRect write FOnGetViewRect;
    property OnGetScreenPoint: TOnGetScreenPoint read FOnGetScreenPoint write FOnGetScreenPoint;
    property OnGetScreenInfo: TOnGetScreenInfo read FOnGetScreenInfo write FOnGetScreenInfo;
    property OnPopupShow: TOnPopupShow read FOnPopupShow write FOnPopupShow;
    property OnPopupSize: TOnPopupSize read FOnPopupSize write FOnPopupSize;
    property OnPaint: TOnPaint read FOnPaint write FOnPaint;
    property OnCursorChange: TOnCursorChange read FOnCursorChange write FOnCursorChange;
    property OnScrollOffsetChanged: TOnScrollOffsetChanged read FOnScrollOffsetChanged write FOnScrollOffsetChanged;
    property OnStartDragging: TOnStartDragging read FOnStartDragging write FOnStartDragging;
    property OnUpdateDragCursor: TOnUpdateDragCursor read FOnUpdateDragCursor write FOnUpdateDragCursor;
    property OnDragEnter: TOnDragEnter read FOnDragEnter write FOnDragEnter;
    property OnDraggableRegionsChanged: TOnDraggableRegionsChanged read FOnDraggableRegionsChanged write FOnDraggableRegionsChanged;
    property OnFindResult: TOnFindResult read FOnFindResult write FOnFindResult;

    property DefaultUrl: ustring read FDefaultUrl write FDefaultUrl;
    property Options: TChromiumOptions read FOptions write FOptions;
    property FontOptions: TChromiumFontOptions read FFontOptions;
    property DefaultEncoding: ustring read FDefaultEncoding write FDefaultEncoding;
    property BrowserId: Integer read FBrowserId;
    property Browser: ICefBrowser read FBrowser;
    property TransparentPainting: Boolean read FTransparentPainting write FTransparentPainting default False;
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


  TChromiumOSR = class(TCustomChromiumOSR)
  public
    property BrowserId;
    property Browser;
  published
    property DefaultUrl;

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
    property OnPluginCrashed;
    property OnRenderViewReady;
    property OnRenderProcessTerminated;

    property OnFileDialog;

    property OnGetRootScreenRect;
    property OnGetViewRect;
    property OnGetScreenPoint;
    property OnPopupShow;
    property OnPopupSize;
    property OnPaint;
    property OnCursorChange;
    property OnScrollOffsetChanged;
    property OnDragEnter;
    property OnDraggableRegionsChanged;
    property OnFindResult;

    property Options;
    property FontOptions;
    property DefaultEncoding;
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
    constructor Create(const crm: IChromiumEvents; renderer: Boolean); override;
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

constructor TVCLClientHandler.Create(const crm: IChromiumEvents; renderer: Boolean);
begin
  inherited Create(crm, renderer);
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

procedure TCustomChromium.CloseDevTools;
begin
  if (FBrowser <> nil) then
    FBrowser.Host.CloseDevTools;
end;

constructor TCustomChromium.Create(AOwner: TComponent);
begin
  inherited;
  FDefaultUrl := 'about:blank';

  if not (csDesigning in ComponentState) then
    FHandler := GetClientHandler;

  FOptions := TChromiumOptions.Create;
  FFontOptions := TChromiumFontOptions.Create;

  FDefaultEncoding := '';
  FBrowserId := 0;
  FBrowser := nil;
end;

procedure TCustomChromium.CreateBrowser;
var
  info: TCefWindowInfo;
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
    FillChar(FSettings, SizeOf(TCefBrowserSettings), 0);
    FSettings.size := SizeOf(TCefBrowserSettings);
    GetSettings(FSettings);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    CefBrowserHostCreate(@info, FHandler, FDefaultUrl, @settings, nil);
{$ELSE}
    FBrowser := CefBrowserHostCreateSync(@info, FHandler, '', @FSettings, nil);
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
    FBrowser.StopLoad;

  if FHandler <> nil then
    (FHandler as ICefClientHandler).Disconnect;
  FHandler := nil;
  FBrowser := nil;
  FFontOptions.Free;
  FOptions.Free;
  inherited;
end;

function TCustomChromium.GetClientHandler: ICefClient;
begin
  Result := TVCLClientHandler.Create(Self, False);
end;

procedure TCustomChromium.GetSettings(var settings: TCefBrowserSettings);
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
  if (FBrowser <> nil) and (FBrowserId <> 0) then
  begin
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

procedure TCustomChromium.ShowDevTools(inspectElementAt: PCefPoint);
var
  info: TCefWindowInfo;
begin
  if (FBrowser = nil) then Exit;

  FillChar(info, SizeOf(info), 0);
  info.style := WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE;
  info.parent_window := FBrowser.Host.WindowHandle;
  info.x := Integer(CW_USEDEFAULT);
  info.y := Integer(CW_USEDEFAULT);
  info.width := Integer(CW_USEDEFAULT);
  info.height := Integer(CW_USEDEFAULT);
  info.window_name := CefString('DevTools');

  FillChar(FSettings, SizeOf(FSettings), 0);
  FSettings.size := SizeOf(FSettings);
  FBrowser.Host.ShowDevTools(@info, TCefClientOwn.Create as ICefClient, @FSettings, inspectElementAt);
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
  Result := False;
  if Assigned(FOnClose) then
    FOnClose(Self, browser, Result);
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

function TCustomChromium.doOnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeBrowse) then
    FOnBeforeBrowse(Self, browser, frame, request, isRedirect, Result);
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

function TCustomChromium.doOnBeforePopup(const browser: ICefBrowser;
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

function TCustomChromium.doOnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := RV_CONTINUE;
  if Assigned(FOnBeforeResourceLoad) then
    FOnBeforeResourceLoad(Self, browser, frame, request, callback, Result);
end;

function TCustomChromium.doOnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean;
  const callback: ICefJsDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeUnloadDialog) then
    FOnBeforeUnloadDialog(Self, browser, messageText, isReload, callback, Result);
end;

procedure TCustomChromium.doOnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  if Assigned(FOnCancelGeolocationPermission) then
    FOnCancelGeolocationPermission(Self, browser, requestingUrl, requestId);
end;

function TCustomChromium.doOnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnCertificateError) then
    FOnCertificateError(Self, browser, certError, requestUrl, sslInfo, callback, Result);
end;

function TCustomChromium.doOnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, browser, message, source, line, Result);
end;

function TCustomChromium.doOnContextMenuCommand(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  commandId: Integer; eventFlags: TCefEventFlags): Boolean;
begin
  Result := False;
  if Assigned(FOnContextMenuCommand) then
    FOnContextMenuCommand(Self, browser, frame, params, commandId, eventFlags, Result);
end;

procedure TCustomChromium.doOnContextMenuDismissed(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnContextMenuDismissed) then
    FOnContextMenuDismissed(Self, browser, frame);
end;

procedure TCustomChromium.doOnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; cursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin

end;

procedure TCustomChromium.doOnDialogClosed(const browser: ICefBrowser);
begin
  if Assigned(FOnDialogClosed) then
    FOnDialogClosed(Self, browser);
end;

procedure TCustomChromium.doOnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if Assigned(FOnDownloadUpdated) then
    FOnDownloadUpdated(Self, browser, downloadItem, callback);
end;

function TCustomChromium.doOnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := False;
  if Assigned(FOnDragEnter) then
    FOnDragEnter(Self, browser, dragData, mask, Result);
end;

procedure TCustomChromium.doOnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin
  if Assigned(FOnDraggableRegionsChanged) then
    FOnDraggableRegionsChanged(Self, browser, regionsCount, regions);
end;

procedure TCustomChromium.doOnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin
  if Assigned(FOnFavIconUrlChange) then
    FOnFavIconUrlChange(Self, browser, iconUrls);
end;

function TCustomChromium.doOnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnFileDialog) then
    FOnFileDialog(Self, browser, mode, title, defaultFilePath, acceptFilters,
      selectedAcceptFilter, callback, Result);
end;

procedure TCustomChromium.doOnFindResult(const browser: ICefBrowser; identifier,
  count: Integer; const selectionRect: PCefRect; activeMatchOrdinal: Integer;
  finalUpdate: Boolean);
begin
  if Assigned(FOnFindResult) then
    FOnFindResult(Self, browser, identifier, count, selectionRect,
      activeMatchOrdinal, finalUpdate);
end;

procedure TCustomChromium.doOnFullScreenModeChange(const browser: ICefBrowser;
  fullscreen: Boolean);
begin
  if Assigned(FOnFullScreenModeChange) then
    FOnFullScreenModeChange(Self, browser, fullscreen);
end;

function TCustomChromium.doOnGetAuthCredentials(const browser: ICefBrowser;
  const frame: ICefFrame; isProxy: Boolean; const host: ustring; port: Integer;
  const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnGetAuthCredentials) then
    FOnGetAuthCredentials(Self, browser, frame, isProxy, host,
      port, realm, scheme, callback, Result);
end;

function TCustomChromium.doOnGetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  if Assigned(FOnGetResourceHandler) then
    FOnGetResourceHandler(Self, browser, frame, request, Result) else
    Result := nil;
end;

function TCustomChromium.doOnGetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

function TCustomChromium.doOnGetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := False;
end;

function TCustomChromium.doOnGetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
end;

function TCustomChromium.doOnGetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
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
  Result := False;
  if Assigned(FOnJsdialog) then
    FOnJsdialog(Self, browser, originUrl, acceptLang, dialogType,
      messageText, defaultPromptText, callback, suppressMessage, Result);
end;

function TCustomChromium.doOnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin
  Result := False;
  if Assigned(FOnKeyEvent) then
    FOnKeyEvent(Self, browser, event, osEvent, Result);
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

function TCustomChromium.doOnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  if Assigned(FOnOpenUrlFromTab) then
    FOnOpenUrlFromTab(Self, browser, frame, targetUrl, targetDisposition,
    userGesture, Result);
end;

procedure TCustomChromium.doOnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
begin

end;

procedure TCustomChromium.doOnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  if Assigned(FOnPluginCrashed) then
    FOnPluginCrashed(Self, browser, pluginPath);
end;

procedure TCustomChromium.doOnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin

end;

procedure TCustomChromium.doOnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin

end;

function TCustomChromium.doOnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnPreKeyEvent) then
    FOnPreKeyEvent(Self, browser, event, osEvent, isKeyboardShortcut, Result);
end;

function TCustomChromium.doOnProcessMessageReceived(const browser: ICefBrowser;
  sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  Result := False;
  if Assigned(FOnProcessMessageReceived) then
    FOnProcessMessageReceived(Self, browser, sourceProcess, message, Result);
end;

procedure TCustomChromium.doOnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  if Assigned(FOnProtocolExecution) then
    FOnProtocolExecution(Self, browser, url, allowOsExecution);
end;

function TCustomChromium.doOnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnQuotaRequest) then
    FOnQuotaRequest(Self, browser, originUrl, newSize, callback, Result);
end;

procedure TCustomChromium.doOnRenderProcessTerminated(const browser: ICefBrowser;
  status: TCefTerminationStatus);
begin
  if Assigned(FOnRenderProcessTerminated) then
    FOnRenderProcessTerminated(Self, browser, status);
end;

procedure TCustomChromium.doOnRenderViewReady(const browser: ICefBrowser);
begin
  if Assigned(FOnRenderViewReady) then
    FOnRenderViewReady(Self, browser);
end;

function TCustomChromium.doOnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnRequestGeolocationPermission) then
    FOnRequestGeolocationPermission(Self, browser, requestingUrl, requestId, callback, Result);
end;

procedure TCustomChromium.doOnResetDialogState(const browser: ICefBrowser);
begin
  if Assigned(FOnResetDialogState) then
    FOnResetDialogState(Self, browser);
end;

procedure TCustomChromium.doOnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin
  if Assigned(FOnResourceRedirect) then
    FOnResourceRedirect(Self, browser, frame, request, newUrl);
end;

function TCustomChromium.doOnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := False;
  if Assigned(FOnResourceResponse) then
    FOnResourceResponse(Self, browser, frame, request, response, Result);
end;

procedure TCustomChromium.doOnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double);
begin

end;

function TCustomChromium.doOnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := False;
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, browser, source, Result);
end;

function TCustomChromium.doOnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := False;
end;

procedure TCustomChromium.doOnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin
  if Assigned(FOnStatusMessage) then
    FOnStatusMessage(Self, browser, value);
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
  Result := False;
  if Assigned(FOnTooltip) then
    FOnTooltip(Self, browser, text, Result);
end;

procedure TCustomChromium.doOnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin

end;

function TCustomChromium.doOnRunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnRunModal) then
    FOnRunModal(Self, browser, Result);
end;

{ TCustomChromiumOSR }

constructor TCustomChromiumOSR.Create(AOwner: TComponent);
begin
  inherited;
  FTransparentPainting := False;
  FDefaultUrl := 'about:blank';

  if not (csDesigning in ComponentState) then
    FHandler := GetClientHandler;

  FOptions := TChromiumOptions.Create;
  FFontOptions := TChromiumFontOptions.Create;

  FDefaultEncoding := '';
  FBrowserId := 0;
  FBrowser := nil;
end;

procedure TCustomChromiumOSR.CreateBrowser;
var
  info: TCefWindowInfo;
begin
  if not (csDesigning in ComponentState) then
  begin
    FillChar(info, SizeOf(info), 0);
    info.windowless_rendering_enabled := Ord(True);
    info.transparent_painting_enabled := Ord(FTransparentPainting);
    FillChar(FSettings, SizeOf(TCefBrowserSettings), 0);
    FSettings.size := SizeOf(TCefBrowserSettings);
    GetSettings(FSettings);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    CefBrowserHostCreate(@info, FHandler, FDefaultUrl, @settings, nil);
{$ELSE}
    FBrowser := CefBrowserHostCreateSync(@info, FHandler, '', @FSettings, nil);
    FBrowserId := FBrowser.Identifier;
{$ENDIF}
  end;
end;

destructor TCustomChromiumOSR.Destroy;
begin
  FOnGetRootScreenRect := nil;
  FOnGetViewRect := nil;
  FOnGetScreenPoint := nil;
  FOnGetScreenInfo := nil;
  FOnPopupShow := nil;
  FOnPopupSize := nil;
  FOnPaint := nil;
  FOnCursorChange := nil;
  FOnStartDragging := nil;
  FOnUpdateDragCursor := nil;
  FOnScrollOffsetChanged := nil;

  if FBrowser <> nil then
  begin
    FBrowser.StopLoad;
    FBrowser.Host.CloseBrowser(False);
  end;

  if FHandler <> nil then
    (FHandler as ICefClientHandler).Disconnect;

  FHandler := nil;
  FBrowser := nil;
  FFontOptions.Free;
  FOptions.Free;
  inherited;
end;

function TCustomChromiumOSR.GetClientHandler: ICefClient;
begin
  Result := TVCLClientHandler.Create(Self, True);
end;

procedure TCustomChromiumOSR.GetSettings(var settings: TCefBrowserSettings);
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

procedure TCustomChromiumOSR.Load(const url: ustring);
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

procedure TCustomChromiumOSR.Loaded;
begin
  inherited;
  CreateBrowser;
  Load(FDefaultUrl);
end;

procedure TCustomChromiumOSR.ReCreateBrowser(const url: string);
begin
  if (FBrowser <> nil) and (FBrowserId <> 0) then
  begin
    FBrowserId := 0;
    FBrowser := nil;

    CreateBrowser;
    Load(url);
  end;
end;

function TCustomChromiumOSR.doOnClose(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnClose) then
    FOnClose(Self, browser, Result);
end;

procedure TCustomChromiumOSR.doOnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin
  if Assigned(FOnAddressChange) then
    FOnAddressChange(Self, browser, frame, url);
end;

procedure TCustomChromiumOSR.doOnAfterCreated(const browser: ICefBrowser);
begin
  if Assigned(FOnAfterCreated) then
    FOnAfterCreated(Self, browser);
end;

function TCustomChromiumOSR.doOnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeBrowse) then
    FOnBeforeBrowse(Self, browser, frame, request, isRedirect, Result);
end;

procedure TCustomChromiumOSR.doOnBeforeClose(const browser: ICefBrowser);
begin
  if Assigned(FOnBeforeClose) then
    FOnBeforeClose(Self, browser);
end;

procedure TCustomChromiumOSR.doOnBeforeContextMenu(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  const model: ICefMenuModel);
begin
  if Assigned(FOnBeforeContextMenu) then
    FOnBeforeContextMenu(Self, browser, frame, params, model);
end;

procedure TCustomChromiumOSR.doOnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin
  if Assigned(FOnBeforeDownload) then
    FOnBeforeDownload(Self, browser, downloadItem, suggestedName, callback);
end;

function TCustomChromiumOSR.doOnBeforePopup(const browser: ICefBrowser;
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

function TCustomChromiumOSR.doOnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := RV_CONTINUE;
  if Assigned(FOnBeforeResourceLoad) then
    FOnBeforeResourceLoad(Self, browser, frame, request, callback, Result);
end;

function TCustomChromiumOSR.doOnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean;
  const callback: ICefJsDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnBeforeUnloadDialog) then
    FOnBeforeUnloadDialog(Self, browser, messageText, isReload, callback, Result);
end;

procedure TCustomChromiumOSR.doOnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  if Assigned(FOnCancelGeolocationPermission) then
    FOnCancelGeolocationPermission(Self, browser, requestingUrl, requestId);
end;

function TCustomChromiumOSR.doOnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnCertificateError) then
    FOnCertificateError(Self, browser, certError, requestUrl, sslInfo, callback, Result);
end;

function TCustomChromiumOSR.doOnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnConsoleMessage) then
    FOnConsoleMessage(Self, browser, message, source, line, Result);
end;

function TCustomChromiumOSR.doOnContextMenuCommand(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  commandId: Integer; eventFlags: TCefEventFlags): Boolean;
begin
  Result := False;
  if Assigned(FOnContextMenuCommand) then
    FOnContextMenuCommand(Self, browser, frame, params, commandId, eventFlags, Result);
end;

procedure TCustomChromiumOSR.doOnContextMenuDismissed(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnContextMenuDismissed) then
    FOnContextMenuDismissed(Self, browser, frame);
end;

procedure TCustomChromiumOSR.doOnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; cursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo);
begin
  if Assigned(FOnCursorChange) then
    FOnCursorChange(Self, browser, cursor, cursorType, customCursorInfo);
end;

procedure TCustomChromiumOSR.doOnDialogClosed(const browser: ICefBrowser);
begin
  if Assigned(FOnDialogClosed) then
    FOnDialogClosed(Self, browser);
end;

procedure TCustomChromiumOSR.doOnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin
  if Assigned(FOnDownloadUpdated) then
    FOnDownloadUpdated(Self, browser, downloadItem, callback);
end;

function TCustomChromiumOSR.doOnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := False;
  if Assigned(FOnDragEnter) then
    FOnDragEnter(Self, browser, dragData, mask, Result);
end;

procedure TCustomChromiumOSR.doOnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin
  if Assigned(FOnDraggableRegionsChanged) then
    FOnDraggableRegionsChanged(Self, browser, regionsCount, regions);
end;

procedure TCustomChromiumOSR.doOnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin
  if Assigned(FOnFavIconUrlChange) then
    FOnFavIconUrlChange(Self, browser, iconUrls);
end;

function TCustomChromiumOSR.doOnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnFileDialog) then
    FOnFileDialog(Self, browser, mode, title, defaultFilePath, acceptFilters,
      selectedAcceptFilter, callback, Result);
end;

procedure TCustomChromiumOSR.doOnFindResult(const browser: ICefBrowser;
  identifier, count: Integer; const selectionRect: PCefRect;
  activeMatchOrdinal: Integer; finalUpdate: Boolean);
begin
  if Assigned(FOnFindResult) then
    FOnFindResult(Self, browser, identifier, count, selectionRect,
      activeMatchOrdinal, finalUpdate);
end;

procedure TCustomChromiumOSR.doOnFullScreenModeChange(
  const browser: ICefBrowser; fullscreen: Boolean);
begin
  if Assigned(FOnFullScreenModeChange) then
    FOnFullScreenModeChange(Self, browser, fullscreen);
end;

function TCustomChromiumOSR.doOnGetAuthCredentials(const browser: ICefBrowser;
  const frame: ICefFrame; isProxy: Boolean; const host: ustring; port: Integer;
  const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnGetAuthCredentials) then
    FOnGetAuthCredentials(Self, browser, frame, isProxy, host,
      port, realm, scheme, callback, Result);
end;

function TCustomChromiumOSR.doOnGetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  if Assigned(FOnGetResourceHandler) then
    FOnGetResourceHandler(Self, browser, frame, request, Result) else
    Result := nil;
end;

function TCustomChromiumOSR.doOnGetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
  if Assigned(FOnGetRootScreenRect) then
    FOnGetRootScreenRect(Self, browser, rect, Result);
end;

function TCustomChromiumOSR.doOnGetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := False;
  if Assigned(FOnGetScreenInfo) then
    FOnGetScreenInfo(Self, browser, screenInfo, Result);
end;

function TCustomChromiumOSR.doOnGetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
  if Assigned(FOnGetScreenPoint) then
    FOnGetScreenPoint(Self, browser, viewX, viewY, screenX, screenY, Result);
end;

function TCustomChromiumOSR.doOnGetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
  if Assigned(FOnGetViewRect) then
    FOnGetViewRect(Self, browser, rect, Result);
end;

procedure TCustomChromiumOSR.doOnGotFocus(const browser: ICefBrowser);
begin
  if Assigned(FOnGotFocus) then
    FOnGotFocus(Self, browser)
end;

function TCustomChromiumOSR.doOnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnJsdialog) then
    FOnJsdialog(Self, browser, originUrl, acceptLang, dialogType,
      messageText, defaultPromptText, callback, suppressMessage, Result);
end;

function TCustomChromiumOSR.doOnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin
  Result := False;
  if Assigned(FOnKeyEvent) then
    FOnKeyEvent(Self, browser, event, osEvent, Result);
end;

procedure TCustomChromiumOSR.doOnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if Assigned(FOnLoadEnd) then
    FOnLoadEnd(Self, browser, frame, httpStatusCode);
end;

procedure TCustomChromiumOSR.doOnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText,
  failedUrl: ustring);
begin
  if Assigned(FOnLoadError) then
    FOnLoadError(Self, browser, frame, errorCode, errorText, failedUrl);
end;

procedure TCustomChromiumOSR.doOnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin
  if Assigned(FOnLoadingStateChange) then
    FOnLoadingStateChange(Self, browser, isLoading, canGoBack, canGoForward);
end;

procedure TCustomChromiumOSR.doOnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  if Assigned(FOnLoadStart) then
    FOnLoadStart(Self, browser, frame);
end;

function TCustomChromiumOSR.doOnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  if Assigned(FOnOpenUrlFromTab) then
    FOnOpenUrlFromTab(Self, browser, frame, targetUrl, targetDisposition,
    userGesture, Result);
end;

procedure TCustomChromiumOSR.doOnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self, browser, kind, dirtyRectsCount, dirtyRects, buffer, width, height);
end;

procedure TCustomChromiumOSR.doOnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  if Assigned(FOnPluginCrashed) then
    FOnPluginCrashed(Self, browser, pluginPath);
end;

procedure TCustomChromiumOSR.doOnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin
  if Assigned(FOnPopupShow) then
    FOnPopupShow(Self, browser, show);
end;

procedure TCustomChromiumOSR.doOnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin
  if Assigned(FOnPopupSize) then
    FOnPopupSize(Self, browser, rect);
end;

function TCustomChromiumOSR.doOnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := False;
  if Assigned(FOnPreKeyEvent) then
    FOnPreKeyEvent(Self, browser, event, osEvent, isKeyboardShortcut, Result);
end;

function TCustomChromiumOSR.doOnProcessMessageReceived(const browser: ICefBrowser;
  sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  Result := False;
  if Assigned(FOnProcessMessageReceived) then
    FOnProcessMessageReceived(Self, browser, sourceProcess, message, Result);
end;

procedure TCustomChromiumOSR.doOnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  if Assigned(FOnProtocolExecution) then
    FOnProtocolExecution(Self, browser, url, allowOsExecution);
end;

function TCustomChromiumOSR.doOnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnQuotaRequest) then
    FOnQuotaRequest(Self, browser, originUrl, newSize, callback, Result);
end;

procedure TCustomChromiumOSR.doOnRenderProcessTerminated(const browser: ICefBrowser;
  status: TCefTerminationStatus);
begin
  if Assigned(FOnRenderProcessTerminated) then
    FOnRenderProcessTerminated(Self, browser, status);
end;

procedure TCustomChromiumOSR.doOnRenderViewReady(const browser: ICefBrowser);
begin
  if Assigned(FOnRenderViewReady) then
    FOnRenderViewReady(Self, browser);
end;

function TCustomChromiumOSR.doOnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := False;
  if Assigned(FOnRequestGeolocationPermission) then
    FOnRequestGeolocationPermission(Self, browser, requestingUrl, requestId, callback, Result);
end;

procedure TCustomChromiumOSR.doOnResetDialogState(const browser: ICefBrowser);
begin
  if Assigned(FOnResetDialogState) then
    FOnResetDialogState(Self, browser);
end;

procedure TCustomChromiumOSR.doOnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin
  if Assigned(FOnResourceRedirect) then
    FOnResourceRedirect(Self, browser, frame, request, newUrl);
end;

function TCustomChromiumOSR.doOnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := False;
  if Assigned(FOnResourceResponse) then
    FOnResourceResponse(Self, browser, frame, request, response, Result);
end;

procedure TCustomChromiumOSR.doOnScrollOffsetChanged(
  const browser: ICefBrowser; x, y: Double);
begin
  if Assigned(FOnScrollOffsetChanged) then
    FOnScrollOffsetChanged(Self, browser, x, y);
end;

function TCustomChromiumOSR.doOnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := False;
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self, browser, source, Result);
end;

function TCustomChromiumOSR.doOnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnStartDragging) then
    FOnStartDragging(Self, browser, dragData, allowedOps, x, y, Result);
end;

procedure TCustomChromiumOSR.doOnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin
  if Assigned(FOnStatusMessage) then
    FOnStatusMessage(Self, browser, value);
end;

procedure TCustomChromiumOSR.doOnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin
  if Assigned(FOnTakeFocus) then
    FOnTakeFocus(Self, browser, next);
end;

procedure TCustomChromiumOSR.doOnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin
  if Assigned(FOnTitleChange) then
    FOnTitleChange(Self, browser, title);
end;

function TCustomChromiumOSR.doOnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := False;
  if Assigned(FOnTooltip) then
    FOnTooltip(Self, browser, text, Result);
end;

procedure TCustomChromiumOSR.doOnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin
  if Assigned(FOnUpdateDragCursor) then
    FOnUpdateDragCursor(Self, browser, operation);
end;

function TCustomChromiumOSR.doOnRunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
  if Assigned(FOnRunModal) then
    FOnRunModal(Self, browser, Result);
end;


{ TChromiumDevTools }

procedure TChromiumDevTools.CloseDevTools(const browser: ICefBrowser);
begin
  if browser <> nil then
  begin
    windows.SetParent(GetWindow(Handle, GW_CHILD), 0);
    browser.Host.CloseDevTools;
  end;
end;

procedure TChromiumDevTools.Resize;
var
  rect: TRect;
  hdwp: THandle;
  hndl: THandle;
begin
  inherited;
  hndl:= GetWindow(Handle, GW_CHILD);
  if hndl = 0 then Exit;

  rect:= GetClientRect;
  hdwp := BeginDeferWindowPos(1);
  try
    hdwp := DeferWindowPos(hdwp, hndl, 0,
      rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top,
      SWP_NOZORDER);
  finally
    EndDeferWindowPos(hdwp);
  end;
end;

procedure TChromiumDevTools.ShowDevTools(const browser: ICefBrowser;
  inspectElementAt: PCefPoint);
var
  info: TCefWindowInfo;
  rect: TRect;
begin
  if browser = nil then Exit;

  FillChar(info, SizeOf(info), 0);

  info.parent_window := Handle;
  info.style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_TABSTOP;
  Rect := GetClientRect;
  info.x := rect.left;
  info.y := rect.top;
  info.Width := rect.right - rect.left;
  info.Height := rect.bottom - rect.top;
  info.window_name := CefString('DevTools');

  FillChar(FSettings, SizeOf(FSettings), 0);
  FSettings.size := SizeOf(FSettings);

  Browser.Host.ShowDevTools(@info, TCefClientOwn.Create as ICefClient, @FSettings, inspectElementAt);
end;

procedure TChromiumDevTools.WndProc(var Message: TMessage);
var
  hndl: THandle;
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        hndl := GetWindow(Handle, GW_CHILD);
        if hndl <> 0 then
          PostMessage(hndl, WM_SETFOCUS, Message.WParam, 0);
        inherited WndProc(Message);
      end;
    WM_ERASEBKGND:
      begin
        hndl := GetWindow(Handle, GW_CHILD);
        if (csDesigning in ComponentState) or (hndl = 0) then
          inherited WndProc(Message);
      end;
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

end.
