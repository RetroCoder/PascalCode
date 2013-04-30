unit DataEngine ;
interface

uses
   Classes, sdl, MySDLSprites, CFconsts, StatsObj ;
   
type
   TDataEngine = class (TSpriteEngine)
    private
      m_SpriteEngine : TSpriteEngine ;
      m_StatObj      : TStats ;

      m_DataList     : TList ;

      m_LocalZone    : integer ;
      m_iFrameCount  : integer ;
      m_iScreenCount : integer ;
      m_DataPointer  : integer ;
      m_MissilePtr   : integer ;
      m_BasePtr      : integer ;
      m_FuelPtr      : integer ;
      m_AlienPtr     : integer ;
      m_ZonePtr      : integer ;
      m_UfoPtr       : integer ;
      m_RadarPtr     : integer ;
 
      procedure UpdatePointer (var thePointer : integer ;
                               const iMax     : integer) ;

      procedure DoMissile (const YPos : integer ;
                           const YMax : integer) ;
      procedure DoBase (const YPos : integer) ;
      procedure DoStation (const YPos : integer) ;
      procedure DoFuel (const YPos : integer) ;
      procedure DoAlien (const YPos : integer) ;
      procedure DoAstro (const YPos : integer) ;
      procedure DoZone (const YPos : integer) ;
      procedure DoUfo (const YPos : integer ;
                       const YMin : integer ;
                       const YMax : integer) ;
      procedure DoRadar (const YPos : integer) ;

      procedure Init ;

    public
      m_Surface : PSDL_Surface ;
      procedure ResetGameData ;
      procedure SetScreenToStartOfZone ;
      procedure KillAllButShip ;

      procedure ScrollBackground ;
      procedure LoadData (const sFile : string) ;

      constructor Create (const surface : PSDL_Surface ;
                          const stats   : TStats);
      destructor Destroy ; override ;
   end ;

implementation

constructor TDataEngine.Create (const surface : PSDL_Surface ;
                                const stats   : TStats) ;
begin
   m_SpriteEngine := inherited Create (surface) ;
   m_Surface := surface ;
   m_StatObj := stats ;
   m_DataList := TList.Create ;

   Init ;
end ;

destructor TDataEngine.Destroy ;
var
   ARecord : pSpriteData ;
   i       : integer ;

begin
   for i := 0 to (m_DataList.Count - 1) do
   begin
     ARecord := m_DataList.Items [i] ;
     Dispose (ARecord) ;
   end ;
   m_DataList.Free ;

   inherited destroy ;
end ;

{-----------------------------------------------------------------------------}
procedure TDataEngine.Init ;
begin
   m_iFrameCount := 15 ;  {set this to the max value so that the sprite load (0 to 15 = 16 the width of the cave wall sprite)}
   m_LocalZone := 1 ;     {When the game starts we will be in zone 1}
   m_iScreenCount := 40 ;
   m_DataPointer := 0 ;
   m_MissilePtr := 0 ;
   m_FuelPtr := 0 ;
   m_AlienPtr := 0 ;
   m_ZonePtr := 0 ;
   m_UfoPtr := 0 ;
   m_RadarPtr := 0 ;
end ;

procedure TDataEngine.ResetGameData ;
var
   i : integer ;

begin
   Init ;

   for i := 0 to  m_SpriteEngine.Sprites.Count - 1 do
   begin
      m_SpriteEngine.Sprites.Items [i].Init ;
   end ;
end ;

procedure TDataEngine.LoadData (const sFile : string) ;
var
   ARecord : pSpriteData ;
   F       : file of TSpriteData ;

begin
   AssignFile (F, sFile) ;
   Reset (F) ;
   try
      while not Eof (F) do
      begin
         New (ARecord) ;
         Read (F, ARecord^) ;
         m_DataList.Add (ARecord) ;
      end ;

   finally
      CloseFile (F) ;
   end ;
end ;

procedure TDataEngine.ScrollBackground ;
var
   ARecord : pSpriteData ;

begin
   m_SpriteEngine.MoveAll ;

   if 15 <> m_iFrameCount then 
   begin
      inc (m_iFrameCount) ;
   end
   else
   begin
      m_iFrameCount := 0 ;
      if 40 = m_iScreenCount then
      begin
         m_iScreenCount := 0 ;
      end
      else
      begin
         inc (m_iScreenCount, 2) ;
      end ;

      ARecord := m_DataList [m_DataPointer] ;

      with m_SpriteEngine do
      begin
         Sprites [m_iScreenCount].y := ARecord^.Spr1Pos ;
         Sprites [m_iScreenCount].x := 640 ;
         Sprites [m_iScreenCount].AnimPhase := ARecord^.Spr1  ;

         Sprites [m_iScreenCount + 1].y := ARecord^.Spr2Pos ;
         Sprites [m_iScreenCount + 1].x := 640 ; 
         Sprites [m_iScreenCount + 1].AnimPhase := ARecord^.Spr2 ;
         m_StatObj.SetLevel (ARecord^.Level, m_dataPointer, ARecord) ;

         if 0 <> ARecord^.Spr3Pos then
         begin
            case ARecord^.Spr3 of
               1 : DoMissile (ARecord^.Spr3Pos, ARecord^.Spr1Pos) ;
               2 : DoBase (ARecord^.Spr3Pos) ;
               3 : DoFuel (ARecord^.Spr3Pos) ;
               4 : DoAlien (ARecord^.Spr3Pos) ;
               5 : DoStation (ARecord^.Spr3Pos) ;
               6 : DoAstro (ARecord^.Spr3Pos) ;
               7 : DoZone (ARecord^.Spr3Pos) ;
               8 : DoUfo (ARecord^.Spr3Pos, ARecord^.Spr1Pos, ARecord^.Spr2Pos) ;
               9 : DoRadar (ARecord^.Spr3Pos) ;
            end ;

            if 0 <> ARecord^.Spr4Pos then
            begin
               case ARecord^.Spr4 of
                  1 : DoMissile (ARecord^.Spr4Pos, ARecord^.Spr1Pos) ;
                  2 : DoBase (ARecord^.Spr4Pos) ;
                  3 : DoFuel (ARecord^.Spr4Pos) ;
                  4 : DoAlien (ARecord^.Spr4Pos) ;
                  5 : DoStation (ARecord^.Spr4Pos) ;
                  6 : DoAstro (ARecord^.Spr4Pos) ;
                  7 : DoZone (ARecord^.Spr4Pos) ;
                  8 : DoUfo (ARecord^.Spr4Pos, ARecord^.Spr1Pos, ARecord^.Spr2Pos) ;
                  9 : DoRadar (ARecord^.Spr4Pos) ;
               end ;
            end ;
         end ;
     end ;
     inc (m_dataPointer) ;
   end ;
