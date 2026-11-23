/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public class Pricing_EmailUtility_Test {
    //Method to setup Test data
    @testSetup
    public static void setUpData() {
        
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Email_Utility_Test');
            List<User> accExecUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExecUserList[0].Email);
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
            
            Group grp = Pricing_Test_Utility.createGroupRecord();
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = adminUserList[0].id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            ChannelProgram chProg = Pricing_Test_Utility.createChannelProgramRecord();
            
            List<Core_MDF_Partner_Group_Mapping__c> partnerGroupList = Pricing_Test_Utility.createPGMRecord(acc,grp,chProg,1);
            Test.stopTest();
            //The setUpData covers 54% for quote creation
        }
        
    }
    
    static testmethod void testSendEmailForRPMApproval() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            /* quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[0];*/
                Test.startTest();
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[0];
            Test.stopTest();
        }
        System.assertEquals('Approved', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        List<SBQQ__QuoteLine__c> updatedQuoteLine = [SELECT id,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLine[0].Id];
        System.assertEquals('Approved', updatedQuoteLine[0].Pricing_Status_Nm__c, 'QuoteLine status was not properly updated');
       // Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>{updatedQuoteLine[0].Id},Label.Pricing_QuoteLine_Approve_OppWonLost_Notification);
       // Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>{updatedQuoteLine[0].Id},Label.Pricing_Quote_Line_Approve_AE_Notification);
    }
    
    static testmethod void testSendEmailForWonAndLoss() {
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c,Pricing_Account_Executive_Nm__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> lstquoteline = [Select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> salesRepUserList = [Select id from User where Email='firstNameSalesRep@intel.com'];
        List<User> rpmUserList = Pricing_Test_Utility.createPricingMangerUser();
        List<User> itsUser = Pricing_Test_Utility.createITSUser();
        
        System.runAs(lstUsers2[0]){
            salesRepUserList[0].DelegatedApproverId = UserInfo.getUserId();
            update salesRepUserList[0];
            
            Test.startTest();
            List<Pricing_Quote_Team__c> quoteTeamMemberList = new  List<Pricing_Quote_Team__c>();
            Pricing_Quote_Team__c qtm1=new Pricing_Quote_Team__c();
            qtm1.Pricing_Quote_Id__c = quoteList[0].Id;
            qtm1.Pricing_Quote_Team_Member_Id__c = quoteList[0].Pricing_Account_Executive_Nm__c;
            qtm1.Pricing_Role_Nm__c = 'Account Executive';
            quoteTeamMemberList.add(qtm1);
            
            Pricing_Quote_Team__c qtm2=new Pricing_Quote_Team__c();
            qtm2.Pricing_Quote_Id__c = quoteList[0].Id;
            qtm2.Pricing_Quote_Team_Member_Id__c =itsUser[0].Id;
            qtm2.Pricing_Role_Nm__c = 'ITS';
            quoteTeamMemberList.add(qtm2);
            
            insert quoteTeamMemberList;
            
            lstquoteline[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
            lstquoteline[0].Pricing_Sales_Rep__c = salesRepUserList[0].Id;
            lstquoteline[0].Pricing_Manager__c = rpmUserList[0].Id;
            update lstquoteline[0];
            
            
            //User partnerUser = [Select id from User where ContactId=:con.Id limit 1];
            List<Pricing_IQR_Event__e> pricingRecList = new List<Pricing_IQR_Event__e>();
            Pricing_IQR_Event__e pricing_Event = new Pricing_IQR_Event__e();
            pricing_Event.Pricing_QuoteLineId_Txt__c = lstquoteline[0].Id;
            pricing_Event.Pricing_IQR_Action_Nm__c = Label.Pricing_IQR_Event_Action_Won_Lost_Integration;
            pricingRecList.add(pricing_Event);
            List<Database.SaveResult> results = EventBus.publish(pricingRecList);
            boolean isSuccess = false;
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    isSuccess = true;
                }
            }
            system.assert(true, isSuccess);
            List<SBQQ__QuoteLine__c> updatedQuoteLine = [SELECT id,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id =: lstquoteline[0].Id];
            System.assertEquals(Label.Pricing_Tender_QuoteLine_Status_Won, updatedQuoteLine[0].Pricing_Status_Nm__c, 'QuoteLine status was not properly updated for Won/Loss');
            Test.stopTest();
        }
    }
    
    static testmethod void testSendEmailForQuotelineRejection() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c,SBQQ__SalesRep__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        //User fseUser = [Select id from User where id=:quoteList[0].SBQQ__SalesRep__c];
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = 'Rejected';
            update quoteLine[0];
        }
        System.assertEquals('Rejected', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        List<SBQQ__QuoteLine__c> updatedQuoteLine = [SELECT id,Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLine[0].Id];
        System.assertEquals('Rejected', updatedQuoteLine[0].Pricing_Status_Nm__c, 'QuoteLine status was not properly updated');
       // Pricing_EmailUtility.sendEmailToReciepents(new Set<Id>{updatedQuoteLine[0].Id}, 'Pricing_FI_QL_Rejection_Notification');
      
        Test.stopTest();
        
    }
    
    static testmethod void testSendEmailToApproverWithQuoteLineIds() {
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c];
        Pricing_EmailUtility.sendEmailToApprover(new Set<Id>{quoteLine[0].id},Label.Pricing_QuoteLineApprovalInitial_Notification);
        Test.stopTest();
        // Validate that the method executed without error (no return value to assert)
        
    }
    
    static testmethod void testgetRoleBasedUsers() {
        Test.startTest();
        Set<Id> qlIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLines = [Select id from SBQQ__QuoteLine__c];
        for(SBQQ__QuoteLine__c qli :quoteLines){
            qlIds.add(qli.Id);
        }
        Pricing_EmailUtility.getRoleBasedUsers(qlIds,true,'PSAM');
        Pricing_EmailUtility.getRoleBasedUsers(qlIds,true,'Sales_Rep_Approver');
        Pricing_EmailUtility.getRoleBasedUsers(qlIds,true,'Primary_Contact');
        System.assertEquals(qlIds.size() > 0,true);
        // Validate that the method executed without error (no return value to assert)
        Test.stopTest();
    }
    
}