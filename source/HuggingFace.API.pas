unit HuggingFace.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.Classes, System.Net.HttpClient, System.Net.URLClient, System.Net.Mime,
  System.JSON, HuggingFace.Errors, HuggingFace.API.Params, System.SysUtils;

type
  HuggingFaceException = class(Exception)
  private
    FCode: Int64;
    FId: string;
    FName: string;
    FError: string;
    FWarnings: TArray<string>;
    FEstimatedTime: Double;
  public
    constructor Create(const ACode: Int64; const AError: TErrorCore); reintroduce; overload;
    constructor Create(const ACode: Int64; const Value: string); reintroduce; overload;
    function ToMessageString: string;
    property Code: Int64 read FCode write FCode;
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Error: string read FError write FError;
    property Warnings: TArray<string> read FWarnings write FWarnings;
    property EstimatedTime: Double read FEstimatedTime write FEstimatedTime;
  end;

  HuggingFaceExceptionAPI = class(Exception);

  /// <summary>
  /// The server could not understand the request due to invalid syntax.
  /// Review the request format and ensure it is correct.
  /// </summary>
  HuggingFaceExceptionBadRequestError = class(HuggingFaceException);

  /// <summary>
  /// The request lacks the required 'Authorization' header, which is needed to authenticate access.
  /// </summary>
  HuggingFaceExceptionUnauthorizedError = class(HuggingFaceException);

  /// <summary>
  /// The specified engine (ID some-fake-engine) was not found.
  /// </summary>
  HuggingFaceExceptionNotFoundError = class(HuggingFaceException);

  /// <summary>
  /// The request was well-formed but could not be followed due to semantic errors.
  /// Verify the data provided for correctness and completeness.
  /// </summary>
  HuggingFaceExceptionInvalidLanguageError = class(HuggingFaceException);

  /// <summary>
  /// Too many requests were sent in a given timeframe. Implement request throttling and respect rate limits.
  /// </summary>
  HuggingFaceExceptionRateLimitExceededError = class(HuggingFaceException);

  /// <summary>
  /// The request was not successful because it lacks valid authentication credentials for the requested resource.
  /// Ensure the request includes the necessary authentication credentials and the api key is valid.
  /// </summary>
  HuggingFaceExceptionContentModerationError = class(HuggingFaceException);

  /// <summary>
  /// The requested resource could not be found. Check the request URL and the existence of the resource.
  /// </summary>
  HuggingFaceExceptionPayloadTooLargeError = class(HuggingFaceException);

  /// <summary>
  /// A generic error occurred on the server. Try the request again later or contact support if the issue persists.
  /// </summary>
  HuggingFaceExceptionInternalServerError = class(HuggingFaceException);

  HuggingFaceExceptionInvalidResponse = class(HuggingFaceException);

  THuggingFaceAPI = class
  public
    const
      URL_BASE = 'https://api-inference.huggingface.co';
  private
    FToken: string;
    FBaseUrl: string;
    FCustomHeaders: TNetHeaders;
    FUseCache: Boolean;
    FWaitForModel: Boolean;

    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetUseCache(const Value: Boolean);
    procedure RaiseError(Code: Int64; Error: TErrorCore);
    procedure ParseError(const Code: Int64; const ResponseText: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);
    procedure SetWaitForModel(const Value: Boolean);

  private
    function ToStringValueFor(const Value: string): string; overload;
    function ToStringValueFor(const Value: string; const Field: string): string; overload;
    function ToStringValueFor(const Value: string; const Field: TArray<string>): string; overload;

  protected
    function GetPath<TParams: TJSONParam>(const Path: string; const Value: TParams): string; //ParamProc: TProc<TParams>
    function GetHeaderValue(const KeyName: string; const Value: TNetHeaders): string;
    function GetHeaders: TNetHeaders; virtual;
    function GetClient: THTTPClient; virtual;
    function GetRequestURL(const Path: string): string;
    function Get(const Path: string; Response: TStringStream; var ResponseHeader: TNetHeaders): Integer; overload;
    function Get(const Path: string; Response: TStringStream): Integer; overload;
    function GetLink(const Link: string; Response: TStringStream; var ResponseHeader: TNetHeaders): Integer; overload;
    function Delete(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStringStream; var ResponseHeader: TNetHeaders): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T; overload;
    procedure CheckAPI;
    function ArrayToObject(const Response: string): string;
  public
    function GetArray<TResult: class, constructor>(const Path: string): TResult;
    function Get<TResult: class, constructor>(const Path: string): TResult; overload;
    function Get<TResult: class, constructor>(const Path: string; var Link: string): TResult; overload;
    function Get<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function GetLink<TResult: class, constructor>(var Link: string): TResult; overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback = nil): Boolean; overload;
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>; RawByteFieldName: string = ''): TResult; overload;
    function Post<TResult: class, constructor>(const Path: string): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>;
      var ResponseHeader: TNetHeaders): TResult; overload;
  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
    property UseCache: Boolean read FUseCache write SetUseCache;
    property WaitForModel: Boolean read FWaitForModel write SetWaitForModel;
  end;

  THuggingFaceAPIRoute = class
  private
    FAPI: THuggingFaceAPI;
    procedure SetAPI(const Value: THuggingFaceAPI);
  public
    property API: THuggingFaceAPI read FAPI write SetAPI;
    constructor CreateRoute(AAPI: THuggingFaceAPI); reintroduce;
  end;

