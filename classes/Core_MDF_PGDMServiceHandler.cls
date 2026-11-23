/****************************************************************************************************************************************
* Class Name  : Core_MDF_PGDMServiceHandler
* Version     : 1.0
* Created Date: 06-Mar-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       06-Mar-2020        Service Class for handling trigger related functions on Partner Group Domain Mapping object.
*****************************************************************************************************************************************/

public with sharing class Core_MDF_PGDMServiceHandler {
   
    // List of all remaining PGM's for one account
    public static Map<Id,List<Core_MDF_Partner_Group_Mapping__c>> acctIdPgmMap = new Map<Id,List<Core_MDF_Partner_Group_Mapping__c>>();  
    // Map of PGDM and its PGM
    public static Map<Core_MDF_Partner_Group_Domain_Mapping__c,Id> mapOfPGDMAndPGM = new Map<Core_MDF_Partner_Group_Domain_Mapping__c,Id>();
    // Map of Current PGM and Account
    public static Map<Id,Id> mapOfCurrentPGMAndAccount = new Map<Id,Id>();
    //Map of existing PGMs Id and its associated domain list
    public static Map<Id,List<String>> mapOfExistingPGMAndDomainList = new Map<Id,List<String>> ();
    //Map of accounts and domainlist associated with that account
    public static Map<Id,List<String>> mapOfAccountAndDomains = new Map<Id,List<String>>();
    
/*****************************************************************************************************
Method Name:        checkDuplicatePGDMRecords
@return  :          void
@parameters:        newPGDMList - This will contain all the pgdm records to be inserted.
Description:        Whenever a record is inserted of Partner Group Domain Mapping object,
                    this method checks whether the current domain record already present for that PGM or for other account's PGM.
                    It is is present, it will throw error.
@Added By:          Accenture - VD - 13-Mar-2020
Modified By:        Date:       Changes:
******************************************************************************************************/    
    public static void checkDuplicatePGDMRecords(List<Core_MDF_Partner_Group_Domain_Mapping__c> newPGDMList) {                 
        try{                         
            for(Core_MDF_Partner_Group_Domain_Mapping__c pgdmRec : newPGDMList){
                //Storing PGM to get its associated accounts 
                mapOfPGDMAndPGM.put(pgdmRec,pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c);
            }
            
            //Storing PGM records in PGMlist to get account record of these PGMs. To save this query we can create a formula field on PGDM and this method in after insert
            if(mapOfPGDMAndPGM != Null && mapOfPGDMAndPGM.size() > 0){
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id,Core_MDF_Account__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Id IN : mapOfPGDMAndPGM.values()]){
                    //Map to store PGM and its Account
                    mapOfCurrentPGMAndAccount.put(pgm.Id,pgm.Core_MDF_Account__c);
                } 
            }
            
            if(mapOfCurrentPGMAndAccount != Null && mapOfCurrentPGMAndAccount.size() > 0){
                // if map is not null taking all the PGMs of that account whose type of access is external and not taking the PGM which are in newPGDMList list
                for(Core_MDF_Partner_Group_Mapping__c pgmRec : [SELECT id, Core_MDF_Account__c FROM Core_MDF_Partner_Group_Mapping__c 
                                                                WHERE Core_MDF_Account__c in : mapOfCurrentPGMAndAccount.values() 
                                                                AND Core_MDF_Type_of_Access__c =: Label.Core_MDF_External_label_for_PGM AND Id NOT IN : mapOfPGDMAndPGM.values() 
                                                                AND (Core_MDF_CoMarketingActive_Ind__c = true OR Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c = true)]){
                    //Map to store all the PGM records of that account of External type to create PGDM records for these PGMs of same account
                    if(acctIdPgmMap.containsKey(pgmRec.Core_MDF_Account__c)){
                        acctIdPgmMap.get(pgmRec.Core_MDF_Account__c).add(pgmRec);
                    }
                    else{
                        acctIdPgmMap.put(pgmRec.Core_MDF_Account__c, new List<Core_MDF_Partner_Group_Mapping__c>{pgmRec});
                    }                       
                }
            }
            
            for(Core_MDF_Partner_Group_Domain_Mapping__c existingPgdm : [SELECT Name, Core_MDF_Partner_Group_Mapping_Id__c, Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Account__c 
                                                                        from Core_MDF_Partner_Group_Domain_Mapping__c LIMIT 1000]){
                
                //Map to store all the existing domains record of the account, which we'll use to check if that domain record exist for that account or any other account
                if(mapOfAccountAndDomains.containsKey(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Account__c)){
                    mapOfAccountAndDomains.get(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Account__c).add(existingPgdm.Name);
                }
                else{
                    mapOfAccountAndDomains.put(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Account__c, new List<String>{existingPgdm.Name});
                } 
                
                //Map of existing PGM and domainlist, which we have used in duplicate check to get domain records for that PGM
                if(mapOfExistingPGMAndDomainList.containsKey(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__c)){
                    mapOfExistingPGMAndDomainList.get(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__c).add(existingPgdm.Name);
                }
                else{
                    mapOfExistingPGMAndDomainList.put(existingPgdm.Core_MDF_Partner_Group_Mapping_Id__c, new List<String>{existingPgdm.Name});
                }               
            }
            
            for(Core_MDF_Partner_Group_Domain_Mapping__c pgdmRec : newPGDMList){
                if(mapOfCurrentPGMAndAccount.containsKey(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c)
                   && mapOfAccountAndDomains != Null && mapOfAccountAndDomains.size() > 0){                
                       for(Id accountId : mapOfAccountAndDomains.keySet()){                    
                           if(accountId != mapOfCurrentPGMAndAccount.get(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c) 
                              && mapOfAccountAndDomains.get(accountId).contains(pgdmRec.Name)){
                               //Adding error if that domain record already exist for some other account
                               pgdmRec.addError(Label.Core_MDF_PGDMDuplicateError);                           
                           }                      
                           else if(accountId == mapOfCurrentPGMAndAccount.get(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c) 
                                   && mapOfAccountAndDomains.get(accountId).contains(pgdmRec.Name)
                                   && mapOfExistingPGMAndDomainList.containsKey(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c)
                                   && mapOfExistingPGMAndDomainList.get(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c).contains(pgdmRec.Name)){
                                       //Adding error if that domain already exists for that PGM record on same account
                                       pgdmRec.addError(Label.Core_MDF_PGDMDuplicateError);
                                   }
                       }
                   }
            }
            
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }  
    }

    
