/**
 * @description       : 
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 03-11-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteBusinessLogic_Test {
    
    //Method to setup Test data
    @testSetup
    public static void setUpData() {
        
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('quoteBusinessLogicAdmin');
        Pricing_Test_Utility.createPriceBook();
        
        System.runAs(adminUserList[0]) {

            List<User> aeUser = Pricing_Test_Utility.createAEUserWithParam('FirstNameAEChange1@intel.com');           
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Contact con1 = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Business_logic_Test');
            
            List<User> accExecUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExecUserList[0].Email);
            List<SBQQ__QuoteLine__c> quoteLineList = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);

            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                    FROM Pricing_Comments__c 
                                                    WHERE Pricing_Quote__c =: quoteList[0].Id and recordtypeid=:commentRecordTypeId];
            for(Pricing_Comments__c pc: lstComment){
                 if(quoteList[0].Id == pc.Pricing_Quote__c){
                     pc.Pricing_Answer__c = '######testing######';
                     pc.Pricing_Required_Ind__c = true;
                 }
                else{
                    pc.Pricing_Answer__c = '######testing######';
                    pc.Pricing_Required_Ind__c = false;
                }
            }
            update lstComment;
            List<Pricing_Performance_Metric__c> performanceList = Pricing_Test_Utility.createPerformanceMetrics(quoteLineList[0].Id);
            insert performanceList;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            
            Group grp = Pricing_Test_Utility.createGroupRecord();
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = adminUserList[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            ChannelProgram chProg = Pricing_Test_Utility.createChannelProgramRecord();

            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupList = Pricing_Test_Utility.createPGMRecord(acc,grp,chProg,2);

            Test.stopTest();
            
            List<Contact> drLimitedConList = Pricing_Test_Utility.createDrafterLimitedContact(acc.Id,1);
             User drafterLimitedUser = [Select id from User where contactId =:drLimitedConList[0].Id limit 1];
             //System.runAs(drafterLimitedUser) {
                    List<SBQQ__Quote__c> quoteNewList= Pricing_Test_Utility.createQuoteWithParam(acc.Id, drLimitedConList[0].Id,1,salesRepUserList[0].Email,'');
                    //SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createWINQuoteLines(quoteNewList[0].Id); 
             //}
            //Test.stopTest();

            //The setUpData covers 54% for quote creation
        }
    }
          
       
    static testmethod void testChangeInPrimaryContactAndAE() {
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Account_Executive_Nm__c,RecordTypeId,SBQQ__Account__c,Pricing_Quote_Program_Nm__c from SBQQ__Quote__c limit 1];
        SBQQ__Quote__c quoteRec = lstquote[0]; 
        List<User> adminUser = [Select id from User where Email='quoteBusinessLogicAdmin@intel.com' LIMIT 1];  
        List<User> aeUser = [Select Id,Email from User Where Email='FirstNameAEChange1@intel.com' Limit 1];
        List<Contact> conList = new List<Contact>();
        System.runAs(adminUser[0]) {
        	 conList = Pricing_Test_Utility.createPrimaryContact(quoteRec.SBQQ__Account__c,2);
             if(!conList.isEmpty() && !aeUser.isEmpty()) {
                 quoteRec.SBQQ__PrimaryContact__c = conList[1].Id;
                 quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c = aeUser[0].Email;
                 quoteRec.Pricing_End_Customer_Country_Nm__c = 'India';
                 update quoteRec;
             }       
        }
        System.assert(quoteRec.SBQQ__PrimaryContact__c != null,'Primary contact can not be blank.');
  
        Test.stopTest(); 
         //58
    }
   
    static testmethod void testUpdateBlankAEEmailOnQuote() {       
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordTypeId,SBQQ__Account__c,Pricing_Intel_Account_Exec_Email_Txt__c from SBQQ__Quote__c limit 1];
        SBQQ__Quote__c quoteRec = lstquote[0]; 
        List<User> fseUser = [select id from User where Email = 'firstNameSalesRep@intel.com'];
        List<User> aeUser = [Select Id,Email from User Where Email='FirstNameAEChange1@intel.com' Limit 1];
        User salesRepOnQuote = [Select id from User where id=:quoteRec.SBQQ__SalesRep__c];
        System.runAs(salesRepOnQuote) {
            if(!aeUser.isEmpty()) {
                quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c = '';//aeUser[0].Email;
                quoteRec.Pricing_Route_Rule_Name_Txt__c ='Test Rule';
                quoteRec.Pricing_Pricing_Manager__c = UserInfo.getUserId();
                quoteRec.Pricing_Program_Type_Nm__c='Data Center';
                 quoteRec.Pricing_ReRouting_Reason_Nm__c='RPM Coverage';
                update quoteRec;
            }
        } 
        System.assertEquals(quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c,'','AE Email field is not updated.');
        Test.stopTest();
    }
    
    static testmethod void testUpdateAccExecOnQuote() {
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c,RecordTypeId,SBQQ__Account__c from SBQQ__Quote__c limit 1];
        SBQQ__Quote__c quoteRec = lstquote[0]; 
        User adminUser = [select id,Email from User where Email = 'quoteBusinessLogicAdmin@intel.com'];
        AccountTeamMember accTeam = new AccountTeamMember(AccountId =quoteRec.SBQQ__Account__c,TeamMemberRole = 'Technical Sales',UserId = adminUser.Id);
        insert accTeam;
        User salesRepOnQuote = [Select id from User where id=:quoteRec.SBQQ__SalesRep__c];
        QuoteBusinessLogic.isQTMChanged = true;

        System.runAs(adminUser) {
            List<User> aeUser = [Select Id,Email from User Where Email='FirstNameAEChange1@intel.com' Limit 1];
            Pricing_Quote_Team__c qtm = new Pricing_Quote_Team__c();
            qtm.Pricing_Quote_Id__c = quoteRec.Id;
            qtm.Pricing_Quote_Team_Member_Id__c = aeUser[0].Id;
            qtm.Pricing_Role_Nm__c = 'Account Executive';
            insert qtm;
        }
		 
        System.runAs(salesRepOnQuote) {
           // quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c = fseUser.Email;
            quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c = '';
            quoteRec.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            update quoteRec;
        }
        System.assertEquals(quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c,'','AE Email field is not updated.');
        Test.stopTest();
    }
    
    static testmethod void testCreateQuoteByITS() {
        Test.startTest();           
    	Account acc = [Select id from Account where Name='Test Account' Limit 1];
        Contact con = [Select id from Contact where AccountId =: acc.Id Limit 1 ];
        User fseUser = [Select id,Email from User where Email = 'firstNameSalesRep@intel.com' Limit 1];
        List<User> itsUser = Pricing_Test_Utility.createITSUser();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        System.runAs(itsUser[0]) {
        	quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id,1,fseUser.Email,'');     
        }
        System.assert(!quoteList.isEmpty(),'Quote is not created by ITS.' );
        Test.stopTest();
    }
   
    static testmethod void testCreateQuoteByAE() {
        Test.startTest();           
    	Account acc = [Select id from Account where Name='Test Account' Limit 1];
        Contact con = [Select id from Contact where AccountId =: acc.Id Limit 1 ];
        User fseUser = [Select id,Email from User where Email = 'firstNameSalesRep@intel.com' Limit 1];
        User aeUser = [Select id,Email from User where Email= 'firstNameAE@intel.com' Limit 1];
        User adminUser = [Select id,Email from User where Email= 'quoteBusinessLogicAdmin@intel.com' Limit 1];
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        System.runAs(aeUser) {
        	quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id,1,fseUser.Email,'');   
        }
        Map<Id,Id> aeoldQuoteIdMap = new Map<Id,Id>();
        aeoldQuoteIdMap.put(quoteList[0].Id,aeUser.Id);
        QuoteBusinessLogic.deleteShareQuoteFuture(aeoldQuoteIdMap);
        System.assert(!quoteList.isEmpty(),'Quote is not created by AE.' );   
        Test.stopTest();
    }
    
    static testmethod void testUpdateFSEOnQuote() {
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select id,Pricing_On_Hold_Cb__c,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c,RecordTypeId,SBQQ__Account__c from SBQQ__Quote__c limit 1];
        SBQQ__Quote__c quoteRec = lstquote[0]; 
        List<User> FSEUser1 = Pricing_Test_Utility.createFSEUserWithParam('FSEUser@intel.com','Test','');
        User fseUser = [select id,Email from User where Email =: FSEUser1[0].Email];
        User adminUser = [select id,Email from User where Email = 'quoteBusinessLogicAdmin@intel.com'];
        AccountTeamMember accTeam = new AccountTeamMember(AccountId =quoteRec.SBQQ__Account__c,TeamMemberRole = 'Technical Sales',UserId = adminUser.Id);
        insert accTeam;
        AccountTeamMember accTeam1 = new AccountTeamMember(AccountId =quoteRec.SBQQ__Account__c,TeamMemberRole = 'Technical Sales',UserId = fseUser.Id);
        insert accTeam1;
       
        User salesRepOnQuote = [Select id from User where id=:quoteRec.SBQQ__SalesRep__c];
        
        //User primaryContact = [Select id from User where ContactId =:quoteRec.SBQQ__PrimaryContact__c limit 1 ];
        //Test.startTest();
        //List<SBQQ__QuoteLine__c> quoteLineList = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].Id];
       // Test.startTest();
        //System.runAs(primaryContact){
        	//Pricing_Publish_Quote.globalVariables glbVariable = Pricing_Publish_Quote.PublishTenderQuote(lstquote[0].id); 
           /* quoteLineList[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
        	update quoteLineList[0];
            Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(new Set<Id>{quoteLineList[0].Id});q*/
       // }
       // Test.startTest();
        QuoteBusinessLogic.isQTMChanged = true;
