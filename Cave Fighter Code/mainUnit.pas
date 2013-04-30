unit mainUnit ;
interface
   {$define BASS}
uses
   SysUtils, sdl, MySDLSprites, CaveSpr, AlienSpr, UfoSpr, RadarSpr, BangSpr,
   ShipSpr, MissileSpr, BaseSpr, BaseStationSpr, LaserSpr, FuelSpr, BombSpr,
   AstroSpr, FuelGuage, ZoneSpr, Lives, Sector, Score, DataEngine, StatsObj,
   Tools, CFconsts ;

const
   TICK_INTERVAL = 1000 div kFPS ;

type
   TMainGame = class
     constructor create ;

     procedure CloseGameWindow;
     procedure GameLoop ;

  private
     m_screen     : PSDL_Surface ;
     m_DataEngine : TDataEngine ;
     m_StatObj    : TStats ;

     next_time    : Cardinal ;

     procedure Initialize ;
     procedure LoadSpriteData ;

     procedure InitAndLoadSoundData ;

     function InitializeSDLScreen : boolean ;

     procedure CheckKeys ;
     procedure UpdateGame ;
     procedure DrawSingleFrame ;
     procedure LifeLostReset ;
     procedure ExplodeCave ;

     function  TimeLeft : UInt32 ;
     procedure EmptyKeyBuffer ;

  public
     procedure Init ;
     function GetHiScore : integer ;
     function GetGameState : TGameState ;

     property GetSurface : PSDL_Surface read m_screen ;
  end ;

implementation

constructor TMainGame.Create ;
begin
   inherited Create ;
   Initialize ;
end ;

procedure TMainGame.Initialize ;
begin
   m_StatObj := TStats.Create ;
   if InitializeSDLScreen then
   begin
      m_DataEngine := TDataEngine.Create (m_Screen, m_StatObj) ;
      m_DataEngine.LoadData ('data/levels.dat') ;
      LoadSpriteData ;
      InitAndLoadSoundData ;
      Init ;
      SDL_ShowCursor (SDL_DISABLE) ;
   end
   else
   begin
    //  MessageBox (0, PChar (Format ('Problem : %s', [SDL_GetError])), 'SDL Initialize Error', MB_OK or MB_ICONHAND) ;
      m_StatObj.SetGameState (gsExit) ;
   end ;
end ;

procedure TMainGame.CloseGameWindow ;
begin
   m_StatObj.Free ;
   m_DataEngine.Free ;
   SDL_Quit ;
end ;

procedure TMainGame.Init ;
begin
   m_StatObj.Reset ; {Always reset the StatObj before reseting the game data}
   m_DataEngine.ResetGameData ;
   next_time := 0 ;
end ;

procedure TMainGame.InitAndLoadSoundData ;
var
   i : integer ;

begin
   m_StatObj.AddMusic ('data/sounds/ingame.xm') ;

{$IFDEF BASS}
   {Use the .mp3 files for BASS}
   m_StatObj.AddEffect ('data/sounds/laser.mp3') ;
   m_StatObj.AddEffect ('data/sounds/liftoff.mp3') ;
{$ELSE}
  {Use the .wav files for SDL_Mixer}
   m_StatObj.AddEffect ('data/sounds/laser.wav') ;
   m_StatObj.AddEffect ('data/sounds/liftoff.wav') ;
{$ENDIF}

   for i := 1 to 7 do
   begin
      m_StatObj.AddEffect ('data/sounds/explosion' + IntToStr (i) + '.wav') ;
   end ;

   m_StatObj.PlayTune (kInGame) ;
end ;

procedure TMainGame.LoadSpriteData ;
var
   iCnt : integer ;

begin
   {This is not a very good way of loading the sprites. It is wasting memory
    as many of the sprites are duplicates. To fix this it would be better to pass
    a pointer of a single image in memory. This is a basic engine that does the job.
    My new tile engine is much more flexible}

   for iCnt := 0 to 41 do
   begin
      m_DataEngine.AddSprite (TCaveSprite.Create ('data/walls.png', 32, 32, m_StatObj)) ;
   end ;

   for iCnt := 0 to 6 do
   begin
      m_DataEngine.AddSprite (TMissileSprite.Create ('data/missile.png', 27, 42, m_StatObj)) ;
   end ;

   for iCnt := 0 to 5 do
   begin
      m_DataEngine.AddSprite (TBaseSprite.Create ('data/station.png', 28, 32, m_StatObj)) ;
   end ;

   for iCnt := 0 to 3 do
   begin
      m_DataEngine.AddSprite (TFuelSprite.Create ('data/fuel.png', 27, 32, m_StatObj)) ;
   end ;

   for iCnt := 0 to 5 do
   begin
      m_DataEngine.AddSprite (TAlienSprite.Create ('data/alien.png', 32, 32, m_StatObj)) ;
   end ;

   for iCnt := 0 to 3 do
   begin
      m_DataEngine.AddSprite (TUFOSprite.Create ('data/ufo.png', 32, 28, m_StatObj)) ;
   end ;

   for iCnt := 0 to 3 do
   begin
      m_DataEngine.AddSprite (TRadarSprite.Create ('data/radar.png', 28, 30, m_StatObj)) ;
   end ;

   m_DataEngine.AddSprite (TBaseStationSprite.Create ('data/base.png', 32, 32, m_StatObj)) ;

   m_DataEngine.AddSprite (TAstroSprite.Create ('data/astro.png', 27, 13, m_StatObj)) ;

   m_DataEngine.AddSprite (TZoneSprite.Create ('data/zone.png', 32, 62, m_StatObj)) ;
   
   m_DataEngine.AddSprite (TLives.Create ('data/lives.png', 144, 16, m_StatObj)) ;
   m_DataEngine.AddSprite (TSector.Create ('data/sector.png', 206, 14, m_StatObj)) ;
   m_DataEngine.AddSprite (TFuelGuage.Create ('data/fuelguage.png', 384, 12, m_StatObj)) ;

   m_DataEngine.AddSprite (TScore.Create ('data/score.png','data/chars_w_16x16.png', m_screen, m_StatObj)) ;

   m_DataEngine.AddSprite (TLaserSprite.Create ('data/laser.png', 24, 6)) ;
   m_DataEngine.AddSprite (TShipSprite.Create ('data/ship.png', 32, 32, m_StatObj)) ;
   m_DataEngine.AddSprite (TBombSprite.Create ('data/bomb.png', 15, 7)) ;

   for iCnt := 0 to 3 do
   begin
      m_DataEngine.AddSprite (TBangSprite.Create ('data/bang.png', 32, 32, iCnt)) ;
   end ;
