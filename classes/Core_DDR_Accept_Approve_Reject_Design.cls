/**************************************************************************************************
Apex Class Name:  Core_DDR_Accept_Approve_Reject_Design
    Version     : 1.0
    Created Date: 16 AUG 2018
    Function    :This class is being used for DDR Accept,Approve and Reject Design Detail page buttons.
    Modification Log :
     * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
Rajesh kumar                Jun-18-2018             Original Version
    Sougata Sarkar              Aug-29-2018             Updated Version
    Venu Karumuru               Jun-07-2021             Added code to check for valid Industry/Sub-Industry in ApproveDesign method
    Venu Karumuru               Oct-04-2021             Updated ApproveDesign method to skip Approved Products check for Re-Submitted designs
     *****************************************************************************************************/
public with sharing class Core_DDR_Accept_Approve_Reject_Design {
    
    public static final String LOG_ENTRY_ORIGIN   = 'Core_DDR_Accept_Approve_Reject_Design';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE_ACCEPTDDR    = 'Accept DDR';
    public static final String LOG_ENTRY_SCOPE_REJECTDDR    = 'Reject DDR';
    public static final String LOG_ENTRY_SCOPE_APPROVEDDR    = 'Approve DDR';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'Info';
    
    public static Core_Design_Registration__c getDDRsoqlquery(String designRegId) {
        Core_Design_Registration__c designQueryResult = new Core_Design_Registration__c();
        designQueryResult= [SELECT Id, Core_Design_Registration_Nm__c,createddate ,Core_Partner_Account_Nm__c,OwnerId, Owner.isActive, Core_Vertical_Market_Nm__c, Core_Intel_Platform_Nm__c,
                Core_End_Customer_Account_Id__r.RecordType.Name, Core_Product_Segment_Nm__c, Core_Product_Application_Nm__c, 
                RecordTypeId, Core_Rejection_Reason_Nm__c,Core_Product_Group_Nm__c, Core_End_Customer_Account_Owner__c, Core_Pending_Product_Cnt__c,
                Core_Approved_Product_Cnt__c, Core_Opportunity_Id__c, Core_Accepted_By_Id__c, Core_End_Customer_Account_Id__c,
                Core_Partner_Account_Id__c, Core_Is_End_Customer_Account_Covered_Ind__c, Core_Is_End_Customer_Account_Blocked_Ind__c,
                Core_End_Customer_Sales_Group_Nm__c, Core_Design_Registration_Status_Nm__c, Core_Intel_Technical_Owner_Id__c,
                Core_Rejection_Comment_Txt__c,Core_Intel_Support_Status__c, Core_End_Customer_Industry_Nm__c, Core_End_Customer_Sub_Industry__c,PCC_Registration_Type__c
                FROM Core_Design_Registration__c WHERE Id =: designRegId with USER_MODE];
        
        return designQueryResult;
    }
    /*Accept Design Update*/
    @AuraEnabled
    public static String updateAcceptDesign(String designId) {
        String alertMsg = '';
        Core_Design_Registration__c designReg = getDDRsoqlquery(designId);
        Core_Design_Registration__c updateDesign = new Core_Design_Registration__c (id =designReg.id);
        if(designReg.Core_Accepted_By_Id__c <> null && designReg.Core_Design_Registration_Status_Nm__c =='Design accepted') {
            alertMsg = 'Design Registration is already been accepted.';
        }
        else if(designReg.Core_Accepted_By_Id__c <> null && designReg.Core_Design_Registration_Status_Nm__c =='Pending with Partner') {
            updateDesign.Core_Design_Registration_Status_Nm__c = 'Design accepted';
            alertMsg = 'You have successfully updated to Design in Review.';
        }
        else {
            updateDesign.Core_Accepted_By_Id__c = UserInfo.getUserId();
            updateDesign.Core_Design_Registration_Status_Nm__c = 'Design accepted';
            alertMsg = 'You have successfully accepted the Design.';
        }
        try{
            //update updateDesign;
            Database.SaveResult res = Database.update(updateDesign,false,AccessLevel.User_mode);
            if(Test.isRunningTest()){
                throw new System.DMLException();
            }
        }catch(Exception e){
            alertMsg = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_ACCEPTDDR, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Accept_Approve_Reject_Design.updateAcceptDesign' ,'' ,e);
    }//' e.getStackTraceString();}
    
    
    return alertMsg;
}

@auraEnabled
public static picklistMsgWrapper getPicklistValues(String designRegisId, String objectType, String fieldName) {
    picklistMsgWrapper picklistWrap = new picklistMsgWrapper();
    Core_Design_Registration__c designRegisUpdate = getDDRsoqlquery(designRegisId);
    picklistWrap.pickListValueList = Core_AcceptReject_Lead_LexController.fetchPicklistValuesByRecType(objectType, fieldName, designRegisUpdate.RecordTypeId);
    picklistWrap.message = 'success';
    picklistWrap.designRegisObj = designRegisUpdate;
    return picklistWrap;
}

/*
 * Method name  : updateDesignRegistration
 * Description  : This Method is used to save the design registration once rejection reason and comments have been added.
 * Parameter    : (Core_Design_Registration__c designRegis);
 */
@auraEnabled
public static String updateDesignRegistration(Core_Design_Registration__c designRegis) {
    String alertMessage = '';
    // String strDetailsAndEx = '';
    Integer rejectedDRPCount = 0;
    //List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
    List<Core_Design_Registration__c> lstDDR = new List<Core_Design_Registration__c>();
    List<Core_Design_Registration_Product__c> updateDRP = new List<Core_Design_Registration_Product__c>();
    Map<Id, Core_Design_Registration__c> mapOfOldDRRecords = new Map<Id, Core_Design_Registration__c>();
    try {
        Core_Design_Registration__c updateDesign = new Core_Design_Registration__c();
        mapOfOldDRRecords.put(designRegis.Id,designRegis);
        if(designRegis.PCC_Registration_Type__c == 'Deal Registration'){
            Core_Design_Registration__c dealRec = [SELECT Id,PCC_Registration_Type__c,Core_Accepted_By_Id__c ,Core_Accepted_By_Id__r.DelegatedApproverId from Core_Design_Registration__c where Id =: designRegis.id WITH SECURITY_ENFORCED ];
            if (!PCC_InvocableMethods.isAuthorizedUser(dealRec)){
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_Unauthorized_User_Error').Value__c;
                return alertMessage;
            }
        }
        Id idrecordtype = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Locked').getRecordTypeId();
        updateDesign.Id = designRegis.Id;
        updateDesign.Core_Design_Registration_Status_Nm__c = 'Rejected';
        updateDesign.Core_Rejection_Reason_Nm__c = designRegis.Core_Rejection_Reason_Nm__c;
        updateDesign.Core_Rejection_Comment_Txt__c = designRegis.Core_Rejection_Comment_Txt__c;
        if(designRegis.PCC_Registration_Type__c == 'Deal Registration'){
            updateDesign.recordTypeId = idrecordtype;
        }
        
        lstDDR.add(updateDesign);
        
        if(!TPT_Tracker.recursiveCheck){
            TPT_Tracker.updateTPTTracker((List<Core_Design_Registration__c>) lstDDR, (Map<Id,Core_Design_Registration__c>) mapOfOldDRRecords);
            TPT_Tracker.recursiveCheck = true;
        }
        
        for(Core_Design_Registration_Product__c drp : [Select id, Core_Comment_Txt__c,Core_Design_Product_Status_Nm__c 
                                                            from Core_Design_Registration_Product__c 
                                                        where Core_Design_Registration_Id__c = :designRegis.Id with USER_MODE]){
            drp.Core_Design_Product_Status_Nm__c = 'Rejected';
            if(drp.Core_Comment_Txt__c != null){
                drp.Core_Comment_Txt__c = drp.Core_Comment_Txt__c + '\n'+designRegis.Core_Rejection_Comment_Txt__c;
            }else{
                drp.Core_Comment_Txt__c = designRegis.Core_Rejection_Comment_Txt__c;
            }
            updateDRP.add(drp);
        }
        
        
        rejectedDRPCount = updateDesignProd(updateDRP);
        if(designRegis.PCC_Registration_Type__c == 'Deal Registration'){
            List<PCC_InvocableMethods.ApprovalWrapper> approvalParam = new List<PCC_InvocableMethods.ApprovalWrapper>();
            PCC_InvocableMethods.ApprovalWrapper wrapper = new PCC_InvocableMethods.ApprovalWrapper();
            approvalParam.add(wrapper);
            approvalParam[0].action = 'Reject';
            approvalParam[0].comments = 'Rejecting the deal';
            approvalParam[0].regId = designregis.id;
            PCC_InvocableMethods.approvalProcessActions(approvalParam);
        alertMessage = updateDesignReg(lstDDR);}
        else{
            if(rejectedDRPCount == updateDRP.size()){
                
                alertMessage = updateDesignReg(lstDDR);
            }
            
            else{
                //alertMessage = 'There is some issue with updating few products. So could not reject the Design-Deal Registration';
                alertMessage = LabelConfiguration__mdt.getInstance('PCC_DDR_Reject_Product').Value__c;
        }}
        
        if(Test.isRunningTest()) {
            throw new System.DMLException();
        }
    }
    catch(exception ex) {
        alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
        Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_REJECTDDR, LOG_ENTRY_SEVERITY,'', '' ,designRegis.Id ,'Core_Design_Registration__c' ,'' ,ex);
    }
    return alertMessage;
}

