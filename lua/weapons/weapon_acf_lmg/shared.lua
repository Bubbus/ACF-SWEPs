	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "ar2"

DEFINE_BASECLASS( "weapon_acf_base" )
    
if (CLIENT) then
	
	SWEP.PrintName			= "ACF Machine Gun"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make lots of dudes disappear."
	SWEP.Instructions       = "Reload at 7.62mm MG Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_mach_m249para.mdl";
SWEP.WorldModel 		= "models/weapons/w_mach_m249para.mdl";
SWEP.ViewModelFlip		= false

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 0.8
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Sound 			= "Weapon_M249.Single"

SWEP.ReloadTime				= 7

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 0.55
SWEP.MaxInaccuracy = 6.6
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.14
SWEP.AccuracyDecay = 6
SWEP.InaccuracyPerShot = 1.2
SWEP.InaccuracyCrouchBonus = 2
SWEP.InaccuracyDuckPenalty = 10

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.006 / 1
SWEP.StaminaJumpDrain = 0.2

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.6
SWEP.ZoomDecayMod = 1
SWEP.ZoomFOV = 65

SWEP.IronSights = true
SWEP.IronSightsPos = Vector(-2, 4.46, 2.24)
SWEP.ZoomPos = Vector(2,2,2)
SWEP.IronSightsAng = Angle(0.35, 0, 0)

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.RecoilScale = 0.21
SWEP.RecoilDamping = 0.18


function SWEP:InitBulletData()
	
	self.BulletData = {}
	//*
	self.BulletData["BoomPower"]			= 0.003757751452224
	self.BulletData["Caliber"]			= 0.762
	self.BulletData["DragCoef"]			= 0.0028381676789465
	self.BulletData["FrAera"]			= 0.4560377976
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 800
	self.BulletData["MaxPen"]			= 9.1893699170626
	self.BulletData["MaxProjLength"]			= 7.85
	self.BulletData["MaxPropLength"]			= 8.54
	self.BulletData["MaxTotalLength"]			= 13
	self.BulletData["MinProjLength"]			= 1.143
	self.BulletData["MinPropLength"]			= 0.01
	self.BulletData["MuzzleVel"]			= 700.79707131587
	self.BulletData["PenAera"]			= 0.51303939370339
	self.BulletData["ProjLength"]			= 4.46
	self.BulletData["ProjMass"]			= 0.016068035760638
	self.BulletData["ProjVolume"]			= 2.033928577296
	self.BulletData["PropLength"]			= 5.15
	self.BulletData["PropMass"]			= 0.003757751452224
	self.BulletData["Ricochet"]			= 75
	self.BulletData["RoundVolume"]			= 4.382523234936
	self.BulletData["ShovePower"]			= 0.2
	self.BulletData["Tracer"]			= 2.5
	self.BulletData["Type"]				=	"AP"
	self.BulletData["Id"] 				=	"7.62mmMG"
	self.BulletData["InvalidateTraceback"]			= true
	
end




function SWEP:CalculateVisRecoilScale()

    local moving = self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)
    local crouching = self.Owner:KeyDown(IN_DUCK) or inVehicle
    local zoomed = self:GetNetworkedBool("Zoomed")
    
    if zoomed and crouching and not moving then 
        return 0.06
    else
        return self.BaseClass.CalculateVisRecoilScale(self)
    end

end