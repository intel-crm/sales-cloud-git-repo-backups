({
	// method called to get all details of users in groups
    doInit : function(component, event, helper) {
    	helper.getDetailsOfUsersInGroup(component, event, helper);
    },
    //method called to close quick action when user clicks on Cancel
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})