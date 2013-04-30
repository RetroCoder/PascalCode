unit BangSpr ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TBangSprite = class (TSprite)
      constructor Create (const filename  : string ;
                          const iWidth    : integer ;
                          const iHeight   : integer ;
                          const Direction : integer) ;

      procedure Init ; override ;
      procedure Move ; override ;
   private
      m_AnimDelay  : integer ;
      m_Direction  : integer ;
   end ;

implementation

constructor TBangSprite.Create (const filename  : string ;
                                const iWidth    : integer ;
                                const iHeight   : integer ;
                                const Direction : integer) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDBang ;
   m_Direction := Direction ;
   Init ;
end ;

procedure TBangSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
end ;

procedure TBangSprite.Move ;
begin
   {0 = NE 1 = SE 2 = SW 3 = NW}
   case m_Direction of
      0 : begin
             inc (x, 2) ;
             dec (y, 2) ;
          end ;
      1 : begin
             inc (x, 1) ;
             inc (y, 1) ;
          end ;
      2 : begin
             dec (x, 4) ;
             inc (y, 2) ;
          end ;
      3 : begin
             dec (x, 2) ;
             dec (y, 1) ;
          end ;
   end ;

   if 2 < m_AnimDelay then
   begin
      m_AnimDelay := 0 ;

      if 7 = AnimPhase then
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

end.
