({
    //this method will be used to fetch all the matching exceptions from the Case record
    loadExceptionList: function(component, event, helper) {
        // call the helper function for fetch contact from apex class 
        helper.onLoad(component, event);
    },
    //For creating ECMs for selected records 
    saveECMRecords: function(component, event, helper) {
        component.set("v.disableSave", true);
        helper.saveECMsHelper(component, event); 
    },
    //this method will be used to close the modal popup
    closeModal: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    //Enable or disable Save button
    /* enableSaveButton: function(component, event, helper){
        
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        alert("Here-->"+selectedRec);
        if (selectedRec == true) {
            component.set("v.disableSave", false);
        } 
    }, */
    // For count the selected checkboxes. 
    checkboxSelect: function(component, event, helper) {        
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.checked");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1 
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
        if(getSelectedNumber > 0){
            component.set("v.disableSave", false);
        }
        else{
            component.set("v.disableSave", true);
        }
    },
})