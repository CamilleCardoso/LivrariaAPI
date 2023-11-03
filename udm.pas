unit udm;

{$mode Delphi}

interface

uses
  Classes, SysUtils, SQLServerUniProvider, Uni,ActiveX;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    SQLServerUniProvider1: TSQLServerUniProvider;
    UniConnection1: TUniConnection;
    UniQuery1: TUniQuery;
    procedure UniConnection1BeforeConnect(Sender: TObject);
    procedure UniConnection1BeforeDisconnect(Sender: TObject);
  private

  public

  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.UniConnection1BeforeConnect(Sender: TObject);
begin
  CoInitialize(nil);
end;

procedure TDataModule1.UniConnection1BeforeDisconnect(Sender: TObject);
begin
  CoUnInitialize;
end;

end.

