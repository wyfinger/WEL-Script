unit ideUnit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SynEditHighlighter, SynHighlighterPas,
  SynEdit, wel, Contnrs, ExtCtrls;

type
  TForm1 = class(TForm)
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    SynEdit2: TSynEdit;
    SynEdit3: TSynEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure SynEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  C : TWel;

implementation

{$R *.dfm}

procedure TForm1.SynEdit1Change(Sender: TObject);
begin
 SynEdit1.Lines.SaveToFile('code.txt');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  a : string;
begin
 SynEdit1.Lines.LoadFromFile('code.txt');
 C := TWel.Create();
 {
 a := '[]';
 a := C.SetArrValR(a, '1', [0]);         ShowMessage(a);
 a := C.SetArrValR(a, '2', [1]);         ShowMessage(a);
 a := C.SetArrValR(a, '3', [2]);         ShowMessage(a);
 a := C.SetArrValR(a, '4', [3]);         ShowMessage(a);
 a := C.SetArrValR(a, '5', [0,0]);       ShowMessage(a);
 a := C.SetArrValR(a, '5', [0,1]);       ShowMessage(a);
 a := C.SetArrValR(a, '5', [0,2]);       ShowMessage(a);
 a := C.SetArrValR(a, '5', [0,3]);       ShowMessage(a);

 
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [1]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [2]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [3]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [4]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [5]));

 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0,0]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0,1]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0,2]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0,3]));
 ShowMessage(C.SetArrValR('[["4",5,6],"1",2,3]', '"new"', [0,4]));
 }
end;

procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : Integer;
  e : string;
  a : string;
begin
 if Key = VK_F9 then
 begin
   SynEdit2.Lines.Clear;
   for i := 0 to SynEdit1.Lines.Count-1 do
   begin
     e := Trim(SynEdit1.Lines[i]);
     if e <> '' then
       begin
         a := C.Calc(e);
         C.fVars.Values['ans'] := a;
         SynEdit2.Lines.Add(A)
       end
     else SynEdit2.Lines.Add('');
   end;
   SynEdit3.Lines.Text := C.fVars.Text;
 end;
end;

end.
