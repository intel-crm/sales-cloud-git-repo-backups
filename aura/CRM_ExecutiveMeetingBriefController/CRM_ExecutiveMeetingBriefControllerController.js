({
	doInit: function (component, event, helper) {
        debugger;
        var recordId = component.get("v.recordId");
        console.log("Record ID: " + recordId);
        
       
        
        /*var pageReference = component.get("v.pageReference");
        if (pageReference) {
            var accountId = pageReference.state.c__accountId;
            if (accountId) {
                // Use the accountId as needed
                console.log("Account ID: " + accountId);
            } else {
                console.error("Account ID is not available in the pageReference state.");
            }
        } else {
            console.error("PageReference is not available.");
        } */      
        
    },

    handleClose: function (component, event, helper) {
        console.log('##rec'+component.get("v.recordId"));
         console.log('AURA CLOSE');
    //$A.get("e.force:refreshView").fire();
    $A.get("e.force:closeQuickAction").fire();
    console.log('AURA CLOSE END');
    }
});