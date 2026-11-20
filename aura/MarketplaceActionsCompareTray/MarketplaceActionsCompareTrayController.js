({
	getActions : function() {
    return {

      // +=+=+=+ COMPARE TRAY ACTIONS A-Z HERE +=+=+=+
			clearCompareTray: function(params) {
				return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'clearCompareTray' }));
        };
			},

			clearCompareTrayNotification: function(params) {
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'clearCompareTrayNotification' }));
        };
      },

			showCompareTrayNotification: function(params) {
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'showCompareTrayNotification' }, params));
        };
      },

      toggleCompareTrayItem: function(params) { 
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'toggleCompareTrayItem' }, params));
        };
      },
// IPA2.0 + US TWC4497-1631
        // fetchMultipleOfferingsAction:function(params){
        //     return function(dispatch, getState, callServer) {
        //         return callServer('fetchMultipleOfferings', { offeringIds:params.offeringIds, 
        //                                              bEditOffering:params.bEditOffering,
        //                                              bViewOffering:params.bViewOffering,
        //                                              bCompareOffering:params.bCompareOffering,
        //                                              langCode:params.langCode
        //                                             },true).then(function(response) {
        //             dispatch({ type: 'fetchMultipleOfferingDetails', response: response });
        //         })
        //     };
        // },
        

    };
	}

})