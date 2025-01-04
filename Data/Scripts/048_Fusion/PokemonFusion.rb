class PBFusion
  Unknown = 0 # Do not use
  Happiness = 1
  HappinessDay = 2
  HappinessNight = 3
  Level = 4
  Trade = 5
  TradeItem = 6
  Item = 7
  AttackGreater = 8
  AtkDefEqual = 9
  DefenseGreater = 10
  Silcoon = 11
  Cascoon = 12
  Ninjask = 13
  Shedinja = 14
  Beauty = 15
  ItemMale = 16
  ItemFemale = 17
  DayHoldItem = 18
  NightHoldItem = 19
  HasMove = 20
  HasInParty = 21
  LevelMale = 22
  LevelFemale = 23
  Location = 24
  TradeSpecies = 25
  Custom1 = 26
  Custom2 = 27
  Custom3 = 28
  Custom4 = 29
  Custom5 = 30
  Custom6 = 31
  Custom7 = 32

  EVONAMES = ["Unknown",
              "Happiness", "HappinessDay", "HappinessNight", "Level", "Trade",
              "TradeItem", "Item", "AttackGreater", "AtkDefEqual", "DefenseGreater",
              "Silcoon", "Cascoon", "Ninjask", "Shedinja", "Beauty",
              "ItemMale", "ItemFemale", "DayHoldItem", "NightHoldItem", "HasMove",
              "HasInParty", "LevelMale", "LevelFemale", "Location", "TradeSpecies",
              "Custom1", "Custom2", "Custom3", "Custom4", "Custom5", "Custom6", "Custom7"
  ]

  # 0 = no parameter
  # 1 = Positive integer
  # 2 = Item internal name
  # 3 = Move internal name
  # 4 = Species internal name
  # 5 = Type internal name
  EVOPARAM = [0, # Unknown (do not use)
              0, 0, 0, 1, 0, # Happiness, HappinessDay, HappinessNight, Level, Trade
              2, 2, 1, 1, 1, # TradeItem, Item, AttackGreater, AtkDefEqual, DefenseGreater
              1, 1, 1, 1, 1, # Silcoon, Cascoon, Ninjask, Shedinja, Beauty
              2, 2, 2, 2, 3, # ItemMale, ItemFemale, DayHoldItem, NightHoldItem, HasMove
              4, 1, 1, 1, 4, # HasInParty, LevelMale, LevelFemale, Location, TradeSpecies
              1, 1, 1, 1, 1, 1, 1 # Custom 1-7
  ]
end

class SpriteMetafile
  VIEWPORT = 0
  TONE = 1
  SRC_RECT = 2
  VISIBLE = 3
  X = 4
  Y = 5
  Z = 6
  OX = 7
  OY = 8
  ZOOM_X = 9
  ZOOM_Y = 10
  ANGLE = 11
  MIRROR = 12
  BUSH_DEPTH = 13
  OPACITY = 14
  BLEND_TYPE = 15
  COLOR = 16
  FLASHCOLOR = 17
  FLASHDURATION = 18
  BITMAP = 19

  def length
    return @metafile.length
  end

  def [](i)
    return @metafile[i]
  end

  def initialize(viewport = nil)
    @metafile = []
    @values = [
      viewport,
      Tone.new(0, 0, 0, 0), Rect.new(0, 0, 0, 0),
      true,
      0, 0, 0, 0, 0, 100, 100,
      0, false, 0, 255, 0,
      Color.new(0, 0, 0, 0), Color.new(0, 0, 0, 0),
      0
    ]
  end

  def disposed?
    return false
  end

  def dispose
  end

  def flash(color, duration)
    if duration > 0
      @values[FLASHCOLOR] = color.clone
      @values[FLASHDURATION] = duration
      @metafile.push([FLASHCOLOR, color])
      @metafile.push([FLASHDURATION, duration])
    end
  end

  def x
    return @values[X]
  end

  def x=(value)
    @values[X] = value
    @metafile.push([X, value])
  end

  def y
    return @values[Y]
  end

  def y=(value)
    @values[Y] = value
    @metafile.push([Y, value])
  end

  def bitmap
    return nil
  end

  def bitmap=(value)
    @values[BITMAP]= value
    @metafile.push([BITMAP, value])

    # if value && !value.disposed?
    #   @values[SRC_RECT].set(0, 0, value.width, value.height)
    #   @metafile.push([SRC_RECT, @values[SRC_RECT].clone])
    # end
  end

  def src_rect
    return @values[SRC_RECT]
  end

  def src_rect=(value)
    @values[SRC_RECT] = value
    @metafile.push([SRC_RECT, value])
  end

  def visible
    return @values[VISIBLE]
  end

  def visible=(value)
    @values[VISIBLE] = value
    @metafile.push([VISIBLE, value])
  end

  def z
    return @values[Z]
  end

  def z=(value)
    @values[Z] = value
    @metafile.push([Z, value])
  end

  def ox
    return @values[OX]
  end

  def ox=(value)
    @values[OX] = value
    @metafile.push([OX, value])
  end

  def oy
    return @values[OY]
  end

  def oy=(value)
    @values[OY] = value
    @metafile.push([OY, value])
  end

  def zoom_x
    return @values[ZOOM_X]
  end

  def zoom_x=(value)
    @values[ZOOM_X] = value
    @metafile.push([ZOOM_X, value])
  end

  def zoom_y
    return @values[ZOOM_Y]
  end

  def zoom_y=(value)
    @values[ZOOM_Y] = value
    @metafile.push([ZOOM_Y, value])
  end

  def angle
    return @values[ANGLE]
  end

  def angle=(value)
    @values[ANGLE] = value
    @metafile.push([ANGLE, value])
  end

  def mirror
    return @values[MIRROR]
  end

  def mirror=(value)
    @values[MIRROR] = value
    @metafile.push([MIRROR, value])
  end

  def bush_depth
    return @values[BUSH_DEPTH]
  end

  def bush_depth=(value)
    @values[BUSH_DEPTH] = value
    @metafile.push([BUSH_DEPTH, value])
  end

  def opacity
    return @values[OPACITY]
  end

  def opacity=(value)
    @values[OPACITY] = value
    @metafile.push([OPACITY, value])
  end

  def blend_type
    return @values[BLEND_TYPE]
  end

  def blend_type=(value)
    @values[BLEND_TYPE] = value
    @metafile.push([BLEND_TYPE, value])
  end

  def color
    return @values[COLOR]
  end

  def color=(value)
    @values[COLOR] = value.clone
    @metafile.push([COLOR, @values[COLOR]])
  end

  def tone
    return @values[TONE]
  end

  def tone=(value)
    @values[TONE] = value.clone
    @metafile.push([TONE, @values[TONE]])
  end

  def update
    @metafile.push([-1, nil])
  end
