({
	fetchRecordInfo : function(component, event) {
        var action = component.get("c.loadCampaignRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordTypeId", result.RecordTypeId);
                component.set("v.recordTypeName", result.RecordType.Name);
                component.set("v.recordTypeDeveloperName", result.RecordType.DeveloperName);
                component.set("v.campaignStatus", result.Status);
               	component.set('v.mode','edit');
                component.set("v.recordInfoLoaded", true);
                component.set("v.proposalBasedIndicator",result.Core_MDF_Proposal_Based_Ind__c);
            } else if (state === "INCOMPLETE") {
                console.log("Core_MDF_Campaign_EditButton :: helper:fetchRecordInfo: Server request incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_Campaign_EditButton :: helper:fetchRecordInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_Campaign_EditButton :: helper:fetchRecordInfo: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFieldSetInfo:function(component, event) {
        console.log("fetchFieldSetInfo called");
        var action = component.get("c.getRtFieldSetMappings");
        action.setParams({
            objectName : "Campaign",
            recordTypeDeveloperName : component.get("v.recordTypeDeveloperName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.fieldSetName", result);
                component.set('v.fieldSetLoaded','true');                
            } else if (state === "INCOMPLETE") {
                console.log("Core_MDF_Campaign_EditButton :: helper:fetchFieldSetInfo: Server request incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_Campaign_EditButton :: helper:fetchFieldSetInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_Campaign_EditButton :: helper:fetchFieldSetInfo: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event) {
      var action = component.get("c.checkSObjectEditPermission");
        action.setParams({
            "objectName" : "Campaign"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var permission = response.getReturnValue();
                if(component.get("v.proposalBasedIndicator") == false){
                    component.set("v.objectEditPermission", false);
                }else{
                 component.set("v.objectEditPermission", permission);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Core_MDF_Campaign_EditButton :: helper:checkObjectPermission: Server request incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_Campaign_EditButton :: helper:checkObjectPermission: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_Campaign_EditButton :: helper:checkObjectPermission: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    } 
})