unit HuggingFace.Hub.Search;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, Rest.Json,
  REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Hub.Support, HuggingFace.Async.Support;

type
  TTokenizerConfig = class
  private
    [JsonNameAttribute('bos_token')]
    FBosToken: string;
    [JsonNameAttribute('chat_template')]
    FChatTemplate: string;
    [JsonNameAttribute('eos_token')]
    FEosToken: string;
    [JsonNameAttribute('pad_token')]
    FPadToken: string;
    [JsonNameAttribute('unk_token')]
    FUnkToken: string;
    [JsonNameAttribute('cls_token')]
    FClsToken: string;
    [JsonNameAttribute('mask_token')]
    FMaskToken: string;
    [JsonNameAttribute('sep_token')]
    FSepToken: string;
  public
    property BosToken: string read FBosToken write FBosToken;
    property ChatTemplate: string read FChatTemplate write FChatTemplate;
    property EosToken: string read FEosToken write FEosToken;
    property PadToken: string read FPadToken write FPadToken;
    property UnkToken: string read FUnkToken write FUnkToken;
    property ClsToken: string read FClsToken write FClsToken;
    property MaskToken: string read FMaskToken write FMaskToken;
    property SepToken: string read FSepToken write FSepToken;
  end;

  TProcessorConfig = class
  private
    [JsonNameAttribute('chat_template')]
    FChatTemplate: string;
  public
    property ChatTemplate: string read FChatTemplate write FChatTemplate;
  end;

  TConfig = class
  private
    FArchitectures: TArray<string>;
    [JsonNameAttribute('model_type')]
    FModelType: string;
    [JsonNameAttribute('processor_config')]
    FProcessorConfig: TProcessorConfig;
    [JsonNameAttribute('tokenizer_config')]
    FTokenizerConfig: TTokenizerConfig;
  public
    property Architectures: TArray<string> read FArchitectures write FArchitectures;
    property ModelType: string read FModelType write FModelType;
    property ProcessorConfig: TProcessorConfig read FProcessorConfig write FProcessorConfig;
    property TokenizerConfig: TTokenizerConfig read FTokenizerConfig write FTokenizerConfig;
    destructor Destroy; override;
  end;

  TSibling = class
  private
    FRfilename: string;
  public
    property Rfilename: string read FRfilename write FRfilename;
  end;

  TWidgetDataItem = class
  private
    [JsonNameAttribute('example_title')]
    FExampleTitle: string;
    FSrc: string;
  public
    property ExampleTitle: string read FExampleTitle write FExampleTitle;
    property Src: string read FSrc write FSrc;
  end;

  TDataFiles = class
  private
    FSplit: string;
    FPath: string;
  public
    property Split: string read FSplit write FSplit;
    property Path: string read FPath write FPath;
  end;

  TCardDataConfig = class
  private
    [JsonNameAttribute('config_name')]
    FConfigName: string;
    [JsonNameAttribute('data_files')]
    FDataFiles: TArray<TDataFiles>;
    FDefault: Boolean;
  public
    property ConfigName: string read FConfigName write FConfigName;
    property DataFiles: TArray<TDataFiles> read FDataFiles write FDataFiles;
    property Default: Boolean read FDefault write FDefault;
    destructor Destroy; override;
  end;

  TModelIndexItem = class;
  
  TCardData = class
  private
    FLanguage: TArray<string>;
    FTags: TArray<string>;
    FWidget: TArray<TWidgetDataItem>;
    [JsonNameAttribute('pipeline_tag')]
    FPipelineTag: string;
    FLicense: string;
    FThumbnail: string;
    FLibrary: string;
    FInference: Boolean;   
    [JsonNameAttribute('library_name')]
    FLibraryName: string;
    FDatasets: TArray<string>;
    [JsonNameAttribute('model-index')]
    FModelIndex: TArray<TModelIndexItem>;
    FMetrics: TArray<string>;
    [JsonNameAttribute('task_categories')]
    FTaskCategories: TArray<string>;
    [JsonNameAttribute('size_categories')]
    FSizeCategories: TArray<string>;
    FConfigs: TArray<TCardDataConfig>;
  public
    property Language: TArray<string> read FLanguage write FLanguage;
    property Tags: TArray<string> read FTags write FTags;
    property Widget: TArray<TWidgetDataItem> read FWidget write FWidget;
    property PipelineTag: string read FPipelineTag write FPipelineTag;
    property License: string read FLicense write FLicense;
    property Thumbnail: string read FThumbnail write FThumbnail;
    property &Library: string read FLibrary write FLibrary;
    property Inference: Boolean read FInference write FInference;
    property LibraryName: string read FLibraryName write FLibraryName;
    property Datasets: TArray<string> read FDatasets write FDatasets;
    property ModelIndex: TArray<TModelIndexItem> read FModelIndex write FModelIndex;
    property Metrics: TArray<string> read FMetrics write FMetrics;
    property TaskCategories: TArray<string> read FTaskCategories write FTaskCategories;
    property SizeCategories: TArray<string> read FSizeCategories write FSizeCategories;
    property Configs: TArray<TCardDataConfig> read FConfigs write FConfigs;
    destructor Destroy; override;
  end;

  TTransformersInfo = class
  private
    [JsonNameAttribute('auto_model')]
    FAutoModel: string;
    [JsonNameAttribute('pipeline_tag')]
    FPipelineTag: string;
    FProcessor: string;
  public
    property AutoModel: string read FAutoModel write FAutoModel;
    property PipelineTag: string read FPipelineTag write FPipelineTag;
    property Processor: string read FProcessor write FProcessor;
  end;

  TSafetensorsParameters = class
  private
    FF16: int64;
  public
    property F16: int64 read FF16 write FF16;
  end;

  TSafetensors = class
  private
    FParameters: TSafetensorsParameters;
    FTotal: Int64;
  public
    property Parameters: TSafetensorsParameters read FParameters write FParameters;
    property Total: Int64 read FTotal write FTotal;
    destructor Destroy; override;
  end;

  TResultTask = class
  private
    FName: string;
    FType: string;
  public
    property Name: string read FName write FName;
    property &Type: string read FType write FType;
  end;

  TDataSetArgs = class
  private
    FLanguage: string;
  public
    property Language: string read FLanguage write FLanguage;
  end;

  TResultDataset = class
  private
    FName: string;
    FType: string;
    FConfig: string;
    FSplit: string;
    FArgs: TDataSetArgs;
  public
    property Name: string read FName write FName;
    property &Type: string read FType write FType;
    property Config: string read FConfig write FConfig;
    property Split: string read FSplit write FSplit;
    property Args: TDataSetArgs read FArgs write FArgs;
    destructor Destroy; override;
  end;

  TResultMetrics = class
  private
    FName: string;
    FType: string;
    FValue: Double;
    FVerified: Boolean;
  public
    property Name: string read FName write FName;
    property &Type: string read FType write FType;
    property Value: Double read FValue write FValue;
    property Verified: Boolean read FVerified write FVerified;
  end;

  TModelResult = class
  private
    FTask: TResultTask;
    FDataset: TResultDataset;
    FMetrics: TArray<TResultMetrics>;
  public
    property Task: TResultTask read FTask write FTask;
    property Dataset: TResultDataset read FDataset write FDataset;
    property Metrics: TArray<TResultMetrics> read FMetrics write FMetrics;
    destructor Destroy; override;
  end;

  TModelIndexItem = class
  private
    FName: string;
    FResults: TArray<TModelResult>;
  public
    property Name: string read FName write FName;
    property Results: TArray<TModelResult> read FResults write FResults;
    destructor Destroy; override;
  end;

  TModel = class
  private
    F_id: string;
    FId: string;
    FAuthor: string;
    FGated: Boolean;
    FInference: string;
    FLastModified: string;
    FLikes: Int64;
    FTrendingScore: Int64;
    FPrivate: Boolean;
    FSha: string;
    FConfig: TConfig;
    FDownloads: Int64;
    FTags: TArray<string>;
    [JsonNameAttribute('pipeline_tag')]
    FPipelineTag: string;
    [JsonNameAttribute('library_name')]
    FLibraryName: string;
    FCreatedAt: string;
    FModelId: string;
    FSiblings: TArray<TSibling>;
  public
    property _id: string read F_id write F_id;
    property Id: string read FId write FId;
    property Author: string read FAuthor write FAuthor;
    property Gated: Boolean read FGated write FGated;
    property Inference: string read FInference write FInference;
    property LastModified: string read FLastModified write FLastModified;
    property Likes: Int64 read FLikes write FLikes;
    property TrendingScore: Int64 read FTrendingScore write FTrendingScore;
    property &Private: Boolean read FPrivate write FPrivate;
    property Sha: string read FSha write FSha;
    property Config: TConfig read FConfig write FConfig;
    property Downloads: Int64 read FDownloads write FDownloads;
    property Tags: TArray<string> read FTags write FTags;
    property PipelineTag: string read FPipelineTag write FPipelineTag;
    property LibraryName: string read FLibraryName write FLibraryName;
    property CreatedAt: string read FCreatedAt write FCreatedAt;
    property ModelId: string read FModelId write FModelId;
    property Siblings: TArray<TSibling> read FSiblings write FSiblings;
    destructor Destroy; override;
  end;

  TModels = class
  private
    FItems: TArray<TModel>;
    FUrlNext: string;
  public
    property Items: TArray<TModel> read FItems write FItems;
    property UrlNext: string read FUrlNext write FUrlNext;
    destructor Destroy; override;
  end;

  TRepoModel = class(TModel)
  private
    FDisabled: Boolean;
    FWidgetData: TArray<TWidgetDataItem>;
    [JsonNameAttribute('model-index')]
    FModelIndex: TArray<TModelIndexItem>;
    FCardData: TCardData;
    FTransformersInfo: TTransformersInfo;
    FSpaces: TArray<string>;
    FSafetensors: TSafetensors;
  public
    property Disabled: Boolean read FDisabled write FDisabled;
    property WidgetData: TArray<TWidgetDataItem> read FWidgetData write FWidgetData;
    property ModelIndex: TArray<TModelIndexItem> read FModelIndex write FModelIndex;
    property CardData: TCardData read FCardData write FCardData;
    property TransformersInfo: TTransformersInfo read FTransformersInfo write FTransformersInfo;
    property Spaces: TArray<string> read FSpaces write FSpaces;
    property Safetensors: TSafetensors read FSafetensors write FSafetensors;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TModels</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModels</c> type extends the <c>TAsynParams&lt;TModels&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynModels = TAsynCallBack<TModels>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TRepoModel</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRepoModel</c> type extends the <c>TAsynParams&lt;TRepoModel&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynRepoModel = TAsynCallBack<TRepoModel>;

  THubRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Fetch model by ID
    /// </summary>
    /// <param name="RepoId">
    /// The model's Id to fetch
    /// </param>
    /// <returns>
    /// A <c>TRepoModel</c> object containing the model returned.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HFHub := THuggingFaceFactory.CreateInstance(BaererKey, True);
    /// var Value := HFHub.Hub.FetchModel('modelId');
    /// try
    ///   // Handle the Value
    /// finally
    ///   Value.Free;
    /// end;
    /// </code>
    /// </remarks>
    function FetchModel(const RepoId: string): TRepoModel; overload;
    /// <summary>
    /// Fetch model by ID
    /// </summary>
    /// <param name="RepoId">
    /// The model's Id to fetch
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynRepoModel</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HFHub := THuggingFaceFactory.CreateInstance(BaererKey, True);
    /// HFHub.Hub.FetchModel('modelId',
    ///   function : TAsynRepoModel
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
    ///        procedure (Sender: TObject; Value: TRepoModel)
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
    procedure FetchModel(const RepoId: string; CallBacks: TFunc<TAsynRepoModel>); overload;
    /// <summary>
    /// Fetch a filtered list of model.
    /// </summary>
    /// <param name="UrlNext">
    /// The URL of the next page of result.
    /// <para>
    /// If Url Next is empty then the first page is fetched
    /// </para>
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TFetchParams</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TModels</c> object containing the list of fetched models.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HFHub := THuggingFaceFactory.CreateInstance(BaererKey, True);
    /// var Value := HFHub.Hub.FetchModels(UrlNext,
    ///     procedure (Params: TFetchParams)
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
    function FetchModels(UrlNext: string; ParamProc: TProc<TFetchParams>): TModels; overload;
    /// <summary>
    /// Fetch a filtered list of model.
    /// </summary>
    /// <param name="UrlNext">
    /// The URL of the next page of result.
    /// <para>
    /// If Url Next is empty then the first page is fetched
    /// </para>
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TFetchParams</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynModels</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HFHub := THuggingFaceFactory.CreateInstance(BaererKey, True);
    /// HFHub.Hub.FetchModels(UrlNext,
    ///   procedure (Params: TFetchParams)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynModels
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
    ///        procedure (Sender: TObject; Value: TModels)
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
    procedure FetchModels(UrlNext: string;
      ParamProc: TProc<TFetchParams>; CallBacks: TFunc<TAsynModels>); overload;
  end;

