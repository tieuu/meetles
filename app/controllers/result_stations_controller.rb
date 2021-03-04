class ResultStationsController < ApplicationController
  def update
    @result_station = ResultStation.find(params[:id])
    @result_station.update(voted: result_station_params[:voted])
    redirect_to meetle_path(@result_station.meetle)
  end

  private

  def result_station_params
    params.require(:result_station).permit(:voted)
  end
end
