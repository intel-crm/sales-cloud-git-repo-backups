/*********************************************************************************************************************
Class Name  : PRM_IPA_Utility_Test
Version       : 1.0
Created Date  : Jan 2022
Function      : Test Class for 'PRM_IPA_Utility'
*********************************************************************************************************************/
@isTest
public class PRM_IPA_Utility_Test{
    @testSetup
    //test data creation
    static void setupDataCreation(){
        Account acc = PRM_TestUtility.getAccount();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.RecordTypeId = accountRecordType;
        insert(acc);    
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testuser@gmail.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
       // con.Core_IPA_Partner_Role__c = 'Service Provider';
        con.Core_IPA_PartnerRole__c = 'Distributor';
        con.Core_Login_Id__c = 'abc';
         con.mailingcountry='India';
        insert con;
        //system.debug(con);

        ChannelProgram cp1 = new ChannelProgram();
        cp1.Name=System.Label.PCC_Channel_Program_Name;
        cp1.IsActive = true;
        insert cp1;
        
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuser@gmail.com';
        newRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest.PRM_Salesforce_ID__c = acc.Id;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
         insert(newRequest);
    }

    @isTest static void CheckforSysAcc(){
        DateTime reqTime = System.now();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        List<String> regRequest = new List<String>();
        Test.startTest();
       
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser@gmail.com' LIMIT 1];
        regRequest.add(rr.PRM_Email_ID__c);
        String recordId = rr.id;
        String externalId = '12345';
        String callType= 'POST';
        String module = 'IPA';
        String reqPayload = 'Test';
        String respPayload = 'Test';
        Integer respCode =200;
        String errorMsg = '';
        String systemName ='AEM';
        String className = 'PRM_IPA_Utility';
        String requestedURL = 'services/apex/test/ddr_v1';
	Id cpId = [SELECT Id FROM ChannelProgram WHERE Name = :System.label.PCC_Channel_Program_Name LIMIT 1].Id;   
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className);
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className,System.now(),System.now());
        PRM_IPA_Utility.systemAccountDetails(regRequest);
	PRM_IPA_Utility.createPCCIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className,reqTime,System.now(), true,cpId,requestedURL);
        Test.stopTest();
    }
    @isTest static void CheckforSysAcc10(){
        DateTime reqTime = System.now();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        List<String> regRequest = new List<String>();
        Test.startTest();
        
        String requestPayload = 'AccountName:'+'Test'+', AccountAddress:'+'test'+', AccountURL:'+'test'+', BizOrgType:'+'test'+', EmailAddress:'+'test@test.com'+', SearchLimit:'+'10'+',MinimumSearchScore :'+'15';
        
        
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser@gmail.com' LIMIT 1];
        regRequest.add(rr.PRM_Email_ID__c);
        String recordId = rr.id;
        String externalId = '12345';
        String callType= 'POST';
        String module = 'IPA';
        String reqPayload = requestPayload;
        String respPayload = 'Test';
        Integer respCode =200;
        String errorMsg = '';
        String systemName ='CIM';
        String className = 'PRM_CIMAccountSearch';
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className,reqTime,System.now());
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,'PRM_CIMCallout',reqTime,System.now());
        PRM_IPA_Utility.systemAccountDetails(regRequest);
        Test.stopTest();
    }
    
    
    @isTest static void CheckforSysAcc1(){
        DateTime reqTime = System.now();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        List<String> regRequest = new List<String>();
        Test.startTest();
        
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser@gmail.com' LIMIT 1];
        regRequest.add(rr.PRM_Email_ID__c);
        String recordId = rr.id;
        String externalId = '12345';
        String callType= 'POST';
        String module = 'IPA';
        String reqPayload = '{"MinimumSearchScore":10,"MaximumNumberOfRecordsToReturn":"25","MandatoryFieldRestrictionLevel":20,"IncludeDefaultAttributesForSourceTypes":false,"CallingSourceSystem":"SLSCLD","BusinessOrganization":{"PhysicalAddress":{"PostalCd":"98765","PhysicalStreetAddressTxt":"rtyu","CountrySubdivisionCd":"AP","Country2Cd":"IN","CityNm":"kjhgf"},"ElectronicAddress":[{"ElectronicAddressTypeCd":"URL","ElectronicAddressTxt":null}],"BusinessOrganizationNm":"TestIpa"},"AsynchronousRequestId":null}';
        String respPayload = 'Test';
        Integer respCode =200;
        String errorMsg = '';
        String systemName ='CIM';
        String className = 'PRM_CIMCallout';
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className);
        //PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,'PRM_Account_Contact_Profiles');
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,'PRM_CIMAccountSearch');     
        PRM_IPA_Utility.systemAccountDetails(regRequest);
        Test.stopTest();
    }
    
    
    @isTest static void CheckforSysAcccim(){
        DateTime reqTime = System.now();
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        List<String> regRequest = new List<String>();
        Test.startTest();
        
        PRM_Registration_Request__c rr = [Select RecordTypeId,PRM_Contact_Country__c,PRM_Channel_Program__c, PRM_First_Name__c,PRM_Matching_Contact__c,PRM_Person_Phone_Number__c,PRM_CIM_ID__c,PRM_EmailVerifiedDateTime__c,PRM_Email_Verification_Criteria__c,PRM_EV_Token__c,PRM_Email_ID__c,PRM_Preferred_Language__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'testuser@gmail.com' LIMIT 1];
        regRequest.add(rr.PRM_Email_ID__c);
        String recordId = rr.id;
        String externalId = '12345';
        String callType= 'POST';
        String module = 'IPA';
        String reqPayload = '{  "KeyInput": {  "InputField": "EMAILID",  "InputValue": "adminregfortracker@gnil.com",  "IsProgramBased": "true",  "Name": "IPA"  }  }';
        String respPayload = '{  "KeyInput": {  "InputField": "EMAILID",  "InputValue": "adminregfortracker@gnil.com",  "IsProgramBased": "true",  "Name": "IPA"  }  }';
        Integer respCode =200;
        String errorMsg = '';
        String systemName ='CIM';
        String className = 'PRM_Account_Contact_Profiles';
        PRM_IPA_Utility.createIntegrationLog(recordId,callType,module,reqPayload,respPayload,respCode,systemName,className,reqTime,System.now());
        PRM_IPA_Utility.systemAccountDetails(regRequest);
        Test.stopTest();
    }
    
     @isTest static void testOPIDReccheck(){
         
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();        
        
        Account parent1 = new Account();
        parent1.RecordTypeId = recordTypeIdPagAccount;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_Deactivated__c = false;
        insert parent1;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='dfsdsds';
        acc.BillingCountry='India';
        acc.BillingStreet='5th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='760037';
        acc.Core_User_Defined_Website__c = 'www.test100.com';
        insert(acc);
        
        
        ChannelProgram cp = new ChannelProgram(); 
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        
       /* PRM_Value_Exchange_Recommendation__c recm1 = new PRM_Value_Exchange_Recommendation__c();
        recm1.PRM_Account_Id__c = acc.Id;
        recm1.PRM_Tier_Id__c = cpl.Id;
        recm1.PRM_Partner_Role_Nm__c = acc.Core_IPA_Partner_Role__c;
        recm1.PRM_Recommendation_Type_Nm__c = 'OPID';
        recm1.PRM_Recommendation_Status_Nm__c = 'In Process';
        recm1.PRM_Grouping_Method_Nm__c = 'LINEOFBUSNS';
        insert recm1;*/ //Priya
        
        PRM_IPA_Utility.createTrackerInstance(null, null, null, acc.Id,acc.Id,null, null,null,true,null, null);
        PRM_IPA_Utility.createTrackerInstance(null, null, acc.Id, null,null, null,null,true,null, null,null);
        PRM_IPA_Utility.createTrackerInstance(null,null,null, null, acc.Id, true,null, false);
        PRM_IPA_Utility.createTrackerInstance(null, null, null, acc.Id, null, null, null, null, true, null, null, null);
    }
    
    
    @isTest
    public static void getACMListTest(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        Id accId = testAccount.Id;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_eRPM_Language_Code__c='Eng';
         cont.mailingcountry='India';
        insert cont;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c ='TEst';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Distributor';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest1.PRM_Status_Reason_Txt__c ='TEst';
        acmList.add(acctChnlMemTest1);
        insert acmList;
        
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'ttestuser@gmail.com';
        newRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = '';
        newRequest.PRM_Matching_Contact__c = cont.Id;
        newRequest.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        newRequest.PRM_Salesforce_ID__c = testAccount.Id;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.PRM_Channel_Program__c = cpTest.Id;
        newRequest.PRM_Partner_Role__c = 'Service Provider';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newRequest;
        
        String partnerRole = 'Cloud Service Provider (CSP)';
        Boolean inactiveIndicator = true;
        Boolean inactiveIndicator1 = null;
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        /*User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                    UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser;
        Id userId=partnerUser.Id;*/
        string primeName = 'testusername';
        string primeName1 = null;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_Status_Reason_Txt__c ='TEst';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_InActive_Ind__c=false;
        //   acctContRel.PRM_Partner_Role__c = 'Service Provider';
       // insert acctContRel;
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        acrList.add(acctContRel);
        insert acrList;
        Campaign c = new Campaign();
        c.name = 'IPA - Proposal Test Sep21';
        insert c;
        
        Test.startTest();
        PRM_IPA_Utility.getACMList(acmList,newRequest);
        PRM_IPA_Utility.isAccountIPAForPartnerRole(testAccount,acmList,partnerRole);
        PRM_IPA_Utility.acmActiveCheck(acmList,newRequest);
        PRM_IPA_Utility.acrActiveCheck(acrList,newRequest);
        PRM_IPA_Utility.createLogEntry('asasasd', null, null, null, null, null);
        //PRM_IPA_Utility.returnReminderEmailInstances(c.Id,'BATCH_00160987');
        PRM_IPA_Utility.fourLetterLangCode(cont);
        PRM_IPA_Utility.getTwoLwtterCountryCode(cont.mailingcountrycode);
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountBenefitAssociationDataTest(){
        
        List<Account> accList = new List<Account>();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        accList.add(testAccount);
        insert accList;
        List<Id> accId = new List<Id>();
        accId.add(testAccount.Id);
        //insert accId;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        insert pbTest4;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = testAccount.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c ='TEst';
        abaList.add(abassociationTest2);
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaList;
        PRM_aba_TriggerHandler.executeTrigger = true;
        String limitCheck = 'ifwq p92';
        Test.startTest();
        PRM_IPA_Utility.getAccountBenefitAssociationData(accId);
        Test.stopTest();
    }
    
  
  /* @isTest
    static void testGetRemainingLimitsAPI() {
        // Create a mock HTTP response
        String mockResponse = '{ "DailyApiRequests": { "Remaining": 100 } }';
        Test.setMock(HttpCalloutMock.class, new PRM_IPA_Utility_HttpsMockCallout_Test(mockResponse));

        // Call the method being tested
        Integer remaining = PRM_IPA_Utility.getRemainingLimitsAPI('DailyApiRequests');

        // Assert the result
        System.assertEquals(100, remaining);
    }*/
    @isTest
    public static void testTierRankandPartnerRole()
    {
        Test.startTest();
        
        Integer highestTier=PRM_IPA_Utility.getHighestTierRank();
        System.assertEquals(5,highestTier);
        
        List<String> result=PRM_IPA_Utility.getApplicablePartnerRoleTier('Distributor','Partner');
        System.assertEquals(1,result.size());
        System.assert(result[0].contains('Distributor-Partner'));
        
        List<String> result1=PRM_IPA_Utility.getApplicablePartnerRoleTier('Distributor', 'Prestige');
        System.assertEquals(2,result1.size());
        
        Test.stopTest();
    }
        
}