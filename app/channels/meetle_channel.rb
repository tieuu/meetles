class MeetleChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    meetle = Meetle.find(params[:id])
    stream_for meetle
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
