public class ContactMindsUpdate {
    public static void myCode(){
    //Date de = TODAY;
        Set<Id> accids = new Set<Id>();
        List<Contact> conList = [SELECT ID , AccountId ,Core_MINDS__c FROM Contact WHERE Core_IPS_Active__c = TRUE and AccountId !=null 
                                 AND LastModifiedDate != TODAY LIMIT 1000];
        system.debug('*********** REcords to be updated : '+conList.size());
        for(Contact con : conList){
            accids.add(con.AccountId);
        }
        Map<Id,Account> accMap =new Map<Id,Account>([Select Id, Core_Military_Aerospace_and_Government__c  FROm Account where Id IN: accids]);
        for(Contact con : conList){
            con.Core_MINDS__c = accMap.get(con.AccountId).Core_Military_Aerospace_and_Government__c;
        }
        database.update(conList,false);
    }
}