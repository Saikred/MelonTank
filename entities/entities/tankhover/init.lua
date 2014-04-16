
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetAngles( Angle( -90 , 180 , 0 ) )
		
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetModel( "models/props_interiors/Radiator01a.mdl" )
	
	self:PhysWake()
	self:PhysicsInit( SOLID_VPHYSICS )

	local selfphys = self:GetPhysicsObject()
	selfphys:SetMass( 750 )
	
	
	self:StartMotionController()
end

function ENT:OnRemove( )

	self:StopMotionController()
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo ) -- pass to physics as forces

end

function ENT:Think()
	if self.Driver.Chopper then
		if not self.ZTarget then
			self.ZTarget = self:GetPos().z + 100
			
			--[[
			self.Driver.PropEnt = ents.Create( "prop_physics" )
			self.Driver.PropEnt:SetPos( self.Driver.TankEnt:GetPos() + Vector( 0 , 0 , 30 ) )
			self.Driver.TankEnt:DeleteOnRemove( self.Driver.PropEnt )
			self.Driver.PropEnt.Driver = self.Driver
			self.Driver.PropEnt:SetModel( "models/props_phx/misc/propeller2x_small.mdl" )
			self.Driver.PropEnt:Spawn()
			
			local Constraint = ents.Create("phys_hinge")
			Constraint:SetPos( self.Driver.PropEnt:GetPos() )
			Constraint:SetKeyValue( "hingeaxis", tostring( self.Driver.TankEnt:GetPos() ) ) 
			Constraint:SetKeyValue( "spawnflags", 1 )
			Constraint:SetPhysConstraintObjects( self.Driver.TankEnt:GetPhysicsObject(), self.Driver.PropEnt:GetPhysicsObject() )
			Constraint:Spawn()
			Constraint:Activate()
				
			self.Driver.TankEnt:PhysWake()
			self.Driver.TurretEnt:PhysWake()]]
		end
			
		local efd = EffectData()
		efd:SetEntity( self )
		efd:SetRadius(20)
		efd:SetMagnitude( math.Clamp( 50 , 50 , 50 ) )
		efd:SetScale( 0.8 )
		util.Effect("chopper_prop", efd)
	elseif self.ZTarget then
		self.ZTarget = false
		--if IsValid( self.Driver.PropEnt ) then self.Driver.PropEnt:Remove() end
	end
	if self.Driver.Shield > 0 then
		local efd = EffectData()
		efd:SetOrigin(self:GetPos())
		efd:SetEntity( self )
		efd:SetRadius(50)
		efd:SetMagnitude( math.Clamp( self.Driver.Shield / 20 , 0.2 , 1 ) )
		efd:SetScale( 1 )
		util.Effect("shield_sphere", efd)
	elseif self.Driver.HP > 0 and self.Driver.HP < 55 and math.random( 1 , self.Driver.HP / 5 ) == 1 then
	
		local efd = EffectData()
		efd:SetOrigin(self:GetPos())
		efd:SetEntity( self )
		efd:SetRadius(5)
		efd:SetMagnitude( 2 )
		efd:SetScale( 1 )
		util.Effect("Sparks", efd)
	end
	
	if self.Driver.HP > 0 then
		local efd = EffectData()
		efd:SetOrigin(self:GetPos())
		efd:SetEntity( self )
		efd:SetRadius(0.5)
		efd:SetMagnitude( 1 )
		efd:SetScale( 30 )
		util.Effect("ThumperDust", efd)
	end
end

ENT.TargetAngles = Angle( 0 , 25 , 0 )
function ENT:PhysicsSimulate( phys, deltatime )
	if not ( self.Driver.HP > 0 ) then return end 
	local hoverheight 	= 60
	local point = self:GetPos()

	-- trace
