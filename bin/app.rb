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

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

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
  mount_uploader :image, ImageUploader
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
  @marks = Mark.order("created_at DESC")
  erb :"index"
end

#Add new mark
get "/marks/new" do
  @title = "Создание новой метки"
  
  erb :"marks/new"
end

#Add mark to DB
post "/marks" do
  @mark = Mark.new
  @mark.image = params[:mark][:image]
  @mark.car_number = params[:mark][:car_number]
  #mark = params[:mark]
  @mark.save
  redirect "marks/#{@mark.id}"
=begin    
  @mark = Mark.new
  @mark.car_number = params[:mark][:car_number]
  
  if @mark.save
    redirect "marks/#{@mark.id}", :notice => 'Классно! Пост добавлен!'
  else
    redirect "marks/new", :error => 'Ты напортачил, попробуй еще!'
  end
=end

end

#Get one mark by ID
get "/marks/:id" do
  @title = "Просмотр метки"
  @mark = Mark.find(params[:id])
  erb :"marks/view"
end

#Edit mark by ID
get "/marks/:id/edit" do
  @mark = Mark.find(params[:id])
  @title = "Edit Form"
  erb :"marks/edit"
end

#Edit mark by ID in DB
put "/marks/:id" do
  @mark = Mark.find(params[:id])
  @mark.update(params[:mark])
  redirect "/marks/#{@mark.id}"
end

=begin

class Mark

  field :car_number, type: String
  field :tag, type: String
  field :ssn
  
  validates :car_number, presence: true
  index({ ssn: 1 }, { unique: true, name: "ssn_index" })
end

# Корень
get '/' do
  puts 'Yasya forever!'
  erb :"index"
end

namespace '/v1' do

  # Список всех публикаций
  get '/marks' do
    content_type 'application/json'
    marks = Mark.all
    return marks.to_json
  end

  get '/clean' do
    puts 'clean!'
    Mark.delete_all
  end

  # Форма для добавления публикации
  get '/marks/new' do
    #erb :"/marks/new"
  end
  
  # Одна публикация
  get '/marks/:id' do

  end
  
  # Сохранение публикации
  post '/marks' do
    digests = self.request.body.read
    data = JSON.parse( digests )

    puts "\nI got request: \"#{digests}\""
    puts "\nI got JSON: \"#{data}\""
    puts "\nCar number: \"#{data['mark']['car_number']}\"\n\n"

    @mark = Mark.new(car_number: data['mark']['car_number'], tag: data['mark']['tag'])
    @mark.save
  end

  # Обновление отредактированной публикации
  put '/marks/:id' do
    
  end

  # Форма для редактировани публикации
  get '/marks/:id/edit' do
    
  end

  # Стриница с предупреждением об удалении публикации
  get '/marks/:id/delete' do
    
  end

  # Удаление публикации
  delete '/marks/:id' do

  end
end

=end