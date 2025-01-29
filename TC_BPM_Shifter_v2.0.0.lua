--
--  ____  _____  __  __        _____ _     _  __ _            
-- |  _ \|  __ \|  \/  |      / ____| |   (_)/ _| |           
-- | |_) | |__) | \  / |_____| (___ | |__  _| |_| |_ ___ _ __ 
-- |  _ <|  ___/| |\/| |______\___ \| '_ \| |  _| __/ _ \ '__|
-- | |_) | |    | |  | |      ____) | | | | | | | ||  __/ |   
-- |____/|_|    |_|  |_|     |_____/|_| |_|_|_|  \__\___|_|   
--                                                           
--[[---------------------------------------------------------------------------
TC BPM Shifter 
Developed by: FD
---------------------------------------------------------------------------]]

local pluginVersion = "2.0.0"
local githubRepoAPI = "https://api.github.com/repos/Compl3xs/TC-BPM-Shifter/releases/latest"
local pluginDir = "C:/ProgramData/MALightingTechnology/gma3_library/datapools/plugins" 

--------------------------------------------------------------------------------
-- Globale Werte & Standard-Einstellungen
--------------------------------------------------------------------------------
local pluginName    = select(1, ...)
local componentName = select(2, ...)
local signalTable   = select(3, ...)
local my_handle     = select(4, ...)

local logdata = "BPM-Shifter Log" 
local logFilePath = GetPath(Enums.PathType.Temp) .. "/" .. logdata .. ".txt"

local colorTransparent = Root().ColorTheme.ColorGroups.Global.Transparent
local errors = 0

local json = require("json")


--------------------------------------------------------------------------------
-- LogFile Function 
--------------------------------------------------------------------------------
local function clearLogFile()
    local file = io.open(logFilePath, "w") 
    if file then
        file:write(os.date("==== Log gestartet am %Y-%m-%d %H:%M:%S ====\n"))
        file:close()
    else
        Printf("[ERROR] Konnte Log-Datei nicht leeren: " .. logFilePath)
    end
end

local function writeToLogFile(entry)
    local file = io.open(logFilePath, "a") 
    if file then
        file:write(entry .. "\n") 
        file:close()
    else
        Printf("[ERROR] Konnte Log-Datei nicht öffnen: " .. logFilePath)
    end
end

function logMessage(level, message)
    local levels = {
        INFO  = "\27[32m[INFO]\27[0m ",
        WARN  = "\27[33m[WARN]\27[0m ",
        ERROR = "\27[31m[ERROR]\27[0m ",
        LOG   = "\27[32m[INFO]\27[0m "
    }
    local prefix = levels[level] or "[UNKNOWN] "
    local logEntry = os.date("%Y-%m-%d %H:%M:%S") .. " " .. prefix .. message

    if level == "INFO" then
        Printf(logEntry)
    elseif level == "WARN" or level == "ERROR" or level == "LOG" then
        Echo(logEntry)
    else
        Printf("[UNKNOWN] " .. message)
    end

    writeToLogFile(logEntry)
end

--------------------------------------------------------------------------------
-- Main Function
--------------------------------------------------------------------------------
local function customPluginLogic()
    local shortcuts = CurrentProfile().KeyboardShortCuts
    shortcuts.KeyboardShortcutsActive = false
    dialog = buildMenubpm(600, 600)
end

