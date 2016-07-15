
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "gmon_ball" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(ply)

	return ent
	
end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Entity:SetModel( "models/weapons/w_models/w_pokeball.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	 
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake() 
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
		phys:SetMaterial("defaultsilent")
	end
	
	self:SetTrigger(false)
	
	local sound = Sound("pokeball/pokeball_twitching.mp3")
	self.WobbleLoop = CreateSound(self, sound)
		  
	self.ShadowParams = {}
end
function ENT:PhysicsSimulate( phys, deltatime )
 
	phys:Wake()
 
	self.ShadowParams.secondstoarrive = .5
	self.ShadowParams.pos = self.TargetPos
	self.ShadowParams.angle = self.TargetAng
	self.ShadowParams.maxangulardamp = 800
	self.ShadowParams.maxangular = 10000
	self.ShadowParams.maxspeed = 10000
	self.ShadowParams.maxspeeddamp = 100
	self.ShadowParams.dampfactor = 1
	self.ShadowParams.teleportdistance = 0
	self.ShadowParams.deltatime = deltatime 
 
	phys:ComputeShadowControl(self.ShadowParams)
 
end
function ENT:OnTakeDamage( dmginfo )

end

function ENT:OnRemove()
	self.WobbleLoop:Stop()
end

ENT.WobbleLoop = nil
ENT.NextWobble = 0
ENT.Enabled = true
function ENT:PhysicsUpdate(phys)
	if self.ToReturn then
		local rHandI = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
		local rhpos, rhang = self:GetOwner():GetBonePosition(rHandI)
		self.TargetPos = rhpos
		if self:GetPos():Distance(self.TargetPos) < 50 then 
			local weap = self:GetOwner():GetWeapon("garrymon_ball")
			if weap and weap:IsValid() then
				weap:ResetView()
			end
			self:Remove() 
		end
	end
end

ENT.ToReturn = false
ENT.WobbleFinish = false
ENT.HitEntityPos = nil
function ENT:PhysicsCollide( data, phys )
	if data.HitEntity:IsNPC() then
		if table.HasValue(GMON_CLASS_EXCEPTIONS, data.HitEntity:GetClass()) then 
			if not self.Triggered then
				self.ToReturn = true
				self.TargetAng = (self:GetPos() - self.Owner:GetShootPos()):GetNormal():Angle()
				self:StartMotionController()
			end
			return 
		end
		self.HitEntityPos = data.HitPos
		self:SetTrigger(true)
		timer.Simple(0, function() pcall(self.CaptureEnt, self, data.HitEntity) end)
	else
		if not self.Triggered then
			self.ToReturn = true
			self:StartMotionController()
			self:SetNotSolid(true)
		elseif not self.Planted then
			self.WobbleLoop:Play()
			self.NextWobble = CurTime() + 1
			phys:EnableMotion(false)
			timer.Simple(self.Shakes, function() pcall(self.Break, self) end)
			self.TargetPos = data.HitPos + Vector(0,0,1)
			self:StopMotionController()
			self:SetDTBool(0, true)
			self:SetDTFloat(0, CurTime())
			self.Planted = true
		end
	end
end

hook.Add("PhysgunPickup", "DisablePokeballPhysgun", function(ply, ent)
	if ent:IsValid() then
		if ent:GetClass() == "gmon_ball" then
			if not ent.CanPickup then
				return false
			end
		end
	end
end)
hook.Add("GravGunPickupAllowed", "DisablePokeballGravgun", function(ply, ent)
	if ent:IsValid() then
		if ent:GetClass() == "gmon_ball" then
			if not ent.CanPickup then
				return false
			end
		end
	end
end)

function ENT:Break()
	local phys = self:GetPhysicsObject()
	phys:SetVelocity(phys:GetVelocity() * -1)
	self.WobbleFinish = true
	self.CanPickup = true
	self:SetDTBool(0, false)
	if not self.Captured then
		self.WobbleLoop:Stop()
		local effect = EffectData()
			effect:SetEntity(self)
		util.Effect("poke_release", effect)
		local npc = ents.Create(self.NPCClass)
		npc:SetPos(self:GetPos() + Vector(0,0,10))
		npc:Spawn()
		npc:SetHealth(self.NPCHealth)
		npc:Activate()
		self:EmitSound("pokeball/pokeball_release.mp3")
		self.ToReturn = true
		phys:EnableMotion(true)
		phys:ApplyForceCenter(VectorRand() * 5)
	else
		local curAng = self:GetAngles()
		curAng.p = 0
		curAng.r = 0
		self:SetAngles(curAng)
		phys:EnableMotion(false)
		self:SetColor(Color(100,100,100,255))
		local effect = EffectData()
			effect:SetOrigin(self:GetPos() + Vector(0,0,5))
		util.Effect("poke_star", effect)
		self:EmitSound("pokeball/pokeball_capture" .. math.random(1,2) .. ".mp3")
	end
end

function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "Planted")
	self:DTVar("Int", 0, "Shakes")
	self:DTVar("Float", 0, "PlantedTime")
