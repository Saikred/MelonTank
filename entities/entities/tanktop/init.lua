
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModel( "models/hunter/blocks/cube05x075x025.mdl" )
	--self:SetModel( "models/props_wasteland/prison_heater001a.mdl" )
	
	self:PhysWake( )
	self:PhysicsInit( SOLID_VPHYSICS )

	local selfphys = self:GetPhysicsObject()
	if ( IsValid( selfphys ) ) then selfphys:SetMass( 100 ) selfphys:EnableGravity( false ) end
end

function ENT:OnRemove( )

end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo ) -- pass to physics as forces

end

function ENT:Think()



end

function ENT:PhysicsUpdate()
	local ply = self.Driver
	if ply.HP > 0 then
		if IsValid( ply.ChamberEnt ) then
			if ply.HP > 0 then
				ply.TurretEnt:SetAngles( Angle( 0 , -ply.MousePos + -45 , 0) )
			end
		end
	end
end
