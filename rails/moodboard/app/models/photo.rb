class Photo < ActiveRecord::Base

  belongs_to :photo_category

  belongs_to :thumb_storage, :class_name => 'Storage', :dependent => :destroy
  belongs_to :main_storage, :class_name => 'Storage', :dependent => :destroy

  def self.import(path, options = {})

    image = Magick::Image::read(path).first

    main_storage = Storage.create_storage('photo_', 'jpg')
    thumb_storage = Storage.create_storage('thumb_', 'jpg')

    photo = Photo.new(
      :width => image.columns,
      :height => image.rows,
      :main_storage => main_storage,
      :thumb_storage => thumb_storage
    )
    photo.assign_attributes(options)
    photo.save

    image.write(main_storage.get_path)
    image.thumbnail!(140, (photo.height * 140.0 / photo.width).round)
    image.write(thumb_storage.get_path)
    image.destroy!


    photo

  end

end
