object Form1: TForm1
  Left = 689
  Top = 174
  Width = 1185
  Height = 624
  Caption = 'WEL Script  -  Wyfinger Expression Language'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 845
    Top = 0
    Height = 586
    Align = alRight
    Color = clActiveCaption
    ParentColor = False
  end
  object Splitter2: TSplitter
    Left = 521
    Top = 0
    Height = 586
    Align = alRight
    Color = clActiveCaption
    ParentColor = False
  end
  object SynEdit1: TSynEdit
    Left = 0
    Top = 0
    Width = 521
    Height = 586
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    OnKeyDown = SynEdit1KeyDown
    BorderStyle = bsNone
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.ShowLineNumbers = True
    Gutter.Width = 20
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = '//code'
    ScrollBars = ssNone
    OnChange = SynEdit1Change
    FontSmoothing = fsmNone
  end
  object SynEdit2: TSynEdit
    Left = 524
    Top = 0
    Width = 321
    Height = 586
    Align = alRight
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 1
    BorderStyle = bsNone
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.Visible = False
    Gutter.Width = 0
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = '//result'
    FontSmoothing = fsmNone
  end
  object SynEdit3: TSynEdit
    Left = 848
    Top = 0
    Width = 321
    Height = 586
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 2
    BorderStyle = bsNone
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.Visible = False
    Gutter.Width = 0
    Highlighter = SynPasSyn1
    Lines.UnicodeStrings = '//variables'
    FontSmoothing = fsmNone
  end
  object SynPasSyn1: TSynPasSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = clMenuHighlight
    Left = 56
    Top = 24
  end
end