--------------------------------------------------------------------------------
-- UI-Aufbau
--------------------------------------------------------------------------------
function buildMenubpm(width, height)
    local result = {}

    -- Display + Overlay
    local display = GetFocusDisplay()
    local overlay = display.ScreenOverlay
    result.display = display
    result.overlay = overlay

    -- Hauptdialog
    local mainDialogbpm = overlay:Append("BaseInput")
    mainDialogbpm.Name = "TC BPM Shifter"
    mainDialogbpm.H = height
    mainDialogbpm.W = width
    mainDialogbpm.Rows = 2
    mainDialogbpm.Columns = 1
    mainDialogbpm[1][1].SizePolicy = "Fixed"
    mainDialogbpm[1][1].Size = "60"
    mainDialogbpm[1][2].SizePolicy = "Stretch"
    mainDialogbpm.AutoClose = "No"
    mainDialogbpm.CloseOnEscape = "Yes"
    result.dialog = mainDialogbpm

    -- TitleBar
    local titleBarbpm = mainDialogbpm:Append("TitleBar")
    titleBarbpm.Columns = 2
    titleBarbpm.Rows    = 1
    titleBarbpm.Anchors = "0,0"
    titleBarbpm[2][2].SizePolicy = "Fixed"
    titleBarbpm[2][2].Size       = "50"
    titleBarbpm.Texture          = "corner2"

    local titleBarIcon = titleBarbpm:Append("TitleButton")
    titleBarIcon.Text    = "TC BPM Shifter "
    titleBarIcon.Texture = "corner1"
    titleBarIcon.Anchors = "0,0"
    titleBarIcon.Icon    = "object_appear"

    local titleBarCloseButton = titleBarbpm:Append("CloseButton")
    titleBarCloseButton.Anchors = "1,0"
    titleBarCloseButton.Texture = "corner2"

    -- Hauptbereich (DialogFrame)
    local dlgFrame = mainDialogbpm:Append("DialogFrame")
    dlgFrame.H       = "100%"
    dlgFrame.W       = "100%"
    dlgFrame.Columns = 1
    dlgFrame.Rows    = 7
    result.dlgFrame  = dlgFrame

    -----------------------------
    -- TC SLOT
    -----------------------------
    buildHeaderbpm("TC Info", dlgFrame, "0,0")

    local rowtcslot = dlgFrame:Append("UILayoutGrid")
    rowtcslot.Anchors = "0,1"
    rowtcslot.Columns = 4
    rowtcslot.Rows    = 1
    rowtcslot[2][1].SizePolicy = "Strech"
    rowtcslot[2][1].Size       = "200"
    rowtcslot[2][3].SizePolicy = "Strech"
    rowtcslot[2][3].Size       = "400"

    local tcslotLabel = rowtcslot:Append("UIObject")
    tcslotLabel.Anchors        = "0,0"
    tcslotLabel.Text           = "TC Slot"
    tcslotLabel.Font           = "Medium20"
    tcslotLabel.TextalignmentH = "Center"


    local tcslotEdit = rowtcslot:Append("LineEdit")
    tcslotEdit.Name          = "TCSlot"
    tcslotEdit.Message       = "TimeCode Slot"
    tcslotEdit.Anchors       = "2,0"
    tcslotEdit.Texture       = "corner0"
    tcslotEdit.Focus         = "InitialFocus"
    tcslotEdit.TextChanged   = "OnChangeAll"
    tcslotEdit.PluginComponent = my_handle
    tcslotEdit.VKPluginName  = "TextInput"
    result.tcslotEdit        = tcslotEdit
    tcslotEdit.ToolTip = "Enter the timecode object number, which you want to change."
    
    -----------------------------
    -- TC Datapool
    -----------------------------
    local rowdp = dlgFrame:Append("UILayoutGrid")
    rowdp.Anchors = "0,2"
    rowdp.Columns = 4
    rowdp.Rows    = 1
    rowdp[2][1].SizePolicy = "Stretch"
    rowdp[2][1].Size       = "200"
    rowdp[2][3].SizePolicy = "Stretch"
    rowdp[2][3].Size       = "400"

    local tcdatapoolLabel = rowdp:Append("UIObject")
    tcdatapoolLabel .Anchors        = "0,0"
    tcdatapoolLabel .Text           = "TC Datapool"
    tcdatapoolLabel .Font           = "Medium20"
    tcdatapoolLabel .TextalignmentH = "Center"


    local tcdatapoolEdit = rowdp:Append("LineEdit")
    tcdatapoolEdit.Name          = "TCDatapool"
    tcdatapoolEdit.Message       = "6"
    tcdatapoolEdit.Anchors       = "2,0"
    tcdatapoolEdit.Texture       = "corner0"
    tcdatapoolEdit.TextChanged   = "OnChangeAll"
    tcdatapoolEdit.PluginComponent = my_handle
    tcdatapoolEdit.VKPluginName  = "TextInputNumOnly"
    tcdatapoolEdit.Filter        = "1234567890"
    tcdatapoolEdit.MaxTextLength = 3
    result.tcdatapoolEdit        = tcdatapoolEdit
    tcdatapoolEdit.ToolTip = "Enter the datapoolnumber, which contains the timecode."
    
    -----------------------------
    -- HEADLINE DataPools
    -----------------------------
    buildHeaderbpm("BPM Settings", dlgFrame, "0,3")

   -----------------------------
    -- OLD BPM
    -----------------------------
    local rowoldbpm = dlgFrame:Append("UILayoutGrid")
    rowoldbpm.Anchors = "0,4"
    rowoldbpm.Columns = 4
    rowoldbpm.Rows    = 1
    rowoldbpm[2][1].SizePolicy = "Strech"
    rowoldbpm[2][1].Size       = "200"
    rowoldbpm[2][3].SizePolicy = "Stretch"
    rowoldbpm[2][3].Size       = "400"

    local oldbpmLabel = rowoldbpm:Append("UIObject")
    oldbpmLabel.Anchors        = "0,0"
    oldbpmLabel.Text           = "Old BPM"
    oldbpmLabel.Font           = "Medium20"
    oldbpmLabel.TextalignmentH = "Center"


    local oldbpmEdit = rowoldbpm:Append("LineEdit")
    oldbpmEdit.Name          = "oldbpm"
    oldbpmEdit.Message       = "120"
    oldbpmEdit.Anchors       = "2,0"
    oldbpmEdit.Texture       = "corner0"
    oldbpmEdit.TextChanged   = "OnChangeAll"
    oldbpmEdit.PluginComponent = my_handle
    oldbpmEdit.VKPluginName  = "TextInputNumOnly"
    oldbpmEdit.Filter        = "1234567890"
    oldbpmEdit.MaxTextLength = 3
    result.oldbpmEdit        = oldbpmEdit
    oldbpmEdit.ToolTip = "The current BPM of the timecode"
  
    -----------------------------
    -- NEW BPM
    -----------------------------
    local rownewbpm = dlgFrame:Append("UILayoutGrid")
    rownewbpm.Anchors = "0,5"
    rownewbpm.Columns = 4
    rownewbpm.Rows    = 1
    rownewbpm[2][1].SizePolicy = "Stretch"
    rownewbpm[2][1].Size       = "200"
    rownewbpm[2][3].SizePolicy = "Stretch"
    rownewbpm[2][3].Size       = "400"

    local newbpmLabel = rownewbpm:Append("UIObject")
    newbpmLabel.Anchors        = "0,0"
    newbpmLabel.Text           = "New BPM"
    newbpmLabel.Font           = "Medium20"
    newbpmLabel.TextalignmentH = "Center"


    local newbpmEdit = rownewbpm:Append("LineEdit")
    newbpmEdit.Name          = "newbpm"
    newbpmEdit.Message       = "128"
    newbpmEdit.Anchors       = "2,0"
    newbpmEdit.Texture       = "corner0"
    newbpmEdit.TextChanged   = "OnChangeAll"
    newbpmEdit.PluginComponent = my_handle
    newbpmEdit.VKPluginName  = "TextInputNumOnly"
    newbpmEdit.Filter        = "1234567890"
    newbpmEdit.MaxTextLength = 3
    result.newbpmEdit        = newbpmEdit
    newbpmEdit.ToolTip = "The new BPM you want to scale to."
   
    -----------------------------
    -- Action Buttons
    -----------------------------
    local actionButtonsbpm = dlgFrame:Append("UILayoutGrid")
    actionButtonsbpm.Anchors = "0,6"
    actionButtonsbpm.Columns = 2
    actionButtonsbpm.Rows    = 1

    -- Apply
    local applyBtn = actionButtonsbpm:Append("Button")
    applyBtn.Anchors       = "0,0"
    applyBtn.Textshadow    = 1
    applyBtn.HasHover      = "Yes"
    applyBtn.Text          = "Apply"
    applyBtn.Font          = "Medium20"
    applyBtn.BackColor     = Root().ColorTheme.ColorGroups.Button.BackgroundClear
    applyBtn.TextalignmentH= "Centre"
    applyBtn.PluginComponent = my_handle
    applyBtn.Clicked       = "ApplyButtonClicked"
    applyBtn.Enabled       = "No"
    result.apply           = applyBtn

    -- Close
    local cancelBtn = actionButtonsbpm:Append("Button")
    cancelBtn.Anchors       = "1,0"
    cancelBtn.Textshadow    = 1
    cancelBtn.HasHover      = "Yes"
    cancelBtn.Text          = "Cancel"
    cancelBtn.Font          = "Medium20"
    cancelBtn.TextalignmentH= "Centre"
    cancelBtn.PluginComponent = my_handle
    cancelBtn.Clicked       = "CancelButtonClicked"

    return result
