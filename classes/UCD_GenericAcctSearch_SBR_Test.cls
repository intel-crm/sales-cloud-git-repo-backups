@istest
public class UCD_GenericAcctSearch_SBR_Test {
   
    
    /*public static testMethod void whenGetAcctRequests(){
        Account acc1 = new Account();
        acc1.name = 'Sample';
        acc1.Core_Account_Tier__c = '';
        acc1.Industry = '';
        acc1.core_deactivated__c = FALSE;
        acc1.BillingCountry = 'USA';
        acc1.BillingState = 'OR';
        //acc1.billingcountrycode = 'India';
        //acc1.billingstatecode = 'AS';
        acc1.BillingPostalCode = '123';
        acc1.Core_CIM_ID__c = '123312';
        acc1.BillingCity='test';
        acc1.BillingStreet='test3';
        acc1.OwnerId = UserInfo.getUserId();
        acc1.Core_Business_Party_Id__c = '12345';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert acc1;
        
        Account_Create_Request__c req = new Account_Create_Request__c();
        //req.name = 'Sample Account';
        //req.Customer_Process_Engagement__c= 'DIR_PRC_EXCPT';    
        // req.Street__c= 'Whitefield';
        // req.City__c= 'Bangalore';
        req.Account_Name__c = 'Sample Account';
        req.Core_Sales_Groups__c = 'Global Strategic Account Sales Group';
        //req.Requested_Account__c = acc1.Id;
        req.Rejected_Reason__c = 'Test Rejected';
        req.Request_Flow_Status__c = 'Pending';
        req.Process_Type__c = 'Opportunity Management';
        req.Requestor_Name__c = UserInfo.getName();
        req.Requestor_Email__c = UserInfo.getUserEmail()+'.invalid';
        req.State__c = 'New';
        
        
        //req.Customer_Process_Engagement__c= 'DIR_PRC_EXCPT';
        insert req;
        
        test.startTest();
        List<UCD_GenericAcctSearch_SBR.accRequestWrap> accReqWrap = UCD_GenericAcctSearch_SBR.getAcctRequests();
        //  boolean flowResponse = UCD_GenericAcctSearch_SBR.callSubmitFlow(req.id,'Sample');
        test.stopTest();
    }*/
   
    /*
    public static testMethod void callSubmitFlowTest(){
        
        Account acc1 = new Account();
        acc1.name = 'Sample';
        acc1.Core_Account_Tier__c = '';
        acc1.Industry = '';
        acc1.core_deactivated__c = FALSE;
        acc1.BillingCountry = 'USA';
        acc1.BillingState = 'OR';
        //acc1.billingcountrycode = 'India';
        //acc1.billingstatecode = 'AS';
        acc1.BillingPostalCode = '123';
        acc1.Core_CIM_ID__c = '123312';
        acc1.BillingCity='test';
        acc1.BillingStreet='test3';
        acc1.OwnerId = UserInfo.getUserId();
        acc1.Core_Business_Party_Id__c = '12345';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        insert acc1;
        
        Account_Create_Request__c c = new Account_Create_Request__c();
       	// c.Core_CIM_ID__c = '12345';
        c.Account_Name__c = 'Sample Account';
        c.Customer_Process_Engagement__c= 'DIR_PRC_EXCPT';
        c.Country__c = 'USA';
        system.assertEquals('USA', c.Country__c);
            
        //insert c;
        
        test.startTest();
        try {
            Boolean response = UCD_GenericAcctSearch_SBR.callSubmitFlow('test', acc1.Name,'','');
            Boolean response2 = UCD_GenericAcctSearch_SBR.callSubmitFlow(c.Id, acc1.Name,'','');
        } catch (Exception ex) {
            System.assertNotEquals(null, ex.getMessage()); 
        }
        test.stopTest();
    }
    
    public static testMethod void callsorting(){
        test.startTest();
        UCD_GenericAcctSearch_SBR genAccSearch = new UCD_GenericAcctSearch_SBR();
        //genAccSearch.compareTo(null);

        test.stopTest();
    }

    */




