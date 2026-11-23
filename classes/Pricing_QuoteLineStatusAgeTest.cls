/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public class Pricing_QuoteLineStatusAgeTest {
    
    //Method to setup Test data
    @testSetup
    public static void setUpData() {
        
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Line_Status_Age_Test');
            
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
            List<SBQQ__Quote__c> quoteNewList= Pricing_Test_Utility.createQuoteWithParam(acc.Id, drLimitedConList[0].Id,1,salesRepUserList[0].Email,'');
            //SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createWINQuoteLines(quoteNewList[0].Id);
            
            //Test.stopTest();
            //The setUpData covers 54% for quote creation
        }
    }
    
    static testmethod void testQuoteLineStatusBatch() {
        Test.startTest();
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Account_Executive_Nm__c,RecordTypeId,SBQQ__Account__c,Pricing_Quote_Program_Nm__c from SBQQ__Quote__c limit 1];
        
        // Create Group
        Group grp = new Group();
        grp.name = 'Test Group22';
        grp.Type = 'Regular';
        grp.DeveloperName = 'Test_Group22';
        Insert grp;
        System.assert(grp.Id != null, 'Group should be created successfully');
        ChannelProgram chProg = [Select Id from ChannelProgram where Name=:Label.Pricing_Tender_PGM_Channel];
        
        List<Core_MDF_Partner_Group_Mapping__c> partnerGroupList = new List<Core_MDF_Partner_Group_Mapping__c>();
        Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
        partnerGroup.Core_MDF_Account__c = lstquote[0].SBQQ__Account__c;
        partnerGroup.Core_MDF_Group_Name__c = grp.DeveloperName;
        partnerGroup.Core_MDF_Type_of_Access__c = Label.Pricing_Tender_PGM_Type;
        partnerGroup.Core_MDF_Channel_Program__c=chProg.id;
        partnerGroup.Core_MDF_AccountIdGroupName__c='Group22';
        partnerGroup.Core_MDF_Group_Id__c=grp.id;
        partnerGroupList.add(partnerGroup);
        
        insert partnerGroupList;
        System.assert(partnerGroupList.size() > 0, 'Partner Group Mapping list should not be empty');
        System.assert(partnerGroupList[0].Id != null, 'Partner Group Mapping should be created successfully');
        
        SBQQ__QuoteLine__c QL2= [Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:lstquote[0].Id Limit 1];
        
        Pricing_Quote_Line_Status_Age__c ql=New Pricing_Quote_Line_Status_Age__c();
        ql.Pricing_TPT_Share_Required__c=true;
        ql.Pricing_TPT_Quote_Line_Number__c = QL2.Id;
        ql.Name='Test';
        insert ql;
        System.assert(ql.Id != null, 'Pricing_Quote_Line_Status_Age record should be created successfully');
        Test.stopTest();
    }
    
}