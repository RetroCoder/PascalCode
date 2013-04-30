unit CaveSpr ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TCaveSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;
      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_theStatObj : TStats ;
      m_Delay      : integer ;
   end ;

implementation

constructor TCaveSprite.Create (const filename : string ;
                                const iWidth   : integer ;
                                const iHeight  : integer ;
                                const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight, SDL_HWACCEL) ;
   ID := IDcave ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TCaveSprite.Init ;
begin
   AnimPhase := 22 ; {which frame to show NB 22 = no picture}
   Visible := true ; {should the sprite be visible}
   m_Delay := 0 ;
end ;

procedure TCaveSprite.Move ;
begin
   dec (x, 2) ;

   if 67 < AnimPhase then
   begin
     if 75 = AnimPhase then
      begin
         visible := false ;
         AnimPhase := 22 ;
      end
      else
      begin
         inc (m_Delay) ;
         if 3 = m_Delay then
         begin
            inc (AnimPhase) ;
            m_Delay := 0 ;
         end ;
      end ;
   end ;
end ;

procedure TCaveSprite.Kill ;
begin
   if gsCompleted = m_theStatObj.GetGameState then
   begin
      AnimPhase := 68 ;
   end ;
end ;

end.
