unit WelTests;

interface

uses
  TestFrameWork, Wel;

type
  TTestWelBasic = class(TTestCase)
    fC: TWel;
  private
    procedure TestDivideByZero;
    procedure TestAbs;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // operators
    procedure TestPlus;
    procedure TestMinus;
    procedure TestMultiply;
    procedure TestDivide;
    procedure TestConcat;
    procedure TestPower;
    procedure TestCompare;
    procedure TestMath;


    procedure TestBrackets;
    // complex variable types: arrays and strings
    
    // build in functions and variables
    procedure TestArithmetic;
    procedure TestArrayCreate;
  end;

  TTestWelComplex = class(TTestCase)
    fC: TWel;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
  end;

implementation

uses SysUtils;

procedure TTestWelBasic.SetUp;
begin
  inherited;
  //
end;

procedure TTestWelBasic.TearDown;
begin
  inherited;
  //
end;

procedure TTestWelBasic.TestPlus;
begin
  // plus operator can be used with numbers, strings and arrays
  fC := TWel.Create;

  // num + num
  CheckEquals('3', fC.Calc('1+2'), 'fails on 1+2');
  CheckEquals('124', fC.Calc('99 + 25 '), 'fails on 99 + 25');
  CheckEquals('45.25', fC.Calc(' 1.25 + 44'), 'fails on 99 + 25');
  CheckEquals('-1.8585', fC.Calc('3.1415+-5'), 'fails on 3.1415+-5');
  CheckEquals('-2', fC.Calc('plus(3., -5)'), 'fails on plus(3.1415, -5)');
  // num and str
  CheckEquals('"12.345hello"', fC.Calc('12.345+"hello"'), 'fails on 12.345+"hello"');
  CheckEquals('"world123"', fC.Calc('"world" + 123'), 'fails on "world" + 123');
  // str + str
  CheckEquals('"Hello World"', fC.Calc('"Hello " + "World"'), 'fails on "Hello " + "World"');
  // num + array
  CheckEquals('[124,125,126]', fC.Calc('123+[1,2,3]'), 'fails on 123+[1,2,3]');
  CheckEquals('[3.65,3.968,4.95428,5.377]', fC.Calc('2.236 + [1.414  1.7320 2.71828,  3.141]'), 'fails on 2.236 + [1.414  1.7320 2.71828,  3.141]');
  // array + str
  CheckEquals('["6 kV","10 kV","35 kV","110 kV","220 kV"]', fC.Calc('[6 10 35 110 220] + " kV"'), 'fails on [6 10 35 110 220] + " kV"');
  // str + array
  CheckEquals('["Age is 18","Age is 6"]', fC.Calc('"Age is " + [18,6]'), 'fails on "Age is " + [18,6]');
  // array with subarray + num
  CheckEquals('[2,3,[3,4]]', fC.Calc('[1,2,[2,3]]+1'), 'fails on [1,2,[2,3]]+1');
  // array + array
  // TODO: only if length of arrays equal summ by elements

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestMinus;
begin
  // minus operator can be used with numbers or arrays
  fC := TWel.Create;

  // num - num
  CheckEquals('-1', fC.Calc('1-2'), 'fails on 1-2');
  CheckEquals('-1', fC.Calc('99-100'), 'fails on 99-100');
  CheckEquals('3', fC.Calc('1--2'), 'fails on 1--2');
  // num - array
  CheckEquals('[0,-2,-3,-4]', fC.Calc('1-[1 3, 4 5]'), 'fails on 1-[1 3, 4 5]');
  // array - num
  CheckEquals('[0.4,1.2,-10.1]', fC.Calc('[5.5, 6.3, -5]-5.1'), 'fails on [5.5, 6.3, -5]-5.1');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestMultiply;
begin
  // multiply operator can be used with numbers or arrays
  fC := TWel.Create;           // WARNING: floating point arithmetic may differ
                               //          on different processors and compilers! 
  // num * num
  CheckEquals('2.44948974278322', fC.Calc('1.4142135623731 * 1.7320508075689'), 'fails on 1.4142135623731 * 1.7320508075689');
  CheckEquals('192.301846064983', fC.Calc('86 * 2.2360679774998'), 'fails on 86 * 2.2360679774998');

  // array * num (or num * array)
  CheckEquals('[2,3]', fC.Calc('1*[2,3]'), 'fails on 1*[2,3]');
  CheckEquals('[24,30]', fC.Calc('[4,5]*6'), 'fails on [4,5]*6');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestDivideByZero;
