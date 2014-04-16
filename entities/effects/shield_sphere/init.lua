
local ShieldMdl = Model("models/Combine_Helicopter/helicopter_bomb01.mdl")
--EFFECT.FollowEnt = nil
function EFFECT:Init(data)
	self.Rad = data:GetRadius()
	self:SetRenderBounds(Vector(-self.Rad, -self.Rad, -self.Rad), Vector(self.Rad, self.Rad, self.Rad))
	self.EndTime = CurTime() + data:GetScale()
	self.FollowEnt = data:GetEntity()
	if IsValid( self.FollowEnt ) then
		self.Shield = ClientsideModel( ShieldMdl , RENDERGROUP_TRANSLUCENT)
		self.Shield:SetPos( self.FollowEnt:GetPos() )
		self.Shield:AddEffects(EF_NODRAW)
	end
	self.EndScale = self.Rad / 16
end

function EFFECT:Think()

	if not IsValid( self.FollowEnt ) then SafeRemoveEntity( self.Shield ) end
	
	if IsValid( self.Shield ) and IsValid( self.FollowEnt ) then
		self.Shield:SetPos( self.FollowEnt:GetPos() )
		self.Shield:SetModelScale( self.EndScale, 0 )
		local MyAngs = self.Shield:GetAngles()
		MyAngs.y = MyAngs.y + 1000 * FrameTime()
		self.Shield:SetAngles( MyAngs )
	end
	if self.EndTime < CurTime() then
		if IsValid( self.Shield ) then SafeRemoveEntity( self.Shield ) end
		return false
	end


	return IsValid( self.Shield )
end

local TransTex = Material( "models/effects/splodearc_sheet" )
function EFFECT:Render()
	if IsValid( self.Shield ) then
		render.MaterialOverride( TransTex )
		render.SuppressEngineLighting( true )
		render.SetColorModulation( 1 , 0.6 , 0.5 )
		render.SetBlend( 0.8 )
		render.SetLightingMode( 1 )
		self.Shield:DrawModel()
		render.SetBlend( 1 )
		render.SetLightingMode( 0 )
		render.SetColorModulation( 1, 1, 1 )
		render.SuppressEngineLighting( false )
		render.MaterialOverride()
	end
end
