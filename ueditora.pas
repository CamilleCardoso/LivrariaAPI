unit ueditora;

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
  Horse.OctetStream,
  jsonparser,
  Horse.Jhonson,
  Horse.CORS,
  unidac10,
  msprovider10,
  horse.Commons;

implementation

procedure GetEditora(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 Editora: TJSONArray;
 DM : TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
  try
  Editora := TJSONArray.Create;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Editora');
  DM.UniQuery1.Open;
  Editora := DM.UniQuery1.ToJSONArray();
  Res.Send< TJSONArray > (Editora);
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
procedure DeleteEditora(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
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
  DM.UniQuery1.SQL.Add('delete from Editora where ID = :id');
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
procedure PutEditora(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, editora: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try

  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('id').asstring;
  editora:=JsonData.FindPath('editora').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Editora set Editora = :editora where ID= :id');
  DM.Uniquery1.ParamByName('editora').AsString:= editora;
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
procedure PostEditora(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  editora : string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


  editora:=JsonData.FindPath('editora').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('insert into Editora');
  DM.UniQuery1.SQL.Add('(Editora)');
  DM.UniQuery1.SQL.Add('values');
  DM.UniQuery1.SQL.Add('(:editora)');

  DM.Uniquery1.ParamByName('editora').AsString:= editora;
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

procedure CarregarEditora;

begin
  THorse.Get('/Editora', GetEditora);
  THorse.Delete('/Editora', DeleteEditora);
  THorse.Put('/Editora', PutEditora);
  THorse.Post('/Editora', PostEditora);
end;

Initialization

CarregarEditora;

end.

