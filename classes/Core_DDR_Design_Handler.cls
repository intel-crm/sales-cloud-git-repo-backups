/****************************************************************************************************
    Apex Class Name : Core_DDR_Design_Handler
    Version         : 1.0 
    Created Date    : 09/14/2017
    Function        : Handler class for the trigger 'Core_DDR_Design_Trigger'
    Modifications   :
    *****************************************************************************************************
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rajadinakaran               09/14/2017             Created
    * Suresh Palvadi              09/25/2017             Added methods to create Opportunity Line Items 
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
    
    public static void processBeforeInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap, User loginUser)
    {
        
    }
    
    public static void processAfterInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        populatePartnerAccount(newList);        
        designRegShare((List<Core_Design_Registration__c>) newList);
    }
    
    public static void processAfterUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {        
        List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();   
        List<Core_Design_Registration__c> lstRejectedDesigns = new List<Core_Design_Registration__c>();        
        List<Core_Design_Registration__c> lstDesignsForGroupName = new List<Core_Design_Registration__c>();        
        
        List<Id> DDRids = new list<Id>();
        Id userId = Userinfo.getUserId();
        
        Pricebook2 priceBook;
        
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();

        try
        {            
            //Check for export compliance
            List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
            
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
                }
            }            
            
            //To populate the partner account and share the design based on owner field
            if(lstDesignRegForSharing.size() > 0)
            {system.debug(lstDesignRegForSharing);
                populatePartnerAccount(lstDesignRegForSharing);
                designRegShare(lstDesignRegForSharing);
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
                
                if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_Submitted && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                {
                    DDRids.add(iDR.id);
                }
                
                //Lock the rejected line items after header is locked
                if((oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_SUBMITTED || oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_RESUBMITTED)&& newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED)
                {
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
                for(Core_Design_Registration__c iDR : lstApprovedDRs)
                {
                    Opportunity createOpp = new Opportunity(Name = iDR.Core_Design_Registration_Nm__c, AccountID = iDR.Core_End_Customer_Account_Id__c, StageName = 'Define');
                    
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
                    if (iDR.Core_FPGA_Quote_Comments_Txt__c == null)
                    createOpp.Description = iDR.Core_Design_Registration_Dsc__c;
                    else
                    createOpp.Description = 'Description:\n---------------\n' + iDR.Core_Design_Registration_Dsc__c + '\n\nFPGA Quote Comments:\n--------------------------------\n' + iDR.Core_FPGA_Quote_Comments_Txt__c;
                    createOpp.OwnerID = iDR.OwnerID;
                    createOpp.Core_Technical_Owner__c = iDR.Core_Intel_Technical_Owner_Id__c!=NULL?iDR.Core_Intel_Technical_Owner_Id__c:UserInfo.getUserId();
                    createOpp.Core_Volume__c = iDR.Core_Opportunity_Volume_Cnt__c; 
                    createOpp.Pricebook2id = priceBook.id;
                    createOpp.Core_Channel_Opportunity_Ind__c = true;
                    createOpp.CloseDate = (iDR.Core_Opportunity_Decision_Dt__c < system.today() ? system.today() : iDR.Core_Opportunity_Decision_Dt__c);
                    
                    if(iDR.Core_Opportunity_Id__c == NULL)
                    {
                        lstInsertOpportunities.add(createOpp); 
                    }
                }

                List<id> insertOppIds = new List<id>();
                if(lstInsertOpportunities.size() > 0)
                {
                    insert lstInsertOpportunities;
                    OpportunityShare(lstInsertOpportunities);
                    
                    List<Core_Design_Registration__c> lstUpdateOppInDDR = new List<Core_Design_Registration__c>();
                    
                    for(Opportunity opp: lstInsertOpportunities)
                    {
                        //add Opp Ids to create OLIs
                        insertOppIds.add(opp.id);
                        
                        //add Opp Id to DR to update the opportunity lookup in DR
                        Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                        
                        tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                        
                        lstUpdateOppInDDR.add(tempDR);                        
                    }
                    
                    if(lstUpdateOppInDDR.size() > 0)
                    {
                        update lstUpdateOppInDDR;
                    }
                }                
                
                //Call OLI creation future method
                if(insertOppIds.size() > 0)
                {  
                    insertOppLineItems(insertOppIds, DDRids);  
                }
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
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);
                insert ExcepLog;
            }
        }
        
    }
    
    public static void populatePartnerAccount(List<Core_Design_Registration__c> lstDesignReg)
    {
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
                update lstUpdateDesignReg;
            }
            
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processBeforeInsert->'+myMsg);        
        }    
    }
    
    public static void updateGroupName(List<Core_Design_Registration__c> lstDesignRegistrations)
    {
        List<Core_Location_To_Approver_Group_Mapping__c> lstISRMappings = new List<Core_Location_To_Approver_Group_Mapping__c>();
        lstISRMappings = Core_Location_To_Approver_Group_Mapping__c.getAll().values();
        Set<Id> setDistiAccountIds = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Core_Design_Registration__c> lstUpdDesigns = new List<Core_Design_Registration__c>();
        
        Map<String,String>  mapFPGA_ISRCityToGroupName = new Map<String,String>();      
        Map<String,String>  mapEmbedded_IOT_ISRCityToGroupName = new Map<String,String>(); 
        
        Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
        Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
        try
        {        
            for(Core_Location_To_Approver_Group_Mapping__c iISRMap : lstISRMappings)
            {
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
                    else if(iISRMap.Core_Product_Group_Nm__c == 'Embedded/IOT')
                    {
                        if(iISRMap.Core_State_Cd__c != NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        }
                        else if(iISRMap.Core_Country_Cd__c != NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                        } 
                        else if(iISRMap.Core_State_Cd__c == NULL && iISRMap.Core_Country_Cd__c == NULL)
                        {
                            mapEmbedded_IOT_ISRCityToGroupName.put('All',iISRMap.Core_Approver_Group_Nm__c);
                        }
                    }
                }
            } 
            
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
                else if(iDR.Core_Product_Group_Nm__c == 'Embedded/IOT')
                {
                    if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
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
                else if(groupDesign.Core_Approver_Grp_Nm__c == NULL && iDR.Core_Product_Group_Nm__c == 'Embedded/IOT')
                {
                    groupDesign.Core_Approver_Grp_Nm__c = mapEmbedded_IOT_ISRCityToGroupName.get('All');
                }
                
                lstUpdDesigns.add(groupDesign);
            }  
            
            if(lstUpdDesigns.size() > 0)
            {
                update lstUpdDesigns;
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
        List<Core_Design_Registration__c> designRegRoleList = [select id, owner.UserRoleId from Core_Design_Registration__c where id IN: newDesignRegList];
        
        for(Core_Design_Registration__c designRegRole: designRegRoleList){
            userRoleSet.add(designRegRole.owner.UserRoleId);
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
            designRoleShr.UserOrGroupId = roleAndGroupMap.get(designShr.owner.UserRoleId);//'00Gg0000002taQY';
            
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
        
        //Create a set for Roles
        Set<id> userRoleSet = new Set<id>();
        List<Opportunity> oppRoleList = [select id, owner.UserRoleId from Opportunity where id IN: newOppList];
        
        for(Opportunity oppRole: oppRoleList){
            userRoleSet.add(oppRole.owner.UserRoleId);
        }
        
        //Get the Group Id
        List<Group> roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: userRoleSet and type = 'role'];
        
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        
        for(group grp: roleGroup){
            roleAndGroupMap.put(grp.RelatedId, grp.id);
        }
        
        // Create a new list of sharing objects for Design Registration
        List<OpportunityShare> oppShrs  = new List<OpportunityShare>();
        
        // Declare variables for Design Registration sharing
        OpportunityShare oppRoleShr;
        
        for(Opportunity oppShr : oppRoleList){
            
            oppRoleShr = new OpportunityShare(); // Instantiate the sharing objects
            
            oppRoleShr.OpportunityId = oppShr.Id; // Set the ID of record being shared
            oppRoleShr.UserOrGroupId = roleAndGroupMap.get(oppShr.owner.UserRoleId); // Set the ID of user or group being granted access
            oppRoleShr.OpportunityAccessLevel = 'edit'; // Set the access level
            oppRoleShr.RowCause = 'Manual'; // Set the Apex sharing 
            oppShrs.add(oppRoleShr);
        }
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(oppShrs,false);
    }
    
    //Suresh 09/25/2017-To create the Opportunity Line Items after approval (Opportunity before trigger causing too many SOQL queries, so written this method as FUTURE)
    @future 
    public static void insertOppLineItems(List<id> insertOppIds, List<id> DDRids) 
    {
        Pricebook2 priceBook;
        List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
        List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstDRLineItems = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstProcessedDRLineItems = new List<Core_Design_Registration_Product__c>();
        
        Map<string, PriceBookEntry> mapProductNameTOPricebookEntry = new map<string, PriceBookEntry>();
        Map<Id, Opportunity> mapOppIdTOOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapDRIDTOOpp = new Map<Id, Opportunity>();     
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        
        List<Opportunity> lstInsertOpportunities = [select id, name, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c, Account.OwnerID, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID from Opportunity where id IN: insertOppIds];
        
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
            
            lstDRLineItems = [SELECT id, Name, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c, 
                Core_Product_Id__c, Core_Full_Year_Qty__c, Core_Target_Resale_Amt__c 
                FROM Core_Design_Registration_Product__c 
            WHERE Core_Design_Registration_Id__c IN: DDRids];
            
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
                    
                    lstOpportunityLIs.add(createOppLineItem);               
                }
            }
            List<Core_Log_Entry__c> logEntriesOppLineItems = new List<Core_Log_Entry__c>();
            
            if(!lstOpportunityLIs.isEmpty())
            {  
                Database.SaveResult[] lstDesignProductUpdate = Database.insert(lstOpportunityLIs, false);         
                for (Database.SaveResult sr : lstDesignProductUpdate)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntriesOppLineItems.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntriesOppLineItems.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineInsertLogEntry, Core_Severity__c = Log_Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
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
            
            //Update OLI Id in DRLI
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
                if(!mapTeamMemberIdOpportunityId.containskey(Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID))
                {
                    OpportunityTeamMember createOppTeamMember = new OpportunityTeamMember();
                    createOppTeamMember.OpportunityId = opp.id;
                    createOppTeamMember.TeamMemberRole = 'Team Member (100%)';
                    createOppTeamMember.userid = Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID;
                    OppTeamMember.add(createOppTeamMember);
                }
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
            if(!logEntriesOppPartner.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert logEntriesOppPartner;
                }
            }
        }
        catch(Exception e)
        {
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
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
            
            if(setDRIds.size() > 0)
            {
                //Call future method to create OLI
                insertApprovedLIsToExistingOpps(setDRIds);
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
        List<OpportunityLineItem> lstOpportunityLIs = new List<OpportunityLineItem>();
        List<Core_Design_Registration_Product__c> lstApprovedDRLineItems = new List<Core_Design_Registration_Product__c>();
        
        lstApprovedDRLineItems = [SELECT id, Name, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c FROM Core_Design_Registration_Product__c WHERE Core_Locked_Ind__c  = FALSE AND Core_Design_Registration_Id__c IN: setDRIds];           
        
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
                    
                    lstOpportunityLIs.add(createOppLineItem);
                }
            }
            update lstApprovedDRLineItems; //added by suresh
            
           // Approval.lock(lstApprovedDRLineItems, true); //added by suresh
            
            if(!lstOpportunityLIs.isEmpty())
            {  
                Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstOpportunityLIs, false);         
                for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                {                    
                    if (!sr.isSuccess())
                    {
                        for(Database.Error err : sr.getErrors())
                        {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Severity, Core_When__c=System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else if(sr.isSuccess())
                    {
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess, Core_Origin__c = OppLineUpdateLogEntry, Core_Severity__c = Log_Severity, Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
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
}