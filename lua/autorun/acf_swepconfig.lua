/*
       _   ___ ___   ___                    
      /_\ / __| __| / __|_ __ _____ _ __ ___
     / _ \ (__| _|  \__ \ V  V / -_) '_ (_-<
    /_/ \_\___|_|   |___/\_/\_/\___| .__/__/
                    By Bubbus!     |_|      

	Global configuration for the SWEPs!
	
//*/




// What accuracy scheme to use?  Choose from WOT, Shooter
local AimStyle = "Shooter"

// USe ironsights when aiming, or just hug the weapon closer?
local IronSights = true

// How fast should stamina recover after sprinting?  This is a scaling number.
local STAMINA_RECOVER = 0.09

// How much should velocity affect accuracy?  This is a scaling number.
local VEL_SCALE = 60


// In shooter mode, what the minimum inaccuracy is multiplied by.  This balances Shooter with WOT.
local SHOOTER_INACC_MUL = 2

// In shooter mode, how fast should the reticule grow/shrink?
local SHOOTER_LERP_MUL = 2





//  Don't edit below this line ok thanks





ACF = ACF or {}
ACF.SWEP = ACF.SWEP or {}
ACF.SWEP.Aim = ACF.SWEP.Aim or {}
ACF.SWEP.IronSights = IronSights

local swep = ACF.SWEP
local aim = ACF.SWEP.Aim



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



function aim.WOT(self)

	local timediff = CurTime() - self.LastThink
	self.Owner.XCFStamina = self.Owner.XCFStamina or 0
	//print(self.Owner:GetVelocity():Length())
	self.LastAim = self.LastAim or Vector(1, 0, 0)
	
	if self.Owner:GetMoveType() ~= MOVETYPE_WALK then
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
		
		local difflimit = self.InaccuracyAimLimit - self.Inaccuracy
		difflimit = difflimit < 0 and 0 or difflimit
		
		local diffaim = math.min(aim:Distance(self.LastAim) * 30, difflimit)
		
		local crouching = self.Owner:Crouching()
		local decay = self.InaccuracyDecay
		local penalty = 0
		
		//print(self.Owner:KeyDown(IN_SPEED), self.Owner:KeyDown(IN_RUN))
		
		local healthFract = self.Owner:Health() / 100
		self.MaxStamina = math.Clamp(healthFract, 0.5, 1)
		
		if self.Owner:KeyDown(IN_SPEED) then
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaDrain, 0, 1)
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
		
		//self.Inaccuracy = math.Clamp(self.Inaccuracy + (vel + diffaim + penalty - decay) * timediff, self.MinInaccuracy, self.MaxInaccuracy)
		local rawinaccuracy = self.MinInaccuracy + vel * timediff
		local idealinaccuracy = biasedapproach(self.Inaccuracy, rawinaccuracy, decay, self.AccuracyDecay) + penalty + diffaim
		self.Inaccuracy = math.Clamp(idealinaccuracy, self.MinInaccuracy, self.MaxInaccuracy)
		
		//print("inacc", self.Inaccuracy)
		
		self.LastAim = aim
		XCFDBG_ThinkTime = timediff
		self.LastThink = CurTime()
		self.WasCrouched = self.Owner:Crouching()
	
		//PrintMessage( HUD_PRINTCENTER, "vel = " .. math.Round(vel, 2) .. "inacc = " .. math.Round(rawinaccuracy, 2) )
	end
	
end




function aim.Shooter(self)

	self.AddInacc = self.AddInacc or 0
	self.WasJumping = self.WasJumping or true

	local timediff = CurTime() - self.LastThink
	self.Owner.XCFStamina = self.Owner.XCFStamina or 0
	//print(self.Owner:GetVelocity():Length())
	
	if self.Owner:GetMoveType() ~= MOVETYPE_WALK then
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
		local crouching = self.Owner:KeyDown(IN_DUCK)
		
		local inacc = 0
		
		if moving then
			inacc = inacc + 0.333
			
			if sprinting then
				inacc = inacc + 0.4
			elseif walking then
				inacc = inacc - 0.2			
			end
		end
		
		if not crouching then
			inacc = inacc + 0.25
		end
		
		
		local zoomed = self:GetNetworkedBool("Zoomed")
		if zoomed then inacc = inacc * 0.5 end
		
		
		--local jumping = self.Owner:KeyDown(IN_JUMP)
		--if jumping and not self.WasJumping then--and self.Owner:OnGround() then
		--	self.Inaccuracy = self.Inaccuracy + 0.5 * inaccuracydiff
		--end
		
		
		local healthFract = self.Owner:Health() / 100
		self.MaxStamina = math.Clamp(healthFract, 0.25, 1)
		
		if self.Owner:KeyDown(IN_SPEED) then
			self.Owner.XCFStamina = math.Clamp(self.Owner.XCFStamina - self.StaminaDrain, 0, 1)
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



ACF.SWEP.DoAccuracy = aim[AimStyle] or error("ACF SWEPs: Couldn't find the " .. tostring(AimStyle) .. " aim-style!  Please choose a valid aim-style in acf_swepconfig.lua")
