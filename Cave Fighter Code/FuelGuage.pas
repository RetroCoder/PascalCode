unit FuelGuage ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TFuelGuage = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Move ; override ;
      procedure Init ; override ;

   private
      m_theStatObj : TStats ;
      m_delay      : integer ;
   end ;

implementation

constructor TFuelGuage.Create (const filename : string ;
                               const iWidth   : integer ;
                               const iHeight  : integer ;
                               const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDnone ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TFuelGuage.Init ;
begin
   m_delay := 0 ;
   x := 4 ;  {x pos}
   y := 34 ; {y pos}

   SrcRect.w := kMaxFuel ;
   Visible := true ;  {should the sprite be visible}
end ;

procedure TFuelGuage.Move ;
begin
   if m_theStatObj.GetGameState = gsRunning then
   begin
      if 4 < m_delay then
      begin
         SrcRect.w := m_theStatObj.GetFuel ;
         m_theStatObj.DecrementFuel ;
         m_delay := 0 ;
      end
      else
      begin
         inc (m_delay) ;
      end ;
   end ;
end ;

end.
