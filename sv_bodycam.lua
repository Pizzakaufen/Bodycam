-- 3D recording sound
RegisterNetEvent("bwc:playRecording3D", function(coords)
    if type(coords) == "vector3" then
        TriggerClientEvent("InteractSound_CL:PlayWithinDistance", -1, coords, Config.RecordingBeepDistance, "recording", Config.SoundVolume)
    end
end)