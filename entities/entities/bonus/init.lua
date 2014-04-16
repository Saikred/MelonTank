
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Contactacted = 0

function ENT:Initialize()
	self.CreatedPos = self:GetPos()
	self:SetMoveType( MOVETYPE_FLY )
	--self:SetAngles( Angle( 90 , self:GetAngles().yaw , 0 ) )
	self:SetPos( self.CreatedPos + Vector( 0 , 0 , 0 ) )
	
	self:PhysicsInit( SOLID_NONE )

	--timer.Simple( 20 , function() self:Remove() end )
	self.hoverheight 	= 20
	
	local Random = math.random( 6 , 6 )
	if Random == 1 then
		self.bonus = "Shield"
		self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	elseif Random == 2 then
		self.bonus = "HP"
		self:SetModel( "models/Items/HealthKit.mdl" )
	elseif Random == 3 then
		self.bonus = "HP"
		self:SetModel( "models/Items/HealthKit.mdl" )
	elseif Random == 4 then
		self.bonus = "Railgun"
		self:SetModel( "models/items/car_battery01.mdl" )
	elseif Random == 5 then
		self.bonus = "Railgun"
		self:SetModel( "models/items/car_battery01.mdl" )
	elseif Random == 6 then
		self.bonus = "Chopper"
		self:SetModel( "models/props_phx/misc/propeller2x_small.mdl" )
	elseif Random == 7 then
		self.bonus = "Shield"
		self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	else
		self.bonus = "Shield"
		self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	end
end

function ENT:Think()
	
	--[[local tr = util.TraceLine( {
		start = self:GetPos() + self:GetAngles():Up() * -20,
		endpos = self:GetPos() + self:GetAngles():Up() * -35
	} )
	if tr.Hit then
		timer.Simple( 0.05 , function() if IsValid( self ) then self:Remove() end end )
	end]]
	for _,Ent in pairs (ents.FindInSphere( self:GetPos() , 60 , "tankhover" ) ) do
		if Ent:GetClass() == "tankhover" then
			Ply = Ent.Driver
			if self.bonus == "Shield" then
				Ply.Shield = 200
			elseif self.bonus == "HP" then
				Ply.HP = 100
			elseif self.bonus == "Chopper" then
				Ply.Chopper = true
				timer.Simple( 30 , function() if IsValid( Ply.TankEnt ) then Ply.Chopper = false end end ) 
			elseif self.bonus == "Railgun" then
				Ply.RailgunShots = 3
			else
				Ply.Shield = 200
			end
			UpdateTank( Ply )
			self:Remove()
		end
	end
end
