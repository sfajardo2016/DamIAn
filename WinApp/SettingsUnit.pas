unit SettingsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DynamicSkinForm, SkinData,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, LinkLabel2, i18nCore,
  i18nLocalizer, i18nCtrls, AdvSmoothLabel;

type
  TFrmSettings = class(TForm)
    spCompressedSkinList1: TspCompressedSkinList;
    spSkinData1: TspSkinData;
    spDynamicSkinForm1: TspDynamicSkinForm;
    Label2: TLabel;
    Edit_SpecialPhase: TEdit;
    LinkLabel21: TLinkLabel2;
		CultureListBox1: TCultureListBox;
    Label4: TLabel;
    Translator1: TTranslator;
    Localizer1: TLocalizer;
    Label5: TLabel;
    ComboBox_Skin: TComboBox;
    AdvSmoothLabel1: TAdvSmoothLabel;
		procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
		{ Private declarations }
    ESCPressedCounter: SmallInt;
  public
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;

implementation

{$R *.dfm}


uses MainUnit;
procedure TFrmSettings.FormCreate(Sender: TObject);
begin
ESCPressedCounter:=0;
end;

procedure TFrmSettings.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

		if (Key=VK_ESCAPE) then begin
			inc ( ESCPressedCounter );
			if (ESCPressedCounter>=2) then Close;
		end else ESCPressedCounter := 0;

end;

end.
