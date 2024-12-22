unit HuggingFace.Image;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, REST.JsonReflect, System.JSON,
  Rest.Json, REST.Json.Types, System.Net.URLClient, HuggingFace.API, HuggingFace.API.Params,
  HuggingFace.Async.Support, HuggingFace.Types;

type

  {$REGION 'Image Classification'}

  TImageClassificationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Possible values: sigmoid, softmax, none.
    /// </summary>
    function FunctionToApply(const Value: TFunctionClassification): TImageClassificationParameters;
    /// <summary>
    /// When specified, limits the output to the top K most probable classes.
    /// </summary>
    function TopK(const Value: Integer): TImageClassificationParameters;
  end;

  TImageClassificationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input image data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the image file
    /// </param>
    function Inputs(const FileName: string): TImageClassificationParam;
    /// <summary>
    /// Classification parameters
    /// </summary>
    function parameters(const FunctionToApply: TFunctionClassification; const TopK: Integer = -1): TImageClassificationParam; overload;
    /// <summary>
    /// Set top_k Classification parameter
    /// </summary>
    function parameters(const TopK: Integer): TImageClassificationParam; overload;
  end;

  TImageClassificationItem = class
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

  TImageClassification = class
  private
    FItems: TArray<TImageClassificationItem>;
  public
    /// <summary>
    /// Output is an array of objects.
    /// </summary>
    property Items: TArray<TImageClassificationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TImageClassification</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImageClassification</c> type extends the <c>TAsynParams&lt;TImageClassification&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynImageClassification = TAsynCallBack<TImageClassification>;

  {$ENDREGION}

  {$REGION 'Image Segmentation'}

  TImageSegmentationParameters = class(TJSONParam)
  public
    /// <summary>
    /// Threshold to use when turning the predicted masks into binary values.
    /// </summary>
    function MaskThreshold(const Value: Double): TImageSegmentationParameters;
    /// <summary>
    /// Mask overlap threshold to eliminate small, disconnected segments.
    /// </summary>
    function OverlapMaskAreaThreshold(const Value: Double): TImageSegmentationParameters;
    /// <summary>
    /// Possible values: instance, panoptic, semantic.
    /// </summary>
    function Subtask(const Value: TSubtaskType): TImageSegmentationParameters;
    /// <summary>
    /// Probability threshold to filter out predicted masks.
    /// </summary>
    function Threshold(const Value: Double): TImageSegmentationParameters;
  end;

  TImageSegmentationParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input image data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the image file
    /// </param>
    function Inputs(const FileName: string): TImageSegmentationParam;
    /// <summary>
    /// Segmentation parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TImageSegmentationParameters>): TImageSegmentationParam;
  end;

  TJSONImageSegmentation = class
  private
    FLabel: string;
    FMask: string;
    FScore: Double;
  public
    /// <summary>
    /// The label of the predicted segment.
    /// </summary>
    property &Label: string read FLabel write FLabel;
    /// <summary>
    /// The corresponding mask as a black-and-white image (base64-encoded).
    /// </summary>
    property Mask: string read FMask write FMask;
    /// <summary>
    /// The score or confidence degree the model has.
    /// </summary>
    property Score: Double read FScore write FScore;
  end;

  TImageSegmentationItem = class(TJSONImageSegmentation)
  private
    FFileName: string;
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
    /// Raises an exception if both the image data are empty.
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

  TImageSegmentation = class
  private
    FItems: TArray<TImageSegmentationItem>;
  public
    /// <summary>
    /// Output is an array of objects.
    /// </summary>
    property Items: TArray<TImageSegmentationItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TImageSegmentation</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImageSegmentation</c> type extends the <c>TAsynParams&lt;TImageSegmentation&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynImageSegmentation = TAsynCallBack<TImageSegmentation>;

  {$ENDREGION}

  {$REGION 'Object Detection'}

  TObjectDetectionParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input image data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the image file
    /// </param>
    function Inputs(const FileName: string): TObjectDetectionParam;
    /// <summary>
    /// The probability necessary to make a prediction.
    /// </summary>
    function Parameters(const Threshold: Double): TObjectDetectionParam;
  end;

  TObjectDetectionBox = class
  private
    FXmin: Integer;
    FXmax: Integer;
    FYmin: Integer;
    FYmax: Integer;
  public
    /// <summary>
    /// The x-coordinate of the top-left corner of the bounding box.
    /// </summary>
    property Xmin: Integer read FXmin write FXmin;
    /// <summary>
    /// The x-coordinate of the bottom-right corner of the bounding box.
    /// </summary>
    property Xmax: Integer read FXmax write FXmax;
    /// <summary>
    /// The y-coordinate of the top-left corner of the bounding box.
    /// </summary>
    property Ymin: Integer read FYmin write FYmin;
    /// <summary>
    /// The y-coordinate of the bottom-right corner of the bounding box.
    /// </summary>
    property Ymax: Integer read FYmax write FYmax;
  end;

  TObjectDetectionItem = class
  private
    FLabel: string;
    FScore: Double;
    FBox: TObjectDetectionBox;
  public
    function ToRect: TRect;
    /// <summary>
    /// The predicted label for the bounding box.
    /// </summary>
    property &Label: string read FLabel write FLabel;
    /// <summary>
    /// The associated score / probability.
    /// </summary>
    property Score: Double read FScore write FScore;
    property Box: TObjectDetectionBox read FBox write FBox;
    destructor Destroy; override;
  end;

  TObjectDetection = class
  private
    FItems: TArray<TObjectDetectionItem>;
  public
    /// <summary>
    /// Output is an array of objects.
    /// </summary>
    property Items: TArray<TObjectDetectionItem> read FItems write FItems;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TObjectDetection</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynObjectDetection</c> type extends the <c>TAsynParams&lt;TObjectDetection&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynObjectDetection = TAsynCallBack<TObjectDetection>;

  {$ENDREGION}

  {$REGION 'Image To Image'}

  TTargetSizeParam = class(TJSONParam)
  public
    function Width(const Value: Integer): TTargetSizeParam;
    function Height(const Value: Integer): TTargetSizeParam;
  end;

  TImageToImageParameters = class(TJSONParam)
  public
    /// <summary>
    /// For diffusion models. A higher guidance scale value encourages the model to generate images
    /// closely linked to the text prompt at the expense of lower image quality.
    /// </summary>
    function GuidanceScale(const Value: Double): TImageToImageParameters;
    /// <summary>
    /// One or several prompt to guide what NOT to include in image generation.
    /// </summary>
    function NegativePrompt(const Value: TArray<string>): TImageToImageParameters;
    /// <summary>
    /// For diffusion models. The number of denoising steps. More denoising steps usually lead to
    /// a higher quality image at the expense of slower inference.
    /// </summary>
    function NumInferenceSteps(const Value: Integer): TImageToImageParameters;
    /// <summary>
    /// The size in pixel of the output image.
    /// </summary>
    function TargetSize(const Width, Height: Integer): TImageToImageParameters;
  end;

  TImageToImageParam = class(TJSONModelParam)
  public
    /// <summary>
    /// The input image data as a base64-encoded string.
    /// </summary>
    /// <param name="FileName">
    /// The path and the name of the image file
    /// </param>
    function Inputs(const FileName: string): TImageToImageParam;
    /// <summary>
    /// Set parameters
    /// </summary>
    function Parameters(ParamProc: TProcRef<TImageToImageParameters>): TImageToImageParam;
  end;

  TImageToImage = class
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
  /// Manages asynchronous callBacks for a request using <c>TImageToImage</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynImageToImage</c> type extends the <c>TAsynParams&lt;TImageToImage&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynImageToImage = TAsynCallBack<TImageToImage>;

  {$ENDREGION}

  TImageRoute = class(THuggingFaceAPIRoute)
    /// <summary>
    /// Image classification is the task of assigning a label or class to an entire image.
    /// Images are expected to have only one class for each image.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageClassificationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TImageClassification</c> object containing the Classification result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Image.Classification(
    ///     procedure (Params: TImageClassificationParam)
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
    function Classification(ParamProc: TProc<TImageClassificationParam>): TImageClassification; overload;
    /// <summary>
    /// Image classification is the task of assigning a label or class to an entire image.
    /// Images are expected to have only one class for each image.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageClassificationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynImageClassification</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Image.Classification(
    ///   procedure (Params: TImageClassificationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynImageClassification
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
    procedure Classification(ParamProc: TProc<TImageClassificationParam>;
      CallBacks: TFunc<TAsynImageClassification>); overload;
    /// <summary>
    /// Image processing from the model.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageToImageParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TImageToImage</c> object containing the ImageToImage result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Image.ImageToImage(
    ///     procedure (Params: TImageToImageParam)
    ///     begin
    ///       // Define parameters
    ///     end;
    /// try
    ///   WriteLn(Value.Text);
    /// finally
    ///   // Handle the Value
    /// end;
    /// </code>
    /// </remarks>
    function ImageToImage(ParamProc: TProc<TImageToImageParam>): TImageToImage; overload;
    /// <summary>
    /// Image classification is the task of assigning a label or class to an entire image.
    /// Images are expected to have only one class for each image.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageToImageParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynImageToImage</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Image.ImageToImage(
    ///   procedure (Params: TImageToImageParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynImageToImage
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
    ///        procedure (Sender: TObject; Value: TImageToImage)
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
    procedure ImageToImage(ParamProc: TProc<TImageToImageParam>;
      CallBacks: TFunc<TAsynImageToImage>); overload;
    /// <summary>
    /// Object Detection models allow users to identify objects of certain defined classes.
    /// These models receive an image as input and output the images with bounding boxes and
    /// labels on detected objects.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TObjectDetectionParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TObjectDetection</c> object containing the ObjectDetection result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Image.ObjectDetection(
    ///     procedure (Params: TObjectDetectionParam)
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
    function ObjectDetection(ParamProc: TProc<TObjectDetectionParam>): TObjectDetection; overload;
    /// <summary>
    /// Object Detection models allow users to identify objects of certain defined classes.
    /// These models receive an image as input and output the images with bounding boxes and
    /// labels on detected objects.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TObjectDetectionParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynObjectDetection</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Image.ObjectDetection(
    ///   procedure (Params: TObjectDetectionParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynObjectDetection
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
    ///        procedure (Sender: TObject; Value: TObjectDetection)
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
    procedure ObjectDetection(ParamProc: TProc<TObjectDetectionParam>;
      CallBacks: TFunc<TAsynObjectDetection>); overload;
    /// <summary>
    /// Image Segmentation divides an image into segments where each pixel in the image is mapped to an object.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageSegmentationParam</c> parameters.
    /// </param>
    /// <returns>
    /// A <c>TImageSegmentation</c> object containing the Segmentation result.
    /// </returns>
    /// <remarks>
    /// <code>
    /// //WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// var Value := HuggingFace.Image.Segmentation(
    ///     procedure (Params: TImageSegmentationParam)
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
    function Segmentation(ParamProc: TProc<TImageSegmentationParam>): TImageSegmentation; overload;
    /// <summary>
    /// Image Segmentation divides an image into segments where each pixel in the image is mapped to an object.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the <c>TImageSegmentationParam</c> parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns <c>TAsynImageSegmentation</c> to handle the asynchronous result.
    /// </param>
    /// <remarks>
    /// <para>
    /// The <c>CallBacks</c> function is invoked when the operation completes, either successfully or with an error.
    /// </para>
    /// <code>
    /// // WARNING - Move the following line into the main OnCreate
    /// //var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// HuggingFace.Image.Segmentation(
    ///   procedure (Params: TImageSegmentationParam)
    ///   begin
    ///     // Define parameters
    ///   end,
    ///
    ///   function : TAsynImageSegmentation
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
    ///        procedure (Sender: TObject; Value: TImageSegmentation)
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
    procedure Segmentation(ParamProc: TProc<TImageSegmentationParam>;
      CallBacks: TFunc<TAsynImageSegmentation>); overload;
  end;

