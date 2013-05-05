unit StatsObj ;

{$MODE Delphi}

interface

uses
   CFconsts, Bass, LCLIntf, LCLType ;

type
   TStats = class

      constructor Create ;
      destructor Destroy ; override ;

   private
      m_Score        : integer ;
      m_Level        : integer ;
      m_Fuel         : integer ;
      m_Life         : integer ;
      m_GameState    : TGameState ;
      m_StartOfLevel : integer ;
      m_ReStartPos   : integer ;
      m_Tunes        : integer ;
      m_Effects      : integer ;
      m_Completed    : boolean ;

      mods : array [0..128] of HMUSIC ;
      sams : array [0..128] of HSAMPLE ;

      procedure InitSound ;

   public
      procedure Reset ;
      procedure WonReset ;

      procedure IncrementLevel ;
      procedure IncrementScore (const theValue : integer) ;
      procedure IncrementFuel (const theValue : integer) ;
      procedure DecrementFuel ;
      procedure ResetFuel ;
      procedure SetLevel (const theLevel    : integer ;
                          const theLevelPos : integer) ;

      procedure DecrementLife ;
      procedure SetGameState (const theState : TGameState) ;

      procedure AddMusic (const theFile : string) ;
      procedure AddEffect (const theFile : string) ;

      procedure PlayTune (const theSoundID : integer) ;
      procedure PlayEffect (const theEffectID : integer) ;

      function GetStartPos : integer ;

     property GetScore : integer read m_Score ;
     property SetScore : integer write m_Score ;

     property GetLevel : integer read m_Level ;

     property GetStartLevel : integer read m_StartOfLevel ;

     property GetFuel : integer read m_Fuel ;
     property SetFuel : integer write m_Fuel ;

     property GetLife : integer read m_Life ;

     property GetGameState : TGameState read m_GameState ;

     property Completed : boolean read m_Completed ;
   end ;

implementation

constructor TStats.Create ;
begin
   inherited Create ;
   m_Tunes := 0 ;
   m_Effects := 0 ;
   m_ReStartPos := 250 ;

   InitSound ;
   Reset ;
end ;

destructor TStats.Destroy ;
var
   i : integer ;

begin
   BASS_Stop ;

   for i := 0 to m_Tunes - 1 do
   begin
      BASS_MusicFree (mods [i]) ;
   end ;

   for i := 0 to m_Effects - 1 do
   begin
      BASS_MusicFree (sams [i]) ;
   end ;

   BASS_Free ;

   inherited Destroy ;
end ;

procedure TStats.InitSound ;
begin
      if BASS_Init (-1, 44100, 0, 0, nil) then
      begin
         BASS_Start ;
      end ;
end ;

procedure TStats.Reset ;
begin
   m_Completed := false ;
   m_Score := 0 ;
   m_Level := 0 ;
   m_StartOfLevel := 0 ;
   m_Life  := kMaxLives ;
   m_Fuel  := kMaxFuel ;
   m_GameState := gsWaiting ;
end ;

procedure TStats.WonReset ;
begin
   m_Level := 0 ;
   m_StartOfLevel := 0 ;
   m_Fuel  := kMaxFuel ;
   m_GameState := gsWaiting ;
   m_Completed := true ;
end ;

procedure TStats.IncrementLevel ;
begin
   inc (m_Level) ;
end ;

procedure TStats.IncrementScore (const theValue : integer) ;
begin
   inc (m_Score, theValue) ;
   if m_Score > 999999 then m_Score := 999999 ;
end ;

procedure TStats.IncrementFuel (const theValue : integer) ;
begin
   inc (m_Fuel, theValue) ;
   if kMaxFuel < m_Fuel then
   begin
      m_Fuel := kMaxFuel ;
   end ;
end ;

procedure TStats.DecrementFuel ;
begin
   dec (m_Fuel) ;
   if kMinFuel > m_Fuel then
   begin
      SetFuel := kMinFuel ;
   end ;
end ;

procedure TStats.ResetFuel ;
begin
   SetFuel := kMaxFuel ;
end ;

procedure TStats.DecrementLife ;
begin
   dec (m_Life) ;
   m_GameState := gsLostLife ;
end ;

procedure TStats.SetLevel (const theLevel    : integer ;
                           const theLevelPos : integer) ;
begin
   if (theLevel <> m_Level) and (0 <> theLevelPos) then
   begin
      m_Level := theLevel ;
      m_StartOfLevel := theLevelPos - 20 ;
   end ;
end ;

function TStats.GetStartPos : integer ;
begin
   case GetLevel of
      0 : result := 250 ;
      1 : result := 184 ;
      2 : result := 272 ;
      3 : result := 360 ;
      4 : result := 144 ;
      5 : result := 256 ;
   else
      result := 250 ;
   end ;
end ;

procedure TStats.AddMusic (const theFile : string) ;
begin
   mods [m_Tunes] := BASS_MusicLoad (FALSE, PChar (theFile), 0, 0, BASS_MUSIC_RAMP or BASS_MUSIC_LOOP, 0) ;
   inc (m_Tunes) ;
end ;

procedure TStats.AddEffect (const theFile : string) ;
begin
   sams [m_Effects] := BASS_SampleLoad (FALSE, PChar (theFile), 0, 0, 5, BASS_SAMPLE_OVER_POS) ;
   inc (m_Effects) ;
end ;

procedure TStats.PlayTune (const theSoundID : integer) ;
begin
   BASS_ChannelPlay (mods [theSoundID], TRUE) ;
end ;

procedure TStats.PlayEffect (const theEffectID : integer) ;
var
  channel : HCHANNEL;
begin
   channel := BASS_SampleGetChannel(sams [theEffectID], FALSE);
   BASS_ChannelPlay (channel, FALSE) ;
end ;

procedure TStats.SetGameState (const theState : TGameState) ;
begin
   if 0 > m_Life then
   begin
      m_GameState := gsExit ;
   end
   else
   begin
      m_GameState := theState ;
   end ;
end ;

end.
