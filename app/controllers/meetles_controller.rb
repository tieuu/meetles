class MeetlesController < ApplicationController
  before_action :authenticate_user!
  def index
    @meetle = Meetle.new
  end

  def show
    @meetle = Meetle.find(params[:id])
    @user = current_user
    # @current_location = current_user.locations.where(meetle_id: @meetle.id)
    # @current_station = Station.find(@current_location.id)
    @meetle_location
  end

  def create
    @user = current_user
    @station = Station.find(meetle_params[:stations])
    @meetle = Meetle.new(active: true)
    @location = Location.new(station: @station, user: @user, meetle: @meetle)
    @meetle.user = @user
    @activity = meetle_params[:activity]
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
    @activity = meetle_params[:activity]
    if meetle_params[:activity] != ""

      @meetle.update(activity: @activity)
      render :show

    end
    if meetle_params[:stations] != ""
      @station = Station.find(meetle_params[:stations])

      if current_user.locations.where(meetle_id: @meetle.id).exists?
        @location = Location.where(user: current_user)
        @location.update(station: @station)
      else
        @location = Location.new(station: @station, user: @user, meetle: @meetle)
        @meetle.locations << @location
      end
    end
  end
end

private

def meetle_params
  params.require(:meetle).permit(:stations, :activity)
end
