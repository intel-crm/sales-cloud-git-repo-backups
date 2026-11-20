({
    init: function(component, event, helper) {
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.searchAccount(component, event, "Corporate");
        helper.populatePicklists(component, event);
        helper.populateCountryPicklists(component, event);
    },
    
    setContactId : function(component, event, helper) {
        var emailAddress = event.getParam("emailAddress");
        //var isClearEntitlements = event.getParam("isClearEntitlements");
        //alert('here');
        component.set('v.email', emailAddress);    
    },

    onRadioSelect: function(component, event, helper){
        var radioSelected = event.getSource().get("v.text");
        component.set("v.loaded",true);
        helper.searchAccount(component, event, radioSelected); 
    },
    
    save: function(component, event, helper){
        //alert('save');
        component.set("v.loaded",true);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.saveCont(component, userId);       
    },
    
    cancel:function(component, event, helper){
        var address = $A.get("$Label.c.Core_GrantAccessUrl");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
           // "url" : "/grant-access"
           "url": address
        });
        urlEvent.fire();  
    },
    
})