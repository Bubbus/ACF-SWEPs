	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Base"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Why do you have this"
	SWEP.Instructions       = "pls stop"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_snip_sg550.mdl";
SWEP.WorldModel 		= "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_SG550.Single"

SWEP.ReloadTime				= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

// misnomer.  the position of the acf muzzleflash.
SWEP.AimOffset = Vector(32, 8, -1)

// use this to chop the scope off your gun
SWEP.ScopeChopPos = Vector(0, 0, 0)
SWEP.ScopeChopAngle = Angle(0, 0, -90)

SWEP.ZoomTime = 0.4

SWEP.MinInaccuracy = 0.5
SWEP.MaxInaccuracy = 12
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.1
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 7
SWEP.InaccuracyCrouchBonus = 1.7
SWEP.InaccuracyDuckPenalty = 6
SWEP.InaccuracyAimLimit = 4

SWEP.StaminaDrain = 0.004
SWEP.StaminaJumpDrain = 0.1

SWEP.HasScope = false

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false



function SWEP:InitBulletData()
	
	self.BulletData = {}
	//*
	self.BulletData["PenAera"]			=	1.2226258898987
	self.BulletData["MaxPen"]			=	15.517221066929
	self.BulletData["RoundVolume"]		=	16.8227276448
	self.BulletData["KETransfert"]		=	0.1
	self.BulletData["ProjMass"]			=	0.04143103391196
	self.BulletData["Tracer"]			=	2.5
	self.BulletData["Ricochet"]			=	75
	self.BulletData["ShovePower"]		=	0.2
	self.BulletData["FrAera"]			=	1.26677166
	self.BulletData["Caliber"]			=	1.27
	self.BulletData["MinPropLength"]	=	0.01
	self.BulletData["MaxProjLength"]	=	4.16
	self.BulletData["ProjLength"]		=	4.14
	self.BulletData["PropLength"]		=	9.14
	self.BulletData["PropMass"]			=	0.01852526875584
	self.BulletData["MaxPropLength"]	=	9.16
	self.BulletData["MuzzleVel"]		=	969.01169895961
	self.BulletData["LimitVel"]			=	800
	self.BulletData["MaxTotalLength"]	=	15.8
	self.BulletData["ProjVolume"]		=	5.2444346724
	self.BulletData["BoomPower"]		=	0.01852526875584
	self.BulletData["DragCoef"]			=	0.0030575429584786
	self.BulletData["MinProjLength"]	=	1.905
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"
	self.BulletData["InvalidateTraceback"]			= true

end




SWEP.LastAim = Vector()
SWEP.LastThink = CurTime()
SWEP.WasCrouched = false


function SWEP:Think()

	if self.ThinkBefore then self:ThinkBefore() end

	local isReloading = self.Weapon:GetNetworkedBool( "reloading", false )	
	
	if CLIENT then
		self:ZoomThink()
	end
	
	
	ACF.SWEP.Think(self)
	
	
	if self.ThinkAfter then self:ThinkAfter() end
	
	
	if SERVER then
		self:SetNetworkedFloat("ServerInacc", self.Inaccuracy)
		self:SetNetworkedFloat("ServerStam", self.Owner.XCFStamina)
	end
	
end



function SWEP:SetZoom(zoom)

	self.Zoomed = zoom or (not self.Zoomed)
	
	if SERVER then self:SetNetworkedBool("Zoomed", self.Zoomed) end
	
	if self.Zoomed then
		self.cachedmin = self.cachedmin or self.MinInaccuracy
		self.cacheddecayin = self.cacheddecayin or self.InaccuracyDecay
		self.cacheddecayac = self.cacheddecayac or self.AccuracyDecay
		
		self.MinInaccuracy = self.MinInaccuracy * self.ZoomInaccuracyMod
		self.InaccuracyDecay = self.InaccuracyDecay * self.ZoomDecayMod
		self.AccuracyDecay = self.AccuracyDecay * self.ZoomDecayMod
		
		if SERVER then self.Owner:SetFOV(self.ZoomFOV, 0.25) end
	else			
		self.MinInaccuracy = self.cachedmin
		self.InaccuracyDecay = self.cacheddecayin
		self.AccuracyDecay = self.cacheddecayac
		
		self.cachedmin = nil
		self.cacheddecayin = nil
		self.cacheddecayac = nil
		
		if SERVER then self.Owner:SetFOV(0, 0.25) end
	end

end



function SWEP:Holster()
	
	--self:SetZoom(false)
	
	return true
end



function SWEP:CanPrimaryAttack()
	if self.Weapon:GetNetworkedBool( "reloading", false ) then return false end
	if not (ACF.SWEP.NoclipShooting or self.Owner:GetMoveType() == MOVETYPE_WALK or self.Owner:InVehicle()) then return false end
	
	if CurTime() < self.Weapon:GetNextPrimaryFire() then return end
	if self.Primary.ClipSize < 0 then
		local ammoct = self.Owner:GetAmmoCount( self.Primary.Ammo )
		if ammoct <= 0 then return false end
	else
		local clip = self.Weapon:Clip1()
		if clip <= 0 then
			self.Weapon:EmitSound( "Weapon_Pistol.Empty", 100, math.random(90,120) )
			return false
		end
	end
	
	return true
