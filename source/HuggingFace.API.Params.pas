unit HuggingFace.API.Params;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.Classes, System.JSON, System.SysUtils, System.Types, System.RTTI,
  REST.JsonReflect, REST.Json.Interceptors, System.Generics.Collections,
  System.Threading;

type
  /// <summary>
  /// Represents a reference to a procedure that takes a single argument of type T and returns no value.
  /// </summary>
  /// <param name="T">
  /// The type of the argument that the referenced procedure will accept.
  /// </param>
  /// <remarks>
  /// This type is useful for defining callbacks or procedures that operate on a variable of type T, allowing for more flexible and reusable code.
  /// </remarks>
  TProcRef<T> = reference to procedure(var Arg: T);

  TJSONInterceptorStringToString = class(TJSONInterceptor)
    constructor Create; reintroduce;
  protected
    RTTI: TRttiContext;
  end;

  TJSONParam = class
  private
    FJSON: TJSONObject;
    procedure SetJSON(const Value: TJSONObject);
    function GetCount: Integer;

  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const Key: string; const Value: string): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Integer): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Extended): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Boolean): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TJSONValue): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TJSONParam): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<string>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<Integer>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<Extended>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam; overload; virtual;
    function GetOrCreateObject(const Name: string): TJSONObject;
    function GetOrCreate<T: TJSONValue, constructor>(const Name: string): T;
    procedure Delete(const Key: string); virtual;
    procedure Clear; virtual;
    property Count: Integer read GetCount;
    function Detach: TJSONObject;
    property JSON: TJSONObject read FJSON write SetJSON;
    function ToJsonString(FreeObject: Boolean = False): string; virtual;
    function ToFormat(FreeObject: Boolean = False): string;
    function ToStringPairs: TArray<TPair<string, string>>;
    function ToStream: TStringStream;
  end;

  TJSONModelNamedParam = class(TJSONParam)
  public
    function Model(const Value: string): TJSONModelNamedParam;
  end;

  TJSONChatParam = class(TJSONModelNamedParam);

  TJSONModelParam = class(TJSONModelNamedParam);

  TCMDParam = class
  private
    FValue: string;
    procedure Check(const Name: string);
    function GetValue: string;
  public
    function Add(const Name, Value: string): TCMDParam; overload;
    function Add(const Name: string; Value: Integer): TCMDParam; overload;
    function Add(const Name: string; Value: Boolean): TCMDParam; overload;
    function Add(const Name: string; Value: Double): TCMDParam; overload;
    property Value: string read GetValue;
    constructor Create;
  end;

  TModel = class
  private
    FModel: string;
  public
    property Model: string read FModel write FModel;
  end;

const
  DATE_FORMAT = 'YYYY-MM-DD';
  TIME_FORMAT = 'HH:NN:SS';
  DATE_TIME_FORMAT = DATE_FORMAT + ' ' + TIME_FORMAT;

implementation

uses
  System.DateUtils;

{ TJSONInterceptorStringToString }

constructor TJSONInterceptorStringToString.Create;
begin
  ConverterType := ctString;
  ReverterType := rtString;
end;

{ Fetch }

type
  Fetch<T> = class
    type
      TFetchProc = reference to procedure(const Element: T);
  public
    class procedure All(const Items: TArray<T>; Proc: TFetchProc);
  end;

{ Fetch<T> }

class procedure Fetch<T>.All(const Items: TArray<T>; Proc: TFetchProc);
var
  Item: T;
begin
  for Item in Items do
    Proc(Item);
end;

{ TJSONParam }

function TJSONParam.Add(const Key, Value: string): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONValue): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONParam): TJSONParam;
begin
  Add(Key, TJSONValue(Value.JSON.Clone));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  Add(Key, FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value)));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Boolean): TJSONParam;
begin
  Add(Key, TJSONBool.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Integer): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Extended): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam;
var
  JArr: TJSONArray;
begin
  JArr := TJSONArray.Create;
  Fetch<TJSONValue>.All(Value, JArr.AddElement);
  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam;
var
  JArr: TJSONArray;
  Item: TJSONParam;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
  try
    JArr.AddElement(Item.JSON);
    Item.JSON := nil;
  finally
    Item.Free;
  end;
  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<Extended>): TJSONParam;
var
  JArr: TJSONArray;
  Item: Extended;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
    JArr.Add(Item);
  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<Integer>): TJSONParam;
