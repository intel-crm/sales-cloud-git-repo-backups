/****************************************************************************************************************************
Apex Class Name     : PRM_AddPartnerController_Test 
Version             : 1.0
Created Date        : 05 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre       05 Jan 2020                Test class to cover PRM_AddPartnerController class

****************************************************************************************************************************/

@isTest()
public class PRM_AddPartnerController_Test {     
    static testmethod void addPartnerTestMethod()
    {   
        Test.startTest();        
        Account testAccount = new Account(); //Account
        testAccount.Name='Big Net';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount.Core_Account_BU_Focus__c= 'CCG';
        testAccount.Core_IPA_Partner_Role__c='Service Provider';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingCountryCode='USA';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Tier__c = 'Tier1';
        testAccount.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        insert testAccount;
        
        Account testAccount1 = new Account(); //Account
        testAccount1.Name='Big Networks';
        testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
        testAccount1.Core_Account_BU_Focus__c= 'CCG';
        testAccount1.Core_IPA_Partner_Role__c='Distributor';
        testAccount1.BillingCity='City';
        testAccount1.BillingStreet='Street';
        testAccount1.BillingCountry='USA';
        testAccount1.BillingCountryCode='USA';
        testAccount1.BillingPostalCode='Postal code';
        testAccount1.Core_Account_Tier__c = 'Tier1';
        testAccount1.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        insert testAccount1;
        
        
        ChannelProgram cprogram = new ChannelProgram();  //Channel Program 
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership(); //Account Channel Membership
        acm.PRM_Account_Id__c = testAccount.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Channel_Program_Level_Id__c = level.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        insert acm;
        
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership(); //Account Channel Membership
        acm1.PRM_Account_Id__c = testAccount1.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Channel_Program_Level_Id__c = level.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Nm__c ='Pending';
        insert acm1;
        
        PRM_Specialty__c testspecialty = new PRM_Specialty__c();//Specialty
        testspecialty.Name = 'Artificial Intelligence Specialty';
        testspecialty.PRM_Description_Txt__c = 'Industrial Specialty';
        testspecialty.PRM_Access_Level_Nm__c = 'public';
        testspecialty.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        testspecialty.PRM_Role_Nm__c = System.Label.PRM_Service_Provider;
        testspecialty.PRM_Tier_Nm__c = 'Gold';
        testspecialty.PRM_Start_Date_Dt__c = system.today()+7;
        insert testspecialty;
        
        PRM_Specialty__c testspecialty1 = new PRM_Specialty__c();//Specialty
        testspecialty1.Name = 'Sp Specialty';
        testspecialty1.PRM_Description_Txt__c = 'Industrial Specialty';
        testspecialty1.PRM_Access_Level_Nm__c = 'public';
        testspecialty1.PRM_Funding_BU_Nm__c = 'CCG Sales Group';
        testspecialty1.PRM_Role_Nm__c = 'Distributor';
        testspecialty1.PRM_Tier_Nm__c = 'Gold';
        testspecialty1.PRM_Start_Date_Dt__c = system.today()+7;
        insert testspecialty1;
        
        PRM_Account_Specialty_Association__c existAsa = new PRM_Account_Specialty_Association__c();
        existAsa.PRM_Account_Id__c = testAccount1.Id;
        existAsa.PRM_Specialty_Id__c = testspecialty.Id;
        existAsa.PRM_Partner_Role__c = 'Distributor';
        existAsa.PRM_InActive_Ind__c = false;
        insert existAsa;
        
        PRM_AddPartnerController.fetchAccsData(testAccount.Name,testspecialty.Id);
        //PRM_AddPartnerController.fetchAccsData(testAccount1.Name,testspecialty1.Id);
        PRM_AddPartnerController.fetchAccCouPickListValue(new Account(), 'BillingCountryCode');
        PRM_AddPartnerController.fetchAccTypePickListValue(new PRM_AccountChannelMembership__c(), 'PRM_Partner_Role__c');
        //PRM_AddPartnerController.fetchPickListValue(new Account(),'Core_Account_BU_Focus__c');
        PRM_AddPartnerController.fetchPickListValue(testspecialty.Id);
        PRM_AddPartnerController.filterAccsData(testAccount.Name, acm.PRM_Partner_Role__c, testAccount.Core_Account_BU_Focus__c, 'USA', acm.PRM_Channel_Program_Level_Id__r.Name,testspecialty.Id);
        PRM_AddPartnerController.fetchTierPickListValue();     
        PRM_AddPartnerController.fetchPendingData(testspecialty.Id);
        Test.stopTest();
        System.assertEquals('Gold',testspecialty.PRM_Tier_Nm__c,'Specialty should be inserted');
    }
    
