class ResultStationsController < ApplicationController
  def update
    @result_station = ResultStation.find(params[:id])
    current_user.favorite(@result_station)
    @result_station.save
    # redirect_to meetle_path(@result_station.meetle)
    @upvote = {}
    ResultStation.where(meetle: @result_station.meetle).each do |result_station|
      @upvote[result_station.id] = result_station.favoritors.count
    end
    MeetleChannel.broadcast_to(
      @result_station.meetle,
      { upvote: @upvote }
    )
  end

  private

  def result_station_params
    params.permit(:voted)
  end
end
