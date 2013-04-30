unit ZoneSpr ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TZoneSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_theStatObj  : TStats ;
      m_AnimDelay   : integer ;
   end ;

implementation

constructor TZoneSprite.Create (const filename : string ;
                                const iWidth   : integer ;
                                const iHeight  : integer ;
                                const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDzone ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TZoneSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
end ;

procedure TZoneSprite.Move ;
begin
   dec (x, 2) ;

   if 6 < m_AnimDelay then
   begin
      m_AnimDelay := 0 ;

      if 9 <> AnimPhase then
      begin
         inc (AnimPhase) ;
      end
      else
      begin
         Visible := false ;
      end ;

      if 6 = AnimPhase then
      begin
         AnimPhase := 0 ;
      end ;
   end
   else
   begin
      inc (m_AnimDelay) ;
   end ;
end ;

procedure TZoneSprite.Kill ;
begin
   if 6 > AnimPhase then
   begin
      AnimPhase := 6 ;
      m_theStatObj.IncrementScore (500) ;
      m_theStatObj.PlayEffect (kExplode2) ;
   end ;
end ;

end.
 