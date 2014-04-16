
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Contactacted = 0

function ENT:Initialize()
		

	self.created = CurTime()
	self:SetMoveType( MOVETYPE_FLY )
	self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	
	timer.Simple( 20 , function() self:Remove() end )
end

function ENT:OnRemove( )

end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo ) -- pass to physics as forces

end

function ENT:Think()


if CurTime() - self.created > 5 then self:Remove() end

end
