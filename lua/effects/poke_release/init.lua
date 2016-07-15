function EFFECT:Init( data )

	self.Ent		= data:GetEntity()
	self.TracerTime = 1
	
	// Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
	self.length = 0
end

function EFFECT:Think( )
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render( )
	if not self.Ent:IsValid() then return end
	self.StartPos = self.Ent:GetPos()
	self.length = self.length + 1
	
	render.SetMaterial( Material( "sprites/glow04_noz" ) )
	render.DrawSprite( self.StartPos, self.length * .5, self.length * .5, Color(255,0,0,127) )
	
	render.SetMaterial( Material( "cable/redlaser" ) )
	for i = 1, 5 do
		render.DrawBeam( self.StartPos, self.StartPos + VectorRand() * self.length * .5, 5, 1, 0, Color(255,255,255,255) )
	end
					 
end
