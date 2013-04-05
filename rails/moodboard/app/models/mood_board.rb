class MoodBoard < ActiveRecord::Base

  has_many :mood_board_tile, :dependent => :destroy

  belongs_to :thumb_storage, :class_name => 'Storage', :dependent => :destroy
  belongs_to :main_storage, :class_name => 'Storage', :dependent => :destroy

  def do_clone

    new = MoodBoard.create(
      :name => (self.status == 'template') ? 'Unnamed' : '',
      :desc => self.desc,
      :status => 'private',
      :width => self.width,
      :height => self.height,
    )

    self.mood_board_tile.each do |tile|

      new_tile = tile.dup
      new_tile.mood_board_id = new.id
      new_tile.save

    end

    new.generate_images
    new.save

    new
  end

  def to_hash(target = :view)

    data = {
      :id     => self.id,
      :name   => self.name,
      :desc   => self.desc,
      :status => self.status,
      :width  => self.width,
      :height => self.height,
      :tiles  => self.mood_board_tile.map { |t| t.to_hash(target) }
    }

    return data
  end

  def from_hash(data)

    self.mood_board_tile.each_with_index do |tile, i|
      tdata = data['tiles'][i]
      tile.photo_id = tdata['attributes'].nil? ? nil : tdata['attributes']['photo-id']
      tile.x = tdata['x']
      tile.y = tdata['y']
      tile.width = tdata['width']
      tile.height = tdata['height']
      tile.edit_width = tdata['edit_width']
      tile.edit_height = tdata['edit_height']
      tile.edit_x_offset = tdata['edit_x_offset']
      tile.edit_y_offset = tdata['edit_y_offset']
      tile.storage.destroy if tile.photo_id.nil? and tile.storage.present?
      tile.save
    end

    self.name = data['name']
    self.desc = data['desc']
    self.status = data['status']
    self.generate_images
    self.save

  end

  def generate_images()

    self.main_storage = Storage.create_storage('moodboard_', 'jpg') if self.main_storage.nil?
    self.thumb_storage = Storage.create_storage('moodboard_', 'jpg') if self.thumb_storage.nil?

    generate_image(self.main_storage.get_path)
    generate_thumb(self.thumb_storage.get_path, self.vertical? ? 187 : 150)

  end

  def get_name
    self.name.to_s.empty? ? 'Unnamed' : self.name
  end

  def vertical?
    self.height > self.width
  end

private

  # FIXME: refactor these methods

  def generate_thumb(path, height)

    tile_margin = 1
    full_height = height

    height -= 2 * tile_margin

    scale = height / self.height.to_f

    img = Magick::Image.new((self.width * full_height / self.height.to_f).round, full_height)

    self.mood_board_tile.each do |tile|

      right = ((tile.x - 1 + tile.width + 2) * scale).round - tile_margin * 1
      bottom = ((tile.y - 1 + tile.height + 2) * scale).round - tile_margin * 1

      left = ((tile.x - 1) * scale).round + tile_margin
      top = ((tile.y - 1) * scale).round + tile_margin

      width = right - left
      height = bottom - top


      tile_img = Magick::Image.new(width + 2, height + 2)

      gc = Magick::Draw.new
      gc.fill('#ececec')
      gc.stroke('#808080')
      gc.rectangle(0, 0, width + 1, height + 1)
      gc.draw(tile_img)

      if tile.photo

        tile_img_photo = Magick::Image.read(tile.storage.get_path).first
        tile_img_photo.scale!(width, height)
        tile_img.composite!(tile_img_photo, 1, 1, Magick::OverCompositeOp)
        tile_img_photo.destroy!

      end

      img.composite!(tile_img, left - 1 + tile_margin, top - 1 + tile_margin, Magick::OverCompositeOp)

      tile_img.destroy!
    end

    img.write(path)
    img.destroy!
  end

  def generate_image(path)

    img = Magick::Image.new(self.width, self.height)

    self.mood_board_tile.each do |tile|

      tile_img = Magick::Image.new(tile.width + 2, tile.height + 2)

      gc = Magick::Draw.new
      gc.fill('#ececec')
      gc.stroke('#808080')
      gc.rectangle(0, 0, tile.width + 1, tile.height + 1)
      gc.draw(tile_img)

      if tile.photo
        tile_img_photo = Magick::Image.read(tile.storage.get_path).first
        tile_img.composite!(tile_img_photo, 1, 1, Magick::OverCompositeOp)
        tile_img_photo.destroy!
      end

      img.composite!(tile_img, tile.x - 1, tile.y - 1, Magick::OverCompositeOp)

      tile_img.destroy!
    end

    #if height != self.height
    #  width = (1.0 * self.width * height / self.height).round
    #  img.scale!(width, height)
    #end

    img.write(path)
    img.destroy!
  end
end
