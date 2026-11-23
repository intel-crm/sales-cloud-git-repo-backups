@isTest
public class Sales_OrderConfirmationControllerTest {
     /*@isTest 
    public static void testorderConfirmation(){
      String errMsg='';
        String description='testdata';
        String productName='testproductname';
        String subject='I can\'t see/find a product that I want to license';

        
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
        
        try{
            Test.startTest(); 
            //Creating License
            OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
            Sales_License__c lic = [Select Id, Sales_License_Order_Product__c,Sales_License_Activation_Code__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
            //Creating Host
            String companionServerId='BBBBAAAACCCC';
            Sales_OrderConfirmationController orderconfirm= new Sales_OrderConfirmationController();
            orderconfirm.getOrderItems();
            Test.stopTest();            
            }catch(Exception e){
            System.debug('Error msg -->'+e.getMessage());
            errMsg=e.getMessage();
            } 
        System.assert(errMsg=='', errMsg);
    } 
  
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   // PSG Downstream true
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
    }*/
    
    /*@isTest 
    public static void testOrderConfirmation(){
        Id dummyOrderId = Sales_TestDataFactory.getFakeId(Order.SObjectType);
        Test.startTest();
        Sales_OrderConfirmationController orderConfirm= new Sales_OrderConfirmationController();
        orderConfirm.orderItem = null;
        List<OrderItem> returnedList = orderConfirm.getOrderItems();
        Test.stopTest();
        System.assert(returnedList.isEmpty());
    }
*/
}