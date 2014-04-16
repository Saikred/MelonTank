
function GM:PlayerInitialSpawn( Ply )
end

function SetNoGravity( Ent , Weight )
local selfphys = Ent:GetPhysicsObject()
	selfphys:SetMass( Weight or 1 ) selfphys:EnableGravity( false )
end
function ResetTeams()
	TeamsTable = {
		Red = 15
		, Blue = 15
		, Green = -1
--		Red = 20
--		, Blue = 20
--		, Green = -1
	}
	for _,Ply in pairs(player.GetAll() ) do
		Ply.TeamColor = nil
	end
	UpdateTeams()
end
ResetTeams()
concommand.Add( "ResetPoints" , ResetTeams )

function GM:PlayerInitialSpawn( Ply )
	TeamMenu( Ply )
end

function GM:ShowHelp( Ply )
	TeamMenu( Ply )
end
function GM:ShowTeam( Ply )
	LoadoutMenu( Ply )
end

function GM:PlayerSpawn( Ply )
	UpdateTeams()
	GAMEMODE:PlayerSpawnAsSpectator( Ply )
end

concommand.Add( "SetTeam" , function( Ply , cmd , args )
	if TeamsTable[ args[1] ] or args[1] == "Spec" then
		local CanSpawn = false
		if Ply.TeamColour == args[1] then return end
		if Ply.HP then
			if Ply.HP > 0 and IsValid( Ply.TurretEnt ) and IsValid( Ply.MelonEnt ) then
				CanSpawn = true
				TeamsTable[ Ply.TeamColour ] = TeamsTable[ Ply.TeamColour ] + 1
			end
		end
		if not ( args[1] == "Spec" ) then
			Ply.TeamColour = args[1]
			UpdateTank( Ply )
		else
			Ply.TeamColour = args[1]
			UpdateTank( Ply )
		end
		
		if CanSpawn then
			Ply.HP = 0
			Ply.Shield = 0
			local effect = EffectData()
			effect:SetStart( Ply.TankEnt:GetPos() )
			effect:SetOrigin( Ply.TankEnt:GetPos() )
			-- these don't have much effect with the default Explosion
			effect:SetScale(100)
			effect:SetRadius(100)
			effect:SetMagnitude(20)

			--   effect:SetNormal(Vector( 0 , 0 , 0 ))

			effect:SetOrigin( Ply.TankEnt:GetPos() )
			sound.Play(c4boom, Ply.TankEnt:GetPos(), 100, 100)
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)
			--Ply.MelonEnt:Remove()
			--Ply.MelonEnt:SetHealth( 1 )
			util.BlastDamage( Ply.TankEnt , Ply.TankEnt, Ply.MelonEnt:GetPos(), 130 , 1 )
			Ply.TurretEnt:Ignite(9999999 , 10 ) 
			
			UpdateTank( Ply )
		end
	end
	UpdateTeams()
	if not Ply.Prim and not Ply.Sec and not ( args[1] == "Spec" ) then 
		LoadoutMenu( Ply )
	else
		GAMEMODE:StartSpawn( Ply )
	end
end )

function GM:PlayerDeath( Ply )
	if IsValid( Ply.TankEnt ) then
		Ply.TankEnt:Remove()
		Ply.TurretEnt:Remove()
	end
end
function RemoveTank( Ply )
	if IsValid( Ply.TankEnt ) then
		Ply.TankEnt:Remove()
		Ply.TurretEnt:Remove()
	end
end

function GM:PlayerDisconnected( Ply )
	if IsValid( Ply.TankEnt ) then
		Ply.TankEnt:Remove()
		Ply.TurretEnt:Remove()
	end
end

