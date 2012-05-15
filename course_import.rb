class CourseImport < ActiveRecord::Base
  set_primary_key "CourseImportID"

  validates_uniqueness_of :Code, :message => 'Please make sure course codes are unique'
  validates_length_of :cipcode, :maximum => 100, :allow_nil => true
  validate :status_value, :allow_blank => true

  def status_value
    unless self.Status == 'OPEN' or self.Status == 'CLOSED'
      errors.add(:status, "must be a valid option: OPEN or CLOSED.")
    end
  end


  def self.import_preview(csv,provider)

    require 'fastercsv'
    #clean out queue
    CourseImport.delete_all
    courses=[]
    skip_first_row=false
    FasterCSV.foreach(csv.local_path) do |row|
      compacted = row
      break if compacted.collect { |x| x unless x.blank? }.compact.empty?

      courses << self.map_import(row,provider) unless skip_first_row===false
      skip_first_row=true
    end

    return courses
  end


  def self.map_import(row, provider)
    unless row[0].blank?
      #confirm course id exists in system
      unless Course.find_by_CourseID(row[0])
        CourseImport.delete_all
        raise "Unable to find course \"#{row[1]}\" in system. Please address and reimport."
      end
    else
      #confirm code doesn't exist in system for new course
      if Course.find_by_Code(row[6])
        CourseImport.delete_all
        raise "The Course \"#{row[1]}\" appears to have a duplicate code. Please address and reimport."
      end
    end

    course_import = CourseImport.new
    
    course_import.CourseID = row[0] unless row[0].blank?
    
    course_import.Title = row[1] unless row[1].blank?
    
    course_import.Prerequisites = row[2] unless row[2].blank?
    course_import.Technology_requirements = row[3] unless row[3].blank?
    course_import.Other_materials = row[4] unless row[4].blank?
    
    course_import.Status = row[5].upcase unless row[5].blank?
    
    course_import.Code = "#{provider.provider_code}#{row[6]}" unless row[6].blank?
    course_import.cte_certification = row[7] unless row[7].blank?
    course_import.ell_notes = row[8] unless row[8].blank?
    course_import.HSCredits = row[9] unless row[9].blank?
    course_import.CollegeCredits = row[10] unless row[10].blank?
    course_import.URL = row[11] unless row[11].blank?
    course_import.Completion_time = row[12] unless row[12].blank?
    course_import.New = row[13] unless row[13].blank?
    course_import.YearLong = row[14] unless row[14].blank?
    course_import.Block = row[15] unless row[15].blank?
    course_import.cipcode = row[16] unless row[16].blank?
    course_import.state_code = row[17] unless row[17].blank?
    
    course_import.subjects = row[18] unless row[18].blank?
    course_import.features = row[19] unless row[19].blank?
    course_import.levels = row[20] unless row[20].blank?
    course_import.grades = row[21] unless row[21].blank?

    if !course_import.save
      CourseImport.delete_all

      raise "Unable to save course import record: \"#{course_import.Title}\". #{course_import.errors.full_messages.join(",")}"
    end

    return course_import
  end


  def self.import_courses(pid)
    courses = CourseImport.find(:all)

    courses.each do | course |
      self.create_course(course,pid)
    end

    #clear the import course table queue
    CourseImport.delete_all
  end


  def self.create_course(import, pid)

    raise 'Please provide a Provider ID' if pid.blank?

    course = Course.find_or_initialize_by_CourseID(import.CourseID)
    course.Provider = pid

    course.Prerequisites = import.Prerequisites unless import.Prerequisites.blank?
    course.Technology_requirements = import.Technology_requirements unless import.Technology_requirements.blank?
    course.Other_materials = import.Other_materials unless import.Other_materials.blank?
    course.Status = import.Status.blank? ? 'OPEN' : import.Status
    course.Title = import.Title unless import.Title.blank?
    course.Code = import.Code unless import.Code.blank?
    course.cte_certification = import.cte_certification unless import.cte_certification.blank?
    course.ell_notes = import.ell_notes unless import.ell_notes.blank?
    course.HSCredits = import.HSCredits unless import.HSCredits.blank?
    course.CollegeCredits = import.CollegeCredits unless import.CollegeCredits.blank?
    course.URL = import.URL unless import.URL.blank?
    course.Completion_time = import.Completion_time unless import.Completion_time.blank?
    course.New = import.New unless import.New.nil?
    course.YearLong = import.YearLong unless import.YearLong.blank?
    course.Block = import.Block unless import.Block.nil?
    course.cipcode = import.cipcode unless import.cipcode.blank?
    course.state_code = import.state_code unless import.state_code.blank?

    raise "Unable to save course: \"#{course.Title}\". Course Code \"#{course.Code}\" may not be unique." if course.save === false

    self.create_subjects(course.CourseID, import.subjects) unless import.subjects.blank?
    self.create_features(course.CourseID, import.features) unless import.features.blank?
    self.create_levels(course.CourseID, import.levels) unless import.levels.blank?
    self.create_grades(course.CourseID, import.grades) unless import.grades.blank?
  end


  def self.create_subjects(cid, subjects)
    subjects.split(/,/).each do | sid |
      CourseSubject.new(:CourseID => cid, :SubjectID => sid ).save
    end
  end


  def self.create_features(cid, features)
    features.split(/,/).each do | fid |
      CourseFeature.new(:course_id => cid, :feature_id => fid ).save
    end
  end


  def self.create_levels(cid, levels)
    levels.split(/,/).each do | lid |
      CourseLevel.new(:CourseID => cid, :LevelID => lid ).save
    end
  end


  def self.create_grades(cid, grades)
    grades.split(/,/).each do | gid |
      CourseGrade.new(:CourseID => cid, :GradeID => gid ).save
    end
  end
end
