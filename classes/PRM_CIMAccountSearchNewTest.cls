@isTest
public class PRM_CIMAccountSearchNewTest {
    public static boolean istruetest=false;
    @isTest 
    public static void DoPostTest_One(){
        set<string> sysAccs=new set<string>();
        sysAccs.add('xyz');
        Address address1 = new Address('abc','','Pune','IN','Maharashtra','02039399');
     //   PRM_CIMCalloutNEW prmUICimCallout = new PRM_CIMCalloutNEW();
        Address address = new Address('Magarpatta','Hadapsar','Pune','IN','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='India';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        
        
        Account__c customSetting = new Account__c();
        customSetting.PRM_Max_Account_Number__c = '63628892297';
        customSetting.Name ='AccountNumber';
        insert customSetting;
        Id INTEL_ACCOUNT_RT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
        List<Id> accIDs = new List<ID>();
        Account acc = new Account();
        acc.Name='John Rick';
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='IND';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_IPA_Partner_Segment__c= 'Data Center';
       // acc.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc.Core_User_Defined_Website__c = 'www.test.com';
        acc.RecordTypeId=INTEL_ACCOUNT_RT;
      //  acc.Core_Export_Compliance_Block__c=false;
        acc.Core_Deactivated__c=false;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.Core_Business_Party_Id__c ='4567';
        
        insert acc;
        
        
        Account acc1 = new Account();
        acc1.Name='Johny Rick';
        acc1.BillingCity='City main';
        acc1.BillingStreet='Street main';
        acc1.BillingCountry='IND';
     //   acc1.BillingCountryCode='IN';
        acc1.BillingPostalCode='Postal code';
        acc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc1.Core_IPA_Partner_Role__c = 'Service Provider';
        acc1.Core_IPA_Partner_Segment__c= 'Data Center';
        acc1.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc1.Core_User_Defined_Website__c = 'www.newtest.com';
        acc1.RecordTypeId=INTEL_ACCOUNT_RT;
        acc1.Core_Export_Compliance_Block__c=false;
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc1.Core_Deactivated__c=false;
        insert acc1;
          contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@test.com';
        ct.AccountId=acc.id;
		ct.mailingcountry='India';
        insert ct;
        
        PRM_SBC_Account_Search_Configuration__c sbcConfig=new PRM_SBC_Account_Search_Configuration__c();
        sbcConfig.Account__c=acc1.Id;
        sbcConfig.Email_Domain__c='pa.com';
        sbcConfig.Country__c='India';
        insert sbcConfig;
        
         PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
       
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Account_Id__c = acc.id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Status_Change_Dt__c=system.now();
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Name = 'Intel Partner Alliance';
        channelProgram.PRM_programCode__c = 'IPA';
       // channelProgram.IsActive= true;
        insert channelProgram;
        
        ChannelProgramLevel channelProgramlevel = new ChannelProgramLevel();
        channelProgramlevel.Name ='Partner';
        channelProgramlevel.ProgramId = channelProgram.Id;
        insert channelProgramlevel;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        acm.PRM_Channel_Program_Id__c=channelProgram.id;
        acm.PRM_Channel_Program_Level_Id__c = channelProgramlevel.Id;
        acm.PRM_Status_Reason_Txt__c='Test';
        acmList.add(acm); 
        
        
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Partner_Role__c = 'Service Provider';
        acm1.PRM_Account_Id__c = acc1.id;
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Status_Change_Dt__c=system.now();
        acm1.PRM_Channel_Program_Id__c=channelProgram.id;
        acm1.PRM_Channel_Program_Level_Id__c=channelProgramlevel.Id;
        acm1.PRM_Status_Reason_Txt__c='Test';
        acmList.add(acm1); 
        
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Partner_Role__c = 'Service Provider';
        acm2.PRM_Account_Id__c = acc.id;
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Status_Change_Dt__c=system.now();
        acm2.PRM_Channel_Program_Id__c=channelProgram.id;
        acm2.PRM_Channel_Program_Level_Id__c=channelProgramlevel.Id;
        acm2.PRM_Status_Reason_Txt__c='Test';
        acmList.add(acm2);
        
        insert acmList;
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.PRM_Agreement_Cd__c = 'IPA_TANDC';
        pa.PRM_InActive_Ind__c = false;
      //  pa.PRM_Agreement_Category_Nm__c = 'Intel Partner Alliance Terms & Conditions';
        pa.PRM_Channel_Program_Id__c = channelProgram.id;
        insert pa;
        
        PRM_AccountLegalAgreemntAssociation__c ala = new PRM_AccountLegalAgreemntAssociation__c();
        ala.PRM_Account_Id__c = acc.Id;
        ala.PRM_Partner_Agreement_Id__c = pa.Id;
        ala.PRM_InActive_Ind__c = false;
        ala.PRM_Contact__c = ct.Id;
        ala.PRM_Agreement_Sign_Dt__c = System.today()+7;
        insert ala;
        
        PRM_AccountLegalAgreemntAssociation__c ala1 = new PRM_AccountLegalAgreemntAssociation__c();
        ala1.PRM_Account_Id__c = acc.Id;
        ala1.PRM_Partner_Agreement_Id__c = pa.Id;
        ala1.PRM_InActive_Ind__c = false;
        ala1.PRM_Contact__c = ct.Id;
        ala1.PRM_Agreement_Sign_Dt__c = System.today()+7;
        insert ala1;
        
        accIDs.add(acc.id);

       PRM_CIM_Request__mdt cimMdt = PRM_CIM_Request__mdt.getinstance('PRM_Dupe_Scores'); 
        
        Test.startTest();
        PRM_SearchAccountsNew.PartnerRoleInfo pr=new PRM_SearchAccountsNew.PartnerRoleInfo(acm.PRM_Partner_Role__c,acm.PRM_Channel_Program_Level_Id__r.name,acm.PRM_Status_Nm__c,acm.PRM_Status_Change_Dt__c);
        list<PRM_SearchAccountsNew.PartnerRoleInfo> partnerrolesinfo2=new list<PRM_SearchAccountsNew.PartnerRoleInfo>{pr};
        PRM_SearchAccountsNew sn=new PRM_SearchAccountsNew(acc.Id,'1234','4567', acc, 10,'Members',1,3,partnerrolesinfo2);
        PRM_SBCSearchResults.partnerRolesInfo parole = new PRM_SBCSearchResults.partnerRolesInfo();
        parole.PartnerRole = 'Service Provider';
        parole.status = 'Complete';
        parole.statusChangeDt = String.valueOf(System.now());
        parole.Tier = 'Partner';//'Gold';
        PRM_SBCSearchResults.AccountAddress paccadd = new PRM_SBCSearchResults.AccountAddress();
        paccadd.StateCode2 = 'UP';
        paccadd.City = 'Delhi';
        paccadd.AddressLine2 = 'india test new';
        paccadd.CountryCode2 = 'IND';
        paccadd.AddressLine1 = 'Test address 2';
        paccadd.PostalCode ='243574';
        
        List<Core_Intel_System_Accounts__mdt> listsystemacc = [select AccountId__c from Core_Intel_System_Accounts__mdt limit 1];
        req.requestURI = 'https://quoterequest.intel.com/--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_CIMAccountSearchNew.doPost('companyName', address, 'www.abc.com', '','123','3', '80');
        istruetest=true;
        if(istruetest){
            PRM_CIMAccountSearchNew.doPost(acc1.name, address, 'www.abc.com', '()','@','3', '80');
             PRM_CIMAccountSearchNew.doPost(acc1.name, address1, 'www.abc.com', '()','@',' ', ' ');
            PRM_CIMAccountSearchNew.doPost(acc.Name,address, 'www.testAccount.com','Cloud Service Provider (CSP)','account@test.com','','');
        }
        
        PRM_CIMAccountSearchNew.getAccountLegalAgreements(accIDs);    
        PRM_CIMAccountSearchNew.performStep2Search('www.test.com', 'John Rick','IND', res,sysAccs);
        PRM_CIMAccountSearchNew.billingCountryForAPI='India';
        PRM_CIMAccountSearchNew.performStep1Search('new@test.com');
        PRM_CIMAccountSearchNew.ipaCheck(true,false);
        PRM_CIMAccountSearchNew.ipaCheck(true,true);
        PRM_CIMAccountSearchNew.ipaCheck(false,true);
        PRM_CIMAccountSearchNew.ipaCheck(false,false);
        PRM_CIMAccountSearchNew.createPartnerRolInfo(acm);
        PRM_CIMAccountSearchNew.getRecordsforSorting(accIDs,acmList);

       //  PRM_CIMAccountSearchNew.performStep2Search('www.null.com', 'null','IND', res);
       // PRM_CIMAccountSearchNew.performStep1Search('new@pa.com');
        Test.stopTest();
        System.assertEquals('https://quoterequest.intel.com/--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
    }
    
    @isTest 
    public static void DoPostTest_Two(){   
        set<string> sysAccs=new set<string>();
        sysAccs.add('xyz');

        Address address = new Address('Magarpatta','Hadapsar','Pune','IN','Maharashtra','02039399');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        Test.startTest();
        req.requestURI = 'https://quoterequest.intel.com/--nppdev.lightning.force.com';  // sample Endpoint
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;
        PRM_SBCSearchResults FinalsearchResult;
        Id INTEL_ACCOUNT_RT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
        List<Id> accIDs = new List<ID>();
        Account acc12 = new Account();
        acc12.Name='Johny Rick null';
        acc12.BillingCity='City main road';
        acc12.BillingStreet='Street main road';
        acc12.BillingCountry='IND';
     //   acc1.BillingCountryCode='IN';
        acc12.BillingPostalCode='Postal code';
        acc12.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc12.Core_IPA_Partner_Role__c = 'Distributor';
        acc12.Core_IPA_Partner_Segment__c= 'Data Center';
        acc12.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc12.Core_User_Defined_Website__c = 'www.newtesting.com';
        acc12.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
	acc12.RecordTypeId=INTEL_ACCOUNT_RT;
        insert acc12;
        
        accIDs.add(acc12.id);
        
        contact ct2 = new contact();
        ct2.FirstName='None ipa';
        ct2.LastName='New ipa';
        ct2.Email='new@testipa.com';
        ct2.AccountId=acc12.id;
		ct2.mailingcountry='India';
        insert ct2;
        
        PRM_SBC_Account_Search_Configuration__c sbcConfig12=new PRM_SBC_Account_Search_Configuration__c();
        sbcConfig12.Account__c=acc12.Id;
        sbcConfig12.Email_Domain__c='pa.com';
        sbcConfig12.Country__c='India';
        insert sbcConfig12;
        
         PRM_AccountChannelMembership__c acm12 = new PRM_AccountChannelMembership__c();
       
        acm12.PRM_Partner_Role__c = 'Service Provider';
        acm12.PRM_Account_Id__c = acc12.id;
        acm12.PRM_Status_Nm__c = 'Approved';
        
        
        ChannelProgram channelProgram12 = new ChannelProgram();
        channelProgram12.Name = 'Intel Partner Alliance';
        channelProgram12.PRM_programCode__c = 'IPA';
       // channelProgram.IsActive= true;
        insert channelProgram12;
        
        ChannelProgramLevel channelProgramlevel12 = new ChannelProgramLevel();
        channelProgramlevel12.Name ='Partner';
        channelProgramlevel12.ProgramId = channelProgram12.Id;
        insert channelProgramlevel12;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        acm12.PRM_Channel_Program_Level_Id__c = channelProgramlevel12.Id;
        acmList.add(acm12);   

        PRM_CIMAccountSearchNew.doPost('companyName',address, 'www.newtesting.com', '124 ','100','3', '80');
        PRM_CIMAccountSearchNew.ipaCheck(true,false);
        PRM_CIMAccountSearchNew.ipaCheck(true,true);
        PRM_CIMAccountSearchNew.ipaCheck(false,true);
        PRM_CIMAccountSearchNew.ipaCheck(false,false);
        PRM_CIMAccountSearchNew.performStep2Search(' ', 'null','abc', res,sysAccs);
          PRM_CIMAccountSearchNew.billingCountryForAPI='India';
        PRM_CIMAccountSearchNew.performStep1Search('new@pa.com');
        PRM_CIMAccountSearchNew.getRecordsforSorting(accIDs,acmList);
        PRM_CIMAccountSearchNew.getAccountLegalAgreements(accIDs); 
              Test.stopTest();
        System.assertEquals('https://quoterequest.intel.com/--nppdev.lightning.force.com', req.requestURI, 'Incorrect URI');
        System.assertEquals('https://quoterequest.intel.com/--nppdev.lightning.force.com', req.requestURI, '400');
    }
    
    
  
}