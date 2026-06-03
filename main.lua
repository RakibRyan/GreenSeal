--- STEAMODDED HEADER
--- MOD_NAME: Green Seal
--- MOD_ID: GreenSeal
--- PREFIX: grns
--- MOD_AUTHOR: [AxBolduc, mwithington, Ryan]
--- MOD_DESCRIPTION: Adds a Green Seal to the game

-- Register the sprite atlases
SMODS.Atlas({ key = "green_seal", path = "green_seal.png", px = 71, py = 95 })
SMODS.Atlas({ key = "c_ancillary", path = "c_ancillary.png", px = 71, py = 95 })

-- 1. The Green Seal
SMODS.Seal({
    key = 'green',
    atlas = 'green_seal',
    pos = { x = 0, y = 0 },
    badge_colour = G.C.GREEN,
    weight = 10, -- Natively handles standard pack injection logic
    loc_txt = {
        name = "Green Seal",
        text = {
            "Increases round hand size",
            "by 1 when {C:attention}discarded"
        }
    },
    calculate = function(self, card, context)
        -- Triggers when the card is discarded
        if context.discard then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.0,
                func = (function()
                    if not G.GAME.round_resets.temp_handsize then
                        G.GAME.round_resets.temp_handsize = 0
                    end

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.hand.config.real_card_limit = (G.hand.config.real_card_limit or G.hand.config.card_limit) + 1
                            G.hand.config.card_limit = math.max(0, G.hand.config.real_card_limit)
                            check_for_unlock({ type = 'min_hand_size' })
                            return true
                        end
                    }))
                    G.GAME.round_resets.temp_handsize = G.GAME.round_resets.temp_handsize + 1
                    return true
                end)
            }))
        end
    end
})

-- 2. The Spectral Card
SMODS.Consumable({
    set = 'Spectral',
    key = 'ancillary',
    atlas = 'c_ancillary',
    pos = { x = 0, y = 0 },
    cost = 4,
    config = { max_highlighted = 1 },
    loc_txt = {
        name = "Ancillary",
        text = {
            "Add a {C:green}Green Seal{}",
            "to {C:attention}1{} selected",
            "card in your hand"
        }
    },
    can_use = function(self, card)
        -- Ensures only exactly 1 card is highlighted before use
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local conv_card = G.hand.highlighted[1]
        
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                -- Apply the namespaced seal key
                conv_card:set_seal('grns_green', nil, true)
                return true
            end
        }))
    end
})

