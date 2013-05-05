unit ShipSpr ;

{$MODE Delphi}

interface

uses
   SDL, MySDLSprites, CFconsts, StatsObj, Tools ;

type
   TShipSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;

   private
      keys         : PKeyStateArr ;
      m_theStatObj : TStats ;
      m_AnimDelay  : integer ;
      m_DieCount   : integer ;
      m_Shield     : integer ;

      procedure DetectCollision ;
   end ;

implementation


constructor TShipSprite.Create (const filename : string ;
                                const iWidth   : integer ;
                                const iHeight  : integer ;
                                const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDship ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TShipSprite.Init ;
begin
   x := 20 ;  {x pos}
   y := m_theStatObj.GetStartPos ; {y pos}
   AnimPhase := 10 ; {which frame to show}
   Visible := true ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
   m_DieCount := 0 ;
   m_Shield := 128 ; {length of time that the ship has a shield}
end ;

procedure TShipSprite.Move ;
begin
   DetectCollision ;
   if gsRunning = m_theStatObj.GetGameState  then
   begin
      if m_Shield > 0 then
      begin
         dec (m_Shield) ;
         if m_Shield = 0 then
         begin
            AnimPhase := 0 ;
         end ;
      end ;

      keys := PKeyStateArr (SDL_GetKeyState (nil)) ;

      if (kMinFuel < m_theStatObj.GetFuel) then
      begin
         if (keys [SDLK_UP] = 1) and (y > 64) then
         begin
            dec (y, 2) ;
         end
         else if (keys [SDLK_DOWN] = 1) and (y < 470) then
         begin
            inc (y, 2) ;
         end ;
         if (keys [SDLK_RIGHT] = 1) and (x < 470) then
         begin
            inc (x, 2) ;
         end
         else if (keys [SDLK_LEFT] = 1) and (x > 5) then
         begin
            dec (x, 4) ;
         end ;
      end
      else
      begin
         // No fuel left so start to crash land
         inc (y, 2) ;
      end ;

      if (keys [SDLK_Z] = 1) and (not ParentList [kLaserListPos].Visible) then
      begin
         ParentList [kLaserListPos].x := x + 34 ;
         ParentList [kLaserListPos].y := y + 15 ;
         ParentList [kLaserListPos].Visible := true ;
         m_theStatObj.PlayEffect (kLaser) ;
      end ;

      if (keys [SDLK_X] = 1) and (not ParentList [kBombPos].Visible) then
      begin
         ParentList [kBombPos].x := x + 32 ;
         ParentList [kBombPos].y := y + 30 ;
         ParentList [kBombPos].Visible := true ;
      end ;
   end ;
end ;

procedure TShipSprite.DetectCollision ;
var
   i     : integer ;
   iBang : integer ;

begin
   if gsLostLife <> m_theStatObj.GetGameState then
   begin
      i := 0 ;

      while i < ParentList.Count - 9 do  // Don't look at the last 9 items 
      begin
         if (ParentList [i].Visible) and (not ParentList [i].Exploding) then
         begin
            if PixelCollideTest (FigureSurface, GetSurfaceRect, ParentList [i].FigureSurface, ParentList [i].GetSurfaceRect,
                                 x, y, ParentList [i].x, ParentList [i].y) then
            begin
               if (m_Shield > 0) and (ParentList [i].ID <> IDcave) then
               begin
                  ParentList [i].Kill ;
                  i := ParentList.Count + 1 ; // Force a break from the loop
                  m_theStatObj.PlayEffect (kExplode6) ;                  
               end
               else
               begin
                  AnimPhase := 0 ;
                  m_theStatObj.DecrementLife ;
                  ParentList [i].Kill ;
                  i := ParentList.Count + 1 ; // Force a break from the loop
                  m_theStatObj.PlayEffect (kExplode6) ;
               end ;
            end ;
         end ;
         inc (i) ;
      end ;
   end
   else
   begin
      if 4 <> m_DieCount then
      begin
         if 3 = m_AnimDelay then
         begin
            m_AnimDelay := -1 ;
            inc (AnimPhase) ;
            inc (y, 2) ;
            if 9 = AnimPhase then
            begin
               for iBang := 0 to 3 do
               begin
                  ParentList.Items [kBangPos + iBang].x := x ;
                  ParentList.Items [kBangPos + iBang].y := y ;
                  ParentList.Items [kBangPos + iBang].Visible := true ;
               end ;
               AnimPhase := 1 ;
               inc (m_DieCount) ;
            end ;
         end ;
         inc (m_AnimDelay) ;
      end
      else
      begin
         m_DieCount := 0 ;
         AnimPhase := 9 ;
         m_theStatObj.SetGameState (gsReStart) ;
      end ;
   end ;
end ;

end.
