unit OptionsScreen ;
interface

uses
   sdl, sdl_image, CFconsts, sysutils ;

const
   kCharW = 16 ;
   kCharH = 16 ;

   Chars = '0123456789';

type
   pScoreData = ^TScoreData ;
   TScoreData = record
      Score : integer ; {This is the Hi-Score}
      Check : integer ; {This is the check code to give a bit of security}
   end ;

   TfrmOption = class
      constructor Create (theScreen : PSDL_Surface) ;
      destructor Destroy ; override ;

    private
      m_GameState  : TGameState ;
      m_HiScore    : integer ;
      m_LastScore  : integer ;

      m_screen     : PSDL_Surface ;
      m_TopImage   : PSDL_Surface ;
      m_EndGameImg : PSDL_Surface ;

      CharsW8x8    : PSDL_Surface ;

      m_TopImgRect : TSDL_Rect ;
      m_EndIMGRect : TSDL_Rect ;
      m_WonIMGRect : TSDL_Rect ;

      ScoreRects   : array [0..5] of TSDL_Rect ;

      procedure CreateScoreString (const theScore : integer) ;
      procedure DrawNumbers (xPos : integer ;
                             yPos : integer) ;
      procedure LoadHiScore ;
      procedure SaveHiScore ;
      procedure DoTheSave ;

      procedure Init ;
      procedure Draw ;

      procedure CheckKeys ;

    public
      procedure OptionLoop ;
      procedure SetHiScore (const theScore : integer) ;

      property GameState : TGameState read m_GameState write m_GameState ;
   end ;

implementation

constructor TfrmOption.Create (theScreen : PSDL_Surface) ;
begin
   inherited Create ;
   m_screen := theScreen ;
   m_GameState := gsWaiting ;
   m_LastScore := 0 ;
   Init ;
end ;

destructor TfrmOption.Destroy ;
begin
   SaveHiScore ;
   SDL_FreeSurface (m_screen) ;
   SDL_FreeSurface (m_TopImage) ;
   SDL_FreeSurface (m_EndGameImg) ;
   SDL_FreeSurface (CharsW8x8) ;
   inherited Destroy ;
end ;

procedure TfrmOption.Init ;
var
   scrTemp : PSDL_Surface ;
   Flags   : cardinal ;

begin
   Flags := SDL_HWACCEL ;

   m_HiScore := 14740 ; {Set the default value}
   LoadHiScore ;
   CreateScoreString (m_HiScore) ;

   scrTemp := IMG_Load (PChar ('data/welldone.png')) ;
   m_EndGameIMG := SDL_DisplayFormat (scrTemp) ;
   SDL_FreeSurface (scrTemp) ;

   m_EndIMGRect.x := 0 ;
   m_EndIMGRect.y := 0 ;
   m_EndIMGRect.w := 216 ; 
   m_EndIMGRect.h := 40 ;

   m_WonIMGRect.x := 0 ;
   m_WonIMGRect.y := 40 ;
   m_WonIMGRect.w := m_EndGameIMG.w ;
   m_WonIMGRect.h := 56 ;

   scrTemp := IMG_Load (PChar ('data/splashoptions.png')) ;
   m_TopImage := SDL_DisplayFormat (scrTemp) ;
   SDL_FreeSurface (scrTemp) ;

   m_TopImgRect.x := 0 ;
   m_TopImgRect.y := 0 ;
   m_TopImgRect.w := m_TopImage.w ;
   m_TopImgRect.h := m_TopImage.h ;

   SDL_SetColorKey (m_EndGameIMG, Flags, SDL_MapRGB (m_EndGameIMG.format, 255, 0, 255 )) ;
   SDL_SetColorKey (m_TopImage, Flags, SDL_MapRGB (m_TopImage.format, 255, 0, 255 )) ;

   scrTemp := IMG_Load ('data/chars_b_16x16.png') ;
   CharsW8x8 := SDL_DisplayFormat (scrTemp) ;
   SDL_FreeSurface (scrTemp) ;

   SDL_SetColorKey (CharsW8x8, Flags, SDL_MapRGB (CharsW8x8.format, 255, 0, 255 )) ;
end ;

procedure TfrmOption.Draw ;
var
   DestRect : TSDL_Rect ;

