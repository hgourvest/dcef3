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
 * Repository : http://code.google.ctom/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}
unit ceflib;
{$IFNDEF CPUX64}
  {$ALIGN ON}
  {$MINENUMSIZE 4}
{$ENDIF}
{$I cef.inc}

interface
uses
{$IFDEF DELPHI14_UP}
  Rtti, TypInfo, Variants, Generics.Collections,
{$ENDIF}
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  Messages,
{$ENDIF}
  SysUtils, Classes, Math, SyncObjs
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF}
{$IFNDEF FPC}
{$ENDIF}
  ;

type
{$IFDEF UNICODE}
  ustring = type string;
  rbstring = type RawByteString;
{$ELSE}
  {$IFDEF FPC}
    {$if declared(unicodestring)}
      ustring = type unicodestring;
    {$else}
      ustring = type WideString;
    {$ifend}
  {$ELSE}
    ustring = type WideString;
  {$ENDIF}
  rbstring = type AnsiString;
{$ENDIF}

{$if not defined(UInt64)}
  UInt64 = Int64;
{$ifend}

{$ifndef DELPHI16_UP}
  NativeUInt = Cardinal;
  PNativeUInt = ^NativeUInt;
  NativeInt = Integer;
{$endif}

  TCefWindowHandle = {$IFDEF MACOS}Pointer{$ELSE}HWND{$ENDIF};
  TCefCursorHandle = {$IFDEF MACOS}Pointer{$ELSE}HCURSOR{$ENDIF};
  TCefEventHandle  = {$IFDEF MACOS}Pointer{$ELSE}PMsg{$ENDIF};
  TCefTextInputContext = Pointer;
  TCefPlatformThreadId = DWORD;
  TCefPlatformThreadHandle = DWORD;

const
  kNullCursorHandle = 0;
  kNullEventHandle = 0;
  kNullWindowHandle = 0;

type
  // CEF provides functions for converting between UTF-8, -16 and -32 strings.
  // CEF string types are safe for reading from multiple threads but not for
  // modification. It is the user's responsibility to provide synchronization if
  // modifying CEF strings from multiple threads.

  // CEF character type definitions. wchat_t is 2 bytes on Windows and 4 bytes on
  // most other platforms.

  Char16 = WideChar;
  PChar16 = PWideChar;

  // 32-bit ARGB color value, not premultiplied. The color components are always
  // in a known order. Equivalent to the SkColor type.

  PCefColor = ^TCefColor;
  TCefColor = Cardinal;

  // Return the alpha byte from a cef_color_t value.
  function CefColorGetA(color: TCefColor): Byte;//      (((color) >> 24) & 0xFF)
  // Return the red byte from a cef_color_t value.
  function CefColorGetR(color: TCefColor): byte; //      (((color) >> 16) & 0xFF)
  // Return the green byte from a cef_color_t value.
  function CefColorGetG(color: TCefColor): Byte;//      (((color) >>  8) & 0xFF)
  // Return the blue byte from a cef_color_t value.
  function CefColorGetB(color: TCefColor): Byte;//      (((color) >>  0) & 0xFF)

  // Return an cef_color_t value with the specified byte component values.
  function CefColorSetARGB(a, r, g, b: Byte): TCefColor;
//      static_cast<cef_color_t>( \
//          (static_cast<unsigned>(a) << 24) | \
//          (static_cast<unsigned>(r) << 16) | \
//          (static_cast<unsigned>(g) << 8) | \
//          (static_cast<unsigned>(b) << 0))

  // Return an int64 value with the specified low and high int32 component values.
  function CefInt64Set(int32_low, int32_high: Integer): Int64;
//      static_cast<int64>((static_cast<uint32>(int32_low)) | \
//          (static_cast<int64>(static_cast<int32>(int32_high))) << 32)

  // Return the low int32 value from an int64 value.
  function CefInt64GetLow(const int64_val: Int64): Integer; // static_cast<int32>(int64_val)
  // Return the high int32 value from an int64 value.
  function CefInt64GetHigh(const int64_val: Int64): Integer;
  //    static_cast<int32>((static_cast<int64>(int64_val) >> 32) & 0xFFFFFFFFL)

type
  // CEF string type definitions. Whomever allocates |str| is responsible for
  // providing an appropriate |dtor| implementation that will free the string in
  // the same memory space. When reusing an existing string structure make sure
  // to call |dtor| for the old value before assigning new |str| and |dtor|
  // values. Static strings will have a NULL |dtor| value. Using the below
  // functions if you want this managed for you.

  PCefStringWide = ^TCefStringWide;
  TCefStringWide = record
    str: PWideChar;
    length: NativeUInt;
    dtor: procedure(str: PWideChar); stdcall;
  end;

  PCefStringUtf8 = ^TCefStringUtf8;
  TCefStringUtf8 = record
    str: PAnsiChar;
    length: NativeUInt;
    dtor: procedure(str: PAnsiChar); stdcall;
  end;

  PCefStringUtf16 = ^TCefStringUtf16;
  TCefStringUtf16 = record
    str: PChar16;
    length: NativeUInt;
    dtor: procedure(str: PChar16); stdcall;
  end;


  // It is sometimes necessary for the system to allocate string structures with
  // the expectation that the user will free them. The userfree types act as a
  // hint that the user is responsible for freeing the structure.

  PCefStringUserFreeWide = ^TCefStringUserFreeWide;
  TCefStringUserFreeWide = type TCefStringWide;

  PCefStringUserFreeUtf8 = ^TCefStringUserFreeUtf8;
  TCefStringUserFreeUtf8 = type TCefStringUtf8;

  PCefStringUserFreeUtf16 = ^TCefStringUserFreeUtf16;
  TCefStringUserFreeUtf16 = type TCefStringUtf16;

{$IFDEF CEF_STRING_TYPE_UTF8}
  TCefChar = AnsiChar;
  PCefChar = PAnsiChar;
  TCefStringUserFree = TCefStringUserFreeUtf8;
  PCefStringUserFree = PCefStringUserFreeUtf8;
  TCefString = TCefStringUtf8;
  PCefString = PCefStringUtf8;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_UTF16}
  TCefChar = Char16;
  PCefChar = PChar16;
  TCefStringUserFree = TCefStringUserFreeUtf16;
  PCefStringUserFree = PCefStringUserFreeUtf16;
  TCefString = TCefStringUtf16;
  PCefString = PCefStringUtf16;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_WIDE}
  TCefChar = WideChar;
  PCefChar = PWideChar;
  TCefStringUserFree = TCefStringUserFreeWide;
  PCefStringUserFree = PCefStringUserFreeWide;
  TCefString = TCefStringWide;
  PCefString = PCefStringWide;
{$ENDIF}

  // CEF strings are NUL-terminated wide character strings prefixed with a size
  // value, similar to the Microsoft BSTR type.  Use the below API functions for
  // allocating, managing and freeing CEF strings.

  // CEF string maps are a set of key/value string pairs.
  TCefStringMap = Pointer;

  // CEF string multimaps are a set of key/value string pairs.
  // More than one value can be assigned to a single key.
  TCefStringMultimap = Pointer;

  // CEF string maps are a set of key/value string pairs.
  TCefStringList = Pointer;

//---------------------------------------------------------------------

  // Structure representing CefExecuteProcess arguments.
  PCefMainArgs = ^TCefMainArgs;
  TCefMainArgs = record
    instance: HINST;
  end;

  // Structure representing window information.
  PCefWindowInfo = ^TCefWindowInfo;
{$IFDEF MACOS}
  TCefWindowInfo = record
    m_windowName: TCefString;
    m_x: Integer;
    m_y: Integer;
    m_nWidth: Integer;
    m_nHeight: Integer;
    m_bHidden: Integer;

    // NSView pointer for the parent view.
    m_ParentView: TCefWindowHandle;

    // NSView pointer for the new browser view.
    m_View: TCefWindowHandle;
  end;
{$ENDIF}

{$IFDEF MSWINDOWS}
  TCefWindowInfo = record
    // Standard parameters required by CreateWindowEx()
    ex_style: DWORD;
    window_name: TCefString;
    style: DWORD;
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;
    parent_window: HWND;
    menu: HMENU;

    // Set to true (1) to create the browser using windowless (off-screen)
    // rendering. No window will be created for the browser and all rendering will
    // occur via the CefRenderHandler interface. The |parent_window| value will be
    // used to identify monitor info and to act as the parent window for dialogs,
    // context menus, etc. If |parent_window| is not provided then the main screen
    // monitor will be used and some functionality that requires a parent window
    // may not function correctly. In order to create windowless browsers the
    // CefSettings.windowless_rendering_enabled value must be set to true.
    windowless_rendering_enabled: Integer;

    // Set to true (1) to enable transparent painting in combination with
    // windowless rendering. When this value is true a transparent background
    // color will be used (RGBA=0x00000000). When this value is false the
    // background will be white and opaque.
    transparent_painting_enabled: Integer;

    // Handle for the new browser window. Only used with windowed rendering.
    window: HWND ;
  end;
{$ENDIF}

  // Log severity levels.
  TCefLogSeverity = (
    // Default logging (currently INFO logging).
    LOGSEVERITY_DEFAULT,
    // Verbose logging.
    LOGSEVERITY_VERBOSE,
    // INFO logging.
    LOGSEVERITY_INFO,
    // WARNING logging.
    LOGSEVERITY_WARNING,
    // ERROR logging.
    LOGSEVERITY_ERROR,
    // Disables logging completely.
    LOGSEVERITY_DISABLE = 99
  );

  // Represents the state of a setting.
  TCefState = (
    // Use the default state for the setting.
    STATE_DEFAULT = 0,

    // Enable or allow the setting.
    STATE_ENABLED,

    // Disable or disallow the setting.
    STATE_DISABLED
  );

  // Initialization settings. Specify NULL or 0 to get the recommended default
  // values. Many of these and other settings can also configured using command-
  // line switches.

  PCefSettings = ^TCefSettings;
  TCefSettings = record
    // Size of this structure.
    size: NativeUInt;

    // Set to true (1) to use a single process for the browser and renderer. This
    // run mode is not officially supported by Chromium and is less stable than
    // the multi-process default. Also configurable using the "single-process"
    // command-line switch.
    single_process: Integer;

    // Set to true (1) to disable the sandbox for sub-processes. See
    // cef_sandbox_win.h for requirements to enable the sandbox on Windows. Also
    // configurable using the "no-sandbox" command-line switch.
    no_sandbox: Integer;

    // The path to a separate executable that will be launched for sub-processes.
    // By default the browser process executable is used. See the comments on
    // CefExecuteProcess() for details. Also configurable using the
    // "browser-subprocess-path" command-line switch.
    browser_subprocess_path: TCefString;

    // Set to true (1) to have the browser process message loop run in a separate
    // thread. If false (0) than the CefDoMessageLoopWork() function must be
    // called from your application message loop. This option is only supported on
    // Windows.
    multi_threaded_message_loop: Integer;

    // Set to true (1) to enable windowless (off-screen) rendering support. Do not
    // enable this value if the application does not use windowless rendering as
    // it may reduce rendering performance on some systems.
    windowless_rendering_enabled: Integer;

    // Set to true (1) to disable configuration of browser process features using
    // standard CEF and Chromium command-line arguments. Configuration can still
    // be specified using CEF data structures or via the
    // CefApp::OnBeforeCommandLineProcessing() method.
    command_line_args_disabled: Integer;

    // The location where cache data will be stored on disk. If empty then
    // browsers will be created in "incognito mode" where in-memory caches are
    // used for storage and no data is persisted to disk. HTML5 databases such as
    // localStorage will only persist across sessions if a cache path is
    // specified. Can be overridden for individual CefRequestContext instances via
    // the CefRequestContextSettings.cache_path value.
    cache_path: TCefString;

    // The location where user data such as spell checking dictionary files will
    // be stored on disk. If empty then the default platform-specific user data
    // directory will be used ("~/.cef_user_data" directory on Linux,
    // "~/Library/Application Support/CEF/User Data" directory on Mac OS X,
    // "Local Settings\Application Data\CEF\User Data" directory under the user
    // profile directory on Windows).
    user_data_path: TCefString;

    // To persist session cookies (cookies without an expiry date or validity
    // interval) by default when using the global cookie manager set this value to
    // true. Session cookies are generally intended to be transient and most Web
    // browsers do not persist them. A |cache_path| value must also be specified
    // to enable this feature. Also configurable using the
    // "persist-session-cookies" command-line switch. Can be overridden for
    // individual CefRequestContext instances via the
    // CefRequestContextSettings.persist_session_cookies value.
    persist_session_cookies: Integer;

    // Value that will be returned as the User-Agent HTTP header. If empty the
    // default User-Agent string will be used. Also configurable using the
    // "user-agent" command-line switch.
    user_agent: TCefString;

    // Value that will be inserted as the product portion of the default
    // User-Agent string. If empty the Chromium product version will be used. If
    // |userAgent| is specified this value will be ignored. Also configurable
    // using the "product-version" command-line switch.
    product_version: TCefString;

    // The locale string that will be passed to WebKit. If empty the default
    // locale of "en-US" will be used. This value is ignored on Linux where locale
    // is determined using environment variable parsing with the precedence order:
    // LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also configurable using the "lang"
    // command-line switch.
    locale: TCefString;

    // The directory and file name to use for the debug log. If empty, the
    // default name of "debug.log" will be used and the file will be written
    // to the application directory. Also configurable using the "log-file"
    // command-line switch.
    log_file: TCefString;

    // The log severity. Only messages of this severity level or higher will be
    // logged.
    log_severity: TCefLogSeverity;

    // Custom flags that will be used when initializing the V8 JavaScript engine.
    // The consequences of using custom flags may not be well tested. Also
    // configurable using the "js-flags" command-line switch.
    javascript_flags: TCefString;

    // The fully qualified path for the resources directory. If this value is
    // empty the cef.pak and/or devtools_resources.pak files must be located in
    // the module directory on Windows/Linux or the app bundle Resources directory
    // on Mac OS X. Also configurable using the "resources-dir-path" command-line
    // switch.
    resources_dir_path: TCefString;

    // The fully qualified path for the locales directory. If this value is empty
    // the locales directory must be located in the module directory. This value
    // is ignored on Mac OS X where pack files are always loaded from the app
    // bundle Resources directory. Also configurable using the "locales-dir-path"
    // command-line switch.
    locales_dir_path: TCefString;

    // Set to true (1) to disable loading of pack files for resources and locales.
    // A resource bundle handler must be provided for the browser and render
    // processes via CefApp::GetResourceBundleHandler() if loading of pack files
    // is disabled. Also configurable using the "disable-pack-loading" command-
    // line switch.
    pack_loading_disabled: Integer;

    // Set to a value between 1024 and 65535 to enable remote debugging on the
    // specified port. For example, if 8080 is specified the remote debugging URL
    // will be http://localhost:8080. CEF can be remotely debugged from any CEF or
    // Chrome browser window. Also configurable using the "remote-debugging-port"
    // command-line switch.
    remote_debugging_port: Integer;

    // The number of stack trace frames to capture for uncaught exceptions.
    // Specify a positive value to enable the CefRenderProcessHandler::
    // OnUncaughtException() callback. Specify 0 (default value) and
    // OnUncaughtException() will not be called. Also configurable using the
    // "uncaught-exception-stack-size" command-line switch.
    uncaught_exception_stack_size: Integer;

    // By default CEF V8 references will be invalidated (the IsValid() method will
    // return false) after the owning context has been released. This reduces the
    // need for external record keeping and avoids crashes due to the use of V8
    // references after the associated context has been released.
    //
    // CEF currently offers two context safety implementations with different
    // performance characteristics. The default implementation (value of 0) uses a
    // map of hash values and should provide better performance in situations with
    // a small number contexts. The alternate implementation (value of 1) uses a
    // hidden value attached to each context and should provide better performance
    // in situations with a large number of contexts.
    //
    // If you need better performance in the creation of V8 references and you
    // plan to manually track context lifespan you can disable context safety by
    // specifying a value of -1.
    //
    // Also configurable using the "context-safety-implementation" command-line
    // switch.

    context_safety_implementation: Integer;

    // Set to true (1) to ignore errors related to invalid SSL certificates.
    // Enabling this setting can lead to potential security vulnerabilities like
    // "man in the middle" attacks. Applications that load content from the
    // internet should not enable this setting. Also configurable using the
    // "ignore-certificate-errors" command-line switch. Can be overridden for
    // individual CefRequestContext instances via the
    // CefRequestContextSettings.ignore_certificate_errors value.
    ignore_certificate_errors: Integer;

    // Opaque background color used for accelerated content. By default the
    // background color will be white. Only the RGB compontents of the specified
    // value will be used. The alpha component must greater than 0 to enable use
    // of the background color but will be otherwise ignored.
    background_color: TCefColor;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. May be overridden on a
    // per-browser basis using the CefBrowserSettings.accept_language_list value.
    // If both values are empty then "en-US,en" will be used. Can be overridden
    // for individual CefRequestContext instances via the
    // CefRequestContextSettings.accept_language_list value.
    accept_language_list: TCefString;
  end;

  // Request context initialization settings. Specify NULL or 0 to get the
  // recommended default values.
  PCefRequestContextSettings = ^TCefRequestContextSettings;
  TCefRequestContextSettings = record
    // Size of this structure.
    size: NativeUInt;

    // The location where cache data will be stored on disk. If empty then
    // browsers will be created in "incognito mode" where in-memory caches are
    // used for storage and no data is persisted to disk. HTML5 databases such as
    // localStorage will only persist across sessions if a cache path is
    // specified. To share the global browser cache and related configuration set
    // this value to match the CefSettings.cache_path value.
    cache_path: TCefString;

    // To persist session cookies (cookies without an expiry date or validity
    // interval) by default when using the global cookie manager set this value to
    // true. Session cookies are generally intended to be transient and most Web
    // browsers do not persist them. Can be set globally using the
    // CefSettings.persist_session_cookies value. This value will be ignored if
    // |cache_path| is empty or if it matches the CefSettings.cache_path value.
    persist_session_cookies: Integer;

    // Set to true (1) to ignore errors related to invalid SSL certificates.
    // Enabling this setting can lead to potential security vulnerabilities like
    // "man in the middle" attacks. Applications that load content from the
    // internet should not enable this setting. Can be set globally using the
    // CefSettings.ignore_certificate_errors value. This value will be ignored if
    // |cache_path| matches the CefSettings.cache_path value.
    ignore_certificate_errors: Integer;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. Can be set globally
    // using the CefSettings.accept_language_list value or overridden on a per-
    // browser basis using the CefBrowserSettings.accept_language_list value. If
    // all values are empty then "en-US,en" will be used. This value will be
    // ignored if |cache_path| matches the CefSettings.cache_path value.
    accept_language_list: TCefString;
  end;

  // Browser initialization settings. Specify NULL or 0 to get the recommended
  // default values. The consequences of using custom values may not be well
  // tested. Many of these and other settings can also configured using command-
  // line switches.
  PCefBrowserSettings = ^TCefBrowserSettings;
  TCefBrowserSettings = record
    // Size of this structure.
    size: NativeUInt;

    // The maximum rate in frames per second (fps) that CefRenderHandler::OnPaint
    // will be called for a windowless browser. The actual fps may be lower if
    // the browser cannot generate frames at the requested rate. The minimum
    // value is 1 and the maximum value is 60 (default 30). This value can also be
    // changed dynamically via CefBrowserHost::SetWindowlessFrameRate.
    windowless_frame_rate: Integer;

    // The below values map to WebPreferences settings.

    // Font settings.
    standard_font_family: TCefString;
    fixed_font_family: TCefString;
    serif_font_family: TCefString;
    sans_serif_font_family: TCefString;
    cursive_font_family: TCefString;
    fantasy_font_family: TCefString;
    default_font_size: Integer;
    default_fixed_font_size: Integer;
    minimum_font_size: Integer;
    minimum_logical_font_size: Integer;

    // Default encoding for Web content. If empty "ISO-8859-1" will be used. Also
    // configurable using the "default-encoding" command-line switch.
    default_encoding: TCefString;

    // Controls the loading of fonts from remote sources. Also configurable using
    // the "disable-remote-fonts" command-line switch.
    remote_fonts: TCefState;


    // Controls whether JavaScript can be executed. Also configurable using the
    // "disable-javascript" command-line switch.
    javascript: TCefState;


    // Controls whether JavaScript can be used for opening windows. Also
    // configurable using the "disable-javascript-open-windows" command-line
    // switch.
    javascript_open_windows: TCefState;

    // Controls whether JavaScript can be used to close windows that were not
    // opened via JavaScript. JavaScript can still be used to close windows that
    // were opened via JavaScript or that have no back/forward history. Also
    // configurable using the "disable-javascript-close-windows" command-line
    // switch.
    javascript_close_windows: TCefState;

    // Controls whether JavaScript can access the clipboard. Also configurable
    // using the "disable-javascript-access-clipboard" command-line switch.
    javascript_access_clipboard: TCefState;

    // Controls whether DOM pasting is supported in the editor via
    // execCommand("paste"). The |javascript_access_clipboard| setting must also
    // be enabled. Also configurable using the "disable-javascript-dom-paste"
    // command-line switch.
    javascript_dom_paste: TCefState;

    // Controls whether the caret position will be drawn. Also configurable using
    // the "enable-caret-browsing" command-line switch.
    caret_browsing: TCefState;

    // Controls whether the Java plugin will be loaded. Also configurable using
    // the "disable-java" command-line switch.
    java: TCefState;

    // Controls whether any plugins will be loaded. Also configurable using the
    // "disable-plugins" command-line switch.
    plugins: TCefState;

    // Controls whether file URLs will have access to all URLs. Also configurable
    // using the "allow-universal-access-from-files" command-line switch.
    universal_access_from_file_urls: TCefState;

    // Controls whether file URLs will have access to other file URLs. Also
    // configurable using the "allow-access-from-files" command-line switch.
    file_access_from_file_urls: TCefState;

    // Controls whether web security restrictions (same-origin policy) will be
    // enforced. Disabling this setting is not recommend as it will allow risky
    // security behavior such as cross-site scripting (XSS). Also configurable
    // using the "disable-web-security" command-line switch.
    web_security: TCefState;

    // Controls whether image URLs will be loaded from the network. A cached image
    // will still be rendered if requested. Also configurable using the
    // "disable-image-loading" command-line switch.
    image_loading: TCefState;

    // Controls whether standalone images will be shrunk to fit the page. Also
    // configurable using the "image-shrink-standalone-to-fit" command-line
    // switch.
    image_shrink_standalone_to_fit: TCefState;

    // Controls whether text areas can be resized. Also configurable using the
    // "disable-text-area-resize" command-line switch.
    text_area_resize: TCefState;


    // Controls whether the tab key can advance focus to links. Also configurable

    // using the "disable-tab-to-links" command-line switch.
    tab_to_links: TCefState;


    // Controls whether local storage can be used. Also configurable using the
    // "disable-local-storage" command-line switch.
    local_storage: TCefState;

    // Controls whether databases can be used. Also configurable using the
    // "disable-databases" command-line switch.
    databases: TCefState;

    // Controls whether the application cache can be used. Also configurable using
    // the "disable-application-cache" command-line switch.
    application_cache: TCefState;

    // Controls whether WebGL can be used. Note that WebGL requires hardware
    // support and may not work on all systems even when enabled. Also
    // configurable using the "disable-webgl" command-line switch.
    webgl: TCefState;

    // Opaque background color used for the browser before a document is loaded
    // and when no document color is specified. By default the background color
    // will be the same as CefSettings.background_color. Only the RGB compontents
    // of the specified value will be used. The alpha component must greater than
    // 0 to enable use of the background color but will be otherwise ignored.
    background_color: TCefColor;

    // Comma delimited ordered list of language codes without any whitespace that
    // will be used in the "Accept-Language" HTTP header. May be set globally
    // using the CefBrowserSettings.accept_language_list value. If both values are
    // empty then "en-US,en" will be used.
    accept_language_list: TCefString;
  end;

  // Return value types.
  TCefReturnValue = (
    // Cancel immediately.
    RV_CANCEL = 0,

    // Continue immediately.
    RV_CONTINUE,

    // Continue asynchronously (usually via a callback).
    RV_CONTINUE_ASYNC
  );

  // URL component parts.
  PCefUrlParts = ^TCefUrlParts;
  TCefUrlParts = record
    // The complete URL specification.
    spec: TCefString;

    // Scheme component not including the colon (e.g., "http").
    scheme: TCefString;

    // User name component.
    username: TCefString;

    // Password component.
    password: TCefString;

    // Host component. This may be a hostname, an IPv4 address or an IPv6 literal
    // surrounded by square brackets (e.g., "[2001:db8::1]").
    host: TCefString;

    // Port number component.
    port: TCefString;

    // Origin contains just the scheme, host, and port from a URL. Equivalent to
    // clearing any username and password, replacing the path with a slash, and
    // clearing everything after that. This value will be empty for non-standard
    // URLs.
    origin: TCefString;

    // Path component including the first slash following the host.
    path: TCefString;

    // Query string component (i.e., everything following the '?').
    query: TCefString;
  end;

  TUrlParts = record
    spec: ustring;
    scheme: ustring;
    username: ustring;
    password: ustring;
    host: ustring;
    port: ustring;
    origin: ustring;
    path: ustring;
    query: ustring;
  end;

  // Time information. Values should always be in UTC.
  PCefTime = ^TCefTime;
  TCefTime = record
    year: Integer;          // Four digit year "2007"
    month: Integer;         // 1-based month (values 1 = January, etc.)
    day_of_week: Integer;   // 0-based day of week (0 = Sunday, etc.)
    day_of_month: Integer;  // 1-based day of month (1-31)
    hour: Integer;          // Hour within the current day (0-23)
    minute: Integer;        // Minute within the current hour (0-59)
    second: Integer;        // Second within the current minute (0-59 plus leap
                            //   seconds which may take it up to 60).
    millisecond: Integer;   // Milliseconds within the current second (0-999)
  end;

  // Cookie information.
  TCefCookie = record
    // The cookie name.
    name: TCefString;

    // The cookie value.
    value: TCefString;

    // If |domain| is empty a host cookie will be created instead of a domain
    // cookie. Domain cookies are stored with a leading "." and are visible to
    // sub-domains whereas host cookies are not.
    domain: TCefString;

    // If |path| is non-empty only URLs at or below the path will get the cookie
    // value.
    path: TCefString;

    // If |secure| is true the cookie will only be sent for HTTPS requests.
    secure: Integer;

    // If |httponly| is true the cookie will only be sent for HTTP requests.
    httponly: Integer;

    // The cookie creation date. This is automatically populated by the system on
    // cookie creation.
    creation: TCefTime;

    // The cookie last access date. This is automatically populated by the system
    // on access.
    last_access: TCefTime;

    // The cookie expiration date is only valid if |has_expires| is true.
    has_expires: Integer;
    expires: TCefTime;
  end;

  // Process termination status values.
  TCefTerminationStatus = (
    // Non-zero exit status.
    TS_ABNORMAL_TERMINATION,
    // SIGKILL or task manager kill.
    TS_PROCESS_WAS_KILLED,
    // Segmentation fault.
    TS_PROCESS_CRASHED
  );

  // Path key values.
  TCefPathKey = (
    // Current directory.
    PK_DIR_CURRENT,
    // Directory containing PK_FILE_EXE.
    PK_DIR_EXE,
    // Directory containing PK_FILE_MODULE.
    PK_DIR_MODULE,
    // Temporary directory.
    PK_DIR_TEMP,
    // Path and filename of the current executable.
    PK_FILE_EXE,
    // Path and filename of the module containing the CEF code (usually the libcef
    // module).
    PK_FILE_MODULE,
    // "Local Settings\Application Data" directory under the user profile
    // directory on Windows.
    PK_LOCAL_APP_DATA,
    // "Application Data" directory under the user profile directory on Windows
    // and "~/Library/Application Support" directory on Mac OS X.
    PK_USER_DATA
  );

  // Storage types.
  TCefStorageType = (
    ST_LOCALSTORAGE = 0,
    ST_SESSIONSTORAGE
  );

  // Supported error code values. See net\base\net_error_list.h for complete
  // descriptions of the error codes.
  TCefErrorcode = Integer;

const
  ERR_NONE = 0;
  ERR_FAILED = -2;
  ERR_ABORTED = -3;
  ERR_INVALID_ARGUMENT = -4;
  ERR_INVALID_HANDLE = -5;
  ERR_FILE_NOT_FOUND = -6;
  ERR_TIMED_OUT = -7;
  ERR_FILE_TOO_BIG = -8;
  ERR_UNEXPECTED = -9;
  ERR_ACCESS_DENIED = -10;
  ERR_NOT_IMPLEMENTED = -11;
  ERR_CONNECTION_CLOSED = -100;
  ERR_CONNECTION_RESET = -101;
  ERR_CONNECTION_REFUSED = -102;
  ERR_CONNECTION_ABORTED = -103;
  ERR_CONNECTION_FAILED = -104;
  ERR_NAME_NOT_RESOLVED = -105;
  ERR_INTERNET_DISCONNECTED = -106;
  ERR_SSL_PROTOCOL_ERROR = -107;
  ERR_ADDRESS_INVALID = -108;
  ERR_ADDRESS_UNREACHABLE = -109;
  ERR_SSL_CLIENT_AUTH_CERT_NEEDED = -110;
  ERR_TUNNEL_CONNECTION_FAILED = -111;
  ERR_NO_SSL_VERSIONS_ENABLED = -112;
  ERR_SSL_VERSION_OR_CIPHER_MISMATCH = -113;
  ERR_SSL_RENEGOTIATION_REQUESTED = -114;
  ERR_CERT_COMMON_NAME_INVALID = -200;
  ERR_CERT_DATE_INVALID = -201;
  ERR_CERT_AUTHORITY_INVALID = -202;
  ERR_CERT_CONTAINS_ERRORS = -203;
  ERR_CERT_NO_REVOCATION_MECHANISM = -204;
  ERR_CERT_UNABLE_TO_CHECK_REVOCATION = -205;
  ERR_CERT_REVOKED = -206;
  ERR_CERT_INVALID = -207;
  ERR_CERT_END = -208;
  ERR_INVALID_URL = -300;
  ERR_DISALLOWED_URL_SCHEME = -301;
  ERR_UNKNOWN_URL_SCHEME = -302;
  ERR_TOO_MANY_REDIRECTS = -310;
  ERR_UNSAFE_REDIRECT = -311;
  ERR_UNSAFE_PORT = -312;
  ERR_INVALID_RESPONSE = -320;
  ERR_INVALID_CHUNKED_ENCODING = -321;
  ERR_METHOD_NOT_SUPPORTED = -322;
  ERR_UNEXPECTED_PROXY_AUTH = -323;
  ERR_EMPTY_RESPONSE = -324;
  ERR_RESPONSE_HEADERS_TOO_BIG = -325;
  ERR_CACHE_MISS = -400;
  ERR_INSECURE_RESPONSE = -501;

type
  // The manner in which a link click should be opened.

  TCefWindowOpenDisposition = (
    WOD_UNKNOWN,
    WOD_SUPPRESS_OPEN,
    WOD_CURRENT_TAB,
    WOD_SINGLETON_TAB,
    WOD_NEW_FOREGROUND_TAB,
    WOD_NEW_BACKGROUND_TAB,
    WOD_NEW_POPUP,
    WOD_NEW_WINDOW,
    WOD_SAVE_TO_DISK,
    WOD_OFF_THE_RECORD,
    WOD_IGNORE_ACTION
  );

  // "Verb" of a drag-and-drop operation as negotiated between the source and
  // destination. These constants match their equivalents in WebCore's
  // DragActions.h and should not be renumbered.

  TCefDragOperation = (
    //DRAG_OPERATION_NONE    = 0;
    DRAG_OPERATION_COPY,
    DRAG_OPERATION_LINK,
    DRAG_OPERATION_GENERIC,
    DRAG_OPERATION_PRIVATE,
    DRAG_OPERATION_MOVE,
    DRAG_OPERATION_DELETE
    //DRAG_OPERATION_EVERY   = High(Cardinal);
  );
  TCefDragOperations = set of TCefDragOperation;

  // V8 access control values.
  TCefV8AccessControl = (
    //V8_ACCESS_CONTROL_DEFAULT               = 0;
    V8_ACCESS_CONTROL_ALL_CAN_READ,
    V8_ACCESS_CONTROL_ALL_CAN_WRITE,
    V8_ACCESS_CONTROL_PROHIBITS_OVERWRITING
  );
  TCefV8AccessControls = set of TCefV8AccessControl;

  // V8 property attribute values.
  TCefV8PropertyAttribute = (
    //V8_PROPERTY_ATTRIBUTE_NONE       = 0;       // Writeable, Enumerable, Configurable
    V8_PROPERTY_ATTRIBUTE_READONLY,  // Not writeable
    V8_PROPERTY_ATTRIBUTE_DONTENUM,  // Not enumerable
    V8_PROPERTY_ATTRIBUTE_DONTDELETE // Not configurable
  );
  TCefV8PropertyAttributes = set of TCefV8PropertyAttribute;

const
   V8_PROPERTY_ATTRIBUTE_NONE = []; // Writeable, Enumerable, Configurable

type
  // Post data elements may represent either bytes or files.
  TCefPostDataElementType = (
    PDE_TYPE_EMPTY  = 0,
    PDE_TYPE_BYTES,
    PDE_TYPE_FILE
  );

  // Resource type for a request.
  TCefResourceType = (
    // Top level page.
    RT_MAIN_FRAME,

    // Frame or iframe.
    RT_SUB_FRAME,

    // CSS stylesheet.
    RT_STYLESHEET,

    // External script.
    RT_SCRIPT,

    // Image (jpg/gif/png/etc).
    RT_IMAGE,

    // Font.
    RT_FONT_RESOURCE,

    // Some other subresource. This is the default type if the actual type is
    // unknown.
    RT_SUB_RESOURCE,

    // Object (or embed) tag for a plugin, or a resource that a plugin requested.
    RT_OBJECT,

    // Media resource.
    RT_MEDIA,

    // Main resource of a dedicated worker.
    RT_WORKER,

    // Main resource of a shared worker.
    RT_SHARED_WORKER,

    // Explicitly requested prefetch.
    RT_PREFETCH,

    // Favicon.
    RT_FAVICON,

    // XMLHttpRequest.
    RT_XHR,

    // A request for a <ping>
    RT_PING,

    // Main resource of a service worker.
    RT_SERVICE_WORKER
  );


  // Transition type for a request. Made up of one source value and 0 or more
  // qualifiers.


  TCefTransitionType = Cardinal;
const
    // Source is a link click or the JavaScript window.open function. This is
    // also the default value for requests like sub-resource loads that are not
    // navigations.
    TT_LINK = 0;

    // Source is some other "explicit" navigation action such as creating a new
    // browser or using the LoadURL function. This is also the default value
    // for navigations where the actual type is unknown.
    TT_EXPLICIT = 1;

    // Source is a subframe navigation. This is any content that is automatically
    // loaded in a non-toplevel frame. For example, if a page consists of several
    // frames containing ads, those ad URLs will have this transition type.
    // The user may not even realize the content in these pages is a separate
    // frame, so may not care about the URL.
    TT_AUTO_SUBFRAME = 3;

    // Source is a subframe navigation explicitly requested by the user that will
    // generate new navigation entries in the back/forward list. These are
    // probably more important than frames that were automatically loaded in
    // the background because the user probably cares about the fact that this
    // link was loaded.
    TT_MANUAL_SUBFRAME = 4;

    // Source is a form submission by the user. NOTE: In some situations
    // submitting a form does not result in this transition type. This can happen
    // if the form uses a script to submit the contents.
    TT_FORM_SUBMIT = 7;

    // Source is a "reload" of the page via the Reload function or by re-visiting
    // the same URL. NOTE: This is distinct from the concept of whether a
    // particular load uses "reload semantics" (i.e. bypasses cached data).
    TT_RELOAD = 8;

    // General mask defining the bits used for the source values.
    TT_SOURCE_MASK = $FF;

    // Qualifiers.
    // Any of the core values above can be augmented by one or more qualifiers.
    // These qualifiers further define the transition.

    // Attempted to visit a URL but was blocked.
    TT_BLOCKED_FLAG = $00800000;

    // Used the Forward or Back function to navigate among browsing history.
    TT_FORWARD_BACK_FLAG = $01000000;

    // The beginning of a navigation chain.
    TT_CHAIN_START_FLAG = $10000000;

    // The last transition in a redirect chain.
    TT_CHAIN_END_FLAG = $20000000;

    // Redirects caused by JavaScript or a meta refresh tag on the page.
    TT_CLIENT_REDIRECT_FLAG = $40000000;

    // Redirects sent from the server by HTTP headers.
    TT_SERVER_REDIRECT_FLAG = $80000000;

    // Used to test whether a transition involves a redirect.
    TT_IS_REDIRECT_MASK = $C0000000;

    // General mask defining the bits used for the qualifiers.
    TT_QUALIFIER_MASK = $FFFFFF00;
 // );

type
  // Flags used to customize the behavior of CefURLRequest.
  TCefUrlRequestFlag = (
    // Default behavior.
    //UR_FLAG_NONE                      = 0,
    // If set the cache will be skipped when handling the request.
    UR_FLAG_SKIP_CACHE,
    // If set user name, password, and cookies may be sent with the request, and
    // cookies may be saved from the response.
    UR_FLAG_ALLOW_CACHED_CREDENTIALS,
    UR_FLAG_DUMMY_1,
    // If set upload progress events will be generated when a request has a body.
    UR_FLAG_REPORT_UPLOAD_PROGRESS,
    // If set load timing info will be collected for the request.
    UR_FLAG_DUMMY_2,
    // If set the headers sent and received for the request will be recorded.
    UR_FLAG_REPORT_RAW_HEADERS,
    // If set the CefURLRequestClient::OnDownloadData method will not be called.
    UR_FLAG_NO_DOWNLOAD_DATA,
    // If set 5XX redirect errors will be propagated to the observer instead of
    // automatically re-tried. This currently only applies for requests
    // originated in the browser process.
    UR_FLAG_NO_RETRY_ON_5XX
  );
  TCefUrlRequestFlags = set of TCefUrlRequestFlag;

  // Flags that represent CefURLRequest status.
  TCefUrlRequestStatus = (
    // Unknown status.
    UR_UNKNOWN = 0,
    // Request succeeded.
    UR_SUCCESS,
    // An IO request is pending, and the caller will be informed when it is
    // completed.
    UR_IO_PENDING,
    // Request was canceled programatically.
    UR_CANCELED,
    // Request failed for some reason.
    UR_FAILED
  );

  // Structure representing a point.
  PCefPoint = ^TCefPoint;
  TCefPoint = record
    x: Integer;
    y: Integer;
  end;

  // Structure representing a rectangle.
  PCefRect = ^TCefRect;
  TCefRect = record
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;
  end;

  // Structure representing a size.
  PCefSize = ^TCefSize;
  TCefSize = record
    width: Integer;
    height: Integer;
  end;

  TCefRectArray = array[0..(High(Integer) div SizeOf(TCefRect))-1] of TCefRect;
  PCefRectArray = ^TCefRectArray;

  // Structure representing a draggable region.
  PCefDraggableRegion = ^TCefDraggableRegion;
  TCefDraggableRegion = record
    // Bounds of the region.
    bounds: TCefRect;
    // True (1) this this region is draggable and false (0) otherwise.
    draggable: Integer;
  end;

  PCefDraggableRegionArray = ^TCefDraggableRegionArray;
  TCefDraggableRegionArray = array[0..(High(Integer) div SizeOf(TCefDraggableRegion))-1]  of TCefDraggableRegion;

  // Existing process IDs.
  TCefProcessId = (
    // Browser process.
    PID_BROWSER,
    // Renderer process.
    PID_RENDERER
  );


  // Existing thread IDs.
  TCefThreadId = (
  // BROWSER PROCESS THREADS -- Only available in the browser process.
    // The main thread in the browser. This will be the same as the main
    // application thread if CefInitialize() is called with a
    // CefSettings.multi_threaded_message_loop value of false.
    ///
    TID_UI,

    // Used to interact with the database.
    TID_DB,

    // Used to interact with the file system.
    TID_FILE,

    // Used for file system operations that block user interactions.
    // Responsiveness of this thread affects users.
    TID_FILE_USER_BLOCKING,

    // Used to launch and terminate browser processes.
    TID_PROCESS_LAUNCHER,

    // Used to handle slow HTTP cache operations.
    TID_CACHE,

    // Used to process IPC and network messages.
    TID_IO,

  // RENDER PROCESS THREADS -- Only available in the render process.

    ///
    // The main thread in the renderer. Used for all WebKit and V8 interaction.
    ///
    TID_RENDERER
  );

  // Supported value types.
  TCefValueType = (
    VTYPE_INVALID = 0,
    VTYPE_NULL,
    VTYPE_BOOL,
    VTYPE_INT,
    VTYPE_DOUBLE,
    VTYPE_STRING,
    VTYPE_BINARY,
    VTYPE_DICTIONARY,
    VTYPE_LIST
  );

  // Supported JavaScript dialog types.
  TCefJsDialogType = (
    JSDIALOGTYPE_ALERT = 0,
    JSDIALOGTYPE_CONFIRM,
    JSDIALOGTYPE_PROMPT
  );

  // Screen information used when window rendering is disabled. This structure is
  // passed as a parameter to CefRenderHandler::GetScreenInfo and should be filled
  // in by the client.
  ///
  TCefScreenInfo = record
    // Device scale factor. Specifies the ratio between physical and logical
    // pixels.
    device_scale_factor: Single;

    // The screen depth in bits per pixel.
    depth: Integer;

    // The bits per color component. This assumes that the colors are balanced
    // equally.
    depth_per_component: Integer;

    // This can be true for black and white printers.
    is_monochrome: Integer;

    // This is set from the rcMonitor member of MONITORINFOEX, to whit:
    //   "A RECT structure that specifies the display monitor rectangle,
    //   expressed in virtual-screen coordinates. Note that if the monitor
    //   is not the primary display monitor, some of the rectangle's
    //   coordinates may be negative values."
    //
    // The |rect| and |available_rect| properties are used to determine the
    // available surface for rendering popup views.
    rect: TCefRect;

    // This is set from the rcWork member of MONITORINFOEX, to whit:
    //   "A RECT structure that specifies the work area rectangle of the
    //   display monitor that can be used by applications, expressed in
    //   virtual-screen coordinates. Windows uses this rectangle to
    //   maximize an application on the monitor. The rest of the area in
    //   rcMonitor contains system windows such as the task bar and side
    //   bars. Note that if the monitor is not the primary display monitor,
    //   some of the rectangle's coordinates may be negative values".
    //
    // The |rect| and |available_rect| properties are used to determine the
    // available surface for rendering popup views.
    ///
    available_rect: TCefRect;
  end;

  // Supported menu IDs. Non-English translations can be provided for the
  // IDS_MENU_* strings in CefResourceBundleHandler::GetLocalizedString().
  TCefMenuId = (
    // Navigation.
    MENU_ID_BACK                = 100,
    MENU_ID_FORWARD             = 101,
    MENU_ID_RELOAD              = 102,
    MENU_ID_RELOAD_NOCACHE      = 103,
    MENU_ID_STOPLOAD            = 104,

    // Editing.
    MENU_ID_UNDO                = 110,
    MENU_ID_REDO                = 111,
    MENU_ID_CUT                 = 112,
    MENU_ID_COPY                = 113,
    MENU_ID_PASTE               = 114,
    MENU_ID_DELETE              = 115,
    MENU_ID_SELECT_ALL          = 116,

    // Miscellaneous.
    MENU_ID_FIND                = 130,
    MENU_ID_PRINT               = 131,
    MENU_ID_VIEW_SOURCE         = 132,

    // Spell checking word correction suggestions.
    MENU_ID_SPELLCHECK_SUGGESTION_0        = 200,
    MENU_ID_SPELLCHECK_SUGGESTION_1        = 201,
    MENU_ID_SPELLCHECK_SUGGESTION_2        = 202,
    MENU_ID_SPELLCHECK_SUGGESTION_3        = 203,
    MENU_ID_SPELLCHECK_SUGGESTION_4        = 204,
    MENU_ID_SPELLCHECK_SUGGESTION_LAST     = 204,
    MENU_ID_NO_SPELLING_SUGGESTIONS        = 205,
    MENU_ID_ADD_TO_DICTIONARY              = 206,

    // Custom menu items originating from the renderer process. For example,
    // plugin placeholder menu items or Flash menu items.
    MENU_ID_CUSTOM_FIRST        = 220,
    MENU_ID_CUSTOM_LAST         = 250,

    // All user-defined menu IDs should come between MENU_ID_USER_FIRST and
    // MENU_ID_USER_LAST to avoid overlapping the Chromium and CEF ID ranges
    // defined in the tools/gritsettings/resource_ids file.
    MENU_ID_USER_FIRST          = 26500,
    MENU_ID_USER_LAST           = 28500
  );

  // Mouse button types.
  TCefMouseButtonType = (
    MBT_LEFT,
    MBT_MIDDLE,
    MBT_RIGHT
  );

  // Paint element types.
  TCefPaintElementType = (
    PET_VIEW,
    PET_POPUP
  );

  // Supported event bit flags.
  TCefEventFlag = (
    //EVENTFLAG_NONE                = 0,
    EVENTFLAG_CAPS_LOCK_ON,
    EVENTFLAG_SHIFT_DOWN,
    EVENTFLAG_CONTROL_DOWN,
    EVENTFLAG_ALT_DOWN,
    EVENTFLAG_LEFT_MOUSE_BUTTON,
    EVENTFLAG_MIDDLE_MOUSE_BUTTON,
    EVENTFLAG_RIGHT_MOUSE_BUTTON,
    // Mac OS-X command key.
    EVENTFLAG_COMMAND_DOWN,
    EVENTFLAG_NUM_LOCK_ON,
    EVENTFLAG_IS_KEY_PAD,
    EVENTFLAG_IS_LEFT,
    EVENTFLAG_IS_RIGHT
  );
  TCefEventFlags = set of TCefEventFlag;

  // Structure representing mouse event information.
  PCefMouseEvent = ^TCefMouseEvent;
  TCefMouseEvent = record
    // X coordinate relative to the left side of the view.
    x: Integer;

    // Y coordinate relative to the top side of the view.
    y: Integer;

    // Bit flags describing any pressed modifier keys. See
    // cef_event_flags_t for values.
    modifiers: TCefEventFlags;
  end;

  // Supported menu item types.
  TCefMenuItemType = (
    MENUITEMTYPE_NONE,
    MENUITEMTYPE_COMMAND,
    MENUITEMTYPE_CHECK,
    MENUITEMTYPE_RADIO,
    MENUITEMTYPE_SEPARATOR,
    MENUITEMTYPE_SUBMENU
  );

  // Supported context menu type flags.
  TCefContextMenuTypeFlag = (
    // No node is selected.
    //CM_TYPEFLAG_NONE        = 0,
    // The top page is selected.
    CM_TYPEFLAG_PAGE,
    // A subframe page is selected.
    CM_TYPEFLAG_FRAME,
    // A link is selected.
    CM_TYPEFLAG_LINK,
    // A media node is selected.
    CM_TYPEFLAG_MEDIA,
    // There is a textual or mixed selection that is selected.
    CM_TYPEFLAG_SELECTION,
    // An editable element is selected.
    CM_TYPEFLAG_EDITABLE
  );
  TCefContextMenuTypeFlags = set of TCefContextMenuTypeFlag;

  // Supported context menu media types.
  TCefContextMenuMediaType = (
    // No special node is in context.
    CM_MEDIATYPE_NONE,
    // An image node is selected.
    CM_MEDIATYPE_IMAGE,
    // A video node is selected.
    CM_MEDIATYPE_VIDEO,
    // An audio node is selected.
    CM_MEDIATYPE_AUDIO,
    // A file node is selected.
    CM_MEDIATYPE_FILE,
    // A plugin node is selected.
    CM_MEDIATYPE_PLUGIN
  );

  // Supported context menu media state bit flags.
  TCefContextMenuMediaStateFlag = (
    //CM_MEDIAFLAG_NONE                  = 0,
    CM_MEDIAFLAG_ERROR,
    CM_MEDIAFLAG_PAUSED,
    CM_MEDIAFLAG_MUTED,
    CM_MEDIAFLAG_LOOP,
    CM_MEDIAFLAG_CAN_SAVE,
    CM_MEDIAFLAG_HAS_AUDIO,
    CM_MEDIAFLAG_HAS_VIDEO,
    CM_MEDIAFLAG_CONTROL_ROOT_ELEMENT,
    CM_MEDIAFLAG_CAN_PRINT,
    CM_MEDIAFLAG_CAN_ROTATE
  );
  TCefContextMenuMediaStateFlags = set of TCefContextMenuMediaStateFlag;

  // Supported context menu edit state bit flags.
  TCefContextMenuEditStateFlag = (
    //CM_EDITFLAG_NONE            = 0,
    CM_EDITFLAG_CAN_UNDO,
    CM_EDITFLAG_CAN_REDO,
    CM_EDITFLAG_CAN_CUT,
    CM_EDITFLAG_CAN_COPY,
    CM_EDITFLAG_CAN_PASTE,
    CM_EDITFLAG_CAN_DELETE,
    CM_EDITFLAG_CAN_SELECT_ALL,
    CM_EDITFLAG_CAN_TRANSLATE
 );
 TCefContextMenuEditStateFlags = set of TCefContextMenuEditStateFlag;

  // Key event types.
  TCefKeyEventType = (
    // Notification that a key transitioned from "up" to "down".
    KEYEVENT_RAWKEYDOWN = 0,
    // Notification that a key was pressed. This does not necessarily correspond
    // to a character depending on the key and language. Use KEYEVENT_CHAR for
    // character input.
    KEYEVENT_KEYDOWN,
    // Notification that a key was released.
    KEYEVENT_KEYUP,
    // Notification that a character was typed. Use this for text input. Key
    // down events may generate 0, 1, or more than one character event depending
    // on the key, locale, and operating system.
    KEYEVENT_CHAR
  );

  // Structure representing keyboard event information.
  PCefKeyEvent = ^TCefKeyEvent;
  TCefKeyEvent = record
    // The type of keyboard event.
    kind: TCefKeyEventType;

    // Bit flags describing any pressed modifier keys. See
    // cef_event_flags_t for values.
    modifiers: TCefEventFlags;

    // The Windows key code for the key event. This value is used by the DOM
    // specification. Sometimes it comes directly from the event (i.e. on
    // Windows) and sometimes it's determined using a mapping function. See
    // WebCore/platform/chromium/KeyboardCodes.h for the list of values.
    windows_key_code: Integer;

    // The actual key code genenerated by the platform.
    native_key_code: Integer;

    // Indicates whether the event is considered a "system key" event (see
    // http://msdn.microsoft.com/en-us/library/ms646286(VS.85).aspx for details).
    // This value will always be false on non-Windows platforms.
    is_system_key: Integer;

    // The character generated by the keystroke.
    character: WideChar;

    // Same as |character| but unmodified by any concurrently-held modifiers
    // (except shift). This is useful for working out shortcut keys.
    unmodified_character: WideChar;

    // True if the focus is currently on an editable field on the page. This is
    // useful for determining if standard key events should be intercepted.
    focus_on_editable_field: Integer;
  end;

  // Focus sources.
  TCefFocusSource = (
    // The source is explicit navigation via the API (LoadURL(), etc).
    FOCUS_SOURCE_NAVIGATION = 0,
    // The source is a system-generated focus event.
    FOCUS_SOURCE_SYSTEM
  );

  // Navigation types.
  TCefNavigationType = (
    NAVIGATION_LINK_CLICKED,
    NAVIGATION_FORM_SUBMITTED,
    NAVIGATION_BACK_FORWARD,
    NAVIGATION_RELOAD,
    NAVIGATION_FORM_RESUBMITTED,
    NAVIGATION_OTHER
  );

  // Supported XML encoding types. The parser supports ASCII, ISO-8859-1, and
  // UTF16 (LE and BE) by default. All other types must be translated to UTF8
  // before being passed to the parser. If a BOM is detected and the correct
  // decoder is available then that decoder will be used automatically.
  TCefXmlEncodingType = (
    XML_ENCODING_NONE = 0,
    XML_ENCODING_UTF8,
    XML_ENCODING_UTF16LE,
    XML_ENCODING_UTF16BE,
    XML_ENCODING_ASCII
  );

  // XML node types.
  TCefXmlNodeType = (
    XML_NODE_UNSUPPORTED = 0,
    XML_NODE_PROCESSING_INSTRUCTION,
    XML_NODE_DOCUMENT_TYPE,
    XML_NODE_ELEMENT_START,
    XML_NODE_ELEMENT_END,
    XML_NODE_ATTRIBUTE,
    XML_NODE_TEXT,
    XML_NODE_CDATA,
    XML_NODE_ENTITY_REFERENCE,
    XML_NODE_WHITESPACE,
    XML_NODE_COMMENT
  );

  // Popup window features.
  PCefPopupFeatures = ^TCefPopupFeatures;
  TCefPopupFeatures = record
    x: Integer;
    xSet: Integer;
    y: Integer;
    ySet: Integer;
    width: Integer;
    widthSet: Integer;
    height: Integer;
    heightSet: Integer;

    menuBarVisible: Integer;
    statusBarVisible: Integer;
    toolBarVisible: Integer;
    locationBarVisible: Integer;
    scrollbarsVisible: Integer;
    resizable: Integer;

    fullscreen: Integer;
    dialog: Integer;
    additionalFeatures: TCefStringList;
  end;

  // DOM document types.
  TCefDomDocumentType = (
    DOM_DOCUMENT_TYPE_UNKNOWN = 0,
    DOM_DOCUMENT_TYPE_HTML,
    DOM_DOCUMENT_TYPE_XHTML,
    DOM_DOCUMENT_TYPE_PLUGIN
  );

  // DOM event category flags.
  TCefDomEventCategory = Integer;
const
  DOM_EVENT_CATEGORY_UNKNOWN = $0;
  DOM_EVENT_CATEGORY_UI = $1;
  DOM_EVENT_CATEGORY_MOUSE = $2;
  DOM_EVENT_CATEGORY_MUTATION = $4;
  DOM_EVENT_CATEGORY_KEYBOARD = $8;
  DOM_EVENT_CATEGORY_TEXT = $10;
  DOM_EVENT_CATEGORY_COMPOSITION = $20;
  DOM_EVENT_CATEGORY_DRAG = $40;
  DOM_EVENT_CATEGORY_CLIPBOARD = $80;
  DOM_EVENT_CATEGORY_MESSAGE = $100;
  DOM_EVENT_CATEGORY_WHEEL = $200;
  DOM_EVENT_CATEGORY_BEFORE_TEXT_INSERTED = $400;
  DOM_EVENT_CATEGORY_OVERFLOW = $800;
  DOM_EVENT_CATEGORY_PAGE_TRANSITION = $1000;
  DOM_EVENT_CATEGORY_POPSTATE = $2000;
  DOM_EVENT_CATEGORY_PROGRESS = $4000;
  DOM_EVENT_CATEGORY_XMLHTTPREQUEST_PROGRESS = $8000;

type
  // DOM event processing phases.
  TCefDomEventPhase = (
    DOM_EVENT_PHASE_UNKNOWN = 0,
    DOM_EVENT_PHASE_CAPTURING,
    DOM_EVENT_PHASE_AT_TARGET,
    DOM_EVENT_PHASE_BUBBLING
  );

  // DOM node types.
  TCefDomNodeType = (
    DOM_NODE_TYPE_UNSUPPORTED = 0,
    DOM_NODE_TYPE_ELEMENT,
    DOM_NODE_TYPE_ATTRIBUTE,
    DOM_NODE_TYPE_TEXT,
    DOM_NODE_TYPE_CDATA_SECTION,
    DOM_NODE_TYPE_PROCESSING_INSTRUCTIONS,
    DOM_NODE_TYPE_COMMENT,
    DOM_NODE_TYPE_DOCUMENT,
    DOM_NODE_TYPE_DOCUMENT_TYPE,
    DOM_NODE_TYPE_DOCUMENT_FRAGMENT
  );

  // Supported file dialog modes.
  TCefFileDialogMode = (
    // Requires that the file exists before allowing the user to pick it.
    FILE_DIALOG_OPEN,

    // Like Open, but allows picking multiple files to open.
    FILE_DIALOG_OPEN_MULTIPLE,

    // Like Open, but selects a folder to open.
    FILE_DIALOG_OPEN_FOLDER,

    // Allows picking a nonexistent file, and prompts to overwrite if the file
    // already exists.
    FILE_DIALOG_SAVE
  );

const
  // General mask defining the bits used for the type values.
  FILE_DIALOG_TYPE_MASK = $FF;

  // Qualifiers.
  // Any of the type values above can be augmented by one or more qualifiers.
  // These qualifiers further define the dialog behavior.

  // Prompt to overwrite if the user selects an existing file with the Save
  // dialog.
  FILE_DIALOG_OVERWRITEPROMPT_FLAG = $01000000;

  // Do not display read-only files.
  FILE_DIALOG_HIDEREADONLY_FLAG = $02000000;


type
  // Geoposition error codes.
  TCefGeopositionErrorCode = (
    GEOPOSITON_ERROR_NONE,
    GEOPOSITON_ERROR_PERMISSION_DENIED,
    GEOPOSITON_ERROR_POSITION_UNAVAILABLE,
    GEOPOSITON_ERROR_TIMEOUT
  );

  // Structure representing geoposition information. The properties of this
  // structure correspond to those of the JavaScript Position object although
  // their types may differ.
  PCefGeoposition = ^TCefGeoposition;
  TCefGeoposition = record
    // Latitude in decimal degrees north (WGS84 coordinate frame).
    latitude: Double;

    // Longitude in decimal degrees west (WGS84 coordinate frame).
    longitude: Double;

    // Altitude in meters (above WGS84 datum).
    altitude: Double;

    // Accuracy of horizontal position in meters.
    accuracy: Double;

    // Accuracy of altitude in meters.
    altitude_accuracy: Double;

    // Heading in decimal degrees clockwise from true north.
    heading: Double;

    // Horizontal component of device velocity in meters per second.
    speed: Double;

    // Time of position measurement in milliseconds since Epoch in UTC time. This
    // is taken from the host computer's system clock.
    timestamp: TCefTime;

    // Error code, see enum above.
    error_code: TCefGeopositionErrorCode;

    // Human-readable error message.
    error_message: TCefString;
  end;

  // Print job color mode values.
  TCefColorModel = (
    COLOR_MODEL_UNKNOWN,
    COLOR_MODEL_GRAY,
    COLOR_MODEL_COLOR,
    COLOR_MODEL_CMYK,
    COLOR_MODEL_CMY,
    COLOR_MODEL_KCMY,
    COLOR_MODEL_CMY_K,  // CMY_K represents CMY+K.
    COLOR_MODEL_BLACK,
    COLOR_MODEL_GRAYSCALE,
    COLOR_MODEL_RGB,
    COLOR_MODEL_RGB16,
    COLOR_MODEL_RGBA,
    COLOR_MODEL_COLORMODE_COLOR,  // Used in samsung printer ppds.
    COLOR_MODEL_COLORMODE_MONOCHROME,  // Used in samsung printer ppds.
    COLOR_MODEL_HP_COLOR_COLOR,  // Used in HP color printer ppds.
    COLOR_MODEL_HP_COLOR_BLACK,  // Used in HP color printer ppds.
    COLOR_MODEL_PRINTOUTMODE_NORMAL,  // Used in foomatic ppds.
    COLOR_MODEL_PRINTOUTMODE_NORMAL_GRAY,  // Used in foomatic ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_CMYK,  // Used in canon printer ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_GREYSCALE,  // Used in canon printer ppds.
    COLOR_MODEL_PROCESSCOLORMODEL_RGB  // Used in canon printer ppds
  );

  // Print job duplex mode values.
  TCefDuplexMode = (
    DUPLEX_MODE_UNKNOWN = -1,
    DUPLEX_MODE_SIMPLEX,
    DUPLEX_MODE_LONG_EDGE,
    DUPLEX_MODE_SHORT_EDGE
  );

  // Structure representing a print job page range.
  PCefPageRange = ^TCefPageRange;
  TCefPageRange = record
    from:Integer;
    to_: Integer;
  end;

  TCefPageRangeArray = array of TCefPageRange;

  // Cursor type values.
  ///
  TCefCursorType = (
    CT_POINTER = 0,
    CT_CROSS,
    CT_HAND,
    CT_IBEAM,
    CT_WAIT,
    CT_HELP,
    CT_EASTRESIZE,
    CT_NORTHRESIZE,
    CT_NORTHEASTRESIZE,
    CT_NORTHWESTRESIZE,
    CT_SOUTHRESIZE,
    CT_SOUTHEASTRESIZE,
    CT_SOUTHWESTRESIZE,
    CT_WESTRESIZE,
    CT_NORTHSOUTHRESIZE,
    CT_EASTWESTRESIZE,
    CT_NORTHEASTSOUTHWESTRESIZE,
    CT_NORTHWESTSOUTHEASTRESIZE,
    CT_COLUMNRESIZE,
    CT_ROWRESIZE,
    CT_MIDDLEPANNING,
    CT_EASTPANNING,
    CT_NORTHPANNING,
    CT_NORTHEASTPANNING,
    CT_NORTHWESTPANNING,
    CT_SOUTHPANNING,
    CT_SOUTHEASTPANNING,
    CT_SOUTHWESTPANNING,
    CT_WESTPANNING,
    CT_MOVE,
    CT_VERTICALTEXT,
    CT_CELL,
    CT_CONTEXTMENU,
    CT_ALIAS,
    CT_PROGRESS,
    CT_NODROP,
    CT_COPY,
    CT_NONE,
    CT_NOTALLOWED,
    CT_ZOOMIN,
    CT_ZOOMOUT,
    CT_GRAB,
    CT_GRABBING,
    CT_CUSTOM
  );

  // Structure representing cursor information. |buffer| will be
  // |size.width|*|size.height|*4 bytes in size and represents a BGRA image with
  // an upper-left origin.

  PCefCursorInfo = ^TCefCursorInfo;
  TCefCursorInfo = record
    hotspot: TCefPoint;
    image_scale_factor: Single;
    buffer: Pointer;
    size: TCefSize;
  end;

  // URI unescape rules passed to CefURIDecode().
  // todo: set of
  TCefUriUnescapeRule = (
    // Don't unescape anything at all.
    UU_NONE = 0,

    // Don't unescape anything special, but all normal unescaping will happen.
    // This is a placeholder and can't be combined with other flags (since it's
    // just the absence of them). All other unescape rules imply "normal" in
    // addition to their special meaning. Things like escaped letters, digits,
    // and most symbols will get unescaped with this mode.
    UU_NORMAL = 1,

    // Convert %20 to spaces. In some places where we're showing URLs, we may
    // want this. In places where the URL may be copied and pasted out, then
    // you wouldn't want this since it might not be interpreted in one piece
    // by other applications.
    UU_SPACES = 2,

    // Unescapes various characters that will change the meaning of URLs,
    // including '%', '+', '&', '/', '#'. If we unescaped these characters, the
    // resulting URL won't be the same as the source one. This flag is used when
    // generating final output like filenames for URLs where we won't be
    // interpreting as a URL and want to do as much unescaping as possible.
    UU_URL_SPECIAL_CHARS = 4,

    // Unescapes control characters such as %01. This INCLUDES NULLs. This is
    // used for rare cases such as data: URL decoding where the result is binary
    // data. This flag also unescapes BiDi control characters.
    //
    // DO NOT use CONTROL_CHARS if the URL is going to be displayed in the UI
    // for security reasons.
    UU_CONTROL_CHARS = 8,

    // URL queries use "+" for space. This flag controls that replacement.
    UU_REPLACE_PLUS_WITH_SPACE = 16
  );

  // Options that can be passed to CefParseJSON.
  // todo: set of
  TCefJsonParserOptions = (
    // Parses the input strictly according to RFC 4627. See comments in Chromium's
    // base/json/json_reader.h file for known limitations/deviations from the RFC.
    JSON_PARSER_RFC = 0,

    // Allows commas to exist after the last element in structures.
    JSON_PARSER_ALLOW_TRAILING_COMMAS = 1 shl 0
  );

  // Error codes that can be returned from CefParseJSONAndReturnError.
  PCefJsonParserError = ^TCefJsonParserError;
  TCefJsonParserError = (
    JSON_NO_ERROR = 0,
    JSON_INVALID_ESCAPE,
    JSON_SYNTAX_ERROR,
    JSON_UNEXPECTED_TOKEN,
    JSON_TRAILING_COMMA,
    JSON_TOO_MUCH_NESTING,
    JSON_UNEXPECTED_DATA_AFTER_ROOT,
    JSON_UNSUPPORTED_ENCODING,
    JSON_UNQUOTED_DICTIONARY_KEY,
    JSON_PARSE_ERROR_COUNT
  );

  // Options that can be passed to CefWriteJSON.
  // Default behavior.
//  JSON_WRITER_DEFAULT = 0;
  TCefJsonWriterOption = (
    // This option instructs the writer that if a Binary value is encountered,
    // the value (and key if within a dictionary) will be omitted from the
    // output, and success will be returned. Otherwise, if a binary value is
    // encountered, failure will be returned.
    JSON_WRITER_OMIT_BINARY_VALUES,

    // This option instructs the writer to write doubles that have no fractional
    // part as a normal integer (i.e., without using exponential notation
    // or appending a '.0') as long as the value is within the range of a
    // 64-bit int.
    JSON_WRITER_OMIT_DOUBLE_TYPE_PRESERVATION,

    // Return a slightly nicer formatted json string (pads with whitespace to
    // help with readability).
    JSON_WRITER_PRETTY_PRINT
  );
  TCefJsonWriterOptions = set of TCefJsonWriterOption;

  // Margin type for PDF printing.
  TCefPdfPrintMarginType = (
    // Default margins.
    PDF_PRINT_MARGIN_DEFAULT,
    // No margins.
    PDF_PRINT_MARGIN_NONE,
    // Minimum margins.
    PDF_PRINT_MARGIN_MINIMUM,
    // Custom margins using the |margin_*| values from cef_pdf_print_settings_t.
    PDF_PRINT_MARGIN_CUSTOM
  );

  // Structure representing PDF print settings.
  PCefPdfPrintSettings = ^TCefPdfPrintSettings;
  TCefPdfPrintSettings = record
    // Page title to display in the header. Only used if |header_footer_enabled|
    // is set to true (1).
    header_footer_title: TCefString;
    // URL to display in the footer. Only used if |header_footer_enabled| is set
    // to true (1).
    header_footer_url: TCefString;
    // Output page size in microns. If either of these values is less than or
    // equal to zero then the default paper size (A4) will be used.
    page_width: Integer;
    page_height: Integer;
    // Margins in millimeters. Only used if |margin_type| is set to
    // PDF_PRINT_MARGIN_CUSTOM.
    margin_top: double;
    margin_right: double;
    margin_bottom: double;
    margin_left: double;
    // Margin type.
    margin_type: TCefPdfPrintMarginType;
    // Set to true (1) to print headers and footers or false (0) to not print
    // headers and footers.
    header_footer_enabled: Integer;
    // Set to true (1) to print the selection only or false (0) to print all.
    selection_only: Integer;
    // Set to true (1) for landscape mode or false (0) for portrait mode.
    landscape: Integer;
    // Set to true (1) to print background graphics or false (0) to not print
    // background graphics.
    backgrounds_enabled: Integer;
  end;

  // Supported UI scale factors for the platform. SCALE_FACTOR_NONE is used for
  // density independent resources such as string, html/js files or an image that
  // can be used for any scale factors (such as wallpapers).
  TCefScaleFactor = (
    SCALE_FACTOR_NONE = 0,
    SCALE_FACTOR_100P,
    SCALE_FACTOR_125P,
    SCALE_FACTOR_133P,
    SCALE_FACTOR_140P,
    SCALE_FACTOR_150P,
    SCALE_FACTOR_180P,
    SCALE_FACTOR_200P,
    SCALE_FACTOR_250P,
    SCALE_FACTOR_300P
  );

  // Plugin policies supported by CefRequestContextHandler::OnBeforePluginLoad.
  PCefPluginPolicy = ^TCefPluginPolicy;
  TCefPluginPolicy = (
    // Allow the content.
    PLUGIN_POLICY_ALLOW,
    // Allow important content and block unimportant content based on heuristics.
    // The user can manually load blocked content.
    PLUGIN_POLICY_DETECT_IMPORTANT,
    // Block the content. The user can manually load blocked content.
    PLUGIN_POLICY_BLOCK,
    // Disable the content. The user cannot load disabled content.
    PLUGIN_POLICY_DISABLE
  );

(*******************************************************************************
   capi
 *******************************************************************************)
type
  PCefv8Handler = ^TCefv8Handler;
  PCefV8Accessor = ^TCefV8Accessor;
  PCefv8Value = ^TCefv8Value;
  PCefV8StackTrace = ^TCefV8StackTrace;
  PCefV8StackFrame = ^TCefV8StackFrame;
  PCefV8ValueArray = array[0..(High(Integer) div SizeOf(Pointer)) - 1] of PCefV8Value;
  PPCefV8Value = ^PCefV8ValueArray;
  PCefSchemeHandlerFactory = ^TCefSchemeHandlerFactory;
  PCefSchemeRegistrar = ^TCefSchemeRegistrar;
  PCefFrame = ^TCefFrame;
  PCefRequest = ^TCefRequest;
  PCefStreamReader = ^TCefStreamReader;
  PCefPostData = ^TCefPostData;
  PCefPostDataElement = ^TCefPostDataElement;
  PPCefPostDataElement = ^PCefPostDataElement;
  PCefReadHandler = ^TCefReadHandler;
  PCefWriteHandler = ^TCefWriteHandler;
  PCefStreamWriter = ^TCefStreamWriter;
  PCefBase = ^TCefBase;
  PCefBrowser = ^TCefBrowser;
  PCefRunFileDialogCallback = ^TCefRunFileDialogCallback;
  PCefBrowserHost = ^TCefBrowserHost;
  PCefPdfPrintCallback = ^TCefPdfPrintCallback;
  PCefTask = ^TCefTask;
  PCefTaskRunner = ^TCefTaskRunner;
  PCefDownloadHandler = ^TCefDownloadHandler;
  PCefXmlReader = ^TCefXmlReader;
  PCefZipReader = ^TCefZipReader;
  PCefDomVisitor = ^TCefDomVisitor;
  PCefDomDocument = ^TCefDomDocument;
  PCefDomNode = ^TCefDomNode;
  PCefResponse = ^TCefResponse;
  PCefv8Context = ^TCefv8Context;
  PCefCookieVisitor = ^TCefCookieVisitor;
  PCefCookie = ^TCefCookie;
  PCefClient = ^TCefClient;
  PCefLifeSpanHandler = ^TCefLifeSpanHandler;
  PCefLoadHandler = ^TCefLoadHandler;
  PCefRequestHandler = ^TCefRequestHandler;
  PCefDisplayHandler = ^TCefDisplayHandler;
  PCefFocusHandler = ^TCefFocusHandler;
  PCefKeyboardHandler = ^TCefKeyboardHandler;
  PCefJsDialogHandler = ^TCefJsDialogHandler;
  PCefApp = ^TCefApp;
  PCefV8Exception = ^TCefV8Exception;
  PCefResourceBundleHandler = ^TCefResourceBundleHandler;
  PCefCookieManager = ^TCefCookieManager;
  PCefWebPluginInfo = ^TCefWebPluginInfo;
  PCefCommandLine = ^TCefCommandLine;
  PCefProcessMessage = ^TCefProcessMessage;
  PCefBinaryValue = ^TCefBinaryValue;
  PCefDictionaryValue = ^TCefDictionaryValue;
  PCefListValue = ^TCefListValue;
  PCefBrowserProcessHandler = ^TCefBrowserProcessHandler;
  PCefRenderProcessHandler = ^TCefRenderProcessHandler;
  PCefAuthCallback = ^TCefAuthCallback;
  PCefRequestCallback = ^TCefRequestCallback;
  PCefResourceHandler = ^TCefResourceHandler;
  PCefCallback = ^TCefCallback;
  PCefCompletionCallback = ^TCefCompletionCallback;
  PCefRunContextMenuCallback = ^TCefRunContextMenuCallback;
  PCefContextMenuHandler = ^TCefContextMenuHandler;
  PCefContextMenuParams = ^TCefContextMenuParams;
  PCefMenuModel = ^TCefMenuModel;
  PCefGeolocationCallback = ^TCefGeolocationCallback;
  PCefGeolocationHandler = ^TCefGeolocationHandler;
  PCefBeforeDownloadCallback = ^TCefBeforeDownloadCallback;
  PCefDownloadItemCallback = ^TCefDownloadItemCallback;
  PCefDownloadItem = ^TCefDownloadItem;
  PCefStringVisitor = ^TCefStringVisitor;
  PCefJsDialogCallback = ^TCefJsDialogCallback;
  PCefUrlRequest = ^TCefUrlRequest;
  PCefUrlRequestClient = ^TCefUrlRequestClient;
  PCefWebPluginInfoVisitor = ^TCefWebPluginInfoVisitor;
  PCefWebPluginUnstableCallback = ^TCefWebPluginUnstableCallback;
  PCefFileDialogCallback = ^TCefFileDialogCallback;
  PCefDialogHandler = ^TCefDialogHandler;
  PCefRenderHandler = ^TCefRenderHandler;
  PCefGetGeolocationCallback = ^TCefGetGeolocationCallback;
  PCefEndTracingCallback = ^TCefEndTracingCallback;
  PCefScreenInfo = ^TCefScreenInfo;
  PCefDragData = ^TCefDragData;
  PCefDragHandler = ^TCefDragHandler;
  PCefRequestContextHandler = ^TCefRequestContextHandler;
  PCefRequestContext = ^TCefRequestContext;
  PCefPrintSettings = ^TCefPrintSettings;
  PCefPrintDialogCallback = ^TCefPrintDialogCallback;
  PCefPrintJobCallback = ^TCefPrintJobCallback;
  PCefPrintHandler = ^TCefPrintHandler;
  PCefNavigationEntry = ^TCefNavigationEntry;
  PCefNavigationEntryVisitor = ^TCefNavigationEntryVisitor;
  PCefFindHandler = ^TCefFindHandler;
  PCefSetCookieCallback = ^TCefSetCookieCallback;
  PCefDeleteCookiesCallback = ^TCefDeleteCookiesCallback;
  PCefValue = ^TCefValue;
  PCefSslCertPrincipal = ^TCefSslCertPrincipal;
  PCefSslInfo = ^TCefSslInfo;
  PCefResourceBundle = ^TCefResourceBundle;

  // Structure defining the reference count implementation functions. All
  // framework structures must include the cef_base_t structure first.
  TCefBase = record
    // Size of the data structure.
    size: NativeUInt;

    // Called to increment the reference count for the object. Should be called
    // for every new copy of a pointer to a given object.
    add_ref: procedure(self: PCefBase); stdcall;

    // Called to decrement the reference count for the object. If the reference
    // count falls to 0 the object should self-delete. Returns true (1) if the
    // resulting reference count is 0.
    release: function(self: PCefBase): Integer; stdcall;

    // Returns true (1) if the current reference count is 1.
    has_one_ref: function(self: PCefBase): Integer; stdcall;
  end;

  // Structure that wraps other data value types. Complex types (binary,
  // dictionary and list) will be referenced but not owned by this object. Can be
  // used on any process and thread.
  TCefValue = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if the underlying data is valid. This will always be true
    // (1) for simple types. For complex types (binary, dictionary and list) the
    // underlying data may become invalid if owned by another object (e.g. list or
    // dictionary) and that other object is then modified or destroyed. This value
    // object can be re-used by calling Set*() even if the underlying data is
    // invalid.

    is_valid: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if the underlying data is owned by another object.
    is_owned: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if the underlying data is read-only. Some APIs may expose
    // read-only objects.
    is_read_only: function(self: PCefValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefValue): Integer; stdcall;

    // Returns a copy of this object. The underlying data will also be copied.
    copy: function(self: PCefValue): PCefValue; stdcall;

    // Returns the underlying value type.
    get_type: function(self: PCefValue): TCefValueType; stdcall;

    // Returns the underlying value as type bool.
    get_bool: function(self: PCefValue): Integer; stdcall;

    // Returns the underlying value as type int.
    get_int: function(self: PCefValue): Integer; stdcall;

    // Returns the underlying value as type double.
    get_double: function(self: PCefValue): Double; stdcall;

    // Returns the underlying value as type string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_string: function(self: PCefValue): PCefStringUserFree; stdcall;

    // Returns the underlying value as type binary. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_binary().
    get_binary: function(self: PCefValue): PCefBinaryValue; stdcall;

    // Returns the underlying value as type dictionary. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_dictionary().
    get_dictionary: function(self: PCefValue): PCefDictionaryValue; stdcall;

    // Returns the underlying value as type list. The returned reference may
    // become invalid if the value is owned by another object or if ownership is
    // transferred to another object in the future. To maintain a reference to the
    // value after assigning ownership to a dictionary or list pass this object to
    // the set_value() function instead of passing the returned reference to
    // set_list().
    get_list: function(self: PCefValue): PCefListValue; stdcall;

    // Sets the underlying value as type null. Returns true (1) if the value was
    // set successfully.
    set_null: function(self: PCefValue): Integer; stdcall;

    // Sets the underlying value as type bool. Returns true (1) if the value was
    // set successfully.
    set_bool: function(self: PCefValue; value: Integer): Integer; stdcall;

    // Sets the underlying value as type int. Returns true (1) if the value was
    // set successfully.
    set_int: function(self: PCefValue; value: Integer): Integer; stdcall;

    // Sets the underlying value as type double. Returns true (1) if the value was
    // set successfully.
    set_double: function(self: PCefValue; value: Double): Integer; stdcall;

    // Sets the underlying value as type string. Returns true (1) if the value was
    // set successfully.
    set_string: function(self: PCefValue; const value: PCefString): Integer; stdcall;

    // Sets the underlying value as type binary. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_binary: function(self: PCefValue; value: PCefBinaryValue): Integer; stdcall;

    // Sets the underlying value as type dict. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_dictionary: function(self: PCefValue; value: PCefDictionaryValue): Integer; stdcall;

    // Sets the underlying value as type list. Returns true (1) if the value was
    // set successfully. This object keeps a reference to |value| and ownership of
    // the underlying data remains unchanged.
    set_list: function(self: PCefValue; value: PCefListValue): Integer; stdcall;
  end;

  // Structure representing a binary value. Can be used on any process and thread.
  TCefBinaryValue = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. This object may become invalid if
    // the underlying data is owned by another object (e.g. list or dictionary)
    // and that other object is then modified or destroyed. Do not call any other
    // functions if this function returns false (0).
    is_valid: function(self: PCefBinaryValue): Integer; stdcall;

    // Returns true (1) if this object is currently owned by another object.
    is_owned: function(self: PCefBinaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data.
    is_same: function(self, that: PCefBinaryValue):Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefBinaryValue): Integer; stdcall;

    // Returns a copy of this object. The data in this object will also be copied.
    copy: function(self: PCefBinaryValue): PCefBinaryValue; stdcall;

    // Returns the data size.
    get_size: function(self: PCefBinaryValue): NativeUInt; stdcall;

    // Read up to |buffer_size| number of bytes into |buffer|. Reading begins at
    // the specified byte |data_offset|. Returns the number of bytes read.
    get_data: function(self: PCefBinaryValue; buffer: Pointer; buffer_size,
      data_offset: NativeUInt): NativeUInt; stdcall;
  end;

  // Structure representing a dictionary value. Can be used on any process and
  // thread.
  TCefDictionaryValue = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. This object may become invalid if
    // the underlying data is owned by another object (e.g. list or dictionary)
    // and that other object is then modified or destroyed. Do not call any other
    // functions if this function returns false (0).
    is_valid: function(self: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if this object is currently owned by another object.
    is_owned: function(self: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if the values of this object are read-only. Some APIs may
    // expose read-only objects.
    is_read_only: function(self: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefDictionaryValue): Integer; stdcall;

    // Returns a writable copy of this object. If |exclude_NULL_children| is true
    // (1) any NULL dictionaries or lists will be excluded from the copy.
    copy: function(self: PCefDictionaryValue; exclude_empty_children: Integer): PCefDictionaryValue; stdcall;

    // Returns the number of values.
    get_size: function(self: PCefDictionaryValue): NativeUInt; stdcall;

    // Removes all values. Returns true (1) on success.
    clear: function(self: PCefDictionaryValue): Integer; stdcall;

    // Returns true (1) if the current dictionary has a value for the given key.
    has_key: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // Reads all keys for this dictionary into the specified vector.
    get_keys: function(self: PCefDictionaryValue; const keys: TCefStringList): Integer; stdcall;

    // Removes the value at the specified key. Returns true (1) is the value was
    // removed successfully.
    remove: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // Returns the value type for the specified key.
    get_type: function(self: PCefDictionaryValue; const key: PCefString): TCefValueType; stdcall;

    // Returns the value at the specified key. For simple types the returned value
    // will copy existing data and modifications to the value will not modify this
    // object. For complex types (binary, dictionary and list) the returned value
    // will reference existing data and modifications to the value will modify
    // this object.
    get_value: function(self: PCefDictionaryValue; const key: PCefString): PCefValue; stdcall;

    // Returns the value at the specified key as type bool.
    get_bool: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // Returns the value at the specified key as type int.
    get_int: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // Returns the value at the specified key as type double.
    get_double: function(self: PCefDictionaryValue; const key: PCefString): Double; stdcall;

    // Returns the value at the specified key as type string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_string: function(self: PCefDictionaryValue; const key: PCefString): PCefStringUserFree; stdcall;

    // Returns the value at the specified key as type binary. The returned value
    // will reference existing data.
    get_binary: function(self: PCefDictionaryValue; const key: PCefString): PCefBinaryValue; stdcall;

    // Returns the value at the specified key as type dictionary. The returned
    // value will reference existing data and modifications to the value will
    // modify this object.
    get_dictionary: function(self: PCefDictionaryValue; const key: PCefString): PCefDictionaryValue; stdcall;

    // Returns the value at the specified key as type list. The returned value
    // will reference existing data and modifications to the value will modify
    // this object.
    get_list: function(self: PCefDictionaryValue; const key: PCefString): PCefListValue; stdcall;

    // Sets the value at the specified key. Returns true (1) if the value was set
    // successfully. If |value| represents simple data then the underlying data
    // will be copied and modifications to |value| will not modify this object. If
    // |value| represents complex data (binary, dictionary or list) then the
    // underlying data will be referenced and modifications to |value| will modify
    // this object.
    set_value: function(self: PCefDictionaryValue; const key: PCefString; value: PCefValue): Integer; stdcall;

    // Sets the value at the specified key as type null. Returns true (1) if the
    // value was set successfully.
    set_null: function(self: PCefDictionaryValue; const key: PCefString): Integer; stdcall;

    // Sets the value at the specified key as type bool. Returns true (1) if the
    // value was set successfully.
    set_bool: function(self: PCefDictionaryValue; const key: PCefString; value: Integer): Integer; stdcall;

    // Sets the value at the specified key as type int. Returns true (1) if the
    // value was set successfully.
    set_int: function(self: PCefDictionaryValue; const key: PCefString; value: Integer): Integer; stdcall;

    // Sets the value at the specified key as type double. Returns true (1) if the
    // value was set successfully.
    set_double: function(self: PCefDictionaryValue; const key: PCefString; value: Double): Integer; stdcall;

    // Sets the value at the specified key as type string. Returns true (1) if the
    // value was set successfully.
    set_string: function(self: PCefDictionaryValue; const key: PCefString; value: PCefString): Integer; stdcall;

    // Sets the value at the specified key as type binary. Returns true (1) if the
    // value was set successfully. If |value| is currently owned by another object
    // then the value will be copied and the |value| reference will not change.
    // Otherwise, ownership will be transferred to this object and the |value|
    // reference will be invalidated.
    set_binary: function(self: PCefDictionaryValue; const key: PCefString; value: PCefBinaryValue): Integer; stdcall;

    // Sets the value at the specified key as type dict. Returns true (1) if the
    // value was set successfully. If |value| is currently owned by another object
    // then the value will be copied and the |value| reference will not change.
    // Otherwise, ownership will be transferred to this object and the |value|
    // reference will be invalidated.
    set_dictionary: function(self: PCefDictionaryValue; const key: PCefString; value: PCefDictionaryValue): Integer; stdcall;

    // Sets the value at the specified key as type list. Returns true (1) if the
    // value was set successfully. If |value| is currently owned by another object
    // then the value will be copied and the |value| reference will not change.
    // Otherwise, ownership will be transferred to this object and the |value|
    // reference will be invalidated.
    set_list: function(self: PCefDictionaryValue; const key: PCefString; value: PCefListValue): Integer; stdcall;
  end;

  // Structure representing a list value. Can be used on any process and thread.
  TCefListValue = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. This object may become invalid if
    // the underlying data is owned by another object (e.g. list or dictionary)
    // and that other object is then modified or destroyed. Do not call any other
    // functions if this function returns false (0).
    is_valid: function(self: PCefListValue): Integer; stdcall;

    // Returns true (1) if this object is currently owned by another object.
    is_owned: function(self: PCefListValue): Integer; stdcall;

    // Returns true (1) if the values of this object are read-only. Some APIs may
    // expose read-only objects.
    is_read_only: function(self: PCefListValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have the same underlying
    // data. If true (1) modifications to this object will also affect |that|
    // object and vice-versa.
    is_same: function(self, that: PCefListValue): Integer; stdcall;

    // Returns true (1) if this object and |that| object have an equivalent
    // underlying value but are not necessarily the same object.
    is_equal: function(self, that: PCefListValue): Integer; stdcall;

    // Returns a writable copy of this object.
    copy: function(self: PCefListValue): PCefListValue; stdcall;

    // Sets the number of values. If the number of values is expanded all new
    // value slots will default to type null. Returns true (1) on success.
    set_size: function(self: PCefListValue; size: NativeUInt): Integer; stdcall;

    // Returns the number of values.
    get_size: function(self: PCefListValue): NativeUInt; stdcall;

    // Removes all values. Returns true (1) on success.
    clear: function(self: PCefListValue): Integer; stdcall;

    // Removes the value at the specified index.
    remove: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // Returns the value type at the specified index.
    get_type: function(self: PCefListValue; index: Integer): TCefValueType; stdcall;

    // Returns the value at the specified index. For simple types the returned
    // value will copy existing data and modifications to the value will not
    // modify this object. For complex types (binary, dictionary and list) the
    // returned value will reference existing data and modifications to the value
    // will modify this object.
    get_value: function(self: PCefListValue; index: Integer): PCefValue; stdcall;

    // Returns the value at the specified index as type bool.
    get_bool: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // Returns the value at the specified index as type int.
    get_int: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // Returns the value at the specified index as type double.
    get_double: function(self: PCefListValue; index: Integer): Double; stdcall;

    // Returns the value at the specified index as type string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_string: function(self: PCefListValue; index: Integer): PCefStringUserFree; stdcall;

    // Returns the value at the specified index as type binary. The returned value
    // will reference existing data.
    get_binary: function(self: PCefListValue; index: Integer): PCefBinaryValue; stdcall;

    // Returns the value at the specified index as type dictionary. The returned
    // value will reference existing data and modifications to the value will
    // modify this object.
    get_dictionary: function(self: PCefListValue; index: Integer): PCefDictionaryValue; stdcall;

    // Returns the value at the specified index as type list. The returned value
    // will reference existing data and modifications to the value will modify
    // this object.
    get_list: function(self: PCefListValue; index: Integer): PCefListValue; stdcall;

    // Sets the value at the specified index. Returns true (1) if the value was
    // set successfully. If |value| represents simple data then the underlying
    // data will be copied and modifications to |value| will not modify this
    // object. If |value| represents complex data (binary, dictionary or list)
    // then the underlying data will be referenced and modifications to |value|
    // will modify this object.
    set_value: function(self: PCefListValue; index: Integer; value: PCefValue): Integer; stdcall;

    // Sets the value at the specified index as type null. Returns true (1) if the
    // value was set successfully.
    set_null: function(self: PCefListValue; index: Integer): Integer; stdcall;

    // Sets the value at the specified index as type bool. Returns true (1) if the
    // value was set successfully.
    set_bool: function(self: PCefListValue; index, value: Integer): Integer; stdcall;

    // Sets the value at the specified index as type int. Returns true (1) if the
    // value was set successfully.
    set_int: function(self: PCefListValue; index, value: Integer): Integer; stdcall;

    // Sets the value at the specified index as type double. Returns true (1) if
    // the value was set successfully.
    set_double: function(self: PCefListValue; index: Integer; value: Double): Integer; stdcall;

    // Sets the value at the specified index as type string. Returns true (1) if
    // the value was set successfully.
    set_string: function(self: PCefListValue; index: Integer; value: PCefString): Integer; stdcall;

    // Sets the value at the specified index as type binary. Returns true (1) if
    // the value was set successfully. If |value| is currently owned by another
    // object then the value will be copied and the |value| reference will not
    // change. Otherwise, ownership will be transferred to this object and the
    // |value| reference will be invalidated.
    set_binary: function(self: PCefListValue; index: Integer; value: PCefBinaryValue): Integer; stdcall;

    // Sets the value at the specified index as type dict. Returns true (1) if the
    // value was set successfully. If |value| is currently owned by another object
    // then the value will be copied and the |value| reference will not change.
    // Otherwise, ownership will be transferred to this object and the |value|
    // reference will be invalidated.
    set_dictionary: function(self: PCefListValue; index: Integer; value: PCefDictionaryValue): Integer; stdcall;

    // Sets the value at the specified index as type list. Returns true (1) if the
    // value was set successfully. If |value| is currently owned by another object
    // then the value will be copied and the |value| reference will not change.
    // Otherwise, ownership will be transferred to this object and the |value|
    // reference will be invalidated.
    set_list: function(self: PCefListValue; index: Integer; value: PCefListValue): Integer; stdcall;
  end;

  // Implement this structure for asynchronous task execution. If the task is
  // posted successfully and if the associated message loop is still running then
  // the execute() function will be called on the target thread. If the task fails
  // to post then the task object may be destroyed on the source thread instead of
  // the target thread. For this reason be cautious when performing work in the
  // task object destructor.

  TCefTask = record
    // Base structure.
    base: TCefBase;
    // Method that will be executed on the target thread.
    execute: procedure(self: PCefTask); stdcall;
  end;

  // Structure that asynchronously executes tasks on the associated thread. It is
  // safe to call the functions of this structure on any thread.
  //
  // CEF maintains multiple internal threads that are used for handling different
  // types of tasks in different processes. The cef_thread_id_t definitions in
  // cef_types.h list the common CEF threads. Task runners are also available for
  // other CEF threads as appropriate (for example, V8 WebWorker threads).
  TCefTaskRunner = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is pointing to the same task runner as
    // |that| object.
    is_same: function(self, that: PCefTaskRunner): Integer; stdcall;

    // Returns true (1) if this task runner belongs to the current thread.
    belongs_to_current_thread: function(self: PCefTaskRunner): Integer; stdcall;

    // Returns true (1) if this task runner is for the specified CEF thread.
    belongs_to_thread: function(self: PCefTaskRunner; threadId: TCefThreadId): Integer; stdcall;

    // Post a task for execution on the thread associated with this task runner.
    // Execution will occur asynchronously.
    post_task: function(self: PCefTaskRunner; task: PCefTask): Integer; stdcall;

    // Post a task for delayed execution on the thread associated with this task
    // runner. Execution will occur asynchronously. Delayed tasks are not
    // supported on V8 WebWorker threads and will be executed without the
    // specified delay.
    post_delayed_task: function(self: PCefTaskRunner; task: PCefTask; delay_ms: Int64): Integer; stdcall;
  end;

  // Structure representing a message. Can be used on any process and thread.
  TCefProcessMessage = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. Do not call any other functions
    // if this function returns false (0).
    is_valid: function(self: PCefProcessMessage): Integer; stdcall;

    // Returns true (1) if the values of this object are read-only. Some APIs may
    // expose read-only objects.
    is_read_only: function(self: PCefProcessMessage): Integer; stdcall;

    // Returns a writable copy of this object.
    copy: function(self: PCefProcessMessage): PCefProcessMessage; stdcall;

    // Returns the message name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_name: function(self: PCefProcessMessage): PCefStringUserFree; stdcall;

    // Returns the list of arguments.
    get_argument_list: function(self: PCefProcessMessage): PCefListValue; stdcall;
  end;

  // Class used to represent a browser window. When used in the browser process
  // the methods of this class may be called on any thread unless otherwise
  // indicated in the comments. When used in the render process the methods of
  // this class may only be called on the main thread.

  TCefBrowser = record
    // Base structure.
    base: TCefBase;

    // Returns the browser host object. This function can only be called in the
    // browser process.
    get_host: function(self: PCefBrowser): PCefBrowserHost; stdcall;

    // Returns true (1) if the browser can navigate backwards.
    can_go_back: function(self: PCefBrowser): Integer; stdcall;

    // Navigate backwards.
    go_back: procedure(self: PCefBrowser); stdcall;

    // Returns true (1) if the browser can navigate forwards.
    can_go_forward: function(self: PCefBrowser): Integer; stdcall;

    // Navigate forwards.
    go_forward: procedure(self: PCefBrowser); stdcall;

    // Returns true (1) if the browser is currently loading.
    is_loading: function(self: PCefBrowser): Integer; stdcall;

    // Reload the current page.
    reload: procedure(self: PCefBrowser); stdcall;

    // Reload the current page ignoring any cached data.
    reload_ignore_cache: procedure(self: PCefBrowser); stdcall;

    // Stop loading the page.
    stop_load: procedure(self: PCefBrowser); stdcall;

    // Returns the globally unique identifier for this browser.
    get_identifier  : function(self: PCefBrowser): Integer; stdcall;

    // Returns true (1) if this object is pointing to the same handle as |that|
    // object.
    is_same: function(self, that: PCefBrowser): Integer; stdcall;

    // Returns true (1) if the window is a popup window.
    is_popup: function(self: PCefBrowser): Integer; stdcall;

    // Returns true (1) if a document has been loaded in the browser.
    has_document: function(self: PCefBrowser): Integer; stdcall;

    // Returns the main (top-level) frame for the browser window.
    get_main_frame: function(self: PCefBrowser): PCefFrame; stdcall;

    // Returns the focused frame for the browser window.
    get_focused_frame: function(self: PCefBrowser): PCefFrame; stdcall;

    // Returns the frame with the specified identifier, or NULL if not found.
    get_frame_byident: function(self: PCefBrowser; identifier: Int64): PCefFrame; stdcall;

    // Returns the frame with the specified name, or NULL if not found.
    get_frame: function(self: PCefBrowser; const name: PCefString): PCefFrame; stdcall;

    // Returns the number of frames that currently exist.
    get_frame_count: function(self: PCefBrowser): NativeUInt; stdcall;

    // Returns the identifiers of all existing frames.
    get_frame_identifiers: procedure(self: PCefBrowser; identifiersCount: PNativeUInt; identifiers: PInt64); stdcall;

    // Returns the names of all existing frames.
    get_frame_names: procedure(self: PCefBrowser; names: TCefStringList); stdcall;

    // Send a message to the specified |target_process|. Returns true (1) if the
    // message was sent successfully.
    send_process_message: function(self: PCefBrowser; target_process: TCefProcessId;
      message: PCefProcessMessage): Integer; stdcall;
  end;

  // Callback structure for cef_browser_host_t::RunFileDialog. The functions of
  // this structure will be called on the browser process UI thread.
  TCefRunFileDialogCallback = record
    // Base structure.
    base: TCefBase;

    // Called asynchronously after the file dialog is dismissed.
    // |selected_accept_filter| is the 0-based index of the value selected from
    // the accept filters array passed to cef_browser_host_t::RunFileDialog.
    // |file_paths| will be a single value or a list of values depending on the
    // dialog mode. If the selection was cancelled |file_paths| will be NULL.
    on_file_dialog_dismissed: procedure(self: PCefRunFileDialogCallback;
      selected_accept_filter: Integer; file_paths: TCefStringList); stdcall;
  end;

  // Callback structure for cef_browser_host_t::GetNavigationEntries. The
  // functions of this structure will be called on the browser process UI thread.
  TCefNavigationEntryVisitor = record
    // Base structure.
    base: TCefBase;

    // Method that will be executed. Do not keep a reference to |entry| outside of
    // this callback. Return true (1) to continue visiting entries or false (0) to
    // stop. |current| is true (1) if this entry is the currently loaded
    // navigation entry. |index| is the 0-based index of this entry and |total| is
    // the total number of entries.
    visit: function(self: PCefNavigationEntryVisitor; entry: PCefNavigationEntry;
      current, index, total: Integer): Integer; stdcall;
  end;

  // Callback structure for cef_browser_host_t::PrintToPDF. The functions of this
  // structure will be called on the browser process UI thread.
  TCefPdfPrintCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be executed when the PDF printing has completed. |path| is
    // the output path. |ok| will be true (1) if the printing completed
    // successfully or false (0) otherwise.
    on_pdf_print_finished: procedure(self: PCefPdfPrintCallback;
      const path: PCefString; ok: Integer); stdcall;
  end;


  // Structure used to represent the browser process aspects of a browser window.
  // The functions of this structure can only be called in the browser process.
  // They may be called on any thread in that process unless otherwise indicated
  // in the comments.
  TCefBrowserHost = record
    // Base structure.
    base: TCefBase;

    // Returns the hosted browser object.
    get_browser: function(self: PCefBrowserHost): PCefBrowser; stdcall;

    // Request that the browser close. The JavaScript 'onbeforeunload' event will
    // be fired. If |force_close| is false (0) the event handler, if any, will be
    // allowed to prompt the user and the user can optionally cancel the close. If
    // |force_close| is true (1) the prompt will not be displayed and the close
    // will proceed. Results in a call to cef_life_span_handler_t::do_close() if
    // the event handler allows the close or if |force_close| is true (1). See
    // cef_life_span_handler_t::do_close() documentation for additional usage
    // information.
    close_browser: procedure(self: PCefBrowserHost; force_close: Integer); stdcall;

    // Set whether the browser is focused.
    set_focus: procedure(self: PCefBrowserHost; focus: Integer); stdcall;

    // Set whether the window containing the browser is visible
    // (minimized/unminimized, app hidden/unhidden, etc). Only used on Mac OS X.
    set_window_visibility: procedure(self: PCefBrowserHost; visible: Integer); stdcall;

    // Retrieve the window handle for this browser.
    get_window_handle: function(self: PCefBrowserHost): TCefWindowHandle; stdcall;

    // Retrieve the window handle of the browser that opened this browser. Will
    // return NULL for non-popup windows. This function can be used in combination
    // with custom handling of modal windows.
    get_opener_window_handle: function(self: PCefBrowserHost): TCefWindowHandle; stdcall;

    // Returns the client for this browser.
    get_client: function(self: PCefBrowserHost): PCefClient; stdcall;

    // Returns the request context for this browser.
    get_request_context: function(self: PCefBrowserHost): PCefRequestContext; stdcall;

    // Get the current zoom level. The default zoom level is 0.0. This function
    // can only be called on the UI thread.
    get_zoom_level: function(self: PCefBrowserHost): Double; stdcall;

    // Change the zoom level to the specified value. Specify 0.0 to reset the zoom
    // level. If called on the UI thread the change will be applied immediately.
    // Otherwise, the change will be applied asynchronously on the UI thread.
    set_zoom_level: procedure(self: PCefBrowserHost; zoomLevel: Double); stdcall;

    // Call to run a file chooser dialog. Only a single file chooser dialog may be
    // pending at any given time. |mode| represents the type of dialog to display.
    // |title| to the title to be used for the dialog and may be NULL to show the
    // default title ("Open" or "Save" depending on the mode). |default_file_path|
    // is the path with optional directory and/or file name component that will be
    // initially selected in the dialog. |accept_filters| are used to restrict the
    // selectable file types and may any combination of (a) valid lower-cased MIME
    // types (e.g. "text/*" or "image/*"), (b) individual file extensions (e.g.
    // ".txt" or ".png"), or (c) combined description and file extension delimited
    // using "|" and ";" (e.g. "Image Types|.png;.gif;.jpg").
    // |selected_accept_filter| is the 0-based index of the filter that will be
    // selected by default. |callback| will be executed after the dialog is
    // dismissed or immediately if another dialog is already pending. The dialog
    // will be initiated asynchronously on the UI thread.

    run_file_dialog: procedure(self: PCefBrowserHost; mode: TCefFileDialogMode;
      const title, default_file_path: PCefString; accept_filters: TCefStringList;
      selected_accept_filter: Integer; callback: PCefRunFileDialogCallback); stdcall;

    // Download the file at |url| using cef_download_handler_t.
    start_download: procedure(self: PCefBrowserHost; const url: PCefString); stdcall;

    // Print the current browser contents.
    print: procedure(self: PCefBrowserHost); stdcall;

    // Print the current browser contents to the PDF file specified by |path| and
    // execute |callback| on completion. The caller is responsible for deleting
    // |path| when done. For PDF printing to work on Linux you must implement the
    // cef_print_handler_t::GetPdfPaperSize function.
    print_to_pdf: procedure(self: PCefBrowserHost; const path: PCefString;
        const settings: PCefPdfPrintSettings; callback: PCefPdfPrintCallback); stdcall;

    // Search for |searchText|. |identifier| can be used to have multiple searches
    // running simultaniously. |forward| indicates whether to search forward or
    // backward within the page. |matchCase| indicates whether the search should
    // be case-sensitive. |findNext| indicates whether this is the first request
    // or a follow-up. The cef_find_handler_t instance, if any, returned via
    // cef_client_t::GetFindHandler will be called to report find results.
    find: procedure(self: PCefBrowserHost; identifier: Integer;
        const searchText: PCefString; forward, matchCase, findNext: Integer); stdcall;

    // Cancel all searches that are currently going on.
    stop_finding: procedure(self: PCefBrowserHost; clearSelection: Integer); stdcall;

    // Open developer tools in its own window. If |inspect_element_at| is non-
    // NULL the element at the specified (x,y) location will be inspected.
    show_dev_tools: procedure(self: PCefBrowserHost; const windowInfo: PCefWindowInfo;
        client: PCefClient; const settings: PCefBrowserSettings;
        const inspect_element_at: PCefPoint); stdcall;

    // Explicitly close the developer tools window if one exists for this browser
    // instance.
    close_dev_tools: procedure(self: PCefBrowserHost); stdcall;

    // Retrieve a snapshot of current navigation entries as values sent to the
    // specified visitor. If |current_only| is true (1) only the current
    // navigation entry will be sent, otherwise all navigation entries will be
    // sent.
    get_navigation_entries: procedure(self: PCefBrowserHost;
        visitor: PCefNavigationEntryVisitor; current_only: Integer); stdcall;

    // Set whether mouse cursor change is disabled.
    set_mouse_cursor_change_disabled: procedure(self: PCefBrowserHost; disabled: Integer); stdcall;

    // Returns true (1) if mouse cursor change is disabled.
    is_mouse_cursor_change_disabled: function(self: PCefBrowserHost): Integer; stdcall;

    // If a misspelled word is currently selected in an editable node calling this
    // function will replace it with the specified |word|.
    replace_misspelling: procedure(self: PCefBrowserHost; const word: PCefString); stdcall;

    // Add the specified |word| to the spelling dictionary.
    add_word_to_dictionary: procedure(self: PCefBrowserHost; const word: PCefString); stdcall;

    // Returns true (1) if window rendering is disabled.
    is_window_rendering_disabled: function(self: PCefBrowserHost): Integer; stdcall;

    // Notify the browser that the widget has been resized. The browser will first
    // call cef_render_handler_t::GetViewRect to get the new size and then call
    // cef_render_handler_t::OnPaint asynchronously with the updated regions. This
    // function is only used when window rendering is disabled.
    was_resized: procedure(self: PCefBrowserHost); stdcall;

    // Notify the browser that it has been hidden or shown. Layouting and
    // cef_render_handler_t::OnPaint notification will stop when the browser is
    // hidden. This function is only used when window rendering is disabled.
    was_hidden: procedure(self: PCefBrowserHost; hidden: Integer); stdcall;

    // Send a notification to the browser that the screen info has changed. The
    // browser will then call cef_render_handler_t::GetScreenInfo to update the
    // screen information with the new values. This simulates moving the webview
    // window from one display to another, or changing the properties of the
    // current display. This function is only used when window rendering is
    // disabled.
    notify_screen_info_changed: procedure(self: PCefBrowserHost); stdcall;

    // Invalidate the view. The browser will call cef_render_handler_t::OnPaint
    // asynchronously. This function is only used when window rendering is
    // disabled.
    invalidate: procedure(self: PCefBrowserHost; kind: TCefPaintElementType); stdcall;

    // Send a key event to the browser.
    send_key_event: procedure(self: PCefBrowserHost; const event: PCefKeyEvent); stdcall;

    // Send a mouse click event to the browser. The |x| and |y| coordinates are
    // relative to the upper-left corner of the view.
    send_mouse_click_event: procedure(self: PCefBrowserHost;
      const event: PCefMouseEvent; kind: TCefMouseButtonType;
      mouseUp, clickCount: Integer); stdcall;

    // Send a mouse move event to the browser. The |x| and |y| coordinates are
    // relative to the upper-left corner of the view.
    send_mouse_move_event: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent; mouseLeave: Integer); stdcall;

    // Send a mouse wheel event to the browser. The |x| and |y| coordinates are
    // relative to the upper-left corner of the view. The |deltaX| and |deltaY|
    // values represent the movement delta in the X and Y directions respectively.
    // In order to scroll inside select popups with window rendering disabled
    // cef_render_handler_t::GetScreenPoint should be implemented properly.
    send_mouse_wheel_event: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent; deltaX, deltaY: Integer); stdcall;

    // Send a focus event to the browser.
    send_focus_event: procedure(self: PCefBrowserHost; setFocus: Integer); stdcall;

    // Send a capture lost event to the browser.
    send_capture_lost_event: procedure(self: PCefBrowserHost); stdcall;

    // Notify the browser that the window hosting it is about to be moved or
    // resized. This function is only used on Windows and Linux.
    notify_move_or_resize_started: procedure(self: PCefBrowserHost); stdcall;

    // Returns the maximum rate in frames per second (fps) that
    // cef_render_handler_t:: OnPaint will be called for a windowless browser. The
    // actual fps may be lower if the browser cannot generate frames at the
    // requested rate. The minimum value is 1 and the maximum value is 60 (default
    // 30). This function can only be called on the UI thread.
    get_windowless_frame_rate: function(self: PCefBrowserHost): Integer; stdcall;

    // Set the maximum rate in frames per second (fps) that cef_render_handler_t::
    // OnPaint will be called for a windowless browser. The actual fps may be
    // lower if the browser cannot generate frames at the requested rate. The
    // minimum value is 1 and the maximum value is 60 (default 30). Can also be
    // set at browser creation via cef_browser_tSettings.windowless_frame_rate.
    set_windowless_frame_rate: procedure(self: PCefBrowserHost; frame_rate: Integer); stdcall;

    // Get the NSTextInputContext implementation for enabling IME on Mac when
    // window rendering is disabled.
    get_nstext_input_context: function(self: PCefBrowserHost): TCefTextInputContext; stdcall;

    // Handles a keyDown event prior to passing it through the NSTextInputClient
    // machinery.
    handle_key_event_before_text_input_client: procedure(self: PCefBrowserHost; keyEvent: TCefEventHandle); stdcall;

    // Performs any additional actions after NSTextInputClient handles the event.
    handle_key_event_after_text_input_client: procedure(self: PCefBrowserHost; keyEvent: TCefEventHandle); stdcall;

    // Call this function when the user drags the mouse into the web view (before
    // calling DragTargetDragOver/DragTargetLeave/DragTargetDrop). |drag_data|
    // should not contain file contents as this type of data is not allowed to be
    // dragged into the web view. File contents can be removed using
    // cef_drag_data_t::ResetFileContents (for example, if |drag_data| comes from
    // cef_render_handler_t::StartDragging). This function is only used when
    // window rendering is disabled.
    drag_target_drag_enter: procedure(self: PCefBrowserHost;
        drag_data: PCefDragData;
        const event: PCefMouseEvent;
        allowed_ops: TCefDragOperations); stdcall;

    // Call this function each time the mouse is moved across the web view during
    // a drag operation (after calling DragTargetDragEnter and before calling
    // DragTargetDragLeave/DragTargetDrop). This function is only used when window
    // rendering is disabled.
    drag_target_drag_over: procedure(self: PCefBrowserHost;
        const event: PCefMouseEvent;
        allowed_ops: TCefDragOperations); stdcall;

    // Call this function when the user drags the mouse out of the web view (after
    // calling DragTargetDragEnter). This function is only used when window
    // rendering is disabled.
    drag_target_drag_leave: procedure(self: PCefBrowserHost); stdcall;

    // Call this function when the user completes the drag operation by dropping
    // the object onto the web view (after calling DragTargetDragEnter). The
    // object being dropped is |drag_data|, given as an argument to the previous
    // DragTargetDragEnter call. This function is only used when window rendering
    // is disabled.
    drag_target_drop: procedure(self: PCefBrowserHost; event: PCefMouseEvent); stdcall;

    // Call this function when the drag operation started by a
    // cef_render_handler_t::StartDragging call has ended either in a drop or by
    // being cancelled. |x| and |y| are mouse coordinates relative to the upper-
    // left corner of the view. If the web view is both the drag source and the
    // drag target then all DragTarget* functions should be called before
    // DragSource* mthods. This function is only used when window rendering is
    // disabled.
    drag_source_ended_at: procedure(self: PCefBrowserHost;
        x, y: Integer; op: TCefDragOperation); stdcall;

    // Call this function when the drag operation started by a
    // cef_render_handler_t::StartDragging call has completed. This function may
    // be called immediately without first calling DragSourceEndedAt to cancel a
    // drag operation. If the web view is both the drag source and the drag target
    // then all DragTarget* functions should be called before DragSource* mthods.
    // This function is only used when window rendering is disabled.
    drag_source_system_drag_ended: procedure(self: PCefBrowserHost); stdcall;
  end;

  // Implement this structure to receive string values asynchronously.
  TCefStringVisitor = record
    // Base structure.
    base: TCefBase;

    // Method that will be executed.
    visit: procedure(self: PCefStringVisitor; const str: PCefString); stdcall;
  end;

  // Structure used to represent a frame in the browser window. When used in the
  // browser process the functions of this structure may be called on any thread
  // unless otherwise indicated in the comments. When used in the render process
  // the functions of this structure may only be called on the main thread.
  TCefFrame = record
    // Base structure.
    base: TCefBase;

    // True if this object is currently attached to a valid frame.
    is_valid: function(self: PCefFrame): Integer; stdcall;

    // Execute undo in this frame.
    undo: procedure(self: PCefFrame); stdcall;

    // Execute redo in this frame.
    redo: procedure(self: PCefFrame); stdcall;

    // Execute cut in this frame.
    cut: procedure(self: PCefFrame); stdcall;

    // Execute copy in this frame.
    copy: procedure(self: PCefFrame); stdcall;

    // Execute paste in this frame.
    paste: procedure(self: PCefFrame); stdcall;

    // Execute delete in this frame.
    del: procedure(self: PCefFrame); stdcall;

    // Execute select all in this frame.
    select_all: procedure(self: PCefFrame); stdcall;

    // Save this frame's HTML source to a temporary file and open it in the
    // default text viewing application. This function can only be called from the
    // browser process.
    view_source: procedure(self: PCefFrame); stdcall;

    // Retrieve this frame's HTML source as a string sent to the specified
    // visitor.
    get_source: procedure(self: PCefFrame; visitor: PCefStringVisitor); stdcall;

    // Retrieve this frame's display text as a string sent to the specified
    // visitor.
    get_text: procedure(self: PCefFrame; visitor: PCefStringVisitor); stdcall;

    // Load the request represented by the |request| object.
    load_request: procedure(self: PCefFrame; request: PCefRequest); stdcall;

    // Load the specified |url|.
    load_url: procedure(self: PCefFrame; const url: PCefString); stdcall;

    // Load the contents of |string_val| with the specified dummy |url|. |url|
    // should have a standard scheme (for example, http scheme) or behaviors like
    // link clicks and web security restrictions may not behave as expected.
    load_string: procedure(self: PCefFrame; const stringVal, url: PCefString); stdcall;

    // Execute a string of JavaScript code in this frame. The |script_url|
    // parameter is the URL where the script in question can be found, if any. The
    // renderer may request this URL to show the developer the source of the
    // error.  The |start_line| parameter is the base line number to use for error
    // reporting.
    execute_java_script: procedure(self: PCefFrame; const code,
      script_url: PCefString; start_line: Integer); stdcall;

    // Returns true (1) if this is the main (top-level) frame.
    is_main: function(self: PCefFrame): Integer; stdcall;

    // Returns true (1) if this is the focused frame.
    is_focused: function(self: PCefFrame): Integer; stdcall;

    // Returns the name for this frame. If the frame has an assigned name (for
    // example, set via the iframe "name" attribute) then that value will be
    // returned. Otherwise a unique name will be constructed based on the frame
    // parent hierarchy. The main (top-level) frame will always have an NULL name
    // value.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_name: function(self: PCefFrame): PCefStringUserFree; stdcall;

    // Returns the globally unique identifier for this frame.
    get_identifier: function(self: PCefFrame): Int64; stdcall;

    // Returns the parent of this frame or NULL if this is the main (top-level)
    // frame.
    get_parent: function(self: PCefFrame): PCefFrame; stdcall;

    // Returns the URL currently loaded in this frame.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_url: function(self: PCefFrame): PCefStringUserFree; stdcall;

    // Returns the browser that this frame belongs to.
    get_browser: function(self: PCefFrame): PCefBrowser; stdcall;

    // Get the V8 context associated with the frame. This function can only be
    // called from the render process.
    get_v8context: function(self: PCefFrame): PCefv8Context; stdcall;

    // Visit the DOM document. This function can only be called from the render
    // process.
    visit_dom: procedure(self: PCefFrame; visitor: PCefDomVisitor); stdcall;
  end;

  // Structure used to implement a custom resource bundle structure. The functions
  // of this structure may be called on multiple threads.
  TCefResourceBundleHandler = record
    // Base structure.
    base: TCefBase;

    // Called to retrieve a localized translation for the specified |string_id|.
    // To provide the translation set |string| to the translation string and
    // return true (1). To use the default translation return false (0). Include
    // cef_pack_strings.h for a listing of valid string ID values.
    get_localized_string: function(self: PCefResourceBundleHandler;
      string_id: Integer; string_val: PCefString): Integer; stdcall;

    // Called to retrieve data for the specified scale independent |resource_id|.
    // To provide the resource data set |data| and |data_size| to the data pointer
    // and size respectively and return true (1). To use the default resource data
    // return false (0). The resource data will not be copied and must remain
    // resident in memory. Include cef_pack_resources.h for a listing of valid
    // resource ID values.
    get_data_resource: function(self: PCefResourceBundleHandler;
        resource_id: Integer; var data: Pointer; var data_size: NativeUInt): Integer; stdcall;

    // Called to retrieve data for the specified |resource_id| nearest the scale
    // factor |scale_factor|. To provide the resource data set |data| and
    // |data_size| to the data pointer and size respectively and return true (1).
    // To use the default resource data return false (0). The resource data will
    // not be copied and must remain resident in memory. Include
    // cef_pack_resources.h for a listing of valid resource ID values.
    get_data_resource_for_scale: function(self: PCefResourceBundleHandler;
      resource_id: Integer; scale_factor: TCefScaleFactor; out data: Pointer;
      data_size: NativeUInt): Integer; stdcall;
  end;

  // Structure used to create and/or parse command line arguments. Arguments with
  // '--', '-' and, on Windows, '/' prefixes are considered switches. Switches
  // will always precede any arguments without switch prefixes. Switches can
  // optionally have a value specified using the '=' delimiter (e.g.
  // "-switch=value"). An argument of "--" will terminate switch parsing with all
  // subsequent tokens, regardless of prefix, being interpreted as non-switch
  // arguments. Switch names are considered case-insensitive. This structure can
  // be used before cef_initialize() is called.

  TCefCommandLine = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. Do not call any other functions
    // if this function returns false (0).
    is_valid: function(self: PCefCommandLine): Integer; stdcall;

    // Returns true (1) if the values of this object are read-only. Some APIs may
    // expose read-only objects.
    is_read_only: function(self: PCefCommandLine): Integer; stdcall;

    // Returns a writable copy of this object.
    copy: function(self: PCefCommandLine): PCefCommandLine; stdcall;

    // Initialize the command line with the specified |argc| and |argv| values.
    // The first argument must be the name of the program. This function is only
    // supported on non-Windows platforms.
    init_from_argv: procedure(self: PCefCommandLine; argc: Integer; const argv: PPAnsiChar); stdcall;

    // Initialize the command line with the string returned by calling
    // GetCommandLineW(). This function is only supported on Windows.
    init_from_string: procedure(self: PCefCommandLine; command_line: PCefString); stdcall;

    // Reset the command-line switches and arguments but leave the program
    // component unchanged.
    reset: procedure(self: PCefCommandLine); stdcall;

    // Retrieve the original command line string as a vector of strings. The argv
    // array: { program, [(--|-|/)switch[=value]]*, [--], [argument]* }
    get_argv: procedure(self: PCefCommandLine; argv: TCefStringList); stdcall;

    // Constructs and returns the represented command line string. Use this
    // function cautiously because quoting behavior is unclear.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_command_line_string: function(self: PCefCommandLine): PCefStringUserFree; stdcall;

    // Get the program part of the command line string (the first item).
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_program: function(self: PCefCommandLine): PCefStringUserFree; stdcall;

    // Set the program part of the command line string (the first item).
    set_program: procedure(self: PCefCommandLine; program_: PCefString); stdcall;

    // Returns true (1) if the command line has switches.
    has_switches: function(self: PCefCommandLine): Integer; stdcall;

    // Returns true (1) if the command line contains the given switch.
    has_switch: function(self: PCefCommandLine; const name: PCefString): Integer; stdcall;

    // Returns the value associated with the given switch. If the switch has no
    // value or isn't present this function returns the NULL string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_switch_value: function(self: PCefCommandLine; const name: PCefString): PCefStringUserFree; stdcall;

    // Returns the map of switch names and values. If a switch has no value an
    // NULL string is returned.
    get_switches: procedure(self: PCefCommandLine; switches: TCefStringMap); stdcall;

    // Add a switch to the end of the command line. If the switch has no value
    // pass an NULL value string.
    append_switch: procedure(self: PCefCommandLine; const name: PCefString); stdcall;

    // Add a switch with the specified value to the end of the command line.
    append_switch_with_value: procedure(self: PCefCommandLine; const name, value: PCefString); stdcall;

    // True if there are remaining command line arguments.
    has_arguments: function(self: PCefCommandLine): Integer; stdcall;

    // Get the remaining command line arguments.
    get_arguments: procedure(self: PCefCommandLine; arguments: TCefStringList); stdcall;

    // Add an argument to the end of the command line.
    append_argument: procedure(self: PCefCommandLine; const argument: PCefString); stdcall;

    // Insert a command before the current command. Common for debuggers, like
    // "valgrind" or "gdb --args".
    prepend_wrapper: procedure(self: PCefCommandLine; const wrapper: PCefString); stdcall;
  end;


  // Structure used to implement browser process callbacks. The functions of this
  // structure will be called on the browser process main thread unless otherwise
  // indicated.
  TCefBrowserProcessHandler = record
    // Base structure.
    base: TCefBase;

    // Called on the browser process UI thread immediately after the CEF context
    // has been initialized.
    on_context_initialized: procedure(self: PCefBrowserProcessHandler); stdcall;

    // Called before a child process is launched. Will be called on the browser
    // process UI thread when launching a render process and on the browser
    // process IO thread when launching a GPU or plugin process. Provides an
    // opportunity to modify the child process command line. Do not keep a
    // reference to |command_line| outside of this function.
    on_before_child_process_launch: procedure(self: PCefBrowserProcessHandler;
      command_line: PCefCommandLine); stdcall;

    // Called on the browser process IO thread after the main thread has been
    // created for a new render process. Provides an opportunity to specify extra
    // information that will be passed to
    // cef_render_process_handler_t::on_render_thread_created() in the render
    // process. Do not keep a reference to |extra_info| outside of this function.
    on_render_process_thread_created: procedure(self: PCefBrowserProcessHandler;
        extra_info: PCefListValue); stdcall;

    // Return the handler for printing on Linux. If a print handler is not
    // provided then printing will not be supported on the Linux platform.
    get_print_handler: function(self: PCefBrowserProcessHandler): PCefPrintHandler; stdcall;
  end;

  // Structure used to implement render process callbacks. The functions of this
  // structure will be called on the render process main thread (TID_RENDERER)
  // unless otherwise indicated.
  TCefRenderProcessHandler = record
    // Base structure.
    base: TCefBase;

    // Called after the render process main thread has been created. |extra_info|
    // is a read-only value originating from
    // cef_browser_process_handler_t::on_render_process_thread_created(). Do not
    // keep a reference to |extra_info| outside of this function.
    on_render_thread_created: procedure(self: PCefRenderProcessHandler;
      extra_info: PCefListValue); stdcall;

    // Called after WebKit has been initialized.
    on_web_kit_initialized: procedure(self: PCefRenderProcessHandler); stdcall;

    // Called after a browser has been created. When browsing cross-origin a new
    // browser will be created before the old browser with the same identifier is
    // destroyed.
    on_browser_created: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser); stdcall;

    // Called before a browser is destroyed.
    on_browser_destroyed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser); stdcall;

    // Return the handler for browser load status events.
    get_load_handler: function(self: PCefRenderProcessHandler): PCefLoadHandler; stdcall;

    // Called before browser navigation. Return true (1) to cancel the navigation
    // or false (0) to allow the navigation to proceed. The |request| object
    // cannot be modified in this callback.
    on_before_navigation: function(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
      navigation_type: TCefNavigationType; is_redirect: Integer): Integer; stdcall;

    // Called immediately after the V8 context for a frame has been created. To
    // retrieve the JavaScript 'window' object use the
    // cef_v8context_t::get_global() function. V8 handles can only be accessed
    // from the thread on which they are created. A task runner for posting tasks
    // on the associated thread can be retrieved via the
    // cef_v8context_t::get_task_runner() function.
    on_context_created: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;

    // Called immediately before the V8 context for a frame is released. No
    // references to the context should be kept after this function is called.
    on_context_released: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;

    // Called for global uncaught exceptions in a frame. Execution of this
    // callback is disabled by default. To enable set
    // CefSettings.uncaught_exception_stack_size > 0.
    on_uncaught_exception: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context;
      exception: PCefV8Exception; stackTrace: PCefV8StackTrace); stdcall;

    // Called when a new node in the the browser gets focus. The |node| value may
    // be NULL if no specific node has gained focus. The node object passed to
    // this function represents a snapshot of the DOM at the time this function is
    // executed. DOM objects are only valid for the scope of this function. Do not
    // keep references to or attempt to access any DOM objects outside the scope
    // of this function.
    on_focused_node_changed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; frame: PCefFrame; node: PCefDomNode); stdcall;

    // Called when a new message is received from a different process. Return true
    // (1) if the message was handled or false (0) otherwise. Do not keep a
    // reference to or attempt to access the message outside of this callback.
    on_process_message_received: function(self: PCefRenderProcessHandler;
      browser: PCefBrowser; source_process: TCefProcessId;
      message: PCefProcessMessage): Integer; stdcall;
  end;

  // Implement this structure to provide handler implementations. Methods will be
  // called by the process and/or thread indicated.
  TCefApp = record
    // Base structure.
    base: TCefBase;

    // Provides an opportunity to view and/or modify command-line arguments before
    // processing by CEF and Chromium. The |process_type| value will be NULL for
    // the browser process. Do not keep a reference to the cef_command_line_t
    // object passed to this function. The CefSettings.command_line_args_disabled
    // value can be used to start with an NULL command-line object. Any values
    // specified in CefSettings that equate to command-line arguments will be set
    // before this function is called. Be cautious when using this function to
    // modify command-line arguments for non-browser processes as this may result
    // in undefined behavior including crashes.
    on_before_command_line_processing: procedure(self: PCefApp; const process_type: PCefString;
      command_line: PCefCommandLine); stdcall;

    // Provides an opportunity to register custom schemes. Do not keep a reference
    // to the |registrar| object. This function is called on the main thread for
    // each process and the registered schemes should be the same across all
    // processes.
    on_register_custom_schemes: procedure(self: PCefApp; registrar: PCefSchemeRegistrar); stdcall;

    // Return the handler for resource bundle events. If
    // CefSettings.pack_loading_disabled is true (1) a handler must be returned.
    // If no handler is returned resources will be loaded from pack files. This
    // function is called by the browser and render processes on multiple threads.
    get_resource_bundle_handler: function(self: PCefApp): PCefResourceBundleHandler; stdcall;

    // Return the handler for functionality specific to the browser process. This
    // function is called on multiple threads in the browser process.
    get_browser_process_handler: function(self: PCefApp): PCefBrowserProcessHandler; stdcall;

    // Return the handler for functionality specific to the render process. This
    // function is called on the render process main thread.
    get_render_process_handler: function(self: PCefApp): PCefRenderProcessHandler; stdcall;
  end;


  // Implement this structure to handle events related to browser life span. The
  // functions of this structure will be called on the UI thread unless otherwise
  // indicated.
  TCefLifeSpanHandler = record
    // Base structure.
    base: TCefBase;

    // Called on the IO thread before a new popup browser is created. The
    // |browser| and |frame| values represent the source of the popup request. The
    // |target_url| and |target_frame_name| values indicate where the popup
    // browser should navigate and may be NULL if not specified with the request.
    // The |target_disposition| value indicates where the user intended to open
    // the popup (e.g. current tab, new tab, etc). The |user_gesture| value will
    // be true (1) if the popup was opened via explicit user gesture (e.g.
    // clicking a link) or false (0) if the popup opened automatically (e.g. via
    // the DomContentLoaded event). The |popupFeatures| structure contains
    // additional information about the requested popup window. To allow creation
    // of the popup browser optionally modify |windowInfo|, |client|, |settings|
    // and |no_javascript_access| and return false (0). To cancel creation of the
    // popup browser return true (1). The |client| and |settings| values will
    // default to the source browser's values. If the |no_javascript_access| value
    // is set to false (0) the new browser will not be scriptable and may not be
    // hosted in the same renderer process as the source browser.

    on_before_popup: function(self: PCefLifeSpanHandler;
      browser: PCefBrowser; frame: PCefFrame;
      const target_url, target_frame_name: PCefString;
      target_disposition: TCefWindowOpenDisposition; user_gesture: Integer;
      const popupFeatures: PCefPopupFeatures;
      windowInfo: PCefWindowInfo; var client: PCefClient;
      settings: PCefBrowserSettings; no_javascript_access: PInteger): Integer; stdcall;

    // Called after a new browser is created.
    on_after_created: procedure(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;

    // Called when a modal window is about to display and the modal loop should
    // begin running. Return false (0) to use the default modal loop
    // implementation or true (1) to use a custom implementation.
    run_modal: function(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;

    // Called when a browser has recieved a request to close. This may result
    // directly from a call to cef_browser_host_t::close_browser() or indirectly
    // if the browser is a top-level OS window created by CEF and the user
    // attempts to close the window. This function will be called after the
    // JavaScript 'onunload' event has been fired. It will not be called for
    // browsers after the associated OS window has been destroyed (for those
    // browsers it is no longer possible to cancel the close).
    //
    // If CEF created an OS window for the browser returning false (0) will send
    // an OS close notification to the browser window's top-level owner (e.g.
    // WM_CLOSE on Windows, performClose: on OS-X and "delete_event" on Linux). If
    // no OS window exists (window rendering disabled) returning false (0) will
    // cause the browser object to be destroyed immediately. Return true (1) if
    // the browser is parented to another window and that other window needs to
    // receive close notification via some non-standard technique.
    //
    // If an application provides its own top-level window it should handle OS
    // close notifications by calling cef_browser_host_t::CloseBrowser(false (0))
    // instead of immediately closing (see the example below). This gives CEF an
    // opportunity to process the 'onbeforeunload' event and optionally cancel the
    // close before do_close() is called.
    //
    // The cef_life_span_handler_t::on_before_close() function will be called
    // immediately before the browser object is destroyed. The application should
    // only exit after on_before_close() has been called for all existing
    // browsers.
    //
    // If the browser represents a modal window and a custom modal loop
    // implementation was provided in cef_life_span_handler_t::run_modal() this
    // callback should be used to restore the opener window to a usable state.
    //
    // By way of example consider what should happen during window close when the
    // browser is parented to an application-provided top-level OS window. 1.
    // User clicks the window close button which sends an OS close
    //     notification (e.g. WM_CLOSE on Windows, performClose: on OS-X and
    //     "delete_event" on Linux).
    // 2.  Application's top-level window receives the close notification and:
    //     A. Calls CefBrowserHost::CloseBrowser(false).
    //     B. Cancels the window close.
    // 3.  JavaScript 'onbeforeunload' handler executes and shows the close
    //     confirmation dialog (which can be overridden via
    //     CefJSDialogHandler::OnBeforeUnloadDialog()).
    // 4.  User approves the close. 5.  JavaScript 'onunload' handler executes. 6.
    // Application's do_close() handler is called. Application will:
    //     A. Set a flag to indicate that the next close attempt will be allowed.
    //     B. Return false.
    // 7.  CEF sends an OS close notification. 8.  Application's top-level window
    // receives the OS close notification and
    //     allows the window to close based on the flag from #6B.
    // 9.  Browser OS window is destroyed. 10. Application's
    // cef_life_span_handler_t::on_before_close() handler is called and
    //     the browser object is destroyed.
    // 11. Application exits by calling cef_quit_message_loop() if no other
    // browsers
    //     exist.
    do_close: function(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;

    // Called just before a browser is destroyed. Release all references to the
    // browser object and do not attempt to execute any functions on the browser
    // object after this callback returns. If this is a modal window and a custom
    // modal loop implementation was provided in run_modal() this callback should
    // be used to exit the custom modal loop. See do_close() documentation for
    // additional usage information.
    on_before_close: procedure(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
  end;


  // Implement this structure to handle events related to browser load status. The

  // functions of this structure will be called on the UI thread.
  TCefLoadHandler = record
    // Base structure.
    base: TCefBase;

    // Called when the loading state has changed. This callback will be executed
    // twice -- once when loading is initiated either programmatically or by user
    // action, and once when loading is terminated due to completion, cancellation
    // of failure.
    on_loading_state_change: procedure(self: PCefLoadHandler;
      browser: PCefBrowser; isLoading, canGoBack, canGoForward: Integer); stdcall;

    // Called when the browser begins loading a frame. The |frame| value will
    // never be NULL -- call the is_main() function to check if this frame is the
    // main frame. Multiple frames may be loading at the same time. Sub-frames may
    // start or continue loading after the main frame load has ended. This
    // function may not be called for a particular frame if the load request for
    // that frame fails. For notification of overall browser load status use
    // OnLoadingStateChange instead.
    on_load_start: procedure(self: PCefLoadHandler;
      browser: PCefBrowser; frame: PCefFrame); stdcall;

    // Called when the browser is done loading a frame. The |frame| value will
    // never be NULL -- call the is_main() function to check if this frame is the
    // main frame. Multiple frames may be loading at the same time. Sub-frames may
    // start or continue loading after the main frame load has ended. This
    // function will always be called for all frames irrespective of whether the
    // request completes successfully.
    on_load_end: procedure(self: PCefLoadHandler; browser: PCefBrowser;
      frame: PCefFrame; httpStatusCode: Integer); stdcall;

    // Called when the resource load for a navigation fails or is canceled.
    // |errorCode| is the error code number, |errorText| is the error text and
    // |failedUrl| is the URL that failed to load. See net\base\net_error_list.h
    // for complete descriptions of the error codes.
    on_load_error: procedure(self: PCefLoadHandler; browser: PCefBrowser;
      frame: PCefFrame; errorCode: Integer; const errorText, failedUrl: PCefString); stdcall;
  end;

  // Generic callback structure used for asynchronous continuation.
  TCefCallback = record
    // Base structure.
    base: TCefBase;

    // Continue processing.
    cont: procedure(self: PCefCallback); stdcall;

    // Cancel processing.
    cancel: procedure(self: PCefCallback); stdcall;
  end;

  // Generic callback structure used for asynchronous completion.
  TCefCompletionCallback = record
    // Base structure.
    base: TCefBase;
    // Method that will be called once the task is complete.
    on_complete: procedure(self: PCefCompletionCallback); stdcall;
  end;


  // Structure used to implement a custom request handler structure. The functions
  // of this structure will always be called on the IO thread.
  TCefResourceHandler = record
    // Base structure.
    base: TCefBase;

    // Begin processing the request. To handle the request return true (1) and
    // call cef_callback_t::cont() once the response header information is
    // available (cef_callback_t::cont() can also be called from inside this
    // function if header information is available immediately). To cancel the
    // request return false (0).
    process_request: function(self: PCefResourceHandler;
      request: PCefRequest; callback: PCefCallback): Integer; stdcall;

    // Retrieve response header information. If the response length is not known
    // set |response_length| to -1 and read_response() will be called until it
    // returns false (0). If the response length is known set |response_length| to
    // a positive value and read_response() will be called until it returns false
    // (0) or the specified number of bytes have been read. Use the |response|
    // object to set the mime type, http status code and other optional header
    // values. To redirect the request to a new URL set |redirectUrl| to the new
    // URL.
    get_response_headers: procedure(self: PCefResourceHandler;
      response: PCefResponse; response_length: PInt64; redirectUrl: PCefString); stdcall;

    // Read response data. If data is available immediately copy up to
    // |bytes_to_read| bytes into |data_out|, set |bytes_read| to the number of
    // bytes copied, and return true (1). To read the data at a later time set
    // |bytes_read| to 0, return true (1) and call cef_callback_t::cont() when the
    // data is available. To indicate response completion return false (0).
    read_response: function(self: PCefResourceHandler;
      data_out: Pointer; bytes_to_read: Integer; bytes_read: PInteger;
        callback: PCefCallback): Integer; stdcall;

    // Return true (1) if the specified cookie can be sent with the request or
    // false (0) otherwise. If false (0) is returned for any cookie then no
    // cookies will be sent with the request.
    can_get_cookie: function(self: PCefResourceHandler;
      const cookie: PCefCookie): Integer; stdcall;

    // Return true (1) if the specified cookie returned with the response can be
    // set or false (0) otherwise.
    can_set_cookie: function(self: PCefResourceHandler;
      const cookie: PCefCookie): Integer; stdcall;

    // Request processing has been canceled.
    cancel: procedure(self: PCefResourceHandler); stdcall;
  end;

  // Callback structure used for asynchronous continuation of authentication
  // requests.
  TCefAuthCallback = record
    // Base structure.
    base: TCefBase;

    // Continue the authentication request.
    cont: procedure(self: PCefAuthCallback;
        const username, password: PCefString); stdcall;

    // Cancel the authentication request.
    cancel: procedure(self: PCefAuthCallback); stdcall;
  end;

  // Callback structure used for asynchronous continuation of quota requests.
  TCefRequestCallback = record
    // Base structure.
    base: TCefBase;

    // Continue the url request. If |allow| is true (1) the request will be
    // continued. Otherwise, the request will be canceled.
    cont: procedure(self: PCefRequestCallback; allow: Integer); stdcall;
    // Cancel the quota request.
    cancel: procedure(self: PCefRequestCallback); stdcall;
  end;

  // Implement this structure to handle events related to browser requests. The
  // functions of this structure will be called on the thread indicated.
  TCefRequestHandler = record
    // Base structure.
    base: TCefBase;

    // Called on the UI thread before browser navigation. Return true (1) to
    // cancel the navigation or false (0) to allow the navigation to proceed. The
    // |request| object cannot be modified in this callback.
    // cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
    // If the navigation is allowed cef_load_handler_t::OnLoadStart and
    // cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
    // cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
    // ERR_ABORTED.
    on_before_browse: function(self: PCefRequestHandler; browser: PCefBrowser;
     frame: PCefFrame; request: PCefRequest; isRedirect: Integer): Integer; stdcall;

    // Called on the UI thread before OnBeforeBrowse in certain limited cases
    // where navigating a new or different browser might be desirable. This
    // includes user-initiated navigation that might open in a special way (e.g.
    // links clicked via middle-click or ctrl + left-click) and certain types of
    // cross-origin navigation initiated from the renderer process (e.g.
    // navigating the top-level frame to/from a file URL). The |browser| and
    // |frame| values represent the source of the navigation. The
    // |target_disposition| value indicates where the user intended to navigate
    // the browser based on standard Chromium behaviors (e.g. current tab, new
    // tab, etc). The |user_gesture| value will be true (1) if the browser
    // navigated via explicit user gesture (e.g. clicking a link) or false (0) if
    // it navigated automatically (e.g. via the DomContentLoaded event). Return
    // true (1) to cancel the navigation or false (0) to allow the navigation to
    // proceed in the source browser's top-level frame.
    on_open_urlfrom_tab: function(self: PCefRequestHandler; browser:PCefBrowser;
      frame: PCefFrame; const target_url: PCefString;
      target_disposition: TCefWindowOpenDisposition; user_gesture: Integer): Integer; stdcall;

    // Called on the IO thread before a resource request is loaded. The |request|
    // object may be modified. To cancel the request return true (1) otherwise
    // return false (0).
    on_before_resource_load: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
      callback: PCefRequestCallback): TCefReturnValue; stdcall;

    // Called on the IO thread before a resource is loaded. To allow the resource
    // to load normally return NULL. To specify a handler for the resource return
    // a cef_resource_handler_t object. The |request| object should not be
    // modified in this callback.
    get_resource_handler: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; request: PCefRequest): PCefResourceHandler; stdcall;

    // Called on the IO thread when a resource load is redirected. The |request|
    // parameter will contain the old URL and other request-related information.
    // The |new_url| parameter will contain the new URL and can be changed if
    // desired. The |request| object cannot be modified in this callback.
    on_resource_redirect: procedure(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; const request: PCefRequest;
      new_url: PCefString); stdcall;

    // Called on the IO thread when a resource response is received. To allow the
    // resource to load normally return false (0). To redirect or retry the
    // resource modify |request| (url, headers or post body) and return true (1).
    // The |response| object cannot be modified in this callback.
    on_resource_response: function(self: PCefRequestHandler;
        browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
        response: PCefResponse): Integer; stdcall;

    // Called on the IO thread when the browser needs credentials from the user.
    // |isProxy| indicates whether the host is a proxy server. |host| contains the
    // hostname and |port| contains the port number. Return true (1) to continue
    // the request and call cef_auth_callback_t::cont() either in this function or
    // at a later time when the authentication information is available. Return
    // false (0) to cancel the request immediately.
    get_auth_credentials: function(self: PCefRequestHandler;
      browser: PCefBrowser; frame: PCefFrame; isProxy: Integer; const host: PCefString;
      port: Integer; const realm, scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;

    // Called on the IO thread when JavaScript requests a specific storage quota
    // size via the webkitStorageInfo.requestQuota function. |origin_url| is the
    // origin of the page making the request. |new_size| is the requested quota
    // size in bytes. Return true (1) to continue the request and call
    // cef_request_tCallback::cont() either in this function or at a later time to
    // grant or deny the request. Return false (0) to cancel the request
    // immediately.
    on_quota_request: function(self: PCefRequestHandler; browser: PCefBrowser;
      const origin_url: PCefString; new_size: Int64; callback: PCefRequestCallback): Integer; stdcall;

    // Called on the UI thread to handle requests for URLs with an unknown
    // protocol component. Set |allow_os_execution| to true (1) to attempt
    // execution via the registered OS protocol handler, if any. SECURITY WARNING:
    // YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
    // OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
    on_protocol_execution: procedure(self: PCefRequestHandler;
      browser: PCefBrowser; const url: PCefString; allow_os_execution: PInteger); stdcall;

    // Called on the UI thread to handle requests for URLs with an invalid SSL
    // certificate. Return true (1) and call cef_request_tCallback::cont() either
    // in this function or at a later time to continue or cancel the request.
    // Return false (0) to cancel the request immediately. If |callback| is NULL
    // the error cannot be recovered from and the request will be canceled
    // automatically. If CefSettings.ignore_certificate_errors is set all invalid
    // certificates will be accepted without calling this function.
    on_certificate_error: function(self: PCefRequestHandler;
      browser: PCefBrowser; cert_error: TCefErrorcode;
      const request_url: PCefString; ssl_info: PCefSslInfo;
      callback: PCefRequestCallback): Integer; stdcall;

    // Called on the browser process UI thread when a plugin has crashed.
    // |plugin_path| is the path of the plugin that crashed.
    on_plugin_crashed: procedure(self: PCefRequestHandler; browser: PCefBrowser;
      const plugin_path: PCefString); stdcall;

    // Called on the browser process UI thread when the render view associated
    // with |browser| is ready to receive/handle IPC messages in the render
    // process.
    on_render_view_ready: procedure(self: PCefRequestHandler; browser: PCefBrowser); stdcall;

    // Called on the browser process UI thread when the render process terminates
    // unexpectedly. |status| indicates how the process terminated.
    on_render_process_terminated: procedure(self: PCefRequestHandler; browser: PCefBrowser;
      status: TCefTerminationStatus); stdcall;
  end;

  // Implement this structure to handle events related to browser display state.

  // The functions of this structure will be called on the UI thread.
  TCefDisplayHandler = record
    // Base structure.
    base: TCefBase;

    // Called when a frame's address has changed.
    on_address_change: procedure(self: PCefDisplayHandler;
      browser: PCefBrowser; frame: PCefFrame; const url: PCefString); stdcall;

    // Called when the page title changes.
    on_title_change: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; const title: PCefString); stdcall;

    // Called when the page icon changes.
    on_favicon_urlchange: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; icon_urls: TCefStringList); stdcall;

    // Called when web content in the page has toggled fullscreen mode. If
    // |fullscreen| is true (1) the content will automatically be sized to fill
    // the browser content area. If |fullscreen| is false (0) the content will
    // automatically return to its original size and position. The client is
    // responsible for resizing the browser if desired.
    on_fullscreen_mode_change: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; fullscreen: Integer); stdcall;

    // Called when the browser is about to display a tooltip. |text| contains the
    // text that will be displayed in the tooltip. To handle the display of the
    // tooltip yourself return true (1). Otherwise, you can optionally modify
    // |text| and then return false (0) to allow the browser to display the
    // tooltip. When window rendering is disabled the application is responsible
    // for drawing tooltips and the return value is ignored.
    on_tooltip: function(self: PCefDisplayHandler;
        browser: PCefBrowser; text: PCefString): Integer; stdcall;

    // Called when the browser receives a status message. |value| contains the
    // text that will be displayed in the status message.
    on_status_message: procedure(self: PCefDisplayHandler;
        browser: PCefBrowser; const value: PCefString); stdcall;

    // Called to display a console message. Return true (1) to stop the message
    // from being output to the console.
    on_console_message: function(self: PCefDisplayHandler;
        browser: PCefBrowser; const message: PCefString;
        const source: PCefString; line: Integer): Integer; stdcall;
  end;

  // Implement this structure to handle events related to focus. The functions of
  // this structure will be called on the UI thread.
  TCefFocusHandler = record
    // Base structure.
    base: TCefBase;

    // Called when the browser component is about to loose focus. For instance, if
    // focus was on the last HTML element and the user pressed the TAB key. |next|
    // will be true (1) if the browser is giving focus to the next component and
    // false (0) if the browser is giving focus to the previous component.
    on_take_focus: procedure(self: PCefFocusHandler;
        browser: PCefBrowser; next: Integer); stdcall;

    // Called when the browser component is requesting focus. |source| indicates
    // where the focus request is originating from. Return false (0) to allow the
    // focus to be set or true (1) to cancel setting the focus.
    on_set_focus: function(self: PCefFocusHandler;
        browser: PCefBrowser; source: TCefFocusSource): Integer; stdcall;

    // Called when the browser component has received focus.
    on_got_focus: procedure(self: PCefFocusHandler; browser: PCefBrowser); stdcall;
  end;

  // Implement this structure to handle events related to keyboard input. The
  // functions of this structure will be called on the UI thread.
  TCefKeyboardHandler = record
    // Base structure.
    base: TCefBase;

    // Called before a keyboard event is sent to the renderer. |event| contains
    // information about the keyboard event. |os_event| is the operating system
    // event message, if any. Return true (1) if the event was handled or false
    // (0) otherwise. If the event will be handled in on_key_event() as a keyboard
    // shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
    on_pre_key_event: function(self: PCefKeyboardHandler;
      browser: PCefBrowser; const event: PCefKeyEvent;
      os_event: TCefEventHandle; is_keyboard_shortcut: PInteger): Integer; stdcall;

    // Called after the renderer and JavaScript in the page has had a chance to
    // handle the event. |event| contains information about the keyboard event.
    // |os_event| is the operating system event message, if any. Return true (1)
    // if the keyboard event was handled or false (0) otherwise.
    on_key_event: function(self: PCefKeyboardHandler;
        browser: PCefBrowser; const event: PCefKeyEvent;
        os_event: TCefEventHandle): Integer; stdcall;
  end;

  // Callback structure used for asynchronous continuation of JavaScript dialog
  // requests.
  TCefJsDialogCallback = record
    // Base structure.
    base: TCefBase;

    // Continue the JS dialog request. Set |success| to true (1) if the OK button
    // was pressed. The |user_input| value should be specified for prompt dialogs.
    cont: procedure(self: PCefJsDialogCallback; success: Integer; const user_input: PCefString); stdcall;
  end;

  // Implement this structure to handle events related to JavaScript dialogs. The
  // functions of this structure will be called on the UI thread.
  TCefJsDialogHandler = record
    // Base structure.
    base: TCefBase;

    // Called to run a JavaScript dialog. The |default_prompt_text| value will be
    // specified for prompt dialogs only. Set |suppress_message| to true (1) and
    // return false (0) to suppress the message (suppressing messages is
    // preferable to immediately executing the callback as this is used to detect
    // presumably malicious behavior like spamming alert messages in
    // onbeforeunload). Set |suppress_message| to false (0) and return false (0)
    // to use the default implementation (the default implementation will show one
    // modal dialog at a time and suppress any additional dialog requests until
    // the displayed dialog is dismissed). Return true (1) if the application will
    // use a custom dialog or if the callback has been executed immediately.
    // Custom dialogs may be either modal or modeless. If a custom dialog is used
    // the application must execute |callback| once the custom dialog is
    // dismissed.
    on_jsdialog: function(self: PCefJsDialogHandler;
      browser: PCefBrowser; const origin_url, accept_lang: PCefString;
      dialog_type: TCefJsDialogType; const message_text, default_prompt_text: PCefString;
      callback: PCefJsDialogCallback; suppress_message: PInteger): Integer; stdcall;

    // Called to run a dialog asking the user if they want to leave a page. Return
    // false (0) to use the default dialog implementation. Return true (1) if the
    // application will use a custom dialog or if the callback has been executed
    // immediately. Custom dialogs may be either modal or modeless. If a custom
    // dialog is used the application must execute |callback| once the custom
    // dialog is dismissed.
    on_before_unload_dialog: function(self: PCefJsDialogHandler;
      browser: PCefBrowser; const message_text: PCefString; is_reload: Integer;
      callback: PCefJsDialogCallback): Integer; stdcall;

    // Called to cancel any pending dialogs and reset any saved dialog state. Will
    // be called due to events like page navigation irregardless of whether any
    // dialogs are currently pending.
    on_reset_dialog_state: procedure(self: PCefJsDialogHandler; browser: PCefBrowser); stdcall;

    // Called when the default implementation dialog is closed.
    on_dialog_closed: procedure(self: PCefJsDialogHandler; browser: PCefBrowser); stdcall;
  end;

  // Supports creation and modification of menus. See cef_menu_id_t for the
  // command ids that have default implementations. All user-defined command ids
  // should be between MENU_ID_USER_FIRST and MENU_ID_USER_LAST. The functions of
  // this structure can only be accessed on the browser process the UI thread.
  TCefMenuModel = record
    // Base structure.
    base: TCefBase;

    // Clears the menu. Returns true (1) on success.
    clear: function(self: PCefMenuModel): Integer; stdcall;

    // Returns the number of items in this menu.
    get_count: function(self: PCefMenuModel): Integer; stdcall;

    // Add a separator to the menu. Returns true (1) on success.
    add_separator: function(self: PCefMenuModel): Integer; stdcall;

    // Add an item to the menu. Returns true (1) on success.
    add_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // Add a check item to the menu. Returns true (1) on success.
    add_check_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // Add a radio item to the menu. Only a single item with the specified
    // |group_id| can be checked at a time. Returns true (1) on success.
    add_radio_item: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString; group_id: Integer): Integer; stdcall;

    // Add a sub-menu to the menu. The new sub-menu is returned.
    add_sub_menu: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): PCefMenuModel; stdcall;

    // Insert a separator in the menu at the specified |index|. Returns true (1)
    // on success.
    insert_separator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Insert an item in the menu at the specified |index|. Returns true (1) on
    // success.
    insert_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // Insert a check item in the menu at the specified |index|. Returns true (1)
    // on success.
    insert_check_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // Insert a radio item in the menu at the specified |index|. Only a single
    // item with the specified |group_id| can be checked at a time. Returns true
    // (1) on success.
    insert_radio_item_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString; group_id: Integer): Integer; stdcall;

    // Insert a sub-menu in the menu at the specified |index|. The new sub-menu is
    // returned.
    insert_sub_menu_at: function(self: PCefMenuModel; index, command_id: Integer;
      const text: PCefString): PCefMenuModel; stdcall;

    // Removes the item with the specified |command_id|. Returns true (1) on
    // success.
    remove: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Removes the item at the specified |index|. Returns true (1) on success.
    remove_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Returns the index associated with the specified |command_id| or -1 if not
    // found due to the command id not existing in the menu.
    get_index_of: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns the command id at the specified |index| or -1 if not found due to
    // invalid range or the index being a separator.
    get_command_id_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Sets the command id at the specified |index|. Returns true (1) on success.
    set_command_id_at: function(self: PCefMenuModel; index, command_id: Integer): Integer; stdcall;

    // Returns the label for the specified |command_id| or NULL if not found.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_label: function(self: PCefMenuModel; command_id: Integer): PCefStringUserFree; stdcall;

    // Returns the label at the specified |index| or NULL if not found due to
    // invalid range or the index being a separator.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_label_at: function(self: PCefMenuModel; index: Integer): PCefStringUserFree; stdcall;

    // Sets the label for the specified |command_id|. Returns true (1) on success.
    set_label: function(self: PCefMenuModel; command_id: Integer;
      const text: PCefString): Integer; stdcall;

    // Set the label at the specified |index|. Returns true (1) on success.
    set_label_at: function(self: PCefMenuModel; index: Integer;
      const text: PCefString): Integer; stdcall;

    // Returns the item type for the specified |command_id|.
    get_type: function(self: PCefMenuModel; command_id: Integer): TCefMenuItemType; stdcall;

    // Returns the item type at the specified |index|.
    get_type_at: function(self: PCefMenuModel; index: Integer): TCefMenuItemType; stdcall;

    // Returns the group id for the specified |command_id| or -1 if invalid.
    get_group_id: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns the group id at the specified |index| or -1 if invalid.
    get_group_id_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Sets the group id for the specified |command_id|. Returns true (1) on
    // success.
    set_group_id: function(self: PCefMenuModel; command_id, group_id: Integer): Integer; stdcall;

    // Sets the group id at the specified |index|. Returns true (1) on success.
    set_group_id_at: function(self: PCefMenuModel; index, group_id: Integer): Integer; stdcall;

    // Returns the submenu for the specified |command_id| or NULL if invalid.
    get_sub_menu: function(self: PCefMenuModel; command_id: Integer): PCefMenuModel; stdcall;

    // Returns the submenu at the specified |index| or NULL if invalid.
    get_sub_menu_at: function(self: PCefMenuModel; index: Integer): PCefMenuModel; stdcall;

    // Returns true (1) if the specified |command_id| is visible.
    is_visible: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns true (1) if the specified |index| is visible.
    is_visible_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Change the visibility of the specified |command_id|. Returns true (1) on
    // success.
    set_visible: function(self: PCefMenuModel; command_id, visible: Integer): Integer; stdcall;

    // Change the visibility at the specified |index|. Returns true (1) on
    // success.
    set_visible_at: function(self: PCefMenuModel; index, visible: Integer): Integer; stdcall;

    // Returns true (1) if the specified |command_id| is enabled.
    is_enabled: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns true (1) if the specified |index| is enabled.
    is_enabled_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Change the enabled status of the specified |command_id|. Returns true (1)
    // on success.
    set_enabled: function(self: PCefMenuModel; command_id, enabled: Integer): Integer; stdcall;

    // Change the enabled status at the specified |index|. Returns true (1) on
    // success.
    set_enabled_at: function(self: PCefMenuModel; index, enabled: Integer): Integer; stdcall;

    // Returns true (1) if the specified |command_id| is checked. Only applies to
    // check and radio items.
    is_checked: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns true (1) if the specified |index| is checked. Only applies to check
    // and radio items.
    is_checked_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Check the specified |command_id|. Only applies to check and radio items.
    // Returns true (1) on success.
    set_checked: function(self: PCefMenuModel; command_id, checked: Integer): Integer; stdcall;

    // Check the specified |index|. Only applies to check and radio items. Returns
    // true (1) on success.
    set_checked_at: function(self: PCefMenuModel; index, checked: Integer): Integer; stdcall;

    // Returns true (1) if the specified |command_id| has a keyboard accelerator
    // assigned.
    has_accelerator: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Returns true (1) if the specified |index| has a keyboard accelerator
    // assigned.
    has_accelerator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Set the keyboard accelerator for the specified |command_id|. |key_code| can
    // be any virtual key or character value. Returns true (1) on success.
    set_accelerator: function(self: PCefMenuModel; command_id, key_code,
      shift_pressed, ctrl_pressed, alt_pressed: Integer): Integer; stdcall;

    // Set the keyboard accelerator at the specified |index|. |key_code| can be
    // any virtual key or character value. Returns true (1) on success.
    set_accelerator_at: function(self: PCefMenuModel; index, key_code,
      shift_pressed, ctrl_pressed, alt_pressed: Integer): Integer; stdcall;

    // Remove the keyboard accelerator for the specified |command_id|. Returns
    // true (1) on success.
    remove_accelerator: function(self: PCefMenuModel; command_id: Integer): Integer; stdcall;

    // Remove the keyboard accelerator at the specified |index|. Returns true (1)
    // on success.
    remove_accelerator_at: function(self: PCefMenuModel; index: Integer): Integer; stdcall;

    // Retrieves the keyboard accelerator for the specified |command_id|. Returns
    // true (1) on success.
    get_accelerator: function(self: PCefMenuModel; command_id: Integer; key_code,
      shift_pressed, ctrl_pressed, alt_pressed: PInteger): Integer; stdcall;

    // Retrieves the keyboard accelerator for the specified |index|. Returns true
    // (1) on success.
    get_accelerator_at: function(self: PCefMenuModel; index: Integer; key_code,
      shift_pressed, ctrl_pressed, alt_pressed: PInteger): Integer; stdcall;
  end;


  // Callback structure used for continuation of custom context menu display.
  TCefRunContextMenuCallback = record
    // Base structure.
    base: TCefBase;
    // Complete context menu display by selecting the specified |command_id| and
    // |event_flags|.
    cont: procedure(self: PCefRunContextMenuCallback; command_id: Integer;
      event_flags: TCefEventFlags); stdcall;
    // Cancel context menu display.
    cancel: procedure(self: PCefRunContextMenuCallback); stdcall;
  end;

  // Implement this structure to handle context menu events. The functions of this
  // structure will be called on the UI thread.
  TCefContextMenuHandler = record
    // Base structure.
    base: TCefBase;

    // Called before a context menu is displayed. |params| provides information
    // about the context menu state. |model| initially contains the default
    // context menu. The |model| can be cleared to show no context menu or
    // modified to show a custom menu. Do not keep references to |params| or
    // |model| outside of this callback.
    on_before_context_menu: procedure(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      model: PCefMenuModel); stdcall;

    // Called to allow custom display of the context menu. |params| provides
    // information about the context menu state. |model| contains the context menu
    // model resulting from OnBeforeContextMenu. For custom display return true
    // (1) and execute |callback| either synchronously or asynchronously with the
    // selected command ID. For default display return false (0). Do not keep
    // references to |params| or |model| outside of this callback.
    run_context_menu: function(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      model: PCefMenuModel; callback: PCefRunContextMenuCallback): Integer; stdcall;

    // Called to execute a command selected from the context menu. Return true (1)
    // if the command was handled or false (0) for the default implementation. See
    // cef_menu_id_t for the command ids that have default implementations. All
    // user-defined command ids should be between MENU_ID_USER_FIRST and
    // MENU_ID_USER_LAST. |params| will have the same values as what was passed to
    // on_before_context_menu(). Do not keep a reference to |params| outside of
    // this callback.
    on_context_menu_command: function(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
      command_id: Integer; event_flags: Integer): Integer; stdcall;

    // Called when the context menu is dismissed irregardless of whether the menu
    // was NULL or a command was selected.
    on_context_menu_dismissed: procedure(self: PCefContextMenuHandler;
      browser: PCefBrowser; frame: PCefFrame); stdcall;
  end;


  // Provides information about the context menu state. The ethods of this
  // structure can only be accessed on browser process the UI thread.
  TCefContextMenuParams = record
    // Base structure.
    base: TCefBase;

    // Returns the X coordinate of the mouse where the context menu was invoked.
    // Coords are relative to the associated RenderView's origin.
    get_xcoord: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns the Y coordinate of the mouse where the context menu was invoked.
    // Coords are relative to the associated RenderView's origin.
    get_ycoord: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns flags representing the type of node that the context menu was
    // invoked on.
    get_type_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns the URL of the link, if any, that encloses the node that the
    // context menu was invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_link_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the link URL, if any, to be used ONLY for "copy link address". We
    // don't validate this field in the frontend process.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_unfiltered_link_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the source URL, if any, for the element that the context menu was
    // invoked on. Example of elements with source URLs are img, audio, and video.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_source_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns true (1) if the context menu was invoked on an image which has non-
    // NULL contents.
    has_image_contents: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns the URL of the top level page that the context menu was invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_page_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the URL of the subframe that the context menu was invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_frame_url: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the character encoding of the subframe that the context menu was
    // invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_frame_charset: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the type of context node that the context menu was invoked on.
    get_media_type: function(self: PCefContextMenuParams): TCefContextMenuMediaType; stdcall;

    // Returns flags representing the actions supported by the media element, if
    // any, that the context menu was invoked on.
    get_media_state_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns the text of the selection, if any, that the context menu was
    // invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_text: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns the text of the misspelled word, if any, that the context menu was
    // invoked on.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_misspelled_word: function(self: PCefContextMenuParams): PCefStringUserFree; stdcall;

    // Returns true (1) if suggestions exist, false (0) otherwise. Fills in
    // |suggestions| from the spell check service for the misspelled word if there
    // is one.
    get_dictionary_suggestions: function(self: PCefContextMenuParams;
      suggestions: TCefStringList): Integer; stdcall;

    // Returns true (1) if the context menu was invoked on an editable node.
    is_editable: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns true (1) if the context menu was invoked on an editable node where
    // spell-check is enabled.
    is_spell_check_enabled: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns flags representing the actions supported by the editable node, if
    // any, that the context menu was invoked on.
    get_edit_state_flags: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns true (1) if the context menu contains items specified by the
    // renderer process (for example, plugin placeholder or pepper plugin menu
    // items).
    is_custom_menu: function(self: PCefContextMenuParams): Integer; stdcall;

    // Returns true (1) if the context menu was invoked from a pepper plugin.
    is_pepper_menu: function(self: PCefContextMenuParams): Integer; stdcall;
  end;

  // Callback structure used for asynchronous continuation of geolocation
  // permission requests.
  TCefGeolocationCallback = record
    // Base structure.
    base: TCefBase;

    // Call to allow or deny geolocation access.
    cont: procedure(self: PCefGeolocationCallback; allow: Integer); stdcall;
  end;


  // Implement this structure to handle events related to geolocation permission
  // requests. The functions of this structure will be called on the browser
  // process UI thread.
  TCefGeolocationHandler = record
    // Base structure.
    base: TCefBase;

    // Called when a page requests permission to access geolocation information.
    // |requesting_url| is the URL requesting permission and |request_id| is the
    // unique ID for the permission request. Return true (1) and call
    // cef_geolocation_callback_t::cont() either in this function or at a later
    // time to continue or cancel the request. Return false (0) to cancel the
    // request immediately.
    on_request_geolocation_permission: function(self: PCefGeolocationHandler;
        browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer;
        callback: PCefGeolocationCallback): Integer; stdcall;

    // Called when a geolocation access request is canceled. |requesting_url| is
    // the URL that originally requested permission and |request_id| is the unique
    // ID for the permission request.
    on_cancel_geolocation_permission: procedure(self: PCefGeolocationHandler;
        browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer); stdcall;
  end;

  // Implement this structure to handle events related to find results. The
  // functions of this structure will be called on the UI thread.
  TCefFindHandler = record
    // Base structure.
    base: TCefBase;

    // Called to report find results returned by cef_browser_host_t::find().
    // |identifer| is the identifier passed to find(), |count| is the number of
    // matches currently identified, |selectionRect| is the location of where the
    // match was found (in window coordinates), |activeMatchOrdinal| is the
    // current position in the search results, and |finalUpdate| is true (1) if
    // this is the last find notification.
    on_find_result: procedure(self: PCefFindHandler; browser: PCefBrowser;
      identifier, count: Integer; const selection_rect: PCefRect;
      active_match_ordinal, final_update: Integer); stdcall;
  end;

  // Implement this structure to provide handler implementations.
  TCefClient = record
    // Base structure.
    base: TCefBase;

    // Return the handler for context menus. If no handler is provided the default
    // implementation will be used.
    get_context_menu_handler: function(self: PCefClient): PCefContextMenuHandler; stdcall;

    // Return the handler for dialogs. If no handler is provided the default
    // implementation will be used.
    get_dialog_handler: function(self: PCefClient): PCefDialogHandler; stdcall;

    // Return the handler for browser display state events.
    get_display_handler: function(self: PCefClient): PCefDisplayHandler; stdcall;

    // Return the handler for download events. If no handler is returned downloads
    // will not be allowed.
    get_download_handler: function(self: PCefClient): PCefDownloadHandler; stdcall;

    // Return the handler for drag events.
    get_drag_handler: function(self: PCefClient): PCefDragHandler; stdcall;

    // Return the handler for find result events.
    get_find_handler: function(self: PCefClient): PCefFindHandler; stdcall;

    // Return the handler for focus events.
    get_focus_handler: function(self: PCefClient): PCefFocusHandler; stdcall;

    // Return the handler for geolocation permissions requests. If no handler is
    // provided geolocation access will be denied by default.
    get_geolocation_handler: function(self: PCefClient): PCefGeolocationHandler; stdcall;

    // Return the handler for JavaScript dialog events.
    get_jsdialog_handler: function(self: PCefClient): PCefJsDialogHandler; stdcall;

    // Return the handler for keyboard events.
    get_keyboard_handler: function(self: PCefClient): PCefKeyboardHandler; stdcall;

    // Return the handler for browser life span events.
    get_life_span_handler: function(self: PCefClient): PCefLifeSpanHandler; stdcall;

    // Return the handler for browser load status events.
    get_load_handler: function(self: PCefClient): PCefLoadHandler; stdcall;

    // Return the handler for off-screen rendering events.
    get_render_handler: function(self: PCefClient): PCefRenderHandler; stdcall;

    // Return the handler for browser request events.
    get_request_handler: function(self: PCefClient): PCefRequestHandler; stdcall;

    // Called when a new message is received from a different process. Return true
    // (1) if the message was handled or false (0) otherwise. Do not keep a
    // reference to or attempt to access the message outside of this callback.
    on_process_message_received: function(self: PCefClient; browser: PCefBrowser;
      source_process: TCefProcessId; message: PCefProcessMessage): Integer; stdcall;
  end;

  // Structure used to represent a web request. The functions of this structure
  // may be called on any thread.
  TCefRequest = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is read-only.
    is_read_only: function(self: PCefRequest): Integer; stdcall;

    // Get the fully qualified URL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_url: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // Set the fully qualified URL.
    set_url: procedure(self: PCefRequest; const url: PCefString); stdcall;

    // Get the request function type. The value will default to POST if post data
    // is provided and GET otherwise.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_method: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // Set the request function type.
    set_method: procedure(self: PCefRequest; const method: PCefString); stdcall;

    // Get the post data.
    get_post_data: function(self: PCefRequest): PCefPostData; stdcall;
    // Set the post data.
    set_post_data: procedure(self: PCefRequest; postData: PCefPostData); stdcall;

    // Get the header values.
    get_header_map: procedure(self: PCefRequest; headerMap: TCefStringMultimap); stdcall;
    // Set the header values.
    set_header_map: procedure(self: PCefRequest; headerMap: TCefStringMultimap); stdcall;

    // Set all values at one time.
    set_: procedure(self: PCefRequest; const url, method: PCefString;
      postData: PCefPostData; headerMap: TCefStringMultimap); stdcall;

    // Get the flags used in combination with cef_urlrequest_t. See
    // cef_urlrequest_flags_t for supported values.
    get_flags: function(self: PCefRequest): Integer; stdcall;
    // Set the flags used in combination with cef_urlrequest_t.  See
    // cef_urlrequest_flags_t for supported values.
    set_flags: procedure(self: PCefRequest; flags: Integer); stdcall;

    // Get the URL to the first party for cookies used in combination with
    // cef_urlrequest_t.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_first_party_for_cookies: function(self: PCefRequest): PCefStringUserFree; stdcall;
    // Set the URL to the first party for cookies used in combination with
    // cef_urlrequest_t.
    set_first_party_for_cookies: procedure(self: PCefRequest; const url: PCefString); stdcall;

    // Get the resource type for this request. Only available in the browser
    // process.
    get_resource_type: function(self: PCefRequest): TCefResourceType; stdcall;

    // Get the transition type for this request. Only available in the browser
    // process and only applies to requests that represent a main frame or sub-
    // frame navigation.
    get_transition_type: function(self: PCefRequest): TCefTransitionType; stdcall;

    // Returns the globally unique identifier for this request or 0 if not
    // specified. Can be used by cef_request_tHandler implementations in the
    // browser process to track a single request across multiple callbacks.
    get_identifier: function(self: PCefRequest): UInt64; stdcall;
  end;


  TCefPostDataElementArray = array[0..(High(Integer) div SizeOf(PCefPostDataElement)) - 1] of PCefPostDataElement;
  PCefPostDataElementArray = ^TCefPostDataElementArray;

  // Structure used to represent post data for a web request. The functions of
  // this structure may be called on any thread.
  TCefPostData = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is read-only.
    is_read_only: function(self: PCefPostData):Integer; stdcall;

    // Returns the number of existing post data elements.
    get_element_count: function(self: PCefPostData): NativeUInt; stdcall;

    // Retrieve the post data elements.
    get_elements: procedure(self: PCefPostData; elementsCount: PNativeUInt;
      elements: PCefPostDataElementArray); stdcall;

    // Remove the specified post data element.  Returns true (1) if the removal
    // succeeds.
    remove_element: function(self: PCefPostData;
      element: PCefPostDataElement): Integer; stdcall;

    // Add the specified post data element.  Returns true (1) if the add succeeds.
    add_element: function(self: PCefPostData;
        element: PCefPostDataElement): Integer; stdcall;

    // Remove all existing post data elements.
    remove_elements: procedure(self: PCefPostData); stdcall;

  end;

  // Structure used to represent a single element in the request post data. The
  // functions of this structure may be called on any thread.
  TCefPostDataElement = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is read-only.
    is_read_only: function(self: PCefPostDataElement): Integer; stdcall;

    // Remove all contents from the post data element.
    set_to_empty: procedure(self: PCefPostDataElement); stdcall;

    // The post data element will represent a file.
    set_to_file: procedure(self: PCefPostDataElement;
        const fileName: PCefString); stdcall;

    // The post data element will represent bytes.  The bytes passed in will be
    // copied.
    set_to_bytes: procedure(self: PCefPostDataElement;
        size: NativeUInt; const bytes: Pointer); stdcall;

    // Return the type of this post data element.
    get_type: function(self: PCefPostDataElement): TCefPostDataElementType; stdcall;

    // Return the file name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_file: function(self: PCefPostDataElement): PCefStringUserFree; stdcall;

    // Return the number of bytes.
    get_bytes_count: function(self: PCefPostDataElement): NativeUInt; stdcall;

    // Read up to |size| bytes into |bytes| and return the number of bytes
    // actually read.
    get_bytes: function(self: PCefPostDataElement;
        size: NativeUInt; bytes: Pointer): NativeUInt; stdcall;
  end;

  // Structure used to represent a web response. The functions of this structure
  // may be called on any thread.
  TCefResponse = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is read-only.
    is_read_only: function(self: PCefResponse): Integer; stdcall;

    // Get the response status code.
    get_status: function(self: PCefResponse): Integer; stdcall;
    // Set the response status code.
    set_status: procedure(self: PCefResponse; status: Integer); stdcall;

    // Get the response status text.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_status_text: function(self: PCefResponse): PCefStringUserFree; stdcall;
    // Set the response status text.
    set_status_text: procedure(self: PCefResponse; const statusText: PCefString); stdcall;

    // Get the response mime type.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_mime_type: function(self: PCefResponse): PCefStringUserFree; stdcall;
    // Set the response mime type.
    set_mime_type: procedure(self: PCefResponse; const mimeType: PCefString); stdcall;

    // Get the value for the specified response header field.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_header: function(self: PCefResponse; const name: PCefString): PCefStringUserFree; stdcall;

    // Get all response header fields.
    get_header_map: procedure(self: PCefResponse; headerMap: TCefStringMultimap); stdcall;
    // Set all response header fields.
    set_header_map: procedure(self: PCefResponse; headerMap: TCefStringMultimap); stdcall;
  end;

  // Structure the client can implement to provide a custom stream reader. The
  // functions of this structure may be called on any thread.
  TCefReadHandler = record
    // Base structure.
    base: TCefBase;

    // Read raw binary data.
    read: function(self: PCefReadHandler; ptr: Pointer;
      size, n: NativeUInt): NativeUInt; stdcall;

    // Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    // SEEK_END or SEEK_SET. Return zero on success and non-zero on failure.
    seek: function(self: PCefReadHandler; offset: Int64;
      whence: Integer): Integer; stdcall;

    // Return the current offset position.
    tell: function(self: PCefReadHandler): Int64; stdcall;

    // Return non-zero if at end of file.
    eof: function(self: PCefReadHandler): Integer; stdcall;

    // Return true (1) if this handler performs work like accessing the file
    // system which may block. Used as a hint for determining the thread to access
    // the handler from.
    may_block: function(self: PCefReadHandler): Integer; stdcall;
  end;

  // Structure used to read data from a stream. The functions of this structure
  // may be called on any thread.
  TCefStreamReader = record
    // Base structure.
    base: TCefBase;

    // Read raw binary data.
    read: function(self: PCefStreamReader; ptr: Pointer;
        size, n: NativeUInt): NativeUInt; stdcall;

    // Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    // SEEK_END or SEEK_SET. Returns zero on success and non-zero on failure.
    seek: function(self: PCefStreamReader; offset: Int64;
        whence: Integer): Integer; stdcall;

    // Return the current offset position.
    tell: function(self: PCefStreamReader): Int64; stdcall;

    // Return non-zero if at end of file.
    eof: function(self: PCefStreamReader): Integer; stdcall;

    // Returns true (1) if this reader performs work like accessing the file
    // system which may block. Used as a hint for determining the thread to access
    // the reader from.
    may_block: function(self: PCefStreamReader): Integer; stdcall;
  end;

  // Structure the client can implement to provide a custom stream writer. The
  // functions of this structure may be called on any thread.
  TCefWriteHandler = record
    // Base structure.
    base: TCefBase;

    // Write raw binary data.
    write: function(self: PCefWriteHandler;
        const ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;

    // Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    // SEEK_END or SEEK_SET.
    seek: function(self: PCefWriteHandler; offset: Int64;
        whence: Integer): Integer; stdcall;

    // Return the current offset position.
    tell: function(self: PCefWriteHandler): Int64; stdcall;

    // Flush the stream.
    flush: function(self: PCefWriteHandler): Integer; stdcall;

    // Return true (1) if this handler performs work like accessing the file
    // system which may block. Used as a hint for determining the thread to access
    // the handler from.
    may_block: function(self: PCefWriteHandler): Integer; stdcall;
  end;

  // Structure used to write data to a stream. The functions of this structure may
  // be called on any thread.
  // TODO: Implement class
  TCefStreamWriter = record
    // Base structure.
    base: TCefBase;

    // Write raw binary data.
    write: function(self: PCefStreamWriter;
        const ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;

    // Seek to the specified offset position. |whence| may be any one of SEEK_CUR,
    // SEEK_END or SEEK_SET.
    seek: function(self: PCefStreamWriter; offset: Int64;
        whence: Integer): Integer; stdcall;

    // Return the current offset position.
    tell: function(self: PCefStreamWriter): Int64; stdcall;

    // Flush the stream.
    flush: function(self: PCefStreamWriter): Integer; stdcall;

    // Returns true (1) if this writer performs work like accessing the file
    // system which may block. Used as a hint for determining the thread to access
    // the writer from.
    may_block: function(self: PCefStreamWriter): Integer; stdcall;
  end;

  // Structure representing a V8 context handle. V8 handles can only be accessed
  // from the thread on which they are created. Valid threads for creating a V8
  // handle include the render process main thread (TID_RENDERER) and WebWorker
  // threads. A task runner for posting tasks on the associated thread can be
  // retrieved via the cef_v8context_t::get_task_runner() function.

  TCefV8Context = record
    // Base structure.
    base: TCefBase;

    // Returns the task runner associated with this context. V8 handles can only
    // be accessed from the thread on which they are created. This function can be
    // called on any render process thread.
    get_task_runner: function(self: PCefv8Context): PCefTask; stdcall;

    // Returns true (1) if the underlying handle is valid and it can be accessed
    // on the current thread. Do not call any other functions if this function
    // returns false (0).
    is_valid: function(self: PCefv8Context): Integer; stdcall;

    // Returns the browser for this context. This function will return an NULL
    // reference for WebWorker contexts.
    get_browser: function(self: PCefv8Context): PCefBrowser; stdcall;

    // Returns the frame for this context. This function will return an NULL
    // reference for WebWorker contexts.
    get_frame: function(self: PCefv8Context): PCefFrame; stdcall;

    // Returns the global object for this context. The context must be entered
    // before calling this function.
    get_global: function(self: PCefv8Context): PCefv8Value; stdcall;

    // Enter this context. A context must be explicitly entered before creating a
    // V8 Object, Array, Function or Date asynchronously. exit() must be called
    // the same number of times as enter() before releasing this context. V8
    // objects belong to the context in which they are created. Returns true (1)
    // if the scope was entered successfully.
    enter: function(self: PCefv8Context): Integer; stdcall;

    // Exit this context. Call this function only after calling enter(). Returns
    // true (1) if the scope was exited successfully.
    exit: function(self: PCefv8Context): Integer; stdcall;

    // Returns true (1) if this object is pointing to the same handle as |that|
    // object.
    is_same: function(self, that: PCefv8Context): Integer; stdcall;

    // Evaluates the specified JavaScript code using this context's global object.
    // On success |retval| will be set to the return value, if any, and the
    // function will return true (1). On failure |exception| will be set to the
    // exception, if any, and the function will return false (0).
    eval: function(self: PCefv8Context; const code: PCefString;
      var retval: PCefv8Value; var exception: PCefV8Exception): Integer; stdcall;
  end;

  // Structure that should be implemented to handle V8 function calls. The
  // functions of this structure will be called on the thread associated with the
  // V8 function.
  TCefv8Handler = record
    // Base structure.
    base: TCefBase;

    // Handle execution of the function identified by |name|. |object| is the
    // receiver ('this' object) of the function. |arguments| is the list of
    // arguments passed to the function. If execution succeeds set |retval| to the
    // function return value. If execution fails set |exception| to the exception
    // that will be thrown. Return true (1) if execution was handled.
    execute: function(self: PCefv8Handler;
        const name: PCefString; obj: PCefv8Value; argumentsCount: NativeUInt;
        const arguments: PPCefV8Value; var retval: PCefV8Value;
        var exception: TCefString): Integer; stdcall;
  end;

  // Structure that should be implemented to handle V8 accessor calls. Accessor
  // identifiers are registered by calling cef_v8value_t::set_value(). The
  // functions of this structure will be called on the thread associated with the
  // V8 accessor.
  TCefV8Accessor = record
    // Base structure.
    base: TCefBase;

    // Handle retrieval the accessor value identified by |name|. |object| is the
    // receiver ('this' object) of the accessor. If retrieval succeeds set
    // |retval| to the return value. If retrieval fails set |exception| to the
    // exception that will be thrown. Return true (1) if accessor retrieval was
    // handled.
    get: function(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; out retval: PCefv8Value; exception: PCefString): Integer; stdcall;

    // Handle assignment of the accessor value identified by |name|. |object| is
    // the receiver ('this' object) of the accessor. |value| is the new value
    // being assigned to the accessor. If assignment fails set |exception| to the
    // exception that will be thrown. Return true (1) if accessor assignment was
    // handled.
    put: function(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; value: PCefv8Value; exception: PCefString): Integer; stdcall;
  end;

  // Structure representing a V8 exception. The functions of this structure may be
  // called on any render process thread.
  TCefV8Exception = record
    // Base structure.
    base: TCefBase;

    // Returns the exception message.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_message: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // Returns the line of source code that the exception occurred within.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_source_line: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // Returns the resource name for the script from where the function causing
    // the error originates.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_script_resource_name: function(self: PCefV8Exception): PCefStringUserFree; stdcall;

    // Returns the 1-based number of the line where the error occurred or 0 if the
    // line number is unknown.
    get_line_number: function(self: PCefV8Exception): Integer; stdcall;

    // Returns the index within the script of the first character where the error
    // occurred.
    get_start_position: function(self: PCefV8Exception): Integer; stdcall;

    // Returns the index within the script of the last character where the error
    // occurred.
    get_end_position: function(self: PCefV8Exception): Integer; stdcall;

    // Returns the index within the line of the first character where the error
    // occurred.
    get_start_column: function(self: PCefV8Exception): Integer; stdcall;

    // Returns the index within the line of the last character where the error
    // occurred.
    get_end_column: function(self: PCefV8Exception): Integer; stdcall;
  end;


  // Structure representing a V8 value handle. V8 handles can only be accessed
  // from the thread on which they are created. Valid threads for creating a V8
  // handle include the render process main thread (TID_RENDERER) and WebWorker
  // threads. A task runner for posting tasks on the associated thread can be
  // retrieved via the cef_v8context_t::get_task_runner() function.

  TCefv8Value = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if the underlying handle is valid and it can be accessed
    // on the current thread. Do not call any other functions if this function
    // returns false (0).
    is_valid: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is undefined.
    is_undefined: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is null.
    is_null: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is bool.
    is_bool: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is int.
    is_int: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is unsigned int.
    is_uint: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is double.
    is_double: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is Date.
    is_date: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is string.
    is_string: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is object.
    is_object: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is array.
    is_array: function(self: PCefv8Value): Integer; stdcall;
    // True if the value type is function.
    is_function: function(self: PCefv8Value): Integer; stdcall;

    // Returns true (1) if this object is pointing to the same handle as |that|
    // object.
    is_same: function(self, that: PCefv8Value): Integer; stdcall;

    // Return a bool value.  The underlying data will be converted to if
    // necessary.
    get_bool_value: function(self: PCefv8Value): Integer; stdcall;
    // Return an int value.  The underlying data will be converted to if
    // necessary.
    get_int_value: function(self: PCefv8Value): Integer; stdcall;
    // Return an unisgned int value.  The underlying data will be converted to if
    // necessary.
    get_uint_value: function(self: PCefv8Value): Cardinal; stdcall;
    // Return a double value.  The underlying data will be converted to if
    // necessary.
    get_double_value: function(self: PCefv8Value): Double; stdcall;
    // Return a Date value.  The underlying data will be converted to if
    // necessary.
    get_date_value: function(self: PCefv8Value): TCefTime; stdcall;
    // Return a string value.  The underlying data will be converted to if
    // necessary.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_string_value: function(self: PCefv8Value): PCefStringUserFree; stdcall;


    // OBJECT METHODS - These functions are only available on objects. Arrays and
    // functions are also objects. String- and integer-based keys can be used
    // interchangably with the framework converting between them as necessary.

    // Returns true (1) if this is a user created object.
    is_user_created: function(self: PCefv8Value): Integer; stdcall;

    // Returns true (1) if the last function call resulted in an exception. This
    // attribute exists only in the scope of the current CEF value object.
    has_exception: function(self: PCefv8Value): Integer; stdcall;

    // Returns the exception resulting from the last function call. This attribute
    // exists only in the scope of the current CEF value object.
    get_exception: function(self: PCefv8Value): PCefV8Exception; stdcall;

    // Clears the last exception and returns true (1) on success.
    clear_exception: function(self: PCefv8Value): Integer; stdcall;

    // Returns true (1) if this object will re-throw future exceptions. This
    // attribute exists only in the scope of the current CEF value object.
    will_rethrow_exceptions: function(self: PCefv8Value): Integer; stdcall;

    // Set whether this object will re-throw future exceptions. By default
    // exceptions are not re-thrown. If a exception is re-thrown the current
    // context should not be accessed again until after the exception has been
    // caught and not re-thrown. Returns true (1) on success. This attribute
    // exists only in the scope of the current CEF value object.
    set_rethrow_exceptions: function(self: PCefv8Value; rethrow: Integer): Integer; stdcall;


    // Returns true (1) if the object has a value with the specified identifier.
    has_value_bykey: function(self: PCefv8Value; const key: PCefString): Integer; stdcall;
    // Returns true (1) if the object has a value with the specified identifier.
    has_value_byindex: function(self: PCefv8Value; index: Integer): Integer; stdcall;

    // Deletes the value with the specified identifier and returns true (1) on
    // success. Returns false (0) if this function is called incorrectly or an
    // exception is thrown. For read-only and don't-delete values this function
    // will return true (1) even though deletion failed.
    delete_value_bykey: function(self: PCefv8Value; const key: PCefString): Integer; stdcall;
    // Deletes the value with the specified identifier and returns true (1) on
    // success. Returns false (0) if this function is called incorrectly, deletion
    // fails or an exception is thrown. For read-only and don't-delete values this
    // function will return true (1) even though deletion failed.
    delete_value_byindex: function(self: PCefv8Value; index: Integer): Integer; stdcall;

    // Returns the value with the specified identifier on success. Returns NULL if
    // this function is called incorrectly or an exception is thrown.
    get_value_bykey: function(self: PCefv8Value; const key: PCefString): PCefv8Value; stdcall;
    // Returns the value with the specified identifier on success. Returns NULL if
    // this function is called incorrectly or an exception is thrown.
    get_value_byindex: function(self: PCefv8Value; index: Integer): PCefv8Value; stdcall;

    // Associates a value with the specified identifier and returns true (1) on
    // success. Returns false (0) if this function is called incorrectly or an
    // exception is thrown. For read-only values this function will return true
    // (1) even though assignment failed.
    set_value_bykey: function(self: PCefv8Value; const key: PCefString;
      value: PCefv8Value; attribute: Integer): Integer; stdcall;
    // Associates a value with the specified identifier and returns true (1) on
    // success. Returns false (0) if this function is called incorrectly or an
    // exception is thrown. For read-only values this function will return true
    // (1) even though assignment failed.
    set_value_byindex: function(self: PCefv8Value; index: Integer;
       value: PCefv8Value): Integer; stdcall;

    // Registers an identifier and returns true (1) on success. Access to the
    // identifier will be forwarded to the cef_v8accessor_t instance passed to
    // cef_v8value_t::cef_v8value_create_object(). Returns false (0) if this
    // function is called incorrectly or an exception is thrown. For read-only
    // values this function will return true (1) even though assignment failed.
    set_value_byaccessor: function(self: PCefv8Value; const key: PCefString;
      settings: Integer; attribute: Integer): Integer; stdcall;

    // Read the keys for the object's values into the specified vector. Integer-
    // based keys will also be returned as strings.
    get_keys: function(self: PCefv8Value; keys: TCefStringList): Integer; stdcall;

    // Sets the user data for this object and returns true (1) on success. Returns
    // false (0) if this function is called incorrectly. This function can only be
    // called on user created objects.
    set_user_data: function(self: PCefv8Value; user_data: PCefBase): Integer; stdcall;

    // Returns the user data, if any, assigned to this object.
    get_user_data: function(self: PCefv8Value): PCefBase; stdcall;

    // Returns the amount of externally allocated memory registered for the
    // object.
    get_externally_allocated_memory: function(self: PCefv8Value): Integer; stdcall;

    // Adjusts the amount of registered external memory for the object. Used to
    // give V8 an indication of the amount of externally allocated memory that is
    // kept alive by JavaScript objects. V8 uses this information to decide when
    // to perform global garbage collection. Each cef_v8value_t tracks the amount
    // of external memory associated with it and automatically decreases the
    // global total by the appropriate amount on its destruction.
    // |change_in_bytes| specifies the number of bytes to adjust by. This function
    // returns the number of bytes associated with the object after the
    // adjustment. This function can only be called on user created objects.
    adjust_externally_allocated_memory: function(self: PCefv8Value; change_in_bytes: Integer): Integer; stdcall;

    // ARRAY METHODS - These functions are only available on arrays.

    // Returns the number of elements in the array.
    get_array_length: function(self: PCefv8Value): Integer; stdcall;


    // FUNCTION METHODS - These functions are only available on functions.

    // Returns the function name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_function_name: function(self: PCefv8Value): PCefStringUserFree; stdcall;

    // Returns the function handler or NULL if not a CEF-created function.
    get_function_handler: function(
        self: PCefv8Value): PCefv8Handler; stdcall;

    // Execute the function using the current V8 context. This function should
    // only be called from within the scope of a cef_v8handler_t or
    // cef_v8accessor_t callback, or in combination with calling enter() and
    // exit() on a stored cef_v8context_t reference. |object| is the receiver
    // ('this' object) of the function. If |object| is NULL the current context's
    // global object will be used. |arguments| is the list of arguments that will
    // be passed to the function. Returns the function return value on success.
    // Returns NULL if this function is called incorrectly or an exception is
    // thrown.
    execute_function: function(self: PCefv8Value; obj: PCefv8Value;
      argumentsCount: NativeUInt; const arguments: PPCefV8Value): PCefv8Value; stdcall;

    // Execute the function using the specified V8 context. |object| is the
    // receiver ('this' object) of the function. If |object| is NULL the specified
    // context's global object will be used. |arguments| is the list of arguments
    // that will be passed to the function. Returns the function return value on
    // success. Returns NULL if this function is called incorrectly or an
    // exception is thrown.
    execute_function_with_context: function(self: PCefv8Value; context: PCefv8Context;
      obj: PCefv8Value; argumentsCount: NativeUInt; const arguments: PPCefV8Value): PCefv8Value; stdcall;
  end;

  // Structure representing a V8 stack trace handle. V8 handles can only be
  // accessed from the thread on which they are created. Valid threads for
  // creating a V8 handle include the render process main thread (TID_RENDERER)
  // and WebWorker threads. A task runner for posting tasks on the associated
  // thread can be retrieved via the cef_v8context_t::get_task_runner() function.
  TCefV8StackTrace = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if the underlying handle is valid and it can be accessed
    // on the current thread. Do not call any other functions if this function
    // returns false (0).
    is_valid: function(self: PCefV8StackTrace): Integer; stdcall;

    // Returns the number of stack frames.
    get_frame_count: function(self: PCefV8StackTrace): Integer; stdcall;

    // Returns the stack frame at the specified 0-based index.
    get_frame: function(self: PCefV8StackTrace; index: Integer): PCefV8StackFrame; stdcall;
  end;

  // Structure representing a V8 stack frame handle. V8 handles can only be
  // accessed from the thread on which they are created. Valid threads for
  // creating a V8 handle include the render process main thread (TID_RENDERER)
  // and WebWorker threads. A task runner for posting tasks on the associated
  // thread can be retrieved via the cef_v8context_t::get_task_runner() function.

  TCefV8StackFrame = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if the underlying handle is valid and it can be accessed
    // on the current thread. Do not call any other functions if this function
    // returns false (0).
    is_valid: function(self: PCefV8StackFrame): Integer; stdcall;

    // Returns the name of the resource script that contains the function.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_script_name: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // Returns the name of the resource script that contains the function or the
    // sourceURL value if the script name is undefined and its source ends with a
    // "//@ sourceURL=..." string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_script_name_or_source_url: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // Returns the name of the function.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_function_name: function(self: PCefV8StackFrame): PCefStringUserFree; stdcall;

    // Returns the 1-based line number for the function call or 0 if unknown.
    get_line_number: function(self: PCefV8StackFrame): Integer; stdcall;

    // Returns the 1-based column offset on the line for the function call or 0 if
    // unknown.
    get_column: function(self: PCefV8StackFrame): Integer; stdcall;

    // Returns true (1) if the function was compiled using eval().
    is_eval: function(self: PCefV8StackFrame): Integer; stdcall;

    // Returns true (1) if the function was called as a constructor via "new".
    is_constructor: function(self: PCefV8StackFrame): Integer; stdcall;
  end;

  // Structure that manages custom scheme registrations.
  TCefSchemeRegistrar = record
    // Base structure.
    base: TCefBase;

    // Register a custom scheme. This function should not be called for the built-
    // in HTTP, HTTPS, FILE, FTP, ABOUT and DATA schemes.
    //
    // If |is_standard| is true (1) the scheme will be treated as a standard
    // scheme. Standard schemes are subject to URL canonicalization and parsing
    // rules as defined in the Common Internet Scheme Syntax RFC 1738 Section 3.1
    // available at http://www.ietf.org/rfc/rfc1738.txt
    //
    // In particular, the syntax for standard scheme URLs must be of the form:
    // <pre>
    //  [scheme]://[username]:[password]@[host]:[port]/[url-path]
    // </pre> Standard scheme URLs must have a host component that is a fully
    // qualified domain name as defined in Section 3.5 of RFC 1034 [13] and
    // Section 2.1 of RFC 1123. These URLs will be canonicalized to
    // "scheme://host/path" in the simplest case and
    // "scheme://username:password@host:port/path" in the most explicit case. For
    // example, "scheme:host/path" and "scheme:///host/path" will both be
    // canonicalized to "scheme://host/path". The origin of a standard scheme URL
    // is the combination of scheme, host and port (i.e., "scheme://host:port" in
    // the most explicit case).
    //
    // For non-standard scheme URLs only the "scheme:" component is parsed and
    // canonicalized. The remainder of the URL will be passed to the handler as-
    // is. For example, "scheme:///some%20text" will remain the same. Non-standard
    // scheme URLs cannot be used as a target for form submission.
    //
    // If |is_local| is true (1) the scheme will be treated as local (i.e., with
    // the same security rules as those applied to "file" URLs). Normal pages
    // cannot link to or access local URLs. Also, by default, local URLs can only
    // perform XMLHttpRequest calls to the same URL (origin + path) that
    // originated the request. To allow XMLHttpRequest calls from a local URL to
    // other URLs with the same origin set the
    // CefSettings.file_access_from_file_urls_allowed value to true (1). To allow
    // XMLHttpRequest calls from a local URL to all origins set the
    // CefSettings.universal_access_from_file_urls_allowed value to true (1).
    //
    // If |is_display_isolated| is true (1) the scheme will be treated as display-
    // isolated. This means that pages cannot display these URLs unless they are
    // from the same scheme. For example, pages in another origin cannot create
    // iframes or hyperlinks to URLs with this scheme.
    //
    // This function may be called on any thread. It should only be called once
    // per unique |scheme_name| value. If |scheme_name| is already registered or
    // if an error occurs this function will return false (0).
    add_custom_scheme: function(self: PCefSchemeRegistrar;
      const scheme_name: PCefString; is_standard, is_local,
      is_display_isolated: Integer): Integer; stdcall;
  end;

  // Structure that creates cef_scheme_handler_t instances. The functions of this
  // structure will always be called on the IO thread.
  TCefSchemeHandlerFactory = record
    // Base structure.
    base: TCefBase;

    // Return a new resource handler instance to handle the request or an NULL
    // reference to allow default handling of the request. |browser| and |frame|
    // will be the browser window and frame respectively that originated the
    // request or NULL if the request did not originate from a browser window (for
    // example, if the request came from cef_urlrequest_t). The |request| object
    // passed to this function will not contain cookie data.
    create: function(self: PCefSchemeHandlerFactory;
        browser: PCefBrowser; frame: PCefFrame; const scheme_name: PCefString;
        request: PCefRequest): PCefResourceHandler; stdcall;
  end;

  // Structure used to represent a download item.
  TCefDownloadItem = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. Do not call any other functions
    // if this function returns false (0).
    is_valid: function(self: PCefDownloadItem): Integer; stdcall;

    // Returns true (1) if the download is in progress.
    is_in_progress: function(self: PCefDownloadItem): Integer; stdcall;

    // Returns true (1) if the download is complete.
    is_complete: function(self: PCefDownloadItem): Integer; stdcall;

    // Returns true (1) if the download has been canceled or interrupted.
    is_canceled: function(self: PCefDownloadItem): Integer; stdcall;

    // Returns a simple speed estimate in bytes/s.
    get_current_speed: function(self: PCefDownloadItem): Int64; stdcall;

    // Returns the rough percent complete or -1 if the receive total size is
    // unknown.
    get_percent_complete: function(self: PCefDownloadItem): Integer; stdcall;

    // Returns the total number of bytes.
    get_total_bytes: function(self: PCefDownloadItem): Int64; stdcall;

    // Returns the number of received bytes.
    get_received_bytes: function(self: PCefDownloadItem): Int64; stdcall;

    // Returns the time that the download started.
    get_start_time: function(self: PCefDownloadItem): TCefTime; stdcall;

    // Returns the time that the download ended.
    get_end_time: function(self: PCefDownloadItem): TCefTime; stdcall;

    // Returns the full path to the downloaded or downloading file.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_full_path: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the unique identifier for this download.
    get_id: function(self: PCefDownloadItem): Cardinal; stdcall;

    // Returns the URL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_url: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the original URL before any redirections.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_original_url: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the suggested file name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_suggested_file_name: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the content disposition.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_content_disposition: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;

    // Returns the mime type.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_mime_type: function(self: PCefDownloadItem): PCefStringUserFree; stdcall;
  end;

  // Callback structure used to asynchronously continue a download.
  TCefBeforeDownloadCallback = record
    // Base structure.
    base: TCefBase;

    // Call to continue the download. Set |download_path| to the full file path
    // for the download including the file name or leave blank to use the
    // suggested name and the default temp directory. Set |show_dialog| to true
    // (1) if you do wish to show the default "Save As" dialog.
    cont: procedure(self: PCefBeforeDownloadCallback;
      const download_path: PCefString; show_dialog: Integer); stdcall;
  end;

  // Callback structure used to asynchronously cancel a download.
  TCefDownloadItemCallback = record
  // Base structure.
    base: TCefBase;

    // Call to cancel the download.
    cancel: procedure(self: PCefDownloadItemCallback); stdcall;
    // Call to pause the download.
    pause: procedure(self: PCefDownloadItemCallback); stdcall;
    // Call to resume the download.
    resume: procedure(self: PCefDownloadItemCallback); stdcall;
  end;

  // Structure used to handle file downloads. The functions of this structure will
  // always be called on the UI thread.
  TCefDownloadHandler = record
    // Base structure.
    base: TCefBase;

    // Called before a download begins. |suggested_name| is the suggested name for
    // the download file. By default the download will be canceled. Execute
    // |callback| either asynchronously or in this function to continue the
    // download if desired. Do not keep a reference to |download_item| outside of
    // this function.
    on_before_download: procedure(self: PCefDownloadHandler;
      browser: PCefBrowser; download_item: PCefDownloadItem;
      const suggested_name: PCefString; callback: PCefBeforeDownloadCallback); stdcall;

    // Called when a download's status or progress information has been updated.
    // This may be called multiple times before and after on_before_download().
    // Execute |callback| either asynchronously or in this function to cancel the
    // download if desired. Do not keep a reference to |download_item| outside of
    // this function.
    on_download_updated: procedure(self: PCefDownloadHandler;
        browser: PCefBrowser; download_item: PCefDownloadItem;
        callback: PCefDownloadItemCallback); stdcall;
  end;

  // Structure that supports the reading of XML data via the libxml streaming API.
  // The functions of this structure should only be called on the thread that
  // creates the object.
  TCefXmlReader = record
    // Base structure.
    base: TcefBase;

    // Moves the cursor to the next node in the document. This function must be
    // called at least once to set the current cursor position. Returns true (1)
    // if the cursor position was set successfully.
    move_to_next_node: function(self: PCefXmlReader): Integer; stdcall;

    // Close the document. This should be called directly to ensure that cleanup
    // occurs on the correct thread.
    close: function(self: PCefXmlReader): Integer; stdcall;

    // Returns true (1) if an error has been reported by the XML parser.
    has_error: function(self: PCefXmlReader): Integer; stdcall;

    // Returns the error string.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_error: function(self: PCefXmlReader): PCefStringUserFree; stdcall;


    // The below functions retrieve data for the node at the current cursor
    // position.

    // Returns the node type.
    get_type: function(self: PCefXmlReader): TCefXmlNodeType; stdcall;

    // Returns the node depth. Depth starts at 0 for the root node.
    get_depth: function(self: PCefXmlReader): Integer; stdcall;

    // Returns the local name. See http://www.w3.org/TR/REC-xml-names/#NT-
    // LocalPart for additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_local_name: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the namespace prefix. See http://www.w3.org/TR/REC-xml-names/ for
    // additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_prefix: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the qualified name, equal to (Prefix:)LocalName. See
    // http://www.w3.org/TR/REC-xml-names/#ns-qualnames for additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_qualified_name: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the URI defining the namespace associated with the node. See
    // http://www.w3.org/TR/REC-xml-names/ for additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_namespace_uri: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the base URI of the node. See http://www.w3.org/TR/xmlbase/ for
    // additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_base_uri: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the xml:lang scope within which the node resides. See
    // http://www.w3.org/TR/REC-xml/#sec-lang-tag for additional details.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_xml_lang: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns true (1) if the node represents an NULL element. <a/> is considered
    // NULL but <a></a> is not.
    is_empty_element: function(self: PCefXmlReader): Integer; stdcall;

    // Returns true (1) if the node has a text value.
    has_value: function(self: PCefXmlReader): Integer; stdcall;

    // Returns the text value.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_value: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns true (1) if the node has attributes.
    has_attributes: function(self: PCefXmlReader): Integer; stdcall;

    // Returns the number of attributes.
    get_attribute_count: function(self: PCefXmlReader): NativeUInt; stdcall;

    // Returns the value of the attribute at the specified 0-based index.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_byindex: function(self: PCefXmlReader; index: Integer): PCefStringUserFree; stdcall;

    // Returns the value of the attribute with the specified qualified name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_byqname: function(self: PCefXmlReader; const qualifiedName: PCefString): PCefStringUserFree; stdcall;

    // Returns the value of the attribute with the specified local name and
    // namespace URI.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_bylname: function(self: PCefXmlReader; const localName, namespaceURI: PCefString): PCefStringUserFree; stdcall;

    // Returns an XML representation of the current node's children.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_inner_xml: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns an XML representation of the current node including its children.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_outer_xml: function(self: PCefXmlReader): PCefStringUserFree; stdcall;

    // Returns the line number for the current node.
    get_line_number: function(self: PCefXmlReader): Integer; stdcall;


    // Attribute nodes are not traversed by default. The below functions can be
    // used to move the cursor to an attribute node. move_to_carrying_element()
    // can be called afterwards to return the cursor to the carrying element. The
    // depth of an attribute node will be 1 + the depth of the carrying element.

    // Moves the cursor to the attribute at the specified 0-based index. Returns
    // true (1) if the cursor position was set successfully.
    move_to_attribute_byindex: function(self: PCefXmlReader; index: Integer): Integer; stdcall;

    // Moves the cursor to the attribute with the specified qualified name.
    // Returns true (1) if the cursor position was set successfully.
    move_to_attribute_byqname: function(self: PCefXmlReader; const qualifiedName: PCefString): Integer; stdcall;

    // Moves the cursor to the attribute with the specified local name and
    // namespace URI. Returns true (1) if the cursor position was set
    // successfully.
    move_to_attribute_bylname: function(self: PCefXmlReader; const localName, namespaceURI: PCefString): Integer; stdcall;

    // Moves the cursor to the first attribute in the current element. Returns
    // true (1) if the cursor position was set successfully.
    move_to_first_attribute: function(self: PCefXmlReader): Integer; stdcall;

    // Moves the cursor to the next attribute in the current element. Returns true
    // (1) if the cursor position was set successfully.
    move_to_next_attribute: function(self: PCefXmlReader): Integer; stdcall;

    // Moves the cursor back to the carrying element. Returns true (1) if the
    // cursor position was set successfully.
    move_to_carrying_element: function(self: PCefXmlReader): Integer; stdcall;
  end;

  // Structure that supports the reading of zip archives via the zlib unzip API.
  // The functions of this structure should only be called on the thread that
  // creates the object.
  TCefZipReader = record
    // Base structure.
    base: TCefBase;

    // Moves the cursor to the first file in the archive. Returns true (1) if the
    // cursor position was set successfully.
    move_to_first_file: function(self: PCefZipReader): Integer; stdcall;

    // Moves the cursor to the next file in the archive. Returns true (1) if the
    // cursor position was set successfully.
    move_to_next_file: function(self: PCefZipReader): Integer; stdcall;

    // Moves the cursor to the specified file in the archive. If |caseSensitive|
    // is true (1) then the search will be case sensitive. Returns true (1) if the
    // cursor position was set successfully.
    move_to_file: function(self: PCefZipReader; const fileName: PCefString; caseSensitive: Integer): Integer; stdcall;

    // Closes the archive. This should be called directly to ensure that cleanup
    // occurs on the correct thread.
    close: function(Self: PCefZipReader): Integer; stdcall;


    // The below functions act on the file at the current cursor position.

    // Returns the name of the file.
  // The resulting string must be freed by calling cef_string_userfree_free().
    get_file_name: function(Self: PCefZipReader): PCefStringUserFree; stdcall;

    // Returns the uncompressed size of the file.
    get_file_size: function(Self: PCefZipReader): Int64; stdcall;

    // Returns the last modified timestamp for the file.
    get_file_last_modified: function(Self: PCefZipReader): TCefTime; stdcall;

    // Opens the file for reading of uncompressed data. A read password may
    // optionally be specified.
    open_file: function(Self: PCefZipReader; const password: PCefString): Integer; stdcall;

    // Closes the file.
    close_file: function(Self: PCefZipReader): Integer; stdcall;

    // Read uncompressed file contents into the specified buffer. Returns < 0 if
    // an error occurred, 0 if at the end of file, or the number of bytes read.
    read_file: function(Self: PCefZipReader; buffer: Pointer; bufferSize: NativeUInt): Integer; stdcall;

    // Returns the current offset in the uncompressed file contents.
    tell: function(Self: PCefZipReader): Int64; stdcall;

    // Returns true (1) if at end of the file contents.
    eof: function(Self: PCefZipReader): Integer; stdcall;
  end;

  // Structure to implement for visiting the DOM. The functions of this structure
  // will be called on the render process main thread.
  TCefDomVisitor = record
    // Base structure.
    base: TCefBase;

    // Method executed for visiting the DOM. The document object passed to this
    // function represents a snapshot of the DOM at the time this function is
    // executed. DOM objects are only valid for the scope of this function. Do not
    // keep references to or attempt to access any DOM objects outside the scope
    // of this function.
    visit: procedure(self: PCefDomVisitor; document: PCefDomDocument); stdcall;
  end;


  // Structure used to represent a DOM document. The functions of this structure
  // should only be called on the render process main thread thread.
  TCefDomDocument = record
    // Base structure.
    base: TCefBase;

    // Returns the document type.
    get_type: function(self: PCefDomDocument): TCefDomDocumentType; stdcall;

    // Returns the root document node.
    get_document: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // Returns the BODY node of an HTML document.
    get_body: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // Returns the HEAD node of an HTML document.
    get_head: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // Returns the title of an HTML document.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_title: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // Returns the document element with the specified ID value.
    get_element_by_id: function(self: PCefDomDocument; const id: PCefString): PCefDomNode; stdcall;

    // Returns the node that currently has keyboard focus.
    get_focused_node: function(self: PCefDomDocument): PCefDomNode; stdcall;

    // Returns true (1) if a portion of the document is selected.
    has_selection: function(self: PCefDomDocument): Integer; stdcall;

    // Returns the selection offset within the start node.
    get_selection_start_offset: function(self: PCefDomDocument): Integer; stdcall;

    // Returns the selection offset within the end node.
    get_selection_end_offset: function(self: PCefDomDocument): Integer; stdcall;

    // Returns the contents of this selection as markup.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_as_markup: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // Returns the contents of this selection as text.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_as_text: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // Returns the base URL for the document.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_base_url: function(self: PCefDomDocument): PCefStringUserFree; stdcall;

    // Returns a complete URL based on the document base URL and the specified
    // partial URL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_complete_url: function(self: PCefDomDocument; const partialURL: PCefString): PCefStringUserFree; stdcall;
  end;


  // Structure used to represent a DOM node. The functions of this structure
  // should only be called on the render process main thread.
  TCefDomNode = record
    // Base structure.
    base: TCefBase;

    // Returns the type for this node.
    get_type: function(self: PCefDomNode): TCefDomNodeType; stdcall;

    // Returns true (1) if this is a text node.
    is_text: function(self: PCefDomNode): Integer; stdcall;

    // Returns true (1) if this is an element node.
    is_element: function(self: PCefDomNode): Integer; stdcall;

    // Returns true (1) if this is an editable node.
    is_editable: function(self: PCefDomNode): Integer; stdcall;

    // Returns true (1) if this is a form control element node.
    is_form_control_element: function(self: PCefDomNode): Integer; stdcall;

    // Returns the type of this form control element node.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_form_control_element_type: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // Returns true (1) if this object is pointing to the same handle as |that|
    // object.
    is_same: function(self, that: PCefDomNode): Integer; stdcall;

    // Returns the name of this node.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_name: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // Returns the value of this node.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_value: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // Set the value of this node. Returns true (1) on success.
    set_value: function(self: PCefDomNode; const value: PCefString): Integer; stdcall;

    // Returns the contents of this node as markup.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_as_markup: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // Returns the document associated with this node.
    get_document: function(self: PCefDomNode): PCefDomDocument; stdcall;

    // Returns the parent node.
    get_parent: function(self: PCefDomNode): PCefDomNode; stdcall;

    // Returns the previous sibling node.
    get_previous_sibling: function(self: PCefDomNode): PCefDomNode; stdcall;

    // Returns the next sibling node.
    get_next_sibling: function(self: PCefDomNode): PCefDomNode; stdcall;

    // Returns true (1) if this node has child nodes.
    has_children: function(self: PCefDomNode): Integer; stdcall;

    // Return the first child node.
    get_first_child: function(self: PCefDomNode): PCefDomNode; stdcall;

    // Returns the last child node.
    get_last_child: function(self: PCefDomNode): PCefDomNode; stdcall;

    // The following functions are valid only for element nodes.

    // Returns the tag name of this element.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_element_tag_name: function(self: PCefDomNode): PCefStringUserFree; stdcall;

    // Returns true (1) if this element has attributes.
    has_element_attributes: function(self: PCefDomNode): Integer; stdcall;

    // Returns true (1) if this element has an attribute named |attrName|.
    has_element_attribute: function(self: PCefDomNode; const attrName: PCefString): Integer; stdcall;

    // Returns the element attribute named |attrName|.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_element_attribute: function(self: PCefDomNode; const attrName: PCefString): PCefStringUserFree; stdcall;

    // Returns a map of all element attributes.
    get_element_attributes: procedure(self: PCefDomNode; attrMap: TCefStringMap); stdcall;

    // Set the value for the element attribute named |attrName|. Returns true (1)
    // on success.
    set_element_attribute: function(self: PCefDomNode; const attrName, value: PCefString): Integer; stdcall;

    // Returns the inner text of the element.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_element_inner_text: function(self: PCefDomNode): PCefStringUserFree; stdcall;
  end;

  // Structure to implement for visiting cookie values. The functions of this
  // structure will always be called on the IO thread.
  TCefCookieVisitor = record
    // Base structure.
    base: TCefBase;

    // Method that will be called once for each cookie. |count| is the 0-based
    // index for the current cookie. |total| is the total number of cookies. Set
    // |deleteCookie| to true (1) to delete the cookie currently being visited.
    // Return false (0) to stop visiting cookies. This function may never be
    // called if no cookies are found.

    visit: function(self: PCefCookieVisitor; const cookie: PCefCookie;
      count, total: Integer; deleteCookie: PInteger): Integer; stdcall;
  end;

  // Structure to implement to be notified of asynchronous completion via
  // cef_cookie_manager_t::set_cookie().

  TCefSetCookieCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be called upon completion. |success| will be true (1) if
    // the cookie was set successfully.
    on_complete: procedure(self: PCefSetCookieCallback; success: Integer); stdcall;
  end;

  // Structure to implement to be notified of asynchronous completion via
  // cef_cookie_manager_t::delete_cookies().

  TCefDeleteCookiesCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be called upon completion. |num_deleted| will be the
    // number of cookies that were deleted or -1 if unknown.

    on_complete: procedure(self: PCefDeleteCookiesCallback; num_deleted: Integer); stdcall;
  end;

  // Structure used for managing cookies. The functions of this structure may be
  // called on any thread unless otherwise indicated.
  TCefCookieManager = record
    // Base structure.
    base: TCefBase;

    // Set the schemes supported by this manager. The default schemes ("http",
    // "https", "ws" and "wss") will always be supported. If |callback| is non-
    // NULL it will be executed asnychronously on the IO thread after the change
    // has been applied. Must be called before any cookies are accessed.
    set_supported_schemes: procedure(self: PCefCookieManager;
      schemes: TCefStringList; callback: PCefCompletionCallback); stdcall;

    // Visit all cookies on the IO thread. The returned cookies are ordered by
    // longest path, then by earliest creation date. Returns false (0) if cookies
    // cannot be accessed.
    visit_all_cookies: function(self: PCefCookieManager; visitor: PCefCookieVisitor): Integer; stdcall;

    // Visit a subset of cookies on the IO thread. The results are filtered by the
    // given url scheme, host, domain and path. If |includeHttpOnly| is true (1)
    // HTTP-only cookies will also be included in the results. The returned
    // cookies are ordered by longest path, then by earliest creation date.
    // Returns false (0) if cookies cannot be accessed.
    visit_url_cookies: function(self: PCefCookieManager; const url: PCefString;
      includeHttpOnly: Integer; visitor: PCefCookieVisitor): Integer; stdcall;

    // Sets a cookie given a valid URL and explicit user-provided cookie
    // attributes. This function expects each attribute to be well-formed. It will
    // check for disallowed characters (e.g. the ';' character is disallowed
    // within the cookie value attribute) and fail without setting the cookie if
    // such characters are found. If |callback| is non-NULL it will be executed
    // asnychronously on the IO thread after the cookie has been set. Returns
    // false (0) if an invalid URL is specified or if cookies cannot be accessed.
    set_cookie: function(self: PCefCookieManager; const url: PCefString;
      const cookie: PCefCookie; callback: PCefSetCookieCallback): Integer; stdcall;

    // Delete all cookies that match the specified parameters. If both |url| and
    // |cookie_name| values are specified all host and domain cookies matching
    // both will be deleted. If only |url| is specified all host cookies (but not
    // domain cookies) irrespective of path will be deleted. If |url| is NULL all
    // cookies for all hosts and domains will be deleted. If |callback| is non-
    // NULL it will be executed asnychronously on the IO thread after the cookies
    // have been deleted. Returns false (0) if a non-NULL invalid URL is specified
    // or if cookies cannot be accessed. Cookies can alternately be deleted using
    // the Visit*Cookies() functions.
    delete_cookies: function(self: PCefCookieManager; const url, cookie_name: PCefString;
      callback: PCefDeleteCookiesCallback): Integer; stdcall;

    // Sets the directory path that will be used for storing cookie data. If
    // |path| is NULL data will be stored in memory only. Otherwise, data will be
    // stored at the specified |path|. To persist session cookies (cookies without
    // an expiry date or validity interval) set |persist_session_cookies| to true
    // (1). Session cookies are generally intended to be transient and most Web
    // browsers do not persist them. If |callback| is non-NULL it will be executed
    // asnychronously on the IO thread after the manager's storage has been
    // initialized. Returns false (0) if cookies cannot be accessed.
    set_storage_path: function(self: PCefCookieManager;
      const path: PCefString; persist_session_cookies: Integer;
      callback: PCefCompletionCallback): Integer; stdcall;

    // Flush the backing store (if any) to disk and execute the specified
    // |callback| on the IO thread when done. Returns false (0) if cookies cannot
    // be accessed.
    flush_store: function(self: PCefCookieManager; handler: PCefCompletionCallback): Integer; stdcall;
  end;


  // Information about a specific web plugin.

  TCefWebPluginInfo = record
    // Base structure.
    base: TCefBase;

    // Returns the plugin name (i.e. Flash).
    get_name: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // Returns the plugin file path (DLL/bundle/library).
    get_path: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // Returns the version of the plugin (may be OS-specific).
    get_version: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;

    // Returns a description of the plugin from the version information.
    get_description: function(self: PCefWebPluginInfo): PCefStringUserFree; stdcall;
  end;

  // Structure to implement for visiting web plugin information. The functions of
  // this structure will be called on the browser process UI thread.
  TCefWebPluginInfoVisitor = record
    // Base structure.
    base: TCefBase;

    // Method that will be called once for each plugin. |count| is the 0-based
    // index for the current plugin. |total| is the total number of plugins.
    // Return false (0) to stop visiting plugins. This function may never be
    // called if no plugins are found.
    visit: function(self: PCefWebPluginInfoVisitor;
      info: PCefWebPluginInfo; count, total: Integer): Integer; stdcall;
  end;

  // Structure to implement for receiving unstable plugin information. The
  // functions of this structure will be called on the browser process IO thread.
  TCefWebPluginUnstableCallback = record
    // Base structure.
    base: TCefBase;

    // Method that will be called for the requested plugin. |unstable| will be
    // true (1) if the plugin has reached the crash count threshold of 3 times in
    // 120 seconds.
    is_unstable: procedure(self: PCefWebPluginUnstableCallback;
        const path: PCefString; unstable: Integer); stdcall;
  end;

  // Structure used to make a URL request. URL requests are not associated with a
  // browser instance so no cef_client_t callbacks will be executed. URL requests
  // can be created on any valid CEF thread in either the browser or render
  // process. Once created the functions of the URL request object must be
  // accessed on the same thread that created it.
  TCefUrlRequest = record
    // Base structure.
    base: TCefBase;

    // Returns the request object used to create this URL request. The returned
    // object is read-only and should not be modified.
    get_request: function(self: PCefUrlRequest): PCefRequest; stdcall;

    // Returns the client.
    get_client: function(self: PCefUrlRequest): PCefUrlRequestClient; stdcall;

    // Returns the request status.
    get_request_status: function(self: PCefUrlRequest): TCefUrlRequestStatus; stdcall;

    // Returns the request error if status is UR_CANCELED or UR_FAILED, or 0
    // otherwise.
    get_request_error: function(self: PCefUrlRequest): TCefErrorcode; stdcall;

    // Returns the response, or NULL if no response information is available.
    // Response information will only be available after the upload has completed.
    // The returned object is read-only and should not be modified.
    get_response: function(self: PCefUrlRequest): PCefResponse; stdcall;

    // Cancel the request.
    cancel: procedure(self: PCefUrlRequest); stdcall;
  end;

  // Structure that should be implemented by the cef_urlrequest_t client. The
  // functions of this structure will be called on the same thread that created
  // the request unless otherwise documented.
  TCefUrlrequestClient = record
    // Base structure.
    base: TCefBase;

    // Notifies the client that the request has completed. Use the
    // cef_urlrequest_t::GetRequestStatus function to determine if the request was
    // successful or not.
    on_request_complete: procedure(self: PCefUrlRequestClient; request: PCefUrlRequest); stdcall;

    // Notifies the client of upload progress. |current| denotes the number of
    // bytes sent so far and |total| is the total size of uploading data (or -1 if
    // chunked upload is enabled). This function will only be called if the
    // UR_FLAG_REPORT_UPLOAD_PROGRESS flag is set on the request.
    on_upload_progress: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; current, total: Int64); stdcall;

    // Notifies the client of download progress. |current| denotes the number of
    // bytes received up to the call and |total| is the expected total size of the
    // response (or -1 if not determined).
    on_download_progress: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; current, total: Int64); stdcall;

    // Called when some part of the response is read. |data| contains the current
    // bytes received since the last call. This function will not be called if the
    // UR_FLAG_NO_DOWNLOAD_DATA flag is set on the request.
    on_download_data: procedure(self: PCefUrlRequestClient;
      request: PCefUrlRequest; const data: Pointer; data_length: NativeUInt); stdcall;

    // Called on the IO thread when the browser needs credentials from the user.
    // |isProxy| indicates whether the host is a proxy server. |host| contains the
    // hostname and |port| contains the port number. Return true (1) to continue
    // the request and call cef_auth_callback_t::cont() when the authentication
    // information is available. Return false (0) to cancel the request. This
    // function will only be called for requests initiated from the browser
    // process.
    get_auth_credentials: function(self: PCefUrlRequestClient; isProxy: Integer;
      const host: PCefString; port: Integer; const realm, scheme: PCefString;
      callback: PCefAuthCallback): Integer; stdcall;
  end;

  // Callback structure for asynchronous continuation of file dialog requests.
  TCefFileDialogCallback = record
    // Base structure.
    base: TCefBase;

    // Continue the file selection. |selected_accept_filter| should be the 0-based
    // index of the value selected from the accept filters array passed to
    // cef_dialog_handler_t::OnFileDialog. |file_paths| should be a single value
    // or a list of values depending on the dialog mode. An NULL |file_paths|
    cont: procedure(self: PCefFileDialogCallback; selected_accept_filter: Integer;
     file_paths: TCefStringList); stdcall;

    // Cancel the file selection.
    cancel: procedure(self: PCefFileDialogCallback); stdcall;
  end;

  // Implement this structure to handle dialog events. The functions of this
  // structure will be called on the browser process UI thread.
  TCefDialogHandler = record
    // Base structure.
    base: TCefBase;

    // Called to run a file chooser dialog. |mode| represents the type of dialog
    // to display. |title| to the title to be used for the dialog and may be NULL
    // to show the default title ("Open" or "Save" depending on the mode).
    // |default_file_path| is the path with optional directory and/or file name
    // component that should be initially selected in the dialog. |accept_filters|
    // are used to restrict the selectable file types and may any combination of
    // (a) valid lower-cased MIME types (e.g. "text/*" or "image/*"), (b)
    // individual file extensions (e.g. ".txt" or ".png"), or (c) combined
    // description and file extension delimited using "|" and ";" (e.g. "Image
    // Types|.png;.gif;.jpg"). |selected_accept_filter| is the 0-based index of
    // the filter that should be selected by default. To display a custom dialog
    // return true (1) and execute |callback| either inline or at a later time. To
    // display the default dialog return false (0).
    on_file_dialog: function(self: PCefDialogHandler; browser: PCefBrowser;
      mode: TCefFileDialogMode; const title, default_file_path: PCefString;
      accept_filters: TCefStringList; selected_accept_filter: Integer;
      callback: PCefFileDialogCallback): Integer; stdcall;
  end;

  // Implement this structure to handle events when window rendering is disabled.
  // The functions of this structure will be called on the UI thread.
  TCefRenderHandler = record
    // Base structure.
    base: TCefBase;

    // Called to retrieve the root window rectangle in screen coordinates. Return
    // true (1) if the rectangle was provided.
    get_root_screen_rect: function(self: PCefRenderHandler; browser: PCefBrowser;
      rect: PCefRect): Integer; stdcall;

    // Called to retrieve the view rectangle which is relative to screen
    // coordinates. Return true (1) if the rectangle was provided.
    get_view_rect: function(self: PCefRenderHandler; browser: PCefBrowser;
      rect: PCefRect): Integer; stdcall;

    // Called to retrieve the translation from view coordinates to actual screen
    // coordinates. Return true (1) if the screen coordinates were provided.
    get_screen_point: function(self: PCefRenderHandler; browser: PCefBrowser;
      viewX, viewY: Integer; screenX, screenY: PInteger): Integer; stdcall;

    // Called to allow the client to fill in the CefScreenInfo object with
    // appropriate values. Return true (1) if the |screen_info| structure has been
    // modified.
    //
    // If the screen info rectangle is left NULL the rectangle from GetViewRect
    // will be used. If the rectangle is still NULL or invalid popups may not be
    // drawn correctly.
    get_screen_info: function(self: PCefRenderHandler; browser: PCefBrowser;
        screen_info: PCefScreenInfo): Integer; stdcall;

    // Called when the browser wants to show or hide the popup widget. The popup
    // should be shown if |show| is true (1) and hidden if |show| is false (0).
    on_popup_show: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      show: Integer); stdcall;

    // Called when the browser wants to move or resize the popup widget. |rect|
    // contains the new location and size in view coordinates.
    on_popup_size: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      const rect: PCefRect); stdcall;

    // Called when an element should be painted. Pixel values passed to this
    // function are scaled relative to view coordinates based on the value of
    // CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
    // indicates whether the element is the view or the popup widget. |buffer|
    // contains the pixel data for the whole image. |dirtyRects| contains the set
    // of rectangles in pixel coordinates that need to be repainted. |buffer| will
    // be |width|*|height|*4 bytes in size and represents a BGRA image with an
    // upper-left origin.
    on_paint: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
      const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer); stdcall;

    // Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
    // |custom_cursor_info| will be populated with the custom cursor information.
    on_cursor_change: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      cursor: TCefCursorHandle; type_: TCefCursorType;
      const custom_cursor_info: PCefCursorInfo); stdcall;

    // Called when the user starts dragging content in the web view. Contextual
    // information about the dragged content is supplied by |drag_data|. (|x|,
    // |y|) is the drag start location in screen coordinates. OS APIs that run a
    // system message loop may be used within the StartDragging call.
    //
    // Return false (0) to abort the drag operation. Don't call any of
    // cef_browser_host_t::DragSource*Ended* functions after returning false (0).
    //
    // Return true (1) to handle the drag operation. Call
    // cef_browser_host_t::DragSourceEndedAt and DragSourceSystemDragEnded either
    // synchronously or asynchronously to inform the web view that the drag
    // operation has ended.
    start_dragging: function(self: PCefRenderProcessHandler; browser: PCefBrowser;
      drag_data: PCefDragData; allowed_ops: TCefDragOperations; x, y: Integer): Integer; stdcall;

    // Called when the web view wants to update the mouse cursor during a drag &
    // drop operation. |operation| describes the allowed operation (none, move,
    // copy, link).
    update_drag_cursor: procedure(self: PCefRenderProcessHandler; browser: PCefBrowser;
      operation: TCefDragOperation); stdcall;

    // Called when the scroll offset has changed.
    on_scroll_offset_changed: procedure(self: PCefRenderProcessHandler;
      browser: PCefBrowser; x, y: Double); stdcall;
  end;

  // Implement this structure to receive geolocation updates. The functions of
  // this structure will be called on the browser process UI thread.
  TCefGetGeolocationCallback = record
    // Base structure.
    base: TCefBase;

    // Called with the 'best available' location information or, if the location
    // update failed, with error information.
    on_location_update: procedure(self: PCefGetGeolocationCallback;
        const position: Pcefgeoposition); stdcall;
  end;

  // Implement this structure to receive notification when tracing has completed.
  // The functions of this structure will be called on the browser process UI
  // thread.
  TCefEndTracingCallback = record
    // Base structure.
    base: TCefBase;

    // Called after all processes have sent their trace data. |tracing_file| is
    // the path at which tracing data was written. The client is responsible for
    // deleting |tracing_file|.
    on_end_tracing_complete: procedure(self: PCefEndTracingCallback; const tracing_file: PCefString); stdcall;
  end;

  TCefDragData = record
    // Base structure.
    base: TCefBase;

    // Returns a copy of the current object.
    clone: function(self: PCefDragData): PCefDragData; stdcall;

    // Returns true (1) if this object is read-only.
    is_read_only: function(self: PCefDragData): Integer; stdcall;

    // Returns true (1) if the drag data is a link.
    is_link: function(self: PCefDragData): Integer; stdcall;

    // Returns true (1) if the drag data is a text or html fragment.
    is_fragment: function(self: PCefDragData): Integer; stdcall;

    // Returns true (1) if the drag data is a file.
    is_file: function(self: PCefDragData): Integer; stdcall;

    // Return the link URL that is being dragged.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_link_url: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the title associated with the link being dragged.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_link_title: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the metadata, if any, associated with the link being dragged.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_link_metadata: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the plain text fragment that is being dragged.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_text: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the text/html fragment that is being dragged.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_html: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the base URL that the fragment came from. This value is used for
    // resolving relative URLs and may be NULL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_fragment_base_url: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Return the name of the file being dragged out of the browser window.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_file_name: function(self: PCefDragData): PCefStringUserFree; stdcall;

    // Write the contents of the file being dragged out of the web view into
    // |writer|. Returns the number of bytes sent to |writer|. If |writer| is NULL
    // this function will return the size of the file contents in bytes. Call
    // get_file_name() to get a suggested name for the file.
    get_file_contents: function(self: PCefDragData; writer: PCefStreamWriter): NativeUInt; stdcall;

    // Retrieve the list of file names that are being dragged into the browser
    // window.
    get_file_names: function(self: PCefDragData; names: TCefStringList): Integer; stdcall;

    // Set the link URL that is being dragged.
    set_link_url: procedure(self: PCefDragData; const url: PCefString); stdcall;

    // Set the title associated with the link being dragged.
    set_link_title: procedure(self: PCefDragData; const title: PCefString); stdcall;

    // Set the metadata associated with the link being dragged.
    set_link_metadata: procedure(self: PCefDragData; const data: PCefString); stdcall;

    // Set the plain text fragment that is being dragged.
    set_fragment_text: procedure(self: PCefDragData; const text: PCefString); stdcall;

    // Set the text/html fragment that is being dragged.
    set_fragment_html: procedure(self: PCefDragData; const html: PCefString); stdcall;

    // Set the base URL that the fragment came from.
    set_fragment_base_url: procedure(self: PCefDragData; const base_url: PCefString); stdcall;

    // Reset the file contents. You should do this before calling
    // cef_browser_host_t::DragTargetDragEnter as the web view does not allow us
    // to drag in this kind of data.
    reset_file_contents: procedure(self: PCefDragData); stdcall;

    // Add a file that is being dragged into the webview.
    add_file: procedure(self: PCefDragData; const path, display_name: PCefString); stdcall;
  end;

  // Implement this structure to handle events related to dragging. The functions
  // of this structure will be called on the UI thread.
  TCefDragHandler = record
    // Base structure.
    base: TCefBase;

    // Called when an external drag event enters the browser window. |dragData|
    // contains the drag event data and |mask| represents the type of drag
    // operation. Return false (0) for default drag handling behavior or true (1)
    // to cancel the drag event.
    on_drag_enter: function(self: PCefDragHandler; browser: PCefBrowser;
      dragData: PCefDragData; mask: TCefDragOperations): Integer; stdcall;
{$ifdef Win32}
    // Called whenever draggable regions for the browser window change. These can
    // be specified using the '-webkit-app-region: drag/no-drag' CSS-property. If
    // draggable regions are never defined in a document this function will also
    // never be called. If the last draggable region is removed from a document
    // this function will be called with an NULL vector.
    on_draggable_regions_changed: procedure(self: PCefDragHandler; browser: PCefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray); stdcall;
{$endif}
  end;

  // Implement this structure to provide handler implementations. The handler
  // instance will not be released until all objects related to the context have
  // been destroyed.
  TCefRequestContextHandler = record
    // Base structure.
    base: TCefBase;

    // Called on the browser process IO thread to retrieve the cookie manager. If
    // this function returns NULL the default cookie manager retrievable via
    // cef_request_tContext::get_default_cookie_manager() will be used.
    get_cookie_manager: function(self: PCefRequestContextHandler): PCefCookieManager; stdcall;

    // Called on multiple browser process threads before a plugin instance is
    // loaded. |mime_type| is the mime type of the plugin that will be loaded.
    // |plugin_url| is the content URL that the plugin will load and may be NULL.
    // |top_origin_url| is the URL for the top-level frame that contains the
    // plugin when loading a specific plugin instance or NULL when building the
    // initial list of enabled plugins for 'navigator.plugins' JavaScript state.
    // |plugin_info| includes additional information about the plugin that will be
    // loaded. |plugin_policy| is the recommended policy. Modify |plugin_policy|
    // and return true (1) to change the policy. Return false (0) to use the
    // recommended policy. The default plugin policy can be set at runtime using
    // the `--plugin-policy=[allow|detect|block]` command-line flag. Decisions to
    // mark a plugin as disabled by setting |plugin_policy| to
    // PLUGIN_POLICY_DISABLED may be cached when |top_origin_url| is NULL. To
    // purge the plugin list cache and potentially trigger new calls to this
    // function call cef_request_tContext::PurgePluginListCache.
    on_before_plugin_load: function(self: PCefRequestContextHandler;
        const mime_type, plugin_url, top_origin_url: PCefString;
        plugin_info: PCefWebPluginInfo; plugin_policy: PCefPluginPolicy): Integer; stdcall;
  end;

  // A request context provides request handling for a set of related browser or
  // URL request objects. A request context can be specified when creating a new
  // browser via the cef_browser_host_t static factory functions or when creating
  // a new URL request via the cef_urlrequest_t static factory functions. Browser
  // objects with different request contexts will never be hosted in the same
  // render process. Browser objects with the same request context may or may not
  // be hosted in the same render process depending on the process model. Browser
  // objects created indirectly via the JavaScript window.open function or
  // targeted links will share the same render process and the same request
  // context as the source browser. When running in single-process mode there is
  // only a single render process (the main process) and so all browsers created
  // in single-process mode will share the same request context. This will be the
  // first request context passed into a cef_browser_host_t static factory
  // function and all other request context objects will be ignored.

  TCefRequestContext = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is pointing to the same context as |that|
    // object.
    is_same: function(self, other: PCefRequestContext): Integer; stdcall;

    // Returns true (1) if this object is sharing the same storage as |that|
    // object.
    is_sharing_with: function(self, other: PCefRequestContext): Integer; stdcall;

    // Returns true (1) if this object is the global context. The global context
    // is used by default when creating a browser or URL request with a NULL
    // context argument.
    is_global: function(self: PCefRequestContext): Integer; stdcall;

    // Returns the handler for this context if any.
    get_handler: function(self: PCefRequestContext): PCefRequestContextHandler; stdcall;

    // Returns the cache path for this object. If NULL an "incognito mode" in-
    // memory cache is being used.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_cache_path: function(self: PCefRequestContext): PCefStringUserFree; stdcall;

    // Returns the default cookie manager for this object. This will be the global
    // cookie manager if this object is the global request context. Otherwise,
    // this will be the default cookie manager used when this request context does
    // not receive a value via cef_request_tContextHandler::get_cookie_manager().
    // If |callback| is non-NULL it will be executed asnychronously on the IO
    // thread after the manager's storage has been initialized.
    get_default_cookie_manager: function(self: PCefRequestContext;
      callback: PCefCompletionCallback): PCefCookieManager; stdcall;

    // Register a scheme handler factory for the specified |scheme_name| and
    // optional |domain_name|. An NULL |domain_name| value for a standard scheme
    // will cause the factory to match all domain names. The |domain_name| value
    // will be ignored for non-standard schemes. If |scheme_name| is a built-in
    // scheme and no handler is returned by |factory| then the built-in scheme
    // handler factory will be called. If |scheme_name| is a custom scheme then
    // you must also implement the cef_app_t::on_register_custom_schemes()
    // function in all processes. This function may be called multiple times to
    // change or remove the factory that matches the specified |scheme_name| and
    // optional |domain_name|. Returns false (0) if an error occurs. This function
    // may be called on any thread in the browser process.
    register_scheme_handler_factory: function(self: PCefRequestContext;
        const scheme_name, domain_name: PCefString;
        factory: PCefSchemeHandlerFactory): Integer; stdcall;

    // Clear all registered scheme handler factories. Returns false (0) on error.
    // This function may be called on any thread in the browser process.
    clear_scheme_handler_factories: function(self: PCefRequestContext): Integer; stdcall;

    // Tells all renderer processes associated with this context to throw away
    // their plugin list cache. If |reload_pages| is true (1) they will also
    // reload all pages with plugins.
    // cef_request_tContextHandler::OnBeforePluginLoad may be called to rebuild
    // the plugin list cache.
    purge_plugin_list_cache: procedure(self: PCefRequestContext; reload_pages: Integer); stdcall;
  end;

  // Structure representing print settings.
  TCefPrintSettings = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. Do not call any other functions
    // if this function returns false (0).
    is_valid: function(self: PCefPrintSettings): Integer; stdcall;

    // Returns true (1) if the values of this object are read-only. Some APIs may
    // expose read-only objects.
    is_read_only: function(self: PCefPrintSettings): Integer; stdcall;


    // Returns a writable copy of this object.
    copy: function(self: PCefPrintSettings): PCefPrintSettings; stdcall;

    // Set the page orientation.
    set_orientation: procedure(self: PCefPrintSettings; landscape: Integer); stdcall;

    // Returns true (1) if the orientation is landscape.
    is_landscape: function(self: PCefPrintSettings): Integer; stdcall;

    // Set the printer printable area in device units. Some platforms already
    // provide flipped area. Set |landscape_needs_flip| to false (0) on those
    // platforms to avoid double flipping.
    set_printer_printable_area: procedure(self: PCefPrintSettings;
        const physical_size_device_units: PCefSize;
        const printable_area_device_units: PCefRect;
        landscape_needs_flip: Integer); stdcall;

    // Set the device name.
    set_device_name: procedure(self: PCefPrintSettings; const name: PCefString); stdcall;

    // Get the device name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_device_name: function(self: PCefPrintSettings): PCefStringUserFree; stdcall;

    // Set the DPI (dots per inch).
    set_dpi: procedure(self: PCefPrintSettings; dpi: Integer); stdcall;

    // Get the DPI (dots per inch).
    get_dpi: function(self: PCefPrintSettings): Integer; stdcall;

    // Set the page ranges.
    set_page_ranges: procedure(self: PCefPrintSettings;
        rangesCount: NativeUInt; ranges: PCefPageRange); stdcall;

    // Returns the number of page ranges that currently exist.
    get_page_ranges_count: function(self: PCefPrintSettings): NativeUInt; stdcall;

    // Retrieve the page ranges.
    get_page_ranges: procedure(self: PCefPrintSettings;
        rangesCount: PNativeUInt; ranges: PCefPageRange); stdcall;

    // Set whether only the selection will be printed.
    set_selection_only:procedure(self: PCefPrintSettings;
        selection_only: Integer); stdcall;

    // Returns true (1) if only the selection will be printed.
    is_selection_only: function(self: PCefPrintSettings): Integer; stdcall;

    // Set whether pages will be collated.
    set_collate: procedure(self: PCefPrintSettings; collate: Integer); stdcall;

    // Returns true (1) if pages will be collated.
    will_collate: function(self: PCefPrintSettings): Integer; stdcall;

    // Set the color model.
    set_color_model: procedure(self: PCefPrintSettings; model: TCefColorModel); stdcall;

    // Get the color model.
    get_color_model: function(self: PCefPrintSettings): TCefColorModel; stdcall;

    // Set the number of copies.
    set_copies: procedure(self: PCefPrintSettings; copies: Integer); stdcall;

    // Get the number of copies.
    get_copies: function(self: PCefPrintSettings): Integer; stdcall;

    // Set the duplex mode.
    set_duplex_mode: procedure(self: PCefPrintSettings; mode: TCefDuplexMode); stdcall;

    // Get the duplex mode.
    get_duplex_mode: function(self: PCefPrintSettings): TCefDuplexMode; stdcall;
  end;

  // Callback structure for asynchronous continuation of print dialog requests.
  TCefPrintDialogCallback = record
    // Base structure.
    base: TCefBase;

    // Continue printing with the specified |settings|.
    cont: procedure(self: PCefPrintDialogCallback; settings: PCefPrintSettings); stdcall;

    // Cancel the printing.
    cancel: procedure(self: PCefPrintDialogCallback); stdcall;
  end;

  // Callback structure for asynchronous continuation of print job requests.
  TCefPrintJobCallback = record
    // Base structure.
    base: TCefBase;

    // Indicate completion of the print job.
    cont: procedure(self: PCefPrintJobCallback); stdcall;
  end;


  // Implement this structure to handle printing on Linux. The functions of this
  // structure will be called on the browser process UI thread.
  TCefPrintHandler = record
    // Base structure.
    base: TCefBase;

    // Called when printing has started for the specified |browser|. This function
    // will be called before the other OnPrint*() functions and irrespective of
    // how printing was initiated (e.g. cef_browser_host_t::print(), JavaScript
    // window.print() or PDF extension print button).
    on_print_start: procedure(self: PCefPrintHandler; browser: PCefBrowser); stdcall;

    // Synchronize |settings| with client state. If |get_defaults| is true (1)
    // then populate |settings| with the default print settings. Do not keep a
    // reference to |settings| outside of this callback.
    on_print_settings: procedure(self: PCefPrintHandler;
        settings: PCefPrintSettings; get_defaults: Integer); stdcall;

    // Show the print dialog. Execute |callback| once the dialog is dismissed.
    // Return true (1) if the dialog will be displayed or false (0) to cancel the
    // printing immediately.
    on_print_dialog: function(self: PCefPrintHandler; has_selection: Integer;
      callback: PCefPrintDialogCallback): Integer; stdcall;

    // Send the print job to the printer. Execute |callback| once the job is
    // completed. Return true (1) if the job will proceed or false (0) to cancel
    // the job immediately.
    on_print_job: function(self: PCefPrintHandler; const document_name, pdf_file_path: PCefString;
        callback: PCefPrintJobCallback): Integer; stdcall;

    // Reset client state related to printing.
    on_print_reset: procedure(self: PCefPrintHandler); stdcall;

    // Return the PDF paper size in device units. Used in combination with
    // cef_browser_host_t::print_to_pdf().
    get_pdf_paper_size: function(self: PCefPrintHandler;
      device_units_per_inch: Integer): TCefSize; stdcall;
  end;

  // Structure used to represent an entry in navigation history.
  TCefNavigationEntry = record
    // Base structure.
    base: TCefBase;

    // Returns true (1) if this object is valid. Do not call any other functions
    // if this function returns false (0).
    is_valid: function(self: PCefNavigationEntry): Integer; stdcall;

    // Returns the actual URL of the page. For some pages this may be data: URL or
    // similar. Use get_display_url() to return a display-friendly version.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // Returns a display-friendly version of the URL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_display_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // Returns the original URL that was entered by the user before any redirects.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_original_url: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // Returns the title set by the page. This value may be NULL.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_title: function(self: PCefNavigationEntry): PCefStringUserFree; stdcall;

    // Returns the transition type which indicates what the user did to move to
    // this page from the previous page.
    get_transition_type: function(self: PCefNavigationEntry): TCefTransitionType; stdcall;

    // Returns true (1) if this navigation includes post data.
    has_post_data: function(self: PCefNavigationEntry): Integer; stdcall;

    // Returns the time for the last known successful navigation completion. A
    // navigation may be completed more than once if the page is reloaded. May be
    // 0 if the navigation has not yet completed.
    get_completion_time: function(self: PCefNavigationEntry): TCefTime; stdcall;

    // Returns the HTTP status code for the last known successful navigation
    // response. May be 0 if the response has not yet been received or if the
    // navigation has not yet completed.
    get_http_status_code: function(self: PCefNavigationEntry): Integer; stdcall;
  end;

  // Structure representing the issuer or subject field of an X.509 certificate.
  TCefSslCertPrincipal = record
    // Base structure.
    base: TCefBase;

    // Returns a name that can be used to represent the issuer.  It tries in this
    // order: CN, O and OU and returns the first non-NULL one found.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_display_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the common name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_common_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the locality name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_locality_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the state or province name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_state_or_province_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Returns the country name.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_country_name: function(self: PCefSslCertPrincipal): PCefStringUserfree; stdcall;

    // Retrieve the list of street addresses.
    get_street_addresses: procedure(self: PCefSslCertPrincipal; addresses: TCefStringList); stdcall;

    // Retrieve the list of organization names.
    get_organization_names: procedure(self: PCefSslCertPrincipal; names: TCefStringList); stdcall;

    // Retrieve the list of organization unit names.
    get_organization_unit_names: procedure(self: PCefSslCertPrincipal; names: TCefStringList); stdcall;

    // Retrieve the list of domain components.
    get_domain_components: procedure(self: PCefSslCertPrincipal; components: TCefStringList); stdcall;
  end;

  // Structure representing SSL information.
  TCefSslInfo = record
    // Base structure.
    base: TCefBase;

    // Returns the subject of the X.509 certificate. For HTTPS server certificates
    // this represents the web server.  The common name of the subject should
    // match the host name of the web server.
    get_subject: function(self: PCefSslInfo): PCefSslCertPrincipal; stdcall;

    // Returns the issuer of the X.509 certificate.
    get_issuer: function(self: PCefSslInfo): PCefSslCertPrincipal; stdcall;

    // Returns the DER encoded serial number for the X.509 certificate. The value
    // possibly includes a leading 00 byte.
    get_serial_number: function(self: PCefSslInfo): PCefBinaryValue; stdcall;

    // Returns the date before which the X.509 certificate is invalid.
    // CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_start: function(self: PCefSslInfo): TCefTime; stdcall;

    // Returns the date after which the X.509 certificate is invalid.
    // CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_expiry: function(self: PCefSslInfo): TCefTime; stdcall;

    // Returns the DER encoded data for the X.509 certificate.
    get_derencoded: function(self: PCefSslInfo): PCefBinaryValue; stdcall;

    // Returns the PEM encoded data for the X.509 certificate.
    get_pemencoded: function(self: PCefSslInfo): PCefBinaryValue; stdcall;
  end;

  // Structure used for retrieving resources from the resource bundle (*.pak)
  // files loaded by CEF during startup or via the cef_resource_bundle_tHandler
  // returned from cef_app_t::GetResourceBundleHandler. See CefSettings for
  // additional options related to resource bundle loading. The functions of this
  // structure may be called on any thread unless otherwise indicated.
  TCefResourceBundle = record
    // Base structure.
    base: TCefBase;

    // Returns the localized string for the specified |string_id| or an NULL
    // string if the value is not found. Include cef_pack_strings.h for a listing
    // of valid string ID values.
    // The resulting string must be freed by calling cef_string_userfree_free().
    get_localized_string: function(self: PCefResourceBundle; string_id: Integer): PCefStringUserFree; stdcall;

    // Retrieves the contents of the specified scale independent |resource_id|. If
    // the value is found then |data| and |data_size| will be populated and this
    // function will return true (1). If the value is not found then this function
    // will return false (0). The returned |data| pointer will remain resident in
    // memory and should not be freed. Include cef_pack_resources.h for a listing
    // of valid resource ID values.
    get_data_resource: function(self: PCefResourceBundle; resource_id: Integer;
      out data: Pointer; out data_size: NativeUInt): Integer; stdcall;

    // Retrieves the contents of the specified |resource_id| nearest the scale
    // factor |scale_factor|. Use a |scale_factor| value of SCALE_FACTOR_NONE for
    // scale independent resources or call GetDataResource instead. If the value
    // is found then |data| and |data_size| will be populated and this function
    // will return true (1). If the value is not found then this function will
    // return false (0). The returned |data| pointer will remain resident in
    // memory and should not be freed. Include cef_pack_resources.h for a listing
    // of valid resource ID values.
     get_data_resource_for_scale: function(self: PCefResourceBundle; resource_id: Integer;
       scale_factor: TCefScaleFactor; out data: Pointer; out data_size: NativeUInt): Integer; stdcall;
  end;

//******************************************************************************
//
//  I N T E R F A C E S
//
//******************************************************************************

  ICefBrowser = interface;
  ICefFrame = interface;
  ICefRequest = interface;
  ICefv8Value = interface;
  ICefDomVisitor = interface;
  ICefDomDocument = interface;
  ICefDomNode = interface;
  ICefv8Context = interface;
  ICefListValue = interface;
  ICefBinaryValue = interface;
  ICefDictionaryValue = interface;
  ICefClient = interface;
  ICefUrlrequestClient = interface;
  ICefBrowserHost = interface;
  ICefTask = interface;
  ICefTaskRunner = interface;
  ICefFileDialogCallback = interface;
  ICefRequestContext = interface;
  ICefDragData = interface;
  ICefNavigationEntry = interface;
  ICefSslInfo = interface;

  ICefBase = interface
    ['{1F9A7B44-DCDC-4477-9180-3ADD44BDEB7B}']
    function Wrap: Pointer;
  end;

  ICefRunFileDialogCallback = interface(ICefBase)
  ['{59FCECC6-E897-45BA-873B-F09586C4BE47}']
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings);
  end;

  TCefRunFileDialogCallbackProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}
    procedure(selectedAcceptFilter: Integer; filePaths: TStrings);

  ICefNavigationEntryVisitor = interface(ICefBase)
  ['{CC4D6BC9-0168-4C2C-98BA-45E9AA9CD619}']
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean;
  end;

  TCefNavigationEntryVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}
    function(const entry: ICefNavigationEntry; current: Boolean; index, total: Integer): Boolean;

  TOnPdfPrintFinishedProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const path: ustring; ok: Boolean);

  ICefPdfPrintCallback = interface(ICefBase)
  ['{F1CC58E9-2C30-4932-91AE-467C8D8EFB8E}']
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean);
  end;

  ICefBrowserHost = interface(ICefBase)
    ['{53AE02FF-EF5D-48C3-A43E-069DA9535424}']
    function GetBrowser: ICefBrowser;
    procedure CloseBrowser(forceClose: Boolean);
    procedure SetFocus(focus: Boolean);
    procedure SetWindowVisibility(visible: Boolean);
    function GetWindowHandle: TCefWindowHandle;
    function GetOpenerWindowHandle: TCefWindowHandle;
    function GetRequestContext: ICefRequestContext;
    function GetZoomLevel: Double;
    procedure SetZoomLevel(zoomLevel: Double);
    procedure RunFileDialog(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
    procedure RunFileDialogProc(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
    procedure StartDownload(const url: ustring);
    procedure Print;
    procedure PrintToPdf(const path: ustring; settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
    procedure PrintToPdfProc(const path: ustring; settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
    procedure Find(identifier: Integer; const searchText: ustring; forward, matchCase, findNext: Boolean);
    procedure StopFinding(clearSelection: Boolean);
    procedure ShowDevTools(const windowInfo: PCefWindowInfo; const client: ICefClient;
      const settings: PCefBrowserSettings; inspectElementAt: PCefPoint);
    procedure CloseDevTools;
    procedure GetNavigationEntries(const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
    procedure GetNavigationEntriesProc(const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
    procedure SetMouseCursorChangeDisabled(disabled: Boolean);
    function IsMouseCursorChangeDisabled: Boolean;
    procedure ReplaceMisspelling(const word: ustring);
    procedure AddWordToDictionary(const word: ustring);
    function IsWindowRenderingDisabled: Boolean;
    procedure WasResized;
    procedure WasHidden(hidden: Boolean);
    procedure NotifyScreenInfoChanged;
    procedure Invalidate(kind: TCefPaintElementType);
    procedure SendKeyEvent(const event: PCefKeyEvent);
    procedure SendMouseClickEvent(const event: PCefMouseEvent;
      kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
    procedure SendMouseMoveEvent(const event: PCefMouseEvent; mouseLeave: Boolean);
    procedure SendMouseWheelEvent(const event: PCefMouseEvent; deltaX, deltaY: Integer);
    procedure SendFocusEvent(setFocus: Boolean);
    procedure SendCaptureLostEvent;
    procedure NotifyMoveOrResizeStarted;
    function GetWindowlessFrameRate(): Integer;
    procedure SetWindowlessFrameRate(frameRate: Integer);
    function GetNsTextInputContext: TCefTextInputContext;
    procedure HandleKeyEventBeforeTextInputClient(keyEvent: TCefEventHandle);
    procedure HandleKeyEventAfterTextInputClient(keyEvent: TCefEventHandle);
    procedure DragTargetDragEnter(const dragData: ICefDragData;
      const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragOver(const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragLeave;
    procedure DragTargetDrop(event: PCefMouseEvent);
    procedure DragSourceEndedAt(x, y: Integer; op: TCefDragOperation);
    procedure DragSourceSystemDragEnded;

    property Browser: ICefBrowser read GetBrowser;
    property WindowHandle: TCefWindowHandle read GetWindowHandle;
    property OpenerWindowHandle: TCefWindowHandle read GetOpenerWindowHandle;
    property ZoomLevel: Double read GetZoomLevel write SetZoomLevel;
    property RequestContext: ICefRequestContext read GetRequestContext;
  end;

  ICefProcessMessage = interface(ICefBase)
    ['{E0B1001A-8777-425A-869B-29D40B8B93B1}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefProcessMessage;
    function GetName: ustring;
    function GetArgumentList: ICefListValue;
    property Name: ustring read GetName;
    property ArgumentList: ICefListValue read GetArgumentList;
  end;

  ICefBrowser = interface(ICefBase)
  ['{BA003C2E-CF15-458F-9D4A-FE3CEFCF3EEF}']
    function GetHost: ICefBrowserHost;
    function CanGoBack: Boolean;
    procedure GoBack;
    function CanGoForward: Boolean;
    procedure GoForward;
    function IsLoading: Boolean;
    procedure Reload;
    procedure ReloadIgnoreCache;
    procedure StopLoad;
    function GetIdentifier: Integer;
    function IsSame(const that: ICefBrowser): Boolean;
    function IsPopup: Boolean;
    function HasDocument: Boolean;
    function GetMainFrame: ICefFrame;
    function GetFocusedFrame: ICefFrame;
    function GetFrameByident(identifier: Int64): ICefFrame;
    function GetFrame(const name: ustring): ICefFrame;
    function GetFrameCount: NativeUInt;
    procedure GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
    procedure GetFrameNames(names: TStrings);
    function SendProcessMessage(targetProcess: TCefProcessId;
      message: ICefProcessMessage): Boolean;
    property MainFrame: ICefFrame read GetMainFrame;
    property FocusedFrame: ICefFrame read GetFocusedFrame;
    property FrameCount: NativeUInt read GetFrameCount;
    property Host: ICefBrowserHost read GetHost;
    property Identifier: Integer read GetIdentifier;
  end;

  ICefPostDataElement = interface(ICefBase)
    ['{3353D1B8-0300-4ADC-8D74-4FF31C77D13C}']
    function IsReadOnly: Boolean;
    procedure SetToEmpty;
    procedure SetToFile(const fileName: ustring);
    procedure SetToBytes(size: NativeUInt; bytes: Pointer);
    function GetType: TCefPostDataElementType;
    function GetFile: ustring;
    function GetBytesCount: NativeUInt;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt;
  end;

  ICefPostData = interface(ICefBase)
    ['{1E677630-9339-4732-BB99-D6FE4DE4AEC0}']
    function IsReadOnly: Boolean;
    function GetCount: NativeUInt;
    function GetElements(Count: NativeUInt): IInterfaceList; // ICefPostDataElement
    function RemoveElement(const element: ICefPostDataElement): Integer;
    function AddElement(const element: ICefPostDataElement): Integer;
    procedure RemoveElements;
  end;

  ICefStringMap = interface
  ['{A33EBC01-B23A-4918-86A4-E24A243B342F}']
    function GetHandle: TCefStringMap;
    function GetSize: Integer;
    function Find(const Key: ustring): ustring;
    function GetKey(Index: Integer): ustring;
    function GetValue(Index: Integer): ustring;
    procedure Append(const Key, Value: ustring);
    procedure Clear;

    property Handle: TCefStringMap read GetHandle;
    property Size: Integer read GetSize;
    property Key[index: Integer]: ustring read GetKey;
    property Value[index: Integer]: ustring read GetValue;
  end;

  ICefStringMultimap = interface
    ['{583ED0C2-A9D6-4034-A7C9-20EC7E47F0C7}']
    function GetHandle: TCefStringMultimap;
    function GetSize: Integer;
    function FindCount(const Key: ustring): Integer;
    function GetEnumerate(const Key: ustring; ValueIndex: Integer): ustring;
    function GetKey(Index: Integer): ustring;
    function GetValue(Index: Integer): ustring;
    procedure Append(const Key, Value: ustring);
    procedure Clear;

    property Handle: TCefStringMap read GetHandle;
    property Size: Integer read GetSize;
    property Key[index: Integer]: ustring read GetKey;
    property Value[index: Integer]: ustring read GetValue;
    property Enumerate[const Key: ustring; ValueIndex: Integer]: ustring read GetEnumerate;
  end;

  ICefRequest = interface(ICefBase)
    ['{FB4718D3-7D13-4979-9F4C-D7F6C0EC592A}']
    function IsReadOnly: Boolean;
    function GetUrl: ustring;
    function GetMethod: ustring;
    function GetPostData: ICefPostData;
    procedure GetHeaderMap(const HeaderMap: ICefStringMultimap);
    procedure SetUrl(const value: ustring);
    procedure SetMethod(const value: ustring);
    procedure SetPostData(const value: ICefPostData);
    procedure SetHeaderMap(const HeaderMap: ICefStringMultimap);
    function GetFlags: TCefUrlRequestFlags;
    procedure SetFlags(flags: TCefUrlRequestFlags);
    function GetFirstPartyForCookies: ustring;
    procedure SetFirstPartyForCookies(const url: ustring);
    procedure Assign(const url, method: ustring;
      const postData: ICefPostData; const headerMap: ICefStringMultimap);
    function GetResourceType: TCefResourceType;
    function GetTransitionType: TCefTransitionType;
    function GetIdentifier: UInt64;

    property Url: ustring read GetUrl write SetUrl;
    property Method: ustring read GetMethod write SetMethod;
    property PostData: ICefPostData read GetPostData write SetPostData;
    property Flags: TCefUrlRequestFlags read GetFlags write SetFlags;
    property FirstPartyForCookies: ustring read GetFirstPartyForCookies write SetFirstPartyForCookies;
    property ResourceType: TCefResourceType read GetResourceType;
    property TransitionType: TCefTransitionType read GetTransitionType;
    property Identifier: UInt64 read GetIdentifier;
  end;

  TCefDomVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const document: ICefDomDocument);

  TCefStringVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const str: ustring);

  ICefStringVisitor = interface(ICefBase)
    ['{63ED4D6C-2FC8-4537-964B-B84C008F6158}']
    procedure Visit(const str: ustring);
  end;

  ICefFrame = interface(ICefBase)
    ['{8FD3D3A6-EA3A-4A72-8501-0276BD5C3D1D}']
    function IsValid: Boolean;
    procedure Undo;
    procedure Redo;
    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Del;
    procedure SelectAll;
    procedure ViewSource;
    procedure GetSource(const visitor: ICefStringVisitor);
    procedure GetSourceProc(const proc: TCefStringVisitorProc);
    procedure GetText(const visitor: ICefStringVisitor);
    procedure GetTextProc(const proc: TCefStringVisitorProc);
    procedure LoadRequest(const request: ICefRequest);
    procedure LoadUrl(const url: ustring);
    procedure LoadString(const str, url: ustring);
    procedure ExecuteJavaScript(const code, scriptUrl: ustring; startLine: Integer);
    function IsMain: Boolean;
    function IsFocused: Boolean;
    function GetName: ustring;
    function GetIdentifier: Int64;
    function GetParent: ICefFrame;
    function GetUrl: ustring;
    function GetBrowser: ICefBrowser;
    function GetV8Context: ICefv8Context;
    procedure VisitDom(const visitor: ICefDomVisitor);
    procedure VisitDomProc(const proc: TCefDomVisitorProc);
    property Name: ustring read GetName;
    property Url: ustring read GetUrl;
    property Browser: ICefBrowser read GetBrowser;
    property Parent: ICefFrame read GetParent;
  end;


  ICefCustomStreamReader = interface(ICefBase)
    ['{BBCFF23A-6FE7-4C28-B13E-6D2ACA5C83B7}']
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  end;

  ICefStreamReader = interface(ICefBase)
    ['{DD5361CB-E558-49C5-A4BD-D1CE84ADB277}']
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  end;

  ICefWriteHandler = interface(ICefBase)
    ['{F2431888-4EAB-421E-9EC3-320BE695AF30}']
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  end;

  ICefStreamWriter = interface(ICefBase)
    ['{4AA6C477-7D8A-4D5A-A704-67F900A827E7}']
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  end;

  ICefResponse = interface(ICefBase)
  ['{E9C896E4-59A8-4B96-AB5E-6EA3A498B7F1}']
    function IsReadOnly: Boolean;
    function GetStatus: Integer;
    procedure SetStatus(status: Integer);
    function GetStatusText: ustring;
    procedure SetStatusText(const StatusText: ustring);
    function GetMimeType: ustring;
    procedure SetMimeType(const mimetype: ustring);
    function GetHeader(const name: ustring): ustring;
    procedure GetHeaderMap(const headerMap: ICefStringMultimap);
    procedure SetHeaderMap(const headerMap: ICefStringMultimap);
    property Status: Integer read GetStatus write SetStatus;
    property StatusText: ustring read GetStatusText write SetStatusText;
    property MimeType: ustring read GetMimeType write SetMimeType;
  end;

  ICefDownloadItem = interface(ICefBase)
  ['{B34BD320-A82E-4185-8E84-B98E5EEC803F}']
    function IsValid: Boolean;
    function IsInProgress: Boolean;
    function IsComplete: Boolean;
    function IsCanceled: Boolean;
    function GetCurrentSpeed: Int64;
    function GetPercentComplete: Integer;
    function GetTotalBytes: Int64;
    function GetReceivedBytes: Int64;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetFullPath: ustring;
    function GetId: Cardinal;
    function GetUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetSuggestedFileName: ustring;
    function GetContentDisposition: ustring;
    function GetMimeType: ustring;

    property CurrentSpeed: Int64 read GetCurrentSpeed;
    property PercentComplete: Integer read GetPercentComplete;
    property TotalBytes: Int64 read GetTotalBytes;
    property ReceivedBytes: Int64 read GetReceivedBytes;
    property StartTime: TDateTime read GetStartTime;
    property EndTime: TDateTime read GetEndTime;
    property FullPath: ustring read GetFullPath;
    property Id: Cardinal read GetId;
    property Url: ustring read GetUrl;
    property OriginalUrl: ustring read GetOriginalUrl;
    property SuggestedFileName: ustring read GetSuggestedFileName;
    property ContentDisposition: ustring read GetContentDisposition;
    property MimeType: ustring read GetMimeType;
  end;

  ICefBeforeDownloadCallback = interface(ICefBase)
  ['{5A81AF75-CBA2-444D-AD8E-522160F36433}']
    procedure Cont(const downloadPath: ustring; showDialog: Boolean);
  end;

  ICefDownloadItemCallback = interface(ICefBase)
  ['{498F103F-BE64-4D5F-86B7-B37EC69E1735}']
    procedure Cancel;
    procedure Pause;
    procedure Resume;
  end;

  ICefDownloadHandler = interface(ICefBase)
  ['{3137F90A-5DC5-43C1-858D-A269F28EF4F1}']
    procedure OnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback);
    procedure OnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback);
  end;

  ICefV8Exception = interface(ICefBase)
    ['{7E422CF0-05AC-4A60-A029-F45105DCE6A4}']
    function GetMessage: ustring;
    function GetSourceLine: ustring;
    function GetScriptResourceName: ustring;
    function GetLineNumber: Integer;
    function GetStartPosition: Integer;
    function GetEndPosition: Integer;
    function GetStartColumn: Integer;
    function GetEndColumn: Integer;

    property Message: ustring read GetMessage;
    property SourceLine: ustring read GetSourceLine;
    property ScriptResourceName: ustring read GetScriptResourceName;
    property LineNumber: Integer read GetLineNumber;
    property StartPosition: Integer read GetStartPosition;
    property EndPosition: Integer read GetEndPosition;
    property StartColumn: Integer read GetStartColumn;
    property EndColumn: Integer read GetEndColumn;
  end;

  ICefv8Context = interface(ICefBase)
    ['{2295A11A-8773-41F2-AD42-308C215062D9}']
    function GetTaskRunner: ICefTaskRunner;
    function IsValid: Boolean;
    function GetBrowser: ICefBrowser;
    function GetFrame: ICefFrame;
    function GetGlobal: ICefv8Value;
    function Enter: Boolean;
    function Exit: Boolean;
    function IsSame(const that: ICefv8Context): Boolean;
    function Eval(const code: ustring; var retval: ICefv8Value; var exception: ICefV8Exception): Boolean;
    property Browser: ICefBrowser read GetBrowser;
    property Frame: ICefFrame read GetFrame;
    property Global: ICefv8Value read GetGlobal;
  end;

  TCefv8ValueArray = array of ICefv8Value;

  ICefv8Handler = interface(ICefBase)
    ['{F94CDC60-FDCB-422D-96D5-D2A775BD5D73}']
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
  end;

  ICefV8Accessor = interface(ICefBase)
    ['{DCA6D4A2-726A-4E24-AA64-5E8C731D868A}']
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean;
    function Put(const name: ustring; const obj: ICefv8Value;
      const value: ICefv8Value; const exception: ustring): Boolean;
  end;

  ICefTask = interface(ICefBase)
    ['{0D965470-4A86-47CE-BD39-A8770021AD7E}']
    procedure Execute;
  end;

  ICefTaskRunner = interface(ICefBase)
  ['{6A500FA3-77B7-4418-8EA8-6337EED1337B}']
    function IsSame(const that: ICefTaskRunner): Boolean;
    function BelongsToCurrentThread: Boolean;
    function BelongsToThread(threadId: TCefThreadId): Boolean;
    function PostTask(const task: ICefTask): Boolean; stdcall;
    function PostDelayedTask(const task: ICefTask; delayMs: Int64): Boolean;
  end;

  ICefv8Value = interface(ICefBase)
  ['{52319B8D-75A8-422C-BD4B-16FA08CC7F42}']
    function IsValid: Boolean;
    function IsUndefined: Boolean;
    function IsNull: Boolean;
    function IsBool: Boolean;
    function IsInt: Boolean;
    function IsUInt: Boolean;
    function IsDouble: Boolean;
    function IsDate: Boolean;
    function IsString: Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsFunction: Boolean;
    function IsSame(const that: ICefv8Value): Boolean;
    function GetBoolValue: Boolean;
    function GetIntValue: Integer;
    function GetUIntValue: Cardinal;
    function GetDoubleValue: Double;
    function GetDateValue: TDateTime;
    function GetStringValue: ustring;
    function IsUserCreated: Boolean;
    function HasException: Boolean;
    function GetException: ICefV8Exception;
    function ClearException: Boolean;
    function WillRethrowExceptions: Boolean;
    function SetRethrowExceptions(rethrow: Boolean): Boolean;
    function HasValueByKey(const key: ustring): Boolean;
    function HasValueByIndex(index: Integer): Boolean;
    function DeleteValueByKey(const key: ustring): Boolean;
    function DeleteValueByIndex(index: Integer): Boolean;
    function GetValueByKey(const key: ustring): ICefv8Value;
    function GetValueByIndex(index: Integer): ICefv8Value;
    function SetValueByKey(const key: ustring; const value: ICefv8Value;
      attribute: TCefV8PropertyAttributes): Boolean;
    function SetValueByIndex(index: Integer; const value: ICefv8Value): Boolean;
    function SetValueByAccessor(const key: ustring; settings: TCefV8AccessControls;
      attribute: TCefV8PropertyAttributes): Boolean;
    function GetKeys(const keys: TStrings): Integer;
    function SetUserData(const data: ICefv8Value): Boolean;
    function GetUserData: ICefv8Value;
    function GetExternallyAllocatedMemory: Integer;
    function AdjustExternallyAllocatedMemory(changeInBytes: Integer): Integer;
    function GetArrayLength: Integer;
    function GetFunctionName: ustring;
    function GetFunctionHandler: ICefv8Handler;
    function ExecuteFunction(const obj: ICefv8Value;
      const arguments: TCefv8ValueArray): ICefv8Value;
    function ExecuteFunctionWithContext(const context: ICefv8Context;
      const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
  end;

  ICefV8StackFrame = interface(ICefBase)
  ['{BA1FFBF4-E9F2-4842-A827-DC220F324286}']
    function IsValid: Boolean;
    function GetScriptName: ustring;
    function GetScriptNameOrSourceUrl: ustring;
    function GetFunctionName: ustring;
    function GetLineNumber: Integer;
    function GetColumn: Integer;
    function IsEval: Boolean;
    function IsConstructor: Boolean;

    property ScriptName: ustring read GetScriptName;
    property ScriptNameOrSourceUrl: ustring read GetScriptNameOrSourceUrl;
    property FunctionName: ustring read GetFunctionName;
    property LineNumber: Integer read GetLineNumber;
    property Column: Integer read GetColumn;
  end;

  ICefV8StackTrace = interface(ICefBase)
  ['{32111C84-B7F7-4E3A-92B9-7CA1D0ADB613}']
    function IsValid: Boolean;
    function GetFrameCount: Integer;
    function GetFrame(index: Integer): ICefV8StackFrame;
    property FrameCount: Integer read GetFrameCount;
    property Frame[index: Integer]: ICefV8StackFrame read GetFrame;
  end;

  ICefXmlReader = interface(ICefBase)
  ['{0DE686C3-A8D7-45D2-82FD-92F7F4E62A90}']
    function MoveToNextNode: Boolean;
    function Close: Boolean;
    function HasError: Boolean;
    function GetError: ustring;
    function GetType: TCefXmlNodeType;
    function GetDepth: Integer;
    function GetLocalName: ustring;
    function GetPrefix: ustring;
    function GetQualifiedName: ustring;
    function GetNamespaceUri: ustring;
    function GetBaseUri: ustring;
    function GetXmlLang: ustring;
    function IsEmptyElement: Boolean;
    function HasValue: Boolean;
    function GetValue: ustring;
    function HasAttributes: Boolean;
    function GetAttributeCount: NativeUInt;
    function GetAttributeByIndex(index: Integer): ustring;
    function GetAttributeByQName(const qualifiedName: ustring): ustring;
    function GetAttributeByLName(const localName, namespaceURI: ustring): ustring;
    function GetInnerXml: ustring;
    function GetOuterXml: ustring;
    function GetLineNumber: Integer;
    function MoveToAttributeByIndex(index: Integer): Boolean;
    function MoveToAttributeByQName(const qualifiedName: ustring): Boolean;
    function MoveToAttributeByLName(const localName, namespaceURI: ustring): Boolean;
    function MoveToFirstAttribute: Boolean;
    function MoveToNextAttribute: Boolean;
    function MoveToCarryingElement: Boolean;
  end;

  ICefZipReader = interface(ICefBase)
  ['{3B6C591F-9877-42B3-8892-AA7B27DA34A8}']
    function MoveToFirstFile: Boolean;
    function MoveToNextFile: Boolean;
    function MoveToFile(const fileName: ustring; caseSensitive: Boolean): Boolean;
    function Close: Boolean;
    function GetFileName: ustring;
    function GetFileSize: Int64;
    function GetFileLastModified: TCefTime;
    function OpenFile(const password: ustring): Boolean;
    function CloseFile: Boolean;
    function ReadFile(buffer: Pointer; bufferSize: NativeUInt): Integer;
    function Tell: Int64;
    function Eof: Boolean;
  end;

  ICefDomNode = interface(ICefBase)
  ['{96C03C9E-9C98-491A-8DAD-1947332232D6}']
    function GetType: TCefDomNodeType;
    function IsText: Boolean;
    function IsElement: Boolean;
    function IsEditable: Boolean;
    function IsFormControlElement: Boolean;
    function GetFormControlElementType: ustring;
    function IsSame(const that: ICefDomNode): Boolean;
    function GetName: ustring;
    function GetValue: ustring;
    function SetValue(const value: ustring): Boolean;
    function GetAsMarkup: ustring;
    function GetDocument: ICefDomDocument;
    function GetParent: ICefDomNode;
    function GetPreviousSibling: ICefDomNode;
    function GetNextSibling: ICefDomNode;
    function HasChildren: Boolean;
    function GetFirstChild: ICefDomNode;
    function GetLastChild: ICefDomNode;
    function GetElementTagName: ustring;
    function HasElementAttributes: Boolean;
    function HasElementAttribute(const attrName: ustring): Boolean;
    function GetElementAttribute(const attrName: ustring): ustring;
    procedure GetElementAttributes(const attrMap: ICefStringMap);
    function SetElementAttribute(const attrName, value: ustring): Boolean;
    function GetElementInnerText: ustring;

    property NodeType: TCefDomNodeType read GetType;
    property Name: ustring read GetName;
    property AsMarkup: ustring read GetAsMarkup;
    property Document: ICefDomDocument read GetDocument;
    property Parent: ICefDomNode read GetParent;
    property PreviousSibling: ICefDomNode read GetPreviousSibling;
    property NextSibling: ICefDomNode read GetNextSibling;
    property FirstChild: ICefDomNode read GetFirstChild;
    property LastChild: ICefDomNode read GetLastChild;
    property ElementTagName: ustring read GetElementTagName;
    property ElementInnerText: ustring read GetElementInnerText;
  end;

  ICefDomDocument = interface(ICefBase)
  ['{08E74052-45AF-4F69-A578-98A5C3959426}']
    function GetType: TCefDomDocumentType;
    function GetDocument: ICefDomNode;
    function GetBody: ICefDomNode;
    function GetHead: ICefDomNode;
    function GetTitle: ustring;
    function GetElementById(const id: ustring): ICefDomNode;
    function GetFocusedNode: ICefDomNode;
    function HasSelection: Boolean;
    function GetSelectionStartOffset: Integer;
    function GetSelectionEndOffset: Integer;
    function GetSelectionAsMarkup: ustring;
    function GetSelectionAsText: ustring;
    function GetBaseUrl: ustring;
    function GetCompleteUrl(const partialURL: ustring): ustring;
    property DocType: TCefDomDocumentType read GetType;
    property Document: ICefDomNode read GetDocument;
    property Body: ICefDomNode read GetBody;
    property Head: ICefDomNode read GetHead;
    property Title: ustring read GetTitle;
    property FocusedNode: ICefDomNode read GetFocusedNode;
    property SelectionStartOffset: Integer read GetSelectionStartOffset;
    property SelectionEndOffset: Integer read GetSelectionEndOffset;
    property SelectionAsMarkup: ustring read GetSelectionAsMarkup;
    property SelectionAsText: ustring read GetSelectionAsText;
    property BaseUrl: ustring read GetBaseUrl;
  end;

  ICefDomVisitor = interface(ICefBase)
  ['{30398428-3196-4531-B968-2DDBED36F6B0}']
    procedure visit(const document: ICefDomDocument);
  end;

  ICefCookieVisitor = interface(ICefBase)
  ['{8378CF1B-84AB-4FDB-9B86-34DDABCCC402}']
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean;
  end;

  ICefResourceBundleHandler = interface(ICefBase)
    ['{09C264FD-7E03-41E3-87B3-4234E82B5EA2}']
    function GetLocalizedString(stringId: Integer; out stringVal: ustring): Boolean;
    function GetDataResource(resourceId: Integer; out data: Pointer; out dataSize: NativeUInt): Boolean;
  end;

  ICefCommandLine = interface(ICefBase)
  ['{6B43D21B-0F2C-4B94-B4E6-4AF0D7669D8E}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefCommandLine;
    procedure InitFromArgv(argc: Integer; const argv: PPAnsiChar);
    procedure InitFromString(const commandLine: ustring);
    procedure Reset;
    function GetCommandLineString: ustring;
    procedure GetArgv(args: TStrings);
    function GetProgram: ustring;
    procedure SetProgram(const prog: ustring);
    function HasSwitches: Boolean;
    function HasSwitch(const name: ustring): Boolean;
    function GetSwitchValue(const name: ustring): ustring;
    procedure GetSwitches(switches: TStrings);
    procedure AppendSwitch(const name: ustring);
    procedure AppendSwitchWithValue(const name, value: ustring);
    function HasArguments: Boolean;
    procedure GetArguments(arguments: TStrings);
    procedure AppendArgument(const argument: ustring);
    procedure PrependWrapper(const wrapper: ustring);
    property CommandLineString: ustring read GetCommandLineString;
  end;

  ICefBrowserProcessHandler = interface(ICefBase)
  ['{27291B7A-C0AE-4EE0-9115-15C810E22F6C}']
    procedure OnContextInitialized;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine);
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue);
  end;

  ICefSchemeRegistrar = interface(ICefBase)
  ['{1832FF6E-100B-4E8B-B996-AD633168BEE7}']
    function AddCustomScheme(const schemeName: ustring; IsStandard, IsLocal,
      IsDisplayIsolated: Boolean): Boolean; stdcall;
  end;

  ICefRenderProcessHandler = interface(IcefBase)
  ['{FADEE3BC-BF66-430A-BA5D-1EE3782ECC58}']
    procedure OnRenderThreadCreated(const extraInfo: ICefListValue) ;
    procedure OnWebKitInitialized;
    procedure OnBrowserCreated(const browser: ICefBrowser);
    procedure OnBrowserDestroyed(const browser: ICefBrowser);
    procedure OnContextCreated(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context);
    procedure OnUncaughtException(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context; const exception: ICefV8Exception;
      const stackTrace: ICefV8StackTrace);
    procedure OnFocusedNodeChanged(const browser: ICefBrowser;
      const frame: ICefFrame; const node: ICefDomNode);
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
  end;

  TOnRegisterCustomSchemes = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const registrar: ICefSchemeRegistrar);
  TOnBeforeCommandLineProcessing = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const processType: ustring; const commandLine: ICefCommandLine);

  ICefApp = interface(ICefBase)
    ['{970CA670-9070-4642-B188-7D8A22DAEED4}']
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine);
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar);
    function GetResourceBundleHandler: ICefResourceBundleHandler;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler;
    function GetRenderProcessHandler: ICefRenderProcessHandler;
  end;

  TCefCookieVisitorProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} function(
    const name, value, domain, path: ustring; secure, httponly,
    hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
    count, total: Integer; out deleteCookie: Boolean): Boolean;

  ICefCompletionCallback = interface(ICefBase)
    ['{A8ECCFBB-FEE0-446F-AB32-AD69A7478D57}']
    procedure OnComplete;
  end;

  TCefCompletionCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure;

  ICefSetCookieCallback = interface(ICefBase)
    ['{16E14B6F-CB0A-4F9D-A008-239E0BC7B892}']
    procedure OnComplete(success: Boolean);
  end;

  TCefSetCookieCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure(success: Boolean);

  ICefDeleteCookiesCallback = interface(ICefBase)
    ['{758B79A1-B9E8-4F0D-94A0-DCE5AFADE33D}']
    procedure OnComplete(numDeleted: Integer);
  end;

  TCefDeleteCookiesCallbackProc = {$IFDEF DELPHI12_UP} reference to {$ENDIF} procedure(numDeleted: Integer);

  ICefCookieManager = Interface(ICefBase)
    ['{CC1749E6-9AD3-4283-8430-AF6CBF3E8785}']
    procedure SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
    procedure SetSupportedSchemesProc(schemes: TStrings; const callback: TCefCompletionCallbackProc);
    function VisitAllCookies(const visitor: ICefCookieVisitor): Boolean;
    function VisitAllCookiesProc(const visitor: TCefCookieVisitorProc): Boolean;
    function VisitUrlCookies(const url: ustring;
      includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
    function VisitUrlCookiesProc(const url: ustring;
      includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
    function SetCookie(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: ICefSetCookieCallback): Boolean;
    function SetCookieProc(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: TCefSetCookieCallbackProc): Boolean;
    function DeleteCookies(const url, cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
    function DeleteCookiesProc(const url, cookieName: ustring; const callback: TCefDeleteCookiesCallbackProc): Boolean;
    function SetStoragePath(const path: ustring; persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
    function SetStoragePathProc(const path: ustring; persistSessionCookies: Boolean; const callback: TCefCompletionCallbackProc): Boolean;
    function FlushStore(const handler: ICefCompletionCallback): Boolean;
    function FlushStoreProc(const proc: TCefCompletionCallbackProc): Boolean;
  end;

  ICefWebPluginInfo = interface(ICefBase)
    ['{AA879E58-F649-44B1-AF9C-655FF5B79A02}']
    function GetName: ustring;
    function GetPath: ustring;
    function GetVersion: ustring;
    function GetDescription: ustring;

    property Name: ustring read GetName;
    property Path: ustring read GetPath;
    property Version: ustring read GetVersion;
    property Description: ustring read GetDescription;
  end;

  ICefCallback = interface(ICefBase)
  ['{1B8C449F-E2D6-4B78-9BBA-6F47E8BCDF37}']
    procedure Cont;
    procedure Cancel;
  end;

  ICefResourceHandler = interface(ICefBase)
  ['{BD3EA208-AAAD-488C-BFF2-76993022F2B5}']
    function ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean;
    procedure GetResponseHeaders(const response: ICefResponse;
      out responseLength: Int64; out redirectUrl: ustring);
    function ReadResponse(const dataOut: Pointer; bytesToRead: Integer;
      var bytesRead: Integer; const callback: ICefCallback): Boolean;
    function CanGetCookie(const cookie: PCefCookie): Boolean;
    function CanSetCookie(const cookie: PCefCookie): Boolean;
    procedure Cancel;
  end;

  ICefSchemeHandlerFactory = interface(ICefBase)
    ['{4D9B7960-B73B-4EBD-9ABE-6C1C43C245EB}']
    function New(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest): ICefResourceHandler;
  end;

  ICefAuthCallback = interface(ICefBase)
  ['{500C2023-BF4D-4FF7-9C04-165E5C389131}']
    procedure Cont(const username, password: ustring);
    procedure Cancel;
  end;

  ICefJsDialogCallback = interface(ICefBase)
  ['{187B2156-9947-4108-87AB-32E559E1B026}']
    procedure Cont(success: Boolean; const userInput: ustring);
  end;

  ICefContextMenuParams = interface(ICefBase)
  ['{E31BFA9E-D4E2-49B7-A05D-20018C8794EB}']
    function GetXCoord: Integer;
    function GetYCoord: Integer;
    function GetTypeFlags: TCefContextMenuTypeFlags;
    function GetLinkUrl: ustring;
    function GetUnfilteredLinkUrl: ustring;
    function GetSourceUrl: ustring;
    function HasImageContents: Boolean;
    function GetPageUrl: ustring;
    function GetFrameUrl: ustring;
    function GetFrameCharset: ustring;
    function GetMediaType: TCefContextMenuMediaType;
    function GetMediaStateFlags: TCefContextMenuMediaStateFlags;
    function GetSelectionText: ustring;
    function GetMisspelledWord: ustring;
    function GetDictionarySuggestions(const suggestions: TStringList): Boolean;
    function IsEditable: Boolean;
    function IsSpellCheckEnabled: Boolean;
    function GetEditStateFlags: TCefContextMenuEditStateFlags;
    function IsCustomMenu: Boolean;
    function IsPepperMenu: Boolean;

    property XCoord: Integer read GetXCoord;
    property YCoord: Integer read GetYCoord;
    property TypeFlags: TCefContextMenuTypeFlags read GetTypeFlags;
    property LinkUrl: ustring read GetLinkUrl;
    property UnfilteredLinkUrl: ustring read GetUnfilteredLinkUrl;
    property SourceUrl: ustring read GetSourceUrl;
    property PageUrl: ustring read GetPageUrl;
    property FrameUrl: ustring read GetFrameUrl;
    property FrameCharset: ustring read GetFrameCharset;
    property MediaType: TCefContextMenuMediaType read GetMediaType;
    property MediaStateFlags: TCefContextMenuMediaStateFlags read GetMediaStateFlags;
    property SelectionText: ustring read GetSelectionText;
    property EditStateFlags: TCefContextMenuEditStateFlags read GetEditStateFlags;
  end;

  ICefMenuModel = interface(ICefBase)
  ['{40AF19D3-8B4E-44B8-8F89-DEB5907FC495}']
    function Clear: Boolean;
    function GetCount: Integer;
    function AddSeparator: Boolean;
    function AddItem(commandId: Integer; const text: ustring): Boolean;
    function AddCheckItem(commandId: Integer; const text: ustring): Boolean;
    function AddRadioItem(commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function AddSubMenu(commandId: Integer; const text: ustring): ICefMenuModel;
    function InsertSeparatorAt(index: Integer): Boolean;
    function InsertItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertCheckItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertRadioItemAt(index, commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function InsertSubMenuAt(index, commandId: Integer; const text: ustring): ICefMenuModel;
    function Remove(commandId: Integer): Boolean;
    function RemoveAt(index: Integer): Boolean;
    function GetIndexOf(commandId: Integer): Integer;
    function GetCommandIdAt(index: Integer): Integer;
    function SetCommandIdAt(index, commandId: Integer): Boolean;
    function GetLabel(commandId: Integer): ustring;
    function GetLabelAt(index: Integer): ustring;
    function SetLabel(commandId: Integer; const text: ustring): Boolean;
    function SetLabelAt(index: Integer; const text: ustring): Boolean;
    function GetType(commandId: Integer): TCefMenuItemType;
    function GetTypeAt(index: Integer): TCefMenuItemType;
    function GetGroupId(commandId: Integer): Integer;
    function GetGroupIdAt(index: Integer): Integer;
    function SetGroupId(commandId, groupId: Integer): Boolean;
    function SetGroupIdAt(index, groupId: Integer): Boolean;
    function GetSubMenu(commandId: Integer): ICefMenuModel;
    function GetSubMenuAt(index: Integer): ICefMenuModel;
    function IsVisible(commandId: Integer): Boolean;
    function isVisibleAt(index: Integer): Boolean;
    function SetVisible(commandId: Integer; visible: Boolean): Boolean;
    function SetVisibleAt(index: Integer; visible: Boolean): Boolean;
    function IsEnabled(commandId: Integer): Boolean;
    function IsEnabledAt(index: Integer): Boolean;
    function SetEnabled(commandId: Integer; enabled: Boolean): Boolean;
    function SetEnabledAt(index: Integer; enabled: Boolean): Boolean;
    function IsChecked(commandId: Integer): Boolean;
    function IsCheckedAt(index: Integer): Boolean;
    function setChecked(commandId: Integer; checked: Boolean): Boolean;
    function setCheckedAt(index: Integer; checked: Boolean): Boolean;
    function HasAccelerator(commandId: Integer): Boolean;
    function HasAcceleratorAt(index: Integer): Boolean;
    function SetAccelerator(commandId, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function SetAcceleratorAt(index, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function RemoveAccelerator(commandId: Integer): Boolean;
    function RemoveAcceleratorAt(index: Integer): Boolean;
    function GetAccelerator(commandId: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function GetAcceleratorAt(index: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
  end;

  ICefValue = interface(ICefBase)
  ['{66F9F439-B12B-4EC3-A945-91AE4EF4D4BA}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefValue): Boolean;
    function IsEqual(const that: ICefValue): Boolean;

    function Copy: ICefValue;

    function GetType: TCefValueType;
    function GetBool: Boolean;
    function GetInt: Integer;
    function GetDouble: Double;
    function GetString: ustring;
    function GetBinary: ICefBinaryValue;
    function GetDictionary: ICefDictionaryValue;
    function GetList: ICefListValue;

    function SetNull: Boolean;
    function SetBool(value: Integer): Boolean;
    function SetInt(value: Integer): Boolean;
    function SetDouble(value: Double): Boolean;
    function SetString(const value: ustring): Boolean;
    function SetBinary(const value: ICefBinaryValue): Boolean;
    function SetDictionary(const value: ICefDictionaryValue): Boolean;
    function SetList(const value: ICefListValue): Boolean;
  end;

  ICefBinaryValue = interface(ICefBase)
  ['{974AA40A-9C5C-4726-81F0-9F0D46D7C5B3}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsSame(const that: ICefBinaryValue): Boolean;
    function IsEqual(const that: ICefBinaryValue): Boolean;
    function Copy: ICefBinaryValue;
    function GetSize: NativeUInt;
    function GetData(buffer: Pointer; bufferSize, dataOffset: NativeUInt): NativeUInt;
  end;

  ICefDictionaryValue = interface(ICefBase)
  ['{B9638559-54DC-498C-8185-233EEF12BC69}']
    function IsValid: Boolean;
    function isOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefDictionaryValue): Boolean;
    function IsEqual(const that: ICefDictionaryValue): Boolean;
    function Copy(excludeEmptyChildren: Boolean): ICefDictionaryValue;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function HasKey(const key: ustring): Boolean;
    function GetKeys(const keys: TStrings): Boolean;
    function Remove(const key: ustring): Boolean;
    function GetType(const key: ustring): TCefValueType;
    function GetValue(const key: ustring): ICefValue;
    function GetBool(const key: ustring): Boolean;
    function GetInt(const key: ustring): Integer;
    function GetDouble(const key: ustring): Double;
    function GetString(const key: ustring): ustring;
    function GetBinary(const key: ustring): ICefBinaryValue;
    function GetDictionary(const key: ustring): ICefDictionaryValue;
    function GetList(const key: ustring): ICefListValue;
    function SetValue(const key: ustring; const value: ICefValue): Boolean;
    function SetNull(const key: ustring): Boolean;
    function SetBool(const key: ustring; value: Boolean): Boolean;
    function SetInt(const key: ustring; value: Integer): Boolean;
    function SetDouble(const key: ustring; value: Double): Boolean;
    function SetString(const key, value: ustring): Boolean;
    function SetBinary(const key: ustring; const value: ICefBinaryValue): Boolean;
    function SetDictionary(const key: ustring; const value: ICefDictionaryValue): Boolean;
    function SetList(const key: ustring; const value: ICefListValue): Boolean;
  end;


  ICefListValue = interface(ICefBase)
  ['{09174B9D-0CC6-4360-BBB0-3CC0117F70F6}']
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefListValue): Boolean;
    function IsEqual(const that: ICefListValue): Boolean;
    function Copy: ICefListValue;
    function SetSize(size: NativeUInt): Boolean;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function Remove(index: Integer): Boolean;
    function GetType(index: Integer): TCefValueType;
    function GetValue(index: Integer): ICefValue;
    function GetBool(index: Integer): Boolean;
    function GetInt(index: Integer): Integer;
    function GetDouble(index: Integer): Double;
    function GetString(index: Integer): ustring;
    function GetBinary(index: Integer): ICefBinaryValue;
    function GetDictionary(index: Integer): ICefDictionaryValue;
    function GetList(index: Integer): ICefListValue;
    function SetValue(index: Integer; const value: ICefValue): Boolean;
    function SetNull(index: Integer): Boolean;
    function SetBool(index: Integer; value: Boolean): Boolean;
    function SetInt(index, value: Integer): Boolean;
    function SetDouble(index: Integer; value: Double): Boolean;
    function SetString(index: Integer; const value: ustring): Boolean;
    function SetBinary(index: Integer; const value: ICefBinaryValue): Boolean;
    function SetDictionary(index: Integer; const value: ICefDictionaryValue): Boolean;
    function SetList(index: Integer; const value: ICefListValue): Boolean;
  end;


  ICefLifeSpanHandler = interface(ICefBase)
  ['{0A3EB782-A319-4C35-9B46-09B2834D7169}']
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean;
    procedure OnAfterCreated(const browser: ICefBrowser);
    procedure OnBeforeClose(const browser: ICefBrowser);
    function RunModal(const browser: ICefBrowser): Boolean;
    function DoClose(const browser: ICefBrowser): Boolean;
  end;

  ICefLoadHandler = interface(ICefBase)
  ['{2C63FB82-345D-4A5B-9858-5AE7A85C9F49}']
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame);
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring);
  end;

  ICefRequestCallback = interface(ICefBase)
  ['{A35B8FD5-226B-41A8-A763-1940787D321C}']
    procedure Cont(allow: Boolean);
    procedure Cancel;
  end;

  ICefRequestHandler = interface(ICefBase)
  ['{050877A9-D1F8-4EB3-B58E-50DC3E3D39FD}']
    function OnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean;
    function OnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean;
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring);
    function OnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean;
    function OnQuotaRequest(const browser: ICefBrowser;
      const originUrl: ustring; newSize: Int64; const callback: ICefRequestCallback): Boolean;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean);
    function OnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring);
    procedure OnRenderViewReady(const browser: ICefBrowser);
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus);
  end;

  ICefDisplayHandler = interface(ICefBase)
  ['{1EC7C76D-6969-41D1-B26D-079BCFF054C4}']
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring);
    procedure OnFaviconUrlChange(const browser: ICefBrowser; icon_urls: TStrings);
    procedure OnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean);
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring);
    function OnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean;
  end;

  ICefFocusHandler = interface(ICefBase)
  ['{BB7FA3FA-7B1A-4ADC-8E50-12A24018DD90}']
    procedure OnTakeFocus(const browser: ICefBrowser; next: Boolean);
    function OnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean;
    procedure OnGotFocus(const browser: ICefBrowser);
  end;

  ICefKeyboardHandler = interface(ICefBase)
  ['{0512F4EC-ED88-44C9-90D3-5C6D03D3B146}']
    function OnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean;
  end;

  ICefJsDialogHandler = interface(ICefBase)
  ['{64E18F86-DAC5-4ED1-8589-44DE45B9DB56}']
    function OnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean;
    function OnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean;
    procedure OnResetDialogState(const browser: ICefBrowser);
    procedure OnDialogClosed(const browser: ICefBrowser);
  end;

  ICefRunContextMenuCallback = interface(ICefBase)
  ['{44C3C6E3-B64D-4F6E-A318-4A0F3A72EB00}']
    procedure Cont(commandId: Integer; eventFlags: TCefEventFlags);
    procedure Cancel;
  end;

  ICefContextMenuHandler = interface(ICefBase)
  ['{C2951895-4087-49D5-BA18-4D9BA4F5EDD7}']
    procedure OnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    function RunContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel;
      const callback: ICefRunContextMenuCallback): Boolean;
    function OnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean;
    procedure OnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame);
  end;

  ICefDialogHandler = interface(ICefBase)
  ['{7763F4B2-8BE1-4E80-AC43-8B825850DC67}']
    function OnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title, defaultFilePath: ustring; acceptFilters: TStrings;
      selectedAcceptFilter: Integer; const callback: ICefFileDialogCallback): Boolean;
  end;

  ICefGeolocationCallback = interface(ICefBase)
  ['{272B8E4F-4AE4-4F14-BC4E-5924FA0C149D}']
    procedure Cont(allow: Boolean);
  end;

  ICefGeolocationHandler = interface(ICefBase)
  ['{1178EE62-BAE7-4E44-932B-EAAC7A18191C}']
    function OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer; const callback: ICefGeolocationCallback): Boolean;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer);
  end;

  ICefRenderHandler = interface(ICefBase)
  ['{1FC1C22B-085A-4741-9366-5249B88EC410}']
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean;
    function GetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean;
    procedure OnPopupShow(const browser: ICefBrowser; show: Boolean);
    procedure OnPopupSize(const browser: ICefBrowser; const rect: PCefRect);
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer);
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      CursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo);
    function OnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean;
    procedure OnUpdateDragCursor(const browser: ICefBrowser;
      operation: TCefDragOperation);
    procedure OnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double);
  end;

  ICefClient = interface(ICefBase)
    ['{1D502075-2FF0-4E13-A112-9E541CD811F4}']
    function GetContextMenuHandler: ICefContextMenuHandler;
    function GetDisplayHandler: ICefDisplayHandler;
    function GetDownloadHandler: ICefDownloadHandler;
    function GetFocusHandler: ICefFocusHandler;
    function GetGeolocationHandler: ICefGeolocationHandler;
    function GetJsdialogHandler: ICefJsdialogHandler;
    function GetKeyboardHandler: ICefKeyboardHandler;
    function GetLifeSpanHandler: ICefLifeSpanHandler;
    function GetLoadHandler: ICefLoadHandler;
    function GetRenderHandler: ICefRenderHandler;
    function GetRequestHandler: ICefRequestHandler;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
  end;

  ICefUrlRequest = interface(ICefBase)
    ['{59226AC1-A0FA-4D59-9DF4-A65C42391A67}']
    function GetRequest: ICefRequest;
    function GetRequestStatus: TCefUrlRequestStatus;
    function GetRequestError: Integer;
    function GetResponse: ICefResponse;
    procedure Cancel;
  end;

  ICefUrlrequestClient = interface(ICefBase)
    ['{114155BD-C248-4651-9A4F-26F3F9A4F737}']
    procedure OnRequestComplete(const request: ICefUrlRequest);
    procedure OnUploadProgress(const request: ICefUrlRequest; current, total: Int64);
    procedure OnDownloadProgress(const request: ICefUrlRequest; current, total: Int64);
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt);
    function OnGetAuthCredentials(isProxy: Boolean; const host: ustring; port: Integer;
      const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
  end;

  ICefWebPluginInfoVisitor = interface(ICefBase)
  ['{7523D432-4424-4804-ACAD-E67D2313436E}']
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean;
  end;

  ICefWebPluginUnstableCallback = interface(ICefBase)
  ['{67459829-EB47-4B7E-9D69-2EE77DF0E71E}']
    procedure IsUnstable(const path: ustring; unstable: Boolean);
  end;

  ICefEndTracingCallback = interface(ICefBase)
  ['{79020EBE-9D1D-49A6-9714-8778FE8929F2}']
    procedure OnEndTracingComplete(const tracingFile: ustring);
  end;

  ICefGetGeolocationCallback = interface(ICefBase)
    ['{ACB82FD9-3FFD-43F9-BF1A-A4849BF5B814}']
    procedure OnLocationUpdate(const position: PCefGeoposition);
  end;

  ICefFileDialogCallback = interface(ICefBase)
    ['{1AF659AB-4522-4E39-9C52-184000D8E3C7}']
    procedure Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
    procedure Cancel;
  end;

  ICefDragData = interface(ICefBase)
  ['{FBB6A487-F633-4055-AB3E-6619EDE75683}']
    function Clone: ICefDragData;
    function IsReadOnly: Boolean;
    function IsLink: Boolean;
    function IsFragment: Boolean;
    function IsFile: Boolean;
    function GetLinkUrl: ustring;
    function GetLinkTitle: ustring;
    function GetLinkMetadata: ustring;
    function GetFragmentText: ustring;
    function GetFragmentHtml: ustring;
    function GetFragmentBaseUrl: ustring;
    function GetFileName: ustring;
    function GetFileContents(const writer: ICefStreamWriter): NativeUInt;
    function GetFileNames(names: TStrings): Integer;
    procedure SetLinkUrl(const url: ustring);
    procedure SetLinkTitle(const title: ustring);
    procedure SetLinkMetadata(const data: ustring);
    procedure SetFragmentText(const text: ustring);
    procedure SetFragmentHtml(const html: ustring);
    procedure SetFragmentBaseUrl(const baseUrl: ustring);
    procedure ResetFileContents;
    procedure AddFile(const path, displayName: ustring);
  end;

  ICefDragHandler = interface(ICefBase)
    ['{59A89579-5B18-489F-A25C-5CC25FF831FC}']
    function OnDragEnter(const browser: ICefBrowser; const dragData: ICefDragData;
      mask: TCefDragOperations): Boolean;
    procedure OnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray);
  end;

  ICefFindHandler = interface(ICefBase)
    ['{F20DF234-BD43-42B3-A80B-D354A9E5B787}']
    procedure OnFindResult(const browser: ICefBrowser;
      identifier, count: Integer; const selectionRect: PCefRect;
      activeMatchOrdinal: Integer; finalUpdate: Boolean);
  end;

  ICefRequestContextHandler = interface(ICefBase)
    ['{76EB1FA7-78DF-4FD5-ABB3-1CDD3E73A140}']
    function GetCookieManager: ICefCookieManager;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean;
  end;

  ICefRequestContext = interface(ICefBase)
    ['{5830847A-2971-4BD5-ABE6-21451F8923F7}']
    function IsSame(const other: ICefRequestContext): Boolean;
    function IsSharingWith(const other: ICefRequestContext): Boolean;
    function IsGlobal: Boolean;
    function GetHandler: ICefRequestContextHandler;
    function GetCachePath: ustring;
    function GetDefaultCookieManager(const callback: ICefCompletionCallback): ICefCookieManager;
    function GetDefaultCookieManagerProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    function RegisterSchemeHandlerFactory(const schemeName, domainName: ustring;
        const factory: ICefSchemeHandlerFactory): Boolean;
    function ClearSchemeHandlerFactories: Boolean;
    procedure PurgePluginListCache(reloadPages: Boolean);
  end;

  ICefPrintSettings = Interface(ICefBase)
    ['{ACBD2395-E9C1-49E5-B7F3-344DAA4A0F12}']
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefPrintSettings;
    procedure SetOrientation(landscape: Boolean);
    function IsLandscape: Boolean;
    procedure SetPrinterPrintableArea(
      const physicalSizeDeviceUnits: PCefSize;
      const printableAreaDeviceUnits: PCefRect;
      landscapeNeedsFlip: Boolean); stdcall;
    procedure SetDeviceName(const name: ustring);
    function GetDeviceName: ustring;
    procedure SetDpi(dpi: Integer);
    function GetDpi: Integer;
    procedure SetPageRanges(const ranges: TCefPageRangeArray);
    function GetPageRangesCount: NativeUInt;
    procedure GetPageRanges(out ranges: TCefPageRangeArray);
    procedure SetSelectionOnly(selectionOnly: Boolean);
    function IsSelectionOnly: Boolean;
    procedure SetCollate(collate: Boolean);
    function WillCollate: Boolean;
    procedure SetColorModel(model: TCefColorModel);
    function GetColorModel: TCefColorModel;
    procedure SetCopies(copies: Integer);
    function GetCopies: Integer;
    procedure SetDuplexMode(mode: TCefDuplexMode);
    function GetDuplexMode: TCefDuplexMode;

    property Landscape: Boolean read IsLandscape write SetOrientation;
    property DeviceName: ustring read GetDeviceName write SetDeviceName;
    property Dpi: Integer read GetDpi write SetDpi;
    property SelectionOnly: Boolean read IsSelectionOnly write SetSelectionOnly;
    property Collate: Boolean read WillCollate write SetCollate;
    property ColorModel: TCefColorModel read GetColorModel write SetColorModel;
    property Copies: Integer read GetCopies write SetCopies;
    property DuplexMode: TCefDuplexMode read GetDuplexMode write SetDuplexMode;
  end;

  ICefNavigationEntry = interface(ICefBase)
  ['{D17B4B37-AA45-42D9-B4E4-AAB6FE2AB297}']
    function IsValid: Boolean;
    function GetUrl: ustring;
    function GetDisplayUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetTitle: ustring;
    function GetTransitionType: TCefTransitionType;
    function HasPostData: Boolean;
    function GetCompletionTime: TDateTime;
    function GetHttpStatusCode: Integer;

    property Url: ustring read GetUrl;
    property DisplayUrl: ustring read GetDisplayUrl;
    property OriginalUrl: ustring read GetOriginalUrl;
    property Title: ustring read GetTitle;
    property TransitionType: TCefTransitionType read GetTransitionType;
    property CompletionTime: TDateTime read GetCompletionTime;
    property HttpStatusCode: Integer read GetHttpStatusCode;
  end;

  ICefSslCertPrincipal = interface(ICefBase)
  ['{A0B083E1-51D3-4753-9FDD-9ADF75C3E68B}']
    function GetDisplayName: ustring;
    function GetCommonName: ustring;
    function GetLocalityName: ustring;
    function GetStateOrProvinceName: ustring;
    function GetCountryName: ustring;
    procedure GetStreetAddresses(addresses: TStrings);
    procedure GetOrganizationNames(names: TStrings);
    procedure GetOrganizationUnitNames(names: TStrings);
    procedure GetDomainComponents(components: TStrings);
  end;

  ICefSslInfo = interface(ICefBase)
  ['{67EC86BD-DE7D-453D-908F-AD15626C514F}']
    function GetSubject: ICefSslCertPrincipal;
    function GetIssuer: ICefSslCertPrincipal;
    function GetSerialNumber: ICefBinaryValue;
    function GetValidStart: TCefTime;
    function GetValidExpiry: TCefTime;
    function GetDerEncoded: ICefBinaryValue;
    function GetPemEncoded: ICefBinaryValue;
  end;

  ICefResourceBundle = interface(ICefBase)
  ['{3213CF97-C854-452B-B615-39192F8D07DC}']
    function GetLocalizedString(stringId: Integer): ustring;
    function GetDataResource(resourceId: Integer;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
    function GetDataResourceForScale(resourceId: Integer; scaleFactor: TCefScaleFactor;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
  end;

/////////////////////////////////////////


  TCefBaseOwn = class(TInterfacedObject, ICefBase)
  private
    FData: Pointer;
  public
    function Wrap: Pointer;
    constructor CreateData(size: Cardinal; owned: Boolean = False); virtual;
    destructor Destroy; override;
  end;

  TCefBaseRef = class(TInterfacedObject, ICefBase)
  private
    FData: Pointer;
  public
    constructor Create(data: Pointer); virtual;
    destructor Destroy; override;
    function Wrap: Pointer;
    class function UnWrap(data: Pointer): ICefBase;
  end;

  TCefRunFileDialogCallbackOwn = class(TCefBaseOwn, ICefRunFileDialogCallback)
  protected
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings); virtual;
  public
    constructor Create;
  end;

  TCefFastRunFileDialogCallback = class(TCefRunFileDialogCallbackOwn)
  private
    FCallback: TCefRunFileDialogCallbackProc;
  protected
    procedure OnFileDialogDismissed(selectedAcceptFilter: Integer; filePaths: TStrings); override;
  public
    constructor Create(callback: TCefRunFileDialogCallbackProc); reintroduce; virtual;
  end;

  TCefBrowserHostRef = class(TCefBaseRef, ICefBrowserHost)
  protected
    function GetBrowser: ICefBrowser;
    procedure CloseBrowser(forceClose: Boolean);
    procedure SetFocus(focus: Boolean);
    procedure SetWindowVisibility(visible: Boolean);
    function GetWindowHandle: TCefWindowHandle;
    function GetOpenerWindowHandle: TCefWindowHandle;
    function GetRequestContext: ICefRequestContext;
    function GetZoomLevel: Double;
    procedure SetZoomLevel(zoomLevel: Double);
    procedure RunFileDialog(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
    procedure RunFileDialogProc(mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
      acceptFilters: TStrings; selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
    procedure StartDownload(const url: ustring);
    procedure Print;
    procedure PrintToPdf(const path: ustring; settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
    procedure PrintToPdfProc(const path: ustring; settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
    procedure Find(identifier: Integer; const searchText: ustring; forward, matchCase, findNext: Boolean);
    procedure StopFinding(clearSelection: Boolean);
    procedure ShowDevTools(const windowInfo: PCefWindowInfo; const client: ICefClient;
      const settings: PCefBrowserSettings; inspectElementAt: PCefPoint);
    procedure CloseDevTools;
    procedure GetNavigationEntries(const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
    procedure GetNavigationEntriesProc(const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
    procedure SetMouseCursorChangeDisabled(disabled: Boolean);
    function IsMouseCursorChangeDisabled: Boolean;
    procedure ReplaceMisspelling(const word: ustring);
    procedure AddWordToDictionary(const word: ustring);
    function IsWindowRenderingDisabled: Boolean;
    procedure WasResized;
    procedure NotifyScreenInfoChanged;
    procedure WasHidden(hidden: Boolean);
    procedure Invalidate(kind: TCefPaintElementType);
    procedure SendKeyEvent(const event: PCefKeyEvent);
    procedure SendMouseClickEvent(const event: PCefMouseEvent;
      kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
    procedure SendMouseMoveEvent(const event: PCefMouseEvent; mouseLeave: Boolean);
    procedure SendMouseWheelEvent(const event: PCefMouseEvent; deltaX, deltaY: Integer);
    procedure SendFocusEvent(setFocus: Boolean);
    procedure SendCaptureLostEvent;
    procedure NotifyMoveOrResizeStarted;
    function GetWindowlessFrameRate(): Integer;
    procedure SetWindowlessFrameRate(frameRate: Integer);
    function GetNsTextInputContext: TCefTextInputContext;
    procedure HandleKeyEventBeforeTextInputClient(keyEvent: TCefEventHandle);
    procedure HandleKeyEventAfterTextInputClient(keyEvent: TCefEventHandle);

    procedure DragTargetDragEnter(const dragData: ICefDragData;
      const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragOver(const event: PCefMouseEvent; allowedOps: TCefDragOperations);
    procedure DragTargetDragLeave;
    procedure DragTargetDrop(event: PCefMouseEvent);
    procedure DragSourceEndedAt(x, y: Integer; op: TCefDragOperation);
    procedure DragSourceSystemDragEnded;
  public
    class function UnWrap(data: Pointer): ICefBrowserHost;
  end;

  TCefBrowserRef = class(TCefBaseRef, ICefBrowser)
  protected
    function GetHost: ICefBrowserHost;
    function CanGoBack: Boolean;
    procedure GoBack;
    function CanGoForward: Boolean;
    procedure GoForward;
    function IsLoading: Boolean;
    procedure Reload;
    procedure ReloadIgnoreCache;
    procedure StopLoad;
    function GetIdentifier: Integer;
    function IsSame(const that: ICefBrowser): Boolean;
    function IsPopup: Boolean;
    function HasDocument: Boolean;
    function GetMainFrame: ICefFrame;
    function GetFocusedFrame: ICefFrame;
    function GetFrameByident(identifier: Int64): ICefFrame;
    function GetFrame(const name: ustring): ICefFrame;
    function GetFrameCount: NativeUInt;
    procedure GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
    procedure GetFrameNames(names: TStrings);
    function SendProcessMessage(targetProcess: TCefProcessId;
      message: ICefProcessMessage): Boolean;
  public
    class function UnWrap(data: Pointer): ICefBrowser;
  end;

  TCefFrameRef = class(TCefBaseRef, ICefFrame)
  protected
    function IsValid: Boolean;
    procedure Undo;
    procedure Redo;
    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Del;
    procedure SelectAll;
    procedure ViewSource;
    procedure GetSource(const visitor: ICefStringVisitor);
    procedure GetSourceProc(const proc: TCefStringVisitorProc);
    procedure GetText(const visitor: ICefStringVisitor);
    procedure GetTextProc(const proc: TCefStringVisitorProc);
    procedure LoadRequest(const request: ICefRequest);
    procedure LoadUrl(const url: ustring);
    procedure LoadString(const str, url: ustring);
    procedure ExecuteJavaScript(const code, scriptUrl: ustring; startLine: Integer);
    function IsMain: Boolean;
    function IsFocused: Boolean;
    function GetName: ustring;
    function GetIdentifier: Int64;
    function GetParent: ICefFrame;
    function GetUrl: ustring;
    function GetBrowser: ICefBrowser;
    function GetV8Context: ICefv8Context;
    procedure VisitDom(const visitor: ICefDomVisitor);
    procedure VisitDomProc(const proc: TCefDomVisitorProc);
  public
    class function UnWrap(data: Pointer): ICefFrame;
  end;

  TCefPostDataRef = class(TCefBaseRef, ICefPostData)
  protected
    function IsReadOnly: Boolean;
    function GetCount: NativeUInt;
    function GetElements(Count: NativeUInt): IInterfaceList; // ICefPostDataElement
    function RemoveElement(const element: ICefPostDataElement): Integer;
    function AddElement(const element: ICefPostDataElement): Integer;
    procedure RemoveElements;
  public
    class function UnWrap(data: Pointer): ICefPostData;
    class function New: ICefPostData;
  end;

  TCefPostDataElementRef = class(TCefBaseRef, ICefPostDataElement)
  protected
    function IsReadOnly: Boolean;
    procedure SetToEmpty;
    procedure SetToFile(const fileName: ustring);
    procedure SetToBytes(size: NativeUInt; bytes: Pointer);
    function GetType: TCefPostDataElementType;
    function GetFile: ustring;
    function GetBytesCount: NativeUInt;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt;
  public
    class function UnWrap(data: Pointer): ICefPostDataElement;
    class function New: ICefPostDataElement;
  end;

  TCefRequestRef = class(TCefBaseRef, ICefRequest)
  protected
    function IsReadOnly: Boolean;
    function GetUrl: ustring;
    function GetMethod: ustring;
    function GetPostData: ICefPostData;
    procedure GetHeaderMap(const HeaderMap: ICefStringMultimap);
    procedure SetUrl(const value: ustring);
    procedure SetMethod(const value: ustring);
    procedure SetPostData(const value: ICefPostData);
    procedure SetHeaderMap(const HeaderMap: ICefStringMultimap);
    function GetFlags: TCefUrlRequestFlags;
    procedure SetFlags(flags: TCefUrlRequestFlags);
    function GetFirstPartyForCookies: ustring;
    procedure SetFirstPartyForCookies(const url: ustring);
    procedure Assign(const url, method: ustring;
      const postData: ICefPostData; const headerMap: ICefStringMultimap);
    function GetResourceType: TCefResourceType;
    function GetTransitionType: TCefTransitionType;
    function GetIdentifier: UInt64;
  public
    class function UnWrap(data: Pointer): ICefRequest;
    class function New: ICefRequest;
  end;

  TCefStreamReaderRef = class(TCefBaseRef, ICefStreamReader)
  protected
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Eof: Boolean;
    function MayBlock: Boolean;
  public
    class function UnWrap(data: Pointer): ICefStreamReader;
    class function CreateForFile(const filename: ustring): ICefStreamReader;
    class function CreateForCustomStream(const stream: ICefCustomStreamReader): ICefStreamReader;
    class function CreateForStream(const stream: TSTream; owned: Boolean): ICefStreamReader;
    class function CreateForData(data: Pointer; size: NativeUInt): ICefStreamReader;
  end;

  TCefWriteHandlerOwn = class(TCefBaseOwn, ICefWriteHandler)
  protected
    function Write(const ptr: Pointer; size, n: NativeUInt): NativeUInt; virtual;
    function Seek(offset: Int64; whence: Integer): Integer; virtual;
    function Tell: Int64; virtual;
    function Flush: Integer; virtual;
    function MayBlock: Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefStreamWriterRef = class(TCefBaseRef, ICefStreamWriter)
  protected
    function write(const ptr: Pointer; size, n: NativeUInt): NativeUInt;
    function Seek(offset: Int64; whence: Integer): Integer;
    function Tell: Int64;
    function Flush: Integer;
    function MayBlock: Boolean;
  public
    class function UnWrap(data: Pointer): ICefStreamWriter;
    class function CreateForFile(const fileName: ustring): ICefStreamWriter;
    class function CreateForHandler(const handler: ICefWriteHandler): ICefStreamWriter;
  end;


  TCefV8AccessorGetterProc = {$IFDEF DELPHI12_UP} reference to{$ENDIF} function(
    const name: ustring; const obj: ICefv8Value; out value: ICefv8Value; const exception: ustring): Boolean;

  TCefV8AccessorSetterProc = {$IFDEF DELPHI12_UP}reference to {$ENDIF} function(
    const name: ustring; const obj, value: ICefv8Value; const exception: ustring): Boolean;

  TCefv8ValueRef = class(TCefBaseRef, ICefv8Value)
  protected
    function IsValid: Boolean;
    function IsUndefined: Boolean;
    function IsNull: Boolean;
    function IsBool: Boolean;
    function IsInt: Boolean;
    function IsUInt: Boolean;
    function IsDouble: Boolean;
    function IsDate: Boolean;
    function IsString: Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsFunction: Boolean;
    function IsSame(const that: ICefv8Value): Boolean;
    function GetBoolValue: Boolean;
    function GetIntValue: Integer;
    function GetUIntValue: Cardinal;
    function GetDoubleValue: Double;
    function GetDateValue: TDateTime;
    function GetStringValue: ustring;
    function IsUserCreated: Boolean;
    function HasException: Boolean;
    function GetException: ICefV8Exception;
    function ClearException: Boolean;
    function WillRethrowExceptions: Boolean;
    function SetRethrowExceptions(rethrow: Boolean): Boolean;
    function HasValueByKey(const key: ustring): Boolean;
    function HasValueByIndex(index: Integer): Boolean;
    function DeleteValueByKey(const key: ustring): Boolean;
    function DeleteValueByIndex(index: Integer): Boolean;
    function GetValueByKey(const key: ustring): ICefv8Value;
    function GetValueByIndex(index: Integer): ICefv8Value;
    function SetValueByKey(const key: ustring; const value: ICefv8Value;
      attribute: TCefV8PropertyAttributes): Boolean;
    function SetValueByIndex(index: Integer; const value: ICefv8Value): Boolean;
    function SetValueByAccessor(const key: ustring; settings: TCefV8AccessControls;
      attribute: TCefV8PropertyAttributes): Boolean;
    function GetKeys(const keys: TStrings): Integer;
    function SetUserData(const data: ICefv8Value): Boolean;
    function GetUserData: ICefv8Value;
    function GetExternallyAllocatedMemory: Integer;
    function AdjustExternallyAllocatedMemory(changeInBytes: Integer): Integer;
    function GetArrayLength: Integer;
    function GetFunctionName: ustring;
    function GetFunctionHandler: ICefv8Handler;
    function ExecuteFunction(const obj: ICefv8Value;
      const arguments: TCefv8ValueArray): ICefv8Value;
    function ExecuteFunctionWithContext(const context: ICefv8Context;
      const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
  public
    class function UnWrap(data: Pointer): ICefv8Value;
    class function NewUndefined: ICefv8Value;
    class function NewNull: ICefv8Value;
    class function NewBool(value: Boolean): ICefv8Value;
    class function NewInt(value: Integer): ICefv8Value;
    class function NewUInt(value: Cardinal): ICefv8Value;
    class function NewDouble(value: Double): ICefv8Value;
    class function NewDate(value: TDateTime): ICefv8Value;
    class function NewString(const str: ustring): ICefv8Value;
    class function NewObject(const Accessor: ICefV8Accessor): ICefv8Value;
    class function NewObjectProc(const getter: TCefV8AccessorGetterProc;
      const setter: TCefV8AccessorSetterProc): ICefv8Value;
    class function NewArray(len: Integer): ICefv8Value;
    class function NewFunction(const name: ustring; const handler: ICefv8Handler): ICefv8Value;
  end;

  TCefv8ContextRef = class(TCefBaseRef, ICefv8Context)
  protected
    function GetTaskRunner: ICefTaskRunner;
    function IsValid: Boolean;
    function GetBrowser: ICefBrowser;
    function GetFrame: ICefFrame;
    function GetGlobal: ICefv8Value;
    function Enter: Boolean;
    function Exit: Boolean;
    function IsSame(const that: ICefv8Context): Boolean;
    function Eval(const code: ustring; var retval: ICefv8Value; var exception: ICefV8Exception): Boolean;
  public
    class function UnWrap(data: Pointer): ICefv8Context;
    class function Current: ICefv8Context;
    class function Entered: ICefv8Context;
  end;

  TCefV8StackFrameRef = class(TCefBaseRef, ICefV8StackFrame)
  protected
    function IsValid: Boolean;
    function GetScriptName: ustring;
    function GetScriptNameOrSourceUrl: ustring;
    function GetFunctionName: ustring;
    function GetLineNumber: Integer;
    function GetColumn: Integer;
    function IsEval: Boolean;
    function IsConstructor: Boolean;
  public
    class function UnWrap(data: Pointer): ICefV8StackFrame;
  end;

  TCefV8StackTraceRef = class(TCefBaseRef, ICefV8StackTrace)
  protected
    function IsValid: Boolean;
    function GetFrameCount: Integer;
    function GetFrame(index: Integer): ICefV8StackFrame;
  public
    class function UnWrap(data: Pointer): ICefV8StackTrace;
    class function Current(frameLimit: Integer): ICefV8StackTrace;
  end;

  TCefv8HandlerRef = class(TCefBaseRef, ICefv8Handler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean;
  public
    class function UnWrap(data: Pointer): ICefv8Handler;
  end;

  TCefClientOwn = class(TCefBaseOwn, ICefClient)
  protected
    function GetContextMenuHandler: ICefContextMenuHandler; virtual;
    function GetDialogHandler: ICefDialogHandler; virtual;
    function GetDisplayHandler: ICefDisplayHandler; virtual;
    function GetDownloadHandler: ICefDownloadHandler; virtual;
    function GetDragHandler: ICefDragHandler; virtual;
    function GetFindHandler: ICefFindHandler; virtual;
    function GetFocusHandler: ICefFocusHandler; virtual;
    function GetGeolocationHandler: ICefGeolocationHandler; virtual;
    function GetJsdialogHandler: ICefJsdialogHandler; virtual;
    function GetKeyboardHandler: ICefKeyboardHandler; virtual;
    function GetLifeSpanHandler: ICefLifeSpanHandler; virtual;
    function GetRenderHandler: ICefRenderHandler; virtual;
    function GetLoadHandler: ICefLoadHandler; virtual;
    function GetRequestHandler: ICefRequestHandler; virtual;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefGeolocationHandlerOwn = class(TCefBaseOwn, ICefGeolocationHandler)
  protected
    function OnRequestGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer;
      const callback: ICefGeolocationCallback): Boolean; virtual;
    procedure OnCancelGeolocationPermission(const browser: ICefBrowser;
      const requestingUrl: ustring; requestId: Integer); virtual;
  public

    constructor Create; virtual;
  end;


  TCefLifeSpanHandlerOwn = class(TCefBaseOwn, ICefLifeSpanHandler)
  protected
    function OnBeforePopup(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean; var popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings;
      var noJavascriptAccess: Boolean): Boolean; virtual;
    procedure OnAfterCreated(const browser: ICefBrowser); virtual;
    procedure OnBeforeClose(const browser: ICefBrowser); virtual;
    function RunModal(const browser: ICefBrowser): Boolean; virtual;
    function DoClose(const browser: ICefBrowser): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefLoadHandlerOwn = class(TCefBaseOwn, ICefLoadHandler)
  protected
    procedure OnLoadingStateChange(const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean); virtual;
    procedure OnLoadStart(const browser: ICefBrowser; const frame: ICefFrame); virtual;
    procedure OnLoadEnd(const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer); virtual;
    procedure OnLoadError(const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer;
      const errorText, failedUrl: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefRequestCallbackRef = class(TCefBaseRef, ICefRequestCallback)
  protected
    procedure Cont(allow: Boolean);
    procedure Cancel;
  public
     class function UnWrap(data: Pointer): ICefRequestCallback;
  end;

  TCefRequestHandlerOwn = class(TCefBaseOwn, ICefRequestHandler)
  protected
    function OnBeforeBrowse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; isRedirect: Boolean): Boolean; virtual;
    function OnOpenUrlFromTab(const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean): Boolean; virtual;
    function OnBeforeResourceLoad(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback): TCefReturnValue; virtual;
    function GetResourceHandler(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest): ICefResourceHandler; virtual;
    procedure OnResourceRedirect(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; var newUrl: ustring); virtual;
    function OnResourceResponse(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse): Boolean; virtual;
    function GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
      isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
      const callback: ICefAuthCallback): Boolean; virtual;
    function OnQuotaRequest(const browser: ICefBrowser; const originUrl: ustring;
      newSize: Int64; const callback: ICefRequestCallback): Boolean; virtual;
    function GetCookieManager(const browser: ICefBrowser; const mainUrl: ustring): ICefCookieManager; virtual;
    procedure OnProtocolExecution(const browser: ICefBrowser; const url: ustring; out allowOsExecution: Boolean); virtual;
    function OnCertificateError(const browser: ICefBrowser; certError: TCefErrorcode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo; const callback: ICefRequestCallback): Boolean; virtual;
    procedure OnPluginCrashed(const browser: ICefBrowser; const pluginPath: ustring); virtual;
    procedure OnRenderViewReady(const browser: ICefBrowser); virtual;
    procedure OnRenderProcessTerminated(const browser: ICefBrowser; status: TCefTerminationStatus); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDisplayHandlerOwn = class(TCefBaseOwn, ICefDisplayHandler)
  protected
    procedure OnAddressChange(const browser: ICefBrowser; const frame: ICefFrame; const url: ustring); virtual;
    procedure OnTitleChange(const browser: ICefBrowser; const title: ustring); virtual;
    procedure OnFaviconUrlChange(const browser: ICefBrowser; iconUrls: TStrings); virtual;
    procedure OnFullScreenModeChange(const browser: ICefBrowser; fullscreen: Boolean); virtual;
    function OnTooltip(const browser: ICefBrowser; var text: ustring): Boolean; virtual;
    procedure OnStatusMessage(const browser: ICefBrowser; const value: ustring); virtual;
    function OnConsoleMessage(const browser: ICefBrowser; const message, source: ustring; line: Integer): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFocusHandlerOwn = class(TCefBaseOwn, ICefFocusHandler)
  protected
    procedure OnTakeFocus(const browser: ICefBrowser; next: Boolean); virtual;
    function OnSetFocus(const browser: ICefBrowser; source: TCefFocusSource): Boolean; virtual;
    procedure OnGotFocus(const browser: ICefBrowser); virtual;
  public
    constructor Create; virtual;
  end;

  TCefKeyboardHandlerOwn = class(TCefBaseOwn, ICefKeyboardHandler)
  protected
    function OnPreKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean): Boolean; virtual;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefJsDialogHandlerOwn = class(TCefBaseOwn, ICefJsDialogHandler)
  protected
    function OnJsdialog(const browser: ICefBrowser; const originUrl, acceptLang: ustring;
      dialogType: TCefJsDialogType; const messageText, defaultPromptText: ustring;
      callback: ICefJsDialogCallback; out suppressMessage: Boolean): Boolean; virtual;
    function OnBeforeUnloadDialog(const browser: ICefBrowser;
      const messageText: ustring; isReload: Boolean;
      const callback: ICefJsDialogCallback): Boolean; virtual;
    procedure OnResetDialogState(const browser: ICefBrowser); virtual;
    procedure OnDialogClosed(const browser: ICefBrowser); virtual;
  public
    constructor Create; virtual;
  end;

  TCefContextMenuHandlerOwn = class(TCefBaseOwn, ICefContextMenuHandler)
  protected
    procedure OnBeforeContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel); virtual;
    function RunContextMenu(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel;
      const callback: ICefRunContextMenuCallback): Boolean; virtual;
    function OnContextMenuCommand(const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags): Boolean; virtual;
    procedure OnContextMenuDismissed(const browser: ICefBrowser; const frame: ICefFrame); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDialogHandlerOwn = class(TCefBaseOwn, ICefDialogHandler)
  protected
    function OnFileDialog(const browser: ICefBrowser; mode: TCefFileDialogMode;
      const title, defaultFilePath: ustring; acceptFilters: TStrings;
      selectedAcceptFilter: Integer; const callback: ICefFileDialogCallback): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefDownloadHandlerOwn = class(TCefBaseOwn, ICefDownloadHandler)
  protected
    procedure OnBeforeDownload(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback); virtual;
    procedure OnDownloadUpdated(const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
        const callback: ICefDownloadItemCallback); virtual;
  public
    constructor Create; virtual;
  end;

  TCefCustomStreamReader = class(TCefBaseOwn, ICefCustomStreamReader)
  private
    FStream: TStream;
    FOwned: Boolean;
  protected
    function Read(ptr: Pointer; size, n: NativeUInt): NativeUInt; virtual;
    function Seek(offset: Int64; whence: Integer): Integer; virtual;
    function Tell: Int64; virtual;
    function Eof: Boolean; virtual;
    function MayBlock: Boolean; virtual;
  public
    constructor Create(Stream: TStream; Owned: Boolean); overload; virtual;
    constructor Create(const filename: string); overload; virtual;
    destructor Destroy; override;
  end;

  TCefPostDataElementOwn = class(TCefBaseOwn, ICefPostDataElement)
  private
    FDataType: TCefPostDataElementType;
    FValueByte: Pointer;
    FValueStr: TCefString;
    FSize: NativeUInt;
    FReadOnly: Boolean;
    procedure Clear;
  protected
    function IsReadOnly: Boolean; virtual;
    procedure SetToEmpty; virtual;
    procedure SetToFile(const fileName: ustring); virtual;
    procedure SetToBytes(size: NativeUInt; bytes: Pointer); virtual;
    function GetType: TCefPostDataElementType; virtual;
    function GetFile: ustring; virtual;
    function GetBytesCount: NativeUInt; virtual;
    function GetBytes(size: NativeUInt; bytes: Pointer): NativeUInt; virtual;
  public
    constructor Create(readonly: Boolean); virtual;
  end;

  TCefCallbackRef = class(TCefBaseRef, ICefCallback)
  protected
    procedure Cont;
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefCallback;
  end;

  TCefCompletionCallbackOwn = class(TCefBaseOwn, ICefCompletionCallback)
  protected
    procedure OnComplete; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastCompletionCallback = class(TCefCompletionCallbackOwn)
  private
    FProc: TCefCompletionCallbackProc;
  protected
    procedure OnComplete; override;
  public
    constructor Create(const proc: TCefCompletionCallbackProc); reintroduce;
  end;

  TCefResourceHandlerOwn = class(TCefBaseOwn, ICefResourceHandler)
  protected
    function ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean; virtual;
    procedure GetResponseHeaders(const response: ICefResponse;
      out responseLength: Int64; out redirectUrl: ustring); virtual;
    function ReadResponse(const dataOut: Pointer; bytesToRead: Integer;
      var bytesRead: Integer; const callback: ICefCallback): Boolean; virtual;
    function CanGetCookie(const cookie: PCefCookie): Boolean; virtual;
    function CanSetCookie(const cookie: PCefCookie): Boolean; virtual;
    procedure Cancel; virtual;
  public
    constructor Create(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest); virtual;
  end;
  TCefResourceHandlerClass = class of TCefResourceHandlerOwn;

  TCefSchemeHandlerFactoryOwn = class(TCefBaseOwn, ICefSchemeHandlerFactory)
  private
    FClass: TCefResourceHandlerClass;
  protected
    function New(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest): ICefResourceHandler; virtual;
  public
    constructor Create(const AClass: TCefResourceHandlerClass); virtual;
  end;

  TCefv8HandlerOwn = class(TCefBaseOwn, ICefv8Handler)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefTaskOwn = class(TCefBaseOwn, ICefTask)
  protected
    procedure Execute; virtual;
  public
    constructor Create; virtual;
  end;

  TCefTaskRef = class(TCefBaseRef, ICefTask)
  protected
    procedure Execute; virtual;
  public
    class function UnWrap(data: Pointer): ICefTask;
  end;

  TCefTaskRunnerRef = class(TCefBaseRef, ICefTaskRunner)
  protected
    function IsSame(const that: ICefTaskRunner): Boolean;
    function BelongsToCurrentThread: Boolean;
    function BelongsToThread(threadId: TCefThreadId): Boolean;
    function PostTask(const task: ICefTask): Boolean; stdcall;
    function PostDelayedTask(const task: ICefTask; delayMs: Int64): Boolean;
  public
    class function UnWrap(data: Pointer): ICefTaskRunner;
    class function GetForCurrentThread: ICefTaskRunner;
    class function GetForThread(threadId: TCefThreadId): ICefTaskRunner;
  end;

  TCefStringMapOwn = class(TInterfacedObject, ICefStringMap)
  private
    FStringMap: TCefStringMap;
  protected
    function GetHandle: TCefStringMap; virtual;
    function GetSize: Integer; virtual;
    function Find(const key: ustring): ustring; virtual;
    function GetKey(index: Integer): ustring; virtual;
    function GetValue(index: Integer): ustring; virtual;
    procedure Append(const key, value: ustring); virtual;
    procedure Clear; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCefStringMultimapOwn = class(TInterfacedObject, ICefStringMultimap)
  private
    FStringMap: TCefStringMultimap;
  protected
    function GetHandle: TCefStringMultimap; virtual;
    function GetSize: Integer; virtual;
    function FindCount(const Key: ustring): Integer; virtual;
    function GetEnumerate(const Key: ustring; ValueIndex: Integer): ustring; virtual;
    function GetKey(Index: Integer): ustring; virtual;
    function GetValue(Index: Integer): ustring; virtual;
    procedure Append(const Key, Value: ustring); virtual;
    procedure Clear; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCefXmlReaderRef = class(TCefBaseRef, ICefXmlReader)
  protected
    function MoveToNextNode: Boolean;
    function Close: Boolean;
    function HasError: Boolean;
    function GetError: ustring;
    function GetType: TCefXmlNodeType;
    function GetDepth: Integer;
    function GetLocalName: ustring;
    function GetPrefix: ustring;
    function GetQualifiedName: ustring;
    function GetNamespaceUri: ustring;
    function GetBaseUri: ustring;
    function GetXmlLang: ustring;
    function IsEmptyElement: Boolean;
    function HasValue: Boolean;
    function GetValue: ustring;
    function HasAttributes: Boolean;
    function GetAttributeCount: NativeUInt;
    function GetAttributeByIndex(index: Integer): ustring;
    function GetAttributeByQName(const qualifiedName: ustring): ustring;
    function GetAttributeByLName(const localName, namespaceURI: ustring): ustring;
    function GetInnerXml: ustring;
    function GetOuterXml: ustring;
    function GetLineNumber: Integer;
    function MoveToAttributeByIndex(index: Integer): Boolean;
    function MoveToAttributeByQName(const qualifiedName: ustring): Boolean;
    function MoveToAttributeByLName(const localName, namespaceURI: ustring): Boolean;
    function MoveToFirstAttribute: Boolean;
    function MoveToNextAttribute: Boolean;
    function MoveToCarryingElement: Boolean;
  public
    class function UnWrap(data: Pointer): ICefXmlReader;
    class function New(const stream: ICefStreamReader;
      encodingType: TCefXmlEncodingType; const URI: ustring): ICefXmlReader;
  end;

  TCefZipReaderRef = class(TCefBaseRef, ICefZipReader)
  protected
    function MoveToFirstFile: Boolean;
    function MoveToNextFile: Boolean;
    function MoveToFile(const fileName: ustring; caseSensitive: Boolean): Boolean;
    function Close: Boolean;
    function GetFileName: ustring;
    function GetFileSize: Int64;
    function GetFileLastModified: TCefTime;
    function OpenFile(const password: ustring): Boolean;
    function CloseFile: Boolean;
    function ReadFile(buffer: Pointer; bufferSize: NativeUInt): Integer;
    function Tell: Int64;
    function Eof: Boolean;
  public
    class function UnWrap(data: Pointer): ICefZipReader;
    class function New(const stream: ICefStreamReader): ICefZipReader;
  end;

  TCefDomVisitorOwn = class(TCefBaseOwn, ICefDomVisitor)
  protected
    procedure visit(const document: ICefDomDocument); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastDomVisitor = class(TCefDomVisitorOwn)
  private
    FProc: TCefDomVisitorProc;
  protected
    procedure visit(const document: ICefDomDocument); override;
  public
    constructor Create(const proc: TCefDomVisitorProc); reintroduce; virtual;
  end;

  TCefDomDocumentRef = class(TCefBaseRef, ICefDomDocument)
  protected
    function GetType: TCefDomDocumentType;
    function GetDocument: ICefDomNode;
    function GetBody: ICefDomNode;
    function GetHead: ICefDomNode;
    function GetTitle: ustring;
    function GetElementById(const id: ustring): ICefDomNode;
    function GetFocusedNode: ICefDomNode;
    function HasSelection: Boolean;
    function GetSelectionStartOffset: Integer;
    function GetSelectionEndOffset: Integer;
    function GetSelectionAsMarkup: ustring;
    function GetSelectionAsText: ustring;
    function GetBaseUrl: ustring;
    function GetCompleteUrl(const partialURL: ustring): ustring;
  public
    class function UnWrap(data: Pointer): ICefDomDocument;
  end;

  TCefDomNodeRef = class(TCefBaseRef, ICefDomNode)
  protected
    function GetType: TCefDomNodeType;
    function IsText: Boolean;
    function IsElement: Boolean;
    function IsEditable: Boolean;
    function IsFormControlElement: Boolean;
    function GetFormControlElementType: ustring;
    function IsSame(const that: ICefDomNode): Boolean;
    function GetName: ustring;
    function GetValue: ustring;
    function SetValue(const value: ustring): Boolean;
    function GetAsMarkup: ustring;
    function GetDocument: ICefDomDocument;
    function GetParent: ICefDomNode;
    function GetPreviousSibling: ICefDomNode;
    function GetNextSibling: ICefDomNode;
    function HasChildren: Boolean;
    function GetFirstChild: ICefDomNode;
    function GetLastChild: ICefDomNode;
    function GetElementTagName: ustring;
    function HasElementAttributes: Boolean;
    function HasElementAttribute(const attrName: ustring): Boolean;
    function GetElementAttribute(const attrName: ustring): ustring;
    procedure GetElementAttributes(const attrMap: ICefStringMap);
    function SetElementAttribute(const attrName, value: ustring): Boolean;
    function GetElementInnerText: ustring;
  public
    class function UnWrap(data: Pointer): ICefDomNode;
  end;

  TCefResponseRef = class(TCefBaseRef, ICefResponse)
  protected
    function IsReadOnly: Boolean;
    function GetStatus: Integer;
    procedure SetStatus(status: Integer);
    function GetStatusText: ustring;
    procedure SetStatusText(const StatusText: ustring);
    function GetMimeType: ustring;
    procedure SetMimeType(const mimetype: ustring);
    function GetHeader(const name: ustring): ustring;
    procedure GetHeaderMap(const headerMap: ICefStringMultimap);
    procedure SetHeaderMap(const headerMap: ICefStringMultimap);
  public
    class function UnWrap(data: Pointer): ICefResponse;
    class function New: ICefResponse;
  end;

  TCefFastTaskProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure;

  TCefFastTask = class(TCefTaskOwn)
  private
    FMethod: TCefFastTaskProc;
  protected
    procedure Execute; override;
  public
    class procedure New(threadId: TCefThreadId; const method: TCefFastTaskProc);
    class procedure NewDelayed(threadId: TCefThreadId; Delay: Int64; const method: TCefFastTaskProc);
    constructor Create(const method: TCefFastTaskProc); reintroduce;
  end;

{$IFDEF DELPHI14_UP}
  TCefRTTIExtension = class(TCefv8HandlerOwn)
  private
    FValue: TValue;
    FCtx: TRttiContext;
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    FSyncMainThread: Boolean;
{$ENDIF}
    function GetValue(pi: PTypeInfo; const v: ICefv8Value; var ret: TValue): Boolean;
    function SetValue(const v: TValue; var ret: ICefv8Value): Boolean;
{$IFDEF CPUX64}
    class function StrToPtr(const str: ustring): Pointer;
    class function PtrToStr(p: Pointer): ustring;
{$ENDIF}
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
      const arguments: TCefv8ValueArray; var retval: ICefv8Value;
      var exception: ustring): Boolean; override;
  public
    constructor Create(const value: TValue
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    ; SyncMainThread: Boolean
{$ENDIF}
); reintroduce;
    destructor Destroy; override;
    class procedure Register(const name: string; const value: TValue
      {$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}; SyncMainThread: Boolean{$ENDIF});
  end;
{$ENDIF}

  TCefV8AccessorOwn = class(TCefBaseOwn, ICefV8Accessor)
  protected
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean; virtual;
    function Put(const name: ustring; const obj, value: ICefv8Value;
      const exception: ustring): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastV8Accessor = class(TCefV8AccessorOwn)
  private
    FGetter: TCefV8AccessorGetterProc;
    FSetter: TCefV8AccessorSetterProc;
  protected
    function Get(const name: ustring; const obj: ICefv8Value;
      out value: ICefv8Value; const exception: ustring): Boolean; override;
    function Put(const name: ustring; const obj, value: ICefv8Value;
      const exception: ustring): Boolean; override;
  public
    constructor Create(const getter: TCefV8AccessorGetterProc;
      const setter: TCefV8AccessorSetterProc); reintroduce;
  end;

  TCefCookieVisitorOwn = class(TCefBaseOwn, ICefCookieVisitor)
  protected
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastCookieVisitor = class(TCefCookieVisitorOwn)
  private
    FVisitor: TCefCookieVisitorProc;
  protected
    function visit(const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      count, total: Integer; out deleteCookie: Boolean): Boolean; override;
  public
    constructor Create(const visitor: TCefCookieVisitorProc); reintroduce;
  end;

  TCefV8ExceptionRef = class(TCefBaseRef, ICefV8Exception)
  protected
    function GetMessage: ustring;
    function GetSourceLine: ustring;
    function GetScriptResourceName: ustring;
    function GetLineNumber: Integer;
    function GetStartPosition: Integer;
    function GetEndPosition: Integer;
    function GetStartColumn: Integer;
    function GetEndColumn: Integer;
  public
    class function UnWrap(data: Pointer): ICefV8Exception;
  end;

  TCefResourceBundleHandlerOwn = class(TCefBaseOwn, ICefResourceBundleHandler)
  protected
    function GetDataResource(stringId: Integer; out data: Pointer;
      out dataSize: NativeUInt): Boolean; virtual; abstract;
    function GetLocalizedString(messageId: Integer;
      out stringVal: ustring): Boolean; virtual; abstract;
    function GetDataResourceForScale(resourceId: Integer;
      scaleFactor: TCefScaleFactor; out data: Pointer;
      dataSize: NativeUInt): Boolean; virtual; abstract;
  public
    constructor Create; virtual;
  end;

 TGetDataResource = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   resourceId: Integer; out data: Pointer; out dataSize: NativeUInt): Boolean;

 TGetLocalizedString = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   stringId: Integer; out stringVal: ustring): Boolean;

 TGetDataResourceForScale = {$IFDEF DELPHI12_UP}reference to{$ENDIF}function(
   resourceId: Integer; scaleFactor: TCefScaleFactor; out data: Pointer;
   out dataSize: NativeUInt): Boolean;

  TCefFastResourceBundle = class(TCefResourceBundleHandlerOwn)
  private
    FGetDataResource: TGetDataResource;
    FGetLocalizedString: TGetLocalizedString;
    FGetDataResourceForScale: TGetDataResourceForScale;
  protected
    function GetDataResource(resourceId: Integer; out data: Pointer;
      out dataSize: NativeUInt): Boolean; override;
    function GetLocalizedString(stringId: Integer;
      out stringVal: ustring): Boolean; override;
    function GetDataResourceForScale(resourceId: Integer;
      scaleFactor: TCefScaleFactor; out data: Pointer;
      dataSize: NativeUInt): Boolean; override;
  public
    constructor Create(
      AGetDataResource: TGetDataResource;
      AGetLocalizedString: TGetLocalizedString;
      AGetDataResourceForScale: TGetDataResourceForScale); reintroduce;
  end;

  TCefAppOwn = class(TCefBaseOwn, ICefApp)
  protected
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine); virtual; abstract;
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar); virtual; abstract;
    function GetResourceBundleHandler: ICefResourceBundleHandler; virtual; abstract;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler; virtual; abstract;
    function GetRenderProcessHandler: ICefRenderProcessHandler; virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefSetCookieCallbackOwn = class(TCefBaseOwn, ICefSetCookieCallback)
  protected
    procedure OnComplete(success: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastSetCookieCallback = class(TCefSetCookieCallbackOwn)
  private
    FCallback: TCefSetCookieCallbackProc;
  protected
    procedure OnComplete(success: Boolean); override;
  public
    constructor Create(const callback: TCefSetCookieCallbackProc); reintroduce;
  end;

  TCefDeleteCookiesCallbackOwn = class(TCefBaseOwn, ICefDeleteCookiesCallback)
  protected
    procedure OnComplete(numDeleted: Integer); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastDeleteCookiesCallback = class(TCefDeleteCookiesCallbackOwn)
  private
    FCallback: TCefDeleteCookiesCallbackProc;
  protected
    procedure OnComplete(numDeleted: Integer); override;
  public
    constructor Create(const callback: TCefDeleteCookiesCallbackProc); reintroduce;
  end;

  TCefCookieManagerRef = class(TCefBaseRef, ICefCookieManager)
  protected
    procedure SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
    procedure SetSupportedSchemesProc(schemes: TStrings; const callback: TCefCompletionCallbackProc);
    function VisitAllCookies(const visitor: ICefCookieVisitor): Boolean;
    function VisitAllCookiesProc(const visitor: TCefCookieVisitorProc): Boolean;
    function VisitUrlCookies(const url: ustring;
      includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
    function VisitUrlCookiesProc(const url: ustring;
      includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
    function SetCookie(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: ICefSetCookieCallback): Boolean;
    function SetCookieProc(const url: ustring; const name, value, domain, path: ustring; secure, httponly,
      hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
      const callback: TCefSetCookieCallbackProc): Boolean;
    function DeleteCookies(const url, cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
    function DeleteCookiesProc(const url, cookieName: ustring; const callback: TCefDeleteCookiesCallbackProc): Boolean;
    function SetStoragePath(const path: ustring; persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
    function SetStoragePathProc(const path: ustring; persistSessionCookies: Boolean; const callback: TCefCompletionCallbackProc): Boolean;
    function FlushStore(const handler: ICefCompletionCallback): Boolean;
    function FlushStoreProc(const proc: TCefCompletionCallbackProc): Boolean;
  public
    class function UnWrap(data: Pointer): ICefCookieManager;
    class function Global(const callback: ICefCompletionCallback): ICefCookieManager;
    class function GlobalProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    class function New(const path: ustring; persistSessionCookies: Boolean;
      const callback: ICefCompletionCallback): ICefCookieManager;
    class function NewProc(const path: ustring; persistSessionCookies: Boolean;
      const callback: TCefCompletionCallbackProc): ICefCookieManager;
  end;

  TCefWebPluginInfoRef = class(TCefBaseRef, ICefWebPluginInfo)
  protected
    function GetName: ustring;
    function GetPath: ustring;
    function GetVersion: ustring;
    function GetDescription: ustring;
  public
    class function UnWrap(data: Pointer): ICefWebPluginInfo;
  end;

  TCefProcessMessageRef = class(TCefBaseRef, ICefProcessMessage)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefProcessMessage;
    function GetName: ustring;
    function GetArgumentList: ICefListValue;
  public
    class function UnWrap(data: Pointer): ICefProcessMessage;
    class function New(const name: ustring): ICefProcessMessage;
  end;

  TCefStringVisitorOwn = class(TCefBaseOwn, ICefStringVisitor)
  protected
    procedure Visit(const str: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastStringVisitor = class(TCefStringVisitorOwn, ICefStringVisitor)
  private
    FVisit: TCefStringVisitorProc;
  protected
    procedure Visit(const str: ustring); override;
  public
    constructor Create(const callback: TCefStringVisitorProc); reintroduce;
  end;

  TCefDownLoadItemRef = class(TCefBaseRef, ICefDownLoadItem)
  protected
    function IsValid: Boolean;
    function IsInProgress: Boolean;
    function IsComplete: Boolean;
    function IsCanceled: Boolean;
    function GetCurrentSpeed: Int64;
    function GetPercentComplete: Integer;
    function GetTotalBytes: Int64;
    function GetReceivedBytes: Int64;
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
    function GetFullPath: ustring;
    function GetId: Cardinal;
    function GetUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetSuggestedFileName: ustring;
    function GetContentDisposition: ustring;
    function GetMimeType: ustring;
  public
    class function UnWrap(data: Pointer): ICefDownLoadItem;
  end;

  TCefBeforeDownloadCallbackRef = class(TCefBaseRef, ICefBeforeDownloadCallback)
  protected
    procedure Cont(const downloadPath: ustring; showDialog: Boolean);
  public
     class function UnWrap(data: Pointer): ICefBeforeDownloadCallback;
  end;

  TCefDownloadItemCallbackRef = class(TCefBaseRef, ICefDownloadItemCallback)
  protected
    procedure Cancel;
    procedure Pause;
    procedure Resume;
  public
    class function UnWrap(data: Pointer): ICefDownloadItemCallback;
  end;

  TCefAuthCallbackRef = class(TCefBaseRef, ICefAuthCallback)
  protected
    procedure Cont(const username, password: ustring);
    procedure Cancel;
  public
     class function UnWrap(data: Pointer): ICefAuthCallback;
  end;

  TCefJsDialogCallbackRef = class(TCefBaseRef, ICefJsDialogCallback)
  protected
    procedure Cont(success: Boolean; const userInput: ustring);
  public
    class function UnWrap(data: Pointer): ICefJsDialogCallback;
  end;

  TCefCommandLineRef = class(TCefBaseRef, ICefCommandLine)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefCommandLine;
    procedure InitFromArgv(argc: Integer; const argv: PPAnsiChar);
    procedure InitFromString(const commandLine: ustring);
    procedure Reset;
    function GetCommandLineString: ustring;
    procedure GetArgv(args: TStrings);
    function GetProgram: ustring;
    procedure SetProgram(const prog: ustring);
    function HasSwitches: Boolean;
    function HasSwitch(const name: ustring): Boolean;
    function GetSwitchValue(const name: ustring): ustring;
    procedure GetSwitches(switches: TStrings);
    procedure AppendSwitch(const name: ustring);
    procedure AppendSwitchWithValue(const name, value: ustring);
    function HasArguments: Boolean;
    procedure GetArguments(arguments: TStrings);
    procedure AppendArgument(const argument: ustring);
    procedure PrependWrapper(const wrapper: ustring);
  public
    class function UnWrap(data: Pointer): ICefCommandLine;
    class function New: ICefCommandLine;
    class function Global: ICefCommandLine;
  end;

  TCefSchemeRegistrarRef = class(TCefBaseRef, ICefSchemeRegistrar)
  protected
    function AddCustomScheme(const schemeName: ustring; IsStandard, IsLocal,
      IsDisplayIsolated: Boolean): Boolean; stdcall;
  public
    class function UnWrap(data: Pointer): ICefSchemeRegistrar;
  end;

  TCefGeolocationCallbackRef = class(TCefBaseRef, ICefGeolocationCallback)
  protected
    procedure Cont(allow: Boolean);
  public
    class function UnWrap(data: Pointer): ICefGeolocationCallback;
  end;

  TCefContextMenuParamsRef = class(TCefBaseRef, ICefContextMenuParams)
  protected
    function GetXCoord: Integer;
    function GetYCoord: Integer;
    function GetTypeFlags: TCefContextMenuTypeFlags;
    function GetLinkUrl: ustring;
    function GetUnfilteredLinkUrl: ustring;
    function GetSourceUrl: ustring;
    function HasImageContents: Boolean;
    function GetPageUrl: ustring;
    function GetFrameUrl: ustring;
    function GetFrameCharset: ustring;
    function GetMediaType: TCefContextMenuMediaType;
    function GetMediaStateFlags: TCefContextMenuMediaStateFlags;
    function GetSelectionText: ustring;
    function GetMisspelledWord: ustring;
    function GetDictionarySuggestions(const suggestions: TStringList): Boolean;
    function IsEditable: Boolean;
    function IsSpellCheckEnabled: Boolean;
    function GetEditStateFlags: TCefContextMenuEditStateFlags;
    function IsCustomMenu: Boolean;
    function IsPepperMenu: Boolean;
  public
    class function UnWrap(data: Pointer): ICefContextMenuParams;
  end;

  TCefMenuModelRef = class(TCefBaseRef, ICefMenuModel)
  protected
    function Clear: Boolean;
    function GetCount: Integer;
    function AddSeparator: Boolean;
    function AddItem(commandId: Integer; const text: ustring): Boolean;
    function AddCheckItem(commandId: Integer; const text: ustring): Boolean;
    function AddRadioItem(commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function AddSubMenu(commandId: Integer; const text: ustring): ICefMenuModel;
    function InsertSeparatorAt(index: Integer): Boolean;
    function InsertItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertCheckItemAt(index, commandId: Integer; const text: ustring): Boolean;
    function InsertRadioItemAt(index, commandId: Integer; const text: ustring; groupId: Integer): Boolean;
    function InsertSubMenuAt(index, commandId: Integer; const text: ustring): ICefMenuModel;
    function Remove(commandId: Integer): Boolean;
    function RemoveAt(index: Integer): Boolean;
    function GetIndexOf(commandId: Integer): Integer;
    function GetCommandIdAt(index: Integer): Integer;
    function SetCommandIdAt(index, commandId: Integer): Boolean;
    function GetLabel(commandId: Integer): ustring;
    function GetLabelAt(index: Integer): ustring;
    function SetLabel(commandId: Integer; const text: ustring): Boolean;
    function SetLabelAt(index: Integer; const text: ustring): Boolean;
    function GetType(commandId: Integer): TCefMenuItemType;
    function GetTypeAt(index: Integer): TCefMenuItemType;
    function GetGroupId(commandId: Integer): Integer;
    function GetGroupIdAt(index: Integer): Integer;
    function SetGroupId(commandId, groupId: Integer): Boolean;
    function SetGroupIdAt(index, groupId: Integer): Boolean;
    function GetSubMenu(commandId: Integer): ICefMenuModel;
    function GetSubMenuAt(index: Integer): ICefMenuModel;
    function IsVisible(commandId: Integer): Boolean;
    function isVisibleAt(index: Integer): Boolean;
    function SetVisible(commandId: Integer; visible: Boolean): Boolean;
    function SetVisibleAt(index: Integer; visible: Boolean): Boolean;
    function IsEnabled(commandId: Integer): Boolean;
    function IsEnabledAt(index: Integer): Boolean;
    function SetEnabled(commandId: Integer; enabled: Boolean): Boolean;
    function SetEnabledAt(index: Integer; enabled: Boolean): Boolean;
    function IsChecked(commandId: Integer): Boolean;
    function IsCheckedAt(index: Integer): Boolean;
    function setChecked(commandId: Integer; checked: Boolean): Boolean;
    function setCheckedAt(index: Integer; checked: Boolean): Boolean;
    function HasAccelerator(commandId: Integer): Boolean;
    function HasAcceleratorAt(index: Integer): Boolean;
    function SetAccelerator(commandId, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function SetAcceleratorAt(index, keyCode: Integer; shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function RemoveAccelerator(commandId: Integer): Boolean;
    function RemoveAcceleratorAt(index: Integer): Boolean;
    function GetAccelerator(commandId: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
    function GetAcceleratorAt(index: Integer; out keyCode: Integer; out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
  public
    class function UnWrap(data: Pointer): ICefMenuModel;
  end;

  TCefListValueRef = class(TCefBaseRef, ICefListValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefListValue): Boolean;
    function IsEqual(const that: ICefListValue): Boolean;
    function Copy: ICefListValue;
    function SetSize(size: NativeUInt): Boolean;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function Remove(index: Integer): Boolean;
    function GetType(index: Integer): TCefValueType;
    function GetValue(index: Integer): ICefValue;
    function GetBool(index: Integer): Boolean;
    function GetInt(index: Integer): Integer;
    function GetDouble(index: Integer): Double;
    function GetString(index: Integer): ustring;
    function GetBinary(index: Integer): ICefBinaryValue;
    function GetDictionary(index: Integer): ICefDictionaryValue;
    function GetList(index: Integer): ICefListValue;
    function SetValue(index: Integer; const value: ICefValue): Boolean;
    function SetNull(index: Integer): Boolean;
    function SetBool(index: Integer; value: Boolean): Boolean;
    function SetInt(index, value: Integer): Boolean;
    function SetDouble(index: Integer; value: Double): Boolean;
    function SetString(index: Integer; const value: ustring): Boolean;
    function SetBinary(index: Integer; const value: ICefBinaryValue): Boolean;
    function SetDictionary(index: Integer; const value: ICefDictionaryValue): Boolean;
    function SetList(index: Integer; const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefListValue;
    class function New: ICefListValue;
  end;

  TCefValueRef = class(TCefBaseRef, ICefValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefValue): Boolean;
    function IsEqual(const that: ICefValue): Boolean;
    function Copy: ICefValue;
    function GetType: TCefValueType;
    function GetBool: Boolean;
    function GetInt: Integer;
    function GetDouble: Double;
    function GetString: ustring;
    function GetBinary: ICefBinaryValue;
    function GetDictionary: ICefDictionaryValue;
    function GetList: ICefListValue;
    function SetNull: Boolean;
    function SetBool(value: Integer): Boolean;
    function SetInt(value: Integer): Boolean;
    function SetDouble(value: Double): Boolean;
    function SetString(const value: ustring): Boolean;
    function SetBinary(const value: ICefBinaryValue): Boolean;
    function SetDictionary(const value: ICefDictionaryValue): Boolean;
    function SetList(const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefValue;
    class function New: ICefValue;
  end;

  TCefBinaryValueRef = class(TCefBaseRef, ICefBinaryValue)
  protected
    function IsValid: Boolean;
    function IsOwned: Boolean;
    function IsSame(const that: ICefBinaryValue): Boolean;
    function IsEqual(const that: ICefBinaryValue): Boolean;
    function Copy: ICefBinaryValue;
    function GetSize: NativeUInt;
    function GetData(buffer: Pointer; bufferSize, dataOffset: NativeUInt): NativeUInt;
  public
    class function UnWrap(data: Pointer): ICefBinaryValue;
    class function New(const data: Pointer; dataSize: NativeUInt): ICefBinaryValue;
  end;

  TCefDictionaryValueRef = class(TCefBaseRef, ICefDictionaryValue)
  protected
    function IsValid: Boolean;
    function isOwned: Boolean;
    function IsReadOnly: Boolean;
    function IsSame(const that: ICefDictionaryValue): Boolean;
    function IsEqual(const that: ICefDictionaryValue): Boolean;
    function Copy(excludeEmptyChildren: Boolean): ICefDictionaryValue;
    function GetSize: NativeUInt;
    function Clear: Boolean;
    function HasKey(const key: ustring): Boolean;
    function GetKeys(const keys: TStrings): Boolean;
    function Remove(const key: ustring): Boolean;
    function GetType(const key: ustring): TCefValueType;
    function GetValue(const key: ustring): ICefValue;
    function GetBool(const key: ustring): Boolean;
    function GetInt(const key: ustring): Integer;
    function GetDouble(const key: ustring): Double;
    function GetString(const key: ustring): ustring;
    function GetBinary(const key: ustring): ICefBinaryValue;
    function GetDictionary(const key: ustring): ICefDictionaryValue;
    function GetList(const key: ustring): ICefListValue;
    function SetValue(const key: ustring; const value: ICefValue): Boolean;
    function SetNull(const key: ustring): Boolean;
    function SetBool(const key: ustring; value: Boolean): Boolean;
    function SetInt(const key: ustring; value: Integer): Boolean;
    function SetDouble(const key: ustring; value: Double): Boolean;
    function SetString(const key, value: ustring): Boolean;
    function SetBinary(const key: ustring; const value: ICefBinaryValue): Boolean;
    function SetDictionary(const key: ustring; const value: ICefDictionaryValue): Boolean;
    function SetList(const key: ustring; const value: ICefListValue): Boolean;
  public
    class function UnWrap(data: Pointer): ICefDictionaryValue;
    class function New: ICefDictionaryValue;
  end;

  TCefBrowserProcessHandlerOwn = class(TCefBaseOwn, ICefBrowserProcessHandler)
  protected
    procedure OnContextInitialized; virtual;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine); virtual;
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue); virtual;
  public
    constructor Create; virtual;
  end;


  TCefRenderProcessHandlerOwn = class(TCefBaseOwn, ICefRenderProcessHandler)
  protected
    procedure OnRenderThreadCreated(const extraInfo: ICefListValue); virtual;
    procedure OnWebKitInitialized; virtual;
    procedure OnBrowserCreated(const browser: ICefBrowser); virtual;
    procedure OnBrowserDestroyed(const browser: ICefBrowser); virtual;
    function GetLoadHandler: PCefLoadHandler; virtual;
    function OnBeforeNavigation(const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; navigationType: TCefNavigationType;
      isRedirect: Boolean): Boolean; virtual;
    procedure OnContextCreated(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context); virtual;
    procedure OnContextReleased(const browser: ICefBrowser;
      const frame: ICefFrame; const context: ICefv8Context); virtual;
    procedure OnUncaughtException(const browser: ICefBrowser; const frame: ICefFrame;
      const context: ICefv8Context; const exception: ICefV8Exception;
      const stackTrace: ICefV8StackTrace); virtual;
    procedure OnFocusedNodeChanged(const browser: ICefBrowser;
      const frame: ICefFrame; const node: ICefDomNode); virtual;
    function OnProcessMessageReceived(const browser: ICefBrowser;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;
  public
    constructor Create; virtual;
  end;


  TCefUrlrequestClientOwn = class(TCefBaseOwn, ICefUrlrequestClient)
  protected
    procedure OnRequestComplete(const request: ICefUrlRequest); virtual;
    procedure OnUploadProgress(const request: ICefUrlRequest; current, total: Int64); virtual;
    procedure OnDownloadProgress(const request: ICefUrlRequest; current, total: Int64); virtual;
    procedure OnDownloadData(const request: ICefUrlRequest; data: Pointer; dataLength: NativeUInt); virtual;
    function OnGetAuthCredentials(isProxy: Boolean; const host: ustring; port: Integer;
      const realm, scheme: ustring; const callback: ICefAuthCallback): Boolean;
  public
    constructor Create; virtual;
  end;

  TCefUrlRequestRef = class(TCefBaseRef, ICefUrlRequest)
  protected
    function GetRequest: ICefRequest;
    function GetRequestStatus: TCefUrlRequestStatus;
    function GetRequestError: Integer;
    function GetResponse: ICefResponse;
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefUrlRequest;
    class function New(const request: ICefRequest; const client: ICefUrlRequestClient;
      const requestContext: ICefRequestContext): ICefUrlRequest;
  end;

  TCefWebPluginInfoVisitorOwn = class(TCefBaseOwn, ICefWebPluginInfoVisitor)
  protected
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefWebPluginInfoVisitorProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} function(const info: ICefWebPluginInfo; count, total: Integer): Boolean;
  TCefWebPluginIsUnstableProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF}procedure(const path: ustring; unstable: Boolean);

  TCefFastWebPluginInfoVisitor = class(TCefWebPluginInfoVisitorOwn)
  private
    FProc: TCefWebPluginInfoVisitorProc;
  protected
    function Visit(const info: ICefWebPluginInfo; count, total: Integer): Boolean; override;
  public
    constructor Create(const proc: TCefWebPluginInfoVisitorProc); reintroduce;
  end;

  TCefWebPluginUnstableCallbackOwn = class(TCefBaseOwn, ICefWebPluginUnstableCallback)
  protected
    procedure IsUnstable(const path: ustring; unstable: Boolean); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFastWebPluginUnstableCallback = class(TCefWebPluginUnstableCallbackOwn)
  private
    FCallback: TCefWebPluginIsUnstableProc;
  protected
    procedure IsUnstable(const path: ustring; unstable: Boolean); override;
  public
    constructor Create(const callback: TCefWebPluginIsUnstableProc); reintroduce;
  end;

  TCefEndTracingCallbackOwn = class(TCefBaseOwn, ICefEndTracingCallback)
  protected
    procedure OnEndTracingComplete(const tracingFile: ustring); virtual;
  public
    constructor Create; virtual;
  end;

  TCefGetGeolocationCallbackOwn = class(TCefBaseOwn, ICefGetGeolocationCallback)
  protected
    procedure OnLocationUpdate(const position: PCefGeoposition); virtual;
  public
    constructor Create; virtual;
  end;

  TOnLocationUpdate = {$IFDEF DELPHI12_UP}reference to{$ENDIF} procedure(const position: PCefGeoposition);

  TCefFastGetGeolocationCallback = class(TCefGetGeolocationCallbackOwn)
  private
    FCallback: TOnLocationUpdate;
  protected
    procedure OnLocationUpdate(const position: PCefGeoposition); override;
  public
    constructor Create(const callback: TOnLocationUpdate); reintroduce;
  end;

  TCefFileDialogCallbackRef = class(TCefBaseRef, ICefFileDialogCallback)
  protected
    procedure Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefFileDialogCallback;
  end;

  TCefRenderHandlerOwn = class(TCefBaseOwn, ICefRenderHandler)
  protected
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean; virtual;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean; virtual;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean; virtual;
    function GetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean; virtual;
    procedure OnPopupShow(const browser: ICefBrowser; show: Boolean); virtual;
    procedure OnPopupSize(const browser: ICefBrowser; const rect: PCefRect); virtual;
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer); virtual;
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      CursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo); virtual;
    function OnStartDragging(const browser: ICefBrowser; const dragData: ICefDragData;
      allowedOps: TCefDragOperations; x, y: Integer): Boolean; virtual;
    procedure OnUpdateDragCursor(const browser: ICefBrowser;
      operation: TCefDragOperation); virtual;
    procedure OnScrollOffsetChanged(const browser: ICefBrowser; x, y: Double); virtual;
  public
    constructor Create; virtual;
  end;

  TCefDragDataRef = class(TCefBaseRef, ICefDragData)
  protected
    function Clone: ICefDragData;
    function IsReadOnly: Boolean;
    function IsLink: Boolean;
    function IsFragment: Boolean;
    function IsFile: Boolean;
    function GetLinkUrl: ustring;
    function GetLinkTitle: ustring;
    function GetLinkMetadata: ustring;
    function GetFragmentText: ustring;
    function GetFragmentHtml: ustring;
    function GetFragmentBaseUrl: ustring;
    function GetFileName: ustring;
    function GetFileContents(const writer: ICefStreamWriter): NativeUInt;
    function GetFileNames(names: TStrings): Integer;
    procedure SetLinkUrl(const url: ustring);
    procedure SetLinkTitle(const title: ustring);
    procedure SetLinkMetadata(const data: ustring);
    procedure SetFragmentText(const text: ustring);
    procedure SetFragmentHtml(const html: ustring);
    procedure SetFragmentBaseUrl(const baseUrl: ustring);
    procedure ResetFileContents;
    procedure AddFile(const path, displayName: ustring);
  public
    class function UnWrap(data: Pointer): ICefDragData;
    class function New: ICefDragData;
  end;

  TCefDragHandlerOwn = class(TCefBaseOwn, ICefDragHandler)
  protected
    function OnDragEnter(const browser: ICefBrowser; const dragData: ICefDragData;
      mask: TCefDragOperations): Boolean; virtual;
    procedure OnDraggableRegionsChanged(const browser: ICefBrowser;
      regionsCount: NativeUInt; regions: PCefDraggableRegionArray); virtual;
  public
    constructor Create; virtual;
  end;

  TCefFindHandlerOwn = class(TCefBaseOwn, ICefFindHandler)
  protected
    procedure OnFindResult(const browser: ICefBrowser;
      identifier, count: Integer; const selectionRect: PCefRect;
      activeMatchOrdinal: Integer; finalUpdate: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefRequestContextRef = class(TCefBaseRef, ICefRequestContext)
  protected
    function IsSame(const other: ICefRequestContext): Boolean;
    function IsSharingWith(const other: ICefRequestContext): Boolean;
    function IsGlobal: Boolean;
    function GetHandler: ICefRequestContextHandler;
    function GetCachePath: ustring;
    function GetDefaultCookieManager(const callback: ICefCompletionCallback): ICefCookieManager;
    function GetDefaultCookieManagerProc(const callback: TCefCompletionCallbackProc): ICefCookieManager;
    function RegisterSchemeHandlerFactory(const schemeName, domainName: ustring;
        const factory: ICefSchemeHandlerFactory): Boolean;
    function ClearSchemeHandlerFactories: Boolean;
    procedure PurgePluginListCache(reloadPages: Boolean);
  public
    class function UnWrap(data: Pointer): ICefRequestContext;
    class function Global: ICefRequestContext;
    class function New(const settings: PCefRequestContextSettings;
      const handler: ICefRequestContextHandler): ICefRequestContext;
    class function Shared(const other: ICefRequestContext;
      const handler: ICefRequestContextHandler): ICefRequestContext;
  end;

  TCefRequestContextHandlerRef = class(TCefBaseRef, ICefRequestContextHandler)
  protected
    function GetCookieManager: ICefCookieManager;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean;
  public
    class function UnWrap(data: Pointer): ICefRequestContextHandler;
  end;

  TCefRequestContextHandlerOwn = class(TCefBaseOwn, ICefRequestContextHandler)
  protected
    function GetCookieManager: ICefCookieManager; virtual;
    function OnBeforePluginLoad(const mimeType, pluginUrl, topOriginUrl: ustring;
      const pluginInfo: ICefWebPluginInfo; pluginPolicy: PCefPluginPolicy): Boolean; virtual;
  public
    constructor Create; virtual;
  end;

  TCefRequestContextHandlerProc = {$IFDEF DELPHI12_UP}reference to{$ENDIF} function: ICefCookieManager;

  TCefFastRequestContextHandler = class(TCefRequestContextHandlerOwn)
  private
    FProc: TCefRequestContextHandlerProc;
  protected
    function GetCookieManager: ICefCookieManager; override;
  public
    constructor Create(const proc: TCefRequestContextHandlerProc); reintroduce;
  end;


  TCefPrintSettingsRef = class(TCefBaseRef, ICefPrintSettings)
  protected
    function IsValid: Boolean;
    function IsReadOnly: Boolean;
    function Copy: ICefPrintSettings;
    procedure SetOrientation(landscape: Boolean);
    function IsLandscape: Boolean;
    procedure SetPrinterPrintableArea(
      const physicalSizeDeviceUnits: PCefSize;
      const printableAreaDeviceUnits: PCefRect;
      landscapeNeedsFlip: Boolean); stdcall;
    procedure SetDeviceName(const name: ustring);
    function GetDeviceName: ustring;
    procedure SetDpi(dpi: Integer);
    function GetDpi: Integer;
    procedure SetPageRanges(const ranges: TCefPageRangeArray);
    function GetPageRangesCount: NativeUInt;
    procedure GetPageRanges(out ranges: TCefPageRangeArray);
    procedure SetSelectionOnly(selectionOnly: Boolean);
    function IsSelectionOnly: Boolean;
    procedure SetCollate(collate: Boolean);
    function WillCollate: Boolean;
    procedure SetColorModel(model: TCefColorModel);
    function GetColorModel: TCefColorModel;
    procedure SetCopies(copies: Integer);
    function GetCopies: Integer;
    procedure SetDuplexMode(mode: TCefDuplexMode);
    function GetDuplexMode: TCefDuplexMode;
  public
    class function New: ICefPrintSettings;
    class function UnWrap(data: Pointer): ICefPrintSettings;
  end;

  TCefNavigationEntryRef = class(TCefBaseRef, ICefNavigationEntry)
  protected
    function IsValid: Boolean;
    function GetUrl: ustring;
    function GetDisplayUrl: ustring;
    function GetOriginalUrl: ustring;
    function GetTitle: ustring;
    function GetTransitionType: TCefTransitionType;
    function HasPostData: Boolean;
    function GetCompletionTime: TDateTime;
    function GetHttpStatusCode: Integer;
  public
    class function UnWrap(data: Pointer): ICefNavigationEntry;
  end;

  TCefNavigationEntryVisitorOwn = class(TCefBaseOwn, ICefNavigationEntryVisitor)
  protected
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean; virtual;
  public
    constructor Create;
  end;

  TCefFastNavigationEntryVisitor = class(TCefNavigationEntryVisitorOwn)
  private
    FVisitor: TCefNavigationEntryVisitorProc;
  protected
    function Visit(const entry: ICefNavigationEntry;
      current: Boolean; index, total: Integer): Boolean; override;
  public
    constructor Create(const proc: TCefNavigationEntryVisitorProc); reintroduce;
  end;


  TCefSslCertPrincipalRef = class(TCefBaseRef, ICefSslCertPrincipal)
  protected
    function GetDisplayName: ustring;
    function GetCommonName: ustring;
    function GetLocalityName: ustring;
    function GetStateOrProvinceName: ustring;
    function GetCountryName: ustring;
    procedure GetStreetAddresses(addresses: TStrings);
    procedure GetOrganizationNames(names: TStrings);
    procedure GetOrganizationUnitNames(names: TStrings);
    procedure GetDomainComponents(components: TStrings);
  public
    class function UnWrap(data: Pointer): ICefSslCertPrincipal;
  end;

  TCefSslInfoRef = class(TCefBaseRef, ICefSslInfo)
  protected
    function GetSubject: ICefSslCertPrincipal;
    function GetIssuer: ICefSslCertPrincipal;
    function GetSerialNumber: ICefBinaryValue;
    function GetValidStart: TCefTime;
    function GetValidExpiry: TCefTime;
    function GetDerEncoded: ICefBinaryValue;
    function GetPemEncoded: ICefBinaryValue;
  public
    class function UnWrap(data: Pointer): ICefSslInfo;
  end;

  TCefPdfPrintCallbackOwn = class(TCefBaseOwn, ICefPdfPrintCallback)
  protected
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean); virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TCefFastPdfPrintCallback = class(TCefPdfPrintCallbackOwn)
  private
    FProc: TOnPdfPrintFinishedProc;
  protected
    procedure OnPdfPrintFinished(const path: ustring; ok: Boolean); override;
  public
    constructor Create(const proc: TOnPdfPrintFinishedProc); reintroduce;
  end;

  TCefRunContextMenuCallbackRef = class(TCefBaseRef, ICefRunContextMenuCallback)
  protected
    procedure Cont(commandId: Integer; eventFlags: TCefEventFlags);
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefRunContextMenuCallback;
  end;

  TCefResourceBundleRef = class(TCefBaseRef, ICefResourceBundle)
  protected
    function GetLocalizedString(stringId: Integer): ustring;
    function GetDataResource(resourceId: Integer;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
    function GetDataResourceForScale(resourceId: Integer; scaleFactor: TCefScaleFactor;
      out data: Pointer; out dataSize: NativeUInt): Boolean;
  public
    class function UnWrap(data: Pointer): ICefResourceBundle;
    class function Global: ICefResourceBundle;
  end;

  ECefException = class(Exception)
  end;

function CefLoadLibDefault: Boolean;
function CefLoadLib(
  const Cache: ustring = '';
  const UserDataPath: ustring = '';
  const UserAgent: ustring = '';
  const ProductVersion: ustring = '';
  const Locale: ustring = '';
  const LogFile: ustring = '';
  const BrowserSubprocessPath: ustring = '';
  LogSeverity: TCefLogSeverity = LOGSEVERITY_DISABLE;
  JavaScriptFlags: ustring = '';
  ResourcesDirPath: ustring = '';
  LocalesDirPath: ustring = '';
  SingleProcess: Boolean = False;
  NoSandbox: Boolean = False;
  CommandLineArgsDisabled: Boolean = False;
  PackLoadingDisabled: Boolean = False;
  RemoteDebuggingPort: Integer = 0;
  UncaughtExceptionStackSize: Integer = 0;
  ContextSafetyImplementation: Integer = 0;
  PersistSessionCookies: Boolean = False;
  IgnoreCertificateErrors: Boolean = False;
  BackgroundColor: TCefColor = 0;
  const AcceptLanguageList: ustring = '';
  WindowsSandboxInfo: Pointer = nil;
  WindowlessRenderingEnabled: Boolean = False): Boolean;
function CefGetObject(ptr: Pointer): TObject;
function CefStringAlloc(const str: ustring): TCefString;

function CefString(const str: ustring): TCefString; overload;
function CefString(const str: PCefString): ustring; overload;
function CefUserFreeString(const str: ustring): PCefStringUserFree;

function CefStringClearAndGet(var str: TCefString): ustring;
procedure CefStringFree(const str: PCefString);
function CefStringFreeAndGet(const str: PCefStringUserFree): ustring;
procedure CefStringSet(const str: PCefString; const value: ustring);
function CefBrowserHostCreate(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): Boolean;
function CefBrowserHostCreateSync(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): ICefBrowser;
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
procedure CefDoMessageLoopWork;
procedure CefRunMessageLoop;
procedure CefQuitMessageLoop;
procedure CefSetOsModalLoop(loop: Boolean);
{$ENDIF}
procedure CefEnableHighDpiSupport;

procedure CefShutDown;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const handler: TCefResourceHandlerClass): Boolean; overload;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const factory: ICefSchemeHandlerFactory): Boolean; overload;

function CefClearSchemeHandlerFactories: Boolean;

function CefAddCrossOriginWhitelistEntry(const SourceOrigin, TargetProtocol,
  TargetDomain: ustring; AllowTargetSubdomains: Boolean): Boolean;
function CefRemoveCrossOriginWhitelistEntry(
  const SourceOrigin, TargetProtocol, TargetDomain: ustring;
  AllowTargetSubdomains: Boolean): Boolean;
function CefClearCrossOriginWhitelist: Boolean;

function CefRegisterExtension(const name, code: ustring;
  const Handler: ICefv8Handler): Boolean;
function CefCurrentlyOn(ThreadId: TCefThreadId): Boolean;
procedure CefPostTask(ThreadId: TCefThreadId; const task: ICefTask);
procedure CefPostDelayedTask(ThreadId: TCefThreadId; const task: ICefTask; delayMs: Int64);
function CefGetData(const i: ICefBase): Pointer;
function CefParseUrl(const url: ustring; var parts: TUrlParts): Boolean;
function CefCreateUrl(var parts: TUrlParts): ustring;
function CefGetMimeType(const extension: ustring): ustring;
procedure CefGetExtensionsForMimeType(const mimeType: ustring; extensions: TStringList);

function CefBase64Encode(const data: Pointer; dataSize: NativeUInt): ustring;
function CefBase64Decode(const data: ustring): ICefBinaryValue;
function CefUriEncode(const text: ustring; usePlus: Boolean): ustring;
function CefUriDecode(const text: ustring; convertToUtf8: Boolean;
  unescapeRule: TCefUriUnescapeRule): ustring;
function CefParseCssColor(const str: ustring; strict: Boolean; out color: TCefColor): Boolean;
{$ifdef Win32}
function CefParseJson(const jsonString: ustring; options: TCefJsonParserOptions): ICefValue;
function CefParseJsonAndReturnError(const jsonString: ustring; options: TCefJsonParserOptions;
  out errorCodeOut: TCefJsonParserError; out errorMsgOut: ustring): ICefValue;
function CefWriteJson(const node: ICefValue; options: TCefJsonWriterOptions): ustring;
{$endif}
procedure CefVisitWebPluginInfo(const visitor: ICefWebPluginInfoVisitor);
procedure CefVisitWebPluginInfoProc(const visitor: TCefWebPluginInfoVisitorProc);
procedure CefRefreshWebPlugins;
procedure CefAddWebPluginPath(const path: ustring);
procedure CefAddWebPluginDirectory(const dir: ustring);
procedure CefRemoveWebPluginPath(const path: ustring);
procedure CefUnregisterInternalWebPlugin(const path: ustring);
procedure CefForceWebPluginShutdown(const path: ustring);
procedure CefRegisterWebPluginCrash(const path: ustring);
procedure CefIsWebPluginUnstable(const path: ustring;
  const callback: ICefWebPluginUnstableCallback);
procedure CefIsWebPluginUnstableProc(const path: ustring;
  const callback: TCefWebPluginIsUnstableProc);

function CefGetPath(key: TCefPathKey; out path: ustring): Boolean;

function CefBeginTracing(const categories: ustring; const callback: ICefCompletionCallback): Boolean;
function CefEndTracing(const tracingFile: ustring; const callback: ICefEndTracingCallback): Boolean;
function CefNowFromSystemTraceTime: Int64;

function CefGetGeolocation(const callback: ICefGetGeolocationCallback): Boolean;

var
  CefLibrary: string = {$IFDEF MSWINDOWS}'libcef.dll'{$ELSE}'libcef.dylib'{$ENDIF};
  CefCache: ustring = '';
  CefUserDataPath: ustring = '';
  CefUserAgent: ustring = '';
  CefProductVersion: ustring = '';
  CefLocale: ustring = '';
  CefLogFile: ustring = '';
  CefLogSeverity: TCefLogSeverity = LOGSEVERITY_DISABLE;
  CefJavaScriptFlags: ustring = '';
  CefResourcesDirPath: ustring = '';
  CefLocalesDirPath: ustring = '';
  CefPackLoadingDisabled: Boolean = False;
  CefSingleProcess: Boolean = True;
  CefNoSandbox: Boolean = False;
  CefBrowserSubprocessPath: ustring = '';
  CefCommandLineArgsDisabled: Boolean = False;
  CefRemoteDebuggingPort: Integer = 0;
  CefGetDataResource: TGetDataResource = nil;
  CefGetLocalizedString: TGetLocalizedString = nil;
  CefUncaughtExceptionStackSize: Integer = 0;
  CefContextSafetyImplementation: Integer = 0;
  CefPersistSessionCookies: Boolean = False;
  CefIgnoreCertificateErrors: Boolean = False;
  CefBackgroundColor: TCefColor = 0;
  CefAcceptLanguageList: ustring = '';
  CefWindowsSandboxInfo: Pointer = nil;
  CefWindowlessRenderingEnabled: Boolean = False;

  CefResourceBundleHandler: ICefResourceBundleHandler = nil;
  CefBrowserProcessHandler: ICefBrowserProcessHandler = nil;
  CefRenderProcessHandler: ICefRenderProcessHandler = nil;
  CefOnBeforeCommandLineProcessing: TOnBeforeCommandLineProcessing = nil;
  CefOnRegisterCustomSchemes: TOnRegisterCustomSchemes = nil;

implementation

  function CefColorGetA(color: TCefColor): Byte;
  begin
    Result := (color shr 24) and $FF;
  end;

  function CefColorGetR(color: TCefColor): byte;
  begin
    Result := (color shr 16) and $FF;
  end;

  function CefColorGetG(color: TCefColor): Byte;
  begin
    Result := (color shr 8) and $FF;
  end;

  function CefColorGetB(color: TCefColor): Byte;
  begin
    Result := color and $FF;
  end;

  function CefColorSetARGB(a, r, g, b: Byte): TCefColor;
  begin
    Result := (a shl 24) or (r shl 16) or (g shl 8) or b;
  end;

  function CefInt64Set(int32_low, int32_high: Integer): Int64;
  begin
    Result := int32_low or (int32_high shl 32);
  end;

  function CefInt64GetLow(const int64_val: Int64): Integer;
  begin
    Result := Integer(int64_val);
  end;

  function CefInt64GetHigh(const int64_val: Int64): Integer;
  begin
    Result := (int64_val shr 32) and $FFFFFFFF;
  end;


type
  TInternalApp = class(TCefAppOwn)
  protected
    procedure OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine); override;
    procedure OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar); override;
    function GetResourceBundleHandler: ICefResourceBundleHandler; override;
    function GetBrowserProcessHandler: ICefBrowserProcessHandler; override;
    function GetRenderProcessHandler: ICefRenderProcessHandler; override;
  end;

  procedure TInternalApp.OnBeforeCommandLineProcessing(const processType: ustring;
      const commandLine: ICefCommandLine);
  begin

    if Assigned(CefOnBeforeCommandLineProcessing) then
      CefOnBeforeCommandLineProcessing(processType, commandLine);
  end;

  procedure TInternalApp.OnRegisterCustomSchemes(const registrar: ICefSchemeRegistrar);
  begin

    if Assigned(CefOnRegisterCustomSchemes) then
      CefOnRegisterCustomSchemes(registrar);
  end;

  function TInternalApp.GetResourceBundleHandler: ICefResourceBundleHandler;
  begin
    Result := CefResourceBundleHandler;
  end;

  function TInternalApp.GetBrowserProcessHandler: ICefBrowserProcessHandler;
  begin

    result := CefBrowserProcessHandler;
  end;

  function TInternalApp.GetRenderProcessHandler: ICefRenderProcessHandler;
  begin
    Result := CefRenderProcessHandler;
  end;

{$IFDEF MSWINDOWS}
function TzSpecificLocalTimeToSystemTime(
  lpTimeZoneInformation: PTimeZoneInformation;
  lpLocalTime, lpUniversalTime: PSystemTime): BOOL; stdcall; external 'kernel32.dll';

function SystemTimeToTzSpecificLocalTime(
  lpTimeZoneInformation: PTimeZoneInformation;
  lpUniversalTime, lpLocalTime: PSystemTime): BOOL; stdcall; external 'kernel32.dll';
{$ENDIF}

var
// These functions set string values. If |copy| is true (1) the value will be
// copied instead of referenced. It is up to the user to properly manage
// the lifespan of references.

  cef_string_wide_set: function(const src: PWideChar; src_len: NativeUInt;  output: PCefStringWide; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_set: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf8; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_set: function(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf16; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_set: function(const src: PCefChar; src_len: NativeUInt; output: PCefString; copy: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions clear string values. The structure itself is not freed.

  cef_string_wide_clear: procedure(str: PCefStringWide); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_clear: procedure(str: PCefStringUtf8); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_clear: procedure(str: PCefStringUtf16); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_clear: procedure(str: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions compare two string values with the same results as strcmp().

  cef_string_wide_cmp: function(const str1, str2: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_cmp: function(const str1, str2: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_cmp: function(const str1, str2: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions convert between UTF-8, -16, and -32 strings. They are
  // potentially slow so unnecessary conversions should be avoided. The best
  // possible result will always be written to |output| with the boolean return
  // value indicating whether the conversion is 100% valid.

  cef_string_wide_to_utf8: function(const src: PWideChar; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf8_to_wide: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_wide_to_utf16: function (const src: PWideChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_to_wide: function(const src: PChar16; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_utf8_to_utf16: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_utf16_to_utf8: function(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_string_to_utf8: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringUtf8): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_utf8: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_to_utf16: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_utf16: function(const src: PChar16; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_to_wide: function(const src: PCefChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_wide: function(const src: PWideChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions convert an ASCII string, typically a hardcoded constant, to a
  // Wide/UTF16 string. Use instead of the UTF8 conversion routines if you know
  // the string is ASCII.

  cef_string_ascii_to_wide: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringWide): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_ascii_to_utf16: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_from_ascii: function(const src: PAnsiChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions allocate a new string structure. They must be freed by
  // calling the associated free function.

  cef_string_userfree_wide_alloc: function(): PCefStringUserFreeWide; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf8_alloc: function(): PCefStringUserFreeUtf8; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf16_alloc: function(): PCefStringUserFreeUtf16; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_alloc: function(): PCefStringUserFree; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // These functions free the string structure allocated by the associated
  // alloc function. Any string contents will first be cleared.

  cef_string_userfree_wide_free: procedure(str: PCefStringUserFreeWide); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf8_free: procedure(str: PCefStringUserFreeUtf8); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_utf16_free: procedure(str: PCefStringUserFreeUtf16); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_userfree_free: procedure(str: PCefStringUserFree); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

// Convenience macros for copying values.
function cef_string_wide_copy(const src: PWideChar; src_len: NativeUInt;  output: PCefStringWide): Integer;
begin
  Result := cef_string_wide_set(src, src_len, output, ord(True))
end;

function cef_string_utf8_copy(const src: PAnsiChar; src_len: NativeUInt; output: PCefStringUtf8): Integer;
begin
  Result := cef_string_utf8_set(src, src_len, output, ord(True))
end;

function cef_string_utf16_copy(const src: PChar16; src_len: NativeUInt; output: PCefStringUtf16): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := cef_string_utf16_set(src, src_len, output, ord(True))
end;

function cef_string_copy(const src: PCefChar; src_len: NativeUInt; output: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := cef_string_set(src, src_len, output, ord(True));
end;

var
  // Create a new browser window using the window parameters specified by
  // |windowInfo|. All values will be copied internally and the actual window will
  // be created on the UI thread. If |request_context| is NULL the global request
  // context will be used. This function can be called on any browser process
  // thread and will not block.
  cef_browser_host_create_browser: function(
      const windowInfo: PCefWindowInfo; client: PCefClient;
      const url: PCefString; const settings: PCefBrowserSettings;
      request_context: PCefRequestContext): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new browser window using the window parameters specified by
  // |windowInfo|. If |request_context| is NULL the global request context will be
  // used. This function can only be called on the browser process UI thread.
  cef_browser_host_create_browser_sync: function(
      const windowInfo: PCefWindowInfo; client: PCefClient;
      const url: PCefString; const settings: PCefBrowserSettings;
      request_context: PCefRequestContext): PCefBrowser; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Perform a single iteration of CEF message loop processing. This function is
  // used to integrate the CEF message loop into an existing application message
  // loop. Care must be taken to balance performance against excessive CPU usage.
  // This function should only be called on the main application thread and only
  // if cef_initialize() is called with a CefSettings.multi_threaded_message_loop
  // value of false (0). This function will not block.
  cef_do_message_loop_work: procedure(); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Run the CEF message loop. Use this function instead of an application-
  // provided message loop to get the best balance between performance and CPU
  // usage. This function should only be called on the main application thread and
  // only if cef_initialize() is called with a
  // CefSettings.multi_threaded_message_loop value of false (0). This function
  // will block until a quit message is received by the system.
  cef_run_message_loop: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Quit the CEF message loop that was started by calling cef_run_message_loop().
  // This function should only be called on the main application thread and only
  // if cef_run_message_loop() was used.
  cef_quit_message_loop: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // Set to true (1) before calling Windows APIs like TrackPopupMenu that enter a
  // modal message loop. Set to false (0) after exiting the modal message loop.
  cef_set_osmodal_loop: procedure(osModalLoop: Integer); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Call during process startup to enable High-DPI support on Windows 7 or newer.
  // Older versions of Windows should be left DPI-unaware because they do not
  // support DirectWrite and GDI fonts are kerned very badly.
  cef_enable_highdpi_support: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // This function should be called from the application entry point function to
  // execute a secondary process. It can be used to run secondary processes from
  // the browser client executable (default behavior) or from a separate
  // executable specified by the CefSettings.browser_subprocess_path value. If
  // called for the browser process (identified by no "type" command-line value)
  // it will return immediately with a value of -1. If called for a recognized
  // secondary process it will block until the process should exit and then return
  // the process exit code. The |application| parameter may be NULL. The
  // |windows_sandbox_info| parameter is only used on Windows and may be NULL (see
  // cef_sandbox_win.h for details).
  cef_execute_process: function(const args: PCefMainArgs; application: PCefApp; windows_sandbox_info: Pointer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // This function should be called on the main application thread to initialize
  // the CEF browser process. The |application| parameter may be NULL. A return
  // value of true (1) indicates that it succeeded and false (0) indicates that it
  // failed.
  cef_initialize: function(const args: PCefMainArgs; const settings: PCefSettings; application: PCefApp; windows_sandbox_info: Pointer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // This function should be called on the main application thread to shut down
  // the CEF browser process before the application exits.
  cef_shutdown: procedure(); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Allocate a new string map.
  cef_string_map_alloc: function(): TCefStringMap; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  //function cef_string_map_size(map: TCefStringMap): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  cef_string_map_size: function(map: TCefStringMap): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Return the value assigned to the specified key.
  cef_string_map_find: function(map: TCefStringMap; const key: PCefString; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Return the key at the specified zero-based string map index.
  cef_string_map_key: function(map: TCefStringMap; index: Integer; var key: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Return the value at the specified zero-based string map index.
  cef_string_map_value: function(map: TCefStringMap; index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Append a new key/value pair at the end of the string map.
  cef_string_map_append: function(map: TCefStringMap; const key, value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Clear the string map.
  cef_string_map_clear: procedure(map: TCefStringMap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Free the string map.
  cef_string_map_free: procedure(map: TCefStringMap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Allocate a new string map.
  cef_string_list_alloc: function(): TCefStringList; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Return the number of elements in the string list.
  cef_string_list_size: function(list: TCefStringList): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Retrieve the value at the specified zero-based string list index. Returns
  // true (1) if the value was successfully retrieved.
  cef_string_list_value: function(list: TCefStringList; index: Integer; value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Append a new value at the end of the string list.
  cef_string_list_append: procedure(list: TCefStringList; const value: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Clear the string list.
  cef_string_list_clear: procedure(list: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Free the string list.
  cef_string_list_free: procedure(list: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Creates a copy of an existing string list.
  cef_string_list_copy: function(list: TCefStringList): TCefStringList;


  // Register a new V8 extension with the specified JavaScript extension code and
  // handler. Functions implemented by the handler are prototyped using the
  // keyword 'native'. The calling of a native function is restricted to the scope
  // in which the prototype of the native function is defined. This function may
  // only be called on the render process main thread.
  //
  // Example JavaScript extension code:
  //
  //   // create the 'example' global object if it doesn't already exist.
  //   if (!example)
  //     example = {};
  //   // create the 'example.test' global object if it doesn't already exist.
  //   if (!example.test)
  //     example.test = {};
  //   (function() {
  //     // Define the function 'example.test.myfunction'.
  //     example.test.myfunction = function() {
  //       // Call CefV8Handler::Execute() with the function name 'MyFunction'
  //       // and no arguments.
  //       native function MyFunction();
  //       return MyFunction();
  //     };
  //     // Define the getter function for parameter 'example.test.myparam'.
  //     example.test.__defineGetter__('myparam', function() {
  //       // Call CefV8Handler::Execute() with the function name 'GetMyParam'
  //       // and no arguments.
  //       native function GetMyParam();
  //       return GetMyParam();
  //     });
  //     // Define the setter function for parameter 'example.test.myparam'.
  //     example.test.__defineSetter__('myparam', function(b) {
  //       // Call CefV8Handler::Execute() with the function name 'SetMyParam'
  //       // and a single argument.
  //       native function SetMyParam();
  //       if(b) SetMyParam(b);
  //     });
  //
  //     // Extension definitions can also contain normal JavaScript variables
  //     // and functions.
  //     var myint = 0;
  //     example.test.increment = function() {
  //       myint += 1;
  //       return myint;
  //     };
  //   })();
  //
  // Example usage in the page:
  //
  //   // Call the function.
  //   example.test.myfunction();
  //   // Set the parameter.
  //   example.test.myparam = value;
  //   // Get the parameter.
  //   value = example.test.myparam;
  //   // Call another function.
  //   example.test.increment();
  //
  cef_register_extension: function(const extension_name,
    javascript_code: PCefString; handler: PCefv8Handler): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Register a scheme handler factory with the global request context. An NULL
  // |domain_name| value for a standard scheme will cause the factory to match all
  // domain names. The |domain_name| value will be ignored for non-standard
  // schemes. If |scheme_name| is a built-in scheme and no handler is returned by
  // |factory| then the built-in scheme handler factory will be called. If
  // |scheme_name| is a custom scheme then you must also implement the
  // cef_app_t::on_register_custom_schemes() function in all processes. This
  // function may be called multiple times to change or remove the factory that
  // matches the specified |scheme_name| and optional |domain_name|. Returns false
  // (0) if an error occurs. This function may be called on any thread in the
  // browser process. Using this function is equivalent to calling cef_request_tCo
  // ntext::cef_request_context_get_global_context()->register_scheme_handler_fact
  // ory().
  cef_register_scheme_handler_factory: function(
      const scheme_name, domain_name: PCefString;
      factory: PCefSchemeHandlerFactory): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Clear all scheme handler factories registered with the global request
  // context. Returns false (0) on error. This function may be called on any
  // thread in the browser process. Using this function is equivalent to calling c
  // ef_request_tContext::cef_request_context_get_global_context()->clear_scheme_h
  // andler_factories().
  cef_clear_scheme_handler_factories: function: Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add an entry to the cross-origin access whitelist.
  //
  // The same-origin policy restricts how scripts hosted from different origins
  // (scheme + domain + port) can communicate. By default, scripts can only access
  // resources with the same origin. Scripts hosted on the HTTP and HTTPS schemes
  // (but no other schemes) can use the "Access-Control-Allow-Origin" header to
  // allow cross-origin requests. For example, https://source.example.com can make
  // XMLHttpRequest requests on http://target.example.com if the
  // http://target.example.com request returns an "Access-Control-Allow-Origin:
  // https://source.example.com" response header.
  //
  // Scripts in separate frames or iframes and hosted from the same protocol and
  // domain suffix can execute cross-origin JavaScript if both pages set the
  // document.domain value to the same domain suffix. For example,
  // scheme://foo.example.com and scheme://bar.example.com can communicate using
  // JavaScript if both domains set document.domain="example.com".
  //
  // This function is used to allow access to origins that would otherwise violate
  // the same-origin policy. Scripts hosted underneath the fully qualified
  // |source_origin| URL (like http://www.example.com) will be allowed access to
  // all resources hosted on the specified |target_protocol| and |target_domain|.
  // If |target_domain| is non-NULL and |allow_target_subdomains| if false (0)
  // only exact domain matches will be allowed. If |target_domain| contains a top-
  // level domain component (like "example.com") and |allow_target_subdomains| is
  // true (1) sub-domain matches will be allowed. If |target_domain| is NULL and
  // |allow_target_subdomains| if true (1) all domains and IP addresses will be
  // allowed.
  //
  // This function cannot be used to bypass the restrictions on local or display
  // isolated schemes. See the comments on CefRegisterCustomScheme for more
  // information.
  //
  // This function may be called on any thread. Returns false (0) if
  // |source_origin| is invalid or the whitelist cannot be accessed.

  cef_add_cross_origin_whitelist_entry: function(const source_origin, target_protocol,
    target_domain: PCefString; allow_target_subdomains: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Remove an entry from the cross-origin access whitelist. Returns false (0) if
  // |source_origin| is invalid or the whitelist cannot be accessed.
  cef_remove_cross_origin_whitelist_entry: function(
      const source_origin, target_protocol, target_domain: PCefString;
      allow_target_subdomains: Integer): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Remove all entries from the cross-origin access whitelist. Returns false (0)
  // if the whitelist cannot be accessed.
  cef_clear_cross_origin_whitelist: function: Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns true (1) if called on the specified thread. Equivalent to using
  // cef_task_tRunner::GetForThread(threadId)->belongs_to_current_thread().
  cef_currently_on: function(threadId: TCefThreadId): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Post a task for execution on the specified thread. Equivalent to using
  // cef_task_tRunner::GetForThread(threadId)->PostTask(task).
  cef_post_task: function(threadId: TCefThreadId; task: PCefTask): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Post a task for delayed execution on the specified thread. Equivalent to
  // using cef_task_tRunner::GetForThread(threadId)->PostDelayedTask(task,
  // delay_ms).
  cef_post_delayed_task: function(threadId: TCefThreadId;
      task: PCefTask; delay_ms: Int64): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Parse the specified |url| into its component parts. Returns false (0) if the
  // URL is NULL or invalid.
  cef_parse_url: function(const url: PCefString; var parts: TCefUrlParts): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a URL from the specified |parts|, which must contain a non-NULL spec
  // or a non-NULL host and path (at a minimum), but not both. Returns false (0)
  // if |parts| isn't initialized as described.
  cef_create_url: function(parts: PCefUrlParts; url: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the mime type for the specified file extension or an NULL string if
  // unknown.
  ///
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_get_mime_type: function(const extension: PCefString): PCefStringUserFree; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Get the extensions associated with the given mime type. This should be passed
  // in lower case. There could be multiple extensions for a given mime type, like
  // "html,htm" for "text/html", or "txt,text,html,..." for "text/*". Any existing
  // elements in the provided vector will not be erased.
  cef_get_extensions_for_mime_type: procedure(const mime_type: PCefString;
    extensions: TCefStringList); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

//******************************************************************************

  // Encodes |data| as a base64 string.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_base64encode: function(const data: Pointer; data_size: NativeUInt): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Decodes the base64 encoded string |data|. The returned value will be NULL if
  // the decoding fails.
  cef_base64decode: function(const data: PCefString): PCefBinaryValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Escapes characters in |text| which are unsuitable for use as a query
  // parameter value. Everything except alphanumerics and -_.!~*'() will be
  // converted to "%XX". If |use_plus| is true (1) spaces will change to "+". The
  // result is basically the same as encodeURIComponent in Javacript.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_uriencode: function(const text: PCefString; use_plus: Integer): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Unescapes |text| and returns the result. Unescaping consists of looking for
  // the exact pattern "%XX" where each X is a hex digit and converting to the
  // character with the numerical value of those digits (e.g. "i%20=%203%3b"
  // unescapes to "i = 3;"). If |convert_to_utf8| is true (1) this function will
  // attempt to interpret the initial decoded result as UTF-8. If the result is
  // convertable into UTF-8 it will be returned as converted. Otherwise the
  // initial decoded result will be returned.  The |unescape_rule| parameter
  // supports further customization the decoding process.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_uridecode: function(const text: PCefString; convert_to_utf8: Integer;
    unescape_rule: TCefUriUnescapeRule): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Parses |string| which represents a CSS color value. If |strict| is true (1)
  // strict parsing rules will be applied. Returns true (1) on success or false
  // (0) on error. If parsing succeeds |color| will be set to the color value
  // otherwise |color| will remain unchanged.
  cef_parse_csscolor: function(const str: PCefString; strict: Integer;
    color: PCefColor): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

{$ifdef Win32}
  // Parses the specified |json_string| and returns a dictionary or list
  // representation. If JSON parsing fails this function returns NULL.
  cef_parse_json: function(const json_string: PCefString; options: TCefJsonParserOptions): PCefValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Parses the specified |json_string| and returns a dictionary or list
  // representation. If JSON parsing fails this function returns NULL and
  // populates |error_code_out| and |error_msg_out| with an error code and a
  // formatted error message respectively.
  cef_parse_jsonand_return_error: function(
      const json_string: PCefString; options: TCefJsonParserOptions;
      error_code_out: PCefJsonParserError; error_msg_out: PCefString): PCefValue;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Generates a JSON string from the specified root |node| which should be a
  // dictionary or list value. Returns an NULL string on failure. This function
  // requires exclusive access to |node| including any underlying data.
  // The resulting string must be freed by calling cef_string_userfree_free().
  cef_write_json: function(node: PCefValue; options: TCefJsonWriterOptions): PCefStringUserFree;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
{$endif}

//******************************************************************************

  // Create a new TCefRequest object.
  cef_request_create: function(): PCefRequest; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new TCefPostData object.
  cef_post_data_create: function(): PCefPostData; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_post_data_Element object.
  cef_post_data_element_create: function(): PCefPostDataElement; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_stream_reader_t object from a file.
  cef_stream_reader_create_for_file: function(const fileName: PCefString): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_stream_reader_t object from data.
  cef_stream_reader_create_for_data: function(data: Pointer; size: NativeUInt): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_stream_reader_t object from a custom handler.
  cef_stream_reader_create_for_handler: function(handler: PCefReadHandler): PCefStreamReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_stream_writer_t object for a file.
  cef_stream_writer_create_for_file: function(const fileName: PCefString): PCefStreamWriter; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_stream_writer_t object for a custom handler.
  cef_stream_writer_create_for_handler: function(handler: PCefWriteHandler): PCefStreamWriter; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the current (top) context object in the V8 context stack.
  cef_v8context_get_current_context: function(): PCefv8Context; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the entered (bottom) context object in the V8 context stack.
  cef_v8context_get_entered_context: function(): PCefv8Context; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns true (1) if V8 is currently inside a context.
  cef_v8context_in_context: function(): Integer;

  // Create a new cef_v8value_t object of type undefined.
  cef_v8value_create_undefined: function(): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type null.
  cef_v8value_create_null: function(): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type bool.
  cef_v8value_create_bool: function(value: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type int.
  cef_v8value_create_int: function(value: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type unsigned int.
  cef_v8value_create_uint: function(value: Cardinal): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type double.
  cef_v8value_create_double: function(value: Double): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type Date. This function should only be
  // called from within the scope of a cef_render_process_handler_t,
  // cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
  // enter() and exit() on a stored cef_v8context_t reference.
  cef_v8value_create_date: function(const value: PCefTime): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type string.
  cef_v8value_create_string: function(const value: PCefString): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_v8value_t object of type object with optional accessor. This
  // function should only be called from within the scope of a
  // cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
  // or in combination with calling enter() and exit() on a stored cef_v8context_t
  // reference.
  cef_v8value_create_object: function(accessor: PCefV8Accessor): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};
  // Create a new cef_v8value_t object of type array with the specified |length|.
  // If |length| is negative the returned array will have length 0. This function
  // should only be called from within the scope of a
  // cef_render_process_handler_t, cef_v8handler_t or cef_v8accessor_t callback,
  // or in combination with calling enter() and exit() on a stored cef_v8context_t
  // reference.
  cef_v8value_create_array: function(length: Integer): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_v8value_t object of type function. This function should only
  // be called from within the scope of a cef_render_process_handler_t,
  // cef_v8handler_t or cef_v8accessor_t callback, or in combination with calling
  // enter() and exit() on a stored cef_v8context_t reference.
  cef_v8value_create_function: function(const name: PCefString; handler: PCefv8Handler): PCefv8Value; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the stack trace for the currently active context. |frame_limit| is
  // the maximum number of frames that will be captured.
  cef_v8stack_trace_get_current: function(frame_limit: Integer): PCefV8StackTrace; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_xml_reader_t object. The returned object's functions can
  // only be called from the thread that created the object.
  cef_xml_reader_create: function(stream: PCefStreamReader;
    encodingType: TCefXmlEncodingType; const URI: PCefString): PCefXmlReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_zip_reader_t object. The returned object's functions can
  // only be called from the thread that created the object.
  cef_zip_reader_create: function(stream: PCefStreamReader): PCefZipReader; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Allocate a new string multimap.
  cef_string_multimap_alloc: function: TCefStringMultimap; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Return the number of elements in the string multimap.
  cef_string_multimap_size: function(map: TCefStringMultimap): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Return the number of values with the specified key.
  cef_string_multimap_find_count: function(map: TCefStringMultimap; const key: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Return the value_index-th value with the specified key.
  cef_string_multimap_enumerate: function(map: TCefStringMultimap;
    const key: PCefString; value_index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Return the key at the specified zero-based string multimap index.
  cef_string_multimap_key: function(map: TCefStringMultimap; index: Integer; var key: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Return the value at the specified zero-based string multimap index.
  cef_string_multimap_value: function(map: TCefStringMultimap; index: Integer; var value: TCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Append a new key/value pair at the end of the string multimap.
  cef_string_multimap_append: function(map: TCefStringMultimap; const key, value: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Clear the string multimap.
  cef_string_multimap_clear: procedure(map: TCefStringMultimap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Free the string multimap.
  cef_string_multimap_free: procedure(map: TCefStringMultimap); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the global cookie manager. By default data will be stored at
  // CefSettings.cache_path if specified or in memory otherwise. If |callback| is
  // non-NULL it will be executed asnychronously on the IO thread after the
  // manager's storage has been initialized. Using this function is equivalent to
  // calling cef_request_tContext::cef_request_context_get_global_context()->get_d
  // efault_cookie_manager().

  cef_cookie_manager_get_global_manager: function(
    callback: PCefCompletionCallback): PCefCookieManager; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new cookie manager. If |path| is NULL data will be stored in memory
  // only. Otherwise, data will be stored at the specified |path|. To persist
  // session cookies (cookies without an expiry date or validity interval) set
  // |persist_session_cookies| to true (1). Session cookies are generally intended
  // to be transient and most Web browsers do not persist them. If |callback| is
  // non-NULL it will be executed asnychronously on the IO thread after the
  // manager's storage has been initialized.

  cef_cookie_manager_create_manager: function(const path: PCefString; persist_session_cookies: Integer;
    callback: PCefCompletionCallback): PCefCookieManager; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // Create a new cef_command_line_t instance.

  cef_command_line_create: function(): PCefCommandLine; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the singleton global cef_command_line_t object. The returned object
  // will be read-only.
  cef_command_line_get_global: function(): PCefCommandLine; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // Create a new cef_process_message_t object with the specified name.
  cef_process_message_create: function(const name: PCefString): PCefProcessMessage; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new object.
  cef_value_create: function(): PCefValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new object that is not owned by any other object. The specified
  // |data| will be copied.
  cef_binary_value_create: function(const data: Pointer; data_size: NativeUInt): PCefBinaryValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new object that is not owned by any other object.
  cef_dictionary_value_create: function: PCefDictionaryValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new object that is not owned by any other object.
  cef_list_value_create: function: PCefListValue; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Retrieve the path associated with the specified |key|. Returns true (1) on
  // success. Can be called on any thread in the browser process.
  cef_get_path: function(key: TCefPathKey; path: PCefString): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Launches the process specified via |command_line|. Returns true (1) upon
  // success. Must be called on the browser process TID_PROCESS_LAUNCHER thread.
  //
  // Unix-specific notes: - All file descriptors open in the parent process will
  // be closed in the
  //   child process except for stdin, stdout, and stderr.
  // - If the first argument on the command line does not contain a slash,
  //   PATH will be searched. (See man execvp.)
  cef_launch_process: function(command_line: PCefCommandLine): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new cef_response_t object.
  cef_response_create: function: PCefResponse; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Create a new URL request. Only GET, POST, HEAD, DELETE and PUT request
  // functions are supported. Multiple post data elements are not supported and
  // elements of type PDE_TYPE_FILE are only supported for requests originating
  // from the browser process. Requests originating from the render process will
  // receive the same handling as requests originating from Web content -- if the
  // response contains Content-Disposition or Mime-Type header values that would
  // not normally be rendered then the response may receive special handling
  // inside the browser (for example, via the file download code path instead of
  // the URL request code path). The |request| object will be marked as read-only
  // after calling this function. In the browser process if |request_context| is
  // NULL the global request context will be used. In the render process
  // |request_context| must be NULL and the context associated with the current
  // renderer process' browser will be used.
  cef_urlrequest_create: function(request: PCefRequest; client: PCefUrlRequestClient;
    request_context: PCefRequestContext): PCefUrlRequest; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Visit web plugin information.
  cef_visit_web_plugin_info: procedure(visitor: PCefWebPluginInfoVisitor); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Cause the plugin list to refresh the next time it is accessed regardless of
  // whether it has already been loaded. Can be called on any thread in the
  // browser process.
  cef_refresh_web_plugins: procedure; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a plugin path (directory + file). This change may not take affect until
  // after cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_add_web_plugin_path: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a plugin directory. This change may not take affect until after
  // cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_add_web_plugin_directory: procedure(const dir: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Remove a plugin path (directory + file). This change may not take affect
  // until after cef_refresh_web_plugins() is called. Can be called on any thread
  // in the browser process.
  cef_remove_web_plugin_path: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Unregister an internal plugin. This may be undone the next time
  // cef_refresh_web_plugins() is called. Can be called on any thread in the
  // browser process.
  cef_unregister_internal_web_plugin: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Force a plugin to shutdown. Can be called on any thread in the browser
  // process but will be executed on the IO thread.
  cef_force_web_plugin_shutdown: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Register a plugin crash. Can be called on any thread in the browser process
  // but will be executed on the IO thread.
  cef_register_web_plugin_crash: procedure(const path: PCefString); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Query if a plugin is unstable. Can be called on any thread in the browser
  // process.
  cef_is_web_plugin_unstable: procedure(const path: PCefString;
    callback: PCefWebPluginUnstableCallback); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Request a one-time geolocation update. This function bypasses any user
  // permission checks so should only be used by code that is allowed to access
  // location information.
  cef_get_geolocation: function(callback: PCefGetGeolocationCallback): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the task runner for the current thread. Only CEF threads will have
  // task runners. An NULL reference will be returned if this function is called
  // on an invalid thread.
  cef_task_runner_get_for_current_thread: function: PCefTaskRunner; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the task runner for the specified CEF thread.
  cef_task_runner_get_for_thread: function(threadId: TCefThreadId): PCefTaskRunner; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // Start tracing events on all processes. Tracing is initialized asynchronously
  // and |callback| will be executed on the UI thread after initialization is
  // complete.
  //
  // If CefBeginTracing was called previously, or if a CefEndTracingAsync call is
  // pending, CefBeginTracing will fail and return false (0).
  //
  // |categories| is a comma-delimited list of category wildcards. A category can
  // have an optional '-' prefix to make it an excluded category. Having both
  // included and excluded categories in the same list is not supported.
  //
  // Example: "test_MyTest*" Example: "test_MyTest*,test_OtherStuff" Example:
  // "-excluded_category1,-excluded_category2"
  //
  // This function must be called on the browser process UI thread.

  cef_begin_tracing: function(const categories: PCefString;
    callback: PCefCompletionCallback): Integer;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Stop tracing events on all processes.
  //
  // This function will fail and return false (0) if a previous call to
  // CefEndTracingAsync is already pending or if CefBeginTracing was not called.
  //
  // |tracing_file| is the path at which tracing data will be written and
  // |callback| is the callback that will be executed once all processes have sent
  // their trace data. If |tracing_file| is NULL a new temporary file path will be
  // used. If |callback| is NULL no trace data will be written.
  //
  // This function must be called on the browser process UI thread.

  cef_end_tracing: function(const tracing_file: PCefString;
    callback: PCefEndTracingCallback): Integer;
    {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the current system trace time or, if none is defined, the current
  // high-res time. Can be used by clients to synchronize with the time
  // information in trace events.
  cef_now_from_system_trace_time: function: int64; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  // Returns the global context object.
  cef_request_context_get_global_context: function: PCefRequestContext; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new context object with the specified |settings| and optional
  // |handler|.
  cef_request_context_create_context: function(const settings: PCefRequestContextSettings;
    handler: PCefRequestContextHandler): PCefRequestContext; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Creates a new context object that shares storage with |other| and uses an
  // optional |handler|.
  create_context_shared: function(other: PCefRequestContext;
    handler: PCefRequestContextHandler): PCefRequestContext;
      {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // See include/base/cef_logging.h for macros and intended usage.

  // Gets the current log level.
  cef_get_min_log_level: function(): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Gets the current vlog level for the given file (usually taken from
  // __FILE__). Note that |N| is the size *with* the null terminator.
  cef_get_vlog_level: function(const file_start: PAnsiChar; N: NativeInt): Integer; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Add a log message. See the LogSeverity defines for supported |severity|
  // values.
  cef_log: procedure(const file_: PAnsiChar; line, severity: Integer; const message: PAnsiChar); {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // Returns the current platform thread ID.
  cef_get_current_platform_thread_id: function(): TCefPlatformThreadId; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the current platform thread handle.
  cef_get_current_platform_thread_handle: function(): TCefPlatformThreadHandle; {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};



  // See include/base/cef_trace_event.h for macros and intended usage.

  // Functions for tracing counters and functions; called from macros.
  // - |category| string must have application lifetime (static or literal). They
  //   may not include "(quotes) chars.
  // - |argX_name|, |argX_val|, |valueX_name|, |valeX_val| are optional parameters
  //   and represent pairs of name and values of arguments
  // - |copy| is used to avoid memory scoping issues with the |name| and
  //   |arg_name| parameters by copying them
  // - |id| is used to disambiguate counters with the same name, or match async
  //   trace events

  cef_trace_event_instant: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: uint64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_begin: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: UInt64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_end: procedure(const category, name, arg1_name: PAnsiChar;
    arg1_val: UInt64; const arg2_name: PAnsiChar; arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_counter: procedure(const category, name, value1_name: PAnsiChar;
    value1_val: UInt64; const value2_name: PAnsiChar; value2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_counter_id: procedure(const category, name: PAnsiChar; id: UInt64;
    const value1_name: PAnsiChar; value1_val: UInt64; const value2_name: PAnsiChar;
    value2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_begin: procedure(const category, name: PAnsiChar; id: UInt64;
    const arg1_name: PAnsiChar; arg1_val: UInt64; const arg2_name: PAnsiChar;
    arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_step_into: procedure(const category, name: PAnsiChar;
    id, step: UInt64; const arg1_name: PAnsiChar; arg1_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_step_past: procedure(const category, name: PAnsiChar;
    id, step: UInt64; const arg1_name: PAnsiChar; arg1_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  cef_trace_event_async_end: procedure(const category, name: PAnsiChar; id: UInt64;
    const arg1_name: PAnsiChar; arg1_val: UInt64; const arg2_name: PAnsiChar;
    arg2_val: UInt64; copy: Integer);
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  cef_print_settings_create: function(): PCefPrintSettings;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


  cef_drag_data_create: function(): PCefDragData;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};

  // Returns the global resource bundle instance.
  cef_resource_bundle_get_global: function(): PCefResourceBundle;
  {$IFDEF CPUX64}stdcall{$ELSE}cdecl{$ENDIF};


var
  LibHandle: THandle = 0;
  CefIsMainProcess: Boolean = False;

function CefLoadLibDefault: Boolean;
begin
  if LibHandle = 0 then
    Result := CefLoadLib(CefCache, CefUserDataPath, CefUserAgent, CefProductVersion,
      CefLocale, CefLogFile, CefBrowserSubprocessPath, CefLogSeverity, CefJavaScriptFlags,
      CefResourcesDirPath, CefLocalesDirPath, CefSingleProcess, CefNoSandbox,
      CefCommandLineArgsDisabled, CefPackLoadingDisabled, CefRemoteDebuggingPort,
      CefUncaughtExceptionStackSize, CefContextSafetyImplementation,
      CefPersistSessionCookies, CefIgnoreCertificateErrors, CefBackgroundColor,
      CefAcceptLanguageList, CefWindowsSandboxInfo, CefWindowlessRenderingEnabled) else
    Result := True;
end;

function CefLoadLib(const Cache, UserDataPath, UserAgent, ProductVersion, Locale, LogFile, BrowserSubprocessPath: ustring;
  LogSeverity: TCefLogSeverity; JavaScriptFlags, ResourcesDirPath, LocalesDirPath: ustring;
  SingleProcess, NoSandbox, CommandLineArgsDisabled, PackLoadingDisabled: Boolean; RemoteDebuggingPort: Integer;
  UncaughtExceptionStackSize: Integer; ContextSafetyImplementation: Integer;
  PersistSessionCookies: Boolean; IgnoreCertificateErrors: Boolean; BackgroundColor: TCefColor;
  const AcceptLanguageList: ustring; WindowsSandboxInfo: Pointer; WindowlessRenderingEnabled: Boolean): Boolean;
var
  settings: TCefSettings;
  app: ICefApp;
  errcode: Integer;
begin
  if LibHandle = 0 then
  begin
    // deactivate FPU exception FPU & SSE2
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);

    LibHandle := LoadLibrary(PChar(CefLibrary));
    if LibHandle = 0 then
      RaiseLastOSError;

    cef_string_wide_set := GetProcAddress(LibHandle, 'cef_string_wide_set');
    cef_string_utf8_set := GetProcAddress(LibHandle, 'cef_string_utf8_set');
    cef_string_utf16_set := GetProcAddress(LibHandle, 'cef_string_utf16_set');
    cef_string_wide_clear := GetProcAddress(LibHandle, 'cef_string_wide_clear');
    cef_string_utf8_clear := GetProcAddress(LibHandle, 'cef_string_utf8_clear');
    cef_string_utf16_clear := GetProcAddress(LibHandle, 'cef_string_utf16_clear');
    cef_string_wide_cmp := GetProcAddress(LibHandle, 'cef_string_wide_cmp');
    cef_string_utf8_cmp := GetProcAddress(LibHandle, 'cef_string_utf8_cmp');
    cef_string_utf16_cmp := GetProcAddress(LibHandle, 'cef_string_utf16_cmp');
    cef_string_wide_to_utf8 := GetProcAddress(LibHandle, 'cef_string_wide_to_utf8');
    cef_string_utf8_to_wide := GetProcAddress(LibHandle, 'cef_string_utf8_to_wide');
    cef_string_wide_to_utf16 := GetProcAddress(LibHandle, 'cef_string_wide_to_utf16');
    cef_string_utf16_to_wide := GetProcAddress(LibHandle, 'cef_string_utf16_to_wide');
    cef_string_utf8_to_utf16 := GetProcAddress(LibHandle, 'cef_string_utf8_to_utf16');
    cef_string_utf16_to_utf8 := GetProcAddress(LibHandle, 'cef_string_utf16_to_utf8');
    cef_string_ascii_to_wide := GetProcAddress(LibHandle, 'cef_string_ascii_to_wide');
    cef_string_ascii_to_utf16 := GetProcAddress(LibHandle, 'cef_string_ascii_to_utf16');
    cef_string_userfree_wide_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_wide_alloc');
    cef_string_userfree_utf8_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_utf8_alloc');
    cef_string_userfree_utf16_alloc := GetProcAddress(LibHandle, 'cef_string_userfree_utf16_alloc');
    cef_string_userfree_wide_free := GetProcAddress(LibHandle, 'cef_string_userfree_wide_free');
    cef_string_userfree_utf8_free := GetProcAddress(LibHandle, 'cef_string_userfree_utf8_free');
    cef_string_userfree_utf16_free := GetProcAddress(LibHandle, 'cef_string_userfree_utf16_free');

{$IFDEF CEF_STRING_TYPE_UTF8}
  cef_string_set := cef_string_utf8_set;
  cef_string_clear := cef_string_utf8_clear;
  cef_string_userfree_alloc := cef_string_userfree_utf8_alloc;
  cef_string_userfree_free := cef_string_userfree_utf8_free;
  cef_string_from_ascii := cef_string_utf8_copy;
  cef_string_to_utf8 := cef_string_utf8_copy;
  cef_string_from_utf8 := cef_string_utf8_copy;
  cef_string_to_utf16 := cef_string_utf8_to_utf16;
  cef_string_from_utf16 := cef_string_utf16_to_utf8;
  cef_string_to_wide := cef_string_utf8_to_wide;
  cef_string_from_wide := cef_string_wide_to_utf8;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_UTF16}
    cef_string_set := cef_string_utf16_set;
    cef_string_clear := cef_string_utf16_clear;
    cef_string_userfree_alloc := cef_string_userfree_utf16_alloc;
    cef_string_userfree_free := cef_string_userfree_utf16_free;
    cef_string_from_ascii := cef_string_ascii_to_utf16;
    cef_string_to_utf8 := cef_string_utf16_to_utf8;
    cef_string_from_utf8 := cef_string_utf8_to_utf16;
    cef_string_to_utf16 := cef_string_utf16_copy;
    cef_string_from_utf16 := cef_string_utf16_copy;
    cef_string_to_wide := cef_string_utf16_to_wide;
    cef_string_from_wide := cef_string_wide_to_utf16;
{$ENDIF}

{$IFDEF CEF_STRING_TYPE_WIDE}
    cef_string_set := cef_string_wide_set;
    cef_string_clear := cef_string_wide_clear;
    cef_string_userfree_alloc := cef_string_userfree_wide_alloc;
    cef_string_userfree_free := cef_string_userfree_wide_free;
    cef_string_from_ascii := cef_string_ascii_to_wide;
    cef_string_to_utf8 := cef_string_wide_to_utf8;
    cef_string_from_utf8 := cef_string_utf8_to_wide;
    cef_string_to_utf16 := cef_string_wide_to_utf16;
    cef_string_from_utf16 := cef_string_utf16_to_wide;
    cef_string_to_wide := cef_string_wide_copy;
    cef_string_from_wide := cef_string_wide_copy;
{$ENDIF}

    cef_string_map_alloc := GetProcAddress(LibHandle, 'cef_string_map_alloc');
    cef_string_map_size := GetProcAddress(LibHandle, 'cef_string_map_size');
    cef_string_map_find := GetProcAddress(LibHandle, 'cef_string_map_find');
    cef_string_map_key := GetProcAddress(LibHandle, 'cef_string_map_key');
    cef_string_map_value := GetProcAddress(LibHandle, 'cef_string_map_value');
    cef_string_map_append := GetProcAddress(LibHandle, 'cef_string_map_append');
    cef_string_map_clear := GetProcAddress(LibHandle, 'cef_string_map_clear');
    cef_string_map_free := GetProcAddress(LibHandle, 'cef_string_map_free');
    cef_string_list_alloc := GetProcAddress(LibHandle, 'cef_string_list_alloc');
    cef_string_list_size := GetProcAddress(LibHandle, 'cef_string_list_size');
    cef_string_list_value := GetProcAddress(LibHandle, 'cef_string_list_value');
    cef_string_list_append := GetProcAddress(LibHandle, 'cef_string_list_append');
    cef_string_list_clear := GetProcAddress(LibHandle, 'cef_string_list_clear');
    cef_string_list_free := GetProcAddress(LibHandle, 'cef_string_list_free');
    cef_string_list_copy := GetProcAddress(LibHandle, 'cef_string_list_copy');
    cef_initialize := GetProcAddress(LibHandle, 'cef_initialize');
    cef_execute_process := GetProcAddress(LibHandle, 'cef_execute_process');
    cef_shutdown := GetProcAddress(LibHandle, 'cef_shutdown');
    cef_do_message_loop_work := GetProcAddress(LibHandle, 'cef_do_message_loop_work');
    cef_run_message_loop := GetProcAddress(LibHandle, 'cef_run_message_loop');
    cef_quit_message_loop := GetProcAddress(LibHandle, 'cef_quit_message_loop');
    cef_set_osmodal_loop := GetProcAddress(LibHandle, 'cef_set_osmodal_loop');
    cef_enable_highdpi_support := GetProcAddress(LibHandle, 'cef_enable_highdpi_support');
    cef_register_extension := GetProcAddress(LibHandle, 'cef_register_extension');
    cef_register_scheme_handler_factory := GetProcAddress(LibHandle, 'cef_register_scheme_handler_factory');
    cef_clear_scheme_handler_factories := GetProcAddress(LibHandle, 'cef_clear_scheme_handler_factories');
    cef_add_cross_origin_whitelist_entry := GetProcAddress(LibHandle, 'cef_add_cross_origin_whitelist_entry');
    cef_remove_cross_origin_whitelist_entry := GetProcAddress(LibHandle, 'cef_remove_cross_origin_whitelist_entry');
    cef_clear_cross_origin_whitelist := GetProcAddress(LibHandle, 'cef_clear_cross_origin_whitelist');
    cef_currently_on := GetProcAddress(LibHandle, 'cef_currently_on');
    cef_post_task := GetProcAddress(LibHandle, 'cef_post_task');
    cef_post_delayed_task := GetProcAddress(LibHandle, 'cef_post_delayed_task');
    cef_parse_url := GetProcAddress(LibHandle, 'cef_parse_url');
    cef_create_url := GetProcAddress(LibHandle, 'cef_create_url');
    cef_get_mime_type := GetProcAddress(LibHandle, 'cef_get_mime_type');
    cef_get_extensions_for_mime_type := GetProcAddress(LibHandle, 'cef_get_extensions_for_mime_type');
    cef_base64encode := GetProcAddress(LibHandle, 'cef_base64encode');
    cef_base64decode := GetProcAddress(LibHandle, 'cef_base64decode');
    cef_uriencode := GetProcAddress(LibHandle, 'cef_uriencode');
    cef_uridecode := GetProcAddress(LibHandle, 'cef_uridecode');
    cef_parse_csscolor := GetProcAddress(LibHandle, 'cef_parse_csscolor');
{$ifdef Win32}
    cef_parse_json := GetProcAddress(LibHandle, 'cef_parse_json');
    cef_parse_jsonand_return_error := GetProcAddress(LibHandle, 'cef_parse_jsonand_return_error');
    cef_write_json := GetProcAddress(LibHandle, 'cef_write_json');
{$endif}
    cef_browser_host_create_browser := GetProcAddress(LibHandle, 'cef_browser_host_create_browser');
    cef_browser_host_create_browser_sync := GetProcAddress(LibHandle, 'cef_browser_host_create_browser_sync');
    cef_request_create := GetProcAddress(LibHandle, 'cef_request_create');
    cef_post_data_create := GetProcAddress(LibHandle, 'cef_post_data_create');
    cef_post_data_element_create := GetProcAddress(LibHandle, 'cef_post_data_element_create');
    cef_stream_reader_create_for_file := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_file');
    cef_stream_reader_create_for_data := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_data');
    cef_stream_reader_create_for_handler := GetProcAddress(LibHandle, 'cef_stream_reader_create_for_handler');
    cef_stream_writer_create_for_file := GetProcAddress(LibHandle, 'cef_stream_writer_create_for_file');
    cef_stream_writer_create_for_handler := GetProcAddress(LibHandle, 'cef_stream_writer_create_for_handler');
    cef_v8context_get_current_context := GetProcAddress(LibHandle, 'cef_v8context_get_current_context');
    cef_v8context_get_entered_context := GetProcAddress(LibHandle, 'cef_v8context_get_entered_context');
    cef_v8context_in_context := GetProcAddress(LibHandle, 'cef_v8context_in_context');
    cef_v8value_create_undefined := GetProcAddress(LibHandle, 'cef_v8value_create_undefined');
    cef_v8value_create_null := GetProcAddress(LibHandle, 'cef_v8value_create_null');
    cef_v8value_create_bool := GetProcAddress(LibHandle, 'cef_v8value_create_bool');
    cef_v8value_create_int := GetProcAddress(LibHandle, 'cef_v8value_create_int');
    cef_v8value_create_uint := GetProcAddress(LibHandle, 'cef_v8value_create_uint');
    cef_v8value_create_double := GetProcAddress(LibHandle, 'cef_v8value_create_double');
    cef_v8value_create_date := GetProcAddress(LibHandle, 'cef_v8value_create_date');
    cef_v8value_create_string := GetProcAddress(LibHandle, 'cef_v8value_create_string');
    cef_v8value_create_object := GetProcAddress(LibHandle, 'cef_v8value_create_object');
    cef_v8value_create_array := GetProcAddress(LibHandle, 'cef_v8value_create_array');
    cef_v8value_create_function := GetProcAddress(LibHandle, 'cef_v8value_create_function');
    cef_v8stack_trace_get_current := GetProcAddress(LibHandle, 'cef_v8stack_trace_get_current');
    cef_xml_reader_create := GetProcAddress(LibHandle, 'cef_xml_reader_create');
    cef_zip_reader_create := GetProcAddress(LibHandle, 'cef_zip_reader_create');

    cef_string_multimap_alloc := GetProcAddress(LibHandle, 'cef_string_multimap_alloc');
    cef_string_multimap_size := GetProcAddress(LibHandle, 'cef_string_multimap_size');
    cef_string_multimap_find_count := GetProcAddress(LibHandle, 'cef_string_multimap_find_count');
    cef_string_multimap_enumerate := GetProcAddress(LibHandle, 'cef_string_multimap_enumerate');
    cef_string_multimap_key := GetProcAddress(LibHandle, 'cef_string_multimap_key');
    cef_string_multimap_value := GetProcAddress(LibHandle, 'cef_string_multimap_value');
    cef_string_multimap_append := GetProcAddress(LibHandle, 'cef_string_multimap_append');
    cef_string_multimap_clear := GetProcAddress(LibHandle, 'cef_string_multimap_clear');
    cef_string_multimap_free := GetProcAddress(LibHandle, 'cef_string_multimap_free');

    cef_cookie_manager_get_global_manager := GetProcAddress(LibHandle, 'cef_cookie_manager_get_global_manager');
    cef_cookie_manager_create_manager := GetProcAddress(LibHandle, 'cef_cookie_manager_create_manager');


    cef_command_line_create := GetProcAddress(LibHandle, 'cef_command_line_create');

    cef_command_line_get_global := GetProcAddress(LibHandle, 'cef_command_line_get_global');

    cef_process_message_create := GetProcAddress(LibHandle, 'cef_process_message_create');

    cef_value_create := GetProcAddress(LibHandle, 'cef_value_create');

    cef_binary_value_create := GetProcAddress(LibHandle, 'cef_binary_value_create');

    cef_dictionary_value_create := GetProcAddress(LibHandle, 'cef_dictionary_value_create');

    cef_list_value_create := GetProcAddress(LibHandle, 'cef_list_value_create');

    cef_get_path := GetProcAddress(LibHandle, 'cef_get_path');

    cef_launch_process := GetProcAddress(LibHandle, 'cef_launch_process');

    cef_response_create := GetProcAddress(LibHandle, 'cef_response_create');

    cef_urlrequest_create := GetProcAddress(LibHandle, 'cef_urlrequest_create');

    cef_visit_web_plugin_info := GetProcAddress(LibHandle, 'cef_visit_web_plugin_info');
    cef_refresh_web_plugins := GetProcAddress(LibHandle, 'cef_refresh_web_plugins');
    cef_add_web_plugin_path := GetProcAddress(LibHandle, 'cef_add_web_plugin_path');
    cef_add_web_plugin_directory := GetProcAddress(LibHandle, 'cef_add_web_plugin_directory');
    cef_remove_web_plugin_path := GetProcAddress(LibHandle, 'cef_remove_web_plugin_path');
    cef_unregister_internal_web_plugin := GetProcAddress(LibHandle, 'cef_unregister_internal_web_plugin');
    cef_force_web_plugin_shutdown := GetProcAddress(LibHandle, 'cef_force_web_plugin_shutdown');
    cef_register_web_plugin_crash := GetProcAddress(LibHandle, 'cef_register_web_plugin_crash');
    cef_is_web_plugin_unstable := GetProcAddress(LibHandle, 'cef_is_web_plugin_unstable');

    cef_get_geolocation := GetProcAddress(LibHandle, 'cef_get_geolocation');

    cef_task_runner_get_for_current_thread := GetProcAddress(LibHandle, 'cef_task_runner_get_for_current_thread');
    cef_task_runner_get_for_thread := GetProcAddress(LibHandle, 'cef_task_runner_get_for_thread');

    cef_begin_tracing := GetProcAddress(LibHandle, 'cef_begin_tracing');
    cef_end_tracing := GetProcAddress(LibHandle, 'cef_end_tracing');
    cef_now_from_system_trace_time := GetProcAddress(LibHandle, 'cef_now_from_system_trace_time');

    cef_request_context_get_global_context := GetProcAddress(LibHandle, 'cef_request_context_get_global_context');
    cef_request_context_create_context := GetProcAddress(LibHandle, 'cef_request_context_create_context');
    create_context_shared := GetProcAddress(LibHandle, 'create_context_shared');

    cef_get_min_log_level := GetProcAddress(LibHandle, 'cef_get_min_log_level');
    cef_get_vlog_level := GetProcAddress(LibHandle, 'cef_get_vlog_level');
    cef_log := GetProcAddress(LibHandle, 'cef_log');

    cef_get_current_platform_thread_id := GetProcAddress(LibHandle, 'cef_get_current_platform_thread_id');
    cef_get_current_platform_thread_handle := GetProcAddress(LibHandle, 'cef_get_current_platform_thread_handle');

    cef_trace_event_instant := GetProcAddress(LibHandle, 'cef_trace_event_instant');
    cef_trace_event_begin := GetProcAddress(LibHandle, 'cef_trace_event_begin');
    cef_trace_event_end := GetProcAddress(LibHandle, 'cef_trace_event_end');
    cef_trace_counter := GetProcAddress(LibHandle, 'cef_trace_counter');
    cef_trace_counter_id := GetProcAddress(LibHandle, 'cef_trace_counter_id');
    cef_trace_event_async_begin := GetProcAddress(LibHandle, 'cef_trace_event_async_begin');
    cef_trace_event_async_step_into := GetProcAddress(LibHandle, 'cef_trace_event_async_step_into');
    cef_trace_event_async_step_past := GetProcAddress(LibHandle, 'cef_trace_event_async_step_past');
    cef_trace_event_async_end := GetProcAddress(LibHandle, 'cef_trace_event_async_end');

    cef_print_settings_create := GetProcAddress(LibHandle, 'cef_print_settings_create');

    cef_drag_data_create := GetProcAddress(LibHandle, 'cef_drag_data_create');

    cef_resource_bundle_get_global := GetProcAddress(LibHandle, 'cef_resource_bundle_get_global');

    if not (
      Assigned(cef_string_wide_set) and
      Assigned(cef_string_utf8_set) and
      Assigned(cef_string_utf16_set) and
      Assigned(cef_string_wide_clear) and
      Assigned(cef_string_utf8_clear) and
      Assigned(cef_string_utf16_clear) and
      Assigned(cef_string_wide_cmp) and
      Assigned(cef_string_utf8_cmp) and
      Assigned(cef_string_utf16_cmp) and
      Assigned(cef_string_wide_to_utf8) and
      Assigned(cef_string_utf8_to_wide) and
      Assigned(cef_string_wide_to_utf16) and
      Assigned(cef_string_utf16_to_wide) and
      Assigned(cef_string_utf8_to_utf16) and
      Assigned(cef_string_utf16_to_utf8) and
      Assigned(cef_string_ascii_to_wide) and
      Assigned(cef_string_ascii_to_utf16) and
      Assigned(cef_string_userfree_wide_alloc) and
      Assigned(cef_string_userfree_utf8_alloc) and
      Assigned(cef_string_userfree_utf16_alloc) and
      Assigned(cef_string_userfree_wide_free) and
      Assigned(cef_string_userfree_utf8_free) and
      Assigned(cef_string_userfree_utf16_free) and
      Assigned(cef_string_map_alloc) and
      Assigned(cef_string_map_size) and
      Assigned(cef_string_map_find) and
      Assigned(cef_string_map_key) and
      Assigned(cef_string_map_value) and
      Assigned(cef_string_map_append) and
      Assigned(cef_string_map_clear) and
      Assigned(cef_string_map_free) and
      Assigned(cef_string_list_alloc) and
      Assigned(cef_string_list_size) and
      Assigned(cef_string_list_value) and
      Assigned(cef_string_list_append) and
      Assigned(cef_string_list_clear) and
      Assigned(cef_string_list_free) and
      Assigned(cef_string_list_copy) and
      Assigned(cef_initialize) and
      Assigned(cef_execute_process) and
      Assigned(cef_shutdown) and
      Assigned(cef_do_message_loop_work) and
      Assigned(cef_run_message_loop) and
      Assigned(cef_quit_message_loop) and
      Assigned(cef_set_osmodal_loop) and
      Assigned(cef_enable_highdpi_support) and
      Assigned(cef_register_extension) and
      Assigned(cef_register_scheme_handler_factory) and
      Assigned(cef_clear_scheme_handler_factories) and
      Assigned(cef_add_cross_origin_whitelist_entry) and
      Assigned(cef_remove_cross_origin_whitelist_entry) and
      Assigned(cef_clear_cross_origin_whitelist) and
      Assigned(cef_currently_on) and
      Assigned(cef_post_task) and
      Assigned(cef_post_delayed_task) and
      Assigned(cef_parse_url) and
      Assigned(cef_create_url) and
      Assigned(cef_get_mime_type) and
      Assigned(cef_get_extensions_for_mime_type) and
      Assigned(cef_base64encode) and
      Assigned(cef_base64decode) and
      Assigned(cef_uriencode) and
      Assigned(cef_uridecode) and
      Assigned(cef_parse_csscolor) and
{$ifdef Win32}
      Assigned(cef_parse_json) and
      Assigned(cef_parse_jsonand_return_error) and
      Assigned(cef_write_json) and
{$endif}
      Assigned(cef_browser_host_create_browser) and
      Assigned(cef_browser_host_create_browser_sync) and
      Assigned(cef_request_create) and
      Assigned(cef_post_data_create) and
      Assigned(cef_post_data_element_create) and
      Assigned(cef_stream_reader_create_for_file) and
      Assigned(cef_stream_reader_create_for_data) and
      Assigned(cef_stream_reader_create_for_handler) and
      Assigned(cef_stream_writer_create_for_file) and
      Assigned(cef_stream_writer_create_for_handler) and
      Assigned(cef_v8context_get_current_context) and
      Assigned(cef_v8context_get_entered_context) and
      Assigned(cef_v8context_in_context) and
      Assigned(cef_v8value_create_undefined) and
      Assigned(cef_v8value_create_null) and
      Assigned(cef_v8value_create_bool) and
      Assigned(cef_v8value_create_int) and
      Assigned(cef_v8value_create_uint) and
      Assigned(cef_v8value_create_double) and
      Assigned(cef_v8value_create_date) and
      Assigned(cef_v8value_create_string) and
      Assigned(cef_v8value_create_object) and
      Assigned(cef_v8value_create_array) and
      Assigned(cef_v8value_create_function) and
      Assigned(cef_v8stack_trace_get_current) and
      Assigned(cef_xml_reader_create) and
      Assigned(cef_zip_reader_create) and
      Assigned(cef_string_multimap_alloc) and
      Assigned(cef_string_multimap_size) and
      Assigned(cef_string_multimap_find_count) and
      Assigned(cef_string_multimap_enumerate) and
      Assigned(cef_string_multimap_key) and
      Assigned(cef_string_multimap_value) and
      Assigned(cef_string_multimap_append) and
      Assigned(cef_string_multimap_clear) and
      Assigned(cef_string_multimap_free) and
      Assigned(cef_cookie_manager_get_global_manager) and
      Assigned(cef_cookie_manager_create_manager) and
      Assigned(cef_command_line_create) and
      Assigned(cef_command_line_get_global) and
      Assigned(cef_process_message_create) and
      Assigned(cef_value_create) and
      Assigned(cef_binary_value_create) and
      Assigned(cef_dictionary_value_create) and
      Assigned(cef_list_value_create) and
      Assigned(cef_get_path) and
      Assigned(cef_launch_process) and
      Assigned(cef_response_create) and
      Assigned(cef_urlrequest_create) and
      Assigned(cef_visit_web_plugin_info) and
      Assigned(cef_refresh_web_plugins) and
      Assigned(cef_add_web_plugin_path) and
      Assigned(cef_add_web_plugin_directory) and
      Assigned(cef_remove_web_plugin_path) and
      Assigned(cef_unregister_internal_web_plugin) and
      Assigned(cef_force_web_plugin_shutdown) and
      Assigned(cef_register_web_plugin_crash) and
      Assigned(cef_is_web_plugin_unstable) and
      Assigned(cef_get_geolocation) and
      Assigned(cef_task_runner_get_for_current_thread) and
      Assigned(cef_task_runner_get_for_thread) and
      Assigned(cef_begin_tracing) and
      Assigned(cef_end_tracing) and
      Assigned(cef_now_from_system_trace_time) and
      Assigned(cef_request_context_get_global_context) and
      Assigned(cef_request_context_create_context) and
      Assigned(create_context_shared) and
      Assigned(cef_get_min_log_level) and
      Assigned(cef_get_vlog_level) and
      Assigned(cef_log) and
      Assigned(cef_get_current_platform_thread_id) and
      Assigned(cef_get_current_platform_thread_handle) and
      Assigned(cef_trace_event_instant) and
      Assigned(cef_trace_event_begin) and
      Assigned(cef_trace_event_end) and
      Assigned(cef_trace_counter) and
      Assigned(cef_trace_counter_id) and
      Assigned(cef_trace_event_async_begin) and
      Assigned(cef_trace_event_async_step_into) and
      Assigned(cef_trace_event_async_step_past) and
      Assigned(cef_trace_event_async_end) and
      Assigned(cef_print_settings_create) and
      Assigned(cef_drag_data_create) and
      Assigned(cef_resource_bundle_get_global)
    ) then raise ECefException.Create('Invalid CEF Library version');

    FillChar(settings, SizeOf(settings), 0);
    settings.size := SizeOf(settings);
    settings.single_process := Ord(SingleProcess);
    settings.no_sandbox := Ord(NoSandbox);
{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    settings.multi_threaded_message_loop := Ord(False);
{$ELSE}
    settings.multi_threaded_message_loop := Ord(True);
{$ENDIF}
    settings.windowless_rendering_enabled := Ord(WindowlessRenderingEnabled);
    settings.cache_path := CefString(Cache);
    settings.user_data_path := CefString(UserDataPath);
    settings.persist_session_cookies := Ord(PersistSessionCookies);
    settings.browser_subprocess_path := CefString(BrowserSubprocessPath);
    settings.command_line_args_disabled := Ord(CommandLineArgsDisabled);
    settings.user_agent := cefstring(UserAgent);
    settings.product_version := CefString(ProductVersion);
    settings.locale := CefString(Locale);
    settings.log_file := CefString(LogFile);
    settings.log_severity := LogSeverity;
    settings.javascript_flags := CefString(JavaScriptFlags);
    settings.resources_dir_path := CefString(ResourcesDirPath);
    settings.locales_dir_path := CefString(LocalesDirPath);
    settings.pack_loading_disabled := Ord(PackLoadingDisabled);
    settings.remote_debugging_port := RemoteDebuggingPort;
    settings.uncaught_exception_stack_size := UncaughtExceptionStackSize;
    settings.context_safety_implementation := ContextSafetyImplementation;
    settings.ignore_certificate_errors := Ord(IgnoreCertificateErrors);
    settings.background_color := BackgroundColor;
    settings.accept_language_list := CefString(AcceptLanguageList);

    app := TInternalApp.Create;
    errcode := cef_execute_process(@HInstance, CefGetData(app), WindowsSandboxInfo);
    if errcode >= 0 then
    begin
      Result := False;
      Exit;
    end;
    cef_initialize(@HInstance, @settings, CefGetData(app), WindowsSandboxInfo);
    CefIsMainProcess := True;
  end;
  Result := True;
end;

{$IFNDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
procedure CefDoMessageLoopWork;
begin
  if LibHandle > 0 then
    cef_do_message_loop_work;
end;

procedure CefRunMessageLoop;
begin
  if LibHandle > 0 then
    cef_run_message_loop;
end;

procedure CefQuitMessageLoop;
begin
  cef_quit_message_loop;
end;

procedure CefSetOsModalLoop(loop: Boolean);
begin
  cef_set_osmodal_loop(Ord(loop));
end;
{$ENDIF}

procedure CefEnableHighDpiSupport;
begin
  cef_enable_highdpi_support();
end;

procedure CefShutDown;
begin
  if LibHandle <> 0 then
  begin
    if CefIsMainProcess then
      cef_shutdown;
    FreeLibrary(LibHandle);
    LibHandle := 0;
  end;
end;

function CefString(const str: ustring): TCefString;
begin
   Result.str := PChar16(PWideChar(str));
   Result.length := Length(str);
   Result.dtor := nil;
end;

function CefString(const str: PCefString): ustring;
begin
  if str <> nil then
    SetString(Result, str.str, str.length) else
    Result := '';
end;

procedure _free_string(str: PChar16); stdcall;
begin
  if str <> nil then
    FreeMem(str);
end;

function CefUserFreeString(const str: ustring): PCefStringUserFree;
begin
  Result := cef_string_userfree_alloc;
  Result.length := Length(str);
  GetMem(Result.str, Result.length * SizeOf(TCefChar));
  Move(PCefChar(str)^, Result.str^, Result.length * SizeOf(TCefChar));
  Result.dtor := @_free_string;
end;

function CefStringAlloc(const str: ustring): TCefString;
begin
  FillChar(Result, SizeOf(Result), 0);
  if str <> '' then
    cef_string_from_wide(PWideChar(str), Length(str), @Result);
end;

procedure CefStringSet(const str: PCefString; const value: ustring);
begin
  if str <> nil then
    cef_string_set(PWideChar(value), Length(value), str, 1);
end;

function CefStringClearAndGet(var str: TCefString): ustring;
begin
  Result := CefString(@str);
  cef_string_clear(@str);
end;

function CefStringFreeAndGet(const str: PCefStringUserFree): ustring;
begin
  if str <> nil then
  begin
    Result := CefString(PCefString(str));
    cef_string_userfree_free(str);
  end else
    Result := '';
end;

procedure CefStringFree(const str: PCefString);
begin
  if str <> nil then
    cef_string_clear(str);
end;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const handler: TCefResourceHandlerClass): Boolean;
var
  s, h: TCefString;
begin
  CefLoadLibDefault;
  s := CefString(SchemeName);
  h := CefString(HostName);
  Result := cef_register_scheme_handler_factory(
    @s,
    @h,
    CefGetData(TCefSchemeHandlerFactoryOwn.Create(handler) as ICefBase)) <> 0;
end;

function CefRegisterSchemeHandlerFactory(const SchemeName, HostName: ustring;
  const factory: ICefSchemeHandlerFactory): Boolean; overload;
var
  s, h: TCefString;
begin
  CefLoadLibDefault;
  s := CefString(SchemeName);
  h := CefString(HostName);
  Result := cef_register_scheme_handler_factory(
    @s,
    @h,
    CefGetData(factory as ICefBase)) <> 0;
end;

function CefClearSchemeHandlerFactories: Boolean;
begin
  CefLoadLibDefault;
  Result := cef_clear_scheme_handler_factories <> 0;
end;

function CefAddCrossOriginWhitelistEntry(const SourceOrigin, TargetProtocol,
  TargetDomain: ustring; AllowTargetSubdomains: Boolean): Boolean;
var
  so, tp, td: TCefString;
begin
  CefLoadLibDefault;
  so := CefString(SourceOrigin);
  tp := CefString(TargetProtocol);
  td := CefString(TargetDomain);
  Result := cef_add_cross_origin_whitelist_entry(@so, @tp, @td, Ord(AllowTargetSubdomains)) <> 0;
end;

function CefRemoveCrossOriginWhitelistEntry(
  const SourceOrigin, TargetProtocol, TargetDomain: ustring;
  AllowTargetSubdomains: Boolean): Boolean;
var
  so, tp, td: TCefString;
begin
  CefLoadLibDefault;
  so := CefString(SourceOrigin);
  tp := CefString(TargetProtocol);
  td := CefString(TargetDomain);
  Result := cef_remove_cross_origin_whitelist_entry(@so, @tp, @td, Ord(AllowTargetSubdomains)) <> 0;
end;

function CefClearCrossOriginWhitelist: Boolean;
begin
  CefLoadLibDefault;
  Result := cef_clear_cross_origin_whitelist <> 0;
end;

function CefRegisterExtension(const name, code: ustring;
  const Handler: ICefv8Handler): Boolean;
var
  n, c: TCefString;
begin
  CefLoadLibDefault;
  n := CefString(name);
  c := CefString(code);
  Result := cef_register_extension(@n, @c, CefGetData(handler)) <> 0;
end;

function CefCurrentlyOn(ThreadId: TCefThreadId): Boolean;
begin
  Result := cef_currently_on(ThreadId) <> 0;
end;

procedure CefPostTask(ThreadId: TCefThreadId; const task: ICefTask);
begin
  cef_post_task(ThreadId, CefGetData(task));
end;

procedure CefPostDelayedTask(ThreadId: TCefThreadId; const task: ICefTask; delayMs: Int64);
begin
  cef_post_delayed_task(ThreadId, CefGetData(task), delayMs);
end;

function CefGetData(const i: ICefBase): Pointer; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  if i <> nil then
    Result := i.Wrap else
    Result := nil;
end;

function CefGetObject(ptr: Pointer): TObject; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  Dec(PByte(ptr), SizeOf(Pointer));
  Result := TObject(PPointer(ptr)^);
end;

function CefParseUrl(const url: ustring; var parts: TUrlParts): Boolean;
var
  u: TCefString;
  p: TCefUrlParts;
begin
  FillChar(p, sizeof(p), 0);
  u := CefString(url);
  Result := cef_parse_url(@u, p) <> 0;
  if Result then
  begin
    //parts.spec := CefString(@p.spec);
    parts.scheme := CefString(@p.scheme);
    parts.username := CefString(@p.username);
    parts.password := CefString(@p.password);
    parts.host := CefString(@p.host);
    parts.port := CefString(@p.port);
    parts.origin := CefString(@p.origin);
    parts.path := CefString(@p.path);
    parts.query := CefString(@p.query);
  end;
end;

function CefCreateUrl(var parts: TUrlParts): ustring;
var
  p: TCefUrlParts;
  u: TCefString;
begin
  FillChar(p, sizeof(p), 0);
  p.spec := CefString(parts.spec);
  p.scheme := CefString(parts.scheme);
  p.username := CefString(parts.username);
  p.password := CefString(parts.password);
  p.host := CefString(parts.host);
  p.port := CefString(parts.port);
  p.origin := CefString(parts.origin);
  p.path := CefString(parts.path);
  p.query := CefString(parts.query);
  FillChar(u, SizeOf(u), 0);
  if cef_create_url(@p, @u) <> 0 then
    Result := CefString(@u) else
    Result := '';
end;

function CefGetMimeType(const extension: ustring): ustring;
var
  s: TCefString;
begin
  s := CefString(extension);
  Result := CefStringFreeAndGet(cef_get_mime_type(@s))
end;

procedure CefGetExtensionsForMimeType(const mimeType: ustring; extensions: TStringList);
var
  list: TCefStringList;
  s, str: TCefString;
  i: Integer;
begin
  list := cef_string_list_alloc();
  try
    s := CefString(mimeType);
    cef_get_extensions_for_mime_type(@s, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      extensions.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function CefBase64Encode(const data: Pointer; dataSize: NativeUInt): ustring;
begin
  Result:= CefStringFreeAndGet(cef_base64encode(data, dataSize));
end;

function CefBase64Decode(const data: ustring): ICefBinaryValue;
var
  s: TCefString;
begin
  s := CefString(data);
  Result := TCefBinaryValueRef.UnWrap(cef_base64decode(@s));
end;

function CefUriEncode(const text: ustring; usePlus: Boolean): ustring;
var
  s: TCefString;
begin
  s := CefString(text);
  Result := CefStringFreeAndGet(cef_uriencode(@s, Ord(usePlus)));
end;

function CefUriDecode(const text: ustring; convertToUtf8: Boolean;
  unescapeRule: TCefUriUnescapeRule): ustring;
var
  s: TCefString;
begin
  s := CefString(text);
  Result := CefStringFreeAndGet(cef_uridecode(@s, Ord(convertToUtf8), unescapeRule));
end;

function CefParseCssColor(const str: ustring; strict: Boolean; out color: TCefColor): Boolean;
var
  s: TCefString;
begin
  s := CefString(str);
  Result := cef_parse_csscolor(@s, Ord(strict), @color) <> 0;
end;

{$ifdef Win32}
function CefParseJson(const jsonString: ustring; options: TCefJsonParserOptions): ICefValue;
var
  s: TCefString;
begin
  s := CefString(jsonString);
  Result := TCefValueRef.UnWrap(cef_parse_json(@s, options));
end;

function CefParseJsonAndReturnError(const jsonString: ustring; options: TCefJsonParserOptions;
  out errorCodeOut: TCefJsonParserError; out errorMsgOut: ustring): ICefValue;
var
  s, e: TCefString;
begin
  s := CefString(jsonString);
  FillChar(e, SizeOf(e), 0);
  Result := TCefValueRef.UnWrap(cef_parse_jsonand_return_error(@s, options,
    @errorCodeOut, @e));
  errorMsgOut := CefString(@e);
end;

function CefWriteJson(const node: ICefValue; options: TCefJsonWriterOptions): ustring;
begin
  Result := CefStringFreeAndGet(cef_write_json(CefGetData(node), options));
end;
{$endif}

function CefBrowserHostCreate(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): Boolean;
var
  u: TCefString;
begin
  CefLoadLibDefault;
  u := CefString(url);
  Result := cef_browser_host_create_browser(windowInfo, CefGetData(client),
    @u, settings, CefGetData(requestContext)) <> 0;
end;

function CefBrowserHostCreateSync(windowInfo: PCefWindowInfo; const client: ICefClient;
  const url: ustring; const settings: PCefBrowserSettings; const requestContext: ICefRequestContext): ICefBrowser;
var
  u: TCefString;
begin
  CefLoadLibDefault;
  u := CefString(url);
  Result := TCefBrowserRef.UnWrap(cef_browser_host_create_browser_sync(windowInfo,
    CefGetData(client), @u, settings, CefGetData(requestContext)));
end;

procedure CefVisitWebPluginInfo(const visitor: ICefWebPluginInfoVisitor);
begin
  cef_visit_web_plugin_info(CefGetData(visitor));
end;

procedure CefVisitWebPluginInfoProc(const visitor: TCefWebPluginInfoVisitorProc);
begin
  CefVisitWebPluginInfo(TCefFastWebPluginInfoVisitor.Create(visitor));
end;

procedure CefRefreshWebPlugins;
begin
  cef_refresh_web_plugins();
end;

procedure CefAddWebPluginPath(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_add_web_plugin_path(@p);
end;

procedure CefAddWebPluginDirectory(const dir: ustring);
var
  d: TCefString;
begin
  d := CefString(dir);
  cef_add_web_plugin_directory(@d);
end;

procedure CefRemoveWebPluginPath(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_remove_web_plugin_path(@p);
end;

procedure CefUnregisterInternalWebPlugin(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_unregister_internal_web_plugin(@p);
end;

procedure CefForceWebPluginShutdown(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_force_web_plugin_shutdown(@p);
end;

procedure CefRegisterWebPluginCrash(const path: ustring);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_register_web_plugin_crash(@p);
end;

procedure CefIsWebPluginUnstable(const path: ustring;
  const callback: ICefWebPluginUnstableCallback);
var
  p: TCefString;
begin
  p := CefString(path);
  cef_is_web_plugin_unstable(@p, CefGetData(callback));
end;

procedure CefIsWebPluginUnstableProc(const path: ustring;
  const callback: TCefWebPluginIsUnstableProc);
begin
  CefIsWebPluginUnstable(path, TCefFastWebPluginUnstableCallback.Create(callback));
end;

function CefGetPath(key: TCefPathKey; out path: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString('');
  Result := cef_get_path(key, @p) <> 0;
  path := CefStringClearAndGet(p);
end;

function CefBeginTracing(const categories: ustring; const callback: ICefCompletionCallback): Boolean;
var
  c: TCefString;
begin
  c := CefString(categories);
  Result := cef_begin_tracing(@c, CefGetData(callback)) <> 0;
end;

function CefEndTracing(const tracingFile: ustring; const callback: ICefEndTracingCallback): Boolean;
var
  s: TCefString;
begin
  s := CefString(tracingFile);
  Result := cef_end_tracing(@s, CefGetData(callback)) <> 0;
end;

function CefNowFromSystemTraceTime: Int64;
begin
  Result := cef_now_from_system_trace_time();
end;

function CefGetGeolocation(const callback: ICefGetGeolocationCallback): Boolean;
begin
  Result := cef_get_geolocation(CefGetData(callback)) <> 0;
end;

{$IFDEF MSWINDOWS}
function CefTimeToSystemTime(const dt: TCefTime): TSystemTime;
begin
  Result.wYear := dt.year;
  Result.wMonth := dt.month;
  Result.wDayOfWeek := dt.day_of_week;
  Result.wDay := dt.day_of_month;
  Result.wHour := dt.hour;
  Result.wMinute := dt.minute;
  Result.wSecond := dt.second;
  Result.wMilliseconds := dt.millisecond;
end;

function SystemTimeToCefTime(const dt: TSystemTime): TCefTime;
begin
  Result.year := dt.wYear;
  Result.month := dt.wMonth;
  Result.day_of_week := dt.wDayOfWeek;
  Result.day_of_month := dt.wDay;
  Result.hour := dt.wHour;
  Result.minute := dt.wMinute;
  Result.second := dt.wSecond;
  Result.millisecond := dt.wMilliseconds;
end;

function CefTimeToDateTime(const dt: TCefTime): TDateTime;
var
  st: TSystemTime;
begin
  st := CefTimeToSystemTime(dt);
  SystemTimeToTzSpecificLocalTime(nil, @st, @st);
  Result := SystemTimeToDateTime(st);
end;

function DateTimeToCefTime(dt: TDateTime): TCefTime;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(dt, st);
  TzSpecificLocalTimeToSystemTime(nil, @st, @st);
  Result := SystemTimeToCefTime(st);
end;
{$ELSE}

function CefTimeToDateTime(const dt: TCefTime): TDateTime;
begin
  Result :=
    EncodeDate(dt.year, dt.month, dt.day_of_month) +
    EncodeTime(dt.hour, dt.minute, dt.second, dt.millisecond);
end;

function DateTimeToCefTime(dt: TDateTime): TCefTime;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(dt, Year, Month, Day);
  DecodeTime(dt, Hour, Min, Sec, MSec);
  Result.year := Year;
  Result.month := Month;
  Result.day_of_week := DayOfWeek(dt);
  Result.day_of_month := Month;
  Result.hour := Hour;
  Result.minute := Min;
  Result.second := Sec;
  Result.millisecond := MSec;
end;

{$ENDIF}

{ cef_base }

procedure cef_base_add_ref(self: PCefBase); stdcall;
begin
  TCefBaseOwn(CefGetObject(self))._AddRef;
end;

function cef_base_release(self: PCefBase): Integer; stdcall;
begin
  Result := TCefBaseOwn(CefGetObject(self))._Release;
end;

function cef_base_has_one_ref(self: PCefBase): Integer; stdcall;
begin
  Result := Ord(TCefBaseOwn(CefGetObject(self)).FRefCount = 1);
end;

procedure cef_base_add_ref_owned(self: PCefBase); stdcall;
begin

end;

function cef_base_release_owned(self: PCefBase): Integer; stdcall;
begin
  Result := 1;
end;

function cef_base_has_one_ref_owned(self: PCefBase): Integer; stdcall;
begin
  Result := 1;
end;

{ cef_client }

function cef_client_get_context_menu_handler(self: PCefClient): PCefContextMenuHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetContextMenuHandler);
end;

function cef_client_get_dialog_handler(self: PCefClient): PCefDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDialogHandler);
end;

function cef_client_get_display_handler(self: PCefClient): PCefDisplayHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDisplayHandler);
end;

function cef_client_get_download_handler(self: PCefClient): PCefDownloadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDownloadHandler);
end;

function cef_client_get_drag_handler(self: PCefClient): PCefDragHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDragHandler);
end;

function cef_client_get_find_handler(self: PCefClient): PCefFindHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFindHandler);
end;

function cef_client_get_focus_handler(self: PCefClient): PCefFocusHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFocusHandler);
end;

function cef_client_get_geolocation_handler(self: PCefClient): PCefGeolocationHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetGeolocationHandler);
end;

function cef_client_get_jsdialog_handler(self: PCefClient): PCefJsDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetJsdialogHandler);
end;

function cef_client_get_keyboard_handler(self: PCefClient): PCefKeyboardHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetKeyboardHandler);
end;

function cef_client_get_life_span_handler(self: PCefClient): PCefLifeSpanHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLifeSpanHandler);
end;

function cef_client_get_load_handler(self: PCefClient): PCefLoadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLoadHandler);
end;

function cef_client_get_get_render_handler(self: PCefClient): PCefRenderHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRenderHandler);
end;

function cef_client_get_request_handler(self: PCefClient): PCefRequestHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRequestHandler);
end;

function cef_client_on_process_message_received(self: PCefClient; browser: PCefBrowser;
  source_process: TCefProcessId; message: PCefProcessMessage): Integer; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := Ord(OnProcessMessageReceived(TCefBrowserRef.UnWrap(browser), source_process,
      TCefProcessMessageRef.UnWrap(message)));
end;

{ cef_geolocation_handler }

function cef_geolocation_handler_on_request_geolocation_permission(self: PCefGeolocationHandler;
  browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer;
  callback: PCefGeolocationCallback): Integer; stdcall;
begin
  with TCefGeolocationHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnRequestGeolocationPermission(TCefBrowserRef.UnWrap(browser), CefString(requesting_url),
      request_id, TCefGeolocationCallbackRef.UnWrap(callback)));
end;

procedure cef_geolocation_handler_on_cancel_geolocation_permission(self: PCefGeolocationHandler;
  browser: PCefBrowser; const requesting_url: PCefString; request_id: Integer); stdcall;
begin
  with TCefGeolocationHandlerOwn(CefGetObject(self)) do
    OnCancelGeolocationPermission(TCefBrowserRef.UnWrap(browser), CefString(requesting_url), request_id);
end;

{ cef_life_span_handler }

function cef_life_span_handler_on_before_popup(self: PCefLifeSpanHandler;
  browser: PCefBrowser; frame: PCefFrame; const target_url, target_frame_name: PCefString;
  target_disposition: TCefWindowOpenDisposition; user_gesture: Integer;
  const popupFeatures: PCefPopupFeatures; windowInfo: PCefWindowInfo; var client: PCefClient;
  settings: PCefBrowserSettings; no_javascript_access: PInteger): Integer; stdcall;
var
  _url, _frame: ustring;
  _client: ICefClient;
  _nojs: Boolean;
begin
  _url := CefString(target_url);
  _frame := CefString(target_frame_name);
  _client := TCefClientOwn(CefGetObject(client)) as ICefClient;
  _nojs := no_javascript_access^ <> 0;
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforePopup(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      _url,
      _frame,
      target_disposition,
      user_gesture <> 0,
      popupFeatures^,
      windowInfo^,
      _client,
      settings^,
      _nojs
    ));
  CefStringSet(target_url, _url);
  CefStringSet(target_frame_name, _frame);
  client := CefGetData(_client);
  no_javascript_access^ := Ord(_nojs);
  _client := nil;
end;

procedure cef_life_span_handler_on_after_created(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    OnAfterCreated(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_life_span_handler_on_before_close(self: PCefLifeSpanHandler; browser: PCefBrowser); stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    OnBeforeClose(TCefBrowserRef.UnWrap(browser));
end;

function cef_life_span_handler_run_modal(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(RunModal(TCefBrowserRef.UnWrap(browser)));
end;

function cef_life_span_handler_do_close(self: PCefLifeSpanHandler; browser: PCefBrowser): Integer; stdcall;
begin
  with TCefLifeSpanHandlerOwn(CefGetObject(self)) do
    Result := Ord(DoClose(TCefBrowserRef.UnWrap(browser)));
end;


{ cef_load_handler }

procedure cef_load_handler_on_loading_state_change(self: PCefLoadHandler;
  browser: PCefBrowser; isLoading, canGoBack, canGoForward: Integer); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadingStateChange(TCefBrowserRef.UnWrap(browser), isLoading <> 0,
      canGoBack <> 0, canGoForward <> 0);
end;

procedure cef_load_handler_on_load_start(self: PCefLoadHandler;
  browser: PCefBrowser; frame: PCefFrame); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadStart(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame));
end;

procedure cef_load_handler_on_load_end(self: PCefLoadHandler;
  browser: PCefBrowser; frame: PCefFrame; httpStatusCode: Integer); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadEnd(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), httpStatusCode);
end;

procedure cef_load_handler_on_load_error(self: PCefLoadHandler; browser: PCefBrowser;
  frame: PCefFrame; errorCode: Integer; const errorText, failedUrl: PCefString); stdcall;
begin
  with TCefLoadHandlerOwn(CefGetObject(self)) do
    OnLoadError(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      errorCode, CefString(errorText), CefString(failedUrl));
end;

{ cef_request_handler }

function cef_request_handler_on_before_browse(self: PCefRequestHandler; browser: PCefBrowser;
  frame: PCefFrame; request: PCefRequest; isRedirect: Integer): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforeBrowse(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), isRedirect <> 0));
end;

function cef_request_handler_on_open_urlfrom_tab(self: PCefRequestHandler; browser: PCefBrowser;
  frame: PCefFrame; const target_url: PCefString; target_disposition: TCefWindowOpenDisposition;
  user_gesture: Integer): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnOpenUrlFromTab(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      CefString(target_url), target_disposition, user_gesture <> 0));
end;

function cef_request_handler_on_before_resource_load(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  callback: PCefRequestCallback): TCefReturnValue; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := OnBeforeResourceLoad(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request),
      TcefRequestCallbackRef.UnWrap(callback));
end;

function cef_request_handler_get_resource_handler(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest): PCefResourceHandler; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := CefGetData(GetResourceHandler(TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame), TCefRequestRef.UnWrap(request)));
end;

procedure cef_request_handler_on_resource_redirect(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; const request: PCefRequest; new_url: PCefString); stdcall;
var
  url: ustring;
begin
  url := CefString(new_url);
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnResourceRedirect(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), url);
  if url <> '' then
    CefStringSet(new_url, url);
end;

function cef_request_handler_on_resource_response(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  response: PCefResponse): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnResourceResponse(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefRequestRef.UnWrap(request), TCefResponseRef.UnWrap(response)));
end;

function cef_request_handler_get_auth_credentials(self: PCefRequestHandler;
  browser: PCefBrowser; frame: PCefFrame; isProxy: Integer; const host: PCefString;
  port: Integer; const realm, scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetAuthCredentials(
      TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), isProxy <> 0,
      CefString(host), port, CefString(realm), CefString(scheme), TCefAuthCallbackRef.UnWrap(callback)));
end;

function cef_request_handler_on_quota_request(self: PCefRequestHandler; browser: PCefBrowser;
  const origin_url: PCefString; new_size: Int64; callback: PCefRequestCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnQuotaRequest(TCefBrowserRef.UnWrap(browser),
      CefString(origin_url), new_size, TCefRequestCallbackRef.UnWrap(callback)));
end;

procedure cef_request_handler_on_protocol_execution(self: PCefRequestHandler;
  browser: PCefBrowser; const url: PCefString; allow_os_execution: PInteger); stdcall;
var
  allow: Boolean;
begin
  allow := allow_os_execution^ <> 0;
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnProtocolExecution(
      TCefBrowserRef.UnWrap(browser),
      CefString(url), allow);
  allow_os_execution^ := Ord(allow);
end;

function cef_request_handler_on_certificate_error(self: PCefRequestHandler;
  browser: PCefBrowser; cert_error: TCefErrorcode; const request_url: PCefString;
  ssl_info: PCefSslInfo; callback: PCefRequestCallback): Integer; stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnCertificateError(TCefBrowserRef.UnWrap(browser), cert_error,
      CefString(request_url), TCefSslInfoRef.UnWrap(ssl_info),
      TCefRequestCallbackRef.UnWrap(callback)));
end;

procedure cef_request_handler_on_plugin_crashed(self: PCefRequestHandler;
  browser: PCefBrowser; const plugin_path: PCefString); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnPluginCrashed(TCefBrowserRef.UnWrap(browser), CefString(plugin_path));
end;

procedure cef_request_handler_on_render_view_ready(self: PCefRequestHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnRenderViewReady(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_request_handler_on_render_process_terminated(self: PCefRequestHandler;
  browser: PCefBrowser; status: TCefTerminationStatus); stdcall;
begin
  with TCefRequestHandlerOwn(CefGetObject(self)) do
    OnRenderProcessTerminated(TCefBrowserRef.UnWrap(browser), status);
end;


{ cef_display_handler }

procedure cef_display_handler_on_address_change(self: PCefDisplayHandler;
  browser: PCefBrowser; frame: PCefFrame; const url: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnAddressChange(
      TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame),
      cefstring(url))
end;

procedure cef_display_handler_on_title_change(self: PCefDisplayHandler;
  browser: PCefBrowser; const title: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnTitleChange(TCefBrowserRef.UnWrap(browser), CefString(title));
end;

procedure cef_display_handler_on_favicon_urlchange(self: PCefDisplayHandler;
  browser: PCefBrowser; icon_urls: TCefStringList); stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(icon_urls) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(icon_urls, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;
    with TCefDisplayHandlerOwn(CefGetObject(self)) do
      OnFaviconUrlChange(TCefBrowserRef.UnWrap(browser), list);
  finally
    list.Free;
  end;
end;

procedure cef_display_handler_on_fullscreen_mode_change(self: PCefDisplayHandler;
  browser: PCefBrowser; fullscreen: Integer); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnFullScreenModeChange(TCefBrowserRef.UnWrap(browser), fullscreen <> 0);
end;

function cef_display_handler_on_tooltip(self: PCefDisplayHandler;
  browser: PCefBrowser; text: PCefString): Integer; stdcall;
var
  t: ustring;
begin
  t := CefStringClearAndGet(text^);
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnTooltip(
      TCefBrowserRef.UnWrap(browser), t));
  text^ := CefStringAlloc(t);
end;

procedure cef_display_handler_on_status_message(self: PCefDisplayHandler;
  browser: PCefBrowser; const value: PCefString); stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    OnStatusMessage(TCefBrowserRef.UnWrap(browser), CefString(value));
end;

function cef_display_handler_on_console_message(self: PCefDisplayHandler;
    browser: PCefBrowser; const message: PCefString;
    const source: PCefString; line: Integer): Integer; stdcall;
begin
  with TCefDisplayHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnConsoleMessage(TCefBrowserRef.UnWrap(browser),
    CefString(message), CefString(source), line));
end;

{ cef_focus_handler }

procedure cef_focus_handler_on_take_focus(self: PCefFocusHandler;
  browser: PCefBrowser; next: Integer); stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    OnTakeFocus(TCefBrowserRef.UnWrap(browser), next <> 0);
end;

function cef_focus_handler_on_set_focus(self: PCefFocusHandler;
  browser: PCefBrowser; source: TCefFocusSource): Integer; stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnSetFocus(TCefBrowserRef.UnWrap(browser), source))
end;

procedure cef_focus_handler_on_got_focus(self: PCefFocusHandler; browser: PCefBrowser); stdcall;
begin
  with TCefFocusHandlerOwn(CefGetObject(self)) do
    OnGotFocus(TCefBrowserRef.UnWrap(browser));
end;

{ cef_keyboard_handler }

function cef_keyboard_handler_on_pre_key_event(self: PCefKeyboardHandler;
  browser: PCefBrowser; const event: PCefKeyEvent;
  os_event: TCefEventHandle; is_keyboard_shortcut: PInteger): Integer; stdcall;
var
  ks: Boolean;
begin
  ks := is_keyboard_shortcut^ <> 0;
  with TCefKeyboardHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnPreKeyEvent(TCefBrowserRef.UnWrap(browser), event, os_event, ks));
  is_keyboard_shortcut^ := Ord(ks);
end;

function cef_keyboard_handler_on_key_event(self: PCefKeyboardHandler;
    browser: PCefBrowser; const event: PCefKeyEvent; os_event: TCefEventHandle): Integer; stdcall;
begin
  with TCefKeyboardHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnKeyEvent(TCefBrowserRef.UnWrap(browser), event, os_event));
end;

{ cef_jsdialog_handler }

function cef_jsdialog_handler_on_jsdialog(self: PCefJsDialogHandler;
  browser: PCefBrowser; const origin_url, accept_lang: PCefString;
  dialog_type: TCefJsDialogType; const message_text, default_prompt_text: PCefString;
  callback: PCefJsDialogCallback; suppress_message: PInteger): Integer; stdcall;
var
  sm: Boolean;
begin
  sm := suppress_message^ <> 0;
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnJsdialog(TCefBrowserRef.UnWrap(browser), CefString(origin_url),
      CefString(accept_lang), dialog_type, CefString(message_text),
      CefString(default_prompt_text), TCefJsDialogCallbackRef.UnWrap(callback), sm));
  suppress_message^ := Ord(sm);
end;

function cef_jsdialog_handler_on_before_unload_dialog(self: PCefJsDialogHandler;
  browser: PCefBrowser; const message_text: PCefString; is_reload: Integer;
  callback: PCefJsDialogCallback): Integer; stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforeUnloadDialog(TCefBrowserRef.UnWrap(browser), CefString(message_text),
      is_reload <> 0, TCefJsDialogCallbackRef.UnWrap(callback)));
end;

procedure cef_jsdialog_handler_on_reset_dialog_state(self: PCefJsDialogHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    OnResetDialogState(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_jsdialog_handler_on_dialog_closed(self: PCefJsDialogHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefJsDialogHandlerOwn(CefGetObject(self)) do
    OnDialogClosed(TCefBrowserRef.UnWrap(browser));
end;

{ cef_context_menu_handler }

procedure cef_context_menu_handler_on_before_context_menu(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  model: PCefMenuModel); stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    OnBeforeContextMenu(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), TCefMenuModelRef.UnWrap(model));
end;

function cef_context_menu_handler_run_context_menu(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  model: PCefMenuModel; callback: PCefRunContextMenuCallback): Integer; stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    Result := Ord(RunContextMenu(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), TCefMenuModelRef.UnWrap(model),
      TCefRunContextMenuCallbackRef.UnWrap(callback)));
end;

function cef_context_menu_handler_on_context_menu_command(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame; params: PCefContextMenuParams;
  command_id: Integer; event_flags: Integer): Integer; stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnContextMenuCommand(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefContextMenuParamsRef.UnWrap(params), command_id, TCefEventFlags(Pointer(@event_flags)^)));
end;

procedure cef_context_menu_handler_on_context_menu_dismissed(self: PCefContextMenuHandler;
  browser: PCefBrowser; frame: PCefFrame); stdcall;
begin
  with TCefContextMenuHandlerOwn(CefGetObject(self)) do
    OnContextMenuDismissed(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame));
end;

{  cef_stream_reader }

function cef_stream_reader_read(self: PCefReadHandler; ptr: Pointer; size, n: NativeUInt): NativeUInt; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Read(ptr, size, n);
end;

function cef_stream_reader_seek(self: PCefReadHandler; offset: Int64; whence: Integer): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Seek(offset, whence);
end;

function cef_stream_reader_tell(self: PCefReadHandler): Int64; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Tell;
end;

function cef_stream_reader_eof(self: PCefReadHandler): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Ord(Eof);
end;

function cef_stream_reader_may_block(self: PCefReadHandler): Integer; stdcall;
begin
  with TCefCustomStreamReader(CefGetObject(self)) do
    Result := Ord(MayBlock);
end;

{ cef_post_data_element }

function cef_post_data_element_is_read_only(self: PCefPostDataElement): Integer; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := Ord(IsReadOnly)
end;

procedure cef_post_data_element_set_to_empty(self: PCefPostDataElement); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToEmpty;
end;

procedure cef_post_data_element_set_to_file(self: PCefPostDataElement; const fileName: PCefString); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToFile(CefString(fileName));
end;

procedure cef_post_data_element_set_to_bytes(self: PCefPostDataElement; size: NativeUInt; const bytes: Pointer); stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    SetToBytes(size, bytes);
end;

function cef_post_data_element_get_type(self: PCefPostDataElement): TCefPostDataElementType; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetType;
end;

function cef_post_data_element_get_file(self: PCefPostDataElement): PCefStringUserFree; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := CefUserFreeString(GetFile);
end;

function cef_post_data_element_get_bytes_count(self: PCefPostDataElement): NativeUInt; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetBytesCount;
end;

function cef_post_data_element_get_bytes(self: PCefPostDataElement; size: NativeUInt; bytes: Pointer): NativeUInt; stdcall;
begin
  with TCefPostDataElementOwn(CefGetObject(self)) do
    Result := GetBytes(size, bytes)
end;

{ cef_v8_handler }

function cef_v8_handler_execute(self: PCefv8Handler;
  const name: PCefString; obj: PCefv8Value; argumentsCount: NativeUInt;
  const arguments: PPCefV8Value; var retval: PCefV8Value;
  var exception: TCefString): Integer; stdcall;
var
  args: TCefv8ValueArray;
  i: NativeInt;
  ret: ICefv8Value;
  exc: ustring;
begin
  SetLength(args, argumentsCount);
  for i := 0 to argumentsCount - 1 do
    args[i] := TCefv8ValueRef.UnWrap(arguments[i]);

  Result := -Ord(TCefv8HandlerOwn(CefGetObject(self)).Execute(
    CefString(name), TCefv8ValueRef.UnWrap(obj), args, ret, exc));
  retval := CefGetData(ret);
  ret := nil;
  exception := CefString(exc);
end;

{ cef_task }

procedure cef_task_execute(self: PCefTask); stdcall;
begin
  TCefTaskOwn(CefGetObject(self)).Execute();
end;

{ cef_download_handler }

procedure cef_download_handler_on_before_download(self: PCefDownloadHandler;
  browser: PCefBrowser; download_item: PCefDownloadItem;
  const suggested_name: PCefString; callback: PCefBeforeDownloadCallback); stdcall;
begin
  TCefDownloadHandlerOwn(CefGetObject(self)).
    OnBeforeDownload(TCefBrowserRef.UnWrap(browser),
    TCefDownLoadItemRef.UnWrap(download_item), CefString(suggested_name),
    TCefBeforeDownloadCallbackRef.UnWrap(callback));
end;

procedure cef_download_handler_on_download_updated(self: PCefDownloadHandler;
  browser: PCefBrowser; download_item: PCefDownloadItem; callback: PCefDownloadItemCallback); stdcall;
begin
  TCefDownloadHandlerOwn(CefGetObject(self)).
    OnDownloadUpdated(TCefBrowserRef.UnWrap(browser),
    TCefDownLoadItemRef.UnWrap(download_item),
    TCefDownloadItemCallbackRef.UnWrap(callback));
end;

{ cef_dom_visitor }

procedure cef_dom_visitor_visite(self: PCefDomVisitor; document: PCefDomDocument); stdcall;
begin
  TCefDomVisitorOwn(CefGetObject(self)).visit(TCefDomDocumentRef.UnWrap(document));
end;

{ cef_v8_accessor }

function cef_v8_accessor_get(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; out retval: PCefv8Value; exception: PCefString): Integer; stdcall;
var
  ret: ICefv8Value;
begin
  Result := Ord(TCefV8AccessorOwn(CefGetObject(self)).Get(CefString(name),
    TCefv8ValueRef.UnWrap(obj), ret, CefString(exception)));
  retval := CefGetData(ret);
end;


function cef_v8_accessor_put(self: PCefV8Accessor; const name: PCefString;
      obj: PCefv8Value; value: PCefv8Value; exception: PCefString): Integer; stdcall;
begin
  Result := Ord(TCefV8AccessorOwn(CefGetObject(self)).Put(CefString(name),
    TCefv8ValueRef.UnWrap(obj), TCefv8ValueRef.UnWrap(value), CefString(exception)));
end;

{ cef_cookie_visitor }

function cef_cookie_visitor_visit(self: PCefCookieVisitor; const cookie: PCefCookie;
  count, total: Integer; deleteCookie: PInteger): Integer; stdcall;
var
  delete: Boolean;
  exp: TDateTime;
begin
  delete := False;
  if cookie.has_expires <> 0 then
    exp := CefTimeToDateTime(cookie.expires) else
    exp := 0;
  Result := Ord(TCefCookieVisitorOwn(CefGetObject(self)).visit(CefString(@cookie.name),
    CefString(@cookie.value), CefString(@cookie.domain), CefString(@cookie.path),
    Boolean(cookie.secure), Boolean(cookie.httponly), Boolean(cookie.has_expires), CefTimeToDateTime(cookie.creation),
    CefTimeToDateTime(cookie.last_access), exp, count, total, delete));
  deleteCookie^ := Ord(delete);
end;

{ cef_resource_bundle_handler }

function cef_resource_bundle_handler_get_localized_string(self: PCefResourceBundleHandler;
  string_id: Integer; string_val: PCefString): Integer; stdcall;
var
  str: ustring;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetLocalizedString(string_id, str));
  if Result <> 0 then
    string_val^ := CefString(str);
end;

function cef_resource_bundle_handler_get_data_resource(self: PCefResourceBundleHandler;
  resource_id: Integer; var data: Pointer; var data_size: NativeUInt): Integer; stdcall;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetDataResource(resource_id, data, data_size));
end;

function cef_resource_bundle_handler_get_data_resource_for_scale(
  self: PCefResourceBundleHandler; resource_id: Integer; scale_factor: TCefScaleFactor;
  out data: Pointer; data_size: NativeUInt): Integer; stdcall;
begin
  Result := Ord(TCefResourceBundleHandlerOwn(CefGetObject(self)).
    GetDataResourceForScale(resource_id, scale_factor, data, data_size));
end;

{ cef_app }

procedure cef_app_on_before_command_line_processing(self: PCefApp;
  const process_type: PCefString; command_line: PCefCommandLine); stdcall;
begin
  with TCefAppOwn(CefGetObject(self)) do
    OnBeforeCommandLineProcessing(CefString(process_type),
      TCefCommandLineRef.UnWrap(command_line));
end;

procedure cef_app_on_register_custom_schemes(self: PCefApp; registrar: PCefSchemeRegistrar); stdcall;
begin
  with TCefAppOwn(CefGetObject(self)) do
    OnRegisterCustomSchemes(TCefSchemeRegistrarRef.UnWrap(registrar));
end;

function cef_app_get_resource_bundle_handler(self: PCefApp): PCefResourceBundleHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetResourceBundleHandler());
end;

function cef_app_get_browser_process_handler(self: PCefApp): PCefBrowserProcessHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetBrowserProcessHandler());
end;

function cef_app_get_render_process_handler(self: PCefApp): PCefRenderProcessHandler; stdcall;
begin
  Result := CefGetData(TCefAppOwn(CefGetObject(self)).GetRenderProcessHandler());
end;

{ cef_string_visitor_visit }

procedure cef_string_visitor_visit(self: PCefStringVisitor; const str: PCefString); stdcall;
begin
  TCefStringVisitorOwn(CefGetObject(self)).Visit(CefString(str));
end;

{ cef_browser_process_handler }

procedure cef_browser_process_handler_on_context_initialized(self: PCefBrowserProcessHandler); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnContextInitialized;
end;

procedure cef_browser_process_handler_on_before_child_process_launch(
  self: PCefBrowserProcessHandler; command_line: PCefCommandLine); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnBeforeChildProcessLaunch(TCefCommandLineRef.UnWrap(command_line));
end;

procedure cef_browser_process_handler_on_render_process_thread_created(
  self: PCefBrowserProcessHandler; extra_info: PCefListValue); stdcall;
begin
  with TCefBrowserProcessHandlerOwn(CefGetObject(self)) do
    OnRenderProcessThreadCreated(TCefListValueRef.UnWrap(extra_info));
end;

{ cef_render_process_handler }

procedure cef_render_process_handler_on_render_thread_created(
  self: PCefRenderProcessHandler; extra_info: PCefListValue); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnRenderThreadCreated(TCefListValueRef.UnWrap(extra_info));
end;

procedure cef_render_process_handler_on_web_kit_initialized(self: PCefRenderProcessHandler); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnWebKitInitialized;
end;

procedure cef_render_process_handler_on_browser_created(self: PCefRenderProcessHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnBrowserCreated(TCefBrowserRef.UnWrap(browser));
end;

procedure cef_render_process_handler_on_browser_destroyed(self: PCefRenderProcessHandler;
  browser: PCefBrowser); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnBrowserDestroyed(TCefBrowserRef.UnWrap(browser));
end;

function cef_render_process_handler_get_load_handler(self: PCefRenderProcessHandler): PCefLoadHandler; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := GetLoadHandler();
end;

function cef_render_process_handler_on_before_navigation(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; request: PCefRequest;
  navigation_type: TCefNavigationType; is_redirect: Integer): Integer; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := Ord(OnBeforeNavigation(TCefBrowserRef.UnWrap(browser),
      TCefFrameRef.UnWrap(frame), TCefRequestRef.UnWrap(request),
      navigation_type, is_redirect <> 0));
end;

procedure cef_render_process_handler_on_context_created(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnContextCreated(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), TCefv8ContextRef.UnWrap(context));
end;

procedure cef_render_process_handler_on_context_released(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnContextReleased(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame), TCefv8ContextRef.UnWrap(context));
end;

procedure cef_render_process_handler_on_uncaught_exception(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; context: PCefv8Context;
  exception: PCefV8Exception; stackTrace: PCefV8StackTrace); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnUncaughtException(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefv8ContextRef.UnWrap(context), TCefV8ExceptionRef.UnWrap(exception),
      TCefV8StackTraceRef.UnWrap(stackTrace));
end;

procedure cef_render_process_handler_on_focused_node_changed(self: PCefRenderProcessHandler;
  browser: PCefBrowser; frame: PCefFrame; node: PCefDomNode); stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    OnFocusedNodeChanged(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      TCefDomNodeRef.UnWrap(node));
end;

function cef_render_process_handler_on_process_message_received(self: PCefRenderProcessHandler;
  browser: PCefBrowser; source_process: TCefProcessId;
  message: PCefProcessMessage): Integer; stdcall;
begin
  with TCefRenderProcessHandlerOwn(CefGetObject(Self)) do
    Result := Ord(OnProcessMessageReceived(TCefBrowserRef.UnWrap(browser), source_process,
      TCefProcessMessageRef.UnWrap(message)));
end;

{ cef_url_request_client }

procedure cef_url_request_client_on_request_complete(self: PCefUrlRequestClient; request: PCefUrlRequest); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnRequestComplete(TCefUrlRequestRef.UnWrap(request));
end;

procedure cef_url_request_client_on_upload_progress(self: PCefUrlRequestClient;
  request: PCefUrlRequest; current, total: Int64); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnUploadProgress(TCefUrlRequestRef.UnWrap(request), current, total);
end;

procedure cef_url_request_client_on_download_progress(self: PCefUrlRequestClient;
  request: PCefUrlRequest; current, total: Int64); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnDownloadProgress(TCefUrlRequestRef.UnWrap(request), current, total);
end;

procedure cef_url_request_client_on_download_data(self: PCefUrlRequestClient;
  request: PCefUrlRequest; const data: Pointer; data_length: NativeUInt); stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    OnDownloadData(TCefUrlRequestRef.UnWrap(request), data, data_length);
end;

function cef_url_request_client_get_auth_credentials(self: PCefUrlRequestClient;
  isProxy: Integer; const host: PCefString; port: Integer; const realm,
  scheme: PCefString; callback: PCefAuthCallback): Integer; stdcall;
begin
  with TCefUrlrequestClientOwn(CefGetObject(self)) do
    Result := Ord(OnGetAuthCredentials(isProxy <> 0, CefString(host), port,
      CefString(realm), CefString(scheme), TCefAuthCallbackRef.UnWrap(callback)));
end;

{ cef_scheme_handler_factory }

function cef_scheme_handler_factory_create(self: PCefSchemeHandlerFactory;
  browser: PCefBrowser; frame: PCefFrame; const scheme_name: PCefString;
  request: PCefRequest): PCefResourceHandler; stdcall;
begin

  with TCefSchemeHandlerFactoryOwn(CefGetObject(self)) do
    Result := CefGetData(New(TCefBrowserRef.UnWrap(browser), TCefFrameRef.UnWrap(frame),
      CefString(scheme_name), TCefRequestRef.UnWrap(request)));
end;

{ cef_resource_handler }

function cef_resource_handler_process_request(self: PCefResourceHandler;
  request: PCefRequest; callback: PCefCallback): Integer; stdcall;
begin
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(ProcessRequest(TCefRequestRef.UnWrap(request), TCefCallbackRef.UnWrap(callback)));
end;

procedure cef_resource_handler_get_response_headers(self: PCefResourceHandler;
  response: PCefResponse; response_length: PInt64; redirectUrl: PCefString); stdcall;
var
  ru: ustring;
begin
  ru := '';
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    GetResponseHeaders(TCefResponseRef.UnWrap(response), response_length^, ru);
  if ru <> '' then
    CefStringSet(redirectUrl, ru);
end;

function cef_resource_handler_read_response(self: PCefResourceHandler;
  data_out: Pointer; bytes_to_read: Integer; bytes_read: PInteger;
    callback: PCefCallback): Integer; stdcall;
begin
  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(ReadResponse(data_out, bytes_to_read, bytes_read^, TCefCallbackRef.UnWrap(callback)));
end;

function cef_resource_handler_can_get_cookie(self: PCefResourceHandler;
  const cookie: PCefCookie): Integer; stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(CanGetCookie(cookie));
end;

function cef_resource_handler_can_set_cookie(self: PCefResourceHandler;
  const cookie: PCefCookie): Integer; stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Result := Ord(CanSetCookie(cookie));
end;

procedure cef_resource_handler_cancel(self: PCefResourceHandler); stdcall;
begin

  with TCefResourceHandlerOwn(CefGetObject(self)) do
    Cancel;
end;


{ cef_web_plugin_info_visitor }


function cef_web_plugin_info_visitor_visit(self: PCefWebPluginInfoVisitor;

      info: PCefWebPluginInfo; count, total: Integer): Integer; stdcall;
begin
  with TCefWebPluginInfoVisitorOwn(CefGetObject(self)) do
    Result := Ord(Visit(TCefWebPluginInfoRef.UnWrap(info), count, total));
end;


{ cef_web_plugin_unstable_callback }


procedure cef_web_plugin_unstable_callback_is_unstable(
  self: PCefWebPluginUnstableCallback; const path: PCefString; unstable: Integer); stdcall;
begin
  with TCefWebPluginUnstableCallbackOwn(CefGetObject(self)) do
    IsUnstable(CefString(path), unstable <> 0);
end;


{ cef_run_file_dialog_callback }

procedure cef_run_file_dialog_callback_on_file_dialog_dismissed(
  self: PCefRunFileDialogCallback; selected_accept_filter: Integer;
  file_paths: TCefStringList); stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(file_paths) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(file_paths, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;
    with TCefRunFileDialogCallbackOwn(CefGetObject(self)) do
      OnFileDialogDismissed(selected_accept_filter, list);
  finally
    list.Free;
  end;
end;


{ cef_end_tracing_callback }

procedure cef_end_tracing_callback_on_end_tracing_complete(self: PCefEndTracingCallback; const tracing_file: PCefString); stdcall;
begin
  with TCefEndTracingCallbackOwn(CefGetObject(self)) do
    OnEndTracingComplete(CefString(tracing_file));
end;

{ cef_get_geolocation_callback }

procedure cef_get_geolocation_callback_on_location_update(
  self: PCefGetGeolocationCallback; const position: PCefGeoposition); stdcall;
begin
  with TCefGetGeolocationCallbackOwn(CefGetObject(self)) do
    OnLocationUpdate(position);
end;

{ cef_dialog_handler }


function cef_dialog_handler_on_file_dialog(self: PCefDialogHandler; browser: PCefBrowser;
  mode: TCefFileDialogMode; const title, default_file_path: PCefString;
  accept_filters: TCefStringList; selected_accept_filter: Integer;
  callback: PCefFileDialogCallback): Integer; stdcall;
var
  list: TStringList;
  i: Integer;
  str: TCefString;
begin
  list := TStringList.Create;
  try
    for i := 0 to cef_string_list_size(accept_filters) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(accept_filters, i, @str);
      list.Add(CefStringClearAndGet(str));
    end;

    with TCefDialogHandlerOwn(CefGetObject(self)) do
      Result := Ord(OnFileDialog(TCefBrowserRef.UnWrap(browser), mode, CefString(title),
        CefString(default_file_path), list, selected_accept_filter,
        TCefFileDialogCallbackRef.UnWrap(callback)));
  finally
    list.Free;
  end;
end;

{ cef_render_handler }

function cef_render_handler_get_root_screen_rect(self: PCefRenderHandler;
  browser: PCefBrowser; rect: PCefRect): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetRootScreenRect(TCefBrowserRef.UnWrap(browser), rect));
end;

function cef_render_handler_get_view_rect(self: PCefRenderHandler;
  browser: PCefBrowser; rect: PCefRect): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetViewRect(TCefBrowserRef.UnWrap(browser), rect));
end;

function cef_render_handler_get_screen_point(self: PCefRenderHandler;
  browser: PCefBrowser; viewX, viewY: Integer; screenX, screenY: PInteger): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetScreenPoint(TCefBrowserRef.UnWrap(browser), viewX, viewY, screenX, screenY));
end;

function cef_render_handler_get_screen_info(self: PCefRenderHandler;
  browser: PCefBrowser; screen_info: PCefScreenInfo): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(GetScreenInfo(TCefBrowserRef.UnWrap(browser), screen_info));
end;

procedure cef_render_handler_on_popup_show(self: PCefRenderProcessHandler;
  browser: PCefBrowser; show: Integer); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPopupShow(TCefBrowserRef.UnWrap(browser), show <> 0);
end;

procedure cef_render_handler_on_popup_size(self: PCefRenderProcessHandler;
  browser: PCefBrowser; const rect: PCefRect); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPopupSize(TCefBrowserRef.UnWrap(browser), rect);
end;

procedure cef_render_handler_on_paint(self: PCefRenderProcessHandler;
  browser: PCefBrowser; kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnPaint(TCefBrowserRef.UnWrap(browser), kind, dirtyRectsCount, dirtyRects,
      buffer, width, height);
end;

procedure cef_render_handler_on_cursor_change(self: PCefRenderProcessHandler;
  browser: PCefBrowser; cursor: TCefCursorHandle; type_: TCefCursorType;
  const custom_cursor_info: PCefCursorInfo); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnCursorChange(TCefBrowserRef.UnWrap(browser), cursor, type_, custom_cursor_info);
end;

function cef_render_handler_start_dragging(self: PCefRenderProcessHandler; browser: PCefBrowser;
  drag_data: PCefDragData; allowed_ops: TCefDragOperations; x, y: Integer): Integer; stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnStartDragging(TCefBrowserRef.UnWrap(browser),
      TCefDragDataRef.UnWrap(drag_data), allowed_ops, x, y));
end;

procedure cef_render_handler_update_drag_cursor(self: PCefRenderProcessHandler;
  browser: PCefBrowser; operation: TCefDragOperation); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnUpdateDragCursor(TCefBrowserRef.UnWrap(browser), operation);
end;

procedure cef_render_handler_on_scroll_offset_changed(self: PCefRenderProcessHandler;
  browser: PCefBrowser; x, y: Double); stdcall;
begin
  with TCefRenderHandlerOwn(CefGetObject(self)) do
    OnScrollOffsetChanged(TCefBrowserRef.UnWrap(browser), x, y);
end;

{ cef_completion_callback }

procedure cef_completion_callback_on_complete(self: PCefCompletionCallback); stdcall;
begin
  with TCefCompletionCallbackOwn(CefGetObject(self)) do
    OnComplete();
end;

{ cef_drag_handler }

function cef_drag_handler_on_drag_enter(self: PCefDragHandler; browser: PCefBrowser;
  dragData: PCefDragData; mask: TCefDragOperations): Integer; stdcall;
begin
  with TCefDragHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnDragEnter(TCefBrowserRef.UnWrap(browser), TCefDragDataRef.UnWrap(dragData), mask));
end;

procedure cef_drag_handler_on_draggable_regions_changed(self: PCefDragHandler;
  browser: PCefBrowser; regionsCount: NativeUInt; regions: PCefDraggableRegionArray); stdcall;
begin
  with TCefDragHandlerOwn(CefGetObject(self)) do
    OnDraggableRegionsChanged(TCefBrowserRef.UnWrap(browser), regionsCount, regions);
end;

{ cef_find_handler }

procedure cef_find_handler_on_find_result(self: PCefFindHandler; browser: PCefBrowser; identifier,
  count: Integer; const selection_rect: PCefRect; active_match_ordinal,
  final_update: Integer); stdcall;
begin
  with TCefFindHandlerOwn(CefGetObject(self)) do
    OnFindResult(TCefBrowserRef.UnWrap(browser), identifier, count, selection_rect,
      active_match_ordinal, final_update <> 0);
end;

{ cef_request_context_handler }

function cef_request_context_handler_get_cookie_manager(self: PCefRequestContextHandler): PCefCookieManager; stdcall;
begin
  with TCefRequestContextHandlerOwn(CefGetObject(self)) do
    Result := CefGetData(GetCookieManager());
end;

function cef_request_context_handler_on_before_plugin_load(self: PCefRequestContextHandler;
  const mime_type, plugin_url, top_origin_url: PCefString;
  plugin_info: PCefWebPluginInfo; plugin_policy: PCefPluginPolicy): Integer; stdcall;
begin
  with TCefRequestContextHandlerOwn(CefGetObject(self)) do
    Result := Ord(OnBeforePluginLoad(CefString(mime_type), CefString(plugin_url),
      CefString(top_origin_url), TCefWebPluginInfoRef.UnWrap(plugin_info), plugin_policy));
end;

{  cef_write_handler_ }

function cef_write_handler_write(self: PCefWriteHandler; const ptr: Pointer;
  size, n: NativeUInt): NativeUInt; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result:= Write(ptr, size, n);
end;

function cef_write_handler_seek(self: PCefWriteHandler; offset: Int64;
  whence: Integer): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Seek(offset, whence);
end;

function cef_write_handler_tell(self: PCefWriteHandler): Int64; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Tell();
end;

function cef_write_handler_flush(self: PCefWriteHandler): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Flush();
end;

function cef_write_handler_may_block(self: PCefWriteHandler): Integer; stdcall;
begin
  with TCefWriteHandlerOwn(CefGetObject(self)) do
    Result := Ord(MayBlock);
end;

{ cef_navigation_entry_visitor }

function cef_navigation_entry_visitor_visit(self: PCefNavigationEntryVisitor;
  entry: PCefNavigationEntry; current, index, total: Integer): Integer; stdcall;
begin
  with TCefNavigationEntryVisitorOwn(CefGetObject(self)) do
    Result := Ord(Visit(TCefNavigationEntryRef.UnWrap(entry), current <> 0, index, total));
end;

{ cef_set_cookie_callback }

procedure cef_set_cookie_callback_on_complete(self: PCefSetCookieCallback; success: Integer); stdcall;
begin
  with TCefSetCookieCallbackOwn(CefGetObject(self)) do
    OnComplete(success <> 0);
end;

{ cef_delete_cookie_callback }

procedure cef_delete_cookie_callback_on_complete(self: PCefDeleteCookiesCallback; num_deleted: Integer); stdcall;
begin
  with TCefDeleteCookiesCallbackOwn(CefGetObject(self)) do
    OnComplete(num_deleted);
end;

{ cef_pdf_print_callback }

procedure cef_pdf_print_callback_on_pdf_print_finished(self: PCefPdfPrintCallback; const path: PCefString; ok: Integer); stdcall;
begin
  with TCefPdfPrintCallbackOwn(CefGetObject(self)) do
    OnPdfPrintFinished(CefString(path), ok <> 0);
end;


{ TCefBaseOwn }

constructor TCefBaseOwn.CreateData(size: Cardinal; owned: Boolean);
begin
  GetMem(FData, size + SizeOf(Pointer));
  PPointer(FData)^ := Self;
  Inc(PByte(FData), SizeOf(Pointer));
  FillChar(FData^, size, 0);
  PCefBase(FData)^.size := size;
  if owned then
  begin
    PCefBase(FData)^.add_ref := cef_base_add_ref_owned;
    PCefBase(FData)^.release := cef_base_release_owned;
    PCefBase(FData)^.has_one_ref := cef_base_has_one_ref_owned;
  end else
  begin
    PCefBase(FData)^.add_ref := cef_base_add_ref;
    PCefBase(FData)^.release := cef_base_release;
    PCefBase(FData)^.has_one_ref := cef_base_has_one_ref;
  end;
end;

destructor TCefBaseOwn.Destroy;
begin
  Dec(PByte(FData), SizeOf(Pointer));
  FreeMem(FData);
  inherited;
end;

function TCefBaseOwn.Wrap: Pointer;
begin
  Result := FData;
  if Assigned(PCefBase(FData)^.add_ref) then
    PCefBase(FData)^.add_ref(PCefBase(FData));
end;

{ TCefBaseRef }

constructor TCefBaseRef.Create(data: Pointer);
begin
  Assert(data <> nil);
  FData := data;
end;

destructor TCefBaseRef.Destroy;
begin
  if Assigned(PCefBase(FData)^.release) then
    PCefBase(FData)^.release(PCefBase(FData));
  inherited;
end;

class function TCefBaseRef.UnWrap(data: Pointer): ICefBase;
begin
  if data <> nil then
    Result := Create(data) as ICefBase else
    Result := nil;
end;

function TCefBaseRef.Wrap: Pointer;
begin
  Result := FData;
  if Assigned(PCefBase(FData)^.add_ref) then
    PCefBase(FData)^.add_ref(PCefBase(FData));
end;

{ TCefBrowserRef }

function TCefBrowserRef.GetHost: ICefBrowserHost;
begin
  Result := TCefBrowserHostRef.UnWrap(PCefBrowser(FData)^.get_host(PCefBrowser(FData)));
end;

function TCefBrowserRef.CanGoBack: Boolean;
begin
  Result := PCefBrowser(FData)^.can_go_back(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.CanGoForward: Boolean;
begin
  Result := PCefBrowser(FData)^.can_go_forward(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.GetFocusedFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_focused_frame(PCefBrowser(FData)))
end;

function TCefBrowserRef.GetFrameByident(identifier: Int64): ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_frame_byident(PCefBrowser(FData), identifier));
end;

function TCefBrowserRef.GetFrame(const name: ustring): ICefFrame;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_frame(PCefBrowser(FData), @n));
end;

function TCefBrowserRef.GetFrameCount: NativeUInt;
begin
  Result := PCefBrowser(FData)^.get_frame_count(PCefBrowser(FData));
end;

procedure TCefBrowserRef.GetFrameIdentifiers(count: PNativeUInt; identifiers: PInt64);
begin
  PCefBrowser(FData)^.get_frame_identifiers(PCefBrowser(FData), count, identifiers);
end;

procedure TCefBrowserRef.GetFrameNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefBrowser(FData)^.get_frame_names(PCefBrowser(FData), list);
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefBrowserRef.SendProcessMessage(targetProcess: TCefProcessId;
  message: ICefProcessMessage): Boolean;
begin
  Result := PCefBrowser(FData)^.send_process_message(PCefBrowser(FData), targetProcess, CefGetData(message)) <> 0;
end;

function TCefBrowserRef.GetMainFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefBrowser(FData)^.get_main_frame(PCefBrowser(FData)))
end;

procedure TCefBrowserRef.GoBack;
begin
  PCefBrowser(FData)^.go_back(PCefBrowser(FData));
end;

procedure TCefBrowserRef.GoForward;
begin
  PCefBrowser(FData)^.go_forward(PCefBrowser(FData));
end;

function TCefBrowserRef.IsLoading: Boolean;
begin
  Result := PCefBrowser(FData)^.is_loading(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.HasDocument: Boolean;
begin
  Result := PCefBrowser(FData)^.has_document(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.IsPopup: Boolean;
begin
  Result := PCefBrowser(FData)^.is_popup(PCefBrowser(FData)) <> 0;
end;

function TCefBrowserRef.IsSame(const that: ICefBrowser): Boolean;
begin
  Result := PCefBrowser(FData)^.is_same(PCefBrowser(FData), CefGetData(that)) <> 0;
end;

procedure TCefBrowserRef.Reload;
begin
  PCefBrowser(FData)^.reload(PCefBrowser(FData));
end;

procedure TCefBrowserRef.ReloadIgnoreCache;
begin
  PCefBrowser(FData)^.reload_ignore_cache(PCefBrowser(FData));
end;

procedure TCefBrowserRef.StopLoad;
begin
  PCefBrowser(FData)^.stop_load(PCefBrowser(FData));
end;

function TCefBrowserRef.GetIdentifier: Integer;
begin
  Result := PCefBrowser(FData)^.get_identifier(PCefBrowser(FData));
end;

class function TCefBrowserRef.UnWrap(data: Pointer): ICefBrowser;
begin
  if data <> nil then
    Result := Create(data) as ICefBrowser else
    Result := nil;
end;

{ TCefFrameRef }

function TCefFrameRef.IsValid: Boolean;
begin
  Result := PCefFrame(FData)^.is_valid(PCefFrame(FData)) <> 0;
end;

procedure TCefFrameRef.Copy;
begin
  PCefFrame(FData)^.copy(PCefFrame(FData));
end;

procedure TCefFrameRef.Cut;
begin
  PCefFrame(FData)^.cut(PCefFrame(FData));
end;

procedure TCefFrameRef.Del;
begin
  PCefFrame(FData)^.del(PCefFrame(FData));
end;

procedure TCefFrameRef.ExecuteJavaScript(const code, scriptUrl: ustring;
  startLine: Integer);
var
  j, s: TCefString;
begin
  j := CefString(code);
  s := CefString(scriptUrl);
  PCefFrame(FData)^.execute_java_script(PCefFrame(FData), @j, @s, startline);
end;

function TCefFrameRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefFrame(FData)^.get_browser(PCefFrame(FData)));
end;

function TCefFrameRef.GetIdentifier: Int64;
begin
  Result := PCefFrame(FData)^.get_identifier(PCefFrame(FData));
end;

function TCefFrameRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefFrame(FData)^.get_name(PCefFrame(FData)));
end;

function TCefFrameRef.GetParent: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefFrame(FData)^.get_parent(PCefFrame(FData)));
end;

procedure TCefFrameRef.GetSource(const visitor: ICefStringVisitor);
begin
  PCefFrame(FData)^.get_source(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.GetSourceProc(const proc: TCefStringVisitorProc);
begin
  GetSource(TCefFastStringVisitor.Create(proc));
end;

procedure TCefFrameRef.getText(const visitor: ICefStringVisitor);
begin
  PCefFrame(FData)^.get_text(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.GetTextProc(const proc: TCefStringVisitorProc);
begin
  GetText(TCefFastStringVisitor.Create(proc));
end;

function TCefFrameRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefFrame(FData)^.get_url(PCefFrame(FData)));
end;

function TCefFrameRef.GetV8Context: ICefv8Context;
begin
  Result := TCefv8ContextRef.UnWrap(PCefFrame(FData)^.get_v8context(PCefFrame(FData)));
end;

function TCefFrameRef.IsFocused: Boolean;
begin
  Result := PCefFrame(FData)^.is_focused(PCefFrame(FData)) <> 0;
end;

function TCefFrameRef.IsMain: Boolean;
begin
  Result := PCefFrame(FData)^.is_main(PCefFrame(FData)) <> 0;
end;

procedure TCefFrameRef.LoadRequest(const request: ICefRequest);
begin
  PCefFrame(FData)^.load_request(PCefFrame(FData), CefGetData(request));
end;

procedure TCefFrameRef.LoadString(const str, url: ustring);
var
  s, u: TCefString;
begin
  s := CefString(str);
  u := CefString(url);
  PCefFrame(FData)^.load_string(PCefFrame(FData), @s, @u);
end;

procedure TCefFrameRef.LoadUrl(const url: ustring);
var
  u: TCefString;
begin
  u := CefString(url);
  PCefFrame(FData)^.load_url(PCefFrame(FData), @u);

end;

procedure TCefFrameRef.Paste;
begin
  PCefFrame(FData)^.paste(PCefFrame(FData));
end;

procedure TCefFrameRef.Redo;
begin
  PCefFrame(FData)^.redo(PCefFrame(FData));
end;

procedure TCefFrameRef.SelectAll;
begin
  PCefFrame(FData)^.select_all(PCefFrame(FData));
end;

procedure TCefFrameRef.Undo;
begin
  PCefFrame(FData)^.undo(PCefFrame(FData));
end;

procedure TCefFrameRef.ViewSource;
begin
  PCefFrame(FData)^.view_source(PCefFrame(FData));
end;

procedure TCefFrameRef.VisitDom(const visitor: ICefDomVisitor);
begin
  PCefFrame(FData)^.visit_dom(PCefFrame(FData), CefGetData(visitor));
end;

procedure TCefFrameRef.VisitDomProc(const proc: TCefDomVisitorProc);
begin
  VisitDom(TCefFastDomVisitor.Create(proc) as ICefDomVisitor);
end;

class function TCefFrameRef.UnWrap(data: Pointer): ICefFrame;
begin
  if data <> nil then
    Result := Create(data) as ICefFrame else
    Result := nil;
end;

{ TCefCustomStreamReader }

constructor TCefCustomStreamReader.Create(Stream: TStream; Owned: Boolean);
begin
  inherited CreateData(SizeOf(TCefReadHandler));
  FStream := stream;
  FOwned := Owned;
  with PCefReadHandler(FData)^ do
  begin
    read := cef_stream_reader_read;
    seek := cef_stream_reader_seek;
    tell := cef_stream_reader_tell;
    eof := cef_stream_reader_eof;
    may_block := cef_stream_reader_may_block;
  end;
end;

constructor TCefCustomStreamReader.Create(const filename: string);
begin
  Create(TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite), True);
end;

destructor TCefCustomStreamReader.Destroy;
begin
  if FOwned then
    FStream.Free;
  inherited;
end;

function TCefCustomStreamReader.Eof: Boolean;
begin
  Result := FStream.Position = FStream.size;
end;

function TCefCustomStreamReader.MayBlock: Boolean;
begin
  Result := False;
end;

function TCefCustomStreamReader.Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
begin
  result := NativeUInt(FStream.Read(ptr^, n * size)) div size;
end;

function TCefCustomStreamReader.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := FStream.Seek(offset, whence);
end;

function TCefCustomStreamReader.Tell: Int64;
begin
  Result := FStream.Position;
end;

{ TCefPostDataRef }

function TCefPostDataRef.IsReadOnly: Boolean;
begin
  Result := PCefPostData(FData)^.is_read_only(PCefPostData(FData)) <> 0;
end;

function TCefPostDataRef.AddElement(
  const element: ICefPostDataElement): Integer;
begin
  Result := PCefPostData(FData)^.add_element(PCefPostData(FData), CefGetData(element));
end;

function TCefPostDataRef.GetCount: NativeUInt;
begin
  Result := PCefPostData(FData)^.get_element_count(PCefPostData(FData))
end;

function TCefPostDataRef.GetElements(Count: NativeUInt): IInterfaceList;
var
  items: PCefPostDataElementArray;
  i: Integer;
begin
  Result := TInterfaceList.Create;
  GetMem(items, SizeOf(PCefPostDataElement) * Count);
  FillChar(items^, SizeOf(PCefPostDataElement) * Count, 0);
  try
    PCefPostData(FData)^.get_elements(PCefPostData(FData), @Count, items);
    for i := 0 to Count - 1 do
      Result.Add(TCefPostDataElementRef.UnWrap(items[i]));
  finally
    FreeMem(items);
  end;
end;

class function TCefPostDataRef.New: ICefPostData;
begin
  Result := UnWrap(cef_post_data_create);
end;

function TCefPostDataRef.RemoveElement(
  const element: ICefPostDataElement): Integer;
begin
  Result := PCefPostData(FData)^.remove_element(PCefPostData(FData), CefGetData(element));
end;

procedure TCefPostDataRef.RemoveElements;
begin
  PCefPostData(FData)^.remove_elements(PCefPostData(FData));
end;

class function TCefPostDataRef.UnWrap(data: Pointer): ICefPostData;
begin
  if data <> nil then
    Result := Create(data) as ICefPostData else
    Result := nil;
end;

{ TCefPostDataElementRef }

function TCefPostDataElementRef.IsReadOnly: Boolean;
begin
  Result := PCefPostDataElement(FData)^.is_read_only(PCefPostDataElement(FData)) <> 0;
end;

function TCefPostDataElementRef.GetBytes(size: NativeUInt;
  bytes: Pointer): NativeUInt;
begin
  Result := PCefPostDataElement(FData)^.get_bytes(PCefPostDataElement(FData), size, bytes);
end;

function TCefPostDataElementRef.GetBytesCount: NativeUInt;
begin
  Result := PCefPostDataElement(FData)^.get_bytes_count(PCefPostDataElement(FData));
end;

function TCefPostDataElementRef.GetFile: ustring;
begin
  Result := CefStringFreeAndGet(PCefPostDataElement(FData)^.get_file(PCefPostDataElement(FData)));
end;

function TCefPostDataElementRef.GetType: TCefPostDataElementType;
begin
  Result := PCefPostDataElement(FData)^.get_type(PCefPostDataElement(FData));
end;

class function TCefPostDataElementRef.New: ICefPostDataElement;
begin
  Result := UnWrap(cef_post_data_element_create);
end;

procedure TCefPostDataElementRef.SetToBytes(size: NativeUInt; bytes: Pointer);
begin
  PCefPostDataElement(FData)^.set_to_bytes(PCefPostDataElement(FData), size, bytes);
end;

procedure TCefPostDataElementRef.SetToEmpty;
begin
  PCefPostDataElement(FData)^.set_to_empty(PCefPostDataElement(FData));
end;

procedure TCefPostDataElementRef.SetToFile(const fileName: ustring);
var
  f: TCefString;
begin
  f := CefString(fileName);
  PCefPostDataElement(FData)^.set_to_file(PCefPostDataElement(FData), @f);
end;

class function TCefPostDataElementRef.UnWrap(data: Pointer): ICefPostDataElement;
begin
  if data <> nil then
    Result := Create(data) as ICefPostDataElement else
    Result := nil;
end;

{ TCefPostDataElementOwn }

procedure TCefPostDataElementOwn.Clear;
begin
  case FDataType of
    PDE_TYPE_BYTES:
      if (FValueByte <> nil) then
      begin
        FreeMem(FValueByte);
        FValueByte := nil;
      end;
    PDE_TYPE_FILE:
      CefStringFree(@FValueStr)
  end;
  FDataType := PDE_TYPE_EMPTY;
  FSize := 0;
end;

constructor TCefPostDataElementOwn.Create(readonly: Boolean);
begin
  inherited CreateData(SizeOf(TCefPostDataElement));
  FReadOnly := readonly;
  FDataType := PDE_TYPE_EMPTY;
  FValueByte := nil;
  FillChar(FValueStr, SizeOf(FValueStr), 0);
  FSize := 0;
  with PCefPostDataElement(FData)^ do
  begin
    is_read_only := cef_post_data_element_is_read_only;
    set_to_empty := cef_post_data_element_set_to_empty;
    set_to_file := cef_post_data_element_set_to_file;
    set_to_bytes := cef_post_data_element_set_to_bytes;
    get_type := cef_post_data_element_get_type;
    get_file := cef_post_data_element_get_file;
    get_bytes_count := cef_post_data_element_get_bytes_count;
    get_bytes := cef_post_data_element_get_bytes;
  end;
end;

function TCefPostDataElementOwn.GetBytes(size: NativeUInt;
  bytes: Pointer): NativeUInt;
begin
  if (FDataType = PDE_TYPE_BYTES) and (FValueByte <> nil) then
  begin
    if size > FSize then
      Result := FSize else
      Result := size;
    Move(FValueByte^, bytes^, Result);
  end else
    Result := 0;
end;

function TCefPostDataElementOwn.GetBytesCount: NativeUInt;
begin
  if (FDataType = PDE_TYPE_BYTES) then
    Result := FSize else
    Result := 0;
end;

function TCefPostDataElementOwn.GetFile: ustring;
begin
  if (FDataType = PDE_TYPE_FILE) then
    Result := CefString(@FValueStr) else
    Result := '';
end;

function TCefPostDataElementOwn.GetType: TCefPostDataElementType;
begin
  Result := FDataType;
end;

function TCefPostDataElementOwn.IsReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

procedure TCefPostDataElementOwn.SetToBytes(size: NativeUInt; bytes: Pointer);
begin
  Clear;
  if (size > 0) and (bytes <> nil) then
  begin
    GetMem(FValueByte, size);
    Move(bytes^, FValueByte, size);
    FSize := size;
  end else
  begin
    FValueByte := nil;
    FSize := 0;
  end;
  FDataType := PDE_TYPE_BYTES;
end;

procedure TCefPostDataElementOwn.SetToEmpty;
begin
  Clear;
end;

procedure TCefPostDataElementOwn.SetToFile(const fileName: ustring);
begin
  Clear;
  FSize := 0;
  FValueStr := CefStringAlloc(fileName);
  FDataType := PDE_TYPE_FILE;
end;

{ TCefRequestRef }

function TCefRequestRef.IsReadOnly: Boolean;
begin
  Result := PCefRequest(FData).is_read_only(PCefRequest(FData)) <> 0;
end;

procedure TCefRequestRef.Assign(const url, method: ustring;
  const postData: ICefPostData; const headerMap: ICefStringMultimap);
var
  u, m: TCefString;
begin
  u := cefstring(url);
  m := cefstring(method);
  PCefRequest(FData).set_(PCefRequest(FData), @u, @m, CefGetData(postData), headerMap.Handle);
end;

function TCefRequestRef.GetFirstPartyForCookies: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData).get_first_party_for_cookies(PCefRequest(FData)));
end;

function TCefRequestRef.GetFlags: TCefUrlRequestFlags;
begin
  Byte(Result) := PCefRequest(FData)^.get_flags(PCefRequest(FData));
end;

procedure TCefRequestRef.GetHeaderMap(const HeaderMap: ICefStringMultimap);
begin
  PCefRequest(FData)^.get_header_map(PCefRequest(FData), HeaderMap.Handle);
end;

function TCefRequestRef.GetIdentifier: UInt64;
begin
  Result := PCefRequest(FData)^.get_identifier(PCefRequest(FData));
end;

function TCefRequestRef.GetMethod: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData)^.get_method(PCefRequest(FData)))
end;

function TCefRequestRef.GetPostData: ICefPostData;
begin
  Result := TCefPostDataRef.UnWrap(PCefRequest(FData)^.get_post_data(PCefRequest(FData)));
end;

function TCefRequestRef.GetResourceType: TCefResourceType;
begin
  Result := PCefRequest(FData).get_resource_type(FData);
end;

function TCefRequestRef.GetTransitionType: TCefTransitionType;
begin
    Result := PCefRequest(FData).get_transition_type(FData);
end;

function TCefRequestRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequest(FData)^.get_url(PCefRequest(FData)))
end;

class function TCefRequestRef.New: ICefRequest;
begin
  Result := UnWrap(cef_request_create);
end;

procedure TCefRequestRef.SetFirstPartyForCookies(const url: ustring);
var
  str: TCefString;
begin
  str := CefString(url);
  PCefRequest(FData).set_first_party_for_cookies(PCefRequest(FData), @str);
end;

procedure TCefRequestRef.SetFlags(flags: TCefUrlRequestFlags);
begin
  PCefRequest(FData)^.set_flags(PCefRequest(FData), PByte(@flags)^);
end;

procedure TCefRequestRef.SetHeaderMap(const HeaderMap: ICefStringMultimap);
begin
  PCefRequest(FData)^.set_header_map(PCefRequest(FData), HeaderMap.Handle);
end;

procedure TCefRequestRef.SetMethod(const value: ustring);
var
  v: TCefString;
begin
  v := CefString(value);
  PCefRequest(FData)^.set_method(PCefRequest(FData), @v);
end;

procedure TCefRequestRef.SetPostData(const value: ICefPostData);
begin
  if value <> nil then
    PCefRequest(FData)^.set_post_data(PCefRequest(FData), CefGetData(value));
end;

procedure TCefRequestRef.SetUrl(const value: ustring);
var
  v: TCefString;
begin
  v := CefString(value);
  PCefRequest(FData)^.set_url(PCefRequest(FData), @v);
end;

class function TCefRequestRef.UnWrap(data: Pointer): ICefRequest;
begin
  if data <> nil then
    Result := Create(data) as ICefRequest else
    Result := nil;
end;

{ TCefStreamReaderRef }

class function TCefStreamReaderRef.CreateForCustomStream(
  const stream: ICefCustomStreamReader): ICefStreamReader;
begin
  Result := UnWrap(cef_stream_reader_create_for_handler(CefGetData(stream)))
end;

class function TCefStreamReaderRef.CreateForData(data: Pointer; size: NativeUInt): ICefStreamReader;
begin
  Result := UnWrap(cef_stream_reader_create_for_data(data, size))
end;

class function TCefStreamReaderRef.CreateForFile(const filename: ustring): ICefStreamReader;
var
  f: TCefString;
begin
  f := CefString(filename);
  Result := UnWrap(cef_stream_reader_create_for_file(@f))
end;

class function TCefStreamReaderRef.CreateForStream(const stream: TSTream;
  owned: Boolean): ICefStreamReader;
begin
  Result := CreateForCustomStream(TCefCustomStreamReader.Create(stream, owned) as ICefCustomStreamReader);
end;

function TCefStreamReaderRef.Eof: Boolean;
begin
  Result := PCefStreamReader(FData)^.eof(PCefStreamReader(FData)) <> 0;
end;

function TCefStreamReaderRef.MayBlock: Boolean;
begin
  Result := PCefStreamReader(FData)^.may_block(FData) <> 0;
end;

function TCefStreamReaderRef.Read(ptr: Pointer; size, n: NativeUInt): NativeUInt;
begin
  Result := PCefStreamReader(FData)^.read(PCefStreamReader(FData), ptr, size, n);
end;

function TCefStreamReaderRef.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := PCefStreamReader(FData)^.seek(PCefStreamReader(FData), offset, whence);
end;

function TCefStreamReaderRef.Tell: Int64;
begin
  Result := PCefStreamReader(FData)^.tell(PCefStreamReader(FData));
end;

class function TCefStreamReaderRef.UnWrap(data: Pointer): ICefStreamReader;
begin
  if data <> nil then
    Result := Create(data) as ICefStreamReader else
    Result := nil;
end;

{ TCefv8ValueRef }

function TCefv8ValueRef.AdjustExternallyAllocatedMemory(
  changeInBytes: Integer): Integer;
begin
  Result := PCefV8Value(FData)^.adjust_externally_allocated_memory(PCefV8Value(FData), changeInBytes);
end;

class function TCefv8ValueRef.NewArray(len: Integer): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_array(len));
end;

class function TCefv8ValueRef.NewBool(value: Boolean): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_bool(Ord(value)));
end;

class function TCefv8ValueRef.NewDate(value: TDateTime): ICefv8Value;
var
  dt: TCefTime;
begin
  dt := DateTimeToCefTime(value);
  Result := UnWrap(cef_v8value_create_date(@dt));
end;

class function TCefv8ValueRef.NewDouble(value: Double): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_double(value));
end;

class function TCefv8ValueRef.NewFunction(const name: ustring;
  const handler: ICefv8Handler): ICefv8Value;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := UnWrap(cef_v8value_create_function(@n, CefGetData(handler)));
end;

class function TCefv8ValueRef.NewInt(value: Integer): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_int(value));
end;

class function TCefv8ValueRef.NewUInt(value: Cardinal): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_uint(value));
end;

class function TCefv8ValueRef.NewNull: ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_null);
end;

class function TCefv8ValueRef.NewObject(const Accessor: ICefV8Accessor): ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_object(CefGetData(Accessor)));
end;

class function TCefv8ValueRef.NewObjectProc(const getter: TCefV8AccessorGetterProc;
  const setter: TCefV8AccessorSetterProc): ICefv8Value;
begin
  Result := NewObject(TCefFastV8Accessor.Create(getter, setter) as ICefV8Accessor);
end;

class function TCefv8ValueRef.NewString(const str: ustring): ICefv8Value;
var
  s: TCefString;
begin
  s := CefString(str);
  Result := UnWrap(cef_v8value_create_string(@s));
end;

class function TCefv8ValueRef.NewUndefined: ICefv8Value;
begin
  Result := UnWrap(cef_v8value_create_undefined);
end;

function TCefv8ValueRef.DeleteValueByIndex(index: Integer): Boolean;
begin
  Result := PCefV8Value(FData)^.delete_value_byindex(PCefV8Value(FData), index) <> 0;
end;

function TCefv8ValueRef.DeleteValueByKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefV8Value(FData)^.delete_value_bykey(PCefV8Value(FData), @k) <> 0;
end;

function TCefv8ValueRef.ExecuteFunction(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray): ICefv8Value;
var
  args: PPCefV8Value;
  i: Integer;
begin
  GetMem(args, SizeOf(PCefV8Value) * Length(arguments));
  try
    for i := 0 to Length(arguments) - 1 do
      args[i] := CefGetData(arguments[i]);
    Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.execute_function(PCefV8Value(FData),
      CefGetData(obj), Length(arguments), args));
  finally
    FreeMem(args);
  end;
end;

function TCefv8ValueRef.ExecuteFunctionWithContext(const context: ICefv8Context;
  const obj: ICefv8Value; const arguments: TCefv8ValueArray): ICefv8Value;
var
  args: PPCefV8Value;
  i: Integer;
begin
  GetMem(args, SizeOf(PCefV8Value) * Length(arguments));
  try
    for i := 0 to Length(arguments) - 1 do
      args[i] := CefGetData(arguments[i]);
    Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.execute_function_with_context(PCefV8Value(FData),
      CefGetData(context), CefGetData(obj), Length(arguments), args));
  finally
    FreeMem(args);
  end;
end;

function TCefv8ValueRef.GetArrayLength: Integer;
begin
  Result := PCefV8Value(FData)^.get_array_length(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetBoolValue: Boolean;
begin
  Result := PCefV8Value(FData)^.get_bool_value(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.GetDateValue: TDateTime;
begin
  Result := CefTimeToDateTime(PCefV8Value(FData)^.get_date_value(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetDoubleValue: Double;
begin
  Result := PCefV8Value(FData)^.get_double_value(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetExternallyAllocatedMemory: Integer;
begin
  Result := PCefV8Value(FData)^.get_externally_allocated_memory(PCefV8Value(FData));
end;

function TCefv8ValueRef.GetFunctionHandler: ICefv8Handler;
begin
  Result := TCefv8HandlerRef.UnWrap(PCefV8Value(FData)^.get_function_handler(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetFunctionName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Value(FData)^.get_function_name(PCefV8Value(FData)))
end;

function TCefv8ValueRef.GetIntValue: Integer;
begin
  Result := PCefV8Value(FData)^.get_int_value(PCefV8Value(FData))
end;

function TCefv8ValueRef.GetUIntValue: Cardinal;
begin
  Result := PCefV8Value(FData)^.get_uint_value(PCefV8Value(FData))
end;

function TCefv8ValueRef.GetKeys(const keys: TStrings): Integer;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefV8Value(FData)^.get_keys(PCefV8Value(FData), list);
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      keys.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefv8ValueRef.SetUserData(const data: ICefv8Value): Boolean;
begin
  Result := PCefV8Value(FData)^.set_user_data(PCefV8Value(FData), CefGetData(data)) <> 0;
end;

function TCefv8ValueRef.GetStringValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Value(FData)^.get_string_value(PCefV8Value(FData)));
end;

function TCefv8ValueRef.IsUserCreated: Boolean;
begin
  Result := PCefV8Value(FData)^.is_user_created(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsValid: Boolean;
begin
  Result := PCefV8Value(FData)^.is_valid(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.HasException: Boolean;
begin
  Result := PCefV8Value(FData)^.has_exception(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.GetException: ICefV8Exception;
begin
   Result := TCefV8ExceptionRef.UnWrap(PCefV8Value(FData)^.get_exception(PCefV8Value(FData)));
end;

function TCefv8ValueRef.ClearException: Boolean;
begin
  Result := PCefV8Value(FData)^.clear_exception(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.WillRethrowExceptions: Boolean;
begin
  Result := PCefV8Value(FData)^.will_rethrow_exceptions(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.SetRethrowExceptions(rethrow: Boolean): Boolean;
begin
  Result := PCefV8Value(FData)^.set_rethrow_exceptions(PCefV8Value(FData), Ord(rethrow)) <> 0;
end;

function TCefv8ValueRef.GetUserData: ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_user_data(PCefV8Value(FData)));
end;

function TCefv8ValueRef.GetValueByIndex(index: Integer): ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_value_byindex(PCefV8Value(FData), index))
end;

function TCefv8ValueRef.GetValueByKey(const key: ustring): ICefv8Value;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefv8ValueRef.UnWrap(PCefV8Value(FData)^.get_value_bykey(PCefV8Value(FData), @k))
end;

function TCefv8ValueRef.HasValueByIndex(index: Integer): Boolean;
begin
  Result := PCefV8Value(FData)^.has_value_byindex(PCefV8Value(FData), index) <> 0;
end;

function TCefv8ValueRef.HasValueByKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefV8Value(FData)^.has_value_bykey(PCefV8Value(FData), @k) <> 0;
end;

function TCefv8ValueRef.IsArray: Boolean;
begin
  Result := PCefV8Value(FData)^.is_array(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsBool: Boolean;
begin
  Result := PCefV8Value(FData)^.is_bool(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsDate: Boolean;
begin
  Result := PCefV8Value(FData)^.is_date(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsDouble: Boolean;
begin
  Result := PCefV8Value(FData)^.is_double(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsFunction: Boolean;
begin
  Result := PCefV8Value(FData)^.is_function(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsInt: Boolean;
begin
  Result := PCefV8Value(FData)^.is_int(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsUInt: Boolean;
begin
  Result := PCefV8Value(FData)^.is_uint(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsNull: Boolean;
begin
  Result := PCefV8Value(FData)^.is_null(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsObject: Boolean;
begin
  Result := PCefV8Value(FData)^.is_object(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsSame(const that: ICefv8Value): Boolean;
begin
  Result := PCefV8Value(FData)^.is_same(PCefV8Value(FData), CefGetData(that)) <> 0;
end;

function TCefv8ValueRef.IsString: Boolean;
begin
  Result := PCefV8Value(FData)^.is_string(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.IsUndefined: Boolean;
begin
  Result := PCefV8Value(FData)^.is_undefined(PCefV8Value(FData)) <> 0;
end;

function TCefv8ValueRef.SetValueByAccessor(const key: ustring;
  settings: TCefV8AccessControls; attribute: TCefV8PropertyAttributes): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result:= PCefV8Value(FData)^.set_value_byaccessor(PCefV8Value(FData), @k,
    PByte(@settings)^, PByte(@attribute)^) <> 0;
end;

function TCefv8ValueRef.SetValueByIndex(index: Integer;
  const value: ICefv8Value): Boolean;
begin
  Result:= PCefV8Value(FData)^.set_value_byindex(PCefV8Value(FData), index, CefGetData(value)) <> 0;
end;

function TCefv8ValueRef.SetValueByKey(const key: ustring;
  const value: ICefv8Value; attribute: TCefV8PropertyAttributes): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result:= PCefV8Value(FData)^.set_value_bykey(PCefV8Value(FData), @k,
    CefGetData(value), PByte(@attribute)^) <> 0;
end;

class function TCefv8ValueRef.UnWrap(data: Pointer): ICefv8Value;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Value else
    Result := nil;
end;

{ TCefv8HandlerRef }

function TCefv8HandlerRef.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
var
  args: array of PCefV8Value;
  i: Integer;
  ret: PCefV8Value;
  exc: TCefString;
  n: TCefString;
begin
  SetLength(args, Length(arguments));
  for i := 0 to Length(arguments) - 1 do
    args[i] := CefGetData(arguments[i]);
  ret := nil;
  FillChar(exc, SizeOf(exc), 0);
  n := CefString(name);
  Result := PCefv8Handler(FData)^.execute(PCefv8Handler(FData), @n,
    CefGetData(obj), Length(arguments), @args, ret, exc) <> 0;
  retval := TCefv8ValueRef.UnWrap(ret);
  exception := CefStringClearAndGet(exc);
end;

class function TCefv8HandlerRef.UnWrap(data: Pointer): ICefv8Handler;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Handler else
    Result := nil;
end;

{ TCefv8HandlerOwn }

constructor TCefv8HandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefv8Handler));
  with PCefv8Handler(FData)^ do
    execute := cef_v8_handler_execute;
end;

function TCefv8HandlerOwn.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
begin
  Result := False;
end;

{ TCefTaskOwn }

constructor TCefTaskOwn.Create;
begin
  inherited CreateData(SizeOf(TCefTask));
  with PCefTask(FData)^ do
    execute := cef_task_execute;
end;

procedure TCefTaskOwn.Execute;
begin

end;

{ TCefStringMapOwn }

procedure TCefStringMapOwn.Append(const key, value: ustring);
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  cef_string_map_append(FStringMap, @k, @v);
end;

procedure TCefStringMapOwn.Clear;
begin
  cef_string_map_clear(FStringMap);
end;

constructor TCefStringMapOwn.Create;
begin
  FStringMap := cef_string_map_alloc;
end;

destructor TCefStringMapOwn.Destroy;
begin
  cef_string_map_free(FStringMap);
end;

function TCefStringMapOwn.Find(const key: ustring): ustring;
var
  str, k: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  k := CefString(key);
  cef_string_map_find(FStringMap, @k, str);
  Result := CefString(@str);
end;

function TCefStringMapOwn.GetHandle: TCefStringMap;
begin
  Result := FStringMap;
end;

function TCefStringMapOwn.GetKey(index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_map_key(FStringMap, index, str);
  Result := CefString(@str);
end;

function TCefStringMapOwn.GetSize: Integer;
begin
  Result := cef_string_map_size(FStringMap);
end;

function TCefStringMapOwn.GetValue(index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_map_value(FStringMap, index, str);
  Result := CefString(@str);
end;

{ TCefStringMultimapOwn }

procedure TCefStringMultimapOwn.Append(const Key, Value: ustring);
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  cef_string_multimap_append(FStringMap, @k, @v);
end;

procedure TCefStringMultimapOwn.Clear;
begin
  cef_string_multimap_clear(FStringMap);
end;

constructor TCefStringMultimapOwn.Create;
begin
  FStringMap := cef_string_multimap_alloc;
end;

destructor TCefStringMultimapOwn.Destroy;
begin
  cef_string_multimap_free(FStringMap);
  inherited;
end;

function TCefStringMultimapOwn.FindCount(const Key: ustring): Integer;
var
  k: TCefString;
begin
  k := CefString(Key);
  Result := cef_string_multimap_find_count(FStringMap, @k);
end;

function TCefStringMultimapOwn.GetEnumerate(const Key: ustring;
  ValueIndex: Integer): ustring;
var
  k, v: TCefString;
begin
  k := CefString(Key);
  FillChar(v, SizeOf(v), 0);
  cef_string_multimap_enumerate(FStringMap, @k, ValueIndex, v);
  Result := CefString(@v);
end;

function TCefStringMultimapOwn.GetHandle: TCefStringMultimap;
begin
  Result := FStringMap;
end;

function TCefStringMultimapOwn.GetKey(Index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_multimap_key(FStringMap, index, str);
  Result := CefString(@str);
end;

function TCefStringMultimapOwn.GetSize: Integer;
begin
  Result := cef_string_multimap_size(FStringMap);
end;

function TCefStringMultimapOwn.GetValue(Index: Integer): ustring;
var
  str: TCefString;
begin
  FillChar(str, SizeOf(str), 0);
  cef_string_multimap_value(FStringMap, index, str);
  Result := CefString(@str);
end;

{ TCefDownloadHandlerOwn }

constructor TCefDownloadHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDownloadHandler));
  with PCefDownloadHandler(FData)^ do
  begin
    on_before_download := cef_download_handler_on_before_download;
    on_download_updated := cef_download_handler_on_download_updated;
  end;
end;

procedure TCefDownloadHandlerOwn.OnBeforeDownload(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem; const suggestedName: ustring;
  const callback: ICefBeforeDownloadCallback);
begin

end;

procedure TCefDownloadHandlerOwn.OnDownloadUpdated(const browser: ICefBrowser;
  const downloadItem: ICefDownloadItem;
  const callback: ICefDownloadItemCallback);
begin

end;

{ TCefXmlReaderRef }

function TCefXmlReaderRef.Close: Boolean;
begin
  Result := PCefXmlReader(FData).close(FData) <> 0;
end;

class function TCefXmlReaderRef.New(const stream: ICefStreamReader;
  encodingType: TCefXmlEncodingType; const URI: ustring): ICefXmlReader;
var
  u: TCefString;
begin
  u := CefString(URI);
  Result := UnWrap(cef_xml_reader_create(CefGetData(stream), encodingType, @u));
end;

function TCefXmlReaderRef.GetAttributeByIndex(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_byindex(FData, index));
end;

function TCefXmlReaderRef.GetAttributeByLName(const localName,
  namespaceURI: ustring): ustring;
var
  l, n: TCefString;
begin
  l := CefString(localName);
  n := CefString(namespaceURI);
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_bylname(FData, @l, @n));
end;

function TCefXmlReaderRef.GetAttributeByQName(
  const qualifiedName: ustring): ustring;
var
  q: TCefString;
begin
  q := CefString(qualifiedName);
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_attribute_byqname(FData, @q));
end;

function TCefXmlReaderRef.GetAttributeCount: NativeUInt;
begin
  Result := PCefXmlReader(FData).get_attribute_count(FData);
end;

function TCefXmlReaderRef.GetBaseUri: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_base_uri(FData));
end;

function TCefXmlReaderRef.GetDepth: Integer;
begin
  Result := PCefXmlReader(FData).get_depth(FData);
end;

function TCefXmlReaderRef.GetError: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_error(FData));
end;

function TCefXmlReaderRef.GetInnerXml: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_inner_xml(FData));
end;

function TCefXmlReaderRef.GetLineNumber: Integer;
begin
  Result := PCefXmlReader(FData).get_line_number(FData);
end;

function TCefXmlReaderRef.GetLocalName: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_local_name(FData));
end;

function TCefXmlReaderRef.GetNamespaceUri: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_namespace_uri(FData));
end;

function TCefXmlReaderRef.GetOuterXml: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_outer_xml(FData));
end;

function TCefXmlReaderRef.GetPrefix: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_prefix(FData));
end;

function TCefXmlReaderRef.GetQualifiedName: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_qualified_name(FData));
end;

function TCefXmlReaderRef.GetType: TCefXmlNodeType;
begin
  Result := PCefXmlReader(FData).get_type(FData);
end;

function TCefXmlReaderRef.GetValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_value(FData));
end;

function TCefXmlReaderRef.GetXmlLang: ustring;
begin
  Result := CefStringFreeAndGet(PCefXmlReader(FData).get_xml_lang(FData));
end;

function TCefXmlReaderRef.HasAttributes: Boolean;
begin
  Result := PCefXmlReader(FData).has_attributes(FData) <> 0;
end;

function TCefXmlReaderRef.HasError: Boolean;
begin
  Result := PCefXmlReader(FData).has_error(FData) <> 0;
end;

function TCefXmlReaderRef.HasValue: Boolean;
begin
  Result := PCefXmlReader(FData).has_value(FData) <> 0;
end;

function TCefXmlReaderRef.IsEmptyElement: Boolean;
begin
  Result := PCefXmlReader(FData).is_empty_element(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByIndex(index: Integer): Boolean;
begin
  Result := PCefXmlReader(FData).move_to_attribute_byindex(FData, index) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByLName(const localName,
  namespaceURI: ustring): Boolean;
var
  l, n: TCefString;
begin
  l := CefString(localName);
  n := CefString(namespaceURI);
  Result := PCefXmlReader(FData).move_to_attribute_bylname(FData, @l, @n) <> 0;
end;

function TCefXmlReaderRef.MoveToAttributeByQName(
  const qualifiedName: ustring): Boolean;
var
  q: TCefString;
begin
  q := CefString(qualifiedName);
  Result := PCefXmlReader(FData).move_to_attribute_byqname(FData, @q) <> 0;
end;

function TCefXmlReaderRef.MoveToCarryingElement: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_carrying_element(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToFirstAttribute: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_first_attribute(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToNextAttribute: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_next_attribute(FData) <> 0;
end;

function TCefXmlReaderRef.MoveToNextNode: Boolean;
begin
  Result := PCefXmlReader(FData).move_to_next_node(FData) <> 0;
end;

class function TCefXmlReaderRef.UnWrap(data: Pointer): ICefXmlReader;
begin
  if data <> nil then
    Result := Create(data) as ICefXmlReader else
    Result := nil;
end;

{ TCefZipReaderRef }

function TCefZipReaderRef.Close: Boolean;
begin
  Result := PCefZipReader(FData).close(FData) <> 0;
end;

function TCefZipReaderRef.CloseFile: Boolean;
begin
  Result := PCefZipReader(FData).close_file(FData) <> 0;
end;

class function TCefZipReaderRef.New(const stream: ICefStreamReader): ICefZipReader;
begin
  Result := UnWrap(cef_zip_reader_create(CefGetData(stream)));
end;

function TCefZipReaderRef.Eof: Boolean;
begin
  Result := PCefZipReader(FData).eof(FData) <> 0;
end;

function TCefZipReaderRef.GetFileLastModified: TCefTime;
begin
  Result := PCefZipReader(FData).get_file_last_modified(FData);
end;

function TCefZipReaderRef.GetFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefZipReader(FData).get_file_name(FData));
end;

function TCefZipReaderRef.GetFileSize: Int64;
begin
  Result := PCefZipReader(FData).get_file_size(FData);
end;

function TCefZipReaderRef.MoveToFile(const fileName: ustring;
  caseSensitive: Boolean): Boolean;
var
  f: TCefString;
begin
  f := CefString(fileName);
  Result := PCefZipReader(FData).move_to_file(FData, @f, Ord(caseSensitive)) <> 0;
end;

function TCefZipReaderRef.MoveToFirstFile: Boolean;
begin
  Result := PCefZipReader(FData).move_to_first_file(FData) <> 0;
end;

function TCefZipReaderRef.MoveToNextFile: Boolean;
begin
  Result := PCefZipReader(FData).move_to_next_file(FData) <> 0;
end;

function TCefZipReaderRef.OpenFile(const password: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(password);
  Result := PCefZipReader(FData).open_file(FData, @p) <> 0;
end;

function TCefZipReaderRef.ReadFile(buffer: Pointer;
  bufferSize: NativeUInt): Integer;
begin
    Result := PCefZipReader(FData).read_file(FData, buffer, buffersize);
end;

function TCefZipReaderRef.Tell: Int64;
begin
  Result := PCefZipReader(FData).tell(FData);
end;

class function TCefZipReaderRef.UnWrap(data: Pointer): ICefZipReader;
begin
  if data <> nil then
    Result := Create(data) as ICefZipReader else
    Result := nil;
end;

{ TCefFastTask }

constructor TCefFastTask.Create(const method: TCefFastTaskProc);
begin
  inherited Create;
  FMethod := method;
end;

procedure TCefFastTask.Execute;
begin
  FMethod();
end;

class procedure TCefFastTask.New(threadId: TCefThreadId; const method: TCefFastTaskProc);
begin
  CefPostTask(threadId, Create(method));
end;

class procedure TCefFastTask.NewDelayed(threadId: TCefThreadId;
  Delay: Int64; const method: TCefFastTaskProc);
begin
  CefPostDelayedTask(threadId, Create(method), Delay);
end;

{ TCefv8ContextRef }

class function TCefv8ContextRef.Current: ICefv8Context;
begin
  Result := UnWrap(cef_v8context_get_current_context)
end;

function TCefv8ContextRef.Enter: Boolean;
begin
  Result := PCefv8Context(FData)^.enter(PCefv8Context(FData)) <> 0;
end;

class function TCefv8ContextRef.Entered: ICefv8Context;
begin
  Result := UnWrap(cef_v8context_get_entered_context)
end;

function TCefv8ContextRef.Exit: Boolean;
begin
  Result := PCefv8Context(FData)^.exit(PCefv8Context(FData)) <> 0;
end;

function TCefv8ContextRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefv8Context(FData)^.get_browser(PCefv8Context(FData)));
end;

function TCefv8ContextRef.GetFrame: ICefFrame;
begin
  Result := TCefFrameRef.UnWrap(PCefv8Context(FData)^.get_frame(PCefv8Context(FData)))
end;

function TCefv8ContextRef.GetGlobal: ICefv8Value;
begin
  Result := TCefv8ValueRef.UnWrap(PCefv8Context(FData)^.get_global(PCefv8Context(FData)));
end;

function TCefv8ContextRef.GetTaskRunner: ICefTaskRunner;
begin
  Result := TCefTaskRunnerRef.UnWrap(PCefv8Context(FData)^.get_task_runner(FData));
end;

function TCefv8ContextRef.IsSame(const that: ICefv8Context): Boolean;
begin
  Result := PCefv8Context(FData)^.is_same(PCefv8Context(FData), CefGetData(that)) <> 0;
end;

function TCefv8ContextRef.IsValid: Boolean;
begin
  Result := PCefv8Context(FData)^.is_valid(FData) <> 0;
end;

function TCefv8ContextRef.Eval(const code: ustring; var retval: ICefv8Value;
 var exception: ICefV8Exception): Boolean;
var
  c: TCefString;
  r: PCefv8Value;
  e: PCefV8Exception;
begin
  c := CefString(code);
  r := nil; e := nil;
  Result := PCefv8Context(FData)^.eval(PCefv8Context(FData), @c, r, e) <> 0;
  retval := TCefv8ValueRef.UnWrap(r);
  exception := TCefV8ExceptionRef.UnWrap(e);
end;

class function TCefv8ContextRef.UnWrap(data: Pointer): ICefv8Context;
begin
  if data <> nil then
    Result := Create(data) as ICefv8Context else
    Result := nil;
end;

{ TCefDomVisitorOwn }

constructor TCefDomVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDomVisitor));
  with PCefDomVisitor(FData)^ do
    visit := cef_dom_visitor_visite;
end;

procedure TCefDomVisitorOwn.visit(const document: ICefDomDocument);
begin

end;

{ TCefFastDomVisitor }

constructor TCefFastDomVisitor.Create(const proc: TCefDomVisitorProc);
begin
  inherited Create;
  FProc := proc;
end;

procedure TCefFastDomVisitor.visit(const document: ICefDomDocument);
begin
  FProc(document);
end;

{ TCefDomDocumentRef }

function TCefDomDocumentRef.GetBaseUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_base_url(PCefDomDocument(FData)))
end;

function TCefDomDocumentRef.GetBody: ICefDomNode;
begin
  Result :=  TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_body(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetCompleteUrl(const partialURL: ustring): ustring;
var
  p: TCefString;
begin
  p := CefString(partialURL);
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_complete_url(PCefDomDocument(FData), @p));
end;

function TCefDomDocumentRef.GetDocument: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_document(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetElementById(const id: ustring): ICefDomNode;
var
  i: TCefString;
begin
  i := CefString(id);
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_element_by_id(PCefDomDocument(FData), @i));
end;

function TCefDomDocumentRef.GetFocusedNode: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_focused_node(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetHead: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomDocument(FData)^.get_head(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionAsMarkup: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_selection_as_markup(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionAsText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_selection_as_text(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetSelectionEndOffset: Integer;
begin
  Result := PCefDomDocument(FData)^.get_selection_end_offset(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.GetSelectionStartOffset: Integer;
begin
  Result := PCefDomDocument(FData)^.get_selection_start_offset(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.GetTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomDocument(FData)^.get_title(PCefDomDocument(FData)));
end;

function TCefDomDocumentRef.GetType: TCefDomDocumentType;
begin
  Result := PCefDomDocument(FData)^.get_type(PCefDomDocument(FData));
end;

function TCefDomDocumentRef.HasSelection: Boolean;
begin
  Result := PCefDomDocument(FData)^.has_selection(PCefDomDocument(FData)) <> 0;
end;

class function TCefDomDocumentRef.UnWrap(data: Pointer): ICefDomDocument;
begin
  if data <> nil then
    Result := Create(data) as ICefDomDocument else
    Result := nil;
end;

{ TCefDomNodeRef }

function TCefDomNodeRef.GetAsMarkup: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_as_markup(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetDocument: ICefDomDocument;
begin
  Result := TCefDomDocumentRef.UnWrap(PCefDomNode(FData)^.get_document(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetElementAttribute(const attrName: ustring): ustring;
var
  p: TCefString;
begin
  p := CefString(attrName);
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_attribute(PCefDomNode(FData), @p));
end;

procedure TCefDomNodeRef.GetElementAttributes(const attrMap: ICefStringMap);
begin
  PCefDomNode(FData)^.get_element_attributes(PCefDomNode(FData), attrMap.Handle);
end;

function TCefDomNodeRef.GetElementInnerText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_inner_text(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetElementTagName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_element_tag_name(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetFirstChild: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_first_child(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetFormControlElementType: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_form_control_element_type(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetLastChild: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_last_child(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_name(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetNextSibling: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_next_sibling(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetParent: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_parent(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetPreviousSibling: ICefDomNode;
begin
  Result := TCefDomNodeRef.UnWrap(PCefDomNode(FData)^.get_previous_sibling(PCefDomNode(FData)));
end;

function TCefDomNodeRef.GetType: TCefDomNodeType;
begin
  Result := PCefDomNode(FData)^.get_type(PCefDomNode(FData));
end;

function TCefDomNodeRef.GetValue: ustring;
begin
  Result := CefStringFreeAndGet(PCefDomNode(FData)^.get_value(PCefDomNode(FData)));
end;

function TCefDomNodeRef.HasChildren: Boolean;
begin
  Result := PCefDomNode(FData)^.has_children(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.HasElementAttribute(const attrName: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(attrName);
  Result := PCefDomNode(FData)^.has_element_attribute(PCefDomNode(FData), @p) <> 0;
end;

function TCefDomNodeRef.HasElementAttributes: Boolean;
begin
  Result := PCefDomNode(FData)^.has_element_attributes(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsEditable: Boolean;
begin
  Result := PCefDomNode(FData)^.is_editable(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsElement: Boolean;
begin
  Result := PCefDomNode(FData)^.is_element(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsFormControlElement: Boolean;
begin
  Result := PCefDomNode(FData)^.is_form_control_element(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.IsSame(const that: ICefDomNode): Boolean;
begin
  Result := PCefDomNode(FData)^.is_same(PCefDomNode(FData), CefGetData(that)) <> 0;
end;

function TCefDomNodeRef.IsText: Boolean;
begin
  Result := PCefDomNode(FData)^.is_text(PCefDomNode(FData)) <> 0;
end;

function TCefDomNodeRef.SetElementAttribute(const attrName,
  value: ustring): Boolean;
var
  p1, p2: TCefString;
begin
  p1 := CefString(attrName);
  p2 := CefString(value);
  Result := PCefDomNode(FData)^.set_element_attribute(PCefDomNode(FData), @p1, @p2) <> 0;
end;

function TCefDomNodeRef.SetValue(const value: ustring): Boolean;
var
  p: TCefString;
begin
  p := CefString(value);
  Result := PCefDomNode(FData)^.set_value(PCefDomNode(FData), @p) <> 0;
end;

class function TCefDomNodeRef.UnWrap(data: Pointer): ICefDomNode;
begin
  if data <> nil then
    Result := Create(data) as ICefDomNode else
    Result := nil;
end;

{ TCefResponseRef }

class function TCefResponseRef.New: ICefResponse;
begin
  Result := UnWrap(cef_response_create);
end;

function TCefResponseRef.GetHeader(const name: ustring): ustring;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_header(PCefResponse(FData), @n));
end;

procedure TCefResponseRef.GetHeaderMap(const headerMap: ICefStringMultimap);
begin
  PCefResponse(FData)^.get_header_map(PCefResponse(FData), headermap.Handle);
end;

function TCefResponseRef.GetMimeType: ustring;
begin
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_mime_type(PCefResponse(FData)));
end;

function TCefResponseRef.GetStatus: Integer;
begin
  Result := PCefResponse(FData)^.get_status(PCefResponse(FData));
end;

function TCefResponseRef.GetStatusText: ustring;
begin
  Result := CefStringFreeAndGet(PCefResponse(FData)^.get_status_text(PCefResponse(FData)));
end;

function TCefResponseRef.IsReadOnly: Boolean;
begin
  Result := PCefResponse(FData)^.is_read_only(PCefResponse(FData)) <> 0;
end;

procedure TCefResponseRef.SetHeaderMap(const headerMap: ICefStringMultimap);
begin
  PCefResponse(FData)^.set_header_map(PCefResponse(FData), headerMap.Handle);
end;

procedure TCefResponseRef.SetMimeType(const mimetype: ustring);
var
  txt: TCefString;
begin
  txt := CefString(mimetype);
  PCefResponse(FData)^.set_mime_type(PCefResponse(FData), @txt);
end;

procedure TCefResponseRef.SetStatus(status: Integer);
begin
  PCefResponse(FData)^.set_status(PCefResponse(FData), status);
end;

procedure TCefResponseRef.SetStatusText(const StatusText: ustring);
var
  txt: TCefString;
begin
  txt := CefString(StatusText);
  PCefResponse(FData)^.set_status_text(PCefResponse(FData), @txt);
end;

class function TCefResponseRef.UnWrap(data: Pointer): ICefResponse;
begin
  if data <> nil then
    Result := Create(data) as ICefResponse else
    Result := nil;
end;

{ TCefRTTIExtension }

{$IFDEF DELPHI14_UP}

constructor TCefRTTIExtension.Create(const value: TValue
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
; SyncMainThread: Boolean
{$ENDIF}
);
begin
  inherited Create;
  FCtx := TRttiContext.Create;
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
  FSyncMainThread := SyncMainThread;
{$ENDIF}
  FValue := value;
end;

destructor TCefRTTIExtension.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TCefRTTIExtension.GetValue(pi: PTypeInfo; const v: ICefv8Value; var ret: TValue): Boolean;
  function ProcessInt: Boolean;
  var
    sv: record
      case byte of
      0:  (ub: Byte);
      1:  (sb: ShortInt);
      2:  (uw: Word);
      3:  (sw: SmallInt);
      4:  (si: Integer);
      5:  (ui: Cardinal);
    end;
    pd: PTypeData;
  begin
    pd := GetTypeData(pi);
    if (v.IsInt or v.IsBool) and (v.GetIntValue >= pd.MinValue) and (v.GetIntValue <= pd.MaxValue) then
    begin
      case pd.OrdType of
        otSByte: sv.sb := v.GetIntValue;
        otUByte: sv.ub := v.GetIntValue;
        otSWord: sv.sw := v.GetIntValue;
        otUWord: sv.uw := v.GetIntValue;
        otSLong: sv.si := v.GetIntValue;
        otULong: sv.ui := v.GetIntValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessInt64: Boolean;
  var
    i: Int64;
  begin
    i := StrToInt64(v.GetStringValue); // hack
    TValue.Make(@i, pi, ret);
    Result := True;
  end;

  function ProcessUString: Boolean;
  var
    vus: string;
  begin
    if v.IsString then
    begin
      vus := v.GetStringValue;
      TValue.Make(@vus, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessLString: Boolean;
  var
    vas: AnsiString;
  begin
    if v.IsString then
    begin
      vas := AnsiString(v.GetStringValue);
      TValue.Make(@vas, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessWString: Boolean;
  var
    vws: WideString;
  begin
    if v.IsString then
    begin
      vws := v.GetStringValue;
      TValue.Make(@vws, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessFloat: Boolean;
  var
    sv: record
      case byte of
      0: (fs: Single);
      1: (fd: Double);
      2: (fe: Extended);
      3: (fc: Comp);
      4: (fcu: Currency);
    end;
  begin
    if v.IsDouble or v.IsInt then
    begin
      case GetTypeData(pi).FloatType of
        ftSingle: sv.fs := v.GetDoubleValue;
        ftDouble: sv.fd := v.GetDoubleValue;
        ftExtended: sv.fe := v.GetDoubleValue;
        ftComp: sv.fc := v.GetDoubleValue;
        ftCurr: sv.fcu := v.GetDoubleValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
    if v.IsDate then
    begin
      sv.fd := v.GetDateValue;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessSet: Boolean;
  var
    sv: record
      case byte of
      0:  (ub: Byte);
      1:  (sb: ShortInt);
      2:  (uw: Word);
      3:  (sw: SmallInt);
      4:  (si: Integer);
      5:  (ui: Cardinal);
    end;
  begin
    if v.IsInt then
    begin
      case GetTypeData(pi).OrdType of
        otSByte: sv.sb := v.GetIntValue;
        otUByte: sv.ub := v.GetIntValue;
        otSWord: sv.sw := v.GetIntValue;
        otUWord: sv.uw := v.GetIntValue;
        otSLong: sv.si := v.GetIntValue;
        otULong: sv.ui := v.GetIntValue;
      end;
      TValue.Make(@sv, pi, ret);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessVariant: Boolean;
  var
    vr: Variant;
    i: Integer;
    vl: TValue;
  begin
    VarClear(vr);
    if v.IsString then vr := v.GetStringValue else
    if v.IsBool then vr := v.GetBoolValue else
    if v.IsInt then vr := v.GetIntValue else
    if v.IsDouble then vr := v.GetDoubleValue else
    if v.IsUndefined then TVarData(vr).VType := varEmpty else
    if v.IsNull then TVarData(vr).VType := varNull else
    if v.IsArray then
      begin
        vr := VarArrayCreate([0, v.GetArrayLength], varVariant);
        for i := 0 to v.GetArrayLength - 1 do
        begin
          if not GetValue(pi, v.GetValueByIndex(i), vl) then Exit(False);
          VarArrayPut(vr, vl.AsVariant, i);
        end;
      end else
      Exit(False);
    TValue.Make(@vr, pi, ret);
    Result := True;
  end;

  function ProcessObject: Boolean;
  var
    ud: ICefv8Value;
    i: Pointer;
    td: PTypeData;
    rt: TRttiType;
  begin
    if v.IsObject then
    begin
      ud := v.GetUserData;
      if (ud = nil) then Exit(False);
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}
      td := GetTypeData(rt.Handle);

      if (rt.TypeKind = tkClass) and td.ClassType.InheritsFrom(GetTypeData(pi).ClassType) then
      begin
{$IFDEF CPUX64}
        i := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
        i := Pointer(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}

        TValue.Make(@i, pi, ret);
      end else
        Exit(False);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessClass: Boolean;
  var
    ud: ICefv8Value;
    i: Pointer;
    rt: TRttiType;
  begin
    if v.IsObject then
    begin
      ud := v.GetUserData;
      if (ud = nil) then Exit(False);
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}

      if (rt.TypeKind = tkClassRef) then
      begin
{$IFDEF CPUX64}
        i := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
        i := Pointer(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
        TValue.Make(@i, pi, ret);
      end else
        Exit(False);
    end else
      Exit(False);
    Result := True;
  end;

  function ProcessRecord: Boolean;
  var
    r: TRttiField;
    f: TValue;
    rec: Pointer;
  begin
    if v.IsObject then
    begin
      TValue.Make(nil, pi, ret);
{$IFDEF DELPHI15_UP}
      rec := TValueData(ret).FValueData.GetReferenceToRawData;
{$ELSE}
      rec := IValueData(TValueData(ret).FHeapData).GetReferenceToRawData;
{$ENDIF}
      for r in FCtx.GetType(pi).GetFields do
      begin
        if not GetValue(r.FieldType.Handle, v.GetValueByKey(r.Name), f) then
          Exit(False);
        r.SetValue(rec, f);
      end;
      Result := True;
    end else
      Result := False;
  end;

  function ProcessInterface: Boolean;
  begin
    if pi = TypeInfo(ICefV8Value) then
    begin
      TValue.Make(@v, pi, ret);
      Result := True;
    end else
      Result := False; // todo
  end;
begin
  case pi.Kind of
    tkInteger, tkEnumeration: Result := ProcessInt;
    tkInt64: Result := ProcessInt64;
    tkUString: Result := ProcessUString;
    tkLString: Result := ProcessLString;
    tkWString: Result := ProcessWString;
    tkFloat: Result := ProcessFloat;
    tkSet: Result := ProcessSet;
    tkVariant: Result := ProcessVariant;
    tkClass: Result := ProcessObject;
    tkClassRef: Result := ProcessClass;
    tkRecord: Result := ProcessRecord;
    tkInterface: Result := ProcessInterface;
  else
    Result := False;
  end;
end;

function TCefRTTIExtension.SetValue(const v: TValue; var ret: ICefv8Value): Boolean;

  function ProcessRecord: Boolean;
  var
    rf: TRttiField;
    vl: TValue;
    ud, v8: ICefv8Value;
    rec: Pointer;
    rt: TRttiType;
  begin
    ud := TCefv8ValueRef.NewArray(1);
    rt := FCtx.GetType(v.TypeInfo);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil);
    ret.SetUserData(ud);

{$IFDEF DELPHI15_UP}
    rec := TValueData(v).FValueData.GetReferenceToRawData;
{$ELSE}
    rec := IValueData(TValueData(v).FHeapData).GetReferenceToRawData;
{$ENDIF}
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    if FSyncMainThread then
    begin
      v8 := ret;
      TThread.Synchronize(nil, procedure
      var
        rf: TRttiField;
        o: ICefv8Value;
      begin
        for rf in rt.GetFields do
        begin
          vl := rf.GetValue(rec);
          SetValue(vl, o);
          v8.SetValueByKey(rf.Name, o, []);
        end;
      end)
    end else
{$ENDIF}
      for rf in FCtx.GetType(v.TypeInfo).GetFields do
      begin
        vl := rf.GetValue(rec);
        if not SetValue(vl, v8) then
          Exit(False);
        ret.SetValueByKey(rf.Name, v8,  []);
      end;
    Result := True;
  end;

  function ProcessObject: Boolean;
  var
    m: TRttiMethod;
    p: TRttiProperty;
    fl: TRttiField;
    f: ICefv8Value;
    _r, _g, _s, ud: ICefv8Value;
    _a: TCefv8ValueArray;
    rt: TRttiType;
  begin
    rt := FCtx.GetType(v.TypeInfo);

    ud := TCefv8ValueRef.NewArray(2);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(v.AsObject)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(v.AsObject)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil); // todo
    ret.SetUserData(ud);

    for m in rt.GetMethods do
      if m.Visibility > mvProtected then
      begin
        f := TCefv8ValueRef.NewFunction(m.Name, Self);
        ret.SetValueByKey(m.Name, f, []);
      end;

    for p in rt.GetProperties do
      if (p.Visibility > mvProtected) then
      begin
        if _g = nil then _g := ret.GetValueByKey('__defineGetter__');
        if _s = nil then _s := ret.GetValueByKey('__defineSetter__');
        SetLength(_a, 2);
        _a[0] := TCefv8ValueRef.NewString(p.Name);
        if p.IsReadable then
        begin
          _a[1] := TCefv8ValueRef.NewFunction('$pg' + p.Name, Self);
          _r := _g.ExecuteFunction(ret, _a);
        end;
        if p.IsWritable then
        begin
          _a[1] := TCefv8ValueRef.NewFunction('$ps' + p.Name, Self);
          _r := _s.ExecuteFunction(ret, _a);
        end;
      end;

    for fl in rt.GetFields do
      if (fl.Visibility > mvProtected) then
      begin
        if _g = nil then _g := ret.GetValueByKey('__defineGetter__');
        if _s = nil then _s := ret.GetValueByKey('__defineSetter__');

        SetLength(_a, 2);
        _a[0] := TCefv8ValueRef.NewString(fl.Name);
        _a[1] := TCefv8ValueRef.NewFunction('$vg' + fl.Name, Self);
        _r := _g.ExecuteFunction(ret, _a);
        _a[1] := TCefv8ValueRef.NewFunction('$vs' + fl.Name, Self);
        _r := _s.ExecuteFunction(ret, _a);
      end;

    Result := True;
  end;

  function ProcessClass: Boolean;
  var
    m: TRttiMethod;
    f, ud: ICefv8Value;
    c: TClass;
    rt: TRttiType;
  begin
    c := v.AsClass;
    rt := FCtx.GetType(c);

    ud := TCefv8ValueRef.NewArray(2);
{$IFDEF CPUX64}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(c)));
{$ELSE}
    ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
    ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(c)));
{$ENDIF}
    ret := TCefv8ValueRef.NewObject(nil); // todo
    ret.SetUserData(ud);

    if c <> nil then
    begin
      for m in rt.GetMethods do
        if (m.Visibility > mvProtected) and (m.MethodKind in [mkClassProcedure, mkClassFunction]) then
        begin
          f := TCefv8ValueRef.NewFunction(m.Name, Self);
          ret.SetValueByKey(m.Name, f, []);
        end;
    end;

    Result := True;
  end;

  function ProcessVariant: Boolean;
  var
    vr: Variant;
  begin
    vr := v.AsVariant;
    case TVarData(vr).VType of
      varSmallint, varInteger, varShortInt:
        ret := TCefv8ValueRef.NewInt(vr);
      varByte, varWord, varLongWord:
        ret := TCefv8ValueRef.NewUInt(vr);
      varUString, varOleStr, varString:
        ret := TCefv8ValueRef.NewString(vr);
      varSingle, varDouble, varCurrency, varUInt64, varInt64:
        ret := TCefv8ValueRef.NewDouble(vr);
      varBoolean:
        ret := TCefv8ValueRef.NewBool(vr);
      varNull:
        ret := TCefv8ValueRef.NewNull;
      varEmpty:
        ret := TCefv8ValueRef.NewUndefined;
    else
      ret := nil;
      Exit(False)
    end;
    Result := True;
  end;

  function ProcessInterface: Boolean;
  var
    m: TRttiMethod;
    f: ICefv8Value;
    ud: ICefv8Value;
    rt: TRttiType;
  begin

    if TypeInfo(ICefV8Value) = v.TypeInfo then
    begin
      ret := ICefV8Value(v.AsInterface);
      Result := True;
    end else
    begin
      rt := FCtx.GetType(v.TypeInfo);


      ud := TCefv8ValueRef.NewArray(2);
  {$IFDEF CPUX64}
      ud.SetValueByIndex(0, TCefv8ValueRef.NewString(PtrToStr(rt)));
      ud.SetValueByIndex(1, TCefv8ValueRef.NewString(PtrToStr(Pointer(v.AsInterface))));
  {$ELSE}
      ud.SetValueByIndex(0, TCefv8ValueRef.NewInt(Integer(rt)));
      ud.SetValueByIndex(1, TCefv8ValueRef.NewInt(Integer(v.AsInterface)));
  {$ENDIF}
      ret := TCefv8ValueRef.NewObject(nil);
      ret.SetUserData(ud);

      for m in rt.GetMethods do
        if m.Visibility > mvProtected then
        begin
          f := TCefv8ValueRef.NewFunction(m.Name, Self);
          ret.SetValueByKey(m.Name, f, []);
        end;

      Result := True;
    end;
  end;

  function ProcessFloat: Boolean;
  begin
    if v.TypeInfo = TypeInfo(TDateTime) then
      ret := TCefv8ValueRef.NewDate(TValueData(v).FAsDouble) else
      ret := TCefv8ValueRef.NewDouble(v.AsExtended);
    Result := True;
  end;

begin
  case v.TypeInfo.Kind of
    tkUString, tkLString, tkWString, tkChar, tkWChar:
      ret := TCefv8ValueRef.NewString(v.AsString);
    tkInteger: ret := TCefv8ValueRef.NewInt(v.AsInteger);
    tkEnumeration:
      if v.TypeInfo = TypeInfo(Boolean) then
        ret := TCefv8ValueRef.NewBool(v.AsBoolean) else
        ret := TCefv8ValueRef.NewInt(TValueData(v).FAsSLong);
    tkFloat: if not ProcessFloat then Exit(False);
    tkInt64: ret := TCefv8ValueRef.NewDouble(v.AsInt64);
    tkClass: if not ProcessObject then Exit(False);
    tkClassRef: if not ProcessClass then Exit(False);
    tkRecord: if not ProcessRecord then Exit(False);
    tkVariant: if not ProcessVariant then Exit(False);
    tkInterface: if not ProcessInterface then Exit(False);
  else
    Exit(False)
  end;
  Result := True;
end;

class procedure TCefRTTIExtension.Register(const name: string;
  const value: TValue{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}; SyncMainThread: Boolean{$ENDIF});
begin
  CefRegisterExtension(name,
    format('__defineSetter__(''%s'', function(v){native function $s();$s(v)});__defineGetter__(''%0:s'', function(){native function $g();return $g()});', [name]),
    TCefRTTIExtension.Create(value
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
    , SyncMainThread
{$ENDIF}
    ) as ICefv8Handler);
end;

{$IFDEF CPUX64}
class function TCefRTTIExtension.StrToPtr(const str: ustring): Pointer;
begin
  HexToBin(PWideChar(str), @Result, SizeOf(Result));
end;

class function TCefRTTIExtension.PtrToStr(p: Pointer): ustring;
begin
  SetLength(Result, SizeOf(p)*2);
  BinToHex(@p, PWideChar(Result), SizeOf(p));
end;
{$ENDIF}

function TCefRTTIExtension.Execute(const name: ustring; const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring): Boolean;
var
  p: PChar;
  ud: ICefv8Value;
  rt: TRttiType;
  val: TObject;
  cls: TClass;
  m: TRttiMethod;
  pr: TRttiProperty;
  vl: TRttiField;
  args: array of TValue;
  prm: TArray<TRttiParameter>;
  i: Integer;
  ret: TValue;
begin
  Result := True;
  p := PChar(name);
  m := nil;
  if obj <> nil then
  begin
    ud := obj.GetUserData;
    if ud <> nil then
    begin
{$IFDEF CPUX64}
      rt := StrToPtr(ud.GetValueByIndex(0).GetStringValue);
{$ELSE}
      rt := TRttiType(ud.GetValueByIndex(0).GetIntValue);
{$ENDIF}
      case rt.TypeKind of
        tkClass:
          begin
{$IFDEF CPUX64}
            val := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
            val := TObject(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
            cls := GetTypeData(rt.Handle).ClassType;

            if p^ = '$' then
            begin
              inc(p);
              case p^ of
                'p':
                  begin
                    inc(p);
                    case p^ of
                    'g':
                      begin
                        inc(p);
                        pr := rt.GetProperty(p);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                        if FSyncMainThread then
                        begin
                          TThread.Synchronize(nil, procedure begin
                            ret := pr.GetValue(val);
                          end);
                          Exit(SetValue(ret, retval));
                        end else
{$ENDIF}
                          Exit(SetValue(pr.GetValue(val), retval));
                      end;
                    's':
                      begin
                        inc(p);
                        pr := rt.GetProperty(p);
                        if GetValue(pr.PropertyType.Handle, arguments[0], ret) then
                        begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                          if FSyncMainThread then
                            TThread.Synchronize(nil, procedure begin
                              pr.SetValue(val, ret) end) else
{$ENDIF}
                            pr.SetValue(val, ret);
                          Exit(True);
                        end else
                          Exit(False);
                      end;
                    end;
                  end;
                'v':
                  begin
                    inc(p);
                    case p^ of
                    'g':
                      begin
                        inc(p);
                        vl := rt.GetField(p);
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                        if FSyncMainThread then
                        begin
                          TThread.Synchronize(nil, procedure begin
                            ret := vl.GetValue(val);
                          end);
                          Exit(SetValue(ret, retval));
                        end else
{$ENDIF}
                          Exit(SetValue(vl.GetValue(val), retval));
                      end;
                    's':
                      begin
                        inc(p);
                        vl := rt.GetField(p);
                        if GetValue(vl.FieldType.Handle, arguments[0], ret) then
                        begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
                          if FSyncMainThread then
                            TThread.Synchronize(nil, procedure begin
                              vl.SetValue(val, ret) end) else
{$ENDIF}
                            vl.SetValue(val, ret);
                          Exit(True);
                        end else
                          Exit(False);
                      end;
                    end;
                  end;
              end;
            end else
              m := rt.GetMethod(name);
          end;
        tkClassRef:
          begin
            val := nil;
{$IFDEF CPUX64}
            cls := StrToPtr(ud.GetValueByIndex(1).GetStringValue);
{$ELSE}
            cls := TClass(ud.GetValueByIndex(1).GetIntValue);
{$ENDIF}
            m := FCtx.GetType(cls).GetMethod(name);
          end;
      else
        m := nil;
        cls := nil;
        val := nil;
      end;

      prm := m.GetParameters;
      i := Length(prm);
      if i = Length(arguments) then
      begin
        SetLength(args, i);
        for i := 0 to i - 1 do
          if not GetValue(prm[i].ParamType.Handle, arguments[i], args[i]) then
            Exit(False);

        case m.MethodKind of
          mkClassProcedure, mkClassFunction:
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
            if FSyncMainThread then
              TThread.Synchronize(nil, procedure begin
                ret := m.Invoke(cls, args) end) else
{$ENDIF}
              ret := m.Invoke(cls, args);
          mkProcedure, mkFunction:
            if (val <> nil) then
            begin
{$IFDEF CEF_MULTI_THREADED_MESSAGE_LOOP}
              if FSyncMainThread then
                TThread.Synchronize(nil, procedure begin
                  ret := m.Invoke(val, args) end) else
{$ENDIF}
                ret := m.Invoke(val, args);
            end else
              Exit(False)
        else
          Exit(False);
        end;

        if m.MethodKind in [mkClassFunction, mkFunction] then
          if not SetValue(ret, retval) then
            Exit(False);
      end else
        Exit(False);
    end else
    if p^ = '$' then
    begin
      inc(p);
      case p^ of
        'g': SetValue(FValue, retval);
        's': GetValue(FValue.TypeInfo, arguments[0], FValue);
      else
        Exit(False);
      end;
    end else
      Exit(False);
  end else
    Exit(False);
end;
{$ENDIF}

{ TCefV8AccessorOwn }

constructor TCefV8AccessorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefV8Accessor));
  PCefV8Accessor(FData)^.get  := cef_v8_accessor_get;
  PCefV8Accessor(FData)^.put := cef_v8_accessor_put;
end;

function TCefV8AccessorOwn.Get(const name: ustring; const obj: ICefv8Value;
  out value: ICefv8Value; const exception: ustring): Boolean;
begin
  Result := False;
end;

function TCefV8AccessorOwn.Put(const name: ustring; const obj,
  value: ICefv8Value; const exception: ustring): Boolean;
begin
  Result := False;
end;

{ TCefFastV8Accessor }

constructor TCefFastV8Accessor.Create(
  const getter: TCefV8AccessorGetterProc;
  const setter: TCefV8AccessorSetterProc);
begin
  FGetter := getter;
  FSetter := setter;
end;

function TCefFastV8Accessor.Get(const name: ustring; const obj: ICefv8Value;
  out value: ICefv8Value; const exception: ustring): Boolean;
begin
  if Assigned(FGetter)  then
    Result := FGetter(name, obj, value, exception) else
    Result := False;
end;

function TCefFastV8Accessor.Put(const name: ustring; const obj,
  value: ICefv8Value; const exception: ustring): Boolean;
begin
  if Assigned(FSetter)  then
    Result := FSetter(name, obj, value, exception) else
    Result := False;
end;

{ TCefCookieVisitorOwn }

constructor TCefCookieVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefCookieVisitor));
  PCefCookieVisitor(FData)^.visit := cef_cookie_visitor_visit;
end;

function TCefCookieVisitorOwn.visit(const name, value, domain, path: ustring;
  secure, httponly, hasExpires: Boolean; const creation, lastAccess, expires: TDateTime;
  count, total: Integer; out deleteCookie: Boolean): Boolean;
begin
  Result := True;
end;

{ TCefFastCookieVisitor }

constructor TCefFastCookieVisitor.Create(const visitor: TCefCookieVisitorProc);
begin
  inherited Create;
  FVisitor := visitor;
end;

function TCefFastCookieVisitor.visit(const name, value, domain, path: ustring;
  secure, httponly, hasExpires: Boolean; const creation, lastAccess,
  expires: TDateTime; count, total: Integer; out deleteCookie: Boolean): Boolean;
begin
  Result := FVisitor(name, value, domain, path, secure, httponly, hasExpires,
    creation, lastAccess, expires, count, total, deleteCookie);
end;

{ TCefClientOwn }

constructor TCefClientOwn.Create;
begin
  inherited CreateData(SizeOf(TCefClient));
  with PCefClient(FData)^ do
  begin
    get_context_menu_handler := cef_client_get_context_menu_handler;
    get_dialog_handler := cef_client_get_dialog_handler;
    get_display_handler := cef_client_get_display_handler;
    get_download_handler := cef_client_get_download_handler;
    get_drag_handler := cef_client_get_drag_handler;
    get_find_handler := cef_client_get_find_handler;
    get_focus_handler := cef_client_get_focus_handler;
    get_geolocation_handler := cef_client_get_geolocation_handler;
    get_jsdialog_handler := cef_client_get_jsdialog_handler;
    get_keyboard_handler := cef_client_get_keyboard_handler;
    get_life_span_handler := cef_client_get_life_span_handler;
    get_load_handler := cef_client_get_load_handler;
    get_render_handler := cef_client_get_get_render_handler;
    get_request_handler := cef_client_get_request_handler;
    on_process_message_received := cef_client_on_process_message_received;
  end;
end;

function TCefClientOwn.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDialogHandler: ICefDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDragHandler: ICefDragHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFindHandler: ICefFindHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFocusHandler: ICefFocusHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetGeolocationHandler: ICefGeolocationHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetJsdialogHandler: ICefJsDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetKeyboardHandler: ICefKeyboardHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLoadHandler: ICefLoadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRenderHandler: ICefRenderHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRequestHandler: ICefRequestHandler;
begin
  Result := nil;
end;

function TCefClientOwn.OnProcessMessageReceived(const browser: ICefBrowser;
  sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  Result := False;
end;

{ TCefGeolocationHandlerOwn }

constructor TCefGeolocationHandlerOwn.Create;
begin

  inherited CreateData(SizeOf(TCefGeolocationHandler));
  with PCefGeolocationHandler(FData)^ do
  begin
    on_request_geolocation_permission := cef_geolocation_handler_on_request_geolocation_permission;
    on_cancel_geolocation_permission :=  cef_geolocation_handler_on_cancel_geolocation_permission;
  end;
end;


function TCefGeolocationHandlerOwn.OnRequestGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer;
  const callback: ICefGeolocationCallback): Boolean;
begin
  Result := False;
end;

procedure TCefGeolocationHandlerOwn.OnCancelGeolocationPermission(
  const browser: ICefBrowser; const requestingUrl: ustring; requestId: Integer);
begin

end;

{ TCefLifeSpanHandlerOwn }


constructor TCefLifeSpanHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefLifeSpanHandler));
  with PCefLifeSpanHandler(FData)^ do
  begin
    on_before_popup := cef_life_span_handler_on_before_popup;
    on_after_created := cef_life_span_handler_on_after_created;
    on_before_close := cef_life_span_handler_on_before_close;
    run_modal := cef_life_span_handler_run_modal;
    do_close := cef_life_span_handler_do_close;
  end;
end;

procedure TCefLifeSpanHandlerOwn.OnAfterCreated(const browser: ICefBrowser);
begin

end;

procedure TCefLifeSpanHandlerOwn.OnBeforeClose(const browser: ICefBrowser);
begin

end;

function TCefLifeSpanHandlerOwn.OnBeforePopup(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl, targetFrameName: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  var popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var noJavascriptAccess: Boolean): Boolean;
begin
  Result := False;
end;

function TCefLifeSpanHandlerOwn.DoClose(const browser: ICefBrowser): Boolean;
begin
  Result := False;
end;

function TCefLifeSpanHandlerOwn.RunModal(const browser: ICefBrowser): Boolean;
begin
  Result := False;
end;


{ TCefLoadHandlerOwn }

constructor TCefLoadHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefLoadHandler));
  with PCefLoadHandler(FData)^ do
  begin
    on_loading_state_change := cef_load_handler_on_loading_state_change;
    on_load_start := cef_load_handler_on_load_start;
    on_load_end := cef_load_handler_on_load_end;
    on_load_error := cef_load_handler_on_load_error;
  end;
end;

procedure TCefLoadHandlerOwn.OnLoadEnd(const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadError(const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText, failedUrl: ustring);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadingStateChange(const browser: ICefBrowser;
  isLoading, canGoBack, canGoForward: Boolean);
begin

end;

procedure TCefLoadHandlerOwn.OnLoadStart(const browser: ICefBrowser;
  const frame: ICefFrame);
begin

end;

{ TCefRequestHandlerOwn }

constructor TCefRequestHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRequestHandler));
  with PCefRequestHandler(FData)^ do
  begin
    on_before_browse := cef_request_handler_on_before_browse;
    on_open_urlfrom_tab := cef_request_handler_on_open_urlfrom_tab;
    on_before_resource_load := cef_request_handler_on_before_resource_load;
    get_resource_handler := cef_request_handler_get_resource_handler;
    on_resource_redirect := cef_request_handler_on_resource_redirect;
    on_resource_response := cef_request_handler_on_resource_response;
    get_auth_credentials := cef_request_handler_get_auth_credentials;
    on_quota_request := cef_request_handler_on_quota_request;
    on_protocol_execution := cef_request_handler_on_protocol_execution;
    on_certificate_error := cef_request_handler_on_certificate_error;
    on_plugin_crashed := cef_request_handler_on_plugin_crashed;
    on_render_view_ready := cef_request_handler_on_render_view_ready;
    on_render_process_terminated := cef_request_handler_on_render_process_terminated;
  end;
end;

function TCefRequestHandlerOwn.GetAuthCredentials(const browser: ICefBrowser; const frame: ICefFrame;
  isProxy: Boolean; const host: ustring; port: Integer; const realm, scheme: ustring;
  const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.GetCookieManager(const browser: ICefBrowser;
  const mainUrl: ustring): ICefCookieManager;
begin
  Result := nil;
end;

function TCefRequestHandlerOwn.OnBeforeBrowse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.OnBeforeResourceLoad(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const callback: ICefRequestCallback): TCefReturnValue;
begin
  Result := RV_CONTINUE;
end;

function TCefRequestHandlerOwn.OnCertificateError(const browser: ICefBrowser;
  certError: TCefErrorcode; const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.OnOpenUrlFromTab(const browser: ICefBrowser;
  const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean): Boolean;
begin
  Result := False;
end;

function TCefRequestHandlerOwn.GetResourceHandler(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest): ICefResourceHandler;
begin
  Result := nil;
end;

procedure TCefRequestHandlerOwn.OnPluginCrashed(const browser: ICefBrowser;
  const pluginPath: ustring);
begin

end;

procedure TCefRequestHandlerOwn.OnProtocolExecution(const browser: ICefBrowser;
  const url: ustring; out allowOsExecution: Boolean);
begin

end;

function TCefRequestHandlerOwn.OnQuotaRequest(const browser: ICefBrowser;
  const originUrl: ustring; newSize: Int64;
  const callback: ICefRequestCallback): Boolean;
begin
  Result := False;
end;

procedure TCefRequestHandlerOwn.OnRenderProcessTerminated(
  const browser: ICefBrowser; status: TCefTerminationStatus);
begin

end;

procedure TCefRequestHandlerOwn.OnRenderViewReady(const browser: ICefBrowser);
begin

end;

procedure TCefRequestHandlerOwn.OnResourceRedirect(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest; var newUrl: ustring);
begin

end;

function TCefRequestHandlerOwn.OnResourceResponse(const browser: ICefBrowser;
  const frame: ICefFrame; const request: ICefRequest;
  const response: ICefResponse): Boolean;
begin
  Result := False;
end;

{ TCefDisplayHandlerOwn }

constructor TCefDisplayHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDisplayHandler));
  with PCefDisplayHandler(FData)^ do
  begin
    on_address_change := cef_display_handler_on_address_change;
    on_title_change := cef_display_handler_on_title_change;
    on_favicon_urlchange := cef_display_handler_on_favicon_urlchange;
    on_fullscreen_mode_change := cef_display_handler_on_fullscreen_mode_change;
    on_tooltip := cef_display_handler_on_tooltip;
    on_status_message := cef_display_handler_on_status_message;
    on_console_message := cef_display_handler_on_console_message;
  end;
end;

procedure TCefDisplayHandlerOwn.OnAddressChange(const browser: ICefBrowser;
  const frame: ICefFrame; const url: ustring);
begin

end;

function TCefDisplayHandlerOwn.OnConsoleMessage(const browser: ICefBrowser;
  const message, source: ustring; line: Integer): Boolean;
begin
  Result := False;
end;

procedure TCefDisplayHandlerOwn.OnFaviconUrlChange(const browser: ICefBrowser;
  iconUrls: TStrings);
begin

end;

procedure TCefDisplayHandlerOwn.OnFullScreenModeChange(
  const browser: ICefBrowser; fullscreen: Boolean);
begin

end;

procedure TCefDisplayHandlerOwn.OnStatusMessage(const browser: ICefBrowser;
  const value: ustring);
begin

end;

procedure TCefDisplayHandlerOwn.OnTitleChange(const browser: ICefBrowser;
  const title: ustring);
begin

end;

function TCefDisplayHandlerOwn.OnTooltip(const browser: ICefBrowser;
  var text: ustring): Boolean;
begin
  Result := False;
end;

{ TCefFocusHandlerOwn }

constructor TCefFocusHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefFocusHandler));
  with PCefFocusHandler(FData)^ do
  begin
    on_take_focus := cef_focus_handler_on_take_focus;
    on_set_focus := cef_focus_handler_on_set_focus;
    on_got_focus := cef_focus_handler_on_got_focus;
  end;
end;

function TCefFocusHandlerOwn.OnSetFocus(const browser: ICefBrowser;
  source: TCefFocusSource): Boolean;
begin
  Result := False;
end;

procedure TCefFocusHandlerOwn.OnGotFocus(const browser: ICefBrowser);
begin

end;

procedure TCefFocusHandlerOwn.OnTakeFocus(const browser: ICefBrowser;
  next: Boolean);
begin

end;

{ TCefKeyboardHandlerOwn }

constructor TCefKeyboardHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefKeyboardHandler));
  with PCefKeyboardHandler(FData)^ do
  begin
    on_pre_key_event := cef_keyboard_handler_on_pre_key_event;
    on_key_event := cef_keyboard_handler_on_key_event;
  end;
end;

function TCefKeyboardHandlerOwn.OnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
begin
  Result := False;
end;

function TCefKeyboardHandlerOwn.OnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
begin

  Result := False;
end;

{ TCefJsDialogHandlerOwn }

constructor TCefJsDialogHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefJsDialogHandler));
  with PCefJsDialogHandler(FData)^ do
  begin
    on_jsdialog := cef_jsdialog_handler_on_jsdialog;
    on_before_unload_dialog := cef_jsdialog_handler_on_before_unload_dialog;
    on_reset_dialog_state := cef_jsdialog_handler_on_reset_dialog_state;
    on_dialog_closed := cef_jsdialog_handler_on_dialog_closed;
  end;
end;

function TCefJsDialogHandlerOwn.OnJsdialog(const browser: ICefBrowser;
  const originUrl, acceptLang: ustring; dialogType: TCefJsDialogType;
  const messageText, defaultPromptText: ustring; callback: ICefJsDialogCallback;
  out suppressMessage: Boolean): Boolean;
begin
  Result := False;
end;

function TCefJsDialogHandlerOwn.OnBeforeUnloadDialog(const browser: ICefBrowser;
  const messageText: ustring; isReload: Boolean; const callback: ICefJsDialogCallback): Boolean;
begin

  Result := False;
end;

procedure TCefJsDialogHandlerOwn.OnDialogClosed(const browser: ICefBrowser);
begin

end;

procedure TCefJsDialogHandlerOwn.OnResetDialogState(const browser: ICefBrowser);
begin

end;

{ TCefContextMenuHandlerOwn }

constructor TCefContextMenuHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefContextMenuHandler));
  with PCefContextMenuHandler(FData)^ do
  begin
    on_before_context_menu := cef_context_menu_handler_on_before_context_menu;
    run_context_menu := cef_context_menu_handler_run_context_menu;
    on_context_menu_command := cef_context_menu_handler_on_context_menu_command;
    on_context_menu_dismissed := cef_context_menu_handler_on_context_menu_dismissed;
  end;
end;

procedure TCefContextMenuHandlerOwn.OnBeforeContextMenu(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin

end;

function TCefContextMenuHandlerOwn.OnContextMenuCommand(
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: TCefEventFlags): Boolean;
begin
  Result := False;
end;

procedure TCefContextMenuHandlerOwn.OnContextMenuDismissed(
  const browser: ICefBrowser; const frame: ICefFrame);
begin

end;

function TCefContextMenuHandlerOwn.RunContextMenu(const browser: ICefBrowser;
  const frame: ICefFrame; const params: ICefContextMenuParams;
  const model: ICefMenuModel;
  const callback: ICefRunContextMenuCallback): Boolean;
begin
  Result := False;
end;

{ TCefV8ExceptionRef }

function TCefV8ExceptionRef.GetEndColumn: Integer;
begin
  Result := PCefV8Exception(FData)^.get_end_column(FData);
end;

function TCefV8ExceptionRef.GetEndPosition: Integer;
begin
  Result := PCefV8Exception(FData)^.get_end_position(FData);
end;

function TCefV8ExceptionRef.GetLineNumber: Integer;
begin
  Result := PCefV8Exception(FData)^.get_line_number(FData);
end;

function TCefV8ExceptionRef.GetMessage: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_message(FData));
end;

function TCefV8ExceptionRef.GetScriptResourceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_script_resource_name(FData));
end;

function TCefV8ExceptionRef.GetSourceLine: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8Exception(FData)^.get_source_line(FData));
end;

function TCefV8ExceptionRef.GetStartColumn: Integer;
begin
  Result := PCefV8Exception(FData)^.get_start_column(FData);
end;

function TCefV8ExceptionRef.GetStartPosition: Integer;
begin
  Result := PCefV8Exception(FData)^.get_start_position(FData);
end;

class function TCefV8ExceptionRef.UnWrap(data: Pointer): ICefV8Exception;
begin
  if data <> nil then
    Result := Create(data) as ICefV8Exception else
    Result := nil;
end;

{ TCefResourceBundleHandlerOwn }

constructor TCefResourceBundleHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefResourceBundleHandler));
  with PCefResourceBundleHandler(FData)^ do
  begin
    get_localized_string := cef_resource_bundle_handler_get_localized_string;
    get_data_resource := cef_resource_bundle_handler_get_data_resource;
    get_data_resource_for_scale := cef_resource_bundle_handler_get_data_resource_for_scale;
  end;
end;

{ TCefFastResourceBundle }

constructor TCefFastResourceBundle.Create(AGetDataResource: TGetDataResource;
  AGetLocalizedString: TGetLocalizedString; AGetDataResourceForScale: TGetDataResourceForScale);
begin
  inherited Create;
  FGetDataResource := AGetDataResource;
  FGetLocalizedString := AGetLocalizedString;
  FGetDataResourceForScale := AGetDataResourceForScale;
end;

function TCefFastResourceBundle.GetDataResource(resourceId: Integer;
  out data: Pointer; out dataSize: NativeUInt): Boolean;
begin
  if Assigned(FGetDataResource) then
    Result := FGetDataResource(resourceId, data, dataSize) else
    Result := False;
end;

function TCefFastResourceBundle.GetDataResourceForScale(resourceId: Integer;
  scaleFactor: TCefScaleFactor; out data: Pointer;
  dataSize: NativeUInt): Boolean;
begin
  if Assigned(FGetDataResourceForScale) then
    Result := FGetDataResourceForScale(resourceId, scaleFactor, data, dataSize) else
    Result := False;
end;

function TCefFastResourceBundle.GetLocalizedString(stringId: Integer;
  out stringVal: ustring): Boolean;
begin
  if Assigned(FGetLocalizedString) then
    Result := FGetLocalizedString(stringId, stringVal) else
    Result := False;
end;

{ TCefAppOwn }

constructor TCefAppOwn.Create;
begin
  inherited CreateData(SizeOf(TCefApp));
  with PCefApp(FData)^ do
  begin
    on_before_command_line_processing := cef_app_on_before_command_line_processing;
    on_register_custom_schemes := cef_app_on_register_custom_schemes;
    get_resource_bundle_handler := cef_app_get_resource_bundle_handler;
    get_browser_process_handler := cef_app_get_browser_process_handler;
    get_render_process_handler := cef_app_get_render_process_handler;
  end;
end;

{ TCefCookieManagerRef }

class function TCefCookieManagerRef.New(const path: ustring; persistSessionCookies: Boolean;
  const callback: ICefCompletionCallback): ICefCookieManager;
var
  pth: TCefString;
begin
  pth := CefString(path);
  Result := UnWrap(cef_cookie_manager_create_manager(@pth, Ord(persistSessionCookies), CefGetData(callback)));
end;

class function TCefCookieManagerRef.NewProc(const path: ustring;
  persistSessionCookies: Boolean;
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := New(path, persistSessionCookies, TCefFastCompletionCallback.Create(callback));
end;

function TCefCookieManagerRef.DeleteCookies(const url,
  cookieName: ustring; const callback: ICefDeleteCookiesCallback): Boolean;
var
  u, n: TCefString;
begin
  u := CefString(url);
  n := CefString(cookieName);
  Result := PCefCookieManager(FData).delete_cookies(
    PCefCookieManager(FData), @u, @n, CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.DeleteCookiesProc(const url, cookieName: ustring;
  const callback: TCefDeleteCookiesCallbackProc): Boolean;
begin
  Result := DeleteCookies(url, cookieName, TCefFastDeleteCookiesCallback.Create(callback));
end;

function TCefCookieManagerRef.FlushStore(
  const handler: ICefCompletionCallback): Boolean;
begin
  Result := PCefCookieManager(FData).flush_store(PCefCookieManager(FData),
    CefGetData(handler)) <> 0;
end;

function TCefCookieManagerRef.FlushStoreProc(
  const proc: TCefCompletionCallbackProc): Boolean;
begin
  Result := FlushStore(TCefFastCompletionCallback.Create(proc))
end;

class function TCefCookieManagerRef.Global(const callback: ICefCompletionCallback): ICefCookieManager;
begin
  Result := UnWrap(cef_cookie_manager_get_global_manager(CefGetData(callback)));
end;

class function TCefCookieManagerRef.GlobalProc(
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := Global(TCefFastCompletionCallback.Create(callback));
end;

function TCefCookieManagerRef.SetCookie(const url, name, value, domain,
  path: ustring; secure, httponly, hasExpires: Boolean; const creation,
  lastAccess, expires: TDateTime; const callback: ICefSetCookieCallback): Boolean;
var
  str: TCefString;
  cook: TCefCookie;
begin
  str := CefString(url);
  cook.name := CefString(name);
  cook.value := CefString(value);
  cook.domain := CefString(domain);
  cook.path := CefString(path);
  cook.secure := Ord(secure);
  cook.httponly := Ord(httponly);
  cook.creation := DateTimeToCefTime(creation);
  cook.last_access := DateTimeToCefTime(lastAccess);
  cook.has_expires := Ord(hasExpires);
  if hasExpires then
    cook.expires := DateTimeToCefTime(expires) else
    FillChar(cook.expires, SizeOf(TCefTime), 0);
  Result := PCefCookieManager(FData).set_cookie(
    PCefCookieManager(FData), @str, @cook, CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.SetCookieProc(const url, name, value, domain,
  path: ustring; secure, httponly, hasExpires: Boolean; const creation,
  lastAccess, expires: TDateTime;
  const callback: TCefSetCookieCallbackProc): Boolean;
begin
  Result := SetCookie(url, name, value, domain, path, secure,
    httponly, hasExpires, creation, lastAccess, expires,
    TCefFastSetCookieCallback.Create(callback));
end;

function TCefCookieManagerRef.SetStoragePath(const path: ustring;
  persistSessionCookies: Boolean; const callback: ICefCompletionCallback): Boolean;
var
  p: TCefString;
begin
  p := CefString(path);
  Result := PCefCookieManager(FData)^.set_storage_path(
    PCefCookieManager(FData), @p, Ord(persistSessionCookies), CefGetData(callback)) <> 0;
end;

function TCefCookieManagerRef.SetStoragePathProc(const path: ustring;
  persistSessionCookies: Boolean;
  const callback: TCefCompletionCallbackProc): Boolean;
begin
  Result := SetStoragePath(path, persistSessionCookies, TCefFastCompletionCallback.Create(callback));
end;

procedure TCefCookieManagerRef.SetSupportedSchemes(schemes: TStrings; const callback: ICefCompletionCallback);
var
  list: TCefStringList;
  i: Integer;
  item: TCefString;
begin
  list := cef_string_list_alloc();
  try
    if (schemes <> nil) then
      for i := 0 to schemes.Count - 1 do
      begin
        item := CefString(schemes[i]);
        cef_string_list_append(list, @item);
      end;
    PCefCookieManager(FData).set_supported_schemes(
      PCefCookieManager(FData), list, CefGetData(callback));

  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefCookieManagerRef.SetSupportedSchemesProc(schemes: TStrings;
  const callback: TCefCompletionCallbackProc);
begin
  SetSupportedSchemes(schemes, TCefFastCompletionCallback.Create(callback));
end;

class function TCefCookieManagerRef.UnWrap(data: Pointer): ICefCookieManager;
begin
  if data <> nil then
    Result := Create(data) as ICefCookieManager else
    Result := nil;
end;

function TCefCookieManagerRef.VisitAllCookies(
  const visitor: ICefCookieVisitor): Boolean;
begin
  Result := PCefCookieManager(FData).visit_all_cookies(
    PCefCookieManager(FData), CefGetData(visitor)) <> 0;
end;

function TCefCookieManagerRef.VisitAllCookiesProc(
  const visitor: TCefCookieVisitorProc): Boolean;
begin
  Result := VisitAllCookies(
    TCefFastCookieVisitor.Create(visitor) as ICefCookieVisitor);
end;

function TCefCookieManagerRef.VisitUrlCookies(const url: ustring;
  includeHttpOnly: Boolean; const visitor: ICefCookieVisitor): Boolean;
var
  str: TCefString;
begin
  str := CefString(url);
  Result := PCefCookieManager(FData).visit_url_cookies(PCefCookieManager(FData), @str, Ord(includeHttpOnly), CefGetData(visitor)) <> 0;
end;

function TCefCookieManagerRef.VisitUrlCookiesProc(const url: ustring;
  includeHttpOnly: Boolean; const visitor: TCefCookieVisitorProc): Boolean;
begin
  Result := VisitUrlCookies(url, includeHttpOnly,
    TCefFastCookieVisitor.Create(visitor) as ICefCookieVisitor);
end;

{ TCefWebPluginInfoRef }

function TCefWebPluginInfoRef.GetDescription: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_description(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_name(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetPath: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_path(PCefWebPluginInfo(FData)));
end;

function TCefWebPluginInfoRef.GetVersion: ustring;
begin
  Result := CefStringFreeAndGet(PCefWebPluginInfo(FData)^.get_version(PCefWebPluginInfo(FData)));
end;

class function TCefWebPluginInfoRef.UnWrap(data: Pointer): ICefWebPluginInfo;
begin
  if data <> nil then
    Result := Create(data) as ICefWebPluginInfo else
    Result := nil;
end;

{ TCefBrowserHostRef }

procedure TCefBrowserHostRef.CloseDevTools;
begin
  PCefBrowserHost(FData).close_dev_tools(FData);
end;

procedure TCefBrowserHostRef.DragSourceEndedAt(x, y: Integer;
  op: TCefDragOperation);
begin
  PCefBrowserHost(FData).drag_source_ended_at(FData, x, y, op);
end;

procedure TCefBrowserHostRef.DragSourceSystemDragEnded;
begin
  PCefBrowserHost(FData).drag_source_system_drag_ended(FData);
end;

procedure TCefBrowserHostRef.DragTargetDragEnter(const dragData: ICefDragData;
  const event: PCefMouseEvent; allowedOps: TCefDragOperations);
begin
  PCefBrowserHost(FData).drag_target_drag_enter(FData, CefGetData(dragData), event, allowedOps);
end;

procedure TCefBrowserHostRef.DragTargetDragLeave;
begin
  PCefBrowserHost(FData).drag_target_drag_leave(FData);
end;

procedure TCefBrowserHostRef.DragTargetDragOver(const event: PCefMouseEvent;
  allowedOps: TCefDragOperations);
begin
  PCefBrowserHost(FData).drag_target_drag_over(FData, event, allowedOps);
end;

procedure TCefBrowserHostRef.DragTargetDrop(event: PCefMouseEvent);
begin
  PCefBrowserHost(FData).drag_target_drop(FData, event);
end;

procedure TCefBrowserHostRef.Find(identifier: Integer;
  const searchText: ustring; forward, matchCase, findNext: Boolean);
var
  s: TCefString;
begin
  s := CefString(searchText);
  PCefBrowserHost(FData).find(FData, identifier, @s, Ord(forward), Ord(matchCase), Ord(findNext));
end;

function TCefBrowserHostRef.GetBrowser: ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefBrowserHost(FData).get_browser(PCefBrowserHost(FData)));
end;

procedure TCefBrowserHostRef.Print;
begin
  PCefBrowserHost(FData).print(FData);
end;

procedure TCefBrowserHostRef.PrintToPdf(const path: ustring;
  settings: PCefPdfPrintSettings; const callback: ICefPdfPrintCallback);
var
  str: TCefString;
begin
  str := CefString(path);
  PCefBrowserHost(FData).print_to_pdf(FData, @str, settings, CefGetData(callback));
end;

procedure TCefBrowserHostRef.PrintToPdfProc(const path: ustring;
  settings: PCefPdfPrintSettings; const callback: TOnPdfPrintFinishedProc);
begin
  PrintToPdf(path, settings, TCefFastPdfPrintCallback.Create(callback));
end;

procedure TCefBrowserHostRef.ReplaceMisspelling(const word: ustring);
var
  str: TCefString;
begin
  str := CefString(word);
  PCefBrowserHost(FData).replace_misspelling(FData, @str);
end;

procedure TCefBrowserHostRef.RunFileDialog(mode: TCefFileDialogMode;
  const title, defaultFilePath: ustring; acceptFilters: TStrings;
  selectedAcceptFilter: Integer; const callback: ICefRunFileDialogCallback);
var
  t, f: TCefString;
  list: TCefStringList;
  item: TCefString;
  i: Integer;
begin
  t := CefString(title);
  f := CefString(defaultFilePath);
  list := cef_string_list_alloc();
  try
    for i := 0 to acceptFilters.Count - 1 do
    begin
      item := CefString(acceptFilters[i]);
      cef_string_list_append(list, @item);
    end;
    PCefBrowserHost(FData).run_file_dialog(PCefBrowserHost(FData), mode, @t, @f,
      list, selectedAcceptFilter, CefGetData(callback));
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefBrowserHostRef.RunFileDialogProc(mode: TCefFileDialogMode;
  const title, defaultFilePath: ustring; acceptFilters: TStrings;
  selectedAcceptFilter: Integer; const callback: TCefRunFileDialogCallbackProc);
begin
  RunFileDialog(mode, title, defaultFilePath, acceptFilters, selectedAcceptFilter,
    TCefFastRunFileDialogCallback.Create(callback));
end;

procedure TCefBrowserHostRef.AddWordToDictionary(const word: ustring);
var
  str: TCefString;
begin
  str := CefString(word);
  PCefBrowserHost(FData).add_word_to_dictionary(FData, @str);
end;

procedure TCefBrowserHostRef.CloseBrowser(forceClose: Boolean);
begin
  PCefBrowserHost(FData).close_browser(PCefBrowserHost(FData), Ord(forceClose));
end;

procedure TCefBrowserHostRef.SendCaptureLostEvent;
begin
  PCefBrowserHost(FData).send_capture_lost_event(FData);
end;

procedure TCefBrowserHostRef.SendFocusEvent(setFocus: Boolean);
begin
  PCefBrowserHost(FData).send_focus_event(FData, Ord(setFocus));
end;

procedure TCefBrowserHostRef.SendKeyEvent(const event: PCefKeyEvent);
begin
  PCefBrowserHost(FData).send_key_event(FData, event);
end;

procedure TCefBrowserHostRef.SendMouseClickEvent(const event: PCefMouseEvent;
  kind: TCefMouseButtonType; mouseUp: Boolean; clickCount: Integer);
begin
  PCefBrowserHost(FData).send_mouse_click_event(FData, event, kind, Ord(mouseUp), clickCount);
end;

procedure TCefBrowserHostRef.SendMouseMoveEvent(const event: PCefMouseEvent;
  mouseLeave: Boolean);
begin
  PCefBrowserHost(FData).send_mouse_move_event(FData, event, Ord(mouseLeave));
end;

procedure TCefBrowserHostRef.SendMouseWheelEvent(const event: PCefMouseEvent;
  deltaX, deltaY: Integer);
begin
  PCefBrowserHost(FData).send_mouse_wheel_event(FData, event, deltaX, deltaY);
end;

procedure TCefBrowserHostRef.SetFocus(focus: Boolean);
begin
  PCefBrowserHost(FData).set_focus(PCefBrowserHost(FData), Ord(focus));
end;

procedure TCefBrowserHostRef.SetMouseCursorChangeDisabled(disabled: Boolean);
begin
  PCefBrowserHost(FData).set_mouse_cursor_change_disabled(PCefBrowserHost(FData), Ord(disabled));
end;

procedure TCefBrowserHostRef.SetWindowlessFrameRate(frameRate: Integer);
begin
  PCefBrowserHost(FData).set_windowless_frame_rate(PCefBrowserHost(FData), frameRate);
end;

procedure TCefBrowserHostRef.SetWindowVisibility(visible: Boolean);
begin
  PCefBrowserHost(FData).set_window_visibility(PCefBrowserHost(FData), Ord(visible));
end;

function TCefBrowserHostRef.GetWindowHandle: TCefWindowHandle;
begin
  Result := PCefBrowserHost(FData).get_window_handle(PCefBrowserHost(FData))
end;

function TCefBrowserHostRef.GetWindowlessFrameRate: Integer;
begin
  Result := PCefBrowserHost(FData).get_windowless_frame_rate(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetOpenerWindowHandle: TCefWindowHandle;
begin
  Result := PCefBrowserHost(FData).get_opener_window_handle(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetRequestContext: ICefRequestContext;
begin
  Result := TCefRequestContextRef.UnWrap(PCefBrowserHost(FData).get_request_context(FData));
end;

procedure TCefBrowserHostRef.GetNavigationEntries(
  const visitor: ICefNavigationEntryVisitor; currentOnly: Boolean);
begin
  PCefBrowserHost(FData).get_navigation_entries(FData, CefGetData(visitor), Ord(currentOnly));
end;

procedure TCefBrowserHostRef.GetNavigationEntriesProc(
  const proc: TCefNavigationEntryVisitorProc; currentOnly: Boolean);
begin
  GetNavigationEntries(TCefFastNavigationEntryVisitor.Create(proc), currentOnly);
end;

function TCefBrowserHostRef.GetNsTextInputContext: TCefTextInputContext;
begin
  Result := PCefBrowserHost(FData).get_nstext_input_context(PCefBrowserHost(FData));
end;

function TCefBrowserHostRef.GetZoomLevel: Double;
begin
  Result := PCefBrowserHost(FData).get_zoom_level(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.HandleKeyEventAfterTextInputClient(
  keyEvent: TCefEventHandle);
begin
  PCefBrowserHost(FData).handle_key_event_after_text_input_client(PCefBrowserHost(FData), keyEvent);
end;

procedure TCefBrowserHostRef.HandleKeyEventBeforeTextInputClient(
  keyEvent: TCefEventHandle);
begin
  PCefBrowserHost(FData).handle_key_event_before_text_input_client(PCefBrowserHost(FData), keyEvent);
end;

procedure TCefBrowserHostRef.Invalidate(kind: TCefPaintElementType);
begin
  PCefBrowserHost(FData).invalidate(FData, kind);
end;

function TCefBrowserHostRef.IsMouseCursorChangeDisabled: Boolean;
begin
  Result := PCefBrowserHost(FData).is_mouse_cursor_change_disabled(FData) <> 0
end;

function TCefBrowserHostRef.IsWindowRenderingDisabled: Boolean;
begin
  Result := PCefBrowserHost(FData).is_window_rendering_disabled(FData) <> 0
end;

procedure TCefBrowserHostRef.NotifyMoveOrResizeStarted;
begin
  PCefBrowserHost(FData).notify_move_or_resize_started(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.NotifyScreenInfoChanged;
begin
  PCefBrowserHost(FData).notify_screen_info_changed(PCefBrowserHost(FData));
end;

procedure TCefBrowserHostRef.SetZoomLevel(zoomLevel: Double);
begin
  PCefBrowserHost(FData).set_zoom_level(PCefBrowserHost(FData), zoomLevel);
end;

procedure TCefBrowserHostRef.ShowDevTools(const windowInfo: PCefWindowInfo;
  const client: ICefClient; const settings: PCefBrowserSettings;
  inspectElementAt: PCefPoint);
begin
  PCefBrowserHost(FData).show_dev_tools(FData, windowInfo, CefGetData(client),
    settings, inspectElementAt);
end;

procedure TCefBrowserHostRef.StartDownload(const url: ustring);
var
  u: TCefString;
begin
  u := CefString(url);
  PCefBrowserHost(FData).start_download(PCefBrowserHost(FData), @u);
end;

procedure TCefBrowserHostRef.StopFinding(clearSelection: Boolean);
begin
  PCefBrowserHost(FData).stop_finding(FData, Ord(clearSelection));
end;

class function TCefBrowserHostRef.UnWrap(data: Pointer): ICefBrowserHost;
begin
  if data <> nil then
    Result := Create(data) as ICefBrowserHost else
    Result := nil;
end;

procedure TCefBrowserHostRef.WasHidden(hidden: Boolean);
begin
  PCefBrowserHost(FData).was_hidden(FData, Ord(hidden));
end;

procedure TCefBrowserHostRef.WasResized;
begin
  PCefBrowserHost(FData).was_resized(FData);
end;

{ TCefProcessMessageRef }

function TCefProcessMessageRef.Copy: ICefProcessMessage;
begin
  Result := UnWrap(PCefProcessMessage(FData)^.copy(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.GetArgumentList: ICefListValue;
begin
  Result := TCefListValueRef.UnWrap(PCefProcessMessage(FData)^.get_argument_list(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.GetName: ustring;
begin
  Result := CefStringFreeAndGet(PCefProcessMessage(FData)^.get_name(PCefProcessMessage(FData)));
end;

function TCefProcessMessageRef.IsReadOnly: Boolean;
begin
  Result := PCefProcessMessage(FData)^.is_read_only(PCefProcessMessage(FData)) <> 0;
end;

function TCefProcessMessageRef.IsValid: Boolean;
begin
  Result := PCefProcessMessage(FData)^.is_valid(PCefProcessMessage(FData)) <> 0;
end;

class function TCefProcessMessageRef.New(const name: ustring): ICefProcessMessage;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := UnWrap(cef_process_message_create(@n));
end;

class function TCefProcessMessageRef.UnWrap(data: Pointer): ICefProcessMessage;
begin
  if data <> nil then
    Result := Create(data) as ICefProcessMessage else
    Result := nil;
end;

{ TCefStringVisitorOwn }

constructor TCefStringVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefStringVisitor));
  with PCefStringVisitor(FData)^ do
    visit := cef_string_visitor_visit;
end;

procedure TCefStringVisitorOwn.Visit(const str: ustring);
begin

end;

{ TCefFastStringVisitor }

constructor TCefFastStringVisitor.Create(
  const callback: TCefStringVisitorProc);
begin
  inherited Create;
  FVisit := callback;
end;

procedure TCefFastStringVisitor.Visit(const str: ustring);
begin
  FVisit(str);
end;

{ TCefDownLoadItemRef }

function TCefDownLoadItemRef.GetContentDisposition: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_content_disposition(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetCurrentSpeed: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_current_speed(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetEndTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefDownloadItem(FData)^.get_end_time(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetFullPath: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_full_path(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetId: Cardinal;
begin
  Result := PCefDownloadItem(FData)^.get_id(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetMimeType: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_mime_type(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetOriginalUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_original_url(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetPercentComplete: Integer;
begin
  Result := PCefDownloadItem(FData)^.get_percent_complete(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetReceivedBytes: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_received_bytes(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetStartTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefDownloadItem(FData)^.get_start_time(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetSuggestedFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_suggested_file_name(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.GetTotalBytes: Int64;
begin
  Result := PCefDownloadItem(FData)^.get_total_bytes(PCefDownloadItem(FData));
end;

function TCefDownLoadItemRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDownloadItem(FData)^.get_url(PCefDownloadItem(FData)));
end;

function TCefDownLoadItemRef.IsCanceled: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_canceled(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsComplete: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_complete(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsInProgress: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_in_progress(PCefDownloadItem(FData)) <> 0;
end;

function TCefDownLoadItemRef.IsValid: Boolean;
begin
  Result := PCefDownloadItem(FData)^.is_valid(PCefDownloadItem(FData)) <> 0;
end;

class function TCefDownLoadItemRef.UnWrap(data: Pointer): ICefDownLoadItem;
begin
  if data <> nil then
    Result := Create(data) as ICefDownLoadItem else
    Result := nil;
end;

{ TCefBeforeDownloadCallbackRef }

procedure TCefBeforeDownloadCallbackRef.Cont(const downloadPath: ustring;
  showDialog: Boolean);
var
  dp: TCefString;
begin
  dp := CefString(downloadPath);
  PCefBeforeDownloadCallback(FData).cont(PCefBeforeDownloadCallback(FData), @dp, Ord(showDialog));
end;

class function TCefBeforeDownloadCallbackRef.UnWrap(
  data: Pointer): ICefBeforeDownloadCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefBeforeDownloadCallback else
    Result := nil;
end;

{ TCefDownloadItemCallbackRef }

procedure TCefDownloadItemCallbackRef.cancel;
begin
  PCefDownloadItemCallback(FData).cancel(PCefDownloadItemCallback(FData));
end;

procedure TCefDownloadItemCallbackRef.Pause;
begin
  PCefDownloadItemCallback(FData).pause(PCefDownloadItemCallback(FData));
end;

procedure TCefDownloadItemCallbackRef.Resume;
begin
  PCefDownloadItemCallback(FData).resume(PCefDownloadItemCallback(FData));
end;

class function TCefDownloadItemCallbackRef.UnWrap(
  data: Pointer): ICefDownloadItemCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefDownloadItemCallback else
    Result := nil;
end;

{ TCefAuthCallbackRef }

procedure TCefAuthCallbackRef.Cancel;
begin
  PCefAuthCallback(FData).cancel(PCefAuthCallback(FData));
end;

procedure TCefAuthCallbackRef.Cont(const username, password: ustring);
var
  u, p: TCefString;
begin
  u := CefString(username);
  p := CefString(password);
  PCefAuthCallback(FData).cont(PCefAuthCallback(FData), @u, @p);
end;

class function TCefAuthCallbackRef.UnWrap(data: Pointer): ICefAuthCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefAuthCallback else
    Result := nil;
end;

{ TCefJsDialogCallbackRef }

procedure TCefJsDialogCallbackRef.Cont(success: Boolean;
  const userInput: ustring);
var
  ui: TCefString;
begin
  ui := CefString(userInput);
  PCefJsDialogCallback(FData).cont(PCefJsDialogCallback(FData), Ord(success), @ui);
end;

class function TCefJsDialogCallbackRef.UnWrap(
  data: Pointer): ICefJsDialogCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefJsDialogCallback else
    Result := nil;
end;

{ TCefCommandLineRef }

procedure TCefCommandLineRef.AppendArgument(const argument: ustring);
var
  a: TCefString;
begin
  a := CefString(argument);
  PCefCommandLine(FData).append_argument(PCefCommandLine(FData), @a);
end;

procedure TCefCommandLineRef.AppendSwitch(const name: ustring);
var
  n: TCefString;
begin
  n := CefString(name);
  PCefCommandLine(FData).append_switch(PCefCommandLine(FData), @n);
end;

procedure TCefCommandLineRef.AppendSwitchWithValue(const name, value: ustring);
var
  n, v: TCefString;
begin
  n := CefString(name);
  v := CefString(value);
  PCefCommandLine(FData).append_switch_with_value(PCefCommandLine(FData), @n, @v);
end;

function TCefCommandLineRef.Copy: ICefCommandLine;
begin
  Result := UnWrap(PCefCommandLine(FData).copy(PCefCommandLine(FData)));
end;

procedure TCefCommandLineRef.GetArguments(arguments: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_arguments(PCefCommandLine(FData), list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      arguments.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefCommandLineRef.GetArgv(args: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_argv(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      args.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefCommandLineRef.GetCommandLineString: ustring;
begin
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_command_line_string(PCefCommandLine(FData)));
end;

function TCefCommandLineRef.GetProgram: ustring;
begin
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_program(PCefCommandLine(FData)));
end;

procedure TCefCommandLineRef.GetSwitches(switches: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefCommandLine(FData).get_switches(PCefCommandLine(FData), list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      switches.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefCommandLineRef.GetSwitchValue(const name: ustring): ustring;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := CefStringFreeAndGet(PCefCommandLine(FData).get_switch_value(PCefCommandLine(FData), @n));
end;

class function TCefCommandLineRef.Global: ICefCommandLine;
begin
  Result := UnWrap(cef_command_line_get_global);
end;

function TCefCommandLineRef.HasArguments: Boolean;
begin
  Result := PCefCommandLine(FData).has_arguments(PCefCommandLine(FData)) <> 0;
end;

function TCefCommandLineRef.HasSwitch(const name: ustring): Boolean;
var
  n: TCefString;
begin
  n := CefString(name);
  Result := PCefCommandLine(FData).has_switch(PCefCommandLine(FData), @n) <> 0;
end;

function TCefCommandLineRef.HasSwitches: Boolean;
begin
  Result := PCefCommandLine(FData).has_switches(PCefCommandLine(FData)) <> 0;
end;

procedure TCefCommandLineRef.InitFromArgv(argc: Integer;
  const argv: PPAnsiChar);
begin
  PCefCommandLine(FData).init_from_argv(PCefCommandLine(FData), argc, argv);
end;

procedure TCefCommandLineRef.InitFromString(const commandLine: ustring);
var
  cl: TCefString;
begin
  cl := CefString(commandLine);
  PCefCommandLine(FData).init_from_string(PCefCommandLine(FData), @cl);
end;

function TCefCommandLineRef.IsReadOnly: Boolean;
begin
  Result := PCefCommandLine(FData).is_read_only(PCefCommandLine(FData)) <> 0;
end;

function TCefCommandLineRef.IsValid: Boolean;
begin
  Result := PCefCommandLine(FData).is_valid(PCefCommandLine(FData)) <> 0;
end;

class function TCefCommandLineRef.New: ICefCommandLine;
begin
  Result := UnWrap(cef_command_line_create);
end;

procedure TCefCommandLineRef.PrependWrapper(const wrapper: ustring);
var
  w: TCefString;
begin
  w := CefString(wrapper);
  PCefCommandLine(FData).prepend_wrapper(PCefCommandLine(FData), @w);
end;

procedure TCefCommandLineRef.Reset;
begin
  PCefCommandLine(FData).reset(PCefCommandLine(FData));
end;

procedure TCefCommandLineRef.SetProgram(const prog: ustring);
var
  p: TCefString;
begin
  p := CefString(prog);
  PCefCommandLine(FData).set_program(PCefCommandLine(FData), @p);
end;

class function TCefCommandLineRef.UnWrap(data: Pointer): ICefCommandLine;
begin
  if data <> nil then
    Result := Create(data) as ICefCommandLine else
    Result := nil;
end;

{ TCefSchemeRegistrarRef }

function TCefSchemeRegistrarRef.AddCustomScheme(const schemeName: ustring;
  IsStandard, IsLocal, IsDisplayIsolated: Boolean): Boolean;
var
  sn: TCefString;
begin
  sn := CefString(schemeName);
  Result := PCefSchemeRegistrar(FData).add_custom_scheme(PCefSchemeRegistrar(FData),
    @sn, Ord(IsStandard), Ord(IsLocal), Ord(IsDisplayIsolated)) <> 0;
end;

class function TCefSchemeRegistrarRef.UnWrap(
  data: Pointer): ICefSchemeRegistrar;
begin
  if data <> nil then
    Result := Create(data) as ICefSchemeRegistrar else
    Result := nil;
end;

{ TCefGeolocationCallbackRef }

procedure TCefGeolocationCallbackRef.Cont(allow: Boolean);
begin
  PCefGeolocationCallback(FData).cont(PCefGeolocationCallback(FData), Ord(allow));
end;

class function TCefGeolocationCallbackRef.UnWrap(
  data: Pointer): ICefGeolocationCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefGeolocationCallback else
    Result := nil;
end;

{ TCefContextMenuParamsRef }

function TCefContextMenuParamsRef.GetDictionarySuggestions(
  const suggestions: TStringList): Boolean;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefContextMenuParams(FData).get_dictionary_suggestions(PCefContextMenuParams(FData), list) <> 0;
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      suggestions.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefContextMenuParamsRef.GetEditStateFlags: TCefContextMenuEditStateFlags;
begin
  Byte(Result) := PCefContextMenuParams(FData).get_edit_state_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetFrameCharset: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_frame_charset(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetFrameUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_frame_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_link_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetMediaStateFlags: TCefContextMenuMediaStateFlags;
begin
  Word(Result) := PCefContextMenuParams(FData).get_media_state_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetMediaType: TCefContextMenuMediaType;
begin
  Result := PCefContextMenuParams(FData).get_media_type(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetMisspelledWord: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_misspelled_word(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetPageUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_page_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetSelectionText: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_selection_text(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetSourceUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_source_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetTypeFlags: TCefContextMenuTypeFlags;
begin
  Byte(Result) := PCefContextMenuParams(FData).get_type_flags(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetUnfilteredLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefContextMenuParams(FData).get_unfiltered_link_url(PCefContextMenuParams(FData)));
end;

function TCefContextMenuParamsRef.GetXCoord: Integer;
begin
  Result := PCefContextMenuParams(FData).get_xcoord(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.GetYCoord: Integer;
begin
  Result := PCefContextMenuParams(FData).get_ycoord(PCefContextMenuParams(FData));
end;

function TCefContextMenuParamsRef.IsCustomMenu: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_custom_menu(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsEditable: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_editable(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsPepperMenu: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_pepper_menu(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.IsSpellCheckEnabled: Boolean;
begin
  Result := PCefContextMenuParams(FData).is_spell_check_enabled(PCefContextMenuParams(FData)) <> 0;
end;

function TCefContextMenuParamsRef.HasImageContents: Boolean;
begin
  Result := PCefContextMenuParams(FData).has_image_contents(PCefContextMenuParams(FData)) <> 0;
end;

class function TCefContextMenuParamsRef.UnWrap(
  data: Pointer): ICefContextMenuParams;
begin
  if data <> nil then
    Result := Create(data) as ICefContextMenuParams else
    Result := nil;
end;

{ TCefMenuModelRef }

function TCefMenuModelRef.AddCheckItem(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_check_item(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.AddItem(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_item(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.AddRadioItem(commandId: Integer; const text: ustring;
  groupId: Integer): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).add_radio_item(PCefMenuModel(FData), commandId, @t, groupId) <> 0;
end;

function TCefMenuModelRef.AddSeparator: Boolean;
begin
  Result := PCefMenuModel(FData).add_separator(PCefMenuModel(FData)) <> 0;
end;

function TCefMenuModelRef.AddSubMenu(commandId: Integer;
  const text: ustring): ICefMenuModel;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).add_sub_menu(PCefMenuModel(FData), commandId, @t));
end;

function TCefMenuModelRef.Clear: Boolean;
begin
  Result := PCefMenuModel(FData).clear(PCefMenuModel(FData)) <> 0;
end;

function TCefMenuModelRef.GetAccelerator(commandId: Integer;
  out keyCode: Integer; out shiftPressed, ctrlPressed,
  altPressed: Boolean): Boolean;
var
  sp, cp, ap: Integer;
begin
  Result := PCefMenuModel(FData).get_accelerator(PCefMenuModel(FData),
    commandId, @keyCode, @sp, @cp, @ap) <> 0;
  shiftPressed := sp <> 0;
  ctrlPressed := cp <> 0;
  altPressed := ap <> 0;
end;

function TCefMenuModelRef.GetAcceleratorAt(index: Integer; out keyCode: Integer;
  out shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
var
  sp, cp, ap: Integer;
begin
  Result := PCefMenuModel(FData).get_accelerator_at(PCefMenuModel(FData),
    index, @keyCode, @sp, @cp, @ap) <> 0;
  shiftPressed := sp <> 0;
  ctrlPressed := cp <> 0;
  altPressed := ap <> 0;
end;

function TCefMenuModelRef.GetCommandIdAt(index: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_command_id_at(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.GetCount: Integer;
begin
  Result := PCefMenuModel(FData).get_count(PCefMenuModel(FData));
end;

function TCefMenuModelRef.GetGroupId(commandId: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_group_id(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetGroupIdAt(index: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_group_id(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.GetIndexOf(commandId: Integer): Integer;
begin
  Result := PCefMenuModel(FData).get_index_of(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetLabel(commandId: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefMenuModel(FData).get_label(PCefMenuModel(FData), commandId));
end;

function TCefMenuModelRef.GetLabelAt(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefMenuModel(FData).get_label_at(PCefMenuModel(FData), index));
end;

function TCefMenuModelRef.GetSubMenu(commandId: Integer): ICefMenuModel;
begin
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).get_sub_menu(PCefMenuModel(FData), commandId));
end;

function TCefMenuModelRef.GetSubMenuAt(index: Integer): ICefMenuModel;
begin
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).get_sub_menu_at(PCefMenuModel(FData), index));
end;

function TCefMenuModelRef.GetType(commandId: Integer): TCefMenuItemType;
begin
  Result := PCefMenuModel(FData).get_type(PCefMenuModel(FData), commandId);
end;

function TCefMenuModelRef.GetTypeAt(index: Integer): TCefMenuItemType;
begin
  Result := PCefMenuModel(FData).get_type_at(PCefMenuModel(FData), index);
end;

function TCefMenuModelRef.HasAccelerator(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).has_accelerator(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.HasAcceleratorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).has_accelerator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.InsertCheckItemAt(index, commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_check_item_at(PCefMenuModel(FData), index, commandId, @t) <> 0;
end;

function TCefMenuModelRef.InsertItemAt(index, commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_item_at(PCefMenuModel(FData), index, commandId, @t) <> 0;
end;

function TCefMenuModelRef.InsertRadioItemAt(index, commandId: Integer;
  const text: ustring; groupId: Integer): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).insert_radio_item_at(PCefMenuModel(FData),
    index, commandId, @t, groupId) <> 0;
end;

function TCefMenuModelRef.InsertSeparatorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).insert_separator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.InsertSubMenuAt(index, commandId: Integer;
  const text: ustring): ICefMenuModel;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := TCefMenuModelRef.UnWrap(PCefMenuModel(FData).insert_sub_menu_at(
    PCefMenuModel(FData), index, commandId, @t));
end;

function TCefMenuModelRef.IsChecked(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_checked(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.IsCheckedAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_checked_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.IsEnabled(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_enabled(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.IsEnabledAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_enabled_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.IsVisible(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_visible(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.isVisibleAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).is_visible_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.Remove(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.RemoveAccelerator(commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_accelerator(PCefMenuModel(FData), commandId) <> 0;
end;

function TCefMenuModelRef.RemoveAcceleratorAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_accelerator_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.RemoveAt(index: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).remove_at(PCefMenuModel(FData), index) <> 0;
end;

function TCefMenuModelRef.SetAccelerator(commandId, keyCode: Integer;
  shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_accelerator(PCefMenuModel(FData),
    commandId, keyCode, Ord(shiftPressed), Ord(ctrlPressed), Ord(altPressed)) <> 0;
end;

function TCefMenuModelRef.SetAcceleratorAt(index, keyCode: Integer;
  shiftPressed, ctrlPressed, altPressed: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_accelerator_at(PCefMenuModel(FData),
    index, keyCode, Ord(shiftPressed), Ord(ctrlPressed), Ord(altPressed)) <> 0;
end;

function TCefMenuModelRef.setChecked(commandId: Integer;
  checked: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_checked(PCefMenuModel(FData),
    commandId, Ord(checked)) <> 0;
end;

function TCefMenuModelRef.setCheckedAt(index: Integer;
  checked: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_checked_at(PCefMenuModel(FData), index, Ord(checked)) <> 0;
end;

function TCefMenuModelRef.SetCommandIdAt(index, commandId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_command_id_at(PCefMenuModel(FData), index, commandId) <> 0;
end;

function TCefMenuModelRef.SetEnabled(commandId: Integer;
  enabled: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_enabled(PCefMenuModel(FData), commandId, Ord(enabled)) <> 0;
end;

function TCefMenuModelRef.SetEnabledAt(index: Integer;
  enabled: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_enabled_at(PCefMenuModel(FData), index, Ord(enabled)) <> 0;
end;

function TCefMenuModelRef.SetGroupId(commandId, groupId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_group_id(PCefMenuModel(FData), commandId, groupId) <> 0;
end;

function TCefMenuModelRef.SetGroupIdAt(index, groupId: Integer): Boolean;
begin
  Result := PCefMenuModel(FData).set_group_id_at(PCefMenuModel(FData), index, groupId) <> 0;
end;

function TCefMenuModelRef.SetLabel(commandId: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).set_label(PCefMenuModel(FData), commandId, @t) <> 0;
end;

function TCefMenuModelRef.SetLabelAt(index: Integer;
  const text: ustring): Boolean;
var
  t: TCefString;
begin
  t := CefString(text);
  Result := PCefMenuModel(FData).set_label_at(PCefMenuModel(FData), index, @t) <> 0;
end;

function TCefMenuModelRef.SetVisible(commandId: Integer;
  visible: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_visible(PCefMenuModel(FData), commandId, Ord(visible)) <> 0;
end;

function TCefMenuModelRef.SetVisibleAt(index: Integer;
  visible: Boolean): Boolean;
begin
  Result := PCefMenuModel(FData).set_visible_at(PCefMenuModel(FData), index, Ord(visible)) <> 0;
end;

class function TCefMenuModelRef.UnWrap(data: Pointer): ICefMenuModel;
begin
  if data <> nil then
    Result := Create(data) as ICefMenuModel else
    Result := nil;
end;

{ TCefListValueRef }

function TCefListValueRef.Clear: Boolean;
begin
  Result := PCefListValue(FData).clear(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.Copy: ICefListValue;
begin
  Result := UnWrap(PCefListValue(FData).copy(PCefListValue(FData)));
end;

class function TCefListValueRef.New: ICefListValue;
begin
  Result := UnWrap(cef_list_value_create);
end;

function TCefListValueRef.GetBinary(index: Integer): ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefListValue(FData).get_binary(PCefListValue(FData), index));
end;

function TCefListValueRef.GetBool(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).get_bool(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.GetDictionary(index: Integer): ICefDictionaryValue;
begin
  Result := TCefDictionaryValueRef.UnWrap(PCefListValue(FData).get_dictionary(PCefListValue(FData), index));
end;

function TCefListValueRef.GetDouble(index: Integer): Double;
begin
  Result := PCefListValue(FData).get_double(PCefListValue(FData), index);
end;

function TCefListValueRef.GetInt(index: Integer): Integer;
begin
  Result := PCefListValue(FData).get_int(PCefListValue(FData), index);
end;

function TCefListValueRef.GetList(index: Integer): ICefListValue;
begin
  Result := UnWrap(PCefListValue(FData).get_list(PCefListValue(FData), index));
end;

function TCefListValueRef.GetSize: NativeUInt;
begin
  Result := PCefListValue(FData).get_size(PCefListValue(FData));
end;

function TCefListValueRef.GetString(index: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefListValue(FData).get_string(PCefListValue(FData), index));
end;

function TCefListValueRef.GetType(index: Integer): TCefValueType;
begin
  Result := PCefListValue(FData).get_type(PCefListValue(FData), index);
end;

function TCefListValueRef.GetValue(index: Integer): ICefValue;
begin
  Result := TCefValueRef.UnWrap(PCefListValue(FData).get_value(PCefListValue(FData), index));
end;

function TCefListValueRef.IsEqual(const that: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).is_equal(PCefListValue(FData), CefGetData(that)) <> 0;
end;

function TCefListValueRef.IsOwned: Boolean;
begin
  Result := PCefListValue(FData).is_owned(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.IsReadOnly: Boolean;
begin
  Result := PCefListValue(FData).is_read_only(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.IsSame(const that: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).is_same(PCefListValue(FData), CefGetData(that)) <> 0;
end;

function TCefListValueRef.IsValid: Boolean;
begin
  Result := PCefListValue(FData).is_valid(PCefListValue(FData)) <> 0;
end;

function TCefListValueRef.Remove(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).remove(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.SetBinary(index: Integer;
  const value: ICefBinaryValue): Boolean;
begin
  Result := PCefListValue(FData).set_binary(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetBool(index: Integer; value: Boolean): Boolean;
begin
  Result := PCefListValue(FData).set_bool(PCefListValue(FData), index, Ord(value)) <> 0;
end;

function TCefListValueRef.SetDictionary(index: Integer;
  const value: ICefDictionaryValue): Boolean;
begin
  Result := PCefListValue(FData).set_dictionary(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetDouble(index: Integer; value: Double): Boolean;
begin
  Result := PCefListValue(FData).set_double(PCefListValue(FData), index, value) <> 0;
end;

function TCefListValueRef.SetInt(index, value: Integer): Boolean;
begin
  Result := PCefListValue(FData).set_int(PCefListValue(FData), index, value) <> 0;
end;

function TCefListValueRef.SetList(index: Integer;
  const value: ICefListValue): Boolean;
begin
  Result := PCefListValue(FData).set_list(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

function TCefListValueRef.SetNull(index: Integer): Boolean;
begin
  Result := PCefListValue(FData).set_null(PCefListValue(FData), index) <> 0;
end;

function TCefListValueRef.SetSize(size: NativeUInt): Boolean;
begin
  Result := PCefListValue(FData).set_size(PCefListValue(FData), size) <> 0;
end;

function TCefListValueRef.SetString(index: Integer;
  const value: ustring): Boolean;
var
  v: TCefString;
begin
  v := CefString(value);
  Result := PCefListValue(FData).set_string(PCefListValue(FData), index, @v) <> 0;
end;

function TCefListValueRef.SetValue(index: Integer;
  const value: ICefValue): Boolean;
begin
  Result := PCefListValue(FData).set_value(PCefListValue(FData), index, CefGetData(value)) <> 0;
end;

class function TCefListValueRef.UnWrap(data: Pointer): ICefListValue;
begin
  if data <> nil then
    Result := Create(data) as ICefListValue else
    Result := nil;
end;

{ TCefBinaryValueRef }

function TCefBinaryValueRef.Copy: ICefBinaryValue;
begin
  Result := UnWrap(PCefBinaryValue(FData).copy(PCefBinaryValue(FData)));
end;

function TCefBinaryValueRef.GetData(buffer: Pointer; bufferSize,
  dataOffset: NativeUInt): NativeUInt;
begin
  Result := PCefBinaryValue(FData).get_data(PCefBinaryValue(FData), buffer, bufferSize, dataOffset);
end;

function TCefBinaryValueRef.GetSize: NativeUInt;
begin
  Result := PCefBinaryValue(FData).get_size(PCefBinaryValue(FData));
end;

function TCefBinaryValueRef.IsEqual(const that: ICefBinaryValue): Boolean;
begin
  Result := PCefBinaryValue(FData).is_equal(PCefBinaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefBinaryValueRef.IsOwned: Boolean;
begin
  Result := PCefBinaryValue(FData).is_owned(PCefBinaryValue(FData)) <> 0;
end;

function TCefBinaryValueRef.IsSame(const that: ICefBinaryValue): Boolean;
begin
  Result := PCefBinaryValue(FData).is_same(PCefBinaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefBinaryValueRef.IsValid: Boolean;
begin
  Result := PCefBinaryValue(FData).is_valid(PCefBinaryValue(FData)) <> 0;
end;

class function TCefBinaryValueRef.New(const data: Pointer; dataSize: NativeUInt): ICefBinaryValue;
begin
  Result := UnWrap(cef_binary_value_create(data, dataSize));
end;

class function TCefBinaryValueRef.UnWrap(data: Pointer): ICefBinaryValue;
begin
  if data <> nil then
    Result := Create(data) as ICefBinaryValue else
    Result := nil;
end;

{ TCefDictionaryValueRef }

function TCefDictionaryValueRef.Clear: Boolean;
begin
  Result := PCefDictionaryValue(FData).clear(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.Copy(
  excludeEmptyChildren: Boolean): ICefDictionaryValue;
begin
  Result := UnWrap(PCefDictionaryValue(FData).copy(PCefDictionaryValue(FData), Ord(excludeEmptyChildren)));
end;

function TCefDictionaryValueRef.GetBinary(const key: ustring): ICefBinaryValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefBinaryValueRef.UnWrap(PCefDictionaryValue(FData).get_binary(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetBool(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_bool(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.GetDictionary(
  const key: ustring): ICefDictionaryValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := UnWrap(PCefDictionaryValue(FData).get_dictionary(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetDouble(const key: ustring): Double;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_double(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetInt(const key: ustring): Integer;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_int(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetKeys(const keys: TStrings): Boolean;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefDictionaryValue(FData).get_keys(PCefDictionaryValue(FData), list) <> 0;
    FillChar(str, SizeOf(str), 0);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      keys.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefDictionaryValueRef.GetList(const key: ustring): ICefListValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefListValueRef.UnWrap(PCefDictionaryValue(FData).get_list(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetSize: NativeUInt;
begin
  Result := PCefDictionaryValue(FData).get_size(PCefDictionaryValue(FData));
end;

function TCefDictionaryValueRef.GetString(const key: ustring): ustring;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := CefStringFreeAndGet(PCefDictionaryValue(FData).get_string(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.GetType(const key: ustring): TCefValueType;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).get_type(PCefDictionaryValue(FData), @k);
end;

function TCefDictionaryValueRef.GetValue(const key: ustring): ICefValue;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := TCefValueRef.UnWrap(PCefDictionaryValue(FData).get_value(PCefDictionaryValue(FData), @k));
end;

function TCefDictionaryValueRef.HasKey(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).has_key(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.IsEqual(
  const that: ICefDictionaryValue): Boolean;
begin
  Result := PCefDictionaryValue(FData).is_equal(PCefDictionaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefDictionaryValueRef.isOwned: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_owned(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.IsReadOnly: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_read_only(PCefDictionaryValue(FData)) <> 0;
end;

function TCefDictionaryValueRef.IsSame(
  const that: ICefDictionaryValue): Boolean;
begin
  Result := PCefDictionaryValue(FData).is_same(PCefDictionaryValue(FData), CefGetData(that)) <> 0;
end;

function TCefDictionaryValueRef.IsValid: Boolean;
begin
  Result := PCefDictionaryValue(FData).is_valid(PCefDictionaryValue(FData)) <> 0;
end;

class function TCefDictionaryValueRef.New: ICefDictionaryValue;
begin
  Result := UnWrap(cef_dictionary_value_create);
end;

function TCefDictionaryValueRef.Remove(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).remove(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.SetBinary(const key: ustring;
  const value: ICefBinaryValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_binary(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetBool(const key: ustring;
  value: Boolean): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_bool(PCefDictionaryValue(FData), @k, Ord(value)) <> 0;
end;

function TCefDictionaryValueRef.SetDictionary(const key: ustring;
  const value: ICefDictionaryValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_dictionary(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetDouble(const key: ustring;
  value: Double): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_double(PCefDictionaryValue(FData), @k, value) <> 0;
end;

function TCefDictionaryValueRef.SetInt(const key: ustring;
  value: Integer): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_int(PCefDictionaryValue(FData), @k, value) <> 0;
end;

function TCefDictionaryValueRef.SetList(const key: ustring;
  const value: ICefListValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_list(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

function TCefDictionaryValueRef.SetNull(const key: ustring): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_null(PCefDictionaryValue(FData), @k) <> 0;
end;

function TCefDictionaryValueRef.SetString(const key, value: ustring): Boolean;
var
  k, v: TCefString;
begin
  k := CefString(key);
  v := CefString(value);
  Result := PCefDictionaryValue(FData).set_string(PCefDictionaryValue(FData), @k, @v) <> 0;
end;

function TCefDictionaryValueRef.SetValue(const key: ustring;
  const value: ICefValue): Boolean;
var
  k: TCefString;
begin
  k := CefString(key);
  Result := PCefDictionaryValue(FData).set_value(PCefDictionaryValue(FData), @k, CefGetData(value)) <> 0;
end;

class function TCefDictionaryValueRef.UnWrap(
  data: Pointer): ICefDictionaryValue;
begin
  if data <> nil then
    Result := Create(data) as ICefDictionaryValue else
    Result := nil;
end;

{ TCefBrowserProcessHandlerOwn }

constructor TCefBrowserProcessHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefBrowserProcessHandler));
  with PCefBrowserProcessHandler(FData)^ do
  begin
    on_context_initialized := cef_browser_process_handler_on_context_initialized;
    on_before_child_process_launch := cef_browser_process_handler_on_before_child_process_launch;
    on_render_process_thread_created := cef_browser_process_handler_on_render_process_thread_created;
    get_print_handler := nil; // linux
  end;
end;

procedure TCefBrowserProcessHandlerOwn.OnBeforeChildProcessLaunch(
  const commandLine: ICefCommandLine);
begin

end;

procedure TCefBrowserProcessHandlerOwn.OnContextInitialized;
begin

end;

procedure TCefBrowserProcessHandlerOwn.OnRenderProcessThreadCreated(
  const extraInfo: ICefListValue);
begin

end;

{ TCefRenderProcessHandlerOwn }

constructor TCefRenderProcessHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRenderProcessHandler));
  with PCefRenderProcessHandler(FData)^ do
  begin
    on_render_thread_created := cef_render_process_handler_on_render_thread_created;
    on_web_kit_initialized := cef_render_process_handler_on_web_kit_initialized;
    on_browser_created := cef_render_process_handler_on_browser_created;
    on_browser_destroyed := cef_render_process_handler_on_browser_destroyed;
    get_load_handler := cef_render_process_handler_get_load_handler;
    on_before_navigation := cef_render_process_handler_on_before_navigation;
    on_context_created := cef_render_process_handler_on_context_created;
    on_context_released := cef_render_process_handler_on_context_released;
    on_uncaught_exception := cef_render_process_handler_on_uncaught_exception;
    on_focused_node_changed := cef_render_process_handler_on_focused_node_changed;
    on_process_message_received := cef_render_process_handler_on_process_message_received;
  end;
end;

function TCefRenderProcessHandlerOwn.GetLoadHandler: PCefLoadHandler;
begin
  Result := nil;
end;

function TCefRenderProcessHandlerOwn.OnBeforeNavigation(
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; navigationType: TCefNavigationType;
  isRedirect: Boolean): Boolean;
begin
  Result := False;
end;

procedure TCefRenderProcessHandlerOwn.OnBrowserCreated(
  const browser: ICefBrowser);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnBrowserDestroyed(
  const browser: ICefBrowser);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnContextCreated(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnContextReleased(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnFocusedNodeChanged(
  const browser: ICefBrowser; const frame: ICefFrame; const node: ICefDomNode);
begin

end;

function TCefRenderProcessHandlerOwn.OnProcessMessageReceived(
  const browser: ICefBrowser; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage): Boolean;
begin
  Result := False;
end;

procedure TCefRenderProcessHandlerOwn.OnRenderThreadCreated(const extraInfo: ICefListValue);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnUncaughtException(
  const browser: ICefBrowser; const frame: ICefFrame;
  const context: ICefv8Context; const exception: ICefV8Exception;
  const stackTrace: ICefV8StackTrace);
begin

end;

procedure TCefRenderProcessHandlerOwn.OnWebKitInitialized;
begin

end;

{ TCefResourceHandlerOwn }

procedure TCefResourceHandlerOwn.Cancel;
begin

end;

function TCefResourceHandlerOwn.CanGetCookie(const cookie: PCefCookie): Boolean;
begin
  Result := False;
end;

function TCefResourceHandlerOwn.CanSetCookie(const cookie: PCefCookie): Boolean;
begin
  Result := False;
end;

constructor TCefResourceHandlerOwn.Create(const browser: ICefBrowser;
  const frame: ICefFrame; const schemeName: ustring;
  const request: ICefRequest);
begin
  inherited CreateData(SizeOf(TCefResourceHandler));
  with PCefResourceHandler(FData)^ do
  begin
    process_request := cef_resource_handler_process_request;
    get_response_headers := cef_resource_handler_get_response_headers;
    read_response := cef_resource_handler_read_response;
    can_get_cookie := cef_resource_handler_can_get_cookie;
    can_set_cookie := cef_resource_handler_can_set_cookie;
    cancel:= cef_resource_handler_cancel;
  end;
end;

procedure TCefResourceHandlerOwn.GetResponseHeaders(
  const response: ICefResponse; out responseLength: Int64;
  out redirectUrl: ustring);
begin

end;

function TCefResourceHandlerOwn.ProcessRequest(const request: ICefRequest;
  const callback: ICefCallback): Boolean;
begin
  Result := False;
end;

function TCefResourceHandlerOwn.ReadResponse(const dataOut: Pointer;
  bytesToRead: Integer; var bytesRead: Integer;
  const callback: ICefCallback): Boolean;
begin
  Result := False;
end;

{ TCefSchemeHandlerFactoryOwn }

constructor TCefSchemeHandlerFactoryOwn.Create(
  const AClass: TCefResourceHandlerClass);
begin
  inherited CreateData(SizeOf(TCefSchemeHandlerFactory));
  FClass := AClass;
  with PCefSchemeHandlerFactory(FData)^ do
    create := cef_scheme_handler_factory_create;
end;

function TCefSchemeHandlerFactoryOwn.New(const browser: ICefBrowser;
  const frame: ICefFrame; const schemeName: ustring;
  const request: ICefRequest): ICefResourceHandler;
begin
  Result := FClass.Create(browser, frame, schemeName, request);
end;

{ TCefCallbackRef }

procedure TCefCallbackRef.Cancel;
begin
  PCefCallback(FData)^.cancel(PCefCallback(FData));
end;

procedure TCefCallbackRef.Cont;
begin
  PCefCallback(FData)^.cont(PCefCallback(FData));
end;

class function TCefCallbackRef.UnWrap(data: Pointer): ICefCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefCallback else
    Result := nil;
end;


{ TCefUrlrequestClientOwn }

constructor TCefUrlrequestClientOwn.Create;
begin
  inherited CreateData(SizeOf(TCefUrlrequestClient));
  with PCefUrlrequestClient(FData)^ do
  begin
    on_request_complete := cef_url_request_client_on_request_complete;
    on_upload_progress := cef_url_request_client_on_upload_progress;
    on_download_progress := cef_url_request_client_on_download_progress;
    on_download_data := cef_url_request_client_on_download_data;
    get_auth_credentials := cef_url_request_client_get_auth_credentials;
  end;
end;

procedure TCefUrlrequestClientOwn.OnDownloadData(const request: ICefUrlRequest;
  data: Pointer; dataLength: NativeUInt);
begin

end;

procedure TCefUrlrequestClientOwn.OnDownloadProgress(
  const request: ICefUrlRequest; current, total: Int64);
begin

end;

function TCefUrlrequestClientOwn.OnGetAuthCredentials(isProxy: Boolean;
  const host: ustring; port: Integer; const realm, scheme: ustring;
  const callback: ICefAuthCallback): Boolean;
begin
  Result := False;
end;

procedure TCefUrlrequestClientOwn.OnRequestComplete(
  const request: ICefUrlRequest);
begin

end;

procedure TCefUrlrequestClientOwn.OnUploadProgress(
  const request: ICefUrlRequest; current, total: Int64);
begin

end;

{ TCefUrlRequestRef }

procedure TCefUrlRequestRef.Cancel;
begin
  PCefUrlRequest(FData).cancel(PCefUrlRequest(FData));
end;

class function TCefUrlRequestRef.New(const request: ICefRequest; const client: ICefUrlRequestClient;
  const requestContext: ICefRequestContext): ICefUrlRequest;
begin
  Result := UnWrap(cef_urlrequest_create(CefGetData(request), CefGetData(client), CefGetData(requestContext)));
end;

function TCefUrlRequestRef.GetRequest: ICefRequest;
begin
  Result := TCefRequestRef.UnWrap(PCefUrlRequest(FData).get_request(PCefUrlRequest(FData)));
end;

function TCefUrlRequestRef.GetRequestError: Integer;
begin
  Result := PCefUrlRequest(FData).get_request_error(PCefUrlRequest(FData));
end;

function TCefUrlRequestRef.GetRequestStatus: TCefUrlRequestStatus;
begin
  Result := PCefUrlRequest(FData).get_request_status(PCefUrlRequest(FData));
end;

function TCefUrlRequestRef.GetResponse: ICefResponse;
begin
  Result := TCefResponseRef.UnWrap(PCefUrlRequest(FData).get_response(PCefUrlRequest(FData)));
end;

class function TCefUrlRequestRef.UnWrap(data: Pointer): ICefUrlRequest;
begin
  if data <> nil then
    Result := Create(data) as ICefUrlRequest else
    Result := nil;
end;


{ TCefWebPluginInfoVisitorOwn }

constructor TCefWebPluginInfoVisitorOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWebPluginInfoVisitor));
  PCefWebPluginInfoVisitor(FData).visit := cef_web_plugin_info_visitor_visit;
end;

function TCefWebPluginInfoVisitorOwn.Visit(const info: ICefWebPluginInfo; count,
  total: Integer): Boolean;
begin
  Result := False;
end;

{ TCefFastWebPluginInfoVisitor }

constructor TCefFastWebPluginInfoVisitor.Create(
  const proc: TCefWebPluginInfoVisitorProc);
begin
  inherited Create;
  FProc := proc;
end;

function TCefFastWebPluginInfoVisitor.Visit(const info: ICefWebPluginInfo;
  count, total: Integer): Boolean;
begin
  Result := FProc(info, count, total);
end;

{ TCefRequestCallbackRef }

procedure TCefRequestCallbackRef.Cancel;
begin
  PCefRequestCallback(FData).cancel(FData);
end;

procedure TCefRequestCallbackRef.Cont(allow: Boolean);
begin
  PCefRequestCallback(FData).cont(FData, Ord(allow));
end;

class function TCefRequestCallbackRef.UnWrap(data: Pointer): ICefRequestCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestCallback else
    Result := nil;
end;

{ TCefV8StackFrameRef }

function TCefV8StackFrameRef.GetColumn: Integer;
begin
  Result := PCefV8StackFrame(FData).get_column(FData);
end;

function TCefV8StackFrameRef.GetFunctionName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_function_name(FData));
end;

function TCefV8StackFrameRef.GetLineNumber: Integer;
begin
  Result := PCefV8StackFrame(FData).get_line_number(FData);
end;

function TCefV8StackFrameRef.GetScriptName: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_script_name(FData));
end;

function TCefV8StackFrameRef.GetScriptNameOrSourceUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefV8StackFrame(FData).get_script_name_or_source_url(FData));
end;

function TCefV8StackFrameRef.IsConstructor: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_constructor(FData) <> 0;
end;

function TCefV8StackFrameRef.IsEval: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_eval(FData) <> 0;
end;

function TCefV8StackFrameRef.IsValid: Boolean;
begin
  Result := PCefV8StackFrame(FData).is_valid(FData) <> 0;
end;

class function TCefV8StackFrameRef.UnWrap(data: Pointer): ICefV8StackFrame;
begin
  if data <> nil then
    Result := Create(data) as ICefV8StackFrame else
    Result := nil;
end;

{ TCefV8StackTraceRef }

class function TCefV8StackTraceRef.Current(frameLimit: Integer): ICefV8StackTrace;
begin
  Result := UnWrap(cef_v8stack_trace_get_current(frameLimit));
end;

function TCefV8StackTraceRef.GetFrame(index: Integer): ICefV8StackFrame;
begin
  Result := TCefV8StackFrameRef.UnWrap(PCefV8StackTrace(FData).get_frame(FData, index));
end;

function TCefV8StackTraceRef.GetFrameCount: Integer;
begin
  Result := PCefV8StackTrace(FData).get_frame_count(FData);
end;

function TCefV8StackTraceRef.IsValid: Boolean;
begin
  Result := PCefV8StackTrace(FData).is_valid(FData) <> 0;
end;

class function TCefV8StackTraceRef.UnWrap(data: Pointer): ICefV8StackTrace;
begin
  if data <> nil then
    Result := Create(data) as ICefV8StackTrace else
    Result := nil;
end;

{ TCefWebPluginUnstableCallbackOwn }

constructor TCefWebPluginUnstableCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWebPluginUnstableCallback));
  PCefWebPluginUnstableCallback(FData).is_unstable := cef_web_plugin_unstable_callback_is_unstable;
end;

procedure TCefWebPluginUnstableCallbackOwn.IsUnstable(const path: ustring;
  unstable: Boolean);
begin

end;

{ TCefFastWebPluginUnstableCallback }

constructor TCefFastWebPluginUnstableCallback.Create(
  const callback: TCefWebPluginIsUnstableProc);
begin
  FCallback := callback;
end;

procedure TCefFastWebPluginUnstableCallback.IsUnstable(const path: ustring;
  unstable: Boolean);
begin
  FCallback(path, unstable);
end;

{ TCefRunFileDialogCallbackOwn }

constructor TCefRunFileDialogCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefRunFileDialogCallback));
  with PCefRunFileDialogCallback(FData)^ do
    on_file_dialog_dismissed := cef_run_file_dialog_callback_on_file_dialog_dismissed;
end;

procedure TCefRunFileDialogCallbackOwn.OnFileDialogDismissed(
  selectedAcceptFilter: Integer; filePaths: TStrings);
begin

end;

{ TCefFastRunFileDialogCallback }

procedure TCefFastRunFileDialogCallback.OnFileDialogDismissed(
  selectedAcceptFilter: Integer; filePaths: TStrings);
begin
  FCallback(selectedAcceptFilter, filePaths);
end;

constructor TCefFastRunFileDialogCallback.Create(
  callback: TCefRunFileDialogCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

{ TCefTaskRef }

procedure TCefTaskRef.Execute;
begin
  PCefTask(FData).execute(FData);
end;

class function TCefTaskRef.UnWrap(data: Pointer): ICefTask;
begin
  if data <> nil then
    Result := Create(data) as ICefTask else
    Result := nil;
end;

{ TCefTaskRunnerRef }

function TCefTaskRunnerRef.BelongsToCurrentThread: Boolean;
begin
  Result := PCefTaskRunner(FData).belongs_to_current_thread(FData) <> 0;
end;

function TCefTaskRunnerRef.BelongsToThread(threadId: TCefThreadId): Boolean;
begin
  Result := PCefTaskRunner(FData).belongs_to_thread(FData, threadId) <> 0;
end;

class function TCefTaskRunnerRef.GetForCurrentThread: ICefTaskRunner;
begin
  Result := UnWrap(cef_task_runner_get_for_current_thread());
end;

class function TCefTaskRunnerRef.GetForThread(threadId: TCefThreadId): ICefTaskRunner;
begin
  Result := UnWrap(cef_task_runner_get_for_thread(threadId));
end;

function TCefTaskRunnerRef.IsSame(const that: ICefTaskRunner): Boolean;
begin
  Result := PCefTaskRunner(FData).is_same(FData, CefGetData(that)) <> 0;
end;

function TCefTaskRunnerRef.PostDelayedTask(const task: ICefTask;
  delayMs: Int64): Boolean;
begin
  Result := PCefTaskRunner(FData).post_delayed_task(FData, CefGetData(task), delayMs) <> 0;
end;

function TCefTaskRunnerRef.PostTask(const task: ICefTask): Boolean;
begin
  Result := PCefTaskRunner(FData).post_task(FData, CefGetData(task)) <> 0;
end;

class function TCefTaskRunnerRef.UnWrap(data: Pointer): ICefTaskRunner;
begin
  if data <> nil then
    Result := Create(data) as ICefTaskRunner else
    Result := nil;
end;

{ TCefEndTracingCallbackOwn }

constructor TCefEndTracingCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefEndTracingCallback));
  with PCefEndTracingCallback(FData)^ do
    on_end_tracing_complete := cef_end_tracing_callback_on_end_tracing_complete;
end;

procedure TCefEndTracingCallbackOwn.OnEndTracingComplete(
  const tracingFile: ustring);
begin

end;

{ TCefGetGeolocationCallbackOwn }

constructor TCefGetGeolocationCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefGetGeolocationCallback));
  with PCefGetGeolocationCallback(FData)^ do
    on_location_update := cef_get_geolocation_callback_on_location_update;
end;

procedure TCefGetGeolocationCallbackOwn.OnLocationUpdate(
  const position: PCefGeoposition);
begin

end;

{ TCefFastGetGeolocationCallback }

constructor TCefFastGetGeolocationCallback.Create(
  const callback: TOnLocationUpdate);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastGetGeolocationCallback.OnLocationUpdate(
  const position: PCefGeoposition);
begin
  FCallback(position);
end;

{ TCefFileDialogCallbackRef }

procedure TCefFileDialogCallbackRef.Cancel;
begin
  PCefFileDialogCallback(FData).cancel(FData);
end;

procedure TCefFileDialogCallbackRef.Cont(selectedAcceptFilter: Integer; filePaths: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    for i := 0 to filePaths.Count - 1 do
    begin
      str := CefString(filePaths[i]);
      cef_string_list_append(list, @str);
    end;
    PCefFileDialogCallback(FData).cont(FData, selectedAcceptFilter, list);
  finally
    cef_string_list_free(list);
  end;
end;

class function TCefFileDialogCallbackRef.UnWrap(
  data: Pointer): ICefFileDialogCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefFileDialogCallback else
    Result := nil;
end;

{ TCefDialogHandlerOwn }

constructor TCefDialogHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefDialogHandler));
  with PCefDialogHandler(FData)^ do
    on_file_dialog := cef_dialog_handler_on_file_dialog;
end;

function TCefDialogHandlerOwn.OnFileDialog(const browser: ICefBrowser;
  mode: TCefFileDialogMode; const title, defaultFilePath: ustring;
  acceptFilters: TStrings; selectedAcceptFilter: Integer;
  const callback: ICefFileDialogCallback): Boolean;
begin
  Result := False;
end;

{ TCefRenderHandlerOwn }

constructor TCefRenderHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefRenderHandler), False);
  with PCefRenderHandler(FData)^ do
  begin
    get_root_screen_rect := cef_render_handler_get_root_screen_rect;
    get_view_rect := cef_render_handler_get_view_rect;
    get_screen_point := cef_render_handler_get_screen_point;
    on_popup_show := cef_render_handler_on_popup_show;
    on_popup_size := cef_render_handler_on_popup_size;
    on_paint := cef_render_handler_on_paint;
    on_cursor_change := cef_render_handler_on_cursor_change;
    start_dragging := cef_render_handler_start_dragging;
    update_drag_cursor := cef_render_handler_update_drag_cursor;
    on_scroll_offset_changed := cef_render_handler_on_scroll_offset_changed;
  end;
end;

function TCefRenderHandlerOwn.GetRootScreenRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
begin
  Result := False;
end;

function TCefRenderHandlerOwn.GetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
begin
  Result := False;
end;

procedure TCefRenderHandlerOwn.OnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; CursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin

end;

procedure TCefRenderHandlerOwn.OnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
begin

end;

procedure TCefRenderHandlerOwn.OnPopupShow(const browser: ICefBrowser;
  show: Boolean);
begin

end;

procedure TCefRenderHandlerOwn.OnPopupSize(const browser: ICefBrowser;
  const rect: PCefRect);
begin

end;

procedure TCefRenderHandlerOwn.OnScrollOffsetChanged(
  const browser: ICefBrowser; x, y: Double);
begin

end;

function TCefRenderHandlerOwn.OnStartDragging(const browser: ICefBrowser;
  const dragData: ICefDragData; allowedOps: TCefDragOperations; x,
  y: Integer): Boolean;
begin
  Result := False;
end;

procedure TCefRenderHandlerOwn.OnUpdateDragCursor(const browser: ICefBrowser;
  operation: TCefDragOperation);
begin

end;

{ TCefCompletionHandlerOwn }

constructor TCefCompletionCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefCompletionCallback));
  with PCefCompletionCallback(FData)^ do
    on_complete := cef_completion_callback_on_complete;
end;

procedure TCefCompletionCallbackOwn.OnComplete;
begin

end;

{ TCefFastCompletionHandler }

constructor TCefFastCompletionCallback.Create(
  const proc: TCefCompletionCallbackProc);
begin
   inherited Create;
   FProc := proc;
end;

procedure TCefFastCompletionCallback.OnComplete;
begin
  FProc();
end;

{ TCefDragDataRef }

procedure TCefDragDataRef.AddFile(const path, displayName: ustring);
var
  p, d: TCefString;
begin
  p := CefString(path);
  d := CefString(displayName);
  PCefDragData(FData).add_file(FData, @p, @d);
end;

function TCefDragDataRef.Clone: ICefDragData;
begin
  Result := UnWrap(PCefDragData(FData).clone(FData));
end;

function TCefDragDataRef.GetFileContents(
  const writer: ICefStreamWriter): NativeUInt;
begin
  Result := PCefDragData(FData).get_file_contents(FData, CefGetData(writer))
end;

function TCefDragDataRef.GetFileName: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_file_name(FData));
end;

function TCefDragDataRef.GetFileNames(names: TStrings): Integer;
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    Result := PCefDragData(FData).get_file_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefDragDataRef.GetFragmentBaseUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_base_url(FData));
end;

function TCefDragDataRef.GetFragmentHtml: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_html(FData));
end;

function TCefDragDataRef.GetFragmentText: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_fragment_text(FData));
end;

function TCefDragDataRef.GetLinkMetadata: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_metadata(FData));
end;

function TCefDragDataRef.GetLinkTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_title(FData));
end;

function TCefDragDataRef.GetLinkUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefDragData(FData).get_link_url(FData));
end;

function TCefDragDataRef.IsFile: Boolean;
begin
  Result := PCefDragData(FData).is_file(FData) <> 0;
end;

function TCefDragDataRef.IsFragment: Boolean;
begin
  Result := PCefDragData(FData).is_fragment(FData) <> 0;
end;

function TCefDragDataRef.IsLink: Boolean;
begin
  Result := PCefDragData(FData).is_link(FData) <> 0;
end;

function TCefDragDataRef.IsReadOnly: Boolean;
begin
  Result := PCefDragData(FData).is_read_only(FData) <> 0;
end;

class function TCefDragDataRef.New: ICefDragData;
begin
  Result := UnWrap(cef_drag_data_create());
end;

procedure TCefDragDataRef.ResetFileContents;
begin
  PCefDragData(FData).reset_file_contents(FData);
end;

procedure TCefDragDataRef.SetFragmentBaseUrl(const baseUrl: ustring);
var
  s: TCefString;
begin
  s := CefString(baseUrl);
  PCefDragData(FData).set_fragment_base_url(FData, @s);
end;

procedure TCefDragDataRef.SetFragmentHtml(const html: ustring);
var
  s: TCefString;
begin
  s := CefString(html);
  PCefDragData(FData).set_fragment_html(FData, @s);
end;

procedure TCefDragDataRef.SetFragmentText(const text: ustring);
var
  s: TCefString;
begin
  s := CefString(text);
  PCefDragData(FData).set_fragment_text(FData, @s);
end;

procedure TCefDragDataRef.SetLinkMetadata(const data: ustring);
var
  s: TCefString;
begin
  s := CefString(data);
  PCefDragData(FData).set_link_metadata(FData, @s);
end;

procedure TCefDragDataRef.SetLinkTitle(const title: ustring);
var
  s: TCefString;
begin
  s := CefString(title);
  PCefDragData(FData).set_link_title(FData, @s);
end;

procedure TCefDragDataRef.SetLinkUrl(const url: ustring);
var
  s: TCefString;
begin
  s := CefString(url);
  PCefDragData(FData).set_link_url(FData, @s);
end;

class function TCefDragDataRef.UnWrap(data: Pointer): ICefDragData;
begin
  if data <> nil then
    Result := Create(data) as ICefDragData else
    Result := nil;
end;

{ TCefDragHandlerOwn }

constructor TCefDragHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefDragHandler), False);
  with PCefDragHandler(FData)^ do
  begin
    on_drag_enter := cef_drag_handler_on_drag_enter;
{$ifdef Win32}
    on_draggable_regions_changed := cef_drag_handler_on_draggable_regions_changed;
{$endif}
  end;
end;

function TCefDragHandlerOwn.OnDragEnter(const browser: ICefBrowser;
  const dragData: ICefDragData; mask: TCefDragOperations): Boolean;
begin
  Result := False;
end;

procedure TCefDragHandlerOwn.OnDraggableRegionsChanged(
  const browser: ICefBrowser; regionsCount: NativeUInt;
  regions: PCefDraggableRegionArray);
begin

end;

{ TCefRequestContextRef }

function TCefRequestContextRef.ClearSchemeHandlerFactories: Boolean;
begin
  Result := PCefRequestContext(FData).clear_scheme_handler_factories(FData) <> 0;
end;

function TCefRequestContextRef.GetCachePath: ustring;
begin
  Result := CefStringFreeAndGet(PCefRequestContext(FData).get_cache_path(FData));
end;

function TCefRequestContextRef.GetDefaultCookieManager(
  const callback: ICefCompletionCallback): ICefCookieManager;
begin
  Result := TCefCookieManagerRef.UnWrap(
    PCefRequestContext(FData).get_default_cookie_manager(
      FData, CefGetData(callback)));
end;

function TCefRequestContextRef.GetDefaultCookieManagerProc(
  const callback: TCefCompletionCallbackProc): ICefCookieManager;
begin
  Result := GetDefaultCookieManager(TCefFastCompletionCallback.Create(callback));
end;

function TCefRequestContextRef.GetHandler: ICefRequestContextHandler;
begin
  Result := TCefRequestContextHandlerRef.UnWrap(PCefRequestContext(FData).get_handler(FData));
end;

class function TCefRequestContextRef.Global: ICefRequestContext;
begin
  Result:= UnWrap(cef_request_context_get_global_context());
end;

function TCefRequestContextRef.IsGlobal: Boolean;
begin
  Result:= PCefRequestContext(FData).is_global(FData) <> 0;
end;

function TCefRequestContextRef.IsSame(const other: ICefRequestContext): Boolean;
begin
  Result:= PCefRequestContext(FData).is_same(FData, CefGetData(other)) <> 0;
end;

function TCefRequestContextRef.IsSharingWith(
  const other: ICefRequestContext): Boolean;
begin
  Result:= PCefRequestContext(FData).is_sharing_with(FData, CefGetData(other)) <> 0;
end;

class function TCefRequestContextRef.New(
  const settings: PCefRequestContextSettings;
  const handler: ICefRequestContextHandler): ICefRequestContext;
begin
  Result := UnWrap(cef_request_context_create_context(settings, CefGetData(handler)));
end;

procedure TCefRequestContextRef.PurgePluginListCache(reloadPages: Boolean);
begin
  PCefRequestContext(FData).purge_plugin_list_cache(FData, Ord(reloadPages));
end;

function TCefRequestContextRef.RegisterSchemeHandlerFactory(const schemeName,
  domainName: ustring; const factory: ICefSchemeHandlerFactory): Boolean;
var
  s, d: TCefString;
begin
  s := CefString(schemeName);
  d := CefString(domainName);
  Result := PCefRequestContext(FData).register_scheme_handler_factory(FData, @s, @d, CefGetData(factory)) <> 0;
end;

class function TCefRequestContextRef.Shared(const other: ICefRequestContext;
  const handler: ICefRequestContextHandler): ICefRequestContext;
begin
  Result := UnWrap(create_context_shared(CefGetData(other), CefGetData(handler)));
end;

class function TCefRequestContextRef.UnWrap(data: Pointer): ICefRequestContext;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestContext else
    Result := nil;
end;

{ TCefRequestContextHandlerRef }

function TCefRequestContextHandlerRef.GetCookieManager: ICefCookieManager;
begin
  Result := TCefCookieManagerRef.UnWrap(PCefRequestContextHandler(FData).get_cookie_manager(FData));
end;

function TCefRequestContextHandlerRef.OnBeforePluginLoad(const mimeType,
  pluginUrl, topOriginUrl: ustring; const pluginInfo: ICefWebPluginInfo;
  pluginPolicy: PCefPluginPolicy): Boolean;
var
  mt, pu, ou: TCefString;
begin
  mt := CefString(mimeType);
  pu:= CefString(pluginUrl);
  ou := CefString(topOriginUrl);
  Result := PCefRequestContextHandler(FData).on_before_plugin_load(
    FData, @mt, @pu, @ou, CefGetData(pluginInfo), pluginPolicy) <> 0;
end;

class function TCefRequestContextHandlerRef.UnWrap(
  data: Pointer): ICefRequestContextHandler;
begin
  if data <> nil then
    Result := Create(data) as ICefRequestContextHandler else
    Result := nil;
end;

{ TCefRequestContextHandlerOwn }

constructor TCefRequestContextHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefRequestContextHandler), False);
  with PCefRequestContextHandler(FData)^ do
  begin
    get_cookie_manager := cef_request_context_handler_get_cookie_manager;
    on_before_plugin_load := cef_request_context_handler_on_before_plugin_load;
  end;
end;

function TCefRequestContextHandlerOwn.GetCookieManager: ICefCookieManager;
begin
  Result:= nil;
end;

function TCefRequestContextHandlerOwn.OnBeforePluginLoad(const mimeType,
  pluginUrl, topOriginUrl: ustring; const pluginInfo: ICefWebPluginInfo;
  pluginPolicy: PCefPluginPolicy): Boolean;
begin
  Result := False;
end;

{ TCefFastRequestContextHandler }

constructor TCefFastRequestContextHandler.Create(
  const proc: TCefRequestContextHandlerProc);
begin
  FProc := proc;
  inherited Create;
end;

function TCefFastRequestContextHandler.GetCookieManager: ICefCookieManager;
begin
  Result := FProc();
end;

{ TCefPrintSettingsRef }

function TCefPrintSettingsRef.Copy: ICefPrintSettings;
begin
  Result := UnWrap(PCefPrintSettings(FData).copy(FData))
end;

function TCefPrintSettingsRef.GetColorModel: TCefColorModel;
begin
  Result := PCefPrintSettings(FData).get_color_model(FData);
end;

function TCefPrintSettingsRef.GetCopies: Integer;
begin
  Result := PCefPrintSettings(FData).get_copies(FData);
end;

function TCefPrintSettingsRef.GetDeviceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefPrintSettings(FData).get_device_name(FData));
end;

function TCefPrintSettingsRef.GetDpi: Integer;
begin
  Result := PCefPrintSettings(FData).get_dpi(FData);
end;

function TCefPrintSettingsRef.GetDuplexMode: TCefDuplexMode;
begin
  Result := PCefPrintSettings(FData).get_duplex_mode(FData);
end;

procedure TCefPrintSettingsRef.GetPageRanges(
  out ranges: TCefPageRangeArray);
var
  len: NativeUInt;
begin
  len := GetPageRangesCount;
  SetLength(ranges, len);
  if len > 0 then
    PCefPrintSettings(FData).get_page_ranges(FData, @len, @ranges[0]);
end;

function TCefPrintSettingsRef.GetPageRangesCount: NativeUInt;
begin
  Result := PCefPrintSettings(FData).get_page_ranges_count(FData);
end;

function TCefPrintSettingsRef.IsLandscape: Boolean;
begin
  Result := PCefPrintSettings(FData).is_landscape(FData) <> 0;
end;

function TCefPrintSettingsRef.IsReadOnly: Boolean;
begin
  Result := PCefPrintSettings(FData).is_read_only(FData) <> 0;
end;

function TCefPrintSettingsRef.IsSelectionOnly: Boolean;
begin
  Result := PCefPrintSettings(FData).is_selection_only(FData) <> 0;
end;

function TCefPrintSettingsRef.IsValid: Boolean;
begin
  Result := PCefPrintSettings(FData).is_valid(FData) <> 0;
end;

class function TCefPrintSettingsRef.New: ICefPrintSettings;
begin
  Result := UnWrap(cef_print_settings_create);
end;

procedure TCefPrintSettingsRef.SetCollate(collate: Boolean);
begin
  PCefPrintSettings(FData).set_collate(FData, Ord(collate));
end;

procedure TCefPrintSettingsRef.SetColorModel(model: TCefColorModel);
begin
  PCefPrintSettings(FData).set_color_model(FData, model);
end;

procedure TCefPrintSettingsRef.SetCopies(copies: Integer);
begin
  PCefPrintSettings(FData).set_copies(FData, copies);
end;

procedure TCefPrintSettingsRef.SetDeviceName(const name: ustring);
var
  s: TCefString;
begin
  s := CefString(name);
  PCefPrintSettings(FData).set_device_name(FData, @s);
end;

procedure TCefPrintSettingsRef.SetDpi(dpi: Integer);
begin
  PCefPrintSettings(FData).set_dpi(FData, dpi);
end;

procedure TCefPrintSettingsRef.SetDuplexMode(mode: TCefDuplexMode);
begin
  PCefPrintSettings(FData).set_duplex_mode(FData, mode);
end;

procedure TCefPrintSettingsRef.SetOrientation(landscape: Boolean);
begin
  PCefPrintSettings(FData).set_orientation(FData, Ord(landscape));
end;

procedure TCefPrintSettingsRef.SetPageRanges(
  const ranges: TCefPageRangeArray);
var
  len: NativeUInt;
begin
  len := Length(ranges);
  if len > 0 then
    PCefPrintSettings(FData).set_page_ranges(FData, len, @ranges[0]) else
    PCefPrintSettings(FData).set_page_ranges(FData, 0, nil);
end;

procedure TCefPrintSettingsRef.SetPrinterPrintableArea(
  const physicalSizeDeviceUnits: PCefSize;
  const printableAreaDeviceUnits: PCefRect; landscapeNeedsFlip: Boolean);
begin
  PCefPrintSettings(FData).set_printer_printable_area(FData, physicalSizeDeviceUnits,
    printableAreaDeviceUnits, Ord(landscapeNeedsFlip));
end;

procedure TCefPrintSettingsRef.SetSelectionOnly(selectionOnly: Boolean);
begin
  PCefPrintSettings(FData).set_selection_only(FData, Ord(selectionOnly));
end;

class function TCefPrintSettingsRef.UnWrap(
  data: Pointer): ICefPrintSettings;
begin
  if data <> nil then
    Result := Create(data) as ICefPrintSettings else
    Result := nil;
end;

function TCefPrintSettingsRef.WillCollate: Boolean;
begin
  Result := PCefPrintSettings(FData).will_collate(FData) <> 0;
end;

{ TCefStreamWriterRef }

class function TCefStreamWriterRef.CreateForFile(
  const fileName: ustring): ICefStreamWriter;
var
  s: TCefString;
begin
  s := CefString(fileName);
  Result := UnWrap(cef_stream_writer_create_for_file(@s));
end;

class function TCefStreamWriterRef.CreateForHandler(
  const handler: ICefWriteHandler): ICefStreamWriter;
begin
  Result := UnWrap(cef_stream_writer_create_for_handler(CefGetData(handler)));
end;

function TCefStreamWriterRef.Flush: Integer;
begin
  Result := PCefStreamWriter(FData).flush(FData);
end;

function TCefStreamWriterRef.MayBlock: Boolean;
begin
  Result := PCefStreamWriter(FData).may_block(FData) <> 0;
end;

function TCefStreamWriterRef.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := PCefStreamWriter(FData).seek(FData, offset, whence);
end;

function TCefStreamWriterRef.Tell: Int64;
begin
  Result := PCefStreamWriter(FData).tell(FData);
end;

class function TCefStreamWriterRef.UnWrap(data: Pointer): ICefStreamWriter;
begin
  if data <> nil then
    Result := Create(data) as ICefStreamWriter else
    Result := nil;
end;

function TCefStreamWriterRef.write(const ptr: Pointer; size,
  n: NativeUInt): NativeUInt;
begin
  Result := PCefStreamWriter(FData).write(FData, ptr, size, n);
end;

{ TCefWriteHandlerOwn }

constructor TCefWriteHandlerOwn.Create;
begin
  inherited CreateData(SizeOf(TCefWriteHandler));
  with PCefWriteHandler(FData)^ do
  begin
    write := cef_write_handler_write;
    seek := cef_write_handler_seek;
    tell := cef_write_handler_tell;
    flush := cef_write_handler_flush;
    may_block := cef_write_handler_may_block;
  end;
end;

function TCefWriteHandlerOwn.Flush: Integer;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.MayBlock: Boolean;
begin
  Result := False;
end;

function TCefWriteHandlerOwn.Seek(offset: Int64; whence: Integer): Integer;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.Tell: Int64;
begin
  Result := 0;
end;

function TCefWriteHandlerOwn.Write(const ptr: Pointer; size,
  n: NativeUInt): NativeUInt;
begin
  Result := 0;
end;

{ TCefNavigationEntryRef }

function TCefNavigationEntryRef.IsValid: Boolean;
begin
  Result := PCefNavigationEntry(FData).is_valid(FData) <> 0;
end;

function TCefNavigationEntryRef.GetUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_url(FData));
end;

function TCefNavigationEntryRef.GetDisplayUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_display_url(FData));
end;

function TCefNavigationEntryRef.GetOriginalUrl: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_original_url(FData));
end;

function TCefNavigationEntryRef.GetTitle: ustring;
begin
  Result := CefStringFreeAndGet(PCefNavigationEntry(FData).get_title(FData));
end;

function TCefNavigationEntryRef.GetTransitionType: TCefTransitionType;
begin
  Result := PCefNavigationEntry(FData).get_transition_type(FData);
end;

function TCefNavigationEntryRef.HasPostData: Boolean;
begin
  Result := PCefNavigationEntry(FData).has_post_data(FData) <> 0;
end;

function TCefNavigationEntryRef.GetCompletionTime: TDateTime;
begin
  Result := CefTimeToDateTime(PCefNavigationEntry(FData).get_completion_time(FData));
end;

function TCefNavigationEntryRef.GetHttpStatusCode: Integer;
begin
  Result := PCefNavigationEntry(FData).get_http_status_code(FData);
end;

class function TCefNavigationEntryRef.UnWrap(data: Pointer): ICefNavigationEntry;
begin
  if data <> nil then
    Result := Create(data) as ICefNavigationEntry else
    Result := nil;
end;

{ TCefNavigationEntryVisitorOwn }

constructor TCefNavigationEntryVisitorOwn.Create;
begin
  CreateData(SizeOf(TCefNavigationEntryVisitor), False);
  with PCefNavigationEntryVisitor(FData)^ do
    visit := cef_navigation_entry_visitor_visit;
end;

function TCefNavigationEntryVisitorOwn.Visit(const entry: ICefNavigationEntry;
  current: Boolean; index, total: Integer): Boolean;
begin
  Result:= False;
end;

{ TCefFastNavigationEntryVisitor }

constructor TCefFastNavigationEntryVisitor.Create(
  const proc: TCefNavigationEntryVisitorProc);
begin
  FVisitor := proc;
  inherited Create;
end;

function TCefFastNavigationEntryVisitor.Visit(const entry: ICefNavigationEntry;
  current: Boolean; index, total: Integer): Boolean;
begin
  Result := FVisitor(entry, current, index, total);
end;

{ TCefFindHandlerOwn }

constructor TCefFindHandlerOwn.Create;
begin
  CreateData(SizeOf(TCefFindHandler), False);
  with PCefFindHandler(FData)^ do
    on_find_result := cef_find_handler_on_find_result;
end;

{ TCefSetCookieCallbackOwn }

constructor TCefSetCookieCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefSetCookieCallback));
  with PCefSetCookieCallback(FData)^ do
    on_complete := cef_set_cookie_callback_on_complete;
end;

{ TCefFastSetCookieCallback }

constructor TCefFastSetCookieCallback.Create(
  const callback: TCefSetCookieCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastSetCookieCallback.OnComplete(success: Boolean);
begin
  FCallback(success);
end;

{ TCefDeleteCookiesCallbackOwn }

constructor TCefDeleteCookiesCallbackOwn.Create;
begin
  inherited CreateData(SizeOf(TCefDeleteCookiesCallback));
  with PCefDeleteCookiesCallback(FData)^ do
    on_complete := cef_delete_cookie_callback_on_complete;
end;

{ TCefFastDeleteCookiesCallback }

constructor TCefFastDeleteCookiesCallback.Create(
  const callback: TCefDeleteCookiesCallbackProc);
begin
  inherited Create;
  FCallback := callback;
end;

procedure TCefFastDeleteCookiesCallback.OnComplete(numDeleted: Integer);
begin
  FCallback(numDeleted)
end;

{ TCefValueRef }

function TCefValueRef.Copy: ICefValue;
begin
  Result := UnWrap(PCefValue(FData).copy(FData));
end;

function TCefValueRef.GetBinary: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefValue(FData).get_binary(FData));
end;

function TCefValueRef.GetBool: Boolean;
begin
  Result := PCefValue(FData).get_bool(FData) <> 0;
end;

function TCefValueRef.GetDictionary: ICefDictionaryValue;
begin
  Result := TCefDictionaryValueRef.UnWrap(PCefValue(FData).get_dictionary(FData));
end;

function TCefValueRef.GetDouble: Double;
begin
  Result := PCefValue(FData).get_double(FData);
end;

function TCefValueRef.GetInt: Integer;
begin
  Result := PCefValue(FData).get_int(FData);
end;

function TCefValueRef.GetList: ICefListValue;
begin
  Result := TCefListValueRef.UnWrap(PCefValue(FData).get_list(FData));
end;

function TCefValueRef.GetString: ustring;
begin
  Result := CefStringFreeAndGet(PCefValue(FData).get_string(FData));
end;

function TCefValueRef.GetType: TCefValueType;
begin
  Result := PCefValue(FData).get_type(FData);
end;

function TCefValueRef.IsEqual(const that: ICefValue): Boolean;
begin
  Result := PCefValue(FData).is_equal(FData, CefGetData(that)) <> 0;
end;

function TCefValueRef.IsOwned: Boolean;
begin
  Result := PCefValue(FData).is_owned(FData) <> 0;
end;

function TCefValueRef.IsReadOnly: Boolean;
begin
  Result := PCefValue(FData).is_read_only(FData) <> 0;
end;

function TCefValueRef.IsSame(const that: ICefValue): Boolean;
begin
  Result := PCefValue(FData).is_same(FData, CefGetData(that)) <> 0;
end;

function TCefValueRef.IsValid: Boolean;
begin
  Result := PCefValue(FData).is_valid(FData) <> 0;
end;

class function TCefValueRef.New: ICefValue;
begin
  Result := UnWrap(cef_value_create());
end;

function TCefValueRef.SetBinary(const value: ICefBinaryValue): Boolean;
begin
  Result := PCefValue(FData).set_binary(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetBool(value: Integer): Boolean;
begin
  Result := PCefValue(FData).set_bool(FData, value) <> 0;
end;

function TCefValueRef.SetDictionary(const value: ICefDictionaryValue): Boolean;
begin
  Result := PCefValue(FData).set_dictionary(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetDouble(value: Double): Boolean;
begin
  Result := PCefValue(FData).set_double(FData, value) <> 0;
end;

function TCefValueRef.SetInt(value: Integer): Boolean;
begin
  Result := PCefValue(FData).set_int(FData, value) <> 0;
end;

function TCefValueRef.SetList(const value: ICefListValue): Boolean;
begin
  Result := PCefValue(FData).set_list(FData, CefGetData(value)) <> 0;
end;

function TCefValueRef.SetNull: Boolean;
begin
  Result := PCefValue(FData).set_null(FData) <> 0;
end;

function TCefValueRef.SetString(const value: ustring): Boolean;
var
 s: TCefString;
begin
  s := CefString(value);
  Result := PCefValue(FData).set_string(FData, @s) <> 0;
end;

class function TCefValueRef.UnWrap(data: Pointer): ICefValue;
begin
  if data <> nil then
    Result := Create(data) as ICefValue else
    Result := nil;
end;

{ TCefSslCertPrincipalRef }

function TCefSslCertPrincipalRef.GetCommonName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_common_name(FData));
end;

function TCefSslCertPrincipalRef.GetCountryName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_country_name(FData));
end;

function TCefSslCertPrincipalRef.GetDisplayName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_display_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetDomainComponents(components: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_domain_components(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      components.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefSslCertPrincipalRef.GetLocalityName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_locality_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetOrganizationNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_organization_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

procedure TCefSslCertPrincipalRef.GetOrganizationUnitNames(names: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_organization_unit_names(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      names.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

function TCefSslCertPrincipalRef.GetStateOrProvinceName: ustring;
begin
  Result := CefStringFreeAndGet(PCefSslCertPrincipal(FData).get_state_or_province_name(FData));
end;

procedure TCefSslCertPrincipalRef.GetStreetAddresses(addresses: TStrings);
var
  list: TCefStringList;
  i: Integer;
  str: TCefString;
begin
  list := cef_string_list_alloc;
  try
    PCefSslCertPrincipal(FData).get_street_addresses(FData, list);
    for i := 0 to cef_string_list_size(list) - 1 do
    begin
      FillChar(str, SizeOf(str), 0);
      cef_string_list_value(list, i, @str);
      addresses.Add(CefStringClearAndGet(str));
    end;
  finally
    cef_string_list_free(list);
  end;
end;

class function TCefSslCertPrincipalRef.UnWrap(
  data: Pointer): ICefSslCertPrincipal;
begin
  if data <> nil then
    Result := Create(data) as ICefSslCertPrincipal else
    Result := nil;
end;

{ TCefSslInfoRef }

function TCefSslInfoRef.GetDerEncoded: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_derencoded(FData));
end;

function TCefSslInfoRef.GetIssuer: ICefSslCertPrincipal;
begin
  Result := TCefSslCertPrincipalRef.UnWrap(PCefSslInfo(FData).get_issuer(FData));
end;

function TCefSslInfoRef.GetPemEncoded: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_pemencoded(FData));
end;

function TCefSslInfoRef.GetSerialNumber: ICefBinaryValue;
begin
  Result := TCefBinaryValueRef.UnWrap(PCefSslInfo(FData).get_serial_number(FData));
end;

function TCefSslInfoRef.GetSubject: ICefSslCertPrincipal;
begin
  Result := TCefSslCertPrincipalRef.UnWrap(PCefSslInfo(FData).get_subject(FData));
end;

function TCefSslInfoRef.GetValidExpiry: TCefTime;
begin
  Result := PCefSslInfo(FData).get_valid_expiry(FData);
end;

function TCefSslInfoRef.GetValidStart: TCefTime;
begin
  Result := PCefSslInfo(FData).get_valid_start(FData);
end;

class function TCefSslInfoRef.UnWrap(data: Pointer): ICefSslInfo;
begin
  if data <> nil then
    Result := Create(data) as ICefSslInfo else
    Result := nil;
end;

{ TCefPdfPrintCallbackOwn }

constructor TCefPdfPrintCallbackOwn.Create;
begin
  CreateData(SizeOf(TCefPdfPrintCallback), False);
  with PCefPdfPrintCallback(FData)^ do
    on_pdf_print_finished := cef_pdf_print_callback_on_pdf_print_finished;
end;

{ TCefFastPdfPrintCallback }

constructor TCefFastPdfPrintCallback.Create(
  const proc: TOnPdfPrintFinishedProc);
begin
  FProc := proc;
  inherited Create;
end;

procedure TCefFastPdfPrintCallback.OnPdfPrintFinished(const path: ustring;
  ok: Boolean);
begin
  FProc(path, ok);
end;

{ TCefRunContextMenuCallbackRef }

procedure TCefRunContextMenuCallbackRef.Cancel;
begin
  PCefRunContextMenuCallback(FData).cancel(FData);
end;

procedure TCefRunContextMenuCallbackRef.Cont(commandId: Integer;
  eventFlags: TCefEventFlags);
begin
  PCefRunContextMenuCallback(FData).cont(FData, commandId, eventFlags);
end;

class function TCefRunContextMenuCallbackRef.UnWrap(
  data: Pointer): ICefRunContextMenuCallback;
begin
  if data <> nil then
    Result := Create(data) as ICefRunContextMenuCallback else
    Result := nil;
end;

{ TCefResourceBundleRef }

function TCefResourceBundleRef.GetDataResource(resourceId: Integer;
  out data: Pointer; out dataSize: NativeUInt): Boolean;
begin
  Result := PCefResourceBundle(FData).get_data_resource(FData, resourceId,
    data, dataSize) <> 0;
end;

function TCefResourceBundleRef.GetDataResourceForScale(resourceId: Integer;
  scaleFactor: TCefScaleFactor; out data: Pointer;
  out dataSize: NativeUInt): Boolean;
begin
  Result := PCefResourceBundle(FData).get_data_resource_for_scale(FData,
    resourceId, scaleFactor, data, dataSize) <> 0;
end;

function TCefResourceBundleRef.GetLocalizedString(stringId: Integer): ustring;
begin
  Result := CefStringFreeAndGet(PCefResourceBundle(FData).get_localized_string(FData, stringId));
end;

class function TCefResourceBundleRef.Global: ICefResourceBundle;
begin
  Result := UnWrap(cef_resource_bundle_get_global());
end;

class function TCefResourceBundleRef.UnWrap(data: Pointer): ICefResourceBundle;
begin
  if data <> nil then
    Result := Create(data) as ICefResourceBundle else
    Result := nil;
end;

initialization
  IsMultiThread := True;

finalization
  CefShutDown;

end.

