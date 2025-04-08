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