begin
   if  gsWaiting = m_GameState then
   begin
      DestRect.x := 0 ;
      DestRect.y := 0 ;
      SDL_BlitSurface (m_TopImage, @m_TopImgRect, m_screen, @DestRect) ;

      DrawNumbers (336, 396) ;
      SDL_Flip (m_screen) ;
   end
   else if gsCompleted = m_GameState then
   begin
      DestRect.x := 124 ;
      DestRect.y := 212 ;
      SDL_BlitSurface (m_EndGameImg, @m_WonIMGRect, m_screen, @DestRect) ;

      CreateScoreString (m_LastScore) ;
      DrawNumbers (384, 248) ;

      SDL_Flip (m_screen) ;
      CreateScoreString (m_HiScore) ;
      SDL_Delay (2000) ;
      m_GameState := gsWaiting
   end
   else if gsReStart  = m_GameState then
   begin
      DestRect.x := 212 ;
      DestRect.y := 230 ;
      SDL_BlitSurface (m_EndGameImg, @m_EndIMGRect, m_screen, @DestRect) ;

      CreateScoreString (m_LastScore) ;
      DrawNumbers (328, 250) ;

      SDL_Flip (m_screen) ;
      CreateScoreString (m_HiScore) ;
      SDL_Delay (2000) ;
      m_GameState := gsWaiting
   end ;
end ;

procedure TfrmOption.OptionLoop ;
begin
   {Clear the screen}
   SDL_FillRect (m_screen, nil, 0 ) ;
   SDL_Flip (m_screen) ;

   CreateScoreString (m_HiScore) ;

   while (gsStart <> m_GameState) and (gsExit <> m_GameState) do
   begin
      CheckKeys ;
      Draw ;
   end ;

   {Clear the screen}
   SDL_FillRect (m_screen, nil, 0 ) ;
   SDL_Flip (m_screen) ;
end ;

procedure TfrmOption.CheckKeys ;
var
   event : TSDL_Event ;

begin
   while (SDL_PollEvent (@event) > 0) do
   begin
      case event.type_ of
         SDL_KEYDOWN:
         begin
            case event.key.keysym.sym of
               SDLK_P:
               begin
                  m_GameState := gsStart ;
               end ;

               SDLK_Q:
               begin
                  m_GameState := gsExit ;
               end ;

               SDLK_R:
               begin
                  m_HiScore := 0 ;
                  CreateScoreString (m_HiScore) ;
               end ;
            end ;
         end ;
      end ;
   end ;
end ;

procedure TfrmOption.SetHiScore (const theScore : integer) ;
begin
   if theScore > m_HiScore then
   begin
      m_HiScore := theScore ;
   end ;
   m_LastScore := theScore ;
end ;

procedure TfrmOption.CreateScoreString (const theScore : integer) ;
var
   i   : integer ;
   Str : string ;

begin
   Str := inttostr (theScore) ;
   Str := StringOfChar ('0', 6 - length (Str)) + Str ;

   for i := 0 to 5 do
   begin
      ScoreRects [i].x := pos (Str [i + 1], Chars) * kCharW - kCharW ;
      ScoreRects [i].y := 0 ;
      ScoreRects [i].w := kCharW ;
      ScoreRects [i].h := kCharH ;
   end ;
end ;

procedure TfrmOption.DrawNumbers (xPos : integer ;
                                  yPos : integer) ;
var
   Dest : TSDL_Rect ;
   i    : integer ;

begin
   Dest.y := yPos ;
   Dest.w := kCharW ;

   for i := 0 to 5 do
   begin
      Dest.x := xPos + i * kCharW ;
      SDL_UpperBlit (CharsW8x8, @ScoreRects [i], m_screen, @Dest) ;
   end ;
end ;

procedure TfrmOption.LoadHiScore ;
var
   ARecord : pScoreData ;
   F       : file of TScoreData ;

begin
   {File can't be read only - "AssignFile" gets upset - TODO: Find a fix}
   if FileExists (kHiFileName) and (not FileIsReadOnly (kHiFileName)) then
   begin
      AssignFile (F, kHiFileName) ;
      try
         Reset (F) ;

         if not Eof (F) then
         begin
            New (ARecord) ;
            Read (F, ARecord^) ;
            {The check is to stop naughty people hacking the Hi-Score}
            if ARecord.Check = (ARecord.Score xor kSeed) then
            begin
               m_HiScore := ARecord.Score
            end ;
            Dispose (ARecord) ;
         end ;
      except
      end ;

      CloseFile (F) ;
   end ;
end ;

procedure TfrmOption.SaveHiScore ;
begin
   {Don't try to write the file if it is set to be read only}
   if not FileExists (kHiFileName) then
   begin
      DoTheSave ;
   end
   else if not FileIsReadOnly (kHiFileName) then
   begin
      DoTheSave ;
   end ;
end ;

procedure TfrmOption.DoTheSave ;
var
   ARecord : pScoreData ;
   F       : file of TScoreData ;

begin
   try
      AssignFile (F, kHiFileName) ;
      Rewrite (F) ;
      New (ARecord) ;

      ARecord^.Score := m_HiScore ;
      ARecord^.Check := ARecord.Score xor kSeed ;
      Write (F, ARecord^) ;
      CloseFile (F) ;

      Dispose (ARecord) ;
   except
      CloseFile (F) ;
   end ;
end ;

end.
