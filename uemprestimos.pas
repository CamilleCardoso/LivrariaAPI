unit uemprestimos;

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
  Horse.OctetStream,
  unidac10,
  msprovider10,
  horse.Commons;


implementation

procedure GetEmprestimos(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 emprestimos: TJSONArray;
 DM : TDataModule1;
begin
  DM := TDataModule1.Create(nil);
  try
  try
  emprestimos := TJSONArray.Create;
  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Emprestimos');
  DM.UniQuery1.Open;
  emprestimos := DM.UniQuery1.ToJSONArray();
  Res.Send< TJSONArray > (emprestimos);
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
procedure DeleteEmprestimos(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
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
  DM.UniQuery1.SQL.Add('delete from Emprestimos where IDEmprestimo = :id');
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
procedure PutEmprestimos(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  id, dataemprestimo,datadevolucao,pessoaid,livroid: string;
  quantidade,diadevolvido: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


  id:= JsonData.FindPath('idemprestimo').asstring;
  dataemprestimo:=JsonData.FindPath('dataemprestimo').asstring;
  datadevolucao:=JsonData.FindPath('datadevolucao').asstring;
  pessoaid:=JsonData.FindPath('pessoaid').asstring;
  livroid:=JsonData.FindPath('livroid').asstring;
  quantidade:=JsonData.FindPath('quantidade').asstring;
  diadevolvido:=JsonData.FindPath('diadevolvido').asstring;


  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('update Emprestimos set DataEmprestimo = :dataemprestimo, DataDevolucao = :datadevolucao, PessoaID = :pessoaid, LivroID = :livroid, Quantidade = :quantidade, DiaDevolvido = :diadevolvido where IDEmprestimo = :id');
  DM.Uniquery1.ParamByName('dataemprestimo').AsString:= dataemprestimo;
  DM.Uniquery1.ParamByName('datadevolucao').AsString:= datadevolucao;
  DM.Uniquery1.ParamByName('pessoaid').AsString:= pessoaid;
  DM.Uniquery1.ParamByName('livroid').AsString:= livroid;
  DM.Uniquery1.ParamByName('quantidade').AsString:= quantidade;
  DM.Uniquery1.ParamByName('diadevolvido').AsString:= diadevolvido;
  DM.Uniquery1.ParamByName('idemprestimo').AsString:= id;
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
procedure PostEmprestimos(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  idemprestimo, dataemprestimo,datadevolucao,pessoaid: string;
  livroid,quantidade,diadevolvido: string;
  json: string;
  JsonData : TJSONData;

begin
  DM := TDataModule1.Create(nil);

  try
  try
  json := Req.Body();
  JsonData := GetJSON(json);


  idemprestimo:= JsonData.FindPath('idemprestimo').asstring;
  dataemprestimo:=JsonData.FindPath('dataemprestimo').asstring;
  datadevolucao:=JsonData.FindPath('datadevolucao').asstring;
  pessoaid:=JsonData.FindPath('pessoaid').asstring;
  livroid:=JsonData.FindPath('livroid').asstring;
  quantidade:=JsonData.FindPath('quantidade').asstring;
  diadevolvido:=JsonData.FindPath('diadevolvido').asstring;


   DM.UniQuery1.SQL.Clear;
   DM.UniQuery1.SQL.Add('insert into Emprestimos');
   DM.UniQuery1.SQL.Add('(DataEmprestimo, DataDevolucao,PessoaID,LivroID,Quantidade,DiaDevolvido)');
   DM.UniQuery1.SQL.Add('values');
   DM.UniQuery1.SQL.Add('(:dataemprestimo, :datadevolucao, :pessoaid, :livroid, :quantidade, :diadevolvido)');

   DM.Uniquery1.ParamByName('dataemprestimo').AsString:= dataemprestimo;
   DM.Uniquery1.ParamByName('datadevolucao').AsString:= datadevolucao;
   DM.Uniquery1.ParamByName('pessoaid').AsString:= pessoaid;
   DM.Uniquery1.ParamByName('livroid').AsString:= livroid;
   DM.Uniquery1.ParamByName('quantidade').AsString:= quantidade;
   DM.Uniquery1.ParamByName('diadevolvido').AsString:= diadevolvido;

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

procedure CarregarEmprestimos;
begin
  THorse.Get('/Emprestimos', GetEmprestimos);
  THorse.Delete('/Emprestimos', DeleteEmprestimos);
  THorse.Put('/Emprestimos', PutEmprestimos);
  THorse.Post('/Emprestimos', PostEmprestimos);
end;

Initialization
CarregarEmprestimos;
end.

