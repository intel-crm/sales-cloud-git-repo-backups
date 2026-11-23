@isTest(SeeAllData=false)
public class PSD_test {
     @TestSetup static void Executedata(){
                Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                // Creating User with utility class 
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.LastName = 'TestUser';
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);
                List<String> bypassFunctionKeys = new List<String>();
        
           
                bypassFunctionKeys.add('Bypass_Sharing_to_PGM');
                bypassFunctionKeys.add('Bypass_Account_Program_based_Sharing');
               
                List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
                Id caseAuditRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
                System.runAs(usr){
                    ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
                    Account intAcc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account', 
                                                                                      Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
                    intAcc1.Core_Account_Type__c = 'Reseller';
                   //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
                    intAcc1.Industry = 'Food & Beverage';
                    Database.insert(intAcc1);
                    List<Account> accList = new List<Account>();
                    Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account',cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
                        dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc1.Id;
                        accList.add(dcfAcc);
                        insert accList;
                    
                    List<Core_MDF_Partnership_Score__c> newValues = new List<Core_MDF_Partnership_Score__c>();
                        Core_MDF_Partnership_Score__c record1 = new Core_MDF_Partnership_Score__c();
                        record1.Core_MDF_Account_Id__c= intAcc1.Id;
                        record1.Core_MDF_Channel_Program_Id__c = cp.Id;
                        record1.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
                        record1.Core_MDF_Quarter_Year_Nm__c = 'Q4 2027';
                        record1.Core_MDF_Quarter_nm__c='Q4';
                        record1.Core_MDF_Year_nm__c='2027';
                        record1.Core_MDF_Zone_nm__c = 'B3';
                        record1.Core_MDF_Aggregate_Claim_Score_Nbr__c=0.0;
                        record1.Core_MDF_Partial_Value_Score_Nbr__c=2.0;
                        record1.Core_MDF_Partnership_Grade_Nbr__c=3.0;
                        record1.Core_MDF_Total_Recovery_Amt__c =22.5;
                        record1.Core_MDF_Trend_Value_Nm__c='B';
                        record1.Core_MDF_External_Id__c = String.valueOf(record1.Core_MDF_Channel_Program_Id__c)+String.valueOf(record1.Core_MDF_Account_Id__c)+String.valueOf(record1.Core_MDF_Quarter_Year_Nm__c);
                        newValues.add(record1);
                        insert newValues;
                    
                        Map<string, List<Core_MDF_Partnership_Score__c>> PSMap = new Map<string,List<Core_MDF_Partnership_Score__c>>();
                        String Key1 = record1.Core_MDF_Program_nm__c + record1.Core_MDF_Account_Id__c +record1.Core_MDF_Quarter_Year_Nm__c;
                        PSMap.put(Key1,newValues);
                    System.debug('PSMap '+PSMap);
                    
                        Case testCase= new Case();
                
                        testCase.recordtypeid = caseAuditRecordId;
                        testCase.Status = 'Open';
                        testCase.Origin = 'Manual Selection';
                        testCase.Core_MDF_Claim_ID__c = 'ClaimID';
                        testCase.AccountId = dcfAcc.Id;
                        testCase.Core_MDF_Region_SubRegion_txt__c = 'APJ-SA';
                        testCase.Core_MDF_Budget_Type_nm__c = 'MDF';
                        testCase.Core_MDF_Channel_Program_txt__c = 'Data Center Co-Marketing Fund';
                        testCase.Core_MDF_Requested_Amount_USD_Amt__c = 100;
                        testCase.ClosedDate = Date.newInstance(2027, 12, 17);
                        testCase.Core_MDF_Claim_Amount_USD__c=10;
                        testCase.Core_MDF_Status__c ='Review Completed'; 
                        
                        Database.insert(testCase);
                    
                        List<Core_MDF_Scorecard__c> newValuesSC = new List<Core_MDF_Scorecard__c>();
                        Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
                        scoreCard.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard.Core_MDF_Attribution_Nbr__c ='1';
                        scoreCard.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard.Core_MDF_Engagement_Nbr__c = '1';
                        scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_POP__c='1';
                        scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=0;
                        newValuesSC.add(scoreCard);
                   Core_MDF_Scorecard__c scoreCard2 = new Core_MDF_Scorecard__c();
                        scoreCard2.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard2.Core_MDF_Attribution_Nbr__c ='1';
                        scoreCard2.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard2.Core_MDF_Engagement_Nbr__c = '2';
                        scoreCard2.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard2.Core_MDF_POP__c='1';
                        scoreCard2.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard2.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=0;
                   newValuesSC.add(scoreCard2);
                   Core_MDF_Scorecard__c scoreCard3 = new Core_MDF_Scorecard__c();
                        scoreCard3.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard3.Core_MDF_Attribution_Nbr__c ='2';
                        scoreCard3.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard3.Core_MDF_Engagement_Nbr__c = '2';
                        scoreCard3.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard3.Core_MDF_POP__c='1';
                        scoreCard3.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard3.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=0;
                   newValuesSC.add(scoreCard3);
                   Core_MDF_Scorecard__c scoreCard4 = new Core_MDF_Scorecard__c();
                        scoreCard4.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard4.Core_MDF_Attribution_Nbr__c ='0';
                        scoreCard4.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard4.Core_MDF_Engagement_Nbr__c = '1';
                        scoreCard4.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard4.Core_MDF_POP__c='1';
                        scoreCard4.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard4.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=0;
                   newValuesSC.add(scoreCard4);
                   Core_MDF_Scorecard__c scoreCard5 = new Core_MDF_Scorecard__c();
                        scoreCard5.Core_MDF_Case_Id__c = testCase.id;
                        scoreCard5.Core_MDF_Attribution_Nbr__c ='2';
                        scoreCard5.Core_MDF_Attribution_PV_Ind__c= 'M';
                        scoreCard5.Core_MDF_Engagement_Nbr__c = '2';
                        scoreCard5.Core_MDF_Engagement_PV_Ind__c = 'M';
                        scoreCard5.Core_MDF_POP__c='2';
                        scoreCard5.Core_MDF_POP_PV_Ind__c = 'M';
                        scoreCard5.Core_MDF_Manual_Recovery_Amount_USD_Amt__c=0;
                   newValuesSC.add(scoreCard5);
                        insert newValuesSC;
                    Map<string, List<Core_MDF_Scorecard__c>> SCMap = new Map<string,List<Core_MDF_Scorecard__c>>();
                    String Key2 = testCase.Core_MDF_Channel_Program_txt__c.replace('-' , '')+intAcc1.Id+'Q4 2027'+';'+'MDF' +','+ 'APJ';
                    SCMap.put (Key2,newValuesSC);
                    
                    Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
                string keypsdetail='Data Center CoMarketing Fund'+intAcc1.id+'Q4 2027'+'MDF'+'APJ';
                psd.Core_MDF_External_ID__c='Data Center CoMarketing Fund'+intAcc1.id+'Q4 2027'+'MDF'+'APJ';
                psd.Core_MDF_Budget_Type_Nm__c= 'MDF';
                psd.Core_MDF_Region_Cd__c ='APJ';
                psd.Core_MDF_Carry_Over_Amt__c=90;
                psd.Core_MDF_Recovered_Amt__c=50;
                psd.Core_MDF_Partnership_Score_Id__c =record1.id;
                insert psd;
                    
                    //Core_MDF_PartnerShipScore_to_Detail.Executedata(newValues, 'Data Center Co-Marketing Fund', 'Q4 2027', intAcc1.Id);
                }
     }
    @isTest static void getPartnershipScoreData(){
        User sysAdminUser = [SELECT Id,Email from User where LastName='TestUser' limit 1];
        
        System.runAs(sysAdminUser) {
            
            Account Acc = [select id from Account where name = 'Test Account' limit 1];
            //List<Core_MDF_Partnership_Score__c> PS = new List<Core_MDF_Partnership_Score__c>();
            List<Core_MDF_Partnership_Score__c> PS = [Select id,Core_MDF_Account_Id__c, Core_MDF_Program_nm__c, Core_MDF_Quarter_nm__c ,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Grade_Nbr__c,Core_MDF_Zone_nm__c,Core_MDF_Channel_Program_Id__c
                                               FROM Core_MDF_Partnership_Score__c where Core_MDF_Quarter_Year_Nm__c='Q4 2027' Limit 1];
            
            List<Core_MDF_Scorecard__c> SC = [Select id,Core_MDF_Case_Id__r.AccountId, Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c,Core_MDF_Quarter__c ,Core_MDF_Score_Nbr__c,Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c
                                       ,Core_MDF_Claim_Amt__c,Core_MDF_Manual_Recovery_Amount_USD_Amt__c  FROM Core_MDF_Scorecard__c  Limit 5];
            
            List<Core_MDF_PartnerResponseZone__c> mdtLst = new List<Core_MDF_PartnerResponseZone__c>();
                        Map<string, List<Core_MDF_PartnerResponseZone__c>> res3 = new Map<string, List<Core_MDF_PartnerResponseZone__c>>();
                        Core_MDF_PartnerResponseZone__c mdt = new Core_MDF_PartnerResponseZone__c();
                        mdt.Core_MDF_Zone_Nm__c = 'B3';
                        mdt.Core_MDF_ZV_Percent_Recovery__c=100;
                        mdt.Core_MDF_PV1_Percent_Recovery__c=25;
                        mdt.Core_MDF_PV2_Percent_Recovery__c=10;
                        mdt.Core_MDF_PV4_Percent_Recovery__c=0;
                        mdtLst.add(mdt);
                        res3.put(mdt.Core_MDF_Zone_Nm__c,mdtLst);
                        assert.areEqual(mdtLst.size(),1);
            
            List<Core_MDF_Partnership_Score_Detail__c> psdrec = [select id,Core_MDF_Total_Recovery_Amt__c,Core_MDF_Carry_Over_Amt__c,Core_MDF_Balance_Amount_Amt__c,Core_MDF_Recovered_Amt__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c,Core_MDF_External_ID__c from Core_MDF_Partnership_Score_Detail__c limit 1];
            Core_MDF_PartnerShipScore_to_Detail.Executedata(PS,'Data Center Co-Marketing Fund','Q4 2027',Acc.id+'');
            
            
        
            
        }
    }
}