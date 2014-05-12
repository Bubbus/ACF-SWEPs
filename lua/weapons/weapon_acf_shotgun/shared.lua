	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Shotgun"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make holes in nearby dudes."
	SWEP.Instructions       = "Reload at 7.62mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_shot_xm1014.mdl";
SWEP.WorldModel 		= "models/weapons/w_shot_xm1014.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5

SWEP.Primary.Recoil			= 2
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 0.3
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_XM1014.Single"

SWEP.ReloadTime				= 0.8
SWEP.ReloadByRound			= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -5.2, 2.19)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.2, 0.74, 0)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 1
SWEP.MaxInaccuracy = 7
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.12
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 6
SWEP.InaccuracyCrouchBonus = 1.3
SWEP.InaccuracyDuckPenalty = 1

SWEP.ShotSpread = 2

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.1

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.1
SWEP.ZoomDecayMod = 1.6
SWEP.ZoomFOV = 65

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false



function SWEP:InitBulletData()
	
	self.BulletData = {}
	//*
	self.BulletData["BoomPower"]			= 0.00054724535712
	self.BulletData["Caliber"]			= 0.762
	self.BulletData["DragCoef"]			= 0.0024820055068243
	self.BulletData["FrAera"]			= 0.4560377976
	self.BulletData["Id"]			= "7.62mmMG"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MuzzleVel"]			= 250.09306022354
	self.BulletData["PenAera"]			= 0.51303939370339
	self.BulletData["ProjLength"]			= 5.0999999046326
	self.BulletData["ProjMass"]			= 0.018373762521724
	self.BulletData["PropLength"]			= 0.75
	self.BulletData["PropMass"]			= 0.00054724535712
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 2.6678210724688
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "AP"
	self.BulletData["InvalidateTraceback"]			= true
end



function SWEP:ThinkBefore()
	if self.Owner:KeyDown(IN_ATTACK) and self.Weapon:GetNetworkedBool( "reloading", false ) then
		if self.Weapon:Clip1() > 0 and self.Weapon:Clip1() < self.Primary.ClipSize then
			//print("cancelled")
			self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
			self.Weapon:SetNetworkedBool( "reloading", false )
		end
	end
end




function SWEP:Reload()
	if self.Weapon:GetNetworkedBool( "reloading", false ) then return end
	
	if self.Zoomed then return false end

	if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
		if SERVER then
			self.Weapon:SetNetworkedBool( "reloading", true )
			timer.Simple(self.ReloadTime, function() self:ReloadShell() end)
			self.Owner:DoReloadEvent()
		end

		//print("do shotgun reload!")
		
		self.Weapon:SetNetworkedBool( "reloading", true )
		//self.Weapon:SetVar( "reloadtimer", CurTime() + self.ReloadTime )
		self.Owner:DoReloadEvent()
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
		
		self.Inaccuracy = self.MaxInaccuracy
	end
end


function SWEP:ReloadShell()
	if not self.Weapon:GetNetworkedBool( "reloading", false ) then return end
	
	if self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
		self.Weapon:SetNetworkedBool( "reloading", false )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		self.Owner:DoReloadEvent()
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return
	end

	timer.Simple(self.ReloadTime, function() self:ReloadShell() end)
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	self.Owner:DoReloadEvent()

	if SERVER then
		self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
		self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
	end
end