var
  JArr: TJSONArray;
  Item: Integer;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
    JArr.Add(Item);
  Add(Key, JArr);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<string>): TJSONParam;
var
  JArr: TJSONArray;
  Item: string;
begin
  JArr := TJSONArray.Create;
  for Item in Value do
    JArr.Add(Item);
  Add(Key, JArr);
  Result := Self;
end;

procedure TJSONParam.Clear;
begin
  FJSON.Free;
  FJSON := TJSONObject.Create;
end;

constructor TJSONParam.Create;
begin
  FJSON := TJSONObject.Create;
end;

procedure TJSONParam.Delete(const Key: string);
var
  Item: TJSONPair;
begin
  Item := FJSON.RemovePair(Key);
  if Assigned(Item) then
    Item.Free;
end;

destructor TJSONParam.Destroy;
begin
  if Assigned(FJSON) then
    FJSON.Free;
  inherited;
end;

function TJSONParam.GetCount: Integer;
begin
  Result := FJSON.Count;
end;

function TJSONParam.GetOrCreate<T>(const Name: string): T;
begin
  if not FJSON.TryGetValue<T>(Name, Result) then
  begin
    Result := T.Create;
    FJSON.AddPair(Name, Result);
  end;
end;

function TJSONParam.GetOrCreateObject(const Name: string): TJSONObject;
begin
  Result := GetOrCreate<TJSONObject>(Name);
end;

function TJSONParam.Detach: TJSONObject;
begin
  Result := JSON;
  JSON := nil;
  var Task: ITask := TTask.Create(
    procedure()
    begin
      Sleep(30);
      TThread.Queue(nil,
      procedure
      begin
        Self.Free;
      end);
    end
  );
  Task.Start;
end;

procedure TJSONParam.SetJSON(const Value: TJSONObject);
begin
  FJSON := Value;
end;

function TJSONParam.ToFormat(FreeObject: Boolean): string;
begin
  Result := FJSON.Format(4);
  if FreeObject then
    Free;
end;

function TJSONParam.ToJsonString(FreeObject: Boolean): string;
begin
  Result := FJSON.ToJSON;
  if FreeObject then
    Free;
end;

function TJSONParam.ToStream: TStringStream;
begin
  Result := TStringStream.Create;
  try
    Result.WriteString(ToJsonString);
    Result.Position := 0;
  except
    Result.Free;
    raise;
  end;
end;

function TJSONParam.ToStringPairs: TArray<TPair<string, string>>;
begin
  for var Pair in FJSON do
    Result := Result + [TPair<string, string>.Create(Pair.JsonString.Value, Pair.JsonValue.AsType<string>)];
end;

{ TCMDParam }

function TCMDParam.Add(const Name, Value: string): TCMDParam;
begin
  Check(Name);
  var S := Format('%s=%s', [Name, Value]);
  if FValue.IsEmpty then
    FValue := S else
    FValue := FValue + '&' + S;
  Result := Self;
end;

function TCMDParam.Add(const Name: string; Value: Integer): TCMDParam;
begin
  Result := Add(Name, Value.ToString);
end;

function TCMDParam.Add(const Name: string; Value: Boolean): TCMDParam;
begin
  Result := Add(Name, BoolToStr(Value, true));
end;

function TCMDParam.Add(const Name: string; Value: Double): TCMDParam;
begin
  Result := Add(Name, Value.ToString);
end;

procedure TCMDParam.Check(const Name: string);
begin
  if FValue.Contains(Name) then
    begin
      var Items := FValue.Split(['&']);
      FValue := EmptyStr;
      for var Item in Items do
        begin
          if not Item.StartsWith(Name) then
            begin
              if FValue.IsEmpty then
                FValue := Item else
                FValue := FValue + '&' + Item;
            end;
        end;
    end;
end;

constructor TCMDParam.Create;
begin
  FValue := EmptyStr;
end;

function TCMDParam.GetValue: string;
begin
  Result := FValue;
  if not Result.IsEmpty then
    Result := '?' + Result; // + '&page=2>; rel="last"';
end;

{ TJSONModelNamedParam }

function TJSONModelNamedParam.Model(const Value: string): TJSONModelNamedParam;
begin
  Result := TJSONModelNamedParam(Add('model', Value));
end;

end.

