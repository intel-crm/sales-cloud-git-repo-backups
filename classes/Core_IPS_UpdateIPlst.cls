/**************************************************************
 * version : 1
 * Created : 13/11/2018
 * ceated by : Orion
 * Developer : Vamsi
 * Function  : to Update the Intrested parties list.  
 */
public class Core_IPS_UpdateIPlst implements Queueable  {
    List<Core_IPS_Case_Interested_Party__c> IPUpdateList = New List<Core_IPS_Case_Interested_Party__c>();
    public Core_IPS_UpdateIPlst(List<Core_IPS_Case_Interested_Party__c> localList){
       IPUpdateList= localList;
    }
public void execute(QueueableContext context) {    
    List<Id> ids = new List<Id>(); // Fixed by Phani for exceptional handling
    for(Core_IPS_Case_Interested_Party__c temp: IPUpdateList)
    {
        ids.add(temp.id);
    }
    List<Core_IPS_Case_Interested_Party__c> IPUpdateList_new = [Select id from Core_IPS_Case_Interested_Party__c where id IN :ids];
   if(IPUpdateList_new != null && IPUpdateList_new.size()>0){
    update IPUpdateList_new;
    }
    
  }
}