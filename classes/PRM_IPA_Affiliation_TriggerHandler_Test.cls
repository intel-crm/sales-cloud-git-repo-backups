/***********************************************************************************************************************************************
Apex Test Class Name: PRM_IPA_Affiliation_TriggerHandler_Test
Created Date: 25 Aug 2022
Function    :  Test class for PRM_IPA_Affiliation_TriggerHandler

Modification Log :
* Developer                  Date                Description                                             Class
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More             25/08/2022        Test class for PRM_IPA_Affiliation_TriggerHandler          PRM_IPA_Affiliation_TriggerHandler
*************************************************************************************************************************************************/

@isTest
public class PRM_IPA_Affiliation_TriggerHandler_Test {
    
    public static testMethod void tagBuilderActiveFieldAfterUpdate_Test(){
        
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
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
        
        Account parent2 = new Account();
        parent2.RecordTypeId = recordTypeIdPagAccount;
        parent2.Name='Cello Ltd - Version2';
        parent2.BillingCity='New City';
        parent2.BillingStreet='New Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='888888';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent2.Core_Deactivated__c = false;
        insert parent2;
        
        Account parent3 = new Account();
        parent3.RecordTypeId = recordTypeIdPagAccount;
        parent3.Name='Cello Ltd - Version3';
        parent3.BillingCity='New City';
        parent3.BillingStreet='New Street';
        parent3.BillingCountry='India';
        parent3.BillingPostalCode='777777';
        parent3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent3.Core_Deactivated__c = false;
        insert parent3;
        
        Account parent4 = new Account();
        parent4.RecordTypeId = recordTypeIdPagAccount;
        parent4.Name='Cellotest - Version5';
        parent4.BillingCity='New pune';
        parent4.BillingStreet='New abc';
        parent4.BillingCountry='India';
        parent4.BillingPostalCode='565656';
        parent4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent4.Core_Deactivated__c = false;
        insert parent4;
        
        
        List<Account> aclist = new List<Account>();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.AccountNumber='30000000230';
        testAccount.Core_User_Defined_Phone_Number__c='9891744621';
        testAccount.Core_Account_BU_Focus__c= 'CCG	';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='USA';
        testAccount.BillingState='OR';
        testAccount.BillingPostalCode = '65436';
        testAccount.ShippingCity = 'USA';
        testAccount.ShippingCountryCode = 'USA';
        testAccount.ShippingCountry = 'USA';
        testAccount.ShippingLatitude = 23.21;
        testAccount.ShippingLongitude = 32.21;
        testAccount.ShippingPostalCode = '12334';
        testAccount.ShippingState = 'OR';
        testAccount.ShippingStateCode = 'OR';
        testAccount.ShippingStreet = '1538 Dogwood Lane';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.intel.com'; 
        testAccount.Core_IPA_One_Partner_Id__c = parent1.Id;
        testAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount.Core_Deactivated__c = false;
        aclist.add(testAccount);
        
        Account testAccount2 = new Account();
        testAccount2.RecordTypeId = recordTypeIdAccount;
        testAccount2.Name='John Test';
        testAccount2.AccountNumber='30887000230';
        testAccount2.Core_User_Defined_Phone_Number__c='9891787621';
        testAccount2.Core_Account_BU_Focus__c= 'CCG';
        testAccount2.BillingCity='Pune';
        testAccount2.BillingStreet='Dhan';
        testAccount2.BillingCountry='USA';
        testAccount2.BillingState='OR';
        testAccount2.BillingPostalCode = '65436';
        testAccount2.ShippingCity = 'USA';
        testAccount2.ShippingCountryCode = 'USA';
        testAccount2.ShippingCountry = 'USA';
        testAccount2.ShippingPostalCode = '12334';
        testAccount2.ShippingState = 'OR';
        testAccount2.ShippingStateCode = 'OR';
        testAccount2.ShippingStreet = '1538 TEst Lane';
        testAccount2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount2.website='www.abchj.com';
        testAccount2.Core_User_Defined_Website__c='www.HCL.com'; 
        testAccount2.Core_IPA_One_Partner_Id__c = parent2.Id;
        testAccount2.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount2.Core_Deactivated__c = false;
        aclist.add(testAccount2);
        
        Account testAccount3 = new Account();
        testAccount3.RecordTypeId = recordTypeIdAccount;
        testAccount3.Name='John2 Test2';
        testAccount3.AccountNumber='30887876230';
        testAccount3.Core_User_Defined_Phone_Number__c='9895677621';
        testAccount3.Core_Account_BU_Focus__c= 'CCG';
        testAccount3.BillingCity='nagpur';
        testAccount3.BillingStreet='kal test';
        testAccount3.BillingCountry='USA';
        testAccount3.BillingState='OR';
        testAccount3.BillingPostalCode = '65765';
        testAccount3.ShippingCity = 'USA';
        testAccount3.ShippingCountryCode = 'USA';
        testAccount3.ShippingCountry = 'USA';
        testAccount3.ShippingPostalCode = '12999';
        testAccount3.ShippingState = 'OR';
        testAccount3.ShippingStateCode = 'OR';
        testAccount3.ShippingStreet = '9875 Lane';
        testAccount3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount3.website='www.alljj.com';
        testAccount3.Core_User_Defined_Website__c='www.per.com'; 
        testAccount3.Core_IPA_One_Partner_Id__c = parent3.Id;
        testAccount3.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount3.Core_Deactivated__c = false;
        aclist.add(testAccount3);
        
        Account testAccount4 = new Account();
        testAccount4.RecordTypeId = recordTypeIdAccount;
        testAccount4.Name='John1 Test1';
        testAccount4.AccountNumber='30887009830';
        testAccount4.Core_User_Defined_Phone_Number__c='9899997621';
        testAccount4.Core_Account_BU_Focus__c= 'CCG';
        testAccount4.BillingCity='Mumbai';
        testAccount4.BillingStreet='tam';
        testAccount4.BillingCountry='USA';
        testAccount4.BillingState='OR';
        testAccount4.BillingPostalCode = '65986';
        testAccount4.ShippingCity = 'USA';
        testAccount4.ShippingCountryCode = 'USA';
        testAccount4.ShippingCountry = 'USA';
        testAccount4.ShippingPostalCode = '12984';
        testAccount4.ShippingState = 'OR';
        testAccount4.ShippingStateCode = 'OR';
        testAccount4.ShippingStreet = '1538 Lane';
        testAccount4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount4.website='www.kjli.com';
        testAccount4.Core_User_Defined_Website__c='www.tcs.com'; 
        testAccount4.Core_IPA_One_Partner_Id__c = parent3.Id;
        testAccount4.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount4.Core_Deactivated__c = false;
        aclist.add(testAccount4);
        
        Account testAccount5 = new Account();
        testAccount5.RecordTypeId = recordTypeIdAccount;
        testAccount5.Name='Acct1 test';
        testAccount5.AccountNumber='30887009830';
        testAccount5.Core_User_Defined_Phone_Number__c='7699876556';
        testAccount5.Core_Account_BU_Focus__c= 'CCG';
        testAccount5.BillingCity='Pune';
        testAccount5.BillingStreet='fgh';
        testAccount5.BillingCountry='USA';
        testAccount5.BillingState='OR';
        testAccount5.BillingPostalCode = '54321';
        testAccount5.ShippingCity = 'USA';
        testAccount5.ShippingCountryCode = 'USA';
        testAccount5.ShippingCountry = 'USA';
        testAccount5.ShippingPostalCode = '98787';
        testAccount5.ShippingState = 'OR';
        testAccount5.ShippingStateCode = 'OR';
        testAccount5.ShippingStreet = '1538 test';
        testAccount5.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount5.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount5.website='www.jhik.com';
        testAccount5.Core_User_Defined_Website__c='www.acct.com'; 
        testAccount5.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount5.Core_IPA_One_Partner_Id__c = parent4.Id;
        testAccount5.Core_Deactivated__c = false;
        aclist.add(testAccount5);
        
        Account testAccount6 = new Account();
        testAccount6.RecordTypeId = recordTypeIdAccount;
        testAccount6.Name='Acct2 test2';
        testAccount6.AccountNumber='30876509830';
        testAccount6.Core_User_Defined_Phone_Number__c='7698886556';
        testAccount6.Core_Account_BU_Focus__c= 'CCG';
        testAccount6.BillingCity='Nagpur';
        testAccount6.BillingStreet='ghj';
        testAccount6.BillingCountry='USA';
        testAccount6.BillingState='OR';
        testAccount6.BillingPostalCode = '54321';
        testAccount6.ShippingCity = 'USA';
        testAccount6.ShippingCountryCode = 'USA';
        testAccount6.ShippingCountry = 'USA';
        testAccount6.ShippingPostalCode = '56543';
        testAccount6.ShippingState = 'OR';
        testAccount6.ShippingStateCode = 'OR';
        testAccount6.ShippingStreet = '8767 test';
        testAccount6.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount6.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount6.website='www.kjik.com';
        testAccount6.Core_User_Defined_Website__c='www.hclih.com'; 
        testAccount6.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount6.Core_IPA_One_Partner_Id__c = parent4.Id;
        testAccount6.Core_Deactivated__c = false;
        aclist.add(testAccount6);
        
        insert aclist;
        
        List<PRM_Builder_Strategy__c> IPAList = new List<PRM_Builder_Strategy__c>();
        PRM_Builder_Strategy__c IA = new PRM_Builder_Strategy__c();
        IA.Name = 'AI Builders';
        IA.PRM_Active__c = true;
        insert IA;
        
        PRM_Builder_Strategy__c IA1 = new PRM_Builder_Strategy__c();
        IA1.Name = 'Network Builders';
        IA1.PRM_Active__c = true;
        Insert IA1;
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        List<PRM_AccountChannelMembership__c> listAcm = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=parent1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Solution Integrator';
        acctChnlMem.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountChannelMembership__c acctChnlMem1 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem1.PRM_Account_Id__c=parent2.Id;
        acctChnlMem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem1.PRM_Status_Nm__c = 'Approved';
        acctChnlMem1.PRM_Partner_Role__c='Solution Integrator';
        acctChnlMem1.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountChannelMembership__c acctChnlMem2 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem2.PRM_Account_Id__c=parent3.Id;
        acctChnlMem2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem2.PRM_Status_Nm__c = 'Approved';
        acctChnlMem2.PRM_Partner_Role__c='Solution Integrator';
        acctChnlMem2.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountChannelMembership__c acctChnlMem3 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem3.PRM_Account_Id__c=parent4.Id;
        acctChnlMem3.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem3.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem3.PRM_Status_Nm__c = 'Approved';
        acctChnlMem3.PRM_Partner_Role__c='Solution Integrator';
        acctChnlMem3.PRM_Status_Reason_Txt__c = 'Test class';
                
        List<PRM_AccountChannelMembership__c> pacmList = new List<PRM_AccountChannelMembership__c>();
        For(Account ac: aclist){
             PRM_AccountChannelMembership__c acctChnl = new PRM_AccountChannelMembership__c(); 
            acctChnl.PRM_Account_Id__c=ac.Id;
            acctChnl.PRM_Channel_Program_Id__c=cpIPATest.Id;
            acctChnl.PRM_Channel_Program_Level_Id__c=cplTest.Id;
            acctChnl.PRM_Status_Nm__c = 'Approved';
            acctChnl.PRM_Status_Reason_Txt__c = 'Test class';
            acctChnl.PRM_Partner_Role__c='Solution Integrator';
            pacmList.add(acctChnl);
        }
        insert pacmList;
        
        List<Core_Account_Group_Member__c> accOpidList = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Inactive_Ind__c = false;
        agm.Core_Partner_Account_Id__c = parent1.id;
        agm.Core_Intel_Account_Id__c = testAccount.id;
        
        Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Inactive_Ind__c = false;
        agm1.Core_Partner_Account_Id__c = parent2.id;
        agm1.Core_Intel_Account_Id__c = testAccount2.id;
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Inactive_Ind__c = false;
        agm2.Core_Partner_Account_Id__c = parent3.id;
        agm2.Core_Intel_Account_Id__c = testAccount3.id;
        
        Core_Account_Group_Member__c agm3 = new Core_Account_Group_Member__c();
        agm3.Core_Inactive_Ind__c = false;
        agm3.Core_Partner_Account_Id__c = parent3.id;
        agm3.Core_Intel_Account_Id__c = testAccount4.id;
        
        Core_Account_Group_Member__c agm4 = new Core_Account_Group_Member__c();
        agm4.Core_Inactive_Ind__c = false;
        agm4.Core_Partner_Account_Id__c = parent4.id;
        agm4.Core_Intel_Account_Id__c = testAccount6.id;
        
        accOpidList.add(agm);
        accOpidList.add(agm1);
        accOpidList.add(agm2);
        accOpidList.add(agm3);
        accOpidList.add(agm4);
        insert accOpidList;
        
        listAcm.add(acctChnlMem);
        listAcm.add(acctChnlMem1);
        listAcm.add(acctChnlMem2);
        listAcm.add(acctChnlMem3);
        insert listAcm;
        
        test.StartTest();
        PRM_IPA_Affiliation__c tb1 = new PRM_IPA_Affiliation__c();
        tb1.PRM_Account__c = parent1.Id;
        tb1.PRM_Active__c = false;
        tb1.PRM_Builder_Strategy__c = IA.id;
        tb1.PRM_Notes__c='Test';
        insert tb1;
        
        PRM_IPA_Affiliation__c tb = new PRM_IPA_Affiliation__c();
        tb.PRM_Account__c = testAccount.Id;
        tb.PRM_Active__c = false;
        tb.PRM_Builder_Strategy__c = IA.id;
        tb.PRM_Notes__c='Test';
        insert tb;
        tb.PRM_Active__c= true;
        update tb;
        
        PRM_IPA_Affiliation__c tb2 = new PRM_IPA_Affiliation__c();
        tb2.PRM_Account__c = parent2.Id;
        tb2.PRM_Active__c = true;
        tb2.PRM_Builder_Strategy__c = IA1.id;
        tb2.PRM_Notes__c='Test';
        insert tb2;   
        
        PRM_IPA_Affiliation__c tag = new PRM_IPA_Affiliation__c();
        tag.PRM_Account__c = testAccount2.Id;
        tag.PRM_Active__c = true;
        tag.PRM_Builder_Strategy__c = IA1.id;
        tag.PRM_Notes__c='Test';
        insert tag;
        tag.PRM_Active__c= false;
        update tag;
        
        PRM_IPA_Affiliation__c tb3 = new PRM_IPA_Affiliation__c();
        tb3.PRM_Account__c = parent3.Id;
        tb3.PRM_Active__c = false;
        tb3.PRM_Builder_Strategy__c = IA1.id;
        tb3.PRM_Notes__c='Test';
        insert tb3;   
        
        PRM_IPA_Affiliation__c tag1 = new PRM_IPA_Affiliation__c();
        tag1.PRM_Account__c = testAccount3.Id;
        tag1.PRM_Active__c = false;
        tag1.PRM_Builder_Strategy__c = IA1.id;
        tag1.PRM_Notes__c='Test';
        insert tag1;
        
        PRM_IPA_Affiliation__c tag5 = new PRM_IPA_Affiliation__c();
        tag5.PRM_Account__c = testAccount5.Id;
        tag5.PRM_Active__c = true;
        tag5.PRM_Builder_Strategy__c = IA1.id;
        tag5.PRM_Notes__c='Test';
        insert tag5;
        tag5.PRM_Active__c = false;
        update tag5;
        
        PRM_IPA_Affiliation__c tag6 = new PRM_IPA_Affiliation__c();
        tag6.PRM_Account__c = testAccount6.Id;
        tag6.PRM_Active__c = true;
        tag6.PRM_Builder_Strategy__c = IA.id;
        tag6.PRM_Notes__c='Test';
        insert tag6;
        
        PRM_IPA_Affiliation__c tag2 = new PRM_IPA_Affiliation__c();
        tag2.PRM_Account__c = testAccount4.Id;
        tag2.PRM_Active__c = true;
        tag2.PRM_Builder_Strategy__c = IA1.id;
        tag2.PRM_Notes__c='Test';
        insert tag2;
        tag2.PRM_Active__c= false;
        update tag2;
        
        tag1.PRM_Active__c = true;
        update tag1;
        
        tag2.PRM_Active__c = true;
        update tag2;
        
        tag1.PRM_Active__c = false;
        update tag1;
        test.StopTest();
        
    }
    
}