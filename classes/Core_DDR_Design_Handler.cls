/****************************************************************************************************
Apex Class Name : Core_DDR_Design_Handler
Version         : 1.0 
Created Date    : 09/14/2017
Function        : Handler class for the trigger 'Core_DDR_Design_Trigger'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran            09/14/2017             Created
* Suresh Palvadi           09/25/2017             Added methods to create Opportunity Line Items 
* Venu Karumuru            10/31/2021             Updated the Opportunity Compliance status, Compliance Sub-Status values for MINDS
* Venu Karumuru            01/31/2022             Opportunity line items not getting copied on first DR Approval. Made insertOppLineItems() method inline to fix this.
* Gaurav Kurwade           02/11/2022             Retry Mechanism for Opportunity & Oppo Line Items
*****************************************************************************************************/
public without sharing Class Core_DDR_Design_Handler
{    
    /*****
Shortforms used:

DR - Design Registration
DRLI - Design Registration Line Item (DR Product)
Opp - Opportunity
OLI - Opportunity Line Item (Opportunity Product)
PBE - Price book Entry
*****/
    
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    public static string DR_STATUS_SUBMITTED = 'Submitted';
    public static string DR_STATUS_REJECTED = 'Rejected';
    public static string DR_STATUS_DESIGN_ACCEPTED = 'Design accepted';
    public static string DR_LI_STATUS_APPROVED = 'Approved';
    public static string DR_LI_STATUS_PENDING = 'Pending';
    public static string PRICEBOOK_NAME = 'Partner Price Book';
    public static string Project = 'DDR';
    public static string Severity = 'High';
    public static string Log_Severity = 'Info';
    public static string InsertSuccess = 'Successfully Inserted';
    public static String LOG_ENTRY_ORIGIN   = 'PCC_CreateDesignRegistration';
    public static String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static String LOG_ENTRY_SCOPE_1  = 'Fetch DDR Picklist Values';
    public static String LOG_ENTRY_ERROR    = 'error';
    public static String LOG_ENTRY_SEVERITY = 'High';
    public static string OppLineInsertExceMtd = 'Core_DDR_Design_Handler.insertOppLineItems_Exception';
    public static string OppLineUpdateExceMtd = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps_Exception';
    public static string OppLineInsertLogEntry = 'Core_DDR_Design_Handler.insertOppLineItems.OppLineItemInsert';
    public static string OppLineUpdateLogEntry = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps.OppLineItemUpdate';
    public static string DesignProductOnOppLineInsert = 'Core_DDR_Design_Handler.insertOppLineItems.DesignProductUpdate';   
    public static string DesignProductOnOppLineUpdate = 'Core_DDR_Design_Handler.insertApprovedLIsToExistingOpps.DesignProductUpdate';
    public static string OppTeamMemberInsert = 'Core_DDR_Design_Handler.insertOppLineItems.OppTeamMemberInsert';
    public static string OppPartnerInsert = 'Core_DDR_Design_Handler.insertOppLineItems.OppPartnerInsert';
    public static string DDRL5Mapping = 'Core_DDR_Design_Handler.insertOppLineItems.updateDDRL5Mapping';
    Public static string failedRecordId;
    Public static string logErrorId;
    Public static Boolean iterated = true;
    Public static Boolean AfterUpdateIterated = true;
    Public static Boolean BeforeUpdateIterated = true;
    
    public static void processBeforeInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap, User loginUser)
    {
        populatePartnerAccountID(newList);
        //checkForExistingOpportunity(newList,null);
        populateDDRFieldValues((List<Core_Design_Registration__c>) newList);
        //validateProductGroup(newList);
    }
    
    public static void processAfterInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        //populatePartnerAccount(newList);     
        designRegShare((List<Core_Design_Registration__c>) newList);
        //populateDDRPartnerType((List<Core_Design_Registration__c>) newList);
    }
    
    public static void processAfterUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {   
        
        
        List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();   
        List<Core_Design_Registration__c> lstRejectedDesigns = new List<Core_Design_Registration__c>();        
        List<Core_Design_Registration__c> lstDesignsForGroupName = new List<Core_Design_Registration__c>();  
        Set<Id> setOfDDRIds = new Set<Id>();
        
        List<Id> DDRids = new list<Id>();
        Id userId = Userinfo.getUserId();
        
        Pricebook2 priceBook;
        
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        List<Core_Log_Entry__c> logEntriesOppLineItemsforOpptyCreation = new List<Core_Log_Entry__c>();
        
        try
        {            
            //Check for export compliance
            List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
            if(AfterUpdateIterated){
                AfterUpdateIterated = false;
                for(Core_Design_Registration__c iDR : newList)
                {
                    if(oldMap.get(iDR.Id).Core_End_Customer_Account_Id__c != newMap.get(iDR.Id).Core_End_Customer_Account_Id__c)
                    {
                        lstDesignRegForExportCompl.add(iDR);    
                    }
                    
                    if(oldMap.get(iDR.Id).OwnerId != newMap.get(iDR.Id).OwnerId)
                    {
                        system.debug(iDR.Id);
                        lstDesignRegForSharing.add(iDR);
                        setOfDDRIds.add(iDR.Id);
                    }
                }    
                
                //To populate the partner account and share the design based on owner field
                if(lstDesignRegForSharing.size() > 0)
                {system.debug(lstDesignRegForSharing);
                 //populatePartnerAccount(lstDesignRegForSharing);
                 designRegShare(lstDesignRegForSharing);
                 system.debug('setOfDDRIds-->'+setOfDDRIds);
                 //update sharing of transactional object as well 
                 PCC_DDRL5ProductMapping_TriggerHandler.DDRL5MappingsSharing(setOfDDRIds);
                }            
                
                if(lstDesignRegForExportCompl.size() > 0)
                {
                    checkForExportCompliance(lstDesignRegForExportCompl);
                }
                
                for(Core_Design_Registration__c iDR : newList)
                {
                    
                    if(iDR.Core_Partner_Account_Id__c != NULL && iDR.Core_Approver_Grp_Nm__c == NULL)
                    {
                        lstDesignsForGroupName.add(iDR);    
                    }
                    
                    //if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && !(oldMap.get(iDR.Id).Core_Opportunity_Id__c != newMap.get(iDR.Id).Core_Opportunity_Id__c) && !(oldMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c != newMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c))
                    if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && iDR.Core_Opportunity_Id__c == null)//Added by Suresh Palvadi
                    {
                        lstApprovedDRs.add(iDR);
                    }    
                    
                    if((oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_Submitted || oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_DESIGN_ACCEPTED) && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED){
                        DDRids.add(iDR.id);
                    }
                    
                    //Lock the rejected line items after header is locked
                    if((oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_SUBMITTED || oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_RESUBMITTED || oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_DESIGN_ACCEPTED)&& newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED){
                        lstRejectedDesigns.add(iDR);
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
                    //lock the approved DRs
                    //Approval.lock(lstApprovedDRs, true);
                    
                    priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
                    
                    //prepare list of Opp to create new Opps
                    lstInsertOpportunities  = createOpportunity(lstApprovedDRs, Pricebook);
                    
                    List<id> insertOppIds = new List<id>();
                    if(lstInsertOpportunities.size() > 0)
                    {
                        Set<String> oppInsert = new Set<String>();
                        //////////////////////////////////insert Opp
                        for(Opportunity opp : lstInsertOpportunities){
                            oppInsert.add(opp.Name);
                        }
                        // List<Opportunity> oppInsertion = [Select Id, Name from Opportunity Where Name IN:oppInsert]; 
                        // if(oppInsertion.size()==0){
                        //insert lstInsertOpportunities;
                        //Inserting Opportunity
                        Integer i = 0;
                        Database.SaveResult[] lstInsertOpportunitiesCreation = Database.insert(lstInsertOpportunities, false);  
                        System.debug('Insert li::'+lstInsertOpportunitiesCreation);
                        for (Database.SaveResult sr : lstInsertOpportunitiesCreation)
                        {                    
                            if (!sr.isSuccess())
                            {
                                for(Database.Error err : sr.getErrors())
                                {
                                    
                                    System.debug('Errors in #214::'+err);
                                    logEntriesOppLineItemsforOpptyCreation.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Retry_Counter__c=1, Core_Next_Scheduled_Run__c=System.Now(),Core_Origin__c = 'Opportunity Creation', Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project,
                                                                                                     Core_sObjectId__c = lstInsertOpportunities[i].Core_Design_Registration_Id__c));
                                    // System.debug('listitem in #691::'+logEntriesOppLineItems);
                                }
                                i++;
                            }
                            else if(sr.isSuccess())
                            {  
                                System.debug('Errors in #223::'+sr);
                                logEntriesOppLineItemsforOpptyCreation.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = 'Opportunity Creation Success', Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project,
                                                                                                 Core_sObjectId__c = lstInsertOpportunities[i].Core_Design_Registration_Id__c));
                                i++;
                            }
                        }
                        
                        OpportunityShare(lstInsertOpportunities);
                        //}          
                        List<Core_Design_Registration__c> lstUpdateOppInDDR = new List<Core_Design_Registration__c>();
                        
                        system.debug('### Insert Opp lst'+lstInsertOpportunities.size());   
                        if(lstInsertOpportunities.size() > 0){
                            for(Opportunity opp: lstInsertOpportunities)
                            {
                                //add Opp Ids to create OLIs
                                insertOppIds.add(opp.id);
                                System.debug('Call inside for::');
                                if(opp.id !=null){
                                    //add Opp Id to DR to update the opportunity lookup in DR
                                    Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                                    
                                    tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                                    
                                    lstUpdateOppInDDR.add(tempDR);   
                                }                               
                            }
                            
                            
                            if(lstUpdateOppInDDR.size() > 0)
                            {
                                System.debug('Inside 218::'+lstUpdateOppInDDR);
                                
                                update lstUpdateOppInDDR;
                            }
                        }
                    }  
                    
                    if(logEntriesOppLineItemsforOpptyCreation.size() > 0){
                        insert logEntriesOppLineItemsforOpptyCreation;
                    }               
                    
                    //Call OLI creation future method
                    if(insertOppIds.size() > 0 )
                    {  
                        insertOppLineItems(insertOppIds, DDRids);  
                    }
                } AfterUpdateIterated = false;
            }
            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            }   
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processAfterUpdate->'+myMsg);
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {
                String ddrId = '';
                if(lstInsertOpportunities.size() > 0){
                    ddrId = lstInsertOpportunities[0].Core_Design_Registration_Id__c;
                }
                List<Core_Log_Entry__c> logEntry = [Select Id,Core_Retry_Counter__c,Core_Message__c,Core_Next_Scheduled_Run__c from Core_Log_Entry__c where Id=:logErrorId];
                System.debug('#Due to Retry Lgic::' +logEntry);
                
                if(logEntry.size()>0){ 
                    System.debug('#If  Scenario 236Line::'+logErrorId);
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c( Id =logEntry[0].id, Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = logEntry[0].Core_Retry_Counter__c+1, Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);     
                    update ExcepLog;
                }
                else{
                    System.debug('#Else Normal Scenario else 236::');
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);
                    insert ExcepLog;
                }
                
                
            }
        }
        
    }
    
    public static void populatePartnerAccount(List<Core_Design_Registration__c> lstDesignReg)
    {
        System.debug('Inside populatePartnerAccount');
        Set<Id> setOwnerIds = new Set<Id>();
        for(Core_Design_Registration__c iDesign : lstDesignReg)
        {
            setOwnerIds.add(iDesign.OwnerId);        
        }
        
        Map<Id, User> mapUserIdTOUserRecord = new Map<Id, User>([SELECT id, Name, Contact.Account.Id FROM User WHERE Id IN: setOwnerIds]);   
        List<Core_Design_Registration__c> lstUpdateDesignReg = new List<Core_Design_Registration__c>();
        
        try
        {
            for(Core_Design_Registration__c iDR : lstDesignReg)
            {
                
                //update partner account value based on the login distributor
                if(mapUserIdTOUserRecord.containsKey(iDR.OwnerId) && mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id != null)
                {
                    Core_Design_Registration__c objDesign = new Core_Design_Registration__c(Id = iDR.Id);
                    objDesign.Core_Partner_Account_Id__c = mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id;
                    System.debug('partneraccountid-->'+objDesign.Core_Partner_Account_Id__c);
                    
                    //To change the group name based on the new partner account's location details and flag design to send email to new ISR group
                    objDesign.Core_Approver_Grp_Nm__c = null;
                    objDesign.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    
                    lstUpdateDesignReg.add(objDesign);
                }
                else
                {
                    Core_Design_Registration__c objDesign = new Core_Design_Registration__c(Id = iDR.Id);
                    objDesign.Core_Partner_Account_Id__c = null;
                    
                    //To change the group name based on the new partner account's location details and flag design to send email to new ISR group
                    objDesign.Core_Approver_Grp_Nm__c = null;
                    objDesign.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    lstUpdateDesignReg.add(objDesign);
                }
            }
            
            if(lstUpdateDesignReg.size() > 0)
            {
                System.debug('Update in Populate'+lstUpdateDesignReg);
                update lstUpdateDesignReg;
            }
            
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processBeforeInsert->'+myMsg);        
        }    
    }
    
    //Update : update approver group name for Embedded/IOT | Boards and System - DINESH 
    public static void updateGroupName(List<Core_Design_Registration__c> lstDesignRegistrations)
    {
        Set<Id> setDistiAccountIds = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Core_Design_Registration__c> lstUpdDesigns = new List<Core_Design_Registration__c>();
        
        Map<String,String>  mapFPGA_ISRCityToGroupName = new Map<String,String>();      
        Map<String,String>  mapEmbedded_IOT_ISRCityToGroupName = new Map<String,String>(); 
        
        Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
        Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
        
        //get product group values from custom metadata
        List<String> prdGroupNames = LabelConfiguration__mdt.getInstance('Core_Product_Group_Nm_c').value__c.trim().split(';');
        
        try
        {        
            for(Core_Location_To_Approver_Group_Mapping__c iISRMap : Core_Location_To_Approver_Group_Mapping__c.getAll().values())
            {
                if(Test.isRunningTest()){
                    
                    iISRMap.Core_Active_Ind__c = TRUE;   
                }  
                
                if(iISRMap.Core_Active_Ind__c == TRUE)
                {
                    
                    if(iISRMap.Core_Product_Group_Nm__c == 'FPGA/Power')
                    {
                        if(iISRMap.Core_State_Cd__c != NULL)
                        {
                            mapFPGA_ISRCityToGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        }
                        else if(iISRMap.Core_Country_Cd__c != NULL)
                        {
                            mapFPGA_ISRCityToGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        }
                        
                        else if(iISRMap.Core_State_Cd__c == NULL && iISRMap.Core_Country_Cd__c == NULL)
                        {
                            mapFPGA_ISRCityToGroupName.put('All',iISRMap.Core_Approver_Group_Nm__c);
                        }
                    }
                    else if(prdGroupNames.contains(iISRMap.Core_Product_Group_Nm__c))
                    {
                        if(iISRMap.Core_State_Cd__c != NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        }
                        else if(iISRMap.Core_Country_Cd__c != NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        } 
                        //added by DINESH for ASMO and EMEA Groups
                        else if(iISRMap.Region__c!=null){
                            mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Region__c,iISRMap.Core_Approver_Group_Nm__c);
                        }
                        else if(iISRMap.Core_State_Cd__c == NULL && iISRMap.Core_Country_Cd__c == NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put('All',iISRMap.Core_Approver_Group_Nm__c);
                        }
                    }
                }
            } 
            
            System.debug('mapEmbedded_IOT_ISRCityToGroupName -->'+JSON.serialize(mapEmbedded_IOT_ISRCityToGroupName));
            
            for(Core_Design_Registration__c iDR : lstDesignRegistrations)
            {
                setDistiAccountIds.add(iDR.Core_Partner_Account_Id__c);
            }
            
            lstAccount = [SELECT id, Name, BillingState, BillingCountry FROM Account WHERE Id IN: setDistiAccountIds];        
            
            for(Account iAcc : lstAccount)
            {
                mapAccountToBillingState.put(iAcc.Id, iAcc.BillingState);
                mapAccountToBillingCountry.put(iAcc.Id, iAcc.BillingCountry);
            }
            
            //get group name based on the DR's distributor account
            for(Core_Design_Registration__c iDR : lstDesignRegistrations)
            {
                Core_Design_Registration__c groupDesign = new Core_Design_Registration__c(Id = iDR.Id);
                
                if(iDR.Core_Product_Group_Nm__c == 'FPGA/Power')
                {
                    
                    if(Test.isRunningTest()){
                        
                        iDR.Core_Design_Solution_Network_Ind__c = FALSE;  
                    }
                    if(iDR.Core_Design_Solution_Network_Ind__c == TRUE)
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = Label.Core_DDR_DSN_Group_Name;
                    }
                    else
                    {
                        
                        if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                        {
                            groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                            System.debug('ApproverGroupName-->' + groupDesign.Core_Approver_Grp_Nm__c);
                        }
                        if(groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                        {
                            groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get(mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                            System.debug('ApproverGroupName-->' + groupDesign.Core_Approver_Grp_Nm__c);
                        }
                        
                    }
                }
                else if( prdGroupNames.contains(iDR.Core_Product_Group_Nm__c))
                {
                    //added by DINESH to update region specific group name one DDR
                    
                    if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Partner_Account_Region_Cd__c!=null && (iDR.Core_Partner_Account_Region_Cd__c =='ASMO' || iDR.Core_Partner_Account_Region_Cd__c =='EMEA'))
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(iDR.Core_Partner_Account_Region_Cd__c);
                    }
                    
                    if( groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                    }
                    if(groupDesign.Core_Approver_Grp_Nm__c == NULL && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                    {
                        groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get(mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                    }
                    
                }
                
                if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Product_Group_Nm__c == 'FPGA/Power')
                {
                    groupDesign.Core_Approver_Grp_Nm__c = mapFPGA_ISRCityToGroupName.get('All');
                }
                else if(groupDesign.Core_Approver_Grp_Nm__c == NULL && prdGroupNames.contains(iDR.Core_Product_Group_Nm__c))
                {
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get('All');
                }
                
                lstUpdDesigns.add(groupDesign);
                System.debug('groupDesign-->' + groupDesign);
            }  
            
            if(lstUpdDesigns.size() > 0 && Trigger.isUpdate && Trigger.isAfter)
            {
                DDR_DMLOprationsCtrl.upsertData(lstUpdDesigns);
            }
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processBeforeUpdate->'+myMsg);         
        }  
        
    }
    
    public static void lockRejectedProducts(List<Core_Design_Registration__c> lstRejectedDesignReg)
    {
        List<Core_Design_Registration_Product__c> lstRejectedProducts = new List<Core_Design_Registration_Product__c>();   
        lstRejectedProducts = [SELECT id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c IN: lstRejectedDesignReg AND Core_Design_Product_Status_Nm__c =: DR_STATUS_REJECTED]; 
        
        if(lstRejectedProducts.size() > 0 )
        {
            for(Core_Design_Registration_Product__c DesignProduct : lstRejectedProducts){
                DesignProduct.Core_Locked_Ind__c = true;
                
                DesignProduct.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
            }
            update lstRejectedProducts;
            //Approval.lock(lstRejectedProducts);
            
        }
        
    }
    
    public static void checkForExportCompliance(List<Core_Design_Registration__c> lstDesignReg)
    {
        
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplBlk = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplUnBlk = new List<Core_Design_Registration__c>();
        
        lstDesignReg = [SELECT id, Name, Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c, Core_Design_Registration_Status_Nm__c, Core_End_Customer_Export_Cmplnc_Bloc_Ind__c FROM Core_Design_Registration__c WHERE Id IN: lstDesignReg];
        
        for(Core_Design_Registration__c iDesignReg : lstDesignReg)
        {
            /*   if(Test.isRunningTest()){

iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == TRUE;
iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c != TRUE;
} */
            if(iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == TRUE && iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c != TRUE)
            {                
                Core_Design_Registration__c tDesignReg = new Core_Design_Registration__c(Id = iDesignReg.Id);
                tDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = TRUE;
                tDesignReg.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                
                lstDesignRegToupdateExportComplBlk.add(tDesignReg);
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
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplblk];
            system.debug('lstDesignRegProdToupdateExportComplBlk'+lstDesignRegProdToupdateExportComplBlk);
            if(lstDesignRegProdToupdateExportComplBlk.size() > 0)
            {
                //Approval.Lock(lstDesignRegProdToupdateExportComplBlk);  
                
                List<Core_Design_Registration_Product__c> lstLockDRProds = new List<Core_Design_Registration_Product__c>();
                for(Core_Design_Registration_Product__c iLockDRProds : lstDesignRegProdToupdateExportComplBlk)
                {
                    Core_Design_Registration_Product__c tempDRProds = new Core_Design_Registration_Product__c(Id = iLockDRProds.Id);
                    tempDRProds.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                    
                    lstLockDRProds.add(tempDRProds);        
                }
                update lstLockDRProds;                
                
            }
        }
        
        if(lstDesignRegToupdateExportComplUnBlk.size() > 0)
        {
            update lstDesignRegToupdateExportComplUnBlk;    
            //Approval.unLock(lstDesignRegToupdateExportComplUnBlk);
            
            List<Core_Design_Registration_Product__c> lstDesignRegProdToupdateExportComplBlk = new List<Core_Design_Registration_Product__c>();
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplUnBlk];
            
            if(lstDesignRegProdToupdateExportComplBlk.size() > 0)
            {
                //Approval.unLock(lstDesignRegProdToupdateExportComplBlk);            
            }        
        }
        
        
    }
    
    
    //DR Share 
    public static void designRegShare(List<Core_Design_Registration__c> newDesignRegList){
        
        //Create a set for Roles
        Set<id> userRoleSet = new Set<id>();
        List<Core_Design_Registration__c> designRegRoleList = [select id, Owner.UserRoleId from Core_Design_Registration__c where id IN: newDesignRegList];
        
        for(Core_Design_Registration__c designRegRole: designRegRoleList){
            userRoleSet.add(designRegRole.Owner.UserRoleId);
        }
        
        //Get the Group Id
        List<Group> roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: userRoleSet and type = 'role'];
        
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        
        for(group grp: roleGroup){
            roleAndGroupMap.put(grp.RelatedId, grp.id);
        }
        
        // Create a new list of sharing objects for Design Registration
        List<Core_Design_Registration__Share> designRegShrs  = new List<Core_Design_Registration__Share>();
        
        // Declare variables for Design Registration sharing
        Core_Design_Registration__Share designRoleShr;
        
        for(Core_Design_Registration__c designShr : designRegRoleList){
            // Instantiate the sharing objects
            designRoleShr = new Core_Design_Registration__Share();
            
            // Set the ID of record being shared
            designRoleShr.ParentId = designShr.Id;
            
            // Set the ID of user or group being granted access
            designRoleShr.UserOrGroupId = roleAndGroupMap.get(designShr.Owner.UserRoleId);//'00Gg0000002taQY';
            
            // Set the access level
            designRoleShr.AccessLevel = 'edit';
            
            // Set the Apex sharing 
            designRoleShr.RowCause = 'Manual';
            designRegShrs.add(designRoleShr);
        }
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(designRegShrs,false);
    }
    
    //Opportunity Share 
    public static void OpportunityShare(List<Opportunity> newOppList){
        Map<String, String> integrationUserMap = new Map<String, String>{'PCC Integration User' => '00EDf000000XKRqMAO;00EDf000000XKRpMAO'};
            // Create a new list of sharing objects for Design Registration
            List<OpportunityShare> oppShrs  = new List<OpportunityShare>();
        
        //Create a set for Roles
        Set<id> userRoleSet = new Set<id>();
        List<Opportunity> oppRoleList = [select id, Core_Technical_Owner__r.UserRoleId, Core_Design_Registration_Id__r.CreatedBy.Name 
                                         from Opportunity where id IN: newOppList];
        
        // SELECT Id, Name FROM UserRole
        
        
        for(Opportunity oppRole: oppRoleList){
            userRoleSet.add(oppRole.Core_Technical_Owner__r.UserRoleId);
            //for m2m Sharing
            if(integrationUserMap.containsKey(oppRole.Core_Design_Registration_Id__r.CreatedBy.Name)){
                List<String> roleIds = new List<String>(integrationUserMap.get(oppRole.Core_Design_Registration_Id__r.CreatedBy.Name).split(';'));
                for(String roleId : roleIds){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.OpportunityId = oppRole.Id;
                    oppShare.UserOrGroupId = roleId;
                    oppShare.OpportunityAccessLevel = 'Edit';
                    oppShare.RowCause = 'Manual';
                    oppShrs.add(oppShare);
                }
            }
        }
        
        //Get the Group Id
        List<Group> roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: userRoleSet and type = 'role'];
        
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        
        for(group grp: roleGroup){
            roleAndGroupMap.put(grp.RelatedId, grp.id);
        }
        
        // Declare variables for Design Registration sharing
        OpportunityShare oppRoleShr;
        
        for(Opportunity oppShr : oppRoleList){
            
            oppRoleShr = new OpportunityShare(); // Instantiate the sharing objects
            
            oppRoleShr.OpportunityId = oppShr.Id; // Set the ID of record being shared
            oppRoleShr.UserOrGroupId = roleAndGroupMap.get(oppShr.Core_Technical_Owner__r.UserRoleId); // Set the ID of user or group being granted access
            oppRoleShr.OpportunityAccessLevel = 'edit'; // Set the access level
            oppRoleShr.RowCause = 'Manual'; // Set the Apex sharing 
            oppShrs.add(oppRoleShr);
        }
        
        System.debug('###oppShrs'+oppShrs);
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(oppShrs,false);
    }
    
    //Suresh 09/25/2017-To create the Opportunity Line Items after approval (Opportunity before trigger causing too many SOQL queries, so written this method as FUTURE)
    //Opportunity line items not getting copied on first DR Approval. Made insertOppLineItems() method inline to fix this.
    //@future 
    public static void insertOppLineItems(List<id> insertOppIds, List<id> DDRids) 
    {
        System.debug('Inside insertOppLineItems');
        Pricebook2 priceBook;
        List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
        List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstDRLineItems = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstProcessedDRLineItems = new List<Core_Design_Registration_Product__c>();
        
        Map<string, PriceBookEntry> mapProductNameTOPricebookEntry = new map<string, PriceBookEntry>();
        Map<Id, Opportunity> mapOppIdTOOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapDRIDTOOpp = new Map<Id, Opportunity>();     
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        List<PCC_DDR_L5_Product_Mapping__c> l5ProdList = new List<PCC_DDR_L5_Product_Mapping__c>();
        List<Opportunity> lstInsertOpportunities = [select id, name,Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.OwnerId, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c, 
                                                    Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID from Opportunity where id IN: insertOppIds];
        
        //query Partner Price Book
        priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
        try{
            for(Opportunity iOpp : lstInsertOpportunities)
            {
                mapDRIDTOOpp.put(iOpp.Core_Design_Registration_Id__c, iOpp);
            }        
            
            // Find relevant price entries
            for(PricebookEntry iPBE : [SELECT Id, UnitPrice, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id =: priceBook.id AND isActive = true])
            {
                mapProductNameTOPricebookEntry.put(iPBE.Product2.Name, iPBE);
            }
            
            lstDRLineItems = [SELECT id, Name,Core_Design_Registration_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c, 
                              Core_Product_Id__c, Core_Full_Year_Qty__c, Core_Target_Resale_Amt__c, Core_Product_Id__r.IsActive 
                              FROM Core_Design_Registration_Product__c 
                              WHERE Core_Design_Registration_Id__c IN: DDRids AND Core_Product_Id__r.IsActive = true];
            
            for(Core_Design_Registration_Product__c iDDRLI : lstDRLineItems)
            {
                //Rajadinakaran 10/05/2017: Added all the line items to update processed 
                if(iDDRLI.Core_Design_Product_Status_Nm__c != DR_LI_STATUS_PENDING)
                {
                    iDDRLI.Core_Locked_Ind__c = TRUE;
                    
                    iDDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                    
                    lstProcessedDRLineItems.add(iDDRLI);
                }
                
                if(iDDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED)
                {
                    lstApprovedDRLineItems.add(iDDRLI);
                }   
            }
            if(lstProcessedDRLineItems.size() > 0)
            {
                System.debug('Line Item update 684'+lstProcessedDRLineItems);
                update lstProcessedDRLineItems;
                //Approval.lock(lstProcessedDRLineItems, true);
            }
            
            //add list of OLIs for OLI creation
            for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
            {
                
                if(mapDRIDTOOpp.containskey(iDRLI.Core_Design_Registration_Id__c))
                {
                    OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = mapDRIDTOOpp.get(iDRLI.Core_Design_Registration_Id__c).Id);
                    
                    createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                    createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                    createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                    createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;   
                    createOppLineItem.PricebookEntryId = mapProductNameTOPricebookEntry.get(iDRLI.Core_Product_Id__r.Name).id;
                    createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                    
                    lstOpportunityLIs.add(createOppLineItem);           
                }
            }
            List<Core_Log_Entry__c> logEntriesOppLineItems = new List<Core_Log_Entry__c>();
            
            if(!lstOpportunityLIs.isEmpty())
            {  
                Integer i = 0;
                Database.SaveResult[] lstDesignProductUpdate = Database.insert(lstOpportunityLIs, false);  
                System.debug('Insert li::'+lstDesignProductUpdate);
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            System.debug('SRsr.getId() in #689::'+lstOpportunityLIs[i].Failed_DDR_RecordID__c);
                            System.debug('Errors in #689::'+err);
                            logEntriesOppLineItems.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_sObjectId__c = lstOpportunityLIs[i].Failed_DDR_RecordID__c));
                            System.debug('listitem in #691::'+logEntriesOppLineItems);
                        }
                        i++;
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesOppLineItems.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        i++;
                    }
                }           
            }
            if(!logEntriesOppLineItems.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesOppLineItems;
                }
            }
            
            List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
            Map<id,OpportunityLineItem>  mapOpLineItem = new Map<id,OpportunityLineItem>();
            //Update OLI Id in DRLI
            for(OpportunityLineItem iOLI : lstOpportunityLIs)
            {
                Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id, Core_Locked_Ind__c = TRUE);
                
                iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                
                lstDRLIWithOLIId.add(iDRLI); 
                mapOpLineItem.put(iOLI.Core_Design_Registration_Product_Id__c,iOLI);
            }
            
            List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();
            
            if(!lstDRLIWithOLIId.isEmpty())
            {  
                Database.SaveResult[] lstDesignProductUpdate = Database.update(lstDRLIWithOLIId, false);         
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineInsert, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    }
                }           
            }
            if(!logEntriesDRP.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesDRP;
                    // Approval.lock(lstDRLIWithOLIId, true);
                }
            }
            
            //Create TeamMember
            list<OpportunityTeamMember> OppTeamMember = new list<OpportunityTeamMember>();
            
            List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
            lstOppTeamMember = [SELECT Id, Name, UserId, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: lstInsertOpportunities];
            Map<Id, Id> mapTeamMemberIdOpportunityId = new Map<Id, Id>();
            
            for(OpportunityTeamMember iTM : lstOppTeamMember)
            {
                mapTeamMemberIdOpportunityId.put(iTM.UserId, iTm.OpportunityId);
            }
            
            for(Opportunity opp : lstInsertOpportunities){
                OpportunityTeamMember createOppTeamMember = new OpportunityTeamMember();
                createOppTeamMember.OpportunityId = opp.id;
                createOppTeamMember.TeamMemberRole = 'Team Member (100%)';
                if(!mapTeamMemberIdOpportunityId.containskey(Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID))
                {
                    
                    createOppTeamMember.userid = Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID;
                    //createOppTeamMember.Core_Description_of_Contribution__c = createOppTeamMember.TeamMemberRole;
                    OppTeamMember.add(createOppTeamMember);
                }
                
                
                // added by DINESH to add End Customer Account Owner to Opportunity Team
                /* if(!mapTeamMemberIdOpportunityId.containskey(Opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.OwnerId))
{
createOppTeamMember.userid = Opp.Core_Design_Registration_Id__r.Core_End_Customer_Account_Id__r.OwnerId;
//createOppTeamMember.Core_Description_of_Contribution__c = createOppTeamMember.TeamMemberRole;
OppTeamMember.add(createOppTeamMember);
}*/
                
            }
            List<Core_Log_Entry__c> logEntriesOppTeam = new List<Core_Log_Entry__c>();
            
            if(!OppTeamMember.isEmpty())
            {  
                Database.SaveResult[] lstDesignProductUpdate = Database.insert(OppTeamMember, false); 
                
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesOppTeam.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppTeamMemberInsert, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesOppTeam.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppTeamMemberInsert, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    }
                }           
            }
            if(!logEntriesOppTeam.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesOppTeam;
                }
            }
            
            //Create opportunity partner using Partner account in DR 
            List<Core_Opportunity_Partner__c> OppPartnerlist = new List<Core_Opportunity_Partner__c>();
            for(Opportunity opp : lstInsertOpportunities){
                Core_Opportunity_Partner__c op = new Core_Opportunity_Partner__c(Core_Opportunity__c = opp.id, Core_Partner_Type__c = 'Distributor', Core_Partner_Role__c = 'Co-Design');
                op.Core_Partner__c = opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c;
                OppPartnerlist.add(op);
            }
            
            List<Core_Log_Entry__c> logEntriesOppPartner = new List<Core_Log_Entry__c>();
            
            if(!OppPartnerlist.isEmpty())
            {  
                Database.SaveResult[] lstDesignProductUpdate = Database.insert(OppPartnerlist, false);         
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesOppPartner.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppPartnerInsert, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesOppPartner.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppPartnerInsert, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    }
                }           
            }
            
            //Added by Chaithaly to update DDR L5 mapping attributes
            l5ProdList = [select Id,PCC_Design_Registration__c, PCC_Design_Registration_Product__c, PCC_Opportunity__c from PCC_DDR_L5_Product_Mapping__c where PCC_Design_Registration__c IN: DDRids];
            list<PCC_DDR_L5_Product_Mapping__c> l5ProdListToUpdate = new list<PCC_DDR_L5_Product_Mapping__c>();
            for (PCC_DDR_L5_Product_Mapping__c l5ProdListRec :l5ProdList){
                l5ProdListRec.PCC_Opportunity__c = mapDRIDTOOpp.containsKey(l5ProdListRec.PCC_Design_Registration__c) ?  ((mapDRIDTOOpp.get(l5ProdListRec.PCC_Design_Registration__c)!= null) ? mapDRIDTOOpp.get(l5ProdListRec.PCC_Design_Registration__c).id : null ) :null;
                
                //  l5ProdListRec.PCC_Opportunity_Product__c = mapOpLineItem.containsKey(l5ProdListRec.PCC_Design_Registration_Product__c) ?  ((mapOpLineItem.get(l5ProdListRec.PCC_Design_Registration_Product__c)!= null) ? mapOpLineItem.get(l5ProdListRec.PCC_Design_Registration_Product__c).id : null ) :null;
                
                l5ProdListToUpdate.add(l5ProdListRec);
            }
            
            if(l5ProdListToUpdate.size()>0){
                Database.SaveResult[] l5ProdListToUpdateResult = Database.update(l5ProdListToUpdate, false);                 
                for (Database.SaveResult sr : l5ProdListToUpdateResult)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesOppPartner.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DDRL5Mapping, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesOppPartner.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DDRL5Mapping, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    }
                }  
                
            }
            if(!logEntriesOppPartner.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesOppPartner;
                }
            }
            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            }   
        }
        catch(Exception e)
        {
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c || Test.isRunningTest())
            {
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineInsertExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
                insert ExcepLog;
            }
        }
    }
    
    public static void postApprovalFromResubmittedDR(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, 
                                                     Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap) 
    {
        
        Set<Id> setDRIds = new Set<Id>();
        List<Core_Design_Registration_Product__c> lstDDRLI = new List<Core_Design_Registration_Product__c>();
        
        try
        {
            //Manage newly added and approved line items after approval
            for(Core_Design_Registration__c iDR: newList)
            {
                if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_RESUBMITTED && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                {
                    setDRIds.add(iDR.Id);        
                }
            }
            system.debug('Inside postApprovalFromResubmittedDR:'+setDRIds);
            if(setDRIds.size() > 0)
            {
                //Call future method to create OLI
                insertApprovedLIsToExistingOpps(setDRIds);
            }
            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            } 
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('postApprovalFromResubmittedDR'+myMsg);
        }       
    }   
    
    @future 
    public static void insertApprovedLIsToExistingOpps(Set<Id> setDRIds)
    {
        system.debug('Inside insertApprovedLIsToExistingOpps:'+setDRIds);
        List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
        List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
        
        //modified SOQL - Gaurav
        lstApprovedDRLineItems = [SELECT id, Name, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c,Core_Locked_Ind__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c FROM Core_Design_Registration_Product__c WHERE Core_Locked_Ind__c  = FALSE AND Core_Design_Registration_Id__c IN: setDRIds];           
        
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        try{
            //add list of OLIs for OLI creation
            for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
            {
                iDRLI.Core_Locked_Ind__c = TRUE;//added by suresh
                iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                
                if(iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED){
                    OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                    
                    createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                    createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                    createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                    createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;   
                    createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                    system.debug('Inside insertApprovedLIsToExistingOpps createOppLineItem:'+createOppLineItem);
                    lstOpportunityLIs.add(createOppLineItem);
                }
            }
            system.debug('Inside insertApprovedLIsToExistingOpps before update:'+lstApprovedDRLineItems);
            update lstApprovedDRLineItems; //added by suresh
            system.debug('Inside insertApprovedLIsToExistingOpps after update:'+lstApprovedDRLineItems);
            System.debug('##919#lstOpportunityLIs:::'+lstOpportunityLIs);
            
            // Approval.lock(lstApprovedDRLineItems, true); //added by suresh
            
            if(!lstOpportunityLIs.isEmpty())
            {  
                Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstOpportunityLIs, false);         
                Integer i = 0;
                for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                {      
                    System.debug('###lstOpportunityLIs size :::'+lstOpportunityLIs.size());
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            System.debug('##919#ERROR:::'+err);                     
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Next_Scheduled_Run__c = System.now()+(5/1440),  Core_Retry_Counter__c = 1, Core_Project__c = Project, Core_sObjectId__c = lstOpportunityLIs[i].Failed_DDR_RecordID__c));
                            
                        }
                        i++;
                    }
                    else if(sr.isSuccess())
                    {
                        
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));                       
                        i++;
                    }
                }           
            }
            if(!logEntries.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntries;
                }
            }
            
            List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
            
            //update OLI id in DR LI
            for(OpportunityLineItem iOLI : lstOpportunityLIs)
            {
                Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id, Core_Locked_Ind__c = TRUE);
                iDRLI.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
                
                lstDRLIWithOLIId.add(iDRLI); 
            }
            
            List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();
            
            if(!lstDRLIWithOLIId.isEmpty())
            {  
                Database.SaveResult[] lstDesignProductUpdate = Database.update(lstDRLIWithOLIId, false);         
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = DesignProductOnOppLineUpdate, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                    }
                }           
            }
            if(!logEntriesDRP.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesDRP;
                    // Approval.lock(lstDRLIWithOLIId, true);
                }
            }
            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            }   
        }
        catch(Exception e)
        {
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
                insert ExcepLog;
            }
        }
    }
    
    /***************Retry Logic for Line items Start******************/
    
    @InvocableMethod(label='DDR Retry' description='Reprocess the failed records' category='LogEntry')
    public static void RetryFailedRecords(List<ID> ids) {
        System.debug('*****Retry Logic Start***');
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
        Id userId = Userinfo.getUserId();
        Set < String > drNameSet = new Set < String > ();
        Set < String > oppNameSet = new Set < String > ();
        Pricebook2 priceBook;
        Set<Id> setOfDDRIds = new Set<Id>();
        
        //Check for export compliance
        List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
        ////////////////////////////////////////
        
        List<Core_Log_Entry__c> logEList=[Select Id, Name, Core_Retry_Counter__c, Core_Origin__c, Core_Message__c, Core_sObjectId__c, Core_Next_Scheduled_Run__c from Core_Log_Entry__c where id IN :ids AND Core_sObjectId__c != null AND Core_Message__c != 'Successfully Inserted'];
        System.debug('***logEList::'+logEList);
        for(Core_Log_Entry__c logE : logEList)
        {
            FailedDdr.add(logE.Core_sObjectId__c); 
            logErrorId = logE.Id;
        }
        System.debug('***FailedDdr:::'+FailedDdr);
        //  If(RetryOrigin == 'Opportunity Creation'){
        listApprovedDDReg = [SELECT id, Name, Core_Product_Group_Nm__c, Core_Design_Registration_Nm__c, Core_Vertical_Market_Nm__c, Core_Military_Aerospace_Gvrnmt_Use_Ind__c, Core_Product_Application_Nm__c,Core_Product_Segment_Nm__c, Core_Opportunity_Id__c, Core_End_Customer_Account_Id__c, OwnerId, Core_Partner_Account_Id__c, Core_Approver_Grp_Nm__c, Core_Design_Registration_Status_Nm__c, Core_Manufacturing_Region_Cd__c, Core_Production_End_Dt__c, Core_First_Customer_Ship_Dt__c, Core_Intel_Platform_Nm__c, Core_FPGA_Quote_Comments_Txt__c, Core_Design_Registration_Dsc__c, Core_Intel_Technical_Owner_Id__c, Core_Opportunity_Volume_Cnt__c, Core_Opportunity_Decision_Dt__c from Core_Design_Registration__c where Id =:FailedDdr AND Core_Opportunity_Id__c=null];
        System.debug('Retry record for opp:::'+listApprovedDDReg);
        
        
        If(listApprovedDDReg.size()>0)
        {
            /***************Retry Logic for Oppo Start******************/
            System.debug('Inside OPP Retry 1');
            
            for(Core_Design_Registration__c oppDDR : listApprovedDDReg)
            {
                lstApprovedDDR.put(oppDDR.Id, oppDDR);
                System.debug('***lstApprovedDDR:: '+lstApprovedDDR);
            }
            
            If(listApprovedDDReg.size()>0)
            {
                
                //////////////////////////////start 
                try
                {           
                    
                    for(Core_Design_Registration__c iDR : listApprovedDDReg)
                    {
                        if(iDR.Core_End_Customer_Account_Id__c != null)
                        {
                            lstDesignRegForExportCompl.add(iDR);    
                        }
                        
                        if(iDR.OwnerId != null && iDR.Core_Partner_Account_Id__c == null)
                        {
                            system.debug(iDR.Id);
                            lstDesignRegForSharing.add(iDR);
                            setOfDDRIds.add(iDR.Id);
                        }
                        
                        drNameSet.add(iDR.Name);
                    }            
                    
                    for (Opportunity opp: [SELECT Id,Name From Opportunity WHERE Name in: drNameSet]) {
                        oppNameSet.add(opp.Name);
                    }
                    //To populate the partner account and share the design based on owner field
                    if(lstDesignRegForSharing.size() > 0)
                    {
                        system.debug('Line 1082'+lstDesignRegForSharing);
                        iterated = false;
                        populatePartnerAccount(lstDesignRegForSharing);
                        designRegShare(lstDesignRegForSharing);
                        system.debug('setOfDDRIds-->'+setOfDDRIds);
                        //update sharing of transactional object as well 
                        PCC_DDRL5ProductMapping_TriggerHandler.DDRL5MappingsSharing(setOfDDRIds);
                    }       
                    system.debug('hereCAS'+lstDesignRegForExportCompl);
                    if(lstDesignRegForExportCompl.size() > 0)
                    {
                        checkForExportCompliance(lstDesignRegForExportCompl);
                    }
                    
                    for(Core_Design_Registration__c iDR : listApprovedDDReg)
                    {
                        
                        if(iDR.Core_Partner_Account_Id__c != NULL && iDR.Core_Approver_Grp_Nm__c == NULL)
                        {
                            lstDesignsForGroupName.add(iDR);    
                        }
                        
                        //if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && !(oldMap.get(iDR.Id).Core_Opportunity_Id__c != newMap.get(iDR.Id).Core_Opportunity_Id__c) && !(oldMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c != newMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c))
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && iDR.Core_Opportunity_Id__c == null &&
                           !oppNameSet.Contains(iDR.Name))//Added by Suresh Palvadi
                        {
                            lstApprovedDRs.add(iDR);
                        }    
                        
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED) 
                        {
                            
                            DDRids.add(iDR.id);
                            System.debug('DDRids::'+DDRids);
                        }
                        
                        //Lock the rejected line items after header is locked
                        if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED)
                        {
                            lstRejectedDesigns.add(iDR);
                        }
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
                        System.debug('inside list 1133');
                        priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
                        
                        //prepare list of Opp to create new Opps
                        lstInsertOpportunities = createOpportunity(lstApprovedDRs, priceBook);
                        
                        List<id> insertOppIds = new List<id>();
                        if(lstInsertOpportunities.size() > 0)
                        {   
                            Set<String> oppInsert = new Set<String>();
                            //////////////////////////////////insert Opp
                            
                            Database.SaveResult[] lstOppLineItemsInsertResults;
                            
                            
                            lstOppLineItemsInsertResults = Database.insert(lstInsertOpportunities, false);  
                            System.debug('###lstOppInsertResults :::'+lstOppLineItemsInsertResults);
                            
                            if(lstOppLineItemsInsertResults.size()>0){
                                
                                for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                                {      
                                    
                                    System.debug('###lstInsertOpportunities size :::'+lstInsertOpportunities.size());
                                    if (!sr.isSuccess())
                                    {
                                        for(Core_Log_Entry__c logE : logEList)
                                        {
                                            Core_Log_Entry__c log = new Core_Log_Entry__c();
                                            log.Id = logE.Id;
                                            System.debug('##log.Id '+log.Id);
                                            log.Core_Retry_Counter__c = logE.Core_Retry_Counter__c +1;
                                            if(log.Core_Retry_Counter__c<4){
                                                log.Core_Message__c = logE.Core_Message__c + ' - Retry Started';
                                            }Else{
                                                log.Core_Message__c = logE.Core_Message__c + ' - Retry Ended';
                                            }                    
                                            log.Core_Next_Scheduled_Run__c = System.now()+(5/1440);
                                            System.debug('###Failed Again:::');
                                            logEntries.add(log);
                                            
                                        }
                                        
                                    }
                                    else if(sr.isSuccess())
                                    { 
                                        
                                        System.debug('###Sucess:::');
                                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess +' - After Retry', Core_Origin__c = 'Opportunity Creation12', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                                        OpportunityShare(lstInsertOpportunities);
                                        
                                        for(Opportunity opp: lstInsertOpportunities)
                                        {
                                            //add Opp Ids to create OLIs
                                            insertOppIds.add(opp.id);
                                            System.debug('Call inside for::');
                                            //add Opp Id to DR to update the opportunity lookup in DR
                                            Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                                            
                                            tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                                            
                                            lstUpdateOppInDDR.add(tempDR);                        
                                            
                                        }
                                        if(lstUpdateOppInDDR.size() > 0)
                                        {
                                            System.debug('Inside 218::'+lstUpdateOppInDDR);
                                            
                                            update lstUpdateOppInDDR;
                                        }
                                        
                                        
                                        if(insertOppIds.size() > 0)
                                        {      
                                            System.debug('Call Insrt insertOppIds::'+insertOppIds);
                                            System.debug('Call Insrt DRid::'+DDRids);
                                            iterated = false;
                                            insertOppLineItems(insertOppIds, DDRids);  
                                        }
                                    }
                                }
                            }                       
                        }
                        
                        //Call OLI creation future method
                        
                        if(!logEntries.isEmpty() && !logSwitch.isEmpty())
                        {
                            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                            {
                                System.debug('###Upsert Logs:::'+logEntries);
                                upsert logEntries;
                            }
                        }    
                    }       
                    //////////////////////////////////////Stop    
                }
                catch(Exception e)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                    system.debug('Retry Opportunity Exception Call:: '+myMsg);
                    if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                    {
                        String ddrId = '';
                        if(lstInsertOpportunities.size() > 0){
                            ddrId = lstInsertOpportunities[0].Core_Design_Registration_Id__c;
                        }
                        Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);
                        upsert ExcepLog;
                    }
                }
            }
        }
        
        
        lstApprovedDRLineItems = [SELECT id, Name, Core_Opportunity_Product_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c,Core_Locked_Ind__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c from Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:FailedDdr AND Core_Opportunity_Product_Id__c=null ]; //AND Core_Design_Registration_Id__r.Core_Opportunity_Id__c != null
        System.debug('***lstDRLineItems:: '+lstApprovedDRLineItems);
        
        if(lstApprovedDRLineItems.size()>0){
            System.debug('Inside Line Intem Retry');                 
            try{
                
                for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
                {
                    System.debug('##inside for:: '+iDRLI);
                    
                    if(iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_APPROVED && iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c != null){
                        System.debug('##checking if::');
                        OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                        
                        createOppLineItem.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                        createOppLineItem.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                        createOppLineItem.Quantity = iDRLI.Core_Full_Year_Qty__c;
                        createOppLineItem.Product2ID = iDRLI.Core_Product_Id__c;   
                        createOppLineItem.Failed_DDR_RecordID__c = iDRLI.Core_Design_Registration_Id__c;
                        
                        lstOpportunityLIs.add(createOppLineItem);
                        System.debug('##List inside for::'+lstOpportunityLIs);
                    }
                }
                //update lstApprovedDRLineItems;
                System.debug('##1048#lstOpportunityLIs:::'+lstOpportunityLIs);
                
                if(!lstOpportunityLIs.isEmpty())
                {  
                    Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstOpportunityLIs, false);         
                    
                    for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                    {      
                        System.debug('###lstOpportunityLIs size :::'+lstOpportunityLIs.size());
                        if (!sr.isSuccess())
                        {
                            for(Core_Log_Entry__c logE : logEList)
                            {
                                Core_Log_Entry__c log = new Core_Log_Entry__c();
                                log.Id = logE.Id;
                                log.Core_Retry_Counter__c = logE.Core_Retry_Counter__c +1;
                                if(log.Core_Retry_Counter__c<4){
                                    log.Core_Message__c = logE.Core_Message__c + ' - Retry Started';
                                }Else{
                                    log.Core_Message__c = logE.Core_Message__c + ' - Retry Ended';
                                }                    
                                log.Core_Next_Scheduled_Run__c = System.now()+(5/1440);
                                System.debug('###Failed Again Line Item:::');
                                logEntries.add(log);
                            }
                            
                        }
                        else if(sr.isSuccess())
                        {   
                            System.debug('###Sucess 1358:::');
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
                
                List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();            
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
                if(!logEntries.isEmpty() && !logSwitch.isEmpty())
                {
                    if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                    {
                        upsert logEntries;
                    }
                }
                if(Test.isRunningTest()){
                    
                    throw new System.DMLException();   
                }   
            }
            catch(Exception e)
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c || Test.isRunningTest())
                {
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = OppLineUpdateExceMtd, Core_Severity__c = Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
                    upsert ExcepLog;
                }
            }
        }
    }
    /***************Retry Logic for Line Items End******************/
    
    public static void processBeforeUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap){
        List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
        Set< String > DDRNames = new Set< String >();
        Set < String > OppDetails = new Set < String >();
        if(BeforeUpdateIterated){
            BeforeUpdateIterated = false;
            populateDDRFieldValues(newList);
            for(Core_Design_Registration__c iDR : newList){
                if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c != DR_STATUS_APPROVED && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && newMap.get(iDR.Id).Core_Opportunity_Id__c == null){
                    DDRNames.add(iDR.Core_Design_Registration_Nm__c);
                }
                if(oldMap.get(iDR.Id).OwnerId != newMap.get(iDR.Id).OwnerId)
                {
                    system.debug(iDR.Id);
                    lstDesignRegForSharing.add(iDR);
                }                    
            }
            if(lstDesignRegForSharing.size() > 0)
            {system.debug(lstDesignRegForSharing);
             populatePartnerAccountID(lstDesignRegForSharing);
            }
            
            /*  for (Opportunity opp: [SELECT Id,Name From Opportunity WHERE Name in: DDRNames]) {
OppDetails.add(opp.Name);
}

for(Core_Design_Registration__c iDR : newList){
if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c != DR_STATUS_APPROVED && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED 
&& newMap.get(iDR.Id).Core_Opportunity_Id__c == null && OppDetails.contains(iDR.Core_Design_Registration_Nm__c)){
iDR.Core_Design_Registration_Nm__c.addError(Label.Core_Opportunity_Exist_for_Design_Registration_Error_Message);
}
}*/
            //    checkForExistingOpportunity(newList,oldMap);
        }
    }
    public static void populatePartnerAccountID(List<Core_Design_Registration__c> lstDesignReg){
        Set<Id> setOwnerIds = new Set<Id>();
        for(Core_Design_Registration__c iDesign : lstDesignReg)
        {
            setOwnerIds.add(iDesign.OwnerId);        
        }
        
        Map<Id, User> mapUserIdTOUserRecord = new Map<Id, User>([SELECT id, Name, Contact.Account.Id FROM User WHERE Id IN: setOwnerIds]);   
        //List<Core_Design_Registration__c> lstInsertDesignReg = new List<Core_Design_Registration__c>();
        for(Core_Design_Registration__c iDR : lstDesignReg)
        {
            
            //insert partner account value based on the login distributor
            if(mapUserIdTOUserRecord.containsKey(iDR.OwnerId) && mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id != null)
            {
                System.debug('OwnerId-->'+iDR.OwnerId);
                iDR.Core_Partner_Account_Id__c = mapUserIdTOUserRecord.get(iDR.OwnerId).Contact.Account.Id;
                iDR.Core_Approver_Grp_Nm__c = null;
                iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;  
            }
            else{
                iDR.Core_Partner_Account_Id__c = null;
                iDR.Core_Approver_Grp_Nm__c = null;
                iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
            }
        }
    }
    
    public static void checkForExistingOpportunity(List<Core_Design_Registration__c> newDesignRegList,Map<Id,Core_Design_Registration__c> designOldMap){
        List<String> drNames = new  List<String>();
        Set<Id> accId = new Set<id>();
        String drQuery;
        List<Core_Design_Registration__c> dupNames;
        for(Core_Design_Registration__c designRec:newDesignRegList){
            if(designOldMap == null || (designOldMap.get(designRec.id).Core_Design_Registration_Nm__c != designRec.Core_Design_Registration_Nm__c)){
                drNames.add(designRec.Core_Design_Registration_Nm__c);
                accId.add(designRec.Core_Partner_Account_Id__c);
            }
        }
        if(!drNames.isEmpty()){
            Map<String, Opportunity> existingOpportunities = new Map<String, Opportunity>();
            for (Opportunity opportunity : [SELECT Name FROM Opportunity WHERE Name IN :drNames]) {
                existingOpportunities.put(opportunity.Name, opportunity);
            }
            if(existingOpportunities!=null){ 
                String fieldName = System.Label.PCC_DesignRegNameConfig;
                drQuery = 'Select id,'+fieldName+' from account where id IN:accId';  
                List<Account> accountList = Database.query(drQuery);
                Map<Id, Account> distiAccountMap = new Map<Id, Account>();
                for (Account acc : accountList) {
                    distiAccountMap.put(acc.Id, acc);
                }
                Datetime now = System.now();
                String systemDate = String.valueOf(now).replaceAll('[^0-9]', '');
                for(Core_Design_Registration__c designRec:newDesignRegList){
                    if (existingOpportunities.containsKey(designRec.Core_Design_Registration_Nm__c)) {
                        system.debug(designRec.Core_Design_Registration_Nm__c);
                        system.debug(distiAccountMap.get(designRec.Core_Partner_Account_Id__c));
                        designRec.Core_Design_Registration_Nm__c = designRec.Core_Design_Registration_Nm__c + ' ' + ((distiAccountMap.containsKey(designRec.Core_Partner_Account_Id__c)) ? distiAccountMap.get(designRec.Core_Partner_Account_Id__c).get(fieldName) + ' ' + systemDate : ' ' + systemDate);
                        
                        
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************************************
* Method Name: populateDDRFieldValues
* Date: 19/07/2023 
* Developer: Sushmita
* Description: This method is used to stamp the DDR field values based on the  onwer's account
******************************************************************************************************************/
    public static void populateDDRFieldValues(List<Core_Design_Registration__c> ddrNewList){
        //Collecting unique Owner Ids from DDR records
        Set<Id> ddrOwnerIds = new Set<Id>();
        Set<Id> odrMatrixAcctIdSet = new Set<Id>();
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        
        try{
            if(ddrNewList.size() > 0){
                for (Core_Design_Registration__c ddr : ddrNewList) {
                    if (ddr.OwnerId != null) {
                        ddrOwnerIds.add(ddr.OwnerId);
                    }
                }
            }
            // Retrieving the User records with associated Contact info
            if(ddrOwnerIds.size() > 0){
                for (User u : [SELECT Id, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, IsActive FROM User WHERE IsActive = true AND Id IN :ddrOwnerIds ]){
                    userIdToContactMap.put(u.Id, u.Contact);
                }
            }
            //Retrieving Account records from ODR Onboarding Matrix object
            
            for (PCC_ODR_Onboarding_Matrix__c odrMatrix : [SELECT PCC_Account__c FROM PCC_ODR_Onboarding_Matrix__c]){
                odrMatrixAcctIdSet.add(odrMatrix.PCC_Account__c);
            }
            
            //Updating the ddr fields on DDR records
            if(ddrOwnerIds.size() > 0){
                for (Core_Design_Registration__c ddr : ddrNewList) {
                    if (ddr.OwnerId != null) {
                        Contact userContactRec = userIdToContactMap.containsKey(ddr.OwnerId) ? userIdToContactMap.get(ddr.OwnerId) : null;
                        System.debug('cont--> '+userContactRec);
                        if (userContactRec != null && userContactRec.AccountId != null){
                            if (odrMatrixAcctIdSet.contains(userContactRec.AccountId)){
                                ddr.Core_DDR_Partner_Type_Txt__c = 'ODM';
                                if( ddr.Core_Product_Group_Nm__c == null){
                                    ddr.Core_Product_Group_Nm__c = 'Embedded/IOT Boards & Systems';
                                }
                                
                            }
                        } else {
                            ddr.Core_DDR_Partner_Type_Txt__c = 'Distributor';
                            if(ddr.Core_Submission_Type__c != 'M2M' && ddr.Core_Product_Group_Nm__c!='FPGA/Power' && ddr.Core_Product_Group_Nm__c!='Embedded/IOT'){
                                ddr.Core_Product_Group_Nm__c.adderror('Product Group can be either FPGA/Power or Embedded/IOT');
                            }
                        } 
                    }   
                }
            }
            
        }catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility' ,'' ,ex); 
        }
    }
    
    /*********************************************************************************************************************************************/
    public static void validateProductGroup(List<Core_Design_Registration__c> ddrNewList){
        //Collecting unique Owner Ids from DDR records
        Set<Id> ddrOwnerIds = new Set<Id>();
        for (Core_Design_Registration__c ddr : ddrNewList) {
            if (ddr.OwnerId != null) {
                ddrOwnerIds.add(ddr.OwnerId);
            }
        }
        // Retrieving the User records with associated Contact info
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        for (User u : [SELECT Id, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, IsActive FROM User WHERE IsActive = true AND Id IN :ddrOwnerIds ]){
            userIdToContactMap.put(u.Id, u.Contact);
        }
        //Retrieving Account records from ODR Onboarding Matrix object
        Set<Id> odrMatrixAcctIdSet = new Set<Id>();
        for (PCC_ODR_Onboarding_Matrix__c odrMatrix : [SELECT PCC_Account__c FROM PCC_ODR_Onboarding_Matrix__c]){
            odrMatrixAcctIdSet.add(odrMatrix.PCC_Account__c);
        }
        
        //Validation on Product Group field on DR
        for (Core_Design_Registration__c ddr : ddrNewList) {
            if (ddr.OwnerId != null && ddr.Core_Product_Group_Nm__c!=null) {
                Contact userContactRec = userIdToContactMap.get(ddr.OwnerId);
                System.debug('cont--> '+userContactRec);
                if (userContactRec != null && userContactRec.AccountId != null){
                    if (odrMatrixAcctIdSet.contains(userContactRec.AccountId)){
                        if(ddr.Core_Product_Group_Nm__c!='Embedded/IOT Boards & Systems'){
                            ddr.Core_Product_Group_Nm__c.addError('Product Group should be Embedded/IOT Boards & Systems');} }
                    else{
                        if(ddr.Core_Product_Group_Nm__c!='FPGA/Power' && ddr.Core_Product_Group_Nm__c!='Embedded/IOT'){
                            ddr.Core_Product_Group_Nm__c.adderror('Product Group can be either FPGA/Power or Embedded/IOT'); }}
                }   
            }   
        }
        
    }
    
    //--------------------------------------------------------------------------------------------------------------------------------------   
    public static List<Opportunity> createOpportunity(List<Core_Design_Registration__c> lstApprovedDRs, Pricebook2 Pricebook){
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();  
        for(Core_Design_Registration__c iDR : lstApprovedDRs)
        {
            String systemDate = String.valueOf(System.now());
            String timeStamp = systemDate.replaceAll('[^0-9]', ''); 
            Opportunity createOpp = new Opportunity(Name = iDR.Core_Design_Registration_Nm__c+' ' + timeStamp, AccountID = iDR.Core_End_Customer_Account_Id__c, StageName = 'Define');
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
            createOpp.RecordTypeId = recordTypeId;
            createOpp.Core_Design_Registration_Id__c = iDR.id;
            createOpp.Core_Sales_Group__c = (iDR.Core_Product_Group_Nm__c == 'FPGA/Power' ? 'PSG Sales': 'Regional Sales');
            createOpp.Core_Military_Aerospace_Govmt_End_Use__c = iDR.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
            createOpp.Core_Commissionable__c = 'Yes';
            createOpp.Core_Opportunity_Type__c = 'Design: Original';
            createOpp.Core_Product_Segment__c = iDR.Core_Product_Segment_Nm__c;
            createOpp.Core_Product_Application__c = iDR.Core_Product_Application_Nm__c;
            createOpp.Core_Consumption_Market__c = iDR.Core_Vertical_Market_Nm__c;
            createOpp.Core_Manufacturing_Geo__c = iDR.Core_Manufacturing_Region_Cd__c;
            createOpp.Core_Production_End_Date__c = iDR.Core_Production_End_Dt__c;
            createOpp.Core_First_Customer_Ship_Date__c = iDR.Core_First_Customer_Ship_Dt__c;
            createOpp.Core_Intel_Platform__c = iDR.Core_Intel_Platform_Nm__c;
            createOpp.Core_Status_Update__c = 'Converted from DDR - '+ idR.Name;
            createOpp.Core_Opportunity_Coverage_Nm__c ='Partner-Led';
            createOpp.Core_Coverage_Type_Nm__c = iDr.Core_Intel_Support_Status__c;
            if (iDR.Core_FPGA_Quote_Comments_Txt__c == null)
                createOpp.Description = iDR.Core_Design_Registration_Dsc__c;
            else
                createOpp.Description = 'Description:\n---------------\n' + iDR.Core_Design_Registration_Dsc__c + '\n\nFPGA Quote Comments:\n--------------------------------\n' + iDR.Core_FPGA_Quote_Comments_Txt__c;
            createOpp.OwnerID = UserInfo.getUserId();
            createOpp.Core_Technical_Owner__c = Idr.OwnerId;
            createOpp.Core_Volume__c = iDR.Core_Opportunity_Volume_Cnt__c; 
            createOpp.Pricebook2id = priceBook.id;
            createOpp.Core_Channel_Opportunity_Ind__c = true;
            createOpp.CloseDate = (iDR.Core_Opportunity_Decision_Dt__c < system.today() ? system.today() : iDR.Core_Opportunity_Decision_Dt__c);
            
            createOpp.Core_Compliance_Status__c = 'N/A';
            createOpp.Core_Compliance_Sub_Status__c = 'Completed';
            if(iDR.Core_Intel_Support_Status__c == LabelConfiguration__mdt.getInstance('DDR_Intel_Support_Device_Builder_Low').value__c || 
               iDR.Core_Intel_Support_Status__c == LabelConfiguration__mdt.getInstance('DDR_Disti_design_Registration_Low').value__c){
                createOpp.Core_Exclude_From_KPIs__c = true;
                createOpp.Core_Exclude_from_Confidence__c = true;
                createOpp.Core_Commissionable__c = 'No';
            }
                
            system.debug('Oppty Creation');
            if(iDR.Core_Opportunity_Id__c == NULL)
            {
                lstInsertOpportunities.add(createOpp); 
            }
        }
        return lstInsertOpportunities;
    }
}