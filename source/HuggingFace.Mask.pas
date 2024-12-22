unit HuggingFace.Mask;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, Rest.Json,
  REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Async.Support;

type
  TMaskParameters = class(TJSONParam)
  public
    /// <summary>
    /// When passed, overrides the number of predictions to return.
    /// </summary>
    function TopK(const Value: Integer): TMaskParameters;
    /// <summary>
    /// When passed, the model will limit the scores to the passed targets instead of looking up in
    /// the whole vocabulary. If the provided targets are not in the model vocab, they will be tokenized
    /// and the first resulting token will be used (with a warning, and that might be slower).
    /// </summary>
    function Targets(const Value: TArray<string>): TMaskParameters;
  end;

  TMaskParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The text with masked tokens.
    /// </summary>
    function Inputs(const Value: string): TMaskParam;
    /// <summary>
    /// Set mask parameters
    /// </summary>
    function Parameters(const TopK: Integer; const Targets: TArray<string> = []): TMaskParam; overload;
    /// <summary>
    /// Set mask parameters
    /// </summary>
    function Parameters(const Targets: TArray<string>): TMaskParam; overload;
  end;

  TMaskItem = class
  private
    FSequence: string;
    FScore: Double;
    FToken: Int64;
    [JsonNameAttribute('token_str')]
    FTokenStr: string;
  public
    /// <summary>
    /// The corresponding input with the mask token prediction.
    /// </summary>
    property Sequence: string read FSequence write FSequence;
    /// <summary>
    /// The corresponding probability.
    /// </summary>
    property Score: Double read FScore write FScore;
    /// <summary>
    /// The predicted token id (to replace the masked one).
    /// </summary>
    property Token: Int64 read FToken write FToken;
    /// <summary>
    /// The predicted token (to replace the masked one).
    /// </summary>
    property TokenStr: string read FTokenStr write FTokenStr;
  end;

  TMask = class
  private
    FItems: TArray<TMaskItem>;
  public
    /// <summary>
    /// Output is an array of objects.
    /// </summary>
    property Items: TArray<TMaskItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TMask</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMask</c> type extends the <c>TAsynParams&lt;TMask&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynMask = TAsynCallBack<TMask>;

  TMaskRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Mask filling is the task of predicting the right word (token to be precise) in the middle of a sequence.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TMaskParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TMask</c> object containing the Classification result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Image.FillCreate(
    ///     procedure (Params: TMaskParam)
    ///     begin
    ///       // Define parameters
    ///     end;
    /// try
    ///   // Handle the Value
    /// finally
    ///   Value.Free;
    /// end;
    /// </code>
    /// </remarks>
    function Fill(ParamProc: TProc<TMaskParam>): TMask; overload;
    /// <summary>
    /// Mask filling is the task of predicting the right word (token to be precise) in the middle of a sequence.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TMaskParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynMask</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Image.Fill(
    ///   procedure (Params: TMaskParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynMask
    ///   begin
    ///      Result.Sender := my_display_component;
    ///
    ///      Result.OnStart :=
    ///        procedure (Sender: TObject);
    ///        begin
    ///          // Handle the start
    ///        end;
    ///
    ///      Result.OnSuccess :=
    ///        procedure (Sender: TObject; Value: TMask)
    ///        begin
    ///          // Handle the display
    ///        end;
    ///
    ///      Result.OnError :=
    ///        procedure (Sender: TObject; Error: string)
    ///        begin
    ///          // Handle the error message
    ///        end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure Fill(ParamProc: TProc<TMaskParam>; CallBacks: TFunc<TAsynMask>); overload;
  end;

implementation

{ TMaskParam }

function TMaskParam.Inputs(const Value: string): TMaskParam;
begin
  Result := TMaskParam(Add('inputs', Value));
end;

function TMaskParam.Parameters(const TopK: Integer;
  const Targets: TArray<string>): TMaskParam;
begin
  var Value := TMaskParameters.Create.TopK(TopK);
  if Length(Targets) > 0 then
    Value := Value.Targets(Targets);
  Result := TMaskParam(Add('parameters', Value.Detach));
end;

function TMaskParam.Parameters(const Targets: TArray<string>): TMaskParam;
begin
  Result := TMaskParam(Add('parameters', TMaskParameters.Create.Targets(Targets).Detach));
end;

{ TMaskParameters }

function TMaskParameters.Targets(const Value: TArray<string>): TMaskParameters;
begin
  Result := TMaskParameters(Add('targets', Value));
end;

function TMaskParameters.TopK(const Value: Integer): TMaskParameters;
begin
  Result := TMaskParameters(Add('top_k', Value));
end;

{ TMask }

destructor TMask.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TMaskRoute }

function TMaskRoute.Fill(ParamProc: TProc<TMaskParam>): TMask;
begin
  Result := API.Post<TMask, TMaskParam>('models', ParamProc);
end;

procedure TMaskRoute.Fill(ParamProc: TProc<TMaskParam>;
  CallBacks: TFunc<TAsynMask>);
begin
  with TAsynCallBackExec<TAsynMask, TMask>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMask
      begin
        Result := Self.Fill(ParamProc);
      end);
  finally
    Free;
  end;
end;

end.