end

class SpriteMetafilePlayer
  def initialize(metafile, sprite = nil)
    @metafile = metafile
    @sprites = []
    @playing = false
    @index = 0
    @sprites.push(sprite) if sprite
  end

  def add(sprite)
    @sprites.push(sprite)
  end

  def playing?
    return @playing
  end

  def play
    @playing = true
    @index = 0
  end

  def update
    if @playing
      for j in @index...@metafile.length
        @index = j + 1
        break if @metafile[j][0] < 0
        code = @metafile[j][0]
        value = @metafile[j][1]
        for sprite in @sprites
          case code
          when SpriteMetafile::X
            sprite.x = value
          when SpriteMetafile::Y
            sprite.y = value
          when SpriteMetafile::OX
            sprite.ox = value
          when SpriteMetafile::OY
            sprite.oy = value
          when SpriteMetafile::ZOOM_X
            sprite.zoom_x = value
          when SpriteMetafile::ZOOM_Y
            sprite.zoom_y = value
          when SpriteMetafile::SRC_RECT
            sprite.src_rect = value
          when SpriteMetafile::VISIBLE
            sprite.visible = value
          when SpriteMetafile::Z
            sprite.z = value
            # prevent crashes
          when SpriteMetafile::ANGLE
            sprite.angle = (value == 180) ? 179.9 : value
          when SpriteMetafile::MIRROR
            sprite.mirror = value
          when SpriteMetafile::BUSH_DEPTH
            sprite.bush_depth = value
          when SpriteMetafile::OPACITY
            sprite.opacity = value
          when SpriteMetafile::BLEND_TYPE
            sprite.blend_type = value
          when SpriteMetafile::COLOR
            sprite.color = value
          when SpriteMetafile::TONE
            sprite.tone = value
          when SpriteMetafile::BITMAP
            sprite.bitmap = value
            echo "\n"

          end
        end
      end
      @playing = false if @index == @metafile.length
    end
  end
end

def pbSaveSpriteState(sprite)
  state = []
  return state if !sprite || sprite.disposed?
  state[SpriteMetafile::BITMAP] = sprite.x
  state[SpriteMetafile::X] = sprite.x
  state[SpriteMetafile::Y] = sprite.y
  state[SpriteMetafile::SRC_RECT] = sprite.src_rect.clone
  state[SpriteMetafile::VISIBLE] = sprite.visible
  state[SpriteMetafile::Z] = sprite.z
  state[SpriteMetafile::OX] = sprite.ox
  state[SpriteMetafile::OY] = sprite.oy
  state[SpriteMetafile::ZOOM_X] = sprite.zoom_x
  state[SpriteMetafile::ZOOM_Y] = sprite.zoom_y
  state[SpriteMetafile::ANGLE] = sprite.angle
  state[SpriteMetafile::MIRROR] = sprite.mirror
  state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
  state[SpriteMetafile::OPACITY] = sprite.opacity
  state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
  state[SpriteMetafile::COLOR] = sprite.color.clone
  state[SpriteMetafile::TONE] = sprite.tone.clone
  return state
end

