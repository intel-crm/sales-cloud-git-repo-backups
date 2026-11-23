({
	doInit : function(component, event, helper) {
		var recId = component.get("v.recordId") ;
 		console.log('recId >>>>>'+ recId);
        
        var url = window.location.href;
        console.log('url '+url);
        
        //event.preventDefault();
        /*var fields = event.getParam('fields');
        console.log('fields :: '+ fields);
        fields.Core_Status__c = 'INACTIVE';
        console.log(fields.Core_Status__c);*/
        //component.find('myform').submit(fields); 
        
    	//$A.get('e.force:closeQuickAction').fire();
        component.set("v.lineItemRecord.Id", recId);
        component.set("v.lineItemRecord.Core_Status__c", 'INACTIVE');
    component.find("lineItemRec").saveRecord($A.getCallback(function(saveResult) {
        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            alert("Save completed successfully.");
        } else if (saveResult.state === "INCOMPLETE") {
            component.set("v.recordSaveError","User is offline, device doesn't support drafts.");
        } else if (saveResult.state === "ERROR") { 
            var errMsg = "";
            // saveResult.error is an array of errors, 
            // so collect all errors into one message
            for (var i = 0; i < saveResult.error.length; i++) {
                errMsg += saveResult.error[i].message + "\n";
            }
            component.set("v.recordSaveError", errMsg);

        } else {
            component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
              JSON.stringify(saveResult.error));
        }
    }));
	}
})