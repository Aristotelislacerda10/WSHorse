program WSHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  ClienteController in 'Controllers\ClienteController.pas',
  Model.Connection in 'Model\Model.Connection.pas',
  Model.Cliente in 'Model\Model.Cliente.pas';

begin
  THorse.Use(Jhonson());
  ClienteController.Registry;
  THorse.Listen(9000);
end.
