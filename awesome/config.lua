local config = {}

config.terminal = "kitty"
config.editor = "nvim"

config.modKey = "Mod4" -- Windows key

config.configRoot = "/home/patryk/.config/awesome"
config.themePath = config.configRoot.."/default"
config.iconPath = config.themePath.."/icons"

config.groups = {
    {
        groupName = utf8.char(0xf0379),
        displayName = "Main",
        program = nil,
        hideEmpty = false
    },
    {
        groupName = utf8.char(0xf04f9),
        displayName = "Second Tag",
        program = nil,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf04f9),
        displayName = "Third Tag",
        program = nil,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf0239),
        displayName = "Firefox",
        program = "firefox",
        spawnOne = true,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf120),
        displayName = "Terminal",
        program = "kitty",
        spawnOne = false,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf066f),
        displayName = "Discord",
        program = "discord",
        spawnOne = false,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf0306),
        displayName = "Keepass",
        program = "keepassxc",
        spawnOne = false,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf04d3),
        displayName = "Steam",
        program = "steam",
        hideEmpty = true,
        spawnOne = false
    },
    {
        groupName = utf8.char(0xf01ee),
        displayName = "ThunderBird",
        program = "thunderbird",
        hideEmpty = true,
        spawnOne = true
    }
}
config.groupCount = #config.groups

config.places = {
    {
        name = "Home",
        path = "/home/patryk"
    },
    {
        name = "Documents",
        path = "/home/patryk/Documents"
    },
    {
        name = "Pictures",
        path = "/home/patryk/Pictures"
    },
    {
        name = "Projects",
        path = "/home/patryk/Projects"
    },
    {
        name = "Downloads",
        path = "/home/patryk/Downloads"
    }
}

config.mainmenu_layout = {
    profile = {
        x = 1,
        y = 1,
        width = 3,
        height = 4,
        wrap = true
    },
    powermenu = {
        x = 16,
        y = 1,
        width = 1,
        height = 5,
        wrap = false
    },
    control = {
        x = 7,
        y = 1,
        width = 5,
        height = 2,
        wrap = true
    },
    sound = {
        x = 7,
        y = 3,
        width = 5,
        height = 2,
        wrap = true
    },
    places = {
        x = 4,
        y = 1,
        width = 3,
        height = 4,
        wrap = true
    },
    brightness = {
        x = 12,
        y = 1,
        width = 1,
        height = 3,
        wrap = true
    },
    clock = {
        x = 15,
        y = 8,
        width = 2,
        height = 1,
        wrap = true,
        wrap_margin = 5
    }
}

config.layouts = {
    Awful.layout.suit.fair,

    Awful.layout.suit.tile,
    Awful.layout.suit.tile.left,
    Awful.layout.suit.tile.top,
    Awful.layout.suit.tile.bottom,

    Awful.layout.suit.floating
}

return config
