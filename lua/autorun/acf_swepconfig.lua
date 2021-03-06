/*
       _   ___ ___   ___                    
      /_\ / __| __| / __|_ __ _____ _ __ ___
     / _ \ (__| _|  \__ \ V  V / -_) '_ (_-<
    /_/ \_\___|_|   |___/\_/\_/\___| .__/__/
                    By Bubbus!     |_|      

	Global configuration for the SWEPs!
	
//*/




// What accuracy scheme to use?  Choose from WOT, Shooter, Static
local AimStyle = "Shooter"

// What reticule should we use?  Choose from Circle, Crosshair
local Reticule = "Crosshair"

// Use ironsights when aiming, or just hug the weapon closer?
local IronSights = true
// Use lag compensation on bullets?
local LagCompensation = true
// Allow shooting while noclipping
local NoclipShooting = false
// Kick up dust on bullet impacts for all guns, or only snipers?  Fun but potentially laggy.
local AlwaysDust = false
// Make the weapon tracers match the player's custom colour?
local PlayerTracers = true


// How fast should stamina drain while sprinting?  This is a scaling number.
local STAMINA_DRAIN = 0.4
// How fast should stamina recover after sprinting?  This is a scaling number.
local STAMINA_RECOVER = 0.09

// How much should velocity affect accuracy?  This is a scaling number.
local VEL_SCALE = 60


// In WOT mode, what the inaccuracy shrinking is multiplied by.  This balances Shooter with WOT.
local WOT_ACC_SCALE = 1.2
// In WOT mode, what the inaccuracy growth caused my moving your aim is multiplied by.
local WOT_INACC_AIM = 1

// In shooter mode, what the minimum inaccuracy is multiplied by.  This balances Shooter with WOT.
local SHOOTER_INACC_MUL = 2
// In shooter mode, how fast should the reticule grow/shrink?
local SHOOTER_LERP_MUL = 2

// In static mode, what fraction of total spread is added to the minimum spread.  It's pretty much impossible to balance Static with WOT.
local STATIC_INACC_MUL = 0.05





//  Don't edit below this line ok thanks





ACF 					= ACF or {}
ACF.SWEP 				= ACF.SWEP or {}
ACF.SWEP.Aim 			= ACF.SWEP.Aim or {}
ACF.SWEP.IronSights 	= IronSights
ACF.SWEP.LagComp 		= LagCompensation
ACF.SWEP.NoclipShooting = NoclipShooting
ACF.SWEP.AlwaysDust		= AlwaysDust
ACF.SWEP.PlayerTracers  = PlayerTracers

local swep	= ACF.SWEP
local aim	= ACF.SWEP.Aim



local function biasedapproach(cur, target, incup, incdn)	
	incdn = math.abs( incdn )
	incup = math.abs( incup )

    if (cur < target) then
        return math.Clamp( cur + incdn, cur, target )
    elseif (cur > target) then
        return math.Clamp( cur - incup, target, cur )
    end

    return target	
end



function swep.SetInaccuracy(self, val)
	ACF.SWEP.AddInaccuracy(self, val - self.Inaccuracy)
end

function swep.AddInaccuracy(self, add)
	aim[AimStyle].AddInaccuracy(self, add)
	self:SetNetworkedFloat("ServerInacc", self.Inaccuracy)
end


function swep.Think(self)
	return aim[AimStyle].Think(self)
end




