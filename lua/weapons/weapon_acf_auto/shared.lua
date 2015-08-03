	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Assault Rifle"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes disappear slowly."
	SWEP.Instructions       = "Reload at 12.7mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_rif_galil.mdl";
SWEP.WorldModel 		= "models/weapons/w_rif_galil.mdl";
SWEP.ViewModelFlip		= false

SWEP.Weight				= 5

SWEP.Primary.Recoil			= 2
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.13
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_Galil.Single"

SWEP.ReloadTime				= 3.5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -7)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-3.23, 5.15, 2.290)
SWEP.ZoomPos = Vector(2,2,2)
SWEP.IronSightsAng = Angle(0, 0, 0)

SWEP.MinInaccuracy = 0.45
SWEP.MaxInaccuracy = 5.5
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.25
SWEP.AccuracyDecay = 0.35
SWEP.InaccuracyPerShot = 2.5
SWEP.InaccuracyCrouchBonus = 1.2
SWEP.InaccuracyDuckPenalty = 3.5

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.006 / 1
SWEP.StaminaJumpDrain = 0.1

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.5
SWEP.ZoomDecayMod = 1
SWEP.ZoomFOV = 65

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.RecoilScale = 0.18
SWEP.RecoilDamping = 0.18


function SWEP:InitBulletData()
	
	self.BulletData = {}
	//*
	self.BulletData["BoomPower"]			= 0.00895860917952
	self.BulletData["Caliber"]			= 1.27
	self.BulletData["DragCoef"]			= 0.002438964903295
	self.BulletData["FrAera"]			= 1.26677166
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 10.039540453683
	self.BulletData["MaxProjLength"]			= 8.88
	self.BulletData["MaxPropLength"]			= 8.11
	self.BulletData["MaxTotalLength"]			= 15.8
	self.BulletData["MinProjLength"]			= 1.905
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 601.8434644641
	self.BulletData["PenAera"]			= 1.2226258898987
	self.BulletData["ProjLength"]			= 5.19
	self.BulletData["ProjMass"]			= 0.05193890483166
	self.BulletData["ProjVolume"]			= 6.5745449154
	self.BulletData["PropLength"]			= 4.42
	self.BulletData["PropMass"]			= 0.00895860917952
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 12.1736756526
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 2.5
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"12.7mmMG"
	self.BulletData["InvalidateTraceback"]			= true
	
end