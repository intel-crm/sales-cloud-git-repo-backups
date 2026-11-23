({
    /*function to call on load of the component*/
    doInit : function(component, event, helper) {
        component.set("v.loaded", false);
        if(component.get("v.recordId") == null){
            component.set("v.urlCall", true);
            var pageReference = component.get("v.pageReference");
            component.set("v.recordId", pageReference.state.c__recordId);
        }
        var action = component.get("c.getOpportunityProducts");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "noValue" : component.get("v.noneValue")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                helper.fetchPicklistValues(component, "Core_Risk_Reason1__c", "riskReason1");
                helper.fetchPicklistValues(component, "Core_Risk_Priority__c", "riskPriority");
                helper.fetchPicklistValues(component, "Core_At_Risk_Status__c", "riskStatus");
                var result = response.getReturnValue();
                component.set("v.oppRecord", result.oppRecord);
                component.set("v.oppProductList", result.oppProductList);
                var priorityList = [];
                var detailList = [];
                var statusList = [];
                var endDateList = [];
                var noValue = component.get("v.noneValue");
                var allAtRisk = true;
                var counter = 0;
                for(var i=0; i<result.oppProductList.length; i++){
                    if($A.util.isEmpty(result.oppProductList[i].riskPriority) || result.oppProductList[i].riskPriority == undefined || result.oppProductList[i].riskPriority == noValue){
                        priorityList.push(noValue);
                    }else{
                        priorityList.push(result.oppProductList[i].riskPriority);
                    }
                    statusList.push(result.oppProductList[i].riskStatus);
                    detailList.push(result.oppProductList[i].riskDetail);
                    endDateList.push(result.oppProductList[i].riskEndDate);
                    if(!result.oppProductList[i].atRisk){
                        allAtRisk = false;
                        counter = counter + 1;
                    }
                }
                component.set("v.riskPriorityList", priorityList);
                component.set("v.riskStatusList", statusList);
                component.set("v.riskDetailList", detailList);
                component.set("v.riskEndDateList", endDateList);
                if(!allAtRisk && counter == 1){
                    allAtRisk = true;
                }
                component.set("v.allAtRisk", allAtRisk);
                component.set("v.loaded", true);
                 console.log('Loaded is:'+component.get("v.loaded"));
            }else{
                console.log("Error on fetching opportunity product details : "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
        var oppID = component.get("v.recordId");
        var action1 = component.get("c.getSeedSampleURL");
        action1.setParams({
            // "oppId" : component.get("v.recordId"),
            // "RiskReason" : selValue
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            console.log('#state'+state+JSON.stringify(response));
            console.log('#response'+JSON.stringify(response.getReturnValue()));
            console.log('##resSeedURL '+response.getReturnValue().SeedURL);
            if(state === "SUCCESS"){
                console.log('##insideif');
                component.set("v.SeedURL",response.getReturnValue().SeedURL+oppID);
                console.log('##res1SeedURL '+component.get("v.SeedURL"));
                component.set("v.SampleURL",response.getReturnValue().SampleURL+oppID);
                console.log('##res1SampleURL '+component.get("v.SampleURL"));
            }else{
                console.log("Error on fetching Seeds/Sample URL details : "+JSON.stringify(response.getError()));
            }

        });
        $A.enqueueAction(action1);
        
        /*TWC3123-5794--function to return boolean value; 
         * true if PCC DEAL REG have FI Products, false for Intel-Led and PCC design and deal REG if atleast one product is non-FI*/ 
        var PCC = component.get("c.showAtRisk");
        PCC.setParams({
            "oppId" : component.get("v.recordId"),
        });
        PCC.setCallback(this, function(data) {
            component.set("v.loaded", true);
            component.set("v.isPCC", data.getReturnValue());
             console.log('PCC - 92');
            console.log(data.getReturnValue()); });
       
        $A.enqueueAction(PCC);
    },
    
    /*function to call on click of at risk checkbox*/
    setAtRiskInOpportunity : function(component, event, helper){
        var selValue = event.getSource().get("v.checked");
        var indx = event.getSource().get("v.tabindex");      
        if(selValue == false && component.get("v.oppProductList["+indx+"].isDisabled") == true){
            var riskStatus = component.get("v.riskStatusList["+indx+"]");            
            if(riskStatus == "New" || riskStatus == "In-Progress"){
                component.set("v.oppProductList["+indx+"].atRisk", true);
                component.set("v.tempIndex", indx);
                component.set("v.atRiskUncheckPopup", true);                
            }else{
                component.set("v.oppProductList["+indx+"].atRisk", true);
                component.set("v.oppProductList["+indx+"].riskStatus", riskStatus);
                component.set("v.oppProductList["+indx+"].riskEndDate", component.get("v.riskEndDateList["+indx+"]"));
                helper.throwErrorMsg(component, event, "error", $A.get("$Label.c.Core_Uncheck_AtRisk_Error"));
            }
        }else{
            helper.atRiskCheckUncheckLogic(component, event, selValue, indx);
        }
    },
    
    onRiskPriorityChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var indx = event.getSource().get("v.tabindex");
        //console.log("selValue "+selValue);
        //console.log("smgStaff "+JSON.stringify(component.get("v.smgStaffAttentionValue")));
        if(selValue == component.get("v.smgStaffAttentionValue")){
            component.set("v.oppProductList["+indx+"].riskPriority", component.get("v.riskPriorityList["+indx+"]"));
            if(component.get("v.oppProductList["+indx+"].riskStatus") == "New"){
                helper.throwErrorMsg(component, event, "error", "'" + selValue + "' " + $A.get("$Label.c.Core_AtRisk_SMGStaff_Error"));
            }else{
                component.set("v.tempIndex", indx);
                component.set("v.tempValue", selValue);
                component.set("v.riskPriorityPopUp", true);
            }
        }else{
            component.set("v.oppProductList["+indx+"].riskPriority", selValue);
        }
    },
    
    onRiskOwnerChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var indx = event.getSource().get("v.tabindex");
        var noValue = component.get("v.noneValue");
        var riskOldStatus = component.get("v.riskStatusList["+indx+"]");
        if($A.util.isEmpty(selValue) || selValue == undefined){
            if(riskOldStatus == noValue || riskOldStatus == "New"){
                component.set("v.oppProductList["+indx+"].riskStatus", "New");
                component.set("v.oppProductList["+indx+"].riskEndDate", null);
            }
        }else{
            if(riskOldStatus == noValue || riskOldStatus == "New"){
                component.set("v.oppProductList["+indx+"].riskStatus", "In-Progress");
                component.set("v.oppProductList["+indx+"].riskEndDate", null);
            }
        }
    },
    
    confirmAtRiskUncheck : function(component, event, helper){
        var indx = component.get("v.tempIndex");
        component.set("v.oppProductList["+indx+"].atRisk", false);
        helper.atRiskCheckUncheckLogic(component, event, false, indx);
        component.set("v.tempIndex", "");
        component.set("v.atRiskUncheckPopup", false);
    },
    
    confirmRiskPriority : function(component, event, helper){
        var tempVal = component.get("v.tempValue");
        if(component.get("v.multiplePopupIndicator") == true){
            component.set("v.allRiskPriority", tempVal);
            component.set("v.isMarkAll", true);
            component.set("v.multiplePopupIndicator", false);
        }else{
            var indx = component.get("v.tempIndex");
            component.set("v.oppProductList["+indx+"].riskPriority", tempVal);
            component.set("v.tempIndex", "");
        }
        component.set("v.tempValue", "");
        component.set("v.riskPriorityPopUp", false);
    },
    
    confirmRiskStatus : function(component, event, helper){
        var indx = component.get("v.tempIndex");
        var tempVal = component.get("v.tempValue");
        component.set("v.oppProductList["+indx+"].riskStatus", tempVal);
        component.set("v.oppProductList["+indx+"].riskEndDate", null);
        component.set("v.tempIndex", "");
        component.set("v.tempValue", "");
        component.set("v.statusBackPopup", false);
    },
    
    closePopUp : function(component, event, helper){
        if(component.get("v.multiplePopupIndicator") == true){
            component.set("v.isMarkAll", true);
            component.set("v.multiplePopupIndicator", false);
        }
        component.set("v.tempIndex", "");
        component.set("v.tempValue", "");
        component.set("v.riskPriorityPopUp", false);
        component.set("v.statusBackPopup", false);
        component.set("v.atRiskUncheckPopup", false);
    },
    
    onRiskStatusChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var indx = event.getSource().get("v.tabindex");
        var prevStatus = component.get("v.riskStatusList["+indx+"]");      
        var prodstatus = component.get("v.oppProductList["+indx+"].prdstatus");        
        if(selValue == "New" && prevStatus != "New" && component.get("v.oppProductList["+indx+"].isDisabled") == true){
            component.set("v.oppProductList["+indx+"].riskStatus", prevStatus);
            helper.throwErrorMsg(component, event, "error", "You are not allowed to change the 'Risk Status' as 'New'.");
        }else if(selValue == "New" && component.get("v.oppProductList["+indx+"].riskPriority") == component.get("v.smgStaffAttentionValue")){
            component.set("v.oppProductList["+indx+"].riskPriority", component.get("v.riskPriorityList["+indx+"]"));
        }/*else if(selValue == "In-Progress" && prevStatus.includes("Closed")){
            component.set("v.oppProductList["+indx+"].riskStatus", prevStatus);
            helper.throwErrorMsg(component, event, "error", $A.get("$Label.c.Core_AtRisk_Validation_Error_Inprogress"));
            component.set("v.tempIndex", indx);
            component.set("v.tempValue", selValue);
            //component.set("v.statusBackPopup", true);
        }*/
        /*else if(selValue.includes("Closed") && prevStatus.includes("Closed") && (prodstatus == "Cancelled" || prodstatus == "Lost" || prodstatus == "Production Lost" || prodstatus == "Production Cancelled")){
            component.set("v.oppProductList["+indx+"].riskStatus", prevStatus);
            helper.throwErrorMsg(component, event, "error", $A.get("$Label.c.Core_AtRisk_Validation_Error_Riskstatus"));                
        }*/
                  
        if(component.get("v.oppProductList["+indx+"].riskStatus").includes("Closed")){
            if(prevStatus == component.get("v.oppProductList["+indx+"].riskStatus")){
                component.set("v.oppProductList["+indx+"].riskEndDate", component.get("v.riskEndDateList["+indx+"]"));
            }else{
                component.set("v.oppProductList["+indx+"].riskEndDate", new Date());
            }
        }else{
            component.set("v.oppProductList["+indx+"].riskEndDate", null);
        }
    },
    
    /*function to call on click of save button*/
	saveAction : function(component, event, helper){
        var countSupplyProd = 0;  //TWC3123-4227
        var countSystemBuildProd = 0;  //TWC3123-4227
        component.set("v.loaded", false);
        var noValue = component.get("v.noneValue");
        var hasError = "false";
        var isSystemOrSupply = "false";  //TWC3123-4227
        var productList = [];
        var changeproductList = [];  //TWC3123-4389
        component.set("v.isBoth", false);  //TWC3123-4227
        component.set("v.isSupplySystemBuild", false);  //TWC3123-4227
        //component.set("v.countSupplyProd", false);  //TWC3123-4227
        productList = component.get("v.oppProductList");
        changeproductList = component.get("v.oppProductList2"); // Added for - TWC3123-4389
        
        //Checkmarx scan fix - check if productList is not empty before using in loop
        
        for(var i=0 && productList.length >0 ; i<productList.length   ; i++){
            //Start - TWC3123-4389
            if(changeproductList.includes(productList[i].oppLineItemId) && productList[i].riskReason1 == 'Risk - Supply: Sample'){
                countSupplyProd = countSupplyProd+1;
                isSystemOrSupply = "true";
            }
            if(changeproductList.includes(productList[i].oppLineItemId) && productList[i].riskReason1 == 'Risk - Supply: System Build'){
                countSystemBuildProd = countSystemBuildProd+1;
                isSystemOrSupply = "true";
            }
            // End - TWC3123-4389

            if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskReason1) || productList[i].riskReason1 == undefined || productList[i].riskReason1 == noValue) && ($A.util.isEmpty(productList[i].riskReason2) || productList[i].riskReason2 == undefined || productList[i].riskReason2 == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskPriority) || productList[i].riskPriority == undefined || productList[i].riskPriority == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskStatus) || productList[i].riskStatus == undefined || productList[i].riskStatus == noValue)){
                hasError = "true";
                i = productList.length;
            }else if(productList[i].atRisk == true && ($A.util.isEmpty(productList[i].riskDetail) || productList[i].riskDetail == undefined || productList[i].riskDetail == null)){
                hasError = "true";
                i = productList.length;
            }   	
        }
        

            if(hasError == "true"){
            helper.throwErrorMsg(component, event, "error", $A.get("$Label.c.Core_AtRisk_Validation_Error"));
            component.set("v.loaded", true);              
        }
        //Start - TWC3123-4227
		else if(isSystemOrSupply == "false"){
            helper.saveProdAtRisk(component, event);
        }
        
        if(hasError == "false"){
        if(countSupplyProd > 0 && countSystemBuildProd > 0){
            component.set("v.isSave", false);
            component.set("v.isBoth", true);
            component.set("v.loaded", true);
            component.set("v.RiskReasonValue", "both");
            component.set("v.ButtonLabel", "Fill out the form");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.Core_AtRisk_ErrorMsg"),
                "type": "error"
            });
            toastEvent.fire();
        }
        if(countSystemBuildProd > 0 && countSupplyProd == 0){
            component.set("v.isSave", true);
            component.set("v.isSupplySystemBuild", true);
            component.set("v.loaded", true);
            component.set("v.RiskReasonValue", "SystemBuild");
            component.set("v.ButtonLabel", "Fill out Demo Depot");
        }
        if(countSupplyProd > 0 && countSystemBuildProd == 0){
            component.set("v.isSave", true);
            component.set("v.isSupplySample", true);
            component.set("v.loaded", true);
            component.set("v.RiskReasonValue", "Sample");
            component.set("v.ButtonLabel", "Fill out My Sample");
        }
        }
        //End - TWC3123-4227
    },
    
    /*function to call on click of cancel button*/
    cancelAction : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    },
    
    //Start - TWC3123-4227
    closeConfirmationPopup : function(component, event, helper){
        component.set("v.isSave", false);
        component.set("v.loaded", true);
        $A.get('e.force:refreshView').fire();
    },
    
    //Start - TWC3123-4920    
    gotoURL : function(component, event, helper) {
    var oppID = component.get("v.recordId");
    var producttype= component.get("v.RiskReasonValue");
        //Order Seeds
        if(producttype == "SystemBuild"){
            helper.saveProdAtRisk(component, event);
            var urlToRedirect = component.get("v.SeedURL");
            console.log('##urlToRedirect '+urlToRedirect);
            $A.get("e.force:navigateToURL").setParams(
                {"url": urlToRedirect}).fire();
        }
        //Request Sample
        else if(producttype == 'Sample'){
            helper.saveProdAtRisk(component, event);
            var urlToRedirect = component.get("v.SampleURL");
            console.log('##SampleurlToRedirect '+urlToRedirect);
            $A.get("e.force:navigateToURL").setParams(
                {"url": urlToRedirect}).fire();
                //window.open(this.SampleURL, '_blank');    
        }
        component.set("v.isSave", false);

    },
   //End - TWC3123-4920 

    // callSaveComp : function(component, event, helper){
    //     var evt = $A.get("e.force:navigateToComponent");
    //     console.log('Event '+evt);
    //     var accountFromId = component.get("v.recordId");
    //     evt.setParams({
    //         componentDef  : "c:AffiliateSaveForm" ,
    //         componentAttribute : {
    //             accId : accountFromId
    //         }
        

    //     });
      
    //     evt.fire();
    // }
    openMarkAllPopup : function(component, event, helper){
        var noValue = component.get("v.noneValue");
        component.set("v.markAllAtRisk", true);
        component.set("v.allRiskReason1", noValue);
        component.set("v.allRiskPriority", noValue);
        component.set("v.allRiskStatus", "New");
        component.set("v.allProdRiskOwner", null);
        component.set("v.allRiskCreateDate", new Date());
        component.set("v.allRiskEndDate", null);
        component.set("v.allRiskDetail", null);
        component.set("v.isMarkAll", true);
    },
    
    closeMarkAllPopup : function(component, event, helper){
        component.set("v.isMarkAll", false);
    },
    
    onAllRiskPriorityChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        if(selValue == component.get("v.smgStaffAttentionValue")){
            component.set("v.allRiskPriority", component.get("v.noneValue"));
            if(component.get("v.allRiskStatus") == "New"){
                helper.throwErrorMsg(component, event, "error", "'" + selValue + "' " + $A.get("$Label.c.Core_AtRisk_SMGStaff_Error"));
            }else{
                component.set("v.tempValue", selValue);
                component.set("v.riskPriorityPopUp", true);
                if(component.get("v.isMarkAll") == true){
                    component.set("v.isMarkAll", false);
                    component.set("v.multiplePopupIndicator", true);
                }
            }
        }else{
            component.set("v.allRiskPriority", selValue);
        }
    },
    
    onAllRiskStatusChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        if(selValue == "New" && component.get("v.allRiskPriority") == component.get("v.smgStaffAttentionValue")){
            component.set("v.allRiskPriority", component.get("v.noneValue"));
        }
        
        if(component.get("v.allRiskStatus").includes("Closed")){
            component.set("v.allRiskEndDate", new Date());
        }else{
            component.set("v.allRiskEndDate", null);
        }
    },
    
    onAllRiskOwnerChange : function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var allRiskStatus = component.get("v.allRiskStatus");
        if($A.util.isEmpty(selValue) || selValue == undefined){
            if(allRiskStatus == "In-Progress"){
                component.set("v.allRiskStatus", "New");
                component.set("v.allRiskEndDate", null);
            }
        }else{
            if(allRiskStatus == "New"){
                component.set("v.allRiskStatus", "In-Progress");
                component.set("v.allRiskEndDate", null);
            }
        }
    },
    
        //Start - TWC3123-4227
    onRiskReasonChange :function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var indx = event.getSource().get("v.tabindex");
        //Start - added for TWC3123-4389
        var oppsProdId = component.get("v.oppProductList["+indx+"].oppLineItemId");
        var productList = [];
        productList = component.get("v.oppProductList2");
        if(!productList.includes(oppsProdId) && (selValue == 'Risk - Supply: Sample' || selValue == 'Risk - Supply: System Build' )){
            productList.push(oppsProdId);
            component.set("v.oppProductList2",productList);
        }
        //End - TWC3123-4389

        component.set("v.isSupplySystemBuild", false);
        component.set("v.isBoth", false);
        component.set("v.isSupplySample", false);
        var action = component.get("c.getProdRiskOwner");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "RiskReason" : selValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.oppProductList["+indx+"].prodRiskOwner",response.getReturnValue());
            }else{
                console.log("Error on fetching opportunity product details : "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    //End - TWC3123-4227
    //Start - TWC3123-4576
    onAllRiskReasonChange:function(component, event, helper){
        var selValue = event.getSource().get("v.value");
        var action = component.get("c.getProdRiskOwner");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "RiskReason" : selValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.allProdRiskOwner",response.getReturnValue());
                //component.set("v.oppProductList["+indx+"].prodRiskOwner",response.getReturnValue());
            }else{
                console.log("Error on fetching opportunity product details : "+JSON.stringify(response.getError()));
            }

        });
        $A.enqueueAction(action);
    },
    //End - TWC3123-4576

    saveAllAtRisk : function(component, event, helper){
        var riskRsn1 = component.get("v.allRiskReason1");
        var riskPrty = component.get("v.allRiskPriority");
        var riskSta = component.get("v.allRiskStatus");
        var riskDet = component.get("v.allRiskDetail");
        var hasError = "false";
        var noValue = component.get("v.noneValue");
        if(riskRsn1 == noValue){
            hasError = "true";
        }else if(riskPrty == noValue){
            hasError = "true";
        }else if(riskSta == noValue){
            hasError = "true";
        }else if(riskDet == null){
            hasError = "true";
        }
        if(hasError == "true"){
            helper.throwErrorMsg(component, event, "error", $A.get("$Label.c.Core_AtRisk_Validation_Error"));
        }else{
            component.set("v.loaded", false);
            component.set("v.isMarkAll", false);
            component.set("v.oppRecord.Core_At_Risk__c", true);
            var productList = [];
            productList = component.get("v.oppProductList");
            for(var i=0; i<productList.length; i++){
                if(!component.get("v.oppProductList["+i+"].atRisk")){
                    component.set("v.oppProductList["+i+"].atRisk", true);
                    component.set("v.oppProductList["+i+"].riskReason1", riskRsn1);
                    component.set("v.oppProductList["+i+"].riskPriority", riskPrty);
                    component.set("v.oppProductList["+i+"].riskStatus", riskSta);
                    component.set("v.oppProductList["+i+"].prodRiskOwner", component.get("v.allProdRiskOwner"));
                    component.set("v.oppProductList["+i+"].riskCreateDate", component.get("v.allRiskCreateDate"));
                    component.set("v.oppProductList["+i+"].riskEndDate", component.get("v.allRiskEndDate"));
                    component.set("v.oppProductList["+i+"].riskDetail", component.get("v.allRiskDetail"));
                   
            	}                           
            }
            helper.saveProdAtRisk(component, event);
        }
    }
})