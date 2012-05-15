class Book < ActiveRecord::Base
  set_table_name "Reg_books"
  set_primary_key "book_id"

  belongs_to :vendor, :foreign_key => "bookvendor_id"

  has_many :course_books, :foreign_key => "book_id"
  has_many :courses, :through => :course_books

  #for pagination
  cattr_reader :per_page
  @@per_page = 50

  def self.all_books
    Book.all(:order=>'title')
  end

  #Function returns price of the book with shipping and tax added.
  def text_book_sale_price(addPayPalFee=false)
    sale_price = 0
    shipping_fee = (self.vendor.shipping_fee.nil?) ? 0 : self.vendor.shipping_fee
    shipping_percentage = (self.vendor.shipping_percentage.nil?) ? 0 : self.vendor.shipping_percentage

    sale_price = self.price + shipping_fee + (self.price * shipping_percentage) * 1.088

    if addPayPalFee
      sale_price *= 1.029
    end

    (sale_price * 100).round.to_f/100
  end


  def self.export_books conditions
    books = CourseBook.all( :include=>[:course, :book], :conditions=>conditions, :order=>"Reg_books.title")
    output = FasterCSV.generate do |csv|
      csv << ['Book Title','ISBN','Vendor','Price','Course','Required?']

      books.each do |b|
        row = []
        if b.book.nil?
          row << ''
          row << ''
          row << ''
          row << ''
        else
          row << "#{b.book.title}"
          row << "#{b.book.isbn}"
          row << ((!b.book.vendor.blank?) ? "#{b.book.vendor.name}" : '')
          row << "$%.2f" % b.book.price
        end
        row << ((!b.course.nil?) ? "#{b.course.Title}(#{b.course.Code})" : '')
        row << ((b.required == 1) ? 'Yes' : 'No')
        csv << row.flatten
      end
    end # output

    return output
  end
end
