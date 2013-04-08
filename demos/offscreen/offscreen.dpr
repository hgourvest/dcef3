program offscreen;

uses
  Forms,
  ceflib,
  main in 'main.pas' {Mainform};

{$R *.res}

begin

  if not CefLoadLibDefault then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainform, Mainform);
  Application.Run;
end.
