unit wel;

interface


uses
  SysUtils, Classes, Math,
  Windows, Messages, Graphics, Controls, Forms, Dialogs, ExtCtrls;

type

  TStack = class
    fData: TStringList;
  private
    function GetResult: string;
    function GetCount: Integer;
  public
    constructor Create();
    destructor Free;
    procedure Push(Value: string);
    function Pop(): string;
    function Peek(): string;
    property Count: Integer read GetCount;
    property Result: string read GetResult;
  end;

  EWelException = Exception;

  TValType = (vtNone, vtString, vtInteger, vtFloat, vtArray, vtVar, vtFunction);

  TMapFunc = function(A, B: string): string of object;

  TWel = class
    fE: string;
    fErr : string;
    fLfac : Integer; // last functiona arguments count
    fO, fV: TStack;
    fVars : TStringList;
    function FindUserFunc(Func: string; ArgCount: Integer; ErrorIfNotFount: Boolean): Integer;
  private
    function readString(str: string; var i : Integer): string;
    function readNumber(str: string; var i : Integer): string;
    //
    function CanCalc(Op: string): Boolean;
    procedure CalcStep();
    //
    function GetValType(Val: string): TValType;
    function UserFunc(Name: string; ArgCount: Integer): string;
    function Func(Name: string): string;
    function Map(Arr, B: string; Func: TMapFunc): string;
    //
    function _add(A,B: string): string;          //   +
    function _addx(A,B: string): string;
    function _sub(A,B: string): string;          //   -
    function _subx(A,B: string): string;
    function _multiply(A,B: string): string;     //   *
    function _divide(A,B: string): string;       //   /
    function _dividex(A, B: string): string;
    function _div(A,B: string): string;          //   \
    function _divx(A,B: string): string;
    function _mod(A,B: string): string;          //   &
    function _modx(A,B: string): string;
    function _concat(A,B: string): string;       //   &
    function _power(A,B: string): string;        //   ^
    function _eq(A, B: string): string;          //   =
    function _ne(A, B: string): string;          //   <>
    function _lt(A, B: string): string;          //   <
    function _gt(A, B: string): string;          //   >
    function _le(A, B: string): string;          //   <=
    function _ge(A, B: string): string;          //   >=
    function _len(A: string): string;
    function _map(Arr, Func: string): string;


  public
    constructor Create();
    destructor Free;
    function GetArrLen(Arr: string): Integer;
    function GetArrVal(Arr: string; n: Integer): string;
    function SetArrVal(Arr, NewVal: string; n: Integer): string;
    function GetArrValR(Arr: string; inx: array of Integer): string;
    function SetArrValR(Arr, NewVal: string; inx: array of Integer): string;    
    function DoWork(): string;
    function Calc(Expr: string): string; // main method
  end;

implementation

{ TStack }

constructor TStack.Create;
begin
 fData := TStringList.Create;
end;

destructor TStack.Free;
begin
 fData.Free;
end;

function TStack.GetCount: Integer;
begin
 Result := fData.Count;
end;

function TStack.GetResult: string;
begin
 Result := fData[0];
end;

function TStack.Peek: string;
begin
 Result := fData[fData.Count-1];
end;

function TStack.Pop: string;
begin
 if fData.Count > 0 then
 begin
   Result := fData[fData.Count-1];
   fData.Delete(fData.Count-1);
 end;  
end;

procedure TStack.Push(Value: string);
begin
 fData.Add(Value);
end;

{ TCalc }

constructor TWel.Create();
begin
 fO := TStack.Create;
 fV := TStack.Create;
 fVars := TStringList.Create;
 //fVars.Add('a=1');
// fE := Expr;
 fErr := '';
end;

destructor TWel.Free;
begin
 fO.Free;
 fV.Free;
 fVars.Free;
end;

function TWel.Calc(Expr: string): string;
var
  i, j : Integer;
  v : TValType;
  leftVar, rigthExpr : string;
  r,a : string;
  inx : array of Integer;
