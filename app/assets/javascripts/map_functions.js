function setMap(lon, lat, zoom)
{
  center = new google.maps.LatLng(lon,lat);
  map.setCenter(center);

  map.setZoom(zoom);

  var marker = new google.maps.Marker({
  	position: center,
  	map: map
  });

}

function displayMessage()
{
  alert("Hello World!");
}