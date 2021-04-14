unit MainUnit;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SkinData, DynamicSkinForm,
	Vcl.StdCtrls, TextFade, Vcl.Mask, SkinBoxCtrls, SkinCtrls, bsSkinBoxCtrls,

	DamianInputUnit,
	System.StrUtils,

	Vcl.ExtCtrls, bsSkinCtrls, varcodedxe81, JvExControls, JvInspector;

type
  TFrmMain = class(TForm)
    spCompressedSkinList1: TspCompressedSkinList;
    spSkinData1: TspSkinData;
    spDynamicSkinForm1: TspDynamicSkinForm;
    Edit_Input: TEdit;
    TextFader1: TTextFader;
    Panel_Input: TPanel;
    Label_Input: TLabel;
		VarCoded: TVarCodedxe81;
		Timer_StartUp: TTimer;
    Timer_Cursor: TTimer;
    Timer_Close: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer_StartUpTimer(Sender: TObject);
    procedure Edit_InputKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_InputKeyPress(Sender: TObject; var Key: Char);
    procedure TextFader1Complete(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer_CursorTimer(Sender: TObject);
    procedure Timer_CloseTimer(Sender: TObject);
	private
		{ Private declarations }


		NonBelieverReplies: TStringList;
		RepliesToBeliever: TStringList;

		NonBelieverIsTakingControl: Boolean;

		SpecialPhase:String;
		SpecialCharacter: Char;


		TheAnswer: String;
		FastQuit:Boolean;

		CanAskAQuestion: Boolean;

		ThisInput: TDamianInput;
		ThisFakeTextVisual: String;





		procedure NewQuestion();
		/// <remarks>
		///   ThisType parameter is to define the type
		///  of reply, maybe change color or add special effects
		/// </remarks>
		procedure ShowReply(ThisReply: String; ThisType: Smallint);
		procedure NonBelieverAsked;
    procedure ProcessKeyAsNormal(ThisChar: Char);
    procedure AddNextCharacterFromPhase;
    procedure ShowSettings;
    function BeginSession: Boolean;
    procedure EndProgram;
    procedure ProcessENTER;
    procedure ProcessESC;
    procedure ProcessBackSpace;
    function  ProcessNewChar(ThisChar: Char): Char;
		procedure ProcessFirstSpecialChar;
    procedure DisplayFakeText(ThisString: String);


  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses SettingsUnit;

{$REGION 'Encrypt/Decrypt for the special phase stored in the INI'}
  
  
	const CKEY1 = 1990;
        CKEY2 = 2018;
  
  function EncryptStr(const S :WideString; Key: Word): String;
  var   i          :Integer;
        RStr       :RawByteString;
        RStrB      :TBytes Absolute RStr;
  begin
    Result:= '';
    RStr:= UTF8Encode(S);
    for i := 0 to Length(RStr)-1 do begin
      RStrB[i] := RStrB[i] xor (Key shr 8);
      Key := (RStrB[i] + Key) * CKEY1 + CKEY2;
    end;
    for i := 0 to Length(RStr)-1 do begin
      Result:= Result + IntToHex(RStrB[i], 2);
    end;
  end;
  
  function DecryptStr(const S: String; Key: Word): String;
  var   i, tmpKey  :Integer;
        RStr       :RawByteString;
        RStrB      :TBytes Absolute RStr;
        tmpStr     :string;
  begin
    tmpStr:= UpperCase(S);
    SetLength(RStr, Length(tmpStr) div 2);
    i:= 1;
    try
      while (i < Length(tmpStr)) do begin
        RStrB[i div 2]:= StrToInt('$' + tmpStr[i] + tmpStr[i+1]);
        Inc(i, 2);
      end;
    except
      Result:= '';
      Exit;
    end;
    for i := 0 to Length(RStr)-1 do begin
      tmpKey:= RStrB[i];
      RStrB[i] := RStrB[i] xor (Key shr 8);
      Key := (tmpKey + Key) * CKEY1 + CKEY2;
    end;
//    Result:= UTF8Decode(RStr);
		Result:= UTF8ToWideString(RStr);
  end;
  
  
{$ENDREGION}

procedure TFrmMain.ShowSettings();
var
	FrmSettings: TFrmSettings;
begin

	FrmSettings:= TFrmSettings.Create(FrmMain);
	FrmSettings.Edit_SpecialPhase.Text := SpecialPhase.Replace('Damian ','');
	FrmSettings.ShowModal;
	SpecialPhase := 'Damian ' + FrmSettings.Edit_SpecialPhase.Text;
	/// <remarks>
  ///   Save the special phase encrypted
  /// </remarks>
	varcoded.WriteINI('System','ID',EncryptStr(SpecialPhase,1972));


end;


procedure TFrmMain.Edit_InputKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);

