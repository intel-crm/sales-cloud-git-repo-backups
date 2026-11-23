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
public class Core_ContactGECQueueable implements Queueable,Database.AllowsCallouts{
    private List<Contact> ConIdList;
    public List<Contact> FailedConLstt{get;set;}
    Public List<Core_Contact_GEC_Staging__c> FailedGECStagingrec{get;set;}
    
    public Core_ContactGECQueueable(List<Contact> records){
        this.ConIdList = records;    
    }
    
    public void execute(QueueableContext context){
        
        FailedConLstt= new List<Contact>();
		FailedGECStagingrec = new List<Core_Contact_GEC_Staging__c>();
        System.debug('ConIdList'+ConIdList.size());
        List<Core_GEC_Contact_wrapper> FailedGECConlst = new List<Core_GEC_Contact_wrapper>();
        FailedGECConlst = Core_SendContact_to_AGS_onGECChange.SendGECInfoTOAGS(ConIdList);
        system.debug('******FailedGECConlst'+FailedGECConlst);
        // FailedConLstt.addAll(wraplst.FailedConLst); 
        for(Core_GEC_Contact_wrapper wraplst: FailedGECConlst){
            system.debug('******FailedGECConlst'+wraplst.FailedConLst);
            if(wraplst.FailedConLst !=null && wraplst.FailedGECStagingrec !=null ){
            FailedConLstt.addAll(wraplst.FailedConLst);
            FailedGECStagingrec.addAll(wraplst.FailedGECStagingrec);
            }
            
        }
        system.debug('*****Conlst'+FailedConLstt);
        system.debug('*****FailedGECStagingrec'+FailedGECStagingrec);
        
        
        if(FailedConLstt.size()>0 && FailedGECStagingrec.size()>0){  
            insert FailedGECStagingrec;
            if(!Test.isRunningTest()){
            Core_ContactGECQueueable_Retry obj= new Core_ContactGECQueueable_Retry(FailedConLstt,FailedGECStagingrec);
            system.enqueuejob(obj);
            }
            
        }
        
    }
    
    
}