hook.Add( "Think", "CheckDeadThink", function()	
	for _,Ply in pairs( player.GetAll() ) do
		if Ply.HP and Ply.HP <= 0 and not Ply.RespawnAt then Ply.RespawnAt = CurTime() + 15 SendRespawnTimer( Ply ) end
		if Ply.MelonEnt and not IsValid( Ply.MelonEnt )  then
			if Ply.HP then
				if Ply.HP > 0 then
					Ply.HP = 0
					Ply.Shield = 0
					if IsValid( Ply.TankEnt ) then
						local effect = EffectData()
						effect:SetStart( Ply.TankEnt:GetPos() )
						effect:SetOrigin( Ply.TankEnt:GetPos() )
						-- these don't have much effect with the default Explosion
						effect:SetScale(100)
						effect:SetRadius(100)
						effect:SetMagnitude(20)

						--   effect:SetNormal(Vector( 0 , 0 , 0 ))

						effect:SetOrigin( Ply.TankEnt:GetPos() )
						sound.Play(c4boom, Ply.TankEnt:GetPos(), 100, 100)
						util.Effect("Explosion", effect, true, true)
						util.Effect("HelicopterMegaBomb", effect, true, true)
						Ply.TurretEnt:Ignite(9999999 , 10 ) 
					end
					UpdateTank( Ply )
				end
			end
		end
		if Ply.RespawnAt and not GameVictor and CurTime() > Ply.RespawnAt then RemoveTank( Ply ) timer.Simple( 0.01 , function() GAMEMODE:StartSpawn( Ply ) end ) end
		
    end
end )

local ShotSound = Sound( "Weapon_AR2.NPC_Double")
local DropMine = Sound( "Weapon_CombineGuard.Special1" )
--Ply.InMenu = false
concommand.Add( "CloseMenu" , function( Ply ) Ply.InMenu = false end )

concommand.Add( "InClMenu" , function( Ply ) Ply.InMenu = true end )

