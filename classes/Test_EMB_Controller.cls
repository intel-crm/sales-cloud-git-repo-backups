public class Test_EMB_Controller {
public Executive_Meeting_Brief__c EMBRecord {get;set;}
    
    public Test_EMB_Controller(ApexPages.StandardController controller){
       Id recordID = controller.getID();
      EMBRecord = [SELECT CRM_Intels_Meeting_Objectives__c,CRM_Other_Partys_Meeting_Objectives__c FROM Executive_Meeting_Brief__c where id =:recordID];
    }
}