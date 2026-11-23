/****************************************************************************************************
Apex Class Name : Core_DDR_Design_Handler_Utility
    Version         : 1.0
    Created Date    : 24/07/2023
    Function        : Utility class for the trigger 'Core_DDR_Design_Trigger'
    Modifications   :
     *****************************************************************************************************
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Utkarsh                     24/07/2023             Created
 * Shraddha                    12/02/2024             Added pcc_designRegShare_M2M - To share Design registration records with M2M Integration users
 * Shraddha                    12/02/2024             Added pcc_opportunityShare_M2M - To share Opportunity records with M2M Integration users
 *****************************************************************************************************/
public without sharing Class Core_DDR_Design_Handler_Utility
{
    /*****
    Shortforms used:
        
    DR - Design Registration
        DRLI - Design Registration Line Item (DR Product)
        Opp - Opportunity
        OLI - Opportunity Line Item (Opportunity Product)
        PBE - Price book Entry
         *****/
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean oppCreationFailed = false;
    
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    public static string DR_STATUS_SUBMITTED = 'Submitted';
    public static string DR_STATUS_REJECTED = 'Rejected';
    
    public static string DR_LI_STATUS_APPROVED = 'Approved';
    public static string DR_LI_STATUS_PENDING = 'Pending';
    public static string PRICEBOOK_NAME = 'Partner Price Book';
    public static string Project = 'DDR';
    public static string Severity = 'High';
    public static string Log_Severity = 'Info';
    public static string InsertSuccess = 'Successfully Inserted';
    public static string OppLineInsertExceMtd = 'Core_DDR_Design_Handler.insertOppLineItems_Exception';
    public static string OppLineUpdateExceMtd = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps_Exception';
    public static string OppLineInsertLogEntry = 'Core_DDR_Design_Handler.insertOppLineItems.OppLineItemInsert';
    public static string OppLineUpdateLogEntry = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps.OppLineItemUpdate';
    public static string DesignProductOnOppLineInsert = 'Core_DDR_Design_Handler.insertOppLineItems.DesignProductUpdate';
    public static string DesignProductOnOppLineUpdate = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps.DesignProductUpdate';
    public static string OppTeamMemberInsert = 'Core_DDR_Design_Handler.insertOppLineItems.OppTeamMemberInsert';
    public static string OppPartnerInsert = 'Core_DDR_Design_Handler.insertOppLineItems.OppPartnerInsert';
    public static string DDRL5Mapping = 'Core_DDR_Design_Handler.insertOppLineItems.updateDDRL5Mapping';
    Public static string logErrorId;
    Public static Boolean iterated = true;
    Public static Boolean AfterUpdateIterated = true;
    Public static Boolean BeforeUpdateIterated = true;
    public static  String LOG_ENTRY_ORIGIN   = 'Core_DDR_Design_Handler';
    public static  String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static  String LOG_ENTRY_SCOPE    = 'Assign DDR Type';
    public static  String LOG_ENTRY_ERROR    = 'error';
    public static  String LOG_ENTRY_SEVERITY = 'High';
    public static  String LOG_ENTRY_INFO     = 'info';
    public static String logEntryMessage = '';
    public static String LOG_ENTRY_MSG = 'Error while Locking Deal Product';
    public static String LOG_VALIDATION_ERROR = 'Error while validating non Latin Characters';
    public static Set<String> oppInsert = new Set<String>(); // using this field for log entry - DINESH
    public static List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();
    public static List<Core_Design_Registration_Product__c> allexistingdrp = new List<Core_Design_Registration_Product__c>();
    public static boolean designRegistration = false;
    
    
    public static void processBeforeInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        populatePartnerAccount(newList, true); // updatted by DINESH - added true
        populateDDRFieldValues((List<Core_Design_Registration__c>) newList, 'Insert');
        validateDRTextFieldsForLatinChars(newList,oldMap,true);
    }
    
    public static void processAfterInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        //populatePartnerAccount(newList);
        designRegShare((List<Core_Design_Registration__c>) newList);
        //createTPTTracker((List<Core_Design_Registration__c>) newList);
        TPT_Tracker.CreateUpdateTPTTracker((List<Core_Design_Registration__c>) newList);
        //populateDDRPartnerType((List<Core_Design_Registration__c>) newList);
    }
    
    public static void processAfterUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        if(!TPT_Tracker.recursiveCheck){
            TPT_Tracker.updateTPTTracker((List<Core_Design_Registration__c>) newList, (Map<Id,Core_Design_Registration__c>) oldMap);
            TPT_Tracker.recursiveCheck = true;
        }
        logEntryMessage = '';
        logEntryMessage+='\n Core_DDR_Design_Handler_Utility.processAfterUpdate started.\n Heap Size : '+Limits.getHeapSize()+' \n CPU Time :'+Limits.getCpuTime();
        List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstRejectedDesigns = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignsForGroupName = new List<Core_Design_Registration__c>();
        Set<Id> setOfDDRIds = new Set<Id>();
        List<Id> DDRids = new list<Id>();
        set<id> drId = new Set<Id>();
        Map<Id,Id> DrpDr = new Map<Id,Id>();
        
        
        try
        {
            //Check for export compliance
            List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
            if(AfterUpdateIterated) {
                AfterUpdateIterated = false;
                
                logEntryMessage+='\n AfterUpdateIterated : '+AfterUpdateIterated;
                
                if(newList != null && !newList.IsEmpty()) {
                    for(Core_Design_Registration__c iDR : newList)
                    {
                        if(iDR.Core_Design_Registration_Status_Nm__c == 'Approved' || iDR.Core_Design_Registration_Status_Nm__c == 'Rejected') {
                            drId.add(iDR.Id);
                        }
                        if(oldMap.get(iDR.Id).Core_End_Customer_Account_Id__c != newMap.get(iDR.Id).Core_End_Customer_Account_Id__c)
                        {
                            lstDesignRegForExportCompl.add(iDR);
                        }
                        
                        if(oldMap.get(iDR.Id).OwnerId != newMap.get(iDR.Id).OwnerId)
                        {
                            lstDesignRegForSharing.add(iDR);setOfDDRIds.add(iDR.Id);
                        }
                    }
                    logEntryMessage+= '\n New DRs :'+JSON.serialize(newList[0].Id);
                }
                
                // commented by DINESH on 11/7/2024
                // allexistingdrp = [SELECT Id, Name, Core_Design_Registration_Id__c, Core_Partner_Tracking_Cd__c,
                //                   Core_Comment_Txt__c, Core_Design_Product_Status_Nm__c,
                //                   Core_Product_Id__r.Name, CreatedDate,Core_Design_Registration_Id__r.Owner.FirstName, LastModifiedDate
                //                   FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c IN :drId
                //                   ORDER BY LastModifiedDate DESC];
                // for (Core_Design_Registration_Product__c drp :allExistingDRP) {
                    //     DrpDr.put(drp.Id,drp.Core_Design_Registration_Id__c);
                // }
                //
                //To populate the partner account and share the design based on owner field
                if(lstDesignRegForSharing.size() > 0)
                {
                    
                    designRegShare(lstDesignRegForSharing);PCC_DDRL5ProductMapping_TriggerHandler.DDRL5MappingsSharing(setOfDDRIds);logEntryMessage+='\n DDRL5MappingsSharing completed';
                    //update sharing of transactional object as well
                    
                    
                }
                
                if(lstDesignRegForExportCompl.size() > 0)
                {
                    checkForExportCompliance(lstDesignRegForExportCompl);
                }
                if(newList != null && !newList.IsEmpty()) {
                    for(Core_Design_Registration__c iDR : newList) {
                        System.debug('Status--> '+oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c+' '+newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c);
                        if(iDR.Core_Partner_Account_Id__c != NULL && iDR.Core_Approver_Grp_Nm__c == NULL)
                        {
                            lstDesignsForGroupName.add(iDR);
                        }
                        
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && iDR.Core_Opportunity_Id__c == null && iDR.PCC_Registration_Type__c != 'Deal Registration')//Added by Suresh Palvadi
                        {
                            lstApprovedDRs.add(iDR);
                        }
                        
                        if((oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == 'Design accepted') && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                        {
                            DDRids.add(iDR.id);
                        }
                        
                        //Lock the rejected line items after header is locked
                        if((oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c != newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c )&& newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED)
                        {
                            lstRejectedDesigns.add(iDR);
                        }
                    }
                }
                
                if(lstDesignsForGroupName.size() > 0)
                {
                    updateGroupName(lstDesignsForGroupName);
                }
                
                if(lstRejectedDesigns.size() > 0)
                {
                    lockRejectedProducts(lstRejectedDesigns);
                }
                
                if(lstApprovedDRs.size() > 0)
                {
                    if (lstApprovedDRs.size() == 1) {
                        PCC_Deal_Approval_Process_Communication__e evt = new PCC_Deal_Approval_Process_Communication__e();
                        evt.PCC_Object__c = 'Opportunity';
                        evt.PCC_Record_ID__c = lstApprovedDRs[0].Id;
                        evt.PCC_Type__c = 'Design';
                        Database.SaveResult result = EventBus.publish(evt);
                    }
                    else{
                        processDesignOpportunity(lstApprovedDRs,DDRids);
                    }
                    
                }
                AfterUpdateIterated = false;
                logEntryMessage += '\n AfterUpdateIterated'+AfterUpdateIterated;
            }
            if(Test.isRunningTest()) {
                
                throw new System.DMLException();
            }
        }
        Catch (Exception e) {
            System.debug(e);
        }
        finally{
            logEntryMessage+='\n Core_DDR_Design_Handler_Utility.processAfterUpdate finished. \n Heap Size : '+Limits.getHeapSize()+' \n CPU Time :'+Limits.getCpuTime()+' \n SOQL Count: '+Limits.getQueries();
            Core_Log_Entry__c finalExcepLog =  new Core_Log_Entry__c(Core_Message__c = 'DR After Update Transaction Information', Core_Origin__c = 'Core_DDR_Design_Handler_Utility', Core_Severity__c = 'Info', Core_When__c = System.Now(),  Core_Project__c = Project, Core_Details__c = logEntryMessage, Core_sObjectType__c ='Core_Design_Registration__c',Core_sObjectId__c=newlist[0].Id,Core_Tags__c=String.join(oppInsert,','));
            listLogEntries.add(finalExcepLog);
            if(listLogEntries.size()>0) {
                database.upsert(listLogEntries,false);
            }
        }
    }

    // This method is created to process Opportunity related logic.
public static String processDesignOpportunity (List<Core_Design_Registration__c> lstApprovedDRs,  List<Id> DDRids) {
    List<Opportunity> lstInsertOpportunities = new List<Opportunity>();
    Map<String, Core_LogEntry_Switch__c> logSwitch;
     Pricebook2 priceBook;
     String errorMessage='';
    try{
                    priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME with USER_MODE];
        logSwitch = Core_LogEntry_Switch__c.getall();
                    if(lstApprovedDRs != null && !lstApprovedDRs.IsEmpty()) {
                        //prepare list of Opp to create new Opps
                        lstInsertOpportunities  = createOpportunity(lstApprovedDRs, Pricebook);
                        
                        List<id> insertOppIds = new List<id>();
                        if(lstInsertOpportunities.size() > 0){
                            
                            for(Opportunity opp : lstInsertOpportunities) {
                                oppInsert.add(opp.Name);
                            }
                            Integer i = 0;
                            Database.SaveResult[] lstInsertOpportunitiesCreation = Database.insert(lstInsertOpportunities, false);
                            String oppRecordIds ='';
                            String failedMessage ='';
                            for (Database.SaveResult sr : lstInsertOpportunitiesCreation){
                                if (!sr.isSuccess()){
                                    for(Database.Error err : sr.getErrors()){
                                        errorMessage += err.getMessage();
                                        failedMessage+='\n Opportunity Creation Failed. Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage();
                                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Retry_Counter__c=1,
                                        Core_Next_Scheduled_Run__c=System.Now(),Core_Origin__c = 'Opportunity Creation',
                                        Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project,
                                        Core_sObjectId__c = lstInsertOpportunities[i].Core_Design_Registration_Id__c));
                                        
                                        if(!(err.getMessage().contains('unable to obtain exclusive access to this record or 1 records'))) {
                                            
                                        oppCreationFailed = true;}
                                    }
                                    i++;
                                }else{
                                    oppRecordIds+=' Id :'+sr.getId();
                                }
                                
                            }
                            
                            errorMessage += OpportunityShare(lstInsertOpportunities);
                        //}
                        List<Core_Design_Registration__c> lstUpdateOppInDDR = new List<Core_Design_Registration__c>();
                        
                        if(lstInsertOpportunities.size() > 0) {
                            for(Opportunity opp: lstInsertOpportunities)
                            {
                                //add Opp Ids to create OLIs
                                insertOppIds.add(opp.id);
                                
                                if(opp.id !=null) {
                                    //add Opp Id to DR to update the opportunity lookup in DR
                                    Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                                    
                                    tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                                    
                                    lstUpdateOppInDDR.add(tempDR);
                                }
                            }
                            if(lstUpdateOppInDDR.size() > 0){
                                
                                Database.SaveResult[] lstUpdateOppInDDRResult = Database.update(lstUpdateOppInDDR,false,AccessLevel.User_mode);

                                for (Database.SaveResult sr : lstUpdateOppInDDRResult){
                                    if (!sr.isSuccess()){
                                        for(Database.Error err : sr.getErrors()){
                                            errorMessage += err.getMessage();
                                        }
                                    } 
                                }
                            }
                        }
                    }
                    //Call OLI creation future method
                    if(insertOppIds.size() > 0){  logEntryMessage += '\n insertOppLineItems method called from processAfterUpdate:';
                        if (LabelConfiguration__mdt.getInstance('DDR_OLI_ASYNC').value__c == 'No') {
                            errorMessage += insertOppLineItems(insertOppIds, DDRids);
                        }
                    }
                }
            return errorMessage;
            }
        catch(Exception e) { // utkarsh - log entry is not needed here since we are logging the records after partial upsert in try block.
            return e.getMessage();
        }
    }
    

