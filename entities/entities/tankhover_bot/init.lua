
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
	
	self.LoseTargetDist	= 2000
	self.SearchRadius 	= 1000
	
	self:StartMotionController()
	self.TeamCol
	self.Pause = false
end

function ENT:SetEnemy( ent )
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy
end

function ENT:SelectEnemy( TEAM )
	for k_v in pairs( ents.FindInSphere( self:GetPos(), self.SearchRadius ) ) do
		if IsValid( v ) and v:GetClass() == "tankhover" and v.Driver.HP and v.Driver.HP > 100 and self.TeamCol != v.Driver.TeamColour ) then
			ENT:SetEnemy( v )
			return true
		end
	end
	return
end

function ENT:HaveEnemy()
	if IsValid( self:GetEnemy() ) then
		if self:GetPos():Distance( self:GetEnemy():GetPos() ) > self.LoseTargetDist then
			return self:SelectEnemy()
		elseif ( not self:GetEnemy().Driver.HP ) or self:GetEnemy().Driver.HP <= 0 then
			return self:SelectEnemy()
		end
		return true
	else
		return self:SelectEnemy()
	end
end

function ENT:OnRemove( )

	self:StopMotionController()
end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo ) -- pass to physics as forces

end

function ENT:Think()
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
	
	-- This is the bot's movement brain --
	
	
	if not self.Pause then
		if ( self:HaveEnemy() ) then
			self:ChaseEnemy()
		else
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.Rand( 100 - 400 ) )
		end
		self.Pause = true
		timer.Simple( 2 , function() self.Pause = false end )
	end

end

function ENT:ChaseEnemy( options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemies position

	if (  !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
	
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute( self, self:GetEnemy():GetPos() )-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		
		if ( options.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() ) then
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.Rand( 100 - 400 ) )
		end


	end

end

function ENT:MoveToPos( VECPOS )



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
	
	
	SelfAddForce = SelfAddForce + ( Vector(0,0,1) * ( ( tr.HitPos.z + hoverheight - self:GetPos().z ) / 2 ) * phys:GetMass() * 0.05 )
	
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