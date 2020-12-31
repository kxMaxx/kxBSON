object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Test BSON - by kxMaxx'
  ClientHeight = 562
  ClientWidth = 771
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PTop: TPanel
    Left = 0
    Top = 0
    Width = 771
    Height = 57
    Align = alTop
    TabOrder = 0
    object BNewRnd: TButton
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 124
      Height = 47
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Caption = 'Create Random'
      TabOrder = 0
      OnClick = BNewRndClick
    end
    object BWriteFile: TButton
      AlignWithMargins = True
      Left = 265
      Top = 5
      Width = 124
      Height = 47
      Margins.Left = 0
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Caption = 'Write to file'
      TabOrder = 1
      OnClick = BWriteFileClick
    end
    object BReadFile: TButton
      AlignWithMargins = True
      Left = 393
      Top = 5
      Width = 124
      Height = 47
      Margins.Left = 0
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Caption = 'Read from file'
      TabOrder = 2
      OnClick = BReadFileClick
    end
    object BStreamCopy: TButton
      AlignWithMargins = True
      Left = 521
      Top = 5
      Width = 124
      Height = 47
      Margins.Left = 0
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Caption = 'Stream copy'
      TabOrder = 3
      OnClick = BStreamCopyClick
    end
    object BNewHandMade: TButton
      AlignWithMargins = True
      Left = 137
      Top = 5
      Width = 124
      Height = 47
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Caption = 'Create handmade'
      TabOrder = 4
      OnClick = BNewHandMadeClick
    end
  end
  object PMemo: TPanel
    Left = 0
    Top = 57
    Width = 771
    Height = 505
    Align = alClient
    TabOrder = 1
    object Memo: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 761
      Height = 476
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Lines.Strings = (
        'Memo')
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object StatusBar: TStatusBar
      Left = 1
      Top = 485
      Width = 769
      Height = 19
      Panels = <
        item
          Text = 'Time'
          Width = 150
        end>
    end
  end
end
