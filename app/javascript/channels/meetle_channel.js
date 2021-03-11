import consumer from "./consumer";
import { updateMap } from "../packs/map";
import { scrollToResults } from "../components/autoscroll";

const initMeetleCable = () => {
  const locationsContainer = document.getElementById('location');
  const resultContainer = document.getElementById('resultcontainer');
  const mapContainer = document.getElementById('map')

  if (locationsContainer) {
    const id = locationsContainer.dataset.meetleId;

    consumer.subscriptions.create({ channel: "MeetleChannel", id: id }, {
      received(data) {
        console.log(data.coordinates);
        // console.log(mapContainer.dataset.markersUsers);
        // console.log(mapContainer);
        // initMapbox();
        updateMap(data.coordinates);
        // do that if uvote not there
        if (data.upvote) {
          Object.keys(data.upvote).forEach((id) => {
            document.querySelector(`#card-result-${id} .topright`).innerHTML = `<i class="fas fa-heart"></i> ${data.upvote[id]}`;
          })
        } else {
          locationsContainer.innerHTML = data.partial;
          resultContainer.innerHTML = data.resultcontainer;
          scrollToResults();
        }
      },
    });
  }
}

export { initMeetleCable };
