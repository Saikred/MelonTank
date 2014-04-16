
include( "shared.lua" )

function ENT:Initialize()
	self.created = CurTime()
	local mat = Matrix()
	mat:Scale( Vector( 2 , 2 , 2 ) )
	self:EnableMatrix( "RenderMultiply", mat )
	self:SetMaterial( "models/debug/debugwhite" )
	self:SetColor( Color( 255 , 255 , 255 , math.random( 0 , 1 ) * 255 ) )
end

function ENT:Think()



end

function ENT:Draw()
	DrawTime = CurTime() - self.created
	local mat = Matrix()
	mat:Scale( Vector( DrawTime , DrawTime , DrawTime ) )
	self:EnableMatrix( "RenderMultiply", mat )
	self:SetColor( Color( 255 , 255 , 255 , math.random( 0 , 255 ) ) )

end