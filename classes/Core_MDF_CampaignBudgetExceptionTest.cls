/*
 * Apex Class Name - Core_MDF_CampaignBudgetException
 * Test Class Name - Core_MDF_CampaignBudgetExceptionTest
 */
@isTest(seeAlldata=false)
private class Core_MDF_CampaignBudgetExceptionTest {
    @isTest
    private static void getMessageTest() {
        Core_MDF_CampaignBudgetException exp = new Core_MDF_CampaignBudgetException();
        exp.getMessage();
    }
}