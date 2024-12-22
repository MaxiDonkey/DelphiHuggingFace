unit HuggingFace;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.URLClient, HuggingFace.API,
  HuggingFace.Hub.Search, HuggingFace.Audio, HuggingFace.Chat, HuggingFace.Embeddings,
  HuggingFace.Mask, HuggingFace.Image, HuggingFace.Text;

type
  /// <summary>
  /// The <c>IHuggingFace</c> interface provides access to the various features and routes of the HuggingFace AI API.
  /// It serves as a comprehensive framework for automating natural language processing, vision tasks, and data retrieval workflows.
  /// </summary>
  /// <remarks>
  /// This interface should be implemented by any class that wants to provide a structured way of accessing
  /// the HuggingFace AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// </remarks>
  IHuggingFace = interface
    ['{FC8BCBFB-B1AC-45D0-AEF1-43AE35CD9D0A}']
    function GetAPI: THuggingFaceAPI;
    procedure SetToken(const Value: string);
    function GetToken: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetUseCache: Boolean;
    procedure SetUseCache(const Value: Boolean);
    function GetWaitForModel: Boolean;
    procedure SetWaitForModel(const Value: Boolean);

    function GetHubRoute: THubRoute;
    function GetAudioRoute: TAudioRoute;
    function GetChatRoute: TChatRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetMaskRoute: TMaskRoute;
    function GetImageRoute: TImageRoute;
    function GetTextRoute: TTextRoute;

    /// <summary>
    /// The cache layer on the inference API to speed up requests. Most models can use those
    /// results as they are deterministic (meaning the outputs will be the same anyway).
    /// </summary>
    /// <remarks>
    /// If you use a nondeterministic model, you can set this parameter to prevent
    /// the caching mechanism from being used, resulting in a real new query.
    /// </remarks>
    property UseCache: Boolean read GetUseCache write SetUseCache;
    /// <summary>
    /// If the model is not ready, wait for it instead of receiving 503. It limits the number
    /// of requests required to get your inference done.
    /// </summary>
    /// <remarks>
    /// It is advised to only set this flag
    /// to true after receiving a 503 error, as it will limit hanging in your application to
    /// known places.
    /// </remarks>
    property WaitForModel: Boolean read GetWaitForModel write SetWaitForModel;
    /// <summary>
    /// This class provides tools for analyzing and transcribing audio data with applications
    /// in classification and speech recognition.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// This class offers functionality for generating contextually appropriate responses within
    /// conversational frameworks, supporting multimodal capabilities integrate language and visual
    /// understanding.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// It focuses on converting text into numerical representations to support data modeling and analysis.
    /// </summary>
    property Embeddings:TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Bringing together advanced features to classify images, detect objects, segment pixels, and work
    /// with vision-language models.
    /// </summary>
    property Image: TImageRoute read GetImageRoute;
    /// <summary>
    /// It provides tools to complete sentences by identifying missing words.
    /// </summary>
    property Mask: TMaskRoute read GetMaskRoute;
    /// <summary>
    /// This class provides advanced tools for processing, analyzing, and generating text,
    /// images, and structured data.
    /// </summary>
    property Text: TTextRoute read GetTextRoute;
    /// <summary>
    /// This class provides API access to manage the hub, including retrieving and filtering model lists
    /// and accessing detailed model information.
    /// </summary>
    /// <remarks>
    /// Can only be used with an instance that has initialized the hub.
    /// <para>
    /// e.g TheHub := THuggingFaceFactory.CreateInstance('my_key', True);
    /// </para>
    /// </remarks>
    property Hub: THubRoute read GetHubRoute;
    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of THuggingFaceAPI for making API calls.
    /// </returns>
    property API: THuggingFaceAPI read GetAPI;
    /// <summary>
    /// Sets or retrieves the API token for authentication.
    /// </summary>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Sets or retrieves the base URL for API requests.
    /// Default is https://api.HuggingFace.com/v1
    /// </summary>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;
  end;

  /// <summary>
  /// The <c>THuggingFaceFactory</c> class is responsible for creating instances of
  /// the <see cref="IHuggingFace"/> interface. It provides a factory method to instantiate
  /// the interface with a provided API token and optional header configuration.
  /// </summary>
  /// <remarks>
  /// This class provides a convenient way to initialize the <see cref="IHuggingFace"/> interface
  /// by encapsulating the necessary configuration details, such as the API token and header options.
  /// By using the factory method, users can quickly create instances of <see cref="IHuggingFace"/> without
  /// manually setting up the implementation details.
  /// </remarks>
  THuggingFaceFactory = class
    /// <summary>
    /// Creates an instance of the <see cref="IHuggingFace"/> interface with the specified API token
    /// and optional header configuration.
    /// </summary>
    /// <param name="AToken">
    /// The API token as a string, required for authenticating with HuggingFace API services.
    /// </param>
    /// <param name="Option">
    /// An optional header configuration of type <see cref="THeaderOption"/> to customize the request headers.
    /// The default value is <c>THeaderOption.none</c>.
    /// </param>
    /// <returns>
    /// An instance of <see cref="IHuggingFace"/> initialized with the provided API token and header option.
    /// </returns>
    /// <remarks>
    /// Code example
    /// <code>
    /// var HuggingFace := THuggingFaceFactory.CreateInstance(BaererKey);
    /// </code>
    /// WARNING : Please take care to adjust the SCOPE of the <c>HuggingFaceCloud</c> interface in you application.
    /// </remarks>
    class function CreateInstance(const AToken: string; const IsHub: Boolean = False): IHuggingFace;
  end;

  /// <summary>
  /// The THuggingFace class provides access to the various features and routes of the HuggingFace AI API.
  /// It serves as a comprehensive framework for automating natural language processing, vision tasks, and data retrieval workflows.
  /// </summary>
  /// <remarks>
  /// This class should be implemented by any class that wants to provide a structured way of accessing
  /// the HuggingFace AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// <seealso cref="THuggingFace"/>
  /// </remarks>
  THuggingFace = class(TInterfacedObject, IHuggingFace)
  strict private

  private
    FAPI: THuggingFaceAPI;
    FAudioRoute: TAudioRoute;
    FHubRoute: THubRoute;
    FChatRoute: TChatRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FMaskRoute: TMaskRoute;
    FImageRoute: TImageRoute;
    FTextRoute: TTextRoute;

    function GetAPI: THuggingFaceAPI;
    function GetToken: string;
    procedure SetToken(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetUseCache: Boolean;
    procedure SetUseCache(const Value: Boolean);
    function GetWaitForModel: Boolean;
    procedure SetWaitForModel(const Value: Boolean);

    function GetHubRoute: THubRoute;
    function GetAudioRoute: TAudioRoute;
    function GetChatRoute: TChatRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetMaskRoute: TMaskRoute;
    function GetImageRoute: TImageRoute;
    function GetTextRoute: TTextRoute;

  public
    /// <summary>
    /// The cache layer on the inference API to speed up requests. Most models can use those
    /// results as they are deterministic (meaning the outputs will be the same anyway).
    /// </summary>
    /// <remarks>
    /// If you use a nondeterministic model, you can set this parameter to prevent
    /// the caching mechanism from being used, resulting in a real new query.
    /// </remarks>
    property UseCache: Boolean read GetUseCache write SetUseCache;
    /// <summary>
    /// If the model is not ready, wait for it instead of receiving 503. It limits the number
    /// of requests required to get your inference done.
    /// </summary>
    /// <remarks>
    /// It is advised to only set this flag
    /// to true after receiving a 503 error, as it will limit hanging in your application to
    /// known places.
    /// </remarks>
    property WaitForModel: Boolean read GetWaitForModel write SetWaitForModel;
    /// <summary>
    /// This class provides tools for analyzing and transcribing audio data with applications
    /// in classification and speech recognition.
    /// </summary>
    property Audio: TAudioRoute read GetAudioRoute;
    /// <summary>
    /// This class offers functionality for generating contextually appropriate responses within
    /// conversational frameworks, supporting multimodal capabilities integrate language and visual
    /// understanding.
    /// </summary>
    property Chat: TChatRoute read GetChatRoute;
    /// <summary>
    /// It focuses on converting text into numerical representations to support data modeling and analysis.
    /// </summary>
    property Embeddings:TEmbeddingsRoute read GetEmbeddingsRoute;
    /// <summary>
    /// Bringing together advanced features to classify images, detect objects, segment pixels, and work
    /// with vision-language models.
    /// </summary>
    property Image: TImageRoute read GetImageRoute;
    /// <summary>
    /// It provides tools to complete sentences by identifying missing words.
    /// </summary>
    property Mask: TMaskRoute read GetMaskRoute;
    /// <summary>
    /// This class provides advanced tools for processing, analyzing, and generating text,
    /// images, and structured data.
    /// </summary>
    property Text: TTextRoute read GetTextRoute;
    /// <summary>
    /// This class provides API access to manage the hub, including retrieving and filtering model lists
    /// and accessing detailed model information.
    /// </summary>
    /// <remarks>
    /// Can only be used with an instance that has initialized the hub.
    /// <para>
    /// e.g TheHub := THuggingFaceFactory.CreateInstance('my_key', True);
    /// </para>
    /// </remarks>
    property Hub: THubRoute read GetHubRoute;
    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of THuggingFaceAPI for making API calls.
    /// </returns>
    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of THuggingFaceAPI for making API calls.
    /// </returns>
    property API: THuggingFaceAPI read GetAPI;
    /// <summary>
    /// Sets or retrieves the API token for authentication.
    /// </summary>
    /// <param name="Value">
    /// The API token as a string.
    /// </param>
    /// <returns>
    /// The current API token.
    /// </returns>
    property Token: string read GetToken write SetToken;
    /// <summary>
    /// Sets or retrieves the base URL for API requests.
    /// Default is https://api.stability.ai
    /// </summary>
    /// <param name="Value">
    /// The base URL as a string.
    /// </param>
    /// <returns>
    /// The current base URL.
    /// </returns>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;

  public
    /// <summary>
    /// Initializes a new instance of the <see cref="THuggingFace"/> class with optional header configuration.
    /// </summary>
    /// <param name="Option">
    /// An optional parameter of type <see cref="THeaderOption"/> to configure the request headers.
    /// The default value is <c>THeaderOption.none</c>.
    /// </param>
    /// <remarks>
    /// This constructor is typically used when no API token is provided initially.
    /// The token can be set later via the <see cref="Token"/> property.
    /// </remarks>
    constructor Create; overload;
    /// <summary>
    /// Initializes a new instance of the <see cref="THuggingFace"/> class with the provided API token and optional header configuration.
    /// </summary>
    /// <param name="AToken">
    /// The API token as a string, required for authenticating with the HuggingFace AI API.
    /// </param>
    /// <param name="Option">
    /// An optional parameter of type <see cref="THeaderOption"/> to configure the request headers.
    /// The default value is <c>THeaderOption.none</c>.
    /// </param>
    /// <remarks>
    /// This constructor allows the user to specify an API token at the time of initialization.
    /// </remarks>
    constructor Create(const AToken: string); overload;
    /// <summary>
    /// Releases all resources used by the current instance of the <see cref="THuggingFace"/> class.
    /// </summary>
    /// <remarks>
    /// This method is called to clean up any resources before the object is destroyed.
    /// It overrides the base <see cref="TInterfacedObject.Destroy"/> method.
    /// </remarks>
    destructor Destroy; override;
  end;

implementation

{ THuggingFace }

constructor THuggingFace.Create;
begin
  inherited Create;
  FAPI := THuggingFaceAPI.Create;
end;

constructor THuggingFace.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor THuggingFace.Destroy;
begin
  FAPI.Free;
  FHubRoute.Free;
  FAudioRoute.Free;
  FChatRoute.Free;
  FEmbeddingsRoute.Free;
  FMaskRoute.Free;
  FImageRoute.Free;
  FTextRoute.Free;
  inherited;
end;

function THuggingFace.GetAPI: THuggingFaceAPI;
begin
  Result := FAPI;
end;

function THuggingFace.GetAudioRoute: TAudioRoute;
begin
  if not Assigned(FAudioRoute) then
    FAudioRoute := TAUdioRoute.CreateRoute(API);
  Result := FAudioRoute;
end;

function THuggingFace.GetBaseUrl: string;
begin
  Result := FAPI.BaseURL;
end;

function THuggingFace.GetChatRoute: TChatRoute;
begin
  if not Assigned(FChatRoute) then
    FChatRoute := TChatRoute.CreateRoute(API);
  Result := FChatRoute;
end;

function THuggingFace.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  if not Assigned(FEmbeddingsRoute) then
    FEmbeddingsRoute := TEmbeddingsRoute.CreateRoute(API);
  Result := FEmbeddingsRoute;
end;

function THuggingFace.GetHubRoute: THubRoute;
begin
  if not Assigned(FHubRoute) then
    FHubRoute := THubRoute.CreateRoute(API);
  Result := FHubRoute;
end;

function THuggingFace.GetImageRoute: TImageRoute;
begin
  if not Assigned(FImageRoute) then
    FImageRoute := TImageRoute.CreateRoute(API);
  Result := FImageRoute;
end;

function THuggingFace.GetMaskRoute: TMaskRoute;
begin
  if not Assigned(FMaskRoute) then
    FMaskRoute := TMaskRoute.CreateRoute(API);
  Result := FMaskRoute;
end;

function THuggingFace.GetTextRoute: TTextRoute;
begin
  if not Assigned(FTextRoute) then
    FTextRoute := TTextRoute.CreateRoute(API);
  Result := FTextRoute;
end;

function THuggingFace.GetToken: string;
begin
  Result := FAPI.Token;
end;

function THuggingFace.GetUseCache: Boolean;
begin
  Result := API.UseCache;
end;

function THuggingFace.GetWaitForModel: Boolean;
begin
  Result := API.WaitForModel;
end;

procedure THuggingFace.SetBaseUrl(const Value: string);
begin
  FAPI.BaseURL := Value;
end;

procedure THuggingFace.SetToken(const Value: string);
begin
  FAPI.Token := Value;
end;

procedure THuggingFace.SetUseCache(const Value: Boolean);
begin
  API.UseCache := Value;
end;

procedure THuggingFace.SetWaitForModel(const Value: Boolean);
begin
  API.WaitForModel := Value;
end;

{ THuggingFaceFactory }

class function THuggingFaceFactory.CreateInstance(const AToken: string; const IsHub: Boolean): IHuggingFace;
begin
  Result := THuggingFace.Create(AToken);
  if IsHub then
    Result.API.BaseUrl := 'https://huggingface.co';
end;

end.
