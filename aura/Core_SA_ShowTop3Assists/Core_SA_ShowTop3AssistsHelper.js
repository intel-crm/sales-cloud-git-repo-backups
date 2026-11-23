({
    //Make an Apex call in SAServiceWrapper.getUserSession
    //this function is called from SAShowTop3AssistsController.js
    //this function gathers all the required information and formulates the URL parameters
	getTop3Assists : function(component, event, helper) {
        
        //retreive local variable to pass it to Apex function
        var accountId = component.get("v.recordId");
               
        //now call Apex function from SAServiceWrapper Class to get the user specific information
        var action = component.get("c.getUserSessionData");

        //set function param
        action.setParams({
                "accountId" : accountId
            });
   
        console.log('Top3Assists-->getUserSession accountId: ' + accountId);
        
        //set action call back
        action.setCallback(this, function(response) {
            var state = response.getState();
            //if the call is successful and userSessionData is received. 
            if (state === "SUCCESS") {
                
                component.set('v.userSessionData', response.getReturnValue());
                //Return value is an object of type SAUserSessionDefination class

                //Retrieve the wwid Property
            	component.set('v.userWWID', component.get('v.userSessionData.wwid'));
                //Retrieve the cimId Property
                component.set('v.cimId', component.get('v.userSessionData.cimId'));

                console.log("Top3Assists-->getTop3Assists call userWWID: " + component.get('v.userWWID'));
                console.log("Top3Assists-->getTop3Assists call cimId: " + component.get('v.cimId'));
                
                //now call helper method to make mulesoft Service call
        		helper.getTop3AssistsServiceCall(component, event, helper);
            }
            else if(state === "INCOMPLETE") {
                // Call was incomplete log an error
                console.log('Top3Assists-->getTop3Assists call INCOMPLETE');
            }
                else if(state === "ERROR") {
               	// Call was errored out so log an error
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Top3Assists-->getTop3Assists Error message: " + 
                                    errors[0].message);
                        
                    } else {
                         console.log("Top3Assists-->Unknown error");
                    }
                }else{
                    console.log('');
                }
        });
        $A.enqueueAction(action);
    },
    
    // Now make an Apex call in SAServiceWrapper.getTop3Assist
	getTop3AssistsServiceCall : function(component, event, helper) {

        //set the input param values
        //var cim_id = '10103977'; //component.get("v.cimId");
        //var wwid =  '1000';  //component.get("v.userWWID");
       	var cim_id = component.get("v.cimId");
       	var wwid =  component.get("v.userWWID");
        
        //check the input values
        console.log("getTop3AssistsServiceCall call userWWID: " + component.get('v.userWWID'));
        console.log("getTop3AssistsServiceCall call cimId: " + component.get('v.cimId'));
        console.log("getTop3AssistsServiceCall call cim_id: " + cim_id);
        console.log("getTop3AssistsServiceCall call wwid: " + wwid);
        
        //set action - No function param required
        var action = component.get("c.getTop3Assists");
        
        //set function param
        action.setParams({
            "cim_id" : cim_id,
            "user_id" : wwid
            });
        
        //get the response back
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state -> ',state);
                component.set('v.data', response.getReturnValue());
                console.log("getTop3Assists-->JSON call Success" + '{!v.data.total_count}');
            }
            else if(state === "INCOMPLETE") {
                // do something
                console.log('getTop3Assists-->JSON call INCOMPLETE');
            }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("getTop3Assists-->Error message: " + 
                                    errors[0].message);
                    } else {
                        console.log("getTop3Assists-->Unknown error");
                    }
                }else{
                    console.log('');
                }
        });
        $A.enqueueAction(action);
    },
})