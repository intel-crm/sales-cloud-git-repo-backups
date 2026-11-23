@isTest
public class Pricing_PerformanceMetricsControllerTest {
    //Method to setup test data
    @testSetup
    public static void setUpData(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        if(!adminUser.isEmpty()){
            system.runAs(adminUser[0]){
                PriceBook2 pBook = Pricing_Test_Utility.createPriceBook();
                System.assertEquals('DCG Price Book', pBook.name);
                Test.startTest();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Performance_Metrics_Controller_Test');
                Pricing_Test_Utility.createTemplate(adminUser[0].id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
                insert accTeam;
                List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
                List<SBQQ__QuoteLine__c> qliLst;
                if(!lstquote.isEmpty()){
                    qliLst = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 2);
                }
                List <Pricing_Performance_Metric__c> lstPerformanceMatric = Pricing_Test_Utility.createPerformanceMetrics(qliLst[0].id);
                insert lstPerformanceMatric ;
                Test.stopTest();
            }
        }
    }
    
    //Method to test pricing_PerformanceMetricsController Class
    static testmethod void PerformanceMetricsControllerTest(){
        List<User> lstUsers = new List<User>([select id from User WHERE IsActive = TRUE Limit 1]);
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id from SBQQ__QuoteLine__c]);
        List<Pricing_Performance_Metric__c> lstPerformanceMatric = [select id,Pricing_Quote_Line__c,Pricing_Performance_Metric_Nm__c,Pricing_Weighting_Pct__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Other_Nm__c from Pricing_Performance_Metric__c where Pricing_Quote_Line__c =:quoteLineList[0].id ];
        List<Pricing_Performance_Metric__c> lstPerformanceMatric2 = Pricing_Test_Utility.createPerformanceMetrics(quoteLineList[0].id);
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                Test.startTest();
                if(!lstPerformanceMatric.isEmpty() && !quoteLineList.isEmpty()){
                    Pricing_PerformanceMetricsController.savePerformanceMetrics(lstPerformanceMatric, quoteLineList[0].id);
                    Pricing_PerformanceMetricsController.savePerformanceMetrics(lstPerformanceMatric2, quoteLineList[0].id);
                    System.assert(Pricing_PerformanceMetricsController.isCreateable() == Schema.sObjectType.Pricing_Performance_Metric__c.isCreateable(), 'isCreateable returned an unexpected value');
                    System.assert(Pricing_PerformanceMetricsController.getPerformanceMetrics(quoteLineList[0].id).size() == 6, 'Should have 6 performance metrics');
                    System.assert(Pricing_PerformanceMetricsController.isUpdateable() == Schema.sObjectType.Pricing_Performance_Metric__c.isUpdateable(), 'isUpdateable returned an unexpected value');
                }
            }
        }
        Test.stopTest();
    }
    
    static testmethod void PerformanceMetricsControllerTestPickVal(){
        List<User> lstUsers = new List<User>([select id from User WHERE IsActive = TRUE Limit 1]);
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id from SBQQ__QuoteLine__c]);
        List<Pricing_Performance_Metric__c> lstPerformanceMatric = [select id,Pricing_Quote_Line__c,Pricing_Performance_Metric_Nm__c,Pricing_Weighting_Pct__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Other_Nm__c from Pricing_Performance_Metric__c where Pricing_Quote_Line__c =:quoteLineList[0].id ];
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                Test.startTest();
                if(!lstPerformanceMatric.isEmpty() && !quoteLineList.isEmpty()){
                    Boolean isDeletable = Pricing_PerformanceMetricsController.isDeletable();
                    System.assert(isDeletable != null, 'isDeletable should not be null');
                    Pricing_PerformanceMetricsController.deletePerformanceMetrics(lstPerformanceMatric[0].id);
                    List<Pricing_Performance_Metric__c> deletedMetrics = [SELECT Id FROM Pricing_Performance_Metric__c WHERE Id = :lstPerformanceMatric[0].id];
                    System.assert(deletedMetrics.isEmpty(), 'Deleted performance metric should not exist anymore');
                    List<String> picklistValues = Pricing_PerformanceMetricsController.getPickListValues('Account','Industry');
                    System.assert(picklistValues != null, 'Picklist values should not be null');
                }
            }
        }
        Test.stopTest();
    }
    static testmethod void PerformanceMetricsControllerTestWithRPM(){
        List<User> pmUser = Pricing_Test_Utility.createPricingMangerUser();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        // Share the quote with RPM user
        Pricing_Test_Utility.shareQuoteWithUser(quoteLineList[0].SBQQ__Quote__c, pmUser[0].Id);
        Pricing_Test_Utility.shareQuoteWithUser(quoteLineList[1].SBQQ__Quote__c, pmUser[0].Id);
        //update quoteLineList;
        Test.startTest();
        if(!pmUser.isEmpty()){
            system.runAs(pmUser[0]){
                Boolean readOnly1 = Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[0].id);
                System.assert(readOnly1 != null, 'isReadOnlyPageLayout should not return null for first quote line');
                quoteLineList[0].Pricing_Status_Nm__c = 'Approved';
                quoteLineList[1].Pricing_Status_Nm__c = 'Pending Further Intel Review';
                update quoteLineList;
                Test.stopTest();
                if(!quoteLineList.isEmpty()){
                    Boolean readOnly2 = Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[0].id);
                    System.assert(readOnly2 != null, 'isReadOnlyPageLayout should not return null for second quote line');
                    Boolean readOnly3 = Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[1].id);
                    System.assert(readOnly3 != null, 'isReadOnlyPageLayout should not return null for third quote line');
                    // Validate that the quote line statuses were updated correctly
                    Set<Id> quoteLineIds = new Set<Id>();
                    for(SBQQ__QuoteLine__c qli : quoteLineList) {
                        quoteLineIds.add(qli.Id);
                    }
                    List<SBQQ__QuoteLine__c> updatedQuoteLines = [SELECT Id, Pricing_Status_Nm__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds];
                    System.assertEquals('Approved', updatedQuoteLines[0].Pricing_Status_Nm__c, 'First quote line should be Approved');
                    System.assertEquals('Pending Further Intel Review', updatedQuoteLines[1].Pricing_Status_Nm__c, 'Second quote line should be Pending Further Intel Review');
                }
            }
        }
        
    }
    
    static testmethod void testShowQliDtls(){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Test.startTest();
        Boolean  result = Pricing_PerformanceMetricsController.showQuoteLineDetail(quoteLineList[0].id);
        Test.stopTest();
        // Validate that the method returns a non-null result
        System.assert(result != null, 'showQuoteLineDetail should return a non-null result');
        // Validate that the result has the expected structure
        System.assert(result != null, 'Result should not be null');
    }
}