/****************************************************************************************************************************************
* Class Name  : Core_MDF_shareRecordToAccountGroup 
* Version     : 1.0 
* Created Date: 21-Aug-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       21-Aug-2020          Generic Class to create Share record with their account group
*****************************************************************************************************************************************/
public without sharing class Core_MDF_shareRecordToAccountGroup {
    
    public static Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    public static Map<Id, Id> budgetToUltimateAcctMap = new Map<Id, Id>();
    public static Map<String,Boolean> progNameNodeBasedSharingReqdMap = new Map<String,Boolean>();
    
    static{        
        for(Core_MDF_ChannelProgram__mdt cp : [Select Core_MDF_Node_Based_Sharing_Required_Ind__c,Core_MDF_Technical_Program_Name__c from Core_MDF_ChannelProgram__mdt]){
            progNameNodeBasedSharingReqdMap.put(cp.Core_MDF_Technical_Program_Name__c,cp.Core_MDF_Node_Based_Sharing_Required_Ind__c);
        }
    }
    
    /***************************************************************************************************** 
    Method Name:        isNodeBasedSharingReqd
    @return  :          Boolean 
    @parameters:        technical program name
    Description:        
    Added By:           Vaishali  - 26-08-2020
    Modified By:        Date:       Changes: 
                    
    *****************************************************************************************************/
    
    public static Boolean isNodeBasedSharingReqd(String programName){
        if(progNameNodeBasedSharingReqdMap.containskey(programName) && progNameNodeBasedSharingReqdMap.get(programName) != Null
           && progNameNodeBasedSharingReqdMap.get(programName)){
               return true;
           }            
        else{
           return false;     
        }                     
    }
    
        
     /***************************************************************************************************** 
    Method Name:        shareRecordToAllAcctGroupInHierarchy
    @return  :          void
    @parameters:        Map of Record Id to share and Its Ultimate Account + Channel Program, Object Name, list of Ultimate Account Id
    Description:        
    Added By:           Pranav - 21-08-2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/    

    public static void shareRecordToAllAcctGroupInHierarchy(Map<Id, String> recordIdToUltimateAccountIdProgramIdMap, String objectName, List<ID> ultimateAccountIdList, List<Id> channelProgramIdsList)
    {
        // Map to store ultimate Account Id and progarm Id as key and List of user groups as Map values
        Map<String,List<Id>> ultimateAcctIdProgramIdToGroupIdsListMap = new Map<String,List<Id>>();
        // Map of Record Id and List of user group Id to pass into generic share method
        Map<Id,List<Id>> objectIdGroupIdListMap = new Map<Id,List<Id>>();
        
        // Iterating over all Accounts in its ultimate Account hierarchy
        for(Account acc : [Select Id, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c from Account Where Core_MDF_CoMarketing_Ultimate_Account__c IN :ultimateAccountIdList AND Core_MDF_Channel_Program__c IN: channelProgramIdsList])
        {
            // Check if Core_MDF_Group_Id__c, account's parent account's ultimate field and channel program on account is not NULL
            if(acc.Core_MDF_Group_Id__c!=null && acc.Core_MDF_CoMarketing_Ultimate_Account__c != NULL && acc.Core_MDF_Channel_Program__c != NULL){
                // Making Key for the Map as String - Account's ultimate Accounts Id and Channel Program Id
                String ultimateAcctIdProgId = String.valueOf(acc.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
                // Preparing map to store ultimate account and list of all groups in the ultimate account's hierarchy
                if(!ultimateAcctIdProgramIdToGroupIdsListMap.containsKey(ultimateAcctIdProgId))
                {
                    ultimateAcctIdProgramIdToGroupIdsListMap.put(ultimateAcctIdProgId, new List<ID> {acc.Core_MDF_Group_Id__c});
                }
                else
                {
                    ultimateAcctIdProgramIdToGroupIdsListMap.get(ultimateAcctIdProgId).add(acc.Core_MDF_Group_Id__c);
                }       
            }
        }
        // Creating a map of each record with list of groups on the basis of ultimate Account and Channel Program
        for(Id recordId : recordIdToUltimateAccountIdProgramIdMap.keySet())
        {
            // ultimate Account and channel program String Key
            String ultimateAcctIdProgramId = recordIdToUltimateAccountIdProgramIdMap.get(recordId);
            if(ultimateAcctIdProgramId != NULL && ultimateAcctIdProgramIdToGroupIdsListMap.containsKey(ultimateAcctIdProgramId)){
                // Map to store record Id and list of groups to share with
                objectIdGroupIdListMap.put(recordId, ultimateAcctIdProgramIdToGroupIdsListMap.get(ultimateAcctIdProgramId));
            }
        }
        // Calling Generic Method to share the records with the groups
        if(objectIdGroupIdListMap != NULL && !objectIdGroupIdListMap.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName, objectIdGroupIdListMap, 'Edit', 'Manual');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
}