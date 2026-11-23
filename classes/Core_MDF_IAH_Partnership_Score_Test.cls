/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_IAH_Partnership_Score_Test 
* Version     : 1.0 
* Created Date: 03-08-2022
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Navneet Kaur 		03-08-2022					  Test class for all methods in Core_MDF_IAH_Partnership_Score
*************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_IAH_Partnership_Score_Test {
     @isTest static void testCallHttp() {            
               Test.setMock(HttpCalloutMock.class, new Core_MDF_IAH_ResponseMockHttpResponse());
               Account intelAccount = [select Id from Account WHERE Name = 'Test Acc New tt' LIMIT 1];
               String accountId = intelAccount.Id+'';
               Test.startTest();
               Core_MDF_IAH_Partnership_Score.callHttp(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Q2 2022',accountId);
               Core_MDF_IAH_Partnership_Score.callHttp('','Q2 2022','');
               Core_MDF_IAH_Partnership_Score.callHttp(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Q2 2022','');
              // Core_MDF_IAH_Partnership_Score.getValuesforforCarryFwd('');
               Test.stopTest();
               //Core_MDF_IAH_Partnership_Score.Core_MDF_Scheduler_IAH_Partnership_Score();
               System.assert(true,Core_MDF_IAH_Partnership_Score.isError);
               Core_MDF_IAH_Partnership_Score.Core_MDF_Scheduler_IAH_Partnership_Score_Retry();
              
           }
    
     	@isTest static void trackres()
        {
            HTTPResponse resfromlink = new HTTPResponse();
            resfromlink.setBody('{"name":"RecoveryAmount","elements":[{"account_id":"0011J00001AIz9jQAD","manual_recovery_amt":5.0,"program_id":"0Pk1J000000CaSZSA0","mview_ts":"20220228055217","recovery_amt":22.5,"quarter_nm":"Q1 2022","zone_nm":"B4","aggregate_claim_score_nbr":0.0,"trend_difference_score_nbr":0.0,"partial_value_score_nbr":null,"partnership_grade_nbr":null,"partnership_score_nbr":0.0,"trend_nm":"B4"}],"links":[{"rel":"self","href":"https://edvp-dev.intel.com/server/finance/RecoveryAmount/views/RecoveryAmount?quarter_nm=Q1+2022&$format=json"},{"rel":"prev","title":"Previous interval","href":"?quarter_nm=Q1+2022&$format=json&$count=2"},{"rel":"next","title":"Next interval","href":"?quarter_nm=Q1+2022&$format=json&$start_index=4&$count=2"}]}');
			string result = Core_MDF_IAH_Partnership_Score.track_resp(resfromlink);
            Assert.isNotNull(result);
        }
   	   /* @isTest static void testParseJSONoutput()
           {
                HTTPResponse res1 = new HTTPResponse();
                HTTPResponse res2 = new HTTPResponse();
                HTTPResponse res3 = new HTTPResponse();
               	List<Core_MDF_IAH_Partnership_Score.Elements> newValues = new List<Core_MDF_IAH_Partnership_Score.Elements>();
               	res1.setBody('{"name":"RecoveryAmount","elements":[{"account_id":"0011J00001AIz9jQAD","manual_recovery_amt":5.0,"program_id":"0Pk1J000000CaSZSA0","mview_ts":"20220228055217","recovery_amt":22.5,"quarter_nm":"Q1 2022","zone_nm":"B4","aggregate_claim_score_nbr":0.0,"trend_difference_score_nbr":0.0,"partial_value_score_nbr":null,"partnership_grade_nbr":null,"partnership_score_nbr":0.0,"trend_nm":"B4"}],"links":[{"rel":"self","href":"https://edvp-dev.intel.com/server/finance/RecoveryAmount/views/RecoveryAmount?quarter_nm=Q1+2022&$format=json"}]}');
               	res2.setBody('[{""}]');
               	res3.setBody('[{""account_id":"001o000000O6IBjAAN","manual_recovery_amt":9.0,"program_id":"0Pk1J000000CaSZSA0""}]');
                Map<string, List<Core_MDF_Partnership_Score__c>> pscarryfwdMap = new Map<string, List<Core_MDF_Partnership_Score__c>>();
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res1);
               
                
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res2);
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res3);
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res1));
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res2));
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res3));
           }*/

     @TestSetup static void createTestData()
            {
                  ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        		  ChannelProgram dcfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
				    Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New tt', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
                Database.insert(intelAccount);
                List<Account> acctList = new List<Account>();
                Account acc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 1', ccfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
                acc1.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
                acctList.add(acc1);
                Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', dcfCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
                acc2.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
                acctList.add(acc2);
                Database.insert(acctList);
                Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                // Creating User with utility class 
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);
                List<String> bypassFunctionKeys = new List<String>();
                bypassFunctionKeys.add('Core_MDF_Bypass_Sharing_to_PGM');
                bypassFunctionKeys.add('Core_MDF_BypassAccPgm_Sharing');
                bypassFunctionKeys.add('Bypass_ValidatePartnerScoreforUpdate');
                bypassFunctionKeys.add('Bypass_PopulateandValidateExternalId');	
                List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
               
                 System.runAs(usr)
                    {
                        Map<Id,string> programIdToLabelMap = new Map<Id,string>();
                        for(Core_MDF_ChannelProgram__mdt channelProgram : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Program_ID__c FROM Core_MDF_ChannelProgram__mdt limit 10]){//ATHR Fix - WW16
                		programIdToLabelMap.put(channelProgram.Core_MDF_Program_ID__c, channelProgram.Core_MDF_Technical_Program_Name__c);
            			}
                        List<Core_MDF_Partnership_Score__c> newValues = new List<Core_MDF_Partnership_Score__c>();
                        Core_MDF_Partnership_Score__c record1 = new Core_MDF_Partnership_Score__c();
                        record1.Core_MDF_Account_Id__c= intelAccount.id;
                        record1.Core_MDF_Channel_Program_Id__c = ccfCP.id;
                        record1.Core_MDF_Program_nm__c = programIdToLabelMap.get(String.valueOf(record1.Core_MDF_Channel_Program_Id__c).substring(0, 15));
                        record1.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
                        record1.Core_MDF_Quarter_nm__c='Q1';
                        record1.Core_MDF_Year_nm__c='2022';
                        record1.Core_MDF_Zone_nm__c = 'B4';
                        record1.Core_MDF_Aggregate_Claim_Score_Nbr__c=0.0;
                    	record1.Core_MDF_Partial_Value_Score_Nbr__c=2.0;
                        record1.Core_MDF_Partnership_Grade_Nbr__c=3.0;
                        record1.Core_MDF_Partnership_Score_Nbr__c=0.0;
                        record1.Core_MDF_Trend_Value_Nm__c='B';
                        record1.Core_MDF_External_Id__c = String.valueOf(record1.Core_MDF_Channel_Program_Id__c)+String.valueOf(record1.Core_MDF_Account_Id__c)+String.valueOf(record1.Core_MDF_Quarter_Year_Nm__c);
                        newValues.add(record1);
                        
                        Core_MDF_Partnership_Score__c record2 = new Core_MDF_Partnership_Score__c();
                        record2.Core_MDF_Account_Id__c= intelAccount.id;
                        record2.Core_MDF_Channel_Program_Id__c = dcfCP.id;
                        record2.Core_MDF_Program_nm__c =programIdToLabelMap.get(String.valueOf(record2.Core_MDF_Channel_Program_Id__c).substring(0, 15));
                        record2.Core_MDF_Quarter_Year_Nm__c = 'Q4 2022';
                        record2.Core_MDF_Quarter_nm__c='Q4';
                        record2.Core_MDF_Year_nm__c='2022';
                        record2.Core_MDF_Zone_nm__c = 'B4';
                        record2.Core_MDF_Aggregate_Claim_Score_Nbr__c=0.0;
                    	record2.Core_MDF_Partial_Value_Score_Nbr__c=2.0;
                        record2.Core_MDF_Partnership_Grade_Nbr__c=2.0;
                        record2.Core_MDF_Partnership_Score_Nbr__c=0.0;
                        record2.Core_MDF_Trend_Value_Nm__c='B';//trend_nm from IAH B4//take the first string
                        record2.Core_MDF_External_Id__c = String.valueOf(record2.Core_MDF_Channel_Program_Id__c)+String.valueOf(record2.Core_MDF_Account_Id__c)+String.valueOf(record2.Core_MDF_Quarter_Year_Nm__c);
                        newValues.add(record2);
                        database.insert(newValues);
                        List<Core_MDF_Partnership_Score__c> newValues2 = new List<Core_MDF_Partnership_Score__c>();
                        Core_MDF_Partnership_Score__c record3 = new Core_MDF_Partnership_Score__c();
                        record3.Core_MDF_Account_Id__c= intelAccount.id;
                        record3.Core_MDF_Channel_Program_Id__c = dcfCP.id;
                        record3.Core_MDF_Program_nm__c =programIdToLabelMap.get(String.valueOf(record2.Core_MDF_Channel_Program_Id__c).substring(0, 15));
                        record3.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
                        record3.Core_MDF_Quarter_nm__c='Q1';
                        record3.Core_MDF_Year_nm__c='2022';
                        record3.Core_MDF_Zone_nm__c = 'B4';
                        record3.Core_MDF_Aggregate_Claim_Score_Nbr__c=0.0;
                    	record3.Core_MDF_Partial_Value_Score_Nbr__c=2.0;
                        record3.Core_MDF_Partnership_Grade_Nbr__c=2.0;
                        record3.Core_MDF_Partnership_Score_Nbr__c=0.0;
                        record3.Core_MDF_Trend_Value_Nm__c='B';//trend_nm from IAH B4//take the first string
                        record3.Core_MDF_External_Id__c = String.valueOf(record3.Core_MDF_Channel_Program_Id__c)+String.valueOf(record3.Core_MDF_Account_Id__c)+String.valueOf(record3.Core_MDF_Quarter_Year_Nm__c);
                        newValues2.add(record3);
                        database.insert(newValues2);
                        
                         Core_MDF_IAH_Partnership_Score.insertCurrQuarterData('Q2 2022');
                        // Highlight: Unused Local Variable - Indira
                       // List<Core_MDF_Partnership_Score__c> ps = [Select Id, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Account_Id__c, Core_MDF_Partnership_Score_Id__c From Core_MDF_Partnership_Score__c Where Core_MDF_Quarter_Year_Nm__c='Q2 2022'];
                        HTTPResponse res1 = new HTTPResponse();
                HTTPResponse res2 = new HTTPResponse();
                HTTPResponse res3 = new HTTPResponse();
               	List<Core_MDF_IAH_Partnership_Score.Elements> newValues3 = new List<Core_MDF_IAH_Partnership_Score.Elements>();
                        
                Core_MDF_IAH_Partnership_Score.Elements elem = new Core_MDF_IAH_Partnership_Score.Elements();
                elem.account_id = '0011J000017etLdQAI';
                elem.manual_recovery_amt = 10;
                elem.program_id = '0Pk1J000000CaSZSA0';
                elem.mview_ts = '20221109023457';
                elem.recovery_amt = 100;
                elem.quarter_nm = 'Q1 2025';
                elem.zone_nm = 'B4';
                elem.aggregate_claim_score_nbr = 5;
                elem.trend_difference_score_nbr = 2;
                elem.partial_value_score_nbr = 3;
                elem.partnership_grade_nbr = 4;
                elem.partnership_score_nbr = 90;
                elem.trend_nm = 'B';
                elem.total_recovery_amt = 120;
                newValues3.add(elem);
                        
               	res1.setBody('{"name":"RecoveryAmount","elements":[{"account_id":"0011J00001AIz9jQAD","manual_recovery_amt":5.0,"program_id":"0Pk1J000000CaSZSA0","mview_ts":"20220228055217","recovery_amt":22.5,"quarter_nm":"Q1 2022","zone_nm":"B4","aggregate_claim_score_nbr":0.0,"trend_difference_score_nbr":0.0,"partial_value_score_nbr":null,"partnership_grade_nbr":null,"partnership_score_nbr":0.0,"trend_nm":"B4"}],"links":[{"rel":"self","href":"https://edvp-dev.intel.com/server/finance/RecoveryAmount/views/RecoveryAmount?quarter_nm=Q1+2022&$format=json"}]}');
               	res2.setBody('[{""}]');
               	res3.setBody('[{""account_id":"001o000000O6IBjAAN","manual_recovery_amt":9.0,"program_id":"0Pk1J000000CaSZSA0""}]');
                Map<string, List<Core_MDF_Partnership_Score__c>> pscarryfwdMap = new Map<string, List<Core_MDF_Partnership_Score__c>>();
                        pscarryfwdMap = Core_MDF_IAH_Partnership_Score.getValuesforforCarryFwd('Q4 2021');
                        pscarryfwdMap.put(record3.Core_MDF_External_Id__c,newValues2);
                Map<Id,Map<Id,Id>> intelAccountIdToProgramToVirtualCorpAccountId = Core_MDF_IAH_Partnership_Score.getVirtualCorpAccount(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, acc1.Id);
                Core_MDF_IAH_Partnership_Score.parseJSONoutput(res1,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId);
                Core_MDF_IAH_Partnership_Score.parseJSONoutput(res2,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId);
                Core_MDF_IAH_Partnership_Score.parseJSONoutput(res3,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId);
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res1,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId));
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res2,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId));
                System.assert(true, Core_MDF_IAH_Partnership_Score.parseJSONoutput(res3,pscarryfwdMap,intelAccountIdToProgramToVirtualCorpAccountId));
            }
            }
 public class Core_MDF_IAH_ResponseMockHttpResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"name":"RecoveryAmount","elements":[{"account_id":"0011J000017etLdQAI","manual_recovery_amt":0,"program_id":"0Pk3b000000GnLUCA0","mview_ts":"20221109023457","recovery_amt":0,"quarter_nm":"Q1 2022","zone_nm":"B4","aggregate_claim_score_nbr":0,"trend_difference_score_nbr":0,"partial_value_score_nbr":0,"partnership_grade_nbr":null,"partnership_score_nbr":0,"trend_nm":"B","total_recovery_amt":0}],"links":[{"rel":"self","href":""}]}');
            res.setStatusCode(200);
            return res;
        }
    }        

}