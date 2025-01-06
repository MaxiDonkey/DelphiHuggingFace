unit HuggingFace.NetEncoding.Base64;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.NetEncoding, System.Net.Mime, System.IOUtils;

  /// <summary>
  /// Decodes a Base64-encoded string and writes the resulting binary data to a specified file.
  /// </summary>
  /// <param name="Base64Str">The Base64-encoded string to decode.</param>
  /// <param name="FileName">The full path and name of the file where the decoded data will be written.</param>
  /// <exception cref="Exception">
  /// Thrown if the Base64 string cannot be decoded or if there is an error writing to the specified file.
  /// </exception>
  procedure DecodeBase64ToFile(const Base64Str: string; const FileName: string);
  /// <summary>
  /// Saves a byte array to a specified file.
  /// </summary>
  /// <param name="Data">The byte array to be written to the file.</param>
  /// <param name="FileName">The full path and name of the file where the data will be saved.</param>
  /// <exception cref="Exception">
  /// Thrown if the <paramref name="Data"/> array is empty, if the existing file cannot be deleted,
  /// or if there is an error writing to the specified file.
  /// </exception>
  /// <remarks>
  /// This procedure writes the provided byte array to the specified file.
  /// If the file already exists, it will be deleted before writing the new data.
  /// Ensure that the application has the necessary permissions to write to the specified location.
  /// Use this method when you need to persist binary data, such as saving decoded files or handling raw file content.
  /// </remarks>
  procedure SaveBytesToFile(const Data: TBytes; const FileName: string);
  /// <summary>
  /// Decodes a Base64-encoded string and writes the resulting binary data to the provided stream.
  /// </summary>
  /// <param name="Base64Str">The Base64-encoded string to decode.</param>
  /// <param name="Stream">The stream where the decoded binary data will be written. The stream should be writable.</param>
  /// <exception cref="Exception">
  /// Thrown if the Base64 string cannot be decoded or if there is an error writing to the provided stream.
  /// </exception>
  /// <remarks>
  /// After decoding, the stream's position is reset to the beginning.
  /// Ensure that the stream is properly managed and freed after use to avoid memory leaks.
  /// </remarks>
  procedure DecodeBase64ToStream(const Base64Str: string; const Stream: TStream);
  /// <summary>
  /// Encodes the content of a file into a Base64-encoded string.
  /// </summary>
  /// <param name="FileLocation">The full path to the file that will be encoded.</param>
  /// <returns>A Base64-encoded string representing the content of the file.</returns>
  /// <exception cref="Exception">Thrown if the specified file does not exist at the provided location.</exception>
  /// <remarks>
  /// This method reads the file from the specified location and converts it to a Base64 string.
  /// It uses different encoding methods depending on the version of the RTL.
  /// For RTL version 35.0 and later, it uses <c>TNetEncoding.Base64String.Encode</c>,
  /// and for earlier versions, it uses <c>TNetEncoding.Base64.Encode</c>.
  /// </remarks>
  function EncodeBase64(FileLocation : string): WideString; overload;
  /// <summary>
  /// Reads the contents of a file and returns them as a byte array.
  /// </summary>
  /// <param name="FilePath">The full path to the file to be read.</param>
  /// <returns>
  /// A <c>TBytes</c> array containing the binary data from the specified file.
  /// </returns>
  /// <exception cref="Exception">
  /// Thrown if the file does not exist at the specified <paramref name="FilePath"/> or if there is an error accessing the file.
  /// </exception>
  /// <remarks>
  /// This function opens the file located at <paramref name="FilePath"/> in read-only mode and reads its entire content into a byte array.
  /// Ensure that the file path is valid and that the application has the necessary permissions to access the file.
  /// Use this function when you need to manipulate or transmit the raw binary data of a file.
  /// </remarks>
  function FileToBytes(const FilePath: string): TBytes;
  /// <summary>
  /// Reads the entire content of the provided stream and returns it as a byte array.
  /// </summary>
  /// <param name="Stream">
  /// The input <c>TStream</c> from which to read the data. The stream must be readable and properly initialized.
  /// </param>
  /// <returns>
  /// A <c>TBytes</c> array containing the binary data read from the stream.
  /// </returns>
  /// <exception cref="Exception">
  /// Thrown if there is an error reading from the stream, such as insufficient permissions or an unexpected end of stream.
  /// </exception>
  /// <remarks>
  /// This function reads all bytes from the specified <paramref name="Stream"/> and returns them as a <c>TBytes</c> array.
  /// After reading, the stream's position is reset to the beginning to allow for subsequent read operations.
  /// Ensure that the stream is properly managed and disposed of after use to prevent memory leaks or resource locking.
  /// Use this method when you need to convert stream data into a byte array for further processing or storage.
  /// </remarks>
  function StreamToBytes(const Stream: TStream): TBytes;
  /// <summary>
  /// Retrieves the MIME type of the specified file based on its location.
  /// </summary>
  /// <param name="FileLocation">The full path to the file whose MIME type is to be resolved.</param>
  /// <returns>
  /// A string representing the MIME type of the file.
  /// If the file does not exist, an exception will be raised.
  /// </returns>
  /// <exception cref="Exception">
  /// Thrown if the specified file cannot be found at the provided location.
  /// </exception>
  /// <remarks>
  /// This method checks if the specified file exists and retrieves its MIME type
  /// using the <c>TMimeTypes.Default.GetFileInfo</c> method.
  /// Ensure the provided path is valid before calling this function.
  /// </remarks>
  function ResolveMimeType(const FileLocation: string): string;
  /// <summary>
  /// Retrieves the size of the specified file in bytes.
  /// </summary>
  /// <param name="FileLocation">
  /// The full path to the file whose size is to be determined.
  /// </param>
  /// <returns>
  /// An <c>Int64</c> value representing the file size in bytes.
  /// </returns>
  /// <exception cref="Exception">
  /// Raised if the specified file cannot be accessed or does not exist at the provided location.
  /// </exception>
  /// <remarks>
  /// This function verifies the existence of the specified file and, if accessible, retrieves its size
  /// using the <c>TFile.GetSize</c> method. Ensure that the file path is valid and accessible
  /// before calling this function.
  /// </remarks>
  function FileSize(const FileLocation: string): Int64;
  /// <summary>
  /// Provides the image data as a Base64-encoded string with a MIME type or as a direct URL.
  /// </summary>
  /// <param name="FileLocation">
  /// The full path to the image file on the local filesystem or a URL.
  /// </param>
  /// <returns>
  /// A string representing the image data:
  /// <para>
  /// - If <paramref name="FileLocation"/> is a local file path, it returns a data URI with a MIME type and Base64-encoded content.
  /// </para>
  /// <para>
  /// - If <paramref name="FileLocation"/> is a URL (starting with "http"), it returns the URL as-is.
  /// </para>
  /// </returns>
  /// <exception cref="Exception">
  /// Raised if the file does not exist at the provided local file path.
  /// </exception>
  /// <remarks>
  /// This function checks if <paramref name="FileLocation"/> is a URL by verifying if it starts with "http".
  /// If it is a URL, it returns it directly as the output.
  /// For local files, it verifies the file's existence, retrieves the MIME type, and encodes the content in Base64 format
  /// to create a data URI for embedding purposes. This data URI can then be used directly in HTML or other contexts where
  /// embedded image data is required.
  /// </remarks>
  function ImageDataProvider(FileLocation : string) : WideString;

  function BytesToBase64(const Value: TBytes): WideString;

  function BytesToString(const Value: TBytes): WideString;

  function EncodeBase64(const Value: TStream): string; overload;

