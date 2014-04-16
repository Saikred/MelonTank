
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetAngles( Angle( 90 , 180 , 0 ) )
	
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModel( "models/props_junk/garbage_milkcarton002a.mdl" )
	
	self:PhysWake( )
	self:PhysicsInit( SOLID_VPHYSICS )

	local selfphys = self:GetPhysicsObject()
	if ( IsValid( selfphys ) ) then selfphys:SetMass( 500 ) end
	self.Created = CurTime()
	if self.Owner.TeamColour == "Red" then self.EnemyCol = "Blue" else self.EnemyCol = "Red" end 
	self.InitPos = self:GetPos()
	local TargetList = ents.FindByClass( "tankhover" )
	for k,v in pairs( TargetList ) do
		if v.Driver.HP and v.Driver.TeamColour != self.EnemyCol and v.Driver.HP > 0 then
			table.remove( TargetList , k )
		end
	end
	if #TargetList < 1 then
		self.FirstPos = self.InitPos + Vector( 0 , 0 , 300 )
		self.SecondPos = self.InitPos + Vector( 0 , 0 , 600 )
		self.TargetPos = self.InitPos + Vector( 0 , 0 , 900 )
	else
		self.TargetPos = table.Random( TargetList ):GetPos()
		self.FirstPos = self.InitPos + Vector( 0 , 0 , 200 )
		self.SecondPos = self.TargetPos + Vector( 0 , 0 , 250 )
	end
	self.Next = 1
	
	local trail = util.SpriteTrail(self, 0, Color(0,255,0), true, 20, 1, 1, 1/(15+1)*0.5, "trails/plasma.vmt")
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
	if self.TargetPos:Distance( self:GetPos() ) < 60 then self:Remove() end
	
	local mul = 0.4
	local TargetPos
	if self.Next == 1 then
		TargetPos = self.FirstPos
		mul = 1.1
		if self:GetPos():Distance( self.FirstPos ) < 75 then self.Next = 2 end
	elseif self.Next == 2 then
		TargetPos = self.SecondPos 
		mul = 0.5
		if self:GetPos():Distance( self.SecondPos  ) < 20 then self.Next = 3 end
	elseif self.Next == 3 then
		TargetPos = self.TargetPos 
		mul = 0.5
		print( self:GetPos():Distance( self.TargetPos  ) )
		if self:GetPos():Distance( self.TargetPos  ) < 75 then self:Remove() return false end
		
	else
		return
	end	
	SelfPhys = self:GetPhysicsObject()
	SelfPhys:ApplyForceCenter( ( TargetPos - self:GetPos() ) * SelfPhys:GetMass() * mul )
	
	if self.Created + 3 < CurTime() then 
		self:Remove()
	end

end

