/******************************************************************************************************
* Class Name  : Core_MDF_Account_Process 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AS      7/7/2020          Class for Account process, Group Creation for Co-marketing Accounts
*******************************************************************************************************/
public class Core_MDF_Account_Process {
    
    /*****************************************************************************************************
Method Name:        createGroupForAccountNode
@return  :          N/A
@parameters:        List of Co-marketing Account
Description:        This method is used to create Group for Node Based Sharing
Added By:           Accenture - AS - 24/7/2020
Modified By:        Date:       Changes: 

*******************************************************************************************************/
    public static void createGroupForAccountNode(List<Account> CoMarketingAccountList){
        //List of AccountIds
        List<Id> nodeAccountList= new List<Id>(); 
        //List of Group Records
        List<Group> nodeGroupList= new List<Group>();
        //Map of AccountId and Account
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>(); 
        
        Database.saveResult[] saveResultList;
        
        //map of accountId and list of group id for sharing of account record with its groupid
        Map<Id,List<Id>> accountIdGroupIdListMap = new Map<Id,List<Id>>();
        
        try{
            for(Account acc : CoMarketingAccountList){
                nodeAccountList.add(acc.Id);
                accountIdToAccountMap.put(acc.Id,acc);
                Group nodeGroupRec = new Group();                        
                nodeGroupRec.Name = 'CCP ACC GRP '+acc.Name;
                nodeGroupRec.DeveloperName = 'Core'+acc.Id;
                //Add each group record for Group List
                nodeGroupList.add(nodeGroupRec);                                        
            }
            
            if(nodeGroupList != NULL && nodeGroupList.size() > 0){   
                //Insert group Record List 
                saveResultList = database.insert(nodeGroupList, false);              
            }
            
            //Query to get records of Account to be Updated
            Map<Id,Account> resultAccountMap =new Map<Id,Account>( [Select Id, Core_MDF_Group_Id__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Parent_Fund_Account__r.recordTypeId from Account where ID IN:accountIdToAccountMap.keyset()]);//map id,account
            
            //Mapping of GroupId records with Accounts
            for(Integer index=0;index<saveResultList.size();index++){
                if(saveResultList[index].isSuccess() && saveResultList[index].getId()!=null ){
                    resultAccountMap.get(nodeAccountList[index]).Core_MDF_Group_Id__c = saveResultList[index].getId();                                    
                }else{
                    accountIdToAccountMap.get(nodeAccountList[index]).addError(Label.Core_MDF_Account_Name_Too_large);
                }
            } 
            //Update Account records with groupId
            database.update(resultAccountMap.values());
            
            for(Account acc : resultAccountMap.values()){
                accountIdGroupIdListMap.put(acc.Id,new List<Id>{acc.Core_MDF_Group_Id__c});                 
            }
            
            if(accountIdGroupIdListMap != NULL && !accountIdGroupIdListMap.isEmpty()){
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account', accountIdGroupIdListMap, 'Edit', 'Manual');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }                
            Core_MDF_shareRecordToAccountGroup.getBudgetForAccounts(resultAccountMap.values());            
        }catch(Exception e){         
            Core_MDF_CCP_UtilityClass.logError(e);}         
    }
    
}