end

--------------------------------------------------------------------------------
-- HEADER-Hilfsfunktion
--------------------------------------------------------------------------------
function buildHeaderbpm(text, parent, anchor)
    local header = parent:Append("UIObject")
    header.Anchors = anchor
    header.Text    = text
    header.Font    = "Medium20"
    header.HasHover= "No"
    header.BackColor = Root().ColorTheme.ColorGroups.Global.PartlySelected
end

--------------------------------------------------------------------------------
-- SIGNAL-TABLE Callback: CancelButtonClicked
--------------------------------------------------------------------------------
signalTable.CancelButtonClicked = function(caller, ...)
    Obj.Delete(dialog.overlay, Obj.Index(dialog.dialog))
end

--------------------------------------------------------------------------------
-- SIGNAL-TABLE Callback: ApplyButtonClicked
--------------------------------------------------------------------------------
signalTable.ApplyButtonClicked = function(caller, ...)
    local opts = {
        title="Confirmation",
        backColor="Global.Focus",
        icon="logo_small",
        titleTextColor="Global.Text",
        message="You really want to shift all timecode events?",
        commands={
            {value=0, name="Cancel"},
            {value=1, name="OK"}
        },
    }
    local mb = MessageBox(opts)
    if mb.result == 1 then
        shiftTCevents()
    else
        Printf("[Indo] User Canceled")
    end
