class MeetlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meetle, only: %i[show update create_result_station]

  def index
    @meetle = Meetle.new
  end

  def show
    @user = current_user
    @result_stations = @meetle.result_stations
    # @result_stations.each do |station|
    #   picture_location_1 = URI.open('https://res.cloudinary.com/deumrs4dd/image/upload/v1615288857/Meetle/Image_from_iOS_4_ggy6wm.jpg')

    #   station.photo.attach(io: number_1, filename: 'number_1.png', content_type: 'image/png')
    #   station.photo.save
    # end
    @markers_locations = []

    @result_stations.reject { |result| result.station.latitude.nil? }.each_with_index do |result, index|
      @markers_locations << {
        lat: result.station.latitude,
        lng: result.station.longitude,
        name: Station.find(result.station_id).name,
        type: "Destination",
        info: "destination_station",
        image_url: "https://res.cloudinary.com/deumrs4dd/image/upload/v1615288857/Meetle/#{index+1}.jpg"
      }
    end

    @markers_users = []
    @meetle.locations { |result| result.station.latitude.nil? }.each do |result|
      @markers_users << {
        lat: result.station.latitude,
        lng: result.station.longitude,
        name: User.find(result.user_id).name,
        # type: "#{User.find(result.user_id).name}'s location",
        image_url: Cloudinary::Utils.cloudinary_url(User.find(result.user_id).photo.key)
      }
    end
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
    @activity = meetle_params[:activity]
    @meetle.update(activity: @activity) if meetle_params[:activity].present?
    if meetle_params[:stations].present?
      @station = Station.find(meetle_params[:stations])
      if current_user.locations.where(meetle: @meetle).exists?
        @location = Location.find_by(user: current_user, meetle: @meetle)
        @location.update(station: @station)
      else
        @location = Location.new(station: @station, user: current_user, meetle: @meetle)
        @location.save
      end
      create_result_stations
      @markers_locations = []
      @meetle.result_stations.reject { |result| result.station.latitude.nil? }.each_with_index do |result, index|
        @markers_locations << {
          lat: result.station.latitude,
          lng: result.station.longitude,
          name: Station.find(result.station_id).name,
          type: "Destination",
          info: "destination_station",
          image_url: "https://res.cloudinary.com/deumrs4dd/image/upload/v1615288857/Meetle/#{index+1}.jpg"
        }
      end
      @markers_users = []
      @meetle.locations { |result| result.station.latitude.nil? }.each do |result|
        @markers_users << {
          lat: result.station.latitude,
          lng: result.station.longitude,
          name: User.find(result.user_id).name,
          type: "#{User.find(result.user_id).name}'s location",
          image_url: Cloudinary::Utils.cloudinary_url(User.find(result.user_id).photo.key)
        }
      end
      set_meetle
      @updated_location = { partial: render_to_string(partial: "partials/location"),
                            coordinates: { locations: @markers_locations, users: @markers_users },
                            resultcontainer: render_to_string(partial: "partials/resultcontainer", locals: {meetle: @meetle}) }
      MeetleChannel.broadcast_to(@meetle, @updated_location)
    end
    respond_to do |format|
      format.html { redirect_to meetle_path(@meetle) }
      format.js
    end
    # redirect_to meetle_path(@meetle)
  end

  private

  def meetle_params
    params.require(:meetle).permit(:stations, :activity, :result_stations)
  end

  def set_meetle
    @meetle = Meetle.find(params[:id])
  end

  def create_result_stations
    meetle_location = @meetle.stations
    results = ResultStation.get_three_fairest_stations(meetle_location) if meetle_location.size >= 2

    unless results.nil?
      ResultStation.where(meetle: @meetle).each { |result| result.destroy } if @meetle.result_stations.exists?
      results.each do |res|
        res_sta = ResultStation.create(meetle: @meetle, station: res.first)
        res.last.each do |fee|
          Fare.create(station: fee.first, result_station: res_sta, fee: fee.last)
        end
      end
    end
  end
end
