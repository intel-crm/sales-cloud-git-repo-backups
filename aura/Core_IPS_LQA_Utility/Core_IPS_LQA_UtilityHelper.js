({
	saveRecord : function(component) {
		//Start--Replace var with let or const--static code violation fix--harsha--14/06/21
        //var recId = component.get("v.recordId"); 
        const recId = component.get("v.recordId"); 
        //var src =  component.get("v.sourceBtn");
        const src =  component.get("v.sourceBtn");
        component.find("caseRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {                
                component.set("v.spinnerOn", false);
                if(src == 'Close Case'){
                    //var surveyPageURL = $A.get("$Label.c.Core_IPS_Case_Survey_Page_URL");
                    const surveyPageURL = $A.get("$Label.c.Core_IPS_Case_Survey_Page_URL");
                    //var surveyPgURL = surveyPageURL  + '' + recId ;
                    const surveyPgURL = surveyPageURL  + '' + recId ;	
                    //var urlEvent = $A.get("e.force:navigateToURL");
                    const urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": surveyPgURL
                    });
                    urlEvent.fire();
                } else {
                    //var toastEvent = $A.get("e.force:showToast");
                    const toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Case Record Saved Successfully.',
                        duration:' 1000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            } else if (saveResult.state === "INCOMPLETE") {
                component.set("v.recordSaveError","User is offline, device doesn't support drafts.");
                component.set("v.spinnerOn", false);
            } else if (saveResult.state === "ERROR") { 
                //var errMsg = "";
                let errMsg = "";
                //for (var i = 0; i < saveResult.error.length; i++) {
                for (let i = 0; i < saveResult.error.length; i++) {
                //End--Replace var with let--static code violation fix--harsha
                    errMsg += saveResult.error[i].message + "\n";
                }
                component.set("v.recordSaveError", errMsg);
                component.set("v.spinnerOn", false);
                
            } else {
                component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                component.set("v.spinnerOn", false);
            }
        }));
	}
})