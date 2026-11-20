(function () {
    'use strict';

    var BANNER_ID      = 'sales-qualifier-banner';
    var DISMISS_BTN_ID = 'sales-qualifier-dismiss';
    var NO_SHOW_CB_ID  = 'sales-qualifier-no-show';

    function hideBanner() {
        var el = document.getElementById(BANNER_ID);
        if (el) { el.style.display = 'none'; }
    }

    function saveHidePreference() {
        if (typeof sqBannerSaveHide === 'function') {
            sqBannerSaveHide();
        }
    }

    function onDismiss() {
        hideBanner();

        var checkbox = document.getElementById(NO_SHOW_CB_ID);
        if (checkbox && checkbox.checked) {
            saveHidePreference();
        }
    }

    function init() {
        var dismissBtn = document.getElementById(DISMISS_BTN_ID);
        if (dismissBtn) {
            dismissBtn.addEventListener('click', onDismiss);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
