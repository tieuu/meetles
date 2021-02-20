class MeetlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meetle, only: :create_result_station

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
    @meetle.update(activity: @activity) if meetle_params[:activity] != ""
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
    @result_stations = create_result_stations
    render :show
  end

  private

  def meetle_params
    params.require(:meetle).permit(:stations, :activity)
  end

  def set_meetle
    @meetle = Meetle.find(params[:id])
  end

  def create_result_stations
    @stations = @meetle.locations.map do |loc|
      loc.station.name
    end
    if @stations.size == 2
      fake_results = ['sugamo', 'sengoku', 'hakusan']
    elsif @stations.size == 3
      fake_results = ['sugamo', 'nakai', 'akebonobashi']
    end
    fake_results = fake_results.map { |station| Station.where(name: station).first }
    @result_stations = fake_results.map do |station|
      ResultStation.create(meetle: @meetle, vote: 0, station: station)
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
    'hakusan': {
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
    'hakusan': {
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
    'akebonobashi': {
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
    'akebonobashi': {
      fee: 280,
      duration: 35
    }
  }
}