begin
 i := Pos(':=', Expr);   // left var can't contain strings or expression
 if i > 0 then
 begin
   leftVar := Trim(Copy(Expr, 1, i-1));
   rigthExpr := Trim(Copy(Expr, i+2, Length(Expr)-i-1));
   // check type of leftVar: variable, array element or function
   i := 1;
   if not (leftVar[i] in ['a'..'z', 'A'..'Z', '@']) then
     raise EWelException.CreateFmt('Illegal variable name ''%s'' on left part of assignment operator',
       [leftVar]);
   v := vtVar;
   while (i <= Length(leftVar)) and (leftVar[i] in ['a'..'z', 'A'..'Z','0'..'9','.','_', '(', '[']) do
   begin
     case leftVar[i] of
       '(' : begin    // this is a function
               v := vtFunction;
               Break;
             end;
       '[' : begin     // this is a array element set
               v := vtArray;
               Break;
             end;
     end;
     Inc(i);
   end;
   case v of
     vtVar : begin
               fE := '('+rigthExpr+')';
               r := DoWork();
               fV.fData.Text := ''; fO.fData.Text := '';
               fVars.Values[leftVar] := r;
               if r = '' then         
               begin
                 if leftVar[1] <> '@' then fVars.Delete(fVars.IndexOfName(leftVar))   // delete variable
                 else for i := fVars.Count-1 downto 0 do
                   if Copy(fVars.Names[i], 1, Length(leftVar)) = leftVar then fVars.Delete(i);
               end;
                 for i := 0 to fVars.Count-1 do
               Result := r;
             end;
     vtFunction : begin                     // define user function
               // check arguments, it is must be a variables only
               for j := i+1 to Length(leftVar)-i do
                 if not (leftVar[j] in [' ', 'a'..'z', 'A'..'Z','0'..'9','.','_', ',']) then
                   raise EWelException.CreateFmt('On user func "%s" define arguments must containe arguments only, without expression', [Copy(leftVar, 1, Pos('(', leftVar)-1)]);
               r := LowerCase(Copy(leftVar, 1, i));
               a := Trim(Copy(leftVar, i+1, Length(leftVar)-i-1));
               i := 1;
               if a <> '' then         // calc function arguments count
               begin
                 j := 1;
                 for i := 1 to Length(a) do
                   if a[i] = ',' then Inc(j);
               end else j := 0;
               i := FindUserFunc(r, j, False);
               r := LowerCase(Copy(leftVar, 1, i)) + Copy(leftVar, i+1, Length(leftVar)-i);
               if i = -1 then
                 fVars.Values['@'+r] := rigthExpr
               else
                 fVars[i] := '@'+r+'='+rigthExpr;
               Result := '@'+r;
             end;
     vtArray : begin
               // calc array indexes
               fE := '('+Copy(Expr, i+1, Length(leftVar)-i-1)+')';
               leftVar := Copy(leftVar, 1, i-1);
               r := DoWork();
               fV.fData.Text := ''; fO.fData.Text := '';
               SetLength(inx, fV.Count+1);
               try
                 inx[fV.Count] := StrToInt(r);
                 while fV.Count > 0 do
                   inx[fV.Count] := StrToInt(fV.Pop());
               except
                 raise EWelException.Create('Array index must be integer, set');
               end;
               r := fVars.Values[leftVar];
                 if GetValType(r) <> vtArray then r := '[0]';
               fE := '('+rigthExpr+')';
               r := SetArrValR(r, DoWork(), inx);
               fVars.Values[leftVar] := r;
               Result := r;
               fV.fData.Text := ''; fO.fData.Text := '';  
             end;
   end;
 end else
 begin
   fE := '('+Expr+')';
   Result := DoWork;
 end;
end;

function TWel.readString(str: string; var i : Integer): string;
begin
 Result := str[i];
 Inc(i);
 while (i <= Length(str)) do
 begin
   Result := Result + str[i];
   if (str[i] = '"') then                  // double quotes in string is a one quote
     if (i < Length(str)-1) and (str[i+1] = '"') then Inc(i) else Break;
   Inc(i);
 end;
 Inc(i);
end;

function TWel.readNumber(str: string; var i: Integer): string;
var
  dotFlag : Boolean;
begin
 Result := '';
 dotFlag := False;
 while (i <= Length(str)) and (str[i] in ['0'..'9','.']) do
 begin
   if str[i] = '.' then
   begin
     if dotFlag then raise EWelException.CreateFmt('Invalid number at char %d, double dot', [i-1]);
     dotFlag := True;
   end;
   Result := Result + str[i];
   Inc(i);
 end;
