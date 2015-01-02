--
-- Hello World example
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    hs.alert.show("Hello World!")
end)
--

--
-- Names: 'Color LCD' and 'DELL U2713HM'
--
local internal_orig_brightness = 42
function screen_handler(name)
    SCREEN_NAME_INTERNAL = 'Color LCD'
    SCREEN_NAME_EXTERNAL = 'DELL U2713HM'

    if name == SCREEN_NAME_INTERNAL then
        hs.alert.show("Internal screen detected!")
        hs.brightness.set(internal_original_brightness)
    elseif name == SCREEN_NAME_EXTERNAL then
        hs.alert.show("External screen detected!")
        internal_original_brightness = hs.brightness.get()
        hs.brightness.set(0)
    end

end

--
-- Screen detection stuff in mirrored mode, where there is only one screen.
--
local prev_name = ''
function screen_detector_mirrored()

    all_screens = hs.screen.allScreens()

    if #all_screens ~= 1 then
        hs.alert.show("More than one screen detected!\nNot in mirrored mode?")
        return
    end

    -- Assuming we have only one screen, get the "vendor name".
    name = hs.screen.name(all_screens[1])

    -- If different than before or initial run
    if name ~= prev_name or not prev_name then
        -- Use external handler to keep this function generic
        screen_handler(name)

        -- Store name
        prev_name = name
    end

end
hs.screen.watcher.new(screen_detector_mirrored):start()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", screen_detector_mirrored)
--

--
-- Hints!
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    hs.hints.windowHints()
   
end)
--



--
-- Battery stuff
--
--
-- Unloading:
-- isCharged: n/a
-- timeToFullCharge: -1
-- designCapacity: 8460
-- name: InternalBattery-0
-- health: Good
-- maxCapacity: 7559
-- powerSource: Battery Power
-- isFinishingCharge: false
-- healthCondition: n/a
-- watts: 27.4743
-- isCharging: true
-- capacity: 363
-- voltage: 11025
-- percentage: 5
-- timeRemaining: -1
-- cycles: 225
-- amperage: 2492
--
--
-- Charging:
-- isCharged: n/a
-- timeToFullCharge: 221
-- designCapacity: 8460
-- name: InternalBattery-0
-- health: Good
-- maxCapacity: 7559
-- powerSource: AC Power
-- isFinishingCharge: false
-- healthCondition: n/a
-- watts: 28.124775
-- isCharging: true
-- capacity: 304
-- voltage: 11025
-- percentage: 4
-- timeRemaining: -2
-- cycles: 225
-- amperage: 2551
--

--------------------------------------------------
-- Directly called by the "low-level" watcher API.
--------------------------------------------------
pct_prev = nil
function batt_watch_low()
    pct = hs.battery.percentage()
    if pct ~= pct_prev and not hs.battery.isCharging() and pct < 42 then
        hs.alert.show(string.format(
        "Andre: Plug-in the power, only %d%% left!!", pct))
    end
    pct_prev = pct
end
--------------------------------------------------


-----------------------------------------------------------------------------
-- Called by the "changed" watcher wrapper,
-- that provides only the changed attributes with its values.
-----------------------------------------------------------------------------
function batt_watch_changed(changed)
    pct = changed.percentage
    if not hs.battery.isCharging() and pct and pct < 42 then
        hs.alert.show(string.format(
        "Andre: Plug-in the power, only %d%% left!!", pct))
    end
end
-----------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Called by the "hist" watcher wrapper,
-- that also provides the previous values for the changed attributes.
-------------------------------------------------------------------------------
function batt_watch_hist(changed)
    pct = changed.percentage
    if not hs.battery.isCharging() and pct and pct.new < 42 then
        hs.alert.show(string.format(
        "Andre: Plug-in the power, only %d%% left!!", pct.new))
    end
end
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Called by the "select" watcher wrapper,
-- that also provides the previous values for the changed attributes.
-------------------------------------------------------------------------------
function batt_watch_select(pct)
    if not hs.battery.isCharging() and pct < 42 then
        hs.alert.show(string.format(
        "Plug-in the power, only %d%% left!!", pct.new))
    end
end
-------------------------------------------------------------------------------


--------------------------------------------------------------------------
-- The "changed" watcher wrapper, that provides a table of changed values.
--------------------------------------------------------------------------
local batt_prev = {}
function batt_wrapper_changed()
    batt_info = hs.battery.getAll()
    changed = {}
    for key, new_val in pairs(batt_info) do
        if new_val ~= batt_prev[key] then
            changed[key] = new_val
        end
    end
    batt_prev = batt_info
    batt_watch_changed(changed)
end
--------------------------------------------------------------------------


-----------------------------------------------------------------
-- "hist" watcher wrapper, that also provides the previous value.
-----------------------------------------------------------------
local batt_prev = {}
function batt_wrapper_hist()
    batt_info = hs.battery.getAll()
    changed = {}
    for key, new_val in pairs(batt_info) do
        if new_val ~= batt_prev[key] then
            changed[key] = {new = new_val, prev = batt_prev[key]}
        end
    end
    batt_prev = batt_info
    --io.write(hs.inspect(changed))
    --hs.alert.show(hs.inspect(changed))
    batt_watch_hist(changed)
end
-----------------------------------------------------------------


-----------------------------------------------------------------
-- "select" watcher wrapper, that also provides the previous value.
-----------------------------------------------------------------
local batt_prev = {}
function batt_wrapper_select(selection)
    batt_info = hs.battery.getAll()
    changed = {}
    for key, new_val in pairs(batt_info) do
        if selection == key and new_val ~= batt_prev[key] then
            changed[key] = {new = new_val, prev = batt_prev[key]}
        end
    end
    batt_prev = batt_info
    batt_watch_select(changed)
end
-----------------------------------------------------------------


--hs.battery.watcher.new(batt_watch_low):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_watch_low)

--hs.battery.watcher.new(batt_wrapper_changed):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_wrapper_changed)

--hs.battery.watcher.new(batt_wrapper_hist):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_wrapper_hist)

--hs.battery.watcher.new(batt_wrapper_select):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_wrapper_select)

--
-- Automagic reload!
--
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(hs.configdir, reload_config):start()
hs.alert.show("Config Re-loaded")
--
