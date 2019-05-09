object frmCutDialog: TfrmCutDialog
  AlignWithMargins = True
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Tribo Viewer'
  ClientHeight = 112
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 82
    Top = 8
    Width = 46
    Height = 13
    Caption = 'Cut from:'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 112
    Height = 13
    Caption = 'Real number  of cycles:'
  end
  object Ok: TButton
    Left = 111
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object Cancel: TButton
    Left = 198
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edCutFrom: TJvCalcEdit
    Left = 152
    Top = 5
    Width = 121
    Height = 21
    TabOrder = 2
    DecimalPlacesAlwaysShown = False
  end
  object edRealNumber: TJvCalcEdit
    Left = 152
    Top = 37
    Width = 121
    Height = 21
    TabOrder = 3
    DecimalPlacesAlwaysShown = False
  end
end
