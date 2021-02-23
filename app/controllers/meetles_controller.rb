class MeetlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meetle, only: :create_result_station

  def index
    @meetle = Meetle.new
  end

  def show
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @result_stations = create_result_stations
    @user_station = @user.locations.where(meetle: @meetle).first.station
  end

  def create
    @user = current_user
    @meetle = Meetle.new(active: true)
    @meetle.user = @user
    @activity = meetle_params[:activity]
    @meetle.activity = @activity
    if @meetle.save
      redirect_to meetle_path(@meetle)
      @activity = meetle_params[:activity]
      @meetle.update(activity: @activity) if meetle_params[:activity].present?
    else
      render :index
    end
  end

  def update
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @activity = meetle_params[:activity]
    @meetle.update(activity: @activity) if meetle_params[:activity].present?
    if meetle_params[:stations].present?
      @station = Station.find(meetle_params[:stations])
      if current_user.locations.where(meetle_id: @meetle.id).exists?
        @location = Location.where(user: current_user)
        @location.update(station: @station)
      else
        @location = Location.new(station: @station, user: @user, meetle: @meetle)
        @meetle.locations << @location
      end
      redirect_to meetle_path(@meetle)
    end
  end

  private

  def meetle_params
    params.require(:meetle).permit(:stations, :activity)
  end

  def set_meetle
    @meetle = Meetle.find(params[:id])
  end

  def create_result_stations
    @stations = @meetle.locations.map { |loc| loc.station }
    if @stations.size == 2
      fake_results = ResultStation::FAKE_RESULT_2
    elsif @stations.size == 3
      fake_results = ResultStation::FAKE_RESULT_3
    end
    unless fake_results.nil?
      fake_stations = fake_results.first.last.keys.map { |station| Station.where(name: station.to_s).first }
      @result_stations = fake_stations.map do |station|
        ResultStation.create(meetle: @meetle, vote: 0, station: station)
      end
      @stations.each do |loc_station|
        @result_stations.each do |res_station|
          Fare.create(station: loc_station,
                      result_station: res_station,
                      fee: fake_results[loc_station.name.to_sym][res_station.station.name.to_sym][:fee],
                      duration: Time.at(fake_results[loc_station.name.to_sym][res_station.station.name.to_sym][:duration] * 60))
        end
      end
    end
    return @result_stations
  end
end
