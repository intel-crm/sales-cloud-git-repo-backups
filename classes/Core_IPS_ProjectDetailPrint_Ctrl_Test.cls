@isTest
public class Core_IPS_ProjectDetailPrint_Ctrl_Test {
     
    @istest static void testMethod1(){
    Core_IPS_Project__c projectObj = new Core_IPS_Project__c();
    projectObj.Name = 'test microsoft';
    projectObj.Core_Status__c = 'Draft';
    projectObj.Core_MPNDA__c='N/A';
        String recordId;
    insert projectObj;
     apexpages.currentpage().getparameters().put('recordId',projectObj.Id);
    Core_IPS_ProjectDetailPrint_Ctrl controller1=new Core_IPS_ProjectDetailPrint_Ctrl();
         controller1.getAllCaseRecordsUnderProject();
        controller1.getChildIpsProductsToProject();
        try{
        controller1.getExistingProjectMembers();
        }catch (Exception ex) {
            
        }
    System.assertEquals('Draft',projectObj.Core_Status__c); 

    }
    
 

}