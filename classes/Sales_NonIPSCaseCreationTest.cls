@isTest
public class Sales_NonIPSCaseCreationTest {
    @testSetup static void setup() {
        User u1 = createUserWithProfile();
        insert u1;       
    }
    
    @isTest 
    public static void nonIpsCaseTest(){
        String description='testdata';
        String productName='testproductname';
        String subject='other';
        User u1=[select id from user where LastName='test Last' limit 1];
        Test.startTest(); 
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
        OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
        Sales_License__c lic = [Select Id, Sales_License_Order_Product__c,Sales_License_Activation_Code__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
        String companionServerId='BBBBAAAACCCC';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
        System.runAs(u1) {
            Sales_NonIPSCaseCreation.checkIPSUser();
            Sales_NonIPSCaseCreation.checkExternal();
            Sales_NonIPSCaseCreation.fetchNonIPSCaseCreation();
            Sales_NonIPSCaseCreation.validateFieldsCaseCreation(ord.Sales_PO_Number_Txt__c,lic.Sales_License_Activation_Code__c,hostRecord.Temporary_NIC_ID__c,description, productName,subject );
        }
        Test.stopTest();            
        
    } 
    
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID'){
            h.Name='AAAAAABC'; 
        }else if(compType=='NIC ID'){
            h.Name='AAAAAABBBBEF';  
        }                  
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c=true;
        insert h;
        return h;
    }
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'APJ Partner Holding';       
        insert acc;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        insert con;
        return con;
    }
    public static OrderItem createOrderProductWithContact(Id ordId, Id prodId, Id pbEntryId, Id ContactId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.SBQQ__Status__c='Draft';
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = ContactId;
        insert i;
        return i;
    }
    public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'	);
        return user;
    }
}