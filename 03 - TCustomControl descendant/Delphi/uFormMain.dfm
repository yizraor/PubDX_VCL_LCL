object FormMain: TFormMain
  Left = 200
  Top = 100
  Caption = #1044#1077#1084#1086#1085#1089#1090#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072'  ( DirectX11 )'
  ClientHeight = 369
  ClientWidth = 585
  Color = clAppWorkSpace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  PopupMenu = PopupMenu
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 350
    Width = 585
    Height = 19
    Panels = <
      item
        Text = #1047#1072#1087#1091#1089#1082'  '#1087#1088#1086#1075#1088#1072#1084#1084#1099' ...'
        Width = 400
      end
      item
        Alignment = taCenter
        Text = '- fps'
        Width = 50
      end>
  end
  object pnShaderCode: TPanel
    Left = 0
    Top = 0
    Width = 265
    Height = 350
    Align = alLeft
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      265
      350)
    object lblShaderCode: TLabel
      Left = 8
      Top = 6
      Width = 249
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1082#1086#1076' '#1096#1077#1081#1076#1077#1088#1086#1074' ( VS + PS ) :'
      Layout = tlCenter
    end
    object lblShadersErrors: TLabel
      Left = 8
      Top = 249
      Width = 249
      Height = 23
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Caption = #1054#1096#1080#1073#1082#1080' '#1082#1086#1084#1087#1080#1083#1103#1094#1080#1080' '#1080' '#1076#1088'. '#1089#1086#1086#1073#1097#1077#1085#1080#1103' :'
      Layout = tlCenter
    end
    object txtShaderCode: TMemo
      Left = 8
      Top = 30
      Width = 249
      Height = 219
      Anchors = [akLeft, akTop, akRight, akBottom]
      ScrollBars = ssBoth
      TabOrder = 0
      WantTabs = True
    end
    object btnShaderApply: TButton
      Left = 48
      Top = 319
      Width = 169
      Height = 25
      Action = actFileCompile
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 2
    end
    object txtShaderErrors: TMemo
      Left = 8
      Top = 272
      Width = 249
      Height = 41
      Anchors = [akLeft, akRight, akBottom]
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
      WantReturns = False
    end
  end
  object MainMenu: TMainMenu
    Left = 384
    Top = 16
    object miFile: TMenuItem
      Caption = '&'#1064#1077#1081#1076#1077#1088
      object miFileSample1: TMenuItem
        Action = actFileSample1
      end
      object miFileSample2: TMenuItem
        Action = actFileSample2
      end
      object miFileSep01: TMenuItem
        Caption = '-'
      end
      object miFileOpen: TMenuItem
        Action = actFileOpen
      end
      object miFileSave: TMenuItem
        Action = actFileSave
      end
    end
    object miRender: TMenuItem
      Caption = '&'#1054#1090#1088#1080#1089#1086#1074#1082#1072
      object miRenderVSync: TMenuItem
        Action = actRenderVSync
        AutoCheck = True
      end
      object miRenderSep01: TMenuItem
        Caption = '-'
      end
      object miRenderMsaa1: TMenuItem
        Action = actRenderMsaa1
        AutoCheck = True
        GroupIndex = 1
      end
      object miRenderMsaa2: TMenuItem
        Action = actRenderMsaa2
        AutoCheck = True
        GroupIndex = 1
      end
      object miRenderMsaa4: TMenuItem
        Action = actRenderMsaa4
        AutoCheck = True
        GroupIndex = 1
      end
      object miRenderMsaa8: TMenuItem
        Action = actRenderMsaa8
        AutoCheck = True
        GroupIndex = 1
      end
    end
    object miOther: TMenuItem
      Caption = '&'#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
      object miOtherDebugDevice: TMenuItem
        Action = actOtherDebugDevice
        AutoCheck = True
      end
      object miOtherDebugReport: TMenuItem
        Action = actOtherDebugReport
      end
      object miOtherSep01: TMenuItem
        Caption = '-'
      end
      object miOtherAboutMsgbox: TMenuItem
        Action = actProgramAboutMsgbox
      end
      object miOtherAboutForm: TMenuItem
        Action = actProgramAboutForm
      end
    end
    object miQuit: TMenuItem
      Action = actProgramQuit
    end
  end
  object PopupMenu: TPopupMenu
    Left = 448
    Top = 16
    object miPopupVSync: TMenuItem
      Action = actRenderVSync
      AutoCheck = True
    end
    object miPopupSep01: TMenuItem
      Caption = '-'
    end
    object miPopupMsaa1: TMenuItem
      Action = actRenderMsaa1
      AutoCheck = True
    end
    object miPopupMsaa2: TMenuItem
      Action = actRenderMsaa2
      AutoCheck = True
    end
    object miPopupMsaa4: TMenuItem
      Action = actRenderMsaa4
      AutoCheck = True
    end
    object miPopupMsaa8: TMenuItem
      Action = actRenderMsaa8
      AutoCheck = True
    end
  end
  object ActionList: TActionList
    Left = 320
    Top = 16
    object actFileSample1: TAction
      Category = #1064#1077#1081#1076#1077#1088
      Caption = #1055#1088#1080#1084#1077#1088'  &1  ( '#1087#1088#1086#1089#1090#1077#1081#1096#1080#1081' )'
      OnExecute = actFileSample1Execute
    end
    object actFileSample2: TAction
      Category = #1064#1077#1081#1076#1077#1088
      Caption = #1055#1088#1080#1084#1077#1088'  &2  ( '#1089' '#1072#1085#1080#1084#1072#1094#1080#1077#1081' )'
      OnExecute = actFileSample2Execute
    end
    object actFileOpen: TAction
      Category = #1064#1077#1081#1076#1077#1088
      Caption = '&'#1054#1090#1082#1088#1099#1090#1100'  '#1092#1072#1081#1083' ...'
      OnExecute = actFileOpenExecute
    end
    object actFileSave: TAction
      Category = #1064#1077#1081#1076#1077#1088
      Caption = '&'#1057#1086#1093#1088#1072#1085#1080#1090#1100'  '#1092#1072#1081#1083' ...'
      OnExecute = actFileSaveExecute
    end
    object actRenderVSync: TAction
      Category = #1054#1090#1088#1080#1089#1086#1074#1082#1072
      AutoCheck = True
      Caption = '&'#1042#1082#1083#1102#1095#1080#1090#1100'  VSync'
      Checked = True
      OnExecute = actRenderVSyncExecute
    end
    object actRenderMsaa1: TAction
      Category = #1054#1090#1088#1080#1089#1086#1074#1082#1072
      AutoCheck = True
      Caption = 'MSAA :  &'#1086#1090#1082#1083#1102#1095#1077#1085
      Checked = True
      GroupIndex = 1
      OnExecute = actRenderMsaa1Execute
    end
    object actRenderMsaa2: TAction
      Category = #1054#1090#1088#1080#1089#1086#1074#1082#1072
      AutoCheck = True
      Caption = 'MSAA :  x&2'
      GroupIndex = 1
      OnExecute = actRenderMsaa2Execute
    end
    object actRenderMsaa4: TAction
      Category = #1054#1090#1088#1080#1089#1086#1074#1082#1072
      AutoCheck = True
      Caption = 'MSAA :  x&4'
      GroupIndex = 1
      OnExecute = actRenderMsaa4Execute
    end
    object actRenderMsaa8: TAction
      Category = #1054#1090#1088#1080#1089#1086#1074#1082#1072
      AutoCheck = True
      Caption = 'MSAA :  x&8'
      GroupIndex = 1
      OnExecute = actRenderMsaa8Execute
    end
    object actOtherDebugDevice: TAction
      Category = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
      AutoCheck = True
      Caption = #1054#1090#1083#1072#1076#1086#1095#1085#1086#1077'  &'#1091#1089#1090#1088#1086#1081#1089#1090#1074#1086'  Direct3D'
      OnExecute = actOtherDebugDeviceExecute
    end
    object actOtherDebugReport: TAction
      Category = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
      Caption = #1054#1090#1083#1072#1076#1086#1095#1085#1099#1081'  &'#1074#1099#1074#1086#1076'  D3D  ( ReportLiveObjects )'
      OnExecute = actOtherDebugReportExecute
    end
    object actProgramAboutMsgbox: TAction
      Category = #1055#1088#1086#1075#1088#1072#1084#1084#1072
      Caption = #1054'  '#1087#1088#1086#1075#1088#1072#1084#1084#1077'  ( MessageBox )'
      OnExecute = actProgramAboutMsgboxExecute
    end
    object actProgramAboutForm: TAction
      Category = #1055#1088#1086#1075#1088#1072#1084#1084#1072
      Caption = #1054'  '#1087#1088#1086#1075#1088#1072#1084#1084#1077'  ( TForm )'
      OnExecute = actProgramAboutFormExecute
    end
    object actProgramQuit: TAction
      Category = #1055#1088#1086#1075#1088#1072#1084#1084#1072
      Caption = '&'#1042#1099#1093#1086#1076
      OnExecute = actProgramQuitExecute
    end
    object actFileCompile: TAction
      Category = #1064#1077#1081#1076#1077#1088
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100'  '#1096#1077#1081#1076#1077#1088
      OnExecute = actFileCompileExecute
    end
  end
  object OpenDlg: TOpenDialog
    Filter = #1042#1089#1077' '#1092#1072#1081#1083#1099'  ( *.* )|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = #1054#1090#1082#1088#1099#1090#1080#1077' '#1092#1072#1081#1083#1072' '#1089' '#1080#1089#1093#1086#1076#1085#1099#1084' '#1082#1086#1076#1086#1084' '#1096#1077#1081#1076#1077#1088#1072
    Left = 384
    Top = 72
  end
  object SaveDlg: TSaveDialog
    Filter = #1042#1089#1077' '#1092#1072#1081#1083#1099'  ( *.* )|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1092#1072#1081#1083#1072' '#1089' '#1080#1089#1093#1086#1076#1085#1099#1084' '#1082#1086#1076#1086#1084' '#1096#1077#1081#1076#1077#1088#1072
    Left = 448
    Top = 72
  end
end
