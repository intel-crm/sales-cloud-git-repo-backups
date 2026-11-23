@isTest
private class Core_OppApproveChecklistCont_Test{
public static List<Opportunity> opptyList = new List<Opportunity>();
 testMethod static void InsertOppTest1() {
         Test.startTest();
         System.runAs(Core_Test_Utility.systemAdminUser){          
           Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Core_CIM_ID__c='10102356'; 
            insert accountInstance;
            
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName ='Define';
            opportunityInstance.Name ='Test OppName';
            opportunityInstance.AccountId = accountInstance.Id;
            opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
            opportunityInstance.Core_Production_End_Date__c =System.Today().addDays(-10);
            opportunityInstance.Core_Opportunity_Type__c='Design: Original';
            opportunityInstance.Core_Loss_Cancel_Details__c='Test opp record';
            insert opportunityInstance;
            
       List<Product2> testProducts = Core_Test_Utility.createProduct(1);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opportunityInstance.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c=null,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Vendor__c=null);
        insert testOppLineItem;
                  
          ApexPages.StandardController sc = new ApexPages.StandardController(opportunityInstance);
          Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc);
        
         PageReference pageRef = Page.Core_OppApproveChecklist;
         pageRef.getParameters().put('id', String.valueOf(opportunityInstance.Id));
         Test.setCurrentPage(pageRef);
         testAccPlan.cancel();
         }
        Test.stopTest();

       }
             
   testMethod static void InsertOppTest2() {
   
   Test.startTest();
   System.runAs(Core_Test_Utility.systemAdminUser){          
           Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';        
            insert accountInstance;
            
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Prospecting';
            opportunityInstance.Name ='Test OppName';
            opportunityInstance.Core_Opportunity_Type__c='Design: Original';
            opportunityInstance.Core_Military_Aerospace_Govmt_End_Use__c='Yes';
            opportunityInstance.Core_Compliance_Status__c ='Approved with Guardrails';
            opportunityInstance.Core_Production_End_Date__c=System.Today().addDays(1);
            opportunityInstance.Core_Opportunity_Type__c ='Design: Secondary';
            opportunityInstance.AccountId = accountInstance.Id;           
            insert opportunityInstance;
            
           // List<Core_Opportunity_Features__c> OppFetaures= Core_Test_Utility.CreateOpportunityFeature(1);
           // insert OppFetaures;
           //Note//
           Note n = new note(parentid=opportunityInstance.id,title='test note',body='test note contents');
            insert n;
          // Attachment //
                Attachment attach=new Attachment();      
                attach.Name='Unit Test Attachment';
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
                attach.body=bodyBlob;
                attach.parentId=opportunityInstance.id;
                insert attach;
                    
        List<Product2> testProducts = Core_Test_Utility.createProduct(1);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opportunityInstance.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Vendor__c=accountInstance.Id);
        insert testOppLineItem;
             List<Core_Opportunity_Partner__c> OppPartner= Core_Test_Utility.createOpportunityPartners(1,opportunityInstance);
             
             insert OppPartner;
                     ApexPages.StandardController sc = new ApexPages.StandardController(opportunityInstance);
          Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc);
        
         PageReference pageRef = Page.Core_OppApproveChecklist;
         pageRef.getParameters().put('id', String.valueOf(opportunityInstance.Id));
         Test.setCurrentPage(pageRef);
         testAccPlan.cancel();
         }
         Test.stopTest();

        
       }     
        testMethod static void InsertOppTest3() {
         Test.startTest();
         System.runAs(Core_Test_Utility.systemAdminUser){          
           Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Core_CIM_ID__c='10102356';       
            insert accountInstance;
         
            opptyList.add(new Opportunity(Name = 'Test Opportunity1',
                          AccountId = accountInstance.Id, StageName = 'Qualify',Core_Loss_Cancel_Reason__c='Cancelled - Duplicate', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
             opptyList.add(new Opportunity(Name = 'Test Opportunity2',
                          AccountId = accountInstance.Id, StageName = 'Production Lost',Core_Loss_Cancel_Details__c='Test opp record',Core_Opportunity_Team_Geo_APJ__c=true, Core_Loss_Cancel_Reason__c='Cancelled - Duplicate',CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
         
             opptyList.add(new Opportunity(Name = 'Test Opportunity3',
                          AccountId = accountInstance.Id, StageName = 'Cancelled', Core_Loss_Cancel_Reason__c='Cancelled - Duplicate', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));

             opptyList.add(new Opportunity(Name = 'Test Opportunity4',
                          AccountId = accountInstance.Id, StageName = 'Define',  Core_Loss_Cancel_Reason__c='Cancelled - Duplicate',CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c = 'Mobile', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));

                       insert opptyList;  
            List<Product2> testProducts = Core_Test_Utility.createProduct(1);
            insert testProducts;
          
           //  insert opportunityInstance;
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
            insert testPBEs;

            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[0].Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_BU_Short_Name__c='T11',
                                                  Core_Loss_Cancel_Reason__c='Cancelled - Budget', Core_Status__c='Pending',Core_Vendor__c=accountInstance.Id,Core_Write_In_Product_Flag__c=true);
            insert testOppLineItem;

                             PageReference pageRef = Page.Core_OppApproveChecklist;
            pageRef.getParameters().put('id', String.valueOf(opptyList[0].Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
            Core_OppApproveChecklistCont testAccPlan0 = new Core_OppApproveChecklistCont(sc);
            testAccPlan0.cancel();

                    PageReference pageRef1 = Page.Core_OppApproveChecklist;
            pageRef1.getParameters().put('id', String.valueOf(opptyList[1].Id));
            Test.setCurrentPage(pageRef1);
            ApexPages.StandardController sc1 = new ApexPages.StandardController(opptyList[1]);
            Core_OppApproveChecklistCont testAccPlan1 = new Core_OppApproveChecklistCont(sc1);
            testAccPlan1.cancel();

            PageReference pageRef2 = Page.Core_OppApproveChecklist;
            pageRef2.getParameters().put('id', String.valueOf(opptyList[2].Id));
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController sc2 = new ApexPages.StandardController(opptyList[2]);
            Core_OppApproveChecklistCont testAccPlan2 = new Core_OppApproveChecklistCont(sc2);
            testAccPlan2.cancel();

            PageReference pageRef3 = Page.Core_OppApproveChecklist;
            pageRef3.getParameters().put('id', String.valueOf(opptyList[3].Id));
            Test.setCurrentPage(pageRef3);
            ApexPages.StandardController sc3 = new ApexPages.StandardController(opptyList[3]);
            Core_OppApproveChecklistCont testAccPlan3 = new Core_OppApproveChecklistCont(sc3);
            testAccPlan3.cancel();
            }
     Test.stopTest();    
    }
    
       
 }