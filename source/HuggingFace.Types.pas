unit HuggingFace.Types;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, HuggingFace.API.Params;

type
  TCoordinate = TArray<TArray<Integer>>;

  TCoordinateHelper = record helper for TCoordinate
    function ToString: string;
  end;

  {--- Embeddings }
  TTruncationDirection = (
    left,
    right
  );

  TTruncationDirectionHelper = record helper for TTruncationDirection
    function ToString: string;
  end;

  {--- Images }
  TFunctionClassification = (
    sigmoid,
    softmax,
    none
  );

  TFunctionClassificationHelper = record helper for TFunctionClassification
    function ToString: string;
  end;

  {--- Audio }
  TEarlyStopping = (
    never,
    estrue,
    esfalse
  );

  TEarlyStoppingHelper = record helper for TEarlyStopping
    function ToString: string;
  end;

  TSubtaskType = (
    instance,
    panoptic,
    semantic
  );

  TSubtaskTypeHelper = record helper for TSubtaskType
    function ToString: string;
  end;

  {--- Chat }
  TRoleType = (
    user,
    assistant,
    system
  );

  TRoleTypeHelper = record helper for TRoleType
    function ToString: string;
    class function Create(const Value: string): TRoleType; static;
  end;

  TRoleTypeInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TContentType = (
    text,
    image_url
  );

  TContentTypeHelper = record helper for TContentType
    function ToString: string;
  end;

  TResponseFormatType = (
    json,
    regex
  );

  TResponseFormatTypeHelper = record helper for TResponseFormatType
    function ToString: string;
  end;

  TToolChoiceType = (
    auto,
    tcnone,
    requiered
  );

  TToolChoiceTypeHelper = record helper for TToolChoiceType
    function ToString: string;
  end;

  TFinishReason = (
    stop,
    length,

    eos_token,
    stop_sequence
  );

  TFinishReasonHelper = record helper for TFinishReason
    function ToString: string;
    class function Create(const Value: string): TFinishReason; static;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TArgsFixInterceptor = class(TJSONInterceptorStringToString)
  public
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {--- Schema }
  TSchemaType = (
    TYPE_UNSPECIFIED,
    stSTRING,
    stNUMBER,
    stINTEGER,
    stBOOLEAN,
    stARRAY,
    stOBJECT
  );

  TSchemaTypeHelper = record helper for TSchemaType
    function ToString: string;
  end;

  {--- Text }
  TTextTruncationType = (
    do_not_truncate,
    longest_first,
    only_first,
    only_second
  );

  TTextTruncationTypeHelper = record helper for TTextTruncationType
    function ToString: string;
  end;

  TPaddingType = (
    do_not_pad,
    longest,
    max_length
  );

  TPaddingTypeHelper = record helper for TPaddingType
   function ToString: string;
  end;

  TAggregationStrategyType = (
    asnone,
    simple,
    first,
    average,
    max
  );

  TAggregationStrategyTypeHelper = record helper for TAggregationStrategyType
    function ToString: string;
  end;

implementation

uses
  System.StrUtils, System.Rtti;

{ TTruncationDirectionHelper }

function TTruncationDirectionHelper.ToString: string;
begin
  case Self of
    left:
      Exit('left');
    right:
      Exit('right');
  end;
end;

{ TFunctionClassificationHelper }

function TFunctionClassificationHelper.ToString: string;
begin
  case Self of
    sigmoid:
      Exit('sigmoid');
    softmax:
      Exit('softmax');
    none:
      Exit('none');
  end;
end;

{ TSubtaskTypeHelper }

function TSubtaskTypeHelper.ToString: string;
begin
  case Self of
    instance:
      Exit('instance');
    panoptic:
      Exit('panoptic');
    semantic:
      Exit('semantic');
  end;
end;

{ TEarlyStoppingHelper }

function TEarlyStoppingHelper.ToString: string;
begin
  case Self of
    never:
      Exit('never');
    estrue:
      Exit('true');
    esfalse:
      Exit('false');
  end;
end;

{ TRoleTypeHelper }