implementation

uses
  System.StrUtils, REST.Json, System.NetConsts, HuggingFace.NetEncoding.Base64;

const
  FieldsToString : TArray<string> = ['"arguments":{'];

type
  THeaderUtils = class
    class function LinkExtract(const Value: string): string;
  end;

constructor THuggingFaceAPI.Create;
begin
  inherited;
  FToken := '';
  FBaseUrl := URL_BASE;
  FUseCache := True;
  FWaitForModel := False;
end;

constructor THuggingFaceAPI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor THuggingFaceAPI.Destroy;
begin
  inherited;
end;

function THuggingFaceAPI.Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Headers := GetHeaders + [TNetHeader.Create('Content-Type', 'application/json')];
    Stream := TStringStream.Create;
    Client.ReceiveDataCallBack := OnReceiveData;
    try
      Stream.WriteString(Body.ToJSON);
      Stream.Position := 0;
      Result := Client.Post(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
    finally
      Client.ReceiveDataCallBack := nil;
      Stream.Free;
    end;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.Get(const Path: string; Response: TStringStream; var ResponseHeader: TNetHeaders): Integer;
begin
  Result := GetLink(GetRequestURL(Path), Response, ResponseHeader);
end;

function THuggingFaceAPI.Get(const Path: string;
  Response: TStringStream): Integer;
var
  ResponseHeader: TNetHeaders;
begin
  Result := Get(Path, Response, ResponseHeader);
end;

function THuggingFaceAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStringStream;
  var ResponseHeader: TNetHeaders): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    var PostResult := Client.Post(GetRequestURL(Path), Body, Response, GetHeaders);
    ResponseHeader := PostResult.Headers;
    Result := PostResult.StatusCode;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.Post(const Path: string; Response: TStringStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Post(GetRequestURL(Path), TStream(nil), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>; RawByteFieldName: string): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(GetPath<TParams>(Path, Params), Params.JSON, Response);
    case Code of
      200..299:
        begin
          if RawByteFieldName.IsEmpty then
            Result := ParseResponse<TResult>(Code, ArrayToObject(ToStringValueFor(Response.DataString)))
          else
            Result := ParseResponse<TResult>(Code, Format('{"%s":"%s"}', [RawByteFieldName, BytesToBase64(Response.Bytes)]));
        end;
      else
        Result := ParseResponse<TResult>(Code, ArrayToObject(ToStringValueFor(Response.DataString)))
    end;

  finally
    Params.Free;
    Response.Free;
  end;
end;

function THuggingFaceAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
  Code: Integer;
begin
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(GetPath<TParams>(Path, Params), Params.JSON, Response, Event);
    case Code of
      200..299:
        Result := True;
    else
      Result := False;
    end;
  finally
    Params.Free;
  end;
end;

function THuggingFaceAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Post(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.Delete(const Path: string; Response: TStringStream): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Result := Client.Delete(GetRequestURL(Path), Response, GetHeaders).StatusCode;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.Delete<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Delete(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.PostForm<TResult, TParams>(const Path: string;
  ParamProc: TProc<TParams>; var ResponseHeader: TNetHeaders): TResult;
begin
  var Response := TStringStream.Create('', TEncoding.UTF8);
  var Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Code := Post(Path, Params, Response, ResponseHeader);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function THuggingFaceAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  ResponseHeader: TNetHeaders;
begin
  Result := PostForm<TResult, TParams>(Path, ParamProc, ResponseHeader);
end;

function THuggingFaceAPI.Get<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Pairs: TArray<string> := [];
    for var Pair in Params.ToStringPairs do
      Pairs := Pairs + [Pair.Key + '=' + Pair.Value];
    var QPath := Path;
    if Length(Pairs) > 0 then
      QPath := QPath + '?' + string.Join('&', Pairs);
    Code := Get(QPath, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

function THuggingFaceAPI.Get<TResult>(const Path: string;
  var Link: string): TResult;
var
  Code: Integer;
  Response: TStringStream;
  ResponseHeader: TNetHeaders;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response, ResponseHeader);
    Link := GetHeaderValue('link', ResponseHeader);
    Result := ParseResponse<TResult>(Code, ArrayToObject(Response.DataString));
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.Get<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response);

    with TStringList.Create do
    try
      Text := Response.DataString;
      SaveToFile('Response.JSON', TEncoding.UTF8);
    finally
      Free;
    end;

    Result := ParseResponse<TResult>(Code, ArrayToObject(Response.DataString));
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.GetArray<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Response);
    var Data := Response.DataString.Trim([#10]);
    if Data.StartsWith('[') then
      Data := Format('{"result":%s}', [Data]);
    Result := ParseResponse<TResult>(Code, Data);
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.GetClient: THTTPClient;
begin
  Result := THTTPClient.Create;
  Result.AcceptCharSet := 'utf-8';
end;

procedure THuggingFaceAPI.GetFile(const Path: string; Response: TStream);
var
  Code: Integer;
  Strings: TStringStream;
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    Code := Client.Get(GetRequestURL(Path), Response, GetHeaders).StatusCode;
    case Code of
      200..299:
        ; {success}
    else
      Strings := TStringStream.Create;
      try
        Response.Position := 0;
        Strings.LoadFromStream(Response);
        ParseError(Code, Strings.DataString);
      finally
        Strings.Free;
      end;
    end;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.GetHeaders: TNetHeaders;
begin
  Result :=
    [TNetHeader.Create('authorization', 'Bearer ' + FToken)] +
    [TNetHeader.Create('x-use-cache', BoolToStr(FUseCache, True))]+
    [TNetHeader.Create('x-wait-for-model', BoolToStr(FWaitForModel, True))]+
    FCustomHeaders;
end;

function THuggingFaceAPI.GetHeaderValue(const KeyName: string;
  const Value: TNetHeaders): string;
begin
  for var Item in Value do
    if Item.Name.ToLower = KeyName.ToLower then
      begin
        Result := Item.Value;
        case IndexStr(KeyName.ToLower, ['link']) of
          0: Result := THeaderUtils.LinkExtract(Result);
        end;
        Break;
      end;
end;

function THuggingFaceAPI.GetLink(const Link: string; Response: TStringStream;
  var ResponseHeader: TNetHeaders): Integer;
var
  Client: THTTPClient;
begin
  CheckAPI;
  Client := GetClient;
  try
    var Data := Client.Get(Link, Response, GetHeaders);
    ResponseHeader := Data.Headers;
    Result := Data.StatusCode;
  finally
    Client.Free;
  end;
end;

function THuggingFaceAPI.GetLink<TResult>(var Link: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
  ResponseHeader: TNetHeaders;
begin
  CustomHeaders := [TNetHeader.Create('accept', 'application/json')];
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := GetLink(Link, Response, ResponseHeader);
    Link := GetHeaderValue('link', ResponseHeader);
    Result := ParseResponse<TResult>(Code, ArrayToObject(Response.DataString));
  finally
    Response.Free;
  end;
end;

function THuggingFaceAPI.GetPath<TParams>(const Path: string;
  const Value: TParams): string;
begin
  var M := TJSON.JsonToObject<TModel>(Value.JSON);
  try
    if M.Model.IsEmpty then
      Exit(Path);

    if TParams.InheritsFrom(TJSONChatParam) then
      Exit(Format('%s/%s/v1/chat/completions', [Path, M.Model]));

    if TParams.InheritsFrom(TJSONModelParam) then
      Exit(Format('%s/%s', [Path, M.Model]));

    Result := Path;
  finally
    M.Free;
  end;
end;

function THuggingFaceAPI.GetRequestURL(const Path: string): string;
begin
  Result := Format('%s/%s', [FBaseURL, Path]);
end;

function THuggingFaceAPI.ArrayToObject(const Response: string): string;
begin
  Result := Response.Replace(#10, '');
//  if Result.StartsWith('[[[') then
//    begin
//      Result := Result.Substring(2, Result.Length - 2);
//      with TStringList.Create do
//      try
//        Text := Result;
//        SaveToFile('Debug.txt', TEncoding.UTF8);
//      finally
//        Free;
//      end;
//    end;
  if Result.StartsWith('[') then
    begin
      Result := ArrayToObject(Result.Substring(1, Result.Length - 2));
      Result := Format('{"items":[%s]}', [Result])
    end
  else
    begin
      Result := Response;
    end;
end;

procedure THuggingFaceAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise HuggingFaceExceptionAPI.Create('Token is empty!');
  if FBaseUrl.IsEmpty then
    raise HuggingFaceExceptionAPI.Create('Base url is empty!');
end;

procedure THuggingFaceAPI.RaiseError(Code: Int64; Error: TErrorCore);
begin
  case Code of
    {--- Client Error Codes }
    400:
      raise HuggingFaceExceptionBadRequestError.Create(Code, Error);
    401:
      raise HuggingFaceExceptionUnauthorizedError.Create(Code, Error);
    403:
      raise HuggingFaceExceptionContentModerationError.Create(Code, Error);
    404:
      raise HuggingFaceExceptionNotFoundError.Create(Code, Error);
    413:
      raise HuggingFaceExceptionPayloadTooLargeError.Create(Code, Error);
    422:
      raise HuggingFaceExceptionInvalidLanguageError.Create(Code, Error);
    429:
      raise HuggingFaceExceptionRateLimitExceededError.Create(Code, Error);
    {--- Server Error Codes }
    500:
      raise HuggingFaceExceptionInternalServerError.Create(Code, Error);
  else
    raise HuggingFaceException.Create(Code, Error);
  end;
end;

procedure THuggingFaceAPI.ParseError(const Code: Int64; const ResponseText: string);
var
  Error: TErrorCore;
begin
  Error := nil;
  try
    try
      Error := TJson.JsonToObject<TError>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) and Assigned(Error) then
      RaiseError(Code, Error)
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

function THuggingFaceAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := TJson.JsonToObject<T>(ResponseText)
      except
        FreeAndNil(Result);
      end;
  else
    ParseError(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise HuggingFaceExceptionInvalidResponse.Create(Code, 'Empty or invalid response');
end;

procedure THuggingFaceAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure THuggingFaceAPI.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure THuggingFaceAPI.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure THuggingFaceAPI.SetUseCache(const Value: Boolean);
begin
  FUseCache := Value;
end;

procedure THuggingFaceAPI.SetWaitForModel(const Value: Boolean);
begin
  FWaitForModel := Value;
end;

function THuggingFaceAPI.ToStringValueFor(const Value: string): string;
begin
  Result := ToStringValueFor(Value, FieldsToString);
end;

function THuggingFaceAPI.ToStringValueFor(const Value, Field: string): string;
begin
  Result := Value;
  var i := Pos(Field, Result);
  while (i > 0) and (i < Result.Length) do
    begin
      i := i + Field.Length - 1;
      Result[i] := '"';
      Inc(i);
      var j := 0;
      while (j > 0) or ((j = 0) and not (Result[i] = '}')) do
        begin
          case Result[i] of
            '{':
              Inc(j);
            '}':
              j := j - 1;
            '"':
              Result[i] := '`';
          end;
          Inc(i);
          if i > Result.Length then
            raise Exception.Create('Invalid JSON string');
        end;
      Result[i] := '"';
      i := Pos(Field, Result);
    end;
end;

function THuggingFaceAPI.ToStringValueFor(const Value: string;
  const Field: TArray<string>): string;
begin
  Result := Value;
  if Length(Field) > 0 then
    begin
      for var Item in Field do
        Result := ToStringValueFor(Result, Item);
    end;
end;

{ THuggingFaceAPIRoute }

constructor THuggingFaceAPIRoute.CreateRoute(AAPI: THuggingFaceAPI);
begin
  inherited Create;
  FAPI := AAPI;
end;

procedure THuggingFaceAPIRoute.SetAPI(const Value: THuggingFaceAPI);
begin
  FAPI := Value;
end;

{ HuggingFaceException }

constructor HuggingFaceException.Create(const ACode: Int64; const Value: string);
begin
  Code := ACode;
  inherited Create(Format('error %d: %s', [ACode, Value]));
end;

function HuggingFaceException.ToMessageString: string;
begin
  if Error.IsEmpty then
    Error := string.join(#10, Warnings)
  else
    Error := Error + #10 + string.join(#10, Warnings);
  Result := Format('error (%d)', [Code]);
  if not Name.IsEmpty then
    Result := Format('%s - type %s', [Result, Name]);
  Result := Format('%s' + sLineBreak + '%s', [Result, Error]);
  if EstimatedTime > 0 then
    Result := Format('%s Estimated time : %s', [Result, EstimatedTime.ToString(ffNumber, 2, 2)]);
end;

constructor HuggingFaceException.Create(const ACode: Int64; const AError: TErrorCore);
begin
  Code := ACode;
  Id := (AError as TError).Id;
  Name := (AError as TError).Name;
  Error := (AError as TError).Error;
  Warnings := (AError as TError).Warnings;
  EstimatedTime := (AError as TError).EstimatedTime;
  inherited Create(ToMessageString);
end;

{ THeaderUtils }

class function THeaderUtils.LinkExtract(const Value: string): string;
begin
  Result := Value.Substring(1, Value.IndexOf('>') - 1);
end;

end.

