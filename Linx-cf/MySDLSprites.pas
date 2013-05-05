unit MySDLSprites ;

{$MODE Delphi}



interface

uses
   LCLIntf, LCLType, Classes, SysUtils, SDL_Image, SDL, Tools, CFconsts, FileUtil ;

type
   TSpriteList = class ;

   TSprite = class
      ID            : TSpriteID ;    // we can easily determine the sprite's type
      ParentList    : TSpriteList ;
      PrevRect      : TSDL_Rect ;    // rectangle of previous position in the screen
      SrcRect       : PSDL_Rect ;    // source rectangle that contains the image-data
      AnimPhase     : integer ;      // which image to draw
      Visible       : boolean ;      // draw it only if it's visible
      x, y          : integer ;      // x, y coords for screen
      HeightMax     : integer ;      // max height movement to the top of the screen
      HeightMin     : integer ;      // max movement to the bottom of the screen
      w, h          : integer ;      // Width & Height of sprite
      Surface       : PSDL_Surface ; // surface
      Background    : PSDL_Surface ; // background surface
      FigureSurface : PSDL_Surface ; // sprite image surface
      Exploding     : boolean ;      // sprite is dying

      constructor Create ; overload ;
      constructor Create (const FileName : string ; Width, Height : integer ; Flags : cardinal) ; overload ;
      constructor Create (const FileName : string ; Width, Height : integer) ; overload ;

      destructor Destroy ;

      procedure GetCollisionRect (Rect : PSDL_Rect ) ; virtual ;

      procedure Remove ;
      procedure Draw ; virtual ; // draw sprite on screen
      procedure Move ; virtual ; abstract ; // move the sprite
      procedure Kill ; virtual ; // Need to override this
      procedure Free ; virtual ; // destroy sprite
      procedure Init ; virtual ; abstract ;

      property GetSurfaceRect : PSDL_Rect read SrcRect ;
   end ;

   TSpriteList = class (TList)
      protected
         function  Get (Index : Integer) : TSprite ;
         procedure Put (Index : Integer ; Item : TSprite) ;
      public
         property Items [Index : Integer] : TSprite read Get write Put ; default ;
   end ;

   TSpriteEngine = class
      private
         FSurface    : PSDL_Surface ; // screen surface
         FBackground : PSDL_Surface ; // background surface

         procedure SetSurface (_Surface : PSDL_Surface) ;
         procedure SetBackground (_Surface : PSDL_Surface) ;
      public
         Sprites     : TSpriteList ; // all sprites
         UpdateRects : array of TSDL_Rect ;

         procedure Clear ;                         // destroy all sprites from list
         procedure AddSprite (Item : TSprite) ;    // add a sprite to list
         procedure RemoveSprite (Item : TSprite) ; // remove a sprite from list and from memory
         procedure Free ;
         procedure MoveAll ; // move all sprites in the list
         procedure Draw ;    // draw all sprites in the list
         property Screen : PSDL_Surface read FSurface write SetSurface ; // screen surface
         property BackgroundSurface : PSDL_Surface read FBackground write SetBackground ; // background surface
         constructor Create (_Surface : PSDL_Surface) ;
   end ;
 
implementation
{ Create a sprite. NB: Transparent color is $00000000 Black}

constructor TSprite.Create ;
begin
end ;

constructor TSprite.Create (const FileName : string ;
                            Width          : integer ;
                            Height         : integer ;
                            Flags          : cardinal) ;
begin
   inherited Create ;

   if FileExistsUTF8(FileName) then
   begin
      FigureSurface := IMG_Load (PChar (FileName)) ;
      SDL_SetColorKey (FigureSurface,
                       Flags or SDL_DOUBLEBUF,
                       SDL_MapRGB (FigureSurface.format, 0, 0, 0 )) ;
      FigureSurface := SDL_DisplayFormat (FigureSurface) ;
   end
   else
   begin
      ASSERT (false) ;
      FigureSurface := nil ;
   end ;

   Surface := nil ;
   Background := nil ;

   AnimPhase := 0 ;
   Exploding := false ;

   x := 0 ;
   y := 0 ;
   w := Width ;
   h := Height ;
   SrcRect := PSDLRect (x, 0, w, h) ;
end ;

constructor TSprite.Create (const FileName : string ;
                            Width          : integer ;
                            Height         : integer) ;
begin
   inherited Create ;

   if FileExistsUTF8(FileName) then
   begin
      FigureSurface := IMG_Load (PChar (FileName)) ;
      SDL_SetColorKey (FigureSurface,
                       SDL_SRCCOLORKEY or SDL_RLEACCEL or SDL_HWACCEL or SDL_DOUBLEBUF,
                       SDL_MapRGB (FigureSurface.format, 0, 0, 0 )) ;
      FigureSurface := SDL_DisplayFormat (FigureSurface) ;
   end
   else
   begin
     // ASSERT (false) ;
      FigureSurface := nil ;
   end ;

   Surface := nil ;
   Background := nil ;

   AnimPhase := 0 ;
   Exploding := false ;

   x := 0 ;
   y := 0 ;
   w := Width ;
   h := Height ;
   SrcRect := PSDLRect (x, 0, w, h) ;
