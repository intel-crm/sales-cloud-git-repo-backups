({
	doInit : function(component, event, helper) {
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
	navigateToPreference : function(component, event, helper) {  
          event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "preferencepage"  
            },  
            state: {  
                sampleVar: 'This is sample text'  
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);  
    },
    navigateToHome : function(component, event, helper) {  
          event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "home"  
            }
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);  
    },
    handleLogout : function(component, event, helper) {
       window.location.replace('https://intel--crmdevcase.sandbox.my.site.com/IPS/secur/logout.jsp?retUrl=https%3A%2F%2Fmycommunity-domain.com%2Flogin')
    }
})