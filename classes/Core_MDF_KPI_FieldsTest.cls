@isTest(SeeAllData=false)
public with sharing class Core_MDF_KPI_FieldsTest {

    @TestSetUp
    static void createTestData() {

        List<User> userList = new List<User>();
        //Role
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

            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                    masterAcc.id, retailCP.Id , 10000 , System.today()-60 , System.today() + 60 , false);
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            update retailBudget;
            
            //Ameya
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);

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
            //Database.insert(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            userList.add(ccfaccntmngr);
            //Database.insert(ccfaccntmngr);

            Database.insert(userList);

            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);

            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Mainstream Consumer - Knowledge','10ᵗʰ Gen Core', 
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

        System.runAs(usr){

            List<CCP_Activity_Type_dependent_fields__mdt> metaDataValues = [SELECT Id,Core_MDF_Object_API_Field_Name__c,Core_MDF_Activity_Category_Txt__c,
                                    Core_MDF_Activity_Type_Txt__c
                                FROM CCP_Activity_Type_dependent_fields__mdt 
                                WHERE Core_MDF_Program_Txt__c =: program
                                AND Core_MDF_Activity_Category_Txt__c != null
                                AND Core_MDF_Activity_Type_Txt__c != null
                                AND Core_MDF_Object_API_Field_Name__c != null
                                AND Core_MDF_Module__c =: objectName
                        ];

            Integer successCount = 0;
            Test.startTest(); 
            for (CCP_Activity_Type_dependent_fields__mdt metaData : metaDataValues){
                InputValues inputValues = new InputValues();
                inputValues.activityCategory = metaData.Core_MDF_Activity_Category_Txt__c;
                inputValues.activityType = metaData.Core_MDF_Activity_Type_Txt__c;
                inputValues.program = program;
                inputValues.objName = objectName;
                inputValues.recordId = null;
                String inputStr = json.serialize(inputValues);
                
                Core_MDF_KPI_FieldsController.KPIAttributes  kpiResults = Core_MDF_KPI_FieldsController.getKPIValues(inputStr);
                
                Map<String, Object> mfieldVisibility = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiResults.visibility));
                string fname = metaData.Core_MDF_Object_API_Field_Name__c.replace('__c','');
                //system.debug('fname->' + fname);
                //system.debug('mfieldVisibility->' + mfieldVisibility.get(fname));
                if (kpiResults != null && mfieldVisibility.get(fname) == true){
                    successCount += 1;
                }
                
            }

            System.debug('SuccessCount<->metaDataValues-> ' + SuccessCount + ' metaDataValues->' + metaDataValues.size());
            System.assertEquals(SuccessCount, metaDataValues.size(),'SuccessCount->' + SuccessCount + 'metaDataValues->' + metaDataValues.size());
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
           // pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED STATES','Mainstream Consumer - Knowledge','2-in-1','10ᵗʰ Gen Core','Sales Readiness','Slotting','Draft',false);
            pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(accCoMarketing.id),System.today()+3,System.today()+13,false); 
            
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            //pfr.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            //pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
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
        System.assert(kpiResultList.Size() > 1, true);
    }catch(Exception e){
        System.assertNotEquals(NULL,e);
    }
    }
    
    /*
    @isTest 
    static void validateKPIfromClaim(){
        system.debug('inside validateKPIfromClaim');
        User usr = [select id,email from User where email='testUsercoreMDF@intel.com' Limit 1];        
        string program = 'Retail Marketing Funds';
        string objectName = 'PartnerFundClaim';
        System.runAs(usr){
            test.startTest();
            
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED STATES','Mainstream Consumer - Knowledge','2-in-1','10ᵗʰ Gen Core','Sales Readiness','Promotion','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            pfr.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            insert pfr;
            
            Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c='TestActiveBank1' LIMIT 1];
            
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 500.00, System.today(), bank2.Id, false);
            
            InputValues inputValues = new InputValues();
            inputValues.activityCategory = pfr.Core_MDF_ActivityCategory__c;
            inputValues.activityType = pfr.Core_MDF_Activity_Types__c;
            inputValues.program = program;
            inputValues.objName = objectName;
            inputValues.recordId = null;
            system.debug('KPI inputValues - '+inputValues);
            String inputStr = json.serialize(inputValues);
                
            Core_MDF_KPI_FieldsController.KPIAttributes  kpiResults = Core_MDF_KPI_FieldsController.getKPIValues(inputStr);
            system.debug('KPI result- '+kpiResults);
            Map<String, Object> mfieldVisibility = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiResults.visibility));
            system.debug('KPI mfieldVisibility- '+mfieldVisibility);
            System.assertNotEquals(null,mfieldVisibility);
            
            Set<String> claimFields = new Set<String>();
            for (String visibilityKey : mfieldVisibility.keyset()){
                System.debug('visibility::::'+mfieldVisibility.get(visibilityKey));
                if(mfieldVisibility.get(visibilityKey) == true){
                    visibilityKey = visibilityKey+'__c';
                    claimFields.add(visibilityKey);
                }
            }
            
            //system.assert(claimFields.contains('Core_MDF_Magazine_Newspaper_txt__c'),false);
            System.debug('claimFields::::'+claimFields);
            claim.Core_MDF_Estimated_Ad_Size_nbr__c=1;
            claim.Core_MDF_Magazine_Newspaper_txt__c = 'test' ;
            claim.Core_MDF_Type_of_Page_txt__c = 'Colour page';
            claim.Core_MDF_Currency__c='USD';
            Database.insert(claim);
            
            test.stopTest();
        }

    }
    
    */
    private class InputValues{
        private Id recordId;
        private string objName = '';
        private string activityCategory = '';
        private string activityType = '';
        private string program = '';
    }
}