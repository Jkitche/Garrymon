if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		= "GBall"
SWEP.Author 		= "Feihc"
SWEP.Category		= ".Garrymon"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.Instructions   = ""
SWEP.IconLetter 	= "x"
SWEP.WorldModel   	= "models/weapons/w_models/w_pokeball.mdl"
SWEP.HoldType		= "melee"

if CLIENT then
	SWEP.WepSelectIcon	= surface.GetTextureID("pokemon/pokeball_weapon_icon")
	SWEP.BounceWeaponIcon = true
end

SWEP.Slot 			= 4
SWEP.SlotPos 		= 1
SWEP.ViewModelFOV 	= 60
SWEP.ViewModelFlip 	= false

SWEP.Spawnable      = true
SWEP.AdminSpawnable = true

SWEP.Primary.Delay			= 0.9
SWEP.Primary.Recoil			= 0		
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"

SWEP.ViewModel = Model( "models/weapons/v_grenade.mdl" )

SWEP.IronSightsPos = Vector(-15.197, -12.205, -20)
SWEP.IronSightsAng = Vector(57.047, -0.276, -33.898)

SWEP.Offset = {
    Pos = {
        Right = 0,
        Forward = 0,
        Up = 0,
    },
    Ang = {
        Right = 0,
        Forward = 90,
        Up = 0,
    },
    Scale = .75,
}

SWEP.BonesToHide = { "ValveBiped.Grenade_body","ValveBiped.Pin" }
function SWEP:HideNade( vm )
	local bone, matrix, k, v, oPos, oAng
	vm:SetupBones( )
	
	oPos, oAng = vm:GetBonePosition(vm:LookupBone("ValveBiped.Grenade_body"))
	
	for k, v in ipairs( self.BonesToHide ) do
		bone = vm:LookupBone( v )
	
		if bone and bone > 0 then
			matrix = vm:GetBoneMatrix( bone )
		
			if matrix then
				matrix:Scale(Vector() * .003)
				vm:SetBoneMatrix( bone, matrix )
			end
		end
	end
	
	if self.Pokeball and self.Pokeball:IsValid() then
		oAng:RotateAroundAxis(oAng:Forward(), -135)
		self.Pokeball:SetPos(oPos + oAng:Up() * .45)
		oAng:RotateAroundAxis(oAng:Forward(), -90)
		oAng:RotateAroundAxis(oAng:Right(), -90)
		self.Pokeball:SetAngles(oAng)
	end
end

function SWEP:ViewModelDrawn()
	if self.Pokeball and self.Pokeball:IsValid() then
		self.Pokeball:DrawModel()
	end
end

function SWEP:GetViewModelPosition( pos, ang )
	if self.dt.Returning then
	
	else
		pos = pos - ang:Right() * -5
	end
	return pos, ang
end

function SWEP:PostDrawTranslucentRenderables( )
	self:HideNade( self.Owner:GetViewModel( ) )
end

local function PostDrawTranslucentRenderables( )
	local pl = LocalPlayer( )
	if not pl:IsValid( ) then return end
	local wep = pl:GetActiveWeapon( )
	if not wep:IsValid( ) then return end
	if not wep.PostDrawTranslucentRenderables then return end
	
	wep:PostDrawTranslucentRenderables( )
end
hook.Add( "PostDrawTranslucentRenderables", "SetupPokeballHand", PostDrawTranslucentRenderables )

SWEP.Pokeball = nil
function SWEP:Initialize()
	self:SetWeaponHoldType("grenade")
	if CLIENT then
		self.Pokeball = ClientsideModel("models/weapons/w_models/w_pokeball.mdl")
		self.Pokeball:SetModelScale(.70,0)
		self.Pokeball:AddEffects(EF_NODRAW)
	end
end

function SWEP:DrawWorldModel( )
    if not self.Owner:IsValid() then
        return self:DrawModel( )
    end
    
    local offset, hand
    
    self.Hand2 = self.Hand2 or self.Owner:LookupAttachment( "anim_attachment_rh" )
    
    hand = self.Owner:GetAttachment( self.Hand2 )
    
    if not hand then
        return
    end
    
    offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * (self.Offset.Pos.Forward) + hand.Ang:Up( ) * self.Offset.Pos.Up
    
    hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
    hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
    hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )
    
    self:SetRenderOrigin( hand.Pos + offset )
    self:SetRenderAngles( hand.Ang )
	if not self.dt.HasBall then
		self:SetModelScale( 0, 0 )
	else 
		self:SetModelScale( self.Offset.Scale, 0 )
	end
	self:DrawModel()
end

