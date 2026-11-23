@isTest(SeeAllData=false)
private class Core_MDF_Batch_UpdateClaimstoPaid_Test {

    @TestSetup static void setUpData(){
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<Account> comarketingAccountsList = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();  
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<User> userList = new List<User>();
        
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert config;
        
       List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        User Usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        Usr1.Email='testPayment@example.com';
        Usr1.LastName='ProgAdmUser';
        Usr1.profileId = ccpCoreProfile.Id;
        Usr1.IsActive = true;
        userList.add(Usr1); 
        database.insert(userList);
        
        /*PermissionSet paymentAdmGeoPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_APJ_User' LIMIT 1]; 
        PermissionSet paymentAdmSchedulePS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_Payment_Schedule_Admin' LIMIT 1]; 
        PermissionSet paymentAdmRMFPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1]; 
        PermissionSet viewAllDataPS = [Select Id from PermissionSet where name='View_All_Data' LIMIT 1];  */
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                            'Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                            'View_All_Data')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
                
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet paymentAdmRMFPS = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data'); 
        
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
        assignGeoPermissionSet.AssigneeId = Usr1.Id;
        assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignGeoPermissionSet);
        
        PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
        assignSchedulePermissionSet.AssigneeId = Usr1.Id;
        assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSet);
        
        PermissionSetAssignment assignRMFPermissionSet = new PermissionSetAssignment();
        assignRMFPermissionSet.AssigneeId = Usr1.Id;
        assignRMFPermissionSet.PermissionSetId = paymentAdmRMFPS.Id;
        permSetAssgnLst.add(assignRMFPermissionSet);
        
        PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
        assignViewAllPermissionSet.AssigneeId = Usr1.Id;
        assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSet);
        
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
        }
        
        
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        database.insert(dellCorpAccount);
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
        channelProgramList.add(cp1);
        database.insert(channelProgramList);
        
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_Geo__c = 'APJ';
        comarketingAccountsList.add(dellRMFVirtualCorp);
        
        Database.insert(comarketingAccountsList);   
        
        Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen','Yes', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        //rsaMDCamp.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
        rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
        rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
        campaignList.add(rsaMDCamp);
      Test.startTest();
        database.insert(campaignList);
        
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp1.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'RSA MD');
        pmbRecord1.IsIgnoreValidation = true;
        pmbList.add(pmbRecord1);
        Database.insert(pmbList);
        
        PartnerFundAllocation rsaMdAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('RSAMDalloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(rsaMdAlloc);
        
        database.insert(pfaList);
        
        PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today(),System.today(),false);
        indiaActivity5.Title = 'indiaActivity5';
        //indiaActivity5.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        indiaActivity5.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c= '100%';
        indiaActivity5.RequestedAmount =1000;
        indiaActivity5.status='Approved';
        indiaActivity5.Amount=1000;
        indiaActivity5.budgetid=pmbRecord1.Id;
        indiaActivity5.allocationid=rsaMdAlloc.Id;
        pfrList.add(indiaActivity5);
        Database.insert(pfrList);
        Test.stopTest();
        PartnerFundClaim claimRSAMd = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, indiaActivity5.Id, System.today(), System.today(), 50.00, false);

        claimRSAMd.Core_MDF_Country_Location_nm__c= 'INDIA';
        claimRSAMd.Title = 'Retail RSA MD Claim';
        claimRSAMd.Core_MDF_To_Be_Audited_Ind__c = true;
        claimRSAMd.Core_MDF_Region_Cd__c='APJ';
        claimRSAMd.Core_MDF_VAT_Eligibility_Ind__c = false;
        claimRSAMd.Core_MDF_Type_Txt__c = 'Claim';
        claimRSAMd.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        claimRSAMd.Core_MDF_Currency__c = 'USD';
        claimRSAMd.Core_MDF_Status__c = 'Payment Due';
        claimRSAMd.Core_MDF_Budget_Type_Options_Nm__c ='RSA MD';
        /*Core_MDF_Program__c
        Core_MDF_Invoice_Date__c
        Core_MDF_Invoice_Number__c
        
        Core_MDF_OtherCostsnotReimbursable_Local__c
        Core_MDF_Taxes_Local__c
        Core_MDF_Budget_Type_Options_Nm__c*/
        
        insert claimRSAMd;
        
        /*POP mandatory for Retail*/
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = claimRSAMd.Id+';#'+'Test Doc1';
        String str2 = claimRSAMd.Id+';#'+'Test Doc2';
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = claimRSAMd.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;   
            auditDoc.Core_MDF_App_Document_Types_nm__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDocList.add(auditDoc);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
    
        Core_MDF_PartnerFundClaim.saveClaim(claimRSAMd, auditDocList,null);   
        
        
        
    }
    @isTest static void testRSAMDPayment(){        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
        PartnerFundClaim clm = [Select Id,Core_MDF_Status__c,Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE Title =: 'Retail RSA MD Claim'];
        Id payment_MD_Record_Type = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_RMF_MD').getRecordTypeId();
        Test.startTest();
        clm.Core_MDF_Status__c = 'Payment Due';
        Database.update(clm);
        Core_MDF_Payment__c paymentRecord = new Core_MDF_Payment__c();
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
            retailPayRunRecord.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            retailPayRunRecord.Core_MDF_Program_Id__c  = retailCP.Id;
            Database.insert(retailPayRunRecord); 
            
          System.assertNotEquals(retailPayRunRecord.Id,null);          
            //Test.stopTest();
            
            paymentRecord.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            paymentRecord.Core_MDF_Payment_Run_Id__c = retailPayRunRecord.Id;
            paymentRecord.Core_MDF_Paid_Amt__c = 60;
            paymentRecord.RecordTypeId = payment_MD_Record_Type;
            insert paymentRecord;
        }
               
        clm.Core_MDF_Status__c = 'Pending Payment';
        clm.Core_MDF_Payment_Id__c = paymentRecord.Id;  
        database.update(clm);
        Test.stopTest();
        paymentRecord.Core_MDF_Payment_Status_Txt__c = 'paid';
        paymentRecord.Core_MDF_RMF_Actual_Payment_Amt__c = 50;
        paymentRecord.Core_MDF_Budget_Type_Nm__c='RSA MD';
        database.update(paymentRecord);
        Map<Id, Core_MDF_Payment__c> map1 = new Map<Id, Core_MDF_Payment__c>();
        map1.put(paymentRecord.Id, paymentRecord);
        Id batchJobId = Database.executeBatch(new Core_MDF_Batch_RollbackPaidPaymentClaims(map1),200); 
    }
}