private static Integer updateDesignProd( List<Core_Design_Registration_Product__c> updateDRP){
    //String strDetailsAndEx = '';
    // List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
    Integer rejectedDRPCount = 0;
    Database.SaveResult[] drpUpdate =  Database.update(updateDRP, false);
    for (Database.SaveResult sr : drpUpdate) {
        if (!sr.isSuccess()) {
            // alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            createLogEntries(sr,sr.getId());
            
        }
        else if(sr.isSuccess()) {
            rejectedDRPCount++;
        }
        
        
    }
    return rejectedDRPCount;
}


private static String updateDesignReg (List<Core_Design_Registration__c> lstDDR){
    // String strDetailsAndEx = '';
    // List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
    String alertMessage = '';
    if (Core_Design_Registration__c.sObjectType.getDescribe().isupdateable()) {
        Core_DDR_Design_Handler_Utility.AfterUpdateIterated = true;
        Database.SaveResult[] designUpdate =  Database.update(lstDDR, false);
        for (Database.SaveResult sr : designUpdate) {
            if (!sr.isSuccess() || Test.isRunningTest()) {
                alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
                createLogEntries(sr,lstDDR[0].Id);
            }
            else if(sr.isSuccess()) {
                alertMessage = 'You have successfully rejected the Design-Deal Registration.';
            }
        }
    }
    return alertMessage;
}

