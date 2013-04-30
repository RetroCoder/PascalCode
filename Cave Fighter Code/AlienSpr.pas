unit AlienSpr ;
interface

uses
   sdl, MySDLSprites, CFconsts, StatsObj ;

type
   TPos = (id_A, id_B, id_C, id_D) ;

   TAlienSprite = class (TSprite)
      constructor Create (const filename : string ;
                          const iWidth   : integer ;
                          const iHeight  : integer ;
                          const StatObj  : TStats) ;

      procedure Init ; override ;

      procedure Move ; override ;
      procedure Kill ; override ;

   private
      m_Position    : TPos ;
      m_Count       : integer ;
      m_AnimDelay   : integer ;
      m_theStatObj  : TStats ;

      procedure DoA ;
      procedure DoB ;
      procedure DoC ;
      procedure DoD ;
   end ;

implementation

constructor TAlienSprite.Create (const filename : string ;
                                 const iWidth   : integer ;
                                 const iHeight  : integer ;
                                 const StatObj  : TStats) ;
begin
   inherited Create (filename, iWidth, iHeight) ;
   ID := IDalien ;
   m_theStatObj := StatObj ;
   Init ;
end ;

procedure TAlienSprite.Init ;
begin
   AnimPhase := 0 ;    {which frame to show}
   Visible := false ;  {should the sprite be visible}
   m_Position := id_A ;
   m_Count := 0 ;
   m_AnimDelay := 0 ;
end ;

procedure TAlienSprite.Move ;
begin
   inc (m_AnimDelay) ;
   if 3 < m_AnimDelay then
   begin
      Case m_Position of
         id_A : DoA ;
         id_B : DoB ;
         id_C : DoC ;
         id_D : DoD ;
      end ;
      m_AnimDelay := 0 ;
   end ;

   dec (x, 2) ;
   if 0 <> AnimPhase then
   begin
      if 6 = AnimPhase then
      begin
         visible := false ;
         AnimPhase := 0 ;
         m_Position := id_A ;
         m_Count := 0 ;
         Exploding := false ;
      end
      else
      begin
         inc (AnimPhase) ;
      end ;
   end ;
end ;

procedure TAlienSprite.DoA ;
begin
   Dec (x, 2) ;
   Inc (y) ;
   Inc (m_Count) ;
   if 5 < m_Count then
   begin
      m_Count := 0 ;
      m_Position := id_B
   end ;
end ;

procedure TAlienSprite.DoB ;
begin
   Inc (x, 2) ;
   Inc (y) ;
   Inc (m_Count) ;
   if 5 < m_Count then
   begin
      m_Count := 0 ;
      m_Position := id_C
   end ;
end ;

procedure TAlienSprite.DoC ;
begin
   Inc (x, 2) ;
   Dec (y) ;
   Inc (m_Count) ;
   if 5 < m_Count then
   begin
      m_Count := 0 ;
      m_Position := id_D
   end ;
end ;

procedure TAlienSprite.DoD ;
begin
   Dec (x, 2) ;
   Dec (y) ;
   Inc (m_Count) ;
   if 5 < m_Count then
   begin
      m_Count := 0 ;
      m_Position := id_A
   end ;
end ;

procedure TAlienSprite.Kill ;
begin
   if 0 = AnimPhase then
   begin
      m_theStatObj.IncrementScore (100) ;
      AnimPhase := 1 ;
      Exploding := true ;
      m_theStatObj.PlayEffect (kExplode5) ;
   end ;
end ;

end.
