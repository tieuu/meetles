class ResultStationsController < ApplicationController
  def update
    @result_station = ResultStation.find(params[:id])
    current_user.favorite(@result_station)
    @result_station.save
    raise
    redirect_to meetle_path(@result_station.meetle)
  end

  private

  def result_station_params
    params.permit(:voted)
  end
end
