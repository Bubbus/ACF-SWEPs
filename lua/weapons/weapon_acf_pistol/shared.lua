	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "pistol"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Pistol"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes one-handedly."
	SWEP.Instructions       = "Reload at 12.7mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_pist_p228.mdl";
SWEP.WorldModel 		= "models/weapons/w_pist_p228.mdl";
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 2
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_P228.Single"

SWEP.ReloadTime				= 2.5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(18, 10, -4)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, -4.74, 2.98)
SWEP.ZoomPos = Vector(2,-2,2)
SWEP.IronSightsAng = Angle(0.45, 0, 0)

SWEP.MinInaccuracy = 1
SWEP.MaxInaccuracy = 5
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.15
SWEP.AccuracyDecay = 0.25
SWEP.InaccuracyPerShot = 3
SWEP.InaccuracyCrouchBonus = 1.3
SWEP.InaccuracyDuckPenalty = 2

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.06

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.6
SWEP.ZoomDecayMod = 1.3
SWEP.ZoomFOV = 70

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.RecoilScale = 0.3
SWEP.RecoilDamping = 0.3


function SWEP:InitBulletData()

	self.BulletData = {}
	//*

	self.BulletData["BoomPower"]			= 0.0047557539540155
	self.BulletData["Caliber"]			= 1.45

	self.BulletData["DragCoef"]			= 0.0027221994813961

	self.BulletData["FrAera"]			= 1.6513035
	self.BulletData["Id"]			= "14.5mmMG"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MuzzleVel"]			= 405.75684870795
	self.BulletData["PenAera"]			= 1.5316264800639

	self.BulletData["ProjLength"]			= 4.6500000953674
	self.BulletData["ProjMass"]			= 0.060660635316597
	self.BulletData["PropLength"]			= 1.7999999523163
	self.BulletData["PropMass"]			= 0.0047557539540155
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 10.65090765374
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 0
	self.BulletData["Type"]			= "AP"
	self.BulletData["InvalidateTraceback"]			= true

end