require "stategraphs/SGadultflytrap"

local assets=
{
    Asset("ANIM", "anim/venus_flytrap_lg_build.zip"),
    Asset("ANIM", "anim/venus_flytrap_planted.zip"),
    Asset("MINIMAP_IMAGE", "mean_flytrap"),
}

local prefabs =
{
    "plantmeat",
    "venus_stalk",
    "vine",
    "nectar_pod",
    "mean_flytrap",
}

SetSharedLootTable("adult_flytrap",
{
    {"plantmeat",   1.0},
    {"plantmeat",   0.5},
    {"vine",        1.0},
    {"vine",        0.5},
    {"venus_stalk", 1.0},
    {"nectar_pod",  1.0},
    {"nectar_pod",  0.3},
})

local function SanityAura(inst, observer)
    return not observer:HasTag("plantkin") and -TUNING.SANITYAURA_MED or 0
end

local function findfood(inst, target)
    if not target.components.inventory then
        return
    end

    return target.components.inventory:FindItem(function(item)
        if not item:IsValid() or not item.components.edible then
            return false
        end

       return item.components.edible.foodtype == FOODTYPE.MEAT
           or item.components.edible.secondaryfoodtype == FOODTYPE.MEAT
    end)
end

local RETARGET_DIST = 6
local RETARGET_DIST_WORMWOOD = 8
local KEEP_TARGET_DIST = 8
local RETARGET_NO_TAGS = {"FX", "NOCLICK", "INLIMBO", "wall", "flytrap", "structure", "aquatic", "notarget"}
local RETARGET_ONE_OF_TAGS = {"character", "monster", "animal"}

local function RetargetFn(inst)
    return FindEntity(inst, RETARGET_DIST, function(ent)
        if ent:HasTag("plantkin") and (ent:GetDistanceSqToInst(inst) > RETARGET_DIST_WORMWOOD * RETARGET_DIST_WORMWOOD or not findfood(inst, ent)) then
            return false
        end

        return inst.components.combat:CanTarget(ent)
    end, nil, RETARGET_NO_TAGS, RETARGET_ONE_OF_TAGS)
end

local function KeepTargetFn(inst, target)
    if not inst.keeptargetevenifnofood and target:HasTag("plantkin") and not findfood(inst, target) then
        return false
    end

    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < KEEP_TARGET_DIST * KEEP_TARGET_DIST
    else
        return false
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.keeptargetevenifnofood = true
end

local function OnNewTarget(inst, data)
    inst.keeptargetevenifnofood = nil
end

local function OnTimerDone(inst, data)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local radius = 15
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, radius, 20, true, false) -- try avoiding walls

    if offset then
        local ents = TheSim:FindEntities(pt.x, 0, pt.z, radius, {"flytrap"})
        if #ents < 5 then
            local plant = SpawnPrefab("mean_flytrap")
            plant.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
            plant.sg:GoToState("enter")
            inst.sg:GoToState("taunt")
        end
    end

    inst.components.timer:StartTimer("spawn_new_plant", math.random()*(TUNING.TOTAL_DAY_TIME*2) + (TUNING.TOTAL_DAY_TIME*2))
end

local function OnSave(inst, data)
    if inst:HasTag("spawned")then
        data.spawned = true
    end
end

local function OnLoad(inst, data)
    if not data then
        return
    end

    if data.spawned then
        inst:AddTag("spawned")
    end
end

local function OnSpawn(inst)
    if not inst:HasTag("spawned") then
        inst.start_scale = 1.4
        inst.inc_scale = (1.8 - 1.4) /5
        inst.sg:GoToState("grow")
        inst:AddTag("spawned")
    else
        inst.sg:GoToState("idle")
        inst.Transform:SetScale(1.8, 1.8, 1.8)
        inst.Transform:SetRotation(math.random(360))
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("venus_flytrap_planted")
    inst.AnimState:SetBuild("venus_flytrap_lg_build")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("root")
    inst.AnimState:Hide("leaf")

    inst.MiniMapEntity:SetIcon("mean_flytrap.tex")

    inst.Transform:SetFourFaced()

    MakeObstaclePhysics(inst, .25)

    inst:AddTag("animal")
    inst:AddTag("character")
    inst:AddTag("flytrap")
    inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ADULT_FLYTRAP_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.ADULT_FLYTRAP_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.ADULT_FLYTRAP_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ADULT_FLYTRAP_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(0.45, 0.15), RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("adult_flytrap")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = SanityAura

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("spawn_new_plant", GetRandomWithVariance(TUNING.TOTAL_DAY_TIME * 3, TUNING.TOTAL_DAY_TIME))

    inst:SetStateGraph("SGadultflytrap")

    MakeLargeFreezableCharacter(inst)
    MakeMediumBurnableCharacter(inst, "stem")

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.onSpawn = OnSpawn
    inst:DoTaskInTime(0, OnSpawn)

    return inst
end

return Prefab("adult_flytrap", fn, assets, prefabs)
