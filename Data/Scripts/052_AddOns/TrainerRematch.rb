# This cannot be renamed without opening this project in RPG Maker XP
#
# This class tracks the Trainer's Pokemon as well as the results of
# each battle vs the Player. Once a Trainer's Pokemon has been
# generated, it will be appended to [party] so that these Pokemon
# will always be the same, regardless of conditions. Previously,
# Trainer Pokemon would constantly have different stats, abilities,
# levels, or even moves. This caused annoyances with some rebattles
# where certain abilities or moves would limit the Player or even
# make fights impossible under rare conditions.
class RematchTrainer
  attr_reader :symbol
  attr_accessor :party
  attr_accessor :participants
  attr_accessor :win_count
  attr_accessor :loss_count
  attr_accessor :draw_count

  def initialize(tr_symbol, tr_party)
    @symbol = tr_symbol
    @party = []
    # create a new instance and copy the data
    # this is so the pokemon in the trainer's party isn't directly
    # modified when modifying this array. there is an entire event
    # dedicated to modifying a trainer's party after it's loaded.
    tr_party.each { |pokemon|
      temp = Pokemon.new(1, 1)
      temp.copy(pokemon)
      @party.push(temp)
    }
    @participants = []
    @win_count = 0
    @loss_count = 0
    @draw_count = 0
  end
  
  def getBattleCount
    return @win_count + @loss_count + @draw_count
  end
  
  def getWinRatio
    return @win_count.to_f / self.getBattleCount
  end
  
  def getLossRatio
    return @loss_count.to_f / self.getBattleCount
  end
  
  def getDrawRatio
    return @draw_count.to_f / self.getBattleCount
  end
end

# This public function returns what is used as the key to
# $PokemonGlobal.match_history
def pbGetTrainerSymbol(trainer)
  return nil if !trainer
  return "#{trainer.trainer_type.to_s} #{trainer.name}".to_sym
end

# This public function returns the match history for the specified
# Trainer, creating one beforehand should it not exist.
def pbGetMatchHistory(trainer)
  tr_sym = pbGetTrainerSymbol(trainer)
  return nil if !tr_sym || tr_sym.nil?
  if !$PokemonGlobal.match_history.has_key?(tr_sym)
    match_history = RematchTrainer.new(tr_sym, trainer.party)
    $PokemonGlobal.match_history.store(tr_sym, match_history)
  end
  return $PokemonGlobal.match_history.fetch(tr_sym)
end

# Filters the evolutions available to select the latest one
# possible, if any.
def selectValidEvolution(pokemon, species, possible_evolutions, filtered_evolutions, part, head)
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
  return selectValidEvolution(pokemon, dexNum(result), possible_evolutions, temp_evolutions, part, head)
end

# This allows for the new Trainer system to force evolve Pokemon
# which were previously unevolved despite surpassing prerequesites
def getEvolution(pokemon)
  species = dexNum(pokemon.species)
  if species >= Settings::NB_POKEMON
    body = getBasePokemonID(species)
    head = getBasePokemonID(species, false)

    bodyPossibleEvolutions = GameData::Species.get(body).get_family_evolutions(true)
    headPossibleEvolutions = GameData::Species.get(head).get_family_evolutions(true)

    bodyCanEvolve = !bodyPossibleEvolutions.empty?
    headCanEvolve = !headPossibleEvolutions.empty?
    evoBodySpecies = bodyCanEvolve ? selectValidEvolution(pokemon, body, bodyPossibleEvolutions, nil, true, false) : nil
    evoHeadSpecies = headCanEvolve ? selectValidEvolution(pokemon, head, headPossibleEvolutions, nil, true, true) : nil
    evoBody = evoBodySpecies ? getDexNumberForSpecies(evoBodySpecies) : nil
    evoHead = evoHeadSpecies ? getDexNumberForSpecies(evoHeadSpecies) : nil

    return species if evoBody == nil && evoHead == nil
    return body * Settings::NB_POKEMON + evoHead if evoBody == nil #only head evolves
    return evoBody * Settings::NB_POKEMON + head if evoHead == nil #only body evolves
    return evoBody * Settings::NB_POKEMON + evoHead   #both evolve
  else
    possible_evolutions = GameData::Species.get(species).get_family_evolutions(true)
    new_species = selectValidEvolution(pokemon, species, possible_evolutions, nil, false, false)
    return new_species ? dexNum(new_species) : species
  end
