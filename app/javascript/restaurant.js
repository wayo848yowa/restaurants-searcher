let currentPosition = null;

// ページ読み込み時に位置情報を取得
window.addEventListener('load', function() {
  getCurrentLocation();
});

function getCurrentLocation() {
  const locationStatus = document.getElementById('location-status');
  const locationCoords = document.getElementById('location-coords');
  const searchBtn = document.getElementById('search-btn');
  const latInput = document.getElementById('lat-input');
  const lngInput = document.getElementById('lng-input');
  
  if (!navigator.geolocation) {
    locationStatus.textContent = '位置情報がサポートされていません';
    locationStatus.style.color = '#d32f2f';
    return;
  }
  
  navigator.geolocation.getCurrentPosition(
    function(position) {
      currentPosition = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude
      };
      
      // 隠しフィールドに位置情報を設定
      latInput.value = currentPosition.latitude;
      lngInput.value = currentPosition.longitude;
      
      locationStatus.textContent = '位置情報を取得しました ✓';
      locationStatus.style.color = '#2e7d32';
      
      locationCoords.textContent = `緯度: ${currentPosition.latitude.toFixed(6)}, 経度: ${currentPosition.longitude.toFixed(6)}`;
      locationCoords.style.display = 'block';
      locationCoords.style.fontSize = '0.9rem';
      locationCoords.style.marginTop = '8px';
      locationCoords.style.color = '#666';
      
      searchBtn.disabled = false;
    },
    function(error) {
      let errorMsg = '';
      switch(error.code) {
        case error.PERMISSION_DENIED:
          errorMsg = '位置情報の利用が拒否されました';
          break;
        case error.POSITION_UNAVAILABLE:
          errorMsg = '位置情報を取得できませんでした';
          break;
        case error.TIMEOUT:
          errorMsg = '位置情報の取得がタイムアウトしました';
          break;
        default:
          errorMsg = '位置情報の取得中にエラーが発生しました';
          break;
      }
      locationStatus.textContent = errorMsg;
      locationStatus.style.color = '#d32f2f';
    },
    {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 300000
    }
  );
}