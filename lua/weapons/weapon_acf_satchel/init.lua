
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false



local MIN_DONK_DELAY = 0.2
local MIN_DONK_VEL = 50
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




local up = Vector(0, 0, 1)
local thinktime = 0.1

function SWEP.grenadeExplode(bomb)
	if IsValid(bomb) then 
		
		local tracedir
		
		if IsValid(bomb:GetParent()) and bomb.LocalSurfaceNormal then
			
			tracedir = -( bomb:LocalToWorld(bomb.LocalSurfaceNormal) - bomb:GetPos() )
		
		else			
			local pos = bomb:GetPos()
			local vel = bomb:GetVelocity()
			
			if vel:Length() < 10 then
				local entup = bomb:GetUp()
				local entdn = -entup
				
				if entup:Dot(up) >= entdn:Dot(up) then
					tracedir = entup
				else
					tracedir = entdn
				end
				
			else
				tracedir = vel:GetNormalized()
			end
		end
		
		bomb.BulletData.Flight = tracedir * (bomb.BulletData.SlugMV or 1000)
		
		debugoverlay.Cross( bomb:GetPos(), 4, 10, Color(255, 0, 0), true )
		debugoverlay.Line( bomb:GetPos(), bomb:GetPos() + bomb.BulletData.Flight, 10, Color(255, 0, 0), true )
	
		bomb:Detonate()
	end
end




function SWEP.grenadeTraceHit(bomb, trace)
	if not IsValid(bomb) then return end
	local parent = bomb:GetParent()
	local hitent = trace.Entity
	
	if 	not IsValid(parent) and not trace.HitWorld and IsValid(hitent) and not (hitent == parent)
		and not (hitent:GetClass() == "acf_grenade") and not (hitent == bomb:GetOwner()) 
		and not hitent:IsPlayer() and not hitent:IsNPC() then
		
		if (trace.HitNormal:Length() < 0.99) then
			local vel = bomb:GetVelocity()
			trace.HitNormal = (vel:Length() < 0.99) and vel:GetNormalized() or bomb:GetUp()
		end
		
		local setpos = trace.HitPos - trace.HitNormal * 1
		
		bomb:SetPos(setpos)
		local forward = trace.HitNormal:Cross(VectorRand():GetNormalized()):GetNormalized()
		local ang = forward:Angle()
		ang:RotateAroundAxis(forward, 90)
		bomb:SetAngles(ang)
		bomb:SetParent(trace.Entity)
		
		bomb.LocalSurfaceNormal = bomb:WorldToLocal(trace.HitNormal + bomb:GetPos())
	end
end




function SWEP:DetonateSatchels()
	
	local detfunc = self.DetonateSatchel
	local owner = self.Owner
	timer.Create("ACFSatchel_Boom", 0.01, 0, function() detfunc(self, owner) end)
	
	self:DetonateSatchel()
	
end




function SWEP:DetonateSatchel(owner)
	owner = owner or self.Owner
	if not IsValid(owner) then return end
	
	local k, bomb = next(owner.ACFSatchels)
	
	if k == nil then
		timer.Remove("ACFSatchel_Boom")
		return
	end
	
	if IsValid(bomb) then
		local boom = bomb.grenadeExplode or bomb.Detonate
		boom(bomb)
	end
	
	owner.ACFSatchels[k] = nil
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
	
	//local bomb = MakeACF_Grenade(self.Owner, MuzzlePos2, Angle(0,0,0), self.BulletData, self.ThrowModel)
	
	local bomb = ents.Create("acf_grenade")
	bomb:SetPos(MuzzlePos2)
	bomb:SetOwner(self.Owner)
	bomb:Spawn()
	bomb:SetModelEasy(self.ThrowModel)
	bomb:SetBulletData(self.BulletData) 
	
	local expfunc = self.grenadeExplode
	bomb.grenadeExplode = expfunc
	timer.Simple(600, function() expfunc(bomb) end)
	
	
	bomb:SetShouldTrace(true)
	bomb.TraceFilter[#bomb.TraceFilter + 1] = self.Owner
	bomb.TraceFilter[#bomb.TraceFilter + 1] = self.Owner:GetVehicle()
	bomb.OnTraceContact = self.grenadeTraceHit
	
	constraint.NoCollide(bomb, self.Owner)
	local phys = bomb:GetPhysicsObject()
	if phys then
		phys:SetVelocityInstantaneous(self.BulletData["Flight"])
		local angvel = self.Owner:LocalToWorld(Vector(400 + math.random()*300, 1000 + math.random()*1000, 40 + math.random()*30)) - self.Owner:GetPos()
		phys:AddAngleVelocity( angvel * throwmod)
		bomb.PhysicsCollide = self.grenadeDonk
		construct.SetPhysProp( nil, bomb, 0, phys, { GravityToggle = true, Material = "rubber" } ) 
	end
	
	
	local satchels = self.Owner.ACFSatchels
	satchels[#satchels + 1] = bomb
	
	
	local owner = self.Owner
	timer.Simple(self.Primary.Delay or 3, function()
			if !(IsValid(owner) and owner:Alive()) then return end
			
			local wep = owner:GetActiveWeapon()
			if IsValid(wep) then
				wep:SendWeaponAnim(ACT_VM_DRAW)
			end
			--if owner:GetAmmoCount( self.Primary.Ammo ) <= 0 and wep.GrenadeRemove then
				--self.Weapon:Remove()
				--owner:ConCommand("lastinv")
			--end
		end)
	
	self.Owner:LagCompensation( false )
	
	debugoverlay.Line(MuzzlePos, MuzzlePos + MuzzleVecFinal * 100, 60, Color(200, 200, 255, 255),  true)
	
end