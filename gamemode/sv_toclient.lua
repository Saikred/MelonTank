

util.AddNetworkString( "MousePos" )
util.AddNetworkString( "SetEntClr" )
util.AddNetworkString( "RespawnTimer" )
util.AddNetworkString( "Teams" )
util.AddNetworkString( "UpdateTank" )
util.AddNetworkString( "NextFire" )
util.AddNetworkString( "SplashScreen" )
util.AddNetworkString( "TeamMenu" )
util.AddNetworkString( "LoadoutMenu" )
util.AddNetworkString( "SendWep" )
util.AddNetworkString( "EndGameSplash" )
util.AddNetworkString( "EndGameSplashClose" )


net.Receive( "MousePos" , function()
	net.ReadEntity().MousePos = net.ReadFloat()
end )


net.Receive( "SendWep" , function()
	local TempTab = net.ReadTable()
	Ply = TempTab[1]
	Ply.Prim = TempTab[2]
	Ply.Sec = TempTab[3]
	GAMEMODE:StartSpawn( Ply )
	Ply.InMenu = false
end )

function SplashScreen( Ply )
	net.Start( "SplashScreen" )
	net.Send( Ply )
	Ply.InMenu = true
end
concommand.Add( "SplashScreen" , function( Ply ) SplashScreen( Ply ) end )

function TeamMenu( Ply )
	if GameVictor then  
		EndGameSplash( GameVictor , Ply)
	else
		net.Start( "TeamMenu" )
		net.Send( Ply )
		Ply.InMenu = true
	end
end
concommand.Add( "CSPurchase" , function( Ply ) TeamMenu( Ply ) end )

function LoadoutMenu( Ply )
	if GameVictor then  
		EndGameSplash( GameVictor , Ply)
	else
		net.Start( "LoadoutMenu" )
		net.Send( Ply )
		Ply.InMenu = true
	end
end
concommand.Add( "LoadoutMenu" , function( Ply ) LoadoutMenu( Ply ) end )

function EndGameSplash( Team , Ply)
	net.Start( "EndGameSplash" )
		net.WriteString( Team )
		net.WriteFloat( CurTime() + 20 )
	if Ply then
		net.Send( Ply )
	else
		net.Broadcast()
	end
end
concommand.Add( "EndGameSplash" , function( ply , cmd , arg ) EndGameSplash( arg[1] ) end )

function EndGameSplashClose()
	net.Start( "EndGameSplashClose" )
	net.Broadcast()
end
concommand.Add( "EndGameSplashClose" , function( ply , cmd , arg ) EndGameSplash( arg[1] ) end )

function SendRespawnTimer( Ply )
	net.Start( "RespawnTimer" )
		net.WriteFloat( Ply.RespawnAt )
	net.Send( Ply )
end

function UpdateTeams()
	net.Start( "Teams" )
		net.WriteTable( TeamsTable )
	net.Broadcast()
end

function UpdateTank( Ply )
	net.Start( "UpdateTank" )
		net.WriteTable( { Ply , Ply.TeamColour , Ply.Shield , Ply.HP , Ply.TankEnt , Ply.MelonEnt } )
	net.Broadcast()
end

function NextFire( Ply , typ , NextTime )
	net.Start( "NextFire" )
		net.WriteTable( { typ , NextTime } )
	net.Send( Ply )
end

function SetEntColour( Ent , Colour , MatStr )		
	timer.Simple( 0.2 , function()
	if not IsValid( Ent ) then return end
		net.Start( "SetEntClr" )
			net.WriteEntity( Ent )
			net.WriteString( MatStr )
			net.WriteVector( Vector( Colour.b , Colour.g , Colour.b ) )
			Ent:SetMaterial( MatStr )
			Ent:SetColor( Colour )
		net.Broadcast()
	end )
end