begin
  fC.Calc('1/0');
end;

procedure TTestWelBasic.TestDivide;
begin
  // devide (/) is a floating point operator,
  // (\) is a integer devide and (%) is a remainder operators
  fC := TWel.Create;

  // num / num
  CheckEquals('2', fC.Calc('10/5'), 'fails on 10/5');
  CheckEquals('0.5', fC.Calc('5 /10'), 'fails on 5 /10');
  CheckEquals('-10', fC.Calc('-30/ 3'), 'fails on -30/ 3');
  CheckEquals('-3', fC.Calc('15/-5'), 'fails on 15/-5');

  // num \ num
  CheckEquals('3', fC.Calc('10\3'), 'fails on 10\3');
  CheckEquals('0', fC.Calc('5 \10'), 'fails on 5 \10');
  CheckEquals('0', fC.Calc('0\ 9.532'), 'fails on 0\ 9.532');
  CheckEquals('2', fC.Calc('0.3\0.1'), 'fails on 0.3\0.1');  // FP bug! it's normall

  // num % num
  CheckEquals('1', fC.Calc('10%3'), 'fails on 10%3');
  CheckEquals('5', fC.Calc('5%10'), 'fails on 5%10');
  CheckEquals('0', fC.Calc('0%9.532'), 'fails on 0%9.532');
  CheckEquals('0.1', fC.Calc('0.3%0.1'), 'fails on 0.3%0.1'); // FP bug! it's normall

  // div by zero
  CheckException(TestDivideByZero, EWelException, 'falis on divide by zero, it must raise exceprion');

  // nums and arrays
  CheckEquals('[3,22,0.2]', fC.Calc('[9,66,0.6]/3'), '[9,66,0.6]/3');
  CheckEquals('[44,6,660]', fC.Calc('132/[3,22,0.2]'), '132/[3,22,0.2]');

  CheckEquals('[3,22,0]', fC.Calc('[9,66,0.6]\3'), '[9,66,0.6]\3');
  CheckEquals('[51,7,769]', fC.Calc('154\[3,22,0.2]'), '154\[3,22,0.2]');

  CheckEquals('[9,6,0.6]', fC.Calc('[9,66,0.6]%10'), '[9,66,0.6]%10');
  CheckEquals('[0,0,0]', fC.Calc('132%[3,22,2]'), '132%[3,22,2]');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestConcat;
begin
  // string concatenation (&) operator, it can be used with
  // strings ot numbers or arrays, like a (+)
  fC := TWel.Create;

  // str & str
  CheckEquals('"Hello World!"', fC.Calc('"Hello " & "World" & "!"'), 'fails on "Hello " & "World" & "!"');

  // str & num
  CheckEquals('"My age is 18"', fC.Calc('"My age is " & 12+6'), 'fails on "My age is " & 12+6');
  CheckEquals('"5 tests completed"', fC.Calc('5 + " tests completed"'), 'fails on 5 + " tests completed"');

  // num & num
  CheckEquals('"37"', fC.Calc('1 + 2 & 3 + 4'), 'fails on 1 + 2 & 3 + 4');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestPower;
begin
  // power
  fC := TWel.Create;

  CheckEquals('8', fC.Calc('2^3'), 'fails on 2^3');
  CheckEquals('3.16227766016838', fC.Calc('10^0.5'), 'fails on 10^0.5');
  CheckEquals('1', fC.Calc('0^0'), 'fails on 0^0');
  CheckEquals('1', fC.Calc('125.15^0'), 'fails on 125.15^0');
  CheckEquals('256', fC.Calc('2^2^3'), 'fails on 2^2^4');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestCompare;
