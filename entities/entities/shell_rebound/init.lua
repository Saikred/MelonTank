
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Contactacted = 0

function ENT:Initialize()
	self.Created = CurTime()
	self:SetMoveType( MOVETYPE_FLY )
	--self:SetAngles( Angle( 90 , self:GetAngles().yaw , 0 ) )
	self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	
	self:PhysWake( )
	self:PhysicsInit( SOLID_VPHYSICS )
	local selfphys = self:GetPhysicsObject()
	if ( IsValid( selfphys ) ) then selfphys:Wake() selfphys:SetMass( 20 ) selfphys:EnableGravity( false )  end
	--timer.Simple( 20 , function() self:Remove() end )
	local trail = util.SpriteTrail(self, 0, Color(0,150,250), false, 25, 1, 1, 1/(15+1)*0.5, "trails/plasma.vmt")
	timer.Simple( 10 , function() if IsValid( self ) then self:Remove() end end )
end

c4boom = Sound("c4.explode")
function ENT:OnRemove( )
	for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 130 ) ) do
		if Ent:GetClass() == "shell_basic" or Ent:GetClass() == "shell_advanced" or Ent:GetClass() == "mine" or Ent:GetClass() == "mine_time" or Ent:GetClass() == "shell_rebound" or Ent:GetClass() == "shell_fast" then
			timer.Simple( 0.1 , function() if IsValid( Ent ) then Ent:Remove() end end )
		end
	end
	for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 200 ) ) do
		if Ent:GetClass() == "prop_physics" and Ent:GetModel() == "models/props_junk/watermelon01.mdl" then
			Ply = Ent.Driver
			Distance = ( Ent:GetPos():Distance( self:GetPos() ) - 200 ) * -1 
			if Ply.Shield > 0 then
				Ply.Shield = Ply.Shield - Distance / 3
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

	--[[local tr = util.TraceLine( {
		start = self:GetPos() + self:GetAngles():Up() * -20,
		endpos = self:GetPos() + self:GetAngles():Up() * -35
	} )
	if tr.Hit then
		timer.Simple( 0.05 , function() if IsValid( self ) then self:Remove() end end )
	end]]
	
	if CurTime() - self.Created > 0.4 then
		for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 60 , "tankhover" ) ) do
			if Ent:GetClass() == "tankhover" or Ent:GetClass() == "mine" or Ent:GetClass() == "mine_time" then
				self:Remove()
			end
		end
	end
	
	
end


function ENT:PhysicsSimulate( phys, deltatime )
	local hoverheight 	= 20
	local point = self:GetPos()

	local TraceIgnore = ents.FindByClass( "tanktop" )
	local TraceIgnore = ents.FindByClass( "tanktop" )
	table.insert( TraceIgnore , self )
	local tr = util.TraceLine( {
		start = point,
		endpos = point - Vector( 0, 0, hoverheight ),
		filter = TraceIgnore,
		mask = bit.bor( MASK_SOLID , MASK_WATER ),
	} )
	
	local SelfAngForce = Vector( 0 , 0 , 0 )
	
	local SelfAddForce = ( Vector(0,0,1) * ( ( tr.HitPos.z + hoverheight - self:GetPos().z ) / 2 ) * phys:GetMass() * 10 )
	return SelfAngForce, SelfAddForce, SIM_GLOBAL_ACCELERATION
	--phys:AddAngleVelocity( SelfAngForce )
	--phys:ApplyForceCenter( SelfAddForce )
end
ENT.Bounce = 0
function ENT:PhysicsCollide( data, physobj )
if self.Bounce > 2 then self:Remove() end
self.Bounce = self.Bounce + 1
	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

	local TargetVelocity = NewVelocity * LastSpeed * 1.1

	physobj:SetVelocity( TargetVelocity )

end