@isTest
public class Pricing_DataScrubBatch_Test {
    Public static PermissionSet permissionRec;
    Static{
        permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
    }
    
    //Method to setup Test data
    @testSetup
    public static void setUpData() {
        
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            
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
        }
    }
    static testmethod void dataScrubTest(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Account_Executive_Nm__c,RecordTypeId,SBQQ__Account__c,Pricing_Quote_Program_Nm__c from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c QL2= [Select Id, pricing_status_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:lstquote[0].Id Limit 1];
        system.runAs(adminUser){
            QL2.pricing_status_nm__c = 'Rejected';
            update QL2;
        }
        test.startTest();
        Database.executeBatch(New Pricing_DataScrubBatch(),200);
        test.stopTest();
    }
    static testmethod void testError(){
        Map<Id,String> errorMap = new Map<Id,String>();
        List<SBQQ__Quote__c> lstquote = [select id,SBQQ__PrimaryContact__c,ownerid,SBQQ__SalesRep__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Account_Executive_Nm__c,RecordTypeId,SBQQ__Account__c,Pricing_Quote_Program_Nm__c from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c QL2= [Select Id, Pricing_Quote_Line_Number__c, pricing_status_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:lstquote[0].Id Limit 1];
        errorMap.put(QL2.Id,'Test');
        test.startTest();
        Pricing_DataScrubBatch.createLogEntry(errorMap);
        test.stopTest();
    }
}