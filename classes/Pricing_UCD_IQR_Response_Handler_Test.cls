/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-26-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_UCD_IQR_Response_Handler_Test {
     //Setting up Test Data
    @testSetup
    public static void setUpData(){
    	List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_UCD_IQR_Response_Handler_Test');
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            Test.startTest();
            List<User> salesRepUserList =Pricing_Test_Utility.createSalesRepUser();

            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuote(acc.Id, con.Id, 1);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
        }
    }
    
    static testmethod void testUCDNewL1l2Creation() {
        Test.startTest();
        List<Account> acc = [Select id from Account limit 1];
        //List<User> partnerUser = [select id from user where email = 'partner@noemail.com' limit 1];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Pricing_Publish_Quote.globalVariables glbVariable;
        List<User> salesRepUserList =[Select id,Email from User where Email = 'FirstName@intel.com' limit 1];
        
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
      
        system.runAs(salesRepUserList[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            lstquoteLines[0].Pricing_Quote_Line_Status_Number__c = 30;
            update lstquoteLines[0];
        }
        Test.stopTest();      
        Pricing_UCD_IQR_Response_Handler.processUCDResponses(getUCDResponseWrapper());
        System.assertEquals(true ,glbVariable != null);
        
       // processUCDResponses(ucdResponseObjectList);
        
    }

    static testmethod void testUCDL1ExistingL2Creation() {
        Test.startTest();
        //List<User> lstUsers4 = [select id from user where email = 'firstName@intel.com' limit 1];
        List<User> partnerUser = [select id from user where email = 'partner@noemail.com' limit 1];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,SBQQ__Account__c from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Pricing_Publish_Quote.globalVariables glbVariable;
        
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
        
        system.runAs(partnerUser[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }

        
     
        Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        newEndCustAccL1.Name = 'Test End Customer';
        newEndCustAccL1.Pricing_Account_Nm__c = lstquote[0].SBQQ__Account__c;
        newEndCustAccL1.Pricing_Active_cb__c = true;
        newEndCustAccL1.Pricing_Unified_EndCustomer_Id__c = '12345';
        insert newEndCustAccL1;
        
        Pricing_UCD_IQR_Response_Handler.processUCDResponses(getUCDResponseWrapper());
        System.assertEquals(true ,lstquote.size() >0);
        Test.stopTest();
       // processUCDResponses(ucdResponseObjectList);
        
    }
    
    static testmethod void testUCDL1L2Present() {
        Test.startTest();
        List<User> lstUsers4 = [select id from user where email = 'firstName@intel.com' limit 1];
        List<User> partnerUser = [select id from user where email = 'partner@noemail.com' limit 1];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,SBQQ__Account__c from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Pricing_Publish_Quote.globalVariables glbVariable;
        
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
        
        system.runAs(partnerUser[0]){
            glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
        }
        lstquoteLines[0].Pricing_Quote_Line_Status_Number__c = 30;
        update lstquoteLines[0];
        
        
        Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
        newEndCustAccL1.Name = 'Test End Customer';
        newEndCustAccL1.Pricing_Account_Nm__c = lstquote[0].SBQQ__Account__c;
        newEndCustAccL1.Pricing_Active_cb__c = true;
        newEndCustAccL1.Pricing_Unified_EndCustomer_Id__c = '12345';
        insert newEndCustAccL1;
        
        Pricing_UnifiedEndCustomerCountryMapping__c newEndCustCountry = new Pricing_UnifiedEndCustomerCountryMapping__c();
        newEndCustCountry.Name = 'Test End Customer';
        newEndCustCountry.Pricing_Country_Nm__c = 'Afghanistan';
        newEndCustCountry.Pricing_Unified_Country_EndCustomer_Id__c ='56789';
        newEndCustCountry.Pricing_Unified_EndCustomer_Act_Mapping__c = newEndCustAccL1.Id;
        insert newEndCustCountry;
        
        Pricing_UCD_IQR_Response_Handler.processUCDResponses(getUCDResponseWrapper());
        System.assertEquals(true ,lstquote.size() >0);
        Test.stopTest();
       // processUCDResponses(ucdResponseObjectList);
        
    }

    static testmethod void testACMEventPublish() {
        Test.startTest();
       // List<Account> acc = [Select id from Account limit 1];
        //List<User> partnerUser = [select id from user where email = 'partner@noemail.com' limit 1];
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>([select id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id  limit 1]);
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Pricing_Publish_Quote.globalVariables glbVariable;
        List<User> salesRepUserList =[Select id,Email from User where Email = 'FirstName@intel.com' limit 1];
        //List<AccountTeamMember> accTeam =Pricing_Test_Utility.createAccountTeamMember(acc[0].Id,salesRepUserList[0].Id);
        
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
      
        system.runAs(salesRepUserList[0]){
           // glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id);
            lstquoteLines[0].Pricing_Quote_Line_Status_Number__c = 30;
            update lstquoteLines[0];
        }
        //Test.stopTest();
        List<Pricing_UCD_ResponseWrapper.ResponseData> responseList = getUCDResponseWrapper();
		
        List<ACM_Account_Change_Event__e> acmEventList = new List<ACM_Account_Change_Event__e>();
        ACM_Account_Change_Event__e acmEvent1 = new ACM_Account_Change_Event__e();
        acmEvent1.Headers__c = JSON.serialize(getUCDResponseHeader()); // {"CustomerAggregationType":"UNFD_CTRY_CUST","CustomerProcessEngagement":"DIR_PRC_EXCPT","DISTI_PRC_EXCPT"}'; 
        acmEvent1.Message__c = JSON.serialize(responseList[0]);
        acmEventList.add(acmEvent1);

        responseList[0].RecordType = 'Rejected Account';
        responseList[0].SurvivorAccountId = responseList[0].AccountId;
        responseList[0].RequestedAccountRejectionReason = 'Rejected';
        //update responseList[0];
        ACM_Account_Change_Event__e acmEvent2 = new ACM_Account_Change_Event__e();
        acmEvent2.Headers__c = JSON.serialize(getUCDResponseHeader());
        acmEvent2.Message__c = JSON.serialize(responseList[0]);
        acmEventList.add(acmEvent2);

        List<Database.SaveResult> sr = EventBus.publish(acmEventList);
        System.assertEquals(true ,lstquote.size() >0);
        Test.stopTest();
    }   
	
    public static List<Pricing_UCD_ResponseWrapper.ResponseData> getUCDResponseWrapper(){
        List<Pricing_UCD_ResponseWrapper.ResponseData> ucdResponseObjectList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id,SBQQ__Account__c from SBQQ__Quote__c Limit 1]);
        List<Account> accRecordList = [select Id from Account limit 10];
        
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        acc.Name = 'Test End Customer';
        acc.Industry = 'Banking';
        acc.BillingCity = 'Pune';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-210';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        //acc.Core_Customer_Process_Engg__c = 'DIR_PRC_EXCPT';
        acc.BillingCountry = 'USA';
        acc.BillingCountryCode = 'USA';
        acc.ShippingCountryCode = 'USA';
        acc.ParentId = accRecordList[0].Id;
        acc.Core_Business_Party_Id__c = '1000678929';
        //acc.Core_Mastered_Country_Nm__c = 'United States';
        //acc.Core_Mastered_Simplified_Account_Nm__c = 'Scarlet';
        insert acc;
        
        Business_Types__c businessType  = new Business_Types__c();
        businessType.Name = 'Direct Price Exception';
        businessType.Business_Type_Code__c = 'SLS_PPLN';
        businessType.Is_Active__c = true;
        insert businessType;
        
        Account_Business_Types__c accBusinessType = new Account_Business_Types__c();
        accBusinessType.Account__c = acc.Id;
        accBusinessType.Business_Types__c = businessType.Id;
        insert accBusinessType;
        
        Pricing_Integration_Staging__c pisRec = new Pricing_Integration_Staging__c();
        pisRec.Pricing_RequestID__c = acc.Id;
        pisRec.Pricing_SObjectId__c = lstquote[0].Id;
        pisRec.Pricing_QuoteID__c =  lstquote[0].Id;
        pisRec.Pricing_Message_Type__c = 'UnifiedEndCustomer';
        pisRec.Pricing_Status__c = 'Successful';
        pisRec.Pricing_UCD_Response_Type__c = 'Requested Account';
        insert pisRec;
        
        Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObject1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        ucdResponseObject1.AccountId = String.valueOf(acc.Id);
        ucdResponseObject1.AccountName = 'Test End Customer';
        ucdResponseObject1.MasteredSimplifiedAccountName = 'Test End Customer';
        ucdResponseObject1.BusinessPartyIdentifier = '56789';
        ucdResponseObject1.RecordType = Label.Pricing_UCD_Account_Record_Type;
   
        Pricing_UCD_ResponseWrapper.AccountAddress  primaryAddress1 = new Pricing_UCD_ResponseWrapper.AccountAddress();
        primaryAddress1.TypeCode ='';
        primaryAddress1.CountryCode ='AFG';
        primaryAddress1.CountryName = 'Afghanistan';
        ucdResponseObject1.PrimaryAddress = primaryAddress1;
        
        Pricing_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress  physicalAddress1 = new Pricing_UCD_ResponseWrapper.MasteredBusinessPhysicalAddress('AFG','Afghanistan');
        ucdResponseObject1.MasteredBusinessPhysicalAddress = physicalAddress1;
        
        Pricing_UCD_ResponseWrapper.AccountAddress  secondaryAddress1 = new Pricing_UCD_ResponseWrapper.AccountAddress();
        ucdResponseObject1.SecondaryAddress = primaryAddress1;
        
        Pricing_UCD_ResponseWrapper.ResponseData parentAcount1 = new Pricing_UCD_ResponseWrapper.ResponseData();
        parentAcount1.AccountId = '5464';
        parentAcount1.AccountName = 'Test End Customer';
        parentAcount1.BusinessPartyIdentifier = '12345';
        ucdResponseObject1.parentAccount = parentAcount1;
        
        List<Pricing_UCD_ResponseWrapper.ComplianceWatchList> cwlList = new List<Pricing_UCD_ResponseWrapper.ComplianceWatchList>();
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('EC', 'Embargoed Country');
        Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl1 = new Pricing_UCD_ResponseWrapper.ComplianceWatchList('NOPAYOUT', 'Block Payment from Intel');
        
        cwlList.add(cwl);
        cwlList.add(cwl1);
        ucdResponseObject1.complianceWatchList = cwlList;
        
        Pricing_UCD_ResponseWrapper.CustomerAggregationType custAgg = new Pricing_UCD_ResponseWrapper.CustomerAggregationType('UNFD_CTRY_CUST','');
        ucdResponseObject1.CustomerAggregationType = custAgg;    
        Pricing_UCD_ResponseWrapper.CustomerProcessEngagement custPro = new Pricing_UCD_ResponseWrapper.CustomerProcessEngagement('DIR_PRC_EXCPT','');
        ucdResponseObject1.CustomerProcessEngagement = new List<Pricing_UCD_ResponseWrapper.CustomerProcessEngagement>{custPro};
  
        ucdResponseObjectList.add(ucdResponseObject1);
      
        return ucdResponseObjectList;
        
    }
    
    public static Pricing_UCD_ResponseWrapper.Header getUCDResponseHeader(){
        Pricing_UCD_ResponseWrapper.Header header = new Pricing_UCD_ResponseWrapper.Header();
        header.CustomerAggregationType = 'UNFD_CTRY_CUST';
        header.CustomerProcessEngagement = 'DIR_PRC_EXCPT';
        return header;
    }
    
}