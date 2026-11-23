({
	doInit: function(cmp,event,helper) {
        var action = cmp.get("c.checkKPIRefreshProcessing");
        action.setParams({ rId : cmp.get("v.recordId") });
 
        
        action.setCallback(this, function(response) {
            var state = response.getState(); console.log('KPI state=='+ state);
            if (state === "SUCCESS") {
                var msg = response.getReturnValue(); console.log('KPI state=='+ JSON.stringify(msg));
                cmp.set("v.lastRefresh",msg.lastRefreshDate);

                if(cmp.get("v.lastRefresh")== 'undefined' || cmp.get("v.lastRefresh")==null || cmp.get("v.lastRefresh")==''){
                    cmp.set("v.showDate", false);
                }
                else{
                    cmp.set("v.showDate", true);
                    cmp.set("v.lastRefresh",msg.lastRefreshDate);
                }
                cmp.set("v.getMsg",msg.msg);
                if(cmp.get("v.getMsg").includes("error")) {
                    cmp.set("v.classname","redClr");
                    
                }
                else if(cmp.get("v.getMsg").includes("progress")){
                    cmp.set("v.classname","blackClr");
                }
            }
            else if (state === "INCOMPLETE") {
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})