// this method is being called in before and update triggers
// and populates l2 approver and partner accountid
public static void populatePartnerAccount(List<Core_Design_Registration__c> lstDesignReg, Boolean isBefore) {
    Set<Id> setOwnerIds = new Set<Id>();
    Set<Id> partnerAccountIds = new Set<Id>(); // added by DINESH
    if (lstDesignReg != null && !lstDesignReg.isEmpty()) {
        for (Core_Design_Registration__c iDesign : lstDesignReg) {
            setOwnerIds.add(iDesign.OwnerId);
            // partnerAccountIds.add(iDesign.Core_Partner_Account_Id__c);
        }
    }
    
    Map<Id, User> mapUserIdTOUserRecord = new Map<Id, User>([SELECT id, Name, Contact.Account.Id, Contact.Account.OwnerId FROM User WHERE Id IN: setOwnerIds]);
    
    for (User user : mapUserIdTOUserRecord.values()) {
        partnerAccountIds.add(user.Contact.Account.Id);
    }
    
    // get the approver id
    List<LabelConfiguration__mdt> actToApproverIds = [SELECT Id, label, value__c FROM LabelConfiguration__mdt WHERE label IN :partnerAccountIds];
    
    // create a map to store mapping of account and related owner
    Map<Id, Id> actToApproverIdMap = new Map<Id, Id>();
    if (actToApproverIds != null && !actToApproverIds.isEmpty()) {
        for (LabelConfiguration__mdt mdtRec : actToApproverIds) {
            actToApproverIdMap.put(mdtRec.label, mdtRec.value__c);
        }
    }
    
    List<Core_Design_Registration__c> lstUpdateDesignReg = new List<Core_Design_Registration__c>();
    
    try {
        if (lstDesignReg != null && !lstDesignReg.isEmpty()) {
            for (Core_Design_Registration__c iDR : lstDesignReg) {
                Core_Design_Registration__c objDesign;
                if (isBefore) {
                    objDesign = iDR;
                } else {
                    objDesign = new Core_Design_Registration__c(Id = iDR.Id);
                }
                
                // update partner account value based on the login distributor
                if (mapUserIdTOUserRecord.containsKey(iDR.OwnerId) && mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id != null) {
                    objDesign.Core_Partner_Account_Id__c = mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id;
                    // To change the group name based on the new partner account's location details and flag design to send email to new ISR group
                    objDesign.Core_Approver_Grp_Nm__c = null;
                    objDesign.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    // updated by DINESH
                    objDesign.L2_Approver__c = actToApproverIdMap != null && !actToApproverIdMap.isEmpty() && actToApproverIdMap.containsKey(iDR.Core_Partner_Account_Id__c) ? actToApproverIdMap.get(iDR.Core_Partner_Account_Id__c) : mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.OwnerId;
                } else {
                    objDesign.Core_Partner_Account_Id__c = null;
                    // To change the group name based on the new partner account's location details and flag design to send email to new ISR group
                    objDesign.Core_Approver_Grp_Nm__c = null;
                    objDesign.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    objDesign.L2_Approver__c = actToApproverIdMap != null && !actToApproverIdMap.isEmpty() && actToApproverIdMap.containsKey(iDR.Core_Partner_Account_Id__c) ? actToApproverIdMap.get(iDR.Core_Partner_Account_Id__c) : mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.OwnerId;
                }
                
                if (!isBefore) {
                    lstUpdateDesignReg.add(objDesign);
                }
            }
        }
        
        if (!isBefore && lstUpdateDesignReg.size() > 0) {
            Database.update(lstUpdateDesignReg,false,AccessLevel.User_mode);
        }
        
        if (Test.isRunningTest()) {
            throw new System.DMLException();
        }
    } catch (Exception e) {
        // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
    }
}


//Update : update approver group name for Embedded/IOT | Boards and System - DINESH
public static void updateGroupName(List<Core_Design_Registration__c> lstDesignRegistrations)
{
    Set<Id> setDistiAccountIds = new Set<Id>();
    List<Account> lstAccount = new List<Account>();
    List<Core_Design_Registration__c> lstUpdDesigns = new List<Core_Design_Registration__c>();
    
    // FPGA LOGIC COMMENTED OUT: Map for FPGA/Power product group approver assignments
    // Map<String,String>  mapFPGA_ISRCityToGroupName = new Map<String,String>();
    Map<String,String>  mapEmbedded_IOT_ISRCityToGroupName = new Map<String,String>();
    
    Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
    Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
    Set<string> listOfCountryForGrpName=new Set<String>();
    //get product group values from custom metadata
    List<String> prdGroupNames = LabelConfiguration__mdt.getInstance('Core_Product_Group_Nm_c').value__c.trim().split(';');
    try
    {
        for(Core_Location_To_Approver_Group_Mapping__c iISRMap : Core_Location_To_Approver_Group_Mapping__c.getAll().values())
        {
            if(Test.isRunningTest()) {iISRMap.Core_Active_Ind__c = TRUE;
            }
            
            if(iISRMap.Core_Active_Ind__c == TRUE){
                
                // FPGA LOGIC COMMENTED OUT: Building mapping for FPGA/Power product group
                /*
                if(iISRMap.Core_Product_Group_Nm__c == 'FPGA/Power'){
                    if(iISRMap.Core_State_Cd__c != NULL){
                        mapFPGA_ISRCityToGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                    }else if(iISRMap.Core_Country_Cd__c != NULL){
                        mapFPGA_ISRCityToGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                    }else if(iISRMap.Core_State_Cd__c == NULL && iISRMap.Core_Country_Cd__c == NULL)
                    {
                        mapFPGA_ISRCityToGroupName.put('All',iISRMap.Core_Approver_Group_Nm__c);
                    }
                }else 
                */
                if(prdGroupNames.contains(iISRMap.Core_Product_Group_Nm__c)){
                    if(iISRMap.Core_State_Cd__c != NULL){
                        mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                    }else if(iISRMap.Core_Country_Cd__c != NULL){
                        listOfCountryForGrpName.add(iISRMap.Core_Country_Cd__c);mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                    }
                    //added by DINESH for ASMO and EMEA Groups
                    else if(iISRMap.Region__c!=null) {
                        mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Region__c,iISRMap.Core_Approver_Group_Nm__c);
                    }
                    else if(iISRMap.Country__c!=null){
                        mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Country__c,iISRMap.Core_Approver_Group_Nm__c);
                    }else if(iISRMap.Core_State_Cd__c == NULL && iISRMap.Core_Country_Cd__c == NULL){
                        mapEmbedded_IOT_ISRCityToGroupName.put('All',iISRMap.Core_Approver_Group_Nm__c);
                    }
                }
            }
        }
        
        for(Core_Design_Registration__c iDR : lstDesignRegistrations)
        {
            setDistiAccountIds.add(iDR.Core_Partner_Account_Id__c);
        }
        
        lstAccount = [SELECT id, Name, BillingState, BillingCountry FROM Account WHERE Id IN: setDistiAccountIds with USER_MODE];
        
        for(Account iAcc : lstAccount)
        {
            mapAccountToBillingState.put(iAcc.Id, iAcc.BillingState);
            mapAccountToBillingCountry.put(iAcc.Id, iAcc.BillingCountry);
        }
        //get group name based on the DR's distributor account
        for(Core_Design_Registration__c iDR : lstDesignRegistrations)
        {
            Core_Design_Registration__c groupDesign = new Core_Design_Registration__c(Id = iDR.Id);
            
            // FPGA LOGIC COMMENTED OUT: Processing approver group assignment for FPGA/Power products
            /*
            if(iDR.Core_Product_Group_Nm__c == 'FPGA/Power')
            {
                if(iDR.Core_Design_Solution_Network_Ind__c == TRUE)
                {
                    groupDesign.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
                }
                else
                {
                    if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                    }
                    if(groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get(mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                    }
                }
            }
            else 
            */
            if(iDR.Core_Product_Group_Nm__c == 'Embedded/IOT Boards & Systems')
            {
                if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Partner_Account_Region_Cd__c!=null && iDR.PCC_End_Customer_Country__c!=null) {
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(iDR.PCC_End_Customer_Country__c);
                }
            }else if(iDR.Core_Product_Group_Nm__c =='Embedded/IOT'){
                //added by DINESH to update region specific group name one DDR
                if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Partner_Account_Region_Cd__c!=null
                    && (iDR.Core_Partner_Account_Region_Cd__c =='ASMO'|| iDR.Core_Partner_Account_Region_Cd__c =='EMEA') &&
                (!listOfCountryForGrpName.contains(mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c)) || !listOfCountryForGrpName.contains(iDR.Core_Partner_Account_Country_Cd__c))){
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(iDR.Core_Partner_Account_Region_Cd__c);
                }
                
                if( groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c)){
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                }
                if(groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c)){
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                }
            }
            
            // FPGA LOGIC COMMENTED OUT: Default group assignment for FPGA/Power
            /*
            if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Product_Group_Nm__c == 'FPGA/Power')
            {
                groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get('All');
            }
            else 
            */
            if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Product_Group_Nm__c == 'Embedded/IOT'){
                groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get('All');
            }
            lstUpdDesigns.add(groupDesign);
        }
        
        if(lstUpdDesigns.size() > 0 && Trigger.isUpdate && Trigger.isAfter)
        {
            //update lstUpdDesigns;
            Database.update(lstUpdDesigns,false,AccessLevel.User_mode);
            logEntryMessage+='\n updateGroupName method completed';
        }
        if(Test.isRunningTest()) {throw new System.DMLException();
        }
    }
    catch(Exception e)
    {
        // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
    }
    
}

public static void lockRejectedProducts(List<Core_Design_Registration__c> lstRejectedDesignReg)
{
    try{
        
        
        List<Core_Design_Registration_Product__c> lstRejectedProducts = new List<Core_Design_Registration_Product__c>();
        
        lstRejectedProducts = [SELECT id,Core_Design_Registration_Id__r.PCC_Registration_Type__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c IN: lstRejectedDesignReg AND Core_Design_Product_Status_Nm__c =: DR_STATUS_REJECTED with USER_MODE];
        List<Core_Design_Registration_Product__c> updateRejctedProducts = new List<Core_Design_Registration_Product__c>();
        if(lstRejectedProducts.size() > 0 )
        {
            Id idrecordtype = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();
            for(Core_Design_Registration_Product__c DesignProduct : lstRejectedProducts) {
                Core_Design_Registration_Product__c newRegProduct = new Core_Design_Registration_Product__c(id = DesignProduct.id);
                newRegProduct.Core_Locked_Ind__c = true;
                if (DesignProduct.Core_Design_Registration_Id__r.PCC_Registration_Type__c == 'Deal Registration'){
                    newRegProduct.RecordTypeId = idrecordtype;
                    //DesignProduct.RecordTypeId = Label.PCC_Deal_Registration_Locked;
                    //DesignProduct.RecordTypeId = LabelConfiguration__mdt.getInstance('PCC_Deal_Registration_Locked').Value__c;
                    //System.debug('recordtypeidvalue = '+LabelConfiguration__mdt.getInstance('Deal Registration Locked').Value__c);
                }else{
                    newRegProduct.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                }
                updateRejctedProducts.add(newRegProduct);
            }
            Database.update(updateRejctedProducts,false,AccessLevel.User_mode);
            logEntryMessage+='\n lockRejectedProducts method completed';
            //Approval.lock(lstRejectedProducts);
            
        }
        if(Test.isRunningTest()) {
            throw new System.DMLException();
        }
    }
    catch(Exception e)
    {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        // upsert ExcepLog;
        listLogEntries.add(ExcepLog);
    }
    
}

public static void checkForExportCompliance(List<Core_Design_Registration__c> lstDesignReg)
{
    try{
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplBlk = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplUnBlk = new List<Core_Design_Registration__c>();
        
        Map<Id,Core_Design_Registration__c> drIdToDrRecMap = new Map<Id,Core_Design_Registration__c>(lstDesignReg); //ApexGuru
        lstDesignReg = [SELECT id, Name, Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c, Core_Design_Registration_Status_Nm__c, Core_End_Customer_Export_Cmplnc_Bloc_Ind__c FROM Core_Design_Registration__c WHERE Id IN: lstDesignReg with USER_MODE];
        
        for(Core_Design_Registration__c iDesignReg : lstDesignReg)
        {
            /*   if(Test.isRunningTest()) {
                
                iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == TRUE;
                iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c != TRUE;
            } */
            if(iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == TRUE && iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c != TRUE)
            {
                Core_Design_Registration__c tDesignReg = new Core_Design_Registration__c(Id = iDesignReg.Id);
                tDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = TRUE;tDesignReg.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;lstDesignRegToupdateExportComplBlk.add(tDesignReg);
            }
            else if(iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == FALSE && iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c == TRUE && iDesignReg.Core_Design_Registration_Status_Nm__c == 'Submitted')
            {
                Core_Design_Registration__c tDesignReg = new Core_Design_Registration__c(Id = iDesignReg.Id);
                tDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = FALSE;
                
                lstDesignRegToupdateExportComplUnBlk.add(tDesignReg);
            }
        }
        
        if(lstDesignRegToupdateExportComplBlk.size() > 0)
        {
            update lstDesignRegToupdateExportComplblk;
            //Approval.Lock(lstDesignRegToupdateExportComplblk);
            
            List<Core_Design_Registration_Product__c> lstDesignRegProdToupdateExportComplBlk = new List<Core_Design_Registration_Product__c>();
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplblk WITH USER_MODE];
            if(lstDesignRegProdToupdateExportComplBlk.size() > 0){
                //Approval.Lock(lstDesignRegProdToupdateExportComplBlk);
                
                List<Core_Design_Registration_Product__c> lstLockDRProds = new List<Core_Design_Registration_Product__c>();
                for(Core_Design_Registration_Product__c iLockDRProds : lstDesignRegProdToupdateExportComplBlk){
                    Core_Design_Registration_Product__c tempDRProds = new Core_Design_Registration_Product__c(Id = iLockDRProds.Id);
                    tempDRProds.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;lstLockDRProds.add(tempDRProds);
                }
                // update lstLockDRProds;
                Database.update(lstLockDRProds,false,AccessLevel.User_mode);
            }
        }
        
        if(lstDesignRegToupdateExportComplUnBlk.size() > 0)
        {
            //update lstDesignRegToupdateExportComplUnBlk;
            Database.update(lstDesignRegToupdateExportComplUnBlk,false,AccessLevel.User_mode);
            logEntryMessage+='\n checkForExportCompliance method completed';
            //Approval.unLock(lstDesignRegToupdateExportComplUnBlk);
            // Commented by Dinesh - 12/1/23 - Unused code
            /*
            List<Core_Design_Registration_Product__c> lstDesignRegProdToupdateExportComplBlk = new List<Core_Design_Registration_Product__c>();
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplUnBlk];
            
            if(lstDesignRegProdToupdateExportComplBlk.size() > 0)
            {
                //Approval.unLock(lstDesignRegProdToupdateExportComplBlk);
            }        */
            if(Test.isRunningTest()) {
            throw new System.DMLException();}
        }
    }
    catch(Exception e)
    {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        //upsert ExcepLog;
        listLogEntries.add(ExcepLog);
    }
}

