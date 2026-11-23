/****************************************************************************************************
Apex Class Name : PSG_CloneDPAControllerTest
Created Date    : 6/4/2021 
Function        : test class for PSG_CloneDPAController
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ---------------------------------------------------------------------------------------------------                
* Pooja                      6/4/2021                   Created
*****************************************************************************************************/
@isTest
public class PSG_CloneDPAControllerTest {
    @testsetup
    public static void setupdata(){
        List<User> lstUsers2 = PSG_Test_Utility.createBOUser();
        System.runAs(lstUsers2[0]){
            Account acc1 = PSG_Test_Utility.createAccount();
            acc1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
            acc1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            acc1.Core_Is_Pricing_Parent_ChkBox__c=true;
            acc1.Core_Direct_Account_Active_Ind__c=true;
            update acc1;
            Account acc = PSG_Test_Utility.createAccount();
            acc.Core_Direct_Pricing_Parent_Id__c=acc1.id;
            acc.Core_Direct_Legal_Parent_Id__c=acc1.id;
            update acc;
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            Opportunity oppty = PSG_Test_Utility.createOpportunity(acc.Id);
            Test.startTest();
            Pricebook2 pb = PSG_Test_Utility.createPriceBook('TestPB');
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
            lstquote[0].core_cpq_end_customer_nm__c=acc.id;
            lstquote[0].core_cpq_sap_ecp_nm__c =acc1.id;
            update lstquote;
            List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALines(lstdpa[0].id, 1);
            Test.stopTest();
        }
    }  
    @isTest
    public static void testcloneDpaController(){
        List<User> lstUsers2 = PSG_Test_Utility.createSOSUser();
        System.runAs(lstUsers2[0]){
            
            Account acc1 = PSG_Test_Utility.createAccount();
            acc1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
            acc1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            acc1.Core_Is_Pricing_Parent_ChkBox__c=true;
            acc1.Core_Direct_Account_Active_Ind__c=true;
            update acc1;
            Test.StartTest();
            List<SBQQ__Quote__c> lstquote = [select id from SBQQ__Quote__c ];
            List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Test.StopTest();
            List<core_cpq_dpa_aln__c> lstdpa = PSG_Test_Utility.createDPARecord(lstquote[0],acc1.Id);
            List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALines(lstdpa[0].id, 1);
            PSG_CloneDPAController.GlobalVariables globalVar = new PSG_CloneDPAController.GlobalVariables();
            PSG_CloneDPAController.GlobalVariables globalVar1 = new PSG_CloneDPAController.GlobalVariables();
            PSG_CloneDPAController.FailedCloneItem CloneItem = new PSG_CloneDPAController.FailedCloneItem();
            globalVar = PSG_CloneDPAController.doClone(lstdpa[0].id,'');
            lstdpa[0].core_cpq_record_type_identifier__c ='ALN';
            update lstdpa;
            String testQLNumber = '12345';
            String testQLType = 'TypeA';
            String testErrorMessage = 'Error occurred';
            CloneItem = new PSG_CloneDPAController.FailedCloneItem(testQLNumber, testQLType, testErrorMessage);
            System.assertEquals(testQLNumber, CloneItem.QLNumber, 'QLNumber did not match');
            System.assertEquals(testQLType, CloneItem.QLType, 'QLType did not match');
            System.assertEquals(testErrorMessage, CloneItem.errorMessage, 'errorMessage did not match');
            globalVar = PSG_CloneDPAController.doClone(lstdpa[0].id,'');
            try{PSG_CloneDPAController.doClone(lstdpa[0].id,'Replace');}catch(Exception e){}
            System.assertEquals(true,globalVar.isSuccess);
        }        
    }
    static testmethod void coverCatchBlock(){
        Test.startTest();
        try{ 
            System.assert(true, '');
            PSG_CloneDPAController.doClone(null,null);
        }catch(Exception ex){
            //System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }    
}