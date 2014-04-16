
include( "shared.lua" )

function ENT:SetMat()
	self:SetMaterial( "models/props_combine/portalball001_sheet" )
	timer.Simple( 1 , function() if IsValid( self ) then self:SetMat() end end )
end

function ENT:Initialize()
	local mat = Matrix()
	mat:Scale( Vector( 2 , 2 , 2 ) )
	self:EnableMatrix( "RenderMultiply", mat )
	self:SetMat()
end
