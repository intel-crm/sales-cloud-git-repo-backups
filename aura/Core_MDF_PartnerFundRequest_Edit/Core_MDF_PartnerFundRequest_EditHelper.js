({
	fetchRecordInfo : function(component, event) {
        //component.set("v.showSpinner",true);
        var action = component.get("c.loadActivityRecord");
        action.setParams({
            "pfrId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
           
            var state = response.getState();
            if (state == "SUCCESS") {
               
                var result = response.getReturnValue();
               // component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                component.set("v.activityStatus", result.Core_MDF_Fund_Request_Status__c);
               	component.set("v.mode", "edit");              
                component.set("v.proposalBasedIndicator",result.Core_MDF_Proposal_Based_Ind__c);
                component.set("v.startDate",result.Core_MDF_Start_Date__c);
                component.set("v.isOutcomeBased", result.Core_MDF_Is_Outcome_Based_Ind__c);
                //component.set("v.recordInfoLoaded", true);
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                	this.checkForEditAccess(component, event);
                }
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
           // component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);        
    },
    
     checkForEditAccess : function(component, event) {
        var action = component.get("c.checkForEditAccess");
        //var campaignObj =  component.get("v.campaignObj");        
        action.setParams({
            "objectName" : "PartnerFundRequest",
            "recTypeDevloperName" : component.get("v.recordtypeDeveloperName"),
            "status" : component.get("v.activityStatus"),
           	"activityId" : component.get("v.recordId"),
            "proposalBasedIndicator" : component.get("v.proposalBasedIndicator"),
            "startDate" : component.get("v.startDate")
        });
       action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                
               // alert('Inside check for checkForEditAccess');
                var result = response.getReturnValue();
                console.log('hasEditAccess');
                component.set("v.hasEditAccess", result);
               // alert('result' + result);
                if(result==false){       
                       
                    //debugger;         
                    var errMsg = $A.get('$Label.c.Core_MDF_CloneAccessError');     
                    if(!component.get("v.isCommunity")) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error ",
                            type: "error",
                            message: errMsg
                        });
                       toastEvent.fire();
                        setTimeout(function () {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId")
                            },true);
                            navEvt.fire();
                            setTimeout(function () {
                                window.location.reload();
                            }, 1000);  
                        }, 2000);     
                    } else {
                        component.set("v.message", errMsg);
                    }
                }             
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
        });
        $A.enqueueAction(action);
    },
      displaySuccessErrorMsg: function(Message,Title,Type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: Title,
            message:Message,
            type: Type
        });
        toastEvent.fire();
    },
})