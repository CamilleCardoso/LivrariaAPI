unit uclientes;

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
  Horse.OctetStream,
  fpjson,
  jsonparser,
  Horse.Jhonson,
  Horse.CORS,
  unidac10,
  msprovider10,
  horse.Commons;

implementation

procedure GetClientes(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 clientes: TJSONArray;
 DM : TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
  try
  clientes := TJSONArray.Create;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Clientes');
  DM.UniQuery1.Open;
  clientes := DM.UniQuery1.ToJSONArray();
  Res.Send< TJSONArray > (clientes);
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
procedure DeleteClientes(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
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
  DM.UniQuery1.SQL.Add('delete from Clientes where ID = :id');
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
procedure PutClientes(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, cliente,telefone,email,password: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try

  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('id').asstring;
  cliente:=JsonData.FindPath('nome').asstring;
  telefone:=JsonData.FindPath('telefone').asstring;
  email:=JsonData.FindPath('email').asstring;
  password:=JsonData.FindPath('password').asstring;

  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Clientes set Nome = :cliente, Telefone = :telefone, Email = :email, Password = :password where ID= :id');
  DM.Uniquery1.ParamByName('cliente').AsString:= cliente;
  DM.Uniquery1.ParamByName('telefone').AsString:= telefone;
  DM.Uniquery1.ParamByName('email').AsString:= email;
  DM.Uniquery1.ParamByName('password').AsString:= password;
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
procedure PostClientes(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, cliente,telefone,email,password: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


 // id:= JsonData.FindPath('id').asstring;
  cliente:=JsonData.FindPath('nome').asstring;
  telefone:=JsonData.FindPath('telefone').asstring;
  email:=JsonData.FindPath('email').asstring;
  password:=JsonData.FindPath('password').asstring;

  DM.UniQuery1.Close;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('insert into Clientes');
  DM.UniQuery1.SQL.Add('(Nome, Telefone,Email,Password)');
  DM.UniQuery1.SQL.Add('values');
  DM.UniQuery1.SQL.Add('(:cliente, :telefone, :email, :password)');

  DM.Uniquery1.ParamByName('cliente').AsString:= cliente;
  DM.Uniquery1.ParamByName('telefone').AsString:= telefone;
  DM.Uniquery1.ParamByName('email').AsString:= email;
  DM.Uniquery1.ParamByName('password').AsString:= password;

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

procedure CarregarClientes;
begin
  THorse.Get('/Clientes', GetClientes);
  THorse.Delete('/Clientes', DeleteClientes);
  THorse.Put('/Clientes', PutClientes);
  THorse.Post('/Clientes', PostClientes);
end;

Initialization
CarregarClientes;
end.

