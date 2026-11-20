({
    fetchRecordInfo : function(component, event) {
        var action = component.get("c.loadCampaignRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.campaignRecord", result);
                this.checkForLegacyProgramAndBudgetTypes(component, event, result);//changes by MD
                if(component.get("v.isValidCampaigToEdit")) {
                    component.set("v.recordTypeId", result.RecordTypeId);
                    component.set("v.campaignName", result.Name);
                    component.set("v.recordTypeDeveloperName", result.RecordType.DeveloperName);
                    component.set("v.recordTypeName", result.RecordType.Name);
                    component.set("v.campaignStatus", result.Status);
                    component.set("v.mode", "edit");              
                    component.set("v.proposalBasedIndicator",result.Core_MDF_Proposal_Based_Ind__c);
                    component.set("v.claimAssociatedIndicator",result.Core_MDF_Claims_Created_Ind__c);
                    component.set("v.recordInfoLoaded", true);  
                    this.fetchActivityRecords(component, event);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignEdit :: helper:fetchRecordInfo: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignEdit :: helper:fetchRecordInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignEdit :: helper:fetchRecordInfo: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //changes by MD - to throw error message on editing campaigns of CCF 1.0, DCF 1.0, CCFB and SPCF
    checkForLegacyProgramAndBudgetTypes: function(component, event, result) {
        let budgetType = result.Core_MDF_Opal_Budget_Type_Txt__c;
        let recordTypeDeveloperName = result.RecordType.DeveloperName;
        
        var restrictedRecTypes =$A.get("$Label.c.Core_MDF_LegacyRestrictedRecordTypes");
        var restrictedRecTypesList = restrictedRecTypes.split(",");
                
        var restrictedBudgetTypes =$A.get("$Label.c.Core_MDF_LegacyRestricBudgetTypes");
        var restrictedBudgetTypesList = restrictedBudgetTypes.split(",");        
        if(((!$A.util.isUndefinedOrNull(recordTypeDeveloperName) && recordTypeDeveloperName != '') &&
           (restrictedRecTypesList.includes(recordTypeDeveloperName))) || 
           ((!$A.util.isUndefinedOrNull(budgetType) && budgetType != '') && 
           (restrictedBudgetTypesList.includes(budgetType)))) {
            
            component.set("v.isValidCampaigToEdit", false);
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error ",
                type: "error",
                duration: 5000,                
                message: $A.get("$Label.c.Core_MDF_CampaignEditError")
            });
            toastEvent.fire();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId")
            });
            navEvt.fire();
            setTimeout(function () {
                window.location.reload();
            }, 5000);
        }
    },
    
    checkForEditAccess : function(component, event) {
        var action = component.get("c.checkForEditAccess");
        var campaignObj =  component.get("v.campaignObj");        
        action.setParams({
            "objectName" : "Campaign",
            "recTypeDevloperName" : component.get("v.recordTypeDeveloperName"),
            "status" : component.get("v.campaignStatus"),
           	"campaignId" : component.get("v.recordId"),
            "proposalBasedIndicator" : component.get("v.proposalBasedIndicator"),
            "claimAssociatedIndicator" : component.get("v.claimAssociatedIndicator")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();   
                component.set("v.hasEditAccess", result);
                if(result==false){
                    var errMsg = $A.get('$Label.c.Core_MDF_CloneAccessError');
                    if(!component.get("v.isCommunity")) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error ",
                            type: "error",
                            message: errMsg
                        });
                        toastEvent.fire();
                        setTimeout(function () {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId")
                            },true);
                            navEvt.fire();
                            setTimeout(function () {
                                window.location.reload();
                            }, 1000);  
                        }, 2000);     
                    } else {
                        component.set("v.message", errMsg);
                    }
                }             
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignEdit :: helper:checkForEditAccess: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignEdit :: helper:checkForEditAccess: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignEdit :: helper:checkForEditAccess: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFieldSetInfo:function(component, event) {
        var action = component.get("c.getRtFieldSetMappings");
        action.setParams({
            objectName : "Campaign",
            recordTypeDeveloperName : component.get("v.recordTypeDeveloperName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.fieldSetName", response.getReturnValue());
                component.set("v.fieldSetLoaded", true);
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignEdit :: helper:fetchFieldSetInfo: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignEdit :: helper:fetchFieldSetInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignEdit :: helper:fetchFieldSetInfo: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    isCommunity : function(component, event) {
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set('v.isCommunity',response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignEdit :: helper:isCommunity: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignEdit :: helper:isCommunity: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignEdit :: helper:isCommunity: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchActivityRecords: function(component, event) {
        if(component.get("v.mode") == 'edit'){ //&& (component.get("v.recordTypeDeveloperName") ==  $A.get('$Label.c.Core_MDF_CCF_RecordTypeName') || component.get("v.recordTypeDeveloperName") ==  $A.get('$Label.c.Core_MDF_IPA_RecordType')))){  
            var action = component.get("c.loadPFRRecords");
            action.setParams({
                campId : component.get("v.recordId"),
                mode : component.get("v.mode")
            });
            action.setCallback(this, function(response){
                let state = response.getState();
                if (state == "SUCCESS") {
                    let result = response.getReturnValue();
                    component.set("v.pfrList", result.pfrList);
                    if(component.get("v.recordTypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                        this.prepareNodeAccData(component,component.get("v.pfrList"));
                    }
                }
                else {
                    let errors = response.getError();
                    console.log("Core_MDF_CampaignEdit :: helper:fetchActivityRecords: Error message: " + errors);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message:  $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"),
                        duration: 5000,
                        type: "error"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        } 
    },
    prepareNodeAccData : function(component, pfrList){
        let vitualCorpToNodeAcc = new Map();
        let nodeAccSet = new Set();
        let NodeAccountsList = [];
        if(pfrList!=null && !$A.util.isUndefinedOrNull(!pfrList)){
                pfrList.forEach(pfr => {
                //if pfr created on virtualcorp
                    let nodeAccountList = [];
                    let keyAccId;
                    let valAccId;
                    if($A.util.isUndefinedOrNull(pfr.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__c)){
                        keyAccId = pfr.ChannelPartnerId;
                    }//if pfr created on node acc and vitualCorpToNodeAcc already has data
                    else{
                        keyAccId = pfr.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__c;
                    }
                    valAccId = pfr.ChannelPartnerId;
                    let nodeAccList = new Set();//change from list to set
                        if(vitualCorpToNodeAcc.has(keyAccId)){
                            nodeAccList = vitualCorpToNodeAcc[keyAccId];
                        }
                        nodeAccList.add(valAccId);
                        nodeAccSet.add(valAccId);
                        nodeAccountList = [...nodeAccList];
                        vitualCorpToNodeAcc[keyAccId] = nodeAccountList;
                });
                NodeAccountsList = [...nodeAccSet];
            component.set("v.vitualCorpToNodeAcc", vitualCorpToNodeAcc);
            component.set("v.NodeAccountsList", NodeAccountsList);
        }
    },
})