({
    doInit: function(component, event, helper) {
        //Static code violation fix--replace var with let or const--harsha--14/6/21
        //var evt = $A.get("e.force:navigateToComponent");
        
        // const pageReference = component.get("v.pageReference");
        // console.log('minhaj edit comp', pageReference);
        helper.helperMethod(component, event, helper);
        //var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId; 
        console.log('page ref',component.get( "v.pageReference" ) )
        //alert( recordTypeId ); 
        var rTypeIdNameMap = component.get('v.recordTypeName');
        console.log('PBS Aura Init ');
       
        
    },
    /*handleClose: function(component, event, helper){
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
	}*/
})