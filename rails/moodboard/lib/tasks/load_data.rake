# lib/tasks/import_surveys.rake

templates = [
  [
    [4, 4, 180, 272], [188, 4, 180, 272], [372, 4, 180, 134], [372, 142, 180, 134],
    [4, 280, 180, 134], [188, 280, 364, 272], [4, 418, 180, 272], [188, 556, 180, 134],
    [372, 556, 180, 134]
  ], [
    [4, 4, 180, 272], [188, 4, 180, 134], [372, 4, 180, 134], [188, 142, 180, 134],
    [372, 142, 180, 272], [4, 280, 180, 134], [188, 280, 180, 134], [4, 418, 180, 272],
    [188, 418, 364, 272]
  ], [
    [4, 4, 134, 180], [142, 4, 134, 180], [280, 4, 134, 180], [418, 4, 134, 180],
    [4, 188, 272, 180], [280, 188, 272, 364], [4, 372, 134, 180], [142, 372, 134, 180],
    [4, 556, 180, 134], [188, 556, 180, 134], [372, 556, 180, 134]
  ], [
    [4, 4, 272, 364], [280, 4, 272, 364], [4, 372, 134, 180], [142, 372, 134, 180],
    [280, 372, 134, 180], [418, 372, 134, 180], [4, 556, 180, 134], [188, 556, 180, 134],
    [372, 556, 180, 134]
  ], [
    [4, 4, 364, 272], [372, 4, 180, 272], [4, 280, 180, 272], [188, 280, 180, 272],
    [372, 280, 180, 272], [4, 556, 180, 134], [188, 556, 180, 134], [372, 556, 180, 134]
  ], [
    [4, 4, 180, 272], [188, 4, 364, 272], [4, 280, 180, 134], [188, 280, 180, 134],
    [372, 280, 180, 272], [4, 418, 364, 272], [372, 556, 180, 134]
  ]
]

desc 'Load initial data'

task :load_data => [:environment] do |t, args|

  PhotoCategory.delete_all
  Photo.delete_all
  MoodBoard.delete_all
  MoodBoardTile.delete_all

  cat1 = PhotoCategory.create(:name=>'cat 1')
  cat2 = PhotoCategory.create(:name=>'cat 2')
  subcat1 = PhotoCategory.create(:name=>'subcat 1', :photo_category => cat1)
  subcat2 = PhotoCategory.create(:name=>'subcat 2', :photo_category => cat1)

  Photo.import(Rails.root + 'data/img1.jpg',  :name=>'photo1',  :photo_category => subcat1, :anchor => 'http://google.com/')
  Photo.import(Rails.root + 'data/img2.jpg',  :name=>'photo2',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img3.jpg',  :name=>'photo3',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img4.jpg',  :name=>'photo4',  :photo_category => subcat1, :anchor => 'http://twitter.com/')
  Photo.import(Rails.root + 'data/img5.jpg',  :name=>'photo5',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img1.jpg',  :name=>'photo1',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img2.jpg',  :name=>'photo2',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img3.jpg',  :name=>'photo3',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img4.jpg',  :name=>'photo4',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img5.jpg',  :name=>'photo5',  :photo_category => subcat1)
  Photo.import(Rails.root + 'data/img6.jpg',  :name=>'photo6',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img7.jpg',  :name=>'photo7',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img8.jpg',  :name=>'photo8',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img6.jpg',  :name=>'photo6',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img7.jpg',  :name=>'photo7',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img8.jpg',  :name=>'photo8',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img6.jpg',  :name=>'photo6',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img7.jpg',  :name=>'photo7',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img8.jpg',  :name=>'photo8',  :photo_category => subcat2)
  Photo.import(Rails.root + 'data/img9.jpg',  :name=>'photo9',  :photo_category => cat2)
  Photo.import(Rails.root + 'data/img10.jpg', :name=>'photo10', :photo_category => cat2)
  Photo.import(Rails.root + 'data/img9.jpg',  :name=>'photo9',  :photo_category => cat2)
  Photo.import(Rails.root + 'data/img10.jpg', :name=>'photo10', :photo_category => cat2)
  Photo.import(Rails.root + 'data/img9.jpg',  :name=>'photo9',  :photo_category => cat2)
  Photo.import(Rails.root + 'data/img10.jpg', :name=>'photo10', :photo_category => cat2)
  Photo.import(Rails.root + 'data/img9.jpg',  :name=>'photo9',  :photo_category => cat2)
  Photo.import(Rails.root + 'data/img10.jpg', :name=>'photo10', :photo_category => cat2)
  Photo.import(Rails.root + 'data/img9.jpg',  :name=>'photo9',  :photo_category => cat2)
  Photo.import(Rails.root + 'data/img10.jpg', :name=>'photo10', :photo_category => cat2)

  templates.each_with_index do |tpl, i|
    mb = MoodBoard.create(:name => 'Template %d' % i, :status => 'template', :width => 556, :height => 694)
    tpl.each do |item|
      MoodBoardTile.create(:mood_board => mb, :x => item[0]+1, :y => item[1]+1, :width => item[2]-2, :height => item[3]-2)
    end
    mb.generate_images
    mb.save
  end

  templates.each_with_index do |tpl, i|
    mb = MoodBoard.create(:name => 'Template %d' % (i + templates.length), :status => 'template', :width => 694, :height => 556)
    tpl.each do |item|
      MoodBoardTile.create(:mood_board => mb, :x => item[1]+1, :y => item[0]+1, :width => item[3]-2, :height => item[2]-2)
    end
    mb.generate_images
    mb.save
  end

end
