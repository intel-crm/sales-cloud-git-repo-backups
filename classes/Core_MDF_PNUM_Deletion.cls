/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_PNUM_Deletion 
* Version     : 1.0 
* Created Date: 11-06-2020
* Modification Log :
* Developer                     Date                          Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - NP(11630236)          11-06-2020                    Class to delete and log PNUM records when user is removed from group (Gets called from Core_MDF_UserGroupMapping_Deletion)
**************************************************************************************************************************************************************************************/
public without sharing class Core_MDF_PNUM_Deletion {
    public static list<id> pnumdeletion(List<id> groupMemberId){
        
        Set<Id> groupIdsList = new Set<Id>();
        set<id> userIdsList = new set<id>();
        set<id> coMarketingActiveAccountIdsList = new set<id>();
        Map<id,List<id>> userIdToGroupMap = new Map<id,List<id>>();
        Map<id,string> groupIdToProgramMap = new Map<id,string>();
        Map<id,string> groupIDToCoMarketingAccountIdMap = new Map<id,string>();
        List<id> toBeDeletedPnum = new List<id>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = new List<Core_MDF_Partner_Group_Mapping__c>();
        try{
            //Query the Groupmemeber and get the User IDs and Group IDs
            for(GroupMember gm: [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE Id IN:groupMemberId]){
                groupIdsList.add(gm.GroupId);
                userIdsList.add(gm.UserOrGroupId);
                //User maybe part of multiple Programs hence multiple Groups
                if(userIdToGroupMap.containsKey(gm.UserOrGroupId)){userIdToGroupMap.get(gm.UserOrGroupId).add(gm.GroupId);}
                else{userIdToGroupMap.put(gm.UserOrGroupId, new List<Id>{ gm.groupid });}
            }
    
            //Query the PGM with the Groups to find out which Account is Co-marketing Active
            pgmRecords = Core_MDF_PGM_Utility.fetchExternalPGMRecords(null,null,null,groupIdsList,null,true);
            for(Core_MDF_Partner_Group_Mapping__c pgm:pgmRecords /*[select Core_MDF_Account__c, Core_MDF_Channel_Program__c,Core_MDF_Group_Id__c,Core_MDF_CoMarketingActive_Ind__c,Core_MDF_Type_of_Access__c, id 
                                                        from Core_MDF_Partner_Group_Mapping__c 
                                                        where Core_MDF_Group_Id__c in: groupIdsList  
                                                        and Core_MDF_CoMarketingActive_Ind__c=true 
                                                        and Core_MDF_Inactive_Ind__c = false
                                                        and Core_MDF_Type_of_Access__c ='External']*/){
                coMarketingActiveAccountIdsList.add(pgm.Core_MDF_Account__c);
                groupIDToCoMarketingAccountIdMap.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Account__c);
                groupIdToProgramMap.put(pgm.Core_MDF_Group_Id__c,pgm.Core_MDF_Channel_Program__c);
            }
             
            //Query the PNUM with the Co-Marketing Accounts obtained
            for(Core_MDF_Partner_Node_User_Mapping__c pnum:[select Core_MDF_User__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c, id 
                                                            from Core_MDF_Partner_Node_User_Mapping__c 
                                                            where Core_MDF_User__c in: userIdsList 
                                                            and Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c in:coMarketingActiveAccountIdsList
                                                           and Core_MDF_Active_Ind__c = true]){
                
                //User may belong to multiple Programs hence adding pnum per user per program per account                                        
                List<id> groupIds = userIdToGroupMap.get(pnum.Core_MDF_User__c);
                for(id groupID:groupIds){
                    id channelProgram = groupIdToProgramMap.get(groupID);
                    id account = groupIDToCoMarketingAccountIdMap.get(groupID);
                                             
                    if(pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__c == channelProgram && pnum.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c == account){
                        toBeDeletedPnum.add(pnum.id);
                    }     
                }                                         
            }
        
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
        return toBeDeletedPnum; 
    }
    
    //Log the PNUM deletion records in UserGroupMapping Log object
    // Updated the comment to - Log the PNUM Inactivate records in UserGroupMapping Log object
    public static void logUGM(list<id> pnumids){
        
        List<Core_MDF_UserGroupMapping_Log__c> logObjectList = new List<Core_MDF_UserGroupMapping_Log__c>();
        
        try{
            for(Core_MDF_Partner_Node_User_Mapping__c log: [select Core_MDF_User__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c, id 
                                                   from Core_MDF_Partner_Node_User_Mapping__c 
                                                   where id in: pnumids]){
                Core_MDF_UserGroupMapping_Log__c logobject = new Core_MDF_UserGroupMapping_Log__c();
                logobject.Core_MDF_User_id__c= log.Core_MDF_User__c;
                logobject.Core_MDF_Account_id__c = log.Core_MDF_Account__c;
                logobject.Core_MDF_Action_nm__c = 'PNUM Deletion';
                logObject.Core_MDF_Status_nm__c= 'In Progress';
                logObject.Core_MDF_Processed_dtm__c = system.now();
                logObjectList.add(logobject);
            }
            Database.SaveResult[] saveList = Database.insert(logObjectList,false);
           
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }

}