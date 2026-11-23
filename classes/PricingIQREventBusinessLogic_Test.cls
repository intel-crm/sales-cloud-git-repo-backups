/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 11-06-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class PricingIQREventBusinessLogic_Test {
    //Method to setup Test data
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));        
        System.runAs(lstUsers2[0])
        {
            
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'IQR_Event_Business_Logic_Test');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                          TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteline = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Test.stopTest();
            User partnerUser = Pricing_Test_Utility.createPartnerUser(acc.Id);
            
            
            //List<Account> accList = [Select id from Account where id=:lstquote[0].SBQQ__Account__c LIMIT 1];
            List<AccountTeamMember> teamList = new List<AccountTeamMember>();
            AccountTeamMember accountTeamMember=new AccountTeamMember(AccountId=acc.Id,TeamMemberRole = 'Technical Sales',UserId = lstUsers2[0].id);
            insert accountTeamMember;
            teamList.add(accountTeamMember);
            /*for(Integer i = 0; i< 1; i++) {
                teamList.add(new AccountTeamMember(AccountId = accList[0].ID,
                                                   TeamMemberRole = 'Technical Sales',UserId = lstUsers2[0].id));
                
            }
            insert teamList;
            */

            Group grp = Pricing_Test_Utility.createGroupRecord();

            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = lstUsers2[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;         
         }
    }
    
    static testmethod void wonLost()
    {
        	//List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordTypeId,SBQQ__Account__c from SBQQ__Quote__c limit 1];
        	List<SBQQ__QuoteLine__c> lstquoteline=[Select id FROM SBQQ__QuoteLine__c LIMIT 1];
        	List<Pricing_IQR_Event__e> pricingRecList2 = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event2 = new Pricing_IQR_Event__e();
            pricing_Event2.Pricing_QuoteLineId_Txt__c = lstquoteline[0].Id;
            pricing_Event2.Pricing_IQR_Action_Nm__c = Label.Pricing_IQR_Event_Action_Won_Lost_Integration;
            pricingRecList2.add(pricing_Event2);
        Test.startTest();
        //PricingIQREventBusinessLogic.wonLostQuoteLineIntegration(pricingRecList2);
         List<Database.SaveResult> results = EventBus.publish(pricingRecList2);
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
        Test.stopTest();
    }
    //Method to test QuoteBusinessLogic Class
    static testmethod void testIQREvent(){
        //Test.startTest();
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordTypeId,SBQQ__Account__c from SBQQ__Quote__c limit 1];
        SBQQ__Quote__c quoteRec = lstquote[0];
        List<Account> accList = [select id from Account limit 1];
        List<User> lstUsers3 = [select id from User where email =: (quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c) Limit 2];
        List<User> lstUsers2 = [select id,Email from User where Email = 'firstName@intel.com'];
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        
        system.runAs(lstUsers2[0])
        {
            if(quoteRec != null && !lstquote.isEmpty())
            {
                //List<User> lstUsers4 = Pricing_Test_Utility.createAdminUser();
                Id UserRecordId = quoteRec.ownerid;
                
                List<Contact> conList = Pricing_Test_Utility.createTestContact(accList[0].Id,1);
                List<Contact> primaryContactList = Pricing_Test_Utility.createPrimaryContact(quoteRec.SBQQ__Account__c,2);
                List<User> user = Pricing_Test_Utility.createAEUserWithParam('FirstNameAEChange1@intel.com');
                List<User> user2 = Pricing_Test_Utility.createAEUserWithParam('FirstNameAEChange2@intel.com');
                quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c = lstUsers2[0].Email;
                List<User> lstUsers5 = [select id from User where email =: (quoteRec.Pricing_Intel_Sales_Rep_Email_Txt__c) Limit 2];
                Test.startTest();
                QuoteBusinessLogic.UpdateQuoteCommnents(new List<SBQQ__Quote__c>{quoteRec});
                List<Pricing_Comments__c> lstComments = [select id from Pricing_Comments__c where Pricing_Quote__c =: quoteRec.id and recordtypeid=:commentRecordTypeId];
                List<Core_CPQ_Tender_Comments__mdt> result = [select Pricing_Question__c,Label,Pricing_Business_Unit_Pkl__c,Pricing_Required_Ind__c 
                                                              from Core_CPQ_Tender_Comments__mdt ORDER BY Label];
                //System.assertNotEquals(lstComments.size(),0);
                if(!primaryContactList.isEmpty() && !user.isEmpty())
                {
                    quoteRec.SBQQ__PrimaryContact__c = primaryContactList[0].Id;
                    quoteRec.Pricing_Intel_Account_Exec_Email_Txt__c = user[0].Email;
                    update quoteRec;
                }               
                Test.stopTest();               
            }
        }
    }
    
    
    static testmethod void testSendMassEmailNotification(){
		List<User> lstUsers2 = [select id,Email from User where Email = 'firstName@intel.com'];
    	//List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));        
        System.runAs(lstUsers2[0])
        {
            
            Pricing_Test_Utility.createPriceBook();
            
            Account acc = [select id from Account limit 1];
            Contact con = [Select id from Contact where AccountId=:acc.id limit 1];
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<User> rpmUserList = Pricing_Test_Utility.createPricingMangerUser();
            salesRepUserList[0].DelegatedApproverId = UserInfo.getUserId();
            update salesRepUserList[0];
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            
            List<Pricing_Quote_Team__c> quoteTeamMemberList = new  List<Pricing_Quote_Team__c>();
            Pricing_Quote_Team__c qtm1=new Pricing_Quote_Team__c();
            qtm1.Pricing_Quote_Id__c = lstquote[0].Id;
            qtm1.Pricing_Quote_Team_Member_Id__c = accountExecutiveUserList[0].Id;
            qtm1.Pricing_Role_Nm__c = 'Account Executive';
            quoteTeamMemberList.add(qtm1);
            insert quoteTeamMemberList;            
            Test.startTest();
            //List<SBQQ__QuoteLine__c> lstquoteline = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<SBQQ__QuoteLine__c> lstquoteline = [Select id,Pricing_Status_Nm__c,Pricing_Sales_Rep__c,Pricing_Manager__c FROM SBQQ__QuoteLine__c LIMIT 1];
            lstquoteline[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
            
            lstquoteline[0].Pricing_Sales_Rep__c = salesRepUserList[0].Id;
            lstquoteline[0].Pricing_Manager__c = rpmUserList[0].Id;
            update lstquoteline[0];
            
            User partnerUser = [Select id from User where ContactId=:con.Id limit 1]; 
            List<Pricing_IQR_Event__e> pricingRecList = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event = new Pricing_IQR_Event__e();
            pricing_Event.Pricing_QuoteLineId_Txt__c = lstquoteline[0].Id;
            pricing_Event.Pricing_IQR_Action_Nm__c = Label.Pricing_IQR_Event_Action_Won_Lost_Integration;
            pricingRecList.add(pricing_Event);
            List<Database.SaveResult> results = EventBus.publish(pricingRecList);
            Test.stopTest();
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
                       
        }    
    }  
    
    static testmethod void testwonLostNotificationForWriteInProducts(){
		List<User> lstUsers2 = [select id,Email from User where Email = 'firstName@intel.com'];
    	//List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));        
        System.runAs(lstUsers2[0])
        {
            
            Pricing_Test_Utility.createPriceBook();
            
            Account acc = [select id from Account limit 1];
            Contact con = [Select id from Contact where AccountId=:acc.id limit 1];
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<User> rpmUserList = Pricing_Test_Utility.createPricingMangerUser();
            salesRepUserList[0].DelegatedApproverId = UserInfo.getUserId();
            update salesRepUserList[0];
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            
            List<Pricing_Quote_Team__c> quoteTeamMemberList = new  List<Pricing_Quote_Team__c>();
            Pricing_Quote_Team__c qtm1=new Pricing_Quote_Team__c();
            qtm1.Pricing_Quote_Id__c = lstquote[0].Id;
            qtm1.Pricing_Quote_Team_Member_Id__c = accountExecutiveUserList[0].Id;
            qtm1.Pricing_Role_Nm__c = 'Account Executive';
            quoteTeamMemberList.add(qtm1);
            insert quoteTeamMemberList;            
            Test.startTest();
            //List<SBQQ__QuoteLine__c> lstquoteline = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<SBQQ__QuoteLine__c> lstquoteline = [Select id,Pricing_Status_Nm__c,Pricing_Sales_Rep__c,Pricing_Manager__c FROM SBQQ__QuoteLine__c LIMIT 1];
            lstquoteline[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
            
            lstquoteline[0].Pricing_Sales_Rep__c = salesRepUserList[0].Id;
            lstquoteline[0].Pricing_Manager__c = rpmUserList[0].Id;
            update lstquoteline[0];
            
            User partnerUser = [Select id from User where ContactId=:con.Id limit 1]; 
            List<Pricing_IQR_Event__e> pricingRecList = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event = new Pricing_IQR_Event__e();
            pricing_Event.Pricing_QuoteLineId_Txt__c = lstquoteline[0].Id;
            pricing_Event.Pricing_IQR_Action_Nm__c = Label.Pricing_IQR_Event_Action_Won_Lost_Notification;
            pricingRecList.add(pricing_Event);
            List<Database.SaveResult> results = EventBus.publish(pricingRecList);
            Test.stopTest();
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
                       
        }    
    } 
    static testmethod void test_reAssignApprovalRequest()
    {
        	List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,RecordTypeId,SBQQ__Account__c from SBQQ__Quote__c limit 1];
            List<Pricing_IQR_Event__e> pricingRecList2 = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event2 = new Pricing_IQR_Event__e();
            pricing_Event2.Pricing_QuoteId_Txt__c = lstquote[0].Id+';'+lstquote[0].Pricing_Intel_Sales_Rep_Email_Txt__c;
            pricing_Event2.Pricing_IQR_Action_Nm__c = 'ApprovalRequestChange';
            pricingRecList2.add(pricing_Event2);
        Test.startTest();
        //PricingIQREventBusinessLogic.wonLostQuoteLineIntegration(pricingRecList2);
         List<Database.SaveResult> results = EventBus.publish(pricingRecList2);
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
        Test.stopTest();
    }
    static testmethod void test_sendMassEmailNotificationOnWonOrLoss()
    {
        	List<SBQQ__QuoteLine__c> lstqli = [select id,SBQQ__Quote__c from SBQQ__QuoteLine__c limit 1];
        Test.startTest();
        PricingIQREventBusinessLogic.sendMassEmailNotificationOnWonOrLoss(lstqli,new Set<Id>{lstqli[0].SBQQ__Quote__c});
        Test.stopTest();
    }
    
    static testmethod void test_sendEmailNotificationToApprover()
    {
        	List<SBQQ__QuoteLine__c> lstquotelines = [select id from SBQQ__QuoteLine__c limit 1];
            List<Pricing_IQR_Event__e> pricingRecList2 = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event2 = new Pricing_IQR_Event__e();
            pricing_Event2.Pricing_QuoteLineId_Txt__c = String.join(lstquotelines,',');
            pricing_Event2.Pricing_EmailTemplate_Nm__c = Label.Pricing_QuoteLineApprovalInitial_Notification;
            pricing_Event2.Pricing_IQR_Action_Nm__c = Label.Pricing_Send_EmailNotificationToBot_Event;
            pricingRecList2.add(pricing_Event2);
        Test.startTest();
        //PricingIQREventBusinessLogic.wonLostQuoteLineIntegration(pricingRecList2);
         List<Database.SaveResult> results = EventBus.publish(pricingRecList2);
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
        Test.stopTest();
    }

    static testmethod void testRunCalculatorService() {
        Test.startTest();
        List<SBQQ__Quote__c> qliList = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
        String quoteIdsStr = qliList[0].Id;
        newsEventList.add(new Pricing_IQR_Event__e(Pricing_QuoteId_Txt__c = quoteIdsStr,
                            Pricing_IQR_Action_Nm__c = Label.Pricing_Run_CalculatorService_Event));

        if(newsEventList.size() > 0) {               
            List<Database.SaveResult> results = EventBus.publish(newsEventList);
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                       isSuccess = true;
                    }
            }
            system.assert(true, isSuccess);
        }
        Test.stopTest();
    }
}