end

def normalizeStats(pokemon)
  stat_values = []
  stats = pokemon.species_data.base_stats
  bst = 0
  stats.each { |s| bst += s }
  stats.each { |s| stat_values.push(s / bst) }
  return stat_values
end

def isPhysical?(stat_values)
  return stat_values[:ATTACK] > stat_values[:SPECIAL_ATTACK] + 0.02
end

def isSpecial?(stat_values)
  return stat_values[:SPECIAL_ATTACK] > stat_values[:ATTACK] + 0.02
end

def isMixed?(stat_values)
  return stat_values[:ATTACK] <= stat_values[:SPECIAL_ATTACK] + 0.02 && stat_values[:SPECIAL_ATTACK] <= stat_values[:ATTACK] + 0.02
end

def averageOffenses(stat_values)
  return (stat_values[:ATTACK] +
          stat_values[:SPECIAL_ATTACK] +
          stat_values[:SPEED]) / 3
end

def averageDefenses(stat_values)
  return (stat_values[:HP] +
          stat_values[:DEFENSE] +
          stat_values[:SPECIAL_DEFENSE]) / 3
end

def isProtect?(move)
  return [:BANEFULBUNKER, :BURNINGBULWARK, :CRAFTYSHIELD, :DETECT,
          :KINGSSHIELD, :MATBLOCK, :OBSTRUCT, :PROTECT, :QUICKGUARD,
          :SILKTRAP, :SPIKYSHIELD, :WIDEGUARD
          ].include(move.id)
end

def changesWeather?(move)
  return [:HAIL, :RAINDANCE, :SANDSTORM, :SNOWSTORM, :SUNNYDAY
          ].include(move.id)
end

def appliesStatus?(move)
  return [:BANEFULBUNKER, :BEAKBLAST, :BURNINGBULWARK,
          :GLARE, :POISONGAS, :POISONPOWDER, :PSYCHOSHIFT,
          :SLEEPPOWDER, :STUNSPORE, :SPORE, :THUNDERWAVE, :TOXIC,
          :TOXICSPIKES, :TOXICTHREAD, :WILLOWISP
          ].include?(move.id)
end

def healsSelf?(move)
          # heal over time
  return [:AQUARING, :FLORALHEALING, :GRASSYTERRAIN, :HEALPULSE,
          :HEALINGWISH, :INGRAIN, :JUNGLEHEALING, :LEECHSEED,
          :LIFEDEW, :LUNARDANCE, :PAINSPLIT, :POLLENPUFF,
          :REVIVALBLESSING, :WISH,
          # instant self heal
          :HEALORDER, :LUNARBLESSING, :MILKDRINK, :MOONLIGHT,
          :MORNINGSUN, :PURIFY, :RECOVER, :REST, :ROOST, :SHOREUP,
          :SLACKOFF, :SOFTBOILED, :STRENGTHSAP, :SYNTHESIS
          ].include?(move.id)
end

def statBoostingOffense?(move)
  return [# :ATTACK
          :DRAGONDANCE, :HONECLAWS, :HOWL, :MEDITATE, :NORETREAT,
          :SHARPEN, :SHIFTGEAR, :TIDYUP, :VICTORYDANCE,
          :SWORDSDANCE,
          :BELLYDRUM,
          # there are cases where this may reduce the opponents defenses
          :GUARDSPLIT,
          # :SPECIAL_ATTACK
          :FLATTER, :QUIVERDANCE,
          :GEOMANCY, :NASTYPLOT,
          :TAILGLOW,
          # BOTH
          :GROWTH, :WORKUP,
          # :SPEED
          :AGILITY, :AUTOTOMIZE, :ROCKPOLISH, :TAILWIND,
          # ALL
          :FILLETAWAY, :SHELLSMASH,
          # targets opponent
          :FLATTER, :SPICYEXTRACT, :SWAGGER,
          # can target ally
          :COACHING, :DECORATE, :GEARUP
          ].include?(move.id)
