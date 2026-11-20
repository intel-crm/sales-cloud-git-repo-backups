({
    //ipa 2.0 priyas change for topic event
	/*getPromotionLanguageOptions: function(component,event,helper){
        return new Promise($A.getCallback(function(resolve,reject){
            var action = component.get("c.getPromotionLanguageOptions");
            
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set("v.languageOptions", returnValue);
                    component.set("v.language",returnValue[0].value);
                    
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        }));
    },*///ipa 2.0 priyas change for topic event

    getCloneImages: function(component,event, helper){
        
            var action = component.get("c.getCloneImageToEvents");
            var topicId = component.get("v.recordId");

            action.setParams({
                 "topicId" : topicId
             });

            $A.enqueueAction(action);
            $A.get("e.force:refreshView").fire();
    },
    
    getEventTopicType: function(component,event,helper){
        return new Promise($A.getCallback(function(resolve,reject){
            var action = component.get("c.getEventTopicType");
            var topicId = component.get("v.recordId");

            action.setParams({
                "topicId" : topicId
            });

            action.setCallback(this, function(response) {
                var status = response.getState();

                if (status === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    
                    console.log('returnValue:::', returnValue);
                    
                    if(returnValue==true){
                        component.set("v.eventTopicType", "true");
                    }else {
                        component.set("v.eventTopicType", "false");
                        component.set("v.errorMessage", "Image Upload Feature is available for Event Topic Type only ");
                        
                    }
                    resolve();
                }else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        }));
    },
})