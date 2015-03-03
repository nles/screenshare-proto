$ ->
  peer = null
  videoElem = $("#screen-video")

  # # REFACTOR: move to teleportscreen.js
  initPeerConnection = (id) ->
    peer = new Peer id, { host: 'scpeerjs.ymme.info', path: '/', port: 9292, secure: true, debug: 0, config:
      # Pass in optional STUN and TURN server for maximum network compatibility
      'iceServers': [
        {url: 'stun:stun.l.google.com:19302'}
        {url: "stun:stun.l.google.com:19302"},
        {url: "stun:stun1.l.google.com:19302"},
        {url: "stun:stun2.l.google.com:19302"},
        {url: "stun:stun3.l.google.com:19302"},
        {url: "stun:stun4.l.google.com:19302"},
        {url: "stun:23.21.150.121"},
        {url: "stun:stun01.sipphone.com"},
        {url: "stun:stun.ekiga.net"},
        {url: "stun:stun.fwdnet.net"},
        {url: "stun:stun.ideasip.com"},
        {url: "stun:stun.iptel.org"},
        {url: "stun:stun.rixtelecom.se"},
        {url: "stun:stun.schlund.de"},
        {url: "stun:stunserver.org"},
        {url: "stun:stun.softjoys.com"},
        {url: "stun:stun.voiparound.com"},
        {url: "stun:stun.voipbuster.com"},
        {url: "stun:stun.voipstunt.com"},
        {url: "stun:stun.voxgratia.org"},
        {url: "stun:stun.xten.com"}
      ]
    }
    #peer.on "open", ->
      #$("#identifier").val peer.id
    return peer

  uniqueToken = ->
    s4 = (-> Math.floor(Math.random() * 0x10000).toString 16)
    return s4() + "" + s4() + "" + s4()

  getIdentifier = ->
    return $("#identifier").val()

  # ####
  # view screen
  # # REFACTOR: move to teleportscreen.js
  window['viewScreen'] = ->
    identifier = getIdentifier()
    peer = initPeerConnection(uniqueToken())

    conn = peer.connect(identifier)
    peer.on "call", (call) ->
      call.answer null
      call.on "stream", (remoteStream) ->
        $('#remote-video').prop('src', URL.createObjectURL(remoteStream));

  $("#share-step-1").on 'click', ->
    $('#share-modal').foundation('reveal', 'open');

  $("#share-step-2").on 'click', ->
    identifier = $("#share-identifier").val().split("/").pop()
    return if identifier is ""
    peer = initPeerConnection identifier
    TeleportScreen.initScreenShare
      success: (stream) ->
        $('#share-modal').foundation('reveal', 'close');
        $('#sharing').show()
        $('#share-step-1').hide()
        $('#stop-sharing').show()
        link = $('#sharing a')
        link.attr('href',link.attr('href')+"/"+identifier)
        $('#sharing .id-placeholder').text(identifier)

        peer.on "connection", (conn) ->
          conn.on "open", ->
            call = peer.call(conn.peer, stream)
            return

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
    ival = input.val()
    ending = ival.split("/").pop().trim()
    ending = ending.replace(/[^a-zA-Z0-9-_]/g, '')
    ending = "" if ival.length > 5 and TeleportScreen.serviceUrl.indexOf(ending) isnt -1
    beginningValue = TeleportScreen.serviceUrl+"/"
    #beginningIntact = ival.substr(0,beginningValue.length) is beginningValue
    #unless beginningIntact
    unless ival is input.attr('data-previous-share-identifier')
      input.val(beginningValue+ending)

  $("#new-random-url").click ->
    generateRandomUrl()


  # init
  generateRandomUrl()
  Ladda.bind('#share-step-1', { timeout: 2000 } );
  #$('#share-modal').foundation('reveal', 'open');
