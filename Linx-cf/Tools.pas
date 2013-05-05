unit Tools;

{$MODE Delphi}

interface

uses   SysUtils, SDL ;

   function PixelCollideTest (SrcSurface1 : PSDL_Surface; SrcRect1 : PSDL_Rect; SrcSurface2 :
                              PSDL_Surface; SrcRect2 : PSDL_Rect; Left1, Top1, Left2, Top2 : integer ) : Boolean;

   function GetVideo (var bpp : integer ;
                      const w : integer ;
                      const h : integer) : PSDL_Surface ;

   function PSDLRect (aLeft, aTop, aWidth, aHeight : integer) : PSDL_Rect ;

   function isCollideRects (Rect1, Rect2 : PSDL_Rect) : boolean ;

implementation

function PixelCollideTest (SrcSurface1 : PSDL_Surface ;
                           SrcRect1    : PSDL_Rect ;
                           SrcSurface2 : PSDL_Surface ;
                           SrcRect2    : PSDL_Rect ;
                           Left1       : integer ;
                           Top1        : integer ;
                           Left2       : integer ;
                           Top2        : integer) : boolean ;
var
   Src_Rect1, Src_Rect2   : TSDL_Rect ;
   right1, bottom1        : integer ;
   right2, bottom2        : integer ;
   Scan1Start, Scan2Start : cardinal ;
   ScanWidth, ScanHeight  : cardinal ;
   Mod1, Mod2             : cardinal ;
   Addr1, Addr2           : cardinal ;
   BPP                    : cardinal ;
   Pitch1, Pitch2         : cardinal ;
   TransparentColor1      : cardinal ;
   TransparentColor2      : cardinal ;
   tx, ty                 : cardinal ;
   Color1, Color2         : cardinal ;
   bLock                  : boolean ;
begin
   Result := false ;

   ASSERT (nil <> SrcRect1) ;
   ASSERT (nil <> SrcRect2) ;
   ASSERT (nil <> SrcSurface1) ;
   ASSERT (nil <> SrcSurface2) ;

   Src_Rect1 := SrcRect1^ ;
   Src_Rect2 := SrcRect2^ ;

   Right1 := Left1 + Src_Rect1.w ;
   Bottom1 := Top1 + Src_Rect1.h ;

   Right2 := Left2 + Src_Rect2.w ;
   Bottom2 := Top2 + Src_Rect2.h ;

   if (Left1 >= Right2) or (Right1 <= Left2) or (Top1 >= Bottom2) or (Bottom1 <= Top2) then exit ;
   bLock := SDL_MustLock (SrcSurface1) or SDL_MustLock (SrcSurface2) ;
   if bLock then
   begin
      SDL_LockSurface (SrcSurface1) ;
      SDL_LockSurface (SrcSurface2) ;
   end ;

  if Left1 <= Left2 then
  begin
    Scan1Start := Src_Rect1.x + Left2 - Left1 ;
    Scan2Start := Src_Rect2.x ;
    ScanWidth := Right1 - Left2 ;
    if ScanWidth > Src_Rect2.w then
    begin
       ScanWidth := Src_Rect2.w ;
    end ;
    end
    else
    begin
       Scan1Start := Src_Rect1.x;
       Scan2Start := Src_Rect2.x + Left1 - Left2 ;
       ScanWidth := Right2 - Left1 ;
       if ScanWidth > Src_Rect1.w then
       begin
          ScanWidth := Src_Rect1.w ;
       end ;
    end ;

   with SrcSurface1^ do
   begin
      Pitch1 := Pitch ;
      Addr1 := cardinal (Pixels) ;
      inc (Addr1, Pitch1 * UInt32 (Src_Rect1.y)) ;
      with format^ do
      begin
         BPP := BytesPerPixel ;
         TransparentColor1 := colorkey ;
      end ;
   end ;

   with SrcSurface2^ do
   begin
      TransparentColor2 := format.colorkey ;
      Pitch2 := Pitch ;
      Addr2 := cardinal (Pixels) ;
      inc (Addr2, Pitch2 * UInt32 (Src_Rect2.y)) ;
   end ;

   Mod1 := Pitch1 - (ScanWidth * BPP) ;
   Mod2 := Pitch2 - (ScanWidth * BPP) ;
   inc (Addr1, BPP * Scan1Start) ;
   inc (Addr2, BPP * Scan2Start) ;

   if Top1 <= Top2 then
   begin
      ScanHeight := Bottom1 - Top2 ;
      if ScanHeight > Src_Rect2.h then
      begin
         ScanHeight := Src_Rect2.h ;
      end ;
      inc (Addr1, Pitch1 * UInt32 (Top2 - Top1)) ;
   end
   else
   begin
      ScanHeight := Bottom2 - Top1 ;
      if ScanHeight > Src_Rect1.h then
      begin
         ScanHeight := Src_Rect1.h ;
      end ;
      inc (Addr2, Pitch2 * UInt32 (Top1 - Top2)) ;
   end ;

  case BPP of
    1 :
      for ty := 1 to ScanHeight do
      begin
         for tx := 1 to ScanWidth do
         begin
            if (PByte (Addr1)^ <> TransparentColor1) and (PByte (Addr2)^ <> TransparentColor2) then
            begin
               Result := true ;
               Break ;
            end ;
            inc (Addr1) ;
            inc (Addr2) ;
          end ;
          inc (Addr1, Mod1) ;
          inc (Addr2, Mod2) ;
      end ;

    2 :
      for ty := 1 to ScanHeight do
      begin
         for tx := 1 to ScanWidth do
         begin
            if (PWord (Addr1)^ <> TransparentColor1) and (PWord (Addr2)^ <> TransparentColor2) then
            begin
               Result := true ;
               Break ;
            end ;
            inc (Addr1, 2) ;
            inc (Addr2, 2) ;
         end ;
         inc (Addr1, Mod1) ;
         inc (Addr2, Mod2) ;
      end ;

    3 :
      for ty := 1 to ScanHeight do
      begin
         for tx := 1 to ScanWidth do
         begin
            Color1 := PLongWord (Addr1)^ and $00FFFFFF ;
            Color2 := PLongWord (Addr2)^ and $00FFFFFF ;
            if (Color1 <> TransparentColor1) and (Color2 <> TransparentColor2) then
            begin
               Result := true ;
               Break ;
            end ;
            inc (Addr1, 3) ;
            inc (Addr2, 3) ;
         end ;
         inc (Addr1, Mod1) ;
         inc (Addr2, Mod2) ;
      end ;

    4 :
      for ty := 1 to ScanHeight do
      begin
         for tx := 1 to ScanWidth do
         begin
            if (PLongWord (Addr1)^ <> TransparentColor1) and (PLongWord (Addr2)^ <> TransparentColor2) then
            begin
               Result := true ;
               Break ;
            end ;
            inc (Addr1, 4) ;
            inc (Addr2, 4) ;
         end ;
         inc (Addr1, Mod1) ;
         inc (Addr2, Mod2) ;
      end ;
   end ;
   if bLock then
   begin
      SDL_UnlockSurface (SrcSurface1) ;
      SDL_UnlockSurface (SrcSurface2) ;
   end ;
