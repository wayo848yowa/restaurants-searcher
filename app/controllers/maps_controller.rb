class MapsController < ApplicationController
  def index; end
end

def search
  @search_term = params[:looking_for]
  @restaurant_results = Restaurant.search(@search_term)
end

def show
  @restaurant_info = Restaurants.details(params[:id])
end

