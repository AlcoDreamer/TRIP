require 'sinatra'
#require 'sinatra/namespace'
#require "sinatra/namespace"
require 'sinatra/contrib'
require 'active_record'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

require 'carrierwave'
require 'carrierwave/orm/activerecord'
#require 'rmagick'

require './bin/environments'

#enable :sessions

use Rack::Session::Cookie, 
  :key => 'rack.session',
  :path => '/',
  :expire_after => 14400, # In seconds
  :secret => 'yasya'

set :port, 8080
set :static, true
set :views, "views"
set :public_directory, "public"

class ImagesUploader < CarrierWave::Uploader::Base
  #include CarrierWave::MiniMagick

  def cache_dir
    "../tmp/uploads"
  end
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{mounted_as}_#{model.id}.#{file.extension}"
  end
  storage :file
end

class Mark < ActiveRecord::Base
  #validates :car_number, presence: true, length: { maximum: 15 }
  mount_uploader :image, ImagesUploader
end

class MarkSerializer
  def initialize(mark)
    @mark = mark
  end

  def as_json(*)
    data = {
      id:@mark.id.to_s,
      title:@mark.title,
      author:@mark.author,
      car_number:@mark.car_number,
      description:@mark.description,
      tags:@mark.tags
    }
    data[:errors] = @mark.errors if@mark.errors.any?
    data
  end
end

class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    data = {
      id:@user.id.to_s,
      name:@user.name,
      nick:@user.nick,
      email:@user.email,
      password:@user.password,
      sex:@user.sex
    }
    data[:errors] = @user.errors if@user.errors.any?
    data
  end
end

class User < ActiveRecord::Base
  #validates :car_number, presence: true, length: { maximum: 15 }
  mount_uploader :image, ImagesUploader
end

class Admin < ActiveRecord::Base
  #validates :car_number, presence: true, length: { maximum: 15 }
end

helpers do
  def title
    if @title
      "#{@title}"
    else
      "Yasya!"
    end
  end
  def protected!
    if not authorized?
      redirect "/admins/signin"
    end
  end
  def authorized?
    not (session[:admin_id].nil?)
  end
  def admins_name
    if authorized?
      (Admin.find(session[:admin_id])).login
    else
      "Yasya!"
    end
  end
  def home_page
    "/marks"
  end

  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://{request.env['HTTP_HOST']}"
  end

  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
end

error do
  redirect to('/')
end

# All Marks
get "/" do
  protected!
  #@marks = Mark.order("created_at DESC")
  #erb :"index"
  redirect home_page
end

##############################
# Обработка меток
##############################

# All Marks
get "/marks" do
  protected!
  @marks = Mark.order("created_at DESC")
  erb :"marks/all"
end

#Add new mark
get "/marks/new" do
  protected!
  erb :"marks/new"
end

#Get one mark by ID
get "/marks/:id" do
  protected!
  @mark = Mark.find(params[:id])
  erb :"marks/view"
end

#Edit mark by ID
get "/marks/:id/edit" do
  protected!
  @mark = Mark.find(params[:id])
  erb :"marks/edit"
end

##############################
# Обработка пользователей
##############################

# All Users
get "/users" do
  protected!
  @users = User.order("created_at DESC")
  erb :"users/all"
end

#Add new user
get "/users/new" do
  protected!
  erb :"users/new"
end

#Get one user by ID
get "/users/:id" do
  protected!
  @user = User.find(params[:id])
  erb :"users/view"
end

#Edit user by ID
get "/users/:id/edit" do
  protected!
  @user = User.find(params[:id])
  erb :"users/edit"
end


#Add mark to DB
post "/marks" do
  protected!
  @mark = Mark.new
  @mark.image = params[:mark][:image]
  @mark.title = params[:mark][:title]
  @mark.author = params[:mark][:author]
  @mark.car_number = params[:mark][:car_number]
  @mark.description = params[:mark][:description]
  @mark.tags = params[:mark][:tags]
  #mark = params[:mark]
  @mark.save
  redirect "marks/#{@mark.id}"
end

post "/marks/:id" do
  protected!
  @mark = Mark.find(params[:id])
  @mark.update(params[:mark])
  redirect "/marks/#{@mark.id}"
end

post "/users" do
  protected!
  @user = User.new
  @user.image = params[:user][:image]
  @user.name = params[:user][:name]
  @user.nick = params[:user][:nick]
  @user.email = params[:user][:email]
  @user.password = params[:user][:password]
  @user.sex = params[:user][:sex]

  @user.save
  redirect "users/#{@user.id}"
end

post "/users/:id" do
  protected!
  @user = User.find(params[:id])
  @user.update(params[:user])
  redirect "/users/#{@user.id}"
end

##### Вход

get '/admins/signin' do
  erb :"admins/signin"
end

post "/admins/signin" do
  @admin = Admin.find_by(login: params[:admin][:login], password: params[:admin][:password])
  if @admin.nil?
    redirect "/admins/signin"
  end
  session[:admin_id] = @admin.id
  redirect home_page
end

get '/admins/logout' do
  session.clear
  redirect "/admins/signin"
end

get '/admins/new' do
  protected!
  erb :"admins/new"
end

get '/admins/all' do
  Admin.all.to_json
end

post "/admins" do
  protected!
  @admin = Admin.new
  if params[:admin][:password1] != params[:admin][:password2]
    redirect "/admins/new"
  end
  @admin.login = params[:admin][:login]
  @admin.password = params[:admin][:password1]
  @admin.save
  redirecthome_page
end

get '/admins/edit' do
  protected!
  erb :"admins/edit"
end

post "/admins/:id" do
  protected!
  if params[:admin][:password1] != params[:admin][:password2]
    redirect "/admins/edit"
  end
  @admin = Admin.find(session[:admin_id])
  if @admin.password != params[:admin][:cur_password]
    redirect "/admins/edit"
  end
  @admin.update(password: params[:admin][:password1])
  redirect home_page
end

####################################################################################################
####################################################################################################
####################################################################################################

namespace '/api/v1' do
  before do
    content_type 'application/json'
  end

  post "/marks" do
    @mark = Mark.new(json_params)
    @mark.image = File.open(Dir.pwd + "/bin/default/mark_default.jpg")
    
    if @mark.save
      #response.headers['Location'] = "#{base_url}/api/v1/books/#{@mark.id}"
      status 201
    else
      status 422
      body MarkSerializer.new(@mark).to_json
    end
  end

  post "/users" do
    @user = User.new(json_params)
    if user.sex == "female"
      @user.image = File.open(Dir.pwd + "/bin/default/user_default_female.jpg")
    else
      @user.image = File.open(Dir.pwd + "/bin/default/user_default_male.jpg")

    if @user.save
      #response.headers['Location'] = "#{base_url}/api/v1/books/#{@mark.id}"
      status 201
    else
      status 422
      body UserSerializer.new(@user).to_json
    end
  end
end