def pbRestoreSpriteState(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.x = state[SpriteMetafile::X]
  sprite.y = state[SpriteMetafile::Y]
  sprite.src_rect = state[SpriteMetafile::SRC_RECT]
  sprite.visible = state[SpriteMetafile::VISIBLE]
  sprite.z = state[SpriteMetafile::Z]
  sprite.ox = state[SpriteMetafile::OX]
  sprite.oy = state[SpriteMetafile::OY]
  sprite.zoom_x = state[SpriteMetafile::ZOOM_X]
  sprite.zoom_y = state[SpriteMetafile::ZOOM_Y]
  sprite.angle = state[SpriteMetafile::ANGLE]
  sprite.mirror = state[SpriteMetafile::MIRROR]
  sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
  sprite.opacity = state[SpriteMetafile::OPACITY]
  sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
  sprite.color = state[SpriteMetafile::COLOR]
  sprite.tone = state[SpriteMetafile::TONE]
end

def pbSaveSpriteStateAndBitmap(sprite)
  return [] if !sprite || sprite.disposed?
  state = pbSaveSpriteState(sprite)
  state[SpriteMetafile::BITMAP] = sprite.bitmap
  return state
end

def pbRestoreSpriteStateAndBitmap(sprite, state)
  return if !state || !sprite || sprite.disposed?
  sprite.bitmap = state[SpriteMetafile::BITMAP]
  pbRestoreSpriteState(sprite, state)
  return state
end

#####################

class PokemonFusionScene
  private

  def generateSplicerMetaFile(nb_seconds,x_pos,y_pos)
    dna_splicer = SpriteMetafile.new
     dna_splicer.opacity = 255
    dna_splicer.x = x_pos
    dna_splicer.y = y_pos

    max_y = 160
    min_y = 140

    dna_splicer.z = 0
    duration = Graphics.frame_rate * nb_seconds
    direction = 1
    #dna_splicer.bitmap = pbBitmap("Graphics/Items/POTION")

    for j in 0...Graphics.frame_rate * 50
      # if j % 2 ==0
      #   dna_splicer.bitmap = pbBitmap("Graphics/Items/SUPERSPLICERS")
      # else
      #   dna_splicer.bitmap = pbBitmap("Graphics/Items/DNASPLICERS")
      # end

      if j % 5 == 0
        dna_splicer.y += direction
        direction = -1 if dna_splicer.y == max_y
        direction = 1 if dna_splicer.y == min_y
      end


      dna_splicer.opacity=0 if j >= duration * 0.75
      dna_splicer.update
    end
    @metafile4 = dna_splicer

  end

  #NEW FUSION ANIMATION (WIP)
  # def pbGenerateMetafiles(nb_seconds,ellipse_center_x,ellipse_center_y,ellipse_major_axis_length,ellipse_minor_axis_length)
  #   sprite_head = SpriteMetafile.new
  #   sprite_body = SpriteMetafile.new
  #   sprite_fused = SpriteMetafile.new
  #
  #   sprite_head.z = 10
  #   sprite_body.z = 10
  #
  #   sprite_head.opacity = 0
  #   sprite_body.opacity = 0
  #   sprite_fused.opacity = 0
  #
  #   duration = Graphics.frame_rate * nb_seconds
  #
  #   sprite_head_angle = 0
  #   sprite_body_angle = Math::PI
  #
  #   #Spinning
  #   angle_incr = 0.1 #speed basically
  #   acceleration = 2
  #   sprite_head.opacity = 255
  #   sprite_body.opacity = 255
  #   for j in 0...duration
  #     if j % 20 == 0
  #       ellipse_major_axis_length -= 10 if ellipse_minor_axis_length > 100
  #       ellipse_major_axis_length -= 18 if ellipse_minor_axis_length > 40
  #       ellipse_minor_axis_length -= 5 if ellipse_minor_axis_length > 10
  #       angle_incr += 0.02*acceleration
  #       acceleration+=0.01
  #     end
  #
  #     sprite_head.x = ellipse_center_x + ellipse_major_axis_length * Math.cos(sprite_head_angle)
  #     sprite_head.y = ellipse_center_y + ellipse_minor_axis_length * Math.sin(sprite_head_angle)
  #
  #     sprite_body.x = ellipse_center_x + ellipse_major_axis_length * Math.cos(sprite_body_angle)
  #     sprite_body.y = ellipse_center_y + ellipse_minor_axis_length * Math.sin(sprite_body_angle)
  #
  #     sprite_head_angle += angle_incr
  #     sprite_body_angle += angle_incr
  #
  #
  #     sprite_head.mirror= sprite_head.y <  ellipse_center_y
  #     sprite_body.mirror= sprite_body.y <  ellipse_center_y
  #
  #     #sprite_body.mirror if sprite_body_angle == 0 || sprite_body_angle == Math::PI
  #
  #     update_sprite_color(sprite_body,j)
  #     update_sprite_color(sprite_head,j)
  #
  #
  #     sprite_head.update
  #     sprite_fused.update
  #     sprite_body.update
  #
  #
  #
  #   end
  #   sprite_head.opacity = 0
  #   sprite_body.opacity = 0
  #   sprite_fused.opacity = 255
  #
  #   @metafile1 = sprite_head
  #   @metafile2 = sprite_fused
  #   @metafile3 = sprite_body
  # end


  def update_sprite_color(sprite,current_frame)
    start_tone_change = 100  #frame at which the tone starts to change
    return if current_frame < start_tone_change
    new_tone = current_frame-start_tone_change
    sprite.tone=Tone.new(new_tone,new_tone,new_tone)
    if current_frame %2 ==0
      #sprite.opacity-= 1
    end
  end
  # def pbGenerateMetafiles(nb_seconds,ellipse_center_x,ellipse_center_y,ellipse_major_axis_length,ellipse_minor_axis_length)

  #def pbGenerateMetafiles(s1x, s1y, s2x, s2y, s3x, s3y, sxx, s3xx)


  #OLD ANIMATION
  def pbGenerateMetafiles(nb_seconds,ellipse_center_x,ellipse_center_y,ellipse_major_axis_length,ellipse_minor_axis_length)

    @sprites["rsprite1"].ox = @sprites["rsprite1"].bitmap.width / 2
    @sprites["rsprite1"].oy = @sprites["rsprite1"].bitmap.height / 2

    @sprites["rsprite3"].ox = @sprites["rsprite3"].bitmap.width / 2
    @sprites["rsprite3"].oy = @sprites["rsprite3"].bitmap.height / 2

    @sprites["rsprite2"].ox = @sprites["rsprite2"].bitmap.width / 2
    @sprites["rsprite2"].oy = @sprites["rsprite2"].bitmap.height / 2

    @sprites["rsprite2"].x = Graphics.width / 2
    @sprites["rsprite1"].y = (Graphics.height - 96) / 2
    @sprites["rsprite3"].y = (Graphics.height - 96) / 2

    @sprites["rsprite1"].x = (Graphics.width / 2) - 100
    @sprites["rsprite3"].x = (Graphics.width / 2) + 100
    s1x, s1y, s2x, s2y, s3x, s3y, sxx, s3xx =@sprites["rsprite1"].ox, @sprites["rsprite1"].oy, @sprites["rsprite2"].ox, @sprites["rsprite2"].oy, @sprites["rsprite3"].ox, @sprites["rsprite3"].oy, @sprites["rsprite1"].x, @sprites["rsprite3"].x

    second = Graphics.frame_rate * 1

    sprite = SpriteMetafile.new
    sprite3 = SpriteMetafile.new
    sprite2 = SpriteMetafile.new

    sprite.opacity = 255
    sprite3.opacity = 255
    sprite2.opacity = 0

    sprite.ox = s1x
    sprite.oy = s1y
    sprite2.ox = s2x
    sprite2.oy = s2y
    sprite3.ox = s3x
    sprite3.oy = s3y

    sprite.x = sxx
    sprite3.x = s3xx

    red = 10
    green = 5
    blue = 90

    for j in 0...26
      sprite.color.red = red
      sprite.color.green = green
      sprite.color.blue = blue
      sprite.color.alpha = j * 10
      sprite.color = sprite.color

      sprite3.color.red = red
      sprite3.color.green = green
      sprite3.color.blue = blue
      sprite3.color.alpha = j * 10
      sprite3.color = sprite3.color

      sprite2.color = sprite.color
      sprite.update
      sprite3.update
      sprite2.update
    end
    anglechange = 0
    sevenseconds = Graphics.frame_rate * 3 #actually 3 seconds
    for j in 0...sevenseconds
      sprite.angle += anglechange
      sprite.angle %= 360

      sprite3.angle += anglechange
      sprite3.angle %= 360

      anglechange += 5 if j % 2 == 0
      if j >= sevenseconds - 50
        sprite2.angle = sprite.angle
        sprite2.opacity += 6
      end

      if sprite.x < sprite3.x && j >= 20
        sprite.x += 2
        sprite3.x -= 2
      else
        #sprite.ox+=1
        #sprite3.ox+=1
      end

      sprite.update
      sprite3.update
      sprite2.update
    end
    sprite.angle = 360 - sprite.angle
    sprite3.angle = 360 - sprite.angle
    sprite2.angle = 360 - sprite2.angle
    for j in 0...sevenseconds
      sprite2.angle += anglechange
      sprite2.angle %= 360
      anglechange -= 5 if j % 2 == 0
      if j < 50
        sprite.angle = sprite2.angle
        sprite.opacity -= 6

        sprite3.angle = sprite2.angle
        sprite3.opacity -= 6
      end

      sprite3.update
      sprite.update
      sprite2.update

    end
    for j in 0...26
      sprite2.color.red = 30
      sprite2.color.green = 230
      sprite2.color.blue = 55
      sprite2.color.alpha = (26 - j) * 10
      sprite2.color = sprite2.color
      sprite.color = sprite2.color
      sprite.update
      sprite2.update
    end
    @metafile1 = sprite
    @metafile2 = sprite2
    @metafile3 = sprite3

  end


  # Starts the fusion screen

  def pbStartScreen(pokemon_head, pokemon_body, splicerItem)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @pokemon1 = pokemon_head
    @pokemon2 = pokemon_body

    addBackgroundOrColoredPlane(@sprites, "background", "DNAbg",
                                Color.new(248, 248, 248), @viewport)

    poke_head_number = @pokemon1.species_data.id_number
    poke_body_number = @pokemon2.species_data.id_number
    # bugfix: the following calculation was not correct
    # @newspecies = poke_head_number * NB_POKEMON + poke_body_number
    @newspecies = poke_body_number * NB_POKEMON + poke_head_number

    @sprites["rsprite1"] = PokemonSprite.new(@viewport)
    @sprites["rsprite2"] = PokemonSprite.new(@viewport)
    @sprites["rsprite3"] = PokemonSprite.new(@viewport)
    @sprites["dnasplicer"] = IconSprite.new(300, 150, @viewport)
    @sprites["dnasplicer"].x = (Graphics.width / 2) - 30
    @sprites["dnasplicer"].y = (Graphics.height / 2) - 50
    @sprites["dnasplicer"].opacity = 0

    @sprites["rsprite1"].setPokemonBitmapFromId(poke_head_number, false, pokemon_head.shiny?)
    @sprites["rsprite3"].setPokemonBitmapFromId(poke_body_number, false, pokemon_body.shiny?)


    spriteLoader = BattleSpriteLoader.new
    @fusion_pif_sprite = spriteLoader.obtain_fusion_pif_sprite(poke_head_number,poke_body_number)

    #this will use the sprite that is set when we call obtain_fusion_pif_sprite, and apply the shiny effect
    @sprites["rsprite2"].setPokemonBitmapFromId(@newspecies, false, pokemon_head.shiny? || pokemon_body.shiny?, pokemon_head.shiny?, pokemon_body.shiny?)

    splicer_bitmap = _INTL("Graphics/Items/{1}",splicerItem)
    @sprites["dnasplicer"].setBitmap(splicer_bitmap)

    @sprites["rsprite1"].ox = @sprites["rsprite1"].bitmap.width / 2
    @sprites["rsprite1"].oy = @sprites["rsprite1"].bitmap.height / 2

    @sprites["rsprite3"].ox = @sprites["rsprite3"].bitmap.width / 2
    @sprites["rsprite3"].oy = @sprites["rsprite3"].bitmap.height / 2

    @sprites["rsprite2"].ox = @sprites["rsprite2"].bitmap.width / 2
    @sprites["rsprite2"].oy = @sprites["rsprite2"].bitmap.height / 2

    @sprites["rsprite2"].x = Graphics.width / 2
    @sprites["rsprite1"].y = (Graphics.height - 96) / 2
    @sprites["rsprite3"].y = (Graphics.height - 96) / 2

    @sprites["rsprite1"].x = (Graphics.width / 2) - 100
    @sprites["rsprite3"].x = (Graphics.width / 2) + 100

    @sprites["rsprite2"].y = (Graphics.height - 96) / 2
    @sprites["rsprite2"].opacity = 0

    @sprites["rsprite1"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite1"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["rsprite2"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite2"].zoom_y = Settings::FRONTSPRITE_SCALE

    @sprites["rsprite3"].zoom_x = Settings::FRONTSPRITE_SCALE
    @sprites["rsprite3"].zoom_y = Settings::FRONTSPRITE_SCALE

    #pbGenerateMetafiles(@sprites["rsprite1"].ox, @sprites["rsprite1"].oy, @sprites["rsprite2"].ox, @sprites["rsprite2"].oy, @sprites["rsprite3"].ox, @sprites["rsprite3"].oy, @sprites["rsprite1"].x, @sprites["rsprite3"].x)

    ellipse_center_x = (Graphics.width/2)
    ellipse_center_y = (Graphics.height/2)-50
    ellipse_major_axis_length = 250
    ellipse_minor_axis_length = 100

    @sprites["rsprite1"].x = ellipse_center_x + ellipse_major_axis_length * Math.cos(0)-75
    @sprites["rsprite1"].y = ellipse_center_y + ellipse_minor_axis_length * Math.sin(0)

    @sprites["rsprite3"].x = ellipse_center_x + ellipse_major_axis_length * Math.cos(Math::PI)+75
    @sprites["rsprite3"].y = ellipse_center_y + ellipse_minor_axis_length * Math.sin(Math::PI)

    pbGenerateMetafiles(7.2,ellipse_center_x,ellipse_center_y,ellipse_major_axis_length,ellipse_minor_axis_length)
    generateSplicerMetaFile(7.2,@sprites["dnasplicer"].x,@sprites["dnasplicer"].y)
    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)
    pbFadeInAndShow(@sprites)

    # FUSION MULTIPLIER

    # LEVELS
    level1 = pokemon_head.level
    level2 = pokemon_body.level

    # LEVEL DIFFERENCE
    if (level1 >= level2) then
      avgLevel = (2 * level1 + level2) / 3
    else
      avgLevel = (2 * level2 + level1) / 3
    end
    return 1
  end

  def calculateAverageValue(value1, value2)
    return ((value1 + value2) / 2).floor
  end

  def pickHighestOfTwoValues(value1, value2)
    return value1 >= value2 ? value1 : value2
  end

  def setFusionIVs(supersplicers)
    if supersplicers
      setHighestFusionIvs()
    else
      averageFusionIvs()
    end
  end

  def averageFusionIvs()
    @pokemon1.iv[:HP] = calculateAverageValue(@pokemon1.iv[:HP], @pokemon2.iv[:HP])
    @pokemon1.iv[:ATTACK] = calculateAverageValue(@pokemon1.iv[:ATTACK], @pokemon2.iv[:ATTACK])
    @pokemon1.iv[:DEFENSE] = calculateAverageValue(@pokemon1.iv[:DEFENSE], @pokemon2.iv[:DEFENSE])
    @pokemon1.iv[:SPECIAL_ATTACK] = calculateAverageValue(@pokemon1.iv[:SPECIAL_ATTACK], @pokemon2.iv[:SPECIAL_ATTACK])
    @pokemon1.iv[:SPECIAL_DEFENSE] = calculateAverageValue(@pokemon1.iv[:SPECIAL_DEFENSE], @pokemon2.iv[:SPECIAL_DEFENSE])
    @pokemon1.iv[:SPEED] = calculateAverageValue(@pokemon1.iv[:SPEED], @pokemon2.iv[:SPEED])
  end

  #unused. was meant for super splicers, but too broken
  def setHighestFusionIvs()
    @pokemon1.iv[:HP] = pickHighestOfTwoValues(@pokemon1.iv[:HP], @pokemon2.iv[:HP])
    @pokemon1.iv[:ATTACK] = pickHighestOfTwoValues(@pokemon1.iv[:ATTACK], @pokemon2.iv[:ATTACK])
    @pokemon1.iv[:DEFENSE] = pickHighestOfTwoValues(@pokemon1.iv[:DEFENSE], @pokemon2.iv[:DEFENSE])
    @pokemon1.iv[:SPECIAL_ATTACK] = pickHighestOfTwoValues(@pokemon1.iv[:SPECIAL_ATTACK], @pokemon2.iv[:SPECIAL_ATTACK])
    @pokemon1.iv[:SPECIAL_DEFENSE] = pickHighestOfTwoValues(@pokemon1.iv[:SPECIAL_DEFENSE], @pokemon2.iv[:SPECIAL_DEFENSE])
    @pokemon1.iv[:SPEED] = pickHighestOfTwoValues(@pokemon1.iv[:SPEED], @pokemon2.iv[:SPEED])
  end

  # Closes the evolution screen.
  def pbEndScreen
    Kernel.pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites) if @sprites
    @viewport.dispose
  end

  # Opens the fusion screen

  def pbFusionScreen(cancancel = false, superSplicer = false, firstOptionSelected = false)
    metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
    metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
    metaplayer3 = SpriteMetafilePlayer.new(@metafile3, @sprites["rsprite3"])
    metaplayer4 = SpriteMetafilePlayer.new(@metafile4, @sprites["dnasplicer"])

    metaplayer1.play
    metaplayer2.play
    metaplayer3.play
    metaplayer4.play
    pbBGMStop()
    pbPlayCry(@pokemon)
    Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("The Pokémon are being fused!"))

    Kernel.pbMessageWaitForInput(@sprites["msgwindow"], 100, true)
    pbPlayDecisionSE()
    oldstate = pbSaveSpriteState(@sprites["rsprite1"])
    oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
    oldstate3 = pbSaveSpriteState(@sprites["rsprite3"])

    pbBGMPlay("fusion")

    canceled = false
    noMoves = false
    begin
      metaplayer1.update
      metaplayer2.update
      metaplayer3.update
      metaplayer4.update

      Graphics.update
      Input.update
      if Input.trigger?(Input::B) && Input.trigger?(Input::C) # && Input.trigger?(Input::A)# && cancancel
        noMoves = true
        pbSEPlay("buzzer")
        Graphics.update
      end
    end while metaplayer1.playing? && metaplayer2.playing?
    if canceled
      pbBGMStop()
      pbPlayCancelSE()
      # Kernel.pbMessageDisplay(@sprites["msgwindow"],
      @pbEndScreen
      _INTL("Huh? The fusion was cancelled!")
    else
      frames = pbCryFrameLength(@newspecies)
      pbBGMStop()
      pbPlayCry(@newspecies)
      frames.times do
        Graphics.update
      end
      
      newSpecies = GameData::Species.get(@newspecies)
      newspeciesname = newSpecies.real_name
      oldspeciesname = GameData::Species.get(@pokemon1.species).real_name

      overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap

      sprite_bitmap = @sprites["rsprite2"].getBitmap

      drawSpriteCredits(@fusion_pif_sprite, @viewport)
      pbBGMPlay(pbGetWildVictoryME)
      Kernel.pbMessageDisplay(@sprites["msgwindow"], _INTL("\\se[]Congratulations! Your Pokémon were fused into {1}!\\wt[80]", newspeciesname))
      
      #add to pokedex
      if !$Trainer.pokedex.owned?(newSpecies)
        $Trainer.pokedex.set_seen(newSpecies)
        $Trainer.pokedex.set_owned(newSpecies)
        Kernel.pbMessageDisplay(@sprites["msgwindow"],
                                _INTL("{1}'s data was added to the Pokédex", newspeciesname))
        @scene.pbShowPokedex(@newspecies)
      end
      
      overlay.dispose
      
      @pokemon1.validate_ability
      @pokemon2.validate_ability
      
      # allow player to choose the ability and nature
      pbSelectAbilityAndNature
      
      # allow player to select moves
      pbSelectFusionMoves if !noMoves
      
      # set fused flag early
      @pokemon1.fused = true
      
      # species
      @pokemon1.species = newSpecies
      
      # track the exp for each part
      @pokemon1.head_exp = @pokemon1.exp
      @pokemon1.body_exp = @pokemon2.exp
      @pokemon1.exp_gained_since_fused = 0
      
      # track if the parts were shiny
      @pokemon1.head_shiny = @pokemon1.shiny?
      @pokemon1.body_shiny = @pokemon2.shiny?
      @pokemon1.debug_shiny = @pokemon1.debug_shiny || @pokemon2.debug_shiny
      
      # forced shiny if either part is shiny
      if @pokemon1.head_shiny || @pokemon1.body_shiny
        @pokemon1.makeShiny
        if !(@pokemon1.debug_shiny || @pokemon2.debug_shiny)
          @pokemon1.natural_shiny = true
        end
      end
      
      # gender
      @pokemon1.head_gender = @pokemon1.gender
      @pokemon1.body_gender = @pokemon2.gender
      if (@pokemon1.male? && @pokemon2.female?) || (@pokemon1.female? && @pokemon2.male?) || @pokemon1.genderless?
        @pokemon1.gender = 2 # force genderless
      end

      # met information
      @pokemon1.head_obtain_method = @pokemon1.obtain_method
      @pokemon1.body_obtain_method = @pokemon2.obtain_method
      @pokemon1.obtain_method = 0
      @pokemon1.head_obtain_map = @pokemon1.obtain_map
      @pokemon1.body_obtain_map = @pokemon2.obtain_map
      @pokemon1.head_obtain_level = @pokemon1.obtain_level
      @pokemon1.body_obtain_level = @pokemon2.obtain_level
      @pokemon1.head_hatched_map = @pokemon1.hatched_map
      @pokemon1.body_hatched_map = @pokemon2.hatched_map
      
      # ribbons
      @pokemon1.head_ribbons = @pokemon1.ribbons
      @pokemon1.body_ribbons = @pokemon2.ribbons
      @pokemon2.ribbons.each_with_index { |a, i| @pokemon1.ribbons.push([a, i]) if a }
      
      # pokerus
      @pokemon1.head_pokerus = @pokemon1.pokerus
      @pokemon1.body_pokerus = @pokemon2.pokerus
      @pokemon1.pokerus = ((@pokemon1.pokerus + @pokemon2.pokerus) / 2).floor
      
      # happiness
      @pokemon1.head_happiness = @pokemon1.happiness
      @pokemon1.body_happiness = @pokemon2.happiness
      @pokemon1.happiness = ((@pokemon1.happiness + @pokemon2.happiness) / 2).floor
      
      # markings
      @pokemon1.head_markings = @pokemon1.markings
      @pokemon1.body_markings = @pokemon2.markings
      @pokemon1.markings |= @pokemon2.markings
      
      # poke ball
      @pokemon1.head_poke_ball = @pokemon1.poke_ball
      @pokemon1.body_poke_ball = @pokemon2.poke_ball
      
      # IV
      @pokemon1.head_iv = @pokemon1.iv
      @pokemon1.body_iv = @pokemon2.iv
      GameData::Stat.each_main do |s|
        @pokemon1.iv[s.id] = ((@pokemon1.head_iv[s.id] + @pokemon1.body_iv[s.id]) / 2).floor
      end
      @pokemon1.head_iv_maxed = @pokemon1.iv_maxed
      @pokemon1.body_iv_maxed = @pokemon2.iv_maxed
      GameData::Stat.each_main do |s|
        @pokemon1.iv_maxed[s.id] = @pokemon1.head_iv_maxed[s.id] && @pokemon1.body_iv_maxed[s.id]
      end
      
      # EV
      @pokemon1.head_ev = @pokemon1.ev
      @pokemon1.body_ev = @pokemon2.ev
      GameData::Stat.each_main do |s|
        @pokemon1.ev[s.id] = ((@pokemon1.head_ev[s.id] + @pokemon1.body_ev[s.id]) / 2).floor
      end
      
      # OT
      @pokemon1.head_owner = @pokemon1.owner
      @pokemon1.body_owner = @pokemon2.owner
      if @pokemon1.owner.name.eql?($Trainer.name)
        @pokemon1.owner = @pokemon2.owner
      end
      
      # hidden power
      @pokemon1.head_hidden_power = @pokemon1.hidden_power
      @pokemon1.body_hidden_power = @pokemon2.hidden_power
      @pokemon1.hidden_power = ((@pokemon1.hidden_power + @pokemon2.hidden_power) / 2).floor

      @pokemon1.level = setPokemonLevel(@pokemon1.level, @pokemon2.level, superSplicer)
      @pokemon1.name = newspeciesname if @pokemon1.name == oldspeciesname
      @pokemon1.calc_stats

      pbSEPlay("Voltorb Flip Point")
      
      pbBGMStop
      pbBGMPlay($PokemonTemp.cueBGM)
    end
  end
