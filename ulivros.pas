unit ulivros;

{$mode Delphi}

interface

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.BasicAuthentication,
  SysUtils,
  DataSet.Serialize,
  udm,
  ueditora,
  ActiveX,
  fpjson,
  DB,
  Horse.OctetStream,
  jsonparser,
  Horse.Jhonson,
  Horse.CORS,
  Classes,
  msprovider10,
  horse.Commons;

implementation

procedure GetLivros(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 Livros: TJSONArray;
 DM : TDataModule1;
 tag: TJsonObject;

begin
  DM := TDataModule1.Create(nil);
  try
  try
  tag := TJSONObject.Create;
  Livros := TJSONArray.Create;

  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Livros');
  DM.UniQuery1.Open;

  Livros := DM.UniQuery1.ToJSONArray();
  tag.Add('INFO', Livros);
  Res.Send<TJSONObject>(tag);

  except
      on e: Exception do
       begin
        Res.ContentType('application/json; charset=UTF-8').Send(Format('{"Error":"%s"}', [E.Message])).Status(501);
       end;
  end;
  finally
    FreeAndNil(DM);
  end;

end;

procedure DeleteLivros(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id: string;
 begin
  DM := TDataModule1.Create(nil);
  try
  try
  id := Req.Query.Items['id'];
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('delete from Livros where ID = :id');
  DM.Uniquery1.ParamByName('id').AsString := id;
  DM.UniQuery1.ExecSqL;
  Res.ContentType('application/json').Send(id + ' Livro excluído!');
  except
      on e: Exception do
       begin
        Res.ContentType('application/json; charset=UTF-8').Send(Format('{"Error":"%s"}', [E.Message])).Status(501);
       end;
  end;
  finally
    FreeAndNil(DM);
  end;


end;

procedure PutLivros(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, livro, ano, stream : string;
  json: string;
  JsonData : TJSONData;
  LStream: TMemoryStream;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);

  id:= JsonData.FindPath('id').asstring;
  livro:=JsonData.FindPath('livro').asstring;
  ano:=JsonData.FindPath('ano').asstring;

  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Livros set Livro = :livro, Ano = :ano where ID= :id');
  DM.Uniquery1.ParamByName('livro').AsString:= livro;
  DM.Uniquery1.ParamByName('ano').AsString:= ano;
  DM.Uniquery1.ParamByName('id').AsString:= id;
  DM.UniQuery1.ExecSqL;

 Res.ContentType('application/json').Send('Alterado!');
     except
      on e: Exception do
       begin
        Res.ContentType('application/json; charset=UTF-8').Send(Format('{"Error":"%s"}', [E.Message])).Status(501);
       end;
     end;
  finally
    FreeAndNil(DM);
  end;

end;
procedure PostLivros(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  livro, ano: string;
  json: TJSONObject;
  JsonData : TJsonData;

begin
  DM := TDataModule1.Create(nil);

  try
  try

  JsonData := TJSONObject(GetJSON(Req.Body));

  livro:=JsonData.FindPath('livro').asstring;
  ano:=JsonData.FindPath('ano').asstring;

  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('insert into Livros');
  DM.UniQuery1.SQL.Add('(Livro, Ano)');
  DM.UniQuery1.SQL.Add('values');
  DM.UniQuery1.SQL.Add('(:livro,:ano)');

  DM.Uniquery1.ParamByName('livro').AsString:= livro;
  DM.Uniquery1.ParamByName('ano').AsString:= ano;
  DM.UniQuery1.ExecSqL;

  Res.Send('Cadastro realizado com sucesso!').Status(201);

     except
      on e: Exception do
       begin
        Res.ContentType('application/json; charset=UTF-8').Send(Format('{"Error":"%s"}', [E.Message])).Status(501);
       end;
       end;
  finally
    FreeAndNil(DM);
  end;
end;


procedure CarregarLivros;
begin
  THorse.Get('/Livros', GetLivros);
  THorse.Delete('/Livros', DeleteLivros);
  THorse.Put('/Livros', PutLivros);
  THorse.Post('/Livros', PostLivros);
 end;

Initialization

CarregarLivros;
end.
