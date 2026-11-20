({

  getReducer: function() {
    return function(state, action) {

      // Initial State
      if (!state) {
        // SLDS Breakpoints list
        var bpList = [
          { bp: 'small',   maxWidth: 768 },
          { bp: 'medium',  maxWidth: 1024 },
          { bp: 'large',   maxWidth: 1280 },
          { bp: 'x-large', maxWidth:10000 }
        ];
    		var currentSldsBreakpoint = bpList.find(function(bp) { return (window.innerWidth < bp.maxWidth); }).bp;
        state = {
          currentScreenSize: window.innerWidth < 768 ? 'mobile' : 'desktop',
    			currentSldsBreakPoint: currentSldsBreakpoint,
          previewMode: false
        };
      }

      switch(action.type) {

        case 'changeSetting':
          return Object.assign({}, state, action.settings);

        default:
          return state;
      }
    };
	},

})