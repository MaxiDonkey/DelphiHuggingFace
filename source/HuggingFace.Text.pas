unit HuggingFace.Text;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, Rest.Json,
  REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Async.Support, HuggingFace.Types, HuggingFace.Chat, HuggingFace.Schema;

type
  {$REGION 'Question Answering'}

  TQuestionAnsweringInputs = class(TJSONParam)
  public
    /// <summary>
    /// The context to be used for answering the question.
    /// </summary>
    function Context(const Value: string): TQuestionAnsweringInputs;
    /// <summary>
    /// The question to be answered.
    /// </summary>
    function Question(const Value: string): TQuestionAnsweringInputs;
  end;

  TQuestionAnsweringParameters = class(TJSONParam)
  public
    /// <summary>
    /// The number of answers to return (will be chosen by order of likelihood).
    /// </summary>
    /// <remarks>
    /// Note that we return less than topk answers if there are not enough options available within
    /// the context.
    /// </remarks>
    function TopK(const Value: Integer): TQuestionAnsweringParameters;
    /// <summary>
    /// If the context is too long to fit with the question for the model, it will be split in several
    /// chunks with some overlap. This argument controls the size of that overlap.
    /// </summary>
    function DocStride(const Value: Integer): TQuestionAnsweringParameters;
    /// <summary>
    /// The maximum length of predicted answers (e.g., only answers with a shorter length are considered).
    /// </summary>
    function MaxAnswerLen(const Value: Integer): TQuestionAnsweringParameters;
    /// <summary>
    /// The maximum length of the total sentence (context + question) in tokens of each chunk passed to
    /// the model. The context will be split in several chunks (using docStride as overlap) if needed.
    /// </summary>
    function MaxSeqLen(const Value: Integer): TQuestionAnsweringParameters;
    /// <summary>
    /// The maximum length of the question after tokenization. It will be truncated if needed.
    /// </summary>
    function MaxQuestionLen(const Value: Integer): TQuestionAnsweringParameters;
    /// <summary>
    /// Whether to accept impossible as an answer.
    /// </summary>
    function HandleImpossibleAnswer(const Value: Boolean): TQuestionAnsweringParameters;
    /// <summary>
    /// Attempts to align the answer to real words. Improves quality on space separated languages.
    /// Might hurt on non-space-separated languages (like Japanese or Chinese)
    /// </summary>
    function AlignToWords(const Value: Boolean): TQuestionAnsweringParameters;
  end;

  TQuestionAnsweringParam = class(TJSONModelParam)
  public
    /// <summary>
    /// One (context, question) pair to answer.
    /// </summary>
    function Inputs(const Question: string): TQuestionAnsweringParam; overload;
    /// <summary>
    /// One (context, question) pair to answer.
    /// </summary>
    function Inputs(const Question, Context: string): TQuestionAnsweringParam; overload;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TQuestionAnsweringParameters>): TQuestionAnsweringParam;
  end;

  TQuestionAnsweringItem = class
  private
    FAnswer: string;
    FScore: Double;
    FStart: Integer;
    FEnd: Integer;
  public
    /// <summary>
    /// The answer to the question.
    /// </summary>
    property Answer: string read FAnswer write FAnswer;
    /// <summary>
    /// The probability associated to the answer.
    /// </summary>
    property Score: Double read FScore write FScore;
    /// <summary>
    /// The character position in the input where the answer begins.
    /// </summary>
    property Start: Integer read FStart write FStart;
    /// <summary>
    /// The character position in the input where the answer ends.
    /// </summary>
    property &End: Integer read FEnd write FEnd;
  end;

  TQuestionAnswering = class(TQuestionAnsweringItem)
  private
    FItems: TArray<TQuestionAnsweringItem>;
  public
    /// <summary>
    /// If output is an array of objects.
    /// </summary>
    property Items: TArray<TQuestionAnsweringItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TQuestionAnswering</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynQuestionAnswering</c> type extends the <c>TAsynParams&lt;TQuestionAnswering&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynQuestionAnswering = TAsynCallBack<TQuestionAnswering>;

  {$ENDREGION}

  {$REGION 'Summarization'}

  TSummarizationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Whether to clean up the potential extra spaces in the text output.
    /// </summary>
    function CleanUpTokenizationSpaces(const Value: Boolean): TSummarizationParameters;
    /// <summary>
    /// Possible values: do_not_truncate, longest_first, only_first, only_second.
    /// </summary>
    function Truncation(const Value: TTextTruncationType): TSummarizationParameters;
    /// <summary>
    /// Additional parametrization of the text generation algorithm.
    /// </summary>
    function GenerateParameters(const Value: TJSONObject): TSummarizationParameters;
  end;

  TSummarizationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input text to summarize.
    /// </summary>
    function Inputs(const Value: string): TSummarizationParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TSummarizationParameters>): TSummarizationParam;
  end;

  TSummarizationItem = class
  private
    [JsonNameAttribute('summary_text')]
    FSummaryText: string;
  public
    /// <summary>
    /// The summarized text.
    /// </summary>
    property SummaryText: string read FSummaryText write FSummaryText;
  end;

  TSummarization = class
  private
    FItems: TArray<TSummarizationItem>;
  public
    property Items: TArray<TSummarizationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSummarization</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynSummarization</c> type extends the <c>TAsynParams&lt;TSummarization&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynSummarization = TAsynCallBack<TSummarization>;

  {$ENDREGION}

  {$REGION 'Table Question Answering'}

  TRow = record
  private
    FFieldName: string;
    FValues: TArray<string>;
  public
    /// <summary>
    /// Row name of the table
    /// </summary>
    property FieldName: string read FFieldName write FFieldName;
    /// <summary>
    /// Row values of the table
    /// </summary>
    property Values: TArray<string> read FValues write FValues;
    class function Create(const FieldName: string; Values: TArray<string>): TRow; static;
  end;

  TTableQAInputs = class(TJSONParam)
  public
    /// <summary>
    /// The table to serve as context for the questions.
    /// </summary>
    function Table(const Value: TArray<TRow>): TTableQAInputs;
    /// <summary>
    /// The question to be answered about the table
    /// </summary>
    function Query(const Value: string): TTableQAInputs;
  end;

  TTableQAParameters = class(TJSONParam)
  public
    /// <summary>
    /// Possible values: do_not_pad, longest, max_length.
    /// </summary>
    function Padding(const Value: TPaddingType): TTableQAParameters;
    /// <summary>
    /// Whether to do inference sequentially or as a batch. Batching is faster, but models like SQA
    /// require the inference to be done sequentially to extract relations within sequences, given
    /// their conversational nature.
    /// </summary>
    function Sequential(const Value: Boolean): TTableQAParameters;
    /// <summary>
    /// Activates and controls truncation.
    /// </summary>
    function Truncation(const Value: Boolean): TTableQAParameters;
  end;

  TTableQAParam = class(TJSONModelParam)
  public
    /// <summary>
    /// One (table, question) pair to answer.
    /// </summary>
    function Inputs(const Query: string; const Table: TArray<TRow>): TTableQAParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TTableQAParameters>): TTableQAParam;
  end;

  TTableQA = class
  private
    FAnswer: string;
    FCoordinates: TCoordinate;
    FCells: TArray<string>;
    FAggregator: string;
  public
    /// <summary>
    /// The answer of the question given the table. If there is an aggregator, the answer will
    /// be preceded by AGGREGATOR >.
    /// </summary>
    property Answer: string read FAnswer write FAnswer;
    /// <summary>
    /// Coordinates of the cells of the answers.
    /// </summary>
    property Coordinates: TCoordinate read FCoordinates write FCoordinates;
    /// <summary>
    /// List of strings made up of the answer cell values.
    /// </summary>
    property Cells: TArray<string> read FCells write FCells;
    /// <summary>
    /// If the model has an aggregator, this returns the aggregator.
    /// </summary>
    property Aggregator: string read FAggregator write FAggregator;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTableQA</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTableQA</c> type extends the <c>TAsynParams&lt;TTableQA&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTableQA = TAsynCallBack<TTableQA>;

  {$ENDREGION}

  {$REGION 'Text Classification'}

  TTextClassificationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Possible values: sigmoid, softmax, none.
    /// </summary>
    function FunctionToApply(const Value: TFunctionClassification): TTextClassificationParameters;
    /// <summary>
    /// When specified, limits the output to the top K most probable classes.
    /// </summary>
    function TopK(const Value: Integer): TTextClassificationParameters;
  end;

  TTextClassificationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The text to classify.
    /// </summary>
    function Inputs(const Value: string): TTextClassificationParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(const FunctionToApply: TFunctionClassification; const TopK: Integer = -1): TTextClassificationParam; overload;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(const TopK: Integer): TTextClassificationParam; overload;
  end;

  TTextClassificationItem = class
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

  TTextClassificationArray = class
  private
    FItems: TArray<TTextClassificationItem>;
  public
    property Items: TArray<TTextClassificationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  TTextClassification = class
  private
    FItems: TArray<TTextClassificationArray>;
  public
    property Items: TArray<TTextClassificationArray> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTextClassification</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTextClassification</c> type extends the <c>TAsynParams&lt;TTextClassification&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTextClassification = TAsynCallBack<TTextClassification>;

  {$ENDREGION}

  {$REGION 'Text to Image'}

  TTargetSizeParam = class(TJSONParam)
  public
    /// <summary>
    /// The width in pixel
    /// </summary>
    function Width(const Value: Integer): TTargetSizeParam;
    /// <summary>
    /// The height in pixel
    /// </summary>
    function Height(const Value: Integer): TTargetSizeParam;
  end;

  TTextToImageParameters = class(TJSONParam)
  public
    /// <summary>
    /// A higher guidance scale value encourages the model to generate images closely linked to
    /// the text prompt, but values too high may cause saturation and other artifacts.
    /// </summary>
    function GuidanceScale(const Value: Double): TTextToImageParameters;
    /// <summary>
    /// One or several prompt to guide what NOT to include in image generation.
    /// </summary>
    function NegativePrompt(const Value: TArray<string>): TTextToImageParameters;
    /// <summary>
    /// The number of denoising steps. More denoising steps usually lead to a higher quality image
    /// at the expense of slower inference.
    /// </summary>
    function NumInferenceSteps(const Value: Integer): TTextToImageParameters;
    /// <summary>
    /// The size in pixel of the output image
    /// </summary>
    function TargetSize(const Width, Height: Integer): TTextToImageParameters;
    /// <summary>
    /// Override the scheduler with a compatible one.
    /// </summary>
    function Scheduler(const Value: string): TTextToImageParameters;
    /// <summary>
    /// Seed for the random number generator.
    /// </summary>
    function Seed(const Value: Integer): TTextToImageParameters;
  end;

  TTextToImageParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input text data (sometimes called “prompt”)
    /// </summary>
    function Inputs(const Value: string): TTextToImageParam;
    /// <summary>
    /// The input text data (sometimes called “prompt”)
    /// </summary>
    function Prompt(const Value: string): TTextToImageParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TTextToImageParameters>): TTextToImageParam;
  end;

  TTextToImage = class
  private
    FFileName: string;
    FImage: string;
  public
    /// <summary>
    /// Retrieves the generated image as a <c>TStream</c>.
    /// </summary>
    /// <returns>
    /// A <c>TStream</c> containing the decoded image data.
    /// </returns>
    /// <remarks>
    /// This method decodes the base64-encoded image data and returns it as a stream.
    /// The caller is responsible for freeing the returned stream.
    /// </remarks>
    /// <exception cref="Exception">
    /// Raises an exception if both the image and video data are empty.
    /// </exception>
    function GetStream: TStream;
    /// <summary>
    /// Saves the generated image to a file.
    /// </summary>
    /// <param name="FileName">
    /// The file path where the image will be saved.
    /// </param>
    /// <remarks>
    /// This method decodes the base64-encoded image data and saves it to the specified file.
    /// </remarks>
    /// <exception cref="Exception">
    /// Raises an exception if the image data cannot be decoded or saved.
    /// </exception>
    procedure SaveToFile(const FileName: string);
    /// <summary>
    /// The output image as base-64 returned
    /// </summary>
    property Image: string read FImage write FImage;
    /// <summary>
    /// Gets the file name where the image was saved.
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
  /// Manages asynchronous callBacks for a request using <c>TTextToImage</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTextToImage</c> type extends the <c>TAsynParams&lt;TTextToImage&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTextToImage = TAsynCallBack<TTextToImage>;

  {$ENDREGION}

  {$REGION 'Token Classification'}

  TTokenClassificationParameters = class(TJSONParam)
    /// <summary>
    /// A list of labels to ignore.
    /// </summary>
    function IgnoreLabels(const Value: TArray<string>): TTokenClassificationParameters;
    /// <summary>
    /// The number of overlapping tokens between chunks when splitting the input text.
    /// </summary>
    function Stride(const Value: Integer): TTokenClassificationParameters;
    /// <summary>
    /// One of the following: asnone, simple, first, average, max
    /// </summary>
    function AggregationStrategy(const Value: TAggregationStrategyType): TTokenClassificationParameters;
  end;

  TTokenClassificationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input text data.
    /// </summary>
    function Inputs(const Value: string): TTokenClassificationParam;
    /// <summary>
    /// Define generation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TTokenClassificationParameters>): TTokenClassificationParam;
  end;

  TTokenClassificationItem = class
  private
    [JsonNameAttribute('entity_group')]
    FEntityGroup: string;
    FEntity: string;
    FScore: Double;
    FWord: string;
    FStart: Integer;
    FEnd: Integer;
  public
    /// <summary>
    /// The predicted label for a group of one or more tokens.
    /// </summary>
    property EntityGroup: string read FEntityGroup write FEntityGroup;
    /// <summary>
    /// The predicted label for a single token.
    /// </summary>
    property Entity: string read FEntity write FEntity;
    /// <summary>
    /// The associated score / probability.
    /// </summary>
    property Score: Double read FScore write FScore;
    /// <summary>
    /// The corresponding text.
    /// </summary>
    property Word: string read FWord write FWord;
    /// <summary>
    /// The character position in the input where this group begins.
    /// </summary>
    property Start: Integer read FStart write FStart;
    /// <summary>
    /// The character position in the input where this group ends.
    /// </summary>
    property &End: Integer read FEnd write FEnd;
  end;

  TTokenClassification = class
  private
    FItems: TArray<TTokenClassificationItem>;
  public
    property Items: TArray<TTokenClassificationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTokenClassification</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTokenClassification</c> type extends the <c>TAsynParams&lt;TTokenClassification&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTokenClassification = TAsynCallBack<TTokenClassification>;

  {$ENDREGION}

  {$REGION 'Translation'}

  TTranslationParameters = class(TJSONParam)
  public
    /// <summary>
    /// The source language of the text. Required for models that can translate from multiple languages.
    /// </summary>
    function SrcLang(const Value: string): TTranslationParameters;
    /// <summary>
    /// Target language to translate to. Required for models that can translate to multiple languages.
    /// </summary>
    function TgtLang(const Value: string): TTranslationParameters;
    /// <summary>
    /// Whether to clean up the potential extra spaces in the text output.
    /// </summary>
    function CleanUpTokenizationSpaces(const Value: Boolean): TTranslationParameters;
    /// <summary>
    /// Possible values: do_not_truncate, longest_first, only_first, only_second.
    /// </summary>
    function Truncation(const Value: TTextTruncationType): TTranslationParameters;
    /// <summary>
    /// Additional parametrization of the text generation algorithm.
    /// </summary>
    function GenerateParameters(const Value: TJSONObject): TTranslationParameters;
  end;

  TTranslationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The text to translate.
    /// </summary>
    function Inputs(const Value: string): TTranslationParam;
    /// <summary>
    /// Define generation parameters.
    /// </summary>
    function Parameters(ParamProc: TProcRef<TTranslationParameters>): TTranslationParam;
  end;

  TTranslationItem = class
  private
    [JsonNameAttribute('translation_text')]
    FTranslationText: string;
  public
    /// <summary>
    /// The translated text.
    /// </summary>
    property TranslationText: string read FTranslationText write FTranslationText;
  end;

  TTranslation = class
  private
    FItems: TArray<TTranslationItem>;
  public
    property Items: TArray<TTranslationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTranslation</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTranslation</c> type extends the <c>TAsynParams&lt;TTranslation&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTranslation = TAsynCallBack<TTranslation>;

  {$ENDREGION}

  {$REGION 'Zero-Shot Classification'}

  TZeroShotClassificationParameters = class(TJSONParam)
  public
    /// <summary>
    /// The set of possible class labels to classify the text into.
    /// </summary>
    function CandidateLabels(const Value: TArray<string>): TZeroShotClassificationParameters;
    /// <summary>
    /// The sentence used in conjunction with candidate_labels to attempt the text classification by
    /// replacing the placeholder with the candidate labels.
    /// </summary>
    function HypothesisTemplate(const Value: string): TZeroShotClassificationParameters;
    /// <summary>
    /// Whether multiple candidate labels can be true. If false, the scores are normalized such that
    /// the sum of the label likelihoods for each sequence is 1. If true, the labels are considered
    /// independent and probabilities are normalized for each candidate.
    /// </summary>
    function MultiLabel(const Value: Boolean): TZeroShotClassificationParameters;
  end;

  TZeroShotClassificationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The text to classify.
    /// </summary>
    function Inputs(const Value: string): TZeroShotClassificationParam;
    /// <summary>
    /// Define generation parameters.
    /// </summary>
    function Parameters(ParamProc: TProcRef<TZeroShotClassificationParameters>): TZeroShotClassificationParam;
  end;

  TZeroShotClassification = class
  private
    FSequence: string;
    FLabels: TArray<string>;
    FScores: TArray<Double>;
  public
    /// <summary>
    /// The input string.
    /// </summary>
    property Sequence: string read FSequence write FSequence;
    /// <summary>
    /// The predicted class label.
    /// </summary>
    property Labels: TArray<string> read FLabels write FLabels;
    /// <summary>
    /// The corresponding probability.
    /// </summary>
    property Scores: TArray<Double> read FScores write FScores;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TZeroShotClassification</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynZeroShotClassification</c> type extends the <c>TAsynParams&lt;TZeroShotClassification&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynZeroShotClassification = TAsynCallBack<TZeroShotClassification>;

  {$ENDREGION}

  {$REGION 'Text Generation'}

  TTextGenerationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Lora adapter id.
    /// </summary>
    function AdapterId(const Value: string): TTextGenerationParameters;
    /// <summary>
    /// Generate best_of sequences and return the one if the highest token logprobs.
    /// </summary>
    function BestOf(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// Whether to return decoder input token logprobs and ids.
    /// </summary>
    function DecoderInputDetails(const Value: Boolean): TTextGenerationParameters;
    /// <summary>
    /// Whether to return generation details.
    /// </summary>
    function Details(const Value: Boolean): TTextGenerationParameters;
    /// <summary>
    /// Activate logits sampling.
    /// </summary>
    function DoSample(const Value: Boolean): TTextGenerationParameters;
    /// <summary>
    /// The parameter for frequency penalty. 1.0 means no penalty Penalize new tokens based on their
    /// existing frequency in the text so far, decreasing the model’s likelihood to repeat the same
    /// line verbatim.
    /// </summary>
    function FrequencyPenalty(const Value: Double): TTextGenerationParameters;
    /// <summary>
    /// Define the grammar pattern
    /// </summary>
    function Grammar(const Value: string): TTextGenerationParameters; overload;
    /// <summary>
    /// Define the grammar pattern
    /// </summary>
    function Grammar(const Value: TSchemaParams): TTextGenerationParameters; overload;
    /// <summary>
    ///   Maximum number of tokens to generate.
    /// </summary>
    function MaxNewTokens(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// The parameter for repetition penalty. 1.0 means no penalty. See this paper for more details.
    /// </summary>
    function RepetitionPenalty(const Value: Double): TTextGenerationParameters;
    /// <summary>
    /// Whether to prepend the prompt to the generated text.
    /// </summary>
    function ReturnFullText(const Value: Boolean): TTextGenerationParameters;
    /// <summary>
    /// Random sampling seed.
    /// </summary>
    function Seed(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// Stop generating tokens if a member of stop is generated.
    /// </summary>
    function Stop(const Value: TArray<string>): TTextGenerationParameters;
    /// <summary>
    /// The value used to module the logits distribution.
    /// </summary>
    function Temperature(const Value: Double): TTextGenerationParameters;
    /// <summary>
    /// The number of highest probability vocabulary tokens to keep for top-k-filtering.
    /// </summary>
    function TopK(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// The number of highest probability vocabulary tokens to keep for top-n-filtering.
    /// </summary>
    function TopNtokens(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// Top-p value for nucleus sampling.
    /// </summary>
    function TopP(const Value: Double): TTextGenerationParameters;
    /// <summary>
    /// Truncate inputs tokens to the given size.
    /// </summary>
    function Truncate(const Value: Integer): TTextGenerationParameters;
    /// <summary>
    /// Typical Decoding mass See Typical Decoding for Natural Language Generation for more information.
    /// </summary>
    function TypicalP(const Value: Double): TTextGenerationParameters;
    /// <summary>
    /// Watermarking with A Watermark for Large Language Models.
    /// </summary>
    /// <remarks>
    /// Watermark for Large Language Model :
    /// <para>
    /// - https://arxiv.org/abs/2301.10226
    /// </para>
    /// </remarks>
    function Watermark(const Value: Boolean): TTextGenerationParameters;
  end;

  TTextGenerationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// Text prompt to guide text generation
    /// </summary>
    function Inputs(const Value: string): TTextGenerationParam;
    /// <summary>
    /// Enables token streaming for partial responses.
    /// </summary>
    function Stream(const Value: Boolean): TTextGenerationParam;
    /// <summary>
    /// Define generation parameters.
    /// </summary>
    function Parameters(ParamProc: TProcRef<TTextGenerationParameters>): TTextGenerationParam;
  end;

  TPrefill = class
  private
    FId: Int64;
    FLogprob: Double;
    FText: string;
  public
    property Id: Int64 read FId write FId;
    property Logprob: Double read FLogprob write FLogprob;
    property Text: string read FText write FText;
  end;

  TTokens = class
  private
    FId: Int64;
    FLogprob: Double;
    FSpecial: Boolean;
    FText: string;
  public
    property Id: Int64 read FId write FId;
    property Logprob: Double read FLogprob write FLogprob;
    property Special: Boolean read FSpecial write FSpecial;
    property Text: string read FText write FText;
  end;

  TBestOfSequences = class
  private
    [JsonNameAttribute('finish_reason')]
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    [JsonNameAttribute('generated_text')]
    FGeneratedText: string;
    [JsonNameAttribute('generated_tokens')]
    FGeneratedTokens: int64;
    FPrefill: TArray<TPrefill>;
    FTokens: TArray<TTokens>;
    [JsonNameAttribute('top_tokens')]
    FTopTokens: TArray<TTokens>;
  public
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    property GeneratedText: string read FGeneratedText write FGeneratedText;
    property GeneratedTokens: int64 read FGeneratedTokens write FGeneratedTokens;
    property Prefill: TArray<TPrefill> read FPrefill write FPrefill;
    property Tokens: TArray<TTokens> read FTokens write FTokens;
    property TopTokens: TArray<TTokens> read FTopTokens write FTopTokens;
    destructor Destroy; override;
  end;

  TDetails = class
  private
    [JsonNameAttribute('generated_text')]
    FGeneratedText: string;
    [JsonNameAttribute('finish_reason')]
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    [JsonNameAttribute('best_of_sequences')]
    FBestOfSequences: TArray<TBestOfSequences>;
    [JsonNameAttribute('generated_tokens')]
    FGeneratedTokens: Int64;
    FPrefill: TArray<TPrefill>;
    FSeed: Int64;
    FTokens: TArray<TTokens>;
    [JsonNameAttribute('top_tokens')]
    FTopTokens: TArray<TTokens>;
  public
    property GeneratedText: string read FGeneratedText write FGeneratedText;
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    property BestOfSequences: TArray<TBestOfSequences> read FBestOfSequences write FBestOfSequences;
    property GeneratedTokens: Int64 read FGeneratedTokens write FGeneratedTokens;
    property Prefill: TArray<TPrefill> read FPrefill write FPrefill;
    property Seed: Int64 read FSeed write FSeed;
    property Tokens: TArray<TTokens> read FTokens write FTokens;
    property TopTokens: TArray<TTokens> read FTopTokens write FTopTokens;
    destructor Destroy; override;
  end;

  TTextGenerationItem = class
  private
    [JsonNameAttribute('generated_text')]
    FGeneratedText: string;
    FDetails: TDetails;
  public
    property GeneratedText: string read FGeneratedText write FGeneratedText;
    property Details: TDetails read FDetails write FDetails;
    destructor Destroy; override;
  end;

  TTextGeneration = class
  private
    FItems: TArray<TTextGenerationItem>;
    FGeneratedText: string;
    [JsonNameAttribute('token')]
    FDelta: TTokens;
  public
    /// <summary>
    /// Text result generated
    /// </summary>
    property GeneratedText: string read FGeneratedText write FGeneratedText;
    property Items: TArray<TTextGenerationItem> read FItems write FItems;
    /// <summary>
    /// Chunk generated when streaming is enabled.
    /// </summary>
    property Delta: TTokens read FDelta write FDelta;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a callback procedure used during the reception of responses from a chat request in streaming mode.
  /// </summary>
  /// <param name="Generation">
  /// The <c>TTextGeneration</c> object containing the current information about the response generated by the model.
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
  /// and the <c>TTextGeneration</c> parameter will be <c>nil</c>.
  /// </remarks>
  TTextGenerationEvent = reference to procedure(var Generation: TTextGeneration; IsDone: Boolean; var Cancel: Boolean);

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TTextGeneration</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTextGeneration</c> type extends the <c>TAsynParams&lt;TTextGeneration&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTextGeneration = TAsynCallBack<TTextGeneration>;

  /// <summary>
  /// Manages asynchronous streaming chat callBacks for a chat request using <c>TTextGeneration</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTextGenerationStream</c> type extends the <c>TAsynStreamParams&lt;TTextGeneration&gt;</c> record to support the lifecycle of an asynchronous streaming chat operation.
  /// It provides callbacks for different stages, including when the operation starts, progresses with new data chunks, completes successfully, or encounters an error.
  /// This structure is ideal for handling scenarios where the chat response is streamed incrementally, providing real-time updates to the user interface.
  /// </remarks>
  TAsynTextGenerationStream = TAsynStreamCallBack<TTextGeneration>;

  {$ENDREGION}

  {$REGION 'Sentiment analysis'}

  TSentimentAnalysisParams = class(TJSONModelParam)
  public
    /// <summary>
    /// Text to analyse
    /// </summary>
    function Inputs(const Value: string): TSentimentAnalysisParams;
  end;

  TEval = class
  private
    FLabel: string;
    FScore: Double;
  public
    /// <summary>
    /// The predicted label.
    /// </summary>
    property &Label: string read FLabel write FLabel;
    /// <summary>
    /// The corresponding probability.
    /// </summary>
    property Score: Double read FScore write FScore;
  end;

  TEvals = class
  private
    FItems: TArray<TEval>;
  public
    /// <summary>
    /// List of evals.
    /// </summary>
    property Evals: TArray<TEval> read FItems write FItems;
    destructor Destroy; override;
  end;

  TSentimentAnalysis = class
  private
    FItems: TArray<TEvals>;
  public
    property Items: TArray<TEvals> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TSentimentAnalysis</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynSentimentAnalysis</c> type extends the <c>TAsynParams&lt;TSentimentAnalysis&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynSentimentAnalysis = TAsynCallBack<TSentimentAnalysis>;

  {$ENDREGION}

  {$REGION 'Text-to-speech'}

  TTextToSpeechParam = class(TJSONModelParam)
  public
    /// <summary>
    /// Text prompt to analyse
    /// </summary>
    function Inputs(const Value: string): TTextToSpeechParam;
  end;

  TTextToAudioParam = class(TJSONModelParam)
  public
    /// <summary>
    /// Text prompt to analyse
    /// </summary>
    function Inputs(const Value: string): TTextToAudioParam;
  end;

  TTextToSpeech = class
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

  TTextToAudio = TTextToSpeech;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TTextToSpeech</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynTextToSpeech</c> type extends the <c>TAsynParams&lt;TTextToSpeech&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynTextToSpeech = TAsynCallBack<TTextToSpeech>;

  TAsynTextToAudio = TAsynTextToSpeech;

  {$ENDREGION}

  TTextRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Generate text based on a prompt.
    /// <para>
    /// If you are interested in a Chat Completion task, which generates a response based on
    /// a list of messages, check out the chat-completion task.
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextGenerationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTextGeneration</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.Generation(
    ///     procedure (Params: TTextGenerationParam)
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
    function Generation(ParamProc: TProc<TTextGenerationParam>): TTextGeneration; overload;
    /// <summary>
    /// Generate text based on a prompt.
    /// <para>
    /// If you are interested in a Chat Completion task, which generates a response based on
    /// a list of messages, check out the chat-completion task.
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextGenerationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTextGeneration</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.Generation(
    ///   procedure (Params: TTextGenerationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTextGeneration
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
    ///        procedure (Sender: TObject; Value: TTextGeneration)
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
    procedure Generation(ParamProc: TProc<TTextGenerationParam>;
      CallBacks: TFunc<TAsynTextGeneration>); overload;
    /// <summary>
    /// Generate a streamed text based on a prompt.
    /// <para>
    /// If you are interested in a Chat Completion task, which generates a response based on
    /// a list of messages, check out the chat-completion task.
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextGenerationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <c>TAsynTextGenerationStream</c> record which contains event handlers for managing different stages of the streaming process: progress updates, success, errors, and cancellation.
    /// </param>
    /// <remarks>
    /// This procedure initiates an asynchronous chat operation in streaming mode, where tokens are progressively received and processed.
    /// The provided event handlers allow for handling progress (i.e., receiving tokens in real time), detecting success, managing errors, and enabling cancellation logic.
    /// <code>
    /// CheckBox1.Checked := False;  //Click to stop the streaming
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.GenerationStream(
    ///   procedure(Params: TChatParams)
    ///   begin
    ///     // Define chat parameters
    ///     Params.Stream(True);
    ///   end,
    ///
    ///   function: TAsynTextGenerationStream
    ///   begin
    ///     Result.Sender := Memo1; // Instance passed to callback parameter
    ///     Result.OnProgress :=
    ///         procedure (Sender: TObject; Value: TTextGeneration)
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
    procedure GenerationStream(ParamProc: TProc<TTextGenerationParam>;
      CallBacks: TFunc<TAsynTextGenerationStream>); overload;
    /// <summary>
    /// Generate a streamed text based on a prompt.
    /// <para>
    /// If you are interested in a Chat Completion task, which generates a response based on
    /// a list of messages, check out the chat-completion task.
    /// </para>
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextGenerationParam</c> parameters.
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
    ///   HuggingFace.Text.GenerationStream(
    ///     procedure (Params: TTextGenerationParam)
    ///     begin
    ///       // Define chat parameters
    ///       Params.Stream(True);
    ///     end,
    ///
    ///     procedure(var Generation: TTextGeneration; IsDone: Boolean; var Cancel: Boolean)
    ///     begin
    ///       // Handle displaying
    ///     end);
    /// </code>
    /// </remarks>
    function GenerationStream(ParamProc: TProc<TTextGenerationParam>; Event: TTextGenerationEvent): Boolean; overload;
    /// <summary>
    /// Question Answering models can retrieve the answer to a question from a given text, which is useful
    /// for searching for an answer in a document.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TQuestionAnsweringParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TQuestionAnswering</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.QuestionAnswering(
    ///     procedure (Params: TQuestionAnsweringParam)
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
    function QuestionAnswering(ParamProc: TProc<TQuestionAnsweringParam>): TQuestionAnswering; overload;
    /// <summary>
    /// Question Answering models can retrieve the answer to a question from a given text, which is useful
    /// for searching for an answer in a document.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TQuestionAnsweringParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynQuestionAnswering</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.QuestionAnswering(
    ///   procedure (Params: TQuestionAnsweringParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynQuestionAnswering
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
    ///        procedure (Sender: TObject; Value: TQuestionAnswering)
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
    procedure QuestionAnswering(ParamProc: TProc<TQuestionAnsweringParam>;
      CallBacks: TFunc<TAsynQuestionAnswering>); overload;
    /// <summary>
    /// Analysis of feelings or emotions from a prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TSentimentAnalysisParams</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TSentimentAnalysis</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.SentimentAnalysis(
    ///     procedure (Params: TSentimentAnalysisParams)
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
    function SentimentAnalysis(ParamProc: TProc<TSentimentAnalysisParams>): TSentimentAnalysis; overload;
    /// <summary>
    /// Analysis of feelings or emotions from a prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TSentimentAnalysisParams</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynSentimentAnalysis</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.SentimentAnalysis(
    ///   procedure (Params: TSentimentAnalysisParams)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynSentimentAnalysis
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
    ///        procedure (Sender: TObject; Value: TSentimentAnalysis)
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
    procedure SentimentAnalysis(ParamProc: TProc<TSentimentAnalysisParams>;
      CallBacks: TFunc<TAsynSentimentAnalysis>); overload;
    /// <summary>
    /// Summarization is the task of producing a shorter version of a document while preserving
    /// its important information. Some models can extract text from the original input, while
    /// other models can generate entirely new text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TSummarizationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TSummarization</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.Summarization(
    ///     procedure (Params: TSummarizationParam)
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
    function Summarization(ParamProc: TProc<TSummarizationParam>): TSummarization; overload;
    /// <summary>
    /// Summarization is the task of producing a shorter version of a document while preserving
    /// its important information. Some models can extract text from the original input, while
    /// other models can generate entirely new text.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TSummarizationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynSummarization</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.Summarization(
    ///   procedure (Params: TSummarizationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynSummarization
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
    ///        procedure (Sender: TObject; Value: TSummarization)
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
    procedure Summarization(ParamProc: TProc<TSummarizationParam>;
      CallBacks: TFunc<TAsynSummarization>); overload;
    /// <summary>
    /// Table Question Answering (Table QA) is the answering a question about an information on a given table.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTableQAParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTableQA</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TableQuestionAnswering(
    ///     procedure (Params: TTableQAParam)
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
    function TableQuestionAnswering(ParamProc: TProc<TTableQAParam>): TTableQA; overload;
    /// <summary>
    /// Table Question Answering (Table QA) is the answering a question about an information on a given table.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTableQAParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTableQA</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TableQuestionAnswering(
    ///   procedure (Params: TTableQAParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTableQA
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
    ///        procedure (Sender: TObject; Value: TTableQA)
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
    procedure TableQuestionAnswering(ParamProc: TProc<TTableQAParam>;
      CallBacks: TFunc<TAsynTableQA>); overload;
    /// <summary>
    /// Text Classification is the task of assigning a label or class to a given text. Some use cases
    /// are sentiment analysis, natural language inference, and assessing grammatical correctness.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextClassificationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTextClassification</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TextClassification(
    ///     procedure (Params: TTextClassificationParam)
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
    function TextClassification(ParamProc: TProc<TTextClassificationParam>): TTextClassification; overload;
    /// <summary>
    /// Text Classification is the task of assigning a label or class to a given text. Some use cases
    /// are sentiment analysis, natural language inference, and assessing grammatical correctness.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextClassificationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTextClassification</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TextClassification(
    ///   procedure (Params: TTextClassificationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTextClassification
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
    ///        procedure (Sender: TObject; Value: TTextClassification)
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
    procedure TextClassification(ParamProc: TProc<TTextClassificationParam>;
      CallBacks: TFunc<TAsynTextClassification>); overload;
    /// <summary>
    /// Generate an image based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToImageParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTextToImage</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TextToImage(
    ///     procedure (Params: TTextToImageParam)
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
    function TextToImage(ParamProc: TProc<TTextToImageParam>): TTextToImage; overload;
    /// <summary>
    /// Generate an image based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToImageParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTextToImage</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TextToImage(
    ///   procedure (Params: TTextToImageParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTextToImage
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
    ///        procedure (Sender: TObject; Value: TTextToImage)
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
    procedure TextToImage(ParamProc: TProc<TTextToImageParam>;
      CallBacks: TFunc<TAsynTextToImage>); overload;
    /// <summary>
    /// Generate an audio based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToAudioParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTextToAudio</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TextToAudio(
    ///     procedure (Params: TTextToAudioParam)
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
    function TextToAudio(ParamProc: TProc<TTextToAudioParam>): TTextToAudio; overload;
    /// <summary>
    /// Generate an audio based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToAudioParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTextToAudio</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TextToAudio(
    ///   procedure (Params: TTextToAudioParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTextToAudio
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
    ///        procedure (Sender: TObject; Value: TTextToAudio)
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
    procedure TextToAudio(ParamProc: TProc<TTextToAudioParam>;
      CallBacks: TFunc<TAsynTextToAudio>); overload;
    /// <summary>
    /// Generate an speech based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToAudioParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTextToAudio</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TextToAudio(
    ///     procedure (Params: TTextToAudioParam)
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
    function TextToSpeech(ParamProc: TProc<TTextToSpeechParam>): TTextToSpeech; overload;
    /// <summary>
    /// Generate an speech based on a given text prompt.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTextToSpeechParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTextToSpeech</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TextToSpeech(
    ///   procedure (Params: TTextToSpeechParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTextToSpeech
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
    ///        procedure (Sender: TObject; Value: TTextToSpeech)
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
    procedure TextToSpeech(ParamProc: TProc<TTextToSpeechParam>;
      CallBacks: TFunc<TAsynTextToSpeech>); overload;
    /// <summary>
    /// Token classification is a task in which a label is assigned to some tokens in a text.
    /// Some popular token classification subtasks are Named Entity Recognition (NER) and
    /// Part-of-Speech (PoS) tagging.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTokenClassificationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTokenClassification</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.TokenClassification(
    ///     procedure (Params: TTokenClassificationParam)
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
    function TokenClassification(ParamProc: TProc<TTokenClassificationParam>): TTokenClassification; overload;
    /// <summary>
    /// Token classification is a task in which a label is assigned to some tokens in a text.
    /// Some popular token classification subtasks are Named Entity Recognition (NER) and
    /// Part-of-Speech (PoS) tagging.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTokenClassificationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTokenClassification</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.TokenClassification(
    ///   procedure (Params: TTokenClassificationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTokenClassification
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
    ///        procedure (Sender: TObject; Value: TTokenClassification)
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
    procedure TokenClassification(ParamProc: TProc<TTokenClassificationParam>;
      CallBacks: TFunc<TAsynTokenClassification>); overload;
    /// <summary>
    /// Translation is the task of converting text from one language to another.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTranslationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TTranslation</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.Translation(
    ///     procedure (Params: TTranslationParam)
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
    function Translation(ParamProc: TProc<TTranslationParam>): TTranslation; overload;
    /// <summary>
    /// Translation is the task of converting text from one language to another.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TTranslationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynTokenClassification</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.Translation(
    ///   procedure (Params: TTranslationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynTokenClassification
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
    ///        procedure (Sender: TObject; Value: TTranslation)
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
    procedure Translation(ParamProc: TProc<TTranslationParam>;
      CallBacks: TFunc<TAsynTranslation>); overload;
    /// <summary>
    /// Zero-shot text classification is super useful to try out classification with zero code, you
    /// simply pass a sentence/paragraph and the possible labels for that sentence, and you get a result.
    /// The model has not been necessarily trained on the labels you provide, but it can still predict
    /// the correct label.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TZeroShotClassificationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TZeroShotClassification</c> object containing the text generation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Text.ZeroShotClassification(
    ///     procedure (Params: TZeroShotClassificationParam)
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
    function ZeroShotClassification(ParamProc: TProc<TZeroShotClassificationParam>): TZeroShotClassification; overload;
    /// <summary>
    /// Zero-shot text classification is super useful to try out classification with zero code, you
    /// simply pass a sentence/paragraph and the possible labels for that sentence, and you get a result.
    /// The model has not been necessarily trained on the labels you provide, but it can still predict
    /// the correct label.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TZeroShotClassificationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynZeroShotClassification</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Text.ZeroShotClassification(
    ///   procedure (Params: TZeroShotClassificationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynZeroShotClassification
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
    ///        procedure (Sender: TObject; Value: TZeroShotClassification)
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
    procedure ZeroShotClassification(ParamProc: TProc<TZeroShotClassificationParam>;
      CallBacks: TFunc<TAsynZeroShotClassification>); overload;
  end;

implementation

uses
  HuggingFace.NetEncoding.Base64, System.Threading, HuggingFace.Async.Params;

{ TQuestionAnsweringInputs }

function TQuestionAnsweringInputs.Context(
  const Value: string): TQuestionAnsweringInputs;
begin
  Result := TQuestionAnsweringInputs(Add('context', Value));
end;

function TQuestionAnsweringInputs.Question(
  const Value: string): TQuestionAnsweringInputs;
begin
  Result := TQuestionAnsweringInputs(Add('question', Value));
end;

{ TQuestionAnsweringParam }

function TQuestionAnsweringParam.Inputs(const Question,
  Context: string): TQuestionAnsweringParam;
begin
  var Value := TQuestionAnsweringInputs.Create.Question(Question).Context(Context).Detach;
  Result := TQuestionAnsweringParam(Add('inputs', Value));
end;

function TQuestionAnsweringParam.Inputs(
  const Question: string): TQuestionAnsweringParam;
begin
  var Value := TQuestionAnsweringInputs.Create.Question(Question).Detach;
  Result := TQuestionAnsweringParam(Add('inputs', Value));
end;

function TQuestionAnsweringParam.Parameters(
  ParamProc: TProcRef<TQuestionAnsweringParameters>): TQuestionAnsweringParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TQuestionAnsweringParameters.Create;
      ParamProc(Value);
      Result := TQuestionAnsweringParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TQuestionAnsweringParameters }

function TQuestionAnsweringParameters.AlignToWords(
  const Value: Boolean): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('align_to_words', Value));
end;

function TQuestionAnsweringParameters.DocStride(
  const Value: Integer): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('doc_stride', Value));
end;

function TQuestionAnsweringParameters.HandleImpossibleAnswer(
  const Value: Boolean): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('handle_impossible_answer', Value));
end;

function TQuestionAnsweringParameters.MaxAnswerLen(
  const Value: Integer): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('max_answer_len', Value));
end;

function TQuestionAnsweringParameters.MaxQuestionLen(
  const Value: Integer): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('max_question_len', Value));
end;

function TQuestionAnsweringParameters.MaxSeqLen(
  const Value: Integer): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('max_seq_len', Value));
end;

function TQuestionAnsweringParameters.TopK(
  const Value: Integer): TQuestionAnsweringParameters;
begin
  Result := TQuestionAnsweringParameters(Add('top_k', Value));
end;

{ TTextRoute }

function TTextRoute.QuestionAnswering(
  ParamProc: TProc<TQuestionAnsweringParam>): TQuestionAnswering;
begin
  Result := API.Post<TQuestionAnswering, TQuestionAnsweringParam>('models', ParamProc);
end;

procedure TTextRoute.QuestionAnswering(
  ParamProc: TProc<TQuestionAnsweringParam>;
  CallBacks: TFunc<TAsynQuestionAnswering>);
begin
  with TAsynCallBackExec<TAsynQuestionAnswering, TQuestionAnswering>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TQuestionAnswering
      begin
        Result := Self.QuestionAnswering(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.SentimentAnalysis(
  ParamProc: TProc<TSentimentAnalysisParams>): TSentimentAnalysis;
begin
  Result := API.Post<TSentimentAnalysis, TSentimentAnalysisParams>('models', ParamProc);
end;

procedure TTextRoute.SentimentAnalysis(
  ParamProc: TProc<TSentimentAnalysisParams>;
  CallBacks: TFunc<TAsynSentimentAnalysis>);
begin
  with TAsynCallBackExec<TAsynSentimentAnalysis, TSentimentAnalysis>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSentimentAnalysis
      begin
        Result := Self.SentimentAnalysis(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.Summarization(
  ParamProc: TProc<TSummarizationParam>): TSummarization;
begin
  Result := API.Post<TSummarization, TSummarizationParam>('models', ParamProc);
end;

procedure TTextRoute.Summarization(ParamProc: TProc<TSummarizationParam>;
  CallBacks: TFunc<TAsynSummarization>);
begin
  with TAsynCallBackExec<TAsynSummarization, TSummarization>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TSummarization
      begin
        Result := Self.Summarization(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.TableQuestionAnswering(
  ParamProc: TProc<TTableQAParam>): TTableQA;
begin
  Result := API.Post<TTableQA, TTableQAParam>('models', ParamProc);
end;

procedure TTextRoute.TableQuestionAnswering(ParamProc: TProc<TTableQAParam>;
  CallBacks: TFunc<TAsynTableQA>);
begin
  with TAsynCallBackExec<TAsynTableQA, TTableQA>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTableQA
      begin
        Result := Self.TableQuestionAnswering(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.TextClassification(
  ParamProc: TProc<TTextClassificationParam>): TTextClassification;
begin
  Result := API.Post<TTextClassification, TTextClassificationParam>('models', ParamProc);
end;

procedure TTextRoute.TextClassification(
  ParamProc: TProc<TTextClassificationParam>;
  CallBacks: TFunc<TAsynTextClassification>);
begin
  with TAsynCallBackExec<TAsynTextClassification, TTextClassification>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTextClassification
      begin
        Result := Self.TextClassification(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.Generation(
  ParamProc: TProc<TTextGenerationParam>): TTextGeneration;
begin
  Result := API.Post<TTextGeneration, TTextGenerationParam>('models', ParamProc);
end;

procedure TTextRoute.Generation(ParamProc: TProc<TTextGenerationParam>;
  CallBacks: TFunc<TAsynTextGeneration>);
begin
  with TAsynCallBackExec<TAsynTextGeneration, TTextGeneration>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTextGeneration
      begin
        Result := Self.Generation(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.GenerationStream(ParamProc: TProc<TTextGenerationParam>;
  Event: TTextGenerationEvent): Boolean;
var
  Response: TStringStream;
  RetPos: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    RetPos := 0;
    Result := API.Post<TTextGenerationParam>('models', ParamProc, Response,
      procedure(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var AAbort: Boolean)
      var
        IsDone: Boolean;
        Data: string;
        Generation: TTextGeneration;
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
          Generation := nil;
          Data := Line.Replace('data: ', '').Trim([' ', #13, #10]);
          IsDone := Data = '[DONE]';

          if not IsDone then
          try
            Generation := TJson.JsonToObject<TTextGeneration>(Data);
          except
            Generation := nil;
          end;

          try
            Event(Generation, IsDone, AAbort);
          finally
            Generation.Free;
          end;
        until Ret < 0;
      end);
    finally
      Response.Free;
    end;
end;

procedure TTextRoute.GenerationStream(ParamProc: TProc<TTextGenerationParam>;
  CallBacks: TFunc<TAsynTextGenerationStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynTextGenerationStream>.CreateInstance(CallBacks);

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
              GenerationStream(ParamProc,
                procedure (var Generation: TTextGeneration; IsDone: Boolean; var Cancel: Boolean)
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
                  if not IsDone and Assigned(Generation) then
                    begin
                      var LocalChat := Generation;
                      Generation := nil;

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
                        end)
                      else
                        LocalChat.Free;
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

function TTextRoute.TextToAudio(
  ParamProc: TProc<TTextToAudioParam>): TTextToAudio;
begin
  Result := API.Post<TTextToAudio, TTextToAudioParam>('models', ParamProc, 'audio');
end;

procedure TTextRoute.TextToAudio(ParamProc: TProc<TTextToAudioParam>;
  CallBacks: TFunc<TAsynTextToSpeech>);
begin
  with TAsynCallBackExec<TAsynTextToSpeech, TTextToSpeech>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTextToSpeech
      begin
        Result := Self.TextToAudio(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.TextToImage(
  ParamProc: TProc<TTextToImageParam>): TTextToImage;
begin
  Result := API.Post<TTextToImage, TTextToImageParam>('models', ParamProc, 'image');
end;

procedure TTextRoute.TextToImage(ParamProc: TProc<TTextToImageParam>;
  CallBacks: TFunc<TAsynTextToImage>);
begin
  with TAsynCallBackExec<TAsynTextToImage, TTextToImage>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTextToImage
      begin
        Result := Self.TextToImage(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.TextToSpeech(
  ParamProc: TProc<TTextToSpeechParam>): TTextToSpeech;
begin
  Result := API.Post<TTextToSpeech, TTextToSpeechParam>('models', ParamProc, 'audio');
end;

procedure TTextRoute.TextToSpeech(ParamProc: TProc<TTextToSpeechParam>;
  CallBacks: TFunc<TAsynTextToSpeech>);
begin
  with TAsynCallBackExec<TAsynTextToSpeech, TTextToSpeech>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTextToSpeech
      begin
        Result := Self.TextToSpeech(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.TokenClassification(
  ParamProc: TProc<TTokenClassificationParam>): TTokenClassification;
begin
  Result := API.Post<TTokenClassification, TTokenClassificationParam>('models', ParamProc);
end;

procedure TTextRoute.TokenClassification(
  ParamProc: TProc<TTokenClassificationParam>;
  CallBacks: TFunc<TAsynTokenClassification>);
begin
  with TAsynCallBackExec<TAsynTokenClassification, TTokenClassification>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTokenClassification
      begin
        Result := Self.TokenClassification(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.Translation(
  ParamProc: TProc<TTranslationParam>): TTranslation;
begin
  Result := API.Post<TTranslation, TTranslationParam>('models', ParamProc);
end;

procedure TTextRoute.Translation(ParamProc: TProc<TTranslationParam>;
  CallBacks: TFunc<TAsynTranslation>);
begin
  with TAsynCallBackExec<TAsynTranslation, TTranslation>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTranslation
      begin
        Result := Self.Translation(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TTextRoute.ZeroShotClassification(
  ParamProc: TProc<TZeroShotClassificationParam>): TZeroShotClassification;
begin
  Result := API.Post<TZeroShotClassification, TZeroShotClassificationParam>('models', ParamProc);
end;

procedure TTextRoute.ZeroShotClassification(
  ParamProc: TProc<TZeroShotClassificationParam>;
  CallBacks: TFunc<TAsynZeroShotClassification>);
begin
  with TAsynCallBackExec<TAsynZeroShotClassification, TZeroShotClassification>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TZeroShotClassification
      begin
        Result := Self.ZeroShotClassification(ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TSummarizationParam }

function TSummarizationParam.Inputs(const Value: string): TSummarizationParam;
begin
  Result := TSummarizationParam(Add('inputs', Value));
end;

function TSummarizationParam.Parameters(
  ParamProc: TProcRef<TSummarizationParameters>): TSummarizationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSummarizationParameters.Create;
      ParamProc(Value);
      Result := TSummarizationParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TSummarizationParameters }

function TSummarizationParameters.CleanUpTokenizationSpaces(
  const Value: Boolean): TSummarizationParameters;
begin
  Result := TSummarizationParameters(Add('clean_up_tokenization_spaces', Value));
end;

function TSummarizationParameters.GenerateParameters(
  const Value: TJSONObject): TSummarizationParameters;
begin
  Result := TSummarizationParameters(Add('generate_parameters', Value));
end;

function TSummarizationParameters.Truncation(
  const Value: TTextTruncationType): TSummarizationParameters;
begin
  Result := TSummarizationParameters(Add('truncation', Value.ToString));
end;

{ TSummarization }

destructor TSummarization.Destroy;
begin
  for var Item in Fitems do
    Item.Free;
  inherited;
end;

{ TTableQAInputs }

function TTableQAInputs.Query(const Value: string): TTableQAInputs;
begin
  Result := TTableQAInputs(Add('query', Value));
end;

function TTableQAInputs.Table(const Value: TArray<TRow>): TTableQAInputs;
begin
  var JSONParam := TJSONParam.Create;
  for var Row in Value do
    JSONParam.Add(Row.FieldName, Row.Values);
  Result := TTableQAInputs(Add('table', JSONParam.Detach));
end;

{ TTableQAParam }

function TTableQAParam.Inputs(const Query: string;
  const Table: TArray<TRow>): TTableQAParam;
begin
  var Value := TTableQAInputs.Create.Query(Query).Table(Table);
  Result := TTableQAParam(Add('inputs', Value.Detach));
end;

function TTableQAParam.Parameters(
  ParamProc: TProcRef<TTableQAParameters>): TTableQAParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TTableQAParameters.Create;
      ParamProc(Value);
      Result := TTableQAParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TTableQAParameters }

function TTableQAParameters.Padding(
  const Value: TPaddingType): TTableQAParameters;
begin
  Result := TTableQAParameters(Add('padding', Value.ToString));
end;

function TTableQAParameters.Sequential(
  const Value: Boolean): TTableQAParameters;
begin
  Result := TTableQAParameters(Add('sequential', Value));
end;

function TTableQAParameters.Truncation(
  const Value: Boolean): TTableQAParameters;
begin
  Result := TTableQAParameters(Add('truncation', Value));
end;

{ TRow }

class function TRow.Create(const FieldName: string;
  Values: TArray<string>): TRow;
begin
  Result.FieldName := FieldName;
  Result.Values := Values;
end;

{ TTextClassificationParam }

function TTextClassificationParam.Inputs(const Value: string): TTextClassificationParam;
begin
  Result := TTextClassificationParam(Add('inputs', Value));
end;

function TTextClassificationParam.Parameters(
  const FunctionToApply: TFunctionClassification;
  const TopK: Integer): TTextClassificationParam;
begin
  var Value := TTextClassificationParameters.Create.FunctionToApply(FunctionToApply);
  if TopK <> -1 then
    Value := Value.TopK(TopK);
  Result := TTextClassificationParam(Add('parameters', Value.Detach));
end;

function TTextClassificationParam.Parameters(
  const TopK: Integer): TTextClassificationParam;
begin
  Result := TTextClassificationParam(Add('parameters', TTextClassificationParameters.Create.TopK(TopK).Detach));
end;

{ TTextClassificationParameters }

function TTextClassificationParameters.FunctionToApply(
  const Value: TFunctionClassification): TTextClassificationParameters;
begin
  Result := TTextClassificationParameters(Add('function_to_apply', Value.ToString));
end;

function TTextClassificationParameters.TopK(
  const Value: Integer): TTextClassificationParameters;
begin
  Result := TTextClassificationParameters(Add('top_k', Value));
end;

{ TTextClassification }

destructor TTextClassification.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TTextClassificationArray }

destructor TTextClassificationArray.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TTextToImageParam }

function TTextToImageParam.Inputs(const Value: string): TTextToImageParam;
begin
  Result := TTextToImageParam(Add('inputs', Value));
end;

function TTextToImageParam.Parameters(
  ParamProc: TProcRef<TTextToImageParameters>): TTextToImageParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TTextToImageParameters.Create;
      ParamProc(Value);
      Result := TTextToImageParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

function TTextToImageParam.Prompt(const Value: string): TTextToImageParam;
begin
  Result := TTextToImageParam(Add('prompt', Value));
end;

{ TTextToImageParameters }

function TTextToImageParameters.GuidanceScale(
  const Value: Double): TTextToImageParameters;
begin
  Result := TTextToImageParameters(Add('guidance_scale', Value));
end;

function TTextToImageParameters.NegativePrompt(
  const Value: TArray<string>): TTextToImageParameters;
begin
  Result := TTextToImageParameters(Add('negative_prompt', Value));
end;

function TTextToImageParameters.NumInferenceSteps(
  const Value: Integer): TTextToImageParameters;
begin
  Result := TTextToImageParameters(Add('num_inference_steps', Value));
end;

function TTextToImageParameters.Scheduler(
  const Value: string): TTextToImageParameters;
begin
  Result := TTextToImageParameters(Add('scheduler', Value));
end;

function TTextToImageParameters.Seed(
  const Value: Integer): TTextToImageParameters;
begin
  Result := TTextToImageParameters(Add('seed', Value));
end;

function TTextToImageParameters.TargetSize(const Width,
  Height: Integer): TTextToImageParameters;
begin
  var Value := TTargetSizeParam.Create.Width(Width).Height(Height);
  Result := TTextToImageParameters(Add('target_size', Value.Detach));
end;

{ TTargetSizeParam }

function TTargetSizeParam.Height(const Value: Integer): TTargetSizeParam;
begin
  Result := TTargetSizeParam(Add('height', Value));
end;

function TTargetSizeParam.Width(const Value: Integer): TTargetSizeParam;
begin
  Result := TTargetSizeParam(Add('width', Value));
end;

{ TTextToImage }

function TTextToImage.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Image, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TTextToImage.SaveToFile(const FileName: string);
begin
  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Image, FileName)
  except
    raise;
  end;
end;

{ TTokenClassificationParam }

function TTokenClassificationParam.Inputs(const Value: string): TTokenClassificationParam;
begin
  Result := TTokenClassificationParam(Add('inputs', Value));
end;

function TTokenClassificationParam.Parameters(
  ParamProc: TProcRef<TTokenClassificationParameters>): TTokenClassificationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TTokenClassificationParameters.Create;
      ParamProc(Value);
      Result := TTokenClassificationParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TTokenClassificationParameters }

function TTokenClassificationParameters.AggregationStrategy(
  const Value: TAggregationStrategyType): TTokenClassificationParameters;
begin
  Result := TTokenClassificationParameters(Add('aggregation_strategy', Value.ToString));
end;

function TTokenClassificationParameters.IgnoreLabels(
  const Value: TArray<string>): TTokenClassificationParameters;
begin
  Result := TTokenClassificationParameters(Add('ignore_labels', Value));
end;

function TTokenClassificationParameters.Stride(
  const Value: Integer): TTokenClassificationParameters;
begin
  Result := TTokenClassificationParameters(Add('stride', Value));
end;

{ TTokenClassification }

destructor TTokenClassification.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TTranslationParam }

function TTranslationParam.Inputs(const Value: string): TTranslationParam;
begin
  Result := TTranslationParam(Add('inputs', Value));
end;

function TTranslationParam.Parameters(
  ParamProc: TProcRef<TTranslationParameters>): TTranslationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TTranslationParameters.Create;
      ParamProc(Value);
      Result := TTranslationParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TTranslationParameters }

function TTranslationParameters.CleanUpTokenizationSpaces(
  const Value: Boolean): TTranslationParameters;
begin
  Result := TTranslationParameters(Add('clean_up_tokenization_spaces', Value));
end;

function TTranslationParameters.GenerateParameters(
  const Value: TJSONObject): TTranslationParameters;
begin
  Result := TTranslationParameters(Add('generate_parameters', Value));
end;

function TTranslationParameters.SrcLang(
  const Value: string): TTranslationParameters;
begin
  Result := TTranslationParameters(Add('src_lang', Value));
end;

function TTranslationParameters.TgtLang(
  const Value: string): TTranslationParameters;
begin
  Result := TTranslationParameters(Add('tgt_lang', Value));
end;

function TTranslationParameters.Truncation(
  const Value: TTextTruncationType): TTranslationParameters;
begin
  Result := TTranslationParameters(Add('truncation', Value.ToString));
end;

{ TTranslation }

destructor TTranslation.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TZeroShotClassificationParam }

function TZeroShotClassificationParam.Inputs(
  const Value: string): TZeroShotClassificationParam;
begin
  Result := TZeroShotClassificationParam(Add('inputs', Value));
end;

function TZeroShotClassificationParam.Parameters(
  ParamProc: TProcRef<TZeroShotClassificationParameters>): TZeroShotClassificationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TZeroShotClassificationParameters.Create;
      ParamProc(Value);
      Result := TZeroShotClassificationParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TZeroShotClassificationParameters }

function TZeroShotClassificationParameters.CandidateLabels(
  const Value: TArray<string>): TZeroShotClassificationParameters;
begin
  Result := TZeroShotClassificationParameters(Add('candidate_labels', Value));
end;

function TZeroShotClassificationParameters.HypothesisTemplate(
  const Value: string): TZeroShotClassificationParameters;
begin
  Result := TZeroShotClassificationParameters(Add('hypothesis_template', Value));
end;

function TZeroShotClassificationParameters.MultiLabel(
  const Value: Boolean): TZeroShotClassificationParameters;
begin
  Result := TZeroShotClassificationParameters(Add('multi_label', Value));
end;

{ TTextGenerationParam }

function TTextGenerationParam.Inputs(const Value: string): TTextGenerationParam;
begin
  Result := TTextGenerationParam(Add('inputs', Value));
end;

function TTextGenerationParam.Parameters(
  ParamProc: TProcRef<TTextGenerationParameters>): TTextGenerationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TTextGenerationParameters.Create;
      ParamProc(Value);
      Result := TTextGenerationParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

function TTextGenerationParam.Stream(
  const Value: Boolean): TTextGenerationParam;
begin
  Result := TTextGenerationParam(Add('stream', Value));
end;

{ TTextGenerationParameters }

function TTextGenerationParameters.AdapterId(
  const Value: string): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('adapter_id', Value));
end;

function TTextGenerationParameters.BestOf(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('best_of', Value));
end;

function TTextGenerationParameters.DecoderInputDetails(
  const Value: Boolean): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('decoder_input_details', Value));
end;

function TTextGenerationParameters.Details(
  const Value: Boolean): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('details', Value));
end;

function TTextGenerationParameters.DoSample(
  const Value: Boolean): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('do_sample', Value));
end;

function TTextGenerationParameters.FrequencyPenalty(
  const Value: Double): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('frequency_penalty', Value));