end ;

procedure TDataEngine.DoMissile (const YPos : integer ;
                                 const YMax : integer) ;
begin
   Sprites [kMissile + m_MissilePtr].y := YPos ;
   Sprites [kMissile + m_MissilePtr].x := 642 ;
   Sprites [kMissile + m_MissilePtr].Visible := true ;
   Sprites [kMissile + m_MissilePtr].HeightMax := YMax + 16 ;
   UpdatePointer (m_MissilePtr, 6) ;
end ;

procedure TDataEngine.DoBase (const YPos : integer) ;
begin
   Sprites [kBase + m_BasePtr].y := YPos ;
   Sprites [kBase + m_BasePtr].x := 642 ;
   Sprites [kBase + m_BasePtr].Visible := true ;
   UpdatePointer (m_BasePtr, 5) ;
end ;

procedure TDataEngine.DoStation (const YPos : integer) ;
begin
   Sprites [kStation].y := YPos ;
   Sprites [kStation].x := 640 ;
   Sprites [kStation].Visible := true ;
end ;

procedure TDataEngine.DoFuel (const YPos : integer) ;
begin
   Sprites [kFuel + m_FuelPtr].y := YPos ;
   Sprites [kFuel + m_FuelPtr].x := 642 ;
   Sprites [kFuel + m_FuelPtr].Visible := true ;
   UpdatePointer (m_FuelPtr, 3) ;
end ;

procedure TDataEngine.DoAlien (const YPos : integer) ;
begin
   Sprites [kAlien + m_AlienPtr].y := YPos ;
   Sprites [kAlien + m_AlienPtr].x := 640 ;
   Sprites [kAlien + m_AlienPtr].Visible := true ;
   UpdatePointer (m_AlienPtr, 5) ;
end ;

procedure TDataEngine.DoAstro (const YPos : integer) ;
begin
   Sprites [kAstro].y := YPos ;
   Sprites [kAstro].x := 640 ;
   Sprites [kAstro].Visible := true ;
end ;

procedure TDataEngine.DoZone (const YPos : integer) ;
begin
   Sprites [kZone].y := YPos ;
   Sprites [kZone].x := 640 ;
   Sprites [kZone].Visible := true ;
end ;

procedure TDataEngine.DoUfo (const YPos : integer ;
                             const YMin : integer ;
                             const YMax : integer) ;
begin
   Sprites [kUfo + m_UfoPtr].y := YPos ;
   Sprites [kUfo + m_UfoPtr].x := 640 ;
   Sprites [kUfo + m_UfoPtr].Visible := true ;
   Sprites [kUfo + m_UfoPtr].HeightMin := YMin ;
   Sprites [kUfo + m_UfoPtr].HeightMax := YMax ;
   UpdatePointer (m_UfoPtr, 3) ;
end ;

procedure TDataEngine.DoRadar (const YPos : integer) ;
begin
   Sprites [kRadar + m_RadarPtr].y := YPos ;
   Sprites [kRadar + m_RadarPtr].x := 642 ;
   Sprites [kRadar + m_RadarPtr].Visible := true ;
   UpdatePointer (m_RadarPtr, 3) ; 
end ;

procedure TDataEngine.UpdatePointer (var thePointer : integer ;
                                     const iMax     : integer) ;
begin
   if iMax = thePointer then
   begin
      thePointer := 0 ;
   end
   else
   begin
      inc (thePointer) ;
   end ;
end ;

procedure TDataEngine.SetScreenToStartOfZone ;
var
   i : integer ;

begin
   m_DataPointer := m_StatObj.GetStartLevel ;
   
   for i := 1 to 320 do {640 div 2 (2 = pixel scroll)}
   begin
      ScrollBackground ;
   end ;
end ;

procedure TDataEngine.KillAllButShip ;
var
   i : integer ;

begin
   Init ;

   for i := 0 to  m_SpriteEngine.Sprites.Count - 1 do
   begin
      if kShipListPos <> i then
      begin
         m_SpriteEngine.Sprites.Items [i].Kill ;
      end ;
   end ;
end ;

end.
