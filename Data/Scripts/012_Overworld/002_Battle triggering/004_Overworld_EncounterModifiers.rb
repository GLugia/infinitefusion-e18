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
def __getBestEvolution(pokemon, species, possible_evolutions, filtered_evolutions, part, head)
  temp_evolutions = []
  if filtered_evolutions
    filtered_evolutions.each { |array|
      next if !array
      next if !array[1]
      next if species >= dexNum(array[1])
      temp_evolutions << array
    }
  else
    possible_evolutions.each { |array|
      next if !array
      next if !array[1]
      next if species >= dexNum(array[1])
      temp_evolutions << array
    }
  end
  return GameData::Species.get(species) if temp_evolutions.empty?
  additive_index = possible_evolutions.length - temp_evolutions.length
  result = nil
  # if multiple evolutions are possible from the current species
  if temp_evolutions.all? { |array| species == dexNum(array[0]) }
    result = temp_evolutions[rand(temp_evolutions.length)][1] if pokemon.level >= 15 * (additive_index + 1)
  # otherwise, select the next possible evolution
  else
    temp_evolutions.each_with_index { |array, i|
      case array[2]
      when :Level
        result = array[1] if pokemon.level >= array[3]
        break
      when :LevelMale
        result = array[1] if pokemon.level >= array[3] && pokemon.male? || (part && (head && pokemon.head_gender == 0) || (!head && pokemon.body_gender == 0))
        break
      when :LevelFemale
        result = array[1] if pokemon.level >= array[3] && pokemon.female? || (part && (head && pokemon.head_gender == 1) || (!head && pokemon.body_gender == 1))
        break
      when :AttackGreater
        result = array[1] if pokemon.level >= array[3] && pokemon.attack > pokemon.defense
        break
      when :AtkDefEqual
        result = array[1] if pokemon.level >= array[3] && pokemon.attack == pokemon.defense
        break
      when :DefenseGreater
        result = array[1] if pokemon.level >= array[3] && pokemon.attack < pokemon.defense
        break
      else
        result = array[1] if pokemon.level >= 15 * (additive_index + i + 1)
        break
      end
    }
  end
  # return species if no evolution is possible
  return GameData::Species.get(species) if !result
  # recursive to scan through all possible species
  return __getBestEvolution(pokemon, dexNum(result), possible_evolutions, temp_evolutions, part, head)
end

def __getEvolutionCustom(pokemon)
  species = dexNum(pokemon.species)
  if species >= Settings::NB_POKEMON
    body = getBasePokemonID(species)
    head = getBasePokemonID(species, false)

    bodyPossibleEvolutions = GameData::Species.get(body).get_family_evolutions(true)
    headPossibleEvolutions = GameData::Species.get(head).get_family_evolutions(true)

    bodyCanEvolve = !bodyPossibleEvolutions.empty?
    headCanEvolve = !headPossibleEvolutions.empty?
    evoBodySpecies = bodyCanEvolve ? __getBestEvolution(pokemon, body, bodyPossibleEvolutions, nil, true, false) : nil
    evoHeadSpecies = headCanEvolve ? __getBestEvolution(pokemon, head, headPossibleEvolutions, nil, true, true) : nil
    evoBody = evoBodySpecies ? getDexNumberForSpecies(evoBodySpecies) : nil
    evoHead = evoHeadSpecies ? getDexNumberForSpecies(evoHeadSpecies) : nil

    return species if evoBody == nil && evoHead == nil
    return body * Settings::NB_POKEMON + evoHead if evoBody == nil #only head evolves
    return evoBody * Settings::NB_POKEMON + head if evoHead == nil #only body evolves
    return evoBody * Settings::NB_POKEMON + evoHead   #both evolve
  else
    possible_evolutions = GameData::Species.get(species).get_family_evolutions(true)
    new_species = __getBestEvolution(pokemon, species, possible_evolutions, nil, false, false)
    return new_species ? dexNum(new_species) : species
  end
