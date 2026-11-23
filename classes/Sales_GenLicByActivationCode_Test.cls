@isTest
public class Sales_GenLicByActivationCode_Test {
    /*public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{});
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        return licAdmDlg1;
    }
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        acc.Core_PSG_Account__c=true;   
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Type = Acctype;
        return acc;
    }
    public static Account createDirectAccount(Id parentId){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        acc.Core_PSG_Account__c=true;   
        acc.Core_Account_Type__c = 'Independent Software Vendor (ISV)';
        acc.Core_Direct_Account_Type_Nm__c = 'End Customer';
        acc.Type = 'Partner';
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
        OrderItem i = Sales_TestDataFactory.createOrderItem();
        i.OrderId = ordId;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = ContactId;
        return i;
    } 
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@testorg.com';   
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
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
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        h.name=compName;
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        insert h;
        return h;
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
    public static void validateSuccessScenerio(){            
        String errMsg='';
        User u4 = createUserWithProfile();
        insert u4;
        Contact partnerContact;
        Contact partnerContact2;
        Contact partnerContact3;
        Account partnerAccount;
        List<Contact> contactToInsert = new List<Contact>();
        system.runAs(u4){ 
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            insert partnerAccount;
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            contactToInsert.add(partnerContact);
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            contactToInsert.add(partnerContact2);
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            contactToInsert.add(partnerContact3);
        }
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
        List<User> users = new List<User>{u1,u2,u3};
            insert users;
        system.runAs(u4){ 
            Core_Product_Ext_Attribute__c extAttr = Sales_TestDataFactory.createProductExternalAttributes();
            extAttr.Core_SW_Lic_Type_Nm__c = 'Float';
            insert extAttr;
            Product2 prod1 = Sales_TestDataFactory.createProduct();
            prod1.Core_Product_Ext_Attribute_Id__c = extAttr.Id;
            insert prod1;
            Pricebookentry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            List<Account> accListToInsert = new List<Account>();
            Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
            accListToInsert.add(parentShipToAccount);
            Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
            accListToInsert.add(parentSoldToAccount);
            Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
            parentEndCustomerAccount.Core_Sub_Industry__c = null;
            accListToInsert.add(parentEndCustomerAccount);
            insert accListToInsert;
            accListToInsert = new List<Account>();
            Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
            shipToAccount.ParentId = parentShipToAccount.Id;
            accListToInsert.add(shipToAccount);
            Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
            soldToAccount.ParentId = parentSoldToAccount.Id;
            accListToInsert.add(soldToAccount);
            Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
            endCustomer.ParentId = parentEndCustomerAccount.Id;
            accListToInsert.add(endCustomer);
            insert accListToInsert;
            Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
                'Core_Sold_To_Account__c'   =>  soldToAccount.Id,
                    'Core_Ship_To_Account__c'   =>  shipToAccount.Id
                    });
            insert relation_Ship_Sold;
            Order ord = Sales_TestDataFactory.createOrder();
            ord.Type = 'Sample Order';
            ord.AccountId = parentSoldToAccount.Id;
            ord.Sales_End_Customer_Account__c = endCustomer.Id;
            ord.Pricebook2Id = Test.getStandardPricebookId();
            ord.Sales_Sold_To_Account__c = soldToAccount.Id;
            ord.Sales_Ship_To_Account__c = shipToAccount.Id;
            insert ord;
            Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact2.Id);
            try{
                Test.startTest(); 
                Account directECAccount = createDirectAccount(partnerAccount.Id);
                insert directECAccount;
                Sales_License_Control__c salesLicenseControl =  Sales_TestDataFactory.createSalesLicenseControl();
                salesLicenseControl.Sales_Account_Competitor__c = directECAccount.Id;
                salesLicenseControl.Sales_Product__c = prod1.Id;
                insert salesLicenseControl;
                Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
                lic.Sales_License_Order__c = ord.Id;
                lic.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
                lic.Sales_License_Product__c = prod1.Id;
                insert lic;
                lic = [Select Sales_License_Primary_Admin_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product__c from Sales_License__c LIMIT 1];
                Sales_GenLicByActivationCondeController.validateLicenses(lic);
                Test.stopTest();            
            }catch(Exception e){
                errMsg=e.getMessage();
            } 
        }
    } 
    @isTest 
    public static void validateNegativeScenerio(){            
        String errMsg='';
        Core_Product_Ext_Attribute__c extAttr = Sales_TestDataFactory.createProductExternalAttributes();
        extAttr.Core_SW_Lic_Type_Nm__c = 'Float';
        insert extAttr;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c = extAttr.Id;
        insert prod1;
        Pricebookentry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        insert accListToInsert;
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'   =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'   =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        Order ord = Sales_TestDataFactory.createOrder();
        ord.Type = 'Sample Order';
        ord.AccountId = parentSoldToAccount.Id;
        ord.Sales_End_Customer_Account__c = endCustomer.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.Sales_Sold_To_Account__c = soldToAccount.Id;
        ord.Sales_Ship_To_Account__c = shipToAccount.Id;
        insert ord;
        try{
            Test.startTest();                          
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Primary_Admin_Contact__c = null;
            lic.Sales_License_Product__c = prod1.Id;
            insert lic;
            lic = [Select Sales_License_Primary_Admin_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product__c from Sales_License__c LIMIT 1];
            Sales_GenLicByActivationCondeController.validateLicenses(lic);
            Test.stopTest();            
        }catch(Exception e){
        } 
    } 
    @isTest 
    public static void validateNegativeScenerio2(){            
        String errMsg='';
        Core_Product_Ext_Attribute__c extAttr = Sales_TestDataFactory.createProductExternalAttributes();
        extAttr.Core_SW_Lic_Type_Nm__c = 'Float';
        insert extAttr;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c = extAttr.Id;
        insert prod1;
        Pricebookentry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        insert accListToInsert;
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'   =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'   =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        Order ord = Sales_TestDataFactory.createOrder();
        ord.Type = 'Sample Order';
        ord.Sales_Order_Reason__c = 'Stocking Order';
        ord.AccountId = parentSoldToAccount.Id;
        ord.Sales_End_Customer_Account__c = endCustomer.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.Sales_Sold_To_Account__c = soldToAccount.Id;
        ord.Sales_Ship_To_Account__c = shipToAccount.Id;
        insert ord;
        List<Contact> contactToInsert = new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        insert partnerAccount;
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        contactToInsert.add(partnerContact2);
        try{
            Test.startTest();                          
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Status__c = 'Unlicensed';
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact2.Id;
            lic.Sales_License_Product__c = prod1.Id;
            insert lic;
            lic = [Select Sales_License_Primary_Admin_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product__c from Sales_License__c LIMIT 1];
            Sales_GenLicByActivationCondeController.validateLicenses(lic);
            Test.stopTest();            
        }catch(Exception e){
        } 
    }
    @isTest 
    public static void validateNegativeScenerio3(){            
        String errMsg='';
        Core_Product_Ext_Attribute__c extAttr = Sales_TestDataFactory.createProductExternalAttributes();
        extAttr.Core_SW_Lic_Type_Nm__c = 'Float';
        insert extAttr;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c = extAttr.Id;
        insert prod1;
        Pricebookentry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        insert accListToInsert;
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'   =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'   =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        Order ord = Sales_TestDataFactory.createOrder();
        ord.Type = 'Sample Order';
        ord.Sales_Order_Reason__c = 'Stocking Order';
        ord.AccountId = parentSoldToAccount.Id;
        ord.Sales_End_Customer_Account__c = endCustomer.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.Sales_Sold_To_Account__c = soldToAccount.Id;
        ord.Sales_Ship_To_Account__c = shipToAccount.Id;
        insert ord;
        List<Contact> contactToInsert = new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        insert partnerAccount;
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        contactToInsert.add(partnerContact2);
        try{
            Test.startTest();                          
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Status__c = 'Unlicensed';
            lic.Sales_License_Primary_Admin_Contact__c = partnerContact2.Id;
            lic.Sales_License_Product__c = prod1.Id;
            insert lic;
            lic = [Select id, Sales_License_Primary_Admin_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product__c from Sales_License__c LIMIT 1];
            Sales_GenLicByActivationCondeController.updateLiceseRecord(lic.id, contactToInsert[0].Id);
            Test.stopTest();            
        }catch(Exception e){
        } 
    }
    @isTest 
    public static void validateNegativeScenerio5(){            
        String errMsg='';
        Core_Product_Ext_Attribute__c extAttr = Sales_TestDataFactory.createProductExternalAttributes();
        extAttr.Core_SW_Lic_Type_Nm__c = 'Float';
        insert extAttr;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c = extAttr.Id;
        insert prod1;
        Pricebookentry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        insert accListToInsert;
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'   =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'   =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        Order ord = Sales_TestDataFactory.createOrder();
        ord.Type = 'Sample Order';
        ord.AccountId = parentSoldToAccount.Id;
        ord.Sales_End_Customer_Account__c = endCustomer.Id;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.Sales_Sold_To_Account__c = soldToAccount.Id;
        ord.Sales_Ship_To_Account__c = shipToAccount.Id;
        ord.Sales_Order_Reason__c='Stocking Order';
        insert ord;
        try{
            Test.startTest();                          
            Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
            lic.Sales_License_Order__c = ord.Id;
            lic.Sales_License_Primary_Admin_Contact__c = null;
            lic.Sales_License_Product__c = prod1.Id;
            lic.Sales_License_Status__c='Unlicensed';
            insert lic;
            lic = [Select Sales_License_Primary_Admin_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product__c from Sales_License__c LIMIT 1];
            Sales_GenLicByActivationCondeController.validateLicenses(lic);
            Test.stopTest();            
        }catch(Exception e){
        }
    } 
    @isTest
    static void validateNegativeScenerio6(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.id);
        Sales_Host__c host= Sales_LicenseGenIntegration_Utility_Test.createHostRecord('111122223344','FIXED','NIC ID',con.Id,'','','');
        List<Sales_License_Generator__c> licenseGen = new List<Sales_License_Generator__c>();
        Sales_License_Generator__c lGen = new  Sales_License_Generator__c();
        lGen.Name='Gen1';
        lGen.Sales_License_Vendor__c='Mentor Graphics';
        lGen.Sales_License_Generator_txt__c='genlic';
        lGen.Sales_License_Feature_Lyn_Syntx_txt__c='Gen';
        licenseGen.add(lGen);
        insert licenseGen;
        Sales_License_Group__c lgp = new Sales_License_Group__c();
        lgp.Name = 'lgp1';
        lgp.Sales_License_Generator__c = licenseGen[0].id ;
        insert lgp;                     
        Product2 p = new Product2();
        p.Name = ' Test Corporate Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionTerm__c=10;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        insert p; 
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = 'BASE';
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Employee';
        l1.Core_Foundation_Product_Id__c=p.id;
        l1.Core_Product_Id__c=p.id;
        insert l1;   
        Sales_License__c lic=new Sales_License__c();
        lic.Sales_License_Quantity__c=1;
        lic.Sales_License_Product_Name_Txt__c='Test';
        lic.Sales_License_Maintenance_Exp_Dt__c=system.today();
        lic.Sales_License_Expiration_Date_Dt__c=system.today()+1;
        lic.Sales_License_Start_Date_Dt__c=system.today();
        lic.Sales_License_Status__c='Licensed';
        lic.Sales_License_Avbl_Qty_Nbr__c=1;
        lic.Sales_License_Avbl_Rehost_Nbr__c=1;
        lic.Opt_in_out__c=true;
        lic.Sales_License_Web_Display_Flag__c=false;
        lic.Sales_License_Type__c='Optional';
        lic.Sales_License_Product__c=p.id;
        lic.Sales_License_Host_Node_Id__c=host.id;
        lic.Sales_License_Activation_Code__c ='123456789';
        insert lic;
        Sales_License_Control__c licConrol= new Sales_License_Control__c();
        licConrol.Sales_Account_Competitor__c=accObj.id;
        licConrol.Sales_InActive_Ind__c =true;
        licConrol.Sales_Product__c=p.id;
        insert licConrol;
        set<id> accid=new set<id>();
        accid.add(accObj.id);
        string activationCode=lic.Sales_License_Activation_Code__c;
        test.startTest();
        Sales_GenLicByActivationCondeController.fetchLicenseDetails(activationCode);
        Sales_GenLicByActivationCondeController.validateMentorGraphics(p.id,accid,accObj.id);
        test.stopTest();
    }*/
}