    static testmethod void getSpCritTestMethod()
    {
        Account testAcc = new Account();
        testAcc.Name='John Wick1';
        testAcc.Core_IPA_Partner_Role__c='Service Provider';
        testAcc.BillingCity='City';
        testAcc.BillingStreet='Beacker Street';
        testAcc.BillingCountry='India';
        testAcc.BillingPostalCode='Postal code1';
        testAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.Name='John Wicking';
        testAcc1.BillingCity='City';
        testAcc1.BillingStreet='Beackerer Street';
        testAcc1.BillingCountry='India';
        testAcc1.BillingPostalCode='Postal code1';
        testAcc1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc1.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc1;
        
        Account testAcc2 = new Account();
        testAcc2.Name='Auto Janes';
        testAcc2.BillingCity='City';
        testAcc2.BillingStreet='Beackerer Street';
        testAcc2.BillingCountry='India';
        testAcc2.BillingPostalCode='Postal code1';
        testAcc2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc2.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc2;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.Name='Cloud Data Center Specialist';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.Name='Cloud Data Center Specialist1';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        Id devRecordTypeId = Schema.SObjectType.PRM_Specialty_Criteria__c.getRecordTypeInfosByName().get('Qualitative').getRecordTypeId();
        PRM_Specialty_Criteria__c psaTest = new PRM_Specialty_Criteria__c();
        psaTest.Name='Test';
        psaTest.RecordTypeId=devRecordTypeId;
        psaTest.PRM_Start_Date_Dt__c = date.today();
        psaTest.PRM_Type_Nm__c = 'Qualitative';
        insert psaTest;
        
        PRM_Persisted_Partners__c persistRec = new PRM_Persisted_Partners__c();
        persistRec.PRM_Account_Id__c = testAcc1.Id;
        persistRec.PRM_Specialty_Id__c = spec.Id;
        persistRec.PRM_Specialty_Criteria_Id__c = psaTest.Id;
        insert persistRec;
        
        PRM_Specialty_Criteria__c spCrit = new PRM_Specialty_Criteria__c();
        spCrit.Name = 'MP Qual Test';
        spCrit.PRM_InActive_Ind__c = true;
        spCrit.PRM_Start_Date_Dt__c = date.today();
        spCrit.PRM_Type_Nm__c = 'Qualitative';
        insert spCrit;
        
        PRM_Account_Specialty_Association__c asaRec = new PRM_Account_Specialty_Association__c();
        asaRec.PRM_Account_Id__c = testAcc.Id;
        asaRec.PRM_Specialty_Id__c = spec.Id;
        asaRec.PRM_InActive_Ind__c = true;
        insert asaRec; 
        
        PRM_Account_Specialty_Qual_Criteria__c asaCrit = new PRM_Account_Specialty_Qual_Criteria__c();
        asaCrit.PRM_Account_Specialty_Association_Id__c = asaRec.Id;
        asaCrit.PRM_Specialty_Criteria_Id__c = spCrit.Id;
        asaCrit.PRM_InActive_Ind__c = true;
        insert asaCrit;        
        
        PRM_Specialty_Criteria__c spCrit1 = new PRM_Specialty_Criteria__c();
        spCrit1.Name = 'MP Qual Test1';
        spCrit1.PRM_InActive_Ind__c = false;
        spCrit1.PRM_Start_Date_Dt__c = date.today();
        spCrit1.PRM_Type_Nm__c = 'Qualitative';
        insert spCrit1;
        
        PRM_Account_Specialty_Association__c asaRec1 = new PRM_Account_Specialty_Association__c();
        asaRec1.PRM_Account_Id__c = testAcc1.Id;
        asaRec1.PRM_Specialty_Id__c = spec1.Id;
        asaRec1.PRM_InActive_Ind__c = false;
        insert asaRec1;
        
        PRM_Account_Specialty_Qual_Criteria__c asaCrit1 = new PRM_Account_Specialty_Qual_Criteria__c();
        asaCrit1.PRM_Account_Specialty_Association_Id__c = asaRec1.Id;
        asaCrit1.PRM_Specialty_Criteria_Id__c = spCrit1.Id;
        asaCrit1.PRM_InActive_Ind__c = false;
        insert asaCrit1;
        
        string accid =testAcc.Id;
        string specID =psaTest.id;
        string jsonInput1 = '[{"label":"'+accid+'","value":["'+specID+'"]}]';
        string jsonInput2 = '[["'+testAcc.Id+'","Sheetal to test"]]';        
        List<Account> lstOfAccount = new List<Account>();
        lstOfAccount.add(testAcc);
        
        List<String> lstofSpCritTodelete = new List<String>();
        lstofSpCritTodelete.add(spCrit1.Id);
        
        //To cover fetchpending data method
        PRM_Persisted_Partners__c persistObj = new PRM_Persisted_Partners__c();
        persistObj.PRM_Account_Id__c = testAcc.Id;
        persistObj.PRM_Partner_Role__c = System.Label.PRM_Service_Provider;
        persistObj.PRM_Specialty_Id__c = spec.Id;
        persistObj.PRM_Specialty_Criteria_Id__c = spCrit.Id;        
        insert persistObj;
        
        ChannelProgram cprogram = new ChannelProgram();  //Channel Program 
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c  acm = PRM_TestUtility.getMembership(); //Account Channel Membership
        acm.PRM_Account_Id__c = testAcc.Id;
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Channel_Program_Level_Id__c = level.Id;
        acm.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm.PRM_Status_Nm__c ='Pending';
        insert acm;
        //code to cover fetchSpeCritRelToACM Method START 
        PRM_Persisted_Partners__c persistObj1 = new PRM_Persisted_Partners__c();
        persistObj1.PRM_Account_Id__c = testAcc1.Id;
        persistObj1.PRM_Partner_Role__c = System.Label.PRM_Service_Provider;
        persistObj1.PRM_Specialty_Id__c = spec.Id;
        persistObj1.PRM_Specialty_Criteria_Id__c = spCrit.Id;        
        insert persistObj1;
        
        PRM_Persisted_Partners__c persistObj2 = new PRM_Persisted_Partners__c();
        persistObj2.PRM_Account_Id__c = testAcc1.Id;
        persistObj2.PRM_Partner_Role__c = System.Label.PRM_Service_Provider;
        persistObj2.PRM_Specialty_Id__c = spec.Id;
        persistObj2.PRM_Specialty_Criteria_Id__c = spCrit1.Id;        
        insert persistObj2;
        
        PRM_AccountChannelMembership__c acmObj = new PRM_AccountChannelMembership__c();
        acmObj.PRM_Account_Id__c = testAcc1.Id;
        acmObj.PRM_Channel_Program_Id__c = cprogram.Id;
        acmObj.PRM_Channel_Program_Level_Id__c = level.Id;
        acmObj.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acmObj.PRM_Status_Nm__c ='Pending';
        insert acmObj;
        
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = testAcc2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Channel_Program_Level_Id__c = level.Id;
        acm2.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm2.PRM_Status_Nm__c ='Pending';
        insert acm2;
        
        List<String> lstofSpCrit = new List<string>();
        lstofSpCrit.add(persistObj1.PRM_Specialty_Criteria_Id__c);
        
        List<WrapperOfACMIdAndRelSpCriLst> lstofSpCritRlatedToACM = new List<WrapperOfACMIdAndRelSpCriLst>();
        WrapperOfACMIdAndRelSpCriLst wrapLst = new WrapperOfACMIdAndRelSpCriLst();
        wrapLst.acmId = acmObj.Id;
        wrapLst.spCrit = lstofSpCrit;
        lstofSpCritRlatedToACM.add(wrapLst);
        
        List<AccAndAcmWrapper> lstofAccAndAcmWrapper = new List<AccAndAcmWrapper>();
        lstofAccAndAcmWrapper.add(new AccAndAcmWrapper(acm.Id,acm.PRM_Account_Id__c,testAcc.AccountNumber,
                                                       testAcc.Name,acm.PRM_Partner_Role__c,testAcc.Core_User_Defined_Phone_Number__c,
                                                       testAcc.BillingCountryCode,testAcc.Core_Account_BU_Focus__c,
                                                       level.Name));
        System.debug('ACm AccID:-'+acm.PRM_Account_Id__c);
        System.debug('ACm AccID1:-'+acm2.PRM_Account_Id__c);
        System.debug('ACm AccID2:-'+acmObj.PRM_Account_Id__c);
        
        PRM_Specialty_Data__c spdata = new PRM_Specialty_Data__c();
        spdata.Name = 'sp Data';
        spdata.PRM_Account_Id__c = testAcc.Id;
        spdata.PRM_Specialty_Id__c = spec.Id;
        spdata.PRM_Specialty_Nbr_Employees_Trained_Nbr__c = 10;
        spdata.PRM_Specialty_Training_Credits_Nbr__c = 80;
        spdata.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
        insert spdata;
        
       /* spdata.Name = 'sp Data';
        spdata.PRM_Account_Id__c = acm2.PRM_Account_Id__c;
        spdata.PRM_Specialty_Id__c = spec.Id;
        spdata.PRM_Specialty_Nbr_Employees_Trained_Nbr__c = 10;
        spdata.PRM_Specialty_Training_Credits_Nbr__c = 80;
        spdata.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
        insert spdata;
        
        spdata.Name = 'sp Data';
        spdata.PRM_Account_Id__c = acmObj.PRM_Account_Id__c;
        spdata.PRM_Specialty_Id__c = spec.Id;
        spdata.PRM_Specialty_Nbr_Employees_Trained_Nbr__c = 10;
        spdata.PRM_Specialty_Training_Credits_Nbr__c = 80;
        spdata.PRM_Partner_Role_Nm__c = System.Label.PRM_Service_Provider;
        insert spdata;*/
        
        List<Object> lstOfSPCri = new List<Object>();
        lstOfSPCri.add(spCrit1);
        
        PRM_Specialty_Criteria__c crit = new PRM_Specialty_Criteria__c();
        crit.Name = 'Mp Qal Criteria';
        crit.PRM_Type_Nm__c = 'Qualitative';
        crit.PRM_Start_Date_Dt__c = Date.today();
		crit.RecordTypeId = devRecordTypeId;
        insert crit;
        
        PRM_Specialty_Qualitative_Criteria__c spQalcrit = new PRM_Specialty_Qualitative_Criteria__c();
        spQalcrit.PRM_Criteria_Id__c= crit.Id;
        spQalcrit.PRM_Specialty_Id__c = spec.Id;      		      		
        insert spQalcrit;
        
        List<string> lstOfTotalSpCrit = new List<string>();
        lstOfTotalSpCrit.add(spQalcrit.PRM_Criteria_Id__c);
        
        Test.startTest();
        PRM_AddPartnerController.getCriteriaDetails(spec.Id);
        PRM_AddPartnerController.insertRelatedRecords(lstofAccAndAcmWrapper,spec.Id,jsonInput2,lstOfTotalSpCrit);
        PRM_AddPartnerController.insertApprovalPendingRecords(lstofAccAndAcmWrapper,spec.Id);
        //PRM_AddPartnerController.insertApprovalPendingCriteria(spec.Id,jsonInput1);
        PRM_AddPartnerController.insertApprovalPendingCriteria(lstofAccAndAcmWrapper,spec.Id,jsonInput1);
        PRM_AddPartnerController.fetchPendingData(spec.Id);
        PRM_AddPartnerController.fetchSpCriteriaData(spec.Id);
        PRM_AddPartnerController.deleteApprovalPendingRec(lstofAccAndAcmWrapper,spec.Id);
        PRM_AddPartnerController.deleteApprovalPendingRec(lstofAccAndAcmWrapper,null);
        PRM_AddPartnerController.fetchSpeCritRelToACM(spec.Id);//US554904 
        PRM_AddPartnerController.fetchCustomSettingValues();
        PRM_AddPartnerController.fetchAccsData(testAcc.Name,spec.Id);
        PRM_AddPartnerController.filterAccsData(testAcc.Name, acm.PRM_Partner_Role__c, testAcc.Core_Account_BU_Focus__c, 'USA', acm.PRM_Channel_Program_Level_Id__r.Name,spec.Id);
        test.stopTest(); 
        System.assertEquals('Gold',spec.PRM_Tier_Nm__c,'Specialty Should be inserted');    
    }      
    @isTest public static void fetchSpCritRelatedToCurrentSpTest(){
        
        Account testAcc = new Account();
        testAcc.Name='John Wick1';
        testAcc.Core_IPA_Partner_Role__c='Service Provider';
        testAcc.BillingCity='City';
        testAcc.BillingStreet='Beacker Street';
        testAcc.BillingCountry='India';
        testAcc.BillingPostalCode='Postal code1';
        testAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc;
        
        PRM_Specialty__c sp = new PRM_Specialty__c();
        sp.Name = ' speciality test';
        sp.PRM_Description_Txt__c = ' eciality tes ';
        sp.PRM_Start_Date_Dt__c = Date.today();
        sp.PRM_End_Date_Dt__c = Date.today()+5;
        sp.PRM_Funding_BU_Nm__c = 'Automotive Sales Group';
        sp.PRM_Tier_Nm__c = 'Gold';
        sp.PRM_Access_Level_Nm__c = 'Public';
        sp.PRM_Role_Nm__c = 'Distributor';
        insert sp;
        
		 Id devRecordTypeId = Schema.SObjectType.PRM_Specialty_Criteria__c.getRecordTypeInfosByName().get('Qualitative').getRecordTypeId();
        List<String> listOfSPC =  new List<String>();
        PRM_Specialty_Criteria__c spc = new PRM_Specialty_Criteria__c();
        spc.Name = 'Specialty criteria Test '+ sp.Id;
        spc.PRM_Start_Date_Dt__c = Date.today();
        spc.PRM_Type_Nm__c = 'Quantitative';
        spc.RecordTypeId = devRecordTypeId;
        insert spc;
        listOfSPC.add(spc.Id);
		
       
        PRM_Specialty_Qualitative_Criteria__c  spqc  = new PRM_Specialty_Qualitative_Criteria__c();
        spqc.PRM_Criteria_Id__c = spc.Id;
        spqc.PRM_Specialty_Id__c = sp.Id;
        insert spqc;

        PRM_Persisted_Partners__c pp = new PRM_Persisted_Partners__c();
        pp.PRM_Account_Id__c = testAcc.Id;
        pp.PRM_Specialty_Criteria_Id__c = spc.Id;
        pp.PRM_Specialty_Id__c = sp.Id;
        pp.PRM_Partner_Role__c = 'FPGA Designer';
        insert pp;
        PRM_AddPartnerController.fetchSpCritRelatedToCurrentSp(sp.Id);
        PRM_AddPartnerController.deleteUnselectedSpCrit(sp.Id,testAcc.Id, 'FPGA Designer',  listOfSPC);
        System.assertNotEquals(Null,sp.Id,'Specialty Should be inserted');   
    }
    
    
    ///-------------------------
    
    
    
    
    static testmethod void getSpCritupdateTestMethod()
    {
        Account testAcc = new Account();
        testAcc.Name='John Wick1';
        testAcc.BillingCity='City';
        testAcc.BillingStreet='Beacker Street';
        testAcc.BillingCountry='India';
        testAcc.BillingPostalCode='Postal code1';
        testAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.Name='John Wicking';
        testAcc1.BillingCity='City';
        testAcc1.BillingStreet='Beackerer Street';
        testAcc1.BillingCountry='India';
        testAcc1.BillingPostalCode='Postal code1';
        testAcc1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc1.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc1;
        
        Account testAcc2 = new Account();
        testAcc2.Name='Auto Wicking';
        testAcc2.BillingCity='City';
        testAcc2.BillingStreet='Beackerer Street';
        testAcc2.BillingCountry='India';
        testAcc2.BillingPostalCode='Postal code1';
        testAcc2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAcc2.Core_IPA_Partner_Speciality__c='Video Specialty';
        testAcc2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert testAcc2;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.Name='Cloud Data Center Specialist';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        Id devRecordTypeId = Schema.SObjectType.PRM_Specialty_Criteria__c.getRecordTypeInfosByName().get('Qualitative').getRecordTypeId();
        PRM_Specialty_Criteria__c psaTest = new PRM_Specialty_Criteria__c();
        psaTest.Name='Test';
        psaTest.RecordTypeId=devRecordTypeId;
        psaTest.PRM_Start_Date_Dt__c = date.today();
        psaTest.PRM_Type_Nm__c = 'Qualitative';
        insert psaTest;
        
        PRM_Account_Specialty_Association__c asaRec = new PRM_Account_Specialty_Association__c();
        asaRec.PRM_Account_Id__c = testAcc1.Id;
        asaRec.PRM_Specialty_Id__c = spec.Id;
        asaRec.PRM_InActive_Ind__c = False;
        insert asaRec; 
        
        PRM_Account_Specialty_Qual_Criteria__c asaCrit = new PRM_Account_Specialty_Qual_Criteria__c();
        asaCrit.PRM_Account_Specialty_Association_Id__c = asaRec.Id;
        asaCrit.PRM_Specialty_Criteria_Id__c = psaTest.Id;
        asaCrit.PRM_InActive_Ind__c = true;
        insert asaCrit;
        
        asaRec.PRM_InActive_Ind__c = True;
        update asaRec; 
        
        asaRec.PRM_InActive_Ind__c = False;
        update asaRec; 
        
        
        string accid =testAcc.Id;
        string specID =psaTest.id;
        string jsonInput1 = '[{"label":"'+accid+'","value":["'+specID+'"]}]';
        string jsonInput2 = '[["'+testAcc.Id+'","Sheetal to test"]]';        
        List<Account> lstOfAccount = new List<Account>();
        lstOfAccount.add(testAcc);
        
        PRM_Specialty_Criteria__c spCrit1 = new PRM_Specialty_Criteria__c();
        spCrit1.Name = 'MP Qual Test1';
        spCrit1.PRM_InActive_Ind__c = false;
        spCrit1.PRM_Start_Date_Dt__c = date.today();
        spCrit1.PRM_Type_Nm__c = 'Qualitative';
        insert spCrit1;
        
        ChannelProgram cprogram = new ChannelProgram();  //Channel Program 
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Member';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = testAcc2.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Channel_Program_Level_Id__c = level.Id;
        acm2.PRM_Partner_Role__c=System.Label.PRM_Service_Provider;
        acm2.PRM_Status_Nm__c ='Pending';
        insert acm2;
        
        List<Object> lstOfSPCri = new List<Object>();
        lstOfSPCri.add(spCrit1);
        
        
        Test.startTest();
        PRM_AddPartnerController.getCriteriaDetails(spec.Id);
        //PRM_AddPartnerController.insertRelatedRecords(lstOfAccount,spec.Id,jsonInput2,lstOfSPCri );
        PRM_AddPartnerController.insertApprovalPendingRecords(lstOfAccount,spec.Id);
        PRM_AddPartnerController.insertApprovalPendingCriteria(lstOfAccount,spec.Id,jsonInput1);
        PRM_AddPartnerController.fetchPendingData(spec.Id);
        PRM_AddPartnerController.fetchSpCriteriaData(spec.Id);
        PRM_AddPartnerController.fetchCustomSettingValues();
        PRM_AddPartnerController.fetchAccsData(testAcc2.Name,spec.Id);
        
        test.stopTest();   
        System.assertEquals('Gold',spec.PRM_Tier_Nm__c,'Specialty Should be inserted');        
    }
    
