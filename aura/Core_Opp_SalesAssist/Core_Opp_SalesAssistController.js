({
	doInit: function(component, event, helper) {
        //component.set("v.spinner",true);
		helper.getEOLData(component, event, helper);
        
	},
    //fetch the url when popup is opened
    openPopUp: function(component, event, helper) {
        component.set("v.urlParams","");
        helper.showSpinner(component, event, helper);
        component.set("v.source", "opportunity_page");
		helper.getURL(component, event, helper);
        component.set("v.isLoaded", false);
	},
    //close the popup
    closeModel: function(component, event, helper) {
		component.set("v.isModalOpen", false);
	},    
})