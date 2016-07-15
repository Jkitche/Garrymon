function EFFECT:Init( data )

	self.Ent		= data:GetEntity()
	self.EndPos 	= data:GetStart()
	local rHandI, rHandA = self.Ent:LookupBone("ValveBiped.Bip01_R_Hand")
	self.StartPos 	= self.Ent:GetBonePosition(rHandI)
	
	self.DieTime = CurTime() + 1
end

function EFFECT:Think( )
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render( )
	
	local rHandI, rHandA = self.Ent:LookupBone("ValveBiped.Bip01_R_Hand")
	self.StartPos = self.Ent:GetBonePosition(rHandI)
	local epos = LerpVector( self.DieTime - CurTime(), self.StartPos, self.EndPos)
	
	render.SetMaterial( Material( "sprites/glow04_noz" ) )
	render.DrawSprite( self.StartPos, 48, 48, Color(255,0,0,127) )
	render.DrawSprite( epos, 48, 48, Color(255,0,0,127) )
	
	render.SetMaterial( Material( "cable/redlaser" ) )
	render.DrawBeam( self.StartPos, epos, 15, 1, 0, Color(255,255,255,255) )
	
end