unit HuggingFace.Chat;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, Rest.Json,
  REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Schema, HuggingFace.Functions.Core, HuggingFace.Async.Support,
  HuggingFace.Types;

type
  TContentPayload = class(TJSONParam)
  public
    /// <summary>
    /// Text of the context.
    /// </summary>
    function Text(const Value: string): TContentPayload;
    /// <summary>
    /// Possible values: text, image_url.
    /// </summary>
    function &Type(const Value: TContentType): TContentPayload;
    /// <summary>
    /// Url of the image.
    /// </summary>
    function ImageUrl(const Value: string): TContentPayload;
  end;

  TPayload = class(TJSONParam)
  public
    /// <summary>
    /// Sets a single string as the content of the message.
    /// </summary>
    /// <param name="Value">
    /// A string representing the message content.
    /// </param>
    /// <returns>
    /// The updated <c>TPayload</c> instance, enabling method chaining.
    /// </returns>
    function Content(const Value: string): TPayload; overload;
    /// <summary>
    /// Sets a single string as the content of the message.
    /// </summary>
    /// <param name="Value">
    /// A string representing the message content.
    /// </param>
    /// <param name="Images">
    /// Array of images urls
    /// </param>
    /// <returns>
    /// The updated <c>TPayload</c> instance, enabling method chaining.
    /// </returns>
    function Content(const Value: string; const Images: TArray<string>): TPayload; overload;
    /// <summary>
    /// Specifies the role of the message sender.
    /// </summary>
    /// <param name="Value">
    /// A <c>TRoleType</c> enum value representing the role (user, assistant, system, or tool).
    /// </param>
    /// <returns>
    /// The updated <c>TPayload</c> instance, enabling method chaining.
    /// </returns>
    /// <remarks>
    /// Use this method to define the sender's role for the current message,
    /// which is critical for establishing context in multi-turn conversations.
    /// </remarks>
    function Role(const Value: TRoleType): TPayload;
    /// <summary>
    /// Name of a function
    /// </summary>
    function Name(const Value: string): TPayload;
    /// <summary>
    /// Creates a user message with the specified content.
    /// </summary>
    /// <param name="Value">
    /// The text content of the user message.
    /// </param>
    /// <returns>
    /// A <c>Payload</c> instance representing a user message.
    /// </returns>
    class function User(const Value: string): TPayload; overload;
    /// <summary>
    /// Creates a user message with text content and an array of image URLs.
    /// </summary>
    /// <param name="Value">
    /// The text content of the user message.
    /// </param>
    /// <param name="Images">
    /// An array of strings, each representing an image URL to include in the message.
    /// </param>
    /// <returns>
    /// A <c>TPayload</c> instance representing a user message with images.
    /// </returns>
    /// <remarks>
    /// This method is useful for messages containing both text and visual content.
    /// Each image URL is included in the payload as a separate JSON element.
    /// </remarks>
    class function User(const Value: string; const Images: TArray<string>): TPayload; overload;
    /// <summary>
    /// Creates an assistant message with the specified content.
    /// </summary>
    /// <param name="Value">
    /// The text content of the assistant message.
    /// </param>
    /// <returns>
    /// A <c>TPayload</c> instance representing an assistant message.
    /// </returns>
    class function Assistant(const Value: string): TPayload;
    /// <summary>
    /// Creates a system message with the specified content.
    /// </summary>
    /// <param name="Value">
    /// The text content of the system message.
    /// </param>
    /// <returns>
    /// A <c>TPayload</c> instance representing a system message.
    /// </returns>
    /// <remarks>
    /// System messages are often used for configuring the chat session or providing
    /// context before any user or assistant interactions.
    /// </remarks>
    class function System(const Value: string): TPayload; overload;
  end;

  TResponseFormat = class(TJSONParam)
  public
    /// <summary>
    /// Possible values: regex, json
    /// </summary>
    function &Type(const Value: TResponseFormatType): TResponseFormat;
    /// <summary>
    /// Depending on the type :
    /// <para>
    /// JSON : A string that represents a JSON Schema. JSON Schema is a declarative language that allows
    /// to annotate JSON documents with types and descriptions.
    /// </para>
    /// <para>
    /// REGEX : A string that represents a regular expression value.
    /// </para>
    /// </summary>
    function Value(const Value: string): TResponseFormat;
    /// <summary>
    /// Create an instance of TResponseFormat as REGEX type
    /// </summary>
    class function Regex(const Value: string): TResponseFormat;
    /// <summary>
    /// Create an instance of TResponseFormat as JSON type
    /// </summary>
    class function Json(const Value: TSchemaParams): TResponseFormat;
  end;

  TChatPayload = class(TJSONChatParam)
  public
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing
    /// frequency in the text so far, decreasing the model’s likelihood to repeat the same line verbatim.
    /// </summary>
    function FrequencyPenalty(const Value: Double): TChatPayload;
    /// <summary>
    /// Whether to return log probabilities of the output tokens or not. If true, returns the log
    /// probabilities of each output token returned in the content of message.
    /// </summary>
    function Logprobs(const Value: Boolean): TChatPayload;
    /// <summary>
    /// The maximum number of tokens that can be generated in the chat completion.
    /// </summary>
    function MaxTokens(const Value: Integer): TChatPayload;
    /// <summary>
    /// A list of messages comprising the conversation so far.
    /// </summary>
    function Messages(const Value: TArray<TPayload>): TChatPayload;
    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear
    /// in the text so far, increasing the model’s likelihood to talk about new topics
    /// </summary>
    function PresencePenalty(const Value: Double): TChatPayload;
    /// <summary>
    /// Seeds the sampling for deterministic output.
    /// </summary>
    function Seed(const Value: Integer): TChatPayload;
    /// <summary>
    /// Up to 4 sequences where the API will stop generating further tokens.
    /// </summary>
    function Stop(const Value: TArray<string>): TChatPayload;
    /// <summary>
    /// Enables token streaming for partial responses.
    /// </summary>
    function Stream(const Value: Boolean): TChatPayload;
    /// <summary>
    /// If set, an additional chunk will be streamed before the data: [DONE] message. The usage field
    /// on this chunk shows the token usage statistics for the entire request, and the choices field
    /// will always be an empty array. All other chunks will also include a usage field, but with a
    /// null value.
    /// </summary>
    function StreamOptions(const Value: Boolean): TChatPayload;
    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output
    /// more random, while lower values like 0.2 will make it more focused and deterministic.
    /// </summary>
    /// <remarks>
    /// We generally recommend altering this or top_p but not both.
    /// </remarks>
    function Temperature(const Value: Double): TChatPayload;
    /// <summary>
    /// An integer between 0 and 5 specifying the number of most likely tokens to return at each token
    /// position, each with an associated log probability. logprobs must be set to true if this parameter
    /// is used.
    /// </summary>
    function TopLogprobs(const Value: Integer): TChatPayload;
    /// <summary>
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers
    /// the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising
    /// the top 10% probability mass are considered.
    /// </summary>
    function TopP(const Value: Double): TChatPayload;
    /// <summary>
    /// Set the response_format
    /// </summary>
    function ResponseFormat(const Value: string): TChatPayload; overload;
    /// <summary>
    /// Set the response_format
    /// </summary>
    function ResponseFormat(const Value: TSchemaParams): TChatPayload; overload;
    /// <summary>
    /// Set the tool_choice
    /// </summary>
    function ToolChoice(const Value: TToolChoiceType): TChatPayload; overload;
    /// <summary>
    /// Set the tool_choice
    /// </summary>
    function ToolChoice(const Value: string): TChatPayload; overload;
    /// <summary>
    /// A prompt to be appended before the tools.
    /// </summary>
    function ToolPrompt(const Value: string): TChatPayload;
    /// <summary>
    /// A list of tools the model may call. Currently, only functions are supported as a tool. Use this
    /// to provide a list of functions the model may generate JSON inputs for.
    /// </summary>
    function Tools(const Value: TArray<IFunctionCore>): TChatPayload;
  end;

  TFunctionCalled = class
  private
    [JsonReflectAttribute(ctString, rtString, TArgsFixInterceptor)]
    FArguments: string;
    FDescription: string;
    FName: string;
  public
    /// <summary>
    /// A JSON-formatted string representing the arguments to pass to the function.
    /// </summary>
    /// <remarks>
    /// The arguments should be formatted as a JSON object, matching the expected parameters of the function.
    /// </remarks>
    property Arguments: string read FArguments write FArguments;
    /// <summary>
    /// Description of the tool called.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// The name of the function to be called.
    /// </summary>
    /// <remarks>
    /// This should match the name of a function defined in the tools available to the model.
    /// </remarks>
    property Name: string read FName write FName;
  end;

  TToolCalls = class
  private
    FId: string;
    FType: string;
    FFunction: TFunctionCalled;
  public
    /// <summary>
    /// A unique identifier for the tool call.
    /// </summary>
    /// <remarks>
    /// The identifier can be used to track or reference specific tool calls within the conversation.
    /// </remarks>
    property Id: string read FId write FId;
    /// <summary>
    /// The type of the tool being called (e.g., "function").
    /// </summary>
    /// <remarks>
    /// The type indicates the nature of the tool, such as whether it's a function call or another kind of tool.
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Details of the function to be called, including its name and arguments.
    /// </summary>
    /// <remarks>
    /// If the tool call is a function call, this property contains the specifics of the function invocation.
    /// </remarks>
    property &Function: TFunctionCalled read FFunction write FFunction;
    destructor Destroy; override;
  end;

  TChoiceMessage = class
  private
    FContent: string;
    [JsonReflectAttribute(ctString, rtString, TRoleTypeInterceptor)]
    FRole: TRoleType;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolCalls>;
  public
    /// <summary>
    /// The textual content of the message.
    /// </summary>
    /// <remarks>
    /// The content may include the assistant's response, user input, or system prompts.
    /// </remarks>
    property Content: string read FContent write FContent;
    /// <summary>
    /// The role of the message sender (e.g., user, assistant, system, tool).
    /// </summary>
    property Role: TRoleType read FRole write FRole;
    /// <summary>
    /// An array of tool calls made by the model during this message.
    /// </summary>
    /// <remarks>
    /// If the model invokes any tools (e.g., functions) during its response generation, those tool calls are recorded here.
    /// </remarks>
    property ToolCalls: TArray<TToolCalls> read FToolCalls write FToolCalls;
    destructor Destroy; override;
  end;

  TTopLogprobs = class
  private
    FLogprob: Double;
    FToken: string;
  public
    /// <summary>
    /// The log probability of the token.
    /// </summary>
    /// <remarks>
    /// Log probabilities are in natural logarithm base and represent the likelihood of the token.
    /// </remarks>
    property Logprob: Double read FLogprob write FLogprob;
    /// <summary>
    /// The token text as predicted by the model.
    /// </summary>
    property Token: string read FToken write FToken;
  end;

  TLogprobContent = class
  private
    FLogprob: Double;
    FToken: string;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TTopLogprobs;
  public
    /// <summary>
    /// The log probability of the token.
    /// </summary>
    /// <remarks>
    /// Provides the likelihood of the token appearing in this context.
    /// </remarks>
    property Logprob: Double read Flogprob write Flogprob;
    /// <summary>
    /// The token text as generated in the content.
    /// </summary>
    property Token: string read FToken write FToken;
    /// <summary>
    /// An array of top alternative tokens with their log probabilities.
    /// </summary>
    /// <remarks>
    /// This allows for analysis of other tokens the model considered at this position and their respective probabilities.
    /// </remarks>
    property TopLogprobs: TTopLogprobs read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  TLogprobs = class
  private
    FContent: TArray<TLogprobContent>;
  public
    /// <summary>
    /// An array of log probabilities for content tokens.
    /// </summary>
    property Content: TArray<TLogprobContent> read FContent write FContent;
    destructor Destroy; override;
  end;

  TChoice = class
  private
    [JsonNameAttribute('finish_reason')]
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    FIndex: Integer;
    FMessage: TChoiceMessage;
    FLogprobs: TLogprobs;
    FDelta: TChoiceMessage;
  public
    /// <summary>
    /// The reason why the model stopped generating the output.
    /// </summary>
    /// <remarks>
    /// Indicates whether the model stopped due to reaching the end of the message, hitting a stop sequence, or other reasons.
    /// </remarks>
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    /// <summary>
    /// Index when SSE processing
    /// </summary>
    property Index: Integer read FIndex write FIndex;
    /// <summary>
    /// The message generated by the model.
    /// </summary>
    /// <remarks>
    /// Contains the actual content of the model's response.
    /// </remarks>
    property Message: TChoiceMessage read FMessage write FMessage;
    /// <summary>
    /// Incremental message content for streaming responses.
    /// </summary>
    /// <remarks>
    /// Used when responses are streamed token by token; contains the latest delta in the message.
    /// </remarks>
    property Delta: TChoiceMessage read FDelta write FDelta;
    /// <summary>
    /// The log probabilities associated with the tokens in the message.
    /// </summary>
    /// <remarks>
    /// Populated if log probabilities were requested; provides detailed token-level probability information.
    /// </remarks>
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;
    destructor Destroy; override;
  end;

  TUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
  public
    /// <summary>
    /// Tokens used for the completion
    /// </summary>
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;
    /// <summary>
    /// Tokens used for the context prompt
    /// </summary>
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;
    /// <summary>
    /// Sum tokens for the completion operation
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
  end;

  TChat = class
  private
    FId: string;
    FChoices: TArray<TChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FUsage: TUsage;
  public
    /// <summary>
    /// The unique identifier for the chat completion.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// The timestamp when the completion was created.
    /// </summary>
    /// <remarks>
    /// Represented as seconds since the Unix epoch.
    /// </remarks>
    property Created: Int64 read FCreated write FCreated;
    /// <summary>
    /// An array of choices returned by the model.
    /// </summary>
    /// <remarks>
    /// Each choice represents a possible completion generated by the model.
    /// </remarks>
    property Choices: TArray<TChoice> read FChoices write FChoices;
    /// <summary>
    /// Model used when the response processing
    /// </summary>
    property Model: string read FModel write FModel;
    /// <summary>
    /// A fingerprint representing the system state.
    /// </summary>
    /// <remarks>
    /// Used for internal tracking and debugging purposes.
    /// </remarks>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;
    /// <summary>
    /// Usage information for the completion request.
    /// </summary>
    property Usage: TUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChat</c> type extends the <c>TAsynParams&lt;TChat&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynChat = TAsynCallBack<TChat>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TChat</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynChatStream</c> type extends the <c>TAsynStreamParams&lt;TChat&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynChatStream = TAsynStreamCallBack<TChat>;

  /// <summary>
  /// Represents a callback procedure used during the reception of responses from a chat request in streaming mode.
  /// </summary>
  /// <param name="Chat">
  /// The <c>TChat</c> object containing the current information about the response generated by the model.
  /// If this value is <c>nil</c>, it indicates that the data stream is complete.
  /// </param>
  /// <param name="IsDone">
  /// A boolean flag indicating whether the streaming process is complete.
  /// If <c>True</c>, it means the model has finished sending all response data.
  /// </param>
  /// <param name="Cancel">
  /// A boolean flag that can be set to <c>True</c> within the callback to cancel the streaming process.
  /// If set to <c>True</c>, the streaming will be terminated immediately.
  /// </param>
  /// <remarks>
  /// This callback is invoked multiple times during the reception of the response data from the model.
  /// It allows for real-time processing of received messages and interaction with the user interface or other systems
  /// based on the state of the data stream.
  /// When the <c>IsDone</c> parameter is <c>True</c>, it indicates that the model has finished responding,
  /// and the <c>Chat</c> parameter will be <c>nil</c>.
  /// </remarks>
  TChatEvent = reference to procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean);

  TChatRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Generate a response given a list of messages in a conversational context, supporting both
    /// conversational Language Models (LLMs) and conversational Vision-Language Models (VLMs).
    /// This is a subtask of text-generation and image-text-to-text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TChatPayload</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TChat</c> object containing the Segmentation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Chat.Completion(
    ///     procedure (Params: TChatPayload)
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
    function Completion(ParamProc: TProc<TChatPayload>): TChat; overload;
    /// <summary>
    /// Generate a response given a list of messages in a conversational context, supporting both
    /// conversational Language Models (LLMs) and conversational Vision-Language Models (VLMs).
    /// This is a subtask of text-generation and image-text-to-text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageSegmentationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynChat</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Chat.Completion(
    ///   procedure (Params: TChatPayload)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynChat
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
    ///        procedure (Sender: TObject; Value: TChat)
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
    procedure Completion(ParamProc: TProc<TChatPayload>; CallBacks: TFunc<TAsynChat>); overload;
    /// <summary>
    /// Generate a streamed response given a list of messages in a conversational context, supporting
    /// both conversational Language Models (LLMs) and conversational Vision-Language Models (VLMs).
    /// This is a subtask of text-generation and image-text-to-text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TChatPayload</c> parameters.
    /// </param>
    /// <param name="Event">
    /// A callback of type <c>TChatEvent</c> that is triggered with each chunk of data received during the streaming process. It includes the current state of the <c>TChat</c> object, a flag indicating if the stream is done, and a boolean to handle cancellation.
    /// </param>
    /// <returns>
    /// Returns <c>True</c> if the streaming process started successfully, <c>False</c> otherwise.
    /// </returns>
    /// <remarks>
    /// This method initiates a chat request in streaming mode, where the response is delivered incrementally in real-time.
    /// The <c>Event</c> callback will be invoked multiple times as tokens are received.
    /// When the response is complete, the <c>IsDone</c> flag will be set to <c>True</c>, and the <c>Chat</c> object will be <c>nil</c>.
    /// The streaming process can be interrupted by setting the <c>Cancel</c> flag to <c>True</c> within the event.
    ///
    /// Example usage:
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    ///   HuggingFace.Chat.CompletionStream(
    ///     procedure (Params: TChatPayload)
    ///     begin
    ///       // Define chat parameters
    ///       Params.Stream(True);
    ///     end,
    ///
    ///     procedure(var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       // Handle displaying
    ///     end);
    /// </code>
    /// </remarks>
    function CompletionStream(ParamProc: TProc<TChatPayload>; Event: TChatEvent): Boolean; overload;
    /// <summary>
    /// Generate a streamed response given a list of messages in a conversational context, supporting
    /// both conversational Language Models (LLMs) and conversational Vision-Language Models (VLMs).
    /// This is a subtask of text-generation and image-text-to-text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TChatPayload</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <c>TAsynChatStream</c> record which contains event handlers for managing different stages of the streaming process: progress updates, success, errors, and cancellation.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous chat operation in streaming mode, where tokens are progressively received and processed.
    /// The provided event handlers allow for handling progress (i.e., receiving tokens in real time), detecting success, managing errors, and enabling cancellation logic.
    /// <code>
    /// CheckBox1.Checked := False;  //Click to stop the streaming
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Chat.CompletionStream(
    ///   procedure(Params: TChatParams)
    ///   begin
    ///     // Define chat parameters
    ///     Params.Stream(True);
    ///   end,
    ///
    ///   function: TAsynChatStream
    ///   begin
    ///     Result.Sender := Memo1; // Instance passed to callback parameter
    ///     Result.OnProgress :=
    ///         procedure (Sender: TObject; Chat: TChat)
    ///         begin
    ///           // Handle progressive updates to the chat response
    ///         end;
    ///     Result.OnSuccess :=
    ///         procedure (Sender: TObject)
    ///         begin
    ///           // Handle success when the operation completes
    ///         end;
    ///     Result.OnError :=
    ///         procedure (Sender: TObject; Value: string)
    ///         begin
    ///           // Handle error message
    ///         end;
    ///     Result.OnDoCancel :=
    ///         function: Boolean
    ///         begin
    ///           Result := CheckBox1.Checked; // Click on checkbox to cancel
    ///         end;
    ///     Result.OnCancellation :=
    ///         procedure (Sender: TObject)
    ///         begin
    ///           // Processing when process has been canceled
    ///         end;
    ///   end);
    /// </code>
    /// </remarks>
    procedure CompletionStream(ParamProc: TProc<TChatPayload>; CallBacks: TFunc<TAsynChatStream>); overload;
  end;

implementation

uses
  System.StrUtils, System.Rtti, HuggingFace.Async.Params, System.Threading,
  HuggingFace.NetEncoding.Base64;

{ TChatPayload }

function TChatPayload.FrequencyPenalty(const Value: Double): TChatPayload;
begin
  Result := TChatPayload(Add('frequency_penalty', Value));
end;

function TChatPayload.Logprobs(const Value: Boolean): TChatPayload;
begin
  Result := TChatPayload(Add('logprobs', Value));
end;

function TChatPayload.MaxTokens(const Value: Integer): TChatPayload;
begin
  Result := TChatPayload(Add('max_tokens', Value));
end;

function TChatPayload.Messages(const Value: TArray<TPayload>): TChatPayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TChatPayload(Add('messages', JSONArray));
end;

function TChatPayload.PresencePenalty(const Value: Double): TChatPayload;
begin
  Result := TChatPayload(Add('presence_penalty', Value));
end;

function TChatPayload.ResponseFormat(const Value: TSchemaParams): TChatPayload;
begin
  Result := TChatPayload(Add('response_format', TResponseFormat.Json(Value).Detach));
end;

function TChatPayload.ResponseFormat(const Value: string): TChatPayload;
begin
  Result := TChatPayload(Add('response_format', TResponseFormat.Regex(Value).Detach));
end;

function TChatPayload.Seed(const Value: Integer): TChatPayload;
begin
  Result := TChatPayload(Add('seed', Value));
end;

function TChatPayload.Stop(const Value: TArray<string>): TChatPayload;
begin
  Result := TChatPayload(Add('stop', Value));
end;

function TChatPayload.Stream(const Value: Boolean): TChatPayload;
begin
  Result := TChatPayload(Add('stream', Value));
end;

function TChatPayload.StreamOptions(const Value: Boolean): TChatPayload;
begin
  Result := TChatPayload(Add('stream_options', TJSONObject.Create.AddPair('include_usage', Value)));
end;

function TChatPayload.Temperature(const Value: Double): TChatPayload;
begin
  Result := TChatPayload(Add('temperature', Value));
end;

function TChatPayload.ToolChoice(const Value: TToolChoiceType): TChatPayload;
begin
  Result := TChatPayload(Add('tool_choice', Value.ToString));
end;

function TChatPayload.ToolChoice(const Value: string): TChatPayload;
begin
  var choice := TJSONObject.Create.AddPair('function', TJSONObject.Create.AddPair('name', Value));
  Result := TChatPayload(Add('tool_choice', choice));
end;

function TChatPayload.ToolPrompt(const Value: string): TChatPayload;
begin
  Result := TChatPayload(Add('tool_prompt', Value));
end;

function TChatPayload.Tools(const Value: TArray<IFunctionCore>): TChatPayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToJson);
  Result := TChatPayload(Add('tools', JSONArray));