end;

function TWel.DoWork(): string;
var
  i, j, d : Integer;
  a, p : string;
  pv : Boolean;
  inx : array of Integer;
  c : TWel;
begin
  if Trim(fE) = '' then begin Result := ''; Exit; end;
  i := 1;
  while i <= Length(fE) do
  begin
    if (fE[i] = '/') and (Length(fE) > i) and (fE[i+1] = '/') then
    begin
      fV.fData.Clear;
      fO.fData.Clear;
      Result := '';
      Exit;                  // comment
    end;
    case fE[i] of
      // values or variables
      '"' : begin                                                          // this is a string value
                a := readString(fE, i);
                fV.Push(a);
                pv := True;
            end;
      '0'..'9' : begin                                                           // this is a number
                a := readNumber(fE, i);
                fV.Push(a);
                pv := True;
                 end;
      // operators
      ')' : begin
              while (fO.Count > 0) and (fO.Peek() <> '(') do
                CalcStep();
              fO.Pop();
              Inc(i);
            end;
      '[' : begin                   // this is a array value
              d := 0;  j := i;
              while i < Length(fE) do
                case fE[i] of
                  '"' : readString(fE, i);
                  '[' : begin Inc(d);  Inc(i); end;
                  ']' : begin
                          Dec(d);
                          Inc(i);
                          if d = 0 then
                          begin               
                            c := TWel.Create;
                            c.fVars.Text := fVars.Text;
                            c.fE := '('+Copy(fE, j+1, i-j-2)+')';
                            a := c.DoWork();   // TODO: DoWork
                            while c.fV.Count > 0 do
                              a := c.fV.Pop()+ ',' + a;
                            c.Free;
                            fV.Push('['+a+']');
                            pv := True;
                            Break;
                          end;
                        end; 
                else Inc(i);
                end;
            end;
      'a'..'z', 'A'..'Z' : begin        // function or variable
                              a := fE[i];
                              Inc(i);
                              while (i <= Length(fE)) and (fE[i] in ['a'..'z', 'A'..'Z','0'..'9','.','_']) do
                              begin
                                a := a + fE[i];
                                Inc(i);
                              end;
                              if fE[i] = '(' then                       // this is a function
                              begin
                                while CanCalc(fE[i]) do
                                  CalcStep();
                                fLfac := fV.Count;
                                fO.Push(a + '(');
                                Inc(i);
                              end else if fE[i] = '[' then               // this is a array variabe
                                begin
                                  d := 0;  j := i;
                                  while i < Length(fE) do
                                    case fE[i] of
                                      '"' : readString(fE, i);
                                      '[' : begin Inc(d);  Inc(i); end;
                                      ']' : begin
                                              Dec(d);
                                              Inc(i);
                                              if d = 0 then
                                              begin
                                                fE := '('+Copy(fE, j+1, i-j-2)+')';
                                                p := DoWork();
                                                SetLength(inx, fV.Count+1);
                                                try
                                                  inx[fV.Count] := StrToInt(p);
                                                  while fV.Count > 0 do
                                                    begin
                                                      p := fV.Pop();
                                                      inx[fV.Count] := StrToInt(p);
                                                    end;
                                                except
                                                  raise EWelException.Create('Array index must be integer, get');
                                                end;
                                                fV.Push(GetArrValR(fVars.Values[a], inx));
                                              end;
                                            end;
                                      else Inc(i);
                                    end;
                                end
                              else begin                           // this is a variable or function
                                if LowerCase(a) = 'nil' then begin fV.Push(''); Break; end;
                                if LowerCase(a) = 'true' then begin fV.Push('1'); Break; end;
                                if LowerCase(a) = 'false' then begin fV.Push('0'); Break; end;
                                if FindUserFunc(a, -1, False) > -1 then
                                begin
                                  fV.Push('@'+a);
                                  pv := True;
                                end else
                                if fVars.Values[a] <> '' then
                                begin
                                  fV.Push(fVars.Values[a]);
                                  pv := True;
                                end else
                                  raise EWelException.CreateFmt('Unknown variable ''%s''', [a]);
                              end;
                           end;
      '+','-','*','/','\','%','&','^','(',',','=','<','>' : begin                                // one symbol operators
                                      if not pv and ((fE[i] = '+') or (fE[i] = '-')) then
                                      begin
                                        fV.Push('0');                        // zero element for sub
                                        pv := True;
                                      end else
                                      while CanCalc(fE[i]) do
                                        CalcStep();
                                      if ((fE[i] = '<') and (fE[i+1] = '>')) or
                                         ((fE[i] = '<') and (fE[i+1] = '=')) or
                                         ((fE[i] = '>') and (fE[i+1] = '=')) then
                                           begin
                                             fO.Push(fE[i]+fE[i+1]);
                                             Inc(i);
                                           end  
                                      else if fE[i] <> ',' then fO.Push(fE[i]);
                                      p := fE[i];
                                      pv := False;
                                      Inc(i);
                                    end;
      else
        Inc(i);
    end;
  end;
  Result := fV.Pop();
  //if fV.Count > 0 then raise
  //  ECalcException.Create('Wrong expression') // length must be 1, else raise error
end;

procedure TWel.CalcStep;
var
  A, B : string;
  W : string;
begin
  W := fO.Pop();
  OutputDebugString(PChar(W));
  if W[Length(W)] = '(' then
    fV.Push( Func(W) )
  else begin
    B := fV.Pop();
    A := fV.Pop();
    if W = '+' then fV.Push( _add(A, B) ) else
    if W = '-' then fV.Push( _sub(A, B) ) else
    if W = '*' then fV.Push( _multiply(A, B) ) else
    if W = '/' then fV.Push( _divide(A, B) ) else
    if W = '\' then fV.Push( _div(A, B) ) else
    if W = '%' then fV.Push( _mod(A, B) ) else
    if W = '&' then fV.Push( _concat(A, B) ) else
    if W = '^' then fV.Push( _power(A, B) ) else
    if W = '=' then fV.Push( _eq(A, B) ) else
    if W = '<>' then fV.Push( _ne(A, B) ) else
    if W = '<' then fV.Push( _lt(A, B) ) else
    if W = '>' then fV.Push( _gt(A, B) ) else
    if W = '<=' then fV.Push( _le(A, B) ) else
    if W = '>=' then fV.Push( _ge(A, B) ) else
  end;
end;

function TWel.CanCalc(Op: string): Boolean;
  function GetPriority(Op: string): Integer;
  begin
    if Op = '(' then Result := -1
    else if (Op = '^') then Result := 1
    else if (Op = '*') or (Op = '/') then Result := 2
    else if (Op = '\') or (Op = '%') then Result := 2
    else if (Op = '+') or (Op = '-') then Result := 3
    else if (Op = '&') then Result := 4
    else if (Op = '=') or (Op = '<>') or (Op = '<') or (Op = '>') or (Op = '<=') or (Op = '>=') then Result := 5
    else if (Op = ',') then Result := 6
    else if (Op[Length(Op)] = '(') then Result := 7           // func
    else fErr := 'Invalid operand';
  end;
var
  p1, p2: Integer;
begin
 Result := False;
 if fO.Count = 0 then Exit;
 p1 := GetPriority(Op);
 p2 := GetPriority(fO.Peek());
 Result := (p1 >= 0) and (p2 >= 0) and (p1 > p2);
end;

function TWel.GetValType(Val: string): TValType;
var
  i : Integer;
  f : Double;
begin
 if Length(Val) = 0 then Result := vtNone
 else if Val[1] = '"' then Result := vtString
 else if Val[1] = '[' then Result := vtArray
 else if Val[1] = '@' then Result := vtFunction
 else if TryStrToInt(Val, i) then Result := vtInteger
 else if TryStrToFloat(Val, f) then Result := vtFloat
 else Result := vtNone;
end;

function TWel.GetArrLen(Arr: string): Integer;
var
  i, d, p : Integer;
begin
 d := 0;  p := 0;  i := 1;
 if Trim(Copy(Arr, 2, Length(Arr)-2)) = '' then begin Result := 0; Exit; end;  
 while i <= Length(Arr) do
 begin
   case Arr[i] of
     '"' : begin readString(Arr, i);  Dec(i); end;
     ',' : if d = 1 then Inc(p);
     '[' : Inc(d);
     ']' : Dec(d);
   end;
   Inc(i);
 end;
 Result := p+1;
end;

function TWel.GetArrVal(Arr: string; n: Integer): string;
var
  i, j, d, p : Integer;
begin
 d := 0;  p := 0;  i := 1;  j := 0;
 Result := 'nil';
 while i <= Length(Arr) do
 begin
   case Arr[i] of
     '"' : begin readString(Arr, i);  Dec(i); end;
     ',' : if d = 1 then Inc(p);
     '[' : Inc(d);
     ']' : Dec(d);
   end;
   if (d = 1) and (p = n) and (j = 0) then j := i+1;
   if ((d = 1) and (p > n)) or (i = Length(Arr)) and (j > 0) then
   begin
     Result := Copy(Arr, j, i-j);
     Break;
   end;
   Inc(i);
 end;
end;

function TWel.GetArrValR(Arr: string; inx: array of Integer): string;
var
  i, d : Integer;
  ind : array of Integer;
  e : string;
begin
 if Length(inx) = 1 then
   Result := GetArrVal(Arr, inx[0])
 else begin
   e := GetArrVal(Arr, inx[0]);
   SetLength(ind, Length(inx)-1);
   for i := 0 to Length(inx)-2 do ind[i] := inx[i+1];
   Result := GetArrValR(e, ind);
 end;
end;

function TWel.SetArrVal(Arr, NewVal: string; n: Integer): string;
var
  i, j, d, p : Integer;
  s : string;
begin
 j := GetArrLen(Arr);
 s := '';
 for i := j to n do
   s := s+',0';
 if n >= j then Insert(s, Arr, Length(Arr));
 d := 0;  p := 0;  i := 1;  j := 0;
 while i <= Length(Arr) do
 begin
   case Arr[i] of
     '"' : begin readString(Arr, i);  Dec(i); end;
     ',' : if d = 1 then Inc(p);
     '[' : Inc(d);
     ']' : Dec(d);
   end;
   if (d = 1) and (p = n) and (j = 0) then j := i+1;
   if ((d = 1) and (p > n)) or (i = Length(Arr)) and (j > 0) then
   begin
     Result := Arr;
     Delete(Result, j, i-j);
     Insert(NewVal, Result, j);
     Break;
   end;
   Inc(i);
 end;
end;

function TWel.SetArrValR(Arr, NewVal: string;
  inx: array of Integer): string;
var
  i, d : Integer;
  ind : array of Integer;
  e : string;
begin
 if Length(inx) = 1 then
   Result := SetArrVal(Arr, NewVal, inx[0])
 else begin
   e := GetArrVal(Arr, inx[0]);
   SetLength(ind, Length(inx)-1);
   for i := 0 to Length(inx)-2 do ind[i] := inx[i+1];
   if GetValType(e) <> vtArray then e := '[0]';
   Result := SetArrVal(Arr, SetArrValR(e, NewVal, ind), inx[0])
 end;
end;

function ArrEq(A, B: array of Integer): Boolean;
var
  l1, l2, i: Integer;
begin
 // if length(A) < length(B) compare first length(A) elements only
 Result := True;
 for i := 0 to Length(A)-1 do
   if A[i] <> B[i] then
   begin
     Result := False;
     Exit;
   end;
end;

function TWel.FindUserFunc(Func: string; ArgCount: Integer; ErrorIfNotFount: Boolean): Integer;
var
  i, j, p, n : Integer;
  a, b : string;
  f : Boolean;
begin
 Result := -1;
 f := false;
 a := '@' + LowerCase(Func);
 for i := 0 to fVars.Count-1 do
 if Copy(LowerCase(fVars.Names[i]), 1, Length(a)) = a then      // function candidat, check arguments count
 begin
   if ArgCount = -1 then begin Result := i; Exit; end;
   f := True;
   p := Pos('(', fVars.Names[i]);
   b := Trim(Copy(fVars.Names[i], p+1, Pos(')', fVars.Names[i])-p-1));
   n := 1;
   for j := 1 to Length(b) do
     if b[j] = ',' then Inc(n);
   if b = '' then n := 0;     // zero arguments
   if n = ArgCount then
   begin
     Result := i;
     Exit;
   end;
 end;
 if ErrorIfNotFount then  // error raising
   if f then
     raise EWelException.CreateFmt('Wrong arguments count in ''%s'' function', [Func])
   else
     raise EWelException.CreateFmt('Undefined function ''%s''', [Func]);
end;

function TWel.UserFunc(Name: string; ArgCount: Integer): string;
var
  i, j, p : Integer;
  a, b: string;
  c : TWel;
begin
  // try user function call
  i := FindUserFunc(Name, ArgCount, False);
  if i > -1 then
  begin
    p := Pos('(', fVars.Names[i]);
    a := Trim(Copy(fVars.Names[i], p+1, Pos(')', fVars.Names[i])-p-1));
    c := TWel.Create();
    c.fVars.Text := fVars.Text;
    // set arguments into
    b := '';  j := Length(a);
    while j > 0 do
    begin
      if a[j] = ',' then
      begin
        c.fVars.Values[Trim(b)] := fV.Pop();
        Dec(j);
        b := a[j] ;
      end else b := a[j] + b;
      Dec(j);
    end;
    if Trim(b) <> '' then c.fVars.Values[Trim(b)] := fV.Pop();
    Result := c.Calc(fVars.ValueFromIndex[i]);
    c.Free;
  end;
end;

function TWel.Func(Name: string): string;
var
  n : string;
  a : Integer;
  v1,v2,v3 : string;
begin
 n := LowerCase(Name);
 a := fV.Count - fLfac;
 Result := '';

 // functions with variable parameters count
 if n = 'round(' then
   if a = 1 then Result := FloatToStr(Round(StrToFloat(fV.Pop()))) else
   if a = 2 then
   begin
     v2 := fV.Pop();  // in pascal func arguments compilations order are not defined!!!!
     v1 := fV.Pop();
     Result := FloatToStr(RoundTo(StrToFloat(v1), -1*StrToInt(v2)));
   end else  raise EWelException.CreateFmt('Invalid parameters count in %s function', [Name]);
 if Result <> '' then Exit;

 // 1 argument functions
 if (n = 'sin(') or (n = 'cos(') or (n = 'sqrt(') or (n = 'round(') or (n = 'frac(') or
    (n = 'trunc(') or (n = 'len(') or (n = 'abs(')  then
 begin
   if a < 1 then raise EWelException.CreateFmt('Not enough actual parameters in %s function', [Name]);
   if a > 1 then raise EWelException.CreateFmt('Too many actual parameters in %s function', [Name]);
   try                             // functions from Math
     if n = 'sin(' then Result := FloatToStr(Sin(StrToFloat(fV.Pop()))) else
     if n = 'cos(' then Result := FloatToStr(Cos(StrToFloat(fV.Pop()))) else
     if n = 'sqrt(' then Result := FloatToStr(Sqrt(StrToFloat(fV.Pop()))) else
     if n = 'frac(' then Result := FloatToStr(Frac(StrToFloat(fV.Pop()))) else
     if n = 'trunc(' then Result := FloatToStr(Trunc(StrToFloat(fV.Pop()))) else
     if n = 'abs(' then Result := FloatToStr(Abs(StrToFloat(fV.Pop())))
   except
     raise EWelException.Create(Name + ' function argument must be a number');
   end;
     if n = 'len(' then Result := _len(fV.Pop());
 end;
 if Result <> '' then Exit;

 // 2 arguments functions
 if (n = 'plus(') or (n = 'map(')  then
 begin
   if (fV.Count - fLfac) < 2 then raise EWelException.CreateFmt('Not enough actual parameters in %s function', [Name]);
   if (fV.Count - fLfac) > 2 then raise EWelException.CreateFmt('Too many actual parameters in %s function', [Name]);
   v2 := fV.Pop();
   v1 := fV.Pop();
   if Name = 'plus(' then Result := _add(v1, v2) else
   if Name = 'map(' then Result := _map(v1, v2);
 end;
 if Result <> '' then Exit;

 // 3 arguments functions
 if (n = 'if(') then
 begin
   if (fV.Count - fLfac) < 3 then raise EWelException.CreateFmt('Not enough actual parameters in %s function', [Name]);
   if (fV.Count - fLfac) > 3 then raise EWelException.CreateFmt('Too many actual parameters in %s function', [Name]);
   v3 := fV.Pop();
   v2 := fV.Pop();
   v1 := fV.Pop();
   if Name = 'if(' then if v1 = '1' then Result := v2 else Result := v3;
 end;
 if Result <> '' then Exit;                                             

 // try to find in user function
 if FindUserFunc(Name, fV.Count - fLfac, False) = -1 then
   raise EWelException.CreateFmt('Function %s is undefined', [Name])
 else Result := UserFunc(Name, fV.Count - fLfac);
end;

function TWel._add(A, B: string): string;
var
  ta, tb : TValType;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then     // num+num
   Result := FloatToStr(StrToFloat(A) + StrToFloat(B))
 else if ((ta = vtInteger) or (ta = vtFloat)) and (tb = vtString) then                     // num+str
   Result := '"' + A + Copy(B, 2, Length(B)-2) + '"'
 else if (ta = vtString) and ((tb = vtInteger)) or (tb = vtFloat) then                     // str+num
   Result := '"' + Copy(A, 2, Length(A)-2) + B + '"'
 else if (ta = vtString) and (tb = vtString) then                                          // str+str
   Result := '"' + Copy(A, 2, Length(A)-2) + Copy(B, 2, Length(B)-2) + '"'
 else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat) or (tb = vtString)) then
   begin
     p := _add;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat) or (ta = vtString)) and  (tb = vtArray) then
   begin
     p := _addx;
     Result := Map(B, A, p);
   end
 else
   raise EWelException.Create('Unsupported types of "+" operator');
