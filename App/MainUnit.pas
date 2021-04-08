unit MainUnit;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, bsSkinCtrls, Vcl.StdCtrls,
	Vcl.Mask, bsSkinBoxCtrls, Vcl.ExtCtrls, varcodedxe81,
  TextFade;

type
	TFrmMain = class(TForm)
		Panel_Bottom: TbsSkinPanel;
		Label_Input: TbsSkinStdLabel;
		Edit_Input: TbsSkinEdit;
    Timer1: TTimer;
    VarCodedxe811: TVarCodedxe81;
    Panel_Config: TbsSkinExPanel;
    Panel_Preferences_Top: TbsSkinPanel;
    bsSkinStdLabel1: TbsSkinStdLabel;
    Edit_SpecialPhase: TbsSkinEdit;
    TextFader1: TTextFader;
		procedure Edit_InputKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure Edit_InputKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure Panel_ConfigClose(Sender: TObject);
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

		function BeginSession: Boolean;
		procedure NewQuestion();
		procedure IDontUnderstand();
		procedure NonBelieverAsked();
    procedure ProcessNonBelieverEntry(ThisChar: Char);
    procedure ShowReply(ThisReply: String; ThisType: Smallint);
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
			Panel_Config.Visible := true;
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
				NewQuestion;
				exit;
			end;

			if Not ( NonBeliever ) then begin
				ShowReply(TheAnswer,0);
				NewQuestion();
			end else begin
				/// <remarks>
				///   Random answer, count 3 answers and then quit
				/// </remarks>
					NonBelieverAsked;
					NewQuestion;
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



procedure TFrmMain.ShowReply(ThisReply:String;ThisType:Smallint);

begin

TextFader1.Lines.Clear;
TextFader1.Lines.Add(ThisReply);
TextFader1.Lines.Add('');
TextFader1.Active := true;

end;

procedure TFrmMain.Panel_ConfigClose(Sender: TObject);
begin
SpecialPhase := 'Damian ' +  Edit_SpecialPhase.Text;
NewQuestion;
end;

procedure TFrmMain.ProcessNonBelieverEntry(ThisChar:Char);
begin
Label_Input.Caption := Label_Input.Caption + ThisChar;

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
		NewQuestion;
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



procedure TFrmMain.FormCreate(Sender: TObject);
begin
Timer1.Enabled:= true;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
Timer1.Enabled:=false;
BeginSession();

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
	NewQuestion();
end;

function TFrmMain.BeginSession(): Boolean;
var
  ThisResult: Boolean;
begin
ThisResult := false;

/// <remarks>
///   Initial values
/// </remarks>


NonBeliever:= False;
TextFader1.Lines.Clear;
ShowReply('ne iterum',0); //not again
NewQuestion;



result := ThisResult;
end;


procedure TFrmMain.NewQuestion();

begin
TheAnswer := '';
QuestionCharWasPressed:= false;
QuestionCharBeenPressed:= false;
ESCKeyPressed:= false;


Edit_Input.Text:='';
Edit_Input.SetFocus;

BackSpaceWasPressed := false;

Label_Input.Caption:='';

SpecialPhase := 'Damian ' +  Edit_SpecialPhase.Text;
SpecialCharacter := ',';


end;

end.