end

def statBoostingBulky?(move)
  return [
          ### ATTACKING MOVES ###
          
          
          ### STATUS MOVES ###
          
          # :ATTACK
          :BULKUP, :COIL, :CURSE,
          # :SPECIAL_ATTACK
          :CALMMIND,
          ].include?(move.id)
end

def classifyMoves(pokemon)
  moves = []
  physical = []
  special = []
  status_off = []
  status_bul = []
  stats_def = []
  
  # get all moves
  if pokemon.fused?
    body = GameData::Species.get(pokemon.body_id)
    head = GameData::Species.get(pokemon.head_id)
    
    body.moves.each do |move|
      next if move[0] > pokemon.level
      moves.push(Pokemon::Move.new(move[1]))
    end
    head.moves.each do |move|
      next if move[0] > pokemon.level
      moves.push(Pokemon::Move.new(move[1]))
    end
  else
    pokemon.species_data.moves.each do |move|
      next if move[0] > pokemon.level
      moves.push(Pokemon::Move.new(move[1]))
    end
  end
  
  moves.each do |move|
    physical.push(move) if move.category == 0
    special.push(move) if move.category == 1
    # status
    if appliesStatus?(move) || statBoostingOffense?(move)
      status_off.push(move)
    end
    if healsSelf?(move) || statBoostingDefense?(move) || isProtect?(move)
      status_def.push(move)
    end
  end
  
  physical.sort { |a, b| a.base_damage <=> b.base_damage }
  special.sort { |a, b| a.base_damage <=> b.base_damage }
  status_off.sort { |a, b| a.accuracy <=> b.accuracy }
  
  return [physical, special, status_off, status_def]
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

# Modifies the Trainer's party to equalize the difference in levels
# compared to the Player using the new Rematch system
Events.onTrainerPartyLoad += proc { |_sender, e|
  next if !Settings::SCALE_TRAINER_POKEMON_LEVELS
  next if !e || !e[0]
  
  trainer = e[0]
  match_history = e[1]
  # load the pokemon that were stored
  trainer.party.each_with_index do |pokemon, index|
    pokemon.copy(match_history.party[index])
    pokemon.heal
  end
  
  balanced_level = pbBalancedLevel($Trainer.party) - 7
  # increase the level based on how many times the trainer has been
  # defeated
  balanced_level += calculateRematchLevel(trainer)
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
      pokemon.calc_stats
    end
    
    # check if the pokemon should be evolved
    new_species = getEvolution(pokemon)
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
  
  # store the new pokemon
  match_history.party.clear
  trainer.party.each do |pokemon|
    temp = Pokemon.new(1, 1)
    temp.copy(pokemon)
    match_history.party.push(temp)
  end
}

# This implements the redesigned Rematch system and allows for
# tracking the results of each battle vs any Trainer.
Events.onTrainerBattleEnd += proc { |_sender, e|
  next if !e || e.length < 6 || !e[2]
  match_histories = e[1]
  opponents = e[2]
  decision = e[6]
  
  opponents.each_with_index do |trainer, index|
    case decision
    when 1
      match_histories[index].win_count += 1
    when 2
      match_histories[index].loss_count += 1
    when 5
      match_histories[index].draw_count += 1
    end
  end
}

def calcExp(trainer, pokemon, target, num_participants, is_trainer_battle)
  base_exp = GameData::Species.get(target.species).base_exp
  exp = (base_exp * target.level) / 5.0
  exp *= 1 / num_participants
  exp *= (((2.0 * target.level) + 10.0) / (target.level + pokemon.level + 10.0) ** 2.5) + 1.0
  exp *= 1.7 if trainer && pokemon.owner && trainer.id != pokemon.owner.id
  exp *= 1.5 if is_trainer_battle
  return exp
