unit WelTests;

interface

uses
  TestFrameWork, Wel;

type
  TTestWelBasic = class(TTestCase)
    fC: TWel;
  private
    procedure TestDivideByZero;
    procedure TestExistsNoParams;
    procedure TestExistsMoreParams;
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
    procedure TestArrayCreate;
    procedure TestArrayGet;
    procedure TestAggregate;
    procedure TestAlign;
    procedure TestIn;
    procedure TestExists;
  end;

  TTestWelComplex = class(TTestCase)
    fC: TWel;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBrackets;
    procedure TestOperatorPriority;
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
  //CheckEquals('256', fC.Calc('2^2^3'), 'fails on 2^2^4');  //

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

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestArrayGet;
begin
  fC := TWel.Create;

  CheckEquals('[1,2,[4,6,7,[8,9]],10]',fC.Calc('A:=[1,2,[4,6,7,[8,9]],10]'),'fails on A:=[1,2,[4,6,7,[8,9]],10]');
  CheckEquals('1',fC.Calc('A[0]'),'fails on A[0]');
  CheckEquals('2',fC.Calc('A[1]'),'fails on A[1]');
  CheckEquals('[4,6,7,[8,9]]',fC.Calc('A[2]'),'fails on A[2]');
  CheckEquals('10',fC.Calc('A[3]'),'fails on A[3]');
  CheckEquals('nil',fC.Calc('A[4]'),'fails on A[4]');
  CheckEquals('4',fC.Calc('A[2,0]'),'fails on A[2,0]');
  CheckEquals('6',fC.Calc('A[2,1]'),'fails on A[2,1]');
  CheckEquals('7',fC.Calc('A[2,2]'),'fails on A[2,2]');
  CheckEquals('[8,9]',fC.Calc('A[2,3]'),'fails on A[2,3]');
  CheckEquals('nil',fC.Calc('A[2,4]'),'fails on A[2,4]');
  CheckEquals('8',fC.Calc('A[2,3,0]'),'fails on A[2,3,0]');
  CheckEquals('9',fC.Calc('A[2,3,1]'),'fails on A[2,3,1]');
  CheckEquals('nil',fC.Calc('A[2,3,2]'),'fails on A[2,3,2]');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestAggregate;
begin
  // aggregate functions: min, max, sum and avg, this functions accept variable count
  // of argumens - number or array with number elements
  fC := TWel.Create;

  CheckEquals('1', fC.Calc('min(1,2,3)'), 'fails on min(1,2,3)');
  CheckEquals('0.1', fC.Calc('min(0.3,0.2,0.1)'), 'fails on min(0.3,0.2,0.1)');
  CheckEquals('3', fC.Calc('max(1,[2,3],0)'), 'fails on max(1,[2,3],0)');
  CheckEquals('6', fC.Calc('max(1,[2,[3,4,5],6]'), 'fails on max(1,[2,[3,4,5],6],0)');
  CheckEquals('6', fC.Calc('sum(2,2,[2])'), 'fails on sum(2,2,[2])');
  CheckEquals('2', fC.Calc('avg(2,2,[])'), 'fails on avg(2,2,[])');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestAlign;
begin
  // align is a function to round number value to a nearest of array elemets
  fC := TWel.Create;

  CheckEquals('0', fC.Calc('align(0.1, [0,0.5,1])'), 'fails on align(0.1, [0,0.5,1])');
  CheckEquals('0', fC.Calc('align(0.5, [0,1])'), 'fails on align(0.5, [0,1])');
  CheckEquals('1', fC.Calc('align(0.51, [0,1])'), 'fails on align(0.51, [0,1])');
  CheckEquals('99.9', fC.Calc('align(99, [98,99.9])'), 'fails on align(99, [98,99.9])');
  CheckEquals('0', fC.Calc('align(-1, [5,9,-0,3])'), 'fails on align(-1, [5,9,-0,3])');
  CheckEquals('-10', fC.Calc('align(-9, [10,-10,+5,1-9])'), 'fails on align(-9, [10,-10,+5,1-9])');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestIn;