end;

function TChatPayload.TopLogprobs(const Value: Integer): TChatPayload;
begin
  Result := TChatPayload(Add('top_logprobs', Value));
end;

function TChatPayload.TopP(const Value: Double): TChatPayload;
begin
  Result := TChatPayload(Add('top_p', Value));
end;

{ TPayload }

function TPayload.Content(const Value: string): TPayload;
begin
  Result := TPayload(Add('content', Value));
end;

class function TPayload.Assistant(const Value: string): TPayload;
begin
  Result := TPayload.Create.Content(Value).Role(TRoleType.assistant);
end;

function TPayload.Content(const Value: string;
  const Images: TArray<string>): TPayload;
begin
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(TContentPayload.Create.Text(Value).Detach);
  for var Item in Images do
    JSONArray.Add(TContentPayload.Create.ImageUrl(Item).Detach);
  Result := TPayload(Add('content', JSONArray));
end;

function TPayload.Name(const Value: string): TPayload;
begin
  Result := TPayload(Add('name', Value));
end;

function TPayload.Role(const Value: TRoleType): TPayload;
begin
  Result := TPayload(Add('role', Value.ToString));
end;

class function TPayload.System(const Value: string): TPayload;
begin
  Result := TPayload.Create.Content(Value).Role(TRoleType.system);
