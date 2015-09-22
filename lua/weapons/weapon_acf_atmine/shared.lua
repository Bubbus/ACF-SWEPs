	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "grenade"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Anti-Tank Mine"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make tanks disappear 10 years in the future."
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
SWEP.ThrowModel 		= "models/maxofs2d/button_05.mdl"
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 6
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"
SWEP.Primary.Sound 			= "Weapon_Grenade.Fire"

SWEP.ReloadTime				= 5

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

SWEP.IsGrenadeWeapon	= true
SWEP.GrenadeRemove		= true
SWEP.HasChargeTimer		= true
SWEP.ChargeTime = 1.5
SWEP.ThrowVel	= 4



function SWEP:InitBulletData()
	
	//*
	self.BulletData = {}
	self.BulletData["Colour"]		= Color(255, 255, 255)
	self.BulletData["Data10"]		= "0.00"
	self.BulletData["Data5"]		= "12059.81"
	self.BulletData["Data6"]		= "86.38"
	self.BulletData["Data7"]		= ""
	self.BulletData["Data8"]		= ""
	self.BulletData["Data9"]		= ""
	self.BulletData["Id"]		= "155mmHW"
	self.BulletData["ProjLength"]		= "122.75"
	self.BulletData["PropLength"]		= "0.42"
	self.BulletData["Type"]		= "HEAT"

	self.BulletData.IsShortForm = true
	//*/

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
		self:AddInaccuracy(self.InaccuracyPerShot)
	end
	
end


function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_THROW )		// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	// 3rd Person Animation
end