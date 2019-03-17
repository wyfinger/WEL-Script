program WelTestsProject;

uses
  TestFramework,
  Forms,
  GUITestRunner,
  TextTestRunner,
  WelTests;

{$R *.RES}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;

end.