class function TRoleTypeHelper.Create(const Value: string): TRoleType;
begin
  var index := IndexStr(AnsiLowerCase(Value), ['user', 'assistant', 'system']);
  if index = -1 then
    raise Exception.Create('String role value not correct');
  Result := TRoleType(index);
end;

function TRoleTypeHelper.ToString: string;
begin
  case Self of
    user:
      Exit('user');
    assistant:
      Exit('assistant');
    system:
      Exit('system');
  end;
end;

{ TRoleTypeInterceptor }

function TRoleTypeInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TRoleType>.ToString;
end;

procedure TRoleTypeInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TRoleType.Create(Arg)));
end;

{ TContentTypeHelper }

function TContentTypeHelper.ToString: string;
begin
  case Self of
    text:
      Exit('text');
    image_url:
      Exit('image_url');
  end;
end;

{ TResponseFormatTypeHelper }

function TResponseFormatTypeHelper.ToString: string;
begin
  case Self of
    json:
      Exit('json');
    regex:
      Exit('regex');
  end;
end;

{ TToolChoiceTypeHelper }

function TToolChoiceTypeHelper.ToString: string;
begin
  case Self of
    auto:
      Exit('auto');
    tcnone:
      Exit('none');
    requiered:
      Exit('requiered');
  end;
end;

{ TFinishReasonHelper }

class function TFinishReasonHelper.Create(const Value: string): TFinishReason;
begin
  var index := IndexStr(AnsiLowerCase(Value), ['stop', 'length', 'eos_token', 'stop_sequence']);
  if index = -1 then
    raise Exception.Create('String finish reason value not correct');
  Result := TFinishReason(index);
end;

function TFinishReasonHelper.ToString: string;
begin
  case self of
    stop:
      Exit('stop');
    length:
      Exit('length');
    eos_token:
      Exit('eos_token');
    stop_sequence:
      Exit('stop_sequence');
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TArgsFixInterceptor }

procedure TArgsFixInterceptor.StringReverter(Data: TObject; Field, Arg: string);
begin
  Arg := Format('{%s}', [Trim(Arg.Replace('`', '"').Replace(#10, ''))]);
  while Arg.Contains(', ') do Arg := Arg.Replace(', ', ',');
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, Arg.Replace(',', ', '));
end;

{ TSchemaTypeHelper }

function TSchemaTypeHelper.ToString: string;
begin
  case Self of
    TYPE_UNSPECIFIED:
      Exit('type_unspecified');
    stSTRING:
      Exit('string');
    stNUMBER:
      Exit('number');
    stINTEGER:
      Exit('integer');
    stBOOLEAN:
      Exit('boolean');
    stARRAY:
      Exit('array');
    stOBJECT:
      Exit('object');
  end;
end;

{ TTextTruncationTypeHelper }

function TTextTruncationTypeHelper.ToString: string;
begin
  case Self of
    do_not_truncate:
      Exit('do_not_truncate');
    longest_first:
      Exit('longest_first');
    only_first:
      Exit('only_first');
    only_second:
      Exit('only_second');
  end;
end;

{ TPaddingTypeHelper }

function TPaddingTypeHelper.ToString: string;
begin
  case Self of
    do_not_pad:
      Exit('do_not_pad');
    longest:
      Exit('longest');
    max_length:
      Exit('max_length');
  end;
end;

{ TCoordinateHelper }

function TCoordinateHelper.ToString: string;
begin
  Result := EmptyStr;
  for var i := 0 to High(Self) do
    if Result.IsEmpty then
      Result := Format('[%s, %s]', [Self[0][0].ToString, Self[0][1].ToString]) else
      Result := Format('%s,  [%s, %s]', [Result, Self[0][0].ToString, Self[0][1].ToString]);
end;

{ TAggregationStrategyTypeHelper }

function TAggregationStrategyTypeHelper.ToString: string;
begin
  case Self of
    asnone:
      Exit('none');
    simple:
      Exit('simple');
    first:
      Exit('first');
    average:
      Exit('average');
    max:
      Exit('max');
  end;
end;

end.
