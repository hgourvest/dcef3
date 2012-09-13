object ProxyFormDlg: TProxyFormDlg
  Left = 0
  Top = 0
  Caption = 'Select a proxy'
  ClientHeight = 68
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object proxyStr: TEdit
    Left = 8
    Top = 8
    Width = 402
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 35
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 335
    Top = 35
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button2Click
  end
end