end

# def separateMoves(species_data)
  # physical_moves = []
  # species_moves = []
  # status_off_moves = []
  # status_def_moves = []
  # moves = species_data.moves
  
  
# end

# def getBestAttackingMove(moves)
  
# end

# def getBestStatusMove(moves, offensive = false)
  
# end

# def getBestMoves(species_data, moves, is_fusion_part = false)
  # return [] if !species_data || !moves || !moves.length
  
  # moves_to_learn = []
  
  # stat_values = []
  # stats = species_data.base_stats
  # bst = 0
  # stats.each { |s| bst += s }
  # stats.each { |s| stat_values[s.id] = s / bst }
  
  # physical = stat_values[:ATTACK] > stat_values[:SPECIAL_ATTACK] + 5
  # special  = stat_values[:SPECIAL_ATTACK] > stat_values[:ATTACK] + 5
  # mixed    = !physical && !special
  
  # bulky_stats = (stat_values[:HP] +
                # stat_values[:DEFENSE] +
                # stat_values[:SPECIAL_DEFENSE]) / 3
  # offensive_stats = (stat_values[:ATTACK] +
                    # stat_values[:SPECIAL_ATTACK] +
                    # stat_values[:SPEED]) / 3
  
  # tank  = offensive_stats < bulky_stats - 0.05
  # off   = offensive_stats > bulky_stats + 0.05
  # bulky = offensive_stats < bulky_stats + 0.05 &&
          # offensive_stats > bulky_stats - 0.05
  
  # phys_moves = moves[0]
  # spec_moves = moves[1]
  # stat_off_moves = moves[2]
  # stat_def_moves = moves[3]
  
  # # add damaging move
  # moves_to_learn << getBestAttackingMove(phys_moves) if physical
  # moves_to_learn << getBestAttackingMove(spec_moves) if special
  # moves_to_learn << getBestAttackingMove(phys_moves + spec_moves) if mixed
  
  # # add second attack and status if it isn't a part
  # if !is_fusion_part
    # moves_to_learn << getBestAttackingMove(phys_moves) if physical
    # moves_to_learn << getBestAttackingMove(spec_moves) if special
    # moves_to_learn << getBestAttackingMove(phys_moves + spec_moves) if mixed
  # end
  # if off
  # elsif tank
    # moves_to_learn << getBestAttackingMove
  
  # addStrongestMove(species_data, moves, learned_moves, num_to_add - 1) if num_to_add
  # return moves_to_learn
# end

# def selectBetterMoves(pokemon)
  # selected_moves = []
  # if pokemon.fused
    # body_id = getBasePokemonID(pokemon.species)
    # head_id = getBasePokemonID(pokemon.species, false)
    # body = GameData::Species.get(body_id)
    # head = GameData::Species.get(head_id)
    # body_moves = separateMoves(body)
    # head_moves = separateMoves(head)
    
    # selected_moves << *getBestMoves(body, body_moves, true)
    # selected_moves << *getBestMoves(head, head_moves, true)
  # else
    # moves = separateMoves(pokemon.species_data)
    # selected_moves << *getBestMoves(pokemon.species_data, moves)
  # end
  # return selected_moves
# end

def isGymBattle
  return $game_variables[VAR_CURRENT_GYM_TYPE] != -1 || $game_map.map_id == 191 # fighting dojo
end

def isRivalBattle(trainer)
  Settings::RIVAL_NAMES.each do |rival|
    return true if trainer.trainer_type == rival[0]
  end
  return false
end

