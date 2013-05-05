unit Lives ;

{$MODE Delphi}

interface

uses
   SDL, MySDLSprites, CFconsts, StatsObj ;

type
   TLives = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Move ; override ;
      procedure Init ; override ;
   private
      m_theStatObj : TStats ;
   end ;

implementation

constructor TLives.Create (const filename : string ;
                           const iWidth   : integer ;
                           const iHeight  : integer ;
                           const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDnone ;
   m_theStatObj := StatObj ;
   init ;
end ;

procedure TLives.Init ;
begin
   x := 430 ;  {x pos}
   y := 4 ;  {y pos}
   AnimPhase := m_theStatObj.GetLife  ;    {which frame to show}
   Visible := true ;  {should the sprite be visible}
end ;

procedure TLives.Move ;
begin
end ;

end.
