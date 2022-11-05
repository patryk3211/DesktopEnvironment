local lgi = require("lgi")
local gio = lgi.require("Gio")
local glib = lgi.require("GLib")

local module = {}

local systemBus = nil
local sessionBus = nil
function module.init()
    systemBus = gio.bus_get_sync(gio.BusType.SYSTEM)
    sessionBus = gio.bus_get_sync(gio.BusType.SESSION)
end

--- Call a DBUS Method
---@param args table Table of arguments
--- bus = 'system/session', default: session<br>
--- name = DBUS name<br>
--- object = DBUS object path<br>
--- interface = DBUS interface<br>
--- func = DBUS function<br>
--- destination = DBUS destination<br>
function module.callMethod(args)
    local bus = sessionBus
    if args.bus == "system" then
        args.bus = systemBus
    end

    local message = gio.DBusMessage.new_method_call(args.name, args.object, args.interface, args.func)
    message:set_destination(args.destination)
    bus:send_message(message, gio.DBusSendMessageFlags.NONE)
end

--- Call a DBUS Method
---@param args table Table of arguments
--- bus = 'system/session', default: session<br>
--- name = DBUS name<br>
--- object = DBUS object path<br>
--- interface = DBUS interface<br>
--- func = DBUS function<br>
--- destination = DBUS destination<br>
--- args = DBUS function args ([{ string: type, any: value }, ...])
function module.callMethodWithReply(args, callback)
    local bus = sessionBus
    if args.bus == "system" then
        bus = systemBus
    end

    local message = gio.DBusMessage.new_method_call(args.name, args.object, args.interface, args.func)
    message:set_destination(args.destination)

    if args.args then
        local typeString = "("
        local valueArray = {}
        for _, entry in ipairs(args.args) do
            typeString = typeString..entry.type
            valueArray[#valueArray+1] = entry.value
        end
        typeString = typeString..")"

        message:set_body(glib.Variant(typeString, valueArray))
    end

    bus:send_message_with_reply(message, gio.DBusSendMessageFlags.NONE, 1000, nil, function (source, res)
        local msg = bus:send_message_with_reply_finish(res)
        if callback then
            callback(msg:get_body())
        end
    end)
end

--- Returns the first dbus destination for a specified prefix
---@param prefix string
---@param callback function
function module.getTarget(prefix, callback)
    Awful.spawn.easy_async("qdbus", function (stdout)
        local mpStart = stdout:find(prefix)
        if mpStart == nil then
            return
        end

        local lineEnd = stdout:find("\n", mpStart)
        if lineEnd == nil then
            lineEnd = stdout:len()
        else
            lineEnd = lineEnd - 1
        end

        callback(stdout:sub(mpStart, lineEnd))
    end)
end

--- Get a property of a DBus object
---@param args table Table of arguments
--- bus = 'system/session', default: session<br>
--- name = DBUS name<br>
--- object = DBUS object path<br>
--- destination = DBUS destination<br>
--- interface = DBUS interface<br>
--- property = Property on the interface<br>
---@param callback function Callback when parameter is received
function module.getProperty(args, callback)
    local bus = sessionBus
    if args.bus == "system" then
        bus = systemBus
    end

    local message = gio.DBusMessage.new_method_call(args.name, args.object, "org.freedesktop.DBus.Properties", "Get")
    message:set_destination(args.destination)
    message:set_body(glib.Variant("(ss)", {
        args.interface, args.property
    }))
    bus:send_message_with_reply(message, gio.DBusSendMessageFlags.NONE, 1000, nil, function (source, res)
        local msg = bus:send_message_with_reply_finish(res)
        if callback then
            callback(msg:get_body())
        end
    end)
end

--- Get properties of a DBus object
---@param args table Table of arguments
--- bus = 'system/session', default: session<br>
--- name = DBUS name<br>
--- object = DBUS object path<br>
--- destination = DBUS destination<br>
--- interface = DBUS interface<br>
---@param callback function Callback when parameter is received
function module.getProperties(args, callback)
    local bus = sessionBus
    if args.bus == "system" then
        bus = systemBus
    end

    local message = gio.DBusMessage.new_method_call(args.name, args.object, "org.freedesktop.DBus.Properties", "GetAll")
    message:set_destination(args.destination)
    message:set_body(glib.Variant("(s)", {
        args.interface
    }))
    bus:send_message_with_reply(message, gio.DBusSendMessageFlags.NONE, 1000, nil, function (source, res)
        local msg = bus:send_message_with_reply_finish(res)
        if callback then
            callback(msg:get_body():get_child_value(0))
        end
    end)
end

return module
