-- ===============================================================
-- VARIABLES
-- ===============================================================

local BONE_NAME_L = "+Breast L A01"    -- Left
local BONE_NAME_R = "+Breast R A01"    -- Right

local CONTAINER_NAME = "Breast_Scaler" -- Container Name, Change if u applying new modifications on same char

-- Basic Math
-- 2.0 Double - Twice Actual Size
-- 1.5 Half - 50% Bigger
-- 1.0 Default - No Changes
-- 0.5 Half - 50% Smaller

local NEW_SCALE_X = 1.2
local NEW_SCALE_Y = 1.2
local NEW_SCALE_Z = 1.2

-- ===============================================================
-- SCRIPT
-- ===============================================================

local function find_active_char()
    local avatar_root = CS.UnityEngine.GameObject.Find("/EntityRoot/AvatarRoot")
    if not avatar_root then return nil end
    for i = 0, avatar_root.transform.childCount - 1 do
        local child = avatar_root.transform:GetChild(i)
        if child.gameObject.activeInHierarchy then
            return child.gameObject
        end
    end
    return nil
end

local function find_body(avatar)
    if not avatar then return nil end
    for i = 0, avatar.transform.childCount - 1 do
        local transform = avatar.transform:GetChild(i)
        if transform.name == "OffsetDummy" then
            for j = 0, transform.childCount - 1 do
                local child = transform:GetChild(j)
                for k = 0, child.transform.childCount - 1 do
                    local body = child.transform:GetChild(k)
                    if body.name == "Body" then
                        return body.gameObject
                    end
                end
            end
        end
    end
    return avatar
end

local function modify_paired_bones()
    local avatar = find_active_char()
    if not avatar then
        CS.MoleMole.ActorUtils.ShowMessage("Active Char not Found"); return
    end

    local body = find_body(avatar)
    if not body then
        CS.MoleMole.ActorUtils.ShowMessage("Body not Found")
    end

    local renderer = body:GetComponent("SkinnedMeshRenderer")

    if not (renderer and renderer.bones) then
        CS.MoleMole.ActorUtils.ShowMessage("ERROR: Mesh Renderer not Found!!!"); return
    end

    local bones = renderer.bones
    local container_transform = nil

    local existing_container = avatar.transform:Find(CONTAINER_NAME, true)

    if existing_container then
        container_transform = existing_container
        CS.MoleMole.ActorUtils.ShowMessage("Container '" .. CONTAINER_NAME .. "' Already in Use")
    else
        CS.MoleMole.ActorUtils.ShowMessage("Creating container '" .. CONTAINER_NAME .. "'...")
        local bone_l, bone_r = nil, nil

        for i = 0, bones.Length - 1 do
            if bones[i].name == BONE_NAME_L then bone_l = bones[i] end
            if bones[i].name == BONE_NAME_R then bone_r = bones[i] end
            if bone_l and bone_r then break end
        end

        if not (bone_l and bone_r) then
            CS.MoleMole.ActorUtils.ShowMessage("ERRO: Bone '" .. BONE_NAME_L .. "' or '" .. BONE_NAME_R .. "' not Found.")
            return
        end

        local shared_parent = bone_l.transform.parent
        if shared_parent ~= bone_r.transform.parent then
            CS.MoleMole.ActorUtils.ShowMessage(
                "WARNING: Bones L and R dont share same parent, Using bone L parent.")
        end

        local container_go = CS.UnityEngine.GameObject(CONTAINER_NAME)

        container_transform = container_go.transform

        container_transform.parent = shared_parent

        container_transform.localPosition = CS.UnityEngine.Vector3.zero
        container_transform.localRotation = CS.UnityEngine.Quaternion.identity
        container_transform.localScale = CS.UnityEngine.Vector3.one

        bone_l.transform.parent = container_transform
        bone_r.transform.parent = container_transform
    end

    if container_transform then
        container_transform.localScale = CS.UnityEngine.Vector3(NEW_SCALE_X, NEW_SCALE_Y, NEW_SCALE_Z)
        CS.MoleMole.ActorUtils.ShowMessage("Scaling sucessfuly on '" .. CONTAINER_NAME .. "'.")
    end
end

local function onError(error)
    CS.MoleMole.ActorUtils.ShowMessage("ERRO: Unexpected Error\n" .. tostring(error))
end

xpcall(modify_paired_bones, onError)