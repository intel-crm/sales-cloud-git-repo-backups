/****************************************************************************************************************************************
* Class Name        :  Core_MDF_DeletePNUM_Batch
* Created Date      :  7/14/2020
* Modification Log
* Developer           	  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Varun       7/14/2020          Batch class to delete PNUM for users who are not part of the Acc-Program specific group
*****************************************************************************************************************************************/
public without sharing class Core_MDF_DeletePNUM_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    Set<Id> groupIdSet = new Set<Id>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToBeDeleted = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    Map<Id,Set<Id>> groupIdUserIdSetMap = new Map<Id,Set<Id>>();
    Set<Id> userIdSet = new Set<Id>();
    Set<Id> ultimateAccIdSet = new Set<Id>();
    Set<Id> channelProgramIdSet = new Set<Id>();
    Map<String,Set<Id>> accIdCpIdKeyUserIdSetMap = new Map<String,Set<Id>>();
    
    //Constructor which is set from Core_MDF_ExternalUserSharing class
    public Core_MDF_DeletePNUM_Batch(Set<Id> groupId) {
        this.groupIdSet = groupId;        
    }
    
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List of PNUMs
    @parameters :   Database.BatchableContext
    Description :   It fetches all PNUM based on Account and Program
    Added By    :   Accenture - Varun - 7/14/2020 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/  
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        try{
            initializeBatch(groupIdSet);
            
            String strQuery = '';
            strQuery = 'SELECT Id, Core_MDF_Account__c, Core_MDF_User__c, '
                        +'Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
                        +'Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_User__r.isActive '
                        +'FROM Core_MDF_Partner_Node_User_Mapping__c '
                        +'WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN : ultimateAccIdSet AND '
                        +'Core_MDF_Account__r.Core_MDF_Channel_Program__c  IN : channelProgramIdSet AND '
                        +'Core_MDF_User__r.isActive = TRUE AND '
                        +'Core_MDF_Active_Ind__c = true';
            return Database.getQueryLocator(strQuery);
            
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);return NULL; }
    }
    
    /******************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   Collects all the PNUM records to be deleted
    Added By    :   Accenture - Varun - 7/14/2020 
    Modified By :                               Date:         		Changes:
    **********************************************************************************************************/  
    public void execute(Database.BatchableContext bc, List<Core_MDF_Partner_Node_User_Mapping__c> scope) {
        
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : scope){                                                  
                String key = (String)pnum.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__c;
                if(accIdCpIdKeyUserIdSetMap.containsKey(key) && 
                   accIdCpIdKeyUserIdSetMap.get(key) != NULL &&
                   !accIdCpIdKeyUserIdSetMap.get(key).contains(pnum.Core_MDF_User__c)){
                    pnumListToBeDeleted.add(pnum);
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /******************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   deletes all the PNUM records
    Added By    :   Accenture - Varun - 7/14/2020 
    Modified By :                               Date:         		Changes:
    **********************************************************************************************************/ 
    public void finish(Database.BatchableContext bc) {
        
        try{
            if(pnumListToBeDeleted != NULL && pnumListToBeDeleted.Size() > 0){                
                database.delete(pnumListToBeDeleted);
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    /******************************************************************************************************** 
    Method Name :   initializeBatch
    @return     :   void
    @parameters :   Set of group ids
    Description :   Prepares a Map of PGM groups and the users associated to that group
    Added By    :   Accenture - Varun - 7/14/2020 
    Modified By :                               Date:         		Changes:
    **********************************************************************************************************/ 
    public void initializeBatch(Set<Id> groupIdSet){
        
        try{
            if(groupIdSet != NULL && !groupIdSet.isEmpty()){
                for(GroupMember gm : [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN:groupIdSet]){
                    userIdSet.add(gm.UserOrGroupId);                    
                    if(groupIdUserIdSetMap.containsKey(gm.GroupId)) {
                        groupIdUserIdSetMap.get(gm.GroupId).add(gm.UserOrGroupId);
                    } else {
                        groupIdUserIdSetMap.put(gm.GroupId, new Set<Id>{gm.UserOrGroupId});
                    }
                }   
            }
            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__c, Core_MDF_Group_Id__c, Core_MDF_Type_of_Access__c
                                                         FROM Core_MDF_Partner_Group_Mapping__c
                                                         WHERE Core_MDF_Group_Id__c IN: groupIdSet AND 
                                                         Core_MDF_Inactive_Ind__c = false AND 
                                                         Core_MDF_Type_of_Access__c = 'External']){
                ultimateAccIdSet.add(pgm.Core_MDF_Account__c);
                channelProgramIdSet.add(pgm.Core_MDF_Channel_Program__c);
                String accIdCpId = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c;
                if(groupIdUserIdSetMap.containsKey(pgm.Core_MDF_Group_Id__c) && groupIdUserIdSetMap.get(pgm.Core_MDF_Group_Id__c) != NULL){
                    accIdCpIdKeyUserIdSetMap.put(accIdCpId, groupIdUserIdSetMap.get(pgm.Core_MDF_Group_Id__c));
                }
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);}
    }
}