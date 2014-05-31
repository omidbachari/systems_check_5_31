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
      conn.exec('SELECT name, id, description, instructions FROM recipes ORDER BY name')
    end
  recipe_hashes = recipe_hashes.to_a
  recipe_arrays = []
  recipe_hashes.each do |hash|
    one_recipe = []
    one_recipe << hash["name"]
    one_recipe << hash["id"]
    one_recipe << hash["description"]
    one_recipe << hash["instructions"]
    recipe_arrays << one_recipe
  end
  recipe_arrays
end


def create_array_of_ingredients
  ingredient_hashes =
    db_connection do |conn|
      conn.exec('SELECT ingredients.name AS ingredients, recipes.name AS recipe FROM ingredients JOIN recipes ON recipes.id = ingredients.recipe_id')
    end
  ingredient_hashes = ingredient_hashes.to_a
  ingredient_arrays = []
  ingredient_hashes.each do |hash|
    one_ingredient = []
    one_ingredient << hash["recipe"]
    one_ingredient << hash["ingredients"]
    ingredient_arrays << one_ingredient
  end
  ingredient_arrays
end


get "/" do

  erb :index
end

get "/recipes" do
  @recipes = create_array_of_recipe_names_ids
  erb :recipes
end

get "/recipes/:id" do
  @recipes = nil
  @ingredients = nil
  create_array_of_recipe_names_ids.each do |array|
    if array[1] == params[:id]
      @recipes = array
      recipe_ingred = []
      create_array_of_ingredients.each do |arrays|
        if array[0] == arrays[0]
        recipe_ingred << arrays[1]
        end
      end
      @ingredients = recipe_ingred
    end
  end
  erb :recipe_page
end
