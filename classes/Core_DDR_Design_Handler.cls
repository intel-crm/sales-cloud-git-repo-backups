/****************************************************************************************************
    Apex Class Name : Core_DDR_Design_Handler
    Version         : 1.0 
    Created Date    : 09/14/2017
    Function        : Handler class for the trigger 'Core_DDR_Design_Trigger'
    Modifications   :
    *****************************************************************************************************
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rajadinakaran             09/14/2017             Created
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
    
    public static string DR_LI_STATUS_APPROVED = 'Approved';
    public static string DR_LI_STATUS_PENDING = 'Pending';
    public static string PRICEBOOK_NAME = 'Partner Price Book';
    
    public static void populatePartnerAccount(List<Core_Design_Registration__c> lstDesignReg)
    {
        User loginUser = [SELECT id, Name, Contact.Account.Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];   
        List<Core_Design_Registration__c> lstUpdateDesignReg = new List<Core_Design_Registration__c>();
        
        try
        {
            for(Core_Design_Registration__c iDR : lstDesignReg)
            {
                //update partner account value based on the login distributor
                if(iDR.Core_Partner_Account_Id__c == NULL && loginUser.Contact.Account.Id != NULL)
                {
                    Core_Design_Registration__c objDesign = new Core_Design_Registration__c(Id = iDR.Id);
                    objDesign.Core_Partner_Account_Id__c = loginUser.Contact.Account.Id;
                    
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
    
    public static void processBeforeInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, 
    Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap, User loginUser)
    {
    /*    
        Set<Id> setDistiAccountIds = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Core_Location_To_Approver_Group_Mapping__c> lstISRMappings = new List<Core_Location_To_Approver_Group_Mapping__c>();
        
        Map<String, String> mapISRCityTOGroupName = new Map<String, String>();
        Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
        Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
        
        String GroupName;
        
        try
        {
            for(Core_Design_Registration__c iDR : newList)
            {
                //update partner account value based on the login distributor
                if(iDR.Core_Partner_Account_Id__c == NULL && loginUser.Contact.Account.Id != NULL)
                {
                    iDR.Core_Partner_Account_Id__c = loginUser.Contact.Account.Id;
                }
                
                setDistiAccountIds.add(iDR.Core_Partner_Account_Id__c);
            }
            
            
            lstAccount = [SELECT id, Name, BillingState, BillingCountry FROM Account WHERE Id IN: setDistiAccountIds];        
            
            lstISRMappings = Core_Location_To_Approver_Group_Mapping__c.getAll().values();
            
            //create a map of ISR location and group name              
            for(Core_Location_To_Approver_Group_Mapping__c iISRMap : lstISRMappings)
            {
                if(iISRMap.Core_State_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
                else if(iISRMap.Core_Country_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
            }    
            
            
            for(Account iAcc : lstAccount)
            {
                mapAccountToBillingState.put(iAcc.Id, iAcc.BillingState);
                mapAccountToBillingCountry.put(iAcc.Id, iAcc.BillingCountry);
            }
            
            
            //get group name based on the DR's distributor account
            for(Core_Design_Registration__c iDR : newList)
            {
                if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                {
                    iDR.Core_Approver_Grp_Nm__c = mapISRCityTOGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                }
                else if(mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                {
                    iDR.Core_Approver_Grp_Nm__c = mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c);
                }
                else
                {
                    iDR.Core_Approver_Grp_Nm__c = 'Core_Design_Approver_Catch_All';
                }
                
            }
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processBeforeInsert->'+myMsg);        
        }
    */    
    }   
    
    public static void processAfterInsert(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, 
    Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        populatePartnerAccount(newList);
        
        designRegShare((List<Core_Design_Registration__c>) oldList, (List<Core_Design_Registration__c>) newList);
    } 
    
    public static void processBeforeUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, 
    Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap, User loginUser)
    {
     /*   
        Set<Id> setDistiAccountIds = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Core_Location_To_Approver_Group_Mapping__c> lstISRMappings = new List<Core_Location_To_Approver_Group_Mapping__c>();
        
        Map<String, String> mapISRCityTOGroupName = new Map<String, String>();
        Map<Id, String> mapAccountToBillingState = new Map<Id, String>();
        Map<Id, String> mapAccountToBillingCountry = new Map<Id, String>();
        
        String GroupName;
        
        try
        {
            for(Core_Design_Registration__c iDR : newList)
            {
                //update partner account value based on the login distributor
                if(iDR.Core_Partner_Account_Id__c == NULL && loginUser.Contact.Account.Id != NULL)
                {
                    iDR.Core_Partner_Account_Id__c = loginUser.Contact.Account.Id;
                }
                
                setDistiAccountIds.add(iDR.Core_Partner_Account_Id__c);
            }
            
            
            lstAccount = [SELECT id, Name, BillingState, BillingCountry FROM Account WHERE Id IN: setDistiAccountIds];        
            
            lstISRMappings = Core_Location_To_Approver_Group_Mapping__c.getAll().values();
            
            //create map of ISR location and group name              
            for(Core_Location_To_Approver_Group_Mapping__c iISRMap : lstISRMappings)
            {
                if(iISRMap.Core_State_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_State_Cd__c + iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
                else if(iISRMap.Core_Country_Cd__c != NULL)
                {
                    mapISRCityTOGroupName.put(iISRMap.Core_Country_Cd__c,iISRMap.Core_Approver_Group_Nm__c);
                }
            }    
            
            
            for(Account iAcc : lstAccount)
            {
                mapAccountToBillingState.put(iAcc.Id, iAcc.BillingState);
                mapAccountToBillingCountry.put(iAcc.Id, iAcc.BillingCountry);
            }
            
            //get group name based on the DR's distributor account
            for(Core_Design_Registration__c iDR : newList)
            {
                if(mapAccountToBillingState.containsKey(iDR.Core_Partner_Account_Id__c) && mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                {
                    iDR.Core_Approver_Grp_Nm__c = mapISRCityTOGroupName.get(mapAccountToBillingState.get(iDR.Core_Partner_Account_Id__c) + mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c));
                }
                else if(mapAccountToBillingCountry.containsKey(iDR.Core_Partner_Account_Id__c))
                {
                    iDR.Core_Approver_Grp_Nm__c = mapAccountToBillingCountry.get(iDR.Core_Partner_Account_Id__c);
                }
                else
                {
                    iDR.Core_Approver_Grp_Nm__c = 'Core_Design_Approver_Catch_All';
                }
                
            }  
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('processBeforeUpdate->'+myMsg);         
        }      
    */    
    }
    
    public static void checkForExportCompliance(List<Core_Design_Registration__c> lstDesignReg)
    {
    
    system.debug('***lstDesignReg'+lstDesignReg);
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplBlk = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegToupdateExportComplUnBlk = new List<Core_Design_Registration__c>();

        lstDesignReg = [SELECT id, Name, Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c, Core_Design_Registration_Status_Nm__c, Core_End_Customer_Export_Cmplnc_Bloc_Ind__c FROM Core_Design_Registration__c WHERE Id IN: lstDesignReg];

        for(Core_Design_Registration__c iDesignReg : lstDesignReg)
        {
        system.debug('***lstDesignReg'+iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c);
                system.debug('***lstDesignReg'+Approval.isLocked(iDesignReg.Id));

            if(iDesignReg.Core_End_Customer_Account_Id__r.Core_Export_Compliance_Block__c == TRUE && iDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c != TRUE)
            {
                
                Core_Design_Registration__c tDesignReg = new Core_Design_Registration__c(Id = iDesignReg.Id);
                tDesignReg.Core_End_Customer_Export_Cmplnc_Bloc_Ind__c = TRUE;
                
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
            Approval.Lock(lstDesignRegToupdateExportComplblk);
            
            List<Core_Design_Registration_Product__c> lstDesignRegProdToupdateExportComplBlk = new List<Core_Design_Registration_Product__c>();
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplblk];
            system.debug('lstDesignRegProdToupdateExportComplBlk'+lstDesignRegProdToupdateExportComplBlk);
            if(lstDesignRegProdToupdateExportComplBlk.size() > 0)
            {
                Approval.Lock(lstDesignRegProdToupdateExportComplBlk);            
            }
        }
        
        if(lstDesignRegToupdateExportComplUnBlk.size() > 0)
        {
            update lstDesignRegToupdateExportComplUnBlk;    
            Approval.unLock(lstDesignRegToupdateExportComplUnBlk);
            
            List<Core_Design_Registration_Product__c> lstDesignRegProdToupdateExportComplBlk = new List<Core_Design_Registration_Product__c>();
            lstDesignRegProdToupdateExportComplBlk = [SELECT id, Name FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c  IN: lstDesignRegToupdateExportComplUnBlk];
                        system.debug('lstDesignRegProdToupdateExportComplBlk'+lstDesignRegProdToupdateExportComplBlk);

            if(lstDesignRegProdToupdateExportComplBlk.size() > 0)
            {
                Approval.unLock(lstDesignRegProdToupdateExportComplBlk);            
            }        
        }
        
    
    }
    
    public static void processAfterUpdate(List<Core_Design_Registration__c> oldList, List<Core_Design_Registration__c> newList, 
    Map<Id,Core_Design_Registration__c> oldMap, Map<Id,Core_Design_Registration__c> newMap)
    {
        
        List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();   
        List<Opportunity> lstUpdateOpportunities = new List<Opportunity>();   
        
        
        List<Id> DDRids = new list<Id>();
        Id userId = Userinfo.getUserId();
        
        Pricebook2 priceBook;
        
        try
        {
        
        //Check for export compliance
        List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
        for(Core_Design_Registration__c iDR : newList)
        {
            if(oldMap.get(iDR.Id).Core_End_Customer_Account_Id__c != newMap.get(iDR.Id).Core_End_Customer_Account_Id__c)
            {
                lstDesignRegForExportCompl.add(iDR);    
            }
        }
        
        if(lstDesignRegForExportCompl.size() > 0)
        {
            checkForExportCompliance(newList);
        }
        
            for(Core_Design_Registration__c iDR : newList)
            {
                
                if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && !(oldMap.get(iDR.Id).Core_Opportunity_Id__c != newMap.get(iDR.Id).Core_Opportunity_Id__c) && !(oldMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c != newMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c))
                {
                    lstApprovedDRs.add(iDR);
                }    
                
                if(oldMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_Submitted && newMap.get(iDR.Id).Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                {
                    DDRids.add(iDR.id);
                }
            }   
            
            if(lstApprovedDRs.size() > 0)
            {
                //lock the approved DRs
                Approval.lock(lstApprovedDRs, true);
                
                priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
                
                //prepare list of Opp to create new Opps
                for(Core_Design_Registration__c iDR : lstApprovedDRs)
                {
                    Opportunity tempOpp = new Opportunity(Name = iDR.Core_Design_Registration_Nm__c, AccountID = iDR.Core_End_Customer_Account_Id__c, StageName = 'Define', CloseDate = iDR.Core_Opportunity_Decision_Dt__c);
                    
                    tempOpp.Core_Design_Registration_Id__c = iDR.id;
                    tempOpp.Core_Sales_Group__c = (iDR.Core_Product_Group_Nm__c == 'FPGA/Power' ? 'PSG Sales': 'Regional Sales');
                    tempOpp.Core_Military_Aerospace_Govmt_End_Use__c = iDR.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
                    tempOpp.Core_Commissionable__c = 'Yes';
                    tempOpp.Core_Opportunity_Type__c = 'Design: Original';
                    tempOpp.Core_Product_Segment__c = iDR.Core_Product_Segment_Nm__c;
                    tempOpp.Core_Product_Application__c = iDR.Core_Product_Application_Nm__c;
                    tempOpp.Core_Consumption_Market__c = iDR.Core_Vertical_Market_Nm__c;
                    tempOpp.Core_Manufacturing_Geo__c = iDR.Core_Manufacturing_Region_Cd__c;
                    tempOpp.Core_Production_End_Date__c = iDR.Core_Production_End_Dt__c;
                    tempOpp.Core_First_Customer_Ship_Date__c = iDR.Core_First_Customer_Ship_Dt__c;
                    tempOpp.Core_Intel_Platform__c = iDR.Core_Intel_Platform_Nm__c;
                    tempOpp.Description = iDR.Core_Design_Registration_Dsc__c;
                    tempOpp.OwnerID = iDR.OwnerID;
                    tempOpp.Core_Technical_Owner__c = iDR.Core_Intel_Technical_Owner_Id__c!=NULL?iDR.Core_Intel_Technical_Owner_Id__c:UserInfo.getUserId();
                    tempOpp.Core_Volume__c = iDR.Core_Opportunity_Volume_Cnt__c; 
                    tempOpp.Pricebook2id = priceBook.id;
                    tempOpp.Core_Channel_Opportunity_Ind__c = true;            
                    
                    if(iDR.Core_Opportunity_Id__c == NULL)
                    {
                        lstInsertOpportunities.add(tempOpp); 
                    }
                    else
                    {
                        lstUpdateOpportunities.add(tempOpp);
                    }
                }
                
                List<id> insertOppIds = new List<id>();
                if(lstInsertOpportunities.size() > 0 || lstUpdateOpportunities.size() > 0)
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
                        lstUpdateOppInDDR.add(tempDR);
                        
                    }
                    
                    if(lstUpdateOppInDDR.size() > 0)
                    {
                        update lstUpdateOppInDDR;
                    }            
                    
                }
                
                if(lstUpdateOpportunities.size() > 0)
                {
                    insert lstUpdateOpportunities;
                    
                    for(Opportunity opp: lstUpdateOpportunities)
                    {
                        //add Opp Ids to create OLIs
                        insertOppIds.add(opp.id);
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
        }
        
    }
    
    //DR Share 
    public static void designRegShare(List<Core_Design_Registration__c> oldDesignReg, List<Core_Design_Registration__c> newDesignRegList){
        
        //Create a set for Roles
        Set<id> userRoleSet = new Set<id>();
        List<Core_Design_Registration__c> designRegRoleList = [select id, owner.UserRoleId from Core_Design_Registration__c where id IN: newDesignRegList];
        
        for(Core_Design_Registration__c designRegRole: designRegRoleList){
            userRoleSet.add(designRegRole.owner.UserRoleId);
            system.debug('Role id'+designRegRole.owner.UserRoleId);
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
            system.debug('Role id'+oppRole.owner.UserRoleId);
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
        
        List<Opportunity> lstInsertOpportunities = [select id, name, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c, Account.OwnerID, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID from Opportunity where id IN: insertOppIds];
        
        //query Partner Price Book
        priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
        
        try
        {
            for(Opportunity iOpp : lstInsertOpportunities)
            {
                mapDRIDTOOpp.put(iOpp.Core_Design_Registration_Id__c, iOpp);
            }        
            
            // Find relevant price entries
            for(PricebookEntry iPBE : [SELECT Id, UnitPrice, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id =: priceBook.id and isActive = true])
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
            }
            
            Approval.lock(lstProcessedDRLineItems, true);
            
            //add list of OLIs for OLI creation
            for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
            {
                
                if(mapDRIDTOOpp.containskey(iDRLI.Core_Design_Registration_Id__c))
                {
                    OpportunityLineItem tempOppLI = new OpportunityLineItem(OpportunityId = mapDRIDTOOpp.get(iDRLI.Core_Design_Registration_Id__c).Id);
                    
                    tempOppLI.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                    tempOppLI.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                    tempOppLI.Quantity = iDRLI.Core_Full_Year_Qty__c;
                    tempOppLI.Product2ID = iDRLI.Core_Product_Id__c;   
                    tempOppLI.PricebookEntryId = mapProductNameTOPricebookEntry.get(iDRLI.Core_Product_Id__r.Name).id;
                    
                    lstOpportunityLIs.add(tempOppLI);               
                }
            }
            
            insert lstOpportunityLIs; 
            
            List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
            
            //Update OLI Id in DRLI
            for(OpportunityLineItem iOLI : lstOpportunityLIs)
            {
                Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id);
                lstDRLIWithOLIId.add(iDRLI); 
            }
            
            update lstDRLIWithOLIId;
            
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
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = opp.id;
                    otm.TeamMemberRole = 'Team Member (100%)';
                    otm.userid = Opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerID;
                    OppTeamMember.add(otm);
                }
            }
            
            insert OppTeamMember;
            
            //Create opportunity partner using Partner account in DR 
            List<Core_Opportunity_Partner__c> Oplist = new List<Core_Opportunity_Partner__c>();
            for(Opportunity opp : lstInsertOpportunities){
                Core_Opportunity_Partner__c op = new Core_Opportunity_Partner__c(Core_Opportunity__c = opp.id, Core_Partner_Type__c = 'Distributor', Core_Partner_Role__c = 'Co-Design');
                op.Core_Partner__c = opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c;
                Oplist.add(op);
            }
            
            insert Oplist;
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('insertOppLineItems->'+myMsg);
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
        
        lstApprovedDRLineItems = [SELECT id, Name, Core_Product_Id__r.Name, Core_Target_Resale_Amt__c, Core_Full_Year_Qty__c, Core_Product_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Product_Status_Nm__c =: DR_LI_STATUS_APPROVED AND Core_Locked_Ind__c  = FALSE AND Core_Design_Registration_Id__c IN: setDRIds];
        
        try
        {
            //add list of OLIs for OLI creation
            for(Core_Design_Registration_Product__c iDRLI : lstApprovedDRLineItems)
            {
                
                OpportunityLineItem tempOppLI = new OpportunityLineItem(OpportunityId = iDRLI.Core_Design_Registration_Id__r.Core_Opportunity_Id__c);
                
                tempOppLI.Core_Design_Registration_Product_Id__c = iDRLI.Id;
                tempOppLI.UnitPrice = iDRLI.Core_Target_Resale_Amt__c;
                tempOppLI.Quantity = iDRLI.Core_Full_Year_Qty__c;
                tempOppLI.Product2ID = iDRLI.Core_Product_Id__c;   
                
                lstOpportunityLIs.add(tempOppLI);               
            }
            
            insert lstOpportunityLIs; 
            
            List<Core_Design_Registration_Product__c> lstDRLIWithOLIId = new List<Core_Design_Registration_Product__c>();
            
            //update OLI id in DR LI
            for(OpportunityLineItem iOLI : lstOpportunityLIs)
            {
                Core_Design_Registration_Product__c iDRLI = new Core_Design_Registration_Product__c(Id = iOLI.Core_Design_Registration_Product_Id__c, Core_Opportunity_Product_Id__c = iOLI.Id);
                lstDRLIWithOLIId.add(iDRLI); 
            }
            
            update lstDRLIWithOLIId;
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('@@insertApprovedLIsToExistingOpps@@'+myMsg);
        }
    }
}