end;

function TTextGenerationParameters.Grammar(
  const Value: TSchemaParams): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('grammar', TResponseFormat.Json(Value).Detach));
end;

function TTextGenerationParameters.Grammar(
  const Value: string): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('grammar', TResponseFormat.Regex(Value).Detach));
end;

function TTextGenerationParameters.MaxNewTokens(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('max_new_tokens', Value));
end;

function TTextGenerationParameters.RepetitionPenalty(
  const Value: Double): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('repetition_penalty', Value));
end;

function TTextGenerationParameters.ReturnFullText(
  const Value: Boolean): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('return_full_text', Value));
end;

function TTextGenerationParameters.Seed(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('seed', Value));
end;

function TTextGenerationParameters.Stop(
  const Value: TArray<string>): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('stop', Value));
end;

function TTextGenerationParameters.Temperature(
  const Value: Double): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('temperature', Value));
end;

function TTextGenerationParameters.TopK(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('top_k', Value));
end;

function TTextGenerationParameters.TopNtokens(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('top_n_tokens', Value));
end;

function TTextGenerationParameters.TopP(
  const Value: Double): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('top_p', Value));
end;

function TTextGenerationParameters.Truncate(
  const Value: Integer): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('truncate', Value));
end;

function TTextGenerationParameters.TypicalP(
  const Value: Double): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('typical_p', Value));
