({
  handleToggleContactLinks : function(component, event, helper) {
    var modalOpen = component.get("v.toggle");
    var overlay = component.find('shareOverlay');

    modalOpen = !modalOpen;
    component.set("v.toggle", modalOpen);
    // have to manually change it here as transitions wont work if we do it inline
    if (modalOpen) {
      $A.util.removeClass(overlay, 'slds-hide');
      window.setTimeout(
        $A.getCallback(function() {
            $A.util.addClass(overlay, 'slds-show');
        }), 5
    );
    } else {
      $A.util.removeClass(overlay, 'slds-show');
      $A.util.addClass(overlay, 'slds-hide');
    }
    event.preventDefault();

  },

  doInit: function(component, event, helper) {
    component.set('v.mapStateToAttributes', function(state) {
			return {
				url: state.shareUrl
			};
		});

    // IE 11 detect
    if (window.navigator.userAgent.indexOf("Trident/7.0") > -1) {
      // ie 11
      component.set('v.isIE11', true);
    }

  },

  handleUrlChange: function(component, event, helper) {
    var url = component.get('v.url');
    var title = component.get('v.title');
    component.set('v.mailto','mailto:?&subject=' + title + '&body=' + title + ' - ' + url);
    component.set('v.linkedin','https://www.linkedin.com/shareArticle?mini=true&url='+ url +'&title=' + title);
    component.set('v.twiter','https://twitter.com/home?status=' + title + ' - ' + url);
  },

  handleCopy : function(component, event, helper) {
    var copyText = component.find('shareUrl').getElement();
    var range = document.createRange();

    if (window.navigator.userAgent.match(/ipad|ipod|iphone/i)) {
      copyText.contentEditable = true;
      copyText.readOnly = false;

      var s = window.getSelection();
      s.removeAllRanges();
      s.addRange(range);
      copyText.setSelectionRange(0, 999999); // A big number, to cover anything that could be inside the element.
    } else {
      copyText.select();
    }
    document.execCommand("copy");
    copyText.blur();
    /* Copy the text inside the text field */
  }
})