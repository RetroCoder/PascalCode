unit LaserSpr ;
interface

uses
  sdl, MySDLSprites, CFconsts, Tools ;

type
   TLaserSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer) ; 

      procedure Init ; override ;
      procedure Move ; override ;

     private
        procedure DetectCollision ;
   end ;

implementation

constructor TLaserSprite.Create (const filename : string ;
                                 const iWidth   : integer ;
                                 const iHeight  : integer) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDLaser ;
   Init ;
end ;

procedure TLaserSprite.Init ;
begin
   AnimPhase := 0 ; {which frame to show}
   Visible := false ;  {should the sprite be visible}
end ;

procedure TLaserSprite.Move ;
begin
   DetectCollision ;

   inc (x, 8) ;
   if 631 < x then
   begin
      Visible := false ;
   end ;
end ;

procedure TLaserSprite.DetectCollision ;
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
            if ParentList [i].ID <> IDcave then
            begin
               ParentList [i].Kill ;
            end ;
            i := ParentList.Count + 1 ; // Force a break from the loop
            Visible := false ;
         end ;
      end ;
      inc (i) ;
   end ;
end ;
 
end.