end;

class function TPayload.User(const Value: string;
  const Images: TArray<string>): TPayload;
begin
  Result := TPayload.Create.Content(Value, Images).Role(TRoleType.user);
end;

class function TPayload.User(const Value: string): TPayload;
begin
  Result := TPayload.Create.Content(Value).Role(TRoleType.user);
end;

{ TContentPayload }

function TContentPayload.&Type(
  const Value: TContentType): TContentPayload;
begin
  Result := TContentPayload(Add('type', Value.ToString));
end;

function TContentPayload.ImageUrl(const Value: string): TContentPayload;
begin
  if not Value.ToLower.StartsWith('http') then
    raise Exception.Create('image url not valid');
  Result := TContentPayload(Add('image_url', TJSONObject.Create.AddPair('url', Value))).&Type(image_url);
end;

function TContentPayload.Text(const Value: string): TContentPayload;
begin
  Result := TContentPayload(Add('text', Value)).&Type(TContentType.text);
end;

{ TChoice }

destructor TChoice.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  if Assigned(FLogprobs) then
    FLogprobs.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ TChat }

destructor TChat.Destroy;
begin
  for var Item in FChoices  do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

{ TChatRoute }

procedure TChatRoute.Completion(ParamProc: TProc<TChatPayload>;
  CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Completion(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TChatRoute.Completion(ParamProc: TProc<TChatPayload>): TChat;
begin
  Result := API.Post<TChat, TChatPayload>('models', ParamProc);
end;

procedure TChatRoute.CompletionStream(ParamProc: TProc<TChatPayload>;
  CallBacks: TFunc<TAsynChatStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynChatStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;

  var Task: ITask := TTask.Create(
        procedure()
        begin
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CompletionStream(ParamProc,
                procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender)
                        end);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Chat) then
                    begin
                      var LocalChat := Chat;
                      Chat := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalChat);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalChat.Free;
                          end;
                        end);
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
                      if Assigned(OnSuccess) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnSuccess(Sender);
                        end);
                    end;
                end);
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
        end);
  Task.Start;