begin
/// <remarks>
///   Special Keys and flags
/// </remarks>
///

	ThisInput.ESCKeyPressed:= False;
	ThisInput.BackSpaceWasPressed := False;

	if (ssAlt in Shift) and ( ssCtrl in Shift ) and ( Key = 88 )  then begin
	{$REGION 'Ctrl + Alt +  X'}
			//Ctrl + Alt + X
			ShowSettings();
			Exit;
		end;

{$ENDREGION}

	if (Key=VK_ESCAPE) then ProcessESC() else ThisInput.ESCKeyPressedCounter:=0;
	if (Key=VK_RETURN) then ProcessENTER();
	if (Key=VK_BACK) then ThisInput.BackSpaceWasPressed := True;



end;





procedure TFrmMain.ProcessESC();
begin

		/// <remarks>
	///   If you hit ESC key 2 times, the nonbeliever flag is activated
	/// </remarks>

			ThisInput.ESCKeyPressed:= True;
			ThisInput.ESCKeyPressedCounter := ThisInput.ESCKeyPressedCounter + 1;
			if ( ThisInput.ESCKeyPressedCounter=2) then
				NonBelieverIsTakingControl := true
			else begin
				if (ThisInput.ESCKeyPressedCounter>3)  then begin
					FastQuit := True;
          EndProgram();
  			end;

			end;
End;




procedure TFrmMain.ProcessENTER();
begin
	//new question for now

	if (ThisInput.NonBeliever) or (NonBelieverIsTakingControl) then begin
		NonBelieverAsked;
		Exit;
	end;

	if (ThisInput.AnswerReady ) and (TheAnswer.ToLower.Equals('vale')) then begin
		EndProgram();
		Exit;


  end;

	if (ThisInput.AnswerReady ) and (ThisInput.TypingTheAnswer) then begin
		ThisInput.TypingTheAnswer := false;
		ThisInput.TypingTheQuestion := true;
		Label_Input.Caption := '';
		Edit_Input.Text := '';
		ThisFakeTextVisual := '';
		Exit;
	end;

	if (ThisInput.AnswerReady ) and ( ThisInput.TypingTheQuestion) then begin
		ShowReply(TheAnswer.Trim,0);
		NewQuestion();
		Exit;
	end;


end;



procedure TFrmMain.ProcessBackSpace();
var
	ThisFakeText: String;
begin
	ThisFakeText := Label_Input.Caption;


	if (ThisFakeText.Length>0) then begin
		ThisFakeText := ThisFakeText.Substring(0,ThisFakeText.Length-1 );
		if (ThisInput.TypingTheAnswer) and not (ThisInput.AnswerReady) then begin
			TheAnswer := TheAnswer.Substring(0,TheAnswer.Length-1 );
			ThisFakeTextVisual := TheAnswer;
		end;
		DisplayFakeText(ThisFakeText);

	end;


end;


procedure TFrmMain.ProcessFirstSpecialChar();
begin

	ThisInput.FirstSpecialChar:=true;
	ThisInput.NonBeliever:=false;
	ThisInput.NonBelieverQuestions := 0;
	NonBelieverIsTakingControl := False;
	ThisInput.TypingTheAnswer := true;
	ThisFakeTextVisual := '';
	AddNextCharacterFromPhase();

end;

function TFrmMain.ProcessNewChar(ThisChar:Char): Char;
const
	CHARS = ['0'..'9', 'a'..'z', 'A'..'Z',' ','?', ',',':','-','ñ','Ñ','!','.'];

var
	ThisKeyIsVisible: Boolean;
	ThisFakeText: String;
	ThisResult: Char;
begin
ThisResult := ThisChar;

