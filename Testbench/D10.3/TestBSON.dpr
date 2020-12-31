program TestBSON;

uses
  Vcl.Forms,
  uMain in '..\uMain.pas' {Main},
  kxBSON in '..\..\Source\kxBSON.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
