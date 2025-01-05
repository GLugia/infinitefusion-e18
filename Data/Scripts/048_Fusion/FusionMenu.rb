class FusionSelectOptionsScene < PokemonOption_Scene
  attr_accessor :hasNickname
  
  def initialize(head, body)
    @abilityList = [GameData::Ability.get(head.ability), GameData::Ability.get(body.ability)]
    @abilityIndex = 0
    
    @natureList = [head.nature, body.nature]
    @natureIndex = 0
    
    @nicknameList = [head.name, body.name]
    @hasNickname = false
    @nicknameIndex = 0
    
    @selBaseColor = Color.new(48,96,216)
    @selShadowColor = Color.new(32,32,32)
    @show_frame=false

    @head = head
    @body = body
  end
  
  def initUIElements
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Select your Pokémon's ability and nature"),
      0, 0, Graphics.width, 64,
      @viewport
    )
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    @sprites["title"].opacity=0
  end
  
  def pbStartScene(inloadscreen = nil)
    super
    @sprites["option"].opacity=0
  end
  
  def shouldSelectNickname
    if @head.nicknamed? && @body.nicknamed?
      @hasNickname=true
      return true
    end
    if @head.nicknamed? && !@body.nicknamed?
      @hasNickname=true
      @nicknameIndex = 0
      return false
    end
    if !@head.nicknamed? && @body.nicknamed?
      @hasNickname=true
      @nicknameIndex = 1
      return false
    end
    @hasNickname=false
    return false
  end
  
  def selectedNickname
    return @nicknameList[@nicknameIndex]
  end
  
  def selectedAbility
    return @abilityList[@abilityIndex]
  end
  
  def getNatureDescription(nature)
    change = nature.stat_changes
    return "Neutral nature" if change.empty?
    positiveChange = change[0]
    negativeChange = change[1]
    return _INTL(
      "+ {1}\n- {2}",
      GameData::Stat.get(positiveChange[0]).name,
      GameData::Stat.get(negativeChange[0]).name
    )
  end
  
  def selectedNature
    return @natureList[@natureIndex]
  end
  
  def getDefaultDescription
    return _INTL("Confirm?")
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    if shouldSelectNickname
      nickname_option = EnumOption.new(
        _INTL("Nickname"),
        [_INTL(@head.name), _INTL(@body.name)],
        proc { @nicknameIndex },
        proc { |value|
          @nicknameIndex = value
        },
        "Select the Pokémon's nickname"
      )
      nickname_option.set(0)
      options << nickname_option
    end
    
    ability_option = EnumOption.new(
      _INTL("Ability"),
      [_INTL(@abilityList[0].real_name), _INTL(@abilityList[1].real_name)],
      proc { @abilityIndex },
      proc { |value|
        @abilityIndex = value
      },
      [@abilityList[0].real_description, @abilityList[1].real_description]
    )
    ability_option.set(0)
    options << ability_option
    
    nature_option = EnumOption.new(
      _INTL("Nature"),
      [_INTL(@natureList[0].real_name), _INTL(@natureList[1].real_name)],
      proc { @natureIndex },
      proc { |value|
        @natureIndex = value
      },
      [getNatureDescription(@natureList[0]), getNatureDescription(@natureList[1])]
    )
    nature_option.set(0)
    options << nature_option
    
    return options
  end
  
  def isConfirmedOnKeyPress
    return true
  end
end