implementation

procedure SaveBytesToFile(const Data: TBytes; const FileName: string);
begin
  if Length(Data) = 0 then
    raise Exception.Create('Empty GLB data.');
  if FileExists(FileName) then
    begin
      DeleteFile(FileName);
      Sleep(300);
    end;
  var MemStream := TMemoryStream.Create;
  try
    MemStream.WriteBuffer(Data[0], Length(Data));
    MemStream.Position := 0;
    MemStream.SaveToFile(FileName);
  finally
    MemStream.Free;
  end;
end;

procedure DecodeBase64ToFile(const Base64Str: string; const FileName: string);
begin
  {--- Convert Base64 string to byte array for input stream }
  var Bytes := TEncoding.UTF8.GetBytes(Base64Str);

  {--- Create the flows }
  var InputStream := TBytesStream.Create(Bytes);
  var OutputStream := TFileStream.Create(FileName, fmCreate);
  try
    {--- Decode using TNetEncoding.Base64.Decode (stream) }
    TNetEncoding.Base64.Decode(InputStream, OutputStream);
  finally
    InputStream.Free;
    OutputStream.Free;
  end;
end;

procedure DecodeBase64ToStream(const Base64Str: string; const Stream: TStream);
begin
  {--- Converts the base64 string directly into the memory stream }
  var InputStream := TBytesStream.Create(TEncoding.UTF8.GetBytes(Base64Str));
    try
      TNetEncoding.Base64.Decode(InputStream, Stream);
      Stream.Position := 0;
    finally
      InputStream.Free;
    end;
