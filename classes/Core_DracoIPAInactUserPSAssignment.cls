/**************************************************************************************
Apex Class Name : Core_DracoIPAInactUserPSAssignment
TestClass Name : Core_DracoIPAInactUserPSAssignment_Test
Version     : 1.0 
Created Date: 11th 05 2026
Description : Apex class gets called from flow 'Core_Draco_Create_Inactive_User_for_Employee_Contact' to create a permissiion
set assignment record for the inatcive employee user created
* Modification Log : 
* Developer                 Date                   Description
* ----------------------------------------------------------------------------
* Team Draco       11-05-2026               Original Version
*************************************************************************************/
public class Core_DracoIPAInactUserPSAssignment {
    @InvocableMethod
    public Static Void createPSAssignmentRecord(List<Id> ids){
        createPSAssignmentRecordsFuture(ids);
    }
    @future
    public Static Void createPSAssignmentRecordsFuture(List<Id> ids){
        try{
            if(ids != null && ids.size() > 0){
                List<GroupMember> lstInsertGrpMembers = new List<GroupMember>();
                Group allPartnerGroup = [SELECT Id FROM Group WHERE Name = 'PMP - All Partner Users' AND Type = 'Regular' LIMIT 1];
                List<PermissionSet> PMPExternalPS = [Select Id,Name FROM PermissionSet where Name ='PMP_External_Employee'];
                List<PermissionSetAssignment> psAsgnList = New List<PermissionSetAssignment>();
                for(String uid : ids){
                    PermissionSetAssignment psAsgnRecord = New PermissionSetAssignment();
                    psAsgnRecord.AssigneeId = uid;
                    psAsgnRecord.PermissionSetId = PMPExternalPS[0].Id; 
                    psAsgnList.add(psAsgnRecord);
                    
                    /*UTKARSH's CHANGES - START*/
                    GroupMember gm = new GroupMember();
                    gm.GroupId = allPartnerGroup.Id;
                    gm.UserOrGroupId = uid;
                    lstInsertGrpMembers.add(gm);
                    System.debug('Creating GroupMember: GroupId=' + gm.GroupId + ', UserId=' + gm.UserOrGroupId);
                    /*UTKARSH's CHANGES - END*/
                }
                if(psAsgnList != null && psAsgnList.size() > 0){
                    database.insert(psAsgnList,false);
                }
                if(lstInsertGrpMembers != null && lstInsertGrpMembers.size() > 0 &&  !lstInsertGrpMembers.isEmpty()){
                    database.insert(lstInsertGrpMembers,false);
                }
            }
        }catch(exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'Core_DracoIPAInactUserPSAssignment', Core_Project__c = 'Core_DracoIPAInactUserPSAssignment' , Core_Details__c = 'Getting exception for PS Assignment creation for Inactive Employee', Core_Severity__c = 'info', Core_When__c = System.Now());
        }
        
    }
}