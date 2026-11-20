({

  callServerFromReduxAction: function(self, component, auraMethodName, params, returnSFObject) {
    // params = JSON.parse(JSON.stringify(params)); // NOTE? Is this necessary?

    if (self.get('v.debug')) {
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
        var status = response.getState();
        if (status === "SUCCESS") {
          var returnValue = response.getReturnValue();
          returnValue = returnSFObject === true ? returnValue : JSON.parse(returnValue);

          if (self.get('v.debug')) {
            console.log('SERVER RESPONSE AuraMethod: ' + auraMethodName +
            (returnSFObject ? ' (APEX object)' : ' (JSON)'), returnValue);
          }
          resolve(returnValue);
          self.destroy();

        } else if (status === "INCOMPLETE") {
          // do something?
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.error(errors[0].message);
              reject(errors[0].message);
              self.destroy();
            };
          }
        } else {
          reject('Unknown error.');
          self.destroy();
        }
      });
      $A.enqueueAction(action);
    });
  },

})