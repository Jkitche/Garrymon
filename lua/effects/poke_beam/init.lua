function EFFECT:Init( data )

	self.EndPos 	= data:GetOrigin()
	self.Ent		= data:GetEntity()
	self.StartPos 	= data:GetOrigin()
	self.TracerTime = 1
	
	// Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
	
end

function EFFECT:Think( )
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render( )
	self.StartPos = self.Ent:LocalToWorld(self.Ent:OBBCenter())
	render.SetMaterial( Material( "sprites/glow04_noz" ) )
	render.DrawSprite( self.StartPos, 48, 48, Color(255,0,0,127) )
	render.DrawSprite( self.EndPos, 48, 48, Color(255,0,0,127) )
	
	render.SetMaterial( Material( "cable/redlaser" ) )
	render.DrawBeam( self.StartPos, self.EndPos, 15, 1, 0, Color(255,255,255,255) )
	
	local dlight = DynamicLight( 1 )
	if ( dlight ) then
		dlight.Pos = self.StartPos
		dlight.r = 255
		dlight.g = 0
		dlight.b = 0
		dlight.Brightness = 1
		dlight.Size = 48
		dlight.Decay = 25
		dlight.DieTime = self.DieTime
	end
	local dlight = DynamicLight( 2 )
	if ( dlight ) then
		dlight.Pos = self.EndPos
		dlight.r = 255
		dlight.g = 0
		dlight.b = 0
		dlight.Brightness = 1
		dlight.Size = 48
		dlight.Decay = 25
		dlight.DieTime = self.DieTime
	end
end
