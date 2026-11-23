({
    doInit:function(component,event, helper){
        var action  = component.get('c.getAccountId');
        action.setParams({acmId:component.get('v.recordId')});
        action.setCallback(this, function(response){            
            var state = response.getState();
            if(state == "SUCCESS"){
                var value = response.getReturnValue();
                if(value!=null && value!=undefined){
                    component.set('v.accountId',value);
                }
            }
        });
        $A.enqueueAction(action);
    },
    redirect: function (component,event,helper){        
        window.location.href = window.location.origin+'/'+component.get('v.accountId');
    }
})