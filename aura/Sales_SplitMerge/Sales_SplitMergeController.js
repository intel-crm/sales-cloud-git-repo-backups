({
    Split_Seats_New : function( cmp, event, helper ) {
        var actionAPI = cmp.find("quickActionAPI");
      
        var args = { actionName : "Sales_License__c.Split_Seats_New", 
                     entityName : "Sales_License__c",
                    };
        actionAPI.setActionFieldValues(args).then(function() {
            actionAPI.invokeAction(args);
        }).catch(function(e) {
            console.error(e.errors);
        });
    }
})