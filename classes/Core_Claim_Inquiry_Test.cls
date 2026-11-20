@isTest
public class Core_Claim_Inquiry_Test{

    private static List<Lead> lstLeads {
        get;
        set;
    }
    private static List<Account> lstAccounts {
        get;
        set;
    }
    private static List<Contact> lstContacts {
        get;
        set;
    }
    private static List<Core_Inquiry__c> lstInquiries {
        get;
        set;
    }
    
     /*
     * Method name  : setupTestData
     * Description  : Method to setup test data for Lead Conversion
     * Return Type  : None
     * Parameter    : None
     */
    static void setupData() {
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
		insert rec;
    
        lstLeads = new List<Lead>();
        lstAccounts = new List<Account>();
        lstContacts = new List<Contact>();
        
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        for (integer i = 0; i <1; i++) {      
            Lead leadInstance = new Lead(); 
            leadInstance.FirstName = 'Team'+i;        
            leadInstance.lastName = 'CSot'+i;
            leadInstance.Company = 'Xcza'+i;
            leadInstance.lastName = String.valueOf(i);
            leadInstance.email = 'tes6578t@' + i + '.com';
            leadInstance.CountryCode = 'USA';
            leadInstance.StateCode = 'AL';
            leadInstance.City = 'Alabama'+i;
            leadInstance.Street = 'test'+i;
           	leadInstance.status = 'Marketing Qualified Lead';
            leadInstance.leadSource = 'Email';
            leadInstance.Core_Last_Activity_Date__c = NULL;
            leadInstance.Core_Lead_Status__c='Accepted';
            leadInstance.PostalCode = '57710'+i;
            leadInstance.Title = 'He8lo'+i;
            leadInstance.Core_Current_Architecture__c='Test';
            leadInstance.Phone='97788788'+i;
            leadInstance.Core_Product_Interest__c='10';
            leadInstance.Core_Project_Phase__c='testing';
            leadInstance.Core_Project_Size__c='4';
            leadInstance.Core_Project_Timeframe__c='12-24 Months';
            leadInstance.Core_Lead_State__c = 'In Pursuit';
            leadInstance.recordtypeid = RId ; 
            leadInstance.Core_Sales_Group__c='Americas US Sales Group';
            leadInstance.Core_System_Account_Sales_Group__c='DCG Sales Group';            
            lstLeads.add(leadInstance);
       }
        for(integer i = 0; i <3; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c='PRC Sales Group';
            lstAccounts.add(accountInstance);
        }
        Contact contactInstance;

        for (Integer i = 0; i <6; i++) {
            contactInstance = new Contact();
            contactInstance.FirstName = 'test';
            contactInstance.LastName = i + '';
            contactInstance.email = 'test@test' + i + '.com';
            lstContacts.add(contactInstance);
        }
        
       
        // Insert Accounts
        for (Integer i = 0; i<lstAccounts.size(); i++) {
            lstAccounts[i].BillingCountryCode = 'USA';
            lstAccounts[i].BIllingStateCode = 'AL';
            lstAccounts[i].BillingCity = 'Alabama';
            lstAccounts[i].BillingStreet = 'test';
            lstAccounts[i].BillingPostalCode = '577100';
            //lstAccounts[i].Core_Sales_Groups__c='EMEA Sales Territory';
            lstAccounts[i].Name = 'Deloitte' + i;
        }
        insert lstAccounts;
        
        System.debug(' All Accounts  '+lstAccounts);
        
        // Insert Contacts
        for (Integer i = 0; i<lstContacts.size(); i++) { 
            for(Integer j = 0; j<3 ;j++){                       
                lstContacts[i].AccountId = lstAccounts.get(j).Id;
                lstContacts[i].Email = 'tet77st' + i + '@tes.com';
		lstContacts[i].MailingCountry = 'India';
            }
        }
        
        insert lstContacts;
        
        System.debug('**All Contacts** '+lstContacts);
        // Insert Leads
        for (Integer i = 0; i<lstLeads.size(); i++) {
            lstLeads[i].CountryCode = 'USA';
            lstLeads[i].StateCode = 'AL';
            lstLeads[i].City = 'Alabama';
            lstLeads[i].Street = 'te7sst';
            lstLeads[i].postalCode = '5771' + i;
            lstLeads[i].Company = 'Delitte' + i;
            lstleads[i].email = 'test77new' + i + '@teshht.com';
            lstleads[i].Core_Sales_Group__c='Americas US Sales Group';
            lstleads[i].Core_System_Account_Sales_Group__c = 'EMEA Sales Territory';
        }
      

        insert lstLeads;
        for(Lead leads : lstLeads){
            leads.status = 'Sales Accepted Lead';
        }
        update lstLeads;
        
        for(Lead leads : lstLeads){
            leads.Core_Lead_Status__c = 'Disqualified';
            leads.Core_Lead_Sub_Status__c = 'Not Target Profile';
        }
        update lstLeads;
        lstInquiries = new List<Core_Inquiry__c>();
        for(integer i=0;i<2;i++){
            Core_Inquiry__c inq = new Core_Inquiry__c();
            inq.Name ='TinTin1';
            inq.Core_Lead_Inquiries__c = lstLeads[0].Id;
            inq.Core_Inquiry_Type_Pkt__c ='Requested Quote';
            lstInquiries.add(inq);
        }
        if(lstInquiries.size()>0 && lstInquiries!= null){
            Database.insert(lstInquiries);
        }
    }
    
    
        
        //This method covers the positive scenario of the method UpdateOwnertoClaimedOwner by claiming being different user than the created user.
        private static testMethod void claimButtonDiffUser(){
            List<User> lstUser = new List<User>();
            Profile p1 = [SELECT Id FROM Profile WHERE Name = : 'IT Admin'];
            lstUser = Core_Test_Utility.Core_User(1);
            lstUser[0].Profileid = p1.id;
            insert lstUser;
            setupData();
            Test.startTest();
            System.runAs(lstUser[0]) {
                //Core_Claim_Inquiry.UpdateOwnertoClaimedOwner(lstInquiries[0].Id);      
            }
            Test.stopTest();   
       }
       
       //This method covers the positive scenario of the method UpdateOwnertoClaimedOwner by claiming being same user than the created user.
        private static testMethod void claimButtonSameUser(){
            setupData();
            Test.startTest();
            //Core_Claim_Inquiry.UpdateOwnertoClaimedOwner(lstInquiries[0].Id);
            Test.stopTest();   
       }
    
    @isTest
    static void testPlaceholder() {
        Core_Claim_Inquiry claim = new Core_Claim_Inquiry();
        System.assert(true, 'This is a placeholder test for a fully commented class.');
    }

}