    @TestSetup
    private static void setCommonData(){

        List<Account> lstAccount = new List<Account>();
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount1','Intel Account','UNFD_GLBL_CUST');
        acc.Core_Business_Party_Id__c = '12345';
        acc.Core_Data_Country_Nm__c = 'India';
        acc.Core_Data_Simplified_Account_Nm__c = 'TestDuplicateAccount';
        acc.OwnerId = UserInfo.getUserId();
        acc.BillingCountryCode = 'IND';
        acc.Core_MDM_Website__c = 'Sample';
        acc.Core_Requested_Name__c = 'TestAccount1';

        insert acc;

        Account acc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount2','Intel Account','UNFD_INTRMD_CUST');
        acc2.Core_Business_Party_Id__c = '12';
        acc2.ParentId = acc.Id;
        acc2.OwnerId = UserInfo.getUserId();
        acc2.BillingCountryCode = 'AN';
        acc2.Core_Unified_Global_Customer__c = acc.Id;
        acc2.Core_Unified_Intermediate_Customer__c = acc.Id;
        acc2.Core_Requested_Name__c = 'TestAccount1';

        insert acc2;

        Account acc5 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount4','Intel Account','UNFD_INTRMD_CUST');
        acc5.Core_Business_Party_Id__c = '12345';
        acc5.OwnerId = UserInfo.getUserId();
        acc5.BillingCountryCode = 'IND';
        acc5.Core_MDM_Website__c = 'Sample';
        acc5.ParentId = acc2.Id;
        acc5.Core_Requested_Name__c = 'TestAccount1';

        insert acc5;

        Account acc3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount3','Intel Account','UNFD_CTRY_CUST');
        acc3.Core_Business_Party_Id__c = '12';
        acc3.ParentId = acc5.Id;
        acc3.OwnerId = UserInfo.getUserId();
        acc3.BillingCountryCode = 'AN';
        acc3.Core_Unified_Global_Customer__c = acc.Id;
        acc3.Core_Requested_Name__c = 'TestAccount1';

        insert acc3;

        Account acc4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount4','Intel Account','UNFD_CTRY_CUST');
        acc4.Core_Business_Party_Id__c = '12';
        acc4.OwnerId = UserInfo.getUserId();
        acc4.ParentId = acc.Id;
        acc4.BillingCountryCode = 'AN';
        acc4.Core_Unified_Global_Customer__c = acc.Id;
        acc4.Core_Requested_Name__c = 'TestAccount1';

        insert acc4;
        
        Account acc6 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount5','Intel Account','UNFD_LOC_CUST');
        acc6.Core_Business_Party_Id__c = '12';
        acc6.OwnerId = UserInfo.getUserId();
        acc6.ParentId = acc3.Id;
        acc6.BillingCountryCode = 'AN';
        acc6.Core_Unified_Global_Customer__c = acc.Id;
        acc6.Core_Requested_Name__c = 'TestAccount1';

        insert acc6;

      

        Business_Types__c businessType = new Business_Types__c(Name='Test123',Is_Active__c=true,Business_Type_Code__c='test123');
        insert businessType;

        Business_Types__c businessType2 = new Business_Types__c(Name='Test123',Is_Active__c=true,Business_Type_Code__c='CPE');
        insert businessType2;

        Business_Types__c businessType3 = new Business_Types__c(Name='Test123',Is_Active__c=true,Business_Type_Code__c='DIR_PRC_EXCPT');
        insert businessType3;

        Account_Business_Types__c accountBusinessType = UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id, businessType.Id);
        insert accountBusinessType;

