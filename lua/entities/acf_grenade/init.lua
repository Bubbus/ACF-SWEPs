
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

CreateConVar('sbox_max_acf_grenade', 20)




function ENT:Initialize()
	
	self.BulletData = {}	
	self.SpecialDamage = true	--If true needs a special ACF_OnDamage function
	self.ShouldTrace = false
	
	self.Model = "models/missiles/aim54.mdl"
	self:SetModelEasy(self.Model)
	
	self.Inputs = Wire_CreateInputs( self, { "Detonate" } )
	self.Outputs = Wire_CreateOutputs( self, {} )
	
	self.ThinkDelay = 0.1
	--self.ACF_HEIgnore = true
	
end



function ENT:ACF_OnDamage( Entity , Energy , FrAera , Angle , Inflictor )
	local HitRes = ACF_PropDamage( Entity , Energy , FrAera , Angle , Inflictor )	--Calling the standard damage prop function
	if self.Detonated then return HitRes end
	
	local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
	if CanDo == false then return HitRes end
	
	HitRes.Kill = false
	self:Detonate()
	
	return HitRes --This function needs to return HitRes
end




function ENT:TriggerInput( inp, value )
	if inp == "Detonate" and value ~= 0 then
		self:Detonate()
	end
end




function MakeACF_Grenade(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	--print(Owner, Pos, Angle, Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	if not Owner:CheckLimit("_acf_grenade") then return false end
	
	--print(Id, Data1, Data2)
	local weapon = ACF.Weapons.Guns[Data1]
	--[[
	if not (weapon and weapon.roundclass and weapon.roundclass == "Bomb") then
		return false, "Can't make a bomb with non-bomb round-data!"
	end
	--]]--
	
	local Bomb = ents.Create("acf_grenade")
	if not Bomb:IsValid() then return false end
	Bomb:SetAngles(Angle)
	Bomb:SetPos(Pos)
	Bomb:Spawn()
	Bomb:SetPlayer(Owner)
	Bomb.Owner = Owner
	
	if type(Id) == "table" and type(Data1) == "string" then
		Mdl = Data1
		local bdata = Id
		Id = bdata.Id
		Data1 = bdata.Data1 or bdata.Id
		Data2 = bdata.Type or bdata.Data2
		Data3 = bdata.PropLength or bdata.Data3
		Data4 = bdata.ProjLength or bdata.Data4
		Data5 = bdata.Data5
		Data6 = bdata.Data6
		Data7 = bdata.Data7
		Data8 = bdata.Data8
		Data9 = bdata.Data9
		Data10 = bdata.Data10
	end
	
	Mdl = Mdl or ACF.Weapons.Guns[Id].model
	
	Bomb.Id = Id
	Bomb:CreateBomb(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)
	
	Owner:AddCount( "_acf_grenade", Bomb )
	Owner:AddCleanup( "acfmenu", Bomb )
	
	return Bomb
end
list.Set( "ACFCvars", "acf_grenade", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "mdl"} )
duplicator.RegisterEntityClass("acf_grenade", MakeACF_Grenade, "Pos", "Angle", "Id", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10", "Model" )




function ENT:CreateBomb(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	self:SetModelEasy(Mdl)
	--print(Id, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)
	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId = Data1		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType = Data2		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3--Lenght of propellant
	self.RoundProjectile = Data4--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 )
	self.RoundData6 = ( Data6 or 0 )
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )
	
	local PlayerData = {}
		PlayerData.Id = self.RoundId
		PlayerData.Type = self.RoundType
		PlayerData.PropLength = self.RoundPropellant
		PlayerData.ProjLength = self.RoundProjectile
		PlayerData.Data5 = self.RoundData5
		PlayerData.Data6 = self.RoundData6
		PlayerData.Data7 = self.RoundData7
		PlayerData.Data8 = self.RoundData8
		PlayerData.Data9 = self.RoundData9
		PlayerData.Data10 = self.RoundData10
	
	
	local guntable = ACF.Weapons.Guns
	local gun = guntable[self.RoundId] or {}
	--local roundclass = XCF.ProjClasses[gun.roundclass or "Bomb"] or error("Unrecognized projectile class " .. (gun.roundclass or "Bomb") .. "!")
	--print("omg jc a bomb!", roundclass)
	--PrintTable(PlayerData)
	self:SetBulletData(ACF_ExpandBulletData(PlayerData))
	
end




function ENT:SetModelEasy(mdl)
	mdl = Model(mdl)
	if not mdl then return end
	self:SetModel( Model(mdl) )
	self.Model = mdl
	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )     	
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass( 10 ) 
	end 
end




function ENT:SetBulletData(bdata)

	--[[
	if bdata.IsShortForm or bdata.Data1 then
		self:CreateBomb(
			bdata.Id,
			bdata.Data1 or bdata.Id,
			bdata.Type or bdata.Data2,
			bdata.PropLength or bdata.Data3,
			bdata.ProjLength or bdata.Data4,
			bdata.Data5, bdata.Data6, bdata.Data7, bdata.Data8, bdata.Data9, bdata.Data10, nil)
	end
	]]--

	self.BulletData = table.Copy(bdata)
	self.BulletData.Entity = self
	self.BulletData.Crate = self
	
	local col = self.BulletData.Colour or Color(255, 255, 255)
	self:SetNetworkedVector( "TracerColour",  Vector(col.r, col.g, col.b))
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (IsValid(phys)) then  		
		phys:SetMass( bdata.ProjMass or bdata.RoundMass or bdata.Mass or 10 ) 
	end
end




local trace = {}
function ENT:TraceFunction()
	local pos = self:GetPos()
	trace.start = pos
	trace.endpos = pos + self:GetVelocity() * self.ThinkDelay
	trace.filter = self

	local res = util.TraceEntity( trace, self ) 
	if res.Hit then
		self:OnTraceContact(res)
	end
end




function ENT:Think()
 	
	if self.ShouldTrace then
		self:TraceFunction()
	end
	
	self:NextThink(CurTime() + self.ThinkDelay)
	
	return true
		
end




function ENT:Detonate()
	
	if self.Detonated then return end
	
	self.Detonated = true
	
	local bdata = self.BulletData
	local pos = self:GetPos()
	local up = self:GetUp()
	local phys = self:GetPhysicsObject()
	local phyvel = phys and phys:GetVelocity() or Vector(0, 0, 0.01)
	
	--pbn(bdata)
	
	bdata.RoundMass = bdata.RoundMass or bdata.ProjMass
	bdata.ProjMass = bdata.ProjMass or bdata.RoundMass 
	
	self.Entity:Remove()
	
	ACF.RoundTypes[bdata.Type]["endflight"]( -1337, bdata, pos, up )
	
	bdata.SimPos = pos
	bdata.SimFlight = phyvel
	
	ACF.RoundTypes[bdata.Type]["endeffect"]( nil, bdata)

end


--local undonked = true
function ENT:OnTraceContact(trace)
	/*
	if undonked then
		print("donk!")
		printByName(trace)
		undonked = false
	end
	//*/
end



function ENT:SetShouldTrace(bool)
	self.ShouldTrace = bool and true
	--print(self.ShouldTrace)
	self:NextThink(CurTime())
end




function ENT:EnableClientInfo(bool)
	self.ClientInfo = bool
	self:SetNetworkedBool("VisInfo", bool)
	
	if bool then
		self:RefreshClientInfo()
	end
end



function ENT:RefreshClientInfo()
	self:SetNetworkedString("RoundId", self.RoundId)
	self:SetNetworkedString("RoundType", self.RoundType)
	self:SetNetworkedFloat("FillerVol", self.RoundData5)
end