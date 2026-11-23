({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getCount");
        action.setCallback(this,function(response){
            var UserPermissionTotalCountMapArray = [];
            var UserPermissionTotalCountMap=response.getReturnValue()
            for ( var key in UserPermissionTotalCountMap ) {
                UserPermissionTotalCountMapArray.push({value:UserPermissionTotalCountMap[key], key:key});
            }
            component.set("v.displayCountOfPsetsProfsUsers",UserPermissionTotalCountMapArray);
        });
        $A.enqueueAction(action);
    }
})