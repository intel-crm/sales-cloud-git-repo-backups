@isTest 
public class Core_MDF_ExtendedDataTable_Test {
    @isTest 
    public static void Core_MDF_CCP_MultiLookup_Test() {
    
        Test.startTest();
        // User usr = [select id,email from User limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'systemadm@example.com';
        insert usr;
        
        System.runAs(usr){

        List<String> comList =new List<String>();
        List<Campaign> capList =new List<Campaign>();
        // List<Account> accList = new List<Account>();
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);//14285 Suma
        insert cp1;
        Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                          Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intacc.Core_Account_Type__c = 'Reseller';
        intacc.Industry = 'Food & Beverage';
        Database.insert(intacc);
        
        Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                     cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        ccfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
        ccfacc.Core_MDF_CoMarketingActive__c = true;
        //accList.add(ccfacc);
        insert ccfacc;
        
        
        
        Campaign campCAP = Core_MDF_CCP_TestDataUtility.createCampaign('Campaign CAP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', /*Date.newInstance(2021, 01, 01)*/System.Today().addDays(-180), /*Date.newInstance(2022, 06, 30).*/System.Today().addDays(180), 10000, 'Consumer Chromebook', ccfacc.Id, '2-in-1', false);
        //campCAP.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
        
        Campaign campCAP2 = Core_MDF_CCP_TestDataUtility.createCampaign('Campaign CAP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', /*Date.newInstance(2021, 01, 01)*/System.Today().addDays(-180), /*Date.newInstance(2022, 06, 30)*/System.Today().addDays(180), 10000, 'Consumer Chromebook', ccfacc.Id, '2-in-1', false);
        //campCAP2.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
        capList.add(campCAP);
        capList.add(campCAP2);
        Database.insert(capList);
        
        
        comList.add(campCAP.Id);
        String campId = campCAP.Id;

            
            //Account accCoMarket = [select id from Account WHERE Name = 'Test Account 3'];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(campCAP.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,ccfacc.id,null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_ActivityCategory__c = '';//14285 Suma
            pfr.Core_MDF_Activity_Types__c = '';//14285 Suma
            insert pfr;
            
            PartnerFundRequest  result = new PartnerFundRequest();
            result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(pfr.Id);
            Core_MDF_PartnerFundRequestCreatePage.fetchOpalMetadataMapping(' AND ActivityCategory_txt__c != null ');
            //Core_MDF_PartnerFundRequestCreatePage.fetchOpalMetadataMapping(null);
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_update');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Creation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           ccfacc.id, cp1.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                           false);
            testBudget1.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
            insert testBudget1;
            
            
            List<String> selectedFields =new List<String>{'Name','Core_MDF_Priority__c','Core_MDF_Account__c','Core_MDF_Program__c'};
            List<String> selectedAccFields =new List<String>{'Name'};
            List<String> selectedAccIds = new List<String>{ccfacc.Id};
            List<String> selectedIds = new List<String>{campId};
            List<String> selectedBudgetFields =new List<String>{'Title','Amount','Core_MDF_Budget_Type_Txt__c'};
            List<String> selectedBudgetIds = new List<String>{testBudget1.Id};
            List<String> selectedPFRFields =new List<String>{'Title','Core_MDF_Fund_Request_Status__c','Core_MDF_Program__c','Core_MDF_Channel_Partner_Led__c','Core_MDF_ActivityCategory__c','Core_MDF_Activity_Types__c'};
            List<String> selectedPFRIds = new List<String>{pfr.Id};
                                            
            Core_MDF_ExtendedDataTable_Controller.getPicklistValuesForObj('PartnerFundRequest','Core_MDF_Fund_Request_Status__c');
            Core_MDF_ExtendedDataTable_Controller.fetchSampleRecs1('PartnerMarketingBudget', selectedBudgetIds);
            Core_MDF_ExtendedDataTable_Controller.getReadOnlyDatatable('Campaign',selectedFields,selectedIds);
            Core_MDF_ExtendedDataTable_Controller.getEditableDataTable('Campaign',selectedFields,selectedIds);
            Core_MDF_ExtendedDataTable_Controller.getEditableDataTable('PartnerMarketingBudget',selectedBudgetFields,selectedBudgetIds);   
            Core_MDF_ExtendedDataTable_Controller.getReadOnlyDatatable('Account',selectedAccFields,selectedAccIds);
            Core_MDF_ExtendedDataTable_Controller.getReadOnlyDatatable('PartnerFundRequest',selectedPFRFields,selectedPFRIds);
            Core_MDF_ExtendedDataTable_Controller.getEditableDataTable('PartnerFundRequest',selectedPFRFields,selectedPFRIds);
            Core_MDF_ExtendedDataTable_Controller.dynamicUpdateRecords(new List<SObject>{campCAP}, 'Inc100203',  'Campaign');
            try{
                List<String> selectedFields1 =new List<String>{'ABC','Title'};
                Core_MDF_ExtendedDataTable_Controller.fetchSampleRecs1('ABC', null);
                Core_MDF_ExtendedDataTable_Controller.getReadOnlyDatatable('ABC',null,null);
                Core_MDF_ExtendedDataTable_Controller.getEditableDataTable('Campaign',selectedFields1,selectedPFRIds);
                Core_MDF_ExtendedDataTable_Controller.dynamicUpdateRecords(new List<SObject>{ccfacc}, null,  'Campaign');
                Core_MDF_ExtendedDataTable_Controller.getPicklistValuesForObj('Campaign', ' ');
            }
            catch(exception e){
                system.assert(e != null);
            }
            campCAP2.StartDate= System.Today().addDays(180);
            campCAP2.EndDate= System.Today().addDays(-180);
            Core_MDF_CCP_BatchUpadateBulkData instanceBatch = new Core_MDF_CCP_BatchUpadateBulkData(new List<SObject>{campCAP,campCAP2},'Inc100203','Campaign');
            database.executeBatch(instanceBatch);
            campCAP2.StartDate= System.Today().addDays(-180);
            campCAP2.EndDate= System.Today().addDays(180);
            Core_MDF_CCP_BatchUpadateBulkData instanceBatch2 = new Core_MDF_CCP_BatchUpadateBulkData(new List<SObject>{campCAP,campCAP2},'Inc100203','Campaign');
            database.executeBatch(instanceBatch2);
            Test.stopTest();
        }
    }
}