$ ->
  loadTwitterSDK()

renderTweetButtons = ->
  $('.twitter-share-button').each ->
    button = $(this)
    button.attr('data-url', document.location.href) unless button.data('url')?
    button.attr('data-text', document.title) unless button.data('text')?
  twttr.widgets.load()

loadTwitterSDK = ->
  url = '//platform.twitter.com/widgets.js'
  $.getScript url, ->
    renderTweetButtons
