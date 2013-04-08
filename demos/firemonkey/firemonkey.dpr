program firemonkey;

uses
  FMX.Forms,
  ceflib,
  main in 'main.pas' {MainForm};

{$R *.res}

begin
  CefSingleProcess := False;
  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
