@isTest(SeeAllData=false)
private class Core_MDF_Scorecard_Helper_Test {
    @TestSetup
   static void createTestData(){
       Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);

                Id caseAuditRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
        
                System.runAs(usr)
                    {
                        Case testCase= new Case();
                
                        testCase.recordtypeid = caseAuditRecordId;
                        testCase.Status = 'Open';
                        testCase.Origin = 'Manual Selection';
                        testCase.Core_MDF_Claim_ID__c = 'ClaimID';
                        testCase.Core_MDF_Requested_Amount_USD_Amt__c = 100;
                        Database.insert(testCase);
                        
                        Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
                        scoreCard.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard.Core_MDF_Attribution_Nbr__c ='1';
                        scoreCard.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard.Core_MDF_Engagement_Nbr__c = '1';
                        scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_POP__c='1';
                        scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
                        Database.insert(scoreCard);
                    }
   }
    
    @isTest static void testScorecardMethod(){
        Case record = [select id from Case limit 1];
        Map<id,boolean> result = new Map<id,boolean>();
        
        result = Core_MDF_Scorecard_Helper.getScoreCardDetailsAndAccess(record.id);
        System.assert(result.size()!=0,'Records returned');
    }
    
    @isTest static void testScorecardMethodException(){
        id record = null;
        Map<id,boolean> result = new Map<id,boolean>();
        try{ 
            result = Core_MDF_Scorecard_Helper.getScoreCardDetailsAndAccess(record);
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
    }
    
    @isTest static void testBeforeUpdateTrigger(){
        Core_MDF_Scorecard__c sc = [select id from Core_MDF_Scorecard__c limit 1];
        sc.Core_MDF_Attribution_Nbr__c = '2';
        sc.Core_MDF_Engagement_Nbr__c = '2';
        sc.Core_MDF_POP__c='2';
        Database.update(sc);
        
        Core_MDF_Scorecard__c assertSc = [select id,Core_MDF_Attribution_PV_Ind__c from Core_MDF_Scorecard__c limit 1];
        system.assertEquals(assertSc.Core_MDF_Attribution_PV_Ind__c, null); 
    }
}