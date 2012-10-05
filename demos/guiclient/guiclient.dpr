program guiclient;

uses
  sysutils,
  ceflib,
  Windows,
  Forms,
  main in 'main.pas' {MainForm},
  ceffilescheme in '..\filescheme\ceffilescheme.pas',
  ProxyForm in 'ProxyForm.pas' {ProxyFormDlg};

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme('local', True, True, False);
end;

var
  proc: string;
begin
//  if StrPos(GetCommandLine, '--type=renderer') <> nil then
//    Beep(1000, 1000);
  //CefLogSeverity := LOGSEVERITY_VERBOSE;
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefSingleProcess := False;
  if not CefLoadLibDefault then Exit;

  CefRegisterSchemeHandlerFactory('local', '', False, TFileScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
