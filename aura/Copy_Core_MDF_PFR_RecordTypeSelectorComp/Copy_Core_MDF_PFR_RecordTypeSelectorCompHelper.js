({
    // Function Called when the Recordtype does not intialize the Child component 
    // and calls standard record creation page 
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                });
            } else{//else create record under master recordType
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                });
            }
            createRecordEvent.fire();
        } else{
            alert('This event is not supported');
        }
    },
    
    closeModal: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": $A.get("$Label.c.Core_MDF_PFRText")
        });
        homeEvent.fire();
    },
    
    // This function called to get page url and checking for PFR
    getPageUrl: function(component) {
        var sPageURL = decodeURIComponent(window.location.href);
        console.log('page url--'+sPageURL);
        if(sPageURL.includes($A.get("$Label.c.Core_MDF_PFR_URL")) || component.get("v.checkSaveandNew")){
            component.set("v.isPfrUrl", true);
        }
        else if(sPageURL.includes('campaign') || sPageURL.includes('Campaign') || component.get("v.checkSaveandNew")){
            console.log('Here-->');
            //component.set("v.selrecordtype", "012g0000000AAvHAAW");
            //component.set("v.selrecordtypeName", "Intel Partner Alliance");
            //component.set("v.selrecordtypeDeveloperName", "Intel_Partner_Alliance");
            component.set("v.isPfrUrl", true);
        }
    }
    
})