end ;

function GetVideo (var bpp : integer ;
                   const w : integer ;
                   const h : integer) : PSDL_Surface ;
const
   kFlags = SDL_DOUBLEBUF or SDL_HWPALETTE or SDL_HWSURFACE or SDL_FullScreen ;
  // kFlags = SDL_HWPALETTE or SDL_SWSURFACE ;

begin
   result := nil ;

   bpp := SDL_VideoModeOk (w, h, 32, kFlags) ;
   if bpp = 0 then
      bpp := SDL_VideoModeOk (w, h, 24, kFlags) ;
   if bpp = 0 then
      bpp := SDL_VideoModeOk (w, h, 16, kFlags) ;
   if bpp = 0 then
      bpp := SDL_VideoModeOk (w, h, 15, kFlags) ;
   if bpp = 0 then
      bpp := SDL_VideoModeOk (w, h, 8, kFlags) ;

   if bpp in [8, 15, 16, 24, 32] then
   begin
      result := SDL_SetVideoMode (w, h, bpp, kFlags) ;
   end ;
end ;

// Allocates memory for a TSDL_Rect and returns its pointer.
// User must free the memory before exiting.
function PSDLRect (aLeft, aTop, aWidth, aHeight : integer) : PSDL_Rect ;
var
  Rect : PSDL_Rect ;

begin
   New (Rect) ;

   with Rect^ do
   begin
      x := aLeft ;
      y := aTop ;
      w := aWidth ;
      h := aHeight ;
   end ;

   Result := Rect ;
end ;

function isCollideRects (Rect1, Rect2 : PSDL_Rect ) : boolean ;
begin
   Result := true ;
   if (Rect1.x + Rect1.w < Rect2.x) or
      (Rect1.x > Rect2.x + Rect2.w) or
      (Rect1.y + Rect1.h < Rect2.y) or
      (Rect1.y > Rect2.y + Rect2.h) then
   begin
      Result := false ;
   end ;
end ;

end.
