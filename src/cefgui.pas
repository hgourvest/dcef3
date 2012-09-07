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

  TOnLoadStart = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame) of object;
  TOnLoadEnd = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer) of object;
  TOnLoadError = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
    const errorText, failedUrl: ustring) of object;
  TOnRenderProcessTerminated = procedure(Sender: TObject; const browser: ICefBrowser; status: TCefTerminationStatus) of object;
  TOnPluginCrashed = procedure(Sender: TObject; const browser: ICefBrowser; const pluginPath: ustring) of object;

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

  TOnLoadingStateChange = procedure(Sender: TObject; const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean) of object;
  TOnAddressChange = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const url: ustring) of object;
  TOnTitleChange = procedure(Sender: TObject; const browser: ICefBrowser; const title: ustring) of object;
  TOnTooltip = procedure(Sender: TObject; const browser: ICefBrowser; var text: ustring; out Result: Boolean) of object;
  TOnStatusMessage = procedure(Sender: TObject; const browser: ICefBrowser; const value: ustring; kind: TCefHandlerStatusType) of object;
  TOnConsoleMessage = procedure(Sender: TObject; const browser: ICefBrowser; const message, source: ustring; line: Integer; out Result: Boolean) of object;

  TOnBeforeDownload = procedure(Sender: TObject; const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
    const suggestedName: ustring; const callback: ICefBeforeDownloadCallback) of object;
  TOnDownloadUpdated = procedure(Sender: TObject; const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback) of object;

  TOnRequestGeolocationPermission = procedure(Sender: TObject; const browser: ICefBrowser;
    const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback) of object;
  TOnCancelGeolocationPermission = procedure(Sender: TObject; const browser: ICefBrowser;
    const requestingUrl: ustring; requestId: Integer) of object;

  TOnJsdialog = procedure(Sender: TObject; const browser: ICefBrowser; const originUrl, acceptLang: ustring;
    dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
    callback: ICefJsDialogCallback; out suppressMessage: Boolean; out Result: Boolean) of object;
  TOnBeforeUnloadDialog = procedure(Sender: TObject; const browser: ICefBrowser;
    const messageText: ustring; isReload: Boolean;
    const callback: ICefJsDialogCallback; out Result: Boolean) of object;
  TOnResetDialogState = procedure(Sender: TObject; const browser: ICefBrowser) of object;

  TOnBeforePopup = procedure(Sender: TObject; const parentBrowser: ICefBrowser;
     var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
     var url: ustring; var client: ICefClient;
     var settings: TCefBrowserSettings; out Result: Boolean) of object;
  TOnAfterCreated = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnBeforeClose = procedure(Sender: TObject; const browser: ICefBrowser) of object;
  TOnRunModal = procedure(Sender: TObject; const browser: ICefBrowser; out Result: Boolean) of object;
  TOnClose = procedure(Sender: TObject; const browser: ICefBrowser; out Result: Boolean) of object;

  TOnBeforeResourceLoad = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; out Result: Boolean) of object;
  TOnGetResourceHandler = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const request: ICefRequest; out Result: ICefResourceHandler) of object;
  TOnResourceRedirect = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    const oldUrl: ustring; var newUrl: ustring) of object;
  TOnGetAuthCredentials = procedure(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
    isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
    const callback: ICefAuthCallback; out Result: Boolean) of object;
  TOnGetCookieManager = procedure(Sender: TObject; const browser: ICefBrowser; const mainUrl: ustring; out Result: ICefCookieManager) of object;
  TOnProtocolExecution = procedure(Sender: TObject; const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean) of object;

  TChromiumOptions = class(TPersistent)
  private
    FEncodingDetectorEnabled: Boolean;
    FJavascriptDisabled: Boolean;
    FJavascriptOpenWindowsDisallowed: Boolean;
    FJavascriptCloseWindowsDisallowed: Boolean;
    FJavascriptAccessClipboardDisallowed: Boolean;
    FDomPasteDisabled: Boolean;
    FCaretBrowsingEnabled: Boolean;
    FJavaDisabled: Boolean;
    FPluginsDisabled: Boolean;
    FUniversalAccessFromFileUrlsAllowed: Boolean;
    FFileAccessFromFileUrlsAllowed: Boolean;
    FWebSecurityDisabled: Boolean;
    FXssAuditorEnabled: Boolean;
    FImageLoadDisabled: Boolean;
    FShrinkStandaloneImagesToFit: Boolean;
    FSiteSpecificQuirksDisabled: Boolean;
    FTextAreaResizeDisabled: Boolean;
    FPageCacheDisabled: Boolean;
    FTabToLinksDisabled: Boolean;
    FHyperlinkAuditingDisabled: Boolean;
    FUserStyleSheetEnabled: Boolean;
    FAuthorAndUserStylesDisabled: Boolean;
    FLocalStorageDisabled: Boolean;
    FDatabasesDisabled: Boolean;
    FApplicationCacheDisabled: Boolean;
    FWebglDisabled: Boolean;
    FAcceleratedCompositingDisabled: Boolean;
    FAcceleratedLayersDisabled: Boolean;
    FAccelerated2dCanvasDisabled: Boolean;
    FAcceleratedPaintingEnabled: Boolean;
    FAcceleratedFiltersEnabled: Boolean;
    FAcceleratedPluginsDisabled: Boolean;
    FDeveloperToolsDisabled: Boolean;
    FFullscreenEnabled: Boolean;
  published
    property EncodingDetectorEnabled: Boolean read FEncodingDetectorEnabled write FEncodingDetectorEnabled default False;
    property JavascriptDisabled: Boolean read FJavascriptDisabled write FJavascriptDisabled default False;
    property JavascriptOpenWindowsDisallowed: Boolean read FJavascriptOpenWindowsDisallowed write FJavascriptOpenWindowsDisallowed default False;
    property JavascriptCloseWindowsDisallowed: Boolean read FJavascriptCloseWindowsDisallowed write FJavascriptCloseWindowsDisallowed default False;
    property JavascriptAccessClipboardDisallowed: Boolean read FJavascriptAccessClipboardDisallowed write FJavascriptAccessClipboardDisallowed default False;
    property DomPasteDisabled: Boolean read FDomPasteDisabled write FDomPasteDisabled default False;
    property CaretBrowsingEnabled: Boolean read FCaretBrowsingEnabled write FCaretBrowsingEnabled default False;
    property JavaDisabled: Boolean read FJavaDisabled write FJavaDisabled default False;
    property PluginsDisabled: Boolean read FPluginsDisabled write FPluginsDisabled default False;
    property UniversalAccessFromFileUrlsAllowed: Boolean read FUniversalAccessFromFileUrlsAllowed write FUniversalAccessFromFileUrlsAllowed default False;
    property FileAccessFromFileUrlsAllowed: Boolean read FFileAccessFromFileUrlsAllowed write FFileAccessFromFileUrlsAllowed default False;
    property WebSecurityDisabled: Boolean read FWebSecurityDisabled write FWebSecurityDisabled default False;
    property XssAuditorEnabled: Boolean read FXssAuditorEnabled write FXssAuditorEnabled default False;
    property ImageLoadDisabled: Boolean read FImageLoadDisabled write FImageLoadDisabled default False;
    property ShrinkStandaloneImagesToFit: Boolean read FShrinkStandaloneImagesToFit write FShrinkStandaloneImagesToFit default False;
    property SiteSpecificQuirksDisabled: Boolean read FSiteSpecificQuirksDisabled write FSiteSpecificQuirksDisabled default False;
    property TextAreaResizeDisabled: Boolean read FTextAreaResizeDisabled write FTextAreaResizeDisabled default False;
    property PageCacheDisabled: Boolean read FPageCacheDisabled write FPageCacheDisabled default False;
    property TabToLinksDisabled: Boolean read FTabToLinksDisabled write FTabToLinksDisabled default False;
    property HyperlinkAuditingDisabled: Boolean read FHyperlinkAuditingDisabled write FHyperlinkAuditingDisabled default False;
    property UserStyleSheetEnabled: Boolean read FUserStyleSheetEnabled write FUserStyleSheetEnabled default False;
    property AuthorAndUserStylesDisabled: Boolean read FAuthorAndUserStylesDisabled write FAuthorAndUserStylesDisabled default False;
    property LocalStorageDisabled: Boolean read FLocalStorageDisabled write FLocalStorageDisabled default False;
    property DatabasesDisabled: Boolean read FDatabasesDisabled write FDatabasesDisabled default False;
    property ApplicationCacheDisabled: Boolean read FApplicationCacheDisabled write FApplicationCacheDisabled default False;
    property WebglDisabled: Boolean read FWebglDisabled write FWebglDisabled default False;
    property AcceleratedCompositingDisabled: Boolean read FAcceleratedCompositingDisabled write FAcceleratedCompositingDisabled;
    property AcceleratedLayersDisabled: Boolean read FAcceleratedLayersDisabled write FAcceleratedLayersDisabled default False;
    property Accelerated2dCanvasDisabled: Boolean read FAccelerated2dCanvasDisabled write FAccelerated2dCanvasDisabled default False;
    property AcceleratedPaintingEnabled: Boolean read FAcceleratedPaintingEnabled write FAcceleratedPaintingEnabled;
    property AcceleratedFiltersEnabled: Boolean read FAcceleratedFiltersEnabled write FAcceleratedFiltersEnabled;
    property AcceleratedPluginsDisabled: Boolean read FAcceleratedPluginsDisabled write FAcceleratedPluginsDisabled;
    property DeveloperToolsDisabled: Boolean read FDeveloperToolsDisabled write FDeveloperToolsDisabled default False;
    property FullscreenEnabled: Boolean read FFullscreenEnabled write FFullscreenEnabled default False;
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
    FRemoteFontsDisabled: Boolean;
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
    property RemoteFontsDisabled: Boolean read FRemoteFontsDisabled write FRemoteFontsDisabled default False;
  end;

  IChromiumEvents = interface
  ['{0C139DB1-0349-4D7F-8155-76FEA6A0126D}']
    procedure GetSettings(var settings: TCefBrowserSettings);
    function doOnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;

    procedure doOnLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
    procedure doOnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure doOnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring);
    procedure doOnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus);
    procedure doOnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring);

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

    procedure doOnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
    procedure doOnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure doOnTitleChange(const browser: ICefBrowser; const title: ustring);
    function doOnTooltip(const browser: ICefBrowser; var text: ustring): Boolean;
    procedure doOnStatusMessage(const browser: ICefBrowser; const value: ustring; kind: TCefHandlerStatusType);
    function doOnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean;

    procedure doOnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback);
    procedure doOnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer);

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

    function doOnBeforePopup(const parentBrowser: ICefBrowser;
       var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
       var url: ustring; var client: ICefClient;
       var settings: TCefBrowserSettings): Boolean;
    procedure doOnAfterCreated(const browser: ICefBrowser);
    procedure doOnBeforeClose(const browser: ICefBrowser);
    function doOnRunModal(const browser: ICefBrowser): Boolean;
    function doOnClose(const browser: ICefBrowser): Boolean;

    function doOnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): Boolean;
    function doOnGetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler;
    procedure doOnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const oldUrl: ustring; var newUrl: ustring);
    function doOnGetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean;
    function doOnGetCookieManager(const browser: ICefBrowser; const mainUrl: ustring): ICefCookieManager;
    procedure doOnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean);
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
    FKeyboardHandler: ICefKeyboardHandler;
    FDisplayHandler: ICefDisplayHandler;
    FDownloadHandler: ICefDownloadHandler;
    FGeolocationHandler: ICefGeolocationHandler;
    FJsDialogHandler: ICefJsDialogHandler;
    FLifeSpanHandler: ICefLifeSpanHandler;
    FRequestHandler: ICefRequestHandler;
  protected
    function GetContextMenuHandler: ICefContextMenuHandler; override;
    function GetDisplayHandler: ICefDisplayHandler; override;
    function GetDownloadHandler: ICefDownloadHandler; override;
    function GetFocusHandler: ICefFocusHandler; override;
    function GetGeolocationHandler: ICefGeolocationHandler; override;
    function GetJsdialogHandler: ICefJsdialogHandler; override;
    function GetKeyboardHandler: ICefKeyboardHandler; override;
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
    function GetLoadHandler: ICefLoadHandler; override;
    function GetRequestHandler: ICefRequestHandler; override;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; override;
    procedure Disconnect;
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomClientHandlerClass = class of TCustomClientHandler;

  TCustomLoadHandler = class(TCefLoadHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); override;
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); override;
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); override;
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); override;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); override;
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
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean); override;
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring); override;
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring); override;
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; override;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring; kind: TCefHandlerStatusType); override;
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
    procedure OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback); override;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer); override;
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
  public
    constructor Create(const events: IChromiumEvents); reintroduce; virtual;
  end;

  TCustomLifeSpanHandler = class(TCefLifeSpanHandlerOwn)
  private
    FEvent: IChromiumEvents;
  protected
    function OnBeforePopup(const parentBrowser: ICefBrowser;
       var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
       var url: ustring; var client: ICefClient;
       var settings: TCefBrowserSettings): Boolean; override;
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
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): Boolean; override;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; override;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const oldUrl: ustring; var newUrl: ustring); override;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; override;
    function GetCookieManager(const browser: ICefBrowser; const mainUrl: ustring): ICefCookieManager; override;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean); override;
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
  FRemoteFontsDisabled := False;
  FFixedFontFamily := '';
  FMinimumFontSize := 0;
