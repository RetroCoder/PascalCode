unit SplashScreen ;
interface

uses
   sdl, sdl_image, CFconsts ;

type
   TfrmSplash = class
      constructor Create (theScreen : PSDL_Surface) ;
      destructor Destroy ; override ;

    private
      m_splashState : TGameState ;

      m_screen      : PSDL_Surface ;
      m_TopImage    : PSDL_Surface ;
      m_BotImage    : PSDL_Surface ;

      m_TopImgRect  : TSDL_Rect ;
      m_BotImgRect  : TSDL_Rect ;

      m_x     : integer ;
      m_count : integer ;

      procedure Init ;
      procedure Draw ;

      procedure CheckKeys ;

    public
      procedure SplashLoop ;
   end ;

implementation

constructor TfrmSplash.Create (theScreen : PSDL_Surface) ;
begin
   inherited Create ;
   m_screen := theScreen ;
   Init ;
end ;

destructor TfrmSplash.Destroy ;
begin
   SDL_FreeSurface (m_screen) ;
   SDL_FreeSurface (m_TopImage) ;
   SDL_FreeSurface (m_BotImage) ;
   
   inherited Destroy ;
end ;

procedure TfrmSplash.Init ;
var
   scrTemp : PSDL_Surface ;
   Flags   : cardinal ;

begin
   Flags := SDL_DOUBLEBUF or SDL_HWPALETTE or SDL_HWSURFACE or SDL_FullScreen ;

   scrTemp := IMG_Load (PChar ('data/splashlogo.png')) ;
   m_TopImage := SDL_DisplayFormat (scrTemp) ;
   SDL_FreeSurface (scrTemp) ;

   m_TopImgRect.x := 0 ;
   m_TopImgRect.y := 0 ;
   m_TopImgRect.w := m_TopImage.w ;
   m_TopImgRect.h := m_TopImage.h ;

   scrTemp := IMG_Load (PChar ('data/splashpoints.png')) ;
   m_BotImage := SDL_DisplayFormat (scrTemp) ;
   SDL_FreeSurface (scrTemp) ;

   m_BotImgRect.x := 0 ;
   m_BotImgRect.y := 0 ;
   m_BotImgRect.w := m_BotImage.w ;
   m_BotImgRect.h := m_BotImage.h ;

   SDL_SetColorKey (m_TopImage, Flags, SDL_MapRGB (m_TopImage.format, 255, 0, 255 )) ;
   m_TopImage := SDL_DisplayFormat (m_TopImage) ;
   SDL_SetColorKey (m_BotImage, Flags, SDL_MapRGB (m_BotImage.format, 255, 0, 255 )) ;
   m_BotImage := SDL_DisplayFormat (m_BotImage) ;

end ;

procedure TfrmSplash.Draw ;
var
   DestRect : TSDL_Rect ;

begin
   DestRect.x := 0 ;

   if 250 > m_count then
   begin
     DestRect.y := 450 + m_x ;
   end
   else
   begin
      DestRect.y := 0 -50;
   end ;

   SDL_BlitSurface (m_BotImage, @m_BotImgRect, m_screen, @DestRect) ;

   if 120 = m_count then
   begin
      SDL_Delay (3000) ;
   end ;

   DestRect.x := 0 ;
   if 120 > m_count then
   begin
      DestRect.y := m_x ;
   end
   else
   begin
      DestRect.y := -238 ;
   end ;

   SDL_BlitSurface (m_TopImage, @m_TopImgRect, m_screen, @DestRect) ;

   SDL_Flip (m_screen) ;

   dec (m_x, 2) ;
   inc (m_count) ;
end ;

procedure TfrmSplash.SplashLoop ;
begin
   m_splashstate := gsWaiting ;
   m_x := 0 ;
   m_count := 0 ;

   Draw ;
   SDL_Delay (1000) ;
   
   while gsWaiting = m_splashState do
   begin
      CheckKeys ;
      Draw ;
      
      if 120 > m_count then
      begin
         SDL_Delay (10) ;
      end
      else
      begin
         SDL_Delay (30) ;
      end ;
   end ;

   {Clear the screen}
   SDL_FillRect (m_screen, nil, 0 ) ;
   SDL_Flip (m_screen) ;
end ;

procedure TfrmSplash.CheckKeys ;
var
   Event : TSDL_Event ;

begin
   while SDL_PollEvent (@Event) > 0 do
   begin
      if Event.key.type_ = SDL_KeyDown then
      begin
         m_splashState := gsExit ;
      end ;
   end ;
end ;

end.
