window.onload = ->
  loadFacebookSDK()

loadFacebookSDK = ->
  url = '//connect.facebook.net/en_US/all.js#xfbml=1'
  window.fbAsyncInit = initializeFacebookSDK
  $.getScript url, ->
    FB?.XFBML.parse()

initializeFacebookSDK = ->
  FB.init
    appId     : '1413637072244383'
    channelUrl: 'http://danimal141.net'
    status    : true
    cookie    : true
    xfbml     : true
    version   : 'v2.0'