/*public static void createTPTTracker(List<Core_Design_Registration__c> newDesignRegList) {
    try{
        list<TPT_Tracker__c> trackerList = new list<TPT_Tracker__c>();
        for(Core_Design_Registration__c dR:newDesignRegList){
            if(dR.PCC_Registration_Type__c!='Deal Registration'){
                TPT_Tracker__c tracker = new TPT_Tracker__c();
                tracker.DealRegistration__c=dR.id;
                tracker.Status__c=dR.Core_Design_Registration_Status_Nm__c;
                tracker.Status_Change_Date_Time__c=string.valueof(DateTime.now());//dR.CreatedDate;
                trackerList.add(tracker);
            }
        }
        if(trackerList!=null && !trackerList.isEmpty()){
            Database.SaveResult[] lsr = Database.insert(trackerList,false);
        }
    }catch(Exception e) {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'TPTTrackerCreation', Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        listLogEntries.add(ExcepLog);
    }
}*/


/*public static void updateTPTTracker(List<Core_Design_Registration__c> newDesignRegList, Map<Id,Core_Design_Registration__c> oldMapDR) {
    try{
        list<TPT_Tracker__c> tptTrackersToUpdate = new list<TPT_Tracker__c>();
        DateTime now = DateTime.now();
        for(Core_Design_Registration__c designReg:newDesignRegList){
            Core_Design_Registration__c oldDesignReg = oldMapDR.get(designReg.id);
            if (designReg.Core_Design_Registration_Status_Nm__c != oldDesignReg.Core_Design_Registration_Status_Nm__c && designReg.PCC_Registration_Type__c!='Deal Registration') {
                TPT_Tracker__c tptTracker = [SELECT Id,Status__c ,Status_Change_Date_Time__c  FROM TPT_Tracker__c WHERE DealRegistration__c = :designReg.Id LIMIT 1];
                
                if (tptTracker!=null) {
                    String newStatusHistory = (tptTracker.Status__c != null ? tptTracker.Status__c + '; ' : '') +'<br/>'+ designReg.Core_Design_Registration_Status_Nm__c;
                    String timeStamp = (tptTracker.Status_Change_Date_Time__c != null ? tptTracker.Status_Change_Date_Time__c + ' ; ' : '') +'<br/>'+ string.valueof(DateTime.now());
                    
                    tptTracker.Status__c = newStatusHistory;
                    tptTracker.Status_Change_Date_Time__c = timeStamp;
                    if(designReg.Core_Design_Registration_Status_Nm__c != oldDesignReg.Core_Design_Registration_Status_Nm__c){
                        list<String> statusTimestamps = tptTracker.Status_Change_Date_Time__c.split(';');
                        DateTime lastDraftTime = DateTime.valueOf(statusTimestamps[0].trim());
                        Long timeDifferenceInMillis = now.getTime() - lastDraftTime.getTime();
                        
                        // Convert time difference to hours
                        //Long timeDifferenceInHours = timeDifferenceInMillis / (1000 * 60 * 60);
                        //tptTracker.Time_Taken_To_Submit__c = String.valueOf(timeDifferenceInHours);
                        
                        // Convert milliseconds to days, hours, minutes, and seconds
                        Integer days = (Integer)(timeDifferenceInMillis / (1000 * 60 * 60 * 24));
                        timeDifferenceInMillis -= days * 1000 * 60 * 60 * 24;
                        Integer hours = (Integer)(timeDifferenceInMillis / (1000 * 60 * 60));
                        timeDifferenceInMillis -= hours * 1000 * 60 * 60;
                        Integer minutes = (Integer)(timeDifferenceInMillis / (1000 * 60));
                        timeDifferenceInMillis -= minutes * 1000 * 60;
                        Integer seconds = (Integer)(timeDifferenceInMillis / 1000);
                        
                        string timeTaken = days + ' days, ' + hours + ' hours, ' + minutes + ' minutes, ' + seconds + ' seconds';
                        
                        tptTracker.Time_Taken_To_Submit__c = timeTaken;
                        
                    }
                    tptTrackersToUpdate.add(tptTracker);
                }
                if(tptTrackersToUpdate!=null && !tptTrackersToUpdate.isEmpty()){
                    Database.upsertResult[] lsr = Database.upsert(tptTrackersToUpdate,false);
                }
            }
        }
    }catch(Exception e) {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'TPTTrackerCreation', Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        listLogEntries.add(ExcepLog);
    }
}*/

/*DR Share*/
public static void designRegShare(List<Core_Design_Registration__c> newDesignRegList) {
    try{
        designShareWrapper drWrp = new designShareWrapper();
        
        Map<Id,Core_Design_Registration__c> drIdToDrRecMap = new Map<Id,Core_Design_Registration__c>(newDesignRegList); //ApexGuru
        List<Core_Design_Registration__c> designRegRoleList = [select id, owner.UserRoleId, CreatedById, CreatedBy.UserRoleId
                                                                   from Core_Design_Registration__c where id IN: drIdToDrRecMap.keySet()]; //ApexGuru
        
        if(designRegRoleList != null && !designRegRoleList.isEmpty()) {
            drWrp = pcc_designRegShare_M2M(designRegRoleList);
        }
        
        //Get the Group Id
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        if (drWrp.userRoleSet != null && !drWrp.userRoleSet.isEmpty()) {
            for(group grp: [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: drWrp.userRoleSet and type = 'role']) {
                roleAndGroupMap.put(grp.RelatedId, grp.id);
            }
        }
        
        // Create a new list of sharing objects for Design Registration
        List<Core_Design_Registration__Share> designRegShrs  = new List<Core_Design_Registration__Share>();
        
        // Declare variables for Design Registration sharing
        //Core_Design_Registration__Share designRoleShr;
        for(Core_Design_Registration__c designShr : designRegRoleList) {
            // Instantiate the sharing objects
            Core_Design_Registration__Share designRoleShr = new Core_Design_Registration__Share();
            designRoleShr.ParentId = designShr.Id; // Set the ID of record being shared
            designRoleShr.UserOrGroupId = roleAndGroupMap.get(designShr.owner.UserRoleId);// Set the ID of user or group being granted access
            designRoleShr.AccessLevel = 'edit'; // Set the access level
            designRoleShr.RowCause = 'Manual'; // Set the Apex sharing
            designRegShrs.add(designRoleShr);
        }
        
        if(drWrp.designRegShrsTemp != null) {
            designRegShrs.addAll(drWrp.designRegShrsTemp);
        }
        
        // Insert sharing records and capture save result
        Database.SaveResult[] lsr = Database.insert(designRegShrs,false);
        logEntryMessage+='\n designRegShare method completed';
        if(Test.isRunningTest()) {
            throw new System.DMLException();
        }
    }
    catch(Exception e) {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        //upsert ExcepLog;
        listLogEntries.add(ExcepLog);
    }
}

/* @desc: To share Design registration records with M2M Integration users
@dev: Shraddha M.
 */
private static designShareWrapper pcc_designRegShare_M2M(List<Core_Design_Registration__c> designRegRoleList) {
    //Create a set for Roles
    Map<String, String> designShareMap = new Map<String, String>();
    // Create a new list of sharing objects for Design Registration
    List<Core_Design_Registration__Share> designRegShrsTemp  = new List<Core_Design_Registration__Share>();
    Set<id> userRoleSet = new Set<id>();
    //wrapper instance
    designShareWrapper drWrp = new designShareWrapper();
    roleToIntegrationUrWrapper wrp = new roleToIntegrationUrWrapper();
    
    //to get the M2M Integration users id with respective role
    wrp = getRoleToIntMapping();
    
    //to get the userGroupId to share the design Registration records
    for(Core_Design_Registration__c designRegRole: designRegRoleList) {
        userRoleSet.add(designRegRole.owner.UserRoleId);
        //created by integration user
        if(wrp.intUserToRoleIdMap.containsKey(designRegRole.CreatedById)) {designShareMap.put(designRegRole.id, designRegRole.CreatedById);
        }
        //created by partner user
        if(designRegRole.CreatedBy.UserRoleId != null && wrp.roleToIntUserIdMap.containsKey(designRegRole.CreatedBy.UserRoleId)) {designShareMap.put(designRegRole.id, wrp.roleToIntUserIdMap.get(designRegRole.CreatedBy.UserRoleId));
        }
    }
    //Share Design Registration record with Integration user
    if(designShareMap!= null && !designShareMap.isEmpty()) {
        for(String drId : designShareMap.keySet()) {
            // Instantiate the sharing objects
            Core_Design_Registration__Share designRoleShr = new Core_Design_Registration__Share();designRoleShr.ParentId = drId;
            designRoleShr.UserOrGroupId = designShareMap.get(drId);designRoleShr.AccessLevel = 'edit';designRoleShr.RowCause = 'Manual';designRegShrsTemp.add(designRoleShr);
        }
    }
    
    drWrp.userRoleSet = userRoleSet;
    drWrp.designRegShrsTemp = designRegShrsTemp;
    return drWrp;
}

/*designShareWrapper*/
public class designShareWrapper {
    public Set<id> userRoleSet{get;set;}
    public List<Core_Design_Registration__Share> designRegShrsTemp{get;set;}
}

/*Opportunity Share*/
public static String OpportunityShare(List<Opportunity> newOppList) {
    String errorMsgShare;
    try{
        //Map<String, String> oppShareMap = new Map<String, String>();
        roleToIntegrationUrWrapper wrp = new roleToIntegrationUrWrapper();
        opportunityWrapper oppWrp = new opportunityWrapper();
        
        //to get the M2M Integration users id with respective role
        wrp = getRoleToIntMapping();
        
        Map<Id,Opportunity> oppIdToOppRecMap = new Map<Id,Opportunity>(newOppList); //ApexGuru
        //get the Opportunity details
        List<Opportunity> oppRoleList = [select id, Core_Technical_Owner__r.UserRoleId, Core_Design_Registration_Id__r.CreatedBy.UserRoleId, 
                                             Core_Design_Registration_Id__r.CreatedById
                                             from Opportunity where id IN: oppIdToOppRecMap.keySet()]; //ApexGuru
        
        if(oppRoleList != null && !oppRoleList.isEmpty()) {
            oppWrp = pcc_opportunityShare_M2M(oppRoleList);
        }
        
        //Get the Group Id
        List<Group> roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: oppWrp.userRoleSet and type = 'role'];
        
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        
        for(group grp: roleGroup) {
            roleAndGroupMap.put(grp.RelatedId, grp.id);
        }
        
        // Create a new list of sharing objects for Design Registration
        List<OpportunityShare> oppShrs  = new List<OpportunityShare>();
        
        // Declare variables for Design Registration sharing
        OpportunityShare oppRoleShr;
        
        for(Opportunity oppShr : oppRoleList) {
            
            oppRoleShr = new OpportunityShare(); // Instantiate the sharing objects
            
            oppRoleShr.OpportunityId = oppShr.Id; // Set the ID of record being shared
            oppRoleShr.UserOrGroupId = roleAndGroupMap.get(oppShr.Core_Technical_Owner__r.UserRoleId); // Set the ID of user or group being granted access
            oppRoleShr.OpportunityAccessLevel = 'edit'; // Set the access level
            oppRoleShr.RowCause = 'Manual'; // Set the Apex sharing
            oppShrs.add(oppRoleShr);
        }
        
        if(oppWrp.oppShrsTemp != null) {
            oppShrs.addAll(oppWrp.oppShrsTemp);
        }
        
        // Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed
        // into the operation
        Database.SaveResult[] lsr = Database.insert(oppShrs,false);
        //added by Dinesh to debug prduction issue on 12/12/2024
        for(Database.saveresult sr : lsr){
            if(!sr.isSuccess()){
                for(Database.error error : sr.getErrors()){
                    errorMsgShare = error.getMessage();
                    logEntryMessage+= '\n Err Code : '+error.getStatusCode() + ' Error Message :' + error.getMessage()+' Erroed Field :'+error.getFields();
                }
            }else{
                logEntryMessage+='\n Opportunity shared with Roles';
            }
        }
        logEntryMessage+='\n OpportunityShare method complete';
        if(Test.isRunningTest()) {
            throw new System.DMLException();
        }
        return errorMsgShare;
    }
    catch(Exception e)
    {
        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
        Database.upsert(ExcepLog,false,AccessLevel.User_mode);
        //upsert ExcepLog;
        return e.getMessage();
    }
}


/* @desc: To share Opportunity records with M2M Integration users
@dev: Shraddha M.
 */