/*****************************************************************************************************
Method Name:        insertDomainRecordsForOtherPGMs
@return  :          void
Description:        Whenever a domain record is created for one PGM, it will create PGDM records for other PGMs 
                    of external type of that account.
@Added By:          Accenture - VD - 13-Mar-2020
Modified By:        Date:       Changes:
******************************************************************************************************/    
    public static void insertDomainRecordsForOtherPGMs(List<Core_MDF_Partner_Group_Domain_Mapping__c> newPGDMList){
        
        // List of New PGDM records to be inserted
        List<Core_MDF_Partner_Group_Domain_Mapping__c> pgdmList = new List<Core_MDF_Partner_Group_Domain_Mapping__c>();
        
        for(Core_MDF_Partner_Group_Domain_Mapping__c pgdmRec : newPGDMList){
            if(mapOfCurrentPGMAndAccount.containsKey(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c)
               && acctIdPgmMap.containsKey(mapOfCurrentPGMAndAccount.get(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c))){ 
                   // Creating domain records for other PGMs of same account
                   for(Core_MDF_Partner_Group_Mapping__c pgmInst : acctIdPgmMap.get(mapOfCurrentPGMAndAccount.get(pgdmRec.Core_MDF_Partner_Group_Mapping_Id__c))){
                       //Restricting creation of domain records for the pGMs which already exists                    
                       if(!(mapOfExistingPGMAndDomainList.containsKey(pgmInst.Id)
                            && mapOfExistingPGMAndDomainList.get(pgmInst.Id).contains(pgdmRec.Name))){
                                //creating objects to create new PGDM records for other PGMs of that account
                                Core_MDF_Partner_Group_Domain_Mapping__c pgdm = new Core_MDF_Partner_Group_Domain_Mapping__c();
                                pgdm.Core_MDF_Partner_Group_Mapping_Id__c = pgmInst.id;
                                pgdm.Name = pgdmRec.Name;
                                pgdmList.add(pgdm);  
                            }                                           
                   }
               }
        }
        if(pgdmList != Null && pgdmList.size() > 0){
            //inserting domain records for other PGMs
            Database.insert(pgdmList);
        }
    }
}