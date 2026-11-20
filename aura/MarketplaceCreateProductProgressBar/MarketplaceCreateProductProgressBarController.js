({
  doInit : function(component, event, helper) {
    window.addEventListener('resize', $A.getCallback(function() {
      if(component.isValid()) {
        // reset to 0 translate for screensize
        var innerNavigation = component.find('inner-scroll').getElement();
        if (innerNavigation) {
            innerNavigation.style.transform = 'translateX(-' + 0 + 'px)';
            component.set('v.scrollOffset', 0);
            helper.checkPaddleState(component);
        }
      }
    }));

		// needs to be done after render
    if (window.innerWidth < 768) {
  		window.setTimeout($A.getCallback(function() {
  			helper.checkPaddleState(component);
  		}), 500);
    }
	},
  handleActiveChange: function(component, event, helper) {

    if (window.innerWidth < 768){

      if (component.get('v.scrollable')){
        window.setTimeout($A.getCallback(function() {
          var progressStep = component.find('progress-step');
          var element;
          var offset = 0;
          var innerNavigation = component.find('inner-scroll').getElement();

          if (progressStep) {

            progressStep.map(function(elem){
              element = elem.getElement();
              if (element && element.className.indexOf('slds-is-current') > -1) {
                offset = element.offsetLeft;
              }
            });
            if (offset > 15) {
              innerNavigation.style.transform = 'translateX(-' + (offset -15 )+ 'px)';
            }

          }
          helper.scrollTop(component);

        }), 200);
      } else {
        helper.scrollTop(component);
      }
    }

  },

  handlePaddleClick: function(component, event, helper) {
    var direction = event.currentTarget.dataset.direction;
    var outer = component.find('outer').getElement();
    var innerNavigation = component.find('inner-scroll').getElement();
    var scrollOffset = component.get('v.scrollOffset');
    var newScrollOffset;

    var navWidth = innerNavigation.scrollWidth;
    var pageWidth = outer.clientWidth;


    if (direction === 'next') {
       newScrollOffset = scrollOffset + pageWidth;
       newScrollOffset = (newScrollOffset > navWidth - pageWidth) ? (navWidth - pageWidth) : newScrollOffset;

    } else {
      newScrollOffset = scrollOffset - pageWidth;
      newScrollOffset = (newScrollOffset < 0) ? 0 : newScrollOffset
    }

    innerNavigation.style.transform = 'translateX(-' + newScrollOffset + 'px)';
    component.set('v.scrollOffset', newScrollOffset);
  }

})