    //wrapper of ACM Id and related Specialty Criteria 
    public with sharing class WrapperOfACMIdAndRelSpCriLst {
        @auraEnabled public List<String> spCrit {get;set;}
        @auraEnabled public String acmId {get;set;} 
        
    }
    
    // wrapper class to fetch value from ACM object related to Account
    public with sharing class AccAndAcmWrapper {
        @auraEnabled public Id id {get;set;}
        @auraEnabled public Id accountId {get;set;}
        @auraEnabled public string accountNum {get;set;}
        @auraEnabled public string accountName {get;set;}
        @auraEnabled public string acmpartnerRole {get;set;}
        @auraEnabled public string accountPhoneNo {get;set;}
        @auraEnabled public string accCountry {get;set;}
        @auraEnabled public string accountBuFocus {get;set;}
        @auraEnabled public string channelProgLevelName {get;set;}
        
        public AccAndAcmWrapper(Id acmId,Id accId,String accountNo,String accName,String partnerRole, String phone,String country, String buFocus, String chProgLevelName){
            id = acmId;
            accountId = accId;
            accountNum = accountNo;
            accountName = accName;
            acmpartnerRole = partnerRole;
            accountPhoneNo = phone;
            accCountry = country;
            accountBuFocus = buFocus;
            channelProgLevelName = chProgLevelName;
            
        }
    }      
}