/*global class PSG_BatchForDelegation implements Database.Batchable<Sobject>, Database.Stateful,Schedulable{
	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id,core_cpq_delegated_For__c, End_Date__c, Start_Date__c, core_cpq_delegated_to__c from core_user_delegation__c 
                                         WHERE  Start_Date__c = TODAY OR End_Date__c = TODAY]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> sobjLst){        
        List<core_user_delegation__c> userDelegationList = (List<core_user_delegation__c>) sobjLst;
        List<core_user_delegation__c> createSharingList = new List<core_user_delegation__c>();
        List<core_user_delegation__c> deleteSharingList = new List<core_user_delegation__c>();
        
        for(core_user_delegation__c delegate:userDelegationList){
            if((delegate.Start_Date__c) == System.today()){
                createSharingList.add(delegate);
            }
            else if((delegate.End_Date__c) == System.today()){
                deleteSharingList.add(delegate);
            }
        }
        if(!createSharingList.isEmpty()){
        	//PSG_UserDelegationBusinessLogic.createSharingForDelegates(createSharingList,'grant');
        }
        if(!deleteSharingList.isEmpty()){
        	//PSG_UserDelegationBusinessLogic.createSharingForDelegates(deleteSharingList,'revoke');   
        }    
    }
    public void finish(Database.BatchableContext bc) {
     
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PSG_BatchForDelegation(), 50);
    }
}*/
@isTest
public class PSG_BatchForDelegation{

}