unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SkinCtrls, SkinData, DynamicSkinForm, StdCtrls, ExtCtrls, SkinExCtrls,
  Vcl.Mask, SkinBoxCtrls;

type
  TForm1 = class(TForm)
    spDynamicSkinForm1: TspDynamicSkinForm;
    spSkinData1: TspSkinData;
    Timer1: TTimer;
    spSkinEdit1: TspSkinEdit;
    spCompressedSkinList1: TspCompressedSkinList;
    spSkinMemo1: TspSkinMemo;
    procedure FormCreate(Sender: TObject);
    procedure spDynamicSkinForm1MouseUpEvent(IDName: String; X, Y: Integer;
      ObjectRect: TRect; Button: TMouseButton);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSkin(FileName: String);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.LoadSkin;
begin
  spSkinData1.LoadFromFile(FileName);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Path: String;
begin
	Path := ExtractFilePath(ParamStr(0));
//	LoadSkin('.\damian.skn');
end;


procedure TForm1.spDynamicSkinForm1MouseUpEvent(IDName: String; X,
  Y: Integer; ObjectRect: TRect; Button: TMouseButton);
begin
  if IDName = 'stopbutton'
  then
    begin
		end
	else
	if IDName = 'playbutton'
	then
		begin
			Timer1.Enabled := True;

    end;
end;

end.
