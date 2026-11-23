({
	checkObjectPermission : function(component, event, helper) {
        /*
        var action1 = component.get("c.getPFRDetails");
        action1.setParams({
            "recordId" : component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var pfrObj = response.getReturnValue();
            console.log('PFR OBJ - '+JSON.stringify(pfrObj));
            if($A.get("$Label.c.Core_MDF_IPA_RecordType") == pfrObj.RecordType.DeveloperName) {
                //alert('Cannot clone IPA Activities.');
                component.set("v.showErrorOnIPAClone", true);
            }
        });
        $A.enqueueAction(action1);*/
        
        var action = component.get("c.checkSObjectCreatePermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "PartnerFundRequest"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            if(permission == true){
            	component.set("v.objectCreatePermission", permission);
            }else{
                component.set("v.showErrorCondition", true);
            }
        });
        $A.enqueueAction(action);
        /*var pageReference = component.get("v.pageReference");
        if(pageReference != null){
            component.set("v.currentRecordId", pageReference.state.c__recordId);
        }*/
        //04-07-2022 
      /*  var recordTypeDevName = component.get("c.getActivityRecordTypeDevname");
        recordTypeDevName.setParams({
            "recordId" : component.get("v.recordId")
        });
        recordTypeDevName.setCallback(this, function(response) {
            var result = response.getReturnValue();            
            	component.set("v.recordtypeDeveloperName", result);
           
        });
        $A.enqueueAction(recordTypeDevName);
       */ 
        var recordTypeDevNamePropInd = component.get("c.getActRecordTypeDevNamePropInd");
        recordTypeDevNamePropInd.setParams({
            "recordId" : component.get("v.recordId")
        });
        recordTypeDevNamePropInd.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                component.set("v.recordtypeName", result.RecordType.Name);
                component.set("v.propBasedIndicator", result.Core_MDF_Proposal_Based_Ind__c); 
                component.set("v.isOutcomeBased", result.Core_MDF_Is_Outcome_Based_Ind__c); 
            }
        });
        $A.enqueueAction(recordTypeDevNamePropInd);
    },
    
    // Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
        var fundRequestRecId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": fundRequestRecId,
            "slideDevName": "detail"
        });
        navEvt.fire();
   	},
    
})