end;

{ TCefCustomHandler }

constructor TCustomClientHandler.Create(const events: IChromiumEvents);
begin
  inherited Create;
  FEvents := events;
  FLoadHandler := TCustomLoadHandler.Create(events);
  FFocusHandler := TCustomFocusHandler.Create(events);
  FContextMenuHandler := TCustomContextMenuHandler.Create(events);
  FKeyboardHandler := TCustomKeyboardHandler.Create(events);
  FDisplayHandler := TCustomDisplayHandler.Create(events);
  FDownloadHandler := TCustomDownloadHandler.Create(events);
  FGeolocationHandler := TCustomGeolocationHandler.Create(events);
  FJsDialogHandler := TCustomJsDialogHandler.Create(events);
  FLifeSpanHandler := TCustomLifeSpanHandler.Create(events);
  FRequestHandler := TCustomRequestHandler.Create(events);
end;

procedure TCustomClientHandler.Disconnect;
begin
  FEvents := nil;
  FLoadHandler := nil;
  FFocusHandler := nil;
  FContextMenuHandler := nil;
  FKeyboardHandler := nil;
  FDisplayHandler := nil;
  FDownloadHandler := nil;
  FGeolocationHandler := nil;
  FJsDialogHandler := nil;
  FLifeSpanHandler := nil;
  FRequestHandler := nil;