end;

function TTextGenerationParameters.Watermark(
  const Value: Boolean): TTextGenerationParameters;
begin
  Result := TTextGenerationParameters(Add('watermark', Value));
end;

{ TTextGeneration }

destructor TTextGeneration.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ TTextGenerationItem }

destructor TTextGenerationItem.Destroy;
begin
  if Assigned(FDetails) then
    FDetails.Free;
  inherited;
end;

{ TBestOfSequences }

destructor TBestOfSequences.Destroy;
begin
  for var Item in FPrefill do
    Item.Free;
  for var Item in FTokens do
    Item.Free;
  for var Item in FTopTokens do
    Item.Free;
  inherited;
end;

{ TDetails }

destructor TDetails.Destroy;
begin
  for var Item in FBestOfSequences do
    Item.Free;
  for var Item in FPrefill do
    Item.Free;
  for var Item in FTokens do
    Item.Free;
  for var Item in FTopTokens do
    Item.Free;
  inherited;
end;

{ TSentimentAnalysisParams }

function TSentimentAnalysisParams.Inputs(
  const Value: string): TSentimentAnalysisParams;
begin
  Result := TSentimentAnalysisParams(Add('inputs', Value));
end;

{ TEvals }

destructor TEvals.Destroy;
begin
  for var Item in FItems  do
    Item.Free;
  inherited;
end;

{ TSentimentAnalysis }

destructor TSentimentAnalysis.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TTextToSpeechParam }

function TTextToSpeechParam.Inputs(const Value: string): TTextToSpeechParam;
begin
  Result := TTextToSpeechParam(Add('inputs', Value));
end;

{ TTextToSpeech }

function TTextToSpeech.GetStream: TStream;
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

procedure TTextToSpeech.SaveToFile(const FileName: string);
begin
  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Audio, FileName)
  except
    raise;
  end;
end;

{ TTextToAudioParam }

function TTextToAudioParam.Inputs(
  const Value: string): TTextToAudioParam;
begin
  Result := TTextToAudioParam(Add('inputs', Value));
end;

{ TQuestionAnswering }

destructor TQuestionAnswering.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

end.
