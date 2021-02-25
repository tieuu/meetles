import consumer from "./consumer";

const initMeetleCable = () => {
  const locationsContainer = document.getElementById('location');
  if (locationsContainer) {
    const id = locationsContainer.dataset.meetleId;

    consumer.subscriptions.create({ channel: "MeetleChannel", id: id }, {
      received(data) {
        locationsContainer.insertAdjacentHTML('beforeend', data);
      },
    });
  }
}

export { initMeetleCable };
