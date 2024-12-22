unit Vcl.HuggingFace.Tutorial;

interface

uses
  System.SysUtils, System.Classes, Winapi.Messages, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Controls, Vcl.Forms, Winapi.Windows, Vcl.Graphics, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Vcl.Dialogs, Vcl.MPlayer,
  HuggingFace.Types, HuggingFace.Aggregator;

type
  TToolFunc = procedure (Sender: TObject; Text: string) of object;

  TVCLHuggingFaceSender = class
  private
    FMemo1: TMemo;
    FImage1: TImage;
    FImage2: TImage;
    FUrlNext: string;
    FMediaPlayer: TMediaPlayer;
    FFunc: IFunctionCore;
    FFuncProc: TToolFunc;
    TempGraphic: TGraphic;
    FFileName: string;
    FStartMessage: string;
    FEndMessage: string;
    procedure SetFileName(const Value: string);
  public
    procedure LoadImageFromFile(const FilePath: TFileName);
    procedure Play;
    property Memo1: TMemo read FMemo1 write FMemo1;
    property Image1: TImage read FImage1 write FImage1;
    property Image2: TImage read FImage2 write FImage2;
    property UrlNext: string read FUrlNext write FUrlNext;
    property FuncProc: TToolFunc read FFuncProc write FFuncProc;
    property Func: IFunctionCore read FFunc write FFunc;
    property FileName: string read FFileName write SetFileName;
    property MediaPlayer: TMediaPlayer read FMediaPlayer write FMediaPlayer;
    property StartMessage: string read FStartMessage write FStartMessage;
    property EndMessage: string read FEndMessage write FEndMessage;
    constructor Create(const AMemo1: TMemo; const AImage1, AImage2: TImage; const AMediaPlayer: TMediaPlayer);
    destructor Destroy; override;
  end;

  TImageHelper = class helper for TImage
    procedure AssignGraphic(const Value: TGraphic);
    procedure DrawTransparentRectangle(Value: TRect; Color: TColor; Alpha: Byte);
    function HighlightObject(const Value: TRect): TRect;
  end;

  procedure Start(Sender: TObject);

  procedure Display(Sender: TObject; Value: string); overload;
  procedure Display(Sender: TObject; Value: TArray<string>); overload;
  procedure Display(Sender: TObject; Value: TChat); overload;
  procedure Display(Sender: TObject; Value: TModels); overload;
  procedure Display(Sender: TObject; Value: TAudioToText); overload;
  procedure Display(Sender: TObject; Value: TEmbeddings); overload;
  procedure Display(Sender: TObject; Value: TMask); overload;
  procedure Display(Sender: TObject; Value: TImageClassification); overload;
  procedure Display(Sender: TObject; Value: TImageSegmentation); overload;
  procedure Display(Sender: TObject; Value: TObjectDetection); overload;
  procedure Display(Sender: TObject; Value: TAudioClassification); overload;
  procedure Display(Sender: TObject; Value: TQuestionAnswering); overload;
  procedure Display(Sender: TObject; Value: TSummarization); overload;
  procedure Display(Sender: TObject; Value: TTableQA); overload;
  procedure Display(Sender: TObject; Value: TTextClassification); overload;
  procedure Display(Sender: TObject; Value: TTextToImage); overload;
  procedure Display(Sender: TObject; Value: TTokenClassification); overload;
  procedure Display(Sender: TObject; Value: TTranslation); overload;
  procedure Display(Sender: TObject; Value: TZeroShotClassification); overload;
  procedure Display(Sender: TObject; Value: TTextGeneration); overload;
  procedure Display(Sender: TObject; Value: TSentimentAnalysis); overload;
  procedure Display(Sender: TObject; Value: TTextToSpeech); overload;
  procedure Display(Sender: TObject; Value: TAudioToAudio); overload;
  procedure Display(Sender: TObject; Value: TImageSegmentationItem); overload;
  procedure Display(Sender: TObject; Value: TObjectDetectionItem); overload;

  procedure DisplayStream(Sender: TObject; Value: string); overload;
  procedure DisplayStream(Sender: TObject; Value: TChat); overload;
  procedure DisplayStream(Sender: TObject; Value: TTextGeneration); overload;

var
  HFTutorial: TVCLHuggingFaceSender = nil;

implementation

uses
  System.StrUtils;

procedure Start(Sender: TObject);
begin
  Display(Sender, HFTutorial.StartMessage);
end;

procedure Display(Sender: TObject; Value: string);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TVCLHuggingFaceSender).Memo1;
  M.Lines.Text := M.Text + Value + sLineBreak;
  M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure Display(Sender: TObject; Value: TArray<string>);
begin
  var index := 0;
  for var Item in Value do
    begin
      if index = 0 then
        Display(Sender, Item) else
      if not Item.IsEmpty then
        Display(Sender, '    . ' + Item) else
        Display(Sender, EmptyStr);
      Inc(index);
    end;
end;

