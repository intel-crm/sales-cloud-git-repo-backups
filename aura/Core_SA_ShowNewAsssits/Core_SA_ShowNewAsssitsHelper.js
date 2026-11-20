({
    //Make an Apex call in SAServiceWrapper.getUserSession
    //this function is called from SAShowTop3AssistsController.js
    //this function gathers all the required information and formulates the URL parameters
	getNewAssists : function(component, event, helper) {
        
        //retreive local variable to pass it to Apex function
        var accountId = component.get("v.recordId");
               
        //now call Apex function from SAServiceWrapper Class to get the user specific information
        var action = component.get("c.getUserSessionData");

        //set function param
        action.setParams({
                "accountId" : accountId
            });
   
        console.log('NewAssists-->getNewAssists accountId: ' + accountId);
        
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

                console.log("NewAssists-->getNewAssists call userWWID: " + component.get('v.userWWID'));
                console.log("NewAssists-->getNewAssists call cimId: " + component.get('v.cimId'));
                
                //now call helper method to make mulesoft Service call
        		helper.getNewAssistsServiceCall(component, event, helper);
            }
            else if(state === "INCOMPLETE") {
                // Call was incomplete log an error
                console.log('NewAssists-->getNewAssists call INCOMPLETE');
            }
                else if(state === "ERROR") {
               	// Call was errored out so log an error
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("NewAssists-->getNewAssists Error message: " + 
                                    errors[0].message);
                        
                    } else {
                        console.log("NewAssists-->getNewAssists: Unknown error");
                    }
                }else{
                    console.log('');
                }
        });
        $A.enqueueAction(action);
    },
    
    // Now make an Apex call in SAServiceWrapper.getNewAssists
	getNewAssistsServiceCall : function(component, event, helper) {
        //set the input param values
       	//var cim_id = '10103977'; //component.get("v.cimId");
       	//var wwid =  '1000';  //component.get("v.userWWID");
        var cim_id = component.get("v.cimId");
        var wwid =  component.get("v.userWWID");
        
        console.log("ShowNewAssists-->getNewAssistsServiceCall call userWWID: " + component.get('v.userWWID'));
        console.log("ShowNewAssists-->getNewAssistsServiceCall call cimId: " + component.get('v.cimId'));
        console.log("ShowNewAssists-->getNewAssistsServiceCall call userWWID: " + cim_id);
        console.log("ShowNewAssists-->getNewAssistsServiceCall call cimId: " + wwid);

        //set action - No function param required
        var action = component.get("c.getNewAssists");
        
        //set function param
        action.setParams({
            "cim_id" : cim_id,
            "user_id" : wwid
            });

        //get the response back
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.data', response.getReturnValue());
                console.log("ShowNewAssists-->getNewAssistsServiceCall call Success");
            }
            else if(state === "INCOMPLETE") {
                // do something
                console.log('ShowNewAssists-->getNewAssistsServiceCall call INCOMPLETE');
            }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("ShowNewAssists-->getNewAssistsServiceCall Error message: " + 
                                    errors[0].message);
                        
                    } else {
                        console.log("ShowNewAssists-->getNewAssistsServiceCall Unknown error");
                    }
                }else{
                    console.log('');
                }
        });
        $A.enqueueAction(action);
    },
})