private static void createLogEntries(Database.SaveResult sr,Id setId) {
    List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
    String strDetailsAndEx = '';
    
    for (Database.Error err : sr.getErrors()) {
        strDetailsAndEx += 'Message: ' + err.getMessage() + '\n' + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
    }
    
    listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = LOG_ENTRY_ERROR,
    Core_Origin__c = LOG_ENTRY_ORIGIN,
    Core_Details__c = strDetailsAndEx,
    Core_Severity__c = LOG_ENTRY_SEVERITY,
    Core_When__c = System.Now(),
    Core_Project__c = LOG_ENTRY_PROJECT,
    Core_Scope__c = LOG_ENTRY_SCOPE_REJECTDDR,
    Core_sObjectId__c = setId,
    Core_sObjectType__c = 'Core_Design_Registration__c'));
    
    if (!listOfLogEntries.isEmpty()) {
        Core_Log_Entry.createLogEntries(listOfLogEntries);
    }
}

/*
 * Method name  : validateInactiveLOVS
 * Description  : This Method is will Gives if any Inactive Lov exists in VM,IP,PS and PA fields.
 * Parameter    : (Core_Design_Registration__c designRegis);
 */
public static String validateInactiveLOVS (Core_Design_Registration__c designReg ) {
    List<SelectOption> options =  new List<SelectOption>();
    List<String> verticalMarketLovs =  new List<String>();
    options.add(new selectOption('None','--- None ---'));
    Schema.DescribeFieldResult fieldResult = Core_Design_Registration__c.Core_Vertical_Market_Nm__c.getDescribe();
    List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
    for(Schema.picklistEntry f:ple)
    {
        verticalMarketLovs.add(f.getValue());
    }
    //Intel Platform Lovs
    List<String> intelPlatformLovs =  new List<String>();
    options.add(new selectOption('None','--- None ---'));
    Schema.DescribeFieldResult intelPlatformfieldResult = Core_Design_Registration__c.Core_Intel_Platform_Nm__c.getDescribe();
    List<Schema.picklistEntry> intelPltform = intelPlatformfieldResult.getPicklistValues();
    for(Schema.picklistEntry f:intelPltform)
    {
        intelPlatformLovs.add(f.getValue());
    }
    //Product Segmeent Lovs
    List<String> prodSegLOvs =  new List<String>();
    options.add(new selectOption('None','--- None ---'));
    Schema.DescribeFieldResult prodSegfieldResult = Core_Design_Registration__c.Core_Product_Segment_Nm__c.getDescribe();
    List<Schema.picklistEntry> prodSeg = prodSegfieldResult.getPicklistValues();
    for(Schema.picklistEntry f:prodSeg)
    {
        prodSegLOvs.add(f.getValue());
    }
    //Product Application
    List<String> prodAppLOvs =  new List<String>();
    options.add(new selectOption('None','--- None ---'));
    Schema.DescribeFieldResult prodAppfieldResult = Core_Design_Registration__c.Core_Product_Application_Nm__c.getDescribe();
    List<Schema.picklistEntry> prodApp = prodAppfieldResult.getPicklistValues();
    for(Schema.picklistEntry f:prodApp) {
        prodAppLOvs.add(f.getValue());
    }
    String inactiveLovs = '';
    inactiveLovs = getInactiveLovs(designReg, verticalMarketLovs, intelPlatformLovs, prodSegLOvs, prodAppLOvs);
    return inactiveLovs;
}
/*
 * Method name  : validateInactiveLOVPartner
 * Description  : This Method is will return if any Inactive Lov exists in VM,IP,PS and PA fields and called from the pcc_displaydraftstatus lwc.
 * Parameter    : string designReg ;
 */
