@isTest
public class UCD_AccountConnector_SBR_Test {
    
        @isTest static  void testGetCallout() {
        UCD_AccountInfoWrapper sampleInput = new UCD_AccountInfoWrapper();
        sampleInput.accName = 'Dell';
        sampleInput.addressLine1 = 'Whitefield';
        sampleInput.addressLine2 = 'Address line 2';
        sampleInput.accPostalCode = '123123';
        sampleInput.accCity = 'Bangalore';
        sampleInput.accCountry = 'IND';
        sampleInput.accStateProvince = 'KA';
        sampleInput.rcdLimit = '25';
        sampleInput.searchScore = '55';
        sampleInput.companyWebsite = 'www.dell.com';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CIMResponse1');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        String countryname = 'India';
        String countrycode = UCD_AccountConnector_SBR.getCountryCode(countryname);
        system.assertEquals(countrycode, 'IND');
        String countryname2 = UCD_AccountConnector_SBR.getCountryName(countrycode);
        system.assertEquals(countryname2, 'India');
        String stateCode = 'KA';
        String stateName = UCD_AccountConnector_SBR.getStateAndCountryName(stateCode);
        String stateCode2 = UCD_AccountConnector_SBR.getStateName(stateName);
    }
    @isTest static  void testCreateAccountFromCIMData() {
        UCD_CIMModel cimdata = new UCD_CIMModel();
        cimdata.cimID = '11172847';
        cimdata.accName='Adonios Inc';
        cimdata.physicalStreetAddr='6656 Dobbin Rd Ste E';
        cimdata.physicalState='MD';
        cimdata.physicalCountry='USA';
        UCD_AccountModel accCreated = new UCD_AccountModel(); 
        Account newAccount = new Account();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();    
        newAccount.RecordTypeId = accountRecordType; 
        newAccount.Name =cimdata.accName;
        newAccount.Core_CIM_ID__c =cimdata.cimID;
        newAccount.BillingStreet =cimdata.physicalStreetAddr;
        newAccount.BillingCity ='Columbia';
        newAccount.BillingPostalCode ='213213';
        newAccount.BillingCountryCode ='USA';
        newAccount.BillingState =cimdata.CountrySubdivisionCd;
        insert newAccount;
        system.assertEquals(newAccount.Name, 'Adonios Inc');
    }
    @isTest static  void findAccountsTest(){
        UCD_AccountConnector_SBR ufind = new UCD_AccountConnector_SBR();
       Account c = new Account();
        c.Core_CIM_ID__c = '12345';
        c.name = 'Sample Account';
        c.BillingStreet= 'Whitefield';
        c.BillingState= 'MD';
        c.BillingCity= 'Bangalore';
        c.BillingCountry = 'USA';
        system.assertEquals('USA', c.BillingCountry);
        insert c;
        UCD_AccountConnector_SBR.findAccounts('Whitefield', '');
        system.debug('!!!!!!!!!!!#########'+UCD_AccountConnector_SBR.findAccounts('Whitefield', ''));
    }
    @isTest static void getOwnerNameTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standtee', Email='standarduser@testorg.intel.com', 
            EmailEncodingKey='UTF-8', LastName='UCDTesting', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.intel.com');
        system.assertEquals('standtee', u.Alias);
        insert u;
        UCD_AccountConnector_SBR ufind = new UCD_AccountConnector_SBR();
        UCD_AccountConnector_SBR.getOwnerName(u.id);
        system.assertEquals(UCD_AccountConnector_SBR.getOwnerName(u.id), 'UCDTesting'); 
    }
    @isTest static  void getSalesCloudAccount() {
        Account c = new Account();
        c.Core_CIM_ID__c = '12345';
        c.name = 'Sample Account';
        c.BillingStreet= 'Whitefield';
        c.BillingState= 'MD';
        c.BillingCity= 'Bangalore';
        c.BillingCountry = 'USA';
        system.assertEquals('USA', c.BillingCountry);
        insert c;
        Map<String,String> cimIdandScore = new Map<String,String>();
        cimIdandScore.put('12345','FullDup');
        UCD_AccountConnector_SBR.findAccountOwners('12345', c.id);
        UCD_AccountConnector_SBR.findAccountOwners('12345', '');
        UCD_AccountModel ac = new UCD_AccountModel();
        ac.accId = c.id;   
        ac.accName = c.Name;
    }
    
    @isTest static void fetchStateCountryValuesTest(){
        //Map<String,List<String>> countryStateCombo = UCD_AccountConnector.fetchStateCountryValues();
		//system.assertNotEquals(null, countryStateCombo.size());
    }

}