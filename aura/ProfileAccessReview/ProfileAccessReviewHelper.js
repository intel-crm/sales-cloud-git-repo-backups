({
	callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params != undefined) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            }
        });
        
        $A.enqueueAction(action);
    },
    
    searchFunction: function(component) {
        // Search term
        var term = component.get("v.term");
        // Show all when no filter, or when filter matches label or value
        component.set("v.ObjectList",
                      component.get("v.AllObjectList").filter(
                          item => item.value.match(term)));
    },
    onChange: function (cmp, event) {
    // Retrieve an array of the selected options
    var selectedOptionValue = event.getParam("value");
   }
})