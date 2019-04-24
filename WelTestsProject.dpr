program WelTestsProject;

uses
  TestFramework,
  Forms,
  GUITestRunner,
  TextTestRunner,
  WelTests,
  wel in 'wel.pas';

{$R *.RES}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;

end.

