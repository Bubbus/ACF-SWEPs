	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "rpg"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Anti-Tank GL"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make tanks disappear."
	SWEP.Instructions       = "Reload at 50mm Cannon Ammo-boxes!"
	//SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/potato_launcher.vtf")

end



SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_RPG.mdl";
SWEP.WorldModel 		= "models/weapons/w_rocket_launcher.mdl";

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 20
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"
SWEP.Primary.Sound 			= "acf_extra/tankfx/gnomefather/8mm1.wav"

util.PrecacheSound( SWEP.Primary.Sound )

SWEP.ReloadTime				= 8

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false

SWEP.MinInaccuracy = 1
SWEP.MaxInaccuracy = 12
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.13
SWEP.AccuracyDecay = 0.3
SWEP.InaccuracyPerShot = 11
SWEP.InaccuracyCrouchBonus = 1.4
SWEP.InaccuracyDuckPenalty = 5

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.005 / 1
SWEP.StaminaJumpDrain = 0.25

SWEP.HasZoom = true
SWEP.ZoomInaccuracyMod = 0.5
SWEP.ZoomDecayMod = 1.2
SWEP.ZoomFOV = 50

SWEP.Class = "C"
SWEP.FlashClass = "AC"
SWEP.Launcher = true


function SWEP:InitBulletData()
	
	self.BulletData = {}
	self.BulletData["BoomPower"]			= 0.98255158122041
	self.BulletData["Caliber"]			= 5
	self.BulletData["CasingMass"]			= 2.6050961123304

	self.BulletData["Detonated"]			= false
	self.BulletData["DragCoef"]			= 0.00054572613655341
	self.BulletData["FillerMass"]			= 0.96527278084591

	self.BulletData["FrAera"]			= 19.635
	self.BulletData["Id"]			= "50mmC"
	self.BulletData["KETransfert"]			= 0.1
	self.BulletData["LimitVel"]			= 100
	self.BulletData["MuzzleVel"]			= 100.42419639755
	self.BulletData["PenAera"]			= 12.562505640641


	self.BulletData["ProjLength"]			= 61.400001525879
	self.BulletData["ProjMass"]			= 3.5979585152375
	self.BulletData["PropLength"]			= 0.55000001192093
	self.BulletData["PropMass"]			= 0.017278800374508
	self.BulletData["Ricochet"]			= 60
	self.BulletData["RoundVolume"]			= 1216.3882801947
	self.BulletData["ShovePower"]			= 0.1
	self.BulletData["SlugCaliber"]			= 1.1009099135806
	self.BulletData["SlugDragCoef"]			= 0.003450235271917
	self.BulletData["SlugMV"]			= 3656.0900686825
	self.BulletData["SlugMass"]			= 0.027589622061193
	self.BulletData["SlugPenAera"]			= 0.95897059965937
	self.BulletData["SlugRicochet"]			= 500
	self.BulletData["Tracer"]			= 1
	self.BulletData["Type"]			= "HEAT"
	self.BulletData["InvalidateTraceback"]			= true

end