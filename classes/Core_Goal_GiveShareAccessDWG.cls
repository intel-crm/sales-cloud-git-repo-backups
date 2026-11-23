/****************************************************************************************************
Apex Class Name : Core_Goal_GiveShareAccessDWG
Version         : 1.0 
Created Date    : 11/13/2017
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_NotifyApprover'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash                11/13/2017              Created
* Ashwin Dash                10/03/2018              PRB000080249 Added condition to skip Deactivated users.
*****************************************************************************************************/

public class Core_Goal_GiveShareAccessDWG{
    

    @InvocableMethod(label='Give_sharing_to_Goal' description='Give sharing to Goal')
    public static List<Core_Goal__c> getAccountNames(List<Core_Goal__c> goalList) {
        //START - PRB000080249 Added condition to skip Deactivated users. -- Ashwin
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> actUserIdSet = new Set<Id>();
        for(Core_Goal__c goal : goalList){
            userIdSet.add(goal.CreatedById);
        }
        if(!userIdSet.isEmpty()){
            for(User usrs : [SELECT id, isActive FROM User WHERE id IN :userIdSet AND isActive = true]){
                actUserIdSet.add(usrs.Id);
            }            
        }
        //END - PRB000080249 Added condition to skip Deactivated users. -- Ashwin
        List<Core_Goal__Share> goalShareList = new List<Core_Goal__Share>();
        for(Core_Goal__c dwg : goalList){
            if(actUserIdSet.contains(dwg.CreatedById)){ // PRB000080249 Added condition to skip Deactivated users. -- Ashwin
                goalShareList.add(new Core_Goal__Share(UserOrGroupId = dwg.CreatedById, ParentId = dwg.Id, RowCause='Core_Deal_Win_Goal__c', AccessLevel = 'read'));
            }
        }
        if(!goalShareList.isEmpty()){
            insert goalShareList;
        }
        return null;
    }
}