end;

function TCustomClientHandler.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := FContextMenuHandler;
end;

function TCustomClientHandler.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := FDisplayHandler;
end;

function TCustomClientHandler.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := FDownloadHandler;
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

function TCustomClientHandler.GetRequestHandler: ICefRequestHandler;
begin
  Result := FRequestHandler;
end;

function TCustomClientHandler.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  Result := FEvents.doOnProcessMessageReceived(browser, sourceProcess, message);
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

procedure TCustomLoadHandler.OnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin
  FEvent.doOnLoadStart(browser, frame);
end;

procedure TCustomLoadHandler.OnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin
  FEvent.doOnPluginCrashed(browser, pluginPath);
end;

procedure TCustomLoadHandler.OnRenderProcessTerminated(
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin
  FEvent.doOnRenderProcessTerminated(browser, status);
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

procedure TCustomDisplayHandler.OnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin
  FEvent.doOnLoadingStateChange(browser, isLoading, canGoBack, canGoForward);
end;

procedure TCustomDisplayHandler.OnStatusMessage(const browser: ICefBrowser;
  const value: ustring; kind: TCefHandlerStatusType);
begin
  FEvent.doOnStatusMessage(browser, value, kind);
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
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin
  FEvent.doOnCancelGeolocationPermission(browser, requestingUrl, requestId);
end;

procedure TCustomGeolocationHandler.OnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback);
begin
  FEvent.doOnRequestGeolocationPermission(browser, requestingUrl, requestId, callback);
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

function TCustomLifeSpanHandler.OnBeforePopup(const parentBrowser: ICefBrowser;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var url: ustring; var client: ICefClient;
  var settings: TCefBrowserSettings): Boolean;
begin
  Result := FEvent.doOnBeforePopup(parentBrowser, popupFeatures, windowInfo, url, client, settings);
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

function TCustomRequestHandler.GetCookieManager(const browser: ICefBrowser;
  const mainUrl: ustring): ICefCookieManager;
begin
  Result := FEvent.doOnGetCookieManager(browser, mainUrl);
end;

function TCustomRequestHandler.GetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  Result := FEvent.doOnGetResourceHandler(browser, frame, request);
end;

function TCustomRequestHandler.OnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): Boolean;
begin
  Result := FEvent.doOnBeforeResourceLoad(browser, frame, request);
end;

procedure TCustomRequestHandler.OnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin
  FEvent.doOnProtocolExecution(browser, url, allowOsExecution);
end;

procedure TCustomRequestHandler.OnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const oldUrl: ustring; var newUrl: ustring);
begin
  FEvent.doOnResourceRedirect(browser, frame, oldUrl, newUrl);
end;

end.
