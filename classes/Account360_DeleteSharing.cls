public without sharing class Account360_DeleteSharing {
  
    public class InputData{
        @InvocableVariable
        public Id userId;
        @InvocableVariable
        public Id accountId;
    }
    
    @InvocableMethod
    public static void invokeDeleteAccount360Sharing(List<InputData> inputData)
    {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(InputData inp : inputData){
            if(inp != null){
                userIdSet.add(inp.userId);
                accIds.add(inp.accountId);
            }
            
        }
        //Set<Id> userIdSet = new Set<Id>();
        List<Account_Plan__Share> accPlanShare = new List<Account_Plan__Share>();
        List<Executive_Meeting_Brief__Share> embShare = new List<Executive_Meeting_Brief__Share>();
        List<Account_Status__Share> accStatusShare = new List<Account_Status__Share>();
        List<Account_Revenue__Share> accRevenueShare = new List<Account_Revenue__Share>();
        List<AccountPlanShare> accStdPlanShare = new List<AccountPlanShare>();
        List<Sobject> objList = new List<Sobject>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        List<Core_Log_Entry__c> logEntries2 = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        try{
            List<String> objectsForAccount360Sharing = System.Label.Objects_for_Account360_sharing.split(','); 
                

                if(objectsForAccount360Sharing.contains('Account_Plan__c'))
                {
                    accPlanShare = [Select ID,ParentId, UserOrGroupId,Parent.Account__c from Account_Plan__Share where UserOrGroupId IN :userIdSet and Parent.Account__c IN : accIds and RowCause = 'Manual'];
                    if(accPlanShare!= null){
                    objList.addAll(accPlanShare);
                    }
                }
                if(objectsForAccount360Sharing.contains('Executive_Meeting_Brief__c'))
                {
                    embShare = [Select ID,ParentId, UserOrGroupId,Parent.Account__c from Executive_Meeting_Brief__Share where UserOrGroupId IN :userIdSet and Parent.Account__c IN : accIds and  RowCause = 'Manual'];
                    if(embShare!= null){
                    objList.addAll(embShare);
                     }
                }
                if(objectsForAccount360Sharing.contains('Account_Status__c'))
                {
                    accStatusShare = [Select ID,ParentId, UserOrGroupId,Parent.Account__c from Account_Status__Share where UserOrGroupId IN :userIdSet and Parent.Account__c IN : accIds and RowCause = 'Manual'];
                    if(accStatusShare != null){
                    objList.addAll(accStatusShare);
                    }
                }
                if(objectsForAccount360Sharing.contains('Account_Revenue__c'))
                {
                    accRevenueShare = [Select ID,ParentId, UserOrGroupId,Parent.Account__c from Account_Revenue__Share where UserOrGroupId IN :userIdSet and Parent.Account__c IN : accIds and RowCause = 'Manual'];
                    if(accRevenueShare != null){
                    objList.addAll(accRevenueShare);
                    }
                }
                //TWC4767-4408 CRM: Sharing and security model for New Standard Account Plans
                if(objectsForAccount360Sharing.contains('AccountPlan'))
                {
                    accStdPlanShare = [Select ID,ParentId, UserOrGroupId,Parent.AccountId from AccountPlanShare where UserOrGroupId IN :userIdSet and Parent.AccountId IN : accIds and RowCause = 'Manual'];
                    if(accStdPlanShare != null){
                    objList.addAll(accStdPlanShare);
                    }
                }         
                
            	if(objList <> null){
                    String listOfDeleted = objList.toString();
                        logEntries2.add(new Core_Log_Entry__c(Core_Message__c ='Info',Core_Details__c = listOfDeleted , Core_Origin__c='Account360_DeleteSharing.objList', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
                            if(!logEntries2.isEmpty() && !logSwitch.isEmpty()){
                                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                                    insert logEntries2;
                        }
                    }
                Database.delete(objList);
            }
        }catch(Exception e){ 
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Account360_DeleteSharing.account360Sharing', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
            	if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                	insert logEntries;
                }
            }
        }
    }

}