end ;

destructor TSprite.Destroy ;
begin
   Dispose (SrcRect) ;
   inherited Destroy ;
end ;

procedure TSprite.GetCollisionRect (Rect : PSDL_Rect) ;
begin
   Rect.x := x ;
   Rect.y := y ;
   Rect.w := w ;
   Rect.h := h ;
end ;

procedure TSprite.Free ;
begin
   Dispose (SrcRect) ;
   if FigureSurface <> nil then
   begin
      SDL_FreeSurface (FigureSurface) ;
   end ;

   inherited Free ;
end ;

procedure TSprite.Kill ;
begin
end ;

procedure TSprite.Remove ;
begin
   PrevRect.w := w ;
   PrevRect.h := h ;
   SDL_BlitSurface (Background, @PrevRect, Surface, @PrevRect) ;
end ;

procedure TSprite.Draw ;
var
   DestRect : TSDL_Rect ;

begin
   if Visible then
   begin
      SrcRect.x := AnimPhase * w ;
      DestRect.x := x ;
      DestRect.y := y ;
      SDL_BlitSurface (FigureSurface, SrcRect, Surface, @DestRect) ;
      PrevRect := DestRect ;
   end ;
end ;


{ - TSpriteList ---------------------------------------------------------- }

function TSpriteList.Get (Index : Integer) : TSprite ;
begin
   Result := inherited Get (Index) ;
end ;

procedure TSpriteList.Put (Index : Integer ;
                           Item  : TSprite) ;
begin
   inherited Put (Index, Item) ;
end ;


{ - TSpriteEngine -------------------------------------------------------- }

constructor TSpriteEngine.Create (_Surface : PSDL_Surface) ;
begin
   inherited Create ;

   Sprites := TSpriteList.Create ;
   SetSurface (_Surface) ;
   SetBackground (nil) ;
   UpdateRects := nil ;
end ;

procedure TSpriteEngine.Free ;
begin
   Clear ;
   Sprites.Free ;
   inherited Free ;
end ;

procedure TSpriteEngine.AddSprite (Item : TSprite) ;
begin
   Item.Surface := Screen ; // setting new sprite's surfaces
   Item.Background := BackgroundSurface ;
   Item.ParentList := Sprites ;
   Sprites.Add (Item) ;
   ReallocMem (UpdateRects, Sprites.Count * 2 * sizeof (TSDL_Rect)) ;
end ;

procedure TSpriteEngine.RemoveSprite (Item : TSprite) ;
begin
   Sprites.Remove (Item) ;
   ReallocMem (UpdateRects, Sprites.Count * 2 * sizeof (TSDL_Rect)) ;
end ;

procedure TSpriteEngine.MoveAll ;
var
   i    : integer ;
   iMax : integer ;

begin
   if Sprites.Count > 0 then
   begin
      i := 0 ;
      iMax := Sprites.Count ;

      repeat
         if Sprites [i].Visible then
         begin
            Sprites [i].Remove ;
            Sprites [i].Move ;
         end ;
         inc (i) ;
      until i >= iMax ;
   end ;
end ;

procedure TSpriteEngine.Draw ;
var
   i   : integer ;
   j   : integer ;
   num : integer ;

begin
   num := Sprites.Count ;
   j := 0 ;

   if num > 0 then
   begin
      for i := 0 to num - 1 do
      begin
         if Sprites [i].Visible then
         begin
            UpdateRects [j] := Sprites [i].PrevRect ;
            Sprites [i].Draw ;
            inc (j) ;

            UpdateRects [j] := Sprites [i].PrevRect ;
            inc (j) ;
         end ;
      end ;
   end ;
end ;

{ set all sprites' Surface to _Surface }
procedure TSpriteEngine.SetSurface (_Surface : PSDL_Surface) ;
var
   i : integer ;

begin
   FSurface := _Surface ;

   if Sprites.Count > 0 then
   begin
      for i := 0 to Sprites.Count - 1 do
      begin
         Sprites [i].Surface := _Surface ;
      end ;
   end ;
end ;

{ set all sprites' Background surface to _Surface }
procedure TSpriteEngine.SetBackground (_Surface : PSDL_Surface) ;
var
   i : integer ;

begin
   FBackground := _Surface ;

   if Sprites.Count > 0 then
   begin
      for i := 0 to Sprites.Count - 1 do
      begin
         Sprites [i].Background := _Surface ;
      end ;
   end ;
end ;

{ destroy all sprites }
procedure TSpriteEngine.Clear ;
var
   TempSpr : TSprite ;

begin
   while Sprites.Count > 0 do
   begin
      TempSpr := Sprites [0] ;
      RemoveSprite (TempSpr) ;
      TempSpr.Free ;
   end ;
   Sprites.Clear ;
end ;

end.


