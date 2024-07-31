let map;
let geocoder;
let markers = [];

function initMap() {
  console.log("initMap called");
  geocoder = new google.maps.Geocoder();
  
  const france = { lat: 46.603354, lng: 1.888334 };
  
  map = new google.maps.Map(document.getElementById("map"), {
    zoom: 6,
    center: france,
  });

  if (document.getElementById('search-input')) {
    document.getElementById('search-input').addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        performSearch();
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', function() {
  if (typeof google === 'object' && typeof google.maps === 'object') {
    initMap();
  } else {
    const script = document.createElement('script');
    script.src = `https://maps.googleapis.com/maps/api/js?key=AIzaSyCA4aUHK_Zd40CQFJLr5VYF_HOfTT-hSGM&libraries=places`;
    script.async = true;
    script.defer = true;
    script.onload = initMap;
    document.head.appendChild(script);
  }

  const searchButton = document.getElementById('search-button');
  if (searchButton) {
    searchButton.addEventListener('click', performSearch);
  }
});

// ... le reste de votre code ...