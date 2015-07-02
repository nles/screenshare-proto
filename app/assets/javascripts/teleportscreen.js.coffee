@TeleportScreen =
  extensionIsLoaded: false
  serviceUrl: "https://teleportingscreen.com"
  chromeExtensionURL: "https://chrome.google.com/webstore/detail/dbkiolhkacgipikjnjncjifknfmfogom"
  screenConstraints: {}
  randomId: null
  sourceId: null
  audioShared: false
  screenShareCallbacks: {success: null, extensionFailure: null, mediaFailure: null}
  audioShareCallbacks: {success: null, extensionFailure: null, mediaFailure: null}
  getUserMedia: navigator.mozGetUserMedia or navigator.webkitGetUserMedia

  initScreenShare: (callbacks) ->
    @screenShareCallbacks = callbacks
    if @extensionIsLoaded
      window.postMessage('teleport-screen-get-sourceId', '*');
    else
      @screenShareCallbacks.extensionFailure()

  initAudioShare: (callbacks) ->
    @audioShareCallbacks = callbacks
    @getUserAudio()

  waitForConnection: (identifier, stream) ->
    # call back with the stream after we get a connection
    peer = @initPeerConnection identifier
    peer.on "connection", (conn) ->
      conn.on "open", ->
        call = peer.call(conn.peer, stream)
        return

  connectToPeer: (identifier, cbs) ->
    # just use a random id for the viewer
    peer = @initPeerConnection @randomUniqueToken()
    # connect to peer
    conn = peer.connect(identifier)
    # the peer sends the call when we connect
    peer.on "call", (call) ->
      call.answer null
      call.on "stream", (remoteStream) ->
        cbs['success'](remoteStream)
    peer.on "error", (error) ->
      cbs['failure'](error)

  getUserAudio: ->
    navigator.getUserMedia = navigator.getUserMedia or navigator.mozGetUserMedia or navigator.webkitGetUserMedia
    navigator.getUserMedia {audio:true,video:false}, (stream) ->
      # if we get users media
      TeleportScreen.audioShared = true
      TeleportScreen.audioShareCallbacks.success(stream)
    , (error) ->
      # if we do not get users media
      TeleportScreen.audioShareCallbacks.mediaFailure error

  onScreenShared: ->
    navigator.getUserMedia = navigator.getUserMedia or navigator.mozGetUserMedia or navigator.webkitGetUserMedia
    navigator.getUserMedia @screenConstraints, (stream) ->
      # if we get users media
      TeleportScreen.screenShareCallbacks.success(stream)
    , (error) ->
      # if we do not get users media
      TeleportScreen.screenShareCallbacks.mediaFailure error

  setScreenConstraints: (error, sourceId) ->
    @screenConstraints =
      audio: false
      video:
        mandatory:
          chromeMediaSource: (if error then "screen" else "desktop")
          maxWidth: (if window.screen.width > 1920 then window.screen.width else 1920)
          maxHeight: (if window.screen.height > 1080 then window.screen.height else 1080)
          chromeMediaSourceId: @sourceId
        optional: []

  initExtensionInstall: (callback) ->
    #navigator.webkitGetUserMedia &&
    window.chrome &&
    chrome.webstore &&
    chrome.webstore.install &&
    chrome.webstore.install @chromeExtensionURL, ->
      window.location = "/extension-just-installed"
    , ->
      # if inline install fails, we
      # need to visualize a button
      # since window open does not work (popup gets blocked)
      $("#ext-inline-install-link").hide()
      $("#ext-inline-install-failed").show()
      $("#chrome-extension-fallback-link").attr('href',TeleportScreen.chromeExtensionURL)

  # helpers
  initPeerConnection: (id) ->
    peer = new Peer id, { host: 'scpeerjs.ymme.info', path: '/peer/ws/', port: 443, secure: true, debug: 3, config:
      # Pass in optional STUN and TURN server for maximum network compatibility
      'iceServers': [
        {url: 'stun:stun.l.google.com:19302'}
        {url: "stun:stun.l.google.com:19302"},
        {url: "stun:stun1.l.google.com:19302"},
        {url: "stun:stun2.l.google.com:19302"},
        {url: "stun:stun3.l.google.com:19302"},
        {url: "stun:stun4.l.google.com:19302"},
        {url: "stun:23.21.150.121"},
        #{url: "stun:stun01.sipphone.com"},
        {url: "stun:stun.ekiga.net"},
        #{url: "stun:stun.fwdnet.net"},
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

  randomUniqueToken: ->
    s4 = (-> Math.floor(Math.random() * 0x10000).toString 16)
    return s4() + "" + s4() + "" + s4()

# listen to messages
window.addEventListener "message", (event) ->
  return unless event.origin is window.location.origin

  msg = event.data
  # "cancel" button is clicked
  if msg is 'teleport-screen-PermissionDeniedError'
    throw new Error('PermissionDeniedError');

  # extension loaded
  if msg is 'teleport-screen-extension-loaded'
    TeleportScreen.extensionIsLoaded = true

  # sourceID shared
  if msg.sourceId
    TeleportScreen.sourceId = msg.sourceId
    TeleportScreen.setScreenConstraints()
    TeleportScreen.onScreenShared()