end

--------------------------------------------------------------------------------
-- SIGNAL-TABLE Callback: OnChangeAll
--------------------------------------------------------------------------------
signalTable.OnChangeAll = function(caller, ...)
    validateDialog()
end

--------------------------------------------------------------------------------
-- VALIDIERUNG
--------------------------------------------------------------------------------
function validateDialog()


    local MAtcslot        = dialog.tcslotEdit.Content or ""
    local MAtcdatapool    = dialog.tcdatapoolEdit.Content or ""
    local MAoldbpm        = dialog.oldbpmEdit.Content or ""
    local MAnewbpm        = dialog.newbpmEdit.Content or ""

    local tcslot         = tonumber(MAtcslot)
    local tcdatapool     = tonumber(MAtcdatapool)
    local oldbpm         = tonumber(MAoldbpm)
    local newbpm         = tonumber(MAnewbpm)

    if tcslot == nil or tcdatapool == nil or oldbpm == nil or newbpm  == nil  then
        disableApplyButton("Entry Missing")
        return
    end


    -- TC Datapool & TC Slot Check
    local tcdatapoolObj = Root().ShowData.DataPools[tcdatapool]
    if tcdatapoolObj == nil then
        disableApplyButton("Datapool not existing")
        return
    end
    if not tcdatapoolObj then
        disableApplyButton("TC Datapool "..tcdatapoolObj.." not found.")
        return
    end
    if not tcdatapoolObj.Timecodes[tcslot] then
        disableApplyButton("Timecode object "..tcslot.." not found.")
        return
    end

    -- Old BPM Check
    if not oldbpm then
        disableApplyButton("Current BPM not entered")
        return
    end

    -- New BPM Check
    if not newbpm then
        disableApplyButton("New BPM not entered")
        return
    end

    enableApplyButton()
end

function disableApplyButton(reason)
    logMessage("WARN", "Apply-button deactivated: " .. reason)
    dialog.apply.Enabled   = "No"
    dialog.apply.BackColor = Root().ColorTheme.ColorGroups.Button.BackgroundClear

end

function enableApplyButton()
    dialog.apply.Enabled   = "Yes"
    dialog.apply.BackColor = Root().ColorTheme.ColorGroups.Button.BackgroundPlease
end

