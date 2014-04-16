
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self.CreatedPos = self:GetPos()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetModel( "models/XQM/Rails/trackball_1.mdl" )
	self:SetPos( self.CreatedPos + Vector( 0 , 0 , 0 ) )
	
	self:PhysicsInit( SOLID_NONE )
	self:SetColor( Color( 255 , 255 , 255 ) )

	--timer.Simple( 20 , function() self:Remove() end )
	
end

function ENT:Draw()
	return false
end