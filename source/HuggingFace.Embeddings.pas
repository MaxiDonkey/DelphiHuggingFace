unit HuggingFace.Embeddings;

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
  TEmbeddingParams = class(TJSONModelParam)
  public
    /// <summary>
    /// The text to embed.
    /// </summary>
    function Inputs(const Value: string): TEmbeddingParams;
    /// <summary>
    /// Normalize the return vector.
    /// </summary>
    function Normalize(const Value: Boolean): TEmbeddingParams;
    /// <summary>
    /// he name of the prompt that should be used by for encoding. If not set, no prompt will
    /// be applied. Must be a key in the sentence-transformers configuration prompts dictionary.
    /// </summary>
    /// <remarks>
    /// For example if prompt_name is “query” and the prompts is {“query”: “query: ”, …}
    /// <para>
    /// then the sentence “What is the capital of France?” will be encoded as
    /// </para>
    /// <para>
    /// “query: What is the capital of France?” because the prompt text will be prepended before
    /// any text to encode.
    /// </para>
    /// </remarks>
    function PromptName(const Value: string): TEmbeddingParams;
    /// <summary>
    /// Truncate the return vector.
    /// </summary>
    function Truncate(const Value: Boolean): TEmbeddingParams;
    /// <summary>
    /// Possible values: Left, Right.
    /// </summary>
    function TruncationDirection(const Value: TTruncationDirection): TEmbeddingParams;
  end;

  TEmbeddings = class
  private
    FItems: TArray<Double>;
  public
    /// <summary>
    /// Output is an array of double.
    /// </summary>
    property Items: TArray<Double> read FItems write FItems;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TEmbeddings</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynEmbeddings</c> type extends the <c>TAsynParams&lt;TEmbeddings&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynEmbeddings = TAsynCallBack<TEmbeddings>;

  TEmbeddingsRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Feature extraction is the task of converting a text into a vector (often called “embedding”).
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TEmbeddingParams</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TEmbeddings</c> object containing the Classification result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Embeddings.Create(
    ///     procedure (Params: TEmbeddingParams)
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
    function Create(ParamProc: TProc<TEmbeddingParams>): TEmbeddings; overload;
    /// <summary>
    /// Feature extraction is the task of converting a text into a vector (often called “embedding”).
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TEmbeddingParams</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynEmbeddings</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Embeddings.Create(
    ///   procedure (Params: TEmbeddingParams)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynEmbeddings
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
    ///        procedure (Sender: TObject; Value: TImageClassification)
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
    procedure Create(ParamProc: TProc<TEmbeddingParams>; CallBacks: TFunc<TAsynEmbeddings>); overload;
  end;

implementation

{ TEmbeddingParams }

function TEmbeddingParams.Inputs(const Value: string): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('inputs', Value));
end;

function TEmbeddingParams.Normalize(const Value: Boolean): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('normalize', Value));
end;

function TEmbeddingParams.PromptName(const Value: string): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('prompt_name', Value));
end;

function TEmbeddingParams.Truncate(const Value: Boolean): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('truncate', Value));
end;

function TEmbeddingParams.TruncationDirection(
  const Value: TTruncationDirection): TEmbeddingParams;
begin
  Result := TEmbeddingParams(Add('truncation_direction', Value.ToString));
end;

{ TEmbeddingsRoute }

function TEmbeddingsRoute.Create(
  ParamProc: TProc<TEmbeddingParams>): TEmbeddings;
begin
  Result := API.Post<TEmbeddings, TEmbeddingParams>('models', ParamProc);
end;

procedure TEmbeddingsRoute.Create(ParamProc: TProc<TEmbeddingParams>;
  CallBacks: TFunc<TAsynEmbeddings>);
begin
  with TAsynCallBackExec<TAsynEmbeddings, TEmbeddings>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TEmbeddings
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

end.
