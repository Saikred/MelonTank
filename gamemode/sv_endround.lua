
ents.RemoveByClass = function( CLASS )
	local Tab = ents.FindByClass( CLASS )
	for _,ENT in pairs( Tab ) do
		if IsValid( ENT ) then ENT:Remove() end
	end
end

function GM:GameEnd( Team ) 
	for _,ENT in pairs( ents.FindByClass( "tankhover" ) ) do
		ENT:Remove()
	end
	for _,ENT in pairs( ents.FindByClass( "tanktop" ) ) do
		ENT:Remove()
	end
	for _,Ply in pairs( player.GetAll() ) do
		if Ply then
			Ply.MyCol = nil
			Ply.TeamColour = nil
			Ply.RespawnAt = 0
			SendRespawnTimer( Ply )
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
		end
	end
	EndGameSplash( Team )
	
	timer.Simple( 20.05 , function()
			for _,Ply in pairs( player.GetAll() ) do
				Ply.MyCol = nil
				GameVictor = false
				Ply.RespawnAt = CurTime() + 1
			end
			local RandTeams = player.GetAll()
			local NextCol = "Red"
			while #RandTeams > 0 do
				RandPlyNum = math.random( 1, #RandTeams )
				Ply = RandTeams[ RandPlyNum ]
				Ply.TeamColour = NextCol
				table.remove( RandTeams , RandPlyNum )
				if NextCol == "Red" then NextCol = "Blue" else NextCol = "Red" end
				ents.RemoveByClass( "mine" )
				ents.RemoveByClass( "mine_time" )
				ents.RemoveByClass( "sec_missile" )
				ents.RemoveByClass( "shell_basic" )
				ents.RemoveByClass( "shell_fast" )
				ents.RemoveByClass( "shell_rebound" )
				
			end
			ResetTeams()
			EndGameSplashClose()
		end )	
end

function TeamHasLivePlayer( TEAM )
	for _,Ply in pairs( player.GetAll() ) do
		if Ply.TeamColour == TEAM then
			if Ply.HP and Ply.HP > 0 then return true end
		end
	end
	return false
end
hook.Add( "Think", "CheckWinner", function()
	if not GameVictor then
		if TeamsTable[ "Red" ] <= 0 then
			if not TeamHasLivePlayer( "Red" ) then
				print( "Blue Won" )
				GAMEMODE:GameEnd( "Blue" ) 
				GameVictor = "Blue"
			end
		end
		
		if TeamsTable[ "Blue" ] <= 0 then
			if not TeamHasLivePlayer( "Blue" ) then
				print( "Red Won" )
				GAMEMODE:GameEnd( "Red" ) 
				GameVictor = "Red"
			end
		end
	end
end )
