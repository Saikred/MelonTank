
Player = FindMetaTable( "Player" )

include( "cl_toserver.lua" )
include( "sh_init.lua" )
include( "cl_cameracontrols.lua" )
include( "cl_hud.lua" )
include( "cl_scoreboard.lua" )


RespawnIn = -1

TeamsTable = {
	Red = 0
	, Blue = 0
	, Green = -1
}

local RoundMusic = false
--[[timer.Simple( 2 , function() SetMusicSounds()
end )
local GameMusic
local MenuMusic

function SetMusicSounds()
	--GameMusic = CreateSound( Entity( 0 ) , "saikred/melontank/r-novoxbfh.mp3" )
	--MenuMusic = CreateSound( Entity( 0 ) , "saikred/melontank/r-bfwc.mp3" )
	GameMusic = "saikred/melontank/r-novoxbfh.mp3" 
	MenuMusic = "saikred/melontank/r-bfwc.mp3" 
end]]
	
--function MusicCheck()
sound.Play( "saikred/melontank/r-novoxbfh.mp3"  , Vector( 0 , 0 , 0 ) , 120 )
timer.Create( "GameMusic" , 125 , 0 , function() sound.Play( "saikred/melontank/r-novoxbfh.mp3"  , Vector( 0 , 0 , 0 ) , 120 ) end )
--[[	if not MenuMusic then return end
	if IsValid( LocalPlayer().TankEnt ) then
		if timer.Exists( "GameMusic" ) then
			return
		else
			print( "Timer Dosent Exists" )
			if timer.Exists( "MenuMusic" ) then
				print( "Fading out menu, playing game" )
				RunConsoleCommand( "Stopsound" )
				timer.Destroy( "MenuMusic" )
				timer.Simple( 1 , function() timer.Create( "GameMusic" , 125 , 0 , function()
					sound.Play( GameMusic , Vector( 0 , 0 , 0 ) , 120 )
				end ) end )
			elseif not ( timer.Exists( "GameMusic" ) ) then
				print( "playing game music" )
				--GameMusic:Play()
				sound.Play( GameMusic , Vector( 0 , 0 , 0 ) , 120 )
				timer.Create( "GameMusic" , 125 , 0 , function() sound.Play( GameMusic , Vector( 0 , 0 , 0 ) , 120 ) end )
			end
		end
	else
		if timer.Exists( "MenuMusic" ) then
			return
		else
			if timer.Exists( "GameMusic" ) then
				timer.Destroy( "GameMusic" )
				RunConsoleCommand( "Stopsound" )
				timer.Simple( 1 , function() timer.Create( "MenuMusic" , 30 , 0 , function()
					sound.Play( MenuMusic , Vector( 0 , 0 , 0 ) , 120 )
				end ) end )
			elseif not ( timer.Exists( "MenuMusic" ) ) then
				--MenuMusic:Play()
				sound.Play( MenuMusic , Vector( 0 , 0 , 0 ) , 120 )
				timer.Create( "MenuMusic" , 30 , 0 , function()sound.Play( MenuMusic , Vector( 0 , 0 , 0 ) , 120 ) end )
			end
		end
	end]]
--end
--hook.Add( "Initialize" , "MusicCheck" , function()MusicCheck() end )

