object MainView: TMainView
  Left = 0
  Top = 0
  ActiveControl = btnStart
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Problem Step Recorder'
  ClientHeight = 452
  ClientWidth = 368
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  StyleName = 'Windows'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 136
    Width = 54
    Height = 15
    Caption = 'Recording'
    FocusControl = btnStart
  end
  object Label2: TLabel
    Left = 24
    Top = 24
    Width = 132
    Height = 15
    Caption = 'Show &display control GUI'
    FocusControl = ToggleSwitchDC
  end
  object Label3: TLabel
    Left = 24
    Top = 48
    Width = 205
    Height = 15
    Caption = '&Capture screenshots for recorded steps'
    FocusControl = ToggleSwitchSC
  end
  object Label4: TLabel
    Left = 24
    Top = 176
    Width = 89
    Height = 15
    Caption = '&Output Filename'
    FocusControl = memoOutput
  end
  object Label5: TLabel
    Left = 24
    Top = 96
    Width = 235
    Height = 15
    Caption = 'Maximum number of recent screen captures'
  end
  object Label6: TLabel
    Left = 24
    Top = 72
    Width = 186
    Height = 15
    Caption = 'Include ETW and XML in output file'
    FocusControl = ToggleSwitchIncludeETWAndXML
  end
  object lblWaiting: TLabel
    Left = 151
    Top = 136
    Width = 111
    Height = 15
    Caption = '(Please wait, saving)'
    FocusControl = btnStart
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object Bevel1: TBevel
    Left = 24
    Top = 344
    Width = 319
    Height = 2
  end
  object btnStart: TButton
    Left = 268
    Top = 132
    Width = 75
    Height = 25
    Caption = '&Start'
    TabOrder = 4
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 268
    Top = 163
    Width = 75
    Height = 25
    Caption = 'S&top'
    Enabled = False
    TabOrder = 5
    OnClick = btnStopClick
  end
  object memoOutput: TMemo
    Left = 24
    Top = 194
    Width = 319
    Height = 140
    TabOrder = 6
    OnDblClick = memoOutputClick
  end
  object ToggleSwitchDC: TToggleSwitch
    Left = 272
    Top = 19
    Width = 71
    Height = 20
    StateCaptions.CaptionOn = 'on'
    StateCaptions.CaptionOff = 'off'
    TabOrder = 0
  end
  object ToggleSwitchSC: TToggleSwitch
    Left = 272
    Top = 43
    Width = 71
    Height = 20
    State = tssOn
    StateCaptions.CaptionOn = 'on'
    StateCaptions.CaptionOff = 'off'
    TabOrder = 1
  end
  object edtMaxSC: TMaskEdit
    Tag = 999
    Left = 272
    Top = 93
    Width = 39
    Height = 23
    EditMask = '###'
    MaxLength = 3
    TabOrder = 3
    Text = '999'
  end
  object ToggleSwitchIncludeETWAndXML: TToggleSwitch
    Left = 272
    Top = 67
    Width = 71
    Height = 20
    StateCaptions.CaptionOn = 'on'
    StateCaptions.CaptionOff = 'off'
    TabOrder = 2
  end
  object ActivityIndicatorSaving: TActivityIndicator
    Left = 102
    Top = 128
  end
  object btnExtractor: TButton
    Left = 268
    Top = 414
    Width = 75
    Height = 25
    Caption = 'Extractor'
    TabOrder = 8
    OnClick = btnExtractorClick
  end
  object edtExtractorOutputFrom: TLabeledEdit
    Left = 56
    Top = 356
    Width = 287
    Height = 23
    EditLabel.Width = 26
    EditLabel.Height = 23
    EditLabel.Caption = 'from'
    LabelPosition = lpLeft
    TabOrder = 9
    Text = ''
  end
  object edtExtractorOutputTo: TLabeledEdit
    Left = 56
    Top = 385
    Width = 287
    Height = 23
    EditLabel.Width = 11
    EditLabel.Height = 23
    EditLabel.Caption = 'to'
    LabelPosition = lpLeft
    TabOrder = 10
    Text = ''
  end
  object BtnOpen: TButton
    Left = 56
    Top = 414
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 11
    OnClick = BtnOpenClick
  end
  object OpenDialog: TOpenDialog
    FileName = '*.zip'
    Filter = 'MHT Zip (*.zip)|*.zip|All types (*.*)|*.*'
    InitialDir = 'c:\Temp\002'
    Left = 72
    Top = 328
  end
end
