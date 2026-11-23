@isTest
public class PCC_InvocableMethodTest {
@isTest
    static void testSetUp(){
        
    List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(3);
    Id dealRecordTypeIDLocked = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByName().get('Deal Registration - Locked').getRecordTypeId();
    DDRLst[0].recordTypeId =  dealRecordTypeIDLocked;
    DDRLst[0].Core_Accepted_By_Id__c = UserInfo.getUserId();
    DDRLst[0].PCC_Consumption_Countries__c = 'US';
     DDRLst[1].PCC_Consumption_Countries__c = 'US';
        DDRLst[2].PCC_Consumption_Countries__c = 'US';
         DDRLst[0].PCC_Current_EndCustomer_Product_Provider__c= 'US';
        DDRLst[1].PCC_Current_EndCustomer_Product_Provider__c= 'US';
        DDRLst[2].PCC_Current_EndCustomer_Product_Provider__c= 'US';
    insert DDRLst;
    PCC_DealFormValidationController.callDealApprovalProcess(DDRLst[0].id);
    List<PCC_InvocableMethods.ApprovalWrapper> approvalParam = new List<PCC_InvocableMethods.ApprovalWrapper>();

// Create a new instance of ApprovalWrapper and add it to the list
     PCC_InvocableMethods.ApprovalWrapper wrapper = new PCC_InvocableMethods.ApprovalWrapper();
     approvalParam.add(wrapper);  
    approvalParam[0].action = 'Reject';
    approvalParam[0].comments = 'hd';
    approvalParam[0].regId = DDRLst[0].id;
    PCC_InvocableMethods.approvalProcessActions(approvalParam);
        
    //PCC_InvocableMethods.isAuthorizedUser(DDRLst[0]); 
    PCC_InvocableMethods.isAuthorizedUser(DDRLst[1]); 
        
    system.assertequals(true,PCC_InvocableMethods.isAuthorizedUser(DDRLst[0]));    
}
}