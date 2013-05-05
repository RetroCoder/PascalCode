unit BangSpr ;

{$MODE Delphi}

interface

uses
   MySDLSprites, CFconsts ;

type

   TBangSprite = class (TSprite)
      constructor Create (const filename  : string ;
                          const iWidth    : integer ;
                          const iHeight   : integer) ;

      procedure Init ; override ;
      procedure Move ; override ;

   private
      m_AnimDelay  : integer ;
   end ;

implementation

constructor TBangSprite.Create (const filename  : string ;
                                const iWidth    : integer ;
                                const iHeight   : integer) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDBang ;
   
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
   x := x + (random (16) - 8) ;
   y := y + (random (16) - 8) ;

   if m_AnimDelay > 4 then
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
