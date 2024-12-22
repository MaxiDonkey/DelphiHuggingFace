unit HuggingFace.Hub.Support;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiHuggingFace
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, HuggingFace.API.Params;

type
  TFetchParams = class(TCMDParam)
  public
    function Search(const Value: string): TFetchParams;
    function Author(const Value: string): TFetchParams;
    function Filter(const Value: string): TFetchParams;
    function Sort(const Value: string): TFetchParams;
    function Direction(const Value: string): TFetchParams;
    function Limit(const Value: Integer): TFetchParams;
    function Full(const Value: Boolean): TFetchParams;
    function Config(const Value: Boolean): TFetchParams;
    constructor Create;
  end;

implementation

{ TFetchParams }

function TFetchParams.Author(const Value: string): TFetchParams;
begin
  Result := TFetchParams(Add('author', Value));
end;

function TFetchParams.Config(const Value: Boolean): TFetchParams;
begin
  Result := TFetchParams(Add('config', Value));
end;

constructor TFetchParams.Create;
begin
  Inherited Create;
  Limit(5);
  Full(True);
  Config(False);
end;

function TFetchParams.Direction(const Value: string): TFetchParams;
begin
  Result := TFetchParams(Add('direction', Value));
end;

function TFetchParams.Filter(const Value: string): TFetchParams;
begin
  Result := TFetchParams(Add('filter', Value));
end;

function TFetchParams.Full(const Value: Boolean): TFetchParams;
begin
  Result := TFetchParams(Add('full', Value));
end;

function TFetchParams.Limit(const Value: Integer): TFetchParams;
begin
  Result := TFetchParams(Add('limit', Value));
end;

function TFetchParams.Search(const Value: string): TFetchParams;
begin
  Result := TFetchParams(Add('search', Value));
end;

function TFetchParams.Sort(const Value: string): TFetchParams;
begin
  Result := TFetchParams(Add('sort', Value));
end;

end.

