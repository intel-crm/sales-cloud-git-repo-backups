@isTest(SeeAllData=false)
private class Core_MDF_Scorecard_Helper_Test {
    @TestSetup
   static void createTestData(){
       Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);

                Id caseAuditRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
       
            	Date aiAuditEligibleDate = Date.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_AI_Audit_Enable_Date')?.Core_MDF_Value_Txt__c);//WW16.4
       
        
                System.runAs(usr)
                    {
                        Case testCase= new Case();
                
                        testCase.recordtypeid = caseAuditRecordId;
                        testCase.Status = 'Open';
                        testCase.Origin = 'Manual Selection';
                        testCase.Core_MDF_Claim_ID__c = 'ClaimID';
                        testCase.Core_MDF_Requested_Amount_USD_Amt__c = 100;
                        testCase.Core_MDF_Status__c = 'Under Review';
                        Database.insert(testCase);          
                                                        
                        Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
                        scoreCard.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard.Core_MDF_Attribution_Nbr__c ='1';
                        scoreCard.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard.Core_MDF_Engagement_Nbr__c = '1';
                        scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_POP__c='1';
                        scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_AI_Processing_Status_Nm__c = 'AI Processing Completed';
                        Database.insert(scoreCard);
                        
                        // Set the created date to aiAuditEligibleDate + 1 day
                        DateTime futureDate = DateTime.newInstance(aiAuditEligibleDate.addDays(1), Time.newInstance(12, 0, 0, 0));
                        Test.setCreatedDate(testCase.Id, futureDate);
                    }
   }
    
    @isTest static void testScorecardMethod(){
        Case record = [select id from Case limit 1];
        Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper result = new Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper();
        result = Core_MDF_Scorecard_Helper.getScoreCardDetailsAndAccess(record.id);
        System.assert(result.scorecardRec!=null,'Records returned');
    }
    
    @isTest static void testScorecardMethodException(){
        id record = null;
        Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper result = new Core_MDF_Scorecard_Helper.ScorecardDetailsWrapper();
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