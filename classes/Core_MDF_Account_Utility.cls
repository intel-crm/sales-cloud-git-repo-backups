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
        
        Database.saveResult[] saveResultList;
        
        for(Account accRec : coMarketingAccountList){
            channelProgramIdSet.add(accRec.Core_MDF_Channel_Program__c);
        }
        
        Map<Id,ChannelProgram> cpIdToTechProgNameMap = new Map<Id,ChannelProgram>([Select Id,Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :channelProgramIdSet]);
        
        try{
            for(Account acc :coMarketingAccountList ){
                if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(cpIdToTechProgNameMap.get(acc.Core_MDF_Channel_Program__c).Core_MDF_Technical_Program_Name__c)){
                    accountIdList.add(acc.Id);
                    accountIdToAccountMap.put(acc.Id,acc);
                    Group nodeGroupRec = new Group();                        
                    nodeGroupRec.Name = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Account_Node_Group_Name_Label')+acc.Id;
                    nodeGroupRec.DeveloperName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Node_Group_DevName_Label')+acc.Id;
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
}