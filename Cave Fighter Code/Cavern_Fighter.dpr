{
   Copyright (C) 2004 Ian Munro

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

   Version 1.00.00
   An acrcade game by SJM Remakes. Use at your own risk. Distribute freely.
   Hints, tips, bugreports, comments to:
   sjmremakes@ntlworld.com

   History:
   07 May 2004 Release of version 1.00.00
   04 June 2004 Revised source code release
}

program Cavern_Fighter ;

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
