@isTest
// Added AssertEquals Added By Chiranjeevi - 31-JAN-2024
public class Core_IPS_MyIntelDataExport_Test {
    public static TestMethod void testMethod1(){
   
        Account caseAccount = TestUtilities.getAccountRecord();
        caseAccount.Name = 'HP Products1212';
        insert caseAccount;
        System.assert(caseAccount.Id != null, 'Record not created');

		Account projectAccount = TestUtilities.getAccountRecord();
        projectAccount.Name = 'HP Products';
        insert projectAccount;
        System.assert(projectAccount.Id != null, 'Record not created');

        
        Account caseContactAccount = TestUtilities.getAccountRecord();
        caseContactAccount.Name = 'Sony Products';
        insert caseContactAccount;
        System.assert(caseContactAccount.Id != null, 'Record not created');

        Contact caseContact = new Contact();
        caseContact.FirstName = 'Test';
        caseContact.LastName = 'Contact1';
        caseContact.Email = 'testemail@email.com';
        caseContact.Core_Enterprise_Id__c = '88899';
        caseContact.AccountId = caseAccount.Id;
        caseContact.Core_IPS_Active__c = true;
        caseContact.MailingCountry = 'India';
        insert caseContact;
        System.assert(caseContact.Id != null, 'Record not created');

        Contact projectMemberContact = new Contact();
        projectMemberContact.FirstName = 'Testi';
        projectMemberContact.LastName = 'Contact2';
        projectMemberContact.Email = 'testemail2@email.com';
        projectMemberContact.Core_Enterprise_Id__c = '99988';
        projectMemberContact.AccountId = projectAccount.Id;
        projectMemberContact.MailingCountry = 'India';
       
        insert projectMemberContact;
        System.assert(projectMemberContact.Id != null, 'Record not created');

        Contact projectMemberContact2 = new Contact();
        projectMemberContact2.FirstName = 'Testing';
        projectMemberContact2.LastName = 'Contact3';
        projectMemberContact2.Email = 'testemail333@email.com';
        projectMemberContact2.Core_Enterprise_Id__c = '19988';
        projectMemberContact2.AccountId = projectAccount.Id;
        projectMemberContact2.MailingCountry = 'India';
       
        insert projectMemberContact2;
		System.assert(projectMemberContact2.Id != null, 'Record not created');


        Product2 product = TestUtilities.getProduct();
        insert product;
		System.assert(product.Id != null, 'Record not created');


        Core_IPS_Project__c premierProjectRecord = new Core_IPS_Project__c();
        insert premierProjectRecord;
		System.assert(premierProjectRecord.Id != null, 'Record not created');

        
        Core_IPS_Account__c premierProjectAccount = new Core_IPS_Account__c();
        premierProjectAccount.Core_Account__c = projectAccount.Id;
        premierProjectAccount.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectAccount;
        System.assert(premierProjectAccount.Id != null, 'Record not created');

        Core_IPS_Project_Member__c premierProjectMember = new Core_IPS_Project_Member__c();
        premierProjectMember.Core_IPS_Contact__c = projectMemberContact.Id;
        premierProjectMember.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectMember;
        System.assert(premierProjectMember.Id != null, 'Record not created');

        Core_IPS_Project_Member__c premierProjectMember2 = new Core_IPS_Project_Member__c();
        premierProjectMember2.Core_IPS_Contact__c = projectMemberContact2.Id;
        premierProjectMember2.Core_IPS_Project__c = premierProjectRecord.Id;
        insert premierProjectMember2;
		System.assert(premierProjectMember2.Id != null, 'Record not created');

        Case caseRecord = new Case();
        caseRecord.Core_IPS_Project_Case__c = premierProjectRecord.Id;
        caseRecord.Subject = 'Test Subject';
        caseRecord.ProductId = product.Id;
        caseRecord.Status = 'Open';
        caseRecord.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord.AccountId = caseAccount.Id;
        caseRecord.ContactId = caseContact.Id;
        caseRecord.Core_CaseType__c = 'Debug Request';
        caseRecord.Core_IPS_Customer_Visible__c = true;
        insert caseRecord;
        System.assert(caseRecord.Id != null, 'Record not created');

        Case caseRecord1 = new Case();
        
        caseRecord1.Subject = 'Test Subject';
        caseRecord1.ProductId = product.Id;
        caseRecord1.Status = 'Open';
        caseRecord1.CreatedDate = DateTime.parse(System.Now().format());
        caseRecord1.LastModifiedDate = DateTime.parse(System.Now().format());
        caseRecord1.AccountId = caseAccount.Id;
        caseRecord1.ContactId = caseContact.Id;
        caseRecord1.Core_CaseType__c = 'Debug Request';
        caseRecord1.Core_IPS_Customer_Visible__c = true;
        insert caseRecord1;
        System.assert(caseRecord1.Id != null, 'Record not created');

        List<Core_IPS_Case_Interested_Party__c> intrestedParties = TestUtilities.getInternalInterestedParties(2);
        
        intrestedParties[0].Case__c = caseRecord1.Id;
         intrestedParties[1].Case__c = caseRecord.Id;
         //Added by Sowmya - Start - 25/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
         intrestedParties[0].Contact__c = projectMemberContact.Id;
         intrestedParties[1].Contact__c = projectMemberContact2.Id;
        //Sowmya - End - 25/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
       
        insert intrestedParties;
        System.assert(intrestedParties[0].Id != null, 'Record not created');

        Test.startTest();  
        String query = 'select id,casenumber,subject,Product.Name,Core_ConEmail__c,Core_IPS_Project_Case__c,Core_IPS_Product_name__c, Status,CreatedDate, LastModifiedDate, AccountId, ContactId, Core_CaseType__c, ContactEmail,'+
            'Contact.Core_Enterprise_Id__c,Core_IPS_Customer_Visible__c  from case where CreatedDate > 2020-06-07T00:00:00Z and CreatedDate < 2050-09-07T00:00:00Z';
        Core_IPS_MyIntelDataExport myIntelData = new Core_IPS_MyIntelDataExport(query);

        Database.executeBatch(myIntelData, 200); 
        Test.stopTest(); 
        System.AssertEquals(intrestedParties.size()>0, true);
    }
    

}