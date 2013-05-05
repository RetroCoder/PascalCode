unit BombSpr ;

{$MODE Delphi}

interface

uses
   SDL, MySDLSprites, CFconsts, Tools ;

type
   TBombSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer) ; 

      procedure Init ; override ;
      procedure Move ; override ;

     private
        m_DropCount : integer ;
        procedure DetectCollision ;
   end ;

implementation

constructor TBombSprite.Create (const filename : string ;
                                const iWidth   : integer ;
                                const iHeight  : integer) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDBomb ;
   Init ;
end ;

procedure TBombSprite.Init ;
begin
   m_DropCount := 0 ;
   AnimPhase := 0 ; {which frame to show}
   Visible := false ;  {should the sprite be visible}
end ;

procedure TBombSprite.Move ;
begin
   DetectCollision ;

   inc (y, 3) ;

   if 9 > m_DropCount then
   begin
      inc (x) ;
      inc (m_DropCount) ;
   end ;

   if 480 < y then
   begin
      Visible := false ;
      m_DropCount := 0 ;
   end ;
end ;

procedure TBombSprite.DetectCollision ;
var
   i : integer ;

begin
   i := 0 ;

   while i < ParentList.Count - 9 do
   begin
      if ParentList [i].Visible then
      begin
         if PixelCollideTest (FigureSurface, GetSurfaceRect, ParentList [i].FigureSurface, ParentList [i].GetSurfaceRect,
                              x, y, ParentList [i].x, ParentList [i].y) then
         begin
            m_DropCount := 0 ;

            if ParentList [i].ID = IDcave then
            begin
               Visible := false ;
            end
            else
            begin
               ParentList [i].Kill ;
               Visible := false ;
            end ;
            i := ParentList.Count + 1 ; // Force a break from the loop
         end ;
      end ;
      inc (i) ;
   end ;
end ;

end.
