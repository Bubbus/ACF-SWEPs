
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
	
	local Gun = data:GetEntity()
	local Propellant = data:GetScale() or 1
	local ReloadTime = data:GetMagnitude() or 1
	local Class = Gun.Class
	local FlashClass = Gun.FlashClass
	local RoundType = ACF.IdRounds[data:GetSurfaceProp()] or "AP"
	
	local PosOverride = data:GetOrigin()
	
	--print(PosOverride)
	
	local FromAnimationEvent = data:GetMaterialIndex() or 0
	if FromAnimationEvent < 1 then
		FromAnimationEvent = false
	end
		
	if not ACF.Classes.GunClass[Class] then 
		Class = "C"
	end
		
		
	local GunSound = Gun:GetNWString( "Sound" ) or ACF.Classes["GunClass"][Class]["sound"] or ""
		
	if Gun:IsValid() then
	
		local lply = false
		if CLIENT and LocalPlayer() == Gun.Owner then
			if not FromAnimationEvent then return end
			lply = true
		end
	
		if Propellant > 0 then
		
			local SoundPressure = (Propellant*1000)^0.5
			
			Muzzle =
			{
				Pos = Gun.Owner:GetShootPos(),
				Ang = Gun.Owner:EyeAngles()
			}
			
			Gun:EmitSound( GunSound, math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255), 1, CHAN_WEAPON )
			//sound.Play( GunSound, Muzzle.Pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
			if not ((Class == "MG") or (Class == "RAC")) then
				//sound.Play( GunSound, Muzzle.Pos , math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255))
				Gun:EmitSound( GunSound, math.Clamp(SoundPressure,75,255), math.Clamp(100,15,255), 1, CHAN_WEAPON )
			end
			
			local aimoffset = Gun.AimOffset or Vector()
			--local muzzoffset
			if FromAnimationEvent == 5003 then
				Muzzle.Pos = PosOverride
				--muzzoffset = Vector(0,0,0)
			elseif FromAnimationEvent == 5001 then
				local mdl = Gun.Owner:GetViewModel()
				Muzzle.Pos = mdl:GetAttachment(1).Pos
				--muzzoffset = Vector(0,0,0)
			end
			
			--Muzzle.Pos = Muzzle.Pos + muzzoffset
			
			local flash = ACF.Classes["GunClass"][FlashClass]["muzzleflash"]
			
			ParticleEffect( flash, Muzzle.Pos, Muzzle.Ang, Gun )
			
			if Gun.Launcher then
				local muzzoffset = (Muzzle.Ang:Forward() * -aimoffset.x) + (Muzzle.Ang:Right() * aimoffset.y) + (Muzzle.Ang:Up() * aimoffset.z)
			
				Muzzle.Pos = Gun.Owner:GetShootPos() + muzzoffset
				Muzzle.Ang = (-Muzzle.Ang:Forward()):Angle()
				ParticleEffect( flash, Muzzle.Pos, Muzzle.Ang, Gun )
			end
			
		end
	end
	
 end 
 
 
 
   
   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end