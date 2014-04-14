
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



function SWEP.CallbackEndFlight(index, bullet, trace)
	if not trace.Hit then return end
	local pos = trace.HitPos
	local dir = (pos - trace.StartPos):GetNormalized()
	
	local Effect = EffectData()
		if bullet.Gun then
			Effect:SetEntity(bullet.Gun)
		end
		Effect:SetOrigin(pos - trace.Normal)
		Effect:SetNormal(dir)
		Effect:SetRadius(bullet.ProjMass * (bullet.Flight:Length() / 39.37) ^ 2)
	util.Effect( "xcf_sniperimpact", Effect, true, true)
end