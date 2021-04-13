unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SkinData, DynamicSkinForm,
  Vcl.StdCtrls, TextFade, Vcl.Mask, SkinBoxCtrls, SkinCtrls, bsSkinBoxCtrls,
  Vcl.ExtCtrls, bsSkinCtrls, varcodedxe81;

type
  TFrmMain = class(TForm)
    spCompressedSkinList1: TspCompressedSkinList;
    spSkinData1: TspSkinData;
    spDynamicSkinForm1: TspDynamicSkinForm;
    Edit_Input: TEdit;
    TextFader1: TTextFader;
    Panel_Input: TPanel;
    Label_Input: TLabel;
    Timer1: TTimer;
    VarCoded: TVarCodedxe81;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Edit_InputKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit_InputKeyPress(Sender: TObject; var Key: Char);
    procedure TextFader1Complete(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
		{ Private declarations }
		QuestionCharWasPressed: Boolean;
		QuestionCharBeenPressed: Boolean;
		FirstSpecialChar:Boolean;

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

		NonBelieverReplies: TStringList;
		RepliesToBeliever: TStringList;

		//new procedure
		SumminingQuestion: Boolean;
		TypingTheQuestion: Boolean;



    function NewQuestion(JustStarting: Boolean): Boolean;
    procedure ShowReply(ThisReply: String; ThisType: Smallint);
    procedure NonBelieverAsked;
    procedure IDontUnderstand;
    procedure ProcessNonBelieverEntry(ThisChar: Char);
    procedure AddNextCharacterFromPhase;
    procedure ShowSettings;
    function BeginSession: Boolean;
    procedure EndProgram;


  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses SettingsUnit;

{$REGION 'Encrypt/Decrypt'}
  
  
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
    Result:= UTF8Decode(RStr);
  end;
  
  
{$ENDREGION}

procedure TFrmMain.ShowSettings();
var
	FrmSettings: TFrmSettings;
begin


	FrmSettings:= TFrmSettings.Create(FrmMain);
	FrmSettings.Edit1.Text := SpecialPhase.Replace('Damian ','');
	FrmSettings.ShowModal;
	SpecialPhase := 'Damian ' + FrmSettings.Edit1.Text;
	varcoded.WriteINI('System','ID',EncryptStr(SpecialPhase,1972));


end;


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

			ShowSettings();
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


	/// <remarks>
	///   Check for backspace
	/// </remarks>


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


	ThisKeyIsVisible:= (Key in CHARS)  or ( Key = SpecialCharacter ) ;
	if not ( ThisKeyIsVisible ) then exit;


	QuestionCharBeenPressed := (Key=SpecialCharacter );
	ThisRealText:= Edit_Input.Text;


	if (ThisRealText.Length=0) then begin //First char

		if (QuestionCharBeenPressed)  then begin
				FirstSpecialChar:=true;
				NonBeliever:=false;
				NonBelieverQuestions := 0;
				Exit;
		end else begin
					NonBeliever:=true;
    end;

	end;



	if ( NonBeliever ) then begin
			ProcessNonBelieverEntry(Key);
			Exit;
	end;





	if  (QuestionCharBeenPressed) and not (QuestionCharWasPressed) and (FirstSpecialChar) then begin
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

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
FreeAndNil(NonBelieverReplies);
FreeAndNil(RepliesToBeliever);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
Timer1.Enabled:= true;
end;


procedure TFrmMain.NonBelieverAsked();
begin

Inc(NonBelieverQuestions);
if (NonBelieverQuestions>3)  then begin
	ShowReply('vale',-1);
	Exit;

end else 		ShowReply(NonBelieverReplies[NonBelieverQuestions-1] ,2);


end;

procedure TFrmMain.IDontUnderstand();

begin
	if ( NonBeliever )  then NonBelieverAsked else 		ShowReply('I dont understand',3);
	NewQuestion(false);
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
		ShowMessage('This instalation is not valid, try reinstalling this app' );
		exit ( false );
end;


if NOT ( varcoded.SetupLog() ) then
begin
		ShowMessage('Can not create LOG file, try reinstalling this app' );
		exit ( false );
end;



NonBeliever:= False;
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









//arce scripturam






ShowReply('ne iterum',0); //not again


SpecialPhase := DecryptStr (Varcoded.ReadINI('System','ID',''),1972);

if SpecialPhase.Length<6 then SpecialPhase := 'Damian paulo diaboli audite me';


//SpecialPhase := 'Damian ' +  Edit_SpecialPhase.Text;
SpecialCharacter := ',';

NewQuestion(false);






result := ThisResult;
end;


function TFrmMain.NewQuestion(JustStarting:Boolean): Boolean;
var
	ThisResult: Boolean;
begin
ThisResult := true;

if (JustStarting) then begin

ThisResult := BeginSession;

exit (ThisResult);
end;


/// <remarks>
///   Initial values
/// </remarks>




Label_Input.Caption:='_';
TheAnswer := '';
QuestionCharWasPressed:= false;
QuestionCharBeenPressed:= false;
ESCKeyPressed:= false;
FirstSpecialChar:=false;


Edit_Input.Text:='';
Edit_Input.SetFocus;

BackSpaceWasPressed := false;


SumminingQuestion:=false;
TypingTheQuestion:=false;




result := ThisResult;
end;


procedure TFrmMain.EndProgram();
begin

		TextFader1.Lines.Clear;

		if (NonBeliever) then
		TextFader1.Lines.Add('qui increduli')
		else
		TextFader1.Lines.Add('Vide te mox');

		TextFader1.Active := true;
		Closing := True;
		Timer1.Interval := 2000; //2 seconds to close
		Timer1.Enabled := true;




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
