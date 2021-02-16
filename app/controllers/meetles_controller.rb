class MeetlesController < ApplicationController
  before_action :authenticate_user!
  def index
    @meetle = Meetle.new
  end

  def show
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @current_location = Location.where(user: current_user)
    @meetle_location
  end

  def create
    @user = current_user
    @station = Station.find(station_params[:stations])
    @meetle = Meetle.new(active: true)
    @location = Location.new(station: @station, user: @user, meetle: @meetle)
    @meetle.user = @user
    @activity = station_params[:activity]
    @meetle.activity = @activity

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
    @activity = station_params[:activity]
    @meetle.update(activity: @activity)
    if current_user.locations.exists?
      @location = Location.where(user: current_user)
      @location.update(station: @station)
    else
      @location = Location.new(station: @station, user: @user, meetle: @meetle)
      @meetle.locations << @location
    end
    render :show
  end

end


private

def station_params
  params.require(:meetle).permit(:stations, :activity)
end
