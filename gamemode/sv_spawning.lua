
function GM:StartSpawn( Ply )

	if Ply.TeamColour then
		local SpawnPoints
		if Ply.TeamColour == "Red" then
			SpawnPoints = ents.FindByClass( "info_player_terrorist" )
		else
			SpawnPoints = ents.FindByClass( "info_player_counterterrorist" )
			--SpawnPoints = ents.FindByClass( "info_player_start" )
		end
		for i = 1 , #SpawnPoints do
			local RandSpawn = table.Random( SpawnPoints )
			local EntsNearSpawn = ents.FindInSphere( RandSpawn:GetPos() + Vector( 0 , 0 , 50 ) , 60 )
			for _,Ent in pairs( EntsNearSpawn ) do
				if Ent:GetClass() == "tankhover" then
				else
					GAMEMODE:SpawnInTeam( Ply , Ply.TeamColour ,  RandSpawn:GetPos() + Vector( 0 , 0 , 50 ) )
					return
				end
			end
		end
		timer.Simple( 1 , function() GAMEMODE:StartSpawn( Ply ) end)
	end
end

function GM:SpawnInTeam( Ply , TEAM , POS )

	if IsValid( Ply.TankEnt ) then
		return
	end
	if not TeamsTable[ Ply.TeamColour ] then 
		GAMEMODE:PlayerSpawnAsSpectator( Ply )
		
		return
	end
	if TeamsTable[ Ply.TeamColour ] > 0 then 
	
		TeamsTable[ Ply.TeamColour ] = TeamsTable[ Ply.TeamColour ] - 1
		Ply.MyCol = Color( 0 , 255 , 0 , 255 )
		if TEAM == "Red" then 
			Ply.MyCol = Color( 255 , 0 , 0 , 255 )
		elseif TEAM == "Blue" then 
			Ply.MyCol = Color( 0 , 0 , 255 , 255 )
		end
		UpdateTeams()
		Ply.ShootTimer = 0
		Ply.ShootTimer2 = 0
		Ply.Shield = 100
		Ply.HP = 100
		Ply.RespawnAt = nil

		Ply.TankEnt = ents.Create( "tankhover" )
		Ply.TankEnt:SetPos( POS )
		Ply.TankEnt:SetAngles( Angle( -90 , 180 , 0 ) )
		Ply.TankEnt:Spawn()
		Ply.TankEnt.Driver = Ply
		SetEntColour( Ply.TankEnt , Color( 255 , 255 , 255 , 255 ) , "models/debug/debugwhite" )
		
		Ply.TurretEnt = ents.Create( "tanktop" )
		Ply.TurretEnt:SetPos( Ply.TankEnt:GetPos() + Vector( 0 , 0 , 15 ) )
		Ply.TankEnt:DeleteOnRemove( Ply.TurretEnt )
		Ply.TurretEnt.Driver = Ply
		Ply.TurretEnt:Spawn()
		
		Ply:Spectate( OBS_MODE_FIXED )
		Ply:SpectateEntity( Ply.TankEnt )
		local Constraint = ents.Create("phys_hinge")
		Constraint:SetPos( Ply.TurretEnt:GetPos() )
		Constraint:SetKeyValue( "hingeaxis", tostring( Ply.TankEnt:GetPos() ) ) 
		Constraint:SetKeyValue( "spawnflags", 1 )
		Constraint:SetPhysConstraintObjects( Ply.TankEnt:GetPhysicsObject(), Ply.TurretEnt:GetPhysicsObject() )
		Constraint:Spawn()
		Constraint:Activate()
			
		Ply.TankEnt:PhysWake()
		Ply.TurretEnt:PhysWake()
		
		CreatePaintEnts( Ply )

		Ply.MousePos = 0
		timer.Simple( 0.1 , function() UpdateTank( Ply ) end )
		timer.Simple( 0.3 , function() UpdateTank( Ply ) end )
	else
		GAMEMODE:PlayerSpawnAsSpectator( Ply )
	end
end

