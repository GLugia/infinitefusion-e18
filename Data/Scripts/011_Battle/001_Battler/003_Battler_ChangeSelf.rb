class PokeBattle_Battler
  #=============================================================================
  # Change HP
  #=============================================================================
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true)
    amt = amt.round
    amt = @hp if amt>@hp
    amt = 1 if amt<1 && !fainted?
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    @tookDamage = true if amt>0 && registerDamage
    return amt
  end

  def pbRecoverHP(amt,anim=true,anyAnim=true)
    amt = amt.round
    amt = @totalhp-@hp if amt>@totalhp-@hp
    amt = 1 if amt<1 && @hp<@totalhp
    oldHP = @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    return amt
  end

  def pbRecoverHPFromDrain(amt,target,msg=nil)
    if target.hasActiveAbility?(:LIQUIDOOZE, true)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!",target.pbThis) if nil_or_empty?(msg)
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt*1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt)
      end
    end
  end
  
  # Gets an array of opposing battlers
  # Returns: [[Pokemon, Owner, PartyIndex], ...]
  def pbGetBattlersOpposingFainted
    return [] if !self.fainted?
    party = @battle.pbOpposingParty(self.index)
    opposing_pokemon = []
    @battle.eachOtherSideBattler(self.index) do |battler|
      party_index = -1
      party.each_with_index do |pokemon, i|
        next if pokemon != battler.pokemon
        party_index = i
        break
      end
      owner = nil
      owner = @battle.pbGetOwnerFromBattlerIndex(battler.index) if @battle.opponent != nil # wild battle
      # raise _INTL("Failed to find index of #{@pokemon.to_s}") if index == -1
      opposing_pokemon << [battler, owner, party_index]
    end
    return opposing_pokemon
  end

  def pbFaint(showMessage=true)
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
    updateSpirits()
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    
    # proc events depending on which side's pokemon fainted
    if @battle.trainerBattle?
      # player pokemon fainted
      if self.pbOwnedByPlayer?
        battler_info = pbGetBattlersOpposingFainted
        match_histories = []
        battler_info.each do |info|
          match_histories.push(pbGetMatchHistory(info[1]))
        end
        Events.onPlayerPokemonFainted.trigger(self, @battle, match_histories, battler_info, @pokemon)
      # trainer pokemon fainted
      else
        battler_info = pbGetBattlersOpposingFainted
        Events.onTrainerPokemonFainted.trigger(self, @battle, battler_info, @pokemon)
      end
    # wild pokemon fainted
    else
      if !self.pbOwnedByPlayer?
        battler_info = pbGetBattlersOpposingFainted
        Events.onWildPokemonFainted.trigger(self, @battle, battler_info, @pokemon)
      end
    # We intentionally do not handle the player's Pokemon fainting in a wild
    # battle. Wild Pokemon cannot gain exp how the player and trainer Pokemon
    # can.
    end
    
    @battle.scene.pbFaintBattler(self)
    pbInitEffects(false)
    # Reset status
    self.status      = :NONE
    self.status_count = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = false
      @battle.eachOtherSideBattler(@index) do |b|
        badLoss = true if b.level>=self.level+30
      end
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  def updateSpirits()
    if $PokemonBag.pbQuantity(:ODDKEYSTONE)>=1 && @pokemon.hasType?(:GHOST)
      nbSpirits = pbGet(VAR_ODDKEYSTONE_NB)
      if nbSpirits < 108
        pbSet(VAR_ODDKEYSTONE_NB, nbSpirits+1)
      end
    end
  end

  #=============================================================================
  # Move PP
  #=============================================================================
  def pbSetPP(move,pp)
    move.pp = pp
    # No need to care about @effects[PBEffects::Mimic], since Mimic can't copy
    # Mimic
    if move.realMove && move.id==move.realMove.id && !@effects[PBEffects::Transform]
      move.realMove.pp = pp
    end
  end

  def pbReducePP(move)
    return true if usingMultiTurnAttack?
    return true if move.pp<0          # Don't reduce PP for special calls of moves
    return true if move.total_pp<=0   # Infinite PP, can always be used
    return false if move.pp==0        # Ran out of PP, couldn't reduce
    pbSetPP(move,move.pp-1) if move.pp>0
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

  #=============================================================================
  # Change type
  #=============================================================================
  def pbChangeTypes(newType)
    if newType.is_a?(PokeBattle_Battler)
      newTypes = newType.pbTypes
      newTypes.push(:NORMAL) if newTypes.length == 0
      newType3 = newType.effects[PBEffects::Type3]
      newType3 = nil if newTypes.include?(newType3)
      @type1 = newTypes[0]
      @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
      @effects[PBEffects::Type3] = newType3
    else
      newType = GameData::Type.get(newType).id
      @type1 = newType
      @type2 = newType
      @effects[PBEffects::Type3] = nil
    end
    @effects[PBEffects::BurnUp] = false
    @effects[PBEffects::Roost]  = false
  end

  #=============================================================================
  # Forms
  #=============================================================================
  def pbChangeForm(newForm, msg)
    return if fainted? || @effects[PBEffects::Transform] || @form == newForm
    oldForm = @form
    oldDmg = @totalhp-@hp
    self.form = newForm
    pbUpdate(true)
    @hp = @totalhp-oldDmg
    @effects[PBEffects::WeightChange] = 0 if Settings::MECHANICS_GENERATION >= 6
    @battle.scene.pbChangePokemon(self,@pokemon)
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(msg) if msg && msg!=""
    PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
    @battle.pbSetSeen(self)
  end

  def pbCheckFormOnStatusChange
    return if fainted? || @effects[PBEffects::Transform]
    # Shaymin - reverts if frozen
    if isSpecies?(:SHAYMIN) && frozen?
      pbChangeForm(0,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnMovesetChange
    return if fainted? || @effects[PBEffects::Transform]
    # Keldeo - knowing Secret Sword
    if isSpecies?(:KELDEO)
      newForm = 0
      newForm = 1 if pbHasMove?(:SECRETSWORD)
      pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
    if isSpecies?(:CASTFORM)
      if hasActiveAbility?(:FORECAST)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun   then newForm = 1
        when :Rain, :HeavyRain then newForm = 2
        when :Hail             then newForm = 3
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        newForm = 1 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end

  # Checks the Pokémon's form and updates it if necessary. Used for when a
  # Pokémon enters battle (endOfRound=false) and at the end of each round
  # (endOfRound=true).
  def pbCheckForm(endOfRound=false)
    return if fainted? || @effects[PBEffects::Transform]
    # Form changes upon entering battle and when the weather changes
    pbCheckFormOnWeatherChange if !endOfRound
    # Darmanitan - Zen Mode
    if isSpecies?(:DARMANITAN) && self.ability == :ZENMODE
      if @hp<=@totalhp/2
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} triggered!",abilityName))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} triggered!",abilityName))
      end
    end
    # Minior - Shields Down
    if isSpecies?(:MINIOR) && self.ability == :SHIELDSDOWN
      if @hp>@totalhp/2   # Turn into Meteor form
        newForm = (@form>=7) ? @form-7 : @form
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} deactivated!",abilityName))
        elsif !endOfRound
          @battle.pbDisplay(_INTL("{1} deactivated!",abilityName))
        end
      elsif @form<7   # Turn into Core form
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(@form+7,_INTL("{1} activated!",abilityName))
      end
    end
    # Wishiwashi - Schooling
    if isSpecies?(:WISHIWASHI) && self.ability == :SCHOOLING
      if @level>=20 && @hp>@totalhp/4
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} formed a school!",pbThis))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} stopped schooling!",pbThis))
      end
    end
    # Zygarde - Power Construct
    if isSpecies?(:ZYGARDE) && self.ability == :POWERCONSTRUCT && endOfRound
      if @hp<=@totalhp/2 && @form<2   # Turn into Complete Forme
        newForm = @form+2
        @battle.pbDisplay(_INTL("You sense the presence of many!"))
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(newForm,_INTL("{1} transformed into its Complete Forme!",pbThis))
      end
    end
  end

  def pbTransform(target)
    if target.is_a?(Integer)
      @battle.pbDisplay(_INTL("But it failed..."))
      return
    end
    oldAbil = @ability
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    pbChangeTypes(target)
    self.ability  = target.ability
    @attack  = target.attack
    @defense = target.defense
    @spatk   = target.spatk
    @spdef   = target.spdef
    @speed   = target.speed
    GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m,i|
      @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
      @moves[i].pp       = 5
      @moves[i].total_pp = 5
    end
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = nil
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,target.pbThis(true)))
    pbOnAbilityChanged(oldAbil)
  end

  def pbHyperMode; end
end
