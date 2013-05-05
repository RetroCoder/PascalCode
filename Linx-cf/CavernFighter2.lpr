program CavernFighter2 ;

{$MODE Delphi}

uses
  SysUtils,
  {LCLIntf, LCLType, LMessages,  }
  SDL,
  MainGameUnit in 'MainGameUnit.pas',
  ScreenMain in 'ScreenMain.pas',
  CaveSprite in 'CaveSprite.pas',
  DataEngine in 'DataEngine.pas',
  GameManager in 'GameManager.pas';

var
   CavernFighter : TMainGame ;

begin
   try
      SDL_Init (SDL_INIT_VIDEO) ;

      CavernFighter := TMainGame.Create ;
      
      CavernFighter.GameLoop ;

   except
      on E : Exception do
      begin
         MessageBox (0, PChar ('Catastrophic failure: ' + E.Message), 'Error', MB_OK + MB_ICONERROR) ;
      end ;
   end ;

   CavernFighter.Free ;
   SDL_Quit ;
end.
