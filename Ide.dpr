program ide;

uses
  Forms,
  ideUnit1 in 'ideUnit1.pas' {Form1},
  wel in 'wel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Wel Ide';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
