
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()

	self.SpecialDamage = true
	self.Owner = self:GetOwner()
	
	print("hi from fakecrate")
	
end




local nullhit = {Damage = 0, Overkill = 0, Loss = 0, Kill = false}
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	return table.Copy(nullhit)
end




function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS
	
end




function ENT:RegisterTo(bullet)

	ACF_MakeCrateForBullet(self, bullet)
	
end


