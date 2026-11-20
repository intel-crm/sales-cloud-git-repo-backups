/******************************************************************************************************
* Class Name  : Core_MDF_Account_Utility 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AS      24/8/2020          Class for Account Group Creation for Co-marketing Accounts
*******************************************************************************************************/
public without sharing class Core_MDF_Account_Utility {
    //added by JK to replace prime ID field
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    /*****************************************************************************************************
Method Name:        createGroupForAccountNode
@return  :          N/A
@parameters:        List of Co-marketing Account
Description:        This method is used to create Group for Node Based Sharing
Added By:           Accenture - AS - 24/8/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Account> createGroupForAccountNode(List<Account> coMarketingAccountList){
        //List of  Co-Marketing AccountIds
        List<Id> accountIdList= new List<Id>(); 
        //List of Accounts To be Updated with GroupIds
        List<Account> accountToBeUpdated= new List<Account>(); 
        //List of Group Records
        List<Group> groupToBeInsertedList= new List<Group>();
        //Map of AccountId and Account
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>(); 
        //map of accountId and list of group id for sharing of account record with its groupid
        Map<Id,List<Id>> accountIdGroupIdListMap = new Map<Id,List<Id>>();
        //Set to Store Co-Marketing AccountIds
        Set<Id> channelProgramIdSet= new Set<Id>();
        // Map to store account Id and corresponding program Id
        Map<Id,Id> accIdProgIdMap = new Map<Id,Id>();
        // Map to store prog Id and program name
        Map<Id,String> cpIdNameMap = new Map<Id,String>();
        
        
        Database.saveResult[] saveResultList;
        
        for(Account accRec : coMarketingAccountList){
            channelProgramIdSet.add(accRec.Core_MDF_Channel_Program__c);
            accIdProgIdMap.put(accRec.Id,accRec.Core_MDF_Channel_Program__c);
        }
        
        Map<Id,ChannelProgram> cpIdToTechProgNameMap = new Map<Id,ChannelProgram>([Select Id,Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :channelProgramIdSet]);
        
        if(cpIdToTechProgNameMap!=NULL)
        {
            for(ChannelProgram cp : cpIdToTechProgNameMap.values())
            {
                cpIdNameMap.put(cp.Id,cp.Core_MDF_Technical_Program_Name__c);
            }
        }
        try{
            for(Account acc :coMarketingAccountList ){
                if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(cpIdToTechProgNameMap.get(acc.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c)){
                    accountIdList.add(acc.Id);
                    accountIdToAccountMap.put(acc.Id,acc);
                    Group nodeGroupRec = new Group();                        
                    nodeGroupRec.Name = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Account_Node_Group_Name_Label')+acc.Id;
                    nodeGroupRec.DeveloperName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Node_Group_DevName_Label')+acc.Id;
                    nodeGroupRec.DoesIncludeBosses = false;
                    //Add each group record for Group List
                    groupToBeInsertedList.add(nodeGroupRec); 
                }
            }
            
            if(groupToBeInsertedList != NULL && groupToBeInsertedList.size() > 0){   
                //Insert group Record List 
                saveResultList = database.insert(groupToBeInsertedList, false);              
            }
            //Mapping of GroupId records with Accounts
            if(saveResultList!=NULL && saveResultList.size()>0){
                for(Integer index=0;index<saveResultList.size();index++){
                    if(saveResultList[index].isSuccess() && saveResultList[index].getId()!=null ){
                        Account account = new Account(Id = accountIdList[index]);
                        account.Core_MDF_Group_Id__c = saveResultList[index].getId();
                        accountToBeUpdated.add(account);                    
                    }else{
                        accountIdToAccountMap.get(accountIdList[index]).addError(Label.Core_MDF_Account_Name_Too_large);
                    }
                }                 
            }             
            //Update Account records with groupId
            if(accountToBeUpdated !=NULL && accountToBeUpdated.size()>0 ){
                database.update(accountToBeUpdated);
                
                //To Share Account with its corresponding Group
                for(Account acc : accountToBeUpdated){
                    if(acc.Core_MDF_Group_Id__c != Null){
                        accountIdGroupIdListMap.put(acc.Id,new List<Id>{acc.Core_MDF_Group_Id__c});    
                    }
                }
            }
            
            if(!Core_MDF_Utility.byPassFeature('Bypass_ExceptionGroupSharingForAllAcc'))
            {
                if(!accountToBeUpdated.isEmpty() && accIdProgIdMap!=NULL && cpIdNameMap!=NULL)
                {
                    exceptionGroupSharingForAllAcc(accountToBeUpdated,accIdProgIdMap,cpIdNameMap);//For sharing exception with new group on node account
                }
            }
            
            
            if(accountIdGroupIdListMap != NULL && !accountIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account', accountIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
        return accountToBeUpdated;
    } 
    /*****************************************************************************************************
Method Name:        recalculateShareAccountWhenOwnerChange
@return  :          N/A
@parameters:        List of Account whose owner is changed
Description:        This method is to reshare account record with its group when account's owner is changed
Added By:           Accenture - VD - 07/9/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
    @InvocableMethod
    public static void recalculateShareAccountWhenOwnerChange(List<Account> accountToBeResharedList){
        
        //map of accountId and list of group id for sharing of account record with its groupid
        Map<Id,List<Id>> accountIdGroupIdListMap = new Map<Id,List<Id>>();
        
        try{
            if(accountToBeResharedList != Null && accountToBeResharedList.size()>0){
                //To Share Account with its corresponding Group
                for(Account acc : accountToBeResharedList){
                    if(acc.Core_MDF_Group_Id__c != Null){
                        accountIdGroupIdListMap.put(acc.Id,new List<Id>{acc.Core_MDF_Group_Id__c});    
                    }                             
                }
            }
            if(accountIdGroupIdListMap != NULL && !accountIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account', accountIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /*****************************************************************************************************
Method Name:        exceptionGroupSharingForAllAcc
@return  :          N/A
@parameters:        List of Accounts to be updated, map of account Id and program Id,map of prog Id and prog name
Description:        This method is to add group in node account to super group on exception for sharing
Added By:           Accenture - BD - 08/02/2023
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 
    public static void exceptionGroupSharingForAllAcc(List<Account> accToBeUpdated,Map<Id,Id> accIdProgIdMap, Map<Id,String> progIdNameMap)
    {
        Map<String,String> progGroupMap = new Map<String,String>();
        Map<String,Id> groupDevNameIdMap = new Map<String,Id>();
        List<GroupMember> gmList = new List<GroupMember>();
        
        try
        {
            for(Core_MDF_CCP_RecordTypes__c recTypeMetadata : [select Name,Core_MDF_Exception_SharingGroup__c 
                                                                  from Core_MDF_CCP_RecordTypes__c
                                                                  where Core_MDF_Exception_SharingGroup__c!=null])
            {
                //Map to store sharing group for corresponding program
                progGroupMap.put(recTypeMetadata.Name,recTypeMetadata.Core_MDF_Exception_SharingGroup__c);
            }
            
            if(!progGroupMap.values().isEmpty())
            {
                for(Group exptGroup : [Select Id,DeveloperName 
                                       from Group 
                                       where DeveloperName in: progGroupMap.values()])
                {
                    //Map to store group name and group Id
                    groupDevNameIdMap.put(exptGroup.DeveloperName,exptGroup.Id);
                }
            }
            
            for(Account acc : accToBeUpdated)
            {
                String progId = accIdProgIdMap!=null && accIdProgIdMap.containskey(acc.Id)?accIdProgIdMap.get(acc.Id) :'';
                String progName = String.isNotBlank(progId) && progIdNameMap!= null && progIdNameMap.containskey(progId)?progIdNameMap.get(progId) :'';
                
                //Verifying if program of the account is eligible for exception group sharing
                if(String.isNotBlank(progName) && progGroupMap.keySet()!=null && progGroupMap.keySet().contains(progName))
                {	
                    String groupName = progGroupMap.get(progIdNameMap.get(accIdProgIdMap.get(acc.Id)));
                    //Fetching Group Id based on group name corresponding to the program of the account
                    if(groupDevNameIdMap!=null && groupDevNameIdMap.containskey(groupName))
                    {
                        GroupMember exptSharingGM = new GroupMember();
                        exptSharingGM.GroupId = groupDevNameIdMap.get(groupName);
                        exptSharingGM.UserOrGroupId = acc.Core_MDF_Group_Id__c;
                        gmList.add(exptSharingGM); 
                    }
                }
            }
            
            if(!gmList.isEmpty())
            {
                String jsonStringGM = JSON.serialize(gmList);
                createGroupMember(jsonStringGM);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    /*****************************************************************************************************                              
Method Name   :        createGroupMember                                
@return       :        void                             
@parameters   :        String jsonString which has new GroupMember                              
Description   :        To insert the GroupMember records                                
Added By      :        Accenture - BD - 08/02/2023                              
Modified By   :        Date:       Changes:                                 
******************************************************************************************************/ 
    @future                             
    public static void createGroupMember(String jsonStringGM){                              
        try{               
            List<GroupMember> gmList = (List<GroupMember>)JSON.deserialize(jsonStringGM,List<GroupMember>.class);                               
            Database.SaveResult[] saveList = Database.insert(gmList,true);                                                              
        }                               
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
    }
    public static List<Account> fetchAccounts(String whereClause){
        //String ultimateAccountPrimeIdOrUnifiedField = isUnifiedIdEnabled?'Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c':'Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c';
        String ultimateAccountPrimeIdOrUnifiedField = 'Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c';
        //String intelAccountPrimeIdOrUnifiedField = isUnifiedIdEnabled?'Core_Unified_Global_Customer_BP_Id__c':'Core_Prime_Id__c';
        String intelAccountPrimeIdOrUnifiedField = 'Core_Unified_Global_Customer_BP_Id__c';
        String Query = 'SELECT Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c,RecordTypeId,Core_IPA_One_Partner_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,'+'Core_MDF_CoMarketingAgency__c,Core_Geo__c,Core_Sub_Geo__c,IsPartner,'+
       intelAccountPrimeIdOrUnifiedField+','+ultimateAccountPrimeIdOrUnifiedField+' FROM Account WHERE ';
        if(String.isNotEmpty(whereClause) && whereClause != null){
            Query += whereClause;
        }
        List<Account> accounts = Database.query(Query);
        return accounts;
    }
    public static List<PRM_IPA_Affiliation__c> fetchPRMIPAAffiliation(Set<Id> accounts,Set<Id> prmIPAId){
        String primeIdOrUnifiedField = 'PRM_Account__r.Core_Unified_Global_Customer_BP_Id__c';
        //String primeIdOrUnifiedField = isUnifiedIdEnabled?'PRM_Account__r.Core_Unified_Global_Customer_BP_Id__c':'PRM_Account__r.Core_Prime_Id__c';
        String excludePartner = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ExcludedPartner');
        String accountDeveloperName = Label.PRM_Intel_Account;
        String Query = 'SELECT Id, PRM_Account__c,'+primeIdOrUnifiedField+' FROM PRM_IPA_Affiliation__c WHERE PRM_Builder_Strategy__r.Name =:excludePartner'+
        ' AND PRM_Active__c = TRUE';
        if(accounts != null){
            Query += ' AND PRM_Account__c IN: accounts';
        }
        if(prmIPAId != null){
           Query += ' AND Id IN: prmIPAId AND PRM_Account__r.RecordType.DeveloperName =:accountDeveloperName';
        }
        List<PRM_IPA_Affiliation__c> prmIPAAff = new List<PRM_IPA_Affiliation__c>();
        for(PRM_IPA_Affiliation__c ipaAff :Database.Query(Query)){
            prmIPAAff.add(ipaAff);
        }
        return prmIPAAff;
    }
    public static List<Account> fetchUnifiedIdAccounts(Set<String> unifedIdSet){
        //String primeIdOrUnifiedField = isUnifiedIdEnabled?'Core_Unified_Global_Customer_BP_Id__c':'Core_Prime_Id__c';
        String primeIdOrUnifiedField = 'Core_Unified_Global_Customer_BP_Id__c';
        String prmRecordType=Label.PRM_Partner_Account_Group_Record_Type;
        String masterAccountRecordtype=Label.Core_MDF_MasterAccount;
       String Query = 'SELECT Id,Name,RecordType.DeveloperName,Core_IPA_One_Partner_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,'+primeIdOrUnifiedField+',Core_MDF_CoMarketingActive__c from Account WHERE '
                    +primeIdOrUnifiedField+' IN: unifedIdSet AND '+'('+'RecordType.DeveloperName =:prmRecordType'+' OR'+' ('+'RecordType.DeveloperName =:masterAccountRecordtype'+' AND Core_Intel_Partner_Alliance_PartnerGroup__c = TRUE'+'))';
        List<Account> accounts = new List<Account>();
        for(Account acc : Database.query(Query)){
            accounts.add(acc);
        }
        return accounts;
    }
    
}