aim.WOT = {}
local WOT = aim.WOT
function WOT.Think(self)

	local timediff = CurTime() - self.LastThink
	self.Owner.XCFStamina = self.Owner.XCFStamina or 0
	self.LastAim = type(self.LastAim) == "Vector" and self.LastAim or Vector(1, 0, 0)
	
	if self.Owner:GetMoveType() ~= MOVETYPE_WALK and not self.Owner:InVehicle() then
		self.Inaccuracy = self.MaxInaccuracy
		self.Owner.XCFStamina = 0
	end
	
	if isReloading then
		self.Inaccuracy = self.MaxInaccuracy
	else
	
		local inaccuracydiff = self.MaxInaccuracy - self.MinInaccuracy
		
		//local vel = math.Clamp(math.sqrt(self.Owner:GetVelocity():Length()/400), 0, 1) * inaccuracydiff	// max vel possible is 3500
		local vel = math.Clamp(self.Owner:GetVelocity():Length()/400, 0, 1) * inaccuracydiff * VEL_SCALE	// max vel possible is 3500
		local aim = self.Owner:GetAimVector()
		
		local difflimit = self.InaccuracyAimLimit * WOT_INACC_AIM - self.Inaccuracy
		difflimit = difflimit < 0 and 0 or difflimit
		
		local diffaim = math.min(aim:Distance(self.LastAim) * 30, difflimit)
		
		local crouching = self.Owner:Crouching()
		local jumping = not (self.Owner:OnGround() or inVehicle)
		local decay = self.InaccuracyDecay * WOT_ACC_SCALE
		local penalty = 0
		
		//print(self.Owner:KeyDown(IN_SPEED), self.Owner:KeyDown(IN_RUN))
		
		local healthFract = self.Owner:Health() / 100
		self.MaxStamina = math.Clamp(healthFract, 0.5, 1)
		
		if self.Owner:KeyDown(IN_SPEED) then
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaDrain * STAMINA_DRAIN, 0, 1)
		else
			local recover = (crouching and STAMINA_RECOVER * self.InaccuracyCrouchBonus or STAMINA_RECOVER) * timediff
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina + recover, 0, self.MaxStamina)
		end
		
		decay = decay * self.Owner.XCFStamina
		
		if crouching then
			decay = decay * self.InaccuracyCrouchBonus
		end
		
		if self.WasCrouched != crouching then
			penalty = penalty + self.InaccuracyDuckPenalty
		end
		
		if jumping then
			penalty = penalty + self.InaccuracyPerShot
			if not self.WasJumping and self.Owner:KeyDown(IN_JUMP) then
				self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaJumpDrain, 0, 1)
			end
		end
		
		//self.Inaccuracy = math.Clamp(self.Inaccuracy + (vel + diffaim + penalty - decay) * timediff, self.MinInaccuracy, self.MaxInaccuracy)
		local rawinaccuracy = self.MinInaccuracy + vel * timediff
		local idealinaccuracy = biasedapproach(self.Inaccuracy, rawinaccuracy, decay, self.AccuracyDecay) + penalty + diffaim
		self.Inaccuracy = math.Clamp(idealinaccuracy, self.MinInaccuracy, self.MaxInaccuracy)
		
		//print("inacc", self.Inaccuracy)
		
		self.LastAim = aim
		XCFDBG_ThinkTime = timediff
		self.LastThink = CurTime()
		self.WasCrouched = self.Owner:Crouching()
		self.WasJumping = jumping
	
		//PrintMessage( HUD_PRINTCENTER, "vel = " .. math.Round(vel, 2) .. "inacc = " .. math.Round(rawinaccuracy, 2) )
	end
	
end


function WOT.AddInaccuracy(self, add)
	self.Inaccuracy = math.Clamp(self.Inaccuracy + add, self.MinInaccuracy, self.MaxInaccuracy)
end



aim.Shooter = {}
local Shooter = aim.Shooter
function Shooter.Think(self)

	self.AddInacc = self.AddInacc or 0
	--self.WasJumping = self.WasJumping or true

	local timediff = CurTime() - self.LastThink
	self.Owner.XCFStamina = self.Owner.XCFStamina or 0
	
	local inVehicle = self.Owner:InVehicle()
	
	if self.Owner:GetMoveType() ~= MOVETYPE_WALK and not inVehicle then
		self.Inaccuracy = self.MaxInaccuracy
		self.Owner.XCFStamina = 0
	end
	
	if isReloading then
		self.Inaccuracy = self.MaxInaccuracy
	else
	
		local inaccuracydiff = self.MaxInaccuracy - self.MinInaccuracy		
		
		local moving = self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)
		local sprinting = self.Owner:KeyDown(IN_SPEED)
		local walking = self.Owner:KeyDown(IN_WALK)
		local crouching = self.Owner:KeyDown(IN_DUCK) or inVehicle
		local zoomed = self:GetNetworkedBool("Zoomed")
		local jumping = not (self.Owner:OnGround() or inVehicle)
		
		local inacc = 0.25
		
		if zoomed then 
			if crouching and not moving then 
				inacc = 0
			elseif not moving then
				inacc = inacc * 0.08
			elseif crouching then 
				inacc = inacc * 0.33
			else
				inacc = inacc * 0.66
			end
		elseif crouching then
			inacc = inacc * 0.5
		end
		
		if moving then 
			if sprinting then 
				inacc = inacc * 4
			elseif walking 
				then inacc = inacc * 1.5
			else
				inacc = inacc * 2
			end
		end
		
		if jumping then
			inacc = inacc * 4 
			if not self.WasJumping and self.Owner:KeyDown(IN_JUMP) then
				self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaJumpDrain, 0, 1)
			end
		end
		
		local healthFract = self.Owner:Health() / 100
		self.MaxStamina = math.Clamp(healthFract, 0.25, 1)
		
		if self.Owner:KeyDown(IN_SPEED) then
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaDrain * STAMINA_DRAIN, 0, 1)
		else
			local recover = (crouching and STAMINA_RECOVER * self.InaccuracyCrouchBonus or STAMINA_RECOVER) * timediff
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina + recover, 0, self.MaxStamina)
		end
		
		local accuracycap = ((1 - self.Owner.XCFStamina) * 0.5) ^ 2
		local rawinaccuracy = self.MinInaccuracy * SHOOTER_INACC_MUL + math.max(inacc + self.AddInacc, accuracycap) * inaccuracydiff
		local idealinaccuracy = biasedapproach(self.Inaccuracy, rawinaccuracy, self.InaccuracyDecay * SHOOTER_LERP_MUL, self.AccuracyDecay * SHOOTER_LERP_MUL)
		self.Inaccuracy = math.Clamp(idealinaccuracy, self.MinInaccuracy, self.MaxInaccuracy)
		
		//print("inacc", self.Inaccuracy)
		
		self.LastAim = aim
		XCFDBG_ThinkTime = timediff
		self.LastThink = CurTime()
		self.WasJumping = jumping
	
		//PrintMessage( HUD_PRINTCENTER, "vel = " .. math.Round(vel, 2) .. "inacc = " .. math.Round(rawinaccuracy, 2) )
	end
	
