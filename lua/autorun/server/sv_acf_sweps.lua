/*
       _   ___ ___   ___                    
      /_\ / __| __| / __|_ __ _____ _ __ ___
     / _ \ (__| _|  \__ \ V  V / -_) '_ (_-<
    /_/ \_\___|_|   |___/\_/\_/\___| .__/__/
                    By Bubbus!     |_|      

	Conversion of XCF sweps to standalone ACF-compatible format.
	
//*/



AddCSLuaFile("autorun/client/drawarc.lua")

if not ACF then error("ACF is not installed - ACF SWEPs require it!") end

ACF.SWEP = ACF.SWEP or {}

ACF.SWEP.PlyBullets = ACF.SWEP.PlyBullets or {}
local bullets = ACF.SWEP.PlyBullets



function ACF_CreateBulletSWEP( BulletData, Swep, LagComp )

	if not IsValid(Swep) then error("Tried to create swep round with no swep or owner!") return end
	
	local owner = Swep:IsPlayer() and Swep or Swep.Owner or BulletData.Owner or error("Tried to create swep round with unowned swep!")

	BulletData = table.Copy(BulletData)
	
	if LagComp then
		BulletData.LastThink = SysTime()
		
		BulletData.Owner = owner
		BulletData.HandlesOwnIteration = true
		BulletData.OnRemoved = ACF_SWEP_OnRemoved
	end
	
	BulletData.TraceBackComp = 0
	--BulletData.TraceBackComp = owner:GetVelocity():Dot(BulletData.Flight:GetNormalized())
	BulletData.Gun = Swep
	
	BulletData.Filter = BulletData.Filter or {}
    
    if IsValid(Swep) then
        BulletData.Filter[#BulletData.Filter + 1] = Swep
    end
    
	if IsValid(owner) then
        BulletData.Filter[#BulletData.Filter + 1] = owner
        
        local vehicle = owner:GetVehicle()
        if IsValid(vehicle) then
            BulletData.Filter[#BulletData.Filter + 1] = vehicle
        end
    end
	
	ACF_CustomBulletLaunch(BulletData)
	
	return BulletData
	
end




function ACF_SWEP_PlayerTickSimulate(ply, move)
	
	local plyBullets = bullets[ply]
	if not plyBullets or #plyBullets < 1 then return end
	
	local CalcFlight = (XCF and XCF.Ballistics and XCF.Ballistics.CalcFlight) or ACF_CalcBulletFlight or error("Could not find ACF flight calc function.")
	
	ply:LagCompensation(true)
	
	for k, bullet in pairs(plyBullets) do
		--print("sim bullet ", k)
		CalcFlight( bullet.Index, bullet )
	end
	
	ply:LagCompensation(false)
	
end

if ACF.Version and ACF.Version < 506 then ErrorNoHalt("ACF SWEPs need ACF v506 or greater to use lag compensation!  Please update ACF!")
else hook.Add("PlayerTick", "ACF_SWEP_PlayerTickSimulate", ACF_SWEP_PlayerTickSimulate) end




function ACF_SWEP_PlayerDisconnected(ply)
	//print("plyDisconn", ply)
	if not IsValid(ply) then return end

	local plyBullets = bullets[ply]
	if not plyBullets then return end
	
	local RemoveBullet = (XCF and XCF.Ballistics and XCF.Ballistics.RemoveProj) or ACF_RemoveBullet or error("Could not find ACF bullet removal function.")
	
	for k, bullet in pairs(plyBullets) do
		if not bullet.Index then continue end
		RemoveBullet(bullet.Index)
	end
	
	bullets[ply] = nil
end
hook.Add( "PlayerDisconnected", "ACF_SWEP_PlayerDisconnected", ACF_SWEP_PlayerDisconnected)




function ACF_SWEP_OnRemoved(bullet)
	--print("rem", bullet)
	if bullet.OwnerIndex then
		bullets[bullet.Owner][bullet.OwnerIndex] = nil
	end
end




function ACF_BulletLaunch(BData)

	ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimt then
		ACF.CurBulletIndex = 1
	end

	local cvarGrav = GetConVar("sv_gravity")
	BData.Accel = Vector(0,0,cvarGrav:GetInt()*-1)			--Those are BData settings that are global and shouldn't change round to round
	BData.LastThink = BData.LastThink or SysTime()
	BData["FlightTime"] = 0
	--BData["TraceBackComp"] = 0
	local Owner = BData.Owner
	
	if BData["FuseLength"] then
		BData["InitTime"] = SysTime()
	end
	
	if not BData.TraceBackComp then											--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		if IsValid(BData.Gun) then
			BData["TraceBackComp"] = BData.Gun:GetPhysicsObject():GetVelocity():Dot(BData.Flight:GetNormalized())
		else
			BData["TraceBackComp"] = 0
		end
	end
	
	BData.Filter = BData.Filter or { BData["Gun"] }
		
	if XCF and XCF.Ballistics then
		BData = XCF.Ballistics.Launch(BData)
		--XCF.Ballistics.CalcFlight( BulletData.Index, BulletData )
	else
		BData.Index = ACF.CurBulletIndex
		ACF.Bullet[ACF.CurBulletIndex] = BData		--Place the bullet at the current index pos
		ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
		--ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	end
	
end




function ACF_CustomBulletLaunch(BData)

	ACF_BulletLaunch(BData)
	
	if BData.HandlesOwnIteration then
		bullets[BData.Owner] = bullets[BData.Owner] or {}
		local btbl = bullets[BData.Owner]
		local btblIdx = #btbl+1
		BData.OwnerIndex = btblIdx
		btbl[btblIdx] = BData
	end
	
end




function ACF_ExpandBulletData(bullet)

	//print("expand bomb")
	//print(debug.traceback())

	/*
	print("\n\nBEFORE EXPAND:\n")
	printByName(bullet)
	//*/

	local toconvert = {}
	toconvert["Id"] = 			bullet["Id"] or "12.7mmMG"
	toconvert["Type"] = 		bullet["Type"] or "AP"
	toconvert["PropLength"] = 	bullet["PropLength"] or 0
	toconvert["ProjLength"] = 	bullet["ProjLength"] or 0
	toconvert["Data5"] = 		bullet["FillerVol"] or bullet["Flechettes"] or bullet["Data5"] or 0
	toconvert["Data6"] = 		bullet["ConeAng"] or bullet["FlechetteSpread"] or bullet["Data6"] or 0
	toconvert["Data7"] = 		bullet["Data7"] or 0
	toconvert["Data8"] = 		bullet["Data8"] or 0
	toconvert["Data9"] = 		bullet["Data9"] or 0
	toconvert["Data10"] = 		bullet["Tracer"] or bullet["Data10"] or 0
	toconvert["Colour"] = 		bullet["Colour"] or Color(255, 255, 255)
		
	/*
	print("\n\nTO EXPAND:\n")
	printByName(toconvert)
	//*/
		
	local rounddef = ACF.RoundTypes[bullet.Type] or error("No definition for the shell-type", bullet.Type)
	local conversion = rounddef.convert
	--print("rdcv", rounddef, conversion)
	
	if not conversion then error("No conversion available for this shell!") end
	local ret = conversion( nil, toconvert )
	
	--ret.ProjClass = this
	
	ret.Pos = bullet.Pos or Vector(0,0,0)
	ret.Flight = bullet.Flight or Vector(0,0,0)
	ret.Type = ret.Type or bullet.Type
	
	local cvarGrav = GetConVar("sv_gravity")
	ret.Accel = Vector(0,0,cvarGrav:GetInt()*-1)
	if ret.Tracer == 0 and bullet["Tracer"] and bullet["Tracer"] > 0 then ret.Tracer = bullet["Tracer"] end
	ret.Colour = toconvert["Colour"]
	/*
	print("\n\nAFTER EXPAND:\n")
	printByName(ret)
	//*/
	
	return ret

end




function ACF_CompactBulletData(crate)  
    
    local compact = {}

    compact["Id"] = 			crate.RoundId       or crate.Id
    compact["Type"] = 		    crate.RoundType     or crate.Type
    compact["PropLength"] = 	crate.PropLength    or crate.RoundPropellant
    compact["ProjLength"] = 	crate.ProjLength    or crate.RoundProjectile
    compact["Data5"] = 		    crate.Data5         or crate.RoundData5         or crate.FillerVol      or crate.CavVol             or crate.Flechettes
    compact["Data6"] = 		    crate.Data6         or crate.RoundData6         or crate.ConeAng        or crate.FlechetteSpread
    compact["Data7"] = 		    crate.Data7         or crate.RoundData7
    compact["Data8"] = 		    crate.Data8         or crate.RoundData8
    compact["Data9"] = 		    crate.Data9         or crate.RoundData9
    compact["Data10"] = 		crate.Data10        or crate.RoundData10        or crate.Tracer
    
    compact["Colour"] = 		crate.GetColor and crate:GetColor() or crate.Colour
    
    
    if not compact.Data5 and crate.FillerMass then
        local Filler = ACF.FillerDensity[compact.Type]
        
        if Filler then
            compact.Data5 = crate.FillerMass / ACF.HEDensity * Filler
        end
    end
    
    return compact
end




function ACF_MakeCrateForBullet(self, bullet)

	if not (type(bullet) == "table") then
		--print("we got swep?")
		if bullet.BulletData then
			self:SetNetworkedString( "Sound", bullet.Primary and bullet.Primary.Sound or nil)
			self.Owner = bullet:GetOwner()
			self:SetOwner(bullet:GetOwner())
			bullet = bullet.BulletData
		end
	end
	
	
	self:SetNetworkedInt( "Caliber", bullet.Caliber or 10)
	self:SetNetworkedInt( "ProjMass", bullet.ProjMass or 10)
	self:SetNetworkedInt( "FillerMass", bullet.FillerMass or 0)
	self:SetNetworkedInt( "DragCoef", bullet.DragCoef or 1)
	self:SetNetworkedString( "AmmoType", bullet.Type or "AP")
	self:SetNetworkedInt( "Tracer" , bullet.Tracer or 0)
    
	local col = bullet.Colour or self:GetColor()
	self:SetNWVector( "Color" , Vector(col.r, col.g, col.b))
	self:SetNWVector( "TracerColour" , Vector(col.r, col.g, col.b))
	self:SetColor(col)

end