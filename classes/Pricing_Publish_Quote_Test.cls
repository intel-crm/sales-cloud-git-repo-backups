/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_Publish_Quote_Test {
    //Setting up Test Data
    @testSetup
    public static void setUpData(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUserWithParam('publishQuoteAdmin');
        //List<User> adminUser2 = Pricing_Test_Utility.createAdminUser2();
        Contact con;
        List<User> accountExecutiveUserList;
        List<User> salesRepUserList;
        System.runAs(adminUser[0]){
            
            Product2 prod = new Product2();
            prod.Core_Product_Org__c = 'Sales';
            prod.Core_Product_Type__c = 'Processors';
            prod.Core_Sales_Visible_Flag__c  = True;
            prod.IsActive = True;
            prod.Core_Hierarchy_ID__c = '43';
            prod.Core_Group_Code_Short_Name__c = 'CCG';
            prod.Name = 'Product X';
            
            Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
                Name = 'Write In Product',
                Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
                Pricing_Active_cb__c = true
            );
            insert prod;
            insert cp;
            
            List<User> fseUserList = Pricing_Test_Utility.createFSEUserWithParam('testnewfseemail@intel.com','testnew','test');
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Publish_Quote_Test');
            Pricing_Test_Utility.createTemplate(adminUser[0].id);
            accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeam = new List<AccountTeamMember>();
            accTeam.add(new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id));
            accTeam.add(new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Technical Sales',UserId = fseUserList[0].Id));
            insert accTeam;
            
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            Pricing_QuoteLineController.getDocumentId(Label.Pricing_Tender_T_C_Document);
        }
        
        User partnerUser = [SELECT Id, FirstName, ContactId  FROM User WHERE Email='partner@noemail.com' LIMIT 1];
        Account acc =  [SELECT Id from Account LIMIT 1];
        System.runAs(partnerUser){
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.startTest();
            
            boolean isPartner = Pricing_QuoteLineController.isPartnerUser();
            //System.assert(isPartner, 'logged in user is not a Partner');
            System.runAs(adminUser[0]){
                List<SBQQ__Quote__c> quotes = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
                List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quotes[0].Id, 1);
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testPublishTenderQuote1(){
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote and recordtypeid=:commentRecordTypeId];
        for(Pricing_Comments__c pc: lstComment){
            if(lstquote[0].id == pc.Pricing_Quote__c){
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            }
            else{
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List<Pricing_Performance_Metric__c> performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);    
        if(!performanceList.isEmpty()){
            insert performanceList;
        }
        Pricing_Publish_Quote.globalVariables glbVariable = new Pricing_Publish_Quote.globalVariables();
        system.runAs(lstUsers[0]){
            Pricing_Publish_Quote.submitForReview(lstquote[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id); 
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_Quote_Comment_Submit_Error_Message);
            //errorMessage.add(Label.Pricing_Tender_Intel_Response_Date_Blank_Error_Submission);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            System.assertEquals(glbVariable.isSuccess,false);
        }
    }
    
    @isTest
    public static void testPublishTenderQuote_success(){
        Test.startTest();
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
        update lstquote[0];
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
        lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
        lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 500;
        lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 450;
        lstquoteLines[0].Pricing_Systems_qty__c = 10;
        lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
        update lstquoteLines[0];
        test.stopTest();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid=:commentRecordTypeId];
        for(Pricing_Comments__c pc: lstComment){
            if(lstquote[0].id == pc.Pricing_Quote__c){
                pc.Pricing_Answer__c = '######testing######';
                pc.Pricing_Required_Ind__c = true;
            }
            else{
                pc.Pricing_Answer__c = '######testing######';
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List<Pricing_Performance_Metric__c> performanceList;
        performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);    
        if(!performanceList.isEmpty()){
            insert performanceList;
        }
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id);
            System.assertEquals(glbVariable.isSuccess,true);
            Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
    }
    
    @isTest
    public static void testPublishTenderQuote_dateCheck(){
        Test.startTest();
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstQLI = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  Limit 1]);
        lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Draft;
        lstquote[0].Pricing_Bid_Dt__c = date.today();
        lstquote[0].Pricing_Intel_Response_Requested_By_Date__c = date.today();
        update lstquote[0];
        test.stopTest();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid=:commentRecordTypeId];
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){ 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_Quote_Comment_Submit_Error_Message);
            errorMessage.add(Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message+': '+lstQLI[0].Pricing_Quote_Line_Number__c);
            errorMessage.add(Label.Pricing_Tender_Quote_IntelResponseReqDate_Submit_Error_Message);
            errorMessage.add(Label.Pricing_Tender_Quote_ProposalDueDate_Submit_Error_Message);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            System.assertEquals(glbVariable.isSuccess,false);        
        }
    }

    @isTest
    public static void testPublishTenderQuote_qliCheck(){
        Test.startTest();
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c,SBQQ__Account__c ,SBQQ__PrimaryContact__c from SBQQ__Quote__c Limit 1]);
        List<SBQQ__Quote__c> quotes = Pricing_Test_Utility.createQuoteWithParam(lstquote[0].SBQQ__Account__c, lstquote[0].SBQQ__PrimaryContact__c, 1,lstquote[0].Pricing_Intel_Sales_Rep_Email_Txt__c,lstquote[0].Pricing_Intel_Account_Exec_Email_Txt__c);
        test.stopTest();
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(quotes[0].id);
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_QuoteLine_Mandatory_Submit_Error_Message);
            //errorMessage.add(Label.Pricing_Tender_Intel_Response_Date_Blank_Error_Submission);
            errorMessage.add(Label.Pricing_Tender_Quote_Comment_Submit_Error_Message);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            System.assertEquals(glbVariable.isSuccess,false);
        }
    }

    @isTest
    public static void testPublishTenderQuote_priceCheck(){
        Test.startTest();
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        lstquote[0].SBQQ__Status__c = Label.Pricing_Tender_Quote_Status_Submitted;
        update lstquote[0];
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c limit 5]);
        lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = null;
        lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1;
        lstquoteLines[0].Pricing_Single_System_Price_Amt__c = null;
        lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = null;
        lstquoteLines[0].Pricing_Systems_qty__c = 10;
        lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 2;
        update lstquoteLines[0];
        test.stopTest();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid=:commentRecordTypeId];
        for(Pricing_Comments__c pc: lstComment){
            if(lstquote[0].id == pc.Pricing_Quote__c){
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            }
            else{
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List<Pricing_Performance_Metric__c> performanceList;
        performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);    
        if(!performanceList.isEmpty()){
            insert performanceList;
        }
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id);
            System.assertEquals(glbVariable.isSuccess,true);
            Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
    }

    @isTest
    public static void testPublishTenderQuote_discountCheck(){
        Test.startTest();
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c,Pricing_Is_Sanctioned__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id limit 1]);
        lstquoteLines[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 100;
        lstquoteLines[0].Pricing_Req_Discounted_Unit_Price__c = 1000;
        lstquoteLines[0].Pricing_Single_System_Price_Amt__c = 1;
        lstquoteLines[0].Pricing_Additional_OEM_Discount_Amt__c = 1;
        lstquoteLines[0].Pricing_Systems_qty__c = 1;
        lstquoteLines[0].Pricing_CPUs_per_system_qty__c = 1;
        update lstquoteLines[0];
        test.stopTest();
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id+';');
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_QuoteLine_INTEL_Discount_Submit_Error_Message+': '+lstquoteLines[0].Pricing_Quote_Line_Number__c);
            errorMessage.add(Label.Pricing_Tender_QuoteLine_OEM_Discount_Submit_Error_Message+': '+lstquoteLines[0].Pricing_Quote_Line_Number__c);
            errorMessage.add(Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message+': '+lstquoteLines[0].Pricing_Quote_Line_Number__c);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            System.assertEquals(glbVariable.isSuccess,false);
            Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
    }
    
    @isTest
    public static void testPublishTenderQuote_svdQuantityCheck(){
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        Account acc = [Select id from Account where Name='Test Account' Limit 1];
        Contact con = [Select id from Contact where AccountId =: acc.Id Limit 1 ];
        User fseUser = [Select Id,Email from User where Email = 'testnewfseemail@intel.com' Limit 1];
        User aeUser = [Select id,Email from User where Email= 'firstNameAE@intel.com' Limit 1];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product']; //CH
        Product2 prod = [Select Id from Product2 where Name = :'Product X'];
        List<User> lstAdminUser = [select id from user where email = 'publishQuoteAdmin@intel.com'];
        
        Pricing_QuoteProgram_CAPSize__c capRec = new Pricing_QuoteProgram_CAPSize__c();
        capRec.Name = 'Test Account';
        capRec.Pricing_Account_Id__c = acc.Id;
        capRec.Pricing_Active_cb__c = true;
        capRec.Pricing_Small_Deal_CAP_size_Number__c = 1;
        insert capRec;
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select Id,SBQQ__Account__c,SBQQ__PrimaryContact__c,Pricing_Server_Deal_Type_Nm__c,Pricing_Project_Name_Nm__c, 
        RecordTypeId, Pricing_Intel_Sales_Rep_Email_Txt__c , Pricing_End_Customer__c, Pricing_Customer_Nm__c, Pricing_ShipmentStDate_Dt__c, Pricing_Intel_Account_Exec_Email_Txt__c, 
        Pricing_Bid_Dt__c, Pricing_ShipmentEndDate_Dt__c, Pricing_End_Customer_Country_Nm__c, Pricing_Region_Nm__c, Pricing_Quote_Program_Nm__c, Pricing_Program_Type_Nm__c 
        FROM SBQQ__Quote__c Limit 1]);
       
        lstquote[0].SBQQ__Account__c = acc.Id;
        lstquote[0].SBQQ__PrimaryContact__c = con.Id;
        lstquote[0].Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        lstquote[0].Pricing_Project_Name_Nm__c = 'Test Project23';
        lstquote[0].RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Small_Volume_Quote_Create);
        lstquote[0].Pricing_Intel_Sales_Rep_Email_Txt__c = fseUser.Email;
        lstquote[0].Pricing_End_Customer__c = endCustomer.Id;
        lstquote[0].Pricing_Customer_Nm__c = '';
        lstquote[0].Pricing_ShipmentStDate_Dt__c = system.today();
        lstquote[0].Pricing_Intel_Account_Exec_Email_Txt__c = aeUser.Email;
        lstquote[0].Pricing_Bid_Dt__c = system.today()+7;
        lstquote[0].Pricing_ShipmentEndDate_Dt__c = system.today()+30;
        lstquote[0].Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        lstquote[0].Pricing_Region_Nm__c = 'APJ';
        lstquote[0].Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
        lstquote[0].Pricing_Program_Type_Nm__c = Label.Pricing_Tender_Small_Volume_Quote;
        UPDATE lstquote; 
        
        List<SBQQ__QuoteLine__c> lstQLI = new List<SBQQ__QuoteLine__c>([select Id,Pricing_Quote_Line_Number__c, RecordTypeId,Pricing_Product_Nm__c,Pricing_Other_Product_Nm__c,
        Pricing_OEM_System_Model_Nm__c,Pricing_Systems_qty__c,Pricing_pm_approval_comments_nm__c,Pricing_CPUs_per_system_qty__c,Pricing_Single_System_Price_Amt__c,
        Pricing_OEM_Standard_Unit_Price_Amt__c,Pricing_Req_Discounted_Unit_Price__c,Pricing_Additional_OEM_Discount_Amt__c,Pricing_Competetor_Product__c,
        Pricing_Other_Competitor_Product_Nm__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  Limit 1]);

        lstQLI[0].RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Create);
        lstQLI[0].Pricing_Product_Nm__c = prod.Id;
        lstQLI[0].Pricing_Other_Product_Nm__c = null;
        lstQLI[0].Pricing_OEM_System_Model_Nm__c = 'Test OEM System ';
        lstQLI[0].Pricing_Systems_qty__c = 600; 
        lstQLI[0].Pricing_pm_approval_comments_nm__c = 'Test Comment 1232';
        lstQLI[0].Pricing_CPUs_per_system_qty__c = 2;
        lstQLI[0].Pricing_Single_System_Price_Amt__c = 40;
        lstQLI[0].Pricing_OEM_Standard_Unit_Price_Amt__c = 20;
        lstQLI[0].Pricing_Req_Discounted_Unit_Price__c = 10;
        lstQLI[0].Pricing_Additional_OEM_Discount_Amt__c = 11;
        lstQLI[0].Pricing_Competetor_Product__c = cp.Id;
        lstQLI[0].Pricing_Other_Competitor_Product_Nm__c = 'test'; 
        lstQLI[0].Pricing_Program_Type_Nm__c = Label.Pricing_Tender_Small_Volume_Quote;
        // lstQLI[0].SBQQ__Quote__c = lstquote[0].Id;
        Test.startTest();
        system.runAs(lstAdminUser[0]){
            //UPDATE lstQLI[0]; // fail
        }
        Test.stopTest();
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        SBQQ__QuoteLine__c qli = [select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where id=:lstQLI[0].id limit 1];
        system.runAs(lstUsers[0]){
            Set<String> errorMessage = new Set<String>();
            String quantityError = Label.Pricing_SVD_Quote_Quantity_Submission_Error;
            errorMessage.add(Label.Pricing_Tender_Intel_Response_Date_Blank_Error_Submission);
            errorMessage.add(Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message+': '+qli.Pricing_Quote_Line_Number__c);
            errorMessage.add(quantityError.replace('{{QuoteQuantity}}',String.valueOf(600)));
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            System.assertEquals(glbVariable.isSuccess,false);
        }
    }
    
    @isTest
    public static void testPublishTenderQuote_noAccessCheck(){
        Test.startTest();
        
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,Pricing_Intel_Account_Exec_Email_Txt__c from SBQQ__Quote__c Limit 1]);
        List<User> lstUsers4 = [select id from user where email = :lstquote[0].Pricing_Intel_Account_Exec_Email_Txt__c];
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c limit 5]);
        test.stopTest();
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                FROM Pricing_Comments__c 
                                                WHERE Pricing_Quote__c =: lstquote[0].id and recordtypeid=:commentRecordTypeId];
        for(Pricing_Comments__c pc: lstComment){
            if(lstquote[0].id == pc.Pricing_Quote__c){
                pc.Pricing_Answer__c = null;
                pc.Pricing_Required_Ind__c = true;
            }
            else{
                pc.Pricing_Required_Ind__c = false;
            }
        }
        update lstComment;
        List<Pricing_Performance_Metric__c> performanceList;
        performanceList = Pricing_Test_Utility.createPerformanceMetrics(lstquoteLines[0].Id);    
        if(!performanceList.isEmpty()){
            insert performanceList;
        }
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers4[0]){
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_No_Access_Error_Message);
            
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id);
            System.assertEquals(glbVariable.isSuccess,false);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
    }

    @isTest
    public static void testPublishTenderQuote_validFSECheck(){
        Test.startTest();
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c Limit 1]);
        List<User> lstUsers4 = [select id from user where email = :lstquote[0].Pricing_Intel_Sales_Rep_Email_Txt__c];
        List<PermissionSetAssignment> psa = new  List<PermissionSetAssignment>([Select id from PermissionSetAssignment where AssigneeId =: lstUsers4[0].Id and PermissionSet.Name = 'Tender_User']);
        delete psa;
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c limit 5]);
        test.stopTest();
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        system.runAs(lstUsers[0]){
            Set<String> errorMessage = new Set<String>();
            errorMessage.add(Label.Pricing_Tender_Quote_Sales_Rep_Error_Message);
            errorMessage.add(Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message+': '+lstquoteLines[0].Pricing_Quote_Line_Number__c);
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].id);
            System.assertEquals(glbVariable.isSuccess,false);
            System.assertEquals(glbVariable.messageNotification,errorMessage);
            Pricing_Publish_Quote.submitForReview(lstquoteLines[0].id); 
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
    }

    @isTest
    public static void testPublishTenderQuote_exceptionCheck(){
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__QuoteLine__c> qli = [select id from SBQQ__QuoteLine__c Limit 1];
        Set<Id> qliSet = new Set<Id>{qli[0].id,null};
            Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        test.startTest();
        system.runAs(lstUsers[0]){
            Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(qliSet);
            Pricing_Publish_Quote.setFSEActionOnQuoteLine (null,null,null,false);
        }
        test.stopTest();
        System.assert(!qli.isEmpty(),'QuoteLine should not be empty');
    }

    @isTest
    public static void testPublishTenderQuotePartnerSubmitted(){
        
        List<User> lstUsers = [select id from user where email = 'partner@noemail.com'];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c ORDER BY Name Desc Limit 1]);
        id quoteId = lstquote[0].Id;
        if(lstquote.size() > 0){
            List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quoteId  limit 1]);
            id quoteLineId = lstquoteLines[0].Id;
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                    FROM Pricing_Comments__c 
                                                    WHERE Pricing_Quote__c =: quoteId and recordtypeid=:commentRecordTypeId];
            for(Pricing_Comments__c pc: lstComment){
                if(quoteId == pc.Pricing_Quote__c){
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = true;
                }
                else{
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            Test.startTest(); //CH
            update lstComment;
            for(SBQQ__QuoteLine__c quoteLine : lstquoteLines)
            {
                quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
                quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
                quoteLine.Pricing_Single_System_Price_Amt__c = 500;
                quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 450;
                quoteLine.Pricing_Systems_qty__c = 10;
                quoteLine.Pricing_CPUs_per_system_qty__c = 2;
            }
            
            update lstquoteLines;
            
            List<Pricing_Performance_Metric__c> performanceList;
            if(quoteLineId != null) {
                performanceList = Pricing_Test_Utility.createPerformanceMetrics(quoteLineId);
            }
            if(!performanceList.isEmpty()) {
                insert performanceList;
            }
            Test.stopTest();
            Pricing_Publish_Quote p = new Pricing_Publish_Quote();
            Pricing_Publish_Quote.globalVariables glbVariable;
            if(!lstUsers.isEmpty()){                
                system.runAs(lstUsers[0]){                    
                    if(lstquote.size() > 0){                  
                        glbVariable = Pricing_Publish_Quote.PublishTenderQuote(quoteId);
                        System.assertEquals(glbVariable.isSuccess,true);
                    }
                    
                }
            }
            
        }
        
    }
    
    @isTest
    public static void testPublishTenderQuoteFSESubmitted(){ 
        List<User> lstFSEUsers = [Select Id,Email from User Where Email='testnewfseemail@intel.com' Limit 1];
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c from SBQQ__QuoteLine__c limit 1]);
        Id quoteId = lstquoteLines[0].SBQQ__Quote__c;
        //List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quoteId, 1);
        Id quoteLineId = lstquoteLines[0].Id;
        /*Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
            FROM Pricing_Comments__c 
            WHERE Pricing_Quote__c =: quoteId and recordtypeid=:commentRecordTypeId];
            for(Pricing_Comments__c pc: lstComment){
            if(quoteId == pc.Pricing_Quote__c){
            pc.Pricing_Answer__c = '######testing######';
            pc.Pricing_Required_Ind__c = true;
            }
            else{
            pc.Pricing_Answer__c = '######testing######';
            pc.Pricing_Required_Ind__c = false;
            }
            }

            update lstComment;*/
        for(SBQQ__QuoteLine__c quoteLine : lstquoteLines)
        {
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 102;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 500;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 450;
            quoteLine.Pricing_Systems_qty__c = 10;
            quoteLine.Pricing_CPUs_per_system_qty__c = 2;
        }
        update lstquoteLines;
        
        List<Pricing_Performance_Metric__c> performanceList;
        if(quoteLineId != null)
        {
            performanceList = Pricing_Test_Utility.createPerformanceMetrics(quoteLineId);
        }
        if(!performanceList.isEmpty())
        {
            insert performanceList;
        }
        Pricing_Publish_Quote p = new Pricing_Publish_Quote();
        Pricing_Publish_Quote.globalVariables glbVariable;
        Pricing_Test_Utility.shareQuoteWithUser(quoteId, lstFSEUsers[0].Id);
        Test.startTest();
        if(!lstFSEUsers.isEmpty()){                
            system.runAs(lstFSEUsers[0]){                                        
                //glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].SBQQ__Quote__c);
                glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquoteLines[0].Id);
                System.debug('glbVariable'+glbVariable);
                //System.assertEquals(glbVariable.messageNotification,new Set<String>{'Successfully submitted!'});
                //System.assertEquals(glbVariable.messageNotification,new Set<String>{'All the FSEs in the Quote Team are invalid. Please add minimum one valid FSE.'});
                System.assertEquals(glbVariable.isSuccess,true);
                System.assertEquals(glbVariable.isOnLoad,true);
                System.assertEquals(glbVariable.hasPermission,true);                    
            }
        }
        Test.stopTest();
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id, Pricing_Intel_Sales_Rep_Email_Txt__c, SBQQ__Account__c from SBQQ__Quote__c ORDER BY Name Desc Limit 1]);
        Boolean isSalesRep = Pricing_Publish_Quote.quoteSalesRepValidation(lstquote[0]);                                                                                
    }

    @isTest
    public static void testFSERecordApproval(){
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__C quoteLine = [SELECT Id, Pricing_Sales_Rep__c, Pricing_Status_Nm__c, Pricing_FSE_Recommended_Price_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id LIMIT 1];
        
        User adminUser = [Select id from User where Email='publishQuoteAdmin@intel.com'];
        
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]){
            quoteLine.Pricing_Status_Nm__c = 'Pending Further Intel Review';
            update quoteLine;
        }
        
        System.runAs(adminUser){
            quoteLine.Pricing_Status_Nm__c = 'Pending Intel Field Review';
            quoteLine.Pricing_Sales_Rep_Approver__c = adminUser.Id;
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test';
            quoteLine.Pricing_FSE_Recommended_Price_Nm__c = '120';
            update quoteLine;
            
            Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{quoteLine.Id});
            System.assertEquals(quoteLine.Pricing_Status_Nm__c,'Pending Intel Field Review');                                                                                
            Pricing_Publish_Quote.setFSEActionOnQuoteLine(new Set<Id>{quoteLine.Id},'Approve','Test',true);
            
            Map<Id, String> qliIdMap = new Map<Id, String>();
            qliIdMap.put(quoteLine.Id, 'Test');
            Pricing_Publish_Quote.setFSEActionOnQuoteLine(qliIdMap,'Approve');
        }
        Test.stopTest();
    }
}