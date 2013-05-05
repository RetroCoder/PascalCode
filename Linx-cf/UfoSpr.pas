unit UfoSpr ;

{$MODE Delphi}

interface

uses
   MySDLSprites, CFconsts, StatsObj ;

type
   TUFOSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_AnimDelay  : integer ;
      m_Delay      : integer ;
      m_theStatObj : TStats ;
      m_Direction  : integer ;
   end ;

implementation

constructor TUFOSprite.Create (const filename : string ;
                               const iWidth   : integer ;
                               const iHeight  : integer ;
                               const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDufo ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TUFOSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_AnimDelay := 0 ;
   m_Delay := 8 ;
   m_Direction := -1 ;
end ;

procedure TUFOSprite.Move ;
begin
   dec (x, 2) ;

   if y = HeightMin + 32 then
   begin
      m_Direction := 1 ;
   end
   else if y = HeightMax - 32 then
   begin
      m_Direction := -1 ;
   end ;
   inc (y, m_Direction) ;

   if m_Delay < m_AnimDelay then
   begin
      m_AnimDelay := 0 ;

      if 9 <> AnimPhase then
      begin
         inc (AnimPhase) ;
      end
      else
      begin
         Visible := false ;
         m_Delay := 8 ;
         Exploding := false ;
      end ;

      if 3 = AnimPhase then
      begin
         AnimPhase := 0 ;
      end ;
   end
   else
   begin
      inc (m_AnimDelay) ;
   end ;
end ;

procedure TUFOSprite.Kill ;
begin
   if 4 > AnimPhase then
   begin
      m_theStatObj.IncrementScore (100) ;
      AnimPhase := 4 ;
      m_Delay := 2 ;
      Exploding := true ;
      m_theStatObj.PlayEffect (kExplode3) ;
   end ;
end ;

end.