end;

function TWel._addx(A, B: string): string;
begin
  Result := _add(B, A);
end;

function TWel._sub(A, B: string): string;
var
  ta, tb : TValType;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then     // num+num
   Result := FloatToStr(StrToFloat(A) - StrToFloat(B))
 else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     p := _sub;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat)) and  (tb = vtArray) then
   begin                          // "-" is non commutative operator
     p := _subx;
     Result := Map(B, A, p);
   end
 else
   raise EWelException.Create('Unsupported types of "-" operator');
end;

function TWel._subx(A, B: string): string;
begin
  Result := _sub(B, A);
end;

function TWel._multiply(A, B: string): string;
var
  ta, tb : TValType;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   Result := FloatToStr(StrToFloat(A) * StrToFloat(B))
 else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     p := _multiply;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat)) and  (tb = vtArray) then
   begin
     p := _multiply;
     Result := Map(B, A, p);
   end
 else
  raise EWelException.Create('Unsupported types of "*" operator');
end;

function TWel._divide(A, B: string): string;
var
  ta, tb : TValType;
  fb : Double;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     fb := StrToFloat(B);
     if fb <> 0 then Result := FloatToStr(StrToFloat(A) / fb )
       else raise EWelException.Create('Division by zero');
   end
 else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     p := _divide;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat)) and  (tb = vtArray) then
   begin
     p := _dividex;     
     Result := Map(B, A, p);
   end
 else
   raise EWelException.Create('Division operands must be a numbers or number and array');