local health = 0
if CLIENT then
local pokeTexture = surface.GetTextureID("pokemon/pokeball")
function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local tr = ply:GetEyeTrace()
	ply.LastTargetTime = ply.LastTargetTime or 0
	ply.LastTarget = ply.LastTarget or nil
	if tr.Entity:IsValid() and tr.Entity:IsNPC() then
		ply.LastTargetTime = CurTime() + 3
		ply.LastTarget = tr.Entity
	end
	if ply.LastTargetTime > CurTime() and ply.LastTarget:IsValid() then
		local sw = ScrW()
		local sh = ScrH()
		surface.SetFont("TargetID")
		surface.SetTextColor(Color(255,255,255,255))
		surface.SetTextPos(sw * .105, sh * .08)
		surface.DrawText(ply.LastTarget:GetClass())
		
		draw.RoundedBox(6, sw * .1, sh * .1, sw * .15, sh * .02, Color(100,100,100,200))
		draw.RoundedBox(2, sw * .12, sh * .1025, sw * .128, sh * .015, Color(255,255,255,200))
		draw.RoundedBox(6, sw * .121, sh * .103, sw * .1255, sh * .013, Color(100,100,100,255))
		draw.RoundedBox(2, sw * .121, sh * .103, sw * .1265, sh * .013, Color(100,100,100,255))
		surface.SetTextPos(sw * .105, sh * .1025)
		surface.SetTextColor(Color(200,200,200,255))
		surface.DrawText("HP")
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture(pokeTexture)
		surface.DrawTexturedRect(sw * .078, sh * .095, sw * .02, sw * .02)
		
		draw.NoTexture()
		surface.SetDrawColor( 200, 0, 0, 255 )
		if ply.LastTarget.HPRatio then
			surface.DrawRect(sw * .121, sh * .1035, sw * .1265 * math.Clamp(ply.LastTarget.HPRatio, 0, 1), sh * .0135)
		end
	end
end
end

SWEP.Returning = false
SWEP.IsSetup = false
function SWEP:Think()
	if not self.IsSetup then
		self.dt.HasBall = true
		self.IsSetup = true
	end
end

function SWEP:Holster()
	self.Owner:SetNWBool("GMonHatFlipped", false)
	return true
end

function SWEP:OnRemove()
	self.Owner:SetNWBool("GMonHatFlipped", false)
	return true
end

function SWEP:SetupDataTables()
	self:DTVar( "Bool", 0, "HasBall" )
	self:DTVar( "Bool", 1, "Returning" )
end

SWEP.HasBall = true
function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted( ) then return end
	if self.dt.HasBall and not self.dt.Returning then
		if SERVER then
			local rHandI = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
			local rhpos = self.Owner:GetBonePosition(rHandI)
			local trace = self.Owner:GetEyeTrace()
			local dir = (trace.HitPos - rhpos):GetNormal()
			local ball = ents.Create("gmon_ball")
			ball:SetPos(rhpos)
			ball:SetAngles(self.Owner:EyeAngles())
			ball:Spawn()
			ball:SetOwner(self.Owner)
			local phys = ball:GetPhysicsObject()
			phys:ApplyForceCenter(phys:GetMass() * dir * 2000 + self.Owner:EyeAngles():Up() * 750)
			phys:AddAngleVelocity(VectorRand() * 500)
			self.Owner:EmitSound("weapons/slam/throw.wav")
		end
		self.dt.HasBall = false
		self:SetNextPrimaryFire(CurTime() + 1)
		self:SendWeaponAnim( ACT_VM_THROW )
		timer.Simple(.55, function() self:HoldNormal() end )
		self.Owner:DoAttackEvent()
	end
end

function SWEP:HoldNormal()
	self:SetWeaponHoldType("normal")
	self:CallOnClient("SetWeaponHoldType", "normal")
	timer.Simple(.01, function()
		if self.dt.HasBall then
			self:HoldThrow()
		end
	end)
end

function SWEP:HoldReturn()
	self:SetWeaponHoldType("pistol")
	self:CallOnClient("SetWeaponHoldType", "pistol")
end

function SWEP:HoldThrow()
	self:SetWeaponHoldType("grenade")
	self:CallOnClient("SetWeaponHoldType", "grenade")
end

function SWEP:ResetView()
	self:SendWeaponAnim(ACT_VM_IDLE)
	self.dt.HasBall = true
	self:EmitSound("pokeball/pokeball_pickup.mp3")
	self:HoldThrow()
end

function SWEP:SecondaryAttack()
	if self.dt.HasBall then
		local tr = self.Owner:GetEyeTrace()
		if tr.Entity:IsValid() and tr.Entity:IsNPC() then
			timer.Simple(.1, function()
				local effect = EffectData()
					effect:SetStart(tr.HitPos)
					effect:SetEntity(self.Owner)
				util.Effect("poke_return", effect)
			end)
			
			local faken = ents.Create("prop_dynamic")
			faken:SetModel(tr.Entity:GetModel())
			faken:SetMaterial("sprites/glow04_noz")
			faken:SetPos(tr.Entity:GetPos())
			faken:SetSequence(tr.Entity:GetSequence())
			faken:SetCycle(tr.Entity:GetCycle())
			faken:SetSkin(tr.Entity:GetSkin())
			faken:Spawn()
			
			faken:SetKeyValue("targetname", "pokesolve")

			tr.Entity:Remove()
		
			local dis = ents.Create("env_entity_dissolver")
			dis:SetPos(faken:GetPos())
			dis:SetKeyValue("magnitude", "1")
			dis:SetKeyValue("dissolvetype", "3")
			dis:SetKeyValue("target", "pokesolve")
			dis:Spawn()
			dis:Fire("Dissolve", "pokesolve", 0)
			dis:Fire("kill", "", 0)
			
			self.dt.Returning = true
			self:HoldReturn()
			timer.Simple(1.15, function() self:HoldThrow(); self.dt.Returning = false end )
			self:SetNextSecondaryFire(CurTime() + 1.5)
			self:SendWeaponAnim( ACT_GRENADE_ROLL )
			self:EmitSound("pokeball/pokeball_return.mp3")
		end
	end
end



