include('shared.lua')

SWEP.DrawAmmo			= true
SWEP.DrawWeaponInfoBox	= true
SWEP.BounceWeaponIcon   = true


function XCF_SG_RecvColour(len)
	local self = net.ReadEntity()
	local idx = net.ReadInt(8)
	if not IsValid(self) then return end
	
	self.SmokeColourIdx = idx
	
	local colour = self.SmokeColours[self.SmokeColourIdx]
	if not colour then return end
	
	self.BulletData.Colour = colour[2]
	GAMEMODE:AddNotify("Smoke colour is now " .. colour[1], NOTIFY_HINT, 3)
end
net.Receive("XCFSGCol", XCF_SG_RecvColour)