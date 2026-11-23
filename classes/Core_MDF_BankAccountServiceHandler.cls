/****************************************************************************************************************************************
* Class Name        : Core_MDF_BankAccountServiceHandler
* Created Date      : 24-11-2018
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Sridhar      24/11/2018          Service Class to handle the bank and bank account mapping sharing to external users when use map the bank 
to account. External budget admin dosent have access to delete the share records so using the default 
sharing option(without sharing)
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BankAccountServiceHandler 
{
    
    private static String manual = 'Manual';
    public static Map<Id, String> abmIdErrorStringMap = new Map<Id, String>();
    /***************************************************************************************************** 
    Method Name:        shareBankAndABMRecordsWithExternalUsers
    @return  :          Viod
    @parameters:        newBankAccountMap - Map variable 
    Description:        Call out the bank and bank account map sharing methods
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void shareBankAndABMRecordsWithExternalUsers(Map<Id,Core_MDF_Account_Bank_Mapping__c> newBankAccountMap)
    {        
        try {
            // Map to store banks and users to whom it should be shared
            Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>(); 
            Map<Id,List<Id>> bankMapIdUserIdListMap = new Map<Id,List<Id>>();
            
            // Get the bank and its users Map
            bankIdUserIdListMap = buildBankUsersMap(newBankAccountMap.values(),'bank');
            
            // Call the generic share record class and share the bank records
            if(bankIdUserIdListMap.size() > 0){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Bank__c',bankIdUserIdListMap);
            }
            
            // Get the bank and its users Map
            bankMapIdUserIdListMap = buildBankUsersMap(newBankAccountMap.values(),'bankaccount');
            
            // Call the generic share record class and share the bank account map records
            if(bankMapIdUserIdListMap.size() > 0){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Account_Bank_Mapping__c',bankMapIdUserIdListMap);
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}        
    }
    
    /***************************************************************************************************** 
    Method Name:        buildBankUsersMap
    @return  :          Map<Bank,list<Users>>
    @parameters:        accountBankMap - bank mapping records, type - String (Bank or Bank Map)
    Description:        get all the accounts and list of users
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<Id,List<Id>> buildBankUsersMap(List<Core_MDF_Account_Bank_Mapping__c> accountBankMap, String type)
    {
        Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>(); // Map to store banks and users to whom it should be shared
        // list to store all the accounts from the trigger
        List<Id> listOfAccounts = new List<Id>();
        
        // Get the list of accounts from the map 
        listOfAccounts = loadAccounts(accountBankMap);
        
        // Proceed to share the banks to the users only if there is valid users and baks exists
        bankIdUserIdListMap = loadBankIdUserIdListMap(listOfAccounts, type, accountBankMap);
        return bankIdUserIdListMap;
    }
    
    /***************************************************************************************************** 
    Method Name:        loadBankIdUserIdListMap
    @return  :          Map<Bank,list<Users>>
    @parameters:        accountBankMap - bank mapping records, type - String (Bank or Bank Map)
    Description:        get all the accounts and list of users
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static Map<Id,List<Id>> loadBankIdUserIdListMap(List<Id> listOfAccounts, String type,List<Core_MDF_Account_Bank_Mapping__c> accountBankMap)
    {
        // Map to store account and its list of users
        Map<Id,List<Id>> accountIdUserIdListMap = new Map<Id,List<Id>>(); 
        // Map to store all the accounts and its banks
        Map<Id,List<Id>> accountIdBankIdListMap = new Map<Id,List<Id>>(); 
        Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>();
        
        // Load the accounts and its users into the accountIdUserIdListMap variable  
        accountIdUserIdListMap = loadAccountsUsers(listOfAccounts);    
        
        if (type == 'bank')
        {
            // Load the accounts and its banks into the accountIdBankIdListMap variable 
            accountIdBankIdListMap = loadAccountBanks(accountBankMap);
        }
        else if (type == 'bankaccount'){
            // Load the accounts and its bank account map into the accountIdBankIdListMap variable 
            accountIdBankIdListMap = loadAccountBankMaps(accountBankMap);
        }
        if(accountIdUserIdListMap.size() > 0 && accountIdBankIdListMap.size() > 0){
            for (Id bankAccountId : accountIdBankIdListMap.keySet()){
                if (accountIdUserIdListMap.containsKey(String.valueOf(bankAccountId))){
                    // Load all the banks and its users to the map
                    for (String bankId : accountIdBankIdListMap.get(bankAccountId)) {
                        
                        if(bankIdUserIdListMap.containsKey(bankId)){
                            bankIdUserIdListMap.get(bankId).addAll(accountIdUserIdListMap.get(bankAccountId));
                        }
                        else{
                            List<Id> userIdList = new List<Id>();
                            userIdList = accountIdUserIdListMap.get(bankAccountId);
                            bankIdUserIdListMap.put(bankId, userIdList);
                        }
                    }
                }
            }
        }
        
        return bankIdUserIdListMap;
    }
    
    /***************************************************************************************************** 
    Method Name:        loadAccounts
    @return  :          List<Id>
    @parameters:        accountBankNewMap - bank mapping records, type - String (Bank or Bank Map)
    Description:        get all the accounts
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static List<Id> loadAccounts(List<Core_MDF_Account_Bank_Mapping__c> accountBankNewMap)
    {
        List<Id> listOfAccounts = new List<Id>();
        for(Core_MDF_Account_Bank_Mapping__c accBankRecord : accountBankNewMap){
            if (!listOfAccounts.contains(accBankRecord.Core_MDF_Account__c))
            {
                listOfAccounts.add(accBankRecord.Core_MDF_Account__c);
            }            
        }        
        return listOfAccounts; 
    } 
    
    /***************************************************************************************************** 
    Method Name:        loadAccountsUsers
    @return  :          Map<Id,List<Id>>
    @parameters:        listOfAccounts - List of Accounts
    Description:        get all the accounts and its users
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static Map<Id,List<Id>> loadAccountsUsers(List<Id> listOfAccounts)
    {
        // Map to store account and its list of users
        Map<Id,List<Id>> accountIdUserIdListMap = new Map<Id,List<Id>>(); 
        
        for(Core_MDF_Partner_Node_User_Mapping__c pNUMappingRecord : [SELECT Core_MDF_Account__c, Core_MDF_User__c
                                                                      FROM Core_MDF_Partner_Node_User_Mapping__c
                                                                      WHERE Core_MDF_Account__c IN :listOfAccounts 
                                                                      AND Core_MDF_User__r.IsActive=true])
        {
            if(accountIdUserIdListMap.containsKey(pNUMappingRecord.Core_MDF_Account__c)){
                accountIdUserIdListMap.get(pNUMappingRecord.Core_MDF_Account__c).add(pNUMappingRecord.Core_MDF_User__c);
            }
            else{
                accountIdUserIdListMap.put(pNUMappingRecord.Core_MDF_Account__c, new List<Id>{pNUMappingRecord.Core_MDF_User__c});
            }
        }        
        return accountIdUserIdListMap;
    }
    
    /***************************************************************************************************** 
    Method Name:        loadAccountBanks
    @return  :          Map<Id,List<Id>>
    @parameters:        listOfAccounts - List of Accounts
    Description:        get all the accounts and its associated banks
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static Map<Id,List<Id>> loadAccountBanks(List<Core_MDF_Account_Bank_Mapping__c> listOfAccounts)
    {
        // Map to store all the accounts and its banks
        Map<Id,List<Id>> accountIdBankIdListMap = new Map<Id,List<Id>>(); 
        
        for(Core_MDF_Account_Bank_Mapping__c accBankRecord : listOfAccounts){
            if(accountIdBankIdListMap.containsKey(accBankRecord.Core_MDF_Account__c))
            {
                accountIdBankIdListMap.get(accBankRecord.Core_MDF_Account__c).add(accBankRecord.Core_MDF_Bank__c);
            }
            else
            {
                accountIdBankIdListMap.put(accBankRecord.Core_MDF_Account__c, new List<Id>{accBankRecord.Core_MDF_Bank__c});
            }
        }
        
        return accountIdBankIdListMap;
    }
    
    /***************************************************************************************************** 
    Method Name:        loadAccountBankMaps
    @return  :          Map<Id,List<Id>>
    @parameters:        listOfAccounts - List of Accounts
    Description:        get all the accounts and its associated banks maps
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static Map<Id,List<Id>> loadAccountBankMaps(List<Core_MDF_Account_Bank_Mapping__c> listOfAccounts)
    {
        // Map to store all the accounts and its banks
        Map<Id,List<Id>> accountIdBankIdListMap = new Map<Id,List<Id>>(); 
        for(Core_MDF_Account_Bank_Mapping__c accBankRecord : listOfAccounts){
            if(accountIdBankIdListMap.containsKey(accBankRecord.Core_MDF_Account__c)){
                accountIdBankIdListMap.get(accBankRecord.Core_MDF_Account__c).add(accBankRecord.Id);
            }
            else{
                accountIdBankIdListMap.put(accBankRecord.Core_MDF_Account__c, new List<Id>{accBankRecord.Id});
            }
        }        
        return accountIdBankIdListMap;
    }
    
    /***************************************************************************************************** 
    Method Name:        beforeUpdateABMCondition
    @return  :          Void
    @parameters:        oldBankAccountMap - old records
    Description:        delete the bank share records
    Added By:           NZ Accenture - 02/10/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void beforeUpdateABMCondition(List<Core_MDF_Account_Bank_Mapping__c> oldABMList, Map<Id, Core_MDF_Account_Bank_Mapping__c> newABMMap)
    {
        Map<Id, Core_MDF_Account_Bank_Mapping__c> updatedABMMap = new Map<Id, Core_MDF_Account_Bank_Mapping__c>();
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        //Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Set<Id>> accountIdABMIdSetMap = new Map<Id,Set<Id>>();
        try {
            //Loop over Account Bank List
            for(Core_MDF_Account_Bank_Mapping__c abm : oldABMList){
                //Validate if change in Account or Bank then populate abmList[passed as param to Delete Share Records] and  updatedABMMap[Passes as param to Check if Claim Exists]
                if((abm.Core_MDF_Bank__c != newABMMap.get(abm.Id).Core_MDF_Bank__c) || (abm.Core_MDF_Account__c != newABMMap.get(abm.Id).Core_MDF_Account__c)){
                    abmList.add(abm);
                    updatedABMMap.put(abm.Id, newABMMap.get(abm.Id));
                    //accountIdSet.add(abm.Core_MDF_Account__c);
                    if(accountIdABMIdSetMap.containsKey(abm.Core_MDF_Account__c)){
                        accountIdABMIdSetMap.get(abm.Core_MDF_Account__c).add(abm.Id);
                    }
                    else{
                        accountIdABMIdSetMap.put(abm.Core_MDF_Account__c, new Set<Id>{abm.Id});
                    }
                }
                //Validate if change in Active Indicator and populate in updatedABMMap[passed as param to Delete Share Records]
                if((abm.Core_MDF_Active_ind__c != newABMMap.get(abm.Id).Core_MDF_Active_ind__c && !newABMMap.get(abm.Id).Core_MDF_Active_ind__c)){
                    updatedABMMap.put(abm.Id, newABMMap.get(abm.Id));
                    //accountIdSet.add(abm.Core_MDF_Account__c);
                    if(accountIdABMIdSetMap.containsKey(abm.Core_MDF_Account__c)){
                        accountIdABMIdSetMap.get(abm.Core_MDF_Account__c).add(abm.Id);
                    }
                    else{
                        accountIdABMIdSetMap.put(abm.Core_MDF_Account__c, new Set<Id>{abm.Id});
                    }
                }
            }
            if(updatedABMMap != NULL && updatedABMMap.size() > 0){
                validateIfClaimExist(updatedABMMap);
            }
            if(accountIdABMIdSetMap != NULL && accountIdABMIdSetMap.size() > 0){
                validateIfEscalationsExist(accountIdABMIdSetMap, newABMMap);
            }
            if(abmList != NULL && abmList.size() > 0){
                // Delete the bank share and bank account map share records
                deleteBankRecordsWithUsers(abmList);
            }
            
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
     
    /***************************************************************************************************** 
    Method Name:        deleteBankRecordsWithUsers
    @return  :          Void
    @parameters:        oldBankAccountMap - old records
    Description:        delete the bank share records
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void deleteBankRecordsWithUsers(List<Core_MDF_Account_Bank_Mapping__c> oldBankAccountMap)
    {
        try {            
            // Delete the bank account map share records
            deleteBankAccountMapShare(oldBankAccountMap);
            
            // Delete the bank share records
            deleteBankShare(oldBankAccountMap);
            
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /***************************************************************************************************** 
    Method Name:        deleteBankAccountMapShare
    @return  :          Void
    @parameters:        oldBankAccountMap - old records
    Description:        delete the account bank map share records
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static void deleteBankAccountMapShare(List<Core_MDF_Account_Bank_Mapping__c> oldBankAccountMap)
    {
        // Map to store banks and users to whom it should be shared
        Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>(); 
        List<Core_MDF_Account_Bank_Mapping__Share> bankShareListToBeDeleted = new List<Core_MDF_Account_Bank_Mapping__Share>();
        
        // Get the bank and its users Map
        bankIdUserIdListMap = buildBankUsersMap(oldBankAccountMap,'bankaccount');
        
        for(Core_MDF_Account_Bank_Mapping__Share bankShareRecord : [SELECT Id, ParentId, UserOrGroupId
                                                                    FROM Core_MDF_Account_Bank_Mapping__Share
                                                                    WHERE ParentId IN : bankIdUserIdListMap.keySet() AND
                                                                    RowCause =:manual limit 1000]){
            //check if the Share record exist
            if(bankIdUserIdListMap.containsKey(bankShareRecord.ParentId) && 
                bankIdUserIdListMap.get(bankShareRecord.ParentId).contains(bankShareRecord.UserOrGroupId))
            {
                bankShareListToBeDeleted.add(bankShareRecord);
            }
        }
        if(bankShareListToBeDeleted.size() > 0) {
            Database.delete(bankShareListToBeDeleted);
        }
    }
    
    /***************************************************************************************************** 
    Method Name:        deleteBankShare
    @return  :          Void
    @parameters:        oldBankAccountMap - old records
    Description:        delete the bank share records
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    
    private static void deleteBankShare(List<Core_MDF_Account_Bank_Mapping__c> oldBankAccountMap)
    {
        Map<Id,List<Id>> bankIdUserIdListMap = new Map<Id,List<Id>>();
        
        /*Compare both the maps and check if the users from respective map which we need to delete exists in any of the existing maps.If so we should not delete the bank share
*/
        bankIdUserIdListMap=bankIdUserIdMapToDelShare(oldBankAccountMap);
        
        //Call the delete bank share method
        if(bankIdUserIdListMap!=null)
        {
            completeBankShareDelete (bankIdUserIdListMap);   
        }
    }
    
    /***************************************************************************************************** 
    Method Name:        completeBankShareDelete
    @return  :          Void
    @parameters:        bankIdUserIdListMap - bankid user id list
    Description:        delete the bankids for the associated user share records
    Added By:           Sridhar - 21/11/2018
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    private static void completeBankShareDelete(Map<Id,List<Id>> bankIdUserIdListMap)
    {
        List<Core_MDF_Bank__Share> bankShareListToBeDeleted = new List<Core_MDF_Bank__Share>();
        
        for(Core_MDF_Bank__Share bankShareRecord : [SELECT Id, ParentId, UserOrGroupId
                                                    FROM Core_MDF_Bank__Share
                                                    WHERE ParentId IN : bankIdUserIdListMap.keySet() AND
                                                    RowCause =:manual]){
            //check if the Share record exist
            if(bankIdUserIdListMap.containsKey(bankShareRecord.ParentId) && 
                bankIdUserIdListMap.get(bankShareRecord.ParentId).contains(bankShareRecord.UserOrGroupId))
            {
                bankShareListToBeDeleted.add(bankShareRecord);
            }
        }
        if(bankShareListToBeDeleted.size() > 0) {
            Database.delete(bankShareListToBeDeleted);
        }
    }    
    
    /***************************************************************************************************** 
    Method Name:        bankIdUserIdMapToDelShare
    @return  :          Map<Id,List<Id>>
    @parameters:        oldBankAccountMap - old account and bank
    Description:        Get the banks and its associated users for delete
    Added By:           Thenammai - 10/4/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    
    private static Map<Id,List<Id>> bankIdUserIdMapToDelShare(List<Core_MDF_Account_Bank_Mapping__c> oldBankAccountMap)
    {
        List<Id> inpAcctIdLst=new List<Id>();
        List<Id> inpBnkIdLst=new List<Id>();
        Map<Id,List<Id>> inpAcctBnkIdMap=new Map<Id,List<Id>>();
        
        //Forming input Account Id and Bank Id list
        for(Core_MDF_Account_Bank_Mapping__c abm:oldBankAccountMap)
        {
            if(!inpAcctIdLst.contains(abm.Core_MDF_Account__c))
            {
                inpAcctIdLst.add(abm.Core_MDF_Account__c);
            }
            if(!inpBnkIdLst.contains(abm.Core_MDF_Bank__c))
            {
                inpBnkIdLst.add(abm.Core_MDF_Bank__c);
            }
            
            //Generating 
            if(inpAcctBnkIdMap.containsKey(abm.Core_MDF_Account__c))
            {
                inpAcctBnkIdMap.get(abm.Core_MDF_Account__c).add(abm.Core_MDF_Bank__c);
            }
            else
            {
                inpAcctBnkIdMap.put(abm.Core_MDF_Account__c,new List<Id>{abm.Core_MDF_Bank__c});
            }
        }
        
        List<Core_MDF_Partner_Node_User_Mapping__c> acctUserIdLst=
            [SELECT Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c
             WHERE Core_MDF_Account__c IN :inpAcctIdLst and Core_MDF_User__r.IsActive=true];
        
        //Account User Map
        Map<Id,List<Id>> acctUserIdMap = new Map<Id,List<Id>>();
        List<Id> userIdLst=new List<Id>();
        
        for(Core_MDF_Partner_Node_User_Mapping__c pnum:acctUserIdLst)
        {
            //UserId Lst
            if(!userIdLst.contains(pnum.Core_MDF_User__c))
            {
                userIdLst.add(pnum.Core_MDF_User__c);
            }
            
            if(acctUserIdMap.containsKey(pnum.Core_MDF_Account__c))
            {
                acctUserIdMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
            }
            else
            {
                acctUserIdMap.put(pnum.Core_MDF_Account__c,new List<Id>{pnum.Core_MDF_User__c});
            }
        }
        
        //Get the bank share of user ids
        List<Core_MDF_Bank__Share> bnkUserShareIdLst=
            [SELECT ParentId,UserOrGroupId FROM Core_MDF_Bank__Share 
             WHERE UserOrGroupId IN :userIdLst AND ParentId in :inpBnkIdLst AND RowCause =:manual];
        
        Map<Id,List<Id>> bnkUserShareIdMap=new Map<Id,List<Id>>();
        List<Id> bnkShareUserIds=new List<Id>();
        
        for(Core_MDF_Bank__Share cmbs:bnkUserShareIdLst)
        {
            if(!bnkShareUserIds.contains(cmbs.ParentId))
            {
                bnkShareUserIds.add(cmbs.ParentId);
            }
            if(bnkUserShareIdMap.containsKey(cmbs.ParentId))
            {
                bnkUserShareIdMap.get(cmbs.ParentId).add(cmbs.UserOrGroupId);
            }
            else
            {
                bnkUserShareIdMap.put(cmbs.ParentId, new List<Id>{cmbs.UserOrGroupId});
            }
        }
        
        List<Core_MDF_Account_Bank_Mapping__Share> acctBnkMapShareUsrIds=
            [SELECT ParentId,UserOrGroupId from Core_MDF_Account_Bank_Mapping__Share 
             WHERE UserOrGroupId IN :userIdLst AND RowCause =:manual AND ParentId IN
             (SELECT Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c 
              NOT IN :inpAcctIdLst AND Core_MDF_Bank__c IN :inpBnkIdLst)];
        
        List<Id> acctBnkMapShareIds=new List<Id>();
        for(Core_MDF_Account_Bank_Mapping__Share abs:acctBnkMapShareUsrIds)
        {
            if(!acctBnkMapShareIds.contains(abs.UserOrGroupId))
            {
                acctBnkMapShareIds.add(abs.UserOrGroupId);
            }
        }
        
        Map<Id,List<Id>> delBnkShareUsr=new Map<Id,List<Id>>();
        
        for(Id bnkShareUser:bnkUserShareIdMap.keySet())
        {
            List<Id> bnkShareUserLst=bnkUserShareIdMap.get(bnkShareUser);
            for(Id b:bnkShareUserLst)
            {
                if(!acctBnkMapShareIds.contains(b))
                {
                    if(delBnkShareUsr.containsKey(bnkShareUser))
                    {
                        delBnkShareUsr.get(bnkShareUser).add(b);
                    }
                    else
                    {
                        delBnkShareUsr.put(bnkShareUser,new List<Id>{b});   
                    }
                }
            }
        }
        return delBnkShareUsr;
    }

    /***************************************************************************************************** 
    Method Name:        validateIfEscalationsExist
    @return  :          void
    @parameters:        accountIdSet - Set of Account Id
    Description:        Check if any Escalations exist for Banks related to ABM in the oldABMMap
    Added By:           Accenture - SB - 21/02/2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void validateIfEscalationsExist(Map<Id,Set<Id>> accountIdABMIdSetMap, Map<Id, Core_MDF_Account_Bank_Mapping__c> newABMMap){
        try{
            Set<Id> accountIdsForWhichEscalationsExist = Core_MDF_BankUtility.fetchEscalationsForAccounts(accountIdABMIdSetMap.keySet());
            Set<Id> abmIdsForWhichEscalationsExist = new Set<Id>();
            if(accountIdsForWhichEscalationsExist != NULL && accountIdsForWhichEscalationsExist.size() > 0){
                for(Id accountId : accountIdsForWhichEscalationsExist){
                    abmIdsForWhichEscalationsExist.addAll(accountIdABMIdSetMap.get(accountId));
                }
            }
            
            if(abmIdsForWhichEscalationsExist != NULL && abmIdsForWhichEscalationsExist.size() > 0){
                for(Id abmId : abmIdsForWhichEscalationsExist){
                    //abmIdErrorStringMap.put(abmId, programMap.get(abmIdProgramStrMap.get(abmId)));
                    if(abmIdErrorStringMap.containsKey(abmId)){
                        //(Label.Core_MDF_Inactive_Bank_Error).replace('<>', abmIdErrorStringMap.get(abmId))
                        newABMMap.get(abmId).addError((Label.Core_MDF_Inactive_Bank_Error).replace('<>', abmIdErrorStringMap.get(abmId)) + ' \n' + Label.Core_MDF_BankErrorForActiveEscalations);
                    }
                    else{
                        newABMMap.get(abmId).addError(Label.Core_MDF_BankErrorForActiveEscalations);
                    }
                }
            }
        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }

    /***************************************************************************************************** 
    Method Name:        validateIfClaimExist
    @return  :          void
    @parameters:        oldABMMap - Map of old ABM records
    Description:        Check if any Claims exist for Banks related to ABM in the oldABMMap
    Added By:           Accenture - SB - 31/7/2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void validateIfClaimExist(Map<Id, Core_MDF_Account_Bank_Mapping__c> oldABMMap){
        try{
            //This will contain all the Banks related to ABM
            Set<Id> bankIdSet = new Set<Id>(); 
            
            //This will contain all the ABM records for which the related Bank has Claims associated
            Set<Id> abmErrorSet = new Set<Id>();            
            
            //Map key-- API name Value --> Label name of Program
            Map<String,String> programMap = new Map<String,String>();

            // Map<ABMId, Program>
            Map<Id, String> abmIdProgramStrMap = new Map<id, String>();

            //Set of String- bankId + AccountId + Program
            Set<String> bankIdAccountIdProgramStrSetWithClaims = new Set<String>();
            
            Map<Id, String> abmIdbankIdAccountIdProgramStrMap = new Map<Id, String>();

            //Core_MDF_Channel_Program_Name_txt__c - Client CoMarketing Fund
            //Core_MDF_Channel_Program_txt__c - Client Co-Marketing Fund
            for(Core_MDF_ClaimActAllocRecTypeMapping__mdt programMapping : [SELECT Id, Core_MDF_Channel_Program_txt__c, Core_MDF_Channel_Program_Name_txt__c
                                                                            FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                programMap.put(programMapping.Core_MDF_Channel_Program_Name_txt__c, programMapping.Core_MDF_Channel_Program_txt__c);
            }
            //NZ to add comments
            Set<Id> eligibleBankIdSet = new Set<Id>();
            //NZ to add comments
            Set<Id> eligibleAccountIdSet = new Set<Id>();
            //NZ to add comments
            Set<String> eligibleBankProgramSet = new Set<String>();
            //Fetch all the Banks and Accounts
            for(Core_MDF_Account_Bank_Mapping__c abm : oldABMMap.values()){  

                abmIdProgramStrMap.put(abm.Id, abm.Core_MDF_Program__c);
                
                if(abm.Core_MDF_Account__c != NULL){
                    eligibleAccountIdSet.add(abm.Core_MDF_Account__c);
                }
                if(abm.Core_MDF_Bank__c != NULL){
                    eligibleBankIdSet.add(abm.Core_MDF_Bank__c);
                }
                if(abm.Core_MDF_Program__c != NULL){
                    eligibleBankProgramSet.add(programMap.get(abm.Core_MDF_Program__c));
                }

                abmIdbankIdAccountIdProgramStrMap.put(abm.Id, (String)abm.Core_MDF_Bank__c + abm.Core_MDF_Account__c + programMap.get(abm.Core_MDF_Program__c));
            }
            
            if(eligibleAccountIdSet != NULL && eligibleBankIdSet != NULL && eligibleBankProgramSet != NULL &&
               eligibleAccountIdSet.size() > 0 && eligibleBankIdSet.size() > 0 && eligibleBankProgramSet.size() > 0){

                bankIdAccountIdProgramStrSetWithClaims = Core_MDF_BankUtility.validateClaimAssociationWithABM(eligibleAccountIdSet, eligibleBankIdSet, eligibleBankProgramSet);
                System.debug('NZ -> bankIdAccountIdProgramStrSetWithClaims : '+bankIdAccountIdProgramStrSetWithClaims);
                for(Id abmId : abmIdbankIdAccountIdProgramStrMap.keySet()){
                    //for(String abmStr :bankIdAccountIdProgramStrSetWithClaims){
                    if(bankIdAccountIdProgramStrSetWithClaims.contains(abmIdbankIdAccountIdProgramStrMap.get(abmId))){
                        /* if(abmIdbankIdAccountIdProgramStrMap.get(abmId).contains(abmStr)){
                            abmErrorSet.add(abmId); 
                            System.debug('NZ -> abmErrorSet: '+abmErrorSet);
                        } */
                        abmErrorSet.add(abmId); 
                        System.debug('NZ -> abmErrorSet: '+abmErrorSet);
                    }                    
                }
            }
            //throw error for ABMs if any Claims exist for Banks related to those ABMs
            if(abmErrorSet != NULL && abmErrorSet.size() > 0){
                for(Id abmId : abmErrorSet){
                    if(Trigger.isUpdate){
                        Trigger.newMap.get(abmId).addError((Label.Core_MDF_Inactive_Bank_Error).replace('<>', programMap.get(abmIdProgramStrMap.get(abmId))));
                        abmIdErrorStringMap.put(abmId,programMap.get(abmIdProgramStrMap.get(abmId)));
                    }
                    else if(Trigger.isDelete){
                        Trigger.oldMap.get(abmId).addError((Label.Core_MDF_Inactive_Bank_Error).replace('<>', programMap.get(abmIdProgramStrMap.get(abmId))));
                    }                        
                }
            }
        
            
        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}  
    }

    /***************************************************************************************************** 
    Method Name:        createABMShareForInternalUsers
    @return  :          void
    @parameters:        Set of ABM records
    Description:        Create share record for ABM based on Geo
    Added By:           Accenture SN
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public static void createABMShareForInternalUsers(Map<Id,Core_MDF_Account_Bank_Mapping__c> abmIdMap){
        Map<Id,List<Id>> bankIdABMIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_Account_Bank_Mapping__Share> abmShareList = new List<Core_MDF_Account_Bank_Mapping__Share>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> channelProgramIdSet = new Set<Id>();
        Set<String> geoSet = new Set<String>();

        //Key=AccId+ProgramId+Geo, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdGeoABMIdsMap = new Map<String,List<Id>>();
        
        //Key=AccId+ProgramId+Geo+SubGeo, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdGeoSubGeoABMIdsMap = new Map<String,List<Id>>();
        
        //For WW -> Key=AccId+ProgramId, value=List<BankId>
        Map<String,List<Id>> accountIdChannelProgramIdABMIdsMap = new Map<String,List<Id>>();

        //key=2 digit country code, value=Geo
        Map<String,String> countryCodeGeoMap = new Map<String,String>();
        
        //key=2 digit country code, value=SubGeo
        Map<String,String> countryCodeSubGeoMap = new Map<String,String>();

        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();

        try{
            //Get the Map of Country code and Geo using Country Geo Mapping Metadata
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt cgm : [SELECT Core_MDF_Code_2_Digits__c,Core_MDF_Geo__c, Core_MDF_Sub_Geo__c
                                                             FROM Core_MDF_CCP_Country_Geo_Mapping__mdt]){
                countryCodeGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Geo__c);
                countryCodeSubGeoMap.put(cgm.Core_MDF_Code_2_Digits__c,cgm.Core_MDF_Sub_Geo__c);
            }

            for(Core_MDF_Account_Bank_Mapping__c abm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name, 
                                                               Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Bank_Location__c
                                                        FROM Core_MDF_Account_Bank_Mapping__c
                                                        WHERE Id IN :abmIdMap.values()]){
                if(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c != NULL){
                    accountIdSet.add(abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);  
                    channelProgramIdSet.add(abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
                    if(countryCodeGeoMap.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c)){
                        if(countryCodeSubGeoMap.containsKey(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c)){
                            recordGeoShareList.add(new Core_MDF_RecordGeoShare(abm.Id, 
                                                                            countryCodeGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c),
                                                                            countryCodeSubGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c), 
                                                                            abm.Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name));
                            String accountIdProgramIdGeoSubGeo = (String)abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c + countryCodeGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c) + countryCodeSubGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c);
                            //Geo and SubGeo
                            if(accountIdChannelProgramIdGeoSubGeoABMIdsMap.containsKey(accountIdProgramIdGeoSubGeo)){ accountIdChannelProgramIdGeoSubGeoABMIdsMap.get(accountIdProgramIdGeoSubGeo).add(abm.Id);
                            }
                            else{
                                accountIdChannelProgramIdGeoSubGeoABMIdsMap.put(accountIdProgramIdGeoSubGeo, new List<String>{abm.Id});
                            }
                        }
                        geoSet.add(countryCodeGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c));

                        String accountIdProgramIdGeo = (String)abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c + countryCodeGeoMap.get(abm.Core_MDF_Bank__r.Core_MDF_Bank_Location__c);
                        //Only Geo
                        if(accountIdChannelProgramIdGeoABMIdsMap.containsKey(accountIdProgramIdGeo)){ accountIdChannelProgramIdGeoABMIdsMap.get(accountIdProgramIdGeo).add(abm.Id);
                        }
                        else{
                            accountIdChannelProgramIdGeoABMIdsMap.put(accountIdProgramIdGeo, new List<String>{abm.Id});
                        }
                        //for WW
                        accountIdProgramIdGeo = (String)abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c;
                        if(accountIdChannelProgramIdABMIdsMap.containsKey(accountIdProgramIdGeo)){ accountIdChannelProgramIdABMIdsMap.get(accountIdProgramIdGeo).add(abm.Id);
                        }
                        else{
                            accountIdChannelProgramIdABMIdsMap.put(accountIdProgramIdGeo, new List<String>{abm.Id});
                        }
                    }
                }
            }
            
            Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('Core_MDF_Account_Bank_Mapping__c', accountIdSet, channelProgramIdSet, geoSet, 
                                                                        accountIdChannelProgramIdGeoSubGeoABMIdsMap, accountIdChannelProgramIdGeoABMIdsMap, 
                                                                        accountIdChannelProgramIdABMIdsMap);

            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Account_Bank_Mapping__c',recordGeoShareList);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}