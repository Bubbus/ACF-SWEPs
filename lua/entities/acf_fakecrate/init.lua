
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()

	self.SpecialDamage = true
	self.Owner = self:GetOwner()
	
	print("hi from fakecrate")
	
end




local nullhit = {Damage = 0, Overkill = 0, Loss = 0, Kill = false}
function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	return table.Copy(nullhit)
end




function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS
	
end




function ENT:RegisterTo(bullet)
	
	--print("we register crate now", type(bullet), bullet:IsWeapon())
	
	if not (type(bullet) == "table") then
		--print("we got swep?")
		if bullet.BulletData then
			self:SetNetworkedString( "Sound", bullet.Primary and bullet.Primary.Sound or nil)
			self.Owner = bullet:GetOwner()
			self:SetOwner(bullet:GetOwner())
			bullet = bullet.BulletData
		end
	end
	
	
	/*
	self.Model = "models/missiles/aim54.mdl"
	self:SetModel( Model(self.Model) )
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	
	local phys = self:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(false)
		phys:SetMass( bullet.Mass or bullet.RoundMass or 100 ) 
	end 
	//*/
	
	
	self:SetNetworkedInt( "Caliber", bullet.Caliber or 10)
	self:SetNetworkedInt( "ProjMass", bullet.ProjMass or 10)
	self:SetNetworkedInt( "FillerMass", bullet.FillerMass or 0)
	self:SetNetworkedInt( "DragCoef", bullet.DragCoef or 1)
	self:SetNetworkedString( "AmmoType", bullet.Type or "AP")
	self:SetNetworkedInt( "Tracer" , bullet.Tracer or 0)
	local col = bullet.Colour or self:GetColor()
	self:SetNetworkedVector( "Color" , Vector(col.r, col.g, col.b))
	self:SetNetworkedVector( "TracerColour" , Vector(col.r, col.g, col.b))
	self:SetColor(col)
	
	/*
	if bullet.Colour then
		self:SetNetworkedVector( "Color" , bullet.Colour)
		self.SetColor(bullet.Colour)
	else
		self:SetNetworkedVector( "Color" , self:GetColor())
	end
	//*/
	
	--self:SetNetworkedVector( "Accel", bullet.Accel or Vector(0,0,-600))
	
	--pbn(bullet)
	
end


