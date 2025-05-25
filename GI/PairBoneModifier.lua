-- ===============================================================
-- CONFIGURATION VARIABLES
-- ===============================================================

-- Target Bone Names
local BONE_NAME_L = "+Breast L A01"    -- Left
local BONE_NAME_R = "+Breast R A01"    -- Right

-- ---------------------------------------------------------------
-- MODE SELECTION: Choose only ONE option as 'true'
-- ---------------------------------------------------------------
-- Priority order is: Left -> Right -> Pair.
-- If MODIFY_LEFT_ONLY is true, it will only modify the left side, ignoring the others.

local MODIFY_PAIR = true       -- Modifies BOTH bones (L and R) with the same settings below.
local MODIFY_LEFT_ONLY = false -- Modifies ONLY the left bone (BONE_NAME_L).
local MODIFY_RIGHT_ONLY = false-- Modifies ONLY the right bone (BONE_NAME_R).

-- ---------------------------------------------------------------
-- TRANSFORMATION SETTINGS
-- (Will be applied to the bones selected by the mode above)
-- ---------------------------------------------------------------

-- Suffix for the container name. The final name will be "BoneName" .. SUFFIX.
-- Example: "+Breast L A01_ModContainer"
local CONTAINER_SUFFIX = "_ModContainer"

local APPLY_SCALE = false
local NEW_SCALE = { x = 1.1, y = 1.1, z = 1.1 }

local APPLY_ROTATION = false
local OFFSET_ROT = { x = 0, y = 0, z = 0 }

local APPLY_POSITION = true
local OFFSET_POS = {x = 0, y = -0.001, z = 0}

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

local function modify_single_bone(all_bones, bone_name)
    local target_bone = nil
    for i = 0, all_bones.Length - 1 do
        if all_bones[i].name == bone_name then
            target_bone = all_bones[i]
            break
        end
    end

    if not target_bone then
        CS.MoleMole.ActorUtils.ShowMessage("ERROR: Bone '" .. bone_name .. "' not found.")
        return
    end

    local container_name = bone_name .. CONTAINER_SUFFIX
    local bone_parent = target_bone.transform.parent
    local container_transform = bone_parent:Find(container_name)

    if not container_transform then
        CS.MoleMole.ActorUtils.ShowMessage("Creating container for '" .. bone_name .. "'...")
        local container_go = CS.UnityEngine.GameObject(container_name)
        container_transform = container_go.transform
        container_transform.parent = bone_parent

        container_transform.localPosition = CS.UnityEngine.Vector3.zero
        container_transform.localRotation = CS.UnityEngine.Quaternion.identity
        container_transform.localScale = CS.UnityEngine.Vector3.one

        target_bone.transform.parent = container_transform
    else
        CS.MoleMole.ActorUtils.ShowMessage("Container for '" .. bone_name .. "' already exists. Reusing.")
    end

    if APPLY_SCALE then
        container_transform.localScale = CS.UnityEngine.Vector3(NEW_SCALE.x, NEW_SCALE.y, NEW_SCALE.z)
    end
    if APPLY_ROTATION then
        container_transform.localEulerAngles = CS.UnityEngine.Vector3(OFFSET_ROT.x, OFFSET_ROT.y, OFFSET_ROT.z)
    end
    if APPLY_POSITION then
        container_transform.localPosition = CS.UnityEngine.Vector3(OFFSET_POS.x, OFFSET_POS.y, OFFSET_POS.z)
    end
end

local function apply_bone_mods()
    local avatar = find_active_char()
    if not avatar then CS.MoleMole.ActorUtils.ShowMessage("Active character not found."); return end

    local body = find_body(avatar)
    if not body then CS.MoleMole.ActorUtils.ShowMessage("Body not found."); return end

    local renderer = body:GetComponent("SkinnedMeshRenderer")
    if not (renderer and renderer.bones) then
        CS.MoleMole.ActorUtils.ShowMessage("ERROR: Mesh Renderer not found!")
        return
    end

    local all_bones = renderer.bones

    if MODIFY_LEFT_ONLY then
        CS.MoleMole.ActorUtils.ShowMessage("Mode: Left Only")
        modify_single_bone(all_bones, BONE_NAME_L)
    elseif MODIFY_RIGHT_ONLY then
        CS.MoleMole.ActorUtils.ShowMessage("Mode: Right Only")
        modify_single_bone(all_bones, BONE_NAME_R)
    elseif MODIFY_PAIR then
        CS.MoleMole.ActorUtils.ShowMessage("Mode: Pair")
        modify_single_bone(all_bones, BONE_NAME_L)
        modify_single_bone(all_bones, BONE_NAME_R)
    else
        CS.MoleMole.ActorUtils.ShowMessage("No modification mode selected.")
        return
    end

    CS.MoleMole.ActorUtils.ShowMessage("Bone modification completed!")
end

local function onError(error)
    CS.MoleMole.ActorUtils.ShowMessage("UNEXPECTED ERROR:\n" .. tostring(error))
end

xpcall(apply_bone_mods, onError)
