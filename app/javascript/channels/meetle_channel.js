import consumer from "./consumer";
import { updateMap } from "../packs/map";

const initMeetleCable = () => {
  const locationsContainer = document.getElementById('location');
  const resultContainer = document.getElementById('resultcontainer');

  if (locationsContainer) {
    const id = locationsContainer.dataset.meetleId;

    consumer.subscriptions.create({ channel: "MeetleChannel", id: id }, {
      received(data) {
        console.log(data);
        locationsContainer.innerHTML = data.partial;
        resultContainer.innerHTML = data.resultcontainer;
        // updateMap(data.coordinates);
        initMapbox();
      },
    });
  }
}

export { initMeetleCable };