end

def drawSpriteCredits(pif_sprite, viewport)
  overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport).bitmap
  return if pif_sprite.type == :AUTOGEN
  x = Graphics.width / 2
  y = 240
  spritename = pif_sprite.to_filename()
  spritename = File.basename(spritename, '.*')

  discord_name = getSpriteCredits(spritename)
  return if !discord_name

  author_name = File.basename(discord_name, '#*')
  return if author_name == nil

  label_base_color = Color.new(98, 231, 110)
  label_shadow_color = Color.new(27, 169, 40)

  #label_shadow_color = Color.new(33, 209, 50)
  text = _INTL("Sprite by {1}", author_name)
  textpos = [[text, x, y, 2, label_base_color, label_shadow_color]]
  pbDrawTextPositions(overlay, textpos)
end

def pbSelectAbilityAndNature
  addBackgroundOrColoredPlane(@sprites, "background", "DNAbg",
                              Color.new(248, 248, 248), @viewport)
  pbDisposeSpriteHash(@sprites)
  
  scene = FusionSelectOptionsScene.new(@pokemon1, @pokemon2)
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
  
  @pokemon1.head_ability = @pokemon1.ability
  @pokemon1.body_ability = @pokemon2.ability
  
  if $game_switches[SWITCH_DOUBLE_ABILITIES]
    @pokemon1.ability2 = @pokemon2.ability
  else
    @pokemon1.ability = scene.selectedAbility
  end
  
  @pokemon1.head_nature = @pokemon1.nature
  @pokemon1.body_nature = @pokemon2.nature
  @pokemon1.nature = scene.selectedNature
  
  if scene.hasNickname
    @pokemon1.name = scene.selectedNickname
  end
