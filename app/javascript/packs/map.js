import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

const fitMapToMarkers = (map, markers) => {
  const bounds = new mapboxgl.LngLatBounds();
  markers.forEach(marker => bounds.extend([ marker.lng, marker.lat ]));
  map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
};

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  if (mapElement) { // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
    const map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/streets-v10'
    });
    const markersUsers = JSON.parse(mapElement.dataset.markersUsers);
    markersUsers.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + marker.type + '</p>'))
        .addTo(map);
    });
    fitMapToMarkers(map, markersUsers);
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


  // [ ... ]


export { initMapbox };
