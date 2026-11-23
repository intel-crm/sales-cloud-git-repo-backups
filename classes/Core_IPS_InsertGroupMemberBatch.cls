public class Core_IPS_InsertGroupMemberBatch implements Database.Batchable<sObject >, Database.Stateful {
    public final String Query;
    public List<Core_IPS_Project_Member__c> projectMembersList;
    //START - Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    List<String> errorRecs = new List<String>();
    Set<Id> groupMemSet = new Set<Id>(); 
    public static Integer maxRetrycount = 3;
    public Integer retryCount = 0; //END
    public Core_IPS_InsertGroupMemberBatch(String q, List<Core_IPS_Project_Member__c> projectMembers, Integer rcnt){
        Query=q;
        projectMembersList = projectMembers;
        retrycount = rcnt; //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query+' IN :projectMembersList');
    }
    public void execute(Database.BatchableContext BC, List<Core_IPS_Project_Member__c> projectMember){
    try{
        List<GroupMember> GMlist = new List<GroupMember>();
        for(Core_IPS_Project_Member__c projMember: projectMember){
            GroupMember GM = new GroupMember();
            GM.GroupId = projMember.Core_IPS_Project__r.Core_IPS_GroupId__c;
            GM.UserorGroupId = projMember.Core_User__c;
            GMList.add(GM);
        }
       //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
        List<Database.SaveResult> results = Database.insert(GMList, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    String errorMessage = 'Error occurred: ' + err.getStatusCode() + ' - ' + err.getMessage()+' - '+err.getFields();
                    errorRecs.add(errorMessage);
                }  
            }
            else if(result.isSuccess()){
                
		groupMemSet.add(result.getId());
            }
        } 
        }
     catch(Exception e){
          String strDetails= 'Exception occured inside Core_IPS_InsertGroupMemberBatch Msg='+e.getMessage()+'stack:'+e.getStackTraceString();
            Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Case',null);
      }  
    }
    public void finish(Database.BatchableContext BC){
        //START - Added as part Active Project Member Fix - Retry Mechanism - TWC745-6567
        if(!errorRecs.isEmpty() && errorRecs!=null){
            String fullErrorMessage = String.join(errorRecs, '\n');
            List<String> userFailedList = new List<String>();
            List<String> userSuccessList = new List<String>();
            List<Core_IPS_Project_Member__c> projMemRecNewList = new List<Core_IPS_Project_Member__c>();
            if(!groupMemSet.isEmpty()){
                List<GroupMember> groupMemRecs = [SELECT Id,GroupId,UserOrGroupId FROM GroupMember WHERE Id IN: groupMemSet];
                for (GroupMember gm : groupMemRecs) {
                    userSuccessList.add(gm.GroupId+':'+gm.UserOrGroupId);
    }
            }    
                for(Core_IPS_Project_Member__c PrjMemberRec: projectMembersList){
                    String grpUserId = PrjMemberRec.Core_IPS_Project__r.Core_IPS_GroupId__c +':'+PrjMemberRec.Core_User__c;
                    if(!userSuccessList.isEmpty() && userSuccessList!=null && !userSuccessList.contains(grpUserId)){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                    else if(userSuccessList.isEmpty() || userSuccessList == null){
                        userFailedList.add(grpUserId);
                        projMemRecNewList.add(PrjMemberRec);
                    }
                }
                if (projMemRecNewList!=null && !projMemRecNewList.isEmpty() && retrycount < maxRetrycount) {
                    retrycount++;
                    DateTime dtCurrentTime = System.now().addminutes(Integer.valueOf(System.Label.Core_IPS_ProjectMemberSchedulerRetryTimeLimit));
                    String sHour = '', sMinute='', sDayOfMonth='', sMonth='', sYear='';
                    sMinute = String.ValueOf(dtCurrentTime.minute());
                    sHour = String.ValueOf(dtCurrentTime.hour());
                    sDayOfMonth = String.ValueOf(dtCurrentTime.day());
                    sMonth = String.ValueOf(dtCurrentTime.month());
                    sYear = String.ValueOf(dtCurrentTime.year());   
                    System.schedule('Schedule Batch Job that runs only once after 30 mins '+System.now() + ' ' + dtCurrentTime.milliSecond(), '0 '+sMinute+' '+sHour+' '+sDayOfMonth+' '+sMonth+' ?'+' '+sYear, new Core_IPS_InsertGroupMemberScheduler('SELECT Id,Core_IPS_Project__r.Core_IPS_GroupId__c,Core_User__c From Core_IPS_Project_Member__c WHERE ID',projMemRecNewList,retrycount));     
                } else {
                    fullErrorMessage = fullErrorMessage+ '\nFailed to Add Member in the Group Ids: '+ String.join(userFailedList, ',');
                    String excetionDeatils= '';
                    if(fullErrorMessage.length() >= 32768) {
                        excetionDeatils = fullErrorMessage.substring(0, 32767);
                    }    else {
                        excetionDeatils = fullErrorMessage;
                    }
                    string  Str = new Core_Exceptionclass().InsertException('','Core_IPS_InsertGroupMemberBatch','Core_IPS_Project_Member__c','','',excetionDeatils);
                }    
        }
    } //END
}