class CompanyVersion < Version
  attr_accessible :slideshow_pictures

  def reify
    model = super
    if slideshow_pictures
      model.versioned_slideshow_pictures = YAML::load( slideshow_pictures )
    end
    model
  end
end