end;

function TChatRoute.CompletionStream(ParamProc: TProc<TChatPayload>;
  Event: TChatEvent): Boolean;
var
  Response: TStringStream;
  RetPos: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    RetPos := 0;
    Result := API.Post<TChatPayload>('models', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
      var
        IsDone: Boolean;
        Data: string;
        Chat: TChat;
        TextBuffer: string;
        Line: string;
        Ret: Integer;
      begin
        try
          TextBuffer := Response.DataString;
        except
          on E: EEncodingError do
            Exit;
        end;
        repeat
          Ret := TextBuffer.IndexOf(#10, RetPos);
          if Ret < 0 then
            Continue;
          Line := TextBuffer.Substring(RetPos, Ret - RetPos);
          RetPos := Ret + 1;
          if Line.IsEmpty or Line.StartsWith(#10) then
            Continue;
          Chat := nil;
          Data := Line.Replace('data: ', '').Trim([' ', #13, #10]);
          IsDone := Data = '[DONE]';

          if not IsDone then
          try
            Chat := TJson.JsonToObject<TChat>(Data);
          except
            Chat := nil;
          end;

          try
            Event(Chat, IsDone, AAbort);
          finally
            Chat.Free;
          end;
        until Ret < 0;
      end);
    finally
      Response.Free;
    end;
end;

{ TResponseFormat }

class function TResponseFormat.Json(
  const Value: TSchemaParams): TResponseFormat;
begin
  Result := TResponseFormat.Create.Value(Value.ToJsonString(True)).&Type(TResponseFormatType.json);
end;

class function TResponseFormat.Regex(const Value: string): TResponseFormat;
begin
  Result := TResponseFormat.Create.Value(Value).&Type(TResponseFormatType.Regex);
end;

function TResponseFormat.&Type(
  const Value: TResponseFormatType): TResponseFormat;
begin
  Result := TResponseFormat(Add('type', Value.ToString));
end;

function TResponseFormat.Value(const Value: string): TResponseFormat;
begin
  Result := TResponseFormat(Add('value', Value));
end;

{ TLogprobContent }

destructor TLogprobContent.Destroy;
begin
  if Assigned(FTopLogprobs) then
    FTopLogprobs.Free;
  inherited;
end;

{ TLogprobs }

destructor TLogprobs.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  inherited;
end;

{ TToolCalls }

destructor TToolCalls.Destroy;
begin
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TChoiceMessage }

destructor TChoiceMessage.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

end.
