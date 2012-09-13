unit ProxyForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

type
  TProxyFormDlg = class(TForm)
    proxyStr: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

  IStringValue = interface
    ['{6E5A4E66-1A47-4EED-BBF0-4DC4BC690930}']
    function GetString: string;
    procedure SetString(const value: string);
    property Value: string read GetString write SetString;
  end;

var
  ProxyFormDlg: TProxyFormDlg;

implementation
uses ceflib;

{$R *.dfm}

procedure TProxyFormDlg.Button1Click(Sender: TObject);
begin
  with CefBrowserProcessHandler.GetProxyHandler as IStringValue do
    Value := proxyStr.Text;
  ModalResult := mrOk;
end;

procedure TProxyFormDlg.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TProxyFormDlg.FormCreate(Sender: TObject);
begin
  with CefBrowserProcessHandler.GetProxyHandler as IStringValue do
    proxyStr.Text := Value;
end;

end.
