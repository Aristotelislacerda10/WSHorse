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
    writeln(dateTimeToStr(now)+ ' - requisição: "Listar clientes" realizada na porta: ' + THorse.Port.ToString);
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
      writeln(dateTimeToStr(now)+ ' - requisição: "ListarClientesID" realizada na porta: ' + THorse.Port.ToString);
    end
    else
     res.send('Cliente nao encontrado').Status(404);


  finally
    QueryCli.free;
    Cliente.free;
  end;
end;

procedure CadastrarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cli : TCliente;
    objCliente: TJSONObject;
    erro : string;
    body  : TJsonValue;
begin
  // Conexao com o banco...
  try
      cli := TCliente.Create;
  except
      res.Send('Erro ao conectar com o banco').Status(500);
      exit;
  end;


  try
     try
        body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

        cli.NOME := body.GetValue<string>('nome', '');
        cli.EMAIL := body.GetValue<string>('email', '');
        cli.FONE := body.GetValue<string>('fone', '');
        cli.Inserir(erro);

        body.Free;

        if erro <> '' then
            raise Exception.Create(erro);

     except
       on ex:exception do
       begin
          res.Send(ex.Message).Status(400);
          exit;
       end;
     end;


      objCliente := TJSONObject.Create;
      objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);
      writeln(dateTimeToStr(now)+ ' - requisição: "CadastrarClientes" realizada na porta: ' + THorse.Port.ToString);

      res.Send<TJSONObject>(objCliente).Status(201);
  finally
      cli.Free;
  end;
end;

procedure deletarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cli : TCliente;
    objCliente: TJSONObject;
    erro : string;
begin
    // Conexao com o banco...
    try
        cli := TCliente.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            cli.ID_CLIENTE := Req.Params['id'].ToInteger;

            if NOT cli.Excluir(erro) then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objCliente := TJSONObject.Create;
        objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);
        writeln(dateTimeToStr(now)+ ' - requisição: "deletarClientes" realizada na porta: ' + THorse.Port.ToString);

        res.Send<TJSONObject>(objCliente);
    finally
        cli.Free;
    end;
end;

procedure AlterarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cli : TCliente;
    objCliente: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    try
        cli := TCliente.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            cli.ID_CLIENTE := body.GetValue<integer>('id_cliente', 0);
            cli.NOME := body.GetValue<string>('nome', '');
            cli.EMAIL := body.GetValue<string>('email', '');
            cli.FONE := body.GetValue<string>('fone', '');
            cli.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objCliente := TJSONObject.Create;
        objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);
        writeln(dateTimeToStr(now)+ ' - requisição: "AlterarClientes" realizada na porta: ' + THorse.Port.ToString);

        res.Send<TJSONObject>(objCliente).Status(200);
    finally
        cli.Free;
    end;
end;

procedure Registry;
begin
  THorse.Get('/cliente',ListarClientes);

  THorse.Get('/cliente/:id',ListarClientesID);

  THorse.Post('/cliente', CadastrarClientes);

  THorse.Delete('/cliente/:id',deletarClientes);

  THorse.Put('/cliente',AlterarClientes);

end;



end.
