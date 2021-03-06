import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

let map;

const fitMapToMarkers = (map, markers) => {
  const bounds = new mapboxgl.LngLatBounds();
  markers.forEach(marker => bounds.extend([ marker.lng, marker.lat ]));
  map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
};

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  if (mapElement) { // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
    map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/tieuu/ckluml80907cj17l71jqddxac'
    });
    const markersUsers = JSON.parse(mapElement.dataset.markersUsers);
    markersUsers.forEach((marker) => {
        const element = document.createElement('div');
        element.className = 'marker';
        element.style.backgroundImage = `url('${marker.image_url}')`;
        element.style.backgroundSize = 'contain';
        element.style.width = '50px';
        element.style.height = '50px';
        element.style.border = '1px solid black'

      new mapboxgl.Marker(element)
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + '</p>'))
        .addTo(map);
    });
    const markersLocations = JSON.parse(mapElement.dataset.markersLocations);
    markersLocations.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + marker.type + '</p>'))
        .addTo(map);
    });
 fitMapToMarkers(map, markersLocations);
  }

};

const updateMap = (markers) => {
  console.log(markers);
  markers.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .addTo(map);
    });
  fitMapToMarkers(map, markers);
};


  // [ ... ]


export { initMapbox, updateMap };
