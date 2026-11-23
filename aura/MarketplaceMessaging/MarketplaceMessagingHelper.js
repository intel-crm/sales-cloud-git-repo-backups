({
  scrollEnd: function(component) {
		window.setTimeout(function(){
			var chatComponent = component.find("slds-chat").getElement();
    	chatComponent.scrollTop = chatComponent.scrollHeight;
		}, 250);    
  },
  scrollPageUp: function(component, helper) {
    var chatComponent = component.find("slds-chat").getElement();
    chatComponent.style.scrollBehavior = 'smooth';
    var newScroll = chatComponent.scrollTop - chatComponent.offsetHeight;
    newScroll = newScroll < 0 ? 0 : newScroll;
    chatComponent.scrollTop = newScroll;
  },
    
    getCurrentUserName:function(component) {
        return new Promise(function(resolve, reject) {
            var action = component.get("c.getUserName");
            //action.setParams({ recordId: component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var response = response.getReturnValue();
                    resolve(response);
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error saving form: " + errors[0].message);
                        reject(errors[0].message);
                    } else {
                        reject("Unknown error.");
                    }
                } else {
                    console.error("Unknown error.");
                    reject("Unknown error.");
                }
            });
            $A.enqueueAction(action);
        });
    },
  loadMessagingData: function(component) {
      
    return new Promise(function(resolve, reject) {
      var action = component.get("c.getMessage");
      action.setParams({ recordId: component.get("v.recordId"),
                        isPartner: component.get("v.isPartner")	});
      action.setCallback(this, function(response) {
        var status = response.getState();
        if (status === "SUCCESS") {
          var response = JSON.parse(response.getReturnValue());
          resolve(response);
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors && errors[0] && errors[0].message) {
            console.error("Error saving form: " + errors[0].message);
            reject(errors[0].message);
          } else {
            reject("Unknown error.");
          }
        } else {
          console.error("Unknown error.");
          reject("Unknown error.");
        }
      });
      $A.enqueueAction(action);
    });
	},
	postMessage: function(component, message) {
        
        console.log("postmessage:",message);
    return new Promise(function(resolve, reject) {
      var action = component.get("c.postMessage");
			action.setParams({recordId: component.get("v.recordId"),
                              message: message,
                              isPartner: component.get("v.isPartner")});
      action.setCallback(this, function(response) {
        var status = response.getState();
        if (status === "SUCCESS") {
          resolve(response);
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors && errors[0] && errors[0].message) {
            console.error("Error saving form: " + errors[0].message);
            reject(errors[0].message);
          } else {
            reject("Unknown error.");
          }
        } else {
          console.error("Unknown error.");
          reject("Unknown error.");
        }
      });
      $A.enqueueAction(action);
    });
  }
});