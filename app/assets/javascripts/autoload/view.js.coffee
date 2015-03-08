$ ->
  window['viewScreen'] = ->
    TeleportScreen.connectToPeer $("#identifier").val(),
      success: ->
        $("#loader").hide()
        $("#screen-found").show()
      failure: ->
        $("#loader").hide()
        $("#screen-not-found").show()

