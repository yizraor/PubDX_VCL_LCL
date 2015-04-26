object FormAbout: TFormAbout
  Left = 0
  Top = 0
  ActiveControl = btnOk
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
  ClientHeight = 201
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    329
    201)
  PixelsPerInch = 96
  TextHeight = 13
  object lblAbout: TLabel
    Left = 8
    Top = 8
    Width = 313
    Height = 154
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Caption = 
      #1044#1077#1084#1086#1085#1089#1090#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072'  ( DirectX 11 )'#13#10#13#10#1058#1077#1084#1072':'#13#10'  - '#1080#1089#1087#1086#1083#1100#1079 +
      #1086#1074#1072#1085#1080#1077' Direct3D '#1074#1084#1077#1089#1090#1077' '#1089' VCL / LCL'#13#10#13#10#1047#1072#1076#1077#1081#1089#1090#1074#1086#1074#1072#1085#1085#1099#1077' DirectX - ' +
      'API :'#13#10'  - DXGI'#13#10'  - Direct3D'#13#10'  - D3Dcompiler ( HLSL )'#13#10
  end
  object btnOk: TButton
    Left = 128
    Top = 168
    Width = 81
    Height = 25
    Anchors = [akBottom]
    Cancel = True
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
