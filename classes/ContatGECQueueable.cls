/**************************************************************************************
Apex Class Name:  ContatGECQueable
Version     : 1.0 
Created Date: 27 Sep 2021
Function    : To send Contact GEC information to AGS
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             27/09/2020             Original Version
*************************************************************************************/
public class ContatGECQueueable implements Queueable,Database.AllowsCallouts{
      private List<Contact> ConIdList;
    
    public ContatGECQueueable(List<Contact> records){
        this.ConIdList = records;    
    }
     
    public void execute(QueueableContext context){
        System.debug('ConIdList'+ConIdList.size());
        Core_SendContact_to_AGS_onGECChange.SendGECInfoTOAGS(ConIdList);
        
    }


}