--
-- Hello World example
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    hs.alert.show("Hello World!")
end)
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
    batt_watch_hist(changed)
end
-----------------------------------------------------------------


--hs.battery.watcher.new(batt_watch_low):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_watch_low)

hs.battery.watcher.new(batt_wrapper_changed):start()
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_wrapper_changed)

--hs.battery.watcher.new(batt_wrapper_hist):start()
--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "B", batt_wrapper_hist)


--
-- Automagic reload!
--
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config Re-loaded")
--
