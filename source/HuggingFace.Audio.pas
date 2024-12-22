unit HuggingFace.Audio;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, Rest.Json,
  REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Async.Support, HuggingFace.Types;

type

  {$REGION 'Audio-To-Text'}

  TGenerationParameters = class(TJSONParam)
  public
    /// <summary>
    /// The value used to modulate the next token probabilities.
    /// </summary>
    function Temperature(const Value: Double): TGenerationParameters;
    /// <summary>
    /// The number of highest probability vocabulary tokens to keep for top-k-filtering.
    /// </summary>
    function TopK(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// If set to float < 1, only the smallest set of most probable tokens with probabilities that
    /// add up to top_p or higher are kept for generation.
    /// </summary>
    function TopP(const Value: Double): TGenerationParameters;
    /// <summary>
    /// Local typicality measures how similar the conditional probability of predicting a target token
    /// next is to the expected conditional probability of predicting a random token next, given the
    /// partial text already generated. If set to float < 1, the smallest set of the most locally typical
    /// tokens with probabilities that add up to typical_p or higher are kept for generation.
    /// </summary>
    function TypicalP(const Value: Double): TGenerationParameters;
    /// <summary>
    /// If set to float strictly between 0 and 1, only tokens with a conditional probability greater
    /// than epsilon_cutoff will be sampled. In the paper, suggested values range from 3e-4 to 9e-4,
    /// depending on the size of the model.
    /// </summary>
    function EpsilonCutoff(const Value: Double): TGenerationParameters;
    /// <summary>
    /// Eta sampling is a hybrid of locally typical sampling and epsilon sampling. If set to float
    /// strictly between 0 and 1, a token is only considered if it is greater than either eta_cutoff
    /// or sqrt(eta_cutoff) * exp(-entropy(softmax(next_token_logits))). The latter term is intuitively
    /// the expected next token probability, scaled by sqrt(eta_cutoff). In the paper, suggested values
    /// range from 3e-4 to 2e-3, depending on the size of the model.
    /// </summary>
    function EtaCutoff(const Value: Double): TGenerationParameters;
    /// <summary>
    /// The maximum length (in tokens) of the generated text, including the input.
    /// </summary>
    function MaxLength(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// The maximum number of tokens to generate. Takes precedence over max_length.
    /// </summary>
    function MaxNewTokens(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// The minimum length (in tokens) of the generated text, including the input.
    /// </summary>
    function MinLength(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// The minimum number of tokens to generate. Takes precedence over min_length.
    /// </summary>
    function MinNewTokens(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// Whether to use sampling instead of greedy decoding when generating new tokens.
    /// </summary>
    function DoSample(const Value: Boolean): TGenerationParameters;
    /// <summary>
    /// Possible values: never, true, false.
    /// </summary>
    function EarlyStopping(const Value: TEarlyStopping): TGenerationParameters;
    /// <summary>
    /// Number of beams to use for beam search.
    /// </summary>
    function NumBeams(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// Number of groups to divide num_beams into in order to ensure diversity among different groups
    /// of beams.
    /// </summary>
    function NumBeamGroups(const Value: Integer): TGenerationParameters;
    /// <summary>
    /// The value balances the model confidence and the degeneration penalty in contrastive search decoding.
    /// </summary>
    function PenaltyAlpha(const Value: Double): TGenerationParameters;
    /// <summary>
    /// Whether the model should use the past last key/values attentions to speed up decoding
    /// </summary>
    function UseCache(const Value: Boolean): TGenerationParameters;
  end;

  TRecognitionParameters = class(TJSONParam)
  public
    /// <summary>
    /// Whether to output corresponding timestamps with the generated text
    /// </summary>
    function ReturnTimestamps(const Value: Boolean): TRecognitionParameters;
  end;

  TAudioToTextParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input audio data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the audio file
    /// </param>
    function Inputs(const FileName: string): TAudioToTextParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(const Value: TJSONObject): TAudioToTextParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function GenerationParameters(ParamProc: TProcRef<TGenerationParameters>): TAudioToTextParam; overload;
  end;

  TAudioChunk = class
  private
    FText: string;
    FTimestamps: TArray<Double>;
  public
    /// <summary>
    /// A chunk of text identified by the model.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// The start and end timestamps corresponding with the text.
    /// </summary>
    property Timestamps: TArray<Double> read FTimestamps write FTimestamps;
  end;

  TAudioToText = class
  private
    FText: string;
    FChunks: TArray<TAudioChunk>;
  public
    /// <summary>
    /// The recognized text.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// When returnTimestamps is enabled, chunks contains a list of audio chunks identified by the model.
    /// </summary>
    property Chunks: TArray<TAudioChunk> read FChunks write FChunks;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TAudioToText</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAudioToText</c> type extends the <c>TAsynParams&lt;TAudioToText&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAudioToText = TAsynCallBack<TAudioToText>;

  {$ENDREGION}

  {$REGION 'Audio-Classification'}

  TAudioClassificationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Possible values: sigmoid, softmax, none.
    /// </summary>
    function FunctionToApply(const Value: TFunctionClassification): TAudioClassificationParameters;
    /// <summary>
    /// When specified, limits the output to the top K most probable classes.
    /// </summary>
    function TopK(const Value: Integer): TAudioClassificationParameters;
  end;

  TAudioClassificationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input audio data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the audio file
    /// </param>
    function Inputs(const FileName: string): TAudioClassificationParam;
    /// <summary>
    /// Classification parameters
    /// </summary>
    function Parameters(const FunctionToApply: TFunctionClassification; const TopK: Integer = -1): TAudioClassificationParam; overload;
    /// <summary>
    /// Classification parameters
    /// </summary>
    function Parameters(const TopK: Integer): TAudioClassificationParam; overload;
  end;

  TAudioClassificationItem = class
  private
    FLabel: string;
    FScore: Double;
  public
    /// <summary>
    /// The predicted class label.
    /// </summary>
    property &Label: string read FLabel write FLabel;
    /// <summary>
    /// The corresponding probability.
    /// </summary>
    property Score: Double read FScore write FScore;
  end;

  TAudioClassification = class
  private
    FItems: TArray<TAudioClassificationItem>;
  public
    /// <summary>
    /// Output is an array of objects.
    /// </summary>
    property Items: TArray<TAudioClassificationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TAudioClassification</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAudioClassification</c> type extends the <c>TAsynParams&lt;TAudioClassification&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAudioClassification = TAsynCallBack<TAudioClassification>;

  {$ENDREGION}

  {$REGION 'Audio-To-Audio'}

  TAudioToAudioParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input audio data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the audio file
    /// </param>
    function Inputs(const FileName: string): TAudioToAudioParam;
  end;

  TAudioToAudio = class
  private
    FFileName: string;
    FAudio: string;
  public
    /// <summary>
    /// Retrieves the generated audio as a <c>TStream</c>.
    /// </summary>
    /// <returns>
    /// A <c>TStream</c> containing the decoded audio data.
    /// </returns>
    /// <remarks>
    /// This method decodes the base64-encoded audio data and returns it as a stream.
    /// The caller is responsible for freeing the returned stream.
    /// </remarks>
    /// <exception cref="Exception">
    /// Raises an exception if both the audio are empty.
    /// </exception>
    function GetStream: TStream;
    /// <summary>
    /// Saves the generated audio to a file.
    /// </summary>
    /// <param name="FileName">
    /// The file path where the audio will be saved.
    /// </param>
    /// <remarks>
    /// This method decodes the base64-encoded audio data and saves it to the specified file.
    /// </remarks>
    /// <exception cref="Exception">
    /// Raises an exception if the audio data cannot be decoded or saved.
    /// </exception>
    procedure SaveToFile(const FileName: string);
    /// <summary>
    /// The base64-encoded audio data.
    /// </summary>
    property Audio: string read FAudio write FAudio;
    /// <summary>
    /// Gets the file name where the audio was saved.
    /// </summary>
    /// <value>
    /// The file path as a string.
    /// </value>
    /// <remarks>
    /// This property holds the file name specified in the last call to <c>SaveToFile</c>.
    /// </remarks>
    property FileName: string read FFileName write FFileName;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TAudioToAudio</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAudioToAudio</c> type extends the <c>TAsynParams&lt;TAudioToAudio&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAudioToAudio = TAsynCallBack<TAudioToAudio>;

  {$ENDREGION}

  TAudioRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Audio processing from the model.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioToAudioParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TAudioToAudio</c> object containing the AudioToAudio result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Audio.AudioToAudio(
    ///     procedure (Params: TAudioToAudioParam)
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
    function AudioToAudio(ParamProc: TProc<TAudioToAudioParam>): TAudioToAudio; overload;
    /// <summary>
    /// Audio processing from the model.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioToAudioParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynAudioToText</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Audio.AudioToAudio(
    ///   procedure (Params: TAudioToAudioParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynAudioToAudio
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
    ///        procedure (Sender: TObject; Value: TAudioToAudio)
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
    procedure AudioToAudio(ParamProc: TProc<TAudioToAudioParam>; CallBacks: TFunc<TAsynAudioToAudio>); overload;
    /// <summary>
    /// Creates a transcription of the provided audio.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioToTextParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TAudioToText</c> object containing the AudioToText result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Audio.AudioToText(
    ///     procedure (Params: TAudioToTextParam)
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
    function AudioToText(ParamProc: TProc<TAudioToTextParam>): TAudioToText; overload;
    /// <summary>
    /// Asynchronously creates a transcription of the provided audio.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioToTextParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynAudioToText</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Audio.AudioToText(
    ///   procedure (Params: TAudioToTextParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynAudioToText
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
    ///        procedure (Sender: TObject; Value: TAudioToText)
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
    procedure AudioToText(ParamProc: TProc<TAudioToTextParam>; CallBacks: TFunc<TAsynAudioToText>); overload;
    /// <summary>
    /// Audio classification is the task of assigning a label or class to a given audio.
    /// <para>
    /// NOTE: This method is <c>synchronous</c>
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioClassificationParam</c> parameters.
    /// </param>
    /// <returns>
    /// Returns a <c>TAudioClassification</c> instance.
    /// </returns>
    /// <exception cref="HuggingFaceException">
    /// Thrown when there is an error in the communication with the API or other underlying issues in the API call.
    /// </exception>
    /// <exception cref="HuggingFaceExceptionBadRequestError">
    /// Thrown when the request is invalid, such as when required parameters are missing or values exceed allowed limits.
    /// </exception>
    /// <remarks>
    /// <code>
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    ///   var Value := HuggingFace.Audio.Classification(
    ///     procedure (Params: TAudioClassificationParam)
    ///     begin
    ///       // Define parameters
    ///     end);
    ///   try
    ///     // Handle the Value
    ///   finally
    ///     Value.Free;
    ///   end;
    /// </code>
    /// </remarks>
    function Classification(ParamProc: TProc<TAudioClassificationParam>): TAudioClassification; overload;
    /// <summary>
    /// Audio classification is the task of assigning a label or class to a given audio.
    /// <para>
    /// NOTE: This method is <c>asynchronous</c>
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TAudioClassificationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAudioClassificationParam</c> to handle the asynchronous result.
    /// </param>
    /// <exception cref="HuggingFaceException">
    /// Thrown when there is an error in the communication with the API or other underlying issues in the API call.
    /// </exception>
    /// <exception cref="HuggingFaceExceptionBadRequestError">
    /// Thrown when the request is invalid, such as when required parameters are missing or values exceed allowed limits.
    /// </exception>
    /// <remarks>
    /// <code>
    /// // WARNING - Move the following line to the main OnCreate method for maximum scope.
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Audio.Classification(
    ///   procedure (Params: TAudioClassificationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynAudioClassification
    ///   begin
    ///     Result.Sender := Image1;  // Instance passed to callback parameter
    ///
    ///     Result.OnStart := nil;   // If nil then; Can be omitted
    ///
    ///     Result.OnSuccess := procedure (Sender: TObject; Value: TAudioClassification)
    ///       begin
    ///         // Handle success operation
    ///       end;
    ///
    ///     Result.OnError := procedure (Sender: TObject; Error: string)
    ///       begin
    ///         // Handle error message
    ///       end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure Classification(ParamProc: TProc<TAudioClassificationParam>; CallBacks: TFunc<TAsynAudioClassification>); overload;
  end;

implementation

uses
  HuggingFace.NetEncoding.Base64;

{ TAudioToTextParam }

function TAudioToTextParam.GenerationParameters(
  ParamProc: TProcRef<TGenerationParameters>): TAudioToTextParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TGenerationParameters.Create;
      ParamProc(Value);
      Result := TAudioToTextParam(Add('generation_parameters', Value.Detach));
    end
  else Result := Self;
end;

function TAudioToTextParam.Inputs(const FileName: string): TAudioToTextParam;
begin
  Result := TAudioToTextParam(Add('inputs', EncodeBase64(FileName)));
end;

function TAudioToTextParam.Parameters(
  const Value: TJSONObject): TAudioToTextParam;
begin
  Result := TAudioToTextParam(Add('parameters', Value));
end;

{ TAudioRoute }

function TAudioRoute.AudioToAudio(
  ParamProc: TProc<TAudioToAudioParam>): TAudioToAudio;
begin
  Result := API.Post<TAudioToAudio, TAudioToAudioParam>('models', ParamProc, 'audio');
end;

procedure TAudioRoute.AudioToAudio(ParamProc: TProc<TAudioToAudioParam>;
  CallBacks: TFunc<TAsynAudioToAudio>);
begin
  with TAsynCallBackExec<TAsynAudioToAudio, TAudioToAudio>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAudioToAudio
      begin
        Result := Self.AudioToAudio(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TAudioRoute.AudioToText(
  ParamProc: TProc<TAudioToTextParam>): TAudioToText;
begin
  Result := API.Post<TAudioToText, TAudioToTextParam>('models', ParamProc);
end;

procedure TAudioRoute.AudioToText(ParamProc: TProc<TAudioToTextParam>;
  CallBacks: TFunc<TAsynAudioToText>);
begin
  with TAsynCallBackExec<TAsynAudioToText, TAudioToText>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAudioToText
      begin
        Result := Self.AudioToText(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAudioRoute.Classification(
  ParamProc: TProc<TAudioClassificationParam>;
  CallBacks: TFunc<TAsynAudioClassification>);
begin
  with TAsynCallBackExec<TAsynAudioClassification, TAudioClassification>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAudioClassification
      begin
        Result := Self.Classification(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TAudioRoute.Classification(
  ParamProc: TProc<TAudioClassificationParam>): TAudioClassification;
begin
  Result := API.Post<TAudioClassification, TAudioClassificationParam>('models', ParamProc);
end;

{ TRecognitionParameters }

function TRecognitionParameters.ReturnTimestamps(
  const Value: Boolean): TRecognitionParameters;
begin
  Result := TRecognitionParameters(Add('return_timestamps', Value));
end;

{ TGenerationParameters }

function TGenerationParameters.DoSample(
  const Value: Boolean): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('do_sample', Value));
end;

function TGenerationParameters.EarlyStopping(
  const Value: TEarlyStopping): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('early_stopping', Value.ToString));
end;

function TGenerationParameters.EpsilonCutoff(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('epsilon_cutoff', Value));
end;

function TGenerationParameters.EtaCutoff(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('eta_cutoff', Value));
end;

function TGenerationParameters.MaxLength(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('max_length', Value));
end;

function TGenerationParameters.MaxNewTokens(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('max_new_tokens', Value));
end;

function TGenerationParameters.MinLength(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('min_length', Value));
end;

function TGenerationParameters.MinNewTokens(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('min_new_tokens', Value));
end;

function TGenerationParameters.NumBeamGroups(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('num_beam_groups', Value));
end;

function TGenerationParameters.NumBeams(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('num_beams', Value));
end;

function TGenerationParameters.PenaltyAlpha(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('penalty_alpha', Value));
end;

function TGenerationParameters.Temperature(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('temperature', Value));
end;

function TGenerationParameters.TopK(
  const Value: Integer): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('top_k', Value));
end;

function TGenerationParameters.TopP(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('top_p', Value));
end;

function TGenerationParameters.TypicalP(
  const Value: Double): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('typical_p', Value));
end;

function TGenerationParameters.UseCache(
  const Value: Boolean): TGenerationParameters;
begin
  Result := TGenerationParameters(Add('use_cache', Value));
end;

{ TAudioToText }

destructor TAudioToText.Destroy;
begin
  for var Item in FChunks do
    Item.Free;
  inherited;
end;

{ TAudioClassificationParam }

function TAudioClassificationParam.Inputs(const FileName: string): TAudioClassificationParam;
begin
  Result := TAudioClassificationParam(Add('inputs', EncodeBase64(FileName)));
end;

function TAudioClassificationParam.Parameters(
  const FunctionToApply: TFunctionClassification;
  const TopK: Integer): TAudioClassificationParam;
begin
  var Value := TAudioClassificationParameters.Create.FunctionToApply(FunctionToApply);
  if TopK <> -1 then
    Value := Value.TopK(TopK);
  Result := TAudioClassificationParam(Add('parameters', Value.Detach));
end;

function TAudioClassificationParam.Parameters(
  const TopK: Integer): TAudioClassificationParam;
begin
  Result := TAudioClassificationParam(Add('parameters', TAudioClassificationParameters.Create.TopK(TopK).Detach));
end;

{ TAudioClassificationParameters }

function TAudioClassificationParameters.FunctionToApply(
  const Value: TFunctionClassification): TAudioClassificationParameters;
begin
  Result := TAudioClassificationParameters(Add('function_to_apply', Value.ToString));
end;

function TAudioClassificationParameters.TopK(
  const Value: Integer): TAudioClassificationParameters;
begin
  Result := TAudioClassificationParameters(Add('top_k', Value));
end;

{ TAudioClassification }

destructor TAudioClassification.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TAudioToAudioParam }

function TAudioToAudioParam.Inputs(const FileName: string): TAudioToAudioParam;
begin
  Result := TAudioToAudioParam(Add('inputs', EncodeBase64(FileName)));
end;

{ TAudioToAudio }

function TAudioToAudio.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Audio, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TAudioToAudio.SaveToFile(const FileName: string);
begin
  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Audio, FileName)
  except
    raise;
  end;
end;

end.
