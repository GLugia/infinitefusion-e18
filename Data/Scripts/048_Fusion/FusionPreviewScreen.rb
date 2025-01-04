class FusionPreviewScreen < DoublePreviewScreen
  attr_writer :draw_types
  attr_writer :draw_level

  BACKGROUND_PATH = "Graphics/Pictures/DNAbg"


  def initialize(pokemon1, pokemon2, usingSuperSplicers = false)
    super(pokemon1, pokemon2)
    @draw_types = true
    @draw_level = true
    @draw_sprite_info=true
    
    new_level = calculateFusedPokemonLevel(pokemon1.level, pokemon2.level, usingSuperSplicers)
    
    fusion_left = (pokemon2.species_data.id_number) * NB_POKEMON + pokemon1.species_data.id_number
    fusion_right = (pokemon1.species_data.id_number) * NB_POKEMON + pokemon2.species_data.id_number
    
    @picture1 = draw_window(fusion_left, new_level, 20, 30)
    @picture2 = draw_window(fusion_right, new_level, 270, 30)
    
    @sprites["picture1"] = @picture1
    @sprites["picture2"] = @picture2
  end

  def getBackgroundPicture
    super
  end
end