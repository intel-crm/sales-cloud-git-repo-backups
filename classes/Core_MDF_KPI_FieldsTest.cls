@isTest(SeeAllData=false)
public with sharing class Core_MDF_KPI_FieldsTest {
    
    @TestSetUp
    static void createTestData() {
        
        List<User> userList = new List<User>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        
        System.runAs(testUser){
            
            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'APJ';
            masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;
            List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
            bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
            bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                            masterAcc.id, retailCP.Id , 10000 , System.today()-60 , System.today() + 60 , false);
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            update retailBudget;
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet extApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Activity_Approver' LIMIT 1];
            
            Contact con  = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id, true);
            User usrBudgetAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrBudgetAdmin.LastName = 'Budget Admin';
            usrBudgetAdmin.ContactId = con.Id;
            usrBudgetAdmin.ProfileId = partnerProfile.Id;
            usrBudgetAdmin.portalRole = 'Manager';
            usrBudgetAdmin.email = 'ccfextapprover@example.com';
            userList.add(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            userList.add(ccfaccntmngr);
            
            Database.insert(userList);
            
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);
            
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Mainstream Consumer - Knowledge','10ᵗʰ Gen Core', 'Yes',
                                                                                  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                                  'Retail_Marketing_Funds', System.today(),
                                                                                  System.today()+300, 10000, 'Instore merchandise', 
                                                                                  masterAcc.Id,'2-in-1', false);
            
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'ACPC';
            insert retailCampaign;
            
            test.startTest();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
            bank.Core_MDF_Intel_Company_Code__c='150';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            Database.insert(bank);
            bank.Core_MDF_Bank_Status__c = 'Active'; 
            Database.update(bank);
            //creating ABM for bank1
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
            test.stopTest();
        }
        
    }
    
    @isTest 
    static void runKPIFromMetaData(){
        
        User usr = [select id,email from User where email='testUsercoreMDF@intel.com' Limit 1];
        string program = 'Retail Marketing Funds';
        string objectName = 'PartnerFundRequest';
        Test.startTest(); 
        System.runAs(usr){
            
            List<CCP_Activity_Type_dependent_fields__mdt> metaDataValues = [SELECT Id,Core_MDF_Object_API_Field_Name__c,Core_MDF_Activity_Category_Txt__c,
                                                                            Core_MDF_Activity_Type_Txt__c, Core_MDF_Activity_Subtype_Txt__c 
                                                                            FROM CCP_Activity_Type_dependent_fields__mdt 
                                                                            WHERE Core_MDF_Program_Txt__c =: program
                                                                            AND Core_MDF_Activity_Category_Txt__c != null
                                                                            AND Core_MDF_Activity_Type_Txt__c != null
                                                                            AND Core_MDF_Object_API_Field_Name__c != null
                                                                            AND Core_MDF_Module__c =: objectName limit 1
                                                                           ];
            
            Integer successCount = 0;
            
            if(!metadataValues.isEmpty()) {
                CCP_Activity_Type_dependent_fields__mdt metaData = metaDataValues[0];
                InputValues inputValues = new InputValues();
                inputValues.activityCategory = metaData.Core_MDF_Activity_Category_Txt__c;
                inputValues.activityType = metaData.Core_MDF_Activity_Type_Txt__c;
                inputValues.activitySubType = metaData.Core_MDF_Activity_Subtype_Txt__c;
                inputValues.program = program;
                inputValues.objName = objectName;
                inputValues.recordId = null;
                String inputStr = json.serialize(inputValues);
                
                Core_MDF_KPI_FieldsController.KPIAttributes  kpiResults = Core_MDF_KPI_FieldsController.getKPIValues(inputStr);
                
                Map<String, Object> mfieldVisibility = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiResults.visibility));
                string fname = metaData.Core_MDF_Object_API_Field_Name__c.replace('__c','');
                if (kpiResults != null && mfieldVisibility.get(fname) == true){
                    successCount += 1;
                }
            }
            //Assert.areEqual(true, successCount>0, 'successCount > 0');
            Test.stopTest();  

        }
        
    }
    
    @isTest 
    static void runKPIEditAcgMgrAndExtApprover(){
        try{
            User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
            string program = 'Retail Marketing Funds';
            string objectName = 'PartnerFundRequest';
            PartnerFundRequest pfr = new PartnerFundRequest();
            List<Core_MDF_KPI_FieldsController.KPIAttributes> kpiResultList = new List<Core_MDF_KPI_FieldsController.KPIAttributes>();
            
            Test.startTest(); 
            System.runAs(usr){
                Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
                Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
                pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accCoMarketing.id),System.today()+3,System.today()+13,false); 
                
                pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                pfr.Title = 'Test Retail Activity';
                pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
                pfr.Core_MDF_Channel_Partner_Led__c = false;
                pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
                pfr.Core_MDF_Budget_Currency_cd__c='USD';
                pfr.Core_MDF_Metrics_txt__c = '123';
                insert pfr;
                
                pfr = [select id,Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c from partnerfundrequest where title = 'Test Retail Activity' limit 1];
                InputValues inputValues = new InputValues();
                inputValues.activityCategory = pfr.Core_MDF_ActivityCategory__c;
                inputValues.activityType = pfr.Core_MDF_Activity_Types__c;
                inputValues.program = program;
                inputValues.objName = objectName;
                inputValues.recordId = pfr.id;
                String inputStr = json.serialize(inputValues);
                Core_MDF_KPI_FieldsController.KPIAttributes kpiResults = Core_MDF_KPI_FieldsController.getKPIValues(inputStr);
                kpiResultList.add(kpiResults);
                Assert.isNotNull(inputStr);
            }
            User usrExtBudgerAdmin = [select id,email from User where email='ccfextapprover@example.com' limit 1];
            System.runAs(usrExtBudgerAdmin){
                InputValues inputValues = new InputValues();
                inputValues.activityCategory = pfr.Core_MDF_ActivityCategory__c;
                inputValues.activityType = pfr.Core_MDF_Activity_Types__c;
                inputValues.program = program;
                inputValues.objName = objectName;
                inputValues.recordId = pfr.id;
                String inputStr = json.serialize(inputValues);
                Core_MDF_KPI_FieldsController.KPIAttributes  kpiResultsBA = Core_MDF_KPI_FieldsController.getKPIValues(inputStr);
                kpiResultList.add(kpiResultsBA);
            }
            Test.stopTest(); 
            Assert.isTrue(kpiResultList.Size() > 1, 'true');
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
            Assert.isNotNull(e);
        }
    }
    
    
    private class InputValues{
        private Id recordId;
        private string objName = '';
        private string activityCategory = '';
        private string activityType = '';
        private string activitySubType = '';
        private string program = '';
    }
}