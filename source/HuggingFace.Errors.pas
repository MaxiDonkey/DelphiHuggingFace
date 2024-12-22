unit HuggingFace.Errors;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  REST.Json.Types;

type
  TErrorCore = class abstract
  end;

  TError = class(TErrorCore)
  private
    FId: string;
    FName: string;
    FError: string;
    FWarnings: TArray<string>;
    [JsonNameAttribute('estimated_time')]
    FEstimatedTime: Double;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Error: string read FError write FError;
    property Warnings: TArray<string> read FWarnings write FWarnings;
    property EstimatedTime: Double read FEstimatedTime write FEstimatedTime;
  end;

implementation


end.
