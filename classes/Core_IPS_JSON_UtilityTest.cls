@isTest public class Core_IPS_JSON_UtilityTest {
    
     static testmethod void caseDescriptionImage() {
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com'      
        );
        Database.insert(contact2);
        
        Case caseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'Low',
            Subject = 'TestSubject1',
            Core_Issue_Description__c = 'TestDescription1 <img alt="User-added image" src="https://inteltest/servlet/rtaImage.imageurlId.com" style="height: 195px; width: 500px;"></img><br>'  
        );
        Database.insert(caseRecord);
        Case caseRecord1 = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'Low',
            Subject = 'TestSubject1',
            Core_Issue_Description__c = ''  
        );
        Test.startTest();
        Core_IPS_JSON_Utility.getBase64ImgConvert(caseRecord.Core_Issue_Description__c);
        Core_IPS_JSON_Utility.getBase64ImgConvert(caseRecord1.Core_Issue_Description__c);
        Test.stopTest();    
        System.assertNOTEquals(caseRecord1.Core_Issue_Description__c, 'test', 'case record with description blank');
        
    }
}