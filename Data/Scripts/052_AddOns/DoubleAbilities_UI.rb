class AbilitySplashDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar2 = addSprite(@sprites["ability2Bar_#{@side}"]) if @sprites["ability2Bar_#{@side}"]

    dir = (@side==0) ? -1 : 1
    bar.moveDelta(0,8,dir*Graphics.width/2,0)
    bar2.moveDelta(0,8,dir*Graphics.width/2,0) if bar2

    bar.setVisible(8,false)
    bar2.setVisible(8,false) if bar2
  end
end

class PokeBattle_Scene
  def pbShowAbilitySplash(battler,secondAbility=false, abilityName=nil)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    side = battler.index%2
    if secondAbility
      pbHideAbilitySplash(battler) if @sprites["ability2Bar_#{side}"].visible
    else
      pbHideAbilitySplash(battler) if @sprites["abilityBar_#{side}"].visible
    end
    if abilityName
      @sprites["abilityBar_#{side}"].ability_name = abilityName if !secondAbility
      @sprites["ability2Bar_#{side}"].ability_name = abilityName if secondAbility
    end


    @sprites["abilityBar_#{side}"].battler = battler
    @sprites["ability2Bar_#{side}"].battler = battler if @sprites["ability2Bar_#{side}"]

    abilitySplashAnim = AbilitySplashAppearAnimation.new(@sprites,@viewport,side,secondAbility)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end
end

class PokeBattle_Battle

  def pbShowSecondaryAbilitySplash(battler,delay=false,logTrigger=true)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler,true)
    if delay
      Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
    end
  end

  def pbShowPrimaryAbilitySplash(battler,delay=false,logTrigger=true)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    @scene.pbShowAbilitySplash(battler,false)
    if delay
      Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
    end
  end
end