        Account_Create_Request__c acr = UCD_ACM_Cntrlr_TestDataInitialization.createApproveAccountRequest(acc);
        acr.Address__City__s = 'test';
        acr.Address__CountryCode__s = 'AFG';
        acr.Address__Street__s = 'test';
        insert acr;
    }


    @isTest
    private static void acctWrapContructorTest(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                             BillingPostalCode,Unified_Hierarchy_View__c,Core_Unified_Global_Customer__r.Name,Core_Requested_Name__c,
                                             Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                             Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c,Core_MDM_Website__c, ParentId, Parent.Core_Customer_Aggregation_Type__c from Account where Name = 'TestAccount1' limit 1];
        system.debug('parentAccount--> '+parentAccount);
        Test.startTest();
            UCD_GenericAcctSearch_SBR.acctWrapContructor(new Map<String, Account>(new List<Account>{parentAccount}), 'Opportunity_Management');
        Test.StopTest();
    }

    @istest
    private static void getAcctResultsTest(){
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fswList = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw1 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw1.fieldLabel = 'BillingCountry';
        fsw1.fieldAPIName = 'BillingCountry';
        fsw1.fieldValue = 'India';
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw2 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw2.fieldLabel = 'Name';
        fsw2.fieldAPIName = 'Name';
        fsw2.fieldValue = 'Sample';
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw3 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw3.fieldLabel = 'Website';
        fsw3.fieldAPIName = 'Website';
        fsw3.fieldValue = 'Sample';

        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw4= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw4.fieldLabel = 'Core_MDM_Website__c';
        fsw4.fieldAPIName = 'Core_MDM_Website__c';
        fsw4.fieldValue = 'Sample';

        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw5= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw5.fieldLabel = 'Core_Requested_Name__c';
        fsw5.fieldAPIName = 'Core_Requested_Name__c';
        fsw5.fieldValue = 'Sample';
        
        
        fswList.add(fsw2);
        fswList.add(fsw5);
        fswList.add(fsw1);
        fswList.add(fsw3);
        fswList.add(fsw4);

        
        
        Test.startTest();
        List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accountMockResponse = UCD_GenericAcctSearch_SBR.getAcctResults(fswList,'Opportunity Management');
        Test.StopTest();
    
    }

    @isTest
    private static void getAccCreateProcessMappingTest(){
        Test.startTest();
            Account_Create_Process_Mapping__mdt accCreateProcessMapping = UCD_GenericAcctSearch_SBR.getAccCreateProcessMapping('Opportunity Management');
        Test.StopTest();
    }

    @isTest
    private static void whenGetCustomerProcesEnggTest(){
        
        test.startTest();
        List<UCD_GenericAcctSearch_SBR.customerProcessEngOption> cpeOptions = UCD_GenericAcctSearch_SBR.getCustomerProcesEngg();
        test.stopTest();
    }


    @isTest
    private static void sortingAccountTest(){
        
        List<Account> lstAccount = [Select id,Name, Core_Requested_Name__c from Account ];
        test.startTest();
            UCD_GenericAcctSearch_SBR.sortingAccount('TestAccount1',lstAccount);
        test.stopTest();
    }


    @isTest
    private static void getAcctRequestsTest(){
        test.startTest();
        List<UCD_GenericAcctSearch_SBR.accRequestWrap> accReqWrap = UCD_GenericAcctSearch_SBR.getAcctRequests();
        test.stopTest();
    }

    @isTest
    public static  void callSubmitFlowTest(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                BillingPostalCode,Unified_Hierarchy_View__c,Core_Unified_Global_Customer__r.Name,
                                Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c from Account where Name = 'TestAccount1' limit 1];

        Account_Create_Request__c acr = [select id from Account_Create_Request__c LIMIT 1];
        test.startTest();
            //Boolean response = UCD_GenericAcctSearch_SBR.callSubmitFlow('test', parentAccount.Name,'','');
            Boolean response2 = UCD_GenericAcctSearch_SBR.callSubmitFlow(acr.Id, parentAccount.Name,'','');
        test.stopTest();
    }


    @isTest
    public static  void customSortingMethod(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                BillingPostalCode,Unified_Hierarchy_View__c,Core_Unified_Global_Customer__r.Name,
                                Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c from Account where Name = 'TestAccount1' limit 1];

        UCD_GenericAcctSearch_SBR.customSortingMethod(new List<Account>{parentAccount});

    }
}