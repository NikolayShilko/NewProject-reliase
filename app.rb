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
#таблица для комментариев Comments

@db.execute 'CREATE TABLE IF NOT EXISTS "Comments" (
	"id"	INTEGER,
	"created_date"	DATE,
	"content"	TEXT,
	"post_id" INTEGER,
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
#универсальный обработчик urla вывод информации о посте
get '/details/:post_id' do
	#получаем переменную из url
	post_id= params[:post_id]
	#получение списка постов и выбор одного поста с записью в переменную @row
results=@db.execute 'select * from POSTS where id=?',[post_id]
@row=results[0]
#выбор комментариев для поста
@comments=@db.execute 'select * from Comments where post_id=? order by id',[post_id]

erb :details
#erb "информация о посте #{post_id}"
end
#обработчик post запросов из details.erb форма отправки комментариев к посту
post '/details/:post_id' do

post_id= params[:post_id]

content= params[:content]
# сохранение данных в талицу бд comments
@db.execute 'insert into Comments(content ,created_date,post_id) values (?,datetime(),?)',[content,post_id]

#erb "Вы ввели #{content} к посту #{post_id}"

redirect to ('/details/'+ post_id)
	end