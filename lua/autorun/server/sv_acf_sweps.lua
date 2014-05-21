/*
       _   ___ ___   ___                    
      /_\ / __| __| / __|_ __ _____ _ __ ___
     / _ \ (__| _|  \__ \ V  V / -_) '_ (_-<
    /_/ \_\___|_|   |___/\_/\_/\___| .__/__/
                    By Bubbus!     |_|      

	Conversion of XCF sweps to standalone ACF-compatible format.
	
//*/



AddCSLuaFile("autorun/client/drawarc.lua")



function ACF_CreateBulletSWEP( BulletData, Swep, LagComp )

	if not IsValid(Swep) then error("Tried to create swep round with no swep or owner!") return end
	
	local owner = Swep:IsPlayer() and Swep or Swep.Owner or BulletData.Owner or Ply or error("Tried to create swep round with unowned swep!")

	BulletData = table.Copy(BulletData)
	BulletData.TraceBackComp = owner:GetVelocity():Dot(BulletData.Flight:GetNormalized())
	BulletData.Gun = Swep
	
	BulletData.Filter = BulletData.Filter or {}
	BulletData.Filter[#BulletData.Filter + 1] = Swep
	BulletData.Filter[#BulletData.Filter + 1] = owner
	
	if LagComp then
		BulletData.LastThink = SysTime() - owner:Ping() / 1000
	end
	
	ACF_CustomBulletLaunch(BulletData)
	
	return BulletData
	
end




function ACF_CustomBulletLaunch(BData)

	ACF.CurBulletIndex = ACF.CurBulletIndex + 1		--Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimt then
		ACF.CurBulletIndex = 1
	end

	local cvarGrav = GetConVar("sv_gravity")
	BData.Accel = Vector(0,0,cvarGrav:GetInt()*-1)			--Those are BData settings that are global and shouldn't change round to round
	BData.LastThink = BData.LastThink or SysTime()
	BData["FlightTime"] = 0
	BData["TraceBackComp"] = 0
	
	if BData["FuseLength"] then
		BData["InitTime"] = SysTime()
	end
	
	if not BData.TraceBackComp and BData.Gun:IsValid() then											--Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		BData["TraceBackComp"] = BData.Gun:GetPhysicsObject():GetVelocity():Dot(BData.Flight:GetNormalized())
	end
	
	BData.Filter = BData.Filter or { BData["Gun"] }
	BData.Index = ACF.CurBulletIndex
		
	if XCF and XCF.Ballistics then
		local BulletData = XCF.Ballistics.Launch(BData)
		XCF.Ballistics.CalcFlight( BulletData.Index, BulletData )
	else
		ACF.Bullet[ACF.CurBulletIndex] = table.Copy(BData)		--Place the bullet at the current index pos
		ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
		ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	end
	
	
end




function ACF_ExpandBulletData(bullet)

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