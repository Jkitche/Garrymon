

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	local ranV = VectorRand()
	for i = 1, 5 do
		ranV = Vector(math.Rand(-25,25), math.Rand(-25,25), math.Rand(25,50))
		local Pos = data:GetOrigin()
		local Emitter = ParticleEmitter(Pos)
			local p = Emitter:Add( "pokemon/star",Pos )
			p:SetVelocity( ranV )
			p:SetDieTime( 3 )
			p:SetStartAlpha( 255 )
			p:SetEndAlpha( 0 )
			p:SetStartSize( 2 )
			p:SetEndSize( 2 )
			p:SetGravity(vector_up * -150)
			p:SetAirResistance(0)
			p:SetCollide(true)
			p:SetRoll( 0 )
			p:SetRollDelta( 0 )
		Emitter:Finish()
	end
end

function EFFECT:Think( )

	// Die instantly
	--return false
	
end

function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