begin
  // in( functions check presence first argument value at second argument array
  fC := TWel.Create;

  CheckEquals('0', fC.Calc('in(99,[1,2,3])'), 'fails on in(99,[1,2,3])');
  CheckEquals('1', fC.Calc('in(99,[1,2,3,99])'), 'fails on in(99,[1,2,3,99])');
  CheckEquals('1', fC.Calc('in(0.1,[0.1,0.2,0.3])'), 'fails on in(0.1,[0.1,0.2,0.3])');
  CheckEquals('1', fC.Calc('in("world",["hello", "world"])'), 'fails on in("world",["hello", "world"])');
  CheckEquals('0', fC.Calc('in(42,[1,2,3,[5,42]])'), 'fails on in(42,[1,2,3,[5,42]])');
  CheckEquals('0', fC.Calc('in(0.07,[])'), 'fails on in(0.07,[])');

  FreeAndNil(fC);
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


procedure TTestWelComplex.TestBrackets;
begin
  fC := TWel.Create;

  CheckEquals('1.125',fC.Calc('1+2*3/4^2+5-6*7/8'),'fails on 1+2*3/4^2+5-6*7/8');
  CheckEquals('0.3125',fC.Calc('(1+2)*3/4^2+5-6*7/8'),'fails on (1+2)*3/4^2+5-6*7/8');
  CheckEquals('1.125',fC.Calc('1+(2*3/4^2+5)-6*7/8'),'fails on 1+(2*3/4^2+5)-6*7/8');
  CheckEquals('2.3125',fC.Calc('1+2*3/4^(2+5-6)*7/8'),'fails on 1+2*3/4^(2+5-6)*7/8');
  CheckEquals('1.125',fC.Calc('1+2*3/4^2+5-(6*7/8)'),'fails on 1+2*3/4^2+5-(6*7/8)');
  CheckEquals('1.875',fC.Calc('(1+2*(3/4)^2+5)-6*7/8'),'fails on (1+2*(3/4)^2+5)-6*7/8');
  CheckEquals('1.39669421487603',fC.Calc('1+2*3/(4^2+((5-6)*7)/8)'),'fails on 1+2*3/(4^2+((5-6)*7)/8)');
  CheckEquals('2.80338347992535',fC.Calc('(1+(2*3)/4)^(2+(5-6)*7/8)'),'fails on (1+(2*3)/4)^(2+(5-6)*7/8)');

  FreeAndNil(fC);
end;

procedure TTestWelComplex.TestOperatorPriority;
begin
  // we use classic operators priority
  // calc from left to right
  // operator calculation order:
  // ^           power, we calc it from left to right, then 4^3^2 = (4^3)^2 = 4096,
  //             some math calculation systems and programming languages have differents order of
  //             power calculation. we do it also as in Matlab
  // * / \ %     division operators
  // + -         ariphmetic operators
  // &           string concatenation
  // <>=         comparison operations
  fC := TWel.Create;

  CheckEquals('"2.55"',fC.Calc('1+2*3/4&"5"'),'fails on 1+2*3/4&"5"');
  CheckEquals('4096',fC.Calc('4^3^2'),'fails on 4^3^2');

  FreeAndNil(fC);
end;

procedure TTestWelBasic.TestExists;
begin
  // exists( is a spec function, if it exists in calculation tree unexpected variables
  // do not rise 'Unknown variable' exception

  fC := TWel.Create;

  CheckException(TestExistsNoParams, EWelException, 'falis on eists( without params, it must raise exceprion');
  CheckException(TestExistsMoreParams, EWelException, 'falis on eists( with more params, it must raise exceprion');

  CheckEquals('1',fC.Calc('exists(1)'),'fails on exists(1)');
  CheckEquals('1',fC.Calc('exists(3.14)'),'fails on exists(3.14)');
  CheckEquals('1',fC.Calc('exists("test")'),'fails on exists("test")');
  CheckEquals('1',fC.Calc('exists([])'),'fails on exists([])');
  fC.Calc('a:=1');
  CheckEquals('1',fC.Calc('exists(a)'),'fails on exists(a)');
  CheckEquals('0',fC.Calc('exists(b)'),'fails on exists(b)');
  CheckEquals('0',fC.Calc('b:=exists(b)'),'fails on b:=exists(b)');
  CheckEquals('1',fC.Calc('if(exists(a),a,"err")'),'fails on if(exists(a),a,"err")');
  CheckEquals('"err"',fC.Calc('if(exists(c),c,"err")'),'fails on if(exists(c),c,"err")');

  FreeAndNil(fC);

end;

procedure TTestWelBasic.TestExistsNoParams;
begin
  fC.Calc('exists()')
end;

procedure TTestWelBasic.TestExistsMoreParams;
begin
  fC.Calc('exists(1,2)')
end;

initialization
  TestFramework.RegisterTest(TTestWelBasic.Suite);
  TestFramework.RegisterTest(TTestWelComplex.Suite);

end.
