/*********************************************************************************************************************
Class Name    : Sales_LicenseTriggerHandlerTest
Version       : 1.0
Created Date  : April 2021  
Function      :  
`
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain          22-Apr-2021              Test class for Sales_LicenseTriggerHandler
* *********************************************************************************************************************/
@isTest
public class Sales_LicenseTriggerHandlerTest{
    /*public static void shareMethodsTest(){
        String errMsg='';
        Account partnerAccount;
        Contact partnerContact ;
        Contact partnerContact2;
        Contact partnerContact3 ;
        User u1 ;
        User u2 ;
        User u3 ;
        List<User> users ;
        Product2 prod1 ;
        Pricebookentry pbEntry ;
        Order ord ;
        List<Order> ol;
        User u4 = createUserWithProfile(); 
        insert u4;
        System.runAs(u4){
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
            users = new List<User>{u1,u2,u3};
                prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
            ol=new List<Order>{ord};
                insert users;    
            OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
            Map<Id, List<Id>>  GrantLicenseAccessForUsersMap = new Map<Id, List<Id>>();
            for(Sales_License__c lic : [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id]) {
                if(GrantLicenseAccessForUsersMap.containsKey(lic.Id)) {
                    List<Id> usersId = GrantLicenseAccessForUsersMap.get(lic.Id);
                    usersId.add(lic.Id);
                    GrantLicenseAccessForUsersMap.put(lic.Id,usersId);
                } else {
                    GrantLicenseAccessForUsersMap.put(lic.Id, new List<Id> { lic.Id });
                }
            }
            Sales_LicenseTriggerUtility.manualShareEditAccessOnLicenses(GrantLicenseAccessForUsersMap);
            Sales_LicenseTriggerUtility.revokeSharedEditAccessOnLicenses(GrantLicenseAccessForUsersMap);
            Sales_LicenseTriggerUtility.automateRenewals(ol);
        }
        try{
            Test.startTest();  
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }   
    @isTest 
    public static void shareRecordTest1(){
        String errMsg='';
        Account partnerAccount ;
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        User u1 ;
        User u2 ;
        User u3 ;
        List<User> users ;
        Product2 prod1 ;
        Pricebookentry pbEntry;
        Order ord ;
        List<Order> ol;
        User u4 = createUserWithProfile(); 
        insert u4;
        System.runAs(u4){
            TriggerHandler.bypass('Core_AccountHandler');
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
            users = new List<User>{u1,u2,u3};
                prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            insert users;
            TriggerHandler.bypass('Sales_OrderTriggerHandler');   
            Test.startTest();
            ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');
            ol=new List<Order>{ord};
                Test.stopTest();
            TriggerHandler.bypass('Sales_LicenseTriggerHandler');
            Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);      
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
            TriggerHandler.bypass('Sales_OrderTriggerHandler'); 
            TriggerHandler.bypass('Sales_OrderProductTriggerHandler'); 
            OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
            Map<Id, List<Id>>  GrantLicenseAccessForUsersMap = new Map<Id, List<Id>>();
            for(Sales_License__c lic : [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id]) {
                if(GrantLicenseAccessForUsersMap.containsKey(lic.Id)) {
                    List<Id> usersId = GrantLicenseAccessForUsersMap.get(lic.Id);
                    usersId.add(lic.Id);
                    GrantLicenseAccessForUsersMap.put(lic.Id,usersId);
                } else {
                    GrantLicenseAccessForUsersMap.put(lic.Id, new List<Id> { lic.Id });
                }
            }
            Sales_LicenseTriggerUtility.manualShareEditAccessOnLicenses(GrantLicenseAccessForUsersMap);
            Sales_LicenseTriggerUtility.revokeSharedEditAccessOnLicenses(GrantLicenseAccessForUsersMap);
            Sales_LicenseTriggerUtility.automateRenewals(ol);
        }
        try{
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }   
    @isTest 
    public static void shareRecordTest2(){
        String errMsg='';
        Account partnerAccount ;
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        Contact partnerContact4;
        User u1 ;
        User u2 ;
        User u3 ;
        List<User> users ;
        Product2 prod1;
        Pricebookentry pbEntry ;
        Order ord ;
        User u4 = createUserWithProfile(); 
        insert u4;
        System.runAs(u4){
            TriggerHandler.bypass('Core_AccountHandler');
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            partnerContact4 = createContactWithDetails(partnerAccount.Id, 'partne4','addhos4','shivamx.vishwakarma35@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
            users = new List<User>{u1,u2,u3};
                prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            insert users;
            TriggerHandler.bypass('Sales_OrderTriggerHandler');
            Test.startTest();
            ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');         
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact2.Id); 
            Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact.Id); 
            Test.stopTest();
            TriggerHandler.bypass('Sales_OrderTriggerHandler');
            OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
            Sales_License__c lic = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c,Sales_License_Lic_User_Contact_ID__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
            lic.Sales_License_Lic_User_Contact_ID__c =partnerContact4.id;
            lic.Sales_License_Web_Display_Flag__c=true;
            update lic;
        }
        try{
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    } 
    public static void revokeShareRecordTest1(){
        String errMsg='';
        Account partnerAccount;
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        User u1 ;
        User u2 ;
        User u3 ;
        List<User> users ;
        Product2 prod1 ;
        Pricebookentry pbEntry ;
        Order ord ;
        User u4 = createUserWithProfile(); 
        insert u4;
        System.runAs(u4){
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
            users = new List<User>{u1,u2,u3};
                insert users;  
            prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order'); 
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact2.Id);             
        }
        try{
            Test.startTest();    
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
            lic.Sales_License_Product__c = prod1.Id;
            insert lic;
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_Lic_User_Contact_ID__c = partnerContact3.Id;
            lic.Sales_License_Web_Display_Flag__c =false;
            update lic;
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    } 
    @isTest 
    public static void revokeAndShareRecordTest(){
        String errMsg='';
        Account partnerAccount ;
        Contact partnerContact;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        User u1 ;
        User u2;
        User u3;
        List<User> users;
        User spuser = createUserWithProfile(); 
        insert spuser;
        System.runAs(spuser){
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
            users = new List<User>{u1,u2,u3};
                Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            Pricebookentry pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            Test.startTest();
            Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');
            Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact2.Id);
            Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact.Id);
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
            Test.stopTest();
            insert users;
            Sales_License__c lic = new Sales_License__c();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
            lic.Sales_License_Lic_User_Contact_ID__c = partnerContact2.Id;
            lic.Sales_License_Product__c = prod1.Id;
            lic.Sales_License_Web_Display_Flag__c =true;
            insert lic;
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic.Sales_License_Lic_User_Contact_ID__c = partnerContact3.Id;
            lic.Sales_License_Web_Display_Flag__c =true;
            update lic;
            Sales_License__c lic1 = new Sales_License__c();
            lic1.Sales_License_Order__c = ord.Id;
            lic1.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
            lic1.Sales_License_Lic_User_Contact_ID__c = partnerContact2.Id;
            lic1.Sales_License_Product__c = prod1.Id;
            insert lic1;
            lic1.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
            lic1.Sales_License_Lic_User_Contact_ID__c = partnerContact3.Id;
            lic1.Sales_License_Web_Display_Flag__c =false;
            update lic;
        }
        try{
        }catch(Exception e){
            errMsg=e.getMessage();
        }
        System.assert(errMsg=='', errMsg);
    }    
    @isTest 
    public static void LicenseMiscMethodsTest(){
        String errMsg='';
        try{
            Test.startTest();  
            Date returnValue = Sales_LicenseTriggerUtility.getLastDateOfMonth( Date.today() );            
            String activationCode = Sales_LicenseTriggerUtility.mdFiveHashAsLicenseActivationCode();
            Test.stopTest();
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest
    public static void cancelLicenseTest(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');        
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        List<Contract> contList = Sales_TestFactory_Utility.createContract(partnerAccount.id);
        Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');  
        try{
            Test.startTest();            
            OrderItem ordItm1 = createOrderProductWithContractandContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id,contList[0].Id); 
            Sales_License__c lic = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
            Sales_License_Order_Product__c licProd = new  Sales_License_Order_Product__c();
            licProd.Sales_License__c = lic.id;
            licProd.Sales_License_ContractId__c = contList[0].Id;
            insert licProd;	
            Sales_LicenseTriggerUtility.cancelLicense(ord.Id);
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest 
    public static void updateExpiryDatesonLicenseTest(){
        String errMsg='';
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
            OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
            Sales_License__c lic = [Select Id, Sales_License_Order_Product__c, Sales_License_Start_Date_Dt__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id]; 
            lic.Sales_License_Start_Date_Dt__c = Date.Today().AddDays(10);  
            update lic;
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }    
    @isTest static void updateAvailableRehostWebdisplayflagTest(){
        String errMsg='';                
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Web_Displayable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);           
        insert prodExt1 ; 
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        try{
            Test.startTest();                          
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Product__c' => prod1.Id , 
                'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });       
            insert lic;
            lic.Sales_License_Start_Date_Dt__c=date.today();
            lic.Sales_License_Type__c ='Evaluation';
            Sales_License__c returnValue = Sales_LicenseTriggerUtility.updateAvailableRehostWebdisplayflag(lic);
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest static void validateHostonLicenseTest(){
        String errMsg='';
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Web_Displayable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);           
        insert prodExt1 ; 
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con3 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con2.Id , 'Sales_License_DlgAdmin_Contact__c' => con1.Id
                    }); 
        Sales_License_Admin_Delegate__c licAdmDlg1 = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
            'Sales_License_PrimaryAdmin_Contact__c' => con2.Id , 'Sales_License_DlgAdmin_Contact__c' => con3.Id
                }); 
        insert licAdmDlg;
        insert licAdmDlg1;
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_License_Type__c'=>'FIXED','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con1.Id,'Sales_License_Type__c'=>'FIXED','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        TriggerHandler.bypass('Sales_HostTriggerHandler');
        insert new List<Sales_Host__c>{hostRec1,hostRec2};
            Test.startTest(); 
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);   
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c' => hostRec1.Id,
            'Sales_License_Primary_Admin_Contact__c'=>con2.Id,'Sales_License_Order__c'=>o.id ,'Sales_License_Order_Product__c' =>oi.id
            });
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        insert lic1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        try{
            Map<Id, Sales_License__c> oldLicMap = new Map<Id, Sales_License__c>{lic1.Id=>lic1};
                lic1.Sales_License_Host_Node_Id__c = hostRec2.Id;
            lic1.Sales_License_Status__c = 'Licensed';
            TriggerHandler.bypass('Sales_LicenseTriggerHandler');
            update lic1;
            TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
            Sales_LicenseTriggerUtility.validateHostonLicense(new List<Sales_License__c>{lic1}, oldLicMap);
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        licAdmDlg1.Sales_License_isActive__c = TRUE;
        insert licAdmDlg1;
        return licAdmDlg1;
    }
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@intel.com';   
        User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
        }
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
            UserRole userRole = [SELECT Id from UserRole where PortalType = 'Partner' Limit 1] ;       
            userTest = new User(Alias=userAlias, Email=emailId, ContactId=partnerContactId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }else{
            userTest = new User(Alias=userAlias, Email=emailId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }
        return userTest;
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
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
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
    public static OrderItem createOrderProductWithContractandContact(Id ordId, Id prodId, Id pbEntryId, Id ContactId, Id ContractId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.SBQQ__Status__c='Draft';
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = ContactId;
        i.SBQQ__Contract__c = ContractId;
        insert i;
        return i;
    } 
    @isTest 
    public static void testAutomateRenewal(){
        TriggerHandler.bypass('Core_AccountHandler');
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivam12345.vishwakarma@intel.com');                
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');         
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact2.Id, partnerContact.Id);
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order ord = Sales_TestFactory_Utility.createNonCommOrder(); 
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        createSalesLicense(partnerAccount.id, ord.id, ordItm1.id, prod1.id ,null);
        Sales_License__c lic = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
        lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
        update lic;
        Order ord2 = ord.clone(false, true, false, false); 
        insert ord2;
        TriggerHandler.clearAllBypasses();
        Test.startTest();
        TriggerHandler.bypass('Core_AccountHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        OrderItem ordItm2 = createOrderProductWithContact(ord2.Id, prod1.id, pbEntry.id, partnerContact.Id); 
        createSalesLicense(partnerAccount.id, ord2.id, ordItm2.id, prod1.id ,null);
        Sales_License__c lic2 = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm2.Id];
        lic2.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
        lic2.Sales_License_Status__c = 'Unlicensed';
        update lic2;
        List<Order> ordList = [Select id, Type,Status, Sales_status__c, Sales_Order_Sub_Type__c from Order where id = :ord2.id];
        ordList[0].Sales_Order_Sub_Type__c = 'Partner license order';        
        ordList[0].Status = 'Activated';
        ordList[0].Sales_status__c = 'Order created successfully';
        Sales_LicenseTriggerUtility.automateRenewals(ordList);   
        TriggerHandler.clearAllBypasses();
        Test.stopTest();
    }
    @isTest 
    public static void testAutomateRenewal2(){
        TriggerHandler.bypass('Core_AccountHandler');
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivam12345.vishwakarma@intel.com');                
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order ord = Sales_TestFactory_Utility.createNonCommOrder(); 
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id); 
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        createSalesLicense(partnerAccount.id, ord.id, ordItm1.id, prod1.id ,null);
        Sales_License__c lic = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
        lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
        update lic;
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.Core_SW_Lic_Type_Nm__c ='FLOAT';
        prodExt2.Core_Prod_Tool_Type_Nm__c = 'RENEWAL';
        prodExt2.Core_SW_Prod_Expiration_Duration_Nbr__c = 365;
        prodExt2.Core_SW_Lic_Renewal_Period_Nbr__c =45;
        prodExt2.Core_Foundation_Product_Id__c =prod1.Id;
        insert prodExt2;
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.Core_Product_Ext_Attribute_Id__c =prodExt2.Id;
        insert prod2;
        Order ord2 = ord.clone(false, true, false, false); 
        insert ord2;
        TriggerHandler.clearAllBypasses();
        Test.startTest();
        TriggerHandler.bypass('Core_AccountHandler');
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        OrderItem ordItm2 = createOrderProductWithContact(ord2.Id, prod2.id, pbEntry.id, partnerContact.Id); 
        createSalesLicense(partnerAccount.id, ord2.id, ordItm2.id, prod2.id ,null);
        Sales_License__c lic2 = [Select Id, Sales_License_Order_Product__c, Sales_License_Primary_Admin_Contact__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm2.Id];
        lic2.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
        lic2.Sales_License_Status__c = 'Unlicensed';
        lic2.Sales_License_Quantity__c= 15;
        update lic2;
        List<Order> ordList = [Select id, Type,Status, Sales_status__c, Sales_Order_Sub_Type__c from Order where id = :ord2.id];
        ordList[0].Sales_Order_Sub_Type__c = 'Partner license order';        
        ordList[0].Status = 'Activated';
        ordList[0].Sales_status__c = 'Order created successfully';
        Sales_LicenseTriggerUtility.automateRenewals(ordList);   
        TriggerHandler.clearAllBypasses();
        Test.stopTest();
    }
    Public static List<Sales_License__c> createSalesLicense(Id accId, Id orderId, Id ordProdId, Id prodId ,Id ContractId){
        List<Sales_License__c> liclist = new List<Sales_License__c>();
        Sales_License__c licobj = new Sales_License__c();
        licobj.Sales_License_Account__c = accId;
        licobj.Sales_License_Order__c = orderId;
        licobj.Sales_License_Order_Product__c=ordProdId;
        licobj.Sales_License_Contract__c = ContractId;
        licobj.Sales_License_Start_Date_Dt__c = System.Today();
        licobj.Sales_License_Status__c = 'Licensed';
        licobj.Sales_License_Product__c = prodId;
        licobj.Sales_License_Type__c = 'Original';
        licObj.Sales_License_Maintenance_Exp_Dt__c = Date.today().addDays(1);
        licObj.Sales_License_Expiration_Date_Dt__c = Date.today().addDays(1);
        licObj.Sales_License_Quantity__c = 10;
        licObj.Sales_License_Avbl_Qty_Nbr__c = 10;
        liclist.add(licobj);
        insert liclist;
        return liclist;
    }
    public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
        return user;
    }
    @isTest
    public static void hostReassginment_Bot(){   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Map<String,String> hostFieldValues = new Map<String,String>();  
        hostFieldValues.put('Sales_Computer_Name_Txt__c', 'youthost');
        hostFieldValues.put('Name', '758826360123');
        hostFieldValues.put('Sales_Host_Is_Created_From_Custom_Page__c','true');
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(hostFieldValues);
        TriggerHandler.bypass('Sales_HostTriggerHandler');
        insert hostObj;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostObj.Id ,    'Sales_License_Product__c' => prod1.Id ,
                'Sales_License_Account__c' => acc.Id , 'Sales_License_Primary_Admin_Contact__c' => con.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        insert lic;
        Sales_Host__c h = Sales_TestDataFactory.createComputerRecord();
        insert h;
        Sales_HostReassignment_Bot.HostInput Input = new Sales_HostReassignment_Bot.HostInput();
        Input.hostObject = h;
        Input.activationCode = lic.Id;
        System.Test.startTest();
        Sales_HostReassignment_Bot.hostReassigment(new List<Sales_HostReassignment_Bot.HostInput>{Input});
        System.Test.stopTest();
    }*/
}