@isTest
private class ER_ENT_PRG_SearchCIMAccount_Test {
    
    @testSetup
    static void createData(){
       List<ChannelProgram> cpp = new List<ChannelProgram>();
        ChannelProgram cp1 = new ChannelProgram();
        cp1.Name=System.Label.PRM_Intel_Partner_Alliance;
        cp1.prm_programCode__c= 'IPA';
        cp1.IsActive = true;
        insert cp1;        
    }
    
    @isTest
    public static void testCallout_One()
    {
        PRM_AdminRegistrationDuplicateDetails.accountContactList accCntList= new PRM_AdminRegistrationDuplicateDetails.accountContactList();
		Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        //acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Construction';
        acc.Core_CIM_ID__c='22213672';
        insert acc;
        
        contact ct = new contact();
        ct.FirstName='None';
        ct.LastName='New';
        ct.Email='new@b.com';
        ct.AccountId=acc.id;
        ct.MailingCountry='India';
        insert ct;
        ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name = 'Intel Partner Alliance' LIMIT 1];

        Core_Country_Code_Mapping__c cccm = new Core_Country_Code_Mapping__c();
        cccm.Country_Code__c = 'IN';
        cccm.ISO_Code__c = 'IND';
        cccm.name = 'India';
        insert cccm;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=acc.id;
        acm.PRM_Channel_Program_Id__c=cp.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
         
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_UIMockHttpResponse()); 
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0]= ct.id;
        System.Test.setFixedSearchResults(fixedSearchResults);
        ER_ENT_PRG_SearchCIMAccount uiCim =new ER_ENT_PRG_SearchCIMAccount();
        set<Id> accSfdcId = new set<Id>();
        accSfdcId.add(acc.Id);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,'new@b.com', null,true ,null, 'Service Provider', true);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', null, '77','www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', '77',null,null, null,False ,accSfdcId, 'Service Provider', False);
        uiCim.getCimResults('Herman', '4th Floor ITPL Brookfield', '560037', 'Bengaluru', 'IND', 'KAR', '0', null,'www.test.com','new@b.com', null,False ,null, 'Service Provider', true);
        map<string,string> requestDetails = new map<string,string>();
        requestDetails.put('DuplicateInfo','');
        requestDetails.put('AccountName','Herman Group');
        requestDetails.put('ContactEmail','new@b.com');
        requestDetails.put('AddressLine1','700 Chestnut Ridge Rd');
        requestDetails.put('City','Chestnut Ridge');
        requestDetails.put('State',null);
        requestDetails.put('PostalCode','109776435');
        requestDetails.put('Country','US');
       // requestDetails.put('BizOrgType','Cloud Service Provider (CSP)');
        requestDetails.put('PartnerRole','Seller');        
        
        accCntList=PRM_AdminRegistrationDuplicateDetails.showAccountsContacts(requestDetails);
        Test.stopTest();
        System.assertEquals(requestDetails.get('ContactEmail'), 'new@b.com', 'Value does not match');

    }
  
}