local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local function Init(inst)
    if inst.components.inventoryitem then
        return
    end

    -- Disable for now for performance reason and also player might get squeezed out of world bound
    inst:AddComponent("keeponpassable")
end

AddComponentPostInit("health", function(self)
    self.inst:DoStaticTaskInTime(0, Init)
end)
