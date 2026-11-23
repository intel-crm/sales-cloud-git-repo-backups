public class PCC_DesignRegistrationUpdateBatch implements Database.Batchable<sObject>{

  public Database.QueryLocator start(Database.BatchableContext BC){
      String idd = 'a3D2D000000AU4OUAW';
      String query = 'Select id,CreatedDate,Core_Accepted_By_Id__c,Core_Design_Registration_Status_Nm__c from Core_Design_Registration__c where Workflow_Status__c = null';
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<Core_Design_Registration__c> scope){
     List<Core_Design_Registration__c> desRegList = new List<Core_Design_Registration__c>();
     for(Core_Design_Registration__c desRec : scope){
     desRec.Core_Submission_Type__c = 'Portal';
     desRec.Core_DDR_Partner_Type_Txt__c = 'Distributor';
     //recordtype 
     
      if(desRec.Core_Accepted_By_Id__c != null && desRec.Core_Design_Registration_Status_Nm__c == 'Submitted'){
        desRec.Core_Design_Registration_Status_Nm__c = 'Design accepted';
    }  
     desRegList.add(desRec);
     List<Database.SaveResult> result = Database.update(desRegList, false);    
    }
    }

   public void finish(Database.BatchableContext BC){
   }
}