implementation

{ TConfig }

destructor TConfig.Destroy;
begin
  if Assigned(FTokenizerConfig) then
    FTokenizerConfig.Free;
  if Assigned(FProcessorConfig) then
    FProcessorConfig.Free;
  inherited;
end;

{ TModel }

destructor TModel.Destroy;
begin
  if Assigned(FConfig) then
    FConfig.Free;
  for var Item in FSiblings do
    Item.Free;
  inherited;
end;

{ TModels }

destructor TModels.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ THubRoute }

function THubRoute.FetchModel(const RepoId: string): TRepoModel;
begin
  Result := API.Get<TRepoModel>('api/models/' + RepoId);
end;

function THubRoute.FetchModels(UrlNext: string; ParamProc: TProc<TFetchParams>): TModels;

  procedure Fetch;
  begin
    var Params := TFetchParams.Create;
    try
      ParamProc(Params);
      Result := API.Get<TModels>('api/models' + Params.Value, UrlNext);
    finally
      Params.Free;
    end;
  end;

  procedure Next;
  begin
    Result := API.GetLink<TModels>(UrlNext);
  end;

begin
  if UrlNext.IsEmpty then
    Fetch else
    Next;
  Result.UrlNext := UrlNext;
end;

procedure THubRoute.FetchModel(const RepoId: string;
  CallBacks: TFunc<TAsynRepoModel>);
