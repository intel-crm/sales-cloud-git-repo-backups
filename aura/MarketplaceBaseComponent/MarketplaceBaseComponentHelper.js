({

  // Helper Utility Functions for Subcomponents

  callServer: function(component, auraMethodName, params, returnRawResponse) {
    //params = JSON.parse(JSON.stringify(params)); // NOTE: is this necessary?

    if (component.get('v.__debugMode')) {
      console.log('SERVER REQUEST AuraMethod: ' + auraMethodName, JSON.parse(JSON.stringify(params)));
    }
    return new Promise(function(resolve, reject) {

      var action = component.get("c." + auraMethodName);
      if (!action) {
        console.warn('Action not available on controller... ' + auraMethodName);
        return;
      }

      if (params) action.setParams(params);

      action.setCallback(this, function(response) {
          var status = response.getState();        if (status === "SUCCESS") {
              var returnValue = response.getReturnValue();
              if(returnRawResponse==undefined)
                  returnRawResponse=true;
              returnValue = returnRawResponse === true ? returnValue : JSON.parse(returnValue);
              
              if (component.get('v.__debugMode')) {
            console.log('SERVER RESPONSE AuraMethod: ' + auraMethodName +
            (returnRawResponse ? ' (APEX object)' : ' (JSON)'), returnValue);
          }
          resolve(returnValue);

        } else if (status === "INCOMPLETE") {
          // do something?
          console.log("INCOMPLETE:");
        } else if (status === "ERROR") {
            console.log("error:");
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.error(errors[0].message);
              reject(errors[0].message);

            };
          }
        } else {
          reject('Unknown error.');

        }
      });
      $A.enqueueAction(action);
    });
  },

})