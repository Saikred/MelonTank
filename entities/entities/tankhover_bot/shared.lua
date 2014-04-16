
ENT.Type 		= "vehicle"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "TankBase"
ENT.Spawnable 	= false

function ENT:Draw()
 self:DrawModel()
 self:CreateShadow()
end
