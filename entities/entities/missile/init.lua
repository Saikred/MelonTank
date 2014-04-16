
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetAngles( Angle( 90 , 180 , 0 ) )
	
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModel( "models/Roller.mdl" )
	
	self:PhysWake( )
	self:PhysicsInit( SOLID_VPHYSICS )

	local selfphys = self:GetPhysicsObject()
	if ( IsValid( selfphys ) ) then selfphys:SetMass( 500 ) end
	self.Created = CurTime()
end

c4boom = Sound("c4.explode")
function ENT:OnRemove( )

	local effect = EffectData()
	effect:SetStart( self:GetPos() )
	effect:SetOrigin( self:GetPos() )
	-- these don't have much effect with the default Explosion
	effect:SetScale(100)
	effect:SetRadius(100)
	effect:SetMagnitude(20)

	--   effect:SetNormal(Vector( 0 , 0 , 0 ))

	sound.Play(c4boom, self:GetPos(), 100, 100)
	util.Effect("cball_explode", effect, true, true)
	util.Effect("Explosion", effect, true, true)
	util.Effect("ThumperDust", effect, true, true)
			
	for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 130 ) ) do
		if Ent:GetClass() == "shell_basic" or Ent:GetClass() == "shell_advanced" or Ent:GetClass() == "mine" then
			timer.Simple( 0.1 , function() if IsValid( Ent ) then Ent:Remove() end end )
		end
	end
	for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 200 ) ) do
		if Ent:GetClass() == "prop_physics" and Ent:GetModel() == "models/props_junk/watermelon01.mdl" then
			Ply = Ent.Driver
			Distance = ( Ent:GetPos():Distance( self:GetPos() ) - 200 ) * -1 
			if Ply.Shield > 0 then
				Ply.Shield = Ply.Shield - Distance / 2
			else
				Ply.HP = Ply.HP - Distance / 3
				if Ply.HP <= 0 then
					local effect = EffectData()
					effect:SetStart( Ply.TankEnt:GetPos() )
					effect:SetOrigin( Ply.TankEnt:GetPos() )
					-- these don't have much effect with the default Explosion
					effect:SetScale(100)
					effect:SetRadius(100)
					effect:SetMagnitude(20)

					--   effect:SetNormal(Vector( 0 , 0 , 0 ))

					effect:SetOrigin( Ply.TankEnt:GetPos() )
					sound.Play(c4boom, self:GetPos(), 100, 100)
					util.Effect("Explosion", effect, true, true)
					util.Effect("HelicopterMegaBomb", effect, true, true)
					--Ply.MelonEnt:Remove()
					Ply.MelonEnt:SetHealth( 1 )
					util.BlastDamage( self , self, Ply.MelonEnt:GetPos(), 130 , 1 )
					Ply.TurretEnt:Ignite(9999999 , 10 ) 
				end
			end
			UpdateTank( Ply )
		end
	end

end

function ENT:OnTakeDamage( dmginfo )
	timer.Simple( 0.2 , function() if IsValid( self ) then self:Remove() end end )
end

function ENT:Think()
	if self.Created + 60 < CurTime() then 
		self:Remove()
	elseif self.Created + 3 < CurTime() then 
		for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 45 , "tankhover" ) ) do
			if Ent:GetClass() == "tankhover" or Ent:GetClass() == "mine" and Ent != self then
				self:Remove()
			end
		end

		local point = self:GetPos()
		SelfPhys = self:GetPhysicsObject()
		for _,Ent in pairs( ents.FindInSphere( self:GetPos() , 200 ) ) do
			if Ent:GetClass() == "tankhover" then
				if Ent.Driver != self.Owner then
					local Dist = ( Ent:GetPos():Distance( self:GetPos() ) * -1 + 250 ) / 200
					SelfPhys:ApplyForceCenter( (Ent:GetPos() - self:GetPos() ) * SelfPhys:GetMass() * Dist * 1.2 )
					return 
				end
			end
		end
	end

end

