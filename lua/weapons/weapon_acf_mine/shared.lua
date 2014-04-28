	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "grenade"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Landmine"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes disappear 10 years in the future."
	SWEP.Instructions       = "Reload at Bomb Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV               = 65

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_c4.mdl"
SWEP.WorldModel 		= "models/weapons/w_c4.mdl"
SWEP.ThrowModel 		= "models/dav0r/buttons/button.mdl"
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 3
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"
SWEP.Primary.Sound 			= "Weapon_Grenade.Fire"

SWEP.ReloadTime				= 6

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AimOffset = Vector(32, 8, -1)

SWEP.ScopeChopPos = false
SWEP.ScopeChopAngle = false
SWEP.WeaponBone = false//"v_weapon.aug_Parent"

SWEP.MinInaccuracy = 4
SWEP.MaxInaccuracy = 16
SWEP.Inaccuracy = SWEP.MaxInaccuracy
SWEP.InaccuracyDecay = 0.2
SWEP.AccuracyDecay = 0.7
SWEP.InaccuracyPerShot = 12
SWEP.InaccuracyCrouchBonus = 1
SWEP.InaccuracyDuckPenalty = 4

SWEP.Stamina = 1
SWEP.StaminaDrain = 0.004 / 1
SWEP.StaminaJumpDrain = 0.07

SWEP.Class = "MG"
SWEP.FlashClass = "MG"
SWEP.Launcher = false

SWEP.GrenadeRemove		= true
SWEP.HasChargeTimer		= true
SWEP.ChargeTime = 3



function SWEP:InitBulletData()
	
	self.BulletData = {}
	
	--[[
self.BulletData["Accel"]		= Vector(0.000000, 0.000000, -600.000000)
self.BulletData["BoomPower"]		= 3.8279950618744
self.BulletData["Caliber"]		= 7.5
self.BulletData["Colour"]		= Color(255, 255, 255)
self.BulletData["DragCoef"]		= 0.00068601249950007
self.BulletData["FillerMass"]		= 3.8272881507874
self.BulletData["Flight"]		= Vector(0.000000, 0.000000, 0.000000)
self.BulletData["FrAera"]		= 44.178749084473
self.BulletData["Id"]		= "75mmHW"
self.BulletData["KETransfert"]		= 0.10000000149012
self.BulletData["LimitVel"]		= 100
self.BulletData["MuzzleVel"]		= 15.18223285675
self.BulletData["PenAera"]		= 25.028303146362
self.BulletData["Pos"]		= Vector(0.000000, 0.000000, 0.000000)

self.BulletData["ProjLength"]		= 59.990001678467
self.BulletData["ProjMass"]		= 6.4399337768555
self.BulletData["PropLength"]		= 0.0099999997764826
self.BulletData["PropMass"]		= 0.00070685998070985
self.BulletData["Ricochet"]		= 60
self.BulletData["RoundVolume"]		= 2650.7250976563
self.BulletData["ShovePower"]		= 0.10000000149012
self.BulletData["Tracer"]		= 0
self.BulletData["Type"]		= "HE"
]]--

self.BulletData["Colour"]		= Color(255, 255, 255)
self.BulletData["Data10"]		= "0.00"
self.BulletData["Data5"]		= "2319.57"
self.BulletData["Data6"]		= "0"
self.BulletData["Data7"]		= "0"
self.BulletData["Data8"]		= "0"
self.BulletData["Data9"]		= "0"
self.BulletData["Id"]		= "75mmHW"
self.BulletData["ProjLength"]		= "59.99"
self.BulletData["PropLength"]		= "0.01"
self.BulletData["Type"]		= "HE"
self.BulletData.IsShortForm = true





end



//*
function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.PressedTime = CurTime()
		if SERVER then
			self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		end
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end
//*/



function SWEP:ThinkBefore()
	
	if self.PressedTime and not self.Owner:KeyDown(IN_ATTACK) then
		
		self.PressedDuration = CurTime() - self.PressedTime
		self.PressedTime = nil
		
		if SERVER then
			self:ShootEffects()
			self.Weapon:EmitSound( self.Primary.Sound )
			self.Weapon:TakePrimaryAmmo(1)
			self:FireBullet()
		end
		
		self.PressedDuration = nil
		self:VisRecoil()
		self.Inaccuracy = math.Clamp(self.Inaccuracy + self.InaccuracyPerShot, self.MinInaccuracy, self.MaxInaccuracy)
	end
	
end


function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_THROW )		// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	// 3rd Person Animation
end