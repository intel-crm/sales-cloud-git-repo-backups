({
    doInit : function(component, event, helper) {
        let button = component.find("OKbuttonid");
        button.set("v.disabled",true);
        helper.showQuarterField(component, event, helper);
    },
	handleSave : function(component, event, helper) {
        component.set("v.spinner", true);
        debugger;
        var stdate = component.get("v.startDate");
        if(!$A.util.isEmpty(stdate)){
			helper.checkOldFCRecords(component, event, helper);
        }
	},
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isWarningModalOpen", false);
        
    },
    
    handleOk : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.isWarningModalOpen", false);
        helper.saveData(component, event, helper);
    },
    warningPopupYesClick : function(component, event, helper) {
        helper.saveData(component, event, helper);
    },
    warningPopupNoClick : function(component, event, helper) {
        var modal = component.find("woWarningModal");
        $A.util.addClass(modal,"slds-hide");
        let button = component.find("OKbuttonid");
        button.set("v.disabled",false);
        let Cnbutton = component.find("Cancelbuttonid");
        Cnbutton.set("v.disabled",false);
    },
    handleChange : function(component, event, helper) {
        var stdate = component.get("v.startDate");
        if($A.util.isEmpty(stdate)){
            let button = component.find("OKbuttonid");
        	button.set("v.disabled",true);
        }
        else{
            let button = component.find("OKbuttonid");
        	button.set("v.disabled",false);
        }
    },
})