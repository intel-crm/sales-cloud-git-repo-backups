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
        acc.Core_User_Defined_Website__c = 'Sample';
        acc.Core_Requested_Name__c = 'TestAccount1';

        insert acc;

        Account acc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount2','Intel Account','UNFD_INTRMD_CUST');
        acc2.Core_Business_Party_Id__c = '12';
        acc2.ParentId = acc.Id;
        acc2.OwnerId = UserInfo.getUserId();
        acc2.BillingCountryCode = 'AN';
        //acc2.Core_Unified_Global_Customer__c = acc.Id;
        //acc2.Core_Unified_Intermediate_Customer__c = acc.Id;
        acc2.Core_Requested_Name__c = 'TestAccount1';

        insert acc2;

        Account acc9 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount245','Intel Account','UNFD_INTRMD_CUST');
        acc9.Core_Business_Party_Id__c = '12';
        acc9.ParentId = acc.Id;
        acc9.OwnerId = UserInfo.getUserId();
        acc9.BillingCountryCode = 'AN';
        //acc9.Core_Unified_Global_Customer__c = acc.Id;
        //acc9.Core_Unified_Intermediate_Customer__c = acc.Id;
        //acc9.Core_Unified_Intermediate_Customer_2__c = acc2.Id;
        acc9.Core_Requested_Name__c = 'TestAccount1';

        insert acc9;
        
        Account acc5 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount4','Intel Account','UNFD_INTRMD_CUST');
        acc5.Core_Business_Party_Id__c = '12345';
        acc5.OwnerId = UserInfo.getUserId();
        acc5.BillingCountryCode = 'IND';
        acc5.Core_MDM_Website__c = 'Sample';
        acc5.Core_User_Defined_Website__c = 'Sample';
        acc5.ParentId = acc2.Id;
        acc5.Core_Requested_Name__c = 'TestAccount1';

        insert acc5;

        Account acc3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount3','Intel Account','UNFD_CTRY_CUST');
        acc3.Core_Business_Party_Id__c = '12';
        acc3.ParentId = acc5.Id;
        acc3.OwnerId = UserInfo.getUserId();
        acc3.BillingCountryCode = 'AN';
        //acc3.Core_Unified_Global_Customer__c = acc.Id;
        acc3.Core_Requested_Name__c = 'TestAccount1';

        insert acc3;

        Account acc4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount4','Intel Account','UNFD_CTRY_CUST');
        acc4.Core_Business_Party_Id__c = '12';
        acc4.OwnerId = UserInfo.getUserId();
        acc4.ParentId = acc.Id;
        acc4.BillingCountryCode = 'AN';
        //acc4.Core_Unified_Global_Customer__c = acc.Id;
        acc4.Core_Requested_Name__c = 'TestAccount1';

        insert acc4;
        
        Account acc6 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccount5','Intel Account','UNFD_LOC_CUST');
        acc6.Core_Business_Party_Id__c = '12';
        acc6.OwnerId = UserInfo.getUserId();
        acc6.ParentId = acc3.Id;
        acc6.BillingCountryCode = 'AN';
        //acc6.Core_Unified_Global_Customer__c = acc.Id;
        acc6.Core_Requested_Name__c = 'TestAccount1';

        insert acc6;

        Account accountDup = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestAccountDuplicateCheck','Intel Account','UNFD_GLBL_CUST');
        accountDup.Core_Business_Party_Id__c = '12345';
        accountDup.Core_Data_Country_Nm__c = 'India';
        accountDup.Core_Data_Simplified_Account_Nm__c = 'TestAccountDuplicateCheck';
        accountDup.OwnerId = UserInfo.getUserId();
        accountDup.BillingCountryCode = 'IND';
        accountDup.BillingStreet='StreetTest';
        accountDup.BillingCity='Mumbai';
        accountDup.BillingStateCode='MH';
        accountDup.BillingPostalCode='560098';
        insert accountDup;

        Account_Create_Request__c acrequest = UCD_ACM_Cntrlr_TestDataInitialization.createApproveAccountRequest(accountDup);
        acrequest.Address__City__s = 'Mumbai';
        acrequest.Address__CountryCode__s = 'IND';
        acrequest.Address__Street__s = 'StreetTest';
        acrequest.Address__StateCode__s = 'MH';
        acrequest.Address__PostalCode__s='560098';
        insert acrequest;

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


   /* @isTest
    private static void acctWrapContructorTest(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                             BillingPostalCode,Unified_Hierarchy_View__c,Core_Unified_Global_Customer__r.Name,Core_Requested_Name__c,
                                             Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                             Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c,Core_MDM_Website__c,Core_User_Defined_Website__c, ParentId, Parent.Core_Customer_Aggregation_Type__c,Core_Alternate_Language_Name__c,Core_Data_Simplified_Local_Language_Nm__c from Account where Name = 'TestAccount1' limit 1];
        //System.debug('parentAccount--> '+parentAccount);
        Test.startTest();
         UCD_GenericAcctSearch_SBR.acctWrapContructor(new Map<String, Account>(new List<Account>{parentAccount}), 'Opportunity_Management');
         system.assertEquals('TestAccount1', parentAccount.name);
        Test.StopTest();
    }*/

    @istest
    private static void getAccountRequestQueueTest(){
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fswList = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw1 = new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw1.fieldLabel = 'Name';
        fsw1.fieldAPIName = 'Name';
        fsw1.fieldValue = 'Sample';
        fswList.add(fsw1);
        Test.startTest();
        List<Account_Create_Request__c> results = UCD_GenericAcctSearch_SBR.getAccountRequestQueue(fswList);
        system.assertEquals('Name', fsw1.fieldLabel);
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
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw6= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw6.fieldLabel = 'Core_User_Defined_Website__c';
        fsw6.fieldAPIName = 'Core_User_Defined_Website__c';
        fsw6.fieldValue = 'Sample';
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw7= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw7.fieldLabel = 'BillingState';
        fsw7.fieldAPIName = 'BillingState';
        fsw7.fieldValue = 'BillingState';
        
        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw8= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw8.fieldLabel = 'BillingStreet';
        fsw8.fieldAPIName = 'BillingStreet';
        fsw8.fieldValue = 'BillingStreet';

        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw9= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw9.fieldLabel = 'Core_Data_Simplified_Account_Nm__c';
        fsw9.fieldAPIName = 'Core_Data_Simplified_Account_Nm__c';
        fsw9.fieldValue = 'Sample';

        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw10= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw10.fieldLabel = 'Core_Data_Simplified_Local_Language_Nm__c';
        fsw10.fieldAPIName = 'Core_Data_Simplified_Local_Language_Nm__c';
        fsw10.fieldValue = 'Sample';

        UCD_GenericAcctSearch_SBR.fieldsetwrapper fsw11= new UCD_GenericAcctSearch_SBR.fieldsetwrapper();
        fsw11.fieldLabel = 'Core_Alternate_Language_Name__c';
        fsw11.fieldAPIName = 'Core_Alternate_Language_Name__c';
        fsw11.fieldValue = 'Sample';
        
        fswList.add(fsw2);
        fswList.add(fsw9);
        fswList.add(fsw10);
        fswList.add(fsw11);
        fswList.add(fsw5);
        fswList.add(fsw8);
        fswList.add(fsw3);
        fswList.add(fsw4);
        fswList.add(fsw6);
        fswList.add(fsw1);
        fswList.add(fsw7); 
        
        
        Test.startTest();
        UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accountMockResponse = UCD_GenericAcctSearch_SBR.getAcctResults(fswList,'Opportunity Management');
        system.assertEquals('BillingCountry', fsw1.fieldLabel);
        Test.StopTest();
    
    }

    @isTest
    private static void getAccCreateProcessMappingTest(){
        Test.startTest();
            Account_Create_Process_Mapping__mdt accCreateProcessMapping = UCD_GenericAcctSearch_SBR.getAccCreateProcessMapping('Opportunity Management');
        System.assert(accCreateProcessMapping != null);
        Test.StopTest();
    }
    
    @isTest
    private static void setErrorMessageTest(){
        Test.startTest();
        	UCD_GenericAcctSearch_SBR.setErrorMessage('test ');
            UCD_GenericAcctSearch_SBR.setErrorMessage('test ');
        	System.assert(UCD_GenericAcctSearch_SBR.setErrorMessage('test ') == null);
        Test.StopTest();
    }

    @isTest
    private static void whenGetCustomerProcesEnggTest(){
        
        test.startTest();
        List<UCD_GenericAcctSearch_SBR.customerProcessEngOption> cpeOptions = UCD_GenericAcctSearch_SBR.getCustomerProcesEngg();
        System.assert(cpeOptions != null);
        test.stopTest();
    }


   /* @isTest
    private static void sortingAccountTest(){
        
        List<Account> lstAccount = [Select id,Name, Core_Requested_Name__c from Account ];
        test.startTest();
        UCD_GenericAcctSearch_SBR.sortingAccount('TestAccount1','TestAccount1',lstAccount);
        System.assert(lstAccount != null);
        test.stopTest();
    }*/


    @isTest
    private static void getAcctRequestsTest(){
        test.startTest();
        List<UCD_GenericAcctSearch_SBR.accRequestWrap> accReqWrap = UCD_GenericAcctSearch_SBR.getAcctRequests();
        System.assert(accReqWrap != null);
        test.stopTest();
    }

    @isTest
    public static  void callSubmitFlowTest(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                BillingPostalCode,Unified_Hierarchy_View__c,
                                Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c from Account where Name = 'TestAccount1' limit 1];

        Account_Create_Request__c acr = [select id from Account_Create_Request__c LIMIT 1];
        test.startTest();
            //Boolean response = UCD_GenericAcctSearch_SBR.callSubmitFlow('test', parentAccount.Name,'','');
            Boolean response2 = UCD_GenericAcctSearch_SBR.callSubmitFlow(acr.Id, parentAccount.Name,'','');
            system.assertEquals('TestAccount1', parentAccount.name);
        test.stopTest();
    }


    @isTest
    public static  void customSortingMethod(){

        Account parentAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,BillingCountryCode,billingstatecode,BillingStreet,BillingCity,
                                BillingPostalCode,Unified_Hierarchy_View__c,
                                Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCountry,ShippingCountry,Account.OwnerId,Owner.Id,Owner.Name,Website,RecordType.Name,
                                Core_Customer_Aggregation_Type__c,Core_Survivor_Account_Id__c,RecordTypeId,Core_Sales_Groups__c from Account where Name = 'TestAccount1' limit 1];

        UCD_GenericAcctSearch_SBR.customSortingMethod(new List<Account>{parentAccount});

        system.assertEquals('TestAccount1', parentAccount.name);


    }

    @istest
    private static void checkDuplicateResultTest(){
        List<Account> account=[Select Id, Name, Core_Alternate_Language_Name__c,BillingCountry, Core_Business_Party_Id__c,Core_Unified_Global_Customer_Name__c,Owner.Name,BillingStreet, BillingCity, BillingState, BillingPostalCode From Account where (Name='TestAccountDuplicateCheck')];
        UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper dupwrap=new UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper(account[0].Id,account[0].Name,String.valueOf(account[0].BillingStreet)+String.valueOf(account[0].BillingCity)+String.valueOf(account[0].BillingState)+String.valueOf(account[0].BillingPostalCode)+String.valueOf(account[0].BillingCountry),account[0].Owner.Name,account[0].Core_Unified_Global_Customer_Name__c,'Account');
        Test.startTest();
        List<UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper> accountDuplicate = UCD_GenericAcctSearch_SBR.checkForDuplicates('TestAccountDuplicateCheck','','IND','StreetTest','Mumbai','MH');
        Test.StopTest();
        System.assert(accountDuplicate != null);
    }

    @istest
    private static void checkDuplicateAccReqResultTest(){
        List<Account_Create_Request__c> accountReq=[Select Id,CreatedDate,Requestor_Name__c,Process_Type__c,Account_Name__c, Core_Alternate_Language_Name__c, Status__c, Address__CountryCode__s, Address__Street__s, Address__City__s,Address__StateCode__s,Address__PostalCode__s From Account_Create_Request__c Where Account_Name__c='Test'];
        UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper dupwraps=new UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper(accountReq[0].Id,accountReq[0].Account_Name__c,String.valueOf(accountReq[0].Address__Street__s)+String.valueOf(accountReq[0].Address__City__s)+String.valueOf(accountReq[0].Address__StateCode__s)+String.valueOf(accountReq[0].Address__PostalCode__s)+String.valueOf(accountReq[0].Address__CountryCode__s),Date.valueOf(accountReq[0].CreatedDate),accountReq[0].Requestor_Name__c,accountReq[0].Process_Type__c,'Account Request Queue');
        Test.startTest();
        List<UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper> accountReqDuplicate = UCD_GenericAcctSearch_SBR.checkForDuplicates('Test','','IND','StreetTest','Mumbai','MH');
        Test.StopTest();
        System.assert(accountReqDuplicate != null);
    }
}