private static opportunityWrapper pcc_opportunityShare_M2M(List<Opportunity> oppRoleList) {
    //Create a set for Roles
    Map<String, String> oppShareMap = new Map<String, String>();
    // Create a new list of sharing objects for Opportunities
    List<OpportunityShare> oppShrsTemp  = new List<OpportunityShare>();
    Set<id> userRoleSet = new Set<id>();
    //wrapper instance
    opportunityWrapper oppWrp = new opportunityWrapper();
    roleToIntegrationUrWrapper wrp = new roleToIntegrationUrWrapper();
    
    //to get the M2M Integration users id with respective role
    wrp = getRoleToIntMapping();
    
    //to get the userGroupId to share the opportunity records
    for(Opportunity oppRole: oppRoleList) {
        userRoleSet.add(oppRole.Core_Technical_Owner__r.UserRoleId);
        //created by integration user
        if(wrp.intUserToRoleIdMap.containsKey(oppRole.Core_Design_Registration_Id__r.CreatedById)) {oppShareMap.put(oppRole.id, oppRole.Core_Design_Registration_Id__r.CreatedById);
        }
        //created by partner user
        if(oppRole.Core_Design_Registration_Id__r.CreatedBy.UserRoleId != null && wrp.roleToIntUserIdMap.containsKey(oppRole.Core_Design_Registration_Id__r.CreatedBy.UserRoleId)) {oppShareMap.put(oppRole.id, wrp.roleToIntUserIdMap.get(oppRole.Core_Design_Registration_Id__r.CreatedBy.UserRoleId));
        }
    }
    
    System.debug('oppShareMap-->'+oppShareMap);
    
    //Share opportunity record with Integration user
    if(oppShareMap!= null && !oppShareMap.isEmpty()) {
        for(String opId : oppShareMap.keySet()) {
            // Instantiate the sharing objects
            OpportunityShare oppRoleShr1 = new OpportunityShare();oppRoleShr1.OpportunityId = opId;
            oppRoleShr1.UserOrGroupId = oppShareMap.get(opId);oppRoleShr1.OpportunityAccessLevel = 'edit';
            oppRoleShr1.RowCause = 'Manual';oppShrsTemp.add(oppRoleShr1);
        }
    }
    
    oppWrp.userRoleSet = userRoleSet;
    oppWrp.oppShrsTemp = oppShrsTemp;
    return oppWrp;
}

/*opportunityWrapper*/
public class opportunityWrapper {
    public Set<id> userRoleSet{get;set;}
    public List<OpportunityShare> oppShrsTemp{get;set;}
}

/*@des: To get the mapping between Role and Integration users to share DR and Opp
@owner: Shraddha M
 */
public static roleToIntegrationUrWrapper getRoleToIntMapping() {
    roleToIntegrationUrWrapper mappingWrp = new roleToIntegrationUrWrapper();
    Map<String, String> intUserToRoleIdMap = new Map<String, String>();
    Map<String, String> roleToIntUserIdMap = new Map<String, String>();
    
    //to get the M2M Integration users id with respective role
    for(LabelConfiguration__mdt mdt: [Select id, Category__c, DeveloperName, Label, Value__c 
                                          from LabelConfiguration__mdt where Category__c = 'M2M_SHARING']
    ) {
        List<String> userRoleIdList = mdt.Value__c.split(';');
        if(userRoleIdList.size() > 1) {
            intUserToRoleIdMap.put(userRoleIdList[0], userRoleIdList[1]);
            roleToIntUserIdMap.put(userRoleIdList[1], userRoleIdList[0]);
        }
    }
    mappingWrp.intUserToRoleIdMap = intUserToRoleIdMap;
    mappingWrp.roleToIntUserIdMap = roleToIntUserIdMap;
    
    return mappingWrp;
}

/*roleToIntegrationUrWrapper*/
public class roleToIntegrationUrWrapper {
    public Map<String, String> intUserToRoleIdMap{get;set;}
    public Map<String, String> roleToIntUserIdMap{get;set;}
}

//Suresh 09/25/2017-To create the Opportunity Line Items after approval (Opportunity before trigger causing too many SOQL queries, so written this method as FUTURE)
//Opportunity line items not getting copied on first DR Approval. Made insertOppLineItems() method inline to fix this.
public static String insertOppLineItems(List<id> insertOppIds, List<id> DDRids) {
    Pricebook2 priceBook;
    List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
    List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> lstDRLineItems = new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> lstProcessedDRLineItems = new List<Core_Design_Registration_Product__c>();
    
    Map<string, PriceBookEntry> mapProductNameTOPricebookEntry = new map<string, PriceBookEntry>();
    //  Map<Id, Opportunity> mapOppIdTOOpp = new Map<Id, Opportunity>();
    Map<Id, Opportunity> mapDRIDTOOpp = new Map<Id, Opportunity>();
    
    Map<Id, Opportunity> mapOppIDToOppRec = new Map<Id, Opportunity>();  //ApexGuru
    Map<String, Core_LogEntry_Switch__c> logSwitch;
    List<PCC_DDR_L5_Product_Mapping__c> l5ProdList = new List<PCC_DDR_L5_Product_Mapping__c>();
    List<Opportunity> lstInsertOpportunities ;
    String errorMessageOli='';
    
    //query Partner Price Book
    try{
        logSwitch = Core_LogEntry_Switch__c.getall();
        lstInsertOpportunities = [select id, name, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c, Account.OwnerID, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID from Opportunity where id IN: insertOppIds with USER_MODE];
        priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME with USER_MODE];
        logEntryMessage+='\n priceBook : '+JSON.serialize(priceBook);
        for(Opportunity iOpp : lstInsertOpportunities){
            mapDRIDTOOpp.put(iOpp.Core_Design_Registration_Id__c, iOpp);
            mapOppIDToOppRec.put(iOpp.Id, iOpp); //ApexGuru
        }
        
        // removed unused fields from this query
        lstDRLineItems = [SELECT id, Name,Core_Design_Registration_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__c, Core_Full_Year_Qty__c, Core_Target_Resale_Amt__c 
                              FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c IN: DDRids AND Core_Product_Id__r.IsActive = true with USER_MODE];
        // get product2 ids
        // Added by DINESH - 12/01/2023
        Set<Id> prd2Id = new Set<Id>();
        for(Core_Design_Registration_Product__c drp : lstDRLineItems) {
            prd2Id.add(drp.Core_Product_Id__c);
        }
        logEntryMessage+='\n prd2Id : '+prd2Id;
        // Find relevant price entries
        // updated by Dinesh 01/12/2023
        for(PricebookEntry iPBE : [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id =: priceBook.id AND isActive = true and Product2Id in :prd2Id WITH USER_MODE]){
            //mapProductNameTOPricebookEntry.put(iPBE.Product2.Name, iPBE);
            mapProductNameTOPricebookEntry.put(iPBE.Product2Id, iPBE);
        }
        logEntryMessage+='\n Pricebook Entry Map : '+mapProductNameTOPricebookEntry;
        
        for(Core_Design_Registration_Product__c iDDRLI : lstDRLineItems){
            //Rajadinakaran 10/05/2017: Added all the line items to update processed
            Core_Design_Registration_Product__c productToUpdate = new Core_Design_Registration_Product__c(id = iDDRLI.id );
            if(iDDRLI.Core_Design_Product_Status_Nm__c != DR_LI_STATUS_PENDING){
                productToUpdate.Core_Locked_Ind__c = TRUE;
                
                productToUpdate.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                
                lstProcessedDRLineItems.add(productToUpdate);
            }
            if(iDDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED){
                lstApprovedDRLineItems.add(iDDRLI);
        }   }
        if(lstProcessedDRLineItems.size() > 0){
            // updated by Dinesh
            String successdrp ='';
            String failedDrp = '';
            for(Database.SaveResult result :  Database.update(lstProcessedDRLineItems,false,AccessLevel.User_mode)) {
                if(result.isSuccess()) {
                    successdrp+= '\n DRP Updated : Id -'+result.getId();
                }else{
                    String errorMessage = '';
                    for(Database.Error err : result.getErrors()) {errorMessage +='Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                    errorMessageOli += err.getMessage();    
                    }
                    failedDrp+= '\n DRP Update Failed : Id -'+result.getId()+' Error : '+errorMessage;
            }}
            logEntryMessage += '\n Updated DR Line items : ' + successdrp + (String.isNotBlank(failedDrp) ? '\n Failed DRP : ' + failedDrp : '');
        }
        //add list of OLIs for OLI creation
        for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems){
            if(mapDRIDTOOpp.containskey(iDRLI.Core_Design_Registration_Id__c))
            {
                OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = mapDRIDTOOpp.get(iDRLI.Core_Design_Registration_Id__c).Id);
                //updated by dinesh = 01/12/2023
                if(!mapProductNameTOPricebookEntry.isEmpty() && mapProductNameTOPricebookEntry.containsKey(iDRLI.Core_Product_Id__c)) {
                    createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                    createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                    createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                    createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;
                    createOppLineItem.PricebookEntryId = mapProductNameTOPricebookEntry.get(iDRLI.Core_Product_Id__c).id;
                    createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                    lstOpportunityLIs.add(createOppLineItem);
        }}}
        logEntryMessage+='\n Opportunity Line items to be inserted :'+JSON.serialize(lstOpportunityLIs);
        
        if(!lstOpportunityLIs.isEmpty()){
            Integer i = 0;
            String SuccessMessage='';
            String errorMessage = '';
            for (Database.SaveResult sr : Database.insert(lstOpportunityLIs,false,AccessLevel.User_mode)){
                if(sr.isSuccess()){
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    SuccessMessage+= '\n Inserting Opportunity LineItems Success: '+sr.getId();
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessageOli += err.getMessage();
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_sObjectId__c = lstOpportunityLIs[i].Failed_DDR_RecordID__c));
                    }
            i++;}}
            logEntryMessage += '\n Successfully inserted Opportunity Line Items : ' + SuccessMessage + (String.isNotBlank(errorMessage) ? '\n Failed Opportunity Line Items : ' + errorMessage : '');
        }
        List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
        Map<id,OpportunityLineItem>  mapOpLineItem = new Map<id,OpportunityLineItem>();
        //Update OLI Id in DRLI
        for(OpportunityLineItem iOLI : lstOpportunityLIs){
            Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id, Core_Locked_Ind__c = TRUE);
            iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
            lstDRLIWithOLIId.add(iDRLI);
            mapOpLineItem.put(iOLI.Core_Design_Registration_Product_Id__c,iOLI);
        }
        if(!lstDRLIWithOLIId.isEmpty()){
            String SucessMessage ='';
            String errorMessage ='';
            Database.SaveResult[] lstDesignProductUpdate = Database.update(lstDRLIWithOLIId, false);
            for (Database.SaveResult sr : lstDesignProductUpdate){
                if(sr.isSuccess()){
                    SucessMessage+= '\n OLI ID Update on DRP: '+sr.getId();
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessageOli += err.getMessage();
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}}
            logEntryMessage += '\n Success Opportunity Line Items Updated on DRP : ' + SucessMessage + (String.isNotBlank(errorMessage) ? '\n Failed Opportunity Line Items Update on DRP : ' + errorMessage : null);
        }
        //Create TeamMember
        list<OpportunityTeamMember> OppTeamMember = new list<OpportunityTeamMember>();
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        lstOppTeamMember = [SELECT Id, Name, UserId, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: lstInsertOpportunities with USER_MODE];
        Map<Id, Id> mapTeamMemberIdOpportunityId = new Map<Id, Id>();
        for(OpportunityTeamMember iTM : lstOppTeamMember){
            mapTeamMemberIdOpportunityId.put(iTM.UserId, iTm.OpportunityId);
        }
        for(Opportunity opp : lstInsertOpportunities) {
            if(!mapTeamMemberIdOpportunityId.containskey(Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID)){
                OpportunityTeamMember createOppTeamMember = new OpportunityTeamMember();
                createOppTeamMember.OpportunityId = opp.id;
                createOppTeamMember.TeamMemberRole = 'Team Member (100%)';
                createOppTeamMember.userid = Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID;
                //createOppTeamMember.Core_Description_of_Contribution__c = createOppTeamMember.TeamMemberRole;
                OppTeamMember.add(createOppTeamMember);
        }}
        if(!OppTeamMember.isEmpty()){
            Database.SaveResult[] lstDesignProductUpdate = Database.insert(OppTeamMember, false);
            String successMessage='';
            String errorMessage='';
            for (Database.SaveResult sr : lstDesignProductUpdate){
                if(sr.isSuccess()){
                    SuccessMessage+= '\n Inserted Oppty Team Member Id: '+sr.getId();
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppTeamMemberInsert, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessageOli += err.getMessage();
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppTeamMemberInsert, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}}
            logEntryMessage += '\n Success Opportunity Team Mem. Success : ' + SuccessMessage + (String.isNotBlank(errorMessage) ? '\n Opportunity Team Mem failed : ' + errorMessage : '');
        }
        
        //Create opportunity partner using Partner account in DR
        List<Core_Opportunity_Partner__c> OppPartnerlist = new List<Core_Opportunity_Partner__c>();
        Set<Id> odrMatrixAcctIdSet = new Set<Id>();
        list<PCC_ODR_Onboarding_Matrix__c> odrList = [SELECT PCC_Account__c FROM PCC_ODR_Onboarding_Matrix__c WITH SYSTEM_MODE];
        for (PCC_ODR_Onboarding_Matrix__c odrMatrix : odrList) {
            odrMatrixAcctIdSet.add(odrMatrix.PCC_Account__c);
        }
        
        for(Opportunity opp : lstInsertOpportunities) {
            Core_Opportunity_Partner__c op = new Core_Opportunity_Partner__c(Core_Opportunity__c = opp.id, Core_Partner_Type__c = (odrMatrixAcctIdSet.contains(opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c)) ? 'ODM' :'Distributor', Core_Partner_Role__c = 'Co-Design');
            op.Core_Partner__c = opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c;
            OppPartnerlist.add(op);
        }
        if(!OppPartnerlist.isEmpty()){
            Database.SaveResult[] lstDesignProductUpdate = Database.insert(OppPartnerlist, false);
            for (Database.SaveResult sr : lstDesignProductUpdate){
                if(sr.isSuccess()){
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppPartnerInsert, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessageOli += err.getMessage();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppPartnerInsert, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}}
        logEntryMessage+='\n Inserted opportunity Partners';}
        
        //Added by Chaithaly to update DDR L5 mapping attributes
        l5ProdList = [select Id,PCC_Design_Registration__c, PCC_Design_Registration_Product__c, PCC_Opportunity__c from PCC_DDR_L5_Product_Mapping__c where PCC_Design_Registration__c IN: DDRids WITH USER_MODE];
        list<PCC_DDR_L5_Product_Mapping__c> l5ProdListToUpdate = new list<PCC_DDR_L5_Product_Mapping__c>();
        for (PCC_DDR_L5_Product_Mapping__c l5ProdListRec :l5ProdList) {
            l5ProdListRec.PCC_Opportunity__c = mapDRIDTOOpp.containsKey(l5ProdListRec.PCC_Design_Registration__c) ?  ((mapDRIDTOOpp.get(l5ProdListRec.PCC_Design_Registration__c)!= null) ? mapDRIDTOOpp.get(l5ProdListRec.PCC_Design_Registration__c).id : null ) :null;l5ProdListToUpdate.add(l5ProdListRec);
        }
        if(l5ProdListToUpdate.size()>0) {
            Database.SaveResult[] l5ProdListToUpdateResult = Database.update(l5ProdListToUpdate, false);
            for (Database.SaveResult sr : l5ProdListToUpdateResult){
                if(sr.isSuccess()){
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DDRL5Mapping, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessageOli += err.getMessage();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DDRL5Mapping, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}}
        logEntryMessage+='\n Updated L5 attributes mapping';}
        if(Test.isRunningTest()) {
        throw new System.DMLException();   }
        return errorMessageOli;
    }
    catch(Exception e)// Utkarsh - inserting log records from catch block can be avoided since we are already doing it from database opeartion at line no 975
    {
        if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c || Test.isRunningTest())
        {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineInsertExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
    listLogEntries.add(ExcepLog);}
    return e.getMessage();}
}

 public static void postApprovalFromResubmittedDR(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList,
Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap){
    
    Set<Id> setDRIds = new Set<Id>();
    // List<Core_Design_Registration_Product__c> lstDDRLI = new List<Core_Design_Registration_Product__c>();
    // GET DESIGN Records types
    // Added by DINESH : 31/5/2024
    // Set<Id> recordTypeIds = new Set<Id>();
    // for(RecordType rectype : [select id from recordtype where name like '%design%']){
        //     recordTypeIds.add(rectype.Id);
    // }
    try
    {
          list<Opportunity> lstOpportunities = new list<Opportunity>();
          Boolean isOppUpdated = false;
           list<id> drIds = new list<id>();
            //Manage newly added and approved line items after approval
            for(Core_Design_Registration__c iDR: newList)
            {
                // record type check at the start : DINESH 31/5/2024
                if(iDR.PCC_Registration_Type__c.contains('Design') && oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_RESUBMITTED && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                {
                   
                    setDRIds.add(iDR.Id);
                    //check if any picklist value is in mismatch with the design reg on opp and if yes update the opportunity
                    Opportunity oppFieldsUpdated = new Opportunity(id=iDR.Core_Opportunity_Id__c);
                    if(iDR.Core_Vertical_Market_Nm__c!=iDR.Core_Opportunity_Id__r.Core_Consumption_Market__c){
                        oppFieldsUpdated.Core_Consumption_Market__c = iDR.Core_Vertical_Market_Nm__c ;
                        isOppUpdated=true;
                    }
                    if(iDR.Core_Intel_Platform_Nm__c!=iDR.Core_Opportunity_Id__r.Core_Intel_Platform__c){
                        oppFieldsUpdated.Core_Intel_Platform__c = iDR.Core_Intel_Platform_Nm__c ;
                        isOppUpdated=true;
                    } 
                    if(iDR.Core_Product_Segment_Nm__c!=iDR.Core_Opportunity_Id__r.Core_Product_Segment__c){
                        oppFieldsUpdated.Core_Product_Segment__c = iDR.Core_Product_Segment_Nm__c ;   
                        isOppUpdated=true;
                    }
                    if(iDR.Core_Product_Application_Nm__c!=iDR.Core_Opportunity_Id__r.Core_Product_Application__c){
                        oppFieldsUpdated.Core_Product_Application__c = iDR.Core_Product_Application_Nm__c ;   
                        isOppUpdated=true;
                    }
                    if(isOppUpdated){
                        lstOpportunities.add(oppFieldsUpdated);                      
                    }                                    
               // Id designId = iDR.Core_Design_Registration_Id__c;
                
                }                
            }
           
         if(lstOpportunities.size()>0){
            //update lstOpportunities;
            Database.SaveResult[] lstOppUpdateResults = Database.update(lstOpportunities,false,AccessLevel.User_mode);
              Integer i = 0;
            String successMessage='';
            String errorMessage ='';
            for (Database.SaveResult sr : lstOppUpdateResults){
                if(sr.isSuccess()){
                    successMessage+= '\n Updated Oppty Id: '+sr.getId();
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Succesfully Updated', Core_Origin__c = 'Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR', Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = 'Core_DDR_Design_Handler_Utility.postApprovalFromResubmittedDR', Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        
                    }
                    i++;
            }}
            logEntryMessage+='\n updatedExistingOppsForUpdatedFieldsOnDR - Success message : '+successMessage+' Error Message : '+errorMessage;
        }        
        if(setDRIds.size() > 0)
        {
            //Call future method to create OLI
            insertApprovedLIsToExistingOpps(setDRIds);
        }
        if(Test.isRunningTest()) {
            
            throw new System.DMLException();
        }
    }
    catch(Exception e)
    {
        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
        
    }
}
    
