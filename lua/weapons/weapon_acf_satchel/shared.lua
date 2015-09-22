	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "grenade"

if (CLIENT) then
	
	SWEP.PrintName			= "ACF Satchel Charge"
	SWEP.Author				= "Bubbus"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "f"
	SWEP.DrawCrosshair		= false
	SWEP.Purpose		= "Make dudes disappear in interesting ways."
	SWEP.Instructions       = "Reload at Bomb Ammo-boxes!"

end

util.PrecacheSound( "weapons/launcher_fire.wav" )

SWEP.Base				= "weapon_acf_base"
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV               = 65

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.Category			= "ACF"
SWEP.ViewModel 			= "models/weapons/v_slam.mdl"
SWEP.WorldModel 		= "models/weapons/w_slam.mdl"
SWEP.ThrowModel 		= "models/weapons/w_slam.mdl"
SWEP.ViewModelFlip		= true

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil			= 5
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 4.5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"
SWEP.Primary.Sound 			= "Weapon_Grenade.Fire"

SWEP.ReloadTime				= 4.5

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
SWEP.ChargeTime = 3
SWEP.ThrowVel	= 3



function SWEP:InitBulletData()
	
	self.BulletData = {}
	self.BulletData["Colour"]		= Color(255, 255, 255)
	self.BulletData["Data10"]		= "0.00"
	self.BulletData["Data5"]		= "4976.37"
	self.BulletData["Data6"]		= "86.55"
	self.BulletData["Data7"]		= ""
	self.BulletData["Data8"]		= ""
	self.BulletData["Data9"]		= ""
	self.BulletData["Id"]		= "122mmHW"
	self.BulletData["ProjLength"]		= "101.40"
	self.BulletData["PropLength"]		= "3.90"
	self.BulletData["Type"]		= "HEAT"
	
	self.BulletData.IsShortForm = true
	
end



//*
function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self.PressedTime = CurTime()
		if SERVER then
			self.Owner.ACFSatchels = self.Owner.ACFSatchels or {}
			--self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		end
		
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end
//*/



function SWEP:SecondaryAttack()

	if self:GetNextSecondaryFire() < CurTime() then
		
		if SERVER then
			timer.Simple(0.25, function() self:DetonateSatchels() end)
		else
			self:EmitSound("buttons/button24.wav", 50, 100)
			--self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
		end
		
	end
	
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)
end




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
	--self:SendWeaponAnim( ACT_SLAM_THROW_THROW )		// View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )	// 3rd Person Animation
end