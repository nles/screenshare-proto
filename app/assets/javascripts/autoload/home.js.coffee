$ ->
  peer = null
  videoElem = $("#screen-video")

  $("#ext-inline-install-link").one 'click', ->
    loadingText = $(@).attr('data-loading-text')
    $(@).attr("href","#").text(loadingText)
    TeleportScreen.initExtensionInstall()

  $("#share-step-1").on 'click', ->
    #$(@).ladda("start")
    $('#share-modal .no-extension, #share-modal .extension-installed').hide()
    if TeleportScreen.extensionIsLoaded
    then $('#share-modal .no-extension').show()
    else $('#share-modal .extension-installed').show()
    $('#share-modal').foundation('reveal', 'open');

  $("#faq-button").on 'click', ->
    $('#faq-modal').show()
    $('#faq-modal').foundation('reveal', 'open');

  $("#feedback-button").on 'click', ->
    $('#feedback-modal').show()
    $('#feedback-modal').foundation('reveal', 'open');

  $("#share-step-2").on 'click', ->
    identifier = $("#share-identifier").val().split("/").pop()
    return if identifier is ""
    TeleportScreen.initScreenShare
      success: (stream) ->
        $('#share-modal').foundation('reveal', 'close');
        $('#sharing').show()
        $('#share-step-1').hide()
        $('#stop-sharing').show()
        $('#share-audio').show()
        link = $('#sharing a')
        link.attr('href',link.attr('href')+"/"+identifier)
        $('#sharing .id-placeholder').text(identifier)
        # start waiting for the viewer to connect
        TeleportScreen.waitForConnection(identifier,stream)

      mediaFailure: (error) ->
        console.log(error)

      extensionFailure: ->
        console.log("failure")

  $("#share-audio").on 'click', ->
    return if TeleportScreen.audioShared
    buttonElem = $(@)
    buttonElem.ladda()
    buttonElem.ladda('start')
    buttonTextElem = $(@).find(".button-text")
    buttonTextElem.text(buttonElem.attr('data-waiting-for-permission-text'))
    #setTimeout (-> audioShareLoad.start()), 2000
    TeleportScreen.initAudioShare
      success: (stream) ->
        buttonElem.ladda('stop')
        buttonElem.find(".button-text").text(buttonElem.attr('data-sharing-success-text'))
        identifier = $('#sharing .id-placeholder').text()+"_AUDIO"
        # start waiting for the viewer to connect
        TeleportScreen.waitForConnection(identifier, stream)

      mediaFailure: (error) ->
        buttonElem.ladda('stop')
        buttonElem.find(".button-text").text(buttonElem.attr('data-sharing-failed-text'))
        console.log(error)

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
