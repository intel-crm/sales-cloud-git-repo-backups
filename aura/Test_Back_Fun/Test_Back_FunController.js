({
    doInit:function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
        
       let navService = component.find("navService");
            navService.navigate({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "PCC_Rebate_Claim_Stage__c", 
                    actionName: "home"
                }
            });
    }
     
   
})