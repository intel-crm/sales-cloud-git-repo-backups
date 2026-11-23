@isTest
public class PSG_QuoteCloneController_Test {
    //Method to setup test data
    /*@testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();
        List<User> lstUsers2 = PSG_Test_Utility.createSOSUser();
        System.runAs(lstUsers2[0]){            
            Account acc = PSG_Test_Utility.createAccount();
            Contact con = PSG_Test_Utility.createContact(acc.Id);
            Opportunity oppty = PSG_Test_Utility.createOpportunity(acc.Id);
            Pricebook2 pb = PSG_Test_Utility.createPriceBook('TestPB');
            PSG_Test_Utility.createDistiMargin(pb.Id, 1);
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, con.Id, 1);
           
           
            List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 2);
            List<Product2> prods=new List<Product2>();
            Product2 prod = new Product2(Name='TestProduct1',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                         Core_OPN__c = 'TESTOPN1',
                                         Core_Item_Class_Nm__c='IC',
                                         IsActive = true);
            prods.add(prod) ;
            Product2 prod1 = new Product2(Name='TestProduct2',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                          Core_OPN__c = 'TESTOPN2',
                                          Core_Item_Class_Nm__c='IC',
                                         IsActive = true);
            prods.add(prod1) ;
            Test.startTest();
            insert prods;
            for(Product2 prod2 : prods){
                prod2.Core_Item_Quotable_Ind__c=true;
                prod2.Core_Item_Orderable_Ind__c=true;
                prod2.isActive=true;
            }
            update prods;
            lstquoteLines[0].core_cpq_product_nm__c=prod.id;
            lstquoteLines[0].core_cpq_product_nm__c=prod.id;
            lstquoteLines[1].SBQQ__Product__c=prod1.id;
            lstquoteLines[1].SBQQ__Product__c=prod1.id;
            update lstquoteLines;
            prod1.IsActive=false;
            update prod1;
            Test.stopTest();
        }
    }
    //Method to test PSG_QuoteCloneController class---for cloning
    @isTest
    public static void testQuoteCloneController()
    {
        
       List<User> lstUsers2 = PSG_Test_Utility.createSOSUser();
        System.runAs(lstUsers2[0]){
                SBQQ.TriggerControl.disable();
                Test.StartTest();
                List<SBQQ__Quote__c> lstquote = [select id from SBQQ__Quote__c ];
                List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
                List<Opportunity> opp=[SELECT Id from Opportunity];
                
                
                SBQQ__Quote__c quote = PSG_QuoteCloneController.initiateQuote();
                SBQQ__Quote__c quote1 = PSG_QuoteCloneController.initiateQuote();
                quote.Id = lstquote[0].id;               
                quote.SBQQ__Status__c = 'Approved';
                quote.core_cpq_quote_type_nm__c = 'Budgetary';
                quoteList.add(quote);
                update quoteList;               
                // Test Notes & Attachments
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                Insert cv;
                
                //Get Content Documents
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                //Create ContentDocumentLink 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = quote.Id;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                Insert cdl;
                PSG_QuoteCloneController.GlobalVariables globalVar = new PSG_QuoteCloneController.GlobalVariables();
                globalVar = PSG_QuoteCloneController.doClone(quote.id, 'Clone','Budgetary');
                System.assertEquals(true,globalVar.isSuccess);
            
            try{
                globalVar = PSG_QuoteCloneController.doClone(null, 'Clone','Tools');
            }catch(Exception e){}
                
                PSG_QuoteCloneController.validateOPNForDesignWin(opp[0].Id,lstquote[0].id);
                 
            }
        Test.StopTest();            
    }
     //Method to test PSG_QuoteCloneController class---for revision
    @isTest
    public static void testQuoterevision(){
        List<User> lstUsers2 = PSG_Test_Utility.createSOSUser();
        System.runAs(lstUsers2[0]){
            SBQQ.TriggerControl.disable();
            List<SBQQ__Quote__c> lstquote = [select id from SBQQ__Quote__c ];
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            Test.StartTest();
            SBQQ__Quote__c quote = PSG_QuoteCloneController.initiateQuote();
            quote.Id = lstquote[0].id;
            quote.SBQQ__Status__c = 'Approved';
            quote.core_cpq_quote_type_nm__c = 'Budgetary';
            quoteList.add(quote);
            update quoteList;
            PSG_QuoteCloneController.GlobalVariables globalVar = new PSG_QuoteCloneController.GlobalVariables();
            globalVar = PSG_QuoteCloneController.doClone(quote.id, 'revision','Budgetary');
            System.assertEquals(true,globalVar.isSuccess);
            quote.core_cpq_quote_type_nm__c='Tools';
            update quote;
            globalVar = PSG_QuoteCloneController.doClone(quote.id, 'revision','Budgetary');
            System.assertEquals(false,globalVar.isSuccess);
            quote.core_cpq_quote_type_nm__c='Design Win';
            quote.core_cpq_active_cb__c=false;
            update quote;
            globalVar = PSG_QuoteCloneController.doClone(quote.id, 'revision','Budgetary');
            Test.stopTest();
        }
        
    }
    @istest
    public static void testCPQuotes(){
        List<User> lstUsers2 = PSG_Test_Utility.createBOUser();
        System.runAs(lstUsers2[0]){
            SBQQ.TriggerControl.disable();
            Test.startTest();
            Account acc = PSG_Test_Utility.createDirectAccount();
            Account acc1= PSG_Test_Utility.createAccount();
            acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
            acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
            update acc1;
            Contact con = [Select id,FirstName,LastName,Email FROM Contact];
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createCPQuotes(acc1.Id, con.Id, 1);
            PSG_QuoteCloneController.GlobalVariables globalVar = new PSG_QuoteCloneController.GlobalVariables();
            globalVar = PSG_QuoteCloneController.doClone(lstquote[0].id, 'revision','Contract Pricing');
            System.assertEquals(true,globalVar.isSuccess);
            try{
                PSG_LookupController.lookUp('Q-', 'SBQQ__Quote__c', '', '', 'Name');
            }catch(Exception e){}
            try{
                PSG_LookupController.lookUp(con.FirstName, 'Contact', '', con.Id, '');
            }catch(Exception e){}
            Test.stopTest();
        }
        
        
    }*/
}