unit cefreg;

{$I ..\src\cef.inc}
{$R chromium.dcr}
interface

procedure Register;

implementation
uses
  Classes, cefvcl;

procedure Register;
begin
  RegisterComponents('Chromium', [
    TChromium]);
end;

end.
