unit Score ;
interface

uses
   sdl, MySDLSprites, CFconsts, sysutils, sdl_image, StatsObj ;

const
   kCharW = 16 ;
   kCharH = 16 ;

   Chars = '0123456789';

type

   TScore = class (TSprite)
      constructor Create (const fileScore  : string ;
                          const fileFont   : string ;
                          const theSurface : PSDL_Surface ;
                          const StatObj    : TStats) ;

      procedure Init ; override ;

      procedure Draw ; override ;
      procedure Move ; override ;

   private
      m_theStatObj  : TStats ;
      m_Score       : integer ;
      m_screen      : PSDL_Surface ;
      CharsW8x8     : PSDL_Surface ;
      ScoreText     : PSDL_Surface ;

      ScoreRects    : array [0..6] of TSDL_Rect ;

      procedure CreateScoreString ;
   end ;

implementation

constructor TScore.Create (const fileScore  : string ;
                           const fileFont   : string ;
                           const theSurface : PSDL_Surface ;
                           const StatObj    : TStats) ;
begin
   inherited Create ('', 0, 0) ;
   ID := IDnone ;
   m_theStatObj := StatObj ;

   m_screen := theSurface ;
   CharsW8x8 := IMG_Load (PAnsiChar (fileFont)) ;
   CharsW8x8 := SDL_DisplayFormat (CharsW8x8) ;

   ScoreText := IMG_Load (PAnsiChar (fileScore)) ;
   ScoreText := SDL_DisplayFormat (ScoreText) ;

   ScoreRects [0].x := 0 ; {Info in item 0 is for the word "SCORE:"}
   ScoreRects [0].y := 0 ;
   ScoreRects [0].w := 86 ;
   ScoreRects [0].h := 12 ;

   Init ;
end ;

procedure TScore.Init ;
var
   i : integer ;

begin
   m_Score := -1 ;
   x := 0 ;  {x pos}
   y := 4 ;  {y pos}
   AnimPhase := 0 ;    {which frame to show}
   Visible := true ;  {should the sprite be visible}

   for i := 1 to 6 do
   begin
      ScoreRects [i].x := 0 ;
      ScoreRects [i].y := 0 ;
      ScoreRects [i].w := kCharW ;
      ScoreRects [i].h := kCharH ;
   end ;
end ;

procedure TScore.Draw ;
var
   Dest : TSDL_Rect ;
   i    : integer ;

begin
   CreateScoreString ;

   Dest.y := 8 ;
   Dest.x := 4 ;
   Dest.h := 12 ;
   Dest.w := 86 ;

   SDL_BlitSurface (ScoreText, @ScoreRects [0], m_screen, @Dest) ;

   Dest.w := kCharW ;

   for i := 1 to 6 do
   begin
      Dest.x := 84 + (i * kCharW) ;
      SDL_BlitSurface (CharsW8x8, @ScoreRects [i], m_screen, @Dest) ;
   end ;
end ;

procedure TScore.CreateScoreString ;
var
   i   : integer ;
   Str : string ;

begin
   if m_theStatObj.GetScore <> m_Score then
   begin
      m_Score := m_theStatObj.GetScore ;
      Str := inttostr (m_Score) ;
      Str := StringOfChar ('0', 6 - length (Str)) + Str ;

      for i := 1 to 6 do
      begin
         ScoreRects [i].x := pos (Str [i], Chars) * kCharW - kCharW ;
      end ;
   end ;
end ;

procedure TScore.Move ;
begin
end ;

end.
