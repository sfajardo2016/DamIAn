unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SkinData, DynamicSkinForm,
  Vcl.StdCtrls, TextFade, Vcl.Mask, SkinBoxCtrls, SkinCtrls, bsSkinBoxCtrls,
  Vcl.ExtCtrls, bsSkinCtrls;

type
  TFrmMain = class(TForm)
    spCompressedSkinList1: TspCompressedSkinList;
    spSkinData1: TspSkinData;
    spDynamicSkinForm1: TspDynamicSkinForm;
    Edit_Input: TEdit;
    TextFader1: TTextFader;
    Panel_Input: TPanel;
    Label_Input: TLabel;
    Panel_Config: TbsSkinExPanel;
    Panel_Preferences_Top: TbsSkinPanel;
    bsSkinStdLabel1: TbsSkinStdLabel;
    Edit_SpecialPhase: TbsSkinEdit;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Edit_InputKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_InputKeyPress(Sender: TObject; var Key: Char);
    procedure TextFader1Complete(Sender: TObject);
  private
		{ Private declarations }
		QuestionCharWasPressed: Boolean;
		QuestionCharBeenPressed: Boolean;

		TheAnswer: String;

		NonBeliever: Boolean;
		NonBelieverQuestions: Smallint;

		BackSpaceWasPressed: Boolean;
		ESCKeyPressed: Boolean;
		ESCKeyPressedCounter: SmallInt;

		SpecialPhase:String;
		SpecialCharacter: Char;

		CanAskAQuestion: Boolean;
		Closing: Boolean;
    function NewQuestion(JustStarting: Boolean): Boolean;
    procedure ShowReply(ThisReply: String; ThisType: Smallint);
    procedure NonBelieverAsked;
    procedure IDontUnderstand;
    procedure ProcessNonBelieverEntry(ThisChar: Char);
    procedure AddNextCharacterFromPhase;


  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.Edit_InputKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
	var
	ThisInput: String;
begin
/// <remarks>
///   Special Keys
/// </remarks>
///
///
///




	ESCKeyPressed:= False;

	if (ssAlt in Shift) and ( ssCtrl in Shift ) and ( Key = 88 )  then begin
	{$REGION 'Ctrl + Alt +  X'}
			//Ctrl + Alt + X
			Panel_Config.Visible :=  not ( Panel_Config.Visible);
			if not ( Panel_Config.Visible) then NewQuestion(false);

			Exit;
		end;



{$ENDREGION}

	if (Key=VK_ESCAPE) then begin
{$REGION 'ESC Key'}

  		ESCKeyPressed:= True;

  		Inc(ESCKeyPressedCounter);

  		if ( ESCKeyPressedCounter>2) then begin
  				NonBeliever := true;
  			end;


		end else 		ESCKeyPressedCounter := 0; //No ESC pressed, reset counter

{$ENDREGION}


	if (Key=VK_RETURN) then begin
			CanAskAQuestion := false; //Replying
{$REGION 'ENTER Key'}
		if (Edit_Input.Text='') then exit;

		ESCKeyPressed:= True;

		if (TheAnswer.Length>0) and (QuestionCharWasPressed) then begin
			/// <remarks>
			///   Flag for another user
      ///   You can also hit 3 times ESC key
			/// </remarks>

			if (TheAnswer.ToLower.StartsWith('ss')) and not (NonBeliever) then begin
				ShowReply('I hope you believe',0);
				NonBeliever := true;
				NewQuestion(false);
				exit;
			end;

			if Not ( NonBeliever ) then begin
				ShowReply(TheAnswer,0);
				NewQuestion(false);
			end else begin
				/// <remarks>
				///   Random answer, count 3 answers and then quit
				/// </remarks>
					NonBelieverAsked;
					NewQuestion(false);
			end;

		end else begin

			/// <remarks>
			///   Wrong format
			/// </remarks>
			///
			///
			IDontUnderstand();

			end;

		end;


{$ENDREGION}

	BackSpaceWasPressed := (Key=VK_BACK);
end;

procedure TFrmMain.Edit_InputKeyPress(Sender: TObject; var Key: Char);
const
	CHARS = ['0'..'9', 'a'..'z', 'A'..'Z',' ','?', ',',':','-','ñ','Ñ','!','.'];

	var
		ThisKeyIsVisible: Boolean;
		ShowQueryText: Boolean;
		ThisFakeText: String;
		ThisRealText: String;

