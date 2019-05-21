require 'sinatra'
require 'sinatra/reloader' if development?
require 'dm-core'
require 'dm-migrations'
require_relative 'students.rb'
require_relative 'comments.rb'
require 'dm-timestamps'

configure :development, :test do
	DataMapper::Logger.new($stdout, :debug) #turn on error logging to STDOUT
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw2.db")
end

configure :production do
	# DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end
configure do
	#set :environment, :development
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'your_secret'
  enable :session
	set :username, "asabharwal"
	set :password, "arushi123"
	set :status, "/"
end

# get '/style.css' do
# 	scss :style
# end

get '/' do
	#already login -> go to students page
  if session[:admin]
    redirect '/students'
  end

  settings.status = "/logout"
  @title = "This is Login page"
  erb :login
end

post '/login' do
	if (params[:username] == settings.username) && (params[:password] == settings.password)
    session[:admin] = true
    redirect '/students'
  else
    # not match, send back to login page
    @err = "wrong username or password"
    erb :login
  end
end

get '/home' do
 	@title = 'This is the Home Page'
	erb :home
end

get '/about' do
	@title = "This is the About page"
	erb :about
end

get '/contact' do
	erb :contact
end

# new comment page
get '/new_comment' do
  erb :new_comment
end

# comment page
get '/comments' do
  @comments = Comment.all
  erb :comments
end

post '/new_comment' do
  new_com = Comment.new
  new_com.name = params[:name]
  new_com.comment = params[:comment]
  #new_com.created_at = Time.now()
  new_com.save

  redirect '/comments'
end

#comment's detail page
get '/comments/:id' do
 @comments = Comment.all(:id => params[:id]).first
 erb :comments_detail
end

#Students's Page
get '/students' do
	# check if user login credentials are correct
	if !session[:admin]
    redirect '/'
	end
		@students = Student.all
	  @title = "This is students page"
		erb :students
end

# students detail page
get '/students/:id' do
  # check if user login credentials are correct
  if !session[:admin]
    redirect '/'
  end

  @student = Student.all(:student_id => params[:id]).first
  erb :student_detail
end

# go to the new student page
get '/newstu' do
  # check if user login credentials are correct
  if !session[:admin]
    redirect '/'
  end

  temp = Student.all(:order => :student_id.asc)

  if temp.count != 0
    @new_id = temp.last.student_id + 1
  else
    @new_id = 1
  end

  erb :add_students
end

#add a new student
post '/addstu' do
 # check if user login
 if !session[:admin]
	 redirect '/'
 end

 # check birthday format
 if !checkDate(params[:birthday])
	 @msg = "Cannot process this entry! Please enter the correct date format!"
	 @students = Student.all
	 @title = "This is the Students page"
	 return erb :students
 end

 # To make sure that ID does not get repeated
 Student.all.each do |x|
	 if x.student_id == params[:id].to_i
		 @msg = "Cannot process this entry! Please enter the different student id!"
		 @students = Student.all
		 @title = "This is the Students page"
		 return erb :students
	 end
 end

 stu_new = Student.new
 stu_new.student_id = params[:id]
 stu_new.firstname = params[:firstname]
 stu_new.lastname = params[:lastname]
 stu_new.birthday = params[:birthday] #mm/dd/yyyy format
 stu_new.address = params[:address]
 stu_new.save
 redirect '/students'
end

# go to the edit student page
get '/editpage_stu' do
  # check if user login credentials are correct
  if !session[:admin]
    redirect '/'
  end

  @student = Student.all(:student_id => params[:id]).first

  erb :edit_students
end

#edit a student entry
post '/edit_stu' do
  # check if user login credentials are correct
  if !session[:admin]
    redirect '/'
  end
  # check date of birth format
  if !checkDate(params[:birthday])
    @msg = "Cannot Process this entry! Please enter the correct date format!"
    @students = Student.all
    @title = "This is Students Page"
    return erb :students
  end

  stu = Student.all(:student_id => params[:id]).first
  stu.firstname = params[:firstname]
  stu.lastname = params[:lastname]
  stu.birthday = params[:birthday] #mm/dd/yyyy format
  stu.address = params[:address]
  stu.save
  redirect '/students'
end

#delete a student
post '/delete_stu' do
  # check if user login credentials are correct
  if !session[:admin]
    redirect '/'
  end

  stu = Student.all(:student_id => params[:id])
  stu.destroy

  redirect '/students'
end

#This is the login page
# get '/login' do
# 	erb :login
# end

#This is the logout page
get '/video' do
  @title = "This is the Video Page"
  erb :video
end

#for Logout page
get '/logout' do
  session[:admin]=false
	session.clear
  # session[:admin]=false
	settings.status = '/'
	redirect '/'
end

not_found do
  @title = "Not found page"
  erb :notfound, :layout => false
end

def checkDate(date) #This function will check the date to be in correct format
  if(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/.match(date) == nil)
    return false
  else
    return true
  end
end
