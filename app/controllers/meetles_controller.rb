
class MeetlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meetle, only: :create_result_station

  def index
    @meetle = Meetle.new
  end

  def show
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @result_stations = @meetle.result_stations || create_result_stations
    @markers = []
    @meetle.result_stations.reject { |result| result.station.latitude.nil? }.each do |result|
      @markers << {
        lat: result.station.latitude,
        lng: result.station.longitude
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
    @meetle = Meetle.find(params[:id])
    @user = current_user
    @activity = meetle_params[:activity]
    @meetle.update(activity: @activity) if meetle_params[:activity].present?
    if meetle_params[:stations].present?
      @station = Station.find(meetle_params[:stations])
      if current_user.locations.where(meetle_id: @meetle.id).exists?
        @location = Location.where(user: current_user, meetle: @meetle)
        @location.update(station: @station)
      else
        @location = Location.new(station: @station, user: @user, meetle: @meetle)
        @meetle.locations << @location
      end
      @meetle.save
      MeetleChannel.broadcast_to(@meetle, render_to_string(partial: "partials/location"))
    end
    redirect_to meetle_path(@meetle)
  end

  private

  def meetle_params
    params.require(:meetle).permit(:stations, :activity, :result_stations)
  end

  def set_meetle
    @meetle = Meetle.find(params[:id])
  end

  def create_result_stations
    stations = @meetle.locations.map do |loc|
      loc.station.name
    end

    fake_results = nil
    if stations.size == 2
      fake_results = ['sugamo', 'sengoku', 'shinjuku']
    elsif stations.size == 3
      fake_results = ['sugamo', 'nakai', 'ueno']
    end
    unless fake_results.nil?
      fake_results = fake_results.map { |station| Station.where(name: station).first }
      if @meetle.result_stations.exists?
        ResultStation.where(meetle: @meetle).each { |result| result.destroy }
      end
      result_stations = fake_results.map do |station|
        ResultStation.create(meetle: @meetle, voted: false, station: station)
      end
    end
  end
end

FAKE_RESULT_2 = {
  'yurakucho': {
    'sugamo': {
      fee: 200,
      duration: 22
    },
    'sengoku': {
      fee: 220,
      duration: 15
    },
    'shinjuku': {
      fee: 220,
      duration: 13
    }
  },
  'itabashihoncho': {
    'sugamo': {
      fee: 220,
      duration: 8
    },
    'sengoku': {
      fee: 220,
      duration: 10
    },
    'shinjuku': {
      fee: 220,
      duration: 11
    }
  }
}

FAKE_RESULT_3 = {
  'yurakucho': {
    'sugamo': {
      fee: 200,
      duration: 22
    },
    'nakai': {
      fee: 350,
      duration: 39
    },
    'ueno': {
      fee: 280,
      duration: 15
    }
  },
  'itabashihoncho': {
    'sugamo': {
      fee: 220,
      duration: 8
    },
    'nakai': {
      fee: 330,
      duration: 50
    },
    'akebonobashi': {
      fee: 280,
      duration: 26
    }
  },
  'meguro': {
    'sugamo': {
      fee: 200,
      duration: 26
    },
    'nakai': {
      fee: 320,
      duration: 26
    },
    'ueno': {
      fee: 280,
      duration: 35
    }
  }
}
