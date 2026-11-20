({
    handleClose: function(component, event, helper){
	    //component.set("v.appName", event.getParam("appName"));
	    console.log('PBS Aura Console Navigation ');
	    var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
	} 
})