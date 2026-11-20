({
    /*this is reusable function to get the picklist values*/
    fetchPicklistValues : function(component, fieldApiName, elementId) {
        var noValue = component.get("v.noneValue");
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "objName": "OpportunityLineItem",
            "fld": fieldApiName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    opts.push(noValue);
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push(allValues[i]);
                    }
                    component.set("v."+elementId, opts);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveProdAtRisk : function(component, event){
        var action = component.get("c.save");
        action.setParams({
            oppRecord : component.get("v.oppRecord"),
            oppProductList : component.get("v.oppProductList"),
            noValue : component.get("v.noneValue")
        });
        action.setCallback(this, function(response){
            var toastEvent = $A.get("e.force:showToast");
            if(response.getState() === "SUCCESS"){
                toastEvent.setParams({
                    "message": $A.get("$Label.c.Core_AtRisk_Success"),
                    "type": "success"
                });
                window.location.reload()
            }else{
                console.log("error "+JSON.stringify(response.getError()));
                var errors = response.getError();
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errors[0].message,
                    "type": "error"
                });
            }
            toastEvent.fire();
            component.set("v.loaded", true);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    atRiskCheckUncheckLogic : function(component, event, selValue, indx){
        var noValue = component.get("v.noneValue");
        if(selValue == false){
            component.set("v.oppProductList["+indx+"].riskReason1", noValue);
            component.set("v.oppProductList["+indx+"].riskPriority", noValue);
            component.set("v.oppProductList["+indx+"].riskStatus", noValue);
            component.set("v.oppProductList["+indx+"].prodRiskOwner", null);
            component.set("v.oppProductList["+indx+"].riskCreateDate", null);
            component.set("v.oppProductList["+indx+"].riskEndDate", null);
            component.set("v.oppProductList["+indx+"].riskDetail", component.get("v.riskDetailList["+indx+"]"));
        }else{
            component.set("v.oppProductList["+indx+"].riskStatus", "New");
            component.set("v.oppProductList["+indx+"].riskCreateDate", new Date());
        }
        var productList = [];
        productList = component.get("v.oppProductList");
        var prodAtRiskCount = 0;
        for(var i=0; i<productList.length; i++){
            if(productList[i].atRisk == true){
                prodAtRiskCount = prodAtRiskCount + 1;
                i = productList.length;
            }
        }
        if(prodAtRiskCount == 0){
            component.set("v.oppRecord.Core_At_Risk__c", false);
        }else{
            component.set("v.oppRecord.Core_At_Risk__c", true);
        }
    },
    
    throwErrorMsg : function(component, event, toastType, toastMsg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": toastMsg,
            "type": toastType,
            "duration": 10000
        });
        toastEvent.fire();
    }
})