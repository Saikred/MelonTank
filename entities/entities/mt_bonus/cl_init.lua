
include( "shared.lua" )


function ENT:Initialize()
	local mat = Matrix()
	mat:Scale( Vector( 0.001 , 0.001 , 0.001 ) )
	self:EnableMatrix( "RenderMultiply", mat )
end
