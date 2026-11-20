({
    doInit : function(component, event, helper) {        
        
        var recType = component.get("v.campRecord.RecordType.DeveloperName");        
        var sDate = component.get("v.campRecord.StartDate");        
        var eDate = component.get("v.campRecord.EndDate");
        var showDCFModal = component.get("v.campRecord.Core_MDF_Show_DCF_Modal__c");
        
        var regionWiseRecTypes = $A.get("$Label.c.Core_MDF_Campaign_RegionWise_Budget").split(';'); 
        var categoryWiseRecTypes = $A.get("$Label.c.Core_MDF_Campaign_CategoryWise_Budget").split(';'); 
        
       // if(recType == 'Core_MDF_Client_CoMarketing_Fund' || recType == 'Core_MDF_Client_CoMarketing_Fund_Boost'){      
        if(regionWiseRecTypes.includes(recType)){            
            var action = component.get("c.regionalData");
            let budgetType;
            let recordTypeDeveloperName;
            action.setParams({
                "cmpId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                //alert("DATA is "+JSON.stringify(data));
                if(data != ''){
                    let firstRecordData = data[0];
                    budgetType = firstRecordData.Core_MDF_Campaign__r.Core_MDF_Opal_Budget_Type_Txt__c;
                    recordTypeDeveloperName = firstRecordData.Core_MDF_Campaign__r.RecordType.DeveloperName;
                    var sDateYear = new Date(sDate).getFullYear();            
                    var eDateYear = new Date(eDate).getFullYear();
                    var totalSum; 
                    var sumBudgetFY='';
                    if (sDateYear != eDateYear){
                        component.set("v.isSecondYearCampaign", true);
                        var sumBudgetSY = '';
                        
                        for(var i in data){
                            sumBudgetFY += data[i].Core_MDF_First_Year_Budget__c;
                            sumBudgetSY += data[i].Core_MDF_Second_Year_Budget__c;
                        }
                        totalSum = sumBudgetFY+sumBudgetSY;
                        if(totalSum.includes(undefined) && showDCFModal)
                            component.set("v.openCCFPopUp", true);
                    }
                    else if(sDateYear == eDateYear){ // Only FY
                        component.set("v.isSecondYearCampaign", false);
                        for(var i in data){
                            // alert(data[i].Core_MDF_First_Year_Budget__c);
                            sumBudgetFY += data[i].Core_MDF_First_Year_Budget__c;
                        }
                        if(sumBudgetFY.includes(undefined) && showDCFModal)
                            component.set("v.openCCFPopUp", true);
                    }
                    
                    component.set('v.regionWiseRecords', data);
                    component.set("v.isCCF", true);
                    
                    
                    
                }         
            });
            
            $A.enqueueAction(action);
            
            var action1 = component.get("c.checkSObjectEditPermission");
            action1.setParams({
                "objectName": "Core_MDF_Regionwise_Campaign_Budget__c"
            });
            
            action1.setCallback(this, function(response) {
                var data = response.getReturnValue();
                var restrictedRecTypes =$A.get("$Label.c.Core_MDF_LegacyRestrictedRecordTypes");
                var restrictedRecTypesList = restrictedRecTypes.split(",");
                
                var restrictedBudgetTypes =$A.get("$Label.c.Core_MDF_LegacyRestricBudgetTypes");
                var restrictedBudgetTypesList = restrictedBudgetTypes.split(",");
                if(data) {
                    if(((!$A.util.isUndefinedOrNull(recordTypeDeveloperName) && recordTypeDeveloperName != '') &&
                        (restrictedRecTypesList.includes(recordTypeDeveloperName))) || 
                       ((!$A.util.isUndefinedOrNull(budgetType) && budgetType != '') && 
                        (restrictedBudgetTypesList.includes(budgetType)))) {
                        component.set('v.regionEditable', false);
                    } else {
                        component.set('v.regionEditable', true);
                    }
                } else {
                    component.set('v.regionEditable', false);
                }
            });
            $A.enqueueAction(action1);
        }
        if (categoryWiseRecTypes.includes(recType)){ 
            
            var rec = component.get("v.recordId");            
            var action = component.get("c.categoryData");
            
            action.setParams({
                "cmpId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                if(data != ''){
                    
                    var sDateYear = new Date(sDate).getFullYear();            
                    var eDateYear = new Date(eDate).getFullYear();
                    var totalSum; 
                    var sumBudgetFY='';
                    if (sDateYear != eDateYear){
                        component.set("v.isSecondYearCampaign", true);
                        var sumBudgetSY = '';
                        
                        for(var i in data){
                            sumBudgetFY += data[i].Core_MDF_First_Year_Budget__c;
                            sumBudgetSY += data[i].Core_MDF_Second_Year_Budget__c;
                        }
                        totalSum = sumBudgetFY+sumBudgetSY;
                        if(totalSum.includes(undefined) && showDCFModal)
                            component.set("v.openDCFPopUp", true);
                    }
                    else if(sDateYear == eDateYear){ // Only FY
                        component.set("v.isSecondYearCampaign", false);
                        for(var i in data){                            
                            sumBudgetFY += data[i].Core_MDF_First_Year_Budget__c;
                        }
                        if(sumBudgetFY.includes(undefined) && showDCFModal)
                            component.set("v.openDCFPopUp", true);
                    }
                    
                    component.set('v.categoryWiseRecords', data);
                    component.set("v.isDCF", true);              
                }            
            }); 
            
            
            $A.enqueueAction(action);
            
            var action1 = component.get("c.checkSObjectEditPermission");
            action1.setParams({
                "objectName": "Core_MDF_Categorywise_Campaign_Budget__c"
            });
            
            action1.setCallback(this, function(response) {
                var data = response.getReturnValue(); 
                component.set('v.categoryEditable', data);
            });
            $A.enqueueAction(action1);
        }
        
        
        
    },
    
    /*Save: function(component, event, helper) {
        
        var recordType = component.get("v.isCCF");
        
        if(recordType){
            
            var action = component.get("c.saveRegionWiseData");
            console.log("region wise records : "+component.get("v.regionWiseRecords"));  
            action.setParams({
                "rWList": component.get("v.regionWiseRecords")
            });       
            
            // set callback 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: $A.get("$Label.c.Core_MDF_CCF_DCF_SUCCESS"),
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'  //mode: 'pester'
                    });
                    toastEvent.fire(); 
                    component.set("v.isDisabled", true);
                    component.set("v.showSaveCancelBtn",false);
                    $A.get('e.force:refreshView').fire();
                }
                if (state === "ERROR") {
                    var err = response.getError();
                    var labelMessage = $A.get("$Label.c.Core_MDF_CannotUpdateCampaignChild");
                    var errorMsg = '';
                    if(err[0].message){
                        errorMsg = err[0].message;
                        console.log('coming to if');
                    }else if(err.length > 0 && (err != null || err != undefined) && err[0].pageErrors != null && err[0].pageErrors.length > 0 ){
                        console.log('coming in else');
                        errorMsg = err[0].pageErrors[0].message;
                    }
                    console.log('labelmsg:',labelMessage);
                    console.log('errorMsg:',errorMsg);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error Message",
                        message: (errorMsg === labelMessage) ? errorMsg : $A.get("$Label.c.Core_MDF_CCF_DCF_ERROR"),
                        duration: 5000,
                        key: 'info_alt',
                        type: "error",
                        mode: "pester"
                    });
                    toastEvent.fire();
                    component.set("v.isDisabled", false);
                    
                }
                
                
            });
        }       
        
        // categoryWise action
        else{
            var recordType = component.get("v.isDCF");
            
            if(recordType){
                
                var action = component.get("c.saveCategoryWiseData");
                console.log("region wise records : "+component.get("v.categoryWiseRecords"));   
                action.setParams({
                    "cWList": component.get("v.categoryWiseRecords")
                });       
                
                // set callback 
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success Message',
                            message:$A.get("$Label.c.Core_MDF_CCF_DCF_SUCCESS"),
                            messageTemplate: 'Record {0} created! See it {1}!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'  //mode: 'pester'
                        });
                        toastEvent.fire(); 
                        component.set("v.isDisabled", true);
                        component.set("v.showSaveCancelBtn",false);
                        $A.get('e.force:refreshView').fire();
                    }
                    if (state === "ERROR") {
                        var err = response.getError();
                        var labelMessage = $A.get("$Label.c.Core_MDF_CannotUpdateCampaignChild");
                        var errorMsg = '';
                        if(err[0].message){
                            errorMsg = err[0].message;
                        }else if(err.length > 0 && (err != null || err != undefined) && err[0].pageErrors != null && err[0].pageErrors.length > 0 ){
                            errorMsg = err[0].pageErrors[0].message;
                        }
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error Message",
                            message: (errorMsg === labelMessage) ? errorMsg : $A.get("$Label.c.Core_MDF_CCF_DCF_ERROR"),
                            duration: 5000,
                            key: 'info_alt',
                            type: "error",
                            mode: "pester"
                        });
                        toastEvent.fire();
                        component.set("v.isDisabled", false);
                    }
                });
            }
        }
        // enqueue the server side action  
        $A.enqueueAction(action);
        
        $A.get('e.force:refreshView').fire();
        
        
    },*/
    
    Save: function(component, event, helper) {
        
        function showToast(title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: title,
                message: message,
                duration: 5000,
                key: 'info_alt',
                type: type,
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
        var action;
        var isCCF = component.get("v.isCCF");
        var isDCF = component.get("v.isDCF");

        if (isCCF) {
            action = component.get("c.saveRegionWiseData");
            action.setParams({ "rWList": component.get("v.regionWiseRecords") });
        } else if (isDCF) {
            action = component.get("c.saveCategoryWiseData");
            action.setParams({ "cWList": component.get("v.categoryWiseRecords") });
        } else {
            return;
        }

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                showToast("Success Message", $A.get("$Label.c.Core_MDF_CCF_DCF_SUCCESS"), "success");
                component.set("v.isDisabled", true);
                component.set("v.showSaveCancelBtn", false);
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var err = response.getError();
                var labelMessage = $A.get("$Label.c.Core_MDF_CannotUpdateCampaignChild");
                var errorMsg = '';

                if (err && err[0]) {
                    if (err[0].message) {
                        errorMsg = err[0].message;
                    } else if (err[0].pageErrors && err[0].pageErrors.length > 0) {
                        errorMsg = err[0].pageErrors[0].message;
                    }
                }

                var finalMessage = (errorMsg === labelMessage) ? errorMsg : $A.get("$Label.c.Core_MDF_CCF_DCF_ERROR");
                showToast("Error Message", finalMessage, "error");
                component.set("v.isDisabled", false);
            }
        });

        $A.enqueueAction(action);
    },    
    
    hideModalOnSave:function(component, event, helper){
        
        component.set("v.openDCFPopUp", false);
        component.set("v.openCCFPopUp", false);
        var recType = component.get("v.campRecord.RecordType.DeveloperName");
        if (recType == 'Core_MDF_Data_Center_CoMarketing_Fund' || 'Core_MDF_Client_CoMarketing_Fund'){
            var action = component.get("c.savecampaignRecord");            
            action.setParams({
                "cRecord": component.get("v.recordId")
            });
        }
        $A.enqueueAction(action); 
        
        $A.get('e.force:refreshView').fire(); 
    },
    hideModal:function(component, event, helper){
        
        component.set("v.openDCFPopUp", false);
        component.set("v.openCCFPopUp", false);
        var recType = component.get("v.campRecord.RecordType.DeveloperName");
        if (recType == 'Core_MDF_Data_Center_CoMarketing_Fund'|| 'Core_MDF_Client_CoMarketing_Fund'){
            
            var action = component.get("c.savecampaignRecord");            
            action.setParams({
                "cRecord": component.get("v.recordId")
            });
            
        }
        $A.enqueueAction(action);  
        //  $A.get('e.force:refreshView').fire();   
        
    }
    
})