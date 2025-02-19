

class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
      # binding.pry
    end
    render(
      status: :ok,
      json: data.as_json(
        only: [:title, :overview, :release_date, :image_url, :id, :inventory, :external_id],
      ),
    )
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  def create
    movie = Movie.find_by(title: params[:title])
    if movie
      if movie.inventory
        movie.inventory += 1
      else
        move.inventory = 1
      end
    else
      movie = Movie.new movie_params
      movie.inventory = 1
    end

    successful = movie.save

    if successful
      render(
        status: :ok,
        json: movie.as_json(
          only: [:title, :overview, :release_date, :image_url, :id, :inventory, :external_id],
        ),
      )
    else
      render status: :bad_request, json: { errors: movie.errors.messages }
    end
  end

  private

  def movie_params
    return params.permit(:title, :overview, :inventory, :release_date, :image_url, :external_id)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])

    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
