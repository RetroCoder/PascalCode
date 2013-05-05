unit FuelSpr ;

{$MODE Delphi}

interface

uses
   SDL, MySDLSprites, CFconsts, StatsObj ;

type
   TFuelSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;
   private
      m_AnimDelay  : integer ;
      m_theStatObj : TStats ;
   end ;

implementation

constructor TFuelSprite.Create (const filename : string ;
                                const iWidth   : integer ;
                                const iHeight  : integer ;
                                const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDfuel ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TFuelSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
end ;

procedure TFuelSprite.Move ;
begin
   dec (x, 2) ;

   if 0 <> AnimPhase then
   begin
      if 2 < m_AnimDelay then
      begin
         m_AnimDelay := 0 ;

         if 5 = AnimPhase then
         begin
            visible := false ;
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

procedure TFuelSprite.Kill ;
begin
   if 0 = AnimPhase then
   begin
      m_theStatObj.IncrementFuel (40) ;
      m_theStatObj.IncrementScore (150) ;
      AnimPhase := 1 ;
      m_theStatObj.PlayEffect (kExplode3) ;
   end ;
end ;

end.
