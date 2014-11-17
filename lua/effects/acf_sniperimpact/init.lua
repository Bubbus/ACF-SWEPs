
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.DirVec = data:GetNormal()

	self.Radius = math.Clamp(math.sqrt(1 + data:GetRadius() * 5), 2.5, 6)
	
	--print("poff", self.Radius)
	
	self.Emitter = ParticleEmitter( self.Origin )
	
	local ImpactTr = { }
		ImpactTr.start = self.Origin - self.DirVec*20
		ImpactTr.endpos = self.Origin + self.DirVec*20
	local Impact = util.TraceLine(ImpactTr)					--Trace to see if it will hit anything
	self.Normal = Impact.HitNormal
	
	local GroundTr = { }
		GroundTr.start = self.Origin + Vector(0,0,1)
		GroundTr.endpos = self.Origin - Vector(0,0,1)*self.Radius*20
		GroundTr.mask = 131083
	local Ground = util.TraceLine(GroundTr)				
	
	if Ground.Hit then
		self.DirVec = Lerp(0.4, self.DirVec, Ground.Normal)
	end
	
	-- Material Enum
	-- 65  ANTLION
	-- 66 BLOODYFLESH
	-- 67 CONCRETE / NODRAW
	-- 68 DIRT
	-- 70 FLESH
	-- 71 GRATE
	-- 72 ALIENFLESH
	-- 73 CLIP
	-- 76 PLASTIC
	-- 77 METAL
	-- 78 SAND
	-- 79 FOLIAGE
	-- 80 COMPUTER
	-- 83 SLOSH
	-- 84 TILE
	-- 86 VENT
	-- 87 WOOD
	-- 89 GLASS
	
	//*
	local Mat = Impact.MatType
	local SmokeColor = Vector(90,90,90)
	if Impact.HitSky or not Impact.Hit then
		return
	elseif Mat == 71 or Mat == 73 or Mat == 77 or Mat == 80 then -- Metal
		SmokeColor = Vector(170,170,170)
		self:Metal( SmokeColor )
	elseif Mat == 68 or Mat == 79 then -- Dirt
		SmokeColor = Vector(100,80,50)
		self:Dirt( SmokeColor )	
	elseif Mat == 78 then -- Sand
		SmokeColor = Vector(100,80,50)
		self:Sand( SmokeColor )
	else -- Nonspecific
		SmokeColor = Vector(90,90,90)
		self:Concrete( SmokeColor )
	end
	//*/
	SmokeColor = Vector(90,90,90)
	if Ground.HitWorld then
		--self:Shockwave( Ground, SmokeColor )
		--self:Core()
	end

 end   
 
function EFFECT:Core(SmokeColor, NoSmoke)
	
	local particlemod = self.Radius
	
	for i=0, 4*particlemod do
	
		local Debris = self.Emitter:Add( "effects/fleck_tile"..math.random(1,2), self.Origin )
		if (Debris) then
			Debris:SetVelocity ( (40 * -self.DirVec + 40 * VectorRand()) * self.Radius)
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.75 , 1.5 )*self.Radius/3 )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 255 )
			Debris:SetStartSize( math.Rand(self.Radius / 3, self.Radius / 2) )
			Debris:SetEndSize( self.Radius / 3 )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )			
			Debris:SetAirResistance( 10 ) 			 
			Debris:SetGravity( Vector( 0, 0, -650 ) ) 			
			Debris:SetColor( (120 + SmokeColor.x) / 2, (120 + SmokeColor.y) / 2, (120 + SmokeColor.z) / 2 )
		end
	end
	
	if not NoSmoke then
		for i=0, 1*particlemod do
			local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
				if (Whisp) then
					Whisp:SetVelocity(((30 + i*5) * -self.DirVec + 10 * VectorRand()) * self.Radius)
					Whisp:SetLifeTime( 0 )
					Whisp:SetDieTime( math.Rand( 0.5 , 1 )*self.Radius/3  )
					Whisp:SetStartAlpha( math.Rand( 100, 150 ) )
					Whisp:SetEndAlpha( 0 )
					Whisp:SetStartSize( 1*self.Radius )
					Whisp:SetEndSize( 8*self.Radius )
					Whisp:SetRoll( math.Rand(150, 360) )
					Whisp:SetRollDelta( math.Rand(-0.2, 0.2) )			
					Whisp:SetAirResistance( 150 ) 			 
					Whisp:SetGravity( self.DirVec ) 			
					Whisp:SetColor( SmokeColor.x + math.random() * 30,SmokeColor.y + math.random() * 30,SmokeColor.z + math.random() * 30 )
				end
		end
	end
	/*
	if self.Radius > 4 then
		for i=0, 0.5*self.Radius do
			local Cookoff = EffectData()				
				Cookoff:SetOrigin( self.Origin )
				Cookoff:SetScale( self.Radius/6 )
			util.Effect( "ACF_Cookoff", Cookoff )
		end
	end
	//*/

	sound.Play( "physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav", self.Origin, 100, 100, 1 )
	