Events.onTrainerPartyLoad += proc { |_sender, e|
  next if !Settings::SCALE_TRAINER_POKEMON_LEVELS
  next if !e[0]
  
  trainer = e[0]
  
  balanced_level = pbBalancedLevel($Trainer.party) - 7
  # decrease the level if the player has less than half of the available badges
  # increase it otherwise
  # TODO: $Trainer.badges.length is 8 until entering johto?
  balanced_level += $Trainer.badge_count - 8
  # the level is higher for more difficult trainers and further increased by difficulty
  balanced_level += (trainer.skill_level / PBTrainerAI.mediumSkill) * $Trainer.selected_difficulty
  # rival and both gym trainers are always 2 levels higher
  balanced_level += 2 if isGymBattle || isRivalBattle(trainer)
  # gym leaders are always 4 levels higher than the toughest trainers
  balanced_level += 4 if is_gym_leader(trainer) || trainer.name == "Koichi"
  # the level must be a whole integer
  balanced_level = balanced_level.round
  # decrease level based on trainer party size and pokemon index
  level_array = [
    [0],
    [1, 1],
    [2, 1, 0],
    [2, 1, 1, 0],
    [2, 2, 1, 1, 0],
    [2, 2, 2, 1, 1, 0]
  ]
  
  # now we iterate over each pokemon to calculate the levels
  for i in 0..trainer.party.length
    pokemon = trainer.party[i]
    next if !pokemon
    
    # set the level
    new_level = balanced_level
    # decrease using the previous array
    new_level -= level_array[trainer.party.length - 1][i]
    
    # case dependant modifiers
    # pokemon which are shiny and/or have pokerus are always stronger
    new_level += 2 if pokemon.pokerusStage > 0
    new_level += 1 if pokemon.shiny?
    # pokemon which have hidden abilities, are fused, or have held items are weaker
    # this is to reduce the level of power they have over the player
    new_level -= 1 if pokemon.hasHiddenAbility?
    new_level -= 1 if pokemon.fused
    new_level -= 1 if pokemon.hasItem?
    
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level).round
    # ensure the pokemon are never a lower level than they are expected to Be
    # this is so the player cannot go anywhere they please
    # as cool as it is in concept, it makes the game easier than this is intended
    if new_level > pokemon.level
      pokemon.level = new_level
    end
    
    # check if the pokemon should be evolved
    new_species = __getEvolutionCustom(pokemon)
    if new_species != pokemon.species
      # ensure the ability is legal, then get the ability the evolution should have
      pokemon.validate_ability
      ability = pbGetAbilityForEvolution(dexNum(pokemon.species), new_species, pokemon.ability)
      
      # "evolve" the pokemon
      pokemon.species = new_species
      
      # set the ability to what it should be and verify it can have it
      pokemon.ability = ability
      pokemon.validate_ability
      
      # calculate the stats of the new species
      pokemon.calc_stats
      
      # we don't reset the moves of pokemon because each pokemon's moveset
      # was personally created by the devs. there is a way to make it work,
      # however; scanning through all the pokemon can learn to separate them
      # into four different arrays, physical, special, status_defensive, and
      # status defensive.
      # ie if the pokemon is a level 34 venusaur, it's best movepool would be
      # [:PETALDANCE, :LEECHSEED, :POISONPOWDER, :TAKEDOWN]
      # since the special attack is the highest stat and petal dance is the
      # strongest move it can learn. it's also fairly bulky with high spatk
      # so leech seed and poison powder would be selected. take down is there
      # as a means to avoid a second grass move while meeting the requirement
      # of "at least 2 attacks which deal direct damage".
      # ie2 if the pokemon is a level 34 musaur (muk/venusaur), it would be
      # [:SEEDBOMB, :SLUDGEBOMB, :MINIMIZE, :LEECHSEED]
      # if a pokemon can learn an evasion move such as double team or
      # minimize, and is fairly bulky compared to other stats, one of these
      # moves will be selected. 
      # anywhere from 2-4 moves which deal direct damage are preferred with a
      # strong lean toward specific status moves which reduce damage taken
      # to some degree (if the pokemon is bulky), or increase damage dealt
      # to some degree (if the pokemon is offensive).
      # pokemon.reset_moves
    end
  end
}


#NECROZMA BATTLE
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_4] && pokemon.species == :NECROZMA
    pokemon.item = :NECROZIUM
  end
}