function CreatePaintEnts( Ply )
	
	Ply.MelonEnt = ents.Create( "prop_physics" )
	Ply.MelonEnt:SetModel( "models/props_junk/watermelon01.mdl" )
	Ply.MelonEnt:SetPos( Ply.TurretEnt:GetPos() + Vector( 0 , 0 , 3 ) )
	Ply.MelonEnt:SetAngles( Ply.TurretEnt:GetAngles() + Angle( 0 , 90 , 0 ) )
	Ply.MelonEnt:Spawn()
	Ply.MelonEnt:SetSolid(SOLID_BSP)
	Ply.MelonEnt:SetParent( Ply.TurretEnt )
	Ply.MelonEnt:SetHealth(999999999999999999999)
	Ply.TurretEnt:DeleteOnRemove( Ply.MelonEnt )
	Ply.MelonEnt:PrecacheGibs()
	Ply.MelonEnt.Driver = Ply
	Ply.MelonEnt.OnTakeDamage = function() return false end
	SetNoGravity( Ply.MelonEnt , 1 )
	
	if Ply.Prim then
		Ply.ChamberEnt = ents.Create( "prop_physics" )
		if Ply.Prim == "shell_fast" then
			Ply.ChamberEnt:SetModel( "models/props_c17/canister01a.mdl" )
			Ply.ChamberEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * 25 + Vector( 0 , 0 , 5 ))
		elseif Ply.Prim == "shell_rebound" then
			Ply.ChamberEnt:SetModel( "models/props_c17/pottery08a.mdl" )
			Ply.ChamberEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * 35 + Vector( 0 , 0 , 5 ))
		else
			Ply.ChamberEnt:SetModel( "models/props_junk/propane_tank001a.mdl" )
			Ply.ChamberEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * 20 + Vector( 0 , 0 , 5 ))
		end
		Ply.ChamberEnt:SetAngles( Ply.TurretEnt:GetAngles() + Angle( -90 , 0 , 0 ) )
		Ply.ChamberEnt:SetParent( Ply.TurretEnt )
		Ply.ChamberEnt:Spawn()
		Ply.ChamberEnt:SetHealth(999999999999999999999)
		Ply.ChamberEnt.OnTakeDamage = function() return false end
		Ply.TurretEnt:DeleteOnRemove( Ply.ChamberEnt )
		SetNoGravity( Ply.TurretEnt , 1 )
	end
	
	if Ply.Sec then
		Ply.SecEnt = ents.Create( "prop_physics" )
		if Ply.Sec == "mine_time" then
			Ply.SecEnt:SetModel( "models/props_junk/plasticbucket001a.mdl" )
			Ply.SecEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * -15 + Vector( 0 , 0 , 5 ))
			Ply.SecEnt:SetAngles( Ply.TurretEnt:GetAngles() + Angle( 90 , 0 , 0 ) )
		elseif Ply.Sec == "missile" then
			Ply.SecEnt:SetModel( "models/props_junk/CinderBlock01a.mdl" )
			Ply.SecEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * -20 + Vector( 0 , 0 , 5 ))
			Ply.SecEnt:SetAngles( Ply.TurretEnt:GetAngles() + Angle( -90 , 90 , 0 ) )
		else
			Ply.SecEnt:SetModel( "models/props_combine/breenglobe.mdl" )
			Ply.SecEnt:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Forward() * -18 + Vector( 0 , 0 , 5 ))
			Ply.SecEnt:SetAngles( Ply.TurretEnt:GetAngles() + Angle( -90 , 0 , 0 ) )
		end
		Ply.SecEnt:SetParent( Ply.TurretEnt )
		Ply.SecEnt:Spawn()
		Ply.SecEnt:SetHealth(999999999999999999999)
		Ply.TurretEnt:DeleteOnRemove( Ply.SecEnt )
		SetNoGravity( Ply.TurretEnt , 1 )
	end
		
		
	Ply.RightTank = ents.Create( "prop_physics" )
	Ply.RightTank:SetModel( "models/props_junk/metalgascan.mdl" )
	Ply.RightTank:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Right() * 15 + Vector( 0 , 0 , 5 ))
	Ply.RightTank:SetAngles( Ply.TurretEnt:GetAngles() + Angle( 90 , 0 , 0 ) )
	Ply.RightTank:SetParent( Ply.TurretEnt )
	Ply.RightTank:Spawn()
	Ply.TurretEnt:DeleteOnRemove( Ply.RightTank )
	SetEntColour( Ply.RightTank , Ply.MyCol , "models/debug/debugwhite" )
	SetNoGravity( Ply.RightTank , 1 )	
	
	Ply.LeftTank = ents.Create( "prop_physics" )
	Ply.LeftTank:SetModel( "models/props_junk/metalgascan.mdl" )
	Ply.LeftTank:SetPos( Ply.TurretEnt:GetPos() + Ply.TurretEnt:GetAngles():Right() * -15 + Vector( 0 , 0 , 5 ))
	Ply.LeftTank:SetAngles( Ply.TurretEnt:GetAngles() + Angle( -90 , 0 , 180 ) )
	Ply.LeftTank:SetParent( Ply.TurretEnt )
	Ply.LeftTank:Spawn()
	Ply.TurretEnt:DeleteOnRemove( Ply.LeftTank )
	SetEntColour( Ply.LeftTank , Ply.MyCol , "models/debug/debugwhite")
	SetNoGravity( Ply.LeftTank , 1 )	
end

