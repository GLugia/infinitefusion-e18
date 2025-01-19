################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
    pokemon.debug_shiny=true
  end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
# Events.onWildPokemonCreate += proc { |_sender, e|
  # next if !Settings::SCALE_WILD_POKEMON_LEVELS
  # pokemon = e[0]
  # if $game_map.map_id == 0
    # new_level = pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
    # new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    # pokemon.level = new_level
    # pokemon.calc_stats
    # pokemon.reset_moves
  # end
# }


#NECROZMA BATTLE
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_4] && pokemon.species == :NECROZMA
    pokemon.item = :NECROZIUM
  end
}