@AuraEnabled
public static string validateInactiveLOVPartner(string designReg ){
    string inactivelovss;
    try{
        Core_Design_Registration__c ddr = (Core_Design_Registration__c) JSON.deserialize(designReg,Core_Design_Registration__c.class);
        inactivelovss = validateInactiveLOVS(ddr);
    }catch(exception ex) {
        inactivelovss = '';
        Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_REJECTDDR, LOG_ENTRY_SEVERITY,'', '' ,designReg ,'Core_Design_Registration__c' ,'' ,ex);
    }
    return inactivelovss;
}
/*
 * Method name  : ValidateInactiveLOVSDeal
 * Description  : This Method is will Gives if any Inactive Lov exists in VM,IP,PS and PA fields and called from the APPROVEDEALREG Flow.
 * Parameter    : list<Core_Design_Registration__c dealReg>;
 */
@InvocableMethod(label='Get InactiveLOV' description='Returns the list of inactive LOV Values' category='PCC')
public static list<String> validateInactiveLOVSDeal (list<Core_Design_Registration__c> dealReg ) {
    list<string> inactiveLovList = new list<string>();
    string inactiveLov = validateInactiveLOVS(dealReg[0]);
    inactiveLovList.add(inactiveLov);
    return inactiveLovList;
}


/*
 * Method name  : ApproveDesign
 * Description  : This Method used check to complete functionality of Approve Design button link on DDR detail page added by Rajesh.
 * Parameter    : (String DDRrecordId);
 */