end;

function TWel._dividex(A, B: string): string;
begin
  Result := _divide(B, A);
end;

function TWel._div(A, B: string): string;
var                                       // integer division
  ta, tb : TValType;
  fa, fb : Double;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     fa := StrToFloat(A);
     fb := StrToFloat(B);
     Result := IntToStr( Trunc(fa/fb) );
   end
  else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     p := _div;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat)) and  (tb = vtArray) then
   begin
     p := _divx;
     Result := Map(B, A, p);
   end
 else raise EWelException.Create('Division operands must be a numbers'); // TODO: add arrays
end;

function TWel._divx(A, B: string): string;
begin
  Result := _div(B, A);
end;

function TWel._mod(A, B: string): string;
var                                       // remainder
  ta, tb : TValType;
  fa, fb : Double;
  p : TMapFunc;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     fa := StrToFloat(A);
     fb := StrToFloat(B);
     Result := FloatToStr( fa - Trunc(fa/fb)*fb );
   end
 else if (ta = vtArray) and ((tb = vtInteger) or (tb = vtFloat)) then
   begin
     p := _mod;
     Result := Map(A, B, p);
   end
 else if ((ta = vtInteger) or (ta = vtFloat)) and  (tb = vtArray) then
   begin
     p := _modx;
     Result := Map(B, A, p);
   end
 else raise EWelException.Create('Mod (remainder) operands must be a numbers'); // TODO: add arrays
