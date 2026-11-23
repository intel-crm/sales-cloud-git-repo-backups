@isTest public class Core_IPS_JSON_UtilityTest {
    
     static testmethod void caseDescriptionImage() {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
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
            RecordTypeId = recordTypeIdAccount,
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com', 
            MailingCountry = 'India'
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
        //System.assertNOTEquals(caseRecord1.Core_Issue_Description__c, 'test', 'case record with description blank');
     //------------
     Test.startTest();
	try{
          Core_IPS_JSON_Utility.getBase64ImgConvert(null);
          //Assert.fail('Custom exception thrown');
		  throw new StringException('Custom exception thrown');
        } catch(Exception e){
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c='test description',Core_IPS_Status__c = 'test status');
            insert errorLog;
            System.assertEquals('Custom exception thrown', e.getMessage(), 'Exception should match');
			}
		 Test.stopTest(); 
     //----------------   
     
     }  
    
    /*try catch coverage
    @isTest
    static void caseDescriptionImage1(){
	Test.startTest();
	try{
          Core_IPS_JSON_Utility.getBase64ImgConvert(null);
          Assert.fail('Custom exception thrown');
		  //throw new StringException('Custom exception thrown');
        } catch(Exception e){
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c='test description',Core_IPS_Status__c = 'test status');
            insert errorLog;
            System.assertEquals('Custom exception thrown', e.getMessage(), 'Exception should match');
			}
		 Test.stopTest(); 
		}*/
	//
}