begin
  with TAsynCallBackExec<TAsynRepoModel, TRepoModel>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRepoModel
      begin
        Result := Self.FetchModel(RepoId);
      end);
  finally
    Free;
  end;
end;

procedure THubRoute.FetchModels(UrlNext: string;
  ParamProc: TProc<TFetchParams>; CallBacks: TFunc<TAsynModels>);
begin
  with TAsynCallBackExec<TAsynModels, TModels>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModels
      begin
        Result := Self.FetchModels(UrlNext, ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TCardData }

destructor TCardData.Destroy;
begin
  for var Item in FWidget do
    Item.Free;
  for var Item in FModelIndex do
    Item.Free;
  for var Item in FConfigs do
    Item.Free;
  inherited;
end;

{ TSafetensors }

destructor TSafetensors.Destroy;
begin
  if Assigned(FParameters) then
    FParameters.Free;
  inherited;
end;

{ TModelIndexItem }

destructor TModelIndexItem.Destroy;
begin
  for var Item in FResults do
    Item.Free;
  inherited;
end;

{ TModelResult }

destructor TModelResult.Destroy;
begin
  if Assigned(FTask) then
    FTask.Free;
  if Assigned(FDataset) then
    FDataset.Free;
  for var Item in FMetrics  do
    Item.Free;
  inherited;
end;

{ TResultDataset }

destructor TResultDataset.Destroy;
begin
  if Assigned(FArgs) then
    FArgs.Free;
  inherited;
end;

{ TRepoModel }

destructor TRepoModel.Destroy;
begin
  for var Item in FWidgetData do
    Item.Free;
  for var Item in FModelIndex do
    Item.Free;  
  if Assigned(FCardData) then
    FCardData.Free;
  if Assigned(FTransformersInfo) then
    FTransformersInfo.Free;
  if Assigned(FSafetensors) then
    FSafetensors.Free;
  inherited;
end;

{ TCardDataConfig }

destructor TCardDataConfig.Destroy;
begin
  for var Item in FDataFiles do
    Item.Free;
  inherited;
end;

end.
