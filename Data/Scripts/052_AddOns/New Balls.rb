###################
## NEW POKEBALLS  #
###################

#GENDER BALL (24) - swap gender
#catch rate: pokeball unless genderless
BallHandlers::ModifyCatchRate.add(:GENDERBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate = -1 if pokemon.gender == 2
  next catchRate
})
BallHandlers::OnCatch.add(:GENDERBALL, proc{|ball, battle, pokemon|
  if pokemon.gender == 0
    pokemon.makeFemale
  elsif  pokemon.gender == 1
    pokemon.makeMale
  end
})

#BOOST BALL 25 - treat pokemon as traded
#catch rate: 80% pokeball
BallHandlers::ModifyCatchRate.add(:TRADEBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate*0.8).floor(1)
  next catchRate
})
BallHandlers::OnCatch.add(:TRADEBALL, proc{|ball, battle, pokemon|
  pokemon.obtain_method = 2
})

#ABILITY BALL 26 - set ability to hidden
#catch rate: 80% pokeball
BallHandlers::ModifyCatchRate.add(:ABILITYBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 0.8).floor(1)
  next catchRate
})
BallHandlers::OnCatch.add(:ABILITYBALL,proc{|ball,battle,pokemon|
  species = getSpecies(dexNum(pokemon))
  ability = species.hidden_abilities[-1]
  pokemon.ability_index = GameData::Ability.try_get(ability).id
})

#VIRUS BALL 27  - give pokerus
#catch rate: 50% pokeball
BallHandlers::ModifyCatchRate.add(:VIRUSBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 0.5).floor(1)
  next catchRate
})
BallHandlers::OnCatch.add(:VIRUSBALL, proc{|ball, battle, pokemon|
  pokemon.givePokerus
})

#SHINY BALL 28  - set shiny
#catchrate: 35% pokeball
BallHandlers::ModifyCatchRate.add(:SHINYBALL,proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 0.35).floor(1)
  next catchRate
})
BallHandlers::OnCatch.add(:SHINYBALL,proc{|ball, battle, pokemon|
  pokemon.glitter=true
})

#PERFECTBALL 29  - set 2-6 IVs to perfect
#catch rate: 15% pokeball (1/7th rounded up)
BallHandlers::ModifyCatchRate.add(:PERFECTBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 0.15).floor(1)
  next catchRate
})
BallHandlers::OnCatch.add(:PERFECTBALL, proc{|ball, battle, pokemon|
  stats = [:ATTACK, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED, :DEFENSE, :HP]
  set_stats = []
  stat_count = rand(stats.length - 2) + 2
  stat_id = nil
  until stat_count == 0 do
    stat_id = rand(stats.length)
    until !set_stats.include?(stat_id) do
      stat_id = rand(stats.length)
    end
    set_stats.append(stat_id)
    pokemon.iv[stats[stat_id]] = 31
    stat_count = stat_count - 1
  end
  pokemon.calc_stats
})

#DREAMBALL  - sleep
BallHandlers::ModifyCatchRate.add(:DREAMBALL, proc{|ball, catchRate, battle, pokemon|
  pokemon.status = :SLEEP
  next catchRate
})

#TOXICBALL  - poison
BallHandlers::ModifyCatchRate.add(:TOXICBALL, proc{|ball, catchRate, battle, pokemon|
  pokemon.status = :POISON
  next catchRate
})

#SCORCHBALL - burn
BallHandlers::ModifyCatchRate.add(:SCORCHBALL, proc{|ball, catchRate, battle, pokemon|
  pokemon.status = :BURN
  next catchRate
})

#FROSTBALL - freeze
BallHandlers::ModifyCatchRate.add(:FROSTBALL, proc{|ball, catchRate, battle, pokemon|
  pokemon.status = :FROZEN
  next catchRate
})

#SPARKBALL  - paralyze
BallHandlers::ModifyCatchRate.add(:SPARKBALL, proc{|ball, catchRate, battle, pokemon|
  pokemon.status = :PARALYSIS
  next catchRate
})

#PUREBALL  - better catch rate with no status
BallHandlers::ModifyCatchRate.add(:PUREBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 3.5).floor if pokemon.status == 0
  next catchRate
})

#STATUSBALL - better catch rate with any status
BallHandlers::ModifyCatchRate.add(:STATUSBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 2.5).floor if pokemon.status != 0
  next catchRate
})

#FUSIONBALL - better catch rate for fusions
BallHandlers::ModifyCatchRate.add(:FUSIONBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate *= 3 if GameData::Species.get(pokemon.species).id_number > Settings::NB_POKEMON
  next catchRate
})

#CANDY BALL  - +5 levels
#catchrate: 80% pokeball
BallHandlers::ModifyCatchRate.add(:CANDYBALL, proc{|ball, catchRate, battle, pokemon|
  catchRate=(catchRate * 0.8).floor
  next catchRate
})
BallHandlers::OnCatch.add(:CANDYBALL, proc{|ball, battle, pokemon|
  pokemon.level = pokemon.level + 5
})

#FIRECRACKER  - TODO
BallHandlers::ModifyCatchRate.add(:FIRECRACKER, proc{|ball, catchRate, battle, pokemon|
  pokemon.hp -= 10
  next 0
})
