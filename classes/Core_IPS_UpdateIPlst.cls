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
   if(IPUpdateList.size()>0){
    update IPUpdateList;
    }
    
  }
}