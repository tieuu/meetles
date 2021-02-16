class MeetlesController < ApplicationController
  before_action :authenticate_user!
  def index
    @meetle = Meetle.new
  end

  def show
    @meetle = Meetle.find(params[:id])
    @user = current_user
  end

  def create
    @user = current_user
    @station = Station.find(station_params[:stations])
    @meetle = Meetle.new(active: true)
    @location = Location.new(station: @station, user: @user, meetle: @meetle)
    @meetle.user = @user

    if @meetle.save && @location.save

      redirect_to meetle_path(@meetle)
    else
      render :index
    end
  end

  def update
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @station = Station.find(station_params[:stations])
    if current_user.locations.exists?
      @location = Location.where(user: current_user)
      @location.update(station: @station)
    else
      @location = Location.new(station: @station, user: @user, meetle: @meetle)
      @meetle.locations << @location
    end
  end
end



private

def station_params
  params.require(:meetle).permit(:stations)
end
