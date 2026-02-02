Config = {}

-- Commands
Config.EquipCommand = "equip_bwc"
Config.EventButtonCommand = "bwc_event_button"
Config.DockCommand = "dock_bwc"

-- Keybind
Config.DefaultKeybind = "U" -- Standard-Taste für den Event-Button

-- Sound Settings
Config.SoundVolume = 1.0 -- Volume für alle Sounds (0.0 - 1.0)
Config.RecordingBeepDistance = 5.0 -- Distanz für 3D Recording-Beep Sound

-- Timing Settings (in Millisekunden)
Config.AnimationWaitTime = 2000 -- Wartezeit nach der Animation
Config.StartingDelay = 600 -- Delay zwischen "starting" und "recording" State
Config.OffSoundDelay = 1000 -- Delay nach "off" Sound
Config.SavingDelay = 1800 -- Delay für "saving" State
Config.RecordingBeepInterval = 120000 -- Intervall für Recording-Beep (120 Sekunden)

-- Animation Settings
Config.AnimationDict = "clothingtie"
Config.AnimationName = "outro"
Config.AnimationBlendInSpeed = 8.0
Config.AnimationBlendOutSpeed = 2.0
Config.AnimationDuration = 1880 -- Dauer der Animation selbst
Config.AnimationFlag = 51
Config.AnimationPlaybackRate = 2.0

-- Axon UI Settings
Config.AxonType = "axon3" -- "axon3", "axon4", "axonfleet"
Config.AxonLabel = "" -- Leer lassen für Standard-Label, oder eigenen Label setzen
Config.UseIngameTime = false -- true = Ingame-Zeit verwenden, false = Echtzeit verwenden
Config.DeviceID = {
    Prefix = "D01A", -- Präfix für Geräte-ID
    Charset = "0123456789ABCDEF", -- Zeichen für Geräte-ID
    Length = 4 -- Länge der zufälligen Zeichen nach dem Präfix
}
