program Cavern_Fighter ;

{$MODE Delphi}

uses
  MySDLSprites in 'MySDLSprites.pas',
  DataEngine in 'DataEngine.pas',
  CaveSpr in 'CaveSpr.pas',
  ShipSpr in 'ShipSpr.pas',
  MissileSpr in 'MissileSpr.pas',
  BaseSpr in 'BaseSpr.pas',
  LaserSpr in 'LaserSpr.pas',
  FuelSpr in 'FuelSpr.pas',
  mainUnit in 'mainUnit.pas',
  BombSpr in 'BombSpr.pas',
  AlienSpr in 'AlienSpr.pas',
  BaseStationSpr in 'BaseStationSpr.pas',
  FuelGuage in 'FuelGuage.pas',
  CFconsts in 'CFconsts.pas',
  AstroSpr in 'AstroSpr.pas',
  SplashScreen in 'SplashScreen.pas',
  OptionsScreen in 'OptionsScreen.pas',
  Lives in 'Lives.pas',
  Sector in 'Sector.pas',
  Score in 'Score.pas',
  StatsObj in 'StatsObj.pas',
  ZoneSpr in 'ZoneSpr.pas',
  Tools in 'Tools.pas',
  UfoSpr in 'UfoSpr.pas',
  RadarSpr in 'RadarSpr.pas',
  BangSpr in 'BangSpr.pas';

var
   theGame : TMainGame ;
   splash  : TfrmSplash ;
   options : TfrmOption ;

begin
   randomize ;

   theGame := TMainGame.Create ;
   if gsExit <> theGame.GetGameState then
   begin
      splash := TfrmSplash.Create (theGame.GetSurface) ;
      options := TfrmOption.Create (theGame.GetSurface) ;

      options.SetHiScore (theGame.GetHiScore) ;
      splash.SplashLoop ;
      options.OptionLoop ;

      while gsExit <> options.GameState do
      begin
         theGame.Init ;
         theGame.GameLoop ;

         if gsCompleted = theGame.GetGameState then
         begin
            options.GameState := gsCompleted ;
            // TODO: Do something as the user has won
         end
         else
         begin
            options.GameState := gsReStart ;
         end ;

         options.SetHiScore (theGame.GetHiScore) ;
         options.OptionLoop ;
      end ;

      options.Destroy ;
      splash.Destroy ;
   end ;
   theGame.CloseGameWindow ;
end.