end



function SWEP:SetInaccuracy(add)
	ACF.SWEP.SetInaccuracy(self, add)
end


function SWEP:AddInaccuracy(add)
	ACF.SWEP.AddInaccuracy(self, add)
end



function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.Weapon:TakePrimaryAmmo(1)
		
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		--self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		if SERVER then
			--self.Weapon:EmitSound( self.Primary.Sound )
			
			self:FireBullet()
		end
		self:VisRecoil()
		
		self:AddInaccuracy(self.InaccuracyPerShot)
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end



function SWEP:VisRecoil()
	if SERVER then
		local rnda = self.Primary.Recoil * -1 
		local rndb = self.Primary.Recoil * math.random(-1, 1) 
		
		if self.Zoomed then
			rnda = rnda * 0.25
			rndb = rndb * 0.25
		end
		
		self.Owner:ViewPunch( Angle( rnda,rndb,rnda/4 ) ) 
	end
end



SWEP.Zoomed = false
function SWEP:SecondaryAttack()

	if SERVER and self.HasZoom then
		self:SetZoom()
	end

	return false
	
end



function SWEP:Reload()

	if self.Weapon:GetNetworkedBool( "reloading", false ) then return end

	if self.Zoomed then return false end
	
	if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
		if SERVER then
			self.Weapon:SetNetworkedBool( "reloading", true )
			//self.Weapon:SetVar( "reloadtimer", CurTime() + self.ReloadTime )
			timer.Simple(self.ReloadTime, function() if IsValid(self) then self.Weapon:SetNetworkedBool( "reloading", false ) end end)
			self.Weapon:SetNextPrimaryFire(CurTime() + self.ReloadTime)
			self.Owner:DoReloadEvent()
		end
		
		local reloaded = self:DefaultReload( ACT_VM_RELOAD )
	
		//print("do reload!")
	
		self:SetInaccuracy(self.MaxInaccuracy)
	end

end



function SWEP.randvec(min, max)
	return Vector(	min.x+math.random()*(max.x-min.x),
					min.y+math.random()*(max.y-min.y),
					min.z+math.random()*(max.z-min.z))
end

// Randomly perturbs a vector within a cone of Degs degrees.
// Gaussian distribution, NOT uniform!
SWEP.cachedvec = Vector()
function SWEP:inaccuracy(vec, degs)
	local rand = self.randvec(vec, self.cachedvec)
	self.cachedvec = rand:Cross(VectorRand()):GetNormalized()
	
	local cos = math.cos(math.rad(degs))

	local phi = 2 * math.pi * math.random()
	local z = cos + ( 1 - cos ) * math.random()
	sint = math.sqrt( 1 - z*z )

	return rand * math.cos(phi) * sint + self.cachedvec * math.sin(phi) * sint + vec * z
end



function SWEP:ShootEffects()
 
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )	// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		// 3rd Person Animation

end



function SWEP:FireAnimationEvent(pos,ang,event)
	
	local curtime = CurTime()
	if not self.NextFlash then self.NextFlash = curtime - 0.05 end
	
	-- firstperson muzzleflash
	if ( event == 5001 ) then 
		if self.NextFlash > curtime then return true end
		self.NextFlash = curtime + 0.05
	
		local Effect = EffectData()
			Effect:SetEntity( self )
			--Effect:SetOrigin(pos)
			--Effect:SetAngles(ang)
			Effect:SetScale( self.BulletData["PropMass"] or 1 )
			Effect:SetMagnitude( self.ReloadTime )
			Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1 )	--Encoding the ammo type into a table index
			Effect:SetMaterialIndex(5001) -- flag for effect from animation event
		util.Effect( "ACF_SWEPMuzzleFlash", Effect, true)
	
		return true
	end	
	
	-- Disable thirdperson muzzle flash
	if ( event == 5003 ) then
		if self.NextFlash > curtime then return true end
		self.NextFlash = curtime + 0.05
	
		local Effect = EffectData()
			Effect:SetEntity( self )			
			Effect:SetOrigin(self:GetAttachment(1).Pos)
			--Effect:SetAngles(ang)
			Effect:SetScale( self.BulletData["PropMass"] or 1 )
			Effect:SetMagnitude( self.ReloadTime )
			Effect:SetSurfaceProp( ACF.RoundTypes[self.BulletData["Type"]]["netid"] or 1 )	--Encoding the ammo type into a table index
			Effect:SetMaterialIndex(5003) -- flag for effect from animation event
		util.Effect( "ACF_SWEPMuzzleFlash", Effect, true)
	
		return true
	end
	
	--if ( event == 6002 ) then return true end
	
end




function SWEP:Equip(ply)
	self.Owner = ply
	self:SetNextPrimaryFire(CurTime())
end