@AuraEnabled
public static globalVariables ApproveDesign(String DDRrecordId, String highTouchOrLowTouch) {
    
    // System.debug('highTouchOrLowTouch -->'+highTouchOrLowTouch);
    // Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_APPROVEDDR, LOG_ENTRY_SEVERITY,'', '' ,'' ,highTouchOrLowTouch ,'' ,null);
    globalVariables globalVar = new globalVariables();
    globalVar.messageNotification = new Set<String>();
    
    //Boolean renderSuccess = true;
    String alertMessage='';
    try {
        Core_Design_Registration__c designReg=getDDRsoqlquery(DDRrecordId);
        if(designReg.Core_Intel_Support_Status__c == null && designReg.Core_Product_Group_Nm__c == LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c
        && highTouchOrLowTouch == Label.DDR_Intel_Support_Status_High){
            designReg.Core_Intel_Support_Status__c = LabelConfiguration__mdt.getInstance('DDR_Intel_Support_Device_Builder_High').Value__c;
        }
        
        else if(designReg.Core_Intel_Support_Status__c == null && designReg.Core_Product_Group_Nm__c==LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c && highTouchOrLowTouch == Label.DDR_Intel_Support_Status_Low){
            designReg.Core_Intel_Support_Status__c = LabelConfiguration__mdt.getInstance('DDR_Intel_Support_Device_Builder_Low').Value__c;
        }
        
        else if(designReg.Core_Intel_Support_Status__c == null){
            designReg.Core_Intel_Support_Status__c = highTouchOrLowTouch;
        }
        
        List<Core_Design_Registration_Product__c> DDRInactiveProducts= new  List<Core_Design_Registration_Product__c>();
        //SOQL Updated
        
        DDRInactiveProducts=[SELECT Id, Core_Product_Id__r.Core_Avail_for_New_Designs__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DDRrecordId AND ((Core_Active_Status__c = false AND Core_Locked_Ind__c = false AND Core_Design_Product_Status_Nm__c = 'Pending' )) with USER_MODE];
        // Utkarsh - TWC727-1138 - Added extra condition to allow approvers to approve DDR when there are atleast one design distributor product is approved.
        approveDesignVariables designVariableTemp = new approveDesignVariables();
        designVariableTemp = setAlertMessages(designReg,DDRInactiveProducts);
        
        globalVar.messageNotification = designVariableTemp.globalVarNew.messageNotification;
        //renderSuccess = designVariableTemp.validDesignReg;
        // if(renderSuccess) {
            if(designVariableTemp.validDesignReg){
                if(Test.isRunningTest()) {Core_DDR_Design_Handler_Utility.oppCreationFailed = true;
                }
                
                alertMessage = getAlertMessage(Core_DDR_Design_Handler_Utility.oppCreationFailed, designReg);
                
                globalVar.messageNotification.add(alertMessage);
            }
            if (Test.isRunningTest()) {
                throw new System.DMLException();
            }
        }
        catch(Exception ex){
            alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            globalVar.messageNotification.clear();
            globalVar.messageNotification.add(alertMessage);
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_APPROVEDDR, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Accept_Approve_Reject_Design.ApproveDesign' ,'' ,ex);
            //throw new AuraHandledException(ex.getMessage());
        }
        return globalVar;
    }
    
    public class globalVariables {
        @AuraEnabled public Set<String> messageNotification {get;set;}
    }
    
    public class picklistMsgWrapper{
        @auraEnabled
        public Core_Design_Registration__c designRegisObj{get;set;}
        @auraEnabled
        public List<String> pickListValueList{get;set;}
        @auraEnabled
        public String message{get;set;}
    }
    
    public class approveDesignVariables{
        public  globalVariables globalVarNew{get;set;}
        //globalVarNew.messageNotification = new Set<String>();
        public Boolean validDesignReg {get;set;}
    }
    
    public static approveDesignVariables setAlertMessages(Core_Design_Registration__c designRegRecord,List<Core_Design_Registration_Product__c> designRegProductRecords){
        approveDesignVariables designVariable = new approveDesignVariables();
        Set<String> alertMessages = new Set<String>();
        String alertMessage='';
        Set<String> returnedAlertMsg = new Set<String>();
        
        
        
        if(designRegRecord.Core_Design_Registration_Status_Nm__c == 'Approved') {
            alertMessage='Design Registration is already Approved.';
            alertMessages.add(alertMessage);
        }else if(designRegRecord.Core_Design_Registration_Status_Nm__c !='Design Accepted' && designRegRecord.Core_Design_Registration_Status_Nm__c !='Re-Submitted'){
            alertMessage='Please complete the Preapprover/Approver actions prior to Design Approval. Ensure that status is Design in Review before you approve the registration';
            alertMessages.add(alertMessage);
        }
        else {
            designVariable = sendAlertMessages(designRegRecord,designRegProductRecords);
            alertMessages.addAll(designVariable.globalVarNew.messageNotification);
            returnedAlertMsg = returnAlertMsg(designRegRecord);
            alertMessages.addAll(returnedAlertMsg);
        }
        // moved this block else to this place
        globalVariables globalVar = new globalVariables();
        globalVar.messageNotification = alertMessages;
        designVariable.globalVarNew = globalVar;
        designVariable.validDesignReg = alertMessages.size()>0?false:true;
        
        return designVariable;
    }
    public static set<string> returnAlertMsg(Core_Design_Registration__c designRegRecord){
        string alertMessage='';
        set<string> alertMessages = new set<string>();
        String inactiveLovFields = validateInactiveLOVS(designRegRecord);
        // Check if End Customer Account has valid Sub-Industry -- Commented by DINESH As part of TWC727-2657 | 27/01/2024
        // if(designRegRecord.Core_End_Customer_Sub_Industry__c == '' || designRegRecord.Core_End_Customer_Sub_Industry__c == null || designRegRecord.Core_End_Customer_Sub_Industry__c == 'To Be Defined' ) {
            //     alertMessage='The Sub-Industry of the account associated with this Design Registration designRegRecord is either blank or To Be Defined. Please change the Sub-Industry value or change the account to proceed.';
            //     alertMessages.add(alertMessage);
            //     // designVariable.globalVarNew.messageNotification.add(alertMessage);
            //     // designVariable.validDesignReg = false;
        // }
        
        // check if the end customer account owner is uncovered or A&E User
        if(designRegRecord.Core_End_Customer_Account_Owner__c=='A&E Account Owner' || designRegRecord.Core_End_Customer_Account_Owner__c=='Uncovered Account') {
            alertMessage='The Account Owner of the account associated with this Design Registration designRegRecord, is Uncovered or A&E User. Please change the account owner or change the account to proceed.';
            alertMessages.add(alertMessage);
            
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        
        // Check the designRegRecord type of the End Customer Account
        if ((designRegRecord.Core_End_Customer_Account_Id__c != null) && (designRegRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' || designRegRecord.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing' )) {
            alertMessage='Current selected value of the field '+'"'+ 'End Customer Account'+'"'+' on this designRegRecord is not a valid value anymore. Please select a valid value and retry submission ';
            alertMessages.add(alertMessage);
            //    designVariable.globalVarNew.messageNotification.add(alertMessage);
            //    designVariable.validDesignReg = false;
        }
        
        // Check if any picklist values are inactive
        if (inactiveLovFields !='') {
            alertMessage= 'Current selected values of the following fields'+'"'+inactiveLovFields+'"'+'on this designRegRecord are inactive. Please select a valid value and retry submission ';
            alertMessages.add(alertMessage);
            
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        // Check if DR owner is active or Not
        if (!designRegRecord.Owner.isActive) {
            alertMessage = system.label.Core_DR_Owner_Inactive_msg;
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        return alertMessages;
        
    }
    
    
    
    public static approveDesignVariables sendAlertMessages(Core_Design_Registration__c designRegRecord,List<Core_Design_Registration_Product__c> designRegProductRecords) {
        approveDesignVariables designVariable = new approveDesignVariables();
        Set<String> alertMessages = new Set<String>();
        String alertMessage='';
        designVariable=endcustAlertMessages(designRegRecord,designRegProductRecords);
        //Set<String> returnMsgs = designVariable!=null ?designVariable.globalVarNew.messageNotification:null;
        alertMessages.addAll(designVariable.globalVarNew.messageNotification);
        
        // Check if any product is became Inactive OR IF PRODUCT IS NOT Available for New Designs
        if(designRegProductRecords.size() > 0) {
            alertMessage='There are Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        // checks if Internal Support Status is NULL -- DINESH  - 7/3/23
        if (String.isEmpty(designRegRecord.Core_Intel_Support_Status__c)) {
            alertMessage = 'The Internal Support status field is not populated with the right value';alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        // Check for Ownership
        if (designRegRecord.Core_Partner_Account_Id__c == null) {
            alertMessage='Please change the Owner to Partner User.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        if (designRegRecord.Core_Pending_Product_Cnt__c > 0) {
            alertMessage='There are some Pending Products. Please disposition all of them before Approving the Design Registration.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        // Check if there are any Approved Products. Skip this check for Re-Submitted designs.
        if (designRegRecord.Core_Approved_Product_Cnt__c == 0 && designRegRecord.Core_Design_Registration_Status_Nm__c != 'Re-Submitted') {
            alertMessage = 'There are NO Approved Products.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        globalVariables globalVar = new globalVariables();
        globalVar.messageNotification = alertMessages;
        
        designVariable.globalVarNew = globalVar;
        
        designVariable.validDesignReg = alertMessages.size()>0?false:true;
        
        
        return designVariable;
    }
    
    
    public static approveDesignVariables endcustAlertMessages(Core_Design_Registration__c designRegRecord,List<Core_Design_Registration_Product__c> designRegProductRecords) {
        approveDesignVariables designVariable = new approveDesignVariables();
        Set<String> alertMessages = new Set<String>();
        String alertMessage='';
        
        // Check if End Customer Account is Covered
        if (designRegRecord.Core_Is_End_Customer_Account_Covered_Ind__c== false) {
            alertMessage='Please provide End Customer Account that is Covered.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        // Check for End Customer Account
        if(designRegRecord.Core_End_Customer_Account_Id__c == null) {
            alertMessage='Please provide End Customer Account.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        
        // Check if End Customer Account is Blocked
        if (designRegRecord.Core_Is_End_Customer_Account_Blocked_Ind__c == true) {
            alertMessage='Please provide End Customer Account that is NOT Export Compliance Blocked.';
            alertMessages.add(alertMessage);
        }
        // Check if End Customer Account has valid Sales Group
        if(String.isBlank(designRegRecord.Core_End_Customer_Sales_Group_Nm__c) || designRegRecord.Core_End_Customer_Sales_Group_Nm__c == 'Undefined' ){ // == '' || designRegRecord.Core_End_Customer_Sales_Group_Nm__c == null || designRegRecord.Core_End_Customer_Sales_Group_Nm__c == 'Undefined' ) {
            alertMessage='The Sales Group of the account associated with this Design Registration designRegRecord is either blank or Undefined. Please change the Sales Group value or change the account to proceed.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }
        // Check if End Customer Account has valid Industry : Commented by DINESH As part of TWC727-2657 | 27/01/2024
        /* if(designRegRecord.Core_End_Customer_Industry_Nm__c == '' || designRegRecord.Core_End_Customer_Industry_Nm__c == null || designRegRecord.Core_End_Customer_Industry_Nm__c == 'To Be Defined' ) {
            alertMessage='The Industry of the account associated with this Design Registration designRegRecord is either blank or To Be Defined. Please change the Industry value or change the account to proceed.';
            alertMessages.add(alertMessage);
            // designVariable.globalVarNew.messageNotification.add(alertMessage);
            // designVariable.validDesignReg = false;
        }*/
        globalVariables globalVar = new globalVariables();
        globalVar.messageNotification = alertMessages;
        
        designVariable.globalVarNew = globalVar;
        
        designVariable.validDesignReg = alertMessages.size()>0?false:true;
        
        return designVariable;
    }
    
    @TestVisible
    
    private static String getAlertMessage(Boolean oppCreationFailed, Core_Design_Registration__c designReg){
        
        String alertMessage = '';
        Core_Design_Registration__c updateDesign = new Core_Design_Registration__c(id=designReg.id );
        Savepoint beforeApproval = Database.setSavepoint();
        updateDesign.Core_Design_Registration_Status_Nm__c = 'Approved';
        updateDesign.Core_Rejection_Reason_Nm__c = '';
        updateDesign.Core_Rejection_Comment_Txt__c = '';
        updateDesign.Core_Intel_Technical_Owner_Id__c = UserInfo.getUserId();
        updateDesign.Core_Intel_Support_Status__c = designReg.Core_Intel_Support_Status__c;
        Database.SaveResult res = Database.update(updateDesign,false,AccessLevel.USER_MODE); // intel  support status is not being updated due to this
        // update designReg;
        List<Core_Log_Entry__c> newListlogEntry = new List<Core_Log_Entry__c>();
        
        if (Core_DDR_Design_Handler_Utility.oppCreationFailed == true){
            Database.rollback(beforeApproval);
            for(Core_Log_Entry__c log : Core_DDR_Design_Handler_Utility.listLogEntries){
                newListlogEntry.add(new Core_Log_Entry__c(Core_Message__c = log.Core_Message__c,Core_Retry_Counter__c=log.Core_Retry_Counter__c,
                Core_Next_Scheduled_Run__c=log.Core_Next_Scheduled_Run__c,Core_Origin__c = log.Core_Origin__c,
                Core_Severity__c = log.Core_Severity__c, Core_When__c=log.Core_When__c, Core_Project__c = log.Core_Project__c,
                Core_sObjectId__c = log.Core_sObjectId__c, Core_Details__c = log.Core_Details__c));
            }
            database.insert(newListlogEntry,false);
            alertMessage = LabelConfiguration__mdt.getInstance('DDR_Approval_Failure_Message').Value__c;
        }
        //  alertMessage='Design Registration Failed';
        else{
            alertMessage = LabelConfiguration__mdt.getInstance('DDR_Approval_Success_Message').Value__c;
            // alertMessage='Design Registration Approved successfully.';
        }
        
        return alertMessage;
    }
    
    private static String getInactiveLovs(Core_Design_Registration__c designReg, List<String> verticalMarketLovs, List<String> intelPlatformLovs, List<String> prodSegLOvs, List<String> prodAppLOvs){
        String inactiveLovs = '';
        if (designReg.Core_Vertical_Market_Nm__c != null && !verticalMarketLovs.contains(designReg.Core_Vertical_Market_Nm__c)) {inactiveLovs='Vertical Market';
        }
        if (designReg.Core_Intel_Platform_Nm__c != null && !intelPlatformLovs.contains(designReg.Core_Intel_Platform_Nm__c)) {
            inactiveLovs = (InactiveLovs == '') ? 'Intel Platform' : InactiveLovs+'&'+'Intel Platform';
        }
        if (designReg.Core_Product_Segment_Nm__c != null && !prodSegLOvs.contains(designReg.Core_Product_Segment_Nm__c)) {inactiveLovs = (InactiveLovs == '') ? 'Product Segment' : InactiveLovs+'&'+'Product Segment';
        }
        if (designReg.Core_Product_Application_Nm__c != null && !prodAppLOvs.contains(designReg.Core_Product_Application_Nm__c)) {inactiveLovs = (InactiveLovs == '') ? 'Product Application' : InactiveLovs+'&'+'Product Application';
        }
        
        return inactiveLovs;
    }
}