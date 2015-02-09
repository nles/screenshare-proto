$ ->
  peer = null
  videoElem = $("#screen-video")

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
    id = $("#identifier").val()
    return uniqueToken() if id is ""
    return id

  # ###
  # open peer connection and set identifier
  $("#identifier").keyup (e) ->
    if e.keyCode is 13
      console.log uniqueToken()

  # ####
  # view screen
  window['viewScreen'] = ->
    identifier = getIdentifier()
    peer = initPeerConnection(uniqueToken())

    conn = peer.connect(identifier)
    peer.on "call", (call) ->
      call.answer null
      call.on "stream", (remoteStream) ->
        $('#remote-video').prop('src', URL.createObjectURL(remoteStream));

  $("#view-btn").on 'click', (-> window['viewScreen']())

  # ####
  # share screen
  initScreenShare = (cb) ->
    getScreenId (error, sourceId, screen_constraints) ->
      # error    == null || 'permission-denied' || 'not-installed' || 'installed-disabled' || 'not-chrome'
      # sourceId == null || 'string' || 'firefox'
      navigator.getUserMedia = navigator.mozGetUserMedia or navigator.webkitGetUserMedia
      console.log screen_constraints
      navigator.getUserMedia screen_constraints, ((stream) ->
        #document.querySelector("video").src = URL.createObjectURL(stream)
        cb(stream)
      ), (error) ->
        console.error error

  $("#share-btn").on 'click', ->
    identifier = getIdentifier()
    peer = initPeerConnection identifier
    initScreenShare (stream) ->
      $('#sharing').show()
      $('#sharing .id-placeholder').text(identifier)

      peer.on "connection", (conn) ->
        conn.on "open", ->
          call = peer.call(conn.peer, stream)
          return
