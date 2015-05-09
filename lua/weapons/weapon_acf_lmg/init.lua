
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false




local LOW_AMMO_COL = Color(255, 100, 0)

function SWEP:BeforeFire()
	local clip1 = self:Clip1()
    
	if clip1 <= 10 and not self.isLow then
		self:UpdateTracers(LOW_AMMO_COL)
        self.isLow = true
    elseif clip1 > 10 and self.isLow then
        self:UpdateTracers()
        self.isLow = false
	end
end
