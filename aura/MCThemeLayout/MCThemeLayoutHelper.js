({

  initializeWindowResizeEventHandler: function (component) {
    let helper = this;
    window.addEventListener('resize', $A.getCallback(function () {
      if (component.isValid()) {
        let currentScreenSize = helper.getCurrentScreenSize();
        let prevScreenSize = component.get('v.appState.Settings.currentScreenSize');
        if (currentScreenSize != prevScreenSize) {
          helper.dispatch(component, 'changeSetting', {
            type: 'changeSetting',
            currentScreenSize: currentScreenSize
          });
        }
      }
    }
    ));
  },

  getCurrentScreenSize: function () {
    // SET UP RESPONSIVE BREAKPOINTS HERE
    // one breakpoint at 768px
    return window.innerWidth < 768 ? 'mobile' : 'desktop';
  },

})