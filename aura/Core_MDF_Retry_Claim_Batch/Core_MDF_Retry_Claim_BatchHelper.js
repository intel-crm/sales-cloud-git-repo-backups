({
	checkFailedClaimBatchRecords : function(component, helper){
		 var action = component.get("c.checkClaimBatchRecordStatus");
        action.setParams({"claimBatchOrClaimBatchRecId" : component.get("v.recordId")});
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null){
                var wrapInst = response.getReturnValue();
                if(wrapInst.exceptionDetails == null){
                    if(wrapInst.isClaimBatchRecStatusFailed){
                        component.set("v.isClaimBatchRecStatusFailed",true);
                    }
                    else{
                        component.set("v.errorMsg","None of the batch records are in Failed status");
                    }
                }
                else{
                    component.set("v.errorMsg",$A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                }
            }
        });
        $A.enqueueAction(action);
	},
    
     updateClaimBatchRecStatus : function(component, helper) {
         
     }
})