local utility = require("utility")

local module = {}
module.updateCallbacks = {}

local function refreshInfo()
    utility.dbus.getProperties({
        bus = "system",
        destination = "org.freedesktop.UPower",
        object = module.displayDevice,
        interface = "org.freedesktop.UPower.Device"
    }, function (props)
        module.batteryProperties = props
        for _, cb in ipairs(module.updateCallbacks) do
            cb()
        end
    end)
end

function module.init()
    local msg = utility.dbus.callMethodWithReplySync({
        bus = "system",
        destination = "org.freedesktop.UPower",
        object = "/org/freedesktop/UPower",
        interface = "org.freedesktop.UPower",
        func = "GetDisplayDevice"
    })
    module.displayDevice = msg:get_string()
    local props = utility.dbus.getPropertiesSync({
            bus = "system",
            destination = "org.freedesktop.UPower",
            object = module.displayDevice,
            interface = "org.freedesktop.UPower.Device"
    })
    module.batteryProperties = props
    if props:lookup_value("IsPresent"):get_boolean() then
        module.timer = Gears.timer {
            timeout = 30,
            autostart = true,
            single_shot = false,
            callback = refreshInfo
        }
    end

    -- This will make sure our battery widget shows us the battery
    -- instead of unknown symbol
    utility.addPostInitCallback(refreshInfo)
end

function module.exists()
    return module.batteryProperties:lookup_value("IsPresent"):get_boolean()
end

function module.getChargeFraction()
    local value = module.batteryProperties:lookup_value("Percentage"):get_double()
    return value / 100
end

function module.getTimeToCharge()
    return module.batteryProperties:lookup_value("TimeToFull"):get_int64()
end

function module.getTimeToEmpty()
    return module.batteryProperties:lookup_value("TimeToEmpty"):get_int64()
end

function module.addUpdateCallback(callback)
    module.updateCallbacks[#module.updateCallbacks+1] = callback
end

function module.isCharging()
    local state = module.batteryProperties:lookup_value("State"):get_uint32()
    return state == 1
end

return module
