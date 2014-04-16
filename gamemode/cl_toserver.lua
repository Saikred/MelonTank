
net.Receive( "RespawnTimer" , function( Length )
		RespawnIn = net.ReadFloat()
end )
net.Receive( "Teams" , function( Length )
		TeamsTable = net.ReadTable()
end )

net.Receive( "NextFire" , function( Length )
	local TempTable= net.ReadTable()
	if TempTable[1] == "PRIM" then
		NextPrimFire = TempTable[2]
	else
		NextSecFire = TempTable[2]
	end
end )

net.Receive( "UpdateTank" , function( Length )
		local TankTbl = net.ReadTable()
		ply = TankTbl[ 1 ]
		ply.TeamCol = TankTbl[ 2 ]
		ply.Shield = TankTbl[ 3 ]
		ply.HP = TankTbl[ 4 ]
		ply.TankEnt = TankTbl[ 5 ]
		ply.MelonEnt = TankTbl[ 6 ]
		if IsValid( ply.MelonEnt ) then
			local mat = Matrix()
			mat:Scale( Vector( 2 , 2 , 2 ) )
			ply.MelonEnt:EnableMatrix( "RenderMultiply", mat )
		end
end )


hook.Add( "Think" , "SendMousePos" , function()
	net.Start( "MousePos" )
		net.WriteEntity( LocalPlayer() )
		local MouseX , MouseY = input.GetCursorPos( )
		local deltaX = MouseX - ScrW() / 2
		local deltaY = MouseY - ScrH() / 2
		local angleInDegrees = math.atan2(deltaY, deltaX) * 180 / math.pi
		net.WriteFloat( angleInDegrees )
	net.SendToServer()
end )


net.Receive( "SetEntClr" , function()
	local Ent = net.ReadEntity()
	if not IsValid( Ent ) then return end
	Ent:SetMaterial( net.ReadString() )
	VecClr = net.ReadVector()
	Ent:SetColor( Color( VecClr.x , VecClr.y , VecClr.z , 255 ) )
end )

