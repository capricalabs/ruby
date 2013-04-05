class PhotoCategory < ActiveRecord::Base
  belongs_to :photo_category

  def self.get_all_data(parent_id = nil)

    cats = PhotoCategory.where(:photo_category_id => parent_id)
    photos = Photo.where(:photo_category_id => parent_id)
    name = parent_id ? PhotoCategory.find(parent_id).name : '';

    data = {
      :id => parent_id,
      :name => name,
      :cats => [],
      :photos => []
    }

    cats.each do |cat|
      data[:cats] << PhotoCategory.get_all_data(cat.id)
    end

    photos.each do |ph|
      data[:photos] << {
        :photo_id => ph.id,
        :url => ph.main_storage.get_url,
        :thumb_url => ph.thumb_storage.get_url,
        :orig_width => ph.width,
        :orig_height => ph.height,
        :name => ph.name
      }
    end

    data

  end

end
