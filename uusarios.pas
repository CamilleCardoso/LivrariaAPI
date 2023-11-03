unit uusarios;

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
  Horse.OctetStream,
  Horse.Jhonson,
  Horse.CORS,
  unidac10,
  msprovider10,
  horse.Commons;


implementation

procedure GetUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 usuario: TJSONArray;
 DM : TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
  try
  usuario := TJSONArray.Create;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Usuarios');
  DM.UniQuery1.Open;
  usuario := DM.UniQuery1.ToJSONArray();
  Res.Send< TJSONArray > (usuario);

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
procedure DeleteUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
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
  DM.UniQuery1.SQL.Add('delete from Usuarios where ID = :id');
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
procedure PutUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, usuario,senha, telefone, email: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('id').asstring;
  usuario:=JsonData.FindPath('nome').asstring;
  senha:=JsonData.FindPath('senha').asstring;
  telefone:=JsonData.FindPath('telefone').asstring;
  email:=JsonData.FindPath('email').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Usuarios set Nome = :usuario, Telefone = :telefone, Senha = :senha, Email = :email where ID= :id');
  DM.Uniquery1.ParamByName('usuario').AsString:= usuario;
  DM.Uniquery1.ParamByName('senha').AsString:= senha;
  DM.Uniquery1.ParamByName('telefone').AsString:= telefone;
  DM.Uniquery1.ParamByName('email').AsString:= email;
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
procedure PostUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, usuario,senha, telefone, email: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);

  id:= JsonData.FindPath('id').asstring;
  usuario:=JsonData.FindPath('nome').asstring;
  senha:=JsonData.FindPath('senha').asstring;
  telefone:=JsonData.FindPath('telefone').asstring;
  email:=JsonData.FindPath('email').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('insert into Usuarios');
  DM.UniQuery1.SQL.Add('(Nome, Telefone,Senha,Email)');
  DM.UniQuery1.SQL.Add('values');
  DM.UniQuery1.SQL.Add('(:usuario, :telefone, :senha, :email)');

  DM.Uniquery1.ParamByName('usuario').AsString:= usuario;
  DM.Uniquery1.ParamByName('senha').AsString:= senha;
  DM.Uniquery1.ParamByName('telefone').AsString:= telefone;
  DM.Uniquery1.ParamByName('email').AsString:= email;

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

procedure CarregarUsuarios;
begin
  THorse.Get('/Usuarios', GetUsuarios);
  THorse.Delete('/Usuarios', DeleteUsuarios);
  THorse.Put('/Usuarios', PutUsuarios);
  THorse.Post('/Usuarios', PostUsuarios);
end;

Initialization
CarregarUsuarios;
end.

