program damian;

{$R *.dres}

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {FrmMain},
  SettingsUnit in 'SettingsUnit.pas' {FrmSettings},
  DamianInputUnit in 'Model\DamianInputUnit.pas';

{$R *.res}

begin
	ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