end

function ENT:DetermineCapture(ent)
	if not ent or not ent:IsValid() then return end	
	local shakes, maxhp, curhp, size, maxsize, pctrate, rate, a, b
	shakes = 1
	maxhp = ent:GetMaxHealth()
	curhp = ent:Health()
	size = ent:GetMaxHealth() + ent:OBBMaxs().z
	maxsize = 1500
	pctrate = (maxsize - math.Clamp(size, 0, maxsize)) / maxsize
	if pctrate == 0 then pctrate = .0005 end --To make it not impossible to catch really big shit
	rate = 255 * pctrate
	if ent:IsOnFire() then bonus = 1.5 else bonus = 1 end
	a = (((3 * maxhp - 2 * curhp) * rate) / (3 * maxhp)) * bonus
	if a > 255 then return 5 end --Instant catch
	b = 1048560 / math.sqrt(math.sqrt(16711680/a))
	for i = 1, 4 do
		local rand = math.random(0, 65535)
		if rand < b then
			shakes = shakes + 1
		elseif rand >= b then
			break
		end
	end
	return shakes
end


ENT.TargetPos = Vector()
ENT.TargetAng = Angle()
ENT.Triggered = false
ENT.CanPickup = true
ENT.Captured = false
ENT.NPCClass = nil
ENT.NPCHealth = 0
ENT.GTable = {}
function ENT:CaptureEnt(ent)
	local phys = self:GetPhysicsObject()
	if ent:IsNPC() and not self.Triggered and not self.ToReturn then
		local hitPos = self.HitEntityPos
		local dir = (self:GetOwner():GetPos() - hitPos):GetNormal():Angle()
		self.TargetPos = hitPos + dir:Forward() * 20 + dir:Right() * -20 + Vector(0,0,25)
		
		local mobCenter = ent:LocalToWorld(ent:OBBCenter())
		local tAng = (self.TargetPos - hitPos):GetNormal():Angle()
		tAng:RotateAroundAxis(tAng:Up(), 90)
		self.TargetAng = tAng
		self:SetAngles(tAng)
		
		self:StartMotionController()
		phys:EnableGravity(false)
		self.Triggered = true
		self.NPCClass = ent:GetClass()
		self.NPCHealth = ent:Health()
		
		local capped = self:DetermineCapture(ent)
		self.Shakes = capped
		self:SetDTInt(0, capped)
		if capped == 5 then
			self.Captured = true
		end
		
		local gmonTab = {}
		gmonTab.Name = ent:GetClass()
		gmonTab.Class = ent:GetClass()
		gmonTab.HP = ent:Health()
		gmonTab.MaxHP = ent:GetMaxHealth()
		gmonTab.Skin = ent:GetSkin()
		gmonTab.Mod = ent:GetModel()
		gmonTab.Mat = ent:GetMaterial()
		self.GTable = gmonTab
		
		self.CanPickup = false
		
		self:EmitSound("pokeball/pokeball_catch" .. math.random(1,2) .. ".mp3")
		
		local faken = ents.Create("prop_dynamic")
		faken:SetModel(ent:GetModel())
		faken:SetMaterial("sprites/glow04_noz")
		faken:SetAngles(ent:GetAngles())
		faken:SetPos(ent:GetPos())
		faken:SetSequence(ent:GetSequence())
		faken:SetCycle(ent:GetCycle())
		faken:SetSkin(ent:GetSkin())
		faken:Spawn()
		
		faken:SetKeyValue("targetname", "pokesolve")

		//ent:Fire("kill", "", .75)
		ent:Remove()
		
		local dis = ents.Create("env_entity_dissolver")
		dis:SetPos(faken:GetPos())
		dis:SetKeyValue("magnitude", "1")
		dis:SetKeyValue("dissolvetype", "3")
		dis:SetKeyValue("target", "pokesolve")
		dis:Spawn()
		dis:Fire("Dissolve", "pokesolve", 0)
		dis:Fire("kill", "", 0)
		
		local effect = EffectData()
			effect:SetEntity(self)
			effect:SetOrigin(self.HitEntityPos)
		util.Effect("poke_beam", effect)

		timer.Simple(1, function() pcall(phys.EnableGravity, phys, true) pcall(phys.SetVelocity, phys, Vector(0,0,150)) end)
		timer.Simple(1, function() pcall(self.StopMotionController, self) end)
	end
end

function ENT:Touch(ent)
	local myOwn = self:GetOwner()
	if ent == myOwn and self.Planted then
		if not self.WobbleFinish then return end
		local weap = self:GetOwner():GetWeapon("garrymon_ball")
		if weap and weap:IsValid() then
			weap:ResetView()
		end
		self:Remove() 
	end
end


function ENT:Use( activator, caller )

end

function ENT:Think()
end


