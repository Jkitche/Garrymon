
include('shared.lua')


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Color = Color( 255, 255, 255, 255 )
	
end


function ENT:Draw()
	local WobbleTime = self:GetDTInt(0)
	local WobbleAmount = 75
	local WobbleSpeed = 10
	local WobbleMod = 0
	if (math.floor(CurTime() - self:GetDTFloat(0)) % 2  == 1) then
		WobbleMod = 0
	else
		WobbleMod = math.sin( CurTime()*WobbleSpeed ) * WobbleAmount
	end
	if self:GetDTBool(0) then
		local Pitch = WobbleMod
		local Roll = 0
		local Yaw = self:GetAngles().y
		local Ang = Angle( Pitch / 2, Yaw, Roll ) 
		
		self:SetAngles( Ang )
	end
	self:DrawModel()
end

