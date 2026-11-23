({
    // Method is called on component Initalization
    doInit: function(component, event, helper) {
        //This is to fetch record type meta data map and set activity record type developer name
        helper.fetchRecordTypeMetaData(component);
        //To identify Partner User
        helper.fetchMemberPartnerDetails(component);        
        
        //To identify weather its clone or EDit claim process
        if(component.get("v.simpleNewClaim.Id")!='' && component.get("v.simpleNewClaim.Id")!= undefined){     
            if(component.get("v.isCloneClaim"))
            {
                component.set("v.isClaimEdit",false);                
                //Making recordId as null since its clone claim and It will create New record
                
                //if its not retail
                if(!component.get("v.isClaimActivitySwap")){ //VD for retail KPI
                    component.set("v.simpleNewClaim.Id",null);
                }
                helper.onCloneClaim(component); 
            }
            else{
                component.set("v.isClaimEdit",true);
                
                helper.onEditClaim(component);
            }  
        }
        // This is to set Claim record type on the basis of Activity Record Type
        //helper.doInit(component);
        // This is to fetch the Invoice Currency Picklist and Logged In User Info
        helper.fetchUserAndPicklistInfo(component);
        // This is to fetch page URL to redirect to the list view
        helper.getPageUrl(component);
        component.set("v.isError", false);
    },
    
    // Method is called on click of cancel icon
    closeModal: function(component, event, helper) {
        helper.closeModel(component);
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
    // This method clears the RequestId and escalationId on change of Activity LookUp
    clearLookUpId : function(component,event,helper){
        var recordId;
        //Escalation check
        if((event.getParam("instanceId"))== 'escalationId'){
            recordId = component.get("v.escObjectId");  
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",'');
            component.set("v.escalationNoSearchString",'');
        }else{
            recordId =  component.get("v.sObjectId");            
            //KPI flag to false on clear activity
            component.set("v.isKpiLoaded",false);
            //set flag to false on clear activity
            component.set("v.isKpiSectionVisible",false);
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
    
    closeErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    
    
    // Method is called on click of Finish and Save Button
    finish : function(component,event,helper){
        helper.saveClaim(component);        
    },
    
    //This function is used to moveNext/Document uploade section from duplicate OK button
    handleDuplicateClick : function(component,event,helper){
        component.set("v.isOkDisabled",true);
        component.set("v.isDuplicate", false);
        if(component.get('v.isClaimActivitySwap') && 
           component.get("v.isKpiSectionVisible") && 
           component.get("v.moveToSecondPage")){
            //in case of retail, If KPI available , goto second page[KPI], on click of duplicate popup Ok button
            component.set("v.currentStep", "2"); 
        }else{
            component.set("v.currentStep", "3"); 
        } 
    },
    
    //This function used to open popup, if duplicate claim exists
    openDuplicateModel: function(component,event,helper){
        component.set('v.isDuplicate',true);
        //component.set("v.currentStep", "1");
        component.set("v.isOkDisabled",false);
    },
    
    
    //This function is used to close duplicate model
    closeDuplicateModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "False"  
        component.set("v.isDuplicate", false);
        component.set("v.isSaveDisabled",false);
        component.set("v.isOkDisabled",false);
        component.set("v.currentStep", "1");
    },
    
    //This function is used for Claim manditory fields & duplicate claim validation
        moveNext : function(component,event,helper){
        //on click on next button [tab 1]
        if(component.get("v.currentStep")=="1"){
            if(component.get("v.isKpiSectionVisible")){
                //KPI Section
                component.set("v.moveToSecondPage",true);
                //POP page
                component.set("v.moveToThirdPage",false);
            }else{
                //POP page
                component.set("v.moveToThirdPage",true);
            }
            if(helper.validateClaimForm(component)){   
                helper.getDuplicateRecords(component);
            }
            else{
                //if valid claim form fails
                component.set("v.currentStep", "1");
            }
        }
        //on click of tab 2 [KPI section]
        else if(component.get("v.currentStep")=="3"){
        	component.set("v.currentStep", "2");
        }
    },    
    
    //Navigate to POP page  on click of KPI section next button  
    moveToPopPage : function(component,event,helper){
        helper.validateKPIFields(component);
        
    },
    
    //Navigate to POP page on click on POP page directly
    nextToPopPage : function(component,event,helper){
        //POP page
        component.set("v.moveToThirdPage",true);
        //KPI Section
        component.set("v.moveToSecondPage",false);
        //click on POP page directly
        if(component.get("v.currentStep")=="1"){
            if(helper.validateClaimForm(component)){   
                helper.getDuplicateRecords(component);
            }
            else{
                //if valid claim form fails
                component.set("v.currentStep", "1");
            }
        }
        // validate KPI fields using validForm attribute
        else if(component.get("v.currentStep")=="2"){
            //click on KPI page next button
            helper.validateKPIFields(component);
        }
    },
    
    // This function is use to move to claim Detils screen
    moveBack : function(component,event,helper){
        // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
            component.set("v.moveToSecondPage",false);
        }else{
            //If KPI availble , goto KPI(second) page
            component.set("v.moveToThirdPage",false);
            if(component.get('v.isClaimActivitySwap') &&
               component.get("v.isKpiSectionVisible")){
                component.set("v.currentStep", "2"); 
            }else{
                //move to first page
                component.set("v.currentStep", "1");
            }
        }
    },
     
    // when user click direactly on step 1,step 2 or step 3 indicator then showing appropriate step using set 'currentStep'   
    clickClaimDetails : function(component,event,helper){
        component.set("v.currentStep", "1");
        //KPI section
        component.set("v.moveToSecondPage",false);
        //POP page
        component.set("v.moveToThirdPage",false);
    },
    
     clickUploadDocuments : function(component,event,helper){
        component.set("v.currentStep", "2");
    },
    
    // This method fetches the escalation details
    fetchEscalationDetails : function(component,event,helper){
        helper.fetchEscalationDetails(component);
    },
})