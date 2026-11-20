global without sharing class Core_IPS_InsertGroupMemberScheduler implements Schedulable{
    public final String Query;
    public List<Core_IPS_Project_Member__c> projectMembersList;
    public Integer retryCount = 0; //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    public Core_IPS_InsertGroupMemberScheduler(String q, List<Core_IPS_Project_Member__c> projectMembers,Integer rcnt){
        Query=q;
        projectMembersList = projectMembers;
        retryCount = rcnt; //Added as part of Active Project Member Fix - Retry Mechanism - TWC745-6567
    }
    global void execute(SchedulableContext SC){ 
       Core_IPS_InsertGroupMemberBatch b = new Core_IPS_InsertGroupMemberBatch(Query, projectMembersList,retryCount);
        database.executebatch(b);
    }
 }