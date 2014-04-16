
include( "shared.lua" )
function ENT:Initialize()
	
	local mat = Matrix()
	mat:Scale( Vector( 0.4 , 0.4 , 0.4 ) )
	self:EnableMatrix( "RenderMultiply", mat )
end
function ENT:Think()
end

function ENT:OnRemove()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint ) // not sure if ( we need a start and origin ( endpoint ) for this effect, but whatever
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 1 )
	util.Effect( "HelicopterMegaBomb", effectdata )
	timer.Simple( 0.05 , function() 
		effectdata:SetScale( 2 )
		util.Effect( "HelicopterMegaBomb", effectdata )
	end )
end