@future
public static void insertApprovedLIsToExistingOpps(Set<Id> setDRIds)
{
    logEntryMessage+='\n insertApprovedLIsToExistingOpps entered';
    List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
    List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> lstApprovedDRLineItemsToUpdate = new List<Core_Design_Registration_Product__c>();
    list<PCC_DDR_L5_Product_Mapping__c> lstToUpdateDRPMappings = new list<PCC_DDR_L5_Product_Mapping__c>();
    
    Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    
    Map<Id, Id> designToOpportunityMap = new Map<Id, Id>();
    list<id> designIDS=new list<id>();
    try{
        
        lstApprovedDRLineItems = [SELECT id, Name, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c,Core_Locked_Ind__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c,(select id,PCC_Opportunity__c from DDR_Product_Mappings__r) FROM Core_Design_Registration_Product__c WHERE (Core_Locked_Ind__c  = FALSE OR Core_Design_Product_Status_Nm__c = 'Cancelled') AND Core_Design_Registration_Id__c IN: setDRIds with USER_MODE];
        //add list of OLIs for OLI creation
        list<Core_Design_Registration__c> drIdforApproved = new list<Core_Design_Registration__c>();
        for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems){
            Core_Design_Registration_Product__c productToUpdate = new Core_Design_Registration_Product__c(id = iDRLI.id);
            productToUpdate.Core_Locked_Ind__c = TRUE;//added by suresh
            productToUpdate.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
            
            if(iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED) {
                OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;
                createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                lstOpportunityLIs.add(createOppLineItem);
                if(!designIDS.contains(iDRLI.Core_Design_Registration_Id__c)){
                designIDS.add(iDRLI.Core_Design_Registration_Id__c);
                designToOpportunityMap.put(iDRLI.Core_Design_Registration_Id__c, iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                }
            }
            if(iDRLI.Core_Design_Product_Status_Nm__c != 'Cancelled') {
                lstApprovedDRLineItemsToUpdate.add(productToUpdate);}
            
            //added this for loop as part of story - TWC727-2595 . DRPmappings if any present on DR ,must be updated with the opportunity ID,after DR Approval.
            for(PCC_DDR_L5_Product_Mapping__c drpmap : iDRLI.DDR_Product_Mappings__r){
                //PCC_DDR_L5_Product_Mapping__c drpm= new PCC_DDR_L5_Product_Mapping__c(id=drpmap.id);
                if(drpmap.PCC_Opportunity__c==null){
                    drpmap.PCC_Opportunity__c = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c;
                    system.debug('iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c--'+iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                    lstToUpdateDRPMappings.add(drpmap);
                }               
            }
        }
         Database.update(lstApprovedDRLineItemsToUpdate,false,AccessLevel.User_mode);
        //TWC727-2698 changes for allowing file submission in resubmitted status and also move the file to opportunity if OLI's approved.
        if(!designToOpportunityMap.isEmpty()){
            filesUpdationOnOpp_ResubmittedDR(designToOpportunityMap,designIDS);
        }
        
       // update lstApprovedDRLineItems; //added by suresh
        logEntryMessage+='\n Updated DR Line Items';
        
        if(!lstOpportunityLIs.isEmpty()){
            Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstOpportunityLIs, false);
            Integer i = 0;
            String successMessage='';
            String errorMessage ='';
            for (Database.SaveResult sr : lstOppLineItemsInsertResults){
                if(sr.isSuccess()){
                    successMessage+= '\n Inserted Oppty LineItem Id: '+sr.getId();
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_Project__c = Project, Core_sObjectId__c = lstOpportunityLIs[i].Failed_DDR_RecordID__c));
                        
                    }
                    i++;
            }}
            logEntryMessage+='\n insertApprovedLIsToExistingOpps - Success message : '+successMessage+' Error Message : '+errorMessage;
        }
        List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
        //update OLI id in DR LI
        for(OpportunityLineItem iOLI : lstOpportunityLIs){
            Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id, Core_Locked_Ind__c = TRUE);
            iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
            lstDRLIWithOLIId.add(iDRLI);
        }
        
        if(!lstDRLIWithOLIId.isEmpty()){
            Database.SaveResult[] lstDesignProductUpdate = Database.update(lstDRLIWithOLIId, false);
            for (Database.SaveResult sr : lstDesignProductUpdate){
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }}
                else if(sr.isSuccess()){
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}
            logEntryMessage+='Updated DRP with OLI';
        }
         System.debug('lstToUpdateDRPMappings---'+lstToUpdateDRPMappings);
        if(!lstToUpdateDRPMappings.isEmpty()){
           Database.SaveResult[] lstDRPMappingUpdate = Database.update(lstToUpdateDRPMappings,false,AccessLevel.system_mode); 
            system.debug('lstDRPMappingUpdate----'+lstDRPMappingUpdate);
            for (Database.SaveResult sr : lstDRPMappingUpdate){
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                }}
                else if(sr.isSuccess()){
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
            }}
            logEntryMessage+='Updated DRPMapping with OppId';
        }
        if(Test.isRunningTest()) {
            throw new System.DMLException();
    }   }catch(Exception e){
        if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c){
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            //insert ExcepLog;// Utkarsh - this can be avoided from catch block
            Database.insert(ExcepLog,false,AccessLevel.User_mode);
    }}
}
    
//TWC727-2698 changes for allowing file submission in resubmitted status and also move the file to opportunity if OLI's approved.   
    public static void filesUpdationOnOpp_ResubmittedDR(Map<Id,Id> designToOpportunityMap,list<id> designIDS){
            Set<Id> designRegistrationIds = designToOpportunityMap.keySet();
            Set<Id> opportunityIds = new Set<Id>(designToOpportunityMap.values());
            
            List<ContentDocumentLink> lstFiles = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :designRegistrationIds OR LinkedEntityId IN :opportunityIds];
            
            Map<Id, List<ContentDocumentLink>> designToFilesMap = new Map<Id, List<ContentDocumentLink>>();
            Map<Id, Set<Id>> opportunityToLinkedDocsMap = new Map<Id, Set<Id>>();
            
            for (ContentDocumentLink cdll : lstFiles) {
                if (designToFilesMap.containsKey(cdll.LinkedEntityId)) {
                    designToFilesMap.get(cdll.LinkedEntityId).add(cdll);
                } else {
                    designToFilesMap.put(cdll.LinkedEntityId, new List<ContentDocumentLink>{cdll});
                }
            
                if (opportunityIds.contains(cdll.LinkedEntityId)) {
                    if (!opportunityToLinkedDocsMap.containsKey(cdll.LinkedEntityId)) {
                        opportunityToLinkedDocsMap.put(cdll.LinkedEntityId, new Set<Id>());
                    }
                    opportunityToLinkedDocsMap.get(cdll.LinkedEntityId).add(cdll.ContentDocumentId);
                }
            }
            
            List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
            
            for(id designId : designIDS) {
                Id opportunityId = designToOpportunityMap.get(designId);
            
                List<ContentDocumentLink> filesOnDesign = designToFilesMap.get(designId);
            
                if (filesOnDesign != null) {
                    for (ContentDocumentLink cdll : filesOnDesign) {
                        if (cdll.LinkedEntityId == designId && (opportunityToLinkedDocsMap.get(opportunityId) == null || !opportunityToLinkedDocsMap.get(opportunityId).contains(cdll.ContentDocumentId))) {
                            ContentDocumentLink newLink = new ContentDocumentLink();
                            newLink.ContentDocumentId = cdll.ContentDocumentId;
                            newLink.LinkedEntityId = opportunityId; 
                            newLink.ShareType = 'V';
                            newLink.Visibility='AllUsers';
                            newLinks.add(newLink);
                            }
                    }
                }
            }
            if(!newLinks.isEmpty()){
            Database.SaveResult[] lstLinksInsertResults = Database.insert(newLinks, false,AccessLevel.system_mode);
            Integer i = 0;
            String successMessage='';
            String errorMessage ='';
            for (Database.SaveResult sr : lstLinksInsertResults){
                if(sr.isSuccess()){
                    successMessage+= '\n Inserted Document on Oppty Id: '+sr.getId();
                    listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = 'DocumentUpdateonOppty', Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    i++;
                }else{
                    for(Database.Error err : sr.getErrors()){
                        errorMessage +='\n Statuscode :'+err.getStatusCode()+' Message :'+err.getMessage()+ ' Fields :' +err.getFields();
                        listLogEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = 'DocumentUpdateonOppty', Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c =sr.getId()));                        
                    }
                    i++;
            }}
            logEntryMessage+='\n insertApprovedDRsDocumentsOnOppty- Success message : '+successMessage+' Error Message : '+errorMessage;
        }
        
    }
/***************Retry Logic for Line items Start******************/