end

function EFFECT:Shockwave( Ground, SmokeColor )

	print("shockwave")

	local Mat = Ground.MatType
	local Radius = (1-Ground.Fraction)*self.Radius
	local Density = 15*Radius
	local Angle = Ground.HitNormal:Angle()
	for i=0, Density do	
		
		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), Ground.HitPos )
		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(5,200*Radius) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*Radius /3 )
			Smoke:SetStartAlpha( math.Rand( 50, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 4*Radius )
			Smoke:SetEndSize( 15*Radius )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 10 , 100 ) ) )			
			Smoke:SetColor( SmokeColor.x,SmokeColor.y,SmokeColor.z )
		end	
	
	end

end

function EFFECT:Metal( SmokeColor )

	self:Core(SmokeColor, true)
	
	local particlemod = self.Radius * 0.25
	
	local Sparks = EffectData()
		Sparks:SetOrigin( self.Origin )
		Sparks:SetNormal( self.DirVec )
		Sparks:SetMagnitude( self.Radius * 0.75 )
		Sparks:SetScale( self.Radius / 4 )
		Sparks:SetRadius( self.Radius / 5 )
	util.Effect( "Sparks", Sparks )
	
end

function EFFECT:Concrete( SmokeColor )

	self:Core(SmokeColor)
	
	local particlemod = self.Radius * 0.25
	
	for i=0, 3*self.Radius do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*particlemod) + VectorRand() * math.random( 30,60*particlemod) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*particlemod/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*particlemod )
			Smoke:SetEndSize( 30*particlemod )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*particlemod, math.random(-5,5)*particlemod, -50 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
	
end

function EFFECT:Dirt( SmokeColor )
	
	self:Core(SmokeColor)
	
	local particlemod = self.Radius * 0.25
	
	for i=0, 3*self.Radius do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*particlemod) + VectorRand() * math.random( 30,60*particlemod) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*particlemod/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*particlemod )
			Smoke:SetEndSize( 30*particlemod )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*particlemod, math.random(-5,5)*particlemod, -50 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
		
end

function EFFECT:Sand( SmokeColor )
	
	self:Core(SmokeColor)
	
	local particlemod = self.Radius * 0.25
	
	for i=0, 3*self.Radius do
	
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Origin )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random( 50,80*particlemod) + VectorRand() * math.random( 30,60*particlemod) )
			Smoke:SetLifeTime( 0 )
			Smoke:SetDieTime( math.Rand( 1 , 2 )*particlemod/3  )
			Smoke:SetStartAlpha( math.Rand( 50, 150 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 5*particlemod )
			Smoke:SetEndSize( 30*particlemod )
			Smoke:SetRoll( math.Rand(150, 360) )
			Smoke:SetRollDelta( math.Rand(-0.2, 0.2) )			
			Smoke:SetAirResistance( 100 ) 			 
			Smoke:SetGravity( Vector( math.random(-5,5)*particlemod, math.random(-5,5)*particlemod, -50 ) ) 			
			Smoke:SetColor(  SmokeColor.x,SmokeColor.y,SmokeColor.z  )
		end
	
	end
		
end

   
/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
		
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end

 
