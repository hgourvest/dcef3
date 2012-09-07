program guiclient;

uses
  ceflib,
  Forms,
  main in 'main.pas' {MainForm},
  ceffilescheme in '..\filescheme\ceffilescheme.pas';

{$R *.res}

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  registrar.AddCustomScheme('local', True, True, False);
end;

begin
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefRemoteDebuggingPort := 9000;
  CefSingleProcess := False;
  if not CefLoadLibDefault then Exit;
  CefRegisterSchemeHandlerFactory('local', '', False, TFileScheme);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
