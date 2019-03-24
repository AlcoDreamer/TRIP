require 'sinatra'
#require 'sinatra/namespace'
require 'active_record'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

require 'carrierwave'
require 'carrierwave/orm/activerecord'
#require 'rmagick'

require './bin/environments'

enable :sessions

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
=begin
  version :small do 
    process :resize_to_fit => [190, 190] 
    process :convert => 'png' 
    def filename
      "small_#{mounted_as}_#{model.id}.#{file.extension}"
    end
  end 
  version :icon do 
    process :resize_to_fill => [50, 50] 
    process :convert => 'png'
    def filename
      "icon_#{mounted_as}_#{model.id}.#{file.extension}"
    end
  end 
=end

  storage :file
end

class Mark < ActiveRecord::Base
  #validates :car_number, presence: true, length: { maximum: 15 }
  mount_uploader :image, ImagesUploader
end

class User < ActiveRecord::Base
  #validates :car_number, presence: true, length: { maximum: 15 }
  mount_uploader :image, ImagesUploader
end

helpers do
  def title
    if @title
      "#{@title}"
    else
      "Yasya!"
    end
  end
end

# All Marks
get "/" do
  #@marks = Mark.order("created_at DESC")
  #erb :"index"
  redirect "/marks"
end

##############################
# Обработка меток
##############################

# All Marks
get "/marks" do
  @title = "Все метки"
  @marks = Mark.order("created_at DESC")
  erb :"marks/all"
end

#Add new mark
get "/marks/new" do
  @title = "Создание новой метки"
  erb :"marks/new"
end

#Get one mark by ID
get "/marks/:id" do
  @title = "Просмотр метки"
  @mark = Mark.find(params[:id])
  erb :"marks/view"
end

#Edit mark by ID
get "/marks/:id/edit" do
  @title = "Редактирование метки"
  @mark = Mark.find(params[:id])
  erb :"marks/edit"
end

##############################
# Обработка пользователей
##############################

# All Users
get "/users" do
  @title = "Все метки"
  @users = User.order("created_at DESC")
  erb :"users/all"
end

#Add new user
get "/users/new" do
  @title = "Создание нового пользователя"
  erb :"users/new"
end

#Get one user by ID
get "/users/:id" do
  @title = "Просмотр пользователя"
  @user = User.find(params[:id])
  erb :"users/view"
end

#Edit user by ID
get "/users/:id/edit" do
  @title = "Редактирование пользователя"
  @user = User.find(params[:id])
  erb :"users/edit"
end


#Add mark to DB
post "/marks" do
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

post "/marks/:id/edit" do
  @mark = Mark.find(params[:id])
  @mark.update(params[:mark])
  redirect "/marks/#{@mark.id}"
end

#Edit mark by ID in DB
put "/marks/:id" do
  @mark = Mark.find(params[:id])
  @mark.update(params[:mark])
  redirect "/marks/#{@mark.id}"
end


post "/users" do
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

post "/users/:id/edit" do
  @user = User.find(params[:id])
  @user.update(params[:user])
  redirect "/users/#{@user.id}"
end

#Edit mark by ID in DB
put "/users/:id" do
  @user = User.find(params[:id])
  @user.update(params[:mark])
  redirect "/marks/#{@mark.id}"
end
