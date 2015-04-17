$ ->
  window['viewScreen'] = ->
    TeleportScreen.connectToPeer $("#identifier").val(),
      success: (remoteStream) ->
        $("#loader").hide()
        $("#screen-found").show()
        # when the sender sends a stream, view it in a video element
        $('#remote-video').prop('src', URL.createObjectURL(remoteStream));
      failure: (error) ->
        $("#loader").hide()
        $("#screen-not-found").show()

  $("a.receive-audio-link").on 'click', ->
    $("#audio-not-shared").hide()
    $("#receive-audio").hide()
    $("#waiting-for-audio").show()
    TeleportScreen.connectToPeer $("#identifier").val()+"_AUDIO",
      success: (remoteStream) ->
        # UI CHANGES
        $("#waiting-for-audio").hide()
        $("#mute-audio").show()
        $('#remote-audio').prop('src', URL.createObjectURL(remoteStream));
      failure: ->
        $("#waiting-for-audio").hide()
        $("#audio-not-shared").show()
        #$("#screen-not-found").show()

  $("#mute-audio").on 'click', ->
    $("#remote-audio").prop('muted', true)
    $(@).hide()
    $("#unmute-audio").show()

  $("#unmute-audio").on 'click', ->
    $("#remote-audio").prop('muted', false)
    $(@).hide()
    $("#mute-audio").show()
