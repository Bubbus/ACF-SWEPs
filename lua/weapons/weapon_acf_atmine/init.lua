
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



local MIN_DONK_DELAY = 0.2
local MIN_DONK_VEL = 50
local MINE_TIMEOUT = 600
local MINE_TRACEDIST = 48

function SWEP.grenadeDonk(nade)

	local phys = nade:GetPhysicsObject()
	if not phys then return end
	
	local vel = phys:GetVelocity():Length()
	if vel < MIN_DONK_VEL then return end
	
	local curtime = CurTime()
	if not nade.lastDonk or nade.lastDonk < curtime - MIN_DONK_DELAY then	
		local decibels 	= math.Clamp(vel / 3, 30, 70) + math.random()*5
		local pitch 	= math.Clamp(vel / 5, 80, 110) + math.random()*15
		sound.Play( "weapons/smokegrenade/grenade_hit1.wav", nade:GetPos(), decibels, pitch, 1 )
		nade.lastDonk = curtime
	end
end




function SWEP.mineExplode(bomb)
	if IsValid(bomb) then 
		bomb:Detonate()
	end
end




function SWEP.mineTraceHit(bomb, trace)
	if not trace.HitWorld then
		--local setpos = trace.HitPos - (trace.HitPos - trace.StartPos):GetNormalized() * (bomb:BoundingRadius() * 1.1)
		
		--debugoverlay.Sphere( setpos, bomb:BoundingRadius(), 10, Color(255, 0, 0), true )
		--debugoverlay.Cross( trace.HitPos, 10, 10, Color(0, 255, 0), true )
		
		--bomb:SetPos(setpos)
		bomb.mineExplode(bomb)
	end
end




local trace = {}
local up = Vector(0, 0, 1)
local thinktime = 0.1
function SWEP.mineTrace(bomb)

	if not bomb.Timeout then bomb.Timeout = CurTime() + 1 end
	
	
	local pos = bomb:GetPos()
	local vel = bomb:GetVelocity()
    local tracedir
    
	trace.start = pos
	trace.filter = bomb.Timeout < CurTime() and bomb or {bomb, bomb.Owner, bomb.Owner:GetVehicle()}
	
	if vel:Length() < 10 then
		local entup = bomb:GetUp()
		local entdn = -entup
		
		if entup:Dot(up) >= entdn:Dot(up) then
			tracedir = entup
		else
			tracedir = entdn
		end
		
		trace.endpos = pos + tracedir * MINE_TRACEDIST
		
	else
        tracedir = vel:GetNormalized()
		trace.endpos = pos + vel * bomb.ThinkDelay
	end
	
    bomb.BulletData.Flight = tracedir * (bomb.BulletData.SlugMV or 1000)
	
	debugoverlay.Cross( trace.start, 4, 0.11, Color(255, 0, 0), true )
	debugoverlay.Line( trace.start, trace.endpos, 0.11, Color(255, 0, 0), true )
	

	local res = util.TraceEntity( trace, bomb ) 
	if res.Hit and not (res.Entity:IsPlayer() or res.Entity:IsNPC()) then
        timer.Simple(0.3, function() if IsValid(bomb) then bomb:OnTraceContact(res) end end)
	end	
	
end




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
	--self.BulletData.ProjClass = XCF.ProjClasses.Bomb or error("Could not find the Bomb projectile type!")
	
	local flight = MuzzleVecFinal * self.ThrowVel * 39.37 + self.Owner:GetVelocity()
	local throwmod = math.Clamp((self.PressedDuration or self.ChargeTime) / self.ChargeTime, 0.33, 1) * 1.5
	self.BulletData["Flight"] = flight * throwmod
	
	--[[
	local bomb = ents.Create("acf_grenade")
	bomb:SetPos(MuzzlePos2)
	bomb:SetOwner(self.Owner)
	bomb:Spawn()
	bomb:SetModelEasy(self.ThrowModel)
	bomb:SetBulletData(self.BulletData)
	]]--
	--local bomb = MakeACF_Grenade(self.Owner, MuzzlePos2, Angle(0,0,0), self.BulletData, self.ThrowModel)
	local bomb = ents.Create("acf_grenade")
	bomb:SetPos(MuzzlePos2)
	bomb:SetOwner(self.Owner)
	bomb:Spawn()
	bomb:SetModelEasy(self.ThrowModel)
	bomb:SetBulletData(self.BulletData)
	
	local expfunc = self.mineExplode
	bomb.mineExplode = expfunc
	timer.Simple(MINE_TIMEOUT, function() expfunc(bomb) end)
	
	bomb.TraceFunction = self.mineTrace
	
	bomb:SetShouldTrace(true)
	bomb.OnTraceContact = self.mineTraceHit
	
	constraint.NoCollide(bomb, self.Owner)
	local phys = bomb:GetPhysicsObject()
	if phys then
		phys:SetVelocityInstantaneous(self.BulletData["Flight"])
		local angvel = self.Owner:LocalToWorld(Vector(400 + math.random()*300, 1000 + math.random()*1000, 40 + math.random()*30)) - self.Owner:GetPos()
		phys:AddAngleVelocity( angvel * throwmod)
		bomb.PhysicsCollide = self.grenadeDonk
		construct.SetPhysProp( nil, bomb, 0, phys, { GravityToggle = true, Material = "rubber" } ) 
	end
	
	
	local owner = self.Owner
	timer.Simple(self.Primary.Delay or 3, function()
			if !(self and self.Primary and IsValid(owner) and owner:Alive()) then return end
			
			local wep = owner:GetActiveWeapon()
			wep:SendWeaponAnim(ACT_VM_DRAW)
			if owner:GetAmmoCount( self.Primary.Ammo ) <= 0 and wep.GrenadeRemove then
				self.Weapon:Remove()
				owner:ConCommand("lastinv")
			end
		end)
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end