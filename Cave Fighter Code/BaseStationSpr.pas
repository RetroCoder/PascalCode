unit BaseStationSpr ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TBaseStationSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_theStatObj   : TStats ;
      m_mysteryScore : integer ;
      m_Delay        : integer ;
   end ;

implementation

constructor TBaseStationSprite.Create (const filename : string ;
                                       const iWidth   : integer ;
                                       const iHeight  : integer ;
                                       const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDbase ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TBaseStationSprite.Init ;
begin
   m_mysteryScore := random (100) + 50 ;
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_Delay := 0 ;
end ;

procedure TBaseStationSprite.Move ;
begin
   dec (x, 2) ;

   if 0 <> AnimPhase then
   begin
      if 5 = AnimPhase then
      begin
         visible := false ;
         AnimPhase := 0 ;
         m_theStatObj.SetGameState (gsCompleted) ;  // Game is won
      end
      else
      begin
         inc (m_Delay) ;
         if 3 = m_Delay then
         begin
            inc (AnimPhase) ;
            m_Delay := 0 ;
         end ;
      end ;
   end ;
end ;

procedure TBaseStationSprite.Kill ;
begin
   if 0 = AnimPhase then
   begin
      m_theStatObj.SetGameState (gsDestroyCave) ;
      m_theStatObj.IncrementScore (m_mysteryScore) ;
      AnimPhase := 1 ;
      m_theStatObj.PlayEffect (kExplode7) ;
   end ;
end ;

end.