implementation

uses
  HuggingFace.NetEncoding.Base64;

{ TImageClassificationParam }

function TImageClassificationParam.Inputs(
  const FileName: string): TImageClassificationParam;
begin
  Result := TImageClassificationParam(Add('inputs', EncodeBase64(FileName)));
end;

function TImageClassificationParam.parameters(
  const FunctionToApply: TFunctionClassification;
  const TopK: Integer): TImageClassificationParam;
begin
  var Value := TImageClassificationParameters.Create.FunctionToApply(FunctionToApply);
  if TopK <> -1 then
    Value := Value.TopK(TopK);
  Result := TImageClassificationParam(Add('parameters', Value.Detach));
end;

function TImageClassificationParam.parameters(
  const TopK: Integer): TImageClassificationParam;
begin
  Result := TImageClassificationParam(Add('parameters', TImageClassificationParameters.Create.TopK(TopK).Detach));
end;

{ TImageClassificationParameters }

function TImageClassificationParameters.FunctionToApply(
  const Value: TFunctionClassification): TImageClassificationParameters;
begin
  Result := TImageClassificationParameters(Add('function_to_apply', Value.ToString));
end;

function TImageClassificationParameters.TopK(
  const Value: Integer): TImageClassificationParameters;
begin
  Result := TImageClassificationParameters(Add('top_k', Value));
