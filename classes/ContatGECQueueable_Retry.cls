public class ContatGECQueueable_Retry implements Queueable,Database.AllowsCallouts{
      private List<Contact> ConIdList;
    
    public ContatGECQueueable_Retry(List<Contact> records){
        this.ConIdList = records;    
    }
     
    public void execute(QueueableContext context){
        System.debug('Retry Queuable class');
        Core_SendContact_to_AGS_onGECChange.SendGECInfoTOAGS(ConIdList);
        
    }


}