end ;

function TMainGame.InitializeSDLScreen : boolean ;
var
   bpp  : integer ;

begin
   result := true ;
   if SDL_Init (SDL_INIT_VIDEO) >= 0 then
   begin
      m_screen := GetVideo (bpp, 640, 480) ;

      if nil <> m_screen then
      begin
         SDL_WM_SetCaption ('Cavern Fighter v 2.0', nil) ;
      end
      else
      begin
         result := false ;
      end ;
   end
   else
   begin
      result := false ;
   end ;
end ;

////////// End of Init stuff ///////////////
function TMainGame.GetHiScore : integer ;
begin
   ASSERT (nil <> m_StatObj) ;

   result := m_StatObj.GetScore ;
end ;

function TMainGame.GetGameState : TGameState ;
begin
   ASSERT (nil <> m_StatObj) ;

   result := m_StatObj.GetGameState ;
end ;

procedure TMainGame.GameLoop ;
begin
   m_DataEngine.SetScreenToStartOfZone ;
   m_StatObj.SetGameState (gsRunning) ;

   while (gsExit <> m_StatObj.GetGameState) and (gsCompleted <> m_StatObj.GetGameState) do
   begin
      if gsReStart = m_StatObj.GetGameState then
      begin
         LifeLostReset ;
      end ;

      CheckKeys ;
      UpdateGame ;

      SDL_FillRect (m_screen, nil, 0 ) ;
      SDL_Delay (TimeLeft) ;

      m_DataEngine.Draw ;
      SDL_Flip (m_screen) ;
   end ;

   if gsCompleted = m_StatObj.GetGameState then
   begin
      ExplodeCave ;
   end ;
end ;

procedure TMainGame.ExplodeCave ;
var
   i : integer ;

begin
   m_DataEngine.KillAllButShip ;
   
   for i := 0 to 24 do
   begin
      UpdateGame ;
      SDL_Delay (TimeLeft) ;
      DrawSingleFrame ;
   end ;
end ;

procedure TMainGame.LifeLostReset ;
begin
   EmptyKeyBuffer ;
   m_DataEngine.ResetGameData ;
   m_StatObj.ResetFuel ;
   m_DataEngine.SetScreenToStartOfZone ;
   DrawSingleFrame ;
   SDL_Delay (500) ;
   m_StatObj.SetGameState (gsRunning) ;
end ;

procedure TMainGame.CheckKeys ;
var
   Event : TSDL_Event ;

begin
   while SDL_PollEvent (@Event) > 0 do
   begin
      if (Event.key.type_ = SDL_KeyDown) and (Event.key.keysym.sym = SDLK_ESCAPE) then
      begin
         m_StatObj.SetGameState (gsExit) ;
      end ;
   end ;
end ;

procedure TMainGame.UpdateGame ;
begin
   m_DataEngine.ScrollBackground ;
end ;

procedure TMainGame.DrawSingleFrame ;
begin
   SDL_FillRect (m_screen, nil, 0 ) ;
   m_DataEngine.Draw ;
   SDL_Flip (m_screen) ;
end ;

function TMainGame.TimeLeft : UInt32 ;
var
   now : cardinal ;

begin
   now := SDL_GetTicks ;
   if next_time <= now then
   begin
      next_time := now + TICK_INTERVAL ;
      result := 0 ;
   end
   else
   begin
      result := next_time - now ;
   end ;
end ;

{Empty the keyboard buffer - required ?}
procedure TMainGame.EmptyKeyBuffer ;
var
   Event : TSDL_Event ;

begin
   SDL_PumpEvents ;
   while SDL_PollEvent (@Event) > 0 do
   begin
   end ;
end ;

end.