end

def giveExp(battle, trainer, match_history, battler, party_index, exp)
  growth_rate = GameData::GrowthRate.get(battler.pokemon.species_data.growth_rate)
  exp_final = growth_rate.add_exp(battler.pokemon.exp, exp)
  exp_gained = exp_final - battler.pokemon.exp
  return if exp_gained <= 0
  
  battle.pbDisplayBrief(_INTL("#{trainer.name}'s #{battler.pokemon.name} gained #{exp_gained.to_s} Exp. Points!"))
  current_level = battler.level
  new_level = growth_rate.level_from_exp(exp_final)
  
  temp_exp = battler.pokemon.exp
  
  # loop over all levels gained
  loop do
    level_min_exp = growth_rate.minimum_exp_for_level(current_level)
    level_max_exp = growth_rate.minimum_exp_for_level(current_level + 1)
    temp_exp2 = level_max_exp < exp_final ? level_max_exp : exp_final
    match_history.party[party_index].exp = temp_exp2
    battler.pokemon.exp = temp_exp2
    
    battle.scene.pbEXPBar(battler, level_min_exp, level_max_exp, temp_exp, temp_exp2)
    
    temp_exp = temp_exp2
    current_level += 1
    if current_level > new_level
      battler.pokemon.calc_stats
      battler.pbUpdate(false)
      battle.scene.pbRefreshOne(battler.index)
      break
    end
    
    battle.pbCommonAnimation("LevelUp", battler)
    battler.pokemon.changeHappiness("levelup")
    battler.pokemon.calc_stats
    battler.pbUpdate(false)
    battle.scene.pbRefreshOne(battler.index)
    battle.pbDisplayPaused(_INTL("#{trainer.name}'s #{battler.pokemon.name} grew to Lv. #{battler.level}!"))
  end
end

# This keeps track of Trainer Pokemon that are switched out
Events.onTrainerSwitchPokemon += proc { |_sender, e|
  next if !e || e.length < 4
  battle = e[0]
  match_history = e[1]
  trainer = e[2]
  battler = e[3] # [Battler, Trainer, PartyIndex]
  
  match_history.participants.push(battler)
}

# The newly designed Rematch system allows for Trainer Pokemon to
# gain experience during the battle just as the Player's Pokemon
# would. The value of the experience gained scales with the
# difference between levels of the fainted Pokemon and the victor.
# This experience is then split between the number of participants
# should the Trainer ever decide to switch Pokemon.
Events.onPlayerPokemonFainted += proc { |_sender, e|
  next if !e || e.length < 3 || !e[0].opponent
  battle = e[0]
  match_histories = e[1]
  trainer_side_battlers = e[2] # [[Battler, Trainer, PartyIndex], ...]
  fainted_pokemon = e[3]
  trainers = battle.opponent
  
  # append participants
  trainers.each_with_index do |trainer, index|
    trainer_side_battlers.push(*match_histories[index].participants)
  end
  
  # apply exp for each pokemon
  trainer_side_battlers.each do |info|
    next if !info || !info.is_a?(Array) || info.length < 3 || info[0].fainted?
    battler = info[0]
    trainer = info[1]
    party_index = info[2]
    
    next if battler.level >=
      pbBalancedLevel($Trainer.party) + ($Trainer.badge_count / 2)
    
    history_index = trainers.index(trainer)
    match_history = match_histories[history_index]
    pokemon = trainer.party[party_index]
    exp = calcExp(trainer, pokemon, fainted_pokemon, trainer_side_battlers.length, true)
    exp *= fainted_pokemon.level.to_f / battler.level.to_f
    giveExp(battle, trainer, match_history, battler, party_index, exp.round)
  end
  
  # clear participants
  match_histories.each do |match_history|
    match_history.participants.clear
  end
}

