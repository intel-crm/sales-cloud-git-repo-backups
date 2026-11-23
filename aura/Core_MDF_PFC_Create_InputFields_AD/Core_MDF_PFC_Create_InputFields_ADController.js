({
    doInit : function(component,event,helper){
        // This is to fetch the Invoice Currency Picklist and Logged In User Info
        helper.fetchUserAndPicklistInfo(component);
        //To identify Partner User
        helper.fetchMemberPartnerDetails(component);        
        
        //To identify weather its clone or EDit claim process     
        if(component.get("v.simpleNewClaim.Id")!='' && component.get("v.simpleNewClaim.Id")!= undefined){     
            if(component.get("v.isCloneClaim"))
            {
                component.set("v.isClaimEdit",false);                
                //Making recordId as null since its clone claim and It will create New record
                component.set("v.simpleNewClaim.Id",null);
                helper.onCloneClaim(component); 
            }
            else{
                component.set("v.isClaimEdit",true);                               
                helper.onEditClaim(component);
            }
        }
    },
    // This method fetches the Activity details
    fetchActivityDetails : function(component,event,helper){
        helper.fetchActivityRecord(component, event, helper);
    },
    // This method sets the RequestId and escalationId on change of Activity LookUp
    updateLookUpId : function(component,event,helper){
        var recordId = event.getParam("sObjectId");
        //Escalation check
        if((event.getParam("instanceId"))== 'escalationId'){
            component.set("v.escObjectId",recordId);  
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",recordId);
        }else{
            component.set("v.sObjectId",recordId); 
            component.set("v.simpleNewClaim.RequestId",recordId);
            
            if(component.get('v.isUserClaimCaseReviewerOrManager')){
                var escalationLookup = component.find('escalationId');
                if(!$A.util.isUndefined(escalationLookup)){
                    escalationLookup.clearLookupPill();
                }
            }
        }
    },
    
      // This method clears the RequestId and escalationId on change of Activity LookUp
    clearLookUpId : function(component,event,helper){
        //Escalation check
        if((event.getParam("instanceId"))== 'escalationId'){ 
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",'');
            component.set("v.escalationNoSearchString",'');
        }else{
            //Clear pick list values, country and request ID , on activity clear lookup
            component.set("v.simpleNewClaim.RequestId",'');
            component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c",'');
            helper.clearPicklistValues(component);
            //lookup cmp will visible ,only if user is CCR/CCRM
            if(component.get('v.isUserClaimCaseReviewerOrManager')){
                var escalationLookup = component.find('escalationId');
                if(!$A.util.isUndefined(escalationLookup)){
                    escalationLookup.clearLookupPill();
                }
            }
        }
    },
    //Validate claim form fields
    validateClaimFormFields: function(component,event,helper){
      helper.validateClaimForm(component);  
    },
    
    //Auto populate activity, in case on edit and clone
    autoPopulateActivity : function(component){
        helper.autoPopulateActivity(component);
    },
    
        //This function is used to close duplicate model
    closeDuplicateModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "False"  
        component.set("v.isDuplicate", false);
        component.set("v.isOkDisabled",false);
        component.set("v.currentStep", "1");
    },
    
        //This function is used to moveNext/Document uploade section from duplicate OK button
    handleDuplicateClick : function(component,event,helper){
        component.set("v.isOkDisabled",true);
        component.set("v.isDuplicate", false);
        component.set("v.currentStep", "2");             
        
    },
    //This function used to open popup, if duplicate claim exists
    openDuplicateModel: function(component,event,helper){
        component.set('v.isDuplicate',true);
        component.set("v.isOkDisabled",false);
    },
    
        // This method fetches the escalation details
    fetchEscalationDetails : function(component,event,helper){
        helper.fetchEscalationDetails(component);
    },
})