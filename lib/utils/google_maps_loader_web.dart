import 'dart:html' as html;

void initGoogleMapsWeb(String apiKey) {
  if (html.document.getElementById('google-maps-sdk') != null) {
    return;
  }
  final script = html.ScriptElement()
    ..id = 'google-maps-sdk'
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places,marker&v=beta'
    ..async = true
    ..defer = true;
  html.document.head?.append(script);
}
