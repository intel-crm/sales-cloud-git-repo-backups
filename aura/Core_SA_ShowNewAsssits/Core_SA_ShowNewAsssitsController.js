({
    //Do Init is called each time the lightning component loads
  	doInit: function(component, event, helper) {
    	//Make an Apex call in SAServiceWrapper.getUserSession
    	//this helper method gathers all the required information and formulates the URL parameters
    	helper.getNewAssists(component, event, helper);
    },
 
    //this function is called from the componet when user clicks on the Title of Number of Unread assists
    gotoURL : function(component, event, helper) {
        //Set the Session data
       //Set CIM ID value
        window.sessionStorage.setItem('sCimId', component.get("v.cimId")); 
        console.log("scimId:" + component.get("v.cimId"));
        
        //Set Account ID value
        window.sessionStorage.setItem('sAccountId', component.get("v.recordId")); 
        console.log("sAccountId:" + component.get("v.recordId"));
        
        //Set the target source value to track the user click
        var rectarget = event.currentTarget;
        var source = rectarget.getAttribute("data-source"); 
       	console.log("source:" + source);
        window.sessionStorage.setItem('sSource', source); 
       	var pageSource = source;
        
        //now navigate to the Assists Custom Tab
        var urlEvent = $A.get("e.force:navigateToURL");
        
        //get Tab URL from a custom label
        //var url = $A.get("$Label.c.Core_SA_TabURL")
        var url = $A.get("$Label.c.Core_SA_TabURL") + "?c__AccountId="+ component.get("v.recordId")+"&c__CimId="+component.get("v.cimId")+"&c__src="+ pageSource;

        urlEvent.setParams({
            "url": url,
            "isredirect":true,
        });
        urlEvent.fire();        
    },
});