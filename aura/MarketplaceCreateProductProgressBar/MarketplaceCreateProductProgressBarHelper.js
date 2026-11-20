({
  checkPaddleState: function(component) {
    if (component.find('inner-scroll')) {
      var innerNavigation = component.find('inner-scroll').getElement();
      var outer = component.find('outer').getElement();

      var navWidth = innerNavigation.scrollWidth;
      var pageWidth = outer.clientWidth;

      component.set('v.scrollable', (pageWidth != navWidth))

    }
  },
  scrollTop: function(component){
    var isSmoothScrollSupported = 'scrollBehavior' in document.documentElement.style;
    if (isSmoothScrollSupported){
      window.scrollTo({
        top: 0,
        behavior: 'smooth',
      });
    } else {
      // usually IE only
      window.scrollTo(0, 0);
    }
  }
})