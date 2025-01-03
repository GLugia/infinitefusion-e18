class PokeBattle_Battler
  attr_accessor :ability
  attr_accessor :ability2

  #Primary ability utility methods for battlers class
  def ability
    return @ability
  end
  
  def ability=(value)
    return if value && !GameData::Ability.exists?(value)
    @ability = (value) ? GameData::Ability.get(value).id : value
  end

  def abilityName
    return "nil" if !@ability
    return GameData::Ability.get(@ability).name
  end

  #Secondary ability utility methods for battlers class
  def ability2
    return @ability2
  end

  def ability2=(value)
    return if value && !GameData::Ability.exists?(value)
    @ability2 = (value) ? GameData::Ability.get(value).id : value
  end

  def ability2Name
    return "nil" if !@ability
    return GameData::Ability.get(@ability).name
  end

  #Ability logic overrides

  def hasActiveAbility?(check_ability, ignore_fainted = false)
    return hasActiveAbilityDouble?(check_ability, ignore_fainted) if $game_switches[SWITCH_DOUBLE_ABILITIES]
    return false if !abilityActive?(ignore_fainted)
    return check_ability.include?(@ability) if check_ability.is_a?(Array)
    return @ability == check_ability
  end

  def hasActiveAbilityDouble?(check_ability, ignore_fainted = false)
    return false if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return false if !abilityActive?(ignore_fainted)
    if check_ability.is_a?(Array)
      return check_ability.include?(@ability) || check_ability.include?(@ability2)
    end
    return @ability == check_ability || @ability2 == check_ability
  end

  def triggerAbilityEffectsOnHit(move, user, target)
    # Target's ability
    if target.abilityActive?(true)
      oldHP = user.hp
      BattleHandlers.triggerTargetAbilityOnHit(target.ability, user, target, move, @battle)
      BattleHandlers.triggerTargetAbilityOnHit(target.ability2, user, target, move, @battle) if $game_switches[SWITCH_DOUBLE_ABILITIES] && target.ability2
      user.pbItemHPHealCheck if user.hp < oldHP
    end
    # User's ability
    if user.abilityActive?(true)
      BattleHandlers.triggerUserAbilityOnHit(user.ability, user, target, move, @battle)
      BattleHandlers.triggerUserAbilityOnHit(user.ability2, user, target, move, @battle) if $game_switches[SWITCH_DOUBLE_ABILITIES] && user.ability2
      user.pbItemHPHealCheck
    end
  end

  def pbCheckDamageAbsorption(user, target)
    # Substitute will take the damage
    if target.effects[PBEffects::Substitute] > 0 && !ignoresSubstitute?(user) &&
      (!user || user.index != target.index)
      target.damageState.substitute = true
      return
    end
    # Disguise will take the damage
    if !@battle.moldBreaker && target.isFusionOf(:MIMIKYU) &&
      target.form == 0 && (target.ability == :DISGUISE || target.ability2 == :DISGUISE)
      target.damageState.disguise = true
      return
    end
  end

  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn = false)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Trace
    if $game_switches[SWITCH_DOUBLE_ABILITIES] && onSwitchIn
      displayOpponentDoubleAbilities()
    else
      if hasActiveAbility?(:TRACE)
        # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
        #       in and not at any later times, even if a traceable ability turns
        #       up later. Essentials ignores this, and allows Trace to trigger
        #       whenever it can even in the old battle mechanics.
        choices = []
        @battle.eachOtherSideBattler(@index) do |b|
          next if b.ungainableAbility? ||
            [:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(b.ability)
          choices.push(b)
        end
        if choices.length > 0
          choice = choices[@battle.pbRandom(choices.length)]
          @battle.pbShowAbilitySplash(self)
          @ability = choice.ability
          @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), choice.abilityName))
          @battle.pbHideAbilitySplash(self)
          if !onSwitchIn && (unstoppableAbility? || abilityActive?)
            BattleHandlers.triggerAbilityOnSwitchIn(@ability, self, @battle)
          end
        end
      end
    end
  end

  def displayOpponentDoubleAbilities()
    @battle.eachOtherSideBattler(@index) do |battler|
      @battle.pbShowPrimaryAbilitySplash(battler,true)
      @battle.pbShowSecondaryAbilitySplash(battler,true) if battler.isFusion?()
       @battle.pbHideAbilitySplash(battler)
    end
  end

end




class Pokemon
  attr_writer :ability
  attr_writer :ability2

  #Primary ability utility methods for pokemon class
  def ability
    @ability = species_data.abilities[rand(species_data.abilities.length)] if !@ability
    return @ability
  end

  def ability
    return GameData::Ability.try_get(@ability)
  end

  def ability=(value)
    return if value && !GameData::Ability.exists?(value)
    @ability = (value) ? GameData::Ability.get(value).id : value
  end

  #Secondary ability utility methods for pokemon class
  def ability2
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    @ability2 = species_data.abilities[rand(species_data.abilities.length)] if !@ability2
    return @ability2
  end

  def ability2
    return nil if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return GameData::Ability.try_get(@ability2)
  end

  def ability2=(value)
    return if !$game_switches[SWITCH_DOUBLE_ABILITIES]
    return if value && !GameData::Ability.exists?(value)
    @ability2 = (value) ? GameData::Ability.get(value).id : value
  end

  def adjustHPForWonderGuard(stats)
    return @ability == :WONDERGUARD ? 1 : stats[:HP] || ($game_switches[SWITCH_DOUBLE_ABILITIES] && @ability2 == :WONDERGUARD)
  end

end


