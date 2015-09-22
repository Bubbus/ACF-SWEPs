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

SWEP.ReloadTime				= 9

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false

SWEP.MinInaccuracy = 0.25
SWEP.MaxInaccuracy = 9
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

SWEP.IronSightsPos = Vector(-5, 5, -3)
SWEP.ZoomPos = Vector(-5, 5, -3)
SWEP.IronSightsAng = Angle(0, 0, 0)

SWEP.Class = "C"
SWEP.FlashClass = "AC"
SWEP.Launcher = true

SWEP.RecoilScale = 0.8
SWEP.RecoilDamping = 0.17


function SWEP:InitBulletData()
	
	self.BulletData = {}
	
	self.BulletData["Accel"]		= Vector(0.000000, 0.000000, -600.000000)
	self.BulletData["BoomFillerMass"]		= 1.866775862069
	self.BulletData["BoomPower"]		= 5.6769826262069
	self.BulletData["Caliber"]		= 10
	self.BulletData["CasingMass"]		= 9.4535766450532
	self.BulletData["Colour"]		= Color(255, 255, 255)
	self.BulletData["Detonated"]		= false
	self.BulletData["DragCoef"]		= 0.00049560917633132
	self.BulletData["FillerMass"]		= 5.6003275862069
	self.BulletData["FrAera"]		= 78.54
	self.BulletData["Id"]		= "100mmSC"
	self.BulletData["KETransfert"]		= 0.1
	self.BulletData["LimitVel"]		= 100
	self.BulletData["MuzzleVel"]		= 100.78693207994
	self.BulletData["NotFirstPen"]		= false
	self.BulletData["PenAera"]		= 40.815701243399
	self.BulletData["ProjLength"]		= 89.7
	self.BulletData["ProjMass"]		= 15.847164207366
	self.BulletData["PropLength"]		= 0.61
	self.BulletData["PropMass"]		= 0.07665504
	self.BulletData["Ricochet"]		= 60
	self.BulletData["RoundVolume"]		= 7092.9474
	self.BulletData["ShovePower"]		= 0.1
	self.BulletData["SlugCaliber"]		= 2.6733351371743
	self.BulletData["SlugDragCoef"]		= 0.00070759078367224
	self.BulletData["SlugMV"]		= 1531.2071598766
	self.BulletData["SlugMass"]		= 0.7932599761062
	self.BulletData["SlugPenAera"]		= 4.3332929833938
	self.BulletData["SlugRicochet"]		= 500
	self.BulletData["Tracer"]		= 0.5
	self.BulletData["Type"]		= "HEAT"

	self.BulletData["InvalidateTraceback"]			= true

end