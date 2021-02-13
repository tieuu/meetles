class MeetlesController < ApplicationController
  before_action :authenticate_user!
  def index
    @meetle = Meetle.new
  end

  def show

    @meetle = Meetle.find(params[:id])

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
end

private

def station_params
  params.require(:meetle).permit(:stations)
end
