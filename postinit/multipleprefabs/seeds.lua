local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function OnDeploy(inst, pt, deployer) --, rot)
    local plant = SpawnPrefab("plant_normal_ground")
    plant.components.crop:StartGrowing(inst.components.plantable.product, inst.components.plantable.growtime)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()
end

local function veggie_seeds_postinit(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:RemoveComponent("farmplantable")

    inst.components.deployable.ondeploy = OnDeploy
end

local ds_veggies = {
    "asparagus",
    "carrot",
    "corn",
    "dragonfruit",
    "durian",
    "eggplant",
    "pomegranate",
    "pumpkin",
    "watermelon",
}

for _, veggie in pairs(ds_veggies) do
    AddPrefabPostInit(veggie .. "_seeds", veggie_seeds_postinit)
end

local random_veggies = table.invert({
    "aloe",
    "asparagus",
    "carrot",
    "corn",
    "dragonfruit",
    "durian",
    "eggplant",
    "pomegranate",
    "pumpkin",
    "radish",
    "watermelon",
})

local function PickProduct()
    local total_weight = 0
    for veggie_name, veggie_data in pairs(VEGGIES) do
        if random_veggies[veggie_name] then
            total_weight = total_weight + (veggie_data.seed_weight or 1)
        end
    end

    local random = math.random() * total_weight
    for veggie_name, veggie_data in pairs(VEGGIES) do
        random = random - (veggie_data.seed_weight or 1)
        if random <= 0 then
            return veggie_name
        end
    end

    return "carrot"
end

local function OnDeployRandomSeed(inst, pt, deployer)
    local prefab
    if inst.components.plantable.product and type(inst.components.plantable.product) == "function" then
        prefab = inst.components.plantable.product(inst)
    else
        prefab = inst.components.plantable.product or inst.prefab
    end

    local plant = SpawnPrefab("plant_normal_ground")
    plant.components.crop:StartGrowing(prefab, inst.components.plantable.growtime, plant)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant.SoundEmitter:PlaySound("dontstarve/common/craftable/farm_basic")
    inst:Remove()
end

local function random_seeds_postinit(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:RemoveComponent("farmplantable")

    inst.components.deployable.ondeploy = OnDeployRandomSeed

    inst.components.plantable.product = PickProduct
end

AddPrefabPostInit("seeds", random_seeds_postinit)
