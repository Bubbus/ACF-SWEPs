
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false




function SWEP:FireBullet()

	self.Owner:LagCompensation( true )

	local MuzzlePos = self.Owner:GetShootPos()
	local MuzzleVec = self.Owner:GetAimVector()
	local angs = self.Owner:EyeAngles()	
	local MuzzlePos2 = MuzzlePos + angs:Forward() * self.AimOffset.x + angs:Right() * self.AimOffset.y
	local MuzzleVecFinal = self:inaccuracy(MuzzleVec, self.Inaccuracy)
	
	self.BulletData["Pos"] = MuzzlePos
	self.BulletData["Owner"] = self.Owner
	self.BulletData["Gun"] = self
	
	local plyvel = self.Owner:GetVelocity()
	for i=1, 8 do
		self.BulletData["Flight"] = self:inaccuracy(MuzzleVecFinal, self.ShotSpread) * self.BulletData["MuzzleVel"] * 39.37 + plyvel + MuzzleVecFinal * 16
			
		ACF_CreateBulletSWEP(self.BulletData, self, true)
	end
	
	self:MuzzleEffect( MuzzlePos2 , MuzzleVec )
	
	self.Owner:LagCompensation( false )
	
	//debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 10000, 60, Color(200, 200, 255, 255),  true)
	
end