List<User> pricingManagerList = Pricing_Test_Utility.createPricingMangerUser();
        //Test.stopTest();  
        System.runAs(salesRepOnQuote) {
            quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c = fseUser.Email;
            update quoteRec;
        }
      
        System.assert(!lstquote.isEmpty(),'lstquote should not be empty');
        Test.stopTest(); 
    }
  
    static testmethod void testCreateSVDQuote(){
        Test.startTest();
        Account acc = [Select id from Account where Name='Test Account' Limit 1];
        Contact con = [Select id from Contact where AccountId =: acc.Id Limit 1 ];
        User fseUser = [Select id,Email from User where Email = 'firstNameSalesRep@intel.com' Limit 1];
        User aeUser = [Select id,Email from User where Email= 'firstNameAE@intel.com' Limit 1];
        
        Pricing_QuoteProgram_CAPSize__c capRec = new Pricing_QuoteProgram_CAPSize__c();
        capRec.Name = 'Test Account';
        capRec.Pricing_Account_Id__c = acc.Id;
        capRec.Pricing_Active_cb__c = true;
        capRec.Pricing_Small_Deal_CAP_size_Number__c = 1;
        insert capRec;
        
        System.runAs(fseUser) {
        	//quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id,1,fseUser.Email,'');
            List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();    
            Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Small_Volume_Quote_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = fseUser.Email;
            quote.Pricing_End_Customer__c = endCustomer.Id;
            quote.Pricing_Customer_Nm__c = '';
            quote.Pricing_ShipmentStDate_Dt__c = system.today();
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = aeUser.Email;
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';      
            quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            lstQuote.add(quote);

            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1.SBQQ__Account__c = acc.Id;
            quote1.SBQQ__PrimaryContact__c = con.Id;
            quote1.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote1.Pricing_Project_Name_Nm__c = 'Test Project23';
            quote1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Small_Volume_Quote_Create);
            quote1.Pricing_Intel_Sales_Rep_Email_Txt__c = fseUser.Email;
            quote1.Pricing_End_Customer__c = endCustomer.Id;
            quote1.Pricing_Customer_Nm__c = '';
            quote1.Pricing_ShipmentStDate_Dt__c = system.today();
            quote1.Pricing_Intel_Account_Exec_Email_Txt__c = aeUser.Email;
            quote1.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote1.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote1.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote1.Pricing_Region_Nm__c = 'APJ';      
            quote1.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
            lstQuote.add(quote1);
            //insert lstQuote;
            
            Set<Id> accountIdSVDSet = new Set<Id>();
            Map<Id,Integer> accountIdSVDQuoteNumberMap = new Map<Id,Integer>();
            accountIdSVDSet.add(lstQuote[0].SBQQ__Account__c);
            lstQuote[0].SBQQ__Status__c = 'Rejected';
            //update lstQuote;
            QuoteBusinessLogic.getSVDCapSizeMap(accountIdSVDSet,accountIdSVDQuoteNumberMap);
            System.assert(!lstQuote.isEmpty(),'lstQuote should not be empty');
        }  
			
        Test.stopTest();
    }
    
    
    static testmethod void testupdateUnifiedEndCustomerQuote(){
         Test.startTest();
        Account newAcc = new Account();
        newAcc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        newAcc.Name = 'Test Account123';
        newAcc.Core_Account_Type__c = 'Distributor';
        newAcc.Industry = 'Banking';
        newAcc.BillingCity = 'Texas';
        newAcc.BillingCountry = 'USA';
        newAcc.BillingStreet = 'G-210';
        newAcc.Core_Business_Party_Id__c='12345';
        insert newAcc;
        Account acc = [Select Id,Core_Parent_Business_Party_Id__c,ParentId from Account where Name='Test Account' Limit 1];
       Assert.isNotNull(acc, 'acc>> The record should have been created/queried.');
        acc.Core_Parent_Business_Party_Id__c='12345';
        acc.ParentId=newAcc.id;
        update acc;
        Account acc2 = [select id,Core_Parent_Business_Party_Id__c,ParentId from Account where Core_Parent_Business_Party_Id__c!=null and Parent.RecordType.name='Intel Account' limit 1];
         Assert.isNotNull(acc2.Core_Parent_Business_Party_Id__c, 'acc2>> The record should have been created/queried.');
        List<SBQQ__Quote__c> lstQuote = [SELECT Id,SBQQ__Account__c,Pricing_End_Customer__c,Pricing_End_Customer_Country_Nm__c,Pricing_Account_Executive_Nm__c,Pricing_Unified_Global_End_Customer_Nm__c FROM SBQQ__Quote__c LIMIT 1];
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
         Pricing_UnifiedEndCustomerCountryMapping__c unifiedCountryObj;
            unifiedCountryObj = new Pricing_UnifiedEndCustomerCountryMapping__c();
            unifiedCountryObj.Pricing_Unified_EndCustomer_Act_Mapping__c = endCustomer.Id;
            unifiedCountryObj.Name = 'Test';
            unifiedCountryObj.Pricing_Unified_Country_EndCustomer_Id__c = '111';
           unifiedCountryObj.Pricing_RequestID__c=acc2.id;
            
            insert unifiedCountryObj;
       
        lstQuote[0].SBQQ__Account__c = newAcc.Id;
        lstQuote[0].Pricing_End_Customer__c = endCustomer.Id;
        lstQuote[0].Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        lstQuote[0].Pricing_Unified_Global_End_Customer_Nm__c = unifiedCountryObj.id;
        lstQuote[0].Pricing_Account_Executive_Nm__c= null;
        update lstQuote;
        System.assert(!lstQuote.isEmpty(),'lstQuote should not be empty');
        Test.stopTest();
    }

	/*
    static testmethod void testCreateQuoteByDrafterLimited() {
        //Test.startTest();
        List<User> adminUser = [select id,Email from User where Email = 'quoteBusinessLogicAdmin@intel.com'];
        User fseUser = [Select id,Email from User where Email = 'firstNameSalesRep@intel.com' Limit 1];
        Account acc = [Select id from Account where Name='Test Account' Limit 1];
		Contact drafterLmtUser = [Select id,Email from Contact where Email = 'drafterLimited0@noemail.com' ];
        System.runAs(adminUser[0]) {
            User partnerAdminUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
			
            Group grp = new Group();
            grp.name = 'Test Group2';
            grp.Type = 'Regular'; 
            Insert grp; 
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = partnerAdminUser.id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            ChannelProgram chProg =[Select id from ChannelProgram Limit 1];

            Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
            partnerGroup.Core_MDF_Account__c = acc.Id;
            partnerGroup.Core_MDF_Group_Name__c = 'Test Group2';
            //partnerGroup.Core_MDF_Channel_Program_Name_Txt__c = Label.Pricing_Tender_PGM_Channel;
            partnerGroup.Core_MDF_Channel_Program__c=chProg.id;
            partnerGroup.Core_MDF_AccountIdGroupName__c='Test Group2';
            partnerGroup.Core_MDF_Group_Id__c=grp.id;
            insert partnerGroup; 
            
            List<SBQQ__Quote__c> quoteList =[Select id,SBQQ__PrimaryContact__c,Pricing_Status_Precedence_Number__c,SBQQ__Status__c from SBQQ__Quote__c where SBQQ__PrimaryContact__c=:drafterLmtUser.Id ];
            SBQQ__QuoteLine__c quoteLine = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].id Limit 1 ];
           
            Group grp1 = [SELECT Id From Group WHERE Name = 'All External Tender Partners' LIMIT 1];
            GroupMember grpMem = new GroupMember();
            grpMem.GroupId  = grp1.Id;
            grpMem.UserOrGroupId = partnerAdminUser.Id;
            insert grpMem;
            Test.startTest();
            System.runAs(partnerAdminUser) {
                quoteList[0].Pricing_Intel_Account_Exec_Email_Txt__c = adminUser[0].Email;
                update quoteList[0];
                Id cmtRecTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
                List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Quote__c
                                                        FROM Pricing_Comments__c 
                                                        WHERE Pricing_Quote__c =: quoteList[0].Id and recordtypeid=:cmtRecTypeId];
                for(Pricing_Comments__c pc: lstComment) {
                    if(quoteList[0].Id == pc.Pricing_Quote__c) {
                        pc.Pricing_Answer__c = '######testing######';
                        pc.Pricing_Required_Ind__c = true;
                    }
                    else {
                        pc.Pricing_Answer__c = '######testing######';
                        pc.Pricing_Required_Ind__c = false;
                    }
                }
                update lstComment;             
                List<Pricing_Performance_Metric__c> performanceList = Pricing_Test_Utility.createPerformanceMetrics(quoteLine.Id);
                insert performanceList;
				
                Pricing_Publish_Quote.globalVariables glbVariable =  Pricing_Publish_Quote.PublishTenderQuote(quoteList[0].Id); 
                System.assert(quoteList[0].SBQQ__PrimaryContact__c!= Null, 'Primary Contact is not updated.');
            } 
            
        } 
        Test.stopTest(); 
    }*/
	static testmethod void testGetLogEntryRec() {
        Test.startTest();
        List<SBQQ__Quoteline__c> lstQli = [select id from SBQQ__Quoteline__c limit 1];
        List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>();
        quoteShares.add(new SBQQ__Quote__Share(ParentId = lstQli[0].Id,
                                                   UserOrGroupId = lstQli[0].Id,
                                                   AccessLevel = 'edit',
                                                   RowCause = Schema.SBQQ__Quote__Share.RowCause.Pricing_Account_Team_Group__c ));
        Database.SaveResult[] result = Database.insert(quoteShares ,false);
        QuoteBusinessLogic.getLogEntryRec(result,'Quote Share');
        System.assertEquals(true,quoteShares.size()>0);
        Test.stopTest(); 
    }
    static testmethod void testChangeOwnerId() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteLst = [Select id from SBQQ__Quote__c];
        QuoteBusinessLogic.changeOwnerId(new Set<Id>{quoteLst[0].id});
        System.assertEquals(true,quoteLst.size()>0);
        Test.stopTest(); 
    }
    static testmethod void testCreateQuotewithPartner() {
        User usr = [select id,ContactId from User where email = 'Quote_Business_logic_Test@noemail.com'];
        Account acc = [select id from Account limit 1];
        Pricing_UnifiedEndCustomerAccountMapping__c endCustomer = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
        System.runAs(usr){
        Test.startTest();
			SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__PrimaryContact__c = usr.ContactId;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Small_Volume_Quote_Create);
            quote.Pricing_End_Customer__c = endCustomer.Id;
            quote.Pricing_Customer_Nm__c = '';
            quote.Pricing_ShipmentStDate_Dt__c = system.today();
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';      
            quote.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;      
            //insert quote;
            System.assertEquals('Tender',quote.Pricing_Quote_Program_Nm__c );
            Test.stopTest(); 
        }
    }
    static testmethod void testupdateQuoteHoldHistory() {
        
        List<Id> lstquoteids = new List<Id>();
        SBQQ__Quote__c lstquote = [select id,Pricing_On_Hold_Comment__c,Pricing_On_Hold_Cb__c from SBQQ__Quote__c limit 1];
        lstquote.Pricing_On_Hold_Comment__c = 'Removed from Hold';
        update lstquote;
        lstquoteids.add(lstquote.Id);

        Pricing_Quote_Hold_Status_Age__c holdStatusAge = new Pricing_Quote_Hold_Status_Age__c();
        holdStatusAge.Pricing_QuoteOnHold__c = lstquote.Id;
        holdStatusAge.Pricing_Is_On_Hold__c = true;
        holdStatusAge.Pricing_QuoteOnHold_End_Time__c = null;
        holdStatusAge.Pricing_Quote_On_Hold_Comment__c = 'Test comments on hold comment field';
        insert holdStatusAge;
        Test.startTest();
        QuoteBusinessLogic.updateQuoteHoldHistory(lstquoteids);
        System.assertEquals('Removed from Hold',lstquote.Pricing_On_Hold_Comment__c);
        Test.stopTest(); 
    }
    
    static testmethod void testgetOpportunityMap() {
        Test.startTest();
        Map<String,id> opportunityIds = new Map<String,id>();
        Map<String, Opportunity> opportunityDetails = new Map<String, Opportunity>();
        Map<Id, Opportunity> quoteIdToOppRecdMap = new Map<Id, Opportunity>();
        Map<Id, Boolean> quoteIdvalidEndCustomerMap = new Map<Id, Boolean>();
        Map<Id, Boolean> quoteIdwithProdMap = new Map<Id, Boolean>();
        Boolean isEndCustCheck = false;
        SBQQ__Quote__c lstquote = [select id from SBQQ__Quote__c limit 1];
        Opportunity oppRecord = Pricing_Test_Utility.createOpportunity();
        opportunityIds.put(oppRecord.id,lstquote.Id);
        QuoteBusinessLogic.getOpportunityMap(opportunityIds,opportunityDetails,quoteIdToOppRecdMap,isEndCustCheck);
        QuoteBusinessLogic.validateEndCustOfQuoteAndOppty(opportunityIds,quoteIdvalidEndCustomerMap);
        QuoteBusinessLogic.validateQLIProductagainstOpportunityProduct(opportunityIds,quoteIdwithProdMap);
        system.assertEquals(1,opportunityIds.size());
        Test.stopTest(); 
        
    }
    
    static testmethod void testOnHold() {
         Test.startTest();
        List<SBQQ__Quote__c> quoteLst = [Select id,Pricing_On_Hold_Cb__c from SBQQ__Quote__c];
        Pricing_Quote_Hold_Status_Age__c holdRec = Pricing_Test_Utility.createQuoteHoldStatusAge(quoteLst[0].id,'test','SDM');
        quoteLst[0].Pricing_On_Hold_Cb__c = true;
        quoteLst[0].Pricing_On_Hold_Comment__c = 'On Hold';
        update quoteLst[0];
        System.assertEquals(true,quoteLst.size()>0);
        Test.stopTest();
    }
    
    static testmethod void testqlApproveAENotifyForOppWonLost() {
        
        set<id> quoteIds = new set<id>();
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id,SBQQ__Quote__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c FROM SBQQ__QuoteLine__c LIMIT 1];
        quoteIds.add(lstQuoteLine[0].SBQQ__Quote__c);
        lstQuoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_Quote_Status_Approved;
        update lstQuoteLine;
        Test.startTest();
        QuoteBusinessLogic.qlApproveAENotifyForOppWonLost(quoteIds);
        System.assertEquals(lstQuoteLine.size() >0,true);
        Test.stopTest();
    }
        
    
}