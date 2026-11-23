({
    /*function to call on load of the component*/
	doInit : function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getOpportunityProducts");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "noValue" : component.get("v.noneValue")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                helper.fetchPicklistValues(component, "Core_Risk_Reason1__c", "riskReason1");
                helper.fetchPicklistValues(component, "Core_Risk_Reason2__c", "riskReason2");
                helper.fetchPicklistValues(component, "Core_Risk_Priority__c", "riskPriority");
                helper.fetchPicklistValues(component, "Core_Risk_Category__c", "riskCategory");
                helper.fetchFieldDependency(component, "Core_Risk_Category__c", "Core_At_Risk_Status__c");
                var result = response.getReturnValue();
                component.set("v.oppRecord", result.oppRecord);
                component.set("v.oppProductList", result.oppProductList);
                var statusList = [];
                for(var i=0; i<result.oppProductList.length; i++){
                    statusList.push(result.oppProductList[i].riskStatus);
                }
                component.set("v.oppProductListDummy", statusList);
                if(result.oppRecord.Core_At_Risk_Created_Date__c != undefined && result.oppRecord.Core_At_Risk_Created_Date__c != ''){
                    component.set("v.atRiskCreatedDate", $A.localizationService.formatDate(result.oppRecord.Core_At_Risk_Created_Date__c, "YYYY-MM-DD"));
                }else{
                    component.set("v.atRiskCreatedDate", $A.localizationService.formatDate('', "YYYY-MM-DD"));
                }
                component.set("v.loaded", true);
            }else{
                console.log("Error on fetching opportunity product details : "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
	},
    
    /*function to call on click of at risk checkbox*/
    setAtRiskInOpportunity : function(component, event, helper){
        var selValue = event.getSource().get("v.checked");
        var indx = event.getSource().get("v.tabindex");
        var noValue = component.get("v.noneValue");
        if(selValue == false){
            component.set("v.oppProductList["+indx+"].riskReason1", noValue);
            component.set("v.oppProductList["+indx+"].riskReason2", noValue);
            component.set("v.oppProductList["+indx+"].riskPriority", noValue);
            component.set("v.oppProductList["+indx+"].riskCategory", noValue);
            component.set("v.oppProductList["+indx+"].riskStatus", noValue);
        }else{
            var riskDate = '';
            riskDate = component.get("v.oppRecord.Core_At_Risk_Created_Date__c");
            if(riskDate == undefined || riskDate == ''){
                component.set("v.oppRecord.Core_At_Risk_Created_Date__c", new Date());
                component.set("v.atRiskCreatedDate", $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
            }
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
            component.set("v.oppRecord.Core_At_Risk_Created_Date__c", '');
            component.set("v.atRiskCreatedDate", $A.localizationService.formatDate('', "YYYY-MM-DD"));
        }else{
            component.set("v.oppRecord.Core_At_Risk__c", true);
        }
    },
    
    /*function to call on change of risk category*/
    onRiskCategoryChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var indx = event.getSource().get("v.tabindex");
        var noValue = component.get("v.noneValue");
        var prevValue = component.get("v.oppProductListDummy["+indx+"]");
        if(selValue != noValue){
            var depValues = [];
            depValues = component.get("v.depnedentFieldMap["+selValue+"]");
            var finalValues = [];
            if(selValue == 'Support Requested'){
                finalValues.push(depValues[0]);
                if(prevValue == noValue){
                    finalValues.push(depValues[1]);
                }else if(prevValue == 'In-Progress'){
                    finalValues.push(depValues[1]);
                    finalValues.push(depValues[2]);
                    finalValues.push(depValues[3]);
                }else if(prevValue == 'Support Granted By HQ' || prevValue == 'Support Not Granted By HQ'){
                    finalValues.push(depValues[2]);
                    finalValues.push(depValues[3]);
                    finalValues.push(depValues[4]);
                    finalValues.push(depValues[5]);
                }else if(prevValue == 'Support Provided' || prevValue == 'Support Not Provided'){
                    finalValues.push(depValues[4]);
                    finalValues.push(depValues[5]);
                }else{
                    finalValues.push(depValues[1]);
                }
            }else{
                finalValues = depValues;
            }
            component.set("v.oppProductList["+indx+"].riskStatusValues", finalValues);
            if(selValue == 'Support Requested'){
                component.set("v.oppProductList["+indx+"].riskStatus", prevValue);
            }
            if(component.get("v.oppProductList["+indx+"].riskStatusValues").length == 2){
                var tempList = [];
                tempList = component.get("v.oppProductList["+indx+"].riskStatusValues");
                component.set("v.oppProductList["+indx+"].riskStatus", tempList[1]);
            }
        }else{
            component.set("v.oppProductList["+indx+"].riskStatus", noValue);
        }
    },
    
    /*function to call on click of save button*/
    saveAction : function(component, event, helper){
        component.set("v.loaded", false);
        var noValue = component.get("v.noneValue");
        var hasError = "false";
        var productList = [];
        productList = component.get("v.oppProductList");
        for(var i=0; i<productList.length; i++){
            if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskReason1) || productList[i].riskReason1 == undefined || productList[i].riskReason1 == noValue) && ($A.util.isEmpty(productList[i].riskReason2) || productList[i].riskReason2 == undefined || productList[i].riskReason2 == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskPriority) || productList[i].riskPriority == undefined || productList[i].riskPriority == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskCategory) || productList[i].riskCategory == undefined || productList[i].riskCategory == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskStatus) || productList[i].riskStatus == undefined || productList[i].riskStatus == noValue)){
                hasError = "true";
                i = productList.length;
            }
        }
        if(hasError == "true"){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.Core_AtRisk_Validation_Error"),
                "type": "error",
                "duration": 10000
            });
            toastEvent.fire();
            component.set("v.loaded", true);
        }else{
            var action = component.get("c.save");
            action.setParams({
                oppRecord : component.get("v.oppRecord"),
                oppProductList : component.get("v.oppProductList"),
                noValue : noValue
            });
            action.setCallback(this, function(response){
                var toastEvent = $A.get("e.force:showToast");
                if(response.getState() === "SUCCESS"){
                    toastEvent.setParams({
                        "message": $A.get("$Label.c.Core_AtRisk_Success"),
                        "type": "success"
                    });
                }else{
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
        }
    },
    
    /*function to call on click of cancel button*/
    cancelAction : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    }
})