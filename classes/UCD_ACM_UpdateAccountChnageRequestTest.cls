@isTest
public class UCD_ACM_UpdateAccountChnageRequestTest {
    
       /* @isTest static  void getApprovalAccount() {
          // Create Business Type
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV'));
        insert businessTypes;
        
        Account_Create_Request__c c = new Account_Create_Request__c();
       // c.Core_CIM_ID__c = '12345';
        //c.name = 'Sample Account';
        c.Customer_Process_Engagement__c= 'DIR_PRC_EXCPT';    
        c.Street__c= 'Whitefield';
        c.City__c= 'Bangalore';
        c.Country__c = 'USA';
        system.assertEquals('USA', c.Country__c);
            
        insert c;
        
        /* Account_Create_Request__c c1 = new Account_Create_Request__c();
        c1.name = 'account1234';
        c1.Status__c = 'New';
        insert c1; */
         
           // try{
          /*  Test.startTest();
            UCD_ACM_UpdateAccountChnageRequest.approveAccountChangeRequest(c.id);
           // UCD_ACM_UpdateAccountChnageRequest.approveAccountChangeRequest(c1.id);
         //   UCD_ACM_UpdateAccountChnageRequest.approveAccountChangeRequest(null);
            Test.stopTest();
       //  }catch(exception e)
         //  {
           // system.debug('exception'+e);
           //} 

       //}*/
    /* @isTest static  void getRejectedAccount() {
        Account_Create_Request__c c = new Account_Create_Request__c();
       // c.Core_CIM_ID__c = '12345';
        //c.name = 'Sample Account';
        c.Customer_Process_Engagement__c= 'DIR_PRC_EXCPT';    
        c.Street__c= 'Whitefield';
        c.City__c= 'Bangalore';
        c.Country__c = 'USA';
        c.Rejected_Reason__c = 'Test Rejected';
        system.assertEquals('USA', c.Country__c);
           
        insert c;
         
        /* Account_Create_Request__c c1 = new Account_Create_Request__c();
        c1.name = 'account1';
        c1.Status__c = 'Rejected';
        c1.Rejected_Reason__c = 'Rejected 2';
        insert c1; */
			         
       // try{    
          /*  Test.startTest();
            UCD_ACM_UpdateAccountChnageRequest.rejectAccountChangeRequest(c.id,c.Rejected_Reason__c);
         //	UCD_ACM_UpdateAccountChnageRequest.rejectAccountChangeRequest(c1.id,c1.Rejected_Reason__c);
         //   UCD_ACM_UpdateAccountChnageRequest.rejectAccountChangeRequest(null,null);
            Test.stopTest();
      //  }catch(exception e)
        //  {
          //  system.debug('exception'+e);
          //} 
         
       }*/
    
       
}