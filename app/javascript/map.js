let map;

function initMap(){

  //位置情報取得
  navigator.geolocation.getCurrentPosition(function (position) {
    LatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    const lat = position.coords.latitude;
    const lng = position.coords.longitude;

    //隠しフィールドに位置情報を設定
    const latField = document.getElementById('latitude');
    const lngField = document.getElementById('longitude');
    if (latField) latField.value = lat;
    if (lngField) lngField.value = lng;

    //取得した位置情報を中心に表示
    map = new google.maps.Map(document.getElementById('map'),{
      center: LatLng,//上で設定した中心
      zoom: 15//ズームの調整
    });
  });
}