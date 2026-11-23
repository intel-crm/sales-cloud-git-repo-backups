({
    fetchRecordInfo : function(component, event) {
         var action = component.get("c.loadRecTypeInfo");
        action.setParams({
           RecordId :component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.recordTypeId", result.RecordType.Id);
                component.set("v.recordTypeName", result.RecordType.Name);
                component.set("v.recordTypeDeveloperName", result.RecordType.DeveloperName);
                component.set("v.mode", "clone");
                component.set("v.recordInfoLoaded", true);
                component.set("v.campaignObject",result);
                component.set("v.showPFRModal",true);
                component.set("v.proposalBasedIndicator",result.Core_MDF_Proposal_Based_Ind__c);
                component.set("v.campaignStatus",result.Status);
                this.getAssociatedActivity(component, event);
                this.checkForCloneAccess(component, event);
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignClone :: helper:fetchRecordInfo: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignClone :: helper:fetchRecordInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignClone :: helper:fetchRecordInfo: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    checkForCloneAccess : function(component, event) {
        var action = component.get("c.checkForCloneAccess");
        var abc = component.get("v.recordTypeDeveloperName");
        action.setParams({
            
            recordTypeDeveloperName :component.get("v.recordTypeDeveloperName"),
            campaignStatus : component.get("v.campaignStatus")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.hasCloneAccess", result);

                if(result==false){
                    component.set("v.message", $A.get('$Label.c.Core_MDF_CloneAccessError'));
                }                
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignClone :: helper:checkForCloneAccess: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignClone :: helper:checkForCloneAccess: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignClone :: helper:checkForCloneAccess: Unknown error");
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
                console.log("Core_MDF_CampaignClone :: helper:fetchFieldSetInfo: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignClone :: helper:fetchFieldSetInfo: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignClone :: helper:fetchFieldSetInfo: Unknown error");
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
                console.log("Core_MDF_CampaignClone :: helper:isCommunity: Server request incomplete");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Core_MDF_CampaignClone :: helper:isCommunity: Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Core_MDF_CampaignClone :: helper:isCommunity: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
       //US1082871: [IPA MDF] - Campaign - Clone a Proposal - get all the associated activities
    getAssociatedActivity : function(component, event) {
        
        if( component.get("v.mode") == 'clone' && (component.get("v.recordTypeDeveloperName") ==  $A.get('$Label.c.Core_MDF_IPA_RecordType') && component.get("v.proposalBasedIndicator"))){  
          var action = component.get("c.loadPFRRecords");
        action.setParams({
            campId : component.get("v.recordId"),
            mode: component.get("v.mode"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result =  response.getReturnValue();
                if(result.isSuccess == true){
                    var updatedPFRList = this.removeExcludedValuesFromPFR(component,result.pfrList);
                     component.set("v.pfrList",updatedPFRList);
                     console.log('pfrList-->',JSON.stringify(component.get("v.pfrList")));
                    
                    if(component.get("v.recordTypeDeveloperName") ==  $A.get('$Label.c.Core_MDF_IPA_RecordType')){
                        this.activityValidation(component, event);
                    } 
                    
                        var recordTypeDeveloperName = component.get("v.recordTypeDeveloperName");
                         if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.proposalBasedIndicator")) {
                             this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                         }
                         else if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.proposalBasedIndicator")) {
                             this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                         }
                     
                }else{
                    console.log('Error'+result.responseMessage);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("Core_MDF_CampaignClone :: helper:loadPFRRecords: Server request incomplete");
            }
                else if (state === "ERROR") {
                    console.log("error");
                    
                }
        });
        $A.enqueueAction(action);
    }
    },

    fetchActSubTypeMulti: function (component,childPickField) {
       var activityList = [];
       activityList = component.get("v.pfrList");
       
        for(var i=0;i < activityList.length;i++){
            var SelActivityType = activityList[i].Core_MDF_Activity_Types__c;
            var childValuesReturn = this.setChildPicklistValues(component, SelActivityType, childPickField);
            if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1) {
                activityList[i].activitySubTypeAvailable = true;    
            }
            else {
                activityList[i].activitySubTypeAvailable = false;  
            }
        }
        component.set("v.pfrList",activityList);
        console.log('pfrList final-->',JSON.stringify(component.get("v.pfrList")));
    },  

    setChildPicklistValues : function(component, controllingValues, dependentValues){
        var childPicklistValue = new Array();
        var childValueOptionsMap = new Array();
        if (dependentValues != null) {
            childValueOptionsMap = dependentValues[controllingValues];
            if (childPicklistValue.length == 0) {
                //setting the first value of the dependent picklist as translated None value
                childPicklistValue.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
            if (childValueOptionsMap != null) {
                for (var index = 0; index < childValueOptionsMap.length; index++){
                    childPicklistValue.push(childValueOptionsMap[index]);
                }	
            }
        }
        return childPicklistValue;
    },


    activityPicker: function (component, recordType) {
        var pickLabel = $A.get("$Label.c.Core_MDF_IPA_PFR_UI_Fields");
        var pickListFields = pickLabel.split(",");
        var result;
        var recType = recordType;
        var action = component.get("c.customPicklistFetcher");
        
        action.setParams({
            "recordTypeName": recType
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            for (var i = 0; i < pickListFields.length; i++) {              
                //Gets value from parent picklist field
                var sControllingFieldValues = result.picklistFieldValues[pickListFields[i]].controllerValues;
                //Gets value from dependent picklist field 
                var sFieldValues = result.picklistFieldValues[pickListFields[i]].values;
                // Constructing the Options for the picklist field
                this.initActcategoryandType(component, pickListFields[i], sControllingFieldValues, sFieldValues);
                }
        });
        $A.enqueueAction(action);
    },
    

    initActcategoryandType: function (component, fldname, scontrolvalues, sfieldcompletevalues) {
        var controllingFieldValues = JSON.stringify(scontrolvalues).slice(1, -1);
        var confieldmap = new Object();
        if (controllingFieldValues != '') {
            var res = controllingFieldValues.split(",");
            for (var index = 0; index < res.length; index++) {
                var keyvalue = res[index].split(":");
                confieldmap[keyvalue[1]] = keyvalue[0].slice(1, -1);
            }
        }
        var sValues;
        var childPickField = new Object();
        for (var i = 0; i < sfieldcompletevalues.length; i++) {
            if (sfieldcompletevalues[i].validFor.length > 0) { //condition to check for dependent field                   
                for (var j = 0; j < sfieldcompletevalues[i].validFor.length; j++) {
                    var key = confieldmap[sfieldcompletevalues[i].validFor[j]];
                    if (key in childPickField) {
                        childPickField[key].push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                        });
                    } else {
                        sValues = new Array();
                        sValues.push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                        });
                        childPickField[key] = sValues;
                    }
                } //map creation
            } //end parent value loop
        } //entire value loop
        
            if (fldname == "Core_MDF_Activity_SubType_nm__c") {
                this.fetchActSubTypeMulti(component,childPickField);
        }
    },



    // Function to remove the excluded values from picklist from  the Activity records
    removeExcludedValuesFromPFR: function(component,actRecordsList){
        var pfrList = actRecordsList;
        var updatedPfrList = new Array();
        var excludedValues = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
        var extIpaUser = component.get("v.isIPAExtUsr");
        pfrList.forEach(item =>{
            var pfrRecData = item;
            if(extIpaUser){
                if(excludedValues.includes(pfrRecData.Core_MDF_Activity_Types__c)){
                    pfrRecData.Core_MDF_Activity_Types__c = '';
                }
        	}

            updatedPfrList.push(pfrRecData);
        });
        return updatedPfrList;
    }, 
 	
 	    isUserIPAExUser: function(component){
    		component.set("v.isIPAExtUsr",false);
            var action = component.get("c.isUserIPAExtUser");
            action.setCallback(this, function (response){
                var state = response.getState();
                if(state == "SUCCESS"){
                    var result = response.getReturnValue();
                    component.set("v.isIPAExtUsr", result);
                }
            });
            $A.enqueueAction(action);
        },
            
            //Fetch date in w.r.t to Local time zone
         getTodayDateLocalTime : function(){
         var timezone = $A.get("$Locale.timezone");          
         var todaysDate = new Date().toLocaleString("fr-CA", {timeZone: timezone}).slice(0,10);
         return todaysDate;
         }, 
        
         activityValidation : function(component, event) {
             var todaysDate = this.getTodayDateLocalTime();
             var activityList = [];
             var startDate;
             var daysDifference = 0;
             var isEdited = false;
             
             activityList = component.get("v.pfrList");
             var updatedActivity = component.get("v.pfrEditRecord");
             isEdited = Object.keys(updatedActivity).length != 0 ? true: false;
             console.log('@@isEdited-->',isEdited);
             //var updatedActivityLength = Object.keys(updatedActivity).length;
             
             if(activityList != undefined && activityList != null && activityList != ''){
                 for(var i=0;i < activityList.length;i++){
                    //IPA-Jegan
                    /*activityList[i].showKPIErrorClone = ((activityList[i].hasOwnProperty("showKPIErrorClone") && activityList[i].showKPIErrorClone == false && activityList[i].hasOwnProperty("kpiMetricEdited") && activityList[i].kpiMetricEdited) || component.get('v.outcomeBasedOptInInd')) ? false : true;
                    if(activityList[i].hasOwnProperty("showKPIErrorClone") && component.get('v.outcomeBasedOptInInd')){
                        delete activityList[i].showKPIErrorClone;
                    }
                    
                    activityList[i].showTacticMetricsErrorClone = ((activityList[i].hasOwnProperty("Core_MDF_Tactics_nm__c") && !this.isNotBlank(activityList[i].Core_MDF_Tactics_nm__c) || !activityList[i].hasOwnProperty("Core_MDF_Tactics_nm__c") || (!activityList[i].hasOwnProperty("tacticMetricEdited") ||  activityList[i].hasOwnProperty("tacticMetricEdited") && !activityList[i].tacticMetricEdited)) && component.get('v.outcomeBasedOptInInd')) ? true : false;*/

                    activityList[i].showKPIErrorClone = ((activityList[i].hasOwnProperty("showKPIErrorClone") && activityList[i].showKPIErrorClone == false && activityList[i].hasOwnProperty("kpiMetricEdited") && activityList[i].kpiMetricEdited) || component.get('v.outcomeBasedOptInInd')) ? false : true;
                    if(activityList[i].hasOwnProperty("showKPIErrorClone") && component.get('v.outcomeBasedOptInInd')){
                        delete activityList[i].showKPIErrorClone;
                        delete activityList[i].kpiMetricEdited;
                        delete activityList[i].isBlankMetrics;
                    }

                    if(!activityList[i].hasOwnProperty("kpiMetricEdited") && !component.get('v.outcomeBasedOptInInd')){
                        activityList[i].kpiMetricEdited = false;
                    }
                    
                    //activityList[i].showTacticMetricsErrorClone = ((activityList[i].hasOwnProperty("Core_MDF_Tactics_nm__c") && !this.isNotBlank(activityList[i].Core_MDF_Tactics_nm__c) || !activityList[i].hasOwnProperty("Core_MDF_Tactics_nm__c") || (!activityList[i].hasOwnProperty("tacticMetricEdited") ||  activityList[i].hasOwnProperty("tacticMetricEdited") && !activityList[i].tacticMetricEdited)) && component.get('v.outcomeBasedOptInInd')) ? true : false;
                    activityList[i].showTacticMetricsErrorClone = ((!activityList[i].hasOwnProperty("tacticMetricEdited") ||  activityList[i].hasOwnProperty("tacticMetricEdited") && !activityList[i].tacticMetricEdited)) && component.get('v.outcomeBasedOptInInd') ? true : false;
                     if(activityList[i].hasOwnProperty("tacticMetricEdited") && activityList[i].tacticMetricEdited && !component.get('v.outcomeBasedOptInInd')){
                        delete activityList[i].showTacticMetricsErrorClone;
                        delete activityList[i].tacticMetricEdited;
                        delete activityList[i].isBlankTacticMetrics;
                    }

                    if(!activityList[i].hasOwnProperty("tacticMetricEdited") && component.get('v.outcomeBasedOptInInd')){
                            activityList[i].tacticMetricEdited = false;
                    }
                    
                     if(!isEdited){
                     var currDateTime = new Date();
                     activityList[i].Core_MDF_StartTime_dtm__c = new Date(currDateTime).toISOString(); //Capture Start Time on Activity while cloning Proposal with existing activities
                     }
                         if((isEdited && updatedActivity.Id == activityList[i].Id) || (!isEdited)){
                         startDate = activityList[i].Core_MDF_Start_Date__c;
                         daysDifference = (Date.parse(startDate) - Date.parse(todaysDate))/(3600*24*1000);
                         if(activityList[i].Core_MDF_ActivityCategory__c == 'Event' 
                            && activityList[i].Core_MDF_Activity_Reimbursement_Amt_nbr__c >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold") 
                            && daysDifference < $A.get("$Label.c.Core_MDF_60DaysMoreThan_50K") && component.get("v.isCommunity")){
                             activityList[i].act60daysValidation = true;
                         }
                         else{
                             activityList[i].act60daysValidation = false;
                         }
                         if(this.isNotBlank(activityList[i].Core_MDF_Initiative_nm__c)){
                             if(activityList[i].Core_MDF_Initiative_nm__c.split(';').includes('None') 
                                && activityList[i].Core_MDF_Initiative_nm__c.split(';').length >1){
                                 activityList[i].initiativeNoneValidation = true;
                             }
                             else{
                                 activityList[i].initiativeNoneValidation = false;
                             }
                         }
                             
                     }
                     
                 }
                 component.set("v.pfrList",activityList);
             }
         },
             
         isNotBlank : function(value) {
             return (value !== undefined && value !== null && value !== '');
         },    

         //IPA-Jegan
         //IPA Outcome Based optin - To map the Activity record with Activity Attribute records
         formActivityToActivityAttributes :function(component, event) {
            var activityToAttributeListFromEvent = JSON.parse(JSON.stringify(event.getParam("activityToAttrList")));
            var activityToAttributeList = Array.isArray(component.get('v.activityToAttributeList')) ? component.get('v.activityToAttributeList') : [];
            var updateList = [];

            if (activityToAttributeListFromEvent.hasOwnProperty('activity')) {
                let recordFound = false;

                for (let i = 0; i < activityToAttributeList.length; i++) {
                    if (activityToAttributeList[i].activity.Id == activityToAttributeListFromEvent.activity.Id) {
                        updateList.push({
                            activity: activityToAttributeListFromEvent.activity,
                            activityAttribute: activityToAttributeListFromEvent.activityAttribute
                        });
                        recordFound = true;
                    } else {
                        updateList.push(activityToAttributeList[i]);
                    }
                }

                if (!recordFound) {
                    updateList.push({
                        activity: activityToAttributeListFromEvent.activity,
                        activityAttribute: activityToAttributeListFromEvent.activityAttribute
                    });
                }
            }
            component.set('v.activityToAttributeList', [...updateList]);
         }
    
})