unit cefreg;

{$I ..\src\cef.inc}
{$R chromium.dcr}
interface

procedure Register;

implementation
uses
  Classes, cefvcl
{$ifdef DELPHI16_UP}
  ,ceffmx
{$endif}
  ;

procedure Register;
begin
  RegisterComponents('Chromium', [
    TChromiumDevTools, TChromium, TChromiumOSR
{$ifdef DELPHI16_UP}
    ,TChromiumFMX
{$endif}
    ]);
end;

end.
