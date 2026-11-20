({
  callServer: function(component, auraMethodName, params, returnRawResponse) {
    params = JSON.parse(JSON.stringify(params));

    if (component.get('v.debug')) {
      console.log('SERVER REQUEST AuraMethod: ' + auraMethodName, params);
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
          console.log("response::");
          console.log(response.getReturnValue());

        if (status === "SUCCESS") {
          var returnValue = response.getReturnValue();
          returnValue = returnRawResponse === false ? returnValue : JSON.parse(returnValue);

          if (component.get('v.debug')) {
            console.log('SERVER RESPONSE AuraMethod: ' + auraMethodName +
            (returnRawResponse ? ' (APEX object)' : ' (JSON)'), returnValue);
          }
          
          
          //console.log('component---inAPI--->'+returnValue.component);
          resolve(returnValue);
            /*if(auraMethodName != "fetchOfferingDetail"){
          		component.destroy();
            }*/

        } else if (status === "INCOMPLETE") {
          // do something?
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.error(errors[0].message);
              reject(errors[0].message);
              component.destroy();
            };
          }
        } else {
          reject('Unknown error.');
          component.destroy();
        }
      });
      $A.enqueueAction(action);
    });
  },
})