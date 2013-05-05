unit RadarSpr ;

{$MODE Delphi}

interface

uses
   SDL, MySDLSprites, CFconsts, StatsObj ;

type
   TRadarSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_theStatObj : TStats ;
      m_AnimDelay  : integer ;
      m_Delay      : integer ;
   end ;

implementation

constructor TRadarSprite.Create (const filename : string ;
                                 const iWidth   : integer ;
                                 const iHeight  : integer ;
                                 const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDradar ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TRadarSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
   m_Delay := 8 ;
end ;

procedure TRadarSprite.Move ;
begin
   dec (x, 2) ;

   if m_Delay < m_AnimDelay then
   begin
      m_AnimDelay := 0 ;

      if 9 <> AnimPhase then
      begin
         inc (AnimPhase) ;
      end
      else
      begin
         Visible := false ;
         m_Delay := 8 ;
      end ;

      if 3 = AnimPhase then
      begin
         AnimPhase := 0 ;
      end ;
   end
   else
   begin
      inc (m_AnimDelay) ;
   end ;
end ;

procedure TRadarSprite.Kill ;
begin
   if 4 > AnimPhase then
   begin
      m_theStatObj.IncrementScore (100) ;
      AnimPhase := 4 ;
      m_Delay := 2 ;
      m_theStatObj.PlayEffect (kExplode1) ;
   end ;
end ;

end.
