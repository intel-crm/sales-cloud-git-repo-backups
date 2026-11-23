({
    //Do Init is called each time the lightning component loads
    doInit: function(component, event, helper) {
        var width = component.get('v.width');
        var size = width === 'LARGE' ? 4 : (width === 'MEDIUM' ? 4 : 12);
        component.set('v._cellSize', size);
    	//this helper method gathers all the required information and formulates the URL parameters
    	helper.getTop3Assists(component, event, helper);
    },
    
    //this function is called from the componet when user clicks on the Title of Number of Unread assists
    gotoURL : function(component, event, helper) {
        //Set the Session data
        //Set CIM ID value
        //
        window.sessionStorage.setItem('sCimId', encryptedCimId); 
        console.log("scimId:" + component.get("v.cimId"));
        
        //Set Account ID value
        window.sessionStorage.setItem('sAccountId', accountId); 
        console.log("sAccountId:" + component.get("v.recordId"));

        //Set the target source value to track the user click        
        var rectarget = event.currentTarget;
        var source = rectarget.getAttribute("data-source"); 
        var pageSource = source;     	
        console.log("source:" + pageSource);
        
       //Set the Assists ID the user clicked on        
        window.sessionStorage.setItem('sSource', source); 
        var source = rectarget.getAttribute("data-aid");
        var aid = source;
       	console.log("aid:" + aid);

       //Set the Assists index value the user clicked on        
        window.sessionStorage.setItem('sAid', source); 
        var source = rectarget.getAttribute("data-key"); 
        source = parseInt(source)  + 1;
        window.sessionStorage.setItem('sIndex', source);
        var index = source;
       	console.log("key:" + index);

        //get Tab URL from a custom label
        var url = $A.get("$Label.c.Core_SA_TabURL") + "?c__AccountId="+ component.get("v.recordId")+"&c__CimId="+component.get("v.cimId")+"&c__src="+ pageSource+"&c__aid="+ aid+"&c__index="+ index;
        var urlEvent = $A.get("e.force:navigateToURL"); 
        urlEvent.setParams({
            "url": url,
            "isredirect":true,
        });
        urlEvent.fire();        
    }
});