end

# somehow, even though pokemon2 is the base here, it's considered the head?
def pbSelectFusionMoves
  choice = Kernel.pbMessage("What to do with the moveset?", [
                            _INTL("Combine movesets"),
                            _INTL("Keep {1}'s moveset", @pokemon1.species_data.real_name),
                            _INTL("Keep {1}'s moveset", @pokemon2.species_data.real_name)
                            ], 0)
  case choice
  when 0 then
    #Learn moves
    movelist = @pokemon2.moves
    for move in movelist
      if move.id != 0
        pbLearnMove(@pokemon1, move.id, true, false, true)
      end
    end
  when 2 then
    @pokemon1.moves = @pokemon2.moves
  end
end

def setPokemonLevel(superSplicers)
  lv1 = @pokemon1.level
  lv2 = @pokemon2.level
  return calculateFusedPokemonLevel(lv1, lv2, superSplicers)
end

def calculateFusedPokemonLevel(lv1, lv2, superSplicers)
  if superSplicers
    if lv1 > lv2
      return lv1
    else
      return lv2
    end
  else
    if (lv1 >= lv2) then
      return (2 * lv1 + lv2) / 3
    else
      return (2 * lv2 + lv1) / 3
    end
  end
  return lv1
end

def pbShowPokedex(species)
  pbFadeOutIn {
    scene = PokemonPokedexInfo_Scene.new
    screen = PokemonPokedexInfoScreen.new(scene)
    screen.pbDexEntry(species)
  }
end

#EDITED FOR GEN2
def fixEvolutionOverflow(retB, retH, oldSpecies)
  #raise Exception.new("retB: " + retB.to_s + " retH: " + retH.to_s)

  oldBody = getBasePokemonID(oldSpecies)
  oldHead = getBasePokemonID(oldSpecies, false)
  return -1 if isNegativeOrNull(retB) && isNegativeOrNull(retH)
  return oldBody * NB_POKEMON + retH if isNegativeOrNull(retB) #only head evolves
  return retB * NB_POKEMON + oldHead if isNegativeOrNull(retH) #only body evolves
  return retB * NB_POKEMON + retH #both evolve
end

