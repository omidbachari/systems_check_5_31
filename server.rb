require "pry"
require "pg"
require "sinatra"


require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

def create_array_of_recipe_names_ids
  recipe_hashes =
    db_connection do |conn|
      conn.exec('SELECT name, id FROM recipes')
    end
  recipe_hashes = recipe_hashes.to_a

  recipe_arrays = []
  recipe_hashes.each do |hash|
    one_recipe = []
    one_recipe << hash["name"]
    one_recipe << hash["id"]
    recipe_arrays << one_recipe
  end
  recipe_arrays

end

get "/" do

  erb :index
end

get "/recipes" do
  @recipes = create_array_of_recipe_names_ids
  erb :recipes
end

get "/recipes/:id" do


  @recipes = create_array_of_recipe_names_ids(params[:id])



  erb :recipe_page
end
