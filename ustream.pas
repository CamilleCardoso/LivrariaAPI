unit ustream;

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
  Horse.OctetStream,
  jsonparser,
  Horse.Jhonson,
  Horse.CORS,
  Classes,
  DB,
  msprovider10,
  horse.Commons;

implementation

procedure GetStream(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
 Livros: TJSONArray;
 DM : TDataModule1;
 img : TMemoryStream;
 LStream: TFileStream;
 filestream: TFileReturn;
 id : string;
 LIVROID: integer;

begin
  DM := TDataModule1.Create(nil);
  try
  try
  Livros := TJSONArray.Create;
  img := TMemoryStream.Create;
  id := Req.Query.Items['id'];

  DM.UniQuery1.SQL.Clear;
  DM.UniQuery1.SQL.Add('SELECT * FROM Livros where ID= :id');
  DM.Uniquery1.ParamByName('id').AsString := id;
  DM.UniQuery1.Open;

  Livros := DM.UniQuery1.ToJSONArray();
  TBlobField(DM.UniQuery1.FieldByName('Stream')).SaveToStream(img);
  filestream := TFileReturn.Create('imagem.png', img);
  Res.Send<TJSONArray> (Livros);
  Res.ContentType('application/octet-stream').Send<TFileReturn>(filestream).status(200);


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
procedure PostStream(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  DM: TDataModule1;
  livro, ano: string;
  LStream: TMemoryStream;
  JsonData: TJsonData;
begin
  DM := TDataModule1.Create(nil);
  LStream := TMemoryStream.Create;

   try
    JsonData := GetJSON(Req.RawWebRequest.GetCustomHeader('conteudo-json'));

    if JsonData is TJSONData then
    begin

      livro:=JsonData.FindPath('livro').asstring;
      ano:=JsonData.FindPath('ano').asstring;


    if (livro <> '') and (ano <> '') then
    begin

      LStream := Req.Body<TMemoryStream>;


      DM.UniQuery1.SQL.Clear;
      DM.UniQuery1.SQL.Add('INSERT INTO Livros (Livro, Ano, Stream) VALUES (:livro, :ano, :stream)');
      DM.UniQuery1.ParamByName('livro').AsString := livro;
      DM.UniQuery1.ParamByName('ano').AsString := ano;
      DM.UniQuery1.ParamByName('stream').LoadFromStream(LStream, ftBlob);
      DM.UniQuery1.ExecSQL;

      Res.Send('Cadastro de livro e imagem realizado com sucesso!').Status(201);
      end
      else
      begin
        Res.Send('Dados insuficientes no corpo da solicitação').Status(400);
      end;
    end
    else
    begin
      Res.Send('JSON inválido no cabeçalho da solicitação').Status(400);
    end;
  except
    Res.Send('Erro ao processar a solicitação').Status(500);
  end;
end;
procedure CarregarImagem;
begin
THorse.Get('/LivroStream',GetStream);
THorse.Post('/LivroStream', PostStream);
end;
initialization
CarregarImagem;
end.