function GM:PlayerButtonDown( Ply, button )
	if Ply.InMenu then return false end
	if button == MOUSE_LEFT then
		if IsValid( Ply.ChamberEnt ) and CurTime() > Ply.ShootTimer and Ply.HP > 0 then 
			sound.Play( ShotSound, Ply.ChamberEnt:GetPos(), 75, math.random( 90, 120 ) )
			local Shell 
			if Ply.ChamberEnt:GetModel() == "models/props_c17/pottery08a.mdl" then
				Shell = ents.Create( "shell_rebound" )
				local TurAng = Ply.ChamberEnt:GetAngles() 
				Shell:SetPos( Ply.ChamberEnt:GetPos() + TurAng:Up() * -20 )
				Shell:SetAngles( TurAng )
				Shell:Spawn()
				Shell:GetPhysicsObject():ApplyForceCenter( TurAng:Up() * - 6500 )
				Shell.Created = CurTime()
				Ply.ShootTimer = CurTime() + 2
			elseif Ply.ChamberEnt:GetModel() == "models/props_c17/canister01a.mdl" then
				Shell = ents.Create( "shell_fast" )
				local TurAng = Ply.ChamberEnt:GetAngles() 
				Shell:SetPos( Ply.ChamberEnt:GetPos() + TurAng:Up() * -20 )
				Shell:SetAngles( TurAng )
				Shell:Spawn()
				Shell:GetPhysicsObject():ApplyForceCenter( TurAng:Up() * - 10000 )
				Shell:GetPhysicsObject():AddAngleVelocity( Vector( 0 , 0 , 1 ) * 400)
				Shell.Created = CurTime()
				Ply.ShootTimer = CurTime() + 1.2
			else
				Ply.ShootTimer = CurTime() + 0.4
				Shell = ents.Create( "shell_basic" )
				local TurAng = Ply.ChamberEnt:GetAngles() 
				Shell:SetPos( Ply.ChamberEnt:GetPos() + TurAng:Up() * -20 )
				Shell:SetAngles( TurAng )
				Shell:Spawn()
				Shell:GetPhysicsObject():ApplyForceCenter( TurAng:Up() * - 6000 )
				Shell:GetPhysicsObject():AddAngleVelocity( Vector( 0 , 0 , 1 ) * 400)
				Shell.Created = CurTime()
				Ply.ShootTimer = CurTime() + 0.4
			end
			NextFire( Ply , "PRIM" , Ply.ShootTimer )

			local efd = EffectData()
			efd:SetOrigin( Shell:GetPos())
			efd:SetEntity( Shell )
			efd:SetRadius(30)
			efd:SetMagnitude( 3 )
			efd:SetScale( 3 )
			EffectAngle = Ply.ChamberEnt:GetAngles()
			EffectAngle:RotateAroundAxis( Ply.ChamberEnt:GetAngles():Right() , -90 )
			efd:SetAngles( EffectAngle )
			efd:SetStart( Shell:GetPos() )
			util.Effect("MuzzleEffect", efd)
		end
		
	elseif button == MOUSE_RIGHT then
		if IsValid( Ply.SecEnt ) and CurTime() > Ply.ShootTimer2 and Ply.HP > 0 then 
			sound.Play( DropMine, Ply.MelonEnt:GetPos(), 75, math.random( 90, 120 ) )
			if Ply.SecEnt:GetModel() == "models/props_junk/CinderBlock01a.mdl" then
				Ply.ShootTimer2 = CurTime() + 10
			elseif Ply.SecEnt:GetModel() == "models/props_junk/plasticbucket001a.mdl" then
				Ply.ShootTimer2 = CurTime() + 6
			else
				Ply.ShootTimer2 = CurTime() + 4
			end
			NextFire( Ply , "SEC" , Ply.ShootTimer2 )
			timer.Simple( 0.7 , function()
				if not IsValid( Ply.MelonEnt ) then return end
				if Ply.SecEnt:GetModel() == "models/props_junk/cinderblock01a.mdl" then
					local Sec = ents.Create( "sec_missile" )
					local TurAng = Ply.TurretEnt:GetAngles() 
					Sec:SetPos( Ply.TurretEnt:GetPos() + TurAng:Forward() * -30 )
					Sec:SetAngles( TurAng )
					Sec.Owner = Ply
					Sec:Spawn()
					Sec:GetPhysicsObject():ApplyForceCenter( TurAng:Up() * 50000 )
					Sec.Created = CurTime()
				elseif Ply.SecEnt:GetModel() == "models/props_junk/plasticbucket001a.mdl" then
					local Sec = ents.Create( "mine_time" )
					local TurAng = Ply.TurretEnt:GetAngles() 
					Sec:SetPos( Ply.TurretEnt:GetPos() + Vector( 0 , 0 , -35 ) )
					Sec:SetAngles( Angle( 180 , 0 , 0 ) )
					Sec.Owner = Ply
					Sec:Spawn()
					Sec.Created = CurTime()
				else
					local Sec = ents.Create( "mine" )
					local TurAng = Ply.TurretEnt:GetAngles() 
					Sec:SetPos( Ply.TurretEnt:GetPos() + TurAng:Forward() * -30 )
					Sec:SetAngles( TurAng )
					Sec.Owner = Ply
					Sec:Spawn()
					Sec:GetPhysicsObject():ApplyForceCenter( TurAng:Up() * 50 )
					Sec:GetPhysicsObject():ApplyForceCenter( TurAng:Forward() * -50 )
					Sec:GetPhysicsObject():AddAngleVelocity( Vector( 0 , 0 , 1 ) * -10000 )
					Sec.Created = CurTime()
				end
			end )
		end
	end
	return true
end


function GM:CanPlayerSuicide( Ply )
	
	if Ply.HP then
		if Ply.HP > 0 then
			Ply.HP = 0
			Ply.Shield = 0
			local effect = EffectData()
			effect:SetStart( Ply.TankEnt:GetPos() )
			effect:SetOrigin( Ply.TankEnt:GetPos() )
			-- these don't have much effect with the default Explosion
			effect:SetScale(100)
			effect:SetRadius(100)
			effect:SetMagnitude(20)

			--   effect:SetNormal(Vector( 0 , 0 , 0 ))

			effect:SetOrigin( Ply.TankEnt:GetPos() )
			sound.Play(c4boom, Ply.TankEnt:GetPos(), 100, 100)
			util.Effect("Explosion", effect, true, true)
			util.Effect("HelicopterMegaBomb", effect, true, true)
			--Ply.MelonEnt:Remove()
			--Ply.MelonEnt:SetHealth( 1 )
			util.BlastDamage( Ply.TankEnt , Ply.TankEnt, Ply.MelonEnt:GetPos(), 130 , 1 )
			Ply.TurretEnt:Ignite(9999999 , 10 ) 
			
			UpdateTank( Ply )
		end
	end
	return false
end

hook.Add("EntityTakeDamage", "stopall", function(ent, attacker)
	return false
end )
