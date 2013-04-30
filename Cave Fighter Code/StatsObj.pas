unit StatsObj ;
interface
  {$define BASS}
uses
   CFconsts,
{$IFDEF BASS}
   windows,
   bass,
{$ELSE}
   sdl_mixer,
{$ENDIF}
   sdl ;

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
{$IFDEF BASS}
     mods : array [0..10] of HMUSIC ;
     sams : array [0..10] of HSAMPLE ;
{$ELSE}
     mods : array [0..10] of PMix_Music ;
     sams : array [0..20] of PMix_Chunk ;
{$ENDIF}

      procedure InitSound ;

   public
      procedure Reset ;
      procedure IncrementLevel ;
      procedure IncrementScore (const theValue : integer) ;
      procedure IncrementFuel (const theValue : integer) ;
      procedure DecrementFuel ;
      procedure ResetFuel ;
      procedure SetLevel (const theLevel    : integer ;
                          const theLevelPos : integer ;
                          const theSprRec   : pSpriteData) ;

      procedure DecrementLife ;
      procedure SetGameState (const theState : TGameState) ;

      procedure AddMusic (const theFile : string) ;
      procedure AddEffect (const theFile : string) ;

      procedure PlayTune (const theSoundID : integer) ;
      procedure PlayEffect (const theEffectID : integer) ;

      function GetStartPos : integer ;
   {Property section}
      property GetScore : integer read m_Score ;
      property SetScore : integer write m_Score ;

      property GetLevel : integer read m_Level ;

      property GetStartLevel : integer read m_StartOfLevel ;

      property GetFuel : integer read m_Fuel ;
      property SetFuel : integer write m_Fuel ;

      property GetLife : integer read m_Life ;

      property GetGameState : TGameState read m_GameState ;
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
{$IFDEF BASS}
   BASS_Stop ;
{$ENDIF}
   for i := 0 to m_Tunes - 1 do
   begin
{$IFDEF BASS}
      BASS_MusicFree (mods [i]) ;
{$ELSE}
      Mix_FreeMusic (mods [i]) ;
{$ENDIF}
   end ;

   for i := 0 to m_Effects - 1 do
   begin
{$IFDEF BASS}
      BASS_MusicFree (sams [i]) ;
{$ELSE}
      Mix_FreeChunk (sams [i]) ;
{$ENDIF}
   end ;

{$IFDEF BASS}
   BASS_Free ;
{$ELSE}
   Mix_CloseAudio ;
{$ENDIF}
   inherited Destroy ;
end ;

procedure TStats.InitSound ;
begin
{$IFDEF BASS}
   if BASS_GetVersion = MAKELONG (1,5) then
   begin
      if BASS_Init (-1, 44100, 0, 0) then
      begin
         BASS_Start ;
      end ;
   end ;
{$ELSE}
   SDL_Init (SDL_INIT_AUDIO) ;
   Mix_OpenAudio (22050, AUDIO_S16LSB, 2, 1024) ;
   Mix_VolumeMusic (128) ;
{$ENDIF}
end ;

procedure TStats.Reset ;
begin
   m_Score := 0 ;
   m_Level := 0 ;
   m_StartOfLevel := 0 ;
   m_Life  := kMaxLives ;
   m_Fuel  := kMaxFuel ;
   m_GameState := gsWaiting ;
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
                           const theLevelPos : integer ;
                           const theSprRec   : pSpriteData) ;
begin
   if (theLevel <> m_Level) and (0 <> theLevelPos) then
   begin
      m_Level := theLevel ;
      m_StartOfLevel := theLevelPos - 20 ;
   end ;
end ;

function TStats.GetStartPos : integer ;
begin
   {strating pos in the Y diection for each level}
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
{$IFDEF BASS}
   mods [m_Tunes] := BASS_MusicLoad (FALSE, PChar (theFile), 0, 0, BASS_MUSIC_RAMP or BASS_MUSIC_LOOP) ;
{$ELSE}
   mods [m_Tunes] := Mix_LoadMUS (PChar (theFile)) ;
{$ENDIF}
   inc (m_Tunes) ;
end ;

procedure TStats.AddEffect (const theFile : string) ;
begin
{$IFDEF BASS}
   sams [m_Effects] := BASS_SampleLoad (FALSE, PChar (theFile), 0, 0, 5, BASS_SAMPLE_OVER_POS) ;
{$ELSE}
   sams [m_Effects] := mix_loadwav (PChar(theFile)) ;
   {FXs are too loud when using SDL_Mixer so adjust the volume}
   Mix_VolumeChunk (sams [m_Effects], 64) ;
{$ENDIF}
   inc (m_Effects) ;
end ;

procedure TStats.PlayTune (const theSoundID : integer) ;
begin
{$IFDEF BASS}
   BASS_MusicPlayEx (mods [theSoundID], 0, -1, TRUE) ;
{$ELSE}
   Mix_PlayMusic (mods [theSoundID], -1) ;
{$ENDIF}
end ;

procedure TStats.PlayEffect (const theEffectID : integer) ;
begin
{$IFDEF BASS}
   BASS_SamplePlayEx (sams [theEffectID], 0, -1, 50, 0, FALSE) ;
{$ELSE}
   Mix_PlayChannel (-1, sams [theEffectID], 0) ;
{$ENDIF}
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
