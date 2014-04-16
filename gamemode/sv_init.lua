
Player = FindMetaTable("Player")

resource.AddFile( "materials/saikred/melontank/orange_crosshair.png" )
resource.AddFile( "materials/saikred/melontank/UI.png" )
resource.AddFile( "materials/saikred/melontank/melon_half.png" )
resource.AddFile( "materials/saikred/melontank/melon_half_moon.png" )
resource.AddFile( "materials/saikred/melontank/logo.png" )
resource.AddFile( "sound/saikred/melontank/r-novoxbfh.mp3" )

include( "sv_toclient.lua" )
include( "sh_init.lua" )
include( "sv_playerfuncs.lua" )
include( "sv_spawning.lua" )
include( "sv_endround.lua" )
AddCSLuaFile( "sh_init.lua" )
AddCSLuaFile( "cl_toserver.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_cameracontrols.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )

hook.Add( "Think" , "Bonus" , function()
	if not #ents.FindByClass( "bonus" ) or #ents.FindByClass( "bonus" ) < 1 then
		if math.random( 1 , 1000 ) > 1 then return false end
		local BonPos = table.Random( ents.FindByClass( "mt_bonus" ) ):GetPos()
		local BonEnt = ents.Create( "bonus" )
		BonEnt:SetPos( BonPos + Vector( 0 , 0 , 35 ) )
		BonEnt:Spawn()
	end
end )

hook.Add( "Think" , "ShiledOver" , function()
	for _,Ply in pairs( player.GetAll() ) do
		if Ply.Shield and Ply.Shield > 100 then Ply.Shield = Ply.Shield - 0.05 UpdateTank( Ply )end
	end
end )
