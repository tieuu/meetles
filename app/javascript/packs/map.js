import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

let map;

const allMarkers = [];

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

      const userMarker = new mapboxgl.Marker(element)
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + '</p>'))
        .addTo(map);
      allMarkers.push(userMarker)
    });

    const markersLocations = JSON.parse(mapElement.dataset.markersLocations);
    markersLocations.forEach((marker) => {
      const locationMarker = new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + marker.type + '</p>'))
        .addTo(map);
      allMarkers.push(locationMarker)
    });

    fitMapToMarkers(map, markersUsers);
}

};

const updateMap = (markers) => {
  // const locationElement = document.getElementById('location')

  allMarkers.forEach((marker) => {
    marker.remove();
  })

  const markersUsers = markers.users;
  console.log(markersUsers);
    markersUsers.forEach((marker) => {
      const element = document.createElement('div');
      element.className = 'marker';
      element.style.backgroundImage = `url('${marker.image_url}')`;
      element.style.backgroundSize = 'contain';
      element.style.width = '50px';
      element.style.height = '50px';

      const userMarker = new mapboxgl.Marker(element)
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + marker.type + '</p>'))
        .addTo(map);
      allMarkers.push(userMarker)
    });

    const markersLocations = markers.locations;
    markersLocations.forEach((marker) => {
      const locationMarker = new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(new mapboxgl.Popup({ offset: 25 }) // add popups
        .setHTML('<h3>' + marker.name + '</h3><p>' + marker.type + '</p>'))
        .addTo(map);
      allMarkers.push(locationMarker)
    });

    fitMapToMarkers(map, markersUsers);
};
  // [ ... ]

export { initMapbox, updateMap };
