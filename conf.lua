function love.conf(t)
    t.identity = "lpgcas-ld28"
    t.version = "0.9.0"
    t.console = false

    t.window.title = "Ludum Dare 28: Warrior"
    t.window.icon = nil
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
end