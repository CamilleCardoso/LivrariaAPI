unit uautores;

{$mode Delphi}{$H+}

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
  ActiveX,
  fpjson,
  jsonparser,
  Horse.Jhonson,
  Horse.CORS,
  unidac10,
  msprovider10,
  Horse.OctetStream,
  horse.Commons;

implementation

procedure GetAutores(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 autor: TJSONArray;
 DM : TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
  try
  autor := TJSONArray.Create;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Autores');
  DM.UniQuery1.Open;
  autor := DM.UniQuery1.ToJSONArray();
  Res.Send< TJSONArray > (autor);
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
procedure DeleteAutores(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id: string;
 begin
  DM := TDataModule1.Create(nil);
  try
  try
  id := Req.Query.Items['id'];
  DM.UniQuery1.Close;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('delete from Autores where ID = :id');
  DM.Uniquery1.ParamByName('id').AsString := id;
  DM.UniQuery1.ExecSqL;
  Res.ContentType('application/json').Send(id + ' Autor excluído!');
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
procedure PutAutores(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, autor,nacionalidade,data: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('id').asstring;
  autor:=JsonData.FindPath('nome').asstring;
  nacionalidade:=JsonData.FindPath('nacionalidade').asstring;
  data:=JsonData.FindPath('data').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Autores set Nome = :autor, Nacionalidade = :nacionalidade, DataNascimento = :data where ID= :id');
  DM.Uniquery1.ParamByName('autor').AsString:= autor;
  DM.Uniquery1.ParamByName('nacionalidade').AsString:= nacionalidade;
  DM.Uniquery1.ParamByName('data').AsString:= data;
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
procedure PostAutores(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  autor,id,nacionalidade,data : string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try

  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('id').asstring;
  autor:=JsonData.FindPath('nome').asstring;
  nacionalidade:=JsonData.FindPath('nacionalidade').asstring;
  data:=JsonData.FindPath('data').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('insert into Autores');
  DM.UniQuery1.SQL.Add('(Nome, Nacionalidade,DataNascimento)');
  DM.UniQuery1.SQL.Add('values');
  DM.UniQuery1.SQL.Add('(:autor, :nacionalidade, :data)');

  DM.Uniquery1.ParamByName('autor').AsString:= autor;
  DM.Uniquery1.ParamByName('nacionalidade').AsString:= nacionalidade;
  DM.Uniquery1.ParamByName('data').AsString:= data;

  DM.UniQuery1.ExecSqL;

  Res.ContentType('application/json').Send('Inserido!');

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

procedure CarregarAutores;
begin
  THorse.Get('/Autores', GetAutores);
  THorse.Delete('/Autores', DeleteAutores);
  THorse.Put('/Autores', PutAutores);
  THorse.Post('/Autores', PostAutores);
end;

Initialization

CarregarAutores;
end.

