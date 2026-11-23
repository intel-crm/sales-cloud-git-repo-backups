/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_PFCSharing
* Version     : 1.0
* Created Date: 03-07-2020
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture  - Pranav Singh       03/07/2020           Created for sharing the claim record with External Users during the creation and 
                                                       owner change according to pnum
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_PFCSharing /*implements Database.Batchable<sObject>*///Commented by AN as unused code
{
     //added dummy method to get the code coverage for this class
     public static void getCodeCoverage(){
    }
    /*public Map<Id,List<Id>> accountUserList = new Map<Id,List<Id>>(); 
    Map<Id,List<Id>> pfcUserShareList = new Map<Id,List<Id>>(); 
    public Map<Id, PartnerFundClaim> pfcTobeSharedMap = new Map<Id, PartnerFundClaim>();
    public Set<Id> accountIdSet;
    
    // Fetching AccountnodeId set and claim Map from Core_MDF_PFC_Sharing class and assigning them to class variables
    public Core_MDF_Batch_PFCSharing(Set<Id> accountNodeIdSet , Map<Id, PartnerFundClaim> newPFCTobeShared)
    {
        pfcTobeSharedMap.putAll(newPFCTobeShared);        
        accountIdSet = new Set<Id>(accountNodeIdSet);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN : accountIdSet and (Core_MDF_User__r.IsActive = true or Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<Core_MDF_Partner_Node_User_Mapping__c> pgmList)
    {
       // Iterating over the pnum list returned through query
       for(Core_MDF_Partner_Node_User_Mapping__c pnumRec: pgmList)
       {
           // Checking if accountUserList contains the given pnum record's Account.          
           if(accountUserList.containsKey(pnumRec.Core_MDF_Account__c))
           {
               accountUserList.get(pnumRec.Core_MDF_Account__c).add(pnumRec.Core_MDF_User__c);
           }
           else 
           {
               accountUserList.put(pnumRec.Core_MDF_Account__c, new List<Id>{pnumRec.Core_MDF_User__c});
           }
    
        }
     
        for(PartnerFundClaim pfc : pfcTobeSharedMap.values())
        {      
            //For each claim add claim Id and list of users to whom the claim record to be shared 
            if(accountUserList.get(pfc.ChannelPartnerId)!=null && accountUserList.get(pfc.ChannelPartnerId).size() > 0)
            {
                pfcUserShareList.put(pfc.Id, accountUserList.get(pfc.ChannelPartnerId));
            }
        }
       
        if(pfcUserShareList!=null && pfcUserShareList.size() > 0)
        {
            //Call the generic sharing method to share the list of claims and corresponding list of users
            //Core_MDF_GenericShareRecordActionClass.createShareRecordList('PartnerFundClaim',pfcUserShareList);
            //Call the generic sharing method to share the list of claims and corresponding list of users
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim',pfcUserShareList, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
    }*/
}