
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false







function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		local decibels 	= 90
		local pitch 	= 100
		sound.Play( "weapons/smokegrenade/sg_explode.wav", bomb:GetPos(), decibels, pitch, 1 )
	
		bomb:Detonate()
	end
end



util.AddNetworkString("XCFSGCol")
function SWEP:SecondaryAttack()

	if not self.SmokeColourIdx then 
		self.SmokeColourIdx = 2
	else
		self.SmokeColourIdx = (self.SmokeColourIdx % #self.SmokeColours) + 1
	end
	
	self.BulletData.Colour = self.SmokeColours[self.SmokeColourIdx][2]
	
	local col = self.BulletData.Colour
	
	if self.FakeCrate then
		self.FakeCrate:SetColor(col)
		self.FakeCrate:SetNetworkedVector( "Color", Vector(col.r, col.g, col.b))
		self.FakeCrate:SetNetworkedVector( "TracerColour", Vector(col.r, col.g, col.b))
	else
		self:UpdateFakeCrate()
	end
	
	--self.SmokeColourIdx = idx
	
	local colour = self.SmokeColours[self.SmokeColourIdx]
	if not colour then return end
	
	--self.BulletData.Colour = colour[2]
	self.Owner:SendLua(string.format("GAMEMODE:AddNotify(%q, \"NOTIFY_HINT\", 3)", "Smoke colour is now " .. colour[1]))
	
	/*
	net.Start("XCFSGCol")
		net.WriteEntity(self)
		net.WriteInt(self.SmokeColourIdx, 8)
	net.Send(self.Owner)
	//*/

end