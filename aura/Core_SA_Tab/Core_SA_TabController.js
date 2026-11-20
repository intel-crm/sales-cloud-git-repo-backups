({
    //do INIT is called each time when the lightning component is intialized or loaded.
    doInit: function(component, event, helper) {
        if (component.get("v.pageRefresh") == false)
        {
            console.log("Assists Tab-->doInit-->page load (No refresh)");
//        	alert ('Init-->No Refresh: ');
    	}
        else if (component.get("v.pageRefresh") == true)
        {
            console.log("Assists Tab-->doInit-->page load (refresh)");
            //component.set("v.pageRefresh", false);
//        	alert ('Init-->refresh: ');
    	}
        //call an helper method
    	//this helper method gathers all the required information and formulates the URL parameters
        helper.getUserSession(component, event, helper);
    },
    refreshPage : function(component, event, helper) {
        console.log("Assists Tab-->refreshPage-->change");
//        alert('Change: ');
        component.set("v.pageRefresh", true);
        window.sessionStorage.clear();
 		var action = component.get('c.doInit');
        $A.enqueueAction(action);
    },
})