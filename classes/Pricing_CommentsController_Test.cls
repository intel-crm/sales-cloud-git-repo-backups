@isTest
Private class Pricing_CommentsController_Test {
    
    @testSetup
    public static void setUpData(){
        List<User> adminUser = new List<User>(Pricing_Test_Utility.createAdminUser());
        List<User> userFSE = new List<User>(Pricing_Test_Utility.createFSEUser());
        Account acc;
        Contact con;
        List<User> accountExecutiveUserList;
        List<User> salesRepUserList;
        if(!adminUser.isEmpty()){
            system.runAs(adminUser[0]){
                /*PriceBook2 pBook=Pricing_Test_Utility.createPriceBook();
                acc = Pricing_Test_Utility.createAccount();
                con = Pricing_Test_Utility.createContact(acc.Id);*/
                
                Pricing_Test_Utility.createPriceBook();
                acc = Pricing_Test_Utility.createAccount();
                con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Comments_Controller_Test');
                Pricing_Test_Utility.createTemplate(adminUser[0].id);
                accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                                  TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
                insert accTeam;
            }
        }
        if(!userFSE.isEmpty()){
            system.runAs(userFSE[0]){
                //Pricing_Test_Utility.createQuote(acc.Id, con.Id, 3);
                List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            }
        }
    }   
    
    static testmethod void getTenderCommentsTest(){
        Test.startTest();
        
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c LIMIT 1]);
        List<Pricing_Comments__c> tenderComment;
        if(!lstquote.isEmpty()){
            tenderComment = Pricing_CommentsController.getTenderComments(lstquote[0].id);
            Pricing_CommentsController.getQuoteStatus(lstquote[0].id);
        }
        if(!tenderComment.isEmpty()){
            tenderComment[0].Pricing_Answer__c = 'Test Class Answer';
            tenderComment[0].Pricing_Question__c = 'Test Class question';
        }
        Pricing_CommentsController.updateTenderComments(tenderComment);
        List<Pricing_Comments__c> tenderComment2 = [SELECT id,Pricing_Question__c, Pricing_Answer__c  from Pricing_Comments__c where Pricing_Quote__c=:lstquote[0].id
                                                    and Pricing_Question__c ='Test Class question' and recordtypeid=:commentRecordTypeId];
        try {
            List<Pricing_Comments__c> emptyCommentsObject ;
            Pricing_CommentsController.updateTenderComments(emptyCommentsObject);
        }catch(Exception e){
            System.Assert(e.getMessage()!= '', 'Exception thrown didnt occur when updating an existant comment');
        }
        System.AssertEquals(tenderComment2[0].Pricing_Answer__c , 'Test Class Answer', 'Update of Comments not working');            
        Test.stopTest();
    }
    
    // Unit test PM comment create and get methods in one go
    static testmethod void createTenderCommentsTest(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c LIMIT 1]);
        if(!lstquote.isEmpty()){
            try{
                Pricing_CommentsController.createTenderComments('Comments entered by Pricing Manager', lstquote[0].Id);
            }catch(Exception e){
                System.Assert(e.getMessage()!= '', 'Exception thrown didnt occur when updating an existant comment');
            }
            List<Pricing_Comments__c> pmComments = Pricing_CommentsController.getPricingManagerComments(lstquote[0].Id);
            Test.stopTest();
            if(!pmComments.isEmpty()){
                System.AssertEquals(pmComments[0].Pricing_Answer__c,'Comments entered by Pricing Manager','Pricing manager comments update not working');
            }
        }
    }    
    
    static testmethod void isPricingManagerTest(){
        Test.startTest();
        List<User> fseUser = new List<User>([select id from User where isActive = true LIMIT 1]);
        if(!fseUser.isEmpty()){
            System.runAs(fseUser[0]){
                System.Assert(!Pricing_CommentsController.isPricingManager(), 'Is pricing manager returing a wrong value');
            }
        }
        Test.stopTest();        
    }

    static testmethod void isFinancialIncentivePricingManagerTest(){
        Test.startTest();
        List<User> fseUser = new List<User>([select id from User where isActive = true LIMIT 1]);
        if(!fseUser.isEmpty()){
            System.runAs(fseUser[0]){
                System.Assert(!Pricing_CommentsController.isFinancialIncentivePricingManager(), 'Is Financial Incentive pricing manager returing a wrong value');
            }
        }
        Test.stopTest();        
    }
    
    static testmethod void isReadOnlyUserTest(){
        Test.startTest();
        List<User> fseUser = new List<User>([select id from User where isActive = true LIMIT 1]);
        if(!fseUser.isEmpty()){
            System.runAs(fseUser[0]){
                System.Assert(!Pricing_CommentsController.isReadOnlyUser(), 'Is readonly user returing a wrong value');
            }
        }
        Test.stopTest();        
    }
    
    static testmethod void getDocumentShare_test(){
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select id from SBQQ__Quote__c LIMIT 1]);
        Pricing_Document__c pc = new Pricing_Document__c(Pricing_Quote_Id__c = lstquote[0].Id);
        insert pc;
        Pricing_CommentsController.DocumentShare docShare = Pricing_CommentsController.getDocumentShare(lstquote[0].Id);
        system.assert(docShare!=null);        
        Test.stopTest();
    }

    static testmethod void getAccountIdCommentsMapping_test(){
        List<SBQQ__Quote__c> lstquote = new List<SBQQ__Quote__c>([select Id, SBQQ__Account__c from SBQQ__Quote__c LIMIT 1]);
        Test.startTest();
        Pricing_AccountId_Comments_Mapping__c accMaping = Pricing_CommentsController.getAccountIdCommentsMapping(lstquote[0].SBQQ__Account__c);
        system.assert(accMaping==null);        
        Test.stopTest();
    }
    
    static testMethod void isPAAEligibleTest(){        
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>([select Id, SBQQ__Account__c from SBQQ__Quote__c LIMIT 1]);
        List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
        SBQQ__QuoteLine__C quoteLine = lstquoteLines[0];
        Pricing_CommentsController.isPAAEligible(quoteLine);
        Test.stopTest(); 
     }
    
}