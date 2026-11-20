({
    getData : function(component, event, helper) {
        var action = component.get("c.getData");
        
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var resp = response.getReturnValue();
                debugger;
                component.set("v.isOppInactive",resp.isOppInactive);
                component.set("v.isVendor",resp.isVendorInactive);                
                if(resp.isOppInactive || resp.isVendorInactive){
                    var title = $A.get("$Label.c.Core_Toast_Title_Inactive_Account");
                    var msg = $A.get("$Label.c.Core_Toast_Message_Inactive_Account");
                    helper.toastMessage(component, "error", title, msg);
                }
            }
            else{
                /*debugger;
                var msg = "";
                console.log("Error on loading forecast record "+JSON.stringify(response.getError()));
                alert(JSON.stringify(response.getError()[0].fieldErrors));
                if(JSON.stringify(response.getError()[0].fieldErrors) !== null){
                    alert("1");
                    msg = JSON.stringify(response.getError()[0].fieldErrors.AccountId[0].message);
                }
                if(msg == null && JSON.stringify(response.getError()[0].pageErrors.length)>0){
                    alert("2");
                	msg = JSON.stringify(response.getError()[0].pageErrors[0].message);
                }
                helper.toastMessage(component, "error", msg);*/
            }
            
        });
        $A.enqueueAction(action);
       helper.get6QPSData(component,helper);
    },

    //Added By Hira
       get6QPSData : function(component,helper){
        var action = component.get("c.get6QPSData");
        
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('Resp'+result);
                component.set("v.quarterMisALign",result);
                if(result){
                    var title = "";
                    var msg = $A.get("$Label.c.Core_6QPS_Quarter_Error");
                    console.log('title');
                    this.toastMessage(component, "error", title, msg);
                }
            }
            else{
               const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.toastMessage(component, "error","Error", errors[0].message,"dismissible");
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    toastMessage : function(component, toastType, title, message,mode) {
        var toastEvent = $A.get("e.force:showToast");
        var toastTitle = "";
        var type = "";
        if(!(mode == "dismissible")){
            mode="sticky"
        }
        if(toastType == "success"){
            toastTitle = "Success!";
        }else{
            toastTitle = "Error!";
            type = "error";
        }
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "type": toastType,
            "mode": mode
        });
        toastEvent.fire();
    }
})