end

function Shooter.AddInaccuracy(self, add)
	self.Inaccuracy = math.Clamp(self.Inaccuracy + add, self.MinInaccuracy, self.MaxInaccuracy)
end



aim.Static = {}
local Static = aim.Static
function Static.Think(self)

	self.AddInacc = self.AddInacc or 0
	self.WasJumping = self.WasJumping or true

	local timediff = CurTime() - self.LastThink
	self.Owner.XCFStamina = self.Owner.XCFStamina or 0
	//print(self.Owner:GetVelocity():Length())
	
	if self.Owner:GetMoveType() ~= MOVETYPE_WALK and not self.Owner:InVehicle() then
		self.Inaccuracy = self.MaxInaccuracy
		self.Owner.XCFStamina = 0
	end
	
	if isReloading then
		self.Inaccuracy = self.MaxInaccuracy
	else
	
		local inaccuracydiff = self.MaxInaccuracy - self.MinInaccuracy		
		
		local inacc = STATIC_INACC_MUL
		
		local zoomed = self:GetNetworkedBool("Zoomed")
		if zoomed then inacc = inacc * (self.HasScope and 0.05 or 0.5) end
		
		local healthFract = self.Owner:Health() / 100
		self.MaxStamina = math.Clamp(healthFract, 0.25, 1)
		
		if self.Owner:KeyDown(IN_SPEED) then
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaDrain * STAMINA_DRAIN, 0, 1)
		else
			local recover = (crouching and STAMINA_RECOVER * self.InaccuracyCrouchBonus or STAMINA_RECOVER) * timediff
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina + recover, 0, self.MaxStamina)
		end
		
		local accuracycap = (1 - self.Owner.XCFStamina) ^ 2
		local rawinaccuracy = self.MinInaccuracy + (inacc + accuracycap) * inaccuracydiff
		//local idealinaccuracy = biasedapproach(self.Inaccuracy, rawinaccuracy, self.InaccuracyDecay * STATIC_LERP_MUL, self.AccuracyDecay * STATIC_LERP_MUL)
		self.Inaccuracy = math.Clamp(rawinaccuracy, self.MinInaccuracy, self.MaxInaccuracy)
		
		//print("inacc", self.Inaccuracy)
		
		self.LastAim = aim
		XCFDBG_ThinkTime = timediff
		self.LastThink = CurTime()
		self.WasJumping = jumping
	
		//PrintMessage( HUD_PRINTCENTER, "vel = " .. math.Round(vel, 2) .. "inacc = " .. math.Round(rawinaccuracy, 2) )
	end
	
end

function Static.AddInaccuracy(self, add)
	//self.Inaccuracy = math.Clamp(self.Inaccuracy + add, self.MinInaccuracy, self.MaxInaccuracy)
end




