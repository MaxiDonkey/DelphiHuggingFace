unit HuggingFace.Aggregator;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  HuggingFace.Hub.Support, HuggingFace.Functions.Core, HuggingFace.Image,
  HuggingFace.Mask,HuggingFace.Embeddings, HuggingFace.Audio, HuggingFace.Chat,
  HuggingFace.Text, HuggingFace.Hub.Search, HuggingFace.Schema;

type
  {$REGION 'HuggingFace.Text'}

  TQuestionAnswering = HuggingFace.Text.TQuestionAnswering;
  TAsynQuestionAnswering = HuggingFace.Text.TAsynQuestionAnswering;
  TQuestionAnsweringParam = HuggingFace.Text.TQuestionAnsweringParam;
  TQuestionAnsweringParameters = HuggingFace.Text.TQuestionAnsweringParameters;
  TQuestionAnsweringInputs = HuggingFace.Text.TQuestionAnsweringInputs;

  TSummarization = HuggingFace.Text.TSummarization;
  TAsynSummarization = HuggingFace.Text.TAsynSummarization;
  TSummarizationParam = HuggingFace.Text.TSummarizationParam;
  TSummarizationItem = HuggingFace.Text.TSummarizationItem;
  TSummarizationParameters = HuggingFace.Text.TSummarizationParameters;

  TTableQA = HuggingFace.Text.TTableQA;
  TAsynTableQA = HuggingFace.Text.TAsynTableQA;
  TTableQAParam = HuggingFace.Text.TTableQAParam;
  TRow = HuggingFace.Text.TRow;
  TTableQAInputs = HuggingFace.Text.TTableQAInputs;
  TTableQAParameters = HuggingFace.Text.TTableQAParameters;

  TTextClassification = HuggingFace.Text.TTextClassification;
  TAsynTextClassification = HuggingFace.Text.TAsynTextClassification;
  TTextClassificationParam = HuggingFace.Text.TTextClassificationParam;
  TTextClassificationParameters = HuggingFace.Text.TTextClassificationParameters;
  TTextClassificationItem = HuggingFace.Text.TTextClassificationItem;

  TTextToImage = HuggingFace.Text.TTextToImage;
  TAsynTextToImage = HuggingFace.Text.TAsynTextToImage;
  TTextToImageParam = HuggingFace.Text.TTextToImageParam;
  TTextToImageParameters = HuggingFace.Text.TTextToImageParameters;
  TTargetSizeParam = HuggingFace.Text.TTargetSizeParam;

  TTokenClassification = HuggingFace.Text.TTokenClassification;
  TAsynTokenClassification = HuggingFace.Text.TAsynTokenClassification;
  TTokenClassificationParam = HuggingFace.Text.TTokenClassificationParam;
  TTokenClassificationParameters = HuggingFace.Text.TTokenClassificationParameters;
  TTokenClassificationItem = HuggingFace.Text.TTokenClassificationItem;

  TTranslation = HuggingFace.Text.TTranslation;
  TAsynTranslation = HuggingFace.Text.TAsynTranslation;
  TTranslationParam = HuggingFace.Text.TTranslationParam;
  TTranslationParameters = HuggingFace.Text.TTranslationParameters;
  TTranslationItem = HuggingFace.Text.TTranslationItem;

  TZeroShotClassification = HuggingFace.Text.TZeroShotClassification;
  TAsynZeroShotClassification= HuggingFace.Text.TAsynZeroShotClassification;
  TZeroShotClassificationParam = HuggingFace.Text.TZeroShotClassificationParam;
  TZeroShotClassificationParameters = HuggingFace.Text.TZeroShotClassificationParameters;

  TTextGeneration = HuggingFace.Text.TTextGeneration;
  TAsynTextGeneration = HuggingFace.Text.TAsynTextGeneration;
  TAsynTextGenerationStream = HuggingFace.Text.TAsynTextGenerationStream;
  TTextGenerationParam = HuggingFace.Text.TTextGenerationParam;
  TTextGenerationParameters = HuggingFace.Text.TTextGenerationParameters;
  TTextGenerationItem = HuggingFace.Text.TTextGenerationItem;
  TBestOfSequences = HuggingFace.Text.TBestOfSequences;
  TPrefill = HuggingFace.Text.TPrefill;
  TTokens = HuggingFace.Text.TTokens;
  TDetails = HuggingFace.Text.TDetails;

  TSentimentAnalysis = HuggingFace.Text.TSentimentAnalysis;
  TAsynSentimentAnalysis = HuggingFace.Text.TAsynSentimentAnalysis;
  TSentimentAnalysisParams = HuggingFace.Text.TSentimentAnalysisParams;
  TEval = HuggingFace.Text.TEval;
  TEvals = HuggingFace.Text.TEvals;

  TTextToSpeech = HuggingFace.Text.TTextToSpeech;
  TAsynTextToSpeech = HuggingFace.Text.TAsynTextToSpeech;
  TTextToSpeechParam = HuggingFace.Text.TTextToSpeechParam;
  TTextToAudioParam = HuggingFace.Text.TTextToAudioParam;

  TTextToAudio = HuggingFace.Text.TTextToAudio;
  TAsynTextToAudio = HuggingFace.Text.TAsynTextToAudio;

  {$ENDREGION}

  {$REGION 'HuggingFace.Hub.Search'}

  TModel = HuggingFace.Hub.Search.TModel;
  TModels = HuggingFace.Hub.Search.TModels;
  TRepoModel = HuggingFace.Hub.Search.TRepoModel;
  TAsynModels = HuggingFace.Hub.Search.TAsynModels;
  TAsynRepoModel = HuggingFace.Hub.Search.TAsynRepoModel;
  TTokenizerConfig = HuggingFace.Hub.Search.TTokenizerConfig;
  TProcessorConfig = HuggingFace.Hub.Search.TProcessorConfig;
  TConfig = HuggingFace.Hub.Search.TConfig;
  TSibling = HuggingFace.Hub.Search.TSibling;
  TWidgetDataItem = HuggingFace.Hub.Search.TWidgetDataItem;
  TDataFiles = HuggingFace.Hub.Search.TDataFiles;
  TCardDataConfig = HuggingFace.Hub.Search.TCardDataConfig;
  TCardData = HuggingFace.Hub.Search.TCardData;
  TTransformersInfo = HuggingFace.Hub.Search.TTransformersInfo;
  TSafetensorsParameters = HuggingFace.Hub.Search.TSafetensorsParameters;
  TSafetensors = HuggingFace.Hub.Search.TSafetensors;
  TResultTask = HuggingFace.Hub.Search.TResultTask;
  TDataSetArgs = HuggingFace.Hub.Search.TDataSetArgs;
  TResultDataset = HuggingFace.Hub.Search.TResultDataset;
  TResultMetrics = HuggingFace.Hub.Search.TResultMetrics;
  TModelResult = HuggingFace.Hub.Search.TModelResult;
  TModelIndexItem = HuggingFace.Hub.Search.TModelIndexItem;

  {$ENDREGION}

  {$REGION 'HuggingFace.Hub.Support'}

  TFetchParams = HuggingFace.Hub.Support.TFetchParams;

  {$ENDREGION}

  {$REGION 'HuggingFace.Schema'}

  TPropertyItem = HuggingFace.Schema.TPropertyItem;
  TSchemaParams = HuggingFace.Schema.TSchemaParams;

  {$ENDREGION}

  {$REGION 'HuggingFace.Functions.Core'}

  IFunctionCore = HuggingFace.Functions.Core.IFunctionCore;
  TFunctionCore = HuggingFace.Functions.Core.TFunctionCore;

  {$ENDREGION}

  {$REGION 'HuggingFace.Chat'}

  TChat = HuggingFace.Chat.TChat;
  TChatPayload = HuggingFace.Chat.TChatPayload;
  TChoice = HuggingFace.Chat.TChoice;
  TAsynChat = HuggingFace.Chat.TAsynChat;
  TAsynChatStream = HuggingFace.Chat.TAsynChatStream;
  TContentPayload = HuggingFace.Chat.TContentPayload;
  TPayload = HuggingFace.Chat.TPayload;
  TResponseFormat = HuggingFace.Chat.TResponseFormat;
  TFunctionCalled = HuggingFace.Chat.TFunctionCalled;
  TToolCalls = HuggingFace.Chat.TToolCalls;
  TChoiceMessage = HuggingFace.Chat.TChoiceMessage;
  TTopLogprobs = HuggingFace.Chat.TTopLogprobs;
  TLogprobContent = HuggingFace.Chat.TLogprobContent;
  TLogprobs = HuggingFace.Chat.TLogprobs;
  TUsage = HuggingFace.Chat.TUsage;
  TChatEvent = HuggingFace.Chat.TChatEvent;

  {$ENDREGION}

  {$REGION 'HuggingFace.Audio'}

  TGenerationParameters = HuggingFace.Audio.TGenerationParameters;
  TRecognitionParameters = HuggingFace.Audio.TRecognitionParameters;

  TAudioChunk = HuggingFace.Audio.TAudioChunk;
  TAudioToText = HuggingFace.Audio.TAudioToText;
  TAsynAudioToText = HuggingFace.Audio.TAsynAudioToText;
  TAudioToTextParam = HuggingFace.Audio.TAudioToTextParam;

  TAudioClassification = HuggingFace.Audio.TAudioClassification;
  TAsynAudioClassification = HuggingFace.Audio.TAsynAudioClassification;
  TAudioClassificationParam = HuggingFace.Audio.TAudioClassificationParam;
  TAudioClassificationParameters = HuggingFace.Audio.TAudioClassificationParameters;
  TAudioClassificationItem = HuggingFace.Audio.TAudioClassificationItem;

  TAudioToAudio = HuggingFace.Audio.TAudioToAudio;
  TAsynAudioToAudio = HuggingFace.Audio.TAsynAudioToAudio;
  TAudioToAudioParam = HuggingFace.Audio.TAudioToAudioParam;

  {$ENDREGION}

  {$REGION 'HuggingFace.Embeddings'}

  TEmbeddings = HuggingFace.Embeddings.TEmbeddings;
  TAsynEmbeddings = HuggingFace.Embeddings.TAsynEmbeddings;
  TEmbeddingParams = HuggingFace.Embeddings.TEmbeddingParams;

  {$ENDREGION}

  {$REGION 'HuggingFace.Mask'}

  TMask = HuggingFace.Mask.TMask;
  TAsynMask = HuggingFace.Mask.TAsynMask;
  TMaskParam = HuggingFace.Mask.TMaskParam;
  TMaskParameters = HuggingFace.Mask.TMaskParameters;
  TMaskItem = HuggingFace.Mask.TMaskItem;

  {$ENDREGION}

  {$REGION 'HuggingFace.Image'}

  TImageClassification = HuggingFace.Image.TImageClassification;
  TAsynImageClassification = HuggingFace.Image.TAsynImageClassification;
  TImageClassificationParam = HuggingFace.Image.TImageClassificationParam;
  TImageClassificationItem = HuggingFace.Image.TImageClassificationItem;

  TImageSegmentation = HuggingFace.Image.TImageSegmentation;
  TAsynImageSegmentation = HuggingFace.Image.TAsynImageSegmentation;
  TImageSegmentationParam = HuggingFace.Image.TImageSegmentationParam;
  TImageSegmentationParameters = HuggingFace.Image.TImageSegmentationParameters;
  TImageSegmentationItem = HuggingFace.Image.TImageSegmentationItem;

  TObjectDetection = HuggingFace.Image.TObjectDetection;
  TAsynObjectDetection = HuggingFace.Image.TAsynObjectDetection;
  TObjectDetectionParam = HuggingFace.Image.TObjectDetectionParam;
  TObjectDetectionItem = HuggingFace.Image.TObjectDetectionItem;

  TImageToImage = HuggingFace.Image.TImageToImage;
  TAsynImageToImage = HuggingFace.Image.TAsynImageToImage;
  TImageToImageParam = HuggingFace.Image.TImageToImageParam;

  {$ENDREGION}

implementation

end.