begin
 fC := TWel.Create;

 CheckEquals('1', fC.Calc('2*2 = 4'), 'fails on 2*2 = 4');                          // =    eq
 CheckEquals('0', fC.Calc('"answer" = 42'), 'fails on "answer" = 42');              // <>   ne
 CheckEquals('1', fC.Calc('4.99 <> 25/5'), 'fails on 4.99 <> 25/5');                // <    lt
 CheckEquals('1', fC.Calc('"first" <> "second"'), 'fails on "first" <> "second"');  // >    gt
 CheckEquals('0', fC.Calc('1 < -1'), 'fails on 1 < -1');                            // <=   le
 CheckEquals('1', fC.Calc('99 < 99.1'), 'fails on 99 < 99.1');                      // >=   ge
 CheckEquals('1', fC.Calc('"0" < "1"'), 'fails on "0" < "1"');
 CheckEquals('0', fC.Calc('75>122'), 'fails on 75>122');
 CheckEquals('1', fC.Calc('11>=11'), 'fails on 11>=11');
 CheckEquals('0', fC.Calc('11>=88'), 'fails on 11>=88');
 CheckEquals('0', fC.Calc('"0123" <= "012"'), 'fails on "0123" <= "012"');

 FreeAndNil(fC);
end;

procedure TTestWelBasic.TestMath;
begin
 // test Math functions with number arguments only. this is a light weight tests
 fC := TWel.Create;

 CheckEquals('0.564642473395035', fC.Calc('sin(0.6)'), 'fails on sin(0.6)');
 CheckEquals('0.955336489125606', fC.Calc('cos(0.3)'), 'fails on cos(0.3)');
 CheckEquals('1.73205080756888', fC.Calc('a:=sqrt(3)'), 'fails on a:=sqrt(3)');
 CheckEquals('2', fC.Calc('round(a)'), 'fails on round(a)');
 CheckEquals('1.73205', fC.Calc('round(a,5)'), 'fails on round(a,5)');
 CheckEquals('0.73205080756888', fC.Calc('frac(a)'), 'fails on frac(a)');
 CheckEquals('1', fC.Calc('trunc(a)'), 'fails on trunc(a)');
 CheckEquals('8.6602540378444', fC.Calc('abs(-5*a)'), 'fails on abs(-5*a)');

 FreeAndNil(fC);
end;

procedure TTestWelBasic.TestAbs;
begin
 fC := TWel.Create;

 CheckEquals('1', fC.Calc('abs(1)'), 'fails on abs(1)');
 CheckEquals('1.23456', fC.Calc('abs(1.23456)'), 'fails on abs(1.23456)');
 CheckEquals('9', fC.Calc('abs(-9)'), 'fails on abs(-9)');
 CheckEquals('9.87654', fC.Calc('abs(-9.87654)'), 'fails on abs(-9.87654)');

 FreeAndNil(fC);
end;

procedure TTestWelBasic.TestBrackets;
begin
  CheckEquals('8', fC.Calc('(2+2)*2'), 'fails on "(2+2)*2"');
  CheckEquals('69', fC.Calc('1+2*3+4*5+6*7'), 'fails on "(2+2)*2"');
end;

procedure TTestWelBasic.TestArithmetic;
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

procedure TTestWelBasic.TestArrayCreate;
begin
  fC := TWel.Create;
  CheckEquals('[1,2,4,6]',fC.Calc('A:=[1 2 4 6]'),'fails on "A:=[1 2 4 6]"');
  CheckEquals('[1,2,4,6]',fC.Calc('A:=[1,2,4,6]'),'fails on "A:=[1,2,4,6]"');
  CheckEquals('[1,2,4,6]',fC.Calc('A:=[1, 2, 4, 6]'),'fails on "A:=[1, 2, 4, 6]"');
  CheckEquals('[1,2,4,6]',fC.Calc('A:=[1 2,4 6]'),'fails on "A:=[1 2,4 6]"');
  CheckEquals('[1,2,4,6]',fC.Calc('A:=[1, 2, 4, 6, ]'),'fails on "A:=[1 2 4 6, ]"');
  CheckEquals('[1,[1,2,3],4,6]',fC.Calc('A:=[1, [1 2 3], 4, 6, ]'),'fails on "A:=[1 2 4 6, ]"');
  CheckEquals('[1,[1,2,3],4,"cat"]',fC.Calc('A:=[1 [1 2,3,],  4"cat"]'),'fails on "A:=[1 [1 2,3,],  4"cat"]"');

  fC.Free;
end;



{ TTestWelComplex }

procedure TTestWelComplex.SetUp;
begin
  inherited;
  //
end;

procedure TTestWelComplex.TearDown;
begin
  inherited;
  //
end;




initialization
  TestFramework.RegisterTest(TTestWelBasic.Suite);
  TestFramework.RegisterTest(TTestWelComplex.Suite);

end.
