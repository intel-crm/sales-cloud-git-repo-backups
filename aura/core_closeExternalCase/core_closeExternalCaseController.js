({
    myAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();		
    },
    
    handleClick : function (component, event){
        var msg = ' {' +
            '             "type" : "text",' + 
            '             "text" : "\\nCustomer would like to close this request."' +
            '       }';
        var action = component.get("c.getExternalID");
        action.setParams({ recordId : component.get("v.recordId")});
        action.setCallback(this, function(response)
                           {
                               var ExternalId = response.getReturnValue();
                               var action2 = component.get("c.postToChatter");
                               action2.setParams({ recordId : ExternalId,
                                                  postText: msg,
                                                  isComment: false});
                               $A.enqueueAction(action2);
                               location.reload();
                           })
        $A.enqueueAction(action);
    }
})