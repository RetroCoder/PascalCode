unit AstroSpr ;

{$MODE Delphi}

interface

uses
   MySDLSprites, CFconsts, StatsObj ;

type
   TAstroSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_AnimDelay   : integer ;
      m_theStatObj  : TStats ;
   end ;

implementation

constructor TAstroSprite.Create (const filename : string ;
                                 const iWidth   : integer ;
                                 const iHeight  : integer ;
                                 const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDastro ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TAstroSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
end ;

procedure TAstroSprite.Move ;
begin
   dec (x, 6) ;
   
   if x < -16 then
   begin
      visible := false ;
   end
   else
   begin
      if 0 <> AnimPhase then
      begin
         inc (y) ;
         if 3 < m_AnimDelay then
         begin
            m_AnimDelay := 0 ;

            if 5 = AnimPhase then
            begin
               visible := false ;
               AnimPhase := 0 ;
            end
            else
            begin
               inc (AnimPhase) ;
            end ;
         end
         else
         begin
            inc (m_AnimDelay) ;
         end ;
      end ;
   end ;
end ;

procedure TAstroSprite.Kill ;
begin
   if 0 = AnimPhase then
   begin
      m_theStatObj.IncrementScore (20) ;
      AnimPhase := 1 ;
      m_theStatObj.PlayEffect (kExplode1) ;
   end ;
end ;

end.
