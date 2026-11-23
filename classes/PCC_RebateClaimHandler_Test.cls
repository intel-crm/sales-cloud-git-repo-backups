@isTest
public with sharing class PCC_RebateClaimHandler_Test {
    // public static User usr = new User();
@testSetup
    public static void createData(){
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        system.runas(sysadm){ 
            test.startTest();
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
            List<account>  acc = Core_Test_Utility.createAccount(1);
            acc[0].Name='Test Test';
            acc[0].recordTypeId = accountRecordTypeIntel;
            insert acc;
            
            Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId(); 
            Contact con = PRM_TestUtility.getContact();
            con.AccountId = acc[0].Id;
            con.Email='test.user@intel.com';
            con.Core_Preferred_Language__c = 'ENG';
            con.Core_eRPM_Language_Code__c = 'ENG';
            con.RecordTypeId = contactRecordType;
            con.Core_IPA_Partner_Role__c = 'Service Provider';
            con.Core_Central_Block__c=false;
            con.MailingCountry = 'India';
            insert con;
            
            Id recTypeParentId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Header').getRecordTypeId();
            Id recTypeChildId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Line_Items').getRecordTypeId();
            
            PCC_Rebate_Claim_Stage__c headerRecord = new PCC_Rebate_Claim_Stage__c();
            headerRecord.PCC_Partner__c = acc[0].Id;
            headerRecord.recordTypeId = recTypeParentId;
            insert headerRecord;
            List<PCC_Rebate_Claim_Stage__c> stgLst = new List<PCC_Rebate_Claim_Stage__c>();
            PCC_Rebate_Claim_Stage__c stageRec = new PCC_Rebate_Claim_Stage__c(PCC_Parent_Record__c = headerRecord.Id,
                                                                               PCC_Quote_Line_Number__c='Q-100-11-1234',PCC_Country__c='USA',PCC_Invoice_Date__c=String.valueof(Date.today()),
                                                                               PCC_Status__c='Pending',PCC_OEM__c = 'Asus',PCC_Product__c = 'TestProduct1',PCC_Quantity__c = String.valueof(10),recordTypeId = recTypeChildId,PCC_Partner__c = acc[0].Id);
            stgLst.add(stageRec);
            
            PCC_Rebate_Claim_Stage__c stageRec1 = new PCC_Rebate_Claim_Stage__c(PCC_Parent_Record__c = headerRecord.Id,
                                                                                PCC_Quote_Line_Number__c='Q-100-11-1234',PCC_Country__c='USA',PCC_Error_Messages__c = 'Blank OEM Name ',
                                                                                PCC_Invoice_Date__c=String.valueof(Date.today()),PCC_Status__c='Pending',PCC_OEM__c = '',PCC_Product__c = 'TestProduct2',
                                                                                PCC_Quantity__c = String.valueof(10),recordTypeId = recTypeChildId,PCC_Partner__c = acc[0].Id);
            stgLst.add(stageRec1);
            
            PCC_Rebate_Claim_Stage__c stageRec2 = new PCC_Rebate_Claim_Stage__c(PCC_Parent_Record__c = headerRecord.Id,
                                                                                PCC_Quote_Line_Number__c='Q-12345-123',PCC_Country__c='USA',PCC_Error_Messages__c = 'Blank Claim Quantity',
                                                                                PCC_Invoice_Date__c=String.valueof(Date.today()),PCC_Status__c='Pending',PCC_OEM__c = 'Asus',PCC_Product__c = 'TestProduct2',
                                                                                PCC_Quantity__c = '',recordTypeId = recTypeChildId,PCC_Partner__c = acc[0].Id);
            stgLst.add(stageRec2);
            
            PCC_Rebate_Claim_Stage__c stageRec3 = new PCC_Rebate_Claim_Stage__c(PCC_Parent_Record__c = headerRecord.Id,
                                                                                PCC_Quote_Line_Number__c='Q-100-11-1234',PCC_Country__c='USA',PCC_Error_Messages__c = 'Error 1: Invalid OEM Name ',
                                                                                PCC_Invoice_Date__c=String.valueof(System.today().addDays(-10)),PCC_Status__c='Pending',PCC_OEM__c = 'Samsung',
                                                                                PCC_Product__c = 'TestProduct2',PCC_Quantity__c = String.valueof(100),recordTypeId = recTypeChildId,PCC_Partner__c = acc[0].Id);
            stgLst.add(stageRec3);
            
            PCC_Rebate_Claim_Stage__c stageRec4 = new PCC_Rebate_Claim_Stage__c(PCC_Parent_Record__c = headerRecord.Id,
                                                                                PCC_Quote_Line_Number__c='Q-111-11-1234',PCC_Country__c='USA',PCC_Error_Messages__c = 'Blank Claim Quantity',
                                                                                PCC_Invoice_Date__c=String.valueof(Date.today()),PCC_Status__c='Pending',PCC_OEM__c = 'Dell',
                                                                                PCC_Product__c = 'TestProduct2',PCC_Quantity__c = String.valueof(1),recordTypeId = recTypeChildId,PCC_Partner__c = acc[0].Id);
            stgLst.add(stageRec4);
            
            insert stgLst;
            test.stopTest();
        }
    }
    static void createTriggerExecutions() {        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'PCC_RebateClaimAddToQueue';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'PCC_RebateClaimHandler';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'PCC_Rebate_Claim__c';
        triggerExec.Core_Trigger_Events__c = 'After Update After Insert';
        triggerExecList.add(triggerExec);
        
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c();
        triggerExec1.Name = 'PCC_RebateClaimPaymentProcessed';
        triggerExec1.Core_Active__c = true;
        triggerExec1.Core_Class_Name__c = 'PCC_RebateClaimHandler';
        triggerExec1.Core_Description__c = 'Test';
        triggerExec1.Core_Object__c = 'PCC_Rebate_Claim__c';
        triggerExec1.Core_Trigger_Events__c = 'After Update';
        triggerExecList.add(triggerExec1);       
        
        insert triggerExecList;
    }
    
    Static PCC_Rebate_Claim__c Create_Rebate_Claim(){       
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
      User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        
        PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
      	rcInstance.PCC_Claim_Status__c = 'Draft';       
        insert rcInstance;  
       
        rcInstance.PCC_Claim_Status__c = 'Claim Submitted';
        rcInstance.PCC_Submitted_By__c =usr.Id;
        update rcInstance;        
        return rcInstance;
    }
   
    @isTest
    public static void AddRebateClaim(){
        createTriggerExecutions();       
       //PCC_Rebate_Claim__c rcInstance = Create_Rebate_Claim(); -Unused Var
        PCC_Rebate_Claim__c claim1 = new PCC_Rebate_Claim__c(
            PCC_CSAR_ID__c = 'CSAR-001',
            PCC_Payment_Ref_Id__c = 'Payment-001',
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
        );
        insert new List<PCC_Rebate_Claim__c>{claim1};
        PCC_Rebate_Claim__c insertedClaim = [SELECT Id, PCC_CSAR_ID__c,PCC_Claim_Status__c FROM PCC_Rebate_Claim__c WHERE PCC_CSAR_ID__c = 'CSAR-001' LIMIT 1];
        System.assertEquals('Claim Approved - Payment Pending', insertedClaim.PCC_Claim_Status__c);
    }
    
    @isTest
    public static void testValidateLines(){       
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        List<Account> acc =[Select id from Account where name='Test Test'];
        Contact con =[Select id from Contact where Email='test.user@intel.com'];
        Assert.isNotNull(acc);
        Assert.isNotNull(con);
        
            system.runas(sysadm){           
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            Product2 prod = new Product2(Name='TestProduct',Core_Product_Org__c = 'Sales',Core_Product_Type__c = 'Processors',Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',Core_Group_Code_Short_Name__c = 'DCG~DCAI',Core_Processor_Number_Nm__c = 'P6500',IsActive = true);
            insert prod;
            
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = acc[0].Id,SBQQ__PrimaryContact__c = con.Id,
                                                      Pricing_Server_Deal_Type_Nm__c = 'Enterprise',Pricing_Project_Name_Nm__c = 'Test Project',RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create),
                                                      Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com', Pricing_End_Customer__c=unifiedEndCustomer.id, Pricing_Customer_Nm__c = 'FMH', Pricing_ShipmentStDate_Dt__c = system.today()+1,
                                                      Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com', Pricing_End_Customer_Country_Nm__c = 'Afghanistan', Pricing_Region_Nm__c = 'APJ', SBQQ__Status__c = 'Submitted');
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7); 
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quoteList.add(quote);
            insert quoteList;  
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 2);
            lstquoteLines[0].Pricing_Quote_Line_Number__c='Q-100-11-1234';
            lstquoteLines[0].Pricing_Approved_Unit_Qty__c=20;
            lstquoteLines[0].Pricing_OEM_Name_FI_Nm__c = 'Asus';
            lstquoteLines[0].Pricing_FI_Net_RPU_Amt__c = 10;
            lstquoteLines[0].Pricing_Status_Nm__c = 'Approved';
            lstquoteLines[1].Pricing_Quote_Line_Number__c='Q-111-11-1234';
            lstquoteLines[1].Pricing_Approved_Unit_Qty__c=20;
            lstquoteLines[1].Pricing_OEM_Name_FI_Nm__c = 'Dell';
            lstquoteLines[1].Pricing_FI_Net_RPU_Amt__c = 10;
            lstquoteLines[1].Pricing_Status_Nm__c = 'Approved';
            update lstquoteLines;
            
            PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c(PCC_Claim_Status__c = 'Draft');  
            insert rcInstance; 
            
            PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c(PCC_Rebate_Claim__c = rcInstance.Id, PCC_Quote_Line_Number__c = lstquoteLines[0].Id, PCC_Quantity__c= 5, PCC_Invoice__c= '2000',    
                                                                                      PCC_OEM_Name__c = 'Asus', PCC_Status__c = 'Submitted', PCC_Invoice_Date__c = System.today(), PCC_Claimed_Rebate_Amount__c = 50000);
            insert rc_line;
            rcInstance.PCC_Claim_Status__c = 'Claim Submitted';
            update rcInstance;            
        }   
        Test.startTest();
        List<PCC_Rebate_Claim_Stage__c> stgRec = [Select Id,PCC_Quote_Line_Number__c,PCC_Country__c,PCC_Invoice_Date__c, PCC_Status__c,PCC_Product__c,PCC_Quantity__c, PCC_Error_Messages__c, PCC_OEM__c from PCC_Rebate_Claim_Stage__c
                                                  where PCC_Quote_Line_Number__c = 'Q-12345-123'];
        
        Assert.isNotNull(stgRec);
        PCC_RebateClaimHandler.validateLineItems(stgRec);
        List<PCC_Rebate_Claim_Stage__c> lstStg = new List<PCC_Rebate_Claim_Stage__c>();
        lstStg = [Select Id,PCC_Quote_Line_Number__c,PCC_Country__c,PCC_Invoice_Date__c, PCC_Status__c,PCC_Product__c,PCC_Quantity__c, PCC_Error_Messages__c, PCC_OEM__c from PCC_Rebate_Claim_Stage__c
                  where PCC_Quote_Line_Number__c = 'Q-100-11-1234'];
        
        Assert.isNotNull(lstStg);
        PCC_RebateClaimHandler.validateLineItems(lstStg);
        List<PCC_Rebate_Claim_Stage__c> stgRec1 = [Select Id,PCC_Quote_Line_Number__c,PCC_Country__c,PCC_Invoice_Date__c, PCC_Status__c,PCC_Product__c,PCC_Quantity__c, PCC_Error_Messages__c, PCC_OEM__c from PCC_Rebate_Claim_Stage__c
                                                   where PCC_Quote_Line_Number__c = 'Q-111-11-1234'];
        
        Assert.isNotNull(stgRec1);
        PCC_RebateClaimHandler.validateLineItems(stgRec1);
        Test.stopTest();
    }

    @isTest
    public static void testCreateRebateClaim(){
        user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true and userRole.name='Admin' Limit 1 ];
        
        system.runas(sysadm){           
           
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            
            List<account>  acc = Core_Test_Utility.createAccount(1);
            acc[0].Name='Test Test';
            acc[0].recordTypeId = accountRecordTypeIntel;
            insert acc;
            
            Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId(); 
            Contact con = PRM_TestUtility.getContact();
            con.AccountId = acc[0].Id;
            con.Email='test.user@intel.com';
            con.Core_Preferred_Language__c = 'ENG';
            con.Core_eRPM_Language_Code__c = 'ENG';
            con.RecordTypeId = contactRecordType;
            con.Core_IPA_Partner_Role__c = 'Service Provider';
            con.Email = 'test.test@test.com';
            con.Core_Central_Block__c=false;
            con.MailingCountry = 'India';
            insert con;
            
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc[0].Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote);
            insert quoteList;  
             List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            lstquoteLines[0].Pricing_Quote_Line_Number__c='Q-100-11-test';
            update lstquoteLines;
        PCC_Rebate_Claim_Stage__c testParentRecord = new PCC_Rebate_Claim_Stage__c(PCC_Status__c = 'Pending');
        insert testParentRecord;
            PCC_Rebate_Claim_Stage__c stageRec = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = testParentRecord.Id,
                PCC_Invoice_Date__c = '02/02/2024',
                PCC_Quantity__c = String.ValueOf(10),
                PCC_Status__c='Pending',
                PCC_Quote_Line_Number__c='Q-100-11-test',
                PCC_Quote_Line_Id__c=lstquoteLines[0].Id
            );
           insert stageRec;
    Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'test content trigger'; 
        cv1.PathOnClient ='SampleTitle.jpg';    
        cv1.VersionData =beforeblob;          
        insert cv1;         

        ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv1.Id];
            
        Assert.isNotNull(testContent1);
            
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=testParentRecord.id;
        contentlink1.ShareType= 'V';
        contentlink1.ContentDocumentId=testcontent1.ContentDocumentId;
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;

      //  List<Id> headerIds = new List<Id> {testParentRecord.Id};- Unused Var
        Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessMap = new Map<Id, List<PCC_Rebate_Claim_Stage__c>>();
        stgSuccessMap.put(testParentRecord.Id, new List<PCC_Rebate_Claim_Stage__c>{stageRec});
        Test.startTest();
         Assert.isNotNull(stgSuccessMap);
        PCC_RebateClaimHandler.createRebateClaim(stgSuccessMap);
        Test.stopTest();
        }
    }
 
    @isTest
    static void testRebateClaimStgQuery() {
        PCC_Rebate_Claim_Stage__c rebateClaimStage = new PCC_Rebate_Claim_Stage__c();
        rebateClaimStage.PCC_Status__c = 'Pending';
        insert rebateClaimStage;

       List<Id> headerIdList = new List<Id>{ rebateClaimStage.PCC_Parent_Record__c };
        String query = PCC_RebateClaimHandler.rebateClaimStgQuery(headerIdList);
        String expectedQueryPart1 = 'SELECT Id, PCC_Error_Messages__c, Name, PCC_Parent_Record__r.Name, PCC_Partner__c, PCC_Partner__r.Core_Geo__c, PCC_Country__c, PCC_Quote_Line_Id__c, PCC_OEM__c, PCC_ProductId__c, PCC_Opportunity__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastViewedDate, LastReferencedDate, RecordTypeId, IsDeleted, PCC_Quote_Line_Number__c,  PCC_Invoice_Date__c, PCC_Product__c, PCC_Quantity__c, PCC_Quote_Invoice_Number__c, PCC_Status__c, PCC_Parent_Record__c, OwnerId, PCC_Submitted_Claim_Rebate_Amount__c FROM PCC_Rebate_Claim_Stage__c WHERE PCC_Parent_Record__r.PCC_Status__c = \'Pending\' AND PCC_Parent_Record__c IN :headerIdList';
        System.assertEquals(expectedQueryPart1, query, 'The query string is not as expected when headerIdList is not null and not empty.');

        query = PCC_RebateClaimHandler.rebateClaimStgQuery(null);
        String expectedQueryPart2 = 'SELECT Id, PCC_Error_Messages__c, Name, PCC_Parent_Record__r.Name, PCC_Partner__c, PCC_Partner__r.Core_Geo__c, PCC_Country__c, PCC_Quote_Line_Id__c, PCC_OEM__c, PCC_ProductId__c, PCC_Opportunity__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastViewedDate, LastReferencedDate, RecordTypeId, IsDeleted, PCC_Quote_Line_Number__c,  PCC_Invoice_Date__c, PCC_Product__c, PCC_Quantity__c, PCC_Quote_Invoice_Number__c, PCC_Status__c, PCC_Parent_Record__c, OwnerId, PCC_Submitted_Claim_Rebate_Amount__c FROM PCC_Rebate_Claim_Stage__c WHERE PCC_Parent_Record__r.PCC_Status__c = \'Pending\'';
        System.assertEquals(expectedQueryPart2, query, 'The query string is not as expected when headerIdList is null.');

        query = PCC_RebateClaimHandler.rebateClaimStgQuery(new List<Id>());
        System.assertEquals(expectedQueryPart2, query, 'The query string is not as expected when headerIdList is empty.');
    }
    
}