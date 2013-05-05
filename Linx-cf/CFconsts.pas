unit CFconsts ;

{$MODE Delphi}

interface

type
   TSpriteID = (IDnone, IDcave, IDmissile, IDbomb, IDship, IDfuel, IDbase, IDlaser,
                IDalien, IDastro, IDzone, IDufo, IDradar, IDBang) ;

   TGameState = (gsRunning, gsWaiting, gsLostLife, gsReStart, gsExit, gsStart, gsDestroyCave, gsCompleted) ;

   pSpriteData = ^TSpriteData ;
   TSpriteData = record
      Spr1    : byte ;
      Spr1Pos : word ;
      Spr2    : byte ;
      Spr2Pos : word ;
      Spr3    : byte ;
      Spr3Pos : word ;
      Spr4    : byte ;
      Spr4Pos : word ;
      Level   : byte ;
   end ;

Const
   kFPS      = 50 ;
   
   kMaxLives = 3 ;
   kMaxFuel  = 384 ;
   kMinFuel  = 78 ;

 {Sprites}
   kMissile   = 42 ;
   kBase      = 49 ;
   kFuel      = 55 ;
   kAlien     = 59 ;
   kUfo       = 65 ;
   kRadar     = 69 ;
   kStation   = 73 ;
   kAstro     = 74 ;
   kZone      = 75 ;
   kLives     = 76 ;
   kSector    = 77 ;
   kFuelGauge = 78 ;
   kScore     = 79 ;

 {pointers}
   kLaserListPos = 80 ;
   kShipListPos  = 81 ;
   kBombPos      = 82 ;
   kBangPos      = 83 ;

 {Sounds}
   kIntro    = 0 ;
   kInGame   = 1 ;

   kLaser    = 0 ;
   kLiftOff  = 1 ;
   kExplode1 = 2 ;
   kExplode2 = 3 ;
   kExplode3 = 4 ;
   kExplode4 = 5 ;
   kExplode5 = 6 ;
   kExplode6 = 7 ;
   kExplode7 = 8 ;

 {Hi Score}
   kHiFileName = 'data/score.dat' ;
   kSeed = 38456 ;
   
implementation
end.
