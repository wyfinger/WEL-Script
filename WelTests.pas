unit WelTests;

interface

uses
  TestFrameWork, Wel;

type
  TTestWel = class(TTestCase)
    fC: TWel;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPlus;
    procedure TestMinus;
    procedure TestMultiply;
    procedure TestBrackets;
    procedure TestArithmetic;
  end;

implementation

procedure TTestWel.SetUp;
begin
  inherited;
  fC := TWel.Create;
end;

procedure TTestWel.TearDown;
begin
  inherited;
  fC.Free; 
end;

procedure TTestWel.TestPlus;
begin
  CheckEquals('3', fC.Calc('1+2'), 'fails on "1+2"');
  CheckEquals('6.1', fC.Calc('1+2.+3.1'), 'fails on "1+2.+3.1"');
  CheckEquals('0', fC.Calc('1+2+-3'), 'fails on "1+2+-3"');
  CheckEquals('188', fC.Calc('plus(42,146)'), 'fails on "plus(42,146)"');
end;

procedure TTestWel.TestMinus;
begin
  CheckEquals('-1', fC.Calc('1-2'), 'fails on "1-2"');
  CheckEquals('-4', fC.Calc('1-2-3'), 'fails on "1-2-3"');
  CheckEquals('3', fC.Calc('1--2'), 'fails on "1--2"');
end;

procedure TTestWel.TestMultiply;
begin
  CheckEquals('25', fC.Calc('5*5'), 'fails on "5*5"');
  CheckEquals('7.006652', fC.Calc('1.234 * 5.678'), 'fails on "1.234 * 5.678"');
end;

procedure TTestWel.TestBrackets;
begin
  CheckEquals('8', fC.Calc('(2+2)*2'), 'fails on "(2+2)*2"');
  CheckEquals('69', fC.Calc('1+2*3+4*5+6*7'), 'fails on "(2+2)*2"');
end;

procedure TTestWel.TestArithmetic;
begin
  CheckEquals('0', fC.Calc('0+0'), 'fails on "0+0"');
  CheckEquals('3', fC.Calc('1+2'), 'fails on "1+2"');
  CheckEquals('20', fC.Calc('10+10'), 'fails on "10+10"');
  CheckEquals('-104', fC.Calc('42+-146'), 'fails on "42+-146"');
  CheckEquals('0', fC.Calc('0-0'), 'fails on "0-0"');
  CheckEquals('0', fC.Calc('0*5'), 'fails on "0*5"');
  CheckEquals('-10', fC.Calc('5*-2'), 'fails on "5*-2"');
  CheckEquals('14', fC.Calc('2+3*4'), 'fails on "2+3*4"');
  CheckEquals('20', fC.Calc('(2+3)*4'), 'fails on "(2+3)*4"');
end;

initialization
  TestFramework.RegisterTest(TTestWel.Suite);

end.
