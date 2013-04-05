class Storage < ActiveRecord::Base

  STORAGE_PATH = Rails.root.join('public', 'storage')
  STORAGE_URL = '/storage/'

  before_destroy do
    File.delete(self.get_path)
  end

  def get_path
    Storage.get_location(Storage::STORAGE_PATH, self.prefix, self.randkey, self.ext)
  end

  def get_url
    Storage.get_location(Storage::STORAGE_URL, self.prefix, self.randkey, self.ext)
  end

  def dup
    new = super
    new.randkey = Storage.make_randkey(new.prefix, new.ext)
    new.save

    FileUtils.cp(self.get_path, new.get_path)

    new
  end

  def self.create_storage(prefix = '', ext = '')

    Storage.create(
      :randkey => Storage.make_randkey(prefix, ext),
      :prefix => prefix,
      :ext => ext
    )

  end

private

  def self.get_location(dirname, prefix, randkey, ext)
    ext = '.' + ext unless ext.to_s.empty?
    prefix = prefix.to_s

    File.join(dirname, prefix + randkey + ext)
  end

  def self.make_randkey(prefix, ext)
    begin
      randkey = SecureRandom.hex(8)
      path = self.get_location(Storage::STORAGE_PATH, prefix, randkey, ext)
    end while File.exists?(path)

    File.new(path, 'w').close()

    randkey
  end

end