end;

{ TImageClassification }

destructor TImageClassification.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TImageRoute }

function TImageRoute.Classification(
  ParamProc: TProc<TImageClassificationParam>): TImageClassification;
begin
  Result := API.Post<TImageClassification, TImageClassificationParam>('models', ParamProc);
end;

procedure TImageRoute.Classification(
  ParamProc: TProc<TImageClassificationParam>;
  CallBacks: TFunc<TAsynImageClassification>);
begin
  with TAsynCallBackExec<TAsynImageClassification, TImageClassification>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TImageClassification
      begin
        Result := Self.Classification(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TImageRoute.ImageToImage(
  ParamProc: TProc<TImageToImageParam>): TImageToImage;
begin
  Result := API.Post<TImageToImage, TImageToImageParam>('models', ParamProc, 'image');
end;

procedure TImageRoute.ImageToImage(ParamProc: TProc<TImageToImageParam>;
  CallBacks: TFunc<TAsynImageToImage>);
begin
  with TAsynCallBackExec<TAsynImageToImage, TImageToImage>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TImageToImage
      begin
        Result := Self.ImageToImage(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TImageRoute.ObjectDetection(ParamProc: TProc<TObjectDetectionParam>;
  CallBacks: TFunc<TAsynObjectDetection>);
begin
  with TAsynCallBackExec<TAsynObjectDetection, TObjectDetection>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TObjectDetection
      begin
        Result := Self.ObjectDetection(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TImageRoute.ObjectDetection(
  ParamProc: TProc<TObjectDetectionParam>): TObjectDetection;
begin
  Result := API.Post<TObjectDetection, TObjectDetectionParam>('models', ParamProc);
end;

procedure TImageRoute.Segmentation(ParamProc: TProc<TImageSegmentationParam>;
  CallBacks: TFunc<TAsynImageSegmentation>);
begin
  with TAsynCallBackExec<TAsynImageSegmentation, TImageSegmentation>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TImageSegmentation
      begin
        Result := Self.Segmentation(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TImageRoute.Segmentation(
  ParamProc: TProc<TImageSegmentationParam>): TImageSegmentation;
begin
  Result := API.Post<TImageSegmentation, TImageSegmentationParam>('models', ParamProc);
end;

{ TImageSegmentationParam }

function TImageSegmentationParam.Inputs(
  const FileName: string): TImageSegmentationParam;
begin
  Result := TImageSegmentationParam(Add('inputs', EncodeBase64(FileName)));
end;

function TImageSegmentationParam.Parameters(
  ParamProc: TProcRef<TImageSegmentationParameters>): TImageSegmentationParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TImageSegmentationParameters.Create;
      ParamProc(Value);
      Result := TImageSegmentationParam(Add('parameters', Value));
    end
  else Result := Self;
end;

{ TImageSegmentationParameters }

function TImageSegmentationParameters.MaskThreshold(
  const Value: Double): TImageSegmentationParameters;
begin
  Result := TImageSegmentationParameters(Add('mask_threshold', Value));
end;

function TImageSegmentationParameters.OverlapMaskAreaThreshold(
  const Value: Double): TImageSegmentationParameters;
begin
  Result := TImageSegmentationParameters(Add('overlap_mask_area_threshold', Value));
end;

function TImageSegmentationParameters.Subtask(
  const Value: TSubtaskType): TImageSegmentationParameters;
begin
  Result := TImageSegmentationParameters(Add('subtask', Value.ToString));
end;

function TImageSegmentationParameters.Threshold(
  const Value: Double): TImageSegmentationParameters;
begin
  Result := TImageSegmentationParameters(Add('threshold', Value));
end;

{ TImageSegmentation }

destructor TImageSegmentation.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TImageSegmentationItem }

function TImageSegmentationItem.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Mask, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TImageSegmentationItem.SaveToFile(const FileName: string);
begin
  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Mask, FileName)
  except
    raise;
  end;
end;

{ TObjectDetectionParam }

function TObjectDetectionParam.Inputs(
  const FileName: string): TObjectDetectionParam;
begin
  Result := TObjectDetectionParam(Add('inputs', EncodeBase64(FileName)));
end;

function TObjectDetectionParam.Parameters(
  const Threshold: Double): TObjectDetectionParam;
begin
  Result := TObjectDetectionParam(Add('parameters', TJSONObject.Create.AddPair('threshold', Threshold)));
end;

{ TObjectDetectionItem }

destructor TObjectDetectionItem.Destroy;
begin
  if Assigned(FBox) then
    FBox.Free;
  inherited;
end;

function TObjectDetectionItem.ToRect: TRect;
begin
  Result := Rect(Box.FXmin, Box.FYmin, Box.Xmax, Box.Ymax);
end;

{ TObjectDetection }

destructor TObjectDetection.Destroy;
begin
  for var Item in FItems do
    Item.Free;
  inherited;
end;

{ TImageToImageParam }

function TImageToImageParam.Inputs(const FileName: string): TImageToImageParam;
begin
  Result := TImageToImageParam(Add('inputs', EncodeBase64(FileName)));
end;

function TImageToImageParam.Parameters(
  ParamProc: TProcRef<TImageToImageParameters>): TImageToImageParam;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TImageToImageParameters.Create;
      ParamProc(Value);
      Result := TImageToImageParam(Add('parameters', Value.Detach));
    end
  else Result := Self;
end;

{ TImageToImage }

function TImageToImage.GetStream: TStream;
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

procedure TImageToImage.SaveToFile(const FileName: string);
begin
  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Image, FileName)
  except
    raise;
  end;
end;

{ TImageToImageParameters }

function TImageToImageParameters.GuidanceScale(
  const Value: Double): TImageToImageParameters;
begin
  Result := TImageToImageParameters(Add('guidance_scale', Value));
end;

function TImageToImageParameters.NegativePrompt(
  const Value: TArray<string>): TImageToImageParameters;
begin
  Result := TImageToImageParameters(Add('negative_prompt', Value));
end;

function TImageToImageParameters.NumInferenceSteps(
  const Value: Integer): TImageToImageParameters;
begin
  Result := TImageToImageParameters(Add('num_inference_steps', Value));
end;

function TImageToImageParameters.TargetSize(const Width,
  Height: Integer): TImageToImageParameters;
begin
  var Value := TTargetSizeParam.Create.Width(Width).Height(Height);
  Result := TImageToImageParameters(Add('target_size', Value.Detach));
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

end.