end;

function TWel._modx(A, B: string): string;
begin
  Result := _mod(B, A);
end;

function TWel._concat(A, B: string): string;
var
  ta, tb : TValType;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ta = vtString then A := Copy(A, 2, Length(A)-2);
 if tb = vtString then B := Copy(B, 2, Length(B)-2);
 Result := '"' + A + B + '"';
end;

function TWel._power(A, B: string): string;
var
  ta, tb : TValType;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   Result := FloatToStr(Power(StrToFloat(A), StrToFloat(B)))
 else raise EWelException.Create('Power operagor arguments must be a numbers');
end;

function TWel._len(A: string): string;
var
  ta : TValType;
begin
 ta := GetValType(A);
 if ta = vtArray then
   Result := IntToStr(GetArrLen(A))
 else if ta = vtString then
   Result := IntToStr(Length(A)-2)
 else raise EWelException.Create('Len() function argument must be a Array or String');
end;

function TWel._map(Arr, Func: string): string;
var
  ta, tf : TValType;
  i, a : Integer;
  c : TWel;
begin
 ta := GetValType(Arr);
 tf := GetValType(Func);
 if (ta <> vtArray) or (tf <> vtFunction) then
   raise EWelException.Create('map() function first argument must be a array, second argument must be a function');
 Func := Copy(Func, 2, Length(Func)-1);
 a := 1;
 i := FindUserFunc(Func, 1, False);
 if i = -1 then
 begin
   i := FindUserFunc(Func, 2, False);
   a := 2;
 end;
 if i = -1 then raise EWelException.Create('In map() function second argument must be a '+
   'function with 1 or 2 arguments.'#13'First argument is element value, second argument is element index.');
 // call Func for all array elements
 c := TWel.Create;
 c.fVars.Text := fVars.Text;
 for i := 0 to GetArrLen(Arr)-1 do
 begin
   if a = 1 then c.fE := Func + '(' + GetArrVal(Arr, i) + ')';
   if a = 2 then c.fE := Func + '(' + GetArrVal(Arr, i) + ',' + IntToStr(i) +')';
   Arr := SetArrVal(Arr, c.DoWork, i);
 end;
 c.Free;
 Result := Arr;
end;

function TWel.Map(Arr, B: string; Func: TMapFunc): string;
var
  i : Integer;
begin
 Result := Arr;
 for i := 0 to GetArrLen(Arr)-1 do
   Result := SetArrVal(Result, Func(GetArrVal(Result, i), B), i);
end;

function TWel._eq(A, B: string): string;
begin         // =
 if A = B then Result := '1' else Result := '0';                      // <>            ne
end;                                                                  // <             lt
                                                                      // >             gt
function TWel._ne(A, B: string): string;                              // <=            le
begin         // <>                                                   // >=            ge
 if A <> B then Result := '1' else Result := '0';
end;

function TWel._lt(A, B: string): string;
var           // <
  ta, tb : TValType;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   if StrToFloat(A) < StrToFloat(B) then Result := '1' else Result := '0'
 else if (ta = vtString) and (tb = vtString) then
   if CompareStr(A, B) < 0 then Result := '1' else Result := '0'
 else raise EWelException.Create('Unsupported types in compare operator');
end;

function TWel._gt(A, B: string): string;
var           // >
  ta, tb : TValType;
begin
 ta := GetValType(A);
 tb := GetValType(B);
 if ((ta = vtInteger) or (ta = vtFloat)) and ((tb = vtInteger) or (tb = vtFloat)) then
   if StrToFloat(A) > StrToFloat(B) then Result := '1' else Result := '0'
 else if (ta = vtString) and (tb = vtString) then
   if CompareStr(A, B) > 0 then Result := '1' else Result := '0'
 else raise EWelException.Create('Unsupported types in compare operator');
end;

function TWel._le(A, B: string): string;
begin         // <=
 if (_eq(A, B) = '1') or (_lt(A, B) = '1') then Result := '1' else Result := '0';
end;

function TWel._ge(A, B: string): string;
begin         // >=
 if (_eq(A, B) = '1') or (_gt(A, B) = '1') then Result := '1' else Result := '0';
end;


end.