@InvocableMethod(label='DDR Retry' description='Reprocess the failed records' category='LogEntry')
public static void RetryFailedRecords(List<ID> ids) {
    List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
    List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
    Set<ID> FailedDdr= new Set<ID>();
    Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    /////////////////for OPP/////////////////
    Map<Id,Core_Design_Registration__c> lstApprovedDDR = new Map<Id,Core_Design_Registration__c>();
    List<Core_Design_Registration__c> listApprovedDDReg = new List<Core_Design_Registration__c>();
    
    List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
    List<Opportunity> lstInsertOpportunities = new List<Opportunity>();
    List<Core_Design_Registration__c> lstRejectedDesigns = new List<Core_Design_Registration__c>();
    List<Core_Design_Registration__c> lstDesignsForGroupName = new List<Core_Design_Registration__c>();
    List<Core_Design_Registration__c> lstUpdateOppInDDR = new List<Core_Design_Registration__c>();
    List<Id> DDRids = new list<Id>();
    // Id userId = Userinfo.getUserId();
    Set < String > drNameSet = new Set < String > ();
    Set < String > oppNameSet = new Set < String > ();
    Pricebook2 priceBook;
    Set<Id> setOfDDRIds = new Set<Id>();
    
    //Check for export compliance
    List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
    List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
    ////////////////////////////////////////
    
    List<Core_Log_Entry__c> logEList=[Select Id, Name, Core_Retry_Counter__c, Core_Origin__c, Core_Message__c, Core_sObjectId__c, Core_Next_Scheduled_Run__c from Core_Log_Entry__c where id IN :ids AND Core_sObjectId__c != null AND Core_Message__c != 'Successfully Inserted' with USER_MODE];
    for(Core_Log_Entry__c logE : logEList)
    {
        FailedDdr.add(logE.Core_sObjectId__c);
        logErrorId = logE.Id;
    }
    //  If(RetryOrigin == 'Opportunity Creation') {
        listApprovedDDReg = [SELECT id, Name,PCC_Registration_Type__c, Core_Product_Group_Nm__c,Core_Intel_Support_Status__c, Core_Design_Registration_Nm__c, Core_Vertical_Market_Nm__c, Core_Military_Aerospace_Gvrnmt_Use_Ind__c, Core_Product_Application_Nm__c,Core_Product_Segment_Nm__c, Core_Opportunity_Id__c, Core_End_Customer_Account_Id__c, OwnerId, Core_Partner_Account_Id__c, Core_Approver_Grp_Nm__c, Core_Design_Registration_Status_Nm__c, Core_Manufacturing_Region_Cd__c, Core_Production_End_Dt__c, Core_First_Customer_Ship_Dt__c, Core_Intel_Platform_Nm__c, Core_FPGA_Quote_Comments_Txt__c, Core_Design_Registration_Dsc__c, Core_Intel_Technical_Owner_Id__c, Core_Opportunity_Volume_Cnt__c, Core_Opportunity_Decision_Dt__c from Core_Design_Registration__c where Id =:FailedDdr AND Core_Opportunity_Id__c=null with USER_MODE];
        
        If(listApprovedDDReg.size()>0)
        {
            /***************Retry Logic for Oppo Start******************/
            
            for(Core_Design_Registration__c oppDDR : listApprovedDDReg)
            {
                lstApprovedDDR.put(oppDDR.Id, oppDDR);
                if(oppDDR.PCC_Registration_Type__c == 'Design Registration') {
                    designRegistration = true;
                }
                
            }
            
            If(listApprovedDDReg.size()>0 && designRegistration)
            {
                
                //////////////////////////////start
                try
                {
                    
                    for(Core_Design_Registration__c iDR : listApprovedDDReg){
                        if(iDR.Core_End_Customer_Account_Id__c != null){
                            lstDesignRegForExportCompl.add(iDR);
                        }
                        
                        if(iDR.OwnerId != null && iDR.Core_Partner_Account_Id__c == null){
                            lstDesignRegForSharing.add(iDR);
                            setOfDDRIds.add(iDR.Id);
                        }
                        
                        drNameSet.add(iDR.Name);
                        
                        if(iDR.Core_Partner_Account_Id__c != NULL && iDR.Core_Approver_Grp_Nm__c == NULL)
                        {
                            lstDesignsForGroupName.add(iDR);
                        }
                        
                        //if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && !(oldMap.get(iDR.Id).Core_Opportunity_Id__c != newMap.get(iDR.Id).Core_Opportunity_Id__c) && !(oldMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c != newMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c))
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && iDR.Core_Opportunity_Id__c == null &&
                            !oppNameSet.Contains(iDR.Name) && iDR.PCC_Registration_Type__c != 'Deal Registration')//Added by Suresh Palvadi
                        {
                            lstApprovedDRs.add(iDR);
                        }
                        
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                        {
                            
                            DDRids.add(iDR.id);
                        }
                        
                        //Lock the rejected line items after header is locked
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED)
                        {
                            lstRejectedDesigns.add(iDR);
                        }
                    }
                    
                    for (Opportunity opp: [SELECT Id,Name From Opportunity WHERE Name in: drNameSet WITH USER_MODE]) {oppNameSet.add(opp.Name);
                    }
                    //To populate the partner account and share the design based on owner field
                    if(lstDesignRegForSharing.size() > 0)
                    {
                        iterated = false;
                        populatePartnerAccount(lstDesignRegForSharing, false); // UPDATED by DINESH - Added false
                        designRegShare(lstDesignRegForSharing);
                        //update sharing of transactional object as well
                        PCC_DDRL5ProductMapping_TriggerHandler.DDRL5MappingsSharing(setOfDDRIds);
                    }
                    if(lstDesignRegForExportCompl.size() > 0)
                    {
                        checkForExportCompliance(lstDesignRegForExportCompl);
                    }
                    
                    if(lstDesignsForGroupName.size() > 0)
                    {
                        iterated = false;
                        updateGroupName(lstDesignsForGroupName);
                    }
                    
                    if(lstRejectedDesigns.size() > 0)
                    {
                        iterated = false;
                        lockRejectedProducts(lstRejectedDesigns);
                    }
                    
                    if(lstApprovedDRs.size() > 0)
                    {
                        //lock the approved DRs
                        //Approval.lock(lstApprovedDRs, true);
                        priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME with USER_MODE];
                        
                        //prepare list of Opp to create new Opps
                        lstInsertOpportunities = createOpportunity(lstApprovedDRs, priceBook);
                        
                        List<id> insertOppIds = new List<id>();
                        if(lstInsertOpportunities.size() > 0)
                        {
                            Database.SaveResult[] lstOppLineItemsInsertResults;
                            
                            
                            lstOppLineItemsInsertResults = Database.insert(lstInsertOpportunities, false);
                            if(lstOppLineItemsInsertResults.size()>0) {
                                
                                for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                                {
                                    if (!sr.isSuccess())
                                    {
                                        for(Core_Log_Entry__c logE : logEList)
                                        {
                                            Core_Log_Entry__c log = new Core_Log_Entry__c();
                                            log.Id = logE.Id;
                                            log.Core_Retry_Counter__c = logE.Core_Retry_Counter__c +1;
                                            if(log.Core_Retry_Counter__c<4) {
                                                log.Core_Message__c = logE.Core_Message__c + ' - Retry Started';
                                            }Else{
                                                log.Core_Message__c = logE.Core_Message__c + ' - Retry Ended';
                                            }
                                            log.Core_Next_Scheduled_Run__c = System.now()+(5/1440);
                                            logEntries.add(log);
                                            
                                        }
                                        
                                    }
                                    else if(sr.isSuccess())
                                    {
                                        
                                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess +' - After Retry', Core_Origin__c = 'Opportunity Creation12', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                                        OpportunityShare(lstInsertOpportunities);
                                        
                                        for(Opportunity opp: lstInsertOpportunities)
                                        {
                                            //add Opp Ids to create OLIs
                                            insertOppIds.add(opp.id);
                                            //add Opp Id to DR to update the opportunity lookup in DR
                                            Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                                            
                                            tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                                            
                                            lstUpdateOppInDDR.add(tempDR);
                                            
                                        }
                                    }
                                }
                                // Moved DMLs outside for loop
                                if(lstUpdateOppInDDR.size() > 0)
                                {
                                    update lstUpdateOppInDDR;
                                }
                                
                                
                                if(insertOppIds.size() > 0)
                                {
                                    iterated = false;
                                    insertOppLineItems(insertOppIds, DDRids);
                                }
                            }
                        }
                        
                        //Call OLI creation future method
                        
                        if(!logEntries.isEmpty() && !logSwitch.isEmpty() && (logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c))
                        {
                            Database.upsert(logEntries,false,AccessLevel.User_mode);
                            
                            //upsert logEntries;
                        }
                    }
                    //////////////////////////////////////Stop
                    if(Test.isRunningTest()) {
                        throw new System.DMLException();
                    }
                }
                catch(Exception e)// Utkarsh - creating log entry records can be avoided
                {
                    // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                    if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                    {
                        String ddrId = '';
                        if(lstInsertOpportunities.size() > 0) {ddrId = lstInsertOpportunities[0].Core_Design_Registration_Id__c;
                        }
                        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);
                        Database.upsert(ExcepLog,false,AccessLevel.User_mode);
                        
                    }
                }
            }
        }
        
        
        lstApprovedDRLineItems = [SELECT id, Name, Core_Opportunity_Product_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c,Core_Locked_Ind__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c from Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:FailedDdr AND Core_Opportunity_Product_Id__c=null with USER_MODE ]; //AND Core_Design_Registration_Id__r.Core_Opportunity_Id__c != null
        if(lstApprovedDRLineItems.size()>0 && designRegistration) {
            try{
                
                for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
                {
                    
                    if(iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED && iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c != null) {
                        OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                        
                        createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                        createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                        createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                        createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;
                        createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                        
                        lstOpportunityLIs.add(createOppLineItem);
                    }
                }
                //update lstApprovedDRLineItems;
                
                if(!lstOpportunityLIs.isEmpty())
                {
                    Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstOpportunityLIs, false);
                    
                    for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                    {
                        if (!sr.isSuccess())
                        {
                            for(Core_Log_Entry__c logE : logEList)
                            {
                                Core_Log_Entry__c log = new Core_Log_Entry__c();
                                log.Id = logE.Id;
                                log.Core_Retry_Counter__c = logE.Core_Retry_Counter__c +1;
                                if(log.Core_Retry_Counter__c<4) {
                                    log.Core_Message__c = logE.Core_Message__c + ' - Retry Started';
                                }Else{
                                    log.Core_Message__c = logE.Core_Message__c + ' - Retry Ended';
                                }
                                log.Core_Next_Scheduled_Run__c = System.now()+(5/1440);
                                logEntries.add(log);
                            }
                            
                        }
                        else if(sr.isSuccess())
                        {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess +' - After Retry', Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                            
                        }
                    }
                }
                
                List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
                for(OpportunityLineItem iOLI : lstOpportunityLIs)
                {
                    Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id, Core_Locked_Ind__c = TRUE);
                    iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                    lstDRLIWithOLIId.add(iDRLI);
                }
                
                //  List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();
                if(!lstDRLIWithOLIId.isEmpty())
                {
                    Database.SaveResult[] lstDesignProductUpdate = Database.update(lstDRLIWithOLIId, false);
                    for (Database.SaveResult sr : lstDesignProductUpdate)
                    {
                        if (!sr.isSuccess())
                        {
                            for(Database.Error err : sr.getErrors())
                            {
                                logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                            }
                        }
                        else if(sr.isSuccess())
                        {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                }
                if(!logEntries.isEmpty() && !logSwitch.isEmpty() && (logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c))
                {
                    // upsert logEntries;
                    Database.upsert(logEntries,false,AccessLevel.User_mode);
                }
                if(Test.isRunningTest()) {
                    
                    throw new System.DMLException();
                }
            }
            catch(Exception e)// Utkarsh - creating log entry records can be avoided
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c || Test.isRunningTest())
                {
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
                    // upsert ExcepLog;
                    Database.upsert(ExcepLog,false,AccessLevel.User_mode);
                }
            }
        }
    }
    /***************Retry Logic for Line Items End******************/
    
    public static void processBeforeUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap) {
        try{
            List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
            Set< String > DDRNames = new Set< String >();
            // Set < String > OppDetails = new Set < String >();
            if(BeforeUpdateIterated) {
                BeforeUpdateIterated = false;
                populateDDRFieldValues(newList, 'Update');
                populateEndCustomerAccount(oldMap,newList);
                for(Core_Design_Registration__c iDR : newList) {
                    
                    if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c != DR_STATUS_APPROVED && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && newMap.get(iDR.Id).Core_Opportunity_Id__c == null) {DDRNames.add(iDR.Core_Design_Registration_Nm__c);
                    }
                    if(oldMap.get(iDR.Id).OwnerId != newMap.get(iDR.Id).OwnerId) {lstDesignRegForSharing.add(iDR);
                    }
                }
                if(lstDesignRegForSharing.size() > 0) {populatePartnerAccount(lstDesignRegForSharing, true); // UPDATED by DINESH - Added TRUE
                }
                if(Test.isRunningTest()) {
                throw new System.DMLException();}
            }
            validateDRTextFieldsForLatinChars(newList,oldMap,false);
        }
        catch(Exception e)
        {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
    }
    
    /*****************************************************************************************************************
     * Method Name: populateDDRFieldValues
     * Date: 19/07/2023
     * Developer: Sushmita
     * Description: This method is used to stamp the DDR field values based on the  onwer's account
     ******************************************************************************************************************/
    public static void populateDDRFieldValues(List<Core_Design_Registration__c> ddrNewList, String action) {
        //Collecting unique Owner Ids from DDR records
        Set<Id> ddrOwnerIds = new Set<Id>();
        Set<Id> odrMatrixAcctIdSet = new Set<Id>();
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        Id userId=UserInfo.getUserId();
        boolean designRegistration = false;
        // Commented by DINESH
        //ApexGuru
        // Id currentUserId = UserInfo.getUserId();
        // User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
        String userProfileName = '';
        Map<Id, Id> userToAccountIdMap = new Map<Id, Id>();
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
            AND (PermissionSet.Name = 'DDR_Pre_Approver_permission_set' OR PermissionSet.Name='DDR_PreApprover_Permission'OR PermissionSet.Name='DDR_Pre_Approver_permission_set_Read_Only'OR PermissionSet.Name='DDR_Internal_Users'OR PermissionSet.Name='DDR_Internal_Users_Read_Only')
            
        ];
        Boolean hasDDRPreApproverPermission =!permissionSetAssignments.isEmpty();
        
        try{
            if(ddrNewList.size() > 0) {
                for (Core_Design_Registration__c ddr : ddrNewList) {
                    if (ddr.OwnerId != null) {
                        ddrOwnerIds.add(ddr.OwnerId);
                    }
                    if(ddr.PCC_Registration_Type__c == 'Design Registration') {
                        designRegistration = true;
                    }
                }
            }
            if(designRegistration) {
                // Retrieving the User records with associated Contact info
                if(ddrOwnerIds.size() > 0) {
                    list<User> userList =[SELECT Id,Contact.Name,Contact.AccountId,Profile.Name FROM User WHERE IsActive = true AND (Id IN :ddrOwnerIds or Id = :userId) ];
                    for (User u : userList) {
                        if(u.id == userId) userProfileName=u.Profile.Name; // added by DINESH
                        userIdToContactMap.put(u.Id, u.Contact);
                        userToAccountIdMap.put(u.Id, u.Contact.AccountId); //ApexGuru
                    }
                }
                //Retrieving Account records from ODR Onboarding Matrix object
                list<PCC_ODR_Onboarding_Matrix__c> odrList = [SELECT PCC_Account__c FROM PCC_ODR_Onboarding_Matrix__c where Pcc_Account__c in :userToAccountIdMap.Values()]; //ApexGuru
                for (PCC_ODR_Onboarding_Matrix__c odrMatrix : odrList) {
                    odrMatrixAcctIdSet.add(odrMatrix.PCC_Account__c);
                }
                
                //Updating the ddr fields on DDR records
                if(ddrOwnerIds.size() > 0) {
                    for (Core_Design_Registration__c ddr : ddrNewList) {
                        if (ddr.OwnerId != null) {
                            //ODR Contacts
                            
                            Contact userContactRec = userIdToContactMap.containsKey(ddr.OwnerId) ? userIdToContactMap.get(ddr.OwnerId) : null;
                            if (userContactRec != null && userContactRec.AccountId != null && odrMatrixAcctIdSet.contains(userContactRec.AccountId)) {
                                ddr.Core_DDR_Partner_Type_Txt__c = 'ODM';
                                if( ddr.Core_Product_Group_Nm__c == null) {ddr.Core_Product_Group_Nm__c = LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c;
                                }else if(action == 'Update' && ddr.Core_Product_Group_Nm__c != LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c && !hasDDRPreApproverPermission) {
                                    ddr.Core_Product_Group_Nm__c.addError(LabelConfiguration__mdt.getInstance('PCC_ODRProductGroupError').Value__c);
                                }
                            }else{ //non ODR contacts
                                ddr.Core_DDR_Partner_Type_Txt__c = 'Distributor';
                                
                                // FPGA LOGIC COMMENTED OUT: Product group validation - non-ODR contacts can only select FPGA/Power or Embedded/IOT
                                /*
                                if(((action == 'Update' && ddr.Core_Product_Group_Nm__c != null) || (action == 'Insert' && ddr.Core_Product_Group_Nm__c == LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c))
                                    && ddr.Core_Product_Group_Nm__c!=LabelConfiguration__mdt.getInstance('DDR_Product_Group_FPGA').Value__c && ddr.Core_Product_Group_Nm__c!=LabelConfiguration__mdt.getInstance('PCC_Product_Group_Embedded').Value__c && userProfileName!='Data Ops' && !hasDDRPreApproverPermission)
                                {
                                    ddr.Core_Product_Group_Nm__c.adderror(LabelConfiguration__mdt.getInstance('PCC_ProductGroupError').Value__c);
                                }
                                */
                                
                                // Modified validation without FPGA check
                                if(((action == 'Update' && ddr.Core_Product_Group_Nm__c != null) || (action == 'Insert' && ddr.Core_Product_Group_Nm__c == LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c))
                                    && ddr.Core_Product_Group_Nm__c!=LabelConfiguration__mdt.getInstance('PCC_Product_Group_Embedded').Value__c && userProfileName!='Data Ops' && !hasDDRPreApproverPermission)
                                {
                                    ddr.Core_Product_Group_Nm__c.adderror(LabelConfiguration__mdt.getInstance('PCC_ProductGroupError').Value__c);
                                }
                            }
                        }
                    }
                }
                if(Test.isRunningTest()) {
                throw new System.DMLException();}
            }
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex);
        }
    }
    
    // can be converted to metadata for mapping
    public static List<Opportunity> createOpportunity(List<Core_Design_Registration__c> lstApprovedDRs, Pricebook2 Pricebook) {
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();
        for(Core_Design_Registration__c iDR : lstApprovedDRs)
        {
            String systemDate = String.valueOf(System.now());
            String timeStamp = systemDate.replaceAll('[^0-9]', '');
            Opportunity createOpp = new Opportunity(Name = iDR.Core_Design_Registration_Nm__c+' ' + timeStamp, AccountID = iDR.Core_End_Customer_Account_Id__c, StageName = LabelConfiguration__mdt.getInstance('OpportunityDefaultStage').Value__c);
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
            createOpp.RecordTypeId = recordTypeId;
            createOpp.Core_Design_Registration_Id__c = iDR.id;
            
            // FPGA LOGIC COMMENTED OUT: Setting sales group based on product group - FPGA products get PSG sales group
            /*
            createOpp.Core_Sales_Group__c = (iDR.Core_Product_Group_Nm__c == LabelConfiguration__mdt.getInstance('DDR_Product_Group_FPGA').Value__c ? LabelConfiguration__mdt.getInstance('Opportunity_Sales_Group_PSG').Value__c : LabelConfiguration__mdt.getInstance('Opportunity_Sales_Group_Regional').Value__c);
            */
            
            // Modified to always use Regional sales group since FPGA is commented out
            createOpp.Core_Sales_Group__c = LabelConfiguration__mdt.getInstance('Opportunity_Sales_Group_Regional').Value__c;
            
            createOpp.Core_Military_Aerospace_Govmt_End_Use__c = iDR.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
            createOpp.Core_Commissionable__c = LabelConfiguration__mdt.getInstance('Opportunity_Commissionable_No').Value__c;
            
            // FPGA LOGIC COMMENTED OUT: Setting opportunity type - Embedded/IOT Boards & Systems get Secondary type, others (including FPGA) get Original type
            if(iDr.Core_Product_Group_Nm__c == LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c) {
                createOpp.Core_Opportunity_Type__c = LabelConfiguration__mdt.getInstance('Opportunity_Type_Secondary').Value__c;
            }else{
                // FPGA LOGIC COMMENTED OUT: FPGA products would get Original opportunity type
                createOpp.Core_Opportunity_Type__c = LabelConfiguration__mdt.getInstance('Opportunity_Type_Original').Value__c;
            }
            
            createOpp.Core_Product_Segment__c = iDR.Core_Product_Segment_Nm__c;
            createOpp.Core_Product_Application__c = iDR.Core_Product_Application_Nm__c;
            createOpp.Core_Consumption_Market__c = iDR.Core_Vertical_Market_Nm__c;
            createOpp.Core_Manufacturing_Geo__c = iDR.Core_Manufacturing_Region_Cd__c;
            createOpp.Core_Production_End_Date__c = iDR.Core_Production_End_Dt__c;
            createOpp.Core_First_Customer_Ship_Date__c = iDR.Core_First_Customer_Ship_Dt__c;
            createOpp.Core_Intel_Platform__c = iDR.Core_Intel_Platform_Nm__c;
            createOpp.Core_Status_Update__c = LabelConfiguration__mdt.getInstance('OpportunityConvertedMsg').Value__c+ idR.Name;
            createOpp.Core_Opportunity_Coverage_Nm__c =LabelConfiguration__mdt.getInstance('OpportunityConverageType').Value__c;
            createOpp.Core_Coverage_Type_Nm__c = iDr.Core_Intel_Support_Status__c;
            
            // FPGA LOGIC COMMENTED OUT: Including FPGA Quote Comments in opportunity description for FPGA products
            /*
            if (iDR.Core_FPGA_Quote_Comments_Txt__c == null){
                createOpp.Description = iDR.Core_Design_Registration_Dsc__c;
            }
            else{
                createOpp.Description = 'Description:\n---------------\n' + iDR.Core_Design_Registration_Dsc__c + '\n\nFPGA Quote Comments:\n--------------------------------\n' + iDR.Core_FPGA_Quote_Comments_Txt__c;
            }
            */
            
            // Modified to only use description without FPGA Quote Comments
            createOpp.Description = iDR.Core_Design_Registration_Dsc__c;
            
            createOpp.OwnerID = UserInfo.getUserId();
            createOpp.Core_Technical_Owner__c = Idr.OwnerId;
            createOpp.Core_Volume__c = iDR.Core_Opportunity_Volume_Cnt__c;
            createOpp.Pricebook2id = priceBook.id;
            createOpp.Core_Channel_Opportunity_Ind__c = true;
            createOpp.CloseDate = (iDR.Core_Opportunity_Decision_Dt__c < system.today() ? system.today() : iDR.Core_Opportunity_Decision_Dt__c);
            
            createOpp.Core_Compliance_Status__c = 'N/A';
            createOpp.Core_Compliance_Sub_Status__c = LabelConfiguration__mdt.getInstance('Opportunity_ComplianceSubStatus_Complete').Value__c;
            
            if(iDR.Core_Intel_Support_Status__c == LabelConfiguration__mdt.getInstance('DDR_Intel_Support_Device_Builder_Low').value__c ||
            iDR.Core_Intel_Support_Status__c == LabelConfiguration__mdt.getInstance('DDR_Disti_design_Registration_Low').value__c){
                createOpp.Core_Exclude_From_KPIs__c = true;
                //createOpp.Core_Exclude_from_Confidence__c = true;
                createOpp.Core_Commissionable__c = LabelConfiguration__mdt.getInstance('Opportunity_Commissionable_No').Value__c;
            }
            
            if(iDR.Core_Opportunity_Id__c == NULL)
            {
                lstInsertOpportunities.add(createOpp);
            }
        }
        return lstInsertOpportunities;
    }
    
    /*****************************************************************************************************************
     * Method Name: fetch Permission set from Deal Partner
     * Date: 25/01/2024
     * Developer: Sandhya
     * Description: This method is used to fetch Permission set from Deal Partner
     ******************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<userPermissionsWrapper> fetchUserPermissions() {
        
        List<String> permissionSetList = new List<String>();
        List<userPermissionsWrapper> wrapList = new List<userPermissionsWrapper>();
        String userId = UserInfo.getUserId();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        boolean hasPartnerAccepted;
        try{
            User userContactId =[Select id, name,ContactId From User Where Id =:userId];
            PRM_PartnerAgreement__c partnerAgreement = [Select id, name from PRM_PartnerAgreement__c where name = 'Deal_Registration_Terms_and_Conditions'];
            PRM_AccountLegalAgreemntAssociation__c[] dealLegalAgreement = [Select Id, Name, PRM_Contact__c From PRM_AccountLegalAgreemntAssociation__c where PRM_Contact__c=:userContactId.ContactId AND PRM_Partner_Agreement_Id__c =:partnerAgreement.Id];
            
            if(!String.isBlank(userId)) {
                List<PermissionSetAssignment> psList = [Select Id,Assignee.name,AssigneeId,PermissionSet.Name from 
                                                        PermissionSetAssignment Where AssigneeId =:userId];
                if(!psList.isEmpty()){
                    for(PermissionSetAssignment ps:psList) {
                        permissionSetList.add(String.valueOf(ps.PermissionSet.Name));
                    }
                    if(dealLegalAgreement.size() > 0){
                        hasPartnerAccepted = true;
                        
                    }
                    else{
                        hasPartnerAccepted = false;
                        
                    }
                    wrapList.add(new userPermissionsWrapper(profileName,permissionSetList,hasPartnerAccepted));
                    
                }
            }
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_ENTRY_MSG, '' ,'' ,'Core_Design_Registration__c' ,'' ,ex);
        }
        return wrapList;
    }
    public class userPermissionsWrapper {
        @AuraEnabled public String profile{get;set;}
        @AuraEnabled public List<String> permissionSets{get;set;}
        @AuraEnabled public boolean hasPartnerAccepted{get;set;}
        public userPermissionsWrapper(String profile, List<String> permissionSets, boolean hasPartnerAccepted) {
            this.profile = profile;
            this.permissionSets = permissionSets;
            this.hasPartnerAccepted = hasPartnerAccepted;
        }
    }
    
    //Sandhya
    @AuraEnabled(cacheable=true)
    public static  Core_Design_Registration__c getDealDesignRecDetails(Id recId) {
        Core_Design_Registration__c dealDesign;
        try{
            dealDesign = [SELECT id,name,PCC_Deal_Description__c,PCC_End_Customer_Use__c,Core_Design_Registration_Status_Nm__c,PCC_Registration_Type__c,PCC_Pricing_Start_Date__c, PCC_Pricing_End_Date__c,PCC_Proposal_Due_Date__c,Core_Accepted_By_Id__c,Core_Partner_Account_Id__r.Core_Covered_Account__c,
                          PCC_Competition_Assumptions__c,Core_End_Customer_Account_Id__c,PCC_Approval_Level__c,Core_Design_Registration_Nm__c,Core_Intel_Technical_Owner_Id__c,PCC_Deal_Project_Name__c,Core_Opportunity_Decision_Dt__c,OwnerId                                                       
                          FROM Core_Design_Registration__c where id=:recId];
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_ENTRY_MSG, '' ,'' ,'Core_Design_Registration__c' ,'' ,ex);
        }
        return dealDesign;
        
    }
    
    /*****************************************************************************************************************
     * Method Name: lockEditsDRP
     * Date: 25/03/2024
     * Developer: Sandhya
     * Description: This method is used to lock the Deal products after Deal is Submitted
     ******************************************************************************************************************/
    public static void lockEditsDRP(Map<Id,Core_Design_Registration__c> oldMap,List<Core_Design_Registration__c> newList)
    {
        try {
            String dealProdLockedRecTypeID = Schema.getGlobalDescribe().get('Core_Design_Registration_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();
            String dealProdPartRecTypeID = Schema.getGlobalDescribe().get('Core_Design_Registration_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
            Set<Id> dealRecIds = new Set<Id>();
            List<Core_Design_Registration_Product__c> updateDealProdList = new List<Core_Design_Registration_Product__c>();
            for(Core_Design_Registration__c dealRec :newList){
                
                if(oldMap.containsKey(dealRec.Id)
                && (oldMap.get(dealRec.Id).Core_Design_Registration_Status_Nm__c)!=dealRec.Core_Design_Registration_Status_Nm__c){
                    dealRecIds.add(dealRec.Id);
                    
                }
            }
            if(newList.size() > 0) {
                
                for(Core_Design_Registration_Product__c dealRegProduct :[SELECT id,
                                                                         Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,
                                                                         Core_Design_Registration_Id__r.PCC_Registration_Type__c,
                                                                         Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c where Core_Design_Registration_Id__c IN:dealRecIds]) {
                    
                    if(dealRegProduct.Core_Design_Registration_Id__r.PCC_Registration_Type__c=='Deal Registration'){
                        
                        if(dealRegProduct.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c!='Draft'
                        && dealRegProduct.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c!='Re-Submitted'){
                            
                            dealRegProduct.recordTypeId = dealProdLockedRecTypeID;
                        }else if(dealRegProduct.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c=='Draft'
                        && dealRegProduct.Core_Design_Product_Status_Nm__c=='Pending')
                        {
                            dealRegProduct.recordTypeId = dealProdPartRecTypeID;
                        }
                    }
                    updateDealProdList.add(dealRegProduct);
                }
            }
            if(!updateDealProdList.isEmpty()){
                update updateDealProdList;
            }
            
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_ENTRY_MSG, '' ,'' ,'Core_Design_Registration__c' ,'' ,e);
        }
    }
    /**
     * @description Method to check if Non-Latin characters are present in Text fields
     * @author Pranjal
     * @param Core_Design_Registration__c
     * @param Map<Id,Core_Design_Registration__c> oldMap
     * @param Boolean isInsert
     **/
    public static void validateDRTextFieldsForLatinChars(List<Core_Design_Registration__c> dealRegList,Map<Id,Core_Design_Registration__c> oldMap, Boolean isInsert){
        try{
            Set<String> dealRegTextFields1 = new Set < String > ((LabelConfiguration__mdt.getInstance('PCC_Deal_fields1_for_Non_Latin').Value__c).split(';'));
            Set<String> dealRegTextFields2 = new Set < String > ((LabelConfiguration__mdt.getInstance('PCC_Deal_fields2_for_Non_Latin').Value__c).split(';'));
            Set<String> dealRegTextFields = new Set<String>();
            dealRegTextFields.addAll(dealRegTextFields1);
            dealRegTextFields.addAll(dealRegTextFields2);
            String recordTypeDR1 = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
            String recordTypeDR2 = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Deal_Registration_Locked').getRecordTypeId();
            String recordTypeDR3 = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Partner').getRecordTypeId();
            List<String> recordTypeDealList = new List<String>{recordTypeDR1,recordTypeDR2,recordTypeDR3};
            
            
            if(dealRegTextFields.size()>0){
                for(Core_Design_Registration__c dealReg: dealRegList) {
                    if(recordTypeDealList.contains(dealReg.RecordTypeId)){
                        for(String field:dealRegTextFields){
                            String fieldValue = '';
                            if(isInsert){
                                if(dealReg.get(field) != null){
                                    fieldValue = (String)dealReg.get(field);
                                }
                            }else{
                                if((String)dealReg.get(field) != (String)oldMap.get(dealReg.Id).get(field)){
                                    fieldValue = (String)dealReg.get(field);
                                }
                            }
                            if(!String.isEmpty(fieldValue) && Pricing_Tender_Utility.validateNonLatinChars(fieldValue)) {
                                dealReg.addError(field,Label.Pricing_Non_Latin_Char_Validation_Error);
                            }
                        }
                    }
                }
            }
        }catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_VALIDATION_ERROR, '' ,'' ,'Core_Design_Registration__c' ,'' ,ex);
        }
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);
        return fieldSetObj.getFields();
    }
    /*****************************************************************************************************************
     * Method Name: fetchPartnerEndCustMapping
     * Date: 14/08/2024
     * Developer: Sandhya
     * Description: This method is used to fetch the Partner Accounts.
     ******************************************************************************************************************/
    public static void fetchPartnerEndCustMapping(Map<Id,Core_Design_Registration__c> oldMap,List<Core_Design_Registration__c> newList)
    {
        try {
            Map<Id,Set<Id>> newDealAccMap = new Map<Id,Set<Id>>();
            Map<Id,Set<Id>> newDesignAccMap = new Map<Id,Set<Id>>();
            List<PCC_EndCustomerAcc_Mapping__c> mappingsToInsert = new List<PCC_EndCustomerAcc_Mapping__c>();
            for (Core_Design_Registration__c dr : newList) {
                if(dr.Core_Design_Registration_Status_Nm__c=='Approved' &&
                dr.Core_Partner_Account_Id__c!=null && dr.Core_End_Customer_Account_Id__c!=null){
                    //&& oldMap.get(dr.Id).Core_Design_Registration_Status_Nm__c!=dr.Core_Design_Registration_Status_Nm__c){
                        if(dr.PCC_Registration_Type__c=='Deal Registration' && PCC_Constants.DEAL_REGISTRATIONTYPE.contains(dr.PCC_Registration_Type__c)){
                            newDealAccMap=addEndCustAccount(newDealAccMap,dr);
                        }else if(dr.PCC_Registration_Type__c=='Design Registration' && PCC_Constants.DEAL_REGISTRATIONTYPE.contains(dr.PCC_Registration_Type__c)){
                            newDesignAccMap = addEndCustAccount(newDesignAccMap,dr);
                        }
                }}
                Set<Id> partnerAccIds =new Set<Id>();
                partnerAccIds.addAll(newDealAccMap.keySet());
                partnerAccIds.addAll(newDesignAccMap.keySet());
                
                if (Schema.SObjectType.PCC_EndCustomerAcc_Mapping__c.isAccessible()) {
                    for (PCC_EndCustomerAcc_Mapping__c existingRec : [SELECT Id,PCC_Write_In_OEM_Nm__c, Name, PCC_End_Customer_Account_Id__c,PCC_Registration_Type_Nm__c,PCC_Partner_Account_Id__c
                    FROM PCC_EndCustomerAcc_Mapping__c where PCC_Partner_Account_Id__c IN :partnerAccIds WITH USER_MODE]) {
                        if(newDealAccMap.containsKey(existingRec.PCC_Partner_Account_Id__c) && existingRec.PCC_Registration_Type_Nm__c=='Deal Registration'){
                            newDealAccMap.get(existingRec.PCC_Partner_Account_Id__c).remove(existingRec.PCC_End_Customer_Account_Id__c);
                            
                        }
                        if(newDesignAccMap.containsKey(existingRec.PCC_Partner_Account_Id__c) && existingRec.PCC_Registration_Type_Nm__c=='Design Registration'){
                            newDesignAccMap.get(existingRec.PCC_Partner_Account_Id__c).remove(existingRec.PCC_End_Customer_Account_Id__c);
                        }
                    }
                }
                
                for (Core_Design_Registration__c dr : newList) {
                    if(newDealAccMap.containskey(dr.Core_Partner_Account_Id__c) && !newDealAccMap.get(dr.Core_Partner_Account_Id__c).isEmpty()
                        && newDealAccMap.get(dr.Core_Partner_Account_Id__c).contains(dr.Core_End_Customer_Account_Id__c)
                    && dr.PCC_Registration_Type__c=='Deal Registration'){
                        PCC_EndCustomerAcc_Mapping__c newEndCustMappingRec = createEndCustMappingRec(newDealAccMap,dr);
                        if(newEndCustMappingRec!=null){
                            mappingsToInsert.add(newEndCustMappingRec);
                            newDealAccMap.get(dr.Core_Partner_Account_Id__c).remove(dr.Core_End_Customer_Account_Id__c);
                        }
                    }
                    if(newDesignAccMap.containskey(dr.Core_Partner_Account_Id__c) && !newDesignAccMap.get(dr.Core_Partner_Account_Id__c).isEmpty()
                        && newDesignAccMap.get(dr.Core_Partner_Account_Id__c).contains(dr.Core_End_Customer_Account_Id__c)
                    && dr.PCC_Registration_Type__c=='Design Registration'){
                        PCC_EndCustomerAcc_Mapping__c newEndCustMappingRec = createEndCustMappingRec(newDesignAccMap,dr);
                        if(newEndCustMappingRec!=null){
                            mappingsToInsert.add(newEndCustMappingRec);
                            newDesignAccMap.get(dr.Core_Partner_Account_Id__c).remove(dr.Core_End_Customer_Account_Id__c);
                        }
                    }
                }
                if (!mappingsToInsert.isEmpty()) {
                    database.insert(mappingsToInsert,false);
                }
            }catch(Exception e){
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_ENTRY_MSG, '' ,'' ,'Core_Design_Registration__c' ,'' ,e);
            }
        }
        
        /**
         * @description Method to populate End CUstomer for Internal Users
         * @author Sandhya
         * @param Core_Design_Registration__c
         * @param Map<Id,Set<Id>> newDealAccMap
         **/
        public static PCC_EndCustomerAcc_Mapping__c createEndCustMappingRec(Map<Id,Set<Id>> newDealAccMap,Core_Design_Registration__c dealDesRec){
            PCC_EndCustomerAcc_Mapping__c endCustMappingRec = new PCC_EndCustomerAcc_Mapping__c();
            endCustMappingRec.Name=dealDesRec.Core_End_Customer_Account_Nm__c;
            endCustMappingRec.PCC_Partner_Account_Id__c=dealDesRec.Core_Partner_Account_Id__c;
            endCustMappingRec.PCC_Write_In_OEM_Nm__c = dealDesRec.Core_End_Customer_Nm__c;
            endCustMappingRec.PCC_End_Customer_Account_Id__c = dealDesRec.Core_End_Customer_Account_Id__c;
            //endCustMappingRec.PCC_End_Customer_City_Nm__c = dealDesRec.Core_End_Customer_City_Nm__c;
            //endCustMappingRec.PCC_End_Customer_State_Nm__c = dealDesRec.Core_End_Customer_Country_Subdivision_Nm__c;
            //endCustMappingRec.PCC_End_Customer_Country_Nm__c = dealDesRec.PCC_End_Customer_Country__c;
            endCustMappingRec.PCC_Registration_Type_Nm__c = dealDesRec.PCC_Registration_Type__c;
            return endCustMappingRec;
        }
        
        
        public static void populateEndCustomerAccount(Map<Id,Core_Design_Registration__c> oldMap,List<Core_Design_Registration__c> lstDesignDealReg) {
            Set<Id> endCustAccIds = new Set<Id>();
            try{
                for (Core_Design_Registration__c ddr : lstDesignDealReg) {
                    if(ddr.PCC_EndCustomerAcc_Mapping__c != null &&
                        (ddr.Core_Design_Registration_Status_Nm__c=='Submitted'
                        //|| ddr.Core_Design_Registration_Status_Nm__c=='Precheck Completed'
                    || ddr.Core_Design_Registration_Status_Nm__c=='Precheck Pending'
                        || ddr.Core_Design_Registration_Status_Nm__c=='Deal accepted')
                    && oldMap.get(ddr.Id).Core_Design_Registration_Status_Nm__c!=ddr.Core_Design_Registration_Status_Nm__c){
                        endCustAccIds.add(ddr.PCC_EndCustomerAcc_Mapping__c);
                        
                    }else if(oldMap.get(ddr.Id).PCC_EndCustomerAcc_Mapping__c!=ddr.PCC_EndCustomerAcc_Mapping__c
                    && ddr.Core_End_Customer_Nm__c != null){
                        ddr.Core_End_Customer_Account_Id__c=null;
                    }
                }
                if (Schema.SObjectType.PCC_EndCustomerAcc_Mapping__c.isAccessible() && !endCustAccIds.isEmpty()) { // added endCustAccIds.isEmpty() by DINESH
                    
                    Map<Id, PCC_EndCustomerAcc_Mapping__c> endCustAccMap = new Map<Id, PCC_EndCustomerAcc_Mapping__c>(
                        [select id,PCC_End_Customer_Account_Id__c 
                    from PCC_EndCustomerAcc_Mapping__c 
                    where id IN : endCustAccIds WITH USER_MODE]);
                    for (Core_Design_Registration__c ddrRec : lstDesignDealReg) {
                        if (ddrRec.PCC_EndCustomerAcc_Mapping__c != null && endCustAccMap.get(ddrRec.PCC_EndCustomerAcc_Mapping__c)!=null
                            && endCustAccMap.containsKey(ddrRec.PCC_EndCustomerAcc_Mapping__c)
                        && PCC_Constants.DEAL_REGISTRATIONTYPE.contains(ddrRec.PCC_Registration_Type__c)) {
                            ddrRec.Core_End_Customer_Account_Id__c = endCustAccMap.get(ddrRec.PCC_EndCustomerAcc_Mapping__c).PCC_End_Customer_Account_Id__c;
                        }
                    }
                }
            }catch(Exception e){
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_ENTRY_MSG, '' ,'' ,'Core_Design_Registration__c' ,'' ,e);
            }
        }
        
        public static Map<Id,Set<Id>> addEndCustAccount(Map<Id,Set<Id>> registrationMap,Core_Design_Registration__c dr) {
            Map<Id,Set<Id>> tmpMap = registrationMap;
            
            Set<Id> tmpSet = new Set<id>();
            if(tmpMap!=null){
                if(tmpMap.containsKey(dr.Core_Partner_Account_Id__c)){
                    tmpSet = registrationMap.get(dr.Core_Partner_Account_Id__c);
                }
                if(tmpMap.containsKey(dr.Core_Partner_Account_Id__c)){
                    tmpMap.get(dr.Core_Partner_Account_Id__c).add(dr.Core_End_Customer_Account_Id__c);
                    
                }else{
                    tmpSet.add(dr.Core_End_Customer_Account_Id__c);
                    tmpMap.put(dr.Core_Partner_Account_Id__c,tmpSet);
                    
                }
            }
            
            return tmpMap;
        }
    }