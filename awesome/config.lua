local config = {}

config.terminal = "kitty"
config.editor = "nvim"

config.modKey = "Mod4" -- Windows key

config.configRoot = "/home/patryk/.config/awesome"
config.themePath = config.configRoot.."/default"
config.iconPath = config.themePath.."/icons"

config.groups = {
    {
        groupName = utf8.char(0xf878),
        displayName = "Main",
        program = nil,
        hideEmpty = false
    },
    {
        groupName = utf8.char(0xf9f8),
        displayName = "Second Tag",
        program = nil,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf9f8),
        displayName = "Third Tag",
        program = nil,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf738),
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
        groupName = utf8.char(0xfb6e),
        displayName = "Discord",
        program = "discord",
        spawnOne = false,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf43d),
        displayName = "Keepass",
        program = "keepassxc",
        spawnOne = false,
        hideEmpty = true
    },
    {
        groupName = utf8.char(0xf9d2),
        displayName = "Steam",
        program = "steam",
        hideEmpty = true,
        spawnOne = false
    },
    {
	groupName = utf8.char(0xf6ed),
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

return config
