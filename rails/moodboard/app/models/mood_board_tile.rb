class MoodBoardTile < ActiveRecord::Base
  belongs_to :photo
  belongs_to :mood_board

  belongs_to :storage, :class_name => 'Storage', :dependent => :destroy

  before_save :before_save_cb

  def dup

    new = super
    new.storage = self.storage.dup if self.storage.present?
    new.save

    new
  end

  def to_hash(target = :view)

    data = {
      :x      => self.x,
      :y      => self.y,
      :width  => self.width,
      :height => self.height,
      :url    => self.storage.present? ? self.storage.get_url : '',
      :title  => self.photo.present? ? self.photo.name : '',
      :anchor  => self.photo.present? ? self.photo.anchor : ''
    }

    data.update ({
      :attributes     => {
        'photo-id' => self.photo_id,
      },
      :edit_width     => self.edit_width,
      :edit_height    => self.edit_height,
      :edit_x_offset  => self.edit_x_offset,
      :edit_y_offset  => self.edit_y_offset,
      :orig_width     => self.photo.present? ? self.photo.width : 0,
      :orig_height    => self.photo.present? ? self.photo.height : 0,
      :orig_url       => self.photo.present? ? self.photo.main_storage.get_url : ''
    }) if target == :edit

    data

  end

private

  def before_save_cb

    return unless self.photo_id

    self.storage = Storage.create_storage('tile', 'jpg') if self.storage.nil?

    orig = Magick::Image::read(self.photo.main_storage.get_path).first
    orig.resize!(self.edit_width, self.edit_height)
    orig.crop!(-self.edit_x_offset, -self.edit_y_offset, self.width, self.height)
    orig.write(self.storage.get_path)
    orig.destroy!

  end
end