--		local TraceIgnore = ents.FindByClass( "tanktop" )
	--	local TraceIgnore = ents.FindByClass( "mine_time" )
	--	table.insert( TraceIgnore , self )
		--filter = TraceIgnore,
	local tr = util.TraceLine( {
		start = point - Vector( 0 , 0 , 5 )
		,endpos = point - Vector( 0, 0, hoverheight )
		,filter = function( ent ) if not ( ent == game.GetWorld() ) then return true end end
		,mask = bit.bor( MASK_SOLID , MASK_WATER )
	} )
	
	-- did we hit water?
	if ( tr.MatType == MAT_SLOSH ) then
	
	end
	
	local SelfAng = phys:GetAngles()
	--local SelfAddForce = Vector( 0 , 0 , -500 )
	local SelfAddForce = Vector( 0 , 0 , 0 )
	local SelfAngForce = Vector( 0 , 0 , 0 )
	SelfAng:RotateAroundAxis( SelfAng:Right() , -90 )
	
	if self.Driver.Chopper and self.ZTarget then
		SelfAddForce = SelfAddForce + ( Vector(0,0,1) * ( ( self.ZTarget + hoverheight - self:GetPos().z ) / 2 ) * phys:GetMass() * 0.05 )
	else
		SelfAddForce = SelfAddForce + ( Vector(0,0,1) * ( ( tr.HitPos.z + hoverheight - self:GetPos().z ) / 2 ) * phys:GetMass() * 0.05 )
	end
	phys:AddVelocity( -phys:GetVelocity() / 15 ) 

	if self.Driver:KeyDown( IN_FORWARD ) then
		if self.Driver:KeyDown( IN_MOVERIGHT ) then
		self.TargetAngles = Angle( 0 , 90 , 0 )
		elseif self.Driver:KeyDown( IN_MOVELEFT ) then
		self.TargetAngles = Angle( 0 , 180 , 0 )
		else
		self.TargetAngles = Angle( 0 , 135 , 0 )
		end
		SelfAddForce = SelfAddForce + self:GetRight() * 800
	elseif self.Driver:KeyDown( IN_BACK ) then
		if self.Driver:KeyDown( IN_MOVERIGHT ) then
		self.TargetAngles = Angle( 0 , 0 , 0 )
		elseif self.Driver:KeyDown( IN_MOVELEFT ) then
		self.TargetAngles = Angle( 0 , -90 , 0 )
		else
		self.TargetAngles = Angle( 0 , -45 , 0 )
		end
		SelfAddForce = SelfAddForce + self:GetRight() * 800
	elseif self.Driver:KeyDown( IN_MOVERIGHT ) then
		self.TargetAngles = Angle( 0 , 45 , 0 )
		SelfAddForce = SelfAddForce + self:GetRight() * 800
	elseif self.Driver:KeyDown( IN_MOVELEFT ) then
		self.TargetAngles = Angle( 0 , 225 , 0 )
		SelfAddForce = SelfAddForce + self:GetRight() * 800
	end
	

	local AngleDiff = Angle()
	AngleDiff.yaw = ( self.TargetAngles.yaw - SelfAng.yaw )
	AngleDiff.pitch = ( self.TargetAngles.pitch - SelfAng.pitch )
	AngleDiff.roll = ( self.TargetAngles.roll - SelfAng.roll )
	AngleDiff:Normalize()
	if AngleDiff.yaw < 0 then
		AngleDiff.yaw = -((-AngleDiff.yaw) ^ 0.7)
	else
		AngleDiff.yaw = AngleDiff.yaw ^ 0.7
	end
	if AngleDiff.pitch < 0 then
		AngleDiff.pitch = -((-AngleDiff.pitch) ^ 0.7)
	else
		AngleDiff.pitch = AngleDiff.pitch ^ 0.7
	end
	if AngleDiff.roll < 0 then
		AngleDiff.roll = -((-AngleDiff.roll) ^ 0.7)
	else
		AngleDiff.roll = AngleDiff.roll ^ 0.7
	end
	local Torque = Vector( AngleDiff.yaw * 1000 , 0 , 0 )
	
	local TempAxis = Vector( 0 , 1 , 0 )
	TempAxis:Rotate( Angle( SelfAng.yaw , 0 , 0 ) )
	Torque = Torque + TempAxis * AngleDiff.roll * 300
	TempAxis:Rotate( Angle( 90 , 0 , 0 ) )
	Torque = Torque + TempAxis * AngleDiff.pitch * 300
	SelfAngForce = SelfAngForce + ( Torque - phys:GetAngleVelocity() * 50 )

	-- simuluate
	return SelfAngForce, SelfAddForce, SIM_GLOBAL_ACCELERATION
	
end

--function ENT:PhysicsUpdate()