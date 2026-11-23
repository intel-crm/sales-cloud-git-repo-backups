/***********************************************************************************************************************************************
Apex Class Name: PRM_IPA_Affiliations_Test
Created Date: 24 Aug 2022
Function    :  Test class for PRM_IPA_Affiliations

Modification Log :
* Developer                     Date                Description                                             Class
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 24/08/2022        Test class for PRM_IPA_Affiliations                 PRM_IPA_Affiliations
*************************************************************************************************************************************************/

@isTest
public class PRM_IPA_Affiliations_Test {
    
    public static testMethod void fetchAccsData_Test(){
        
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();        
        
        List<Account> acList = new List<Account>();
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
        acList.add(parent1);     
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.AccountNumber='30000000230';
        testAccount.Core_User_Defined_Phone_Number__c='9891744621';
        testAccount.Core_Account_BU_Focus__c= 'CCG';
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
        acList.add(testAccount);
        
        Account testAccount1 = new Account();
        testAccount1.RecordTypeId = recordTypeIdAccount;
        testAccount1.Name='John Test';
        testAccount1.AccountNumber='30001111230';
        testAccount1.Core_User_Defined_Phone_Number__c='9891788621';
        testAccount1.Core_Account_BU_Focus__c= 'CCG';
        testAccount1.BillingCity='pune';
        testAccount1.BillingStreet='test';
        testAccount1.BillingCountry='USA';
        testAccount1.BillingState='OR';
        testAccount1.BillingPostalCode = '65436';
        testAccount1.ShippingCity = 'USA';
        testAccount1.ShippingCountryCode = 'USA';
        testAccount1.ShippingCountry = 'USA';
        testAccount1.ShippingPostalCode = '19934';
        testAccount1.ShippingState = 'OR';
        testAccount1.ShippingStateCode = 'OR';
        testAccount1.ShippingStreet = '1538 Lane';
        testAccount1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount1.website='www.kjh.com';
        testAccount1.Core_User_Defined_Website__c='www.hcl.com'; 
        testAccount1.Core_IPA_One_Partner_Id__c = parent1.Id;
        testAccount1.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount1.Core_Deactivated__c = false;
        acList.add(testAccount1);       
        insert acList;
              
        PRM_Builder_Strategy__c IA = new PRM_Builder_Strategy__c();
        IA.Name = 'AI Builders';
        IA.PRM_Active__c = true;
        Insert IA;
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        List<PRM_AccountChannelMembership__c> listAcm = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=testAccount.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Seller';
        
        PRM_AccountChannelMembership__c acctChnlMem1 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem1.PRM_Account_Id__c=testAccount1.Id;
        acctChnlMem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem1.PRM_Status_Nm__c = 'Approved';
        acctChnlMem1.PRM_Partner_Role__c='Seller';
        
        listAcm.add(acctChnlMem);
        listAcm.add(acctChnlMem1);
        insert listAcm;
        
        PRM_AccountChannelMembership__c acctChnlMem2 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem2.PRM_Account_Id__c=parent1.Id;
        acctChnlMem2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem2.PRM_Status_Nm__c = 'Approved';
        acctChnlMem2.PRM_Partner_Role__c='Seller';
        insert acctChnlMem2;
        
        PRM_IPA_Affiliation__c tb = new PRM_IPA_Affiliation__c();
        tb.PRM_Account__c = listAcm[0].PRM_Account_Id__c;
        tb.PRM_Active__c = true;
        tb.PRM_Builder_Strategy__c = IA.id;
        insert tb;
        
        
        Test.startTest();
        PRM_IPA_Affiliations.fetchAccsData(testAccount.Name,tb.PRM_Builder_Strategy__c);
        List<PRM_IPA_Affiliations.AccAndAcmWrapper > wrapperList = PRM_IPA_Affiliations.fetchAccsData(testAccount1.Name,IA.id);
        PRM_IPA_Affiliations.fetchAccsData('abc',IA.Id);
        try{
          	PRM_IPA_Affiliations.tagBuilders(wrapperList, tb.PRM_Builder_Strategy__c);  
            PRM_IPA_Affiliations.fetchAccsData(null, null);
        }
        catch(exception e){
        }
        Test.stopTest();
    }
    
    public static testMethod void fetchAccsData_Test1(){
        
        Test.startTest();
         try{
        	PRM_IPA_Affiliations.tagBuilders(null, null);   
   		}
        catch(exception e){
        }
        Test.stopTest();        
    }
    
    public static testMethod void fetchAccsData_Test2(){
        
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();   
                   
        Account parent2 = new Account();
        parent2.RecordTypeId = recordTypeIdPagAccount;
        parent2.Name='Cello test ltd1';
        parent2.BillingCity='New City';
        parent2.BillingStreet='New Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='956999';
        parent2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent2.Industry='Construction';
        parent2.Core_Deactivated__c = false;
        insert parent2; 
        
        Account testAccount2 = new Account();
        testAccount2.RecordTypeId = recordTypeIdAccount;
        testAccount2.Name='John acc test';
        testAccount2.AccountNumber='30004343230';
        testAccount2.Core_User_Defined_Phone_Number__c='9891788621';
        testAccount2.Core_Account_BU_Focus__c= 'CCG';
        testAccount2.BillingCity='mumbai';
        testAccount2.BillingStreet='test';
        testAccount2.BillingCountry='USA';
        testAccount2.BillingState='OR';
        testAccount2.BillingPostalCode = '65436';
        testAccount2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount2.website='www.kjh.com';
        testAccount2.Core_User_Defined_Website__c='www.hcl.com'; 
        testAccount2.Core_IPA_One_Partner_Id__c = parent2.Id;
        testAccount2.Core_IPA_Partner_Role__c = 'Service Provider';
        testAccount2.Core_Deactivated__c = false;
        insert testAccount2;
        
        PRM_Builder_Strategy__c IA = new PRM_Builder_Strategy__c();
        IA.Name = 'AI Builders';
        IA.PRM_Active__c = true;
        Insert IA;
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMem4 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem4.PRM_Account_Id__c=testAccount2.Id;
        acctChnlMem4.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem4.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem4.PRM_Status_Nm__c = 'Approved';
        acctChnlMem4.PRM_Partner_Role__c='Seller';
        insert acctChnlMem4;
        
        PRM_AccountChannelMembership__c acctChnlMem3 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem3.PRM_Account_Id__c=parent2.Id;
        acctChnlMem3.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem3.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem3.PRM_Status_Nm__c = 'Inactive';
        acctChnlMem3.PRM_Partner_Role__c='Seller';
        insert acctChnlMem3;
        
        Test.startTest();
        List<PRM_IPA_Affiliations.AccAndAcmWrapper > wrapperList = PRM_IPA_Affiliations.fetchAccsData(testAccount2.Name,IA.id);
        try{
          	PRM_IPA_Affiliations.tagBuilders(wrapperList, IA.Id);  
        }
        catch(exception e){
        }
        Test.stopTest();
    }
    
}