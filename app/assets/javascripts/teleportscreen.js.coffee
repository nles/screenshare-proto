@TeleportScreen =
  extensionIsLoaded: false
  serviceUrl: "https://rtc.ymme.info"
  screenConstraints: {}
  randomId: null
  sourceId: null
  callbacks: {success: null, extensionFailure: null, mediaFailure: null}

  initScreenShare: (callbacks) ->
    @callbacks = callbacks
    if @extensionIsLoaded
      window.postMessage('teleport-screen-get-sourceId', '*');
    else
      @callbacks.extensionFailure()

  onScreenShared: ->
    navigator.getUserMedia = navigator.mozGetUserMedia or navigator.webkitGetUserMedia
    navigator.getUserMedia @screenConstraints, (stream) ->
      # if we get users media
      TeleportScreen.callbacks.success(stream)
    , (error) ->
      # if we do not get users media
      TeleportScreen.callbacks.mediaFailure error

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

  initPluginInstall: (callback) ->
    navigator.webkitGetUserMedia &&
    window.chrome &&
    chrome.webstore &&
    chrome.webstore.install &&
    chrome.webstore.install 'https://chrome.google.com/webstore/detail/dbkiolhkacgipikjnjncjifknfmfogom', ->
      location.reload()
    , ->
      # if inline install fails, we
      # need to visualize a button:
      # <a id="chrome-plugin-link" target="_blank" href="https://chrome.google.com/webstore/detail/teleporting-screen/dbkiolhkacgipikjnjncjifknfmfogom">Chrome Plugin</a>
      # since window open does not work (popup gets blocked)

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
