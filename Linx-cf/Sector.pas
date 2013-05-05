unit Sector ;

{$MODE Delphi}

interface

uses
  SDL, MySDLSprites, CFconsts, StatsObj ;

type

   TSector = class (TSprite)
      m_AnimCounter : integer ;

      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;

   private
      m_theStatObj : TStats ;
   end ;

implementation

constructor TSector.Create (const filename : string ;
                            const iWidth   : integer ;
                            const iHeight  : integer ;
                            const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   m_theStatObj := StatObj ;
   ID := IDnone ;
   Init ;
end ;

procedure TSector.Init ;
begin
   x := 430 ;  {x pos}
   y := 33 ;  {y pos}
   AnimPhase := 0 ;    {which frame to show}
   Visible := true ;  {should the sprite be visible}
end ;

procedure TSector.Move ;
begin
   AnimPhase := m_theStatObj.GetLevel ;
end ;

end.
