require 'sinatra'
#require 'sinatra/namespace'
require 'active_record'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require './bin/environments'

enable :sessions

set :port, 8080
set :static, true
set :views, "views"
set :public_directory, "public"

class Mark < ActiveRecord::Base
  validates :car_number, presence: true, length: { maximum: 15 }
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
  @mark = Mark.new
  erb :"marks/new"
end

#Add mark to DB
post "/marks" do
  @mark = Mark.new(params[:mark])
  if @mark.save
    redirect "marks/#{@mark.id}", :notice => 'Классно! Пост добавлен!'
  else
    redirect "marks/new", :error => 'Ты напортачил, попробуй еще!'
  end
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