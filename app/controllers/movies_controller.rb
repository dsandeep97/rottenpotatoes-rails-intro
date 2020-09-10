class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect_page = false
    if params[:sort_criteria]
        session[:sort_criteria] = params[:sort_criteria]
    elsif session[:sort_criteria]
        redirect_page = true
        params[:sort_criteria] = session[:sort_criteria]
    end

    @all_ratings = Movie.uniq.pluck(:rating)
    @checked_ratings = @all_ratings
    if params[:ratings]
        session[:ratings] = params[:ratings]
    elsif session[:ratings]
        redirect_page = true
        params[:ratings] = session[:ratings]
    end

    if params[:ratings] != nil
        @checked_ratings = params[:ratings].keys
    end

    if redirect_page
        flash.keep
        redirect_to movies_path(:sort_criteria => session[:sort_criteria], :ratings => session[:ratings])
    end

    @movies = Movie.with_ratings(@checked_ratings).order(params[:sort_criteria])
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
