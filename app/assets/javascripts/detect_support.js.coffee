$ ->
  $("#has-support-body").show() # try to make sure something shows up
  hasRTC = Modernizr.getusermedia
  isChrome = $.browser.chrome
  if hasRTC && isChrome
    $("#has-support-body").show()
    $("#no-support-body").hide()
  else
    $("#has-support-body").hide()
    $("#no-support-body").show()