if CLIENT then

	ACF.SWEP.Reticules = {}
	local rets = ACF.SWEP.Reticules
	
	
	function swep.DrawReticule(self, screenpos, aimRadius, fillFraction, colourFade)
		rets[Reticule].Draw(self, screenpos, aimRadius, fillFraction, colourFade)
	end
	
	
	
	rets.Circle = {}
	local Circle = rets.Circle
	
	function Circle.Draw(self, screenpos, radius, progress, colourFade)
	
		screenpos = Vector(math.floor(screenpos.x + 0.5), math.floor(screenpos.y + 0.5), 0)
	
		local alpha = (self:GetNetworkedBool("Zoomed") and ACF.SWEP.IronSights and self.IronSights and not self.HasScope) and 50 or 255
	
		local circlehue = Color(255, colourFade*255, colourFade*255, alpha)
	
		if self.ShotSpread and self.ShotSpread > 0 then
			radius = ScrW() / 2 * (self.ShotSpread) / self.Owner:GetFOV()
			surface.DrawCircle(screenpos.x, screenpos.y, radius , Color(0, 0, 0, 128) )
			
			radius = ScrW() / 2 * (self.curVisInacc + self.ShotSpread) / self.Owner:GetFOV()
		end
		draw.Arc(screenpos.x, screenpos.y, radius, -2, (1-progress)*360, 360, 3, Color(0, 0, 0, alpha))
		draw.Arc(screenpos.x, screenpos.y, radius, -1, (1-progress)*360, 360, 3, circlehue)
		
	end
	
	
	
	rets.Crosshair = {}
	local Crosshair = rets.Crosshair
	local CrosshairLength = 20
	
	function Crosshair.Draw(self, screenpos, radius, progress, colourFade)
	
		screenpos = Vector(math.floor(screenpos.x + 0.5), math.floor(screenpos.y + 0.5), 0)
	
		local alpha = (self:GetNetworkedBool("Zoomed") and ACF.SWEP.IronSights and self.IronSights and not self.HasScope) and 70 or 255
	
		local circlehue = Color(255, colourFade*255, colourFade*255, alpha)
	
		if self.ShotSpread and self.ShotSpread > 0 then
			radius = ScrW() / 2 * (self.ShotSpread) / self.Owner:GetFOV()
			
			draw.Arc(screenpos.x, screenpos.y, radius, 2, 0, 360, 3, Color(0, 0, 0, 128))
			--surface.DrawCircle(screenpos.x, screenpos.y, radius , Color(0, 0, 0, 128) )
			radius = ScrW() / 2 * (self.curVisInacc + self.ShotSpread) / self.Owner:GetFOV()
		end
		
		if progress < 1 then progress = 1 - progress end
		radius = radius + 1
		
		surface.SetDrawColor(Color(0, 0, 0, circlehue.a))
		surface.DrawRect((screenpos.x - radius - CrosshairLength - 1), screenpos.y - 1, CrosshairLength + 3, 3)
		surface.DrawRect((screenpos.x + radius - 1), screenpos.y - 1, CrosshairLength + 2, 3)
		surface.DrawRect(screenpos.x - 1, (screenpos.y - radius - CrosshairLength - 1), 3, CrosshairLength + 3)
		surface.DrawRect(screenpos.x - 1, (screenpos.y + radius - 1), 3, CrosshairLength + 2)
		
		surface.SetDrawColor(circlehue)
		surface.DrawLine((screenpos.x + radius), screenpos.y, (screenpos.x + (radius + CrosshairLength * progress)), screenpos.y)
		surface.DrawLine((screenpos.x - radius), screenpos.y, (screenpos.x - (radius + CrosshairLength * progress) - 1), screenpos.y)
		surface.DrawLine(screenpos.x, (screenpos.y + radius), screenpos.x, (screenpos.y + (radius + CrosshairLength * progress)))
		surface.DrawLine(screenpos.x, (screenpos.y - radius), screenpos.x, (screenpos.y - (radius + CrosshairLength * progress) - 1))
		
		
		--draw.Arc(screenpos.x, screenpos.y, radius, -1.5, (1-progress)*360, 360, 5, circlehue)
		
	end

	
	
	if not (Reticule and rets[Reticule]) then
		print("ACF SWEPs: Couldn't find the " .. tostring(Reticule) .. " reticule!  Please choose a valid reticule in acf_swepconfig.lua.  Defaulting to Circle.")
		Reticule = "Circle"
	end
	
end




if not (AimStyle and aim[AimStyle]) then
	print("ACF SWEPs: Couldn't find the " .. tostring(AimStyle) .. " aim-style!  Please choose a valid aim-style in acf_swepconfig.lua.  Defaulting to WOT.")
	AimStyle = "WOT"
end

if not aim[AimStyle] then error("ACF SWEPs: Couldn't find the " .. tostring(AimStyle) .. " aim-style!  Please choose a valid aim-style in acf_swepconfig.lua") end

AddCSLuaFile()