procedure Display(Sender: TObject; Value: TChat);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TVCLHuggingFaceSender).Memo1;
  for var Item in Value.Choices do
    begin
      if Assigned(HFTutorial.FFuncProc) then
        for var SubItem in Item.Message.ToolCalls do
          begin
            HFTutorial.FFuncProc(M, HFTutorial.Func.Execute(SubItem.&Function.Arguments));
          end;
      Display(M, Item.Message.Content);
    end;
end;

procedure Display(Sender: TObject; Value: TModels);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TVCLHuggingFaceSender).Memo1;
  HFTutorial.UrlNext := Value.UrlNext;
  for var Item in Value.Items do
    begin
//      if IndexStr(Item.Inference.ToLower, ['cold', 'warm']) > -1 then
//        Display(M, Format('%s (%s)', [Item.Id, Item.Inference]))
//      else
        DisplayStream(M, Format('%s (%s) '#10, [Item.Id, Item.Inference]));
    end;
  if Value.UrlNext.IsEmpty then
    Display(M, EmptyStr);
end;

procedure Display(Sender: TObject; Value: TAudioToText);
begin
  Display(Sender, Value.Text);
  if System.Length(Value.Chunks) > 0 then
    for var Item in Value.Chunks do
      begin
        Display(Sender, '  . ' + Item.Text);
        for var SubItem  in Item.Timestamps do
          Display(Sender, '     > ' + SubItem.ToString(ffNumber, 4, 4));
      end;
end;

procedure Display(Sender: TObject; Value: TEmbeddings);
begin
  for var Item in Value.Items do
    Display(Sender, Item.ToString);
end;

procedure Display(Sender: TObject; Value: TMask);
begin
  for var Item in Value.Items do
    Display(Sender, [Item.Sequence, Item.TokenStr, Item.Score.ToString, Item.Token.ToString, EmptyStr]);
end;

procedure Display(Sender: TObject; Value: TImageClassification);
begin
  for var Item in Value.Items do
    Display(Sender, [Item.&Label, Item.Score.ToString(ffNumber, 5, 5)]);
end;

procedure Display(Sender: TObject; Value: TImageSegmentation);
begin
  for var Item in Value.Items do
    begin
      Display(Sender, [Item.&Label, Item.Score.ToString(ffNumber, 2, 2)]);
      Display(HFTutorial.Image2, Item);
    end;
end;

procedure Display(Sender: TObject; Value: TObjectDetection);
begin
  for var Item in Value.Items do
    begin
      Display(Sender, [Item.&Label, Item.Score.ToString(ffNumber, 2,2)]);
      Display(HFTutorial.Image1, Item);
    end;
end;

procedure Display(Sender: TObject; Value: TAudioClassification);
begin
  for var Item in Value.Items do
    Display(Sender, [Item.&Label, Item.Score.ToString]);
end;

procedure Display(Sender: TObject; Value: TQuestionAnswering);
begin
  if System.Length(Value.Items) = 0 then
    begin
      with Value do
        Display(Sender, [Answer, Score.ToString(ffNumber, 2,2), Start.ToString, &End.ToString]);
    end
  else
    begin
      for var Item in Value.Items do
        with Item do
          Display(Sender, [Answer, Score.ToString(ffNumber, 2,2), Start.ToString, &End.ToString]);
    end;
end;

procedure Display(Sender: TObject; Value: TSummarization);
begin
  for var Item in Value.Items do
    Display(Sender, Item.SummaryText);
end;

procedure Display(Sender: TObject; Value: TTableQA);
begin
  with Value do
    Display(Sender, [Answer, Coordinates.ToString, string.Join(', ', Cells), Aggregator]);
end;

procedure Display(Sender: TObject; Value: TTextClassification);
begin
  for var Item in Value.Items do
    for var SubItem in Item.Items do
      Display(Sender, [SubItem.&Label, SubItem.Score.ToString(ffNumber, 5, 5)]);
end;

procedure Display(Sender: TObject; Value: TTextToImage);
begin
  var Stream := Value.GetStream;
  try
    HFTutorial.Image1.Picture.LoadFromStream(Stream);
    if not HFTutorial.FileName.IsEmpty then
      Value.SaveToFile(HFTutorial.FileName);
  finally
    Stream.Free;
  end;
end;

procedure Display(Sender: TObject; Value: TTokenClassification);
begin
  for var Item in Value.Items do
    Display(Sender,
      [Item.EntityGroup, Item.Score.ToString(ffNumber, 5, 5),
       Item.Word, Item.Start.ToString, Item.&end.ToString, Item.Entity]);
end;

procedure Display(Sender: TObject; Value: TTranslation);
begin
  for var Item in Value.Items do
    Display(HFTutorial, Item.TranslationText);
end;

procedure Display(Sender: TObject; Value: TZeroShotClassification);
begin
  Display(HFTutorial, Value.Sequence);
  var Index := 0;
  for var Item in Value.Labels do
    begin
      Display(HFTutorial, '   . ' + Item + ' : ' + Value.Scores[Index].ToString(ffNumber, 5, 5));
      Inc(Index);
    end;
end;

procedure Display(Sender: TObject; Value: TTextGeneration);
begin
  for var Item in Value.Items do
    Display(HFTutorial, Item.GeneratedText);
end;

procedure Display(Sender: TObject; Value: TSentimentAnalysis);
begin
  for var Item in Value.Items do
    begin
      for var SubItem in Item.Evals do
        begin
          Display(Sender, [SubItem.&Label, SubItem.Score.ToString(ffNumber, 4, 4)]);
        end;
    end;
end;

procedure Display(Sender: TObject; Value: TTextToSpeech);
begin
  Display(Sender, HFTutorial.EndMessage);
  if HFTutorial.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');
  Value.SaveToFile(HFTutorial.FileName);
  HFTutorial.Play;
end;

procedure Display(Sender: TObject; Value: TAudioToAudio);
begin
  if HFTutorial.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');
  Value.SaveToFile(HFTutorial.FileName);
  HFTutorial.Play;
end;

procedure Display(Sender: TObject; Value: TImageSegmentationItem);
begin
  var Image := Sender as TImage;
  var Stream: TStream := nil;
  try
    Stream := Value.GetStream;
    Image.Picture.LoadFromStream(Stream);
    ShowMessage('Next');
  finally
    Stream.Free;
  end;
end;

procedure Display(Sender: TObject; Value: TObjectDetectionItem);
begin
  var Image := Sender as TImage;
  Image.HighlightObject(Value.ToRect);
  ShowMessage('Next');
  Image.AssignGraphic(HFTutorial.TempGraphic);
end;

procedure DisplayStream(Sender: TObject; Value: string);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TVCLHuggingFaceSender).Memo1;
  M.Lines.Text := M.Text + Value;
  M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure DisplayStream(Sender: TObject; Value: TChat);
begin
  for var Item in Value.Choices do
    DisplayStream(Sender, Item.Delta.Content);
end;

procedure DisplayStream(Sender: TObject; Value: TTextGeneration);
begin
  DisplayStream(HFTutorial, Value.Delta.Text);
end;

{ TVCLHuggingFaceSender }

constructor TVCLHuggingFaceSender.Create(const AMemo1: TMemo;
  const AImage1, AImage2: TImage; const AMediaPlayer: TMediaPlayer);
begin
  inherited Create;
  FMemo1 := AMemo1;
  FImage1 := AImage1;
  FImage2 := AImage2;
  FMediaPlayer := AMediaPlayer;
  FStartMessage := 'Please wait...';
  FEndMessage := 'Process ended...';
end;

destructor TVCLHuggingFaceSender.Destroy;
begin
  TempGraphic.Free;
  inherited;
end;

procedure TVCLHuggingFaceSender.LoadImageFromFile(const FilePath: TFileName);
begin
  if not FileExists(FilePath) then
    raise Exception.CreateFmt('File not found (%s)', [FilePath]);

  if Assigned(TempGraphic) then
    TempGraphic.Free;

  if SameText(ExtractFileExt(FilePath), '.jpg') or SameText(ExtractFileExt(FilePath), '.jpeg') then
    TempGraphic := TJPEGImage.Create
  else
  if SameText(ExtractFileExt(FilePath), '.png') then
    TempGraphic := TPngImage.Create
  else
    raise Exception.Create('Format d''image non pris en charge.');

  TempGraphic.LoadFromFile(FilePath);
  Image1.AssignGraphic(TempGraphic);
end;

procedure TVCLHuggingFaceSender.Play;
begin
  with HFTutorial.MediaPlayer do
    begin
      FileName := HFTutorial.FileName;
      Open;
      Play;
    end;
end;

procedure TVCLHuggingFaceSender.SetFileName(const Value: string);
begin
  FFileName := Value;
  FMediaPlayer.Close;
end;

{ TImageHelper }

procedure TImageHelper.AssignGraphic(const Value: TGraphic);
begin
  Picture.Bitmap.Assign(Value);
end;

procedure TImageHelper.DrawTransparentRectangle(Value: TRect;
  Color: TColor; Alpha: Byte);
type
  TRGBTripleArray = array[0..MaxInt div SizeOf(TRGBTriple) - 1] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
var
  X, Y: Integer;
  R, G, B: Byte;
  SrcR, SrcG, SrcB: Byte;
  Row: PRGBTripleArray;
  Bitmap: TBitmap;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);

  Bitmap := Picture.Bitmap;
  Bitmap.PixelFormat := pf24bit;

  for Y := Value.Top to Value.Bottom - 1 do
  begin
    Row := Bitmap.ScanLine[Y];
    for X := Value.Left to Value.Right - 1 do
    begin
      SrcR := Row[X].rgbtRed;
      SrcG := Row[X].rgbtGreen;
      SrcB := Row[X].rgbtBlue;

      Row[X].rgbtRed := (SrcR * (255 - Alpha) + R * Alpha) div 255;
      Row[X].rgbtGreen := (SrcG * (255 - Alpha) + G * Alpha) div 255;
      Row[X].rgbtBlue := (SrcB * (255 - Alpha) + B * Alpha) div 255;
    end;
  end;

  Invalidate;
end;

function TImageHelper.HighlightObject(const Value: TRect): TRect;
begin
  DrawTransparentRectangle(Value, clYellow, 128);
end;

initialization
finalization
  if Assigned(HFTutorial) then
    HFTutorial.Free;
end.
