local mod_id = "example_mod"

-- logger
local logging = require("logging")
local logger = logging.getLogger(mod_id)

-- APIs
local joker = require('joker')
local consumable = require("consumable")
local challenge = require("challenge")
local seal = require("seal")
local balamod = require("balamod")

-- config
local mod_config = {}

local function on_enable()
    -- Add an example joker
    joker.add({
        mod_id = mod_id,
        id = "j_example_joker",
        name = "Example Joker",
        desc = { "{C:green}1 in 1{} chance to do nothing." },
        effect = "This is an example effect.",
        calculate_joker_effect = function(context)
            logger:info("Example joker effect")
        end,
        unlocked = true,
        discovered = true,
        cost = 0,
        blueprint_compat = false,
    })


    -- Add an example consumable (planet card)
    consumable.add({
        mod_id = mod_id,
        set = "Planet",
        config = {hand_type = 'High Card'},
        id = "c_example_planet",
        name = "Example planet card",
        desc = { "This is an example planet card." },
        effect = "This is an example effect.",
        use_effect = function(context)
            logger:info("Example planet card effect")
        end,
        unlocked = true,
        discovered = true,
        cost = 3,
        blueprint_compat = false,
    })


    -- add an example challenge
    challenge.add({
        mod_id = mod_id,
        id = "c_example_1",
        name = "Example challenge",
        rules = {
            custom = {
            },
            modifiers = {
            }
        },
        jokers = {
            {id = 'j_ceremonial', eternal = true},
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            cards = {{s='D',r='4',},{s='D',r='5',},{s='D',r='6',},{s='D',r='7',},{s='D',r='8',},{s='D',r='9',},{s='D',r='T',},{s='D',r='J',},{s='D',r='Q',},{s='D',r='K',},{s='D',r='J',},{s='D',r='Q',},{s='D',r='K',},{s='C',r='4',},{s='C',r='5',},{s='C',r='6',},{s='C',r='7',},{s='C',r='8',},{s='C',r='9',},{s='C',r='T',},{s='C',r='J',},{s='C',r='Q',},{s='C',r='K',},{s='C',r='J',},{s='C',r='Q',},{s='C',r='K',},{s='H',r='4',},{s='H',r='5',},{s='H',r='6',},{s='H',r='7',},{s='H',r='8',},{s='H',r='9',},{s='H',r='T',},{s='H',r='J',},{s='H',r='Q',},{s='H',r='K',},{s='H',r='J',},{s='H',r='Q',},{s='H',r='K',},{s='S',r='4',},{s='S',r='5',},{s='S',r='6',},{s='S',r='7',},{s='S',r='8',},{s='S',r='9',},{s='S',r='T',},{s='S',r='J',},{s='S',r='Q',},{s='S',r='K',},{s='S',r='J',},{s='S',r='Q',},{s='S',r='K',}},
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
            }
        }
    })


    -- add an example seal
    seal.registerSeal({
        mod_id = mod_id,
        id = "Green",
        label = "Green Seal",
        color = "green",
        description = { "Does nothing." },
        effect = function(context)
            logger:info("Green Seal effect")
        end,
        timing = "onDiscard"
    })

    -- Add an example menu (can also be added in on_game_load)
    G.UIDEF.example_mod_ui_definition = function()
        -- create a new UI box here
    end
end

local function on_disable()
    joker.remove("j_example_joker")
    consumable.remove("c_example_planet")
    challenge.remove("c_example_1")
end

local function menu()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu({ definition = G.UIDEF.example_mod_ui_definition() })
end

local function on_game_load(args)
    -- load config
    mod_config = balamod.mods[mod_id].load_config()

    -- Example code injection from https://github.com/HeyImKyu/balatro-gay
    -- You will need sometimes to "pre-patch" the game so use thi function instead of on_enable
    local patch = [[
                G.localization.misc.poker_hands['Straight Flush'] = "Gay Flush"
                G.localization.misc.poker_hands['Straight'] = "Gay"
                G.localization.misc.poker_hands['Royal Flush'] = "Royal Gay Flush"

                init_localization()
                ]]

    local toPatch = "init_localization()"

    logger:info("Gaying up the game")

    balalib.inject("game", "Game:set_language", toPatch, patch)
end

local function on_game_quit()
    if not mod_config then
        mod_config = {test = 0}
    end
    balamod.mods[mod_id].save_config(mod_config)
end

local function on_key_pressed(key) -- you can return true to prevent the game from handling the event
    -- will add 1$ every time the "m" key is pressed
    if key == "m" then
        ease_dollars(1, true)
    end
end

local function on_key_released(key) -- you can return true to prevent the game from handling the event
    -- will remove 1$ every time the "m" key is released
    if key == "m" then
        ease_dollars(-1, true)
    end
end

local function on_mouse_pressed(button, x, y, touch) -- you can return true to prevent the game from handling the event
    local buttons = {
       "left",
        "right",
        "middle",
    }

    local message = "Mouse button " .. buttons[button] .. " pressed at (" .. x .. ", " .. y .. ")"
    if touch then
        message = message .. " by touching screen or pad"
    else
        message = message .. " without touching screen or pad"
    end

    logger:info(message)
end

local function on_mouse_released(button, x, y)
    local buttons = {
        "left",
        "right",
        "middle",
    }

    logger:info("Mouse button " .. buttons[button] .. " released at (" .. x .. ", " .. y .. ")")
end

local function on_mousewheel(x, y)
    logger:info("Mouse wheel scrolled left/right by " .. x .. " and up/down by " .. y)
end

local function on_pre_render() -- you can return true to prevent the game from handling the event
    -- This event is called before the game start the rendering process of a frame
end

local function on_post_render()
    -- This event is called after the game finish the rendering process of a frame
end

local function on_error(message)
    logger:error("An error occurred: " .. message)
end

local function on_pre_update(dt) -- you can return true to prevent the game from handling the event
    -- This event is called before the game start running a game tick
    -- dt is the time in seconds since the last tick
end

local function on_post_update(dt)
    -- This event is called after the game finish running a game tick
    -- dt is the time in seconds since the last tick
end

return {
    on_enable = on_enable,
    on_disable = on_disable,
    menu = menu,
    on_game_load = on_game_load,
    on_game_quit = on_game_quit,
    on_key_pressed = on_key_pressed,
    on_key_released = on_key_released,
    on_mouse_pressed = on_mouse_pressed,
    on_mouse_released = on_mouse_released,
    on_mousewheel = on_mousewheel,
    on_pre_render = on_pre_render,
    on_post_render = on_post_render,
    on_error = on_error,
    on_pre_update = on_pre_update,
    on_post_update = on_post_update,
}