/// <remarks>
///   Exit(#0) means cancel the character
/// </remarks>

	if not (CanAskAQuestion) then Exit(#0);
	if (FastQuit) 					 then Exit(#0);
	if  ( ThisInput.ESCKeyPressed ) then begin
			NewQuestion();
			Exit(#0);
	end;


	/// <remarks>
	///   Replace the _ character when the user types
	///  This is to simulate the cursor and the user knows where to type
	/// </remarks>
	ThisFakeText := Label_Input.Caption;
	Label_Input.Caption := ThisFakeText.Replace('_','');
	ThisFakeText := Label_Input.Caption;


	/// <remarks>
	///   Check for backspace
	/// </remarks>
	if (ThisInput.BackSpaceWasPressed) then begin
		ProcessBackSpace();
		Exit(ThisChar);
	end;

	ThisKeyIsVisible:= CharInSet( ThisChar,CHARS) or ( ThisChar = SpecialCharacter ) ;     // (ThisChar In CHARS)  or ( ThisChar = SpecialCharacter ) ;
	/// <remarks>
	///   Only CHARS are allowed
	/// </remarks>

	if not ( ThisKeyIsVisible ) then exit(#0);

	if  (NonBelieverIsTakingControl) then begin
			ProcessKeyAsNormal(ThisChar);
			Exit(ThisChar);
	end;


	ThisInput.QuestionCharBeenPressed := (ThisChar=SpecialCharacter );


	if (ThisFakeText.Length=0) then begin //First char
{$REGION 'First char'}
				if (ThisInput.QuestionCharBeenPressed)  then begin
						ProcessFirstSpecialChar();
						Exit(#0);
				end;

				if (ThisInput.TypingTheQuestion) then begin
					ProcessKeyAsNormal(ThisChar);
					Exit(ThisChar);
				end;

				ThisInput.NonBeliever:=true;
				ProcessKeyAsNormal(ThisChar);
				Exit(ThisChar);

		end;

{$ENDREGION}

	if ( ThisInput.NonBeliever ) then begin
			ProcessKeyAsNormal(ThisChar);
			Exit(ThisChar);
	end;



	if ((ThisInput.AnswerReady) and (ThisInput.TypingTheAnswer)) or ( ThisInput.TypingTheQuestion ) then begin
			ProcessKeyAsNormal(ThisChar);
			Exit(ThisChar);
	end;




	/// <remarks>
	///   If not comma preset, add the character to the answer
	/// </remarks>


	if (ThisInput.QuestionCharBeenPressed) and (ThisInput.TypingTheAnswer) then begin
			//Second time the speciah char is pressed
			TheAnswer := ' '+ TheAnswer;
			AddNextCharacterFromPhase();

			ThisInput.AnswerReady := True;
			Exit(#0);
	end;

	if (ThisInput.TypingTheAnswer) then begin
		if (ThisFakeText.Length< SpecialPhase.Length) then begin
			TheAnswer := TheAnswer + ThisChar;
			AddNextCharacterFromPhase();
			Exit(ThisChar);

		end;




	end;


result := ThisResult;
end;


procedure TFrmMain.Edit_InputKeyPress(Sender: TObject; var Key: Char);

begin

	Key := ProcessNewChar(Key);

end;


procedure TFrmMain.AddNextCharacterFromPhase();
var
	ThisFakeText:String;
begin
ThisFakeText := Label_Input.Caption;
ThisFakeTextVisual := TheAnswer;
ThisFakeText := ThisFakeText + SpecialPhase.Substring(ThisFakeTextVisual.Length ,1);

//ThisFakeText := ThisFakeTextVisual;
Label_Input.Caption := ThisFakeText;

end;


procedure TFrmMain.ProcessKeyAsNormal(ThisChar:Char);
begin
ThisFakeTextVisual := ThisFakeTextVisual + ThisChar;
DisplayFakeText(Label_Input.Caption + ThisChar);

end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
FreeAndNil(NonBelieverReplies);
FreeAndNil(RepliesToBeliever);
FreeAndNil(ThisInput);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
Timer_StartUp.Enabled:= true;
end;


procedure TFrmMain.NonBelieverAsked();
begin

ThisInput.NonBelieverQuestions := ThisInput.NonBelieverQuestions + 1;

if (ThisInput.NonBelieverQuestions>3)  then begin
	ShowReply('vale',-1);
	Exit;
end else begin
	ShowReply(NonBelieverReplies[ThisInput.NonBelieverQuestions-1] ,2);
	NewQuestion();
end;


end;


procedure TFrmMain.DisplayFakeText(ThisString:String);
var
	FinalText: String;
begin
/// <remarks>
///   Limit of 25 characteres
/// </remarks>

	FinalText := ThisString;

	if (ThisString.Length>=31) then FinalText := RightStr(ThisString,30);
	Label_Input.Caption := FinalText;


end;

function TFrmMain.BeginSession(): Boolean;
var
	ThisResult: Boolean;

begin
ThisResult := True;



/// <remarks>
///   First time setup
/// </remarks>
///
///



varcoded.SetCreator('Zaphod (See "About" for contact)');


if NOT ( varcoded.IsValidInstallation() ) then
begin
		ShowMessage('This installation is not valid, try reinstalling this app' );
		exit ( false );
end;

/// <remarks>
///   log disable for production
/// </remarks>

(*
if NOT ( varcoded.SetupLog() ) then
begin
		ShowMessage('Can not create LOG file, try reinstalling this app' );
		exit ( false );
end;

			 *)
ThisInput := TDamianInput.Create;

ThisInput.NonBeliever:= False;
FastQuit := False;
NonBelieverIsTakingControl := false;

TextFader1.Lines.Clear;




NonBelieverReplies:= TStringList.Create;
NonBelieverReplies.Add('qui es, et quid vis '); //who are you and what do you want
NonBelieverReplies.Add('Sunt enim multae cogitationes in corde '); //you have to many doubts in your min
NonBelieverReplies.Add('responsum est modo scientia'); // only science have answers


RepliesToBeliever := TStringList.Create;

RepliesToBeliever.Add('ego audiam vos'); //I'm listen to you
RepliesToBeliever.Add('Ita mihi'); //yes, tell me
RepliesToBeliever.Add('Ita?'); //yes?
RepliesToBeliever.Add('tibi operam meam'); //all my atention to you

RepliesToBeliever.Add('arce scripturam'); //continue writing
RepliesToBeliever.Add('Ego damian '); //I am damian
RepliesToBeliever.Add('aut daemonium artificialis intelligentia'); //AI or a demon
RepliesToBeliever.Add('lingua est binarii '); //binary is the language



SpecialPhase := DecryptStr (Varcoded.ReadINI('System','ID',''),1972);

if SpecialPhase.Length<6 then SpecialPhase := 'Damian paulo diaboli audite me';

SpecialCharacter := ',';
ShowReply('ne iterum',0); //not again
NewQuestion();






result := ThisResult;
end;


procedure TFrmMain.NewQuestion();

begin
/// <remarks>
///   Initial values
/// </remarks>

Label_Input.Caption:='_';
TheAnswer := '';
ThisInput.NewQuestion();

Edit_Input.Text:='';
Edit_Input.SetFocus;

Timer_Cursor.Enabled := true;
CanAskAQuestion:= true;

ThisFakeTextVisual:= '';


end;


procedure TFrmMain.EndProgram();
begin

		if (FastQuit) then begin
			Close;
			Exit;
    end;

		TextFader1.Lines.Clear;
		TextFader1.LineDelay := 500;

		if (ThisInput.NonBeliever) or (NonBelieverIsTakingControl) then
		TextFader1.Lines.Add('qui increduli')
		else
		TextFader1.Lines.Add('Vide te mox');

		TextFader1.Active := true;
		Timer_Close.Enabled := true;



end;

procedure TFrmMain.ShowReply(ThisReply:String;ThisType:Smallint);

begin


/// <remarks>
///   exit text
/// </remarks>
	if (thisreply.ToLower.Trim.Equals('vale')) then begin
		EndProgram();
		Exit;
	end;

/// <remarks>
///   Else just show the reply
/// </remarks>

TextFader1.Lines.Clear;
TextFader1.Lines.Add(ThisReply);
TextFader1.Lines.Add('');
//calculate time how long the reply is

case ThisReply.Length of
	0..25  : TextFader1.LineDelay := 1000;
	26..50 : TextFader1.LineDelay := 2000;
	51..100: TextFader1.LineDelay := 3000;
	101..200: TextFader1.LineDelay := 4000;
	else TextFader1.LineDelay := 5000;


end;


TextFader1.Active := true;


	

end;






procedure TFrmMain.TextFader1Complete(Sender: TObject);
begin
CanAskAQuestion := true;
end;

procedure TFrmMain.Timer_StartUpTimer(Sender: TObject);
begin
Timer_StartUp.Enabled:=false;
if not (BeginSession()) then close;



end;

procedure TFrmMain.Timer_CloseTimer(Sender: TObject);
begin
	Timer_Close.Enabled := false;
	Close;


end;

procedure TFrmMain.Timer_CursorTimer(Sender: TObject);
var
	ThisFakeText: String;
begin
Timer_Cursor.Enabled := false;
ThisFakeText := Label_Input.Caption;
if NOT (ThisFakeText.EndsWith('_')) then ThisFakeText := ThisFakeText + '_';
DisplayFakeText(ThisFakeText);
//**Label_Input.Caption := ThisFakeText;
Timer_Cursor.Enabled := true;


end;

end.
