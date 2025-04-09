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