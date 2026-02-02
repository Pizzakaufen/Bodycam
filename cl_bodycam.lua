local bodycamEquipped = false
local bodycamHUDVisible = false
local isRecording = false
local currentDeviceID = nil
local axonUIVisible = false

-- Generate random device ID
local function GenerateDeviceID()
    local id = Config.DeviceID.Prefix
    local charset = Config.DeviceID.Charset
    local length = Config.DeviceID.Length
    
    math.randomseed(GetGameTimer())
    
    for i = 1, length do
        local randomChar = math.random(1, #charset)
        id = id .. string.sub(charset, randomChar, randomChar)
    end
    
    return id
end

-- Format timestamp for Axon UI
local function FormatTimestamp()
    if Config.UseIngameTime then
        local hours = GetClockHours()
        local minutes = GetClockMinutes()
        local day = GetClockDayOfMonth()
        local month = GetClockMonth()
        local year = GetClockYear()
        return string.format("%04d-%02d-%02d T%02d:%02d", year, month, day, hours, minutes)
    else
        -- Return placeholder - JavaScript will format with real date/time
        return "REALTIME"
    end
end

-- Format serial number
local function FormatSerial(deviceID)
    local axontype = Config.AxonType == "axonfleet" and "AXON FLEET 3" or "AXON BODY 2"
    return axontype .. " X" .. deviceID
end

-- Play the recording beep locally and 3D for nearby players
local function PlayRecordingBeep()
    local pedCoords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("bwc:playRecording3D", pedCoords)
end

-- Equip bodycam command
RegisterCommand(Config.EquipCommand, function()
    if not bodycamEquipped then
        bodycamEquipped = true
        bodycamHUDVisible = true
        ShowBodycamHUD(true)

        -- Generate device ID
        currentDeviceID = GenerateDeviceID()

        -- Axon UI wird NICHT automatisch angezeigt, nur bei Taste U
        axonUIVisible = false

        -- Play startup sound (neue Vorlage) - nur wenn Datei existiert
        -- SendNUIMessage({
        --     transactionType = "playSound",
        --     transactionFile = "axon_in",
        --     transactionVolume = Config.SoundVolume
        -- })

        -- Default to READY state when equipped
        SendNUIMessage({
            action = "ready",
            ready = true
        })

        SendNUIMessage({ type = "startup", volume = Config.SoundVolume })

        Notify("~g~Bodycam equipped.")
    else
        Notify("~y~You already have a bodycam equipped.")
    end
end)

-- Toggle recording command (Taste U) - zeigt auch Axon UI an
RegisterCommand(Config.EventButtonCommand, function(source, args, rawCommand)
    if not bodycamEquipped then
        Notify("~r~You must equip your bodycam first. Use /equip_bwc.")
        return
    end

    -- Zeige Axon UI an (wenn noch nicht sichtbar)
    if not axonUIVisible then
        if currentDeviceID then
            SendNUIMessage({
                transactionType = "showAxon",
                show = true,
                timestamp = FormatTimestamp(),
                serial = FormatSerial(currentDeviceID)
            })
            axonUIVisible = true
        else
            currentDeviceID = GenerateDeviceID()
            SendNUIMessage({
                transactionType = "showAxon",
                show = true,
                timestamp = FormatTimestamp(),
                serial = FormatSerial(currentDeviceID)
            })
            axonUIVisible = true
        end
    end

    local playerPed = PlayerPedId()

    while not HasAnimDictLoaded(Config.AnimationDict) do
        RequestAnimDict(Config.AnimationDict)
        Citizen.Wait(0)
    end

    ClearPedTasks(playerPed)
    TaskPlayAnim(playerPed, Config.AnimationDict, Config.AnimationName, Config.AnimationBlendInSpeed, Config.AnimationBlendOutSpeed, Config.AnimationDuration, Config.AnimationFlag, Config.AnimationPlaybackRate, 0, 0, 0)

    Wait(Config.AnimationWaitTime) -- after animation

    if not isRecording then
        -- STARTING -> RECORDING
        SendNUIMessage({ action = "ready", ready = false })
        SendNUIMessage({ action = "starting", starting = true })

        -- play "on" sound
        SendNUIMessage({ type = "on", volume = Config.SoundVolume })

        Wait(Config.StartingDelay)

        SendNUIMessage({ action = "starting", starting = false })
        SendNUIMessage({ action = "recording", recording = true })

        isRecording = true

        -- start looping "recording" sound every X seconds
        Citizen.CreateThread(function()
            while isRecording do
                PlayRecordingBeep() -- Play immediately

                -- Wait configured interval before playing again, unless stopped
                local timer = Config.RecordingBeepInterval
                local elapsed = 0
                while elapsed < timer and isRecording do
                    Wait(1000)
                    elapsed = elapsed + 1000
                end
            end
        end)

    else
        SendNUIMessage({ type = "off", volume = Config.SoundVolume })

        Wait(Config.OffSoundDelay)

        -- SAVING -> READY
        SendNUIMessage({ action = "recording", recording = false })
        SendNUIMessage({ action = "saving", saving = true })

        Wait(Config.SavingDelay)

        SendNUIMessage({ action = "saving", saving = false })
        SendNUIMessage({ action = "ready", ready = true })

        isRecording = false
        
        -- Verstecke Axon UI wenn Recording beendet wird
        SendNUIMessage({
            transactionType = "showAxon",
            show = false
        })
        axonUIVisible = false
    end
end)

-- Remove bodycam command
RegisterCommand(Config.DockCommand, function()
    if bodycamEquipped then
        -- If currently recording, stop and save first
        if isRecording then
            -- Stop recording
            SendNUIMessage({ action = "recording", recording = false })
            isRecording = false
        end

        -- Hide HUD and reset states
        bodycamEquipped = false
        bodycamHUDVisible = false
        ShowBodycamHUD(false)
        SendNUIMessage({ action = "ready", ready = false })
        SendNUIMessage({ action = "starting", starting = false })
        
        -- Hide Axon UI
        SendNUIMessage({
            transactionType = "showAxon",
            show = false
        })
        
        axonUIVisible = false
        currentDeviceID = nil

        Notify("~r~Bodycam removed.")
    else
        Notify("~y~You do not have a bodycam equipped.")
    end
end)

-- Register keybind
RegisterKeyMapping(Config.EventButtonCommand, "BWC Event Button", "keyboard", Config.DefaultKeybind)


-- Show/hide HUD
function ShowBodycamHUD(state)
    if state then
        SendNUIMessage({ action = "showHUD", state = true })
    else
        SendNUIMessage({ action = "showHUD", state = false })
    end
end

-- Notification helper
function Notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

-- Update timestamp in Axon UI
Citizen.CreateThread(function()
    while true do
        if bodycamEquipped and axonUIVisible and currentDeviceID then
            -- Update die Zeit, wenn UI sichtbar ist
            SendNUIMessage({
                transactionType = "updateTime",
                timestamp = FormatTimestamp()
            })
        end
        Citizen.Wait(1000)
    end
end)
