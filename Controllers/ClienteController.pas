unit ClienteController;

interface

uses Horse, System.JSON, System.SysUtils, Model.Cliente, Data.DB,
 FireDAC.Comp.Client, DataSet.Serialize;

procedure Registry;

implementation

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente       : TCliente;
    QueryCli      : TFDQuery;
    erro          : string;
    ArrayClientes : TJSONArray;
begin
  try
    Cliente := TCliente.create;
  except
    on E: Exception do
    begin
      res.send('Erro ao conectar com o banco ' + E.Message).Status(500);
      Exit;
    end;
  end;

  try
    QueryCli := Cliente.ListarCliente('',erro);
    ArrayClientes := QueryCli.toJSONArray();

    res.send<TJSONArray>(ArrayClientes);
  finally
    QueryCli.free;
    Cliente.free;
  end;
end;

procedure ListarClientesID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Cliente       : TCliente;
    QueryCli      : TFDQuery;
    erro          : string;
    ObjClientes   : TJSONObject;
begin
  try
    Cliente := TCliente.create;
    Cliente.ID_CLIENTE := req.params['id'].toInteger;
  except
    on E: Exception do
    begin
      res.send('Erro ao conectar com o banco ' + E.Message).Status(500);
      Exit;
    end;
  end;

  try
    QueryCli := Cliente.ListarCliente('',erro);

    if QueryCli.recordCount > 0 then
    begin
      ObjClientes := QueryCli.toJSONObject();
      res.send<TJSONObject>(ObjClientes);
    end
    else
     res.send('Cliente nao encontrado').Status(404);


  finally
    QueryCli.free;
    Cliente.free;
  end;
end;

procedure CadastrarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('cadastrar clientes...');
end;

procedure deletarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('deletar clientes...');
end;

procedure AlterarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('Altera clientes...');
end;

procedure Registry;
begin
  THorse.Get('/cliente',ListarClientes);

  THorse.Get('/cliente/:id',ListarClientesID);

  THorse.Post('/cliente', CadastrarClientes);

  THorse.Delete('/cliente',deletarClientes);

  THorse.Put('/cliente',AlterarClientes);

end;



end.
