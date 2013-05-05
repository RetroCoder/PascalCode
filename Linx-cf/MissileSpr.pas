unit MissileSpr ;

{$MODE Delphi}

interface

uses
   MySDLSprites, CFconsts, StatsObj ;

type
   TMissileSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

      Private
         m_AnimDelay  : integer ;
         m_Fire       : boolean ;
         m_theStatObj : TStats ;
         m_Hit        : boolean ;
   end ;

implementation

constructor TMissileSprite.Create (const filename : string ;
                                   const iWidth   : integer ;
                                   const iHeight  : integer ;
                                   const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDmissile ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TMissileSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   HeightMax := 0 ;
   m_Fire := false ;
   m_AnimDelay := 0 ;
   m_Hit := false ;
end ;

procedure TMissileSprite.Move ;
begin
   dec (x, 2) ;

   if (not m_Fire) and (2 >  abs ((y - ParentList [kShipListPos].y) - (x - ParentList [kShipListPos].x))) then
   begin
      m_Fire := true ;
      AnimPhase := 1 ;
      m_theStatObj.PlayEffect (kLiftOff) ;
   end ;

   if m_Fire then
   begin
      dec (y, 2) ;
   end ;

   if (y < HeightMax) or m_Hit then
   begin
      if 1 < m_AnimDelay then
      begin
         m_AnimDelay := 0 ;

         if 6 = AnimPhase then
         begin
            Exploding := false ;
            visible := false ;
            m_Hit := false ;
            m_Fire := false ;
            AnimPhase := 0 ;
         end
         else
         begin
            inc (AnimPhase) ;
         end ;
      end
      else
      begin
         inc (m_AnimDelay) ;
      end ;
   end ;
end ;

procedure TMissileSprite.Kill ;
begin
   if not m_Hit then
   begin
      if m_Fire then
      begin
         m_theStatObj.IncrementScore (80) ;
         m_theStatObj.PlayEffect (kExplode2) ;
      end
      else
      begin
         m_theStatObj.IncrementScore (50) ;
         m_theStatObj.PlayEffect (kExplode2) ;
      end ;
      Exploding := true ;
      m_Hit := true ;
      m_Fire := true ; {this should force the missile into self destruct mode}
   end ;
end ;

end.
