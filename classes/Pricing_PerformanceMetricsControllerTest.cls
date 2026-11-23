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
                Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Performance_Metrics_Controller_test');
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
        List<User> lstUsers = new List<User>([select id from User Limit 10]);
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id from SBQQ__QuoteLine__c]);
        List<Pricing_Performance_Metric__c> lstPerformanceMatric = [select id,Pricing_Quote_Line__c,Pricing_Performance_Metric_Nm__c,Pricing_Weighting_Pct__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Other_Nm__c from Pricing_Performance_Metric__c where Pricing_Quote_Line__c =:quoteLineList[0].id ];
        List<Pricing_Performance_Metric__c> lstPerformanceMatric2 = Pricing_Test_Utility.createPerformanceMetrics(quoteLineList[0].id);
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                Test.startTest();
                if(!lstPerformanceMatric.isEmpty() && !quoteLineList.isEmpty()){
                    Pricing_PerformanceMetricsController.savePerformanceMetrics(lstPerformanceMatric, quoteLineList[0].id);
                    Pricing_PerformanceMetricsController.savePerformanceMetrics(lstPerformanceMatric2, quoteLineList[0].id);
                    System.assertEquals(Pricing_PerformanceMetricsController.isCreateable(),true);
                    System.assertEquals((Pricing_PerformanceMetricsController.getPerformanceMetrics(quoteLineList[0].id)).size(),6);
                    System.assertEquals(Pricing_PerformanceMetricsController.isUpdateable(),true);
                    System.assertEquals(Pricing_PerformanceMetricsController.isUpdateable(),true);
                }
            }
        }
        Test.stopTest();
    } 
    
    static testmethod void PerformanceMetricsControllerTestPickVal(){
        List<User> lstUsers = new List<User>([select id from User Limit 10]);
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id from SBQQ__QuoteLine__c]);
        List<Pricing_Performance_Metric__c> lstPerformanceMatric = [select id,Pricing_Quote_Line__c,Pricing_Performance_Metric_Nm__c,Pricing_Weighting_Pct__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Other_Nm__c from Pricing_Performance_Metric__c where Pricing_Quote_Line__c =:quoteLineList[0].id ];
        if(!lstUsers.isEmpty()){
            system.runAs(lstUsers[0]){
                Test.startTest();
                if(!lstPerformanceMatric.isEmpty() && !quoteLineList.isEmpty()){
                    Pricing_PerformanceMetricsController.isDeletable();   
                    Pricing_PerformanceMetricsController.deletePerformanceMetrics(lstPerformanceMatric[0].id);                    
                    Pricing_PerformanceMetricsController.getPickListValues('Account','Industry');
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
                Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[0].id);
                quoteLineList[0].Pricing_Status_Nm__c = 'Approved';
                quoteLineList[1].Pricing_Status_Nm__c = 'Pending Further Intel Review';
        		update quoteLineList;
                Test.stopTest();
                if(!quoteLineList.isEmpty()){
                    Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[0].id);
                    Pricing_PerformanceMetricsController.isReadOnlyPageLayout(quoteLineList[1].id);
                }
            }
        }
        
    } 
    
    static testmethod void testShowQliDtls(){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>([select id,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
    Test.startTest();
        Pricing_PerformanceMetricsController.showQuoteLineDetail(quoteLineList[0].id);
    Test.stopTest();
    } 
}