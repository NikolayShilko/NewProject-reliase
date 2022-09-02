#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
#создание базы данных Blog.db    

def init_db
	@db=SQLite3::Database.new 'Blog.db'
	@db.results_as_hash= true
	end
#метод Before вызывается каждый раз при перезагрузке страницы
# служит для обновления данных в бд.
before do
	init_db
end

configure do
	init_db #инициализация БД
	#создание таблицы POSTS если не существует
@db.execute 'CREATE TABLE IF NOT EXISTS "POSTS" (
	"id"	INTEGER,
	"created_date"	DATE,
	"content"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
)';
	end

get '/' do
	# запись данных из бд в переменную 
	@results=@db.execute 'select * from POSTS order by id desc'
	erb :index		
end

get '/Post' do
  erb :new
end
 
 #обработчик Post запроса /new
post '/new' do
# получение данных из формы в new.erb и запись  в переменную content	
  content= params[:content]
#проверка параметров данных введенных в форму
if content.length ==0  
	@error="Введите текст!"
	return erb :new
end
#запись данных из формы /new в таблицу POSTS,добавлен datetime для звписи времени поста
@db.execute 'insert into POSTS (content ,created_date) values (?,datetime())',[content]
  #erb "Вы ввели:#{content}"
  redirect to '/'
end
