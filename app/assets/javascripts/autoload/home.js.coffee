$ ->
  peer = null
  videoElem = $("#screen-video")

  $("#share-step-1").on 'click', ->
    $('#share-modal').foundation('reveal', 'open');

  $("#share-step-2").on 'click', ->
    identifier = $("#share-identifier").val().split("/").pop()
    return if identifier is ""
    TeleportScreen.initScreenShare
      success: (stream) ->
        $('#share-modal').foundation('reveal', 'close');
        $('#sharing').show()
        $('#share-step-1').hide()
        $('#stop-sharing').show()
        link = $('#sharing a')
        link.attr('href',link.attr('href')+"/"+identifier)
        $('#sharing .id-placeholder').text(identifier)
        # start waiting for the viewer to connect
        TeleportScreen.waitForConnection(identifier,stream)

      mediaFailure: (error) ->
        console.log(error)

      extensionFailure: ->
        console.log("failure")

  $("#stop-sharing").on 'click', ->
    window.location.reload()

  generateRandomUrl = ->
    randomness = Math.random().toString(36).slice(-5);
    randomness = randomness.replace(/l/g,"i")
    $('#share-identifier').val(TeleportScreen.serviceUrl+"/"+randomness)

  $('#select-ending').click ->
    input = $('#share-identifier')
    inputVal = input.val()
    input[0].selectionStart = TeleportScreen.serviceUrl.length+1
    input[0].selectionEnd = inputVal.length
    $('#share-identifier').focus()

  $('#select-all').click ->
    $('#share-identifier').select()

  $('#share-identifier').keydown (e) ->
    input = $(@)
    ival = input.val()
    input.attr('data-previous-share-identifier',ival)

  $('#share-identifier').keyup (e) ->
    input = $(@)
    # make sure beginning stays the same
    beginningValue = TeleportScreen.serviceUrl+"/"
    if input.val().substr(0,beginningValue.length) isnt beginningValue
      input.val(beginningValue)
    # set the ending
    ival = input.val()
    ending = ival.split("/").pop().trim()
    ending = ending.replace(/[^a-zA-Z0-9-_]/g, '')
    input.val(beginningValue+ending)

  $("#new-random-url").click ->
    generateRandomUrl()

  $("#language-select select").change ->
    lang = $(@).val()
    window.location = "?lang="+lang

  # init
  generateRandomUrl()
  Ladda.bind('#share-step-1', { timeout: 2000 } );
  #$('#share-modal').foundation('reveal', 'open');
