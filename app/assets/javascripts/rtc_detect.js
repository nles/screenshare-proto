var RTCDetect = {};

var screenCallback;

RTCDetect.screen = {
  chromeMediaSource: 'screen',
  getSourceId: function (callback) {
    screenCallback = callback;
    window.postMessage('get-sourceId', '*');
  },
  onMessageCallback: function (data) {
    // "cancel" button is clicked
    if (data == 'PermissionDeniedError') {
      RTCDetect.screen.chromeMediaSource = 'PermissionDeniedError';
      if (screenCallback) return screenCallback('PermissionDeniedError');
      else throw new Error('PermissionDeniedError');
    }

    // extension notified his presence
    if (data == 'rtcmulticonnection-extension-loaded') {
      RTCDetect.screen.chromeMediaSource = 'desktop';
    }

    // extension shared temp sourceId
    if (data.sourceId) {
      RTCDetect.screen.sourceId = data.sourceId;
      if (screenCallback) screenCallback(RTCDetect.screen.sourceId);
    }
  },
  getChromeExtensionStatus: function (callback) {
    // https://chrome.google.com/webstore/detail/screen-capturing/ajhifddimkapgcifgcodmmfdlknahffk
    var extensionid = 'ajhifddimkapgcifgcodmmfdlknahffk';

    var image = document.createElement('img');
    image.src = 'chrome-extension://' + extensionid + '/icon.png';
    image.onload = function () {
      RTCDetect.screen.chromeMediaSource = 'screen';
      window.postMessage('are-you-there', '*');
      setTimeout(function () {
        if (RTCDetect.screen.chromeMediaSource == 'screen') {
          callback('installed-disabled');
        } else callback('installed-enabled');
      }, 2000);
    };
    image.onerror = function () {
      callback('not-installed');
    };
  }
};

function captureSourceId() {
  // check if desktop-capture extension installed.
  RTCDetect.screen.getChromeExtensionStatus(function (status) {
  });
}
