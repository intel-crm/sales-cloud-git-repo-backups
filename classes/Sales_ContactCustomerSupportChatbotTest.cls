@isTest
public class Sales_ContactCustomerSupportChatbotTest {
    @isTest
    public static void Sales_ContactCustomerSupportChatbotTest(){
        String errMsg = '';
         String description='testdata';
        String productName='testproductname';
        String subject='Other';
        Sales_ContactCustomerSupportChatbot.ComputerInput Input  = new Sales_ContactCustomerSupportChatbot.ComputerInput();
        Sales_NonIpsCaseCreationChatbot.pickListWrapper Wrapper=new Sales_NonIpsCaseCreationChatbot.pickListWrapper();
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact partnerContact = createContactWithDetails(acc.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Order ord = Sales_TestFactory_Utility.createOrders(acc.Id, Test.getStandardPricebookId(), 'Sample Order');     
        OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
        Sales_License__c lic = [Select Id, Sales_License_Order_Product__c,Sales_License_Activation_Code__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
        String companionServerId='BBBBAAAACCCC';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
        Wrapper.label=subject;
        Wrapper.value=subject;
        Input.WrapperObj=Wrapper;
        Input.ContactId=partnerContact.Id;
        Input.PoNo=ord.Sales_PO_Number_Txt__c;
        Input.LacSerialNo=lic.Sales_License_Activation_Code__c;
        Input.HostId=hostRecord.Temporary_NIC_ID__c;
        Input.ProdName=productName;
        Input.description=description;
            System.Test.startTest();
        try{
            Sales_ContactCustomerSupportChatbot.CreateNonIpsCase(new List<Sales_ContactCustomerSupportChatbot.ComputerInput>{Input});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAAAAABC';                  
        else if(compType=='NIC ID')
            h.Name='AAAAAABBBBEF';              
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c = true;  
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
        acc.Core_Sales_Groups__c = 'CCG Sales Group';       
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
}