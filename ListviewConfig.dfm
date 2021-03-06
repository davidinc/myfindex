object frmListViewConfig: TfrmListViewConfig
  Left = 836
  Top = 586
  BorderStyle = bsDialog
  Caption = 'Dateilistenansicht: Spaltenlayout'
  ClientHeight = 203
  ClientWidth = 308
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gb1: TGroupBox
    Left = 8
    Top = 8
    Width = 177
    Height = 185
    Caption = ' Spalten '
    TabOrder = 0
    object clbCols: TCheckListBox
      Left = 8
      Top = 16
      Width = 161
      Height = 161
      HelpContext = 5001
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object btnOk: TFlatButton
    Left = 200
    Top = 128
    Width = 89
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    BevelWidth = 1
    BevelWidthM = 2
    BevelWidthDown = 1
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object btnAbort: TFlatButton
    Left = 200
    Top = 160
    Width = 89
    Height = 25
    Caption = 'Abbrechen'
    TabOrder = 3
    BevelWidth = 1
    BevelWidthM = 2
    BevelWidthDown = 1
    Kind = bkCancel
  end
  object gbOptions: TGroupBox
    Left = 192
    Top = 8
    Width = 105
    Height = 73
    Caption = ' Optionen '
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 63
      Height = 13
      Caption = 'Dateigröße in'
    end
    object cbSizeFmt: TComboBox
      Left = 8
      Top = 40
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'automatisch'
        'Byte'
        'KB'
        'MB'
        'GB'
        'TB')
    end
  end
end
