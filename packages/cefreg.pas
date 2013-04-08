unit cefreg;

{$I ..\src\cef.inc}
{$R chromium.dcr}
interface

procedure Register;

implementation
uses
  Classes, cefvcl
{$ifdef DELPHI16_UP}
{$ifndef DELPHI17_UP}
  ,ceffmx
{$endif}
{$endif}
  ;

procedure Register;
begin
  RegisterComponents('Chromium', [
    TChromium, TChromiumOSR
{$ifdef DELPHI16_UP}
{$ifndef DELPHI17_UP}
    ,TChromiumFMX
{$endif}
{$endif}
    ]);
end;

end.
