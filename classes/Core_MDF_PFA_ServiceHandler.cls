/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFAServiceHandler 
* Version     : 1.0 
* Created Date: 27-11-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -    27-11-2018          Service Class for Handling Allocations and sending list of allocations for further processing
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFA_ServiceHandler{
    //public static Id budgetTypeBasedRecordTypeId = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_BudType_Based_Allocation_Record_Type').getRecordTypeId();
    public static void checkUpdatedAllocations(list<PartnerFundAllocation> allocationsUpdated, map<Id,PartnerFundAllocation> allocationsBeforeUpdate){
        
        
        Map<Id,PartnerFundAllocation> updatedAllocations = new Map<Id,PartnerFundAllocation>();
        try{
            for(PartnerFundAllocation pfaRecord: allocationsUpdated){
                PartnerFundAllocation oldPfaRecord = (PartnerFundAllocation)allocationsBeforeUpdate.get(pfaRecord.Id);
                if((pfaRecord.Amount > oldPfaRecord.Amount)){
                    updatedAllocations.put(pfaRecord.Id,pfaRecord);
                }
                
            }
        }     
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}   
        if(updatedAllocations!=null && updatedAllocations.size()>0 ) {
            Core_MDF_Process_PAF_Claim.fetchClaimsByAllocationIds(updatedAllocations.keySet());
            
        } 
        
        
    }
    /***************************************************************************************************** 
Method Name:        invokeAllocationShareRecordToGeoGroup
@return  :          void
@parameters:        List of Allocation record
Description:        This is invocable method to perform Geo Based Sharing for a Allocation record
Added By:           Accenture-VD  
Date :        04-Nov-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @InvocableMethod
    public static void invokeAllocationShareRecordToGeoGroup(List<PartnerFundAllocation> listOfPFA)
    {
        if(!Core_MDF_Utility.byPassFeature('Bypass_GeoBased_Allocation_Sharing')){
            //To share record on the basis of Channel Program and geo      
            List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
            //Getting all the account ids from Partner Marketing Budget
            List<Id> accountIds = new List<Id>();
            //to store mapping of pfa and pmb
            Map<Id,Id> pfaBudgetIdMap = new Map<Id,Id>();
            //to store mapping of pmb and its budget type
            Map<Id,String> pmbBudgetTypeMap = new Map<Id,String>();
            //Map of account id and account 
            Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
            //To store program ids
            List<Id> programIds = new List<Id>();
            //Map of channel Program id and technical program name 
            Map<Id,String> cpIdToTechProgNameMap = new Map<Id,String>();
            //map of record id and group id with which it will to be shared-VD
            Map<Id,List<Id>> allocationIdGroupIdListMap = new Map<Id,List<Id>>();
            List<String> programsIncludedBTSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Applicable_BTBased_Sharing_Prog');
            //List to story Primary partner Accounts
            List<Id> primaryAccIds = new List<Id>();
            //Map of Primary Account Id and Account
            Map<Id,Account> primaryAccIdToAccountMap = new Map<Id,Account>();
            //Map of Allocation Id and Budget ChannelPartner
            Map<Id,Id> allocIdToBudgetCpId = new Map<Id,Id>();
            set<Id> pfrIdSet = new set<Id>();
            String ACTIVATING_PARTNER = Core_MDF_CCP_ConstantClass.ACTIVATING_PARTNER ;            
            try{
                for(PartnerFundAllocation pfaRecord :listOfPFA){
                    pfrIdSet.add(pfaRecord.id);
                }
                List<PartnerFundAllocation> pfaList = [SELECT Id,ChannelPartnerId,BudgetId,Core_MDF_Budget_Type__c,ChannelPartner.Core_MDF_Partner_Type_nm__c,ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c,
                                                       Core_MDF_Program_Txt__c,Budget.Core_MDF_Budget_Partner__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c
                                                       FROM PartnerFundAllocation WHERE Id In: pfrIdSet];
               
                for(PartnerFundAllocation pfa: pfaList){
                    //Getting all the accounts from Budget List
                    accountIds.add(pfa.ChannelPartnerId);
                    pfaBudgetIdMap.put(pfa.Id,pfa.BudgetId);
                    if(pfa.Core_MDF_Budget_Type__c != 'Not Applicable'){
                        pmbBudgetTypeMap.put(pfa.BudgetId,pfa.Core_MDF_Budget_Type__c);
                    }
                    //To share allocation record to Primary account groups when allocation is created on Activating account
                    if(pfa.Core_MDF_Program_Txt__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && 
                       ((pfa.ChannelPartner.Core_MDF_Partner_Type_nm__c != NULL && pfa.ChannelPartner.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER) && pfa.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c != pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) ||
                        (pfa.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__C !=NULL &&pfa.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER)))
                      ){
                          primaryAccIds.add(pfa.Budget.Core_MDF_Budget_Partner__c);
                          allocIdToBudgetCpId.put(pfa.id,pfa.Budget.Core_MDF_Budget_Partner__c);
                      }
                }
                for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c,
                                   Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                                   Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Group_Id__c 
                                   from Account 
                                   where id IN :accountIds OR id IN :primaryAccIds]) 
                {
                    //Mapping EEF Primary accountId to account if allocation created on EEF Activating Account
                    if(!primaryAccIds.isEmpty() && primaryAccIds.contains(acc.Id)){
                        primaryAccIdToAccountMap.put(acc.id,acc);
                    }else{
                    //To get account's geo and subgeo field
                    accountIdToAccountMap.put(acc.Id,acc);
                    }
                    
                    programIds.add(acc.Core_MDF_Channel_Program__c);
                }
                //Iterating to get channel program technical program name
                for (ChannelProgram cp: [Select Id,Name,Core_MDF_Technical_Program_Name__c from ChannelProgram 
                                         where id IN :programIds]) {
                                             cpIdToTechProgNameMap.put(cp.Id,cp.Name);
                                         }
             /* for(PartnerMarketingBudget pmb : [Select Id, Core_MDF_Budget_Type_Txt__c from PartnerMarketingBudget 
                                                  where Id in :pfaBudgetIdMap.values()])
                {
                    pmbBudgetTypeMap.put(pmb.Id,pmb.Core_MDF_Budget_Type_Txt__c);
                }*/
                
                for(PartnerFundAllocation pfaObj : listOfPFA){
                    Account account = accountIdToAccountMap.get(pfaObj.ChannelPartnerId);
                    //To share record on the basis of Channel Program and geo
                  /*  if(cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c)== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name') || 
                       cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c)== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name'))*/
                     if(programsIncludedBTSharing.contains(cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c)))
                        
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfaObj.id,account.Core_Geo__c,account.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c), pmbBudgetTypeMap.get(pfaBudgetIdMap.get(pfaObj.id))));
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfaObj.id,account.Core_Geo__c,account.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c), pmbBudgetTypeMap.get(pfaBudgetIdMap.get(pfaObj.id)), account.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }
                    else
                    {
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfaObj.id,account.Core_Geo__c,account.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c))); 
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfaObj.id,account.Core_Geo__c,account.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c), account.Core_MDF_CoMarketing_Ultimate_Account__c));
                    }
                    //to share allocation record with account group - VD
                    
                    if(accountIdToAccountMap.containskey(pfaObj.ChannelPartnerId) && accountIdToAccountMap.get(pfaObj.ChannelPartnerId).Core_MDF_Channel_Program__c != Null 
                       && accountIdToAccountMap.get(pfaObj.ChannelPartnerId).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null 
                       && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(accountIdToAccountMap.get(pfaObj.ChannelPartnerId).Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)                   
                       && accountIdToAccountMap.get(pfaObj.ChannelPartnerId).Core_MDF_Group_Id__c != Null)
                    {
                        allocationIdGroupIdListMap.put(pfaObj.Id, new List<Id>{accountIdToAccountMap.get(pfaObj.ChannelPartnerId).Core_MDF_Group_Id__c});
                    } 
                    //To share allocation record to Primary account groups when allocation is created on Activating account
                    if(pfaObj.Core_MDF_Program_Txt__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && allocIdToBudgetCpId.containsKey(pfaObj.id) &&
                       primaryAccIdToAccountMap.containsKey(allocIdToBudgetCpId.get(pfaObj.id))
                      ){
                          Account acc = primaryAccIdToAccountMap.get(allocIdToBudgetCpId.get(pfaObj.id));
                          recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfaObj.id,acc.Core_Geo__c,acc.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(acc.Core_MDF_Channel_Program__c), pmbBudgetTypeMap.get(pfaBudgetIdMap.get(pfaObj.id))));
                          recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfaObj.id,acc.Core_Geo__c,acc.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(acc.Core_MDF_Channel_Program__c), pmbBudgetTypeMap.get(pfaBudgetIdMap.get(pfaObj.id)), acc.Core_MDF_CoMarketing_Ultimate_Account__c));
                      }
                }  
                //To share record on the basis of Channel Program and geo
                if(recordGeoShareList!=null && recordGeoShareList.size()>0){
                    Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerFundAllocation',recordGeoShareList);
                }
                // to share the allocation to the respective Group
                if(recordPGMShareList != null && recordPGMShareList.size() >0){
                    Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerFundAllocation', recordPGMShareList);
                }
                //To share allocation with its account group -VD  
                if(allocationIdGroupIdListMap != NULL && !allocationIdGroupIdListMap.isEmpty()){
                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundAllocation', allocationIdGroupIdListMap, 'Edit', 'Manual');
                    Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        }
    }
    
    /*****************************************************************************************************
Method Name:        sharePfaWithAccountExternalGroup
@return  :          void
@parameters:        newPfaMap - Map variable
Description:        Used to share PartnerFundAllocation records with respective Account External Group.
Added By:           Accenture - JB - 02/14/2022
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void sharePfaWithAccountExternalGroup(Map<Id,PartnerFundAllocation> newPfaMap){
        
        //Map of account Id and Group Id
        Map<Id, Id> accountIdGroupIdMap = new Map<Id, Id>();
        Map<Id,String> pfaIdToProgramNameMap = new Map<Id,String>();
        string EEF_PROG = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name');
        
        // Get the list of accounts from the map
        Set<Id> listOfAccounts = new Set<Id>();
         String ACTIVATING_PARTNER = Core_MDF_CCP_ConstantClass.ACTIVATING_PARTNER ;
                List<PartnerFundAllocation> pfaList = [SELECT Id,ChannelPartnerId,BudgetId,Core_MDF_Budget_Type__c,ChannelPartner.Core_MDF_Partner_Type_nm__c,ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c,
                                                       Core_MDF_Program_Txt__c,Budget.Core_MDF_Budget_Partner__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c
                                                       FROM PartnerFundAllocation WHERE Id In: newPfaMap.keySet()];
        for(PartnerFundAllocation pfaRecord : pfaList){
            if(String.isNotBlank(pfaRecord.ChannelPartnerId)){
                listOfAccounts.add(pfaRecord.ChannelPartnerId);
            }
            if(String.isNotBlank(pfaRecord.BudgetId) && String.isNotBlank(pfaRecord.Core_MDF_Program_Txt__c)){
                pfaIdToProgramNameMap.put(pfaRecord.Id, pfaRecord.Core_MDF_Program_Txt__c);
            }
            //To share allocation record to Primary account External group when allocation is created on Activating account
                    if(pfaRecord.Core_MDF_Program_Txt__c == EEF_PROG && 
                       ((pfaRecord.ChannelPartner.Core_MDF_Partner_Type_nm__c != NULL && pfaRecord.ChannelPartner.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER) && pfaRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c != pfaRecord.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) ||//check with ultimate acc
                        (pfaRecord.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__C !=NULL && pfaRecord.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER)))
                      ){
                          listOfAccounts.add(pfaRecord.Budget.Core_MDF_Budget_Partner__c);
                      }
            
        }
        
        //Create the mapping of Account Id to External Group Id
        for(Account accRecord : [SELECT Id, Core_MDF_External_Group_Id__c
                                 FROM Account
                                 WHERE Core_MDF_External_Group_Id__c != NULL AND Id IN :listOfAccounts]){
                                     accountIdGroupIdMap.put(accRecord.Id, accRecord.Core_MDF_External_Group_Id__c);
                                 }
        
        Map<Id,List<Id>> pfaIdGroupIdListMap = new Map<Id,List<Id>>();
        
        List<String> programsToBeExcluded = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Retail_Channel_Program_Name');
        for(PartnerFundAllocation pfa : pfaList){
            
            if(accountIdGroupIdMap.containsKey(pfa.ChannelPartnerId) && accountIdGroupIdMap.get(pfa.ChannelPartnerId) != null && (!programsToBeExcluded.contains(pfaIdToProgramNameMap.get(pfa.Id))) ){
                //Creation of PFA and Group mapping
                pfaIdGroupIdListMap.put(pfa.Id, new List<Id>{accountIdGroupIdMap.get(pfa.ChannelPartnerId)});
            }
            if(pfa.Core_MDF_Program_Txt__c == EEF_PROG && !accountIdGroupIdMap.isEmpty() && pfaIdGroupIdListMap.containsKey(pfa.Id) && accountIdGroupIdMap.containsKey(pfa.Budget.Core_MDF_Budget_Partner__c)){

                pfaIdGroupIdListMap.get(pfa.Id).add(accountIdGroupIdMap.get(pfa.Budget.Core_MDF_Budget_Partner__c));
            }
            
        }
        
        //PFA External User Sharing
        if(pfaIdGroupIdListMap != NULL && !pfaIdGroupIdListMap.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundAllocation', pfaIdGroupIdListMap, 'Edit', 'Manual');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
    
    /*****************************************************************************************************
Method Name:        sharePfaWithGroupsOnUpdate
@return  :          void
@parameters:        newPfaMap - new PFA records, oldPfa - old version records
Description:        Used to share PartnerFundAllocation records.
Added By:           Accenture - JB - 02/22/2022
Modified By:        Date:       Changes:
******************************************************************************************************/
    public static void sharePfaWithGroupsOnUpdate(Map<Id,PartnerFundAllocation> newPfaMap, List<PartnerFundAllocation> oldPfa){
        
        Map<Id,PartnerFundAllocation> pfaMap = new Map<Id,PartnerFundAllocation>();
        
        //Share records when the owner changes
        for(PartnerFundAllocation pfa : oldPfa){
            if(pfa.OwnerId != newPfaMap.get(pfa.Id).OwnerId){
                pfaMap.put(pfa.Id, pfa);
            }
        }
        
        if(pfaMap != null && !pfaMap.isEmpty()){
            if(!Core_MDF_Utility.byPassFeature('Bypass_SharePfaWithAccountExtGrp')){
                Core_MDF_PFA_ServiceHandler.sharePfaWithAccountExternalGroup(pfaMap);
            }
            if(!Core_MDF_Utility.byPassFeature('Bypass_GeoBased_Allocation_Sharing')){
                Core_MDF_PFA_ServiceHandler.invokeAllocationShareRecordToGeoGroup(pfaMap.values());
            }
        }
    }

    /*****************************************************************************************************
    Method Name:        populateUniqueField
    @return  :          void
    @parameters:        newPfaMap - new PFA records
    Description:        Used to populate unique field on Allocation to prevent duplicate records
                        All Allocation creation
                        Allocation update when the Budget or Node account field value changed
    Added By:           Accenture - JB - 28/07/2024
    Modified By:        Date:       Changes:
    ******************************************************************************************************/
    public static void populateUniqueField(List<PartnerFundAllocation> pfaList, Map<Id, PartnerFundAllocation> oldPfaMap){

        for(PartnerFundAllocation pfa : pfaList){
            if(oldPfaMap == null || (oldPfaMap != null && (pfa.BudgetId != oldPfaMap.get(pfa.Id).BudgetId || pfa.ChannelPartnerId != oldPfaMap.get(pfa.Id).ChannelPartnerId))){
                pfa.Core_MDF_BudgetIdNodeAccountId_txt__c = '' + pfa.BudgetId + pfa.ChannelPartnerId; // Budget Id, Node Account Id
            }
        }
    }
}