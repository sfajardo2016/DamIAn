program damian;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {FrmMain},
  SettingsUnit in 'SettingsUnit.pas' {FrmSettings};

{$R *.res}

begin
	ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
