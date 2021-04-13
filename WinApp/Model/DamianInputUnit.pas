unit DamianInputUnit;


interface

type
	TDamianInput = Class
	private
		fQuestionCharWasPressed		: Boolean;
		fQuestionCharBeenPressed	: Boolean;
		fFirstSpecialChar					: Boolean;

		fNonBeliever							: Boolean;
		fNonBelieverQuestions			: Smallint;

		fBackSpaceWasPressed			: Boolean;
		fESCKeyPressed						: Boolean;
		fESCKeyPressedCounter			: SmallInt;
		fCanAskAQuestion					: Boolean;

		fTypingTheAnswer					: Boolean;
		fTypingTheQuestion				: Boolean;

		fAnswerReady   						: Boolean;

		procedure SetDefaultValues;

	public
		constructor Create;
		procedure NewQuestion;
	published
		property QuestionCharWasPressed   : Boolean  read fQuestionCharWasPressed		write fQuestionCharWasPressed;
		property QuestionCharBeenPressed  : Boolean  read fQuestionCharBeenPressed	write fQuestionCharBeenPressed;
		property FirstSpecialChar         : Boolean  read fFirstSpecialChar         write fFirstSpecialChar;
		property NonBeliever              : Boolean  read fNonBeliever  				  	write fNonBeliever;
		property NonBelieverQuestions     : Smallint read fNonBelieverQuestions	  	write fNonBelieverQuestions;

		property BackSpaceWasPressed      : Boolean  read fBackSpaceWasPressed			write fBackSpaceWasPressed;
		property ESCKeyPressed						: Boolean	 read fESCKeyPressed						write fESCKeyPressed;
		property ESCKeyPressedCounter     : SmallInt read fESCKeyPressedCounter			write fESCKeyPressedCounter;

		property TypingTheAnswer          : Boolean  read fTypingTheAnswer					write fTypingTheAnswer;
		property TypingTheQuestion				: Boolean	 read fTypingTheQuestion				write fTypingTheQuestion;

		property AnswerReady						  : Boolean  read fAnswerReady					  	write fAnswerReady;

end;

implementation

constructor TDamianInput.Create();
begin
	SetDefaultValues();
end;

procedure TDamianInput.NewQuestion();
begin
	fQuestionCharWasPressed		:= false;
	fQuestionCharBeenPressed	:= false;
	fFirstSpecialChar					:= false;
	fBackSpaceWasPressed			:= false;

	fESCKeyPressed						:= false;

	fTypingTheAnswer					:= false;
	fTypingTheQuestion				:= false;

	fAnswerReady						:= false;



end;

procedure TDamianInput.SetDefaultValues();
begin

fNonBeliever							:= false;
fNonBelieverQuestions			:= 0;


fESCKeyPressedCounter			:= 0;
fCanAskAQuestion					:= true;

NewQuestion();

end;

end.
