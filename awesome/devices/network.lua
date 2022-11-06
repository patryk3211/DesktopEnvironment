local utility = require("utility")

local module = {}

function module.wifiHardwareEnabled(callback)
    utility.dbus.getProperty({
        bus = "system",
        destination = "org.freedesktop.NetworkManager",
        object = "/org/freedesktop/NetworkManager",
        interface = "org.freedesktop.NetworkManager",
        property = "WirelessHardwareEnabled"
    }, function (msg)
        if callback then
            local value = msg:get_variant():get_boolean()
            callback(value)
        end
    end)
end

function module.getDevices(callback)
    local result = {}

    utility.dbus.callMethodWithReply({
        bus = "system",
        destination = "org.freedesktop.NetworkManager",
        object = "/org/freedesktop/NetworkManager",
        interface = "org.freedesktop.NetworkManager",
        func = "GetAllDevices"
    }, function (msg)
        local count = msg:n_children()

        for i = 0, count - 1 do
            local entry = msg:get_child_value(i)
            local devLoc = entry:get_string()

            utility.dbus.getProperties({
                bus = "system",
                destination = "org.freedesktop.NetworkManager",
                object = devLoc,
                interface = "org.freedesktop.NetworkManager.Device"

            }, function (properties)
                local obj = {
                    interface = properties:lookup_value("Interface"):get_string(),
                    type = properties:lookup_value("DeviceType"):get_uint32(),
                    connection = properties:lookup_value("ActiveConnection"):get_string(),
                    path = devLoc
                }

                result[#result+1] = obj
                if #result == count then
                    callback(result)
                end
            end)
        end
    end)
end

function module.getConnections(callback)
    local result = {}

    utility.dbus.callMethodWithReply({
        bus = "system",
        destination = "org.freedesktop.NetworkManager",
        object = "/org/freedesktop/NetworkManager/Settings",
        interface = "org.freedesktop.NetworkManager.Settings",
        func = "ListConnections"
    }, function (msg)
        local count = msg:n_children()

        for i = 0, count - 1 do
            local entry = msg:get_child_value(i)
            local connLoc = entry:get_string()

            utility.dbus.callMethodWithReply({
                bus = "system",
                destination = "org.freedesktop.NetworkManager",
                object = connLoc,
                interface = "org.freedesktop.NetworkManager.Settings.Connection",
                func = "GetSettings"
            }, function (msg)
                local connect = msg:lookup_value("connection")

                local obj = {
                    type = connect:lookup_value("type"):get_string(),
                    name = connect:lookup_value("id"):get_string(),
                    path = connLoc
                }

                local interface = connect:lookup_value("interface-name")
                if interface then
                    obj.interface = interface:get_string()
                end

                result[#result+1] = obj
                if #result == count then
                    callback(result)
                end
            end)
        end
    end)
end

function module.readProperties(object, interface, callback)
    utility.dbus.getProperties({
        bus = "system",
        destination = "org.freedesktop.NetworkManager",
        object = object,
        interface = interface
    }, callback)
end

function module.findAP(device, ssidToFind, callback)
    utility.dbus.callMethodWithReply({
        bus = "system",
        destination = "org.freedesktop.NetworkManager",
        object = device,
        interface = "org.freedesktop.NetworkManager.Device.Wireless",
        func = "GetAccessPoints"
    }, function (msg)
        local count = msg:n_children()

        for i = 0, count - 1 do
            local entry = msg:get_child_value(i):get_string()
            module.readProperties(entry, "org.freedesktop.NetworkManager.AccessPoint", function (properties)
                local ssid = properties:lookup_value("Ssid")

                local ssidString = ""
                for i = 0, ssid:n_children() - 1 do
                    local byte = ssid:get_child_value(i):get_byte()
                    ssidString = ssidString..utf8.char(byte)
                end

                if ssidString == ssidToFind then
                    callback(entry)
                end
            end)
        end
    end)
end

function module.refreshButtons(wifiButton, wiredButton)
    -- Refresh wifi button
    wifiButton.conn = nil
    wifiButton.dev = nil
    wifiButton.activeConn = nil
    wifiButton.specificObj = nil

    wiredButton.specificObj = "/"
    wiredButton.conn = nil
    wiredButton.dev = nil
    wiredButton.activeConn = nil

    module.getDevices(function (devices)
        local foundWireless = false
        local foundWired = false

        for _, dev in ipairs(devices) do
            if dev.type == 2 and not foundWireless then
                wifiButton.dev = dev.path
                if dev.connection == "/" then
                    -- Not connected to a network
                    wifiButton.setArg("state", false)
                    module.getConnections(function (connections)
                        local found = false

                        for _, conn in ipairs(connections) do
                            if conn.type == "802-11-wireless" then
                                found = true
                                wifiButton.conn = conn.path

                                module.findAP(dev.path, conn.name, function (ap)
                                    wifiButton.specificObj = ap
                                    wifiButton.setArg("enabled", true)
                                end)
                                break
                            end
                        end

                        if not found then
                            wifiButton.setArg("enabled", false)
                        end
                    end)
                else
                    -- Save current connection as the connection of the wifi button
                    wifiButton.setArg("enabled", true)
                    wifiButton.setArg("state", true)
                    wifiButton.activeConn = dev.connection
                    module.readProperties(dev.connection, "org.freedesktop.NetworkManager.Connection.Active", function (properties)
                        wifiButton.conn = properties:lookup_value("Connection"):get_string()
                        wifiButton.specificObj = properties:lookup_value("SpecificObject"):get_string()
                    end)
                end

                wifiButton.setArg("disable_right", false)
                foundWireless = true
            elseif dev.type == 1 and not foundWired then
                wiredButton.dev = dev.path
                if dev.connection == "/" then
                    -- Not connected to a network
                    wiredButton.setArg("state", false)
                    module.getConnections(function (connections)
                        local found = false

                        for _, conn in ipairs(connections) do
                            if conn.type == "802-3-ethernet" then
                                found = true
                                wiredButton.conn = conn.path
                                break
                            end
                        end

                        --- I should probably configure a new wired connection in this case
                        if not found then
                            wiredButton.setArg("enabled", false)
                        end
                    end)
                else
                    -- Save current connection as connection of ethernet button
                    wiredButton.setArg("state", true)
                    wiredButton.activeConn = dev.connection
                    module.readProperties(dev.connection, "org.freedesktop.NetworkManager.Connection.Active", function (properties)
                        wiredButton.conn = properties:lookup_value("Connection"):get_string()
                    end)
                end

                wiredButton.setArg("enabled", true)
                foundWired = true
            end
        end

        if not foundWireless then
            wifiButton.setArg("enabled", false)
            wifiButton.setArg("disable_right", true)
        end

        if not foundWired then
            wiredButton.setArg("enabled", false)
        end
    end)
end

return module
