({
	 doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        // alert(recID);
        var action = component.get("c.fetchHistory");
        action.setParams({
            recordId: recID
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
           // console.log('data'+JSON.stringify(data));
            component.set("v.mydata", data);
            //console.log('recordname'+JSON.stringify(data));
            // console.log('recordname'+JSON.stringify(data[1].acrHistory));
            // console.log('recordname'+JSON.stringify(data[1].contactName));
            
            
            
        });
        $A.enqueueAction(action);
    }
})