begin

	if not (CanAskAQuestion) then begin
		Key := #0;
		Exit;


  end;

	ThisFakeText := Label_Input.Caption;

	/// <remarks>
	///   Replace the first character when the app runs
	/// </remarks>
	Label_Input.Caption := ThisFakeText.Replace('_','');
	ThisFakeText := Label_Input.Caption;


	if (BackSpaceWasPressed) then begin
		if (ThisFakeText.Length>0) then ThisFakeText := ThisFakeText.Substring(0,ThisFakeText.Length-1 );
		Label_Input.Caption := ThisFakeText;
		if NOT (QuestionCharWasPressed) then begin
			TheAnswer := TheAnswer.Substring(0,TheAnswer.Length-1 );
		end;
		if (ThisFakeText.Length<=0) then QuestionCharWasPressed := false;
		Exit;
	end;

	if ( ESCKeyPressed ) then begin
		NewQuestion(false);
		Exit;
	end;



	if ( NonBeliever ) then begin
			ProcessNonBelieverEntry(Key);
			Exit;
	end;



	/// <remarks>
	///   Check for backspace
	/// </remarks>



	ThisKeyIsVisible:= (Key in CHARS)  or ( Key = SpecialCharacter ) ;

	if not ( ThisKeyIsVisible ) then exit;

	QuestionCharBeenPressed := (Key=SpecialCharacter );

	if  (QuestionCharBeenPressed) and not (QuestionCharWasPressed) then begin
		/// <remarks>
		///   First time press a comma
		/// </remarks>

		if ( ThisFakeText.Length<=0)  then begin
				Edit_Input.Text := '';
				exit;
		end;
		QuestionCharWasPressed := true;
		AddNextCharacterFromPhase();
		Exit;
	end;

	/// <remarks>
	///   If not comma preset, add the character to the answer
	/// </remarks>

	if not (QuestionCharWasPressed)  then 	TheAnswer := TheAnswer + Key;

	ThisRealText:= Edit_Input.Text;


	if ( ThisFakeText.Length<=SpecialPhase.Length ) and not ( QuestionCharWasPressed  )then
		AddNextCharacterFromPhase()
		else
		Label_Input.Caption := ThisFakeText + Key;



end;


procedure TFrmMain.AddNextCharacterFromPhase();
var
	ThisFakeText:String;
begin
ThisFakeText := Label_Input.Caption;
Label_Input.Caption := ThisFakeText + SpecialPhase.Substring(ThisFakeText.Length ,1);

end;


procedure TFrmMain.ProcessNonBelieverEntry(ThisChar:Char);
begin
Label_Input.Caption := Label_Input.Caption + ThisChar;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
Timer1.Enabled:= true;
end;


procedure TFrmMain.NonBelieverAsked();
begin

Inc(NonBelieverQuestions);
if (NonBelieverQuestions>3)  then begin
	ShowReply('retro !!',-1);
	Application.Terminate;
end else 		ShowReply('you dont believe',2);


end;

procedure TFrmMain.IDontUnderstand();

begin
	if ( NonBeliever )  then NonBelieverAsked else 		ShowReply('I dont understand',3);
	NewQuestion(false);
end;



function TFrmMain.NewQuestion(JustStarting:Boolean): Boolean;
var
	ThisResult: Boolean;
begin
ThisResult := true;

/// <remarks>
///   Initial values
/// </remarks>

if (JustStarting) then begin


NonBeliever:= False;
TextFader1.Lines.Clear;
ShowReply('ne iterum',0); //not again
Label_Input.Caption:='_';
CanAskAQuestion := false;
Closing := False;
end else Label_Input.Caption:='';


TheAnswer := '';
QuestionCharWasPressed:= false;
QuestionCharBeenPressed:= false;
ESCKeyPressed:= false;


Edit_Input.Text:='';
Edit_Input.SetFocus;

BackSpaceWasPressed := false;



SpecialPhase := 'Damian ' +  Edit_SpecialPhase.Text;
SpecialCharacter := ',';




result := ThisResult;
end;


procedure TFrmMain.ShowReply(ThisReply:String;ThisType:Smallint);

begin


/// <remarks>
///   exit text
/// </remarks>
	if (thisreply.ToLower.Trim.Equals('vale')) then begin
			TextFader1.Lines.Clear;
			TextFader1.Lines.Add('Vide te mox ');
			TextFader1.Active := true;
			Closing := True;
			Timer1.Interval := 2000; //2 seconds to close
			Timer1.Enabled := true;
			Exit;
	end;

/// <remarks>
///   Else just show the reply
/// </remarks>

TextFader1.Lines.Clear;
TextFader1.Lines.Add(ThisReply);
TextFader1.Lines.Add('');
TextFader1.Active := true;




	

end;






procedure TFrmMain.TextFader1Complete(Sender: TObject);
begin
CanAskAQuestion := true;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
Timer1.Enabled:=false;
if (Closing) then Close else begin

	if not (NewQuestion(True)) then close;

end;




end;

end.