end;

function EncodeBase64(FileLocation : string): WideString;
begin
  if not FileExists(FileLocation) then
    raise Exception.CreateFmt('File not found : %s', [FileLocation]);

  var Stream := TMemoryStream.Create;
  var StreamOutput := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromFile(FileLocation);
    Stream.Position := 0;
    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, StreamOutput);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, StreamOutput);
    {$ENDIF}
    Result := StreamOutput.DataString;
  finally
    Stream.Free;
    StreamOutput.Free;
  end;
end;

function FileToBytes(const FilePath: string): TBytes;
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File not found : %s', [FilePath]);

  var InputFile := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
  try
    Result := StreamToBytes(InputFile);
  finally
    InputFile.Free;
  end;
end;

function StreamToBytes(const Stream: TStream): TBytes;
begin
  SetLength(Result, Stream.Size);
  Stream.ReadBuffer(Result[0], Stream.Size);
  Stream.Position := 0;
end;

function ResolveMimeType(const FileLocation: string): string;
begin
  if not FileExists(FileLocation) then
    raise Exception.CreateFmt('File not found: %s', [FileLocation]);

  var LKind: TMimeTypes.TKind;
  TMimeTypes.Default.GetFileInfo(FileLocation, Result, LKind);
end;

function FileSize(const FileLocation: string): Int64;
begin
  try
    FileSize := TFile.GetSize(FileLocation);
  except
    raise;
  end;
end;

function ImageDataProvider(FileLocation : string) : WideString;
begin
  if FileLocation.ToLower.StartsWith('http') then
    Result := FileLocation
  else
  if FileExists(FileLocation) then
    Result := Format('data:%s;base64,%s', [ResolveMimeType(FileLocation), EncodeBase64(FileLocation)])
  else
    raise Exception.CreateFmt('File not found : %s', [FileLocation]);
end;

function BytesToBase64(const Value: TBytes): WideString;
begin
  if Length(Value) = 0 then
    raise Exception.Create('No data recieved.');
  var MemStream := TMemoryStream.Create;
  try
    MemStream.WriteBuffer(Value[0], Length(Value));
    MemStream.Position := 0;
    Result := EncodeBase64(MemStream);
  finally
    MemStream.Free;
  end;
end;

function BytesToString(const Value: TBytes): WideString;
begin
  if Length(Value) = 0 then
    raise Exception.Create('No data recieved.');
  var MemStream := TMemoryStream.Create;
  try
    MemStream.WriteBuffer(Value[0], Length(Value));
    MemStream.Position := 0;
    var Reader := TStreamReader.Create(MemStream, TEncoding.UTF8);
    try
      Result := Reader.ReadToEnd;
    finally
      Reader.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

function EncodeBase64(const Value: TStream): string;
begin
  var Stream := TMemoryStream.Create;
  var StreamOutput := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromStream(Value);
    Stream.Position := 0;
    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, StreamOutput);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, StreamOutput);
    {$ENDIF}
    Result := StreamOutput.DataString;
  finally
    Stream.Free;
    StreamOutput.Free;
  end;
end;

end.
