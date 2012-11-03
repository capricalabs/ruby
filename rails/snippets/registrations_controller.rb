class Admin::RegistrationsController < AdminController
  layout "admin"

  skip_before_filter :verify_authenticity_token

  def index
    @provider = params[:provider]
    @term = params[:term]
    @status   = params[:status]
    @student = params[:student]
    @course = params[:course]
    @sort = params[:sort]
    @batch = params[:batch]

    if params[:filterFlag] && session[:registration_filter]
      registration_filter = session[:registration_filter]
      @provider = registration_filter[0]
      @term = registration_filter[1]
      @status   = registration_filter[2]
      @student = registration_filter[3]
      @course = registration_filter[4]
      @sort = registration_filter[5]
      @batch = registration_filter[6]
    else
      registration_filter = [@provider, @term, @status, @student, @course, @sort, @batch]
      session[:registration_filter] = registration_filter
    end

    @regs = Registration::query_registrations(
      (params[:format] && params[:format] == 'csv') ? 'all' : params[:page],
      @provider,
      @term,
      @status,
      @student,
      @course,
      @sort,
      @batch
    )

    respond_to do |format|
      format.html
      format.csv do
        response.headers['Content-Disposition'] = 'attachment;filename=registrations.csv'
        render :layout => false
      end
    end
  end

  def list
    begin
      @provider = Provider.find(params[:id])
      @reg_status = params[:status] || "Processing"
      @process_only = ['Sent to Provider','Drop Sent to Provider','Enrolled','Year Long Course'].include?(@reg_status)

      @start_date = Date.strptime(params[:sd]) rescue ''
      @title = {'Drop Requested'=>'Drop Requests',
                'Processing'=>'New Registrations',
                'Sent to Provider'=>'Enrollment Confirmation',
                'Drop Sent to Provider'=>'Drop Confirmation',
                'Enrolled'=>'Completed Courses',
                'Modified'=>'Modified Registrations',
                'Year Long Course'=>'Enrollment Confirmation',
                'Confirming'=>'Enrolled Courses'
      }

      @term = Term.find(params[:term]) rescue Term.new
      @regs = Registration.Search({
          :status=>[@reg_status],
          :provider=>@provider.id,
          :term=>@term.id,
          :start_date=>@start_date,
          :order_by=>'Reg_RegistrationInfo.courseStartDate',
          :group_by=>false, :modified=>false
      })

      report_type =  ProviderEmail.get_report_type(@reg_status)
      reg_plural = (@regs.length > 1) ? 's' : ''
      @email_body = "Dear #{@provider.name},\n\nPlease use the following link to download #{@regs.length} #{@reg_status} course registration#{reg_plural}:\n\n"
      @email_body += "<LINKS_OR_ATTACHMENTS>\n\n"

      @email_body += "\nTo see all of #{@provider.name}'s registration activity, go here:\n\nhttp://#{PUBLIC_APP_HOST}/approval/providers/registrations/dash"

      @email_body += "\n\n-----------------------------------------------\n"
      @email_body += "The Digital Learning Department"

      @email = ProviderEmail.new(:ProviderID=>@provider.id, :report_type => report_type, :email_subject => ProviderEmail.get_email_subject(@reg_status) % @provider.name + ((@provider.id != 11)? '' : ' ' + Time.now.strftime("%m-%d-%Y")), :email_body => @email_body ) if !@process_only

      @startdates = CourseDate.StartDates(@provider.id,@term)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Provider was not found!  Please try again."
      redirect_to :root
    rescue => e
      flash[:error] = e.message
      redirect_to :root
    end
  end


  def refactor

    # begin

      @regs = Registration.paginate(:page => params[:page])

    # rescue ActiveRecord::RecordNotFound
    #   flash[:error] = "Provider was not found!  Please try again."
    #   #redirect_to :root
    # rescue
    #   flash[:error] = 'There was an error loading the page, please try again.'
    #   #redirect_to :root
    # end
  end


  def finalize
    @a=['Confirming', 'Drop Sent to Provider', 'Enrolled','Sent to Provider', 'Waitlist', "Year Long Course"]
  end


  def waitlist
    @regs = Registration.Search({:status=>['Waitlist'],:provider=>params[:id], :term=>params[:term]})
  end


  def process_waitlisted
    begin
      params['r'].each{|k,v| Registration.find(k).process_registration(session['UID'], v['status'])}
      flash[:notice] = "Successfully Processed!"
      redirect_to :action=> 'finalize'
    rescue
      flash[:error] = 'Didn\'t receive the required reg IDs from submission.'
      redirect_to :root
    end
  end


  def processed
    @main_file_name = params[:f1]
    @supp_file_name = params[:f2]
  end


  def modified
    begin
      @provider = Provider.find(params[:id])
      @log_items = Registration.SearchModified(@provider.id)

      reg_plural = (@log_items.length > 1) ? 's' : ''
      @email_body = "Dear #{@provider.name},\n\nPlease use the following link to download #{@log_items.length} modified course registration#{reg_plural}:\n"
      @email_body +="\n<LINKS_OR_ATTACHMENTS>\n\n"

      @email_body += "\nTo see all of #{@provider.name}'s registration activity, go here:\n\nhttp://#{PUBLIC_APP_HOST}/approval/providers/registrations/dash"

      @email_body += "\n\n-----------------------------------------------\n"
      @email_body += "The Digital Learning Department"

      @email = ProviderEmail.new(:ProviderID=>@provider.id, :report_type => ProviderEmail.get_report_type('Modified'), :email_subject => ProviderEmail.get_email_subject('Modified') % @provider.name, :email_body => @email_body)
      @log_items = Registration.SearchModified(@provider.id)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Provider was not found!  Please try again."
      redirect_to :root
    rescue => e
      flash[:error] = e.message
      redirect_to :root
    end
  end


  def edit
    @r = Registration.find(params[:id])
  end


  def update
    @r = Registration.find(params[:id])

    if params['r'] and params['r']['CourseID']
      params[:registration] = params[:registration].merge({'CourseID'=>params['r']['CourseID']})
    end

    if params[:registration]['courseStartDate']=='other'
      params[:registration]['courseStartDate'] = params['sd']
    end

    if params[:registration]['courseEndDate']=='other'
      params[:registration]['courseEndDate'] = params['ed']
    end

    u = Registration.new(params[:registration])
    @r.AddLogEntry(session['UID'], params[:log],true) if !params[:log].blank?

    #update textbooks
    @r.UpdateOrderedBooks(session['UID'], params[:books], params[:book], true, false)

    Log.reg_update(@r, u, session['UID'])

    process_second_sem = true if @r.SecondSemRegID && (@r.status != u.status) && (["Dropped", "Deleted"].include? u.status)

    if @r.update_attributes(params[:registration])
      process_second_sem_msg = process_second_sem ? "<a href=#{url_for(:action => 'second_sem', :id=> @r.id, :only_path => true)}> Process 2nd Semester </a>" : nil
      flash[:notice] = "Registration Information Updated. #{process_second_sem_msg}<br />" #<a href=\"student_registrations.php?student_id='.$Reg_row->id_student.'">Student Registrations</a>';"
      redirect_to :action => 'edit', :id => @r

    else
      flash[:notice] = "Error!"
      render :action => 'edit', :id => @r
    end
  end

  def second_sem
    r = Registration.find(params[:id])
    u = r.second_semester_registration
    if r.SecondSemRegID && (r.status != u.status) && (["Dropped", "Deleted"].include? r.status) && u.update_attributes(:status => r.status)
        flash[:notice] = "2nd Semester of Registration Updated.<br />" #<a href=\"student_registrations.php?student_id='.$Reg_row->id_student.'">Student Registrations</a>';"
        redirect_to :action => 'edit', :id => u
    else
      flash[:notice] = "Error!"
      redirect_to :action => 'edit', :id => r
    end
  end


  # Called via AJAX from Reg Edit Form
  # so this call does nothing useful on the server side. revisit
  # to confirm we need this action rather than an embedded js
  def ajax_edit_term
    #reset provider and course ( if course is set )
    render :update do |page|

      page['course_Provider'].selectedIndex = 0

      page << 'if ($("r_CourseID")) {'
        page['r_CourseID'].selectedIndex = 0
      page << '}'
    end
  end


  # Called via AJAX from Reg Edit Form
  def ajax_edit_provider
    #updates list of courses
    render :update do |page|
      page.replace_html 'courses', {:partial => 'course_select', :locals=>{:term_id => params[:term], :provider_id=>params[:provider]}}
    end
  end


  # Called via AJAX from Reg Edit Form
  def ajax_edit_course
    #updates start dates, textbooks, course cost, and end dates
    r = Registration.find(params[:id])

    if params[:course]==r.CourseID.to_s and params[:term]==r.OfferingID.to_s
      cost = r.CourseCost
      charge = r.ActualChargeByProvider
    else
      ct = CourseTerm.find_course_term(params[:course],params[:term])
      cost = (ct.blank?) ? 0 : ct.CourseCost
      charge = cost
    end

    render :update do |page|
      page['registration_CourseCost'].value = cost
      page['registration_ActualChargeByProvider'].value = charge

      page.replace_html 'start_dates', {:partial => 'admin/misc/course_start_dates', :locals=>{:r => r, :term_id => params[:term], :provider_id=>params[:provider], :course_id=>params[:course]}}
      page.replace_html 'end_dates',   {:partial => 'admin/misc/course_end_dates',   :locals=>{:r => r, :term_id => params[:term], :provider_id=>params[:provider], :course_id=>params[:course]}}
      page.replace_html 'textbooks',   {:partial => 'admin/misc/textbooks', :locals=>{:r => r, :course_id=>params[:course]}}
    end
  end


  def compile_new #process only checked ones

    @registrations = Registration.find(params[:approve] || [])

    begin
      raise 'You didn\'t select any registrations to process.' if @registrations.empty?

      mode = params[:form_action]

      @term = Term.find(params[:term_id]) rescue Term.new
      @provider = @registrations[0].course.provider

      if (mode=="download") #update status, don't generate report
        @registrations.each do | r |
          r.process_registration(session['UID'])
          # Create Notification
          r.AddNotification?("http://#{PUBLIC_APP_HOST }/user_feedback/writeReview.php?courseID=#{r.CourseID}")
        end

        batch_id = Reports.process_new_reg(@provider,params,mode,@term,@registrations,session['UID'])
        flash[:notice] = "Successfully processed."

        redirect_to :action => 'success', :batch_id => batch_id

      else #process and generate files

        if @provider.id == 2 && params['ecode'].blank?
          flash[:notice] = 'Please specify an Ecode supplied by Aventa Learning Provider.'
          return redirect_to :action =>"list", :id=>@provider, :term => @term.id
        end

        Reports.process_new_reg(@provider,params,mode,@term,@registrations,session['UID'])

        flash[:notice] = "Successfully processed and e-mailed registeration data."
        return redirect_to :root
      end # end  processing of registrations and generating files

    rescue RuntimeError => e
      flash[:error] = 'Error: ' + e.message
      return redirect_to :root
    end
  end


  def compile_modified #process only checked ones
     emailing = params[:form_action] == "email" ? "email" : params[:form_action] == "links" ? "links" : false
     @log_items = Log.find(params[:approve] || [])

     begin

       raise "You didn't select any registrations to process." if @log_items.empty?

       @provider = Provider.find(@log_items[0].registration.course.Provider)

       # for Aventa report check the ecode value was entered
       raise "Please specify an Ecode supplied by Aventa Learning Provider." if @provider.id == 2 && params['ecode'].blank?

       files = Reports.process_modified_reg(@log_items, @provider,emailing, params)

    rescue RuntimeError => e

       flash[:error] = 'Error: ' + e.message
       return redirect_to :root

    rescue ArgumentError => e

       flash[:error] = e.message
       return redirect_to :action =>"modified", :id=>@provider
    end

    if emailing
      flash[:notice] = "Successfully processed and e-mailed registeration data."
      return redirect_to :root
    else
      redirect_to :action => 'success', :f1 => files['main_file_name'], :f2 => files['supp_file_name']
    end
  end

  #
  def success
    @batch_id = params[:batch_id]
  end

  def download
    @rb= RegistrationBatch.find(params[:id])
    if @rb.registrations.any?
      files = @rb.download_new_reg
      file =  params[:type] =="secondary" ? files['supp_file_name'] : files['main_file_name']
      if file
        send_file_options = { :type => 'text', :filename=> File.basename(file) }
        case SEND_FILE_METHOD
        when :apache then send_file_options[:x_sendfile] = true
        end
        send_file(file, send_file_options)
      end
    else
      @rb.update_attributes(:downloaded_at=>Time.now) unless @rb.downloaded_at #makeing it as downlod if reg status is modifed before it is downloaded
      flash[:notice] = "No Registrations found"
      redirect_to provider_registrations_path(@provider.id)
    end
  end
end
