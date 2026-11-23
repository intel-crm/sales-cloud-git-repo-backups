({
	// Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "PartnerFundRequest"
            });
            homeEvent.fire();
   	},
    
    // Function called on the click of the Edit button
    handleClick : function (cmp, event, helper) {
        console.log("alert");
        cmp.set("v.CheckEdit",true);
        //.body.style.overflow = "hidden";
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) {
      //Fetching Record Type Developer Name
      console.log("Here-->0"+component.get("v.recordId"));
        if(component.get("v.recordId")!=null){
            var recordtypeAction = component.get("c.getActivityRecordTypeDevname");
            //pass the record Id name here for which
            //to fetch developername
            recordtypeAction.setParams({
                "recordId" : component.get("v.recordId")
            });
            recordtypeAction.setCallback(this, function(res) {
                var state = res.getState();
                if (state === "SUCCESS") {
                    var recordTypeDevName = res.getReturnValue();
                    console.log("Here-->"+recordTypeDevName);
                    component.set("v.recordtypeDeveloperName",recordTypeDevName);
                    // if(recordTypeDevName != "Core_MDF_Intel_Partner_Alliance"){
                   if(recordTypeDevName != $A.get("$Label.c.Core_MDF_Retail_Program")){
                        var action = component.get("c.checkSObjectEditPermission");
                        //pass the object name here for which you want
                        //to fetch check the permission
                        action.setParams({
                            "objectName" : "PartnerFundRequest"
                        });
                        action.setCallback(this, function(response) {
                            var permission = response.getReturnValue();
                            component.set("v.objectEditPermission", permission);
                        });
                        $A.enqueueAction(action);
                    } 
                }else{
                    var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                    helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
                //  }
            });
            $A.enqueueAction(recordtypeAction);
        }
    },
   
})