--------------------------------------------------------------------------------
-- Iterate Children
--------------------------------------------------------------------------------
function iterateChildren(parent, callback)
    local children = parent:Children()
    for _, child in ipairs(children) do
        callback(child)
    end
end

--------------------------------------------------------------------------------
-- Shift Events
--------------------------------------------------------------------------------
function shiftTCevents()
    logMessage("INFO", "-------------------------------------------- LOGFILE Shift Events --------------------------------------------")
    logMessage("INFO", "OOPS / UNDO marker created")

    local MAtcslot        = dialog.tcslotEdit.Content or ""
    local MAtcdatapool    = dialog.tcdatapoolEdit.Content or ""
    local MAoldbpm        = dialog.oldbpmEdit.Content or ""
    local MAnewbpm        = dialog.newbpmEdit.Content or ""

    local tcslot         = tonumber(MAtcslot)
    local tcdatapool     = tonumber(MAtcdatapool)
    local oldbpm         = tonumber(MAoldbpm)
    local newbpm         = tonumber(MAnewbpm)

    local startTime = os.clock()

    local scale = oldbpm / newbpm

    local timecode = Root().ShowData.DataPools[tcdatapool].Timecodes[tcslot]
    if not timecode then
        logMessage("ERROR", "Timecode in slot " ..tcslot.. " not found.")
        errors = errors + 1
        return
    end

    local undo = CreateUndo("Shift Timecode Events")
    local progressIndex = StartProgress("Shifting Timecode Events")
    local totalEvents = 0
    local processedEvents = 0

    -- Fortschrittsbereich setzen
    SetProgressRange(progressIndex, 0, totalEvents)

    -- Verarbeite alle Events mit Fortschrittsanzeige
    iterateChildren(timecode, function(trackGroup)
        iterateChildren(trackGroup, function(track)
            iterateChildren(track, function(timeRange)
                iterateChildren(timeRange, function(cmdSubTrack)
                    iterateChildren(cmdSubTrack, function(event)
                        if event then
                            local eventTime = event:Get("Time")
                            if eventTime then
                                local events = cmdSubTrack:Children()
                                totalEvents = totalEvents + #events
                                -- Speichere den ursprünglichen Zustand im Undo-Block
                                Cmd("Set " .. tostring(event) .. " Property \"Time\" \"" .. eventTime .. "\"", undo)

                                -- Skaliere die Zeit und setze die neue Zeit
                                local newTime = eventTime * scale
                                event:Set("Time", newTime)
                                logMessage("LOG", "Event: old time = " .. eventTime .. ", new time = " .. newTime)
                            else
                            logMessage("ERROR", "Event in CmdSubTrack " .. tostring(cmdSubTrack) .. " hat keine Zeitinformation.")
                            errors = errors + 1
                            end
                        end

                        -- Fortschritt aktualisieren
                        processedEvents = processedEvents + 1
                        SetProgress(progressIndex, processedEvents)
                    end)
                end)
            end)
        end)
    end)
    local endTime = os.clock()
    

    StopProgress(progressIndex)
    CloseUndo(undo)
    disableApplyButton("Finish")

    logMessage("INFO", "Total events shifted:" ..processedEvents)
    logMessage("INFO", "Total errors: " .. errors)
    logMessage("INFO", "Job finished in " .. (endTime - startTime) .. " seconds.")
end

--------------------------------------------------------------------------------
-- Update Function
--------------------------------------------------------------------------------

-- Funktion zum Bereinigen des Inhalts
local function cleanOutput(content)
    local cleanedContent = content:match("{.*}") 
    return cleanedContent or nil
end

-- Funktion zum Lesen der Ausgabe
local function readOutputFile(outputPath)
    local file = io.open(outputPath, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return cleanOutput(content)
end

-- Funktion zur Umwandlung einer Versionsnummer in eine Tabelle {major, minor, patch}
local function parseVersion(versionString)
    local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
    return { tonumber(major), tonumber(minor), tonumber(patch) }
end

-- Funktion zum Vergleich von zwei Versionen
local function isVersionNewer(currentVersion, latestVersion)
    local current = parseVersion(currentVersion)
    local latest = parseVersion(latestVersion)

    if not current or not latest then
        Printf("[ERROR] Versionsvergleich fehlgeschlagen! Ungültige Versionsnummer.")
        return false
    end

    -- Vergleich: Hauptversion, Nebenversion, Patch
    if latest[1] > current[1] then return true end
    if latest[1] == current[1] and latest[2] > current[2] then return true end
    if latest[1] == current[1] and latest[2] == current[2] and latest[3] > current[3] then return true end

    return false
end

-- Funktion zum Parsen von JSON und Versionsprüfung
local function parseJSON(response)
    local data = json.decode(response)
    if not data or not data.tag_name then return nil end

    local latestVersion = data.tag_name

    -- **Neuen Versionsvergleich nutzen**
    if not isVersionNewer(pluginVersion, latestVersion) then
        Printf("Plugin ist aktuell. Keine Updates verfügbar.")
        return nil
    end

    Printf("Neue Version gefunden: %s (Aktuell: %s)", latestVersion, pluginVersion)

    for _, asset in ipairs(data.assets) do
        if asset.name:match("%.lua$") then
            return asset.browser_download_url
        end
    end
    return nil
end

-- Funktion für Pop-up zur Update-Abfrage
local function askForUpdate()
    local messageBoxOptions = {
        title="Update!",
        backColor="Global.Focus",
        icon="logo_small",
        titleTextColor="Global.Text",
        message="New Version available. Do you want to download and install it?",
        commands = {
            {value=0, name="No"},
            {value=1, name="Yes"}
        },
    }
    local response = MessageBox(messageBoxOptions)
    return response.result == 1
end

-- Funktion zum Extrahieren des Dateinamens aus einer URL
local function getFileNameFromURL(url)
    return url:match(".+/([^/]+)$")
end

-- Funktion für den Download der `.lua`-Datei
local function downloadLuaFile(downloadURL, saveDirectory)
    local fileName = getFileNameFromURL(downloadURL)
    if not fileName then return nil end

    local savePath = saveDirectory .. "/" .. fileName
    local command = string.format("powershell -Command \"& {Invoke-WebRequest -Uri '%s' -OutFile '%s'}\"", downloadURL, savePath)

    os.execute(command)

    local file = io.open(savePath, "r")
    if file then
        file:close()
        return savePath
    else
        return nil
    end
end

-- Funktion zum Verschieben der Datei
local function moveFile(sourcePath, targetDirectory)
    local fileName = sourcePath:match("([^/\\]+)$")
    local targetPath = targetDirectory .. "/" .. fileName

    local input = io.open(sourcePath, "rb")
    if not input then return nil end

    local output = io.open(targetPath, "wb")
    if not output then
        input:close()
        return nil
    end

    output:write(input:read("*a"))
    input:close()
    output:close()
    os.remove(sourcePath)

    return fileName
end

-- Funktion zum Aktualisieren des `FileName`-Wertes im Plugin
local function updatePluginFileName(pluginName, newFileName)
    local pluginPath = ShowData().DataPools.Default.Plugins[pluginName][1]
    if pluginPath then
        pluginPath:Set("FileName", newFileName)
    end
end

-- LuaMain Function
local function main()
    clearLogFile()
    local tempDir = GetPath(Enums.PathType.Temp)
    local outputPath = tempDir .. "/output.txt"
    local command = "curl -s \"" .. githubRepoAPI .. "\""

    -- JSON-Daten abrufen
    os.execute(command .. " > " .. outputPath)
    local output = readOutputFile(outputPath)
    if not output then return end

    -- Download-URL extrahieren und prüfen, ob ein Update verfügbar ist
    local downloadURL = parseJSON(output)
    if downloadURL then
        -- **Pop-up zur Update-Abfrage**
        if askForUpdate() then
            local savePath = downloadLuaFile(downloadURL, tempDir)
            if savePath then
                local fileName = moveFile(savePath, pluginDir)
                if fileName then
                    updatePluginFileName(pluginName, fileName)
                    logMessage("INFO", "Update erfolgreich installiert!")
                end
            end
        else
            logMessage("WARN", "Update abgelehnt. Plugin bleibt auf der aktuellen Version.")
        end
    end
    -- Temporäre Dateien bereinigen
    os.remove(outputPath)
    -- **Starte die eigentliche Plugin-Logik**
    customPluginLogic()

end

return main
