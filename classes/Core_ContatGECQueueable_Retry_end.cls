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
public class Core_ContatGECQueueable_Retry_end implements Queueable,Database.AllowsCallouts {
    private List<Contact> ConIdList;
    public List<Contact> FailedConLstt{get;set;}
    Public List<Core_Contact_GEC_Staging__c> FailedGECStagingrec;
	Public List<Core_Contact_GEC_Staging__c> UpdateRetryCntrLst;

	
	 public Core_ContatGECQueueable_Retry_end(List<Contact> records,List<Core_Contact_GEC_Staging__c>FailedGECStagingrec){
        this.ConIdList = records; 
        this.FailedGECStagingrec=FailedGECStagingrec;
    }
    
    
       public void execute(QueueableContext context){
         
        FailedConLstt= new  List<Contact>();
       // FailedGECStagingrec = new List<Core_Contact_GEC_Staging__c>();
        UpdateRetryCntrLst= new List<Core_Contact_GEC_Staging__c>();
        //System.debug('****Retry Queuable classW End');
        List<Core_GEC_Contact_wrapper> FailedGEClst3= Core_SendContact_to_AGS_onGECChange.SendGECInfoTOAGS(ConIdList);
        //System.debug('****FailedGEClst3'+FailedGEClst3);
        
        for(Core_GEC_Contact_wrapper wraplst: FailedGEClst3){
            //System.debug('******FailedGECConlst'+wraplst.FailedConLst);
            if(wraplst.FailedConLst !=null){
            
            FailedConLstt.addAll(wraplst.FailedConLst);
            }
       
            
        }
        //System.debug('*****Conlst'+FailedConLstt);
        //System.debug('*****FailedGECStagingrec'+FailedGECStagingrec);
        
         if(FailedGECStagingrec.size()>0){  
		     
			 for(Core_Contact_GEC_Staging__c Gecstage :FailedGECStagingrec){
				 
                 Core_Contact_GEC_Staging__c Gec= new Core_Contact_GEC_Staging__c();
                   //System.debug('******id'+Gecstage.Id);
				 Gec.Core_GEC_Retry_Counter__c=Gecstage.Core_GEC_Retry_Counter__c+1;
                 Gec.id=Gecstage.Id;
               
				 UpdateRetryCntrLst.add(Gec); 
			 }
            update UpdateRetryCntrLst;  
        }
	
		
        
        
    } 
    


}