@isTest
        public class Core_MDF_BankAccountTriggerHandler_Test {
            
            @TestSetup static void setUpData(){
                
                
                List<Account> accountList = new List<Account>();
                // Creating Intel Account with utility class
                //Account intelAccountRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account Maptst', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
                Account intelAccountRecord = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
                intelAccountRecord.BillingCity = 'Pune';         
                intelAccountRecord.BillingCountry= 'IND';
                intelAccountRecord.Core_Geo__c ='APJ';
                intelAccountRecord.Core_Sub_Geo__c = 'SA';
                intelAccountRecord.BillingStreet= 'Test Street';
                Database.insert(intelAccountRecord);
                intelAccountRecord.isPartner = true;
                Database.update(intelAccountRecord);
             
                ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
                ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
                ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
             
                // Creating Co-marketing Account with utility class
                Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account map1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,intelAccountRecord.Id,false);
                acc.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
                acc.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
                //acc.IsPartner = true;
                accountList.add(acc);        
               // Test.startTest();
                Account accDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account map2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id, false);
                accDCF.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
                accDCF.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
                //acc2.IsPartner = true;
                accountList.add(accDCF);
                Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account mapDCF', dcfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id, false);
                acc2.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
                acc2.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
                //acc2.IsPartner = true;
                accountList.add(acc2);
        
                Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account map3', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id,false);
                acc3.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
                acc3.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
                //acc3.IsPartner = true;
                accountList.add(acc3);
               
                Account acc4 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account map4', cpRetail.Id,
                                                                           Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
                acc4.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
                acc4.BillingCity = 'Pune';
                acc4.BillingCountry = 'IND';
                acc4.Core_Geo__c ='APJ';
                acc4.Core_Sub_Geo__c = 'SA';
                accountList.add(acc4);
                
                Database.insert(accountList);
                for(Account accRecord : accountList){
                    accRecord.IsPartner = true;
                }
                Database.update(accountList); 
        
                //Create CCF Group
                Group ccfgrp = new Group();
                ccfgrp.Name = 'Core CCP CCF Internal';
                ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
                Database.insert(ccfgrp);
                
                //Create Retail Group
                Group retailgrp = new Group();
                retailgrp.Name = 'Core CCP Retail Internal';
                retailgrp.DeveloperName = 'Core_CCP_Retail_Internal';
                Database.insert(retailgrp);
                
                List<Contact> contactList = new List<Contact>();
                //Creating Contact for Partner User
                Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(intelAccountRecord.Id,false);
                contactList.add(conRecord1);
                Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(intelAccountRecord.Id,false);
                contactList.add(conRecord2);
                insert contactList;
        
                // Creating User with utility class 
                List<User> userList = new List<User>();
        
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.Email = 'paymentadmin@example.com';
                
                userList.add(usr);
                
                Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
                
                User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
                usr1.Email='test1@example.com';
                usr1.ContactId = contactList[0].Id;
                usr1.ProfileId = profileId;
                
                usr1.isActive = true;
                userList.add(usr1);
                
                User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr2.Email='test2@example.com';
                usr2.ContactId = contactList[1].Id;
                usr2.ProfileId = profileId;
                
                usr2.isActive = true;
                userList.add(usr2);
        
                Database.insert(userList);
               
                //Create PGM
                Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
                ccfPgm.Core_MDF_Account__c = intelAccountRecord.Id;
                ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
                ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
                ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
                ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
                ccfPgm.Core_MDF_Region_cd__c = 'APJ';
                ccfPgm.Core_MDF_Source_Txt__c = 'test';
                ccfPgm.Core_MDF_AccountIdGroupName__c = intelAccountRecord.Id + '_Core_CCP_CCF_Internal';
                Database.insert(ccfPgm);
                
                Core_MDF_Partner_Group_Mapping__c retailPgm = new Core_MDF_Partner_Group_Mapping__c();
                retailPgm.Core_MDF_Account__c = intelAccountRecord.Id;
                retailPgm.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal';
                retailPgm.Core_MDF_Type_of_Access__c = 'Internal';
                retailPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
                retailPgm.Core_MDF_Channel_Program__c = cp.Id;
                retailPgm.Core_MDF_Source_Txt__c = 'test';
                retailPgm.Core_MDF_Region_cd__c = 'APJ';
                retailPgm.Core_MDF_AccountIdGroupName__c = intelAccountRecord.Id + '_Core_CCP_Retail_Internal';
                Database.insert(retailPgm);
        
                      
                // Creating Bank with utility class
                List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
                Core_MDF_Bank__c testBank1 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
                testBank1.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund;';
                bankList.add(testBank1);
                
                Core_MDF_Bank__c testBank2 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1237784581');
                bankList.add(testBank2);
                
                // Core_MDF_Bank__c testBank3 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1237784584');
                
                Core_MDF_Bank__c testBank3 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.id, 'Core_MDF_Retail_Marketing_Funds', false,'1234567894');
                testBank3.Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'; 
                testBank3.Core_MDF_Intel_Company_Code__c ='420';
                testBank3.Core_MDF_Tax_codes_cd__c ='I0';
                bankList.add(testBank3);  
                System.debug('testBank3--->'+testBank3.Core_MDF_Program__c);
                insert bankList;
        
                bankList[0].Core_MDF_Bank_Location__c = 'IN';
                bankList[0].Core_MDF_ESD_Update__c = true;
                bankList[0].Core_MDF_Bank_Status__c = 'Active';
        
                bankList[1].Core_MDF_Bank_Location__c = 'US';
                bankList[1].Core_MDF_ESD_Update__c = true;
                bankList[1].Core_MDF_Bank_Status__c = 'Active';
                
                bankList[2].Core_MDF_Bank_Location__c = 'US';
                bankList[2].Core_MDF_ESD_Update__c = true;
                bankList[2].Core_MDF_Bank_Status__c = 'Active';
        
                update bankList;
                 
                // Creating campaigns using utility class
                Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                            'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                            System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', true);
                
                // Creating Budget using utility class
                PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                       acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                                       true);
                
                Test.startTest();
                // Creating Allocation using utility class
                PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
                
                PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                'Desktop','Intel® Core™ i7 Processor','Broadcast',
                'Podcast','Draft',false);
                pfr.RequestedAmount = 900000;
                pfr.Amount = 900000;
                pfr.Status = 'Approved';
                pfr.AllocationId = pfa.Id;
                pfr.BudgetId = pmb.Id;
                //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
                pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
                pfr.Core_MDF_End_Date__c = System.today();
                Database.insert(pfr);
                
                List<PartnerFundRequest> partnerFndActivityNumber = [select Core_MDF_Activity_Number__c from PartnerFundRequest where id=:pfr.id];
                
                List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
                Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id, bankList[0].Id, FALSE);
                abmCCF1.Core_MDF_Active_ind__c = TRUE;
                abmList.add(abmCCF1);
                Core_MDF_Account_Bank_Mapping__c abmDCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bankList[0].Id, FALSE);
                abmList.add(abmDCF);
                insert(abmList);
                
                Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
                Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
                esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc1.Core_MDF_Escalation_Name_txt__c='Test1';
                esc1.Core_MDF_Total_Dollar_Impact_amt__c= 56;
                esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
                esc1.Core_MDF_Co_Marketing_Activity_id__c = partnerFndActivityNumber[0].Id;
                esc1.Core_MDF_Channel_Program_id__c = cp.Id;
                esc1.recordtypeid= claimRecType;
                Database.insert(esc1);
                
                Case cs = new Case();
                Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
                //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
                cs.Status = 'Closed';
                cs.recordTypeId = caseAuditRecType;
                cs.AccountId = acc.Id;
                insert cs;  
                Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
                Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
                esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
                esc2.Core_MDF_Escalation_Name_txt__c='Test2';
                esc2.Core_MDF_Total_Dollar_Impact_amt__c= 45;
                esc2.Core_MDF_Root_Cause_nm__c = 'Creative';
                esc2.Core_MDF_Case_ID_Number_id__c = cs.Id;
                esc2.Core_MDF_Channel_Program_id__c = cp.Id;
                esc2.recordtypeid = caseRecType;
                
                Database.insert(esc2);
                Test.stopTest();  
            }
            @isTest
            static void createCCFMapping(){
                ChannelProgram cp = [Select Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
                User usr = [SELECT Id,Email from User where Email='paymentadmin@example.com' limit 1];
                Test.startTest();
                Account intelAcc = [SELECT Id from Account where Name='Test Account' limit 1];
                Account coaccCCF = [SELECT Id from Account where Name='Test Account map1' limit 1];
                Account coaccDCF = [SELECT Id from Account where Name='Test Account mapDCF' limit 1];
                PartnerMarketingBudget budget = [SELECT Id from PartnerMarketingBudget where Title='Test Budget' limit 1];
                Campaign camp = [SELECT Id from Campaign where Name='TestCamp' limit 1];
                PartnerFundRequest pfr = [SELECT Id from PartnerFundRequest where Title='Test' limit 1];
                Core_MDF_Bank__c testBank = [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                             FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567891'];
                
               
                System.RunAs(usr){
                    Core_MDF_Account_Bank_Mapping__c abmCCF1 = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: coaccCCF.Id ]; 
                    Core_MDF_Account_Bank_Mapping__c abmDCF = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: coaccDCF.Id ]; 
                  
                   
                    System.assert(abmCCF1.Id != NULL);
                    System.assert(abmCCF1.Core_MDF_Active_ind__c == TRUE);
                   
                    PartnerFundClaim newClaim = new PartnerFundClaim();
                    newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                        Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                        System.today(), System.today(), 122, 
                                                                        System.today(), testBank.Id, false);
                    newClaim.Core_MDF_Status__c = 'Submitted';
                    newClaim.Core_MDF_Currency__c = 'USD';
                    newClaim.Core_MDF_Taxes_Local__c = 0;
                    Database.insert(newClaim);
                    
                    abmCCF1.Core_MDF_Active_ind__c = FALSE;
                    abmDCF.Core_MDF_Active_ind__c = FALSE;
                    
                    try{
                        Update(abmCCF1);
                        Update(abmDCF);
                        System.assert(abmCCF1.Core_MDF_Active_ind__c == TRUE);
                        System.assert(abmDCF.Core_MDF_Active_ind__c == FALSE);
                    }
                    catch(Exception e){
                        System.assert(abmCCF1.Core_MDF_Active_ind__c == FALSE);
                    }
                }   
                Test.stopTest();
            }
            
           
            @isTest static void createMapping(){
                
                User usr = new User();//[SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
                User usr1 = new User();//[SELECT Id,Email from User where Email='test1@example.com' limit 1];
                User usr2 = new User();//[SELECT Id,Email from User where Email='test2@example.com' limit 1];
                
                for(User userRecord : [SELECT Id,Email
                                       FROM User
                                       WHERE Email IN ('paymentadmin@example.com', 'test1@example.com', 'test2@example.com')
                                       LIMIT 3]){
                    if(userRecord.Email == 'paymentadmin@example.com'){
                        usr = userRecord;
                    }
                    else if(userRecord.Email == 'test1@example.com'){
                        usr1 = userRecord;
                    }
                    else if(userRecord.Email == 'test2@example.com'){
                        usr2 = userRecord;
                    }
                }
                
                Account intelAcc;//[SELECT Id from Account where Name='Test Account maptst' limit 1];
                Account coacc1;//[SELECT Id from Account where Name='Test Account map1' limit 1];
                Account coacc2;//[SELECT Id from Account where Name='Test Account map2' limit 1];
                Account coacc3;//[SELECT Id from Account where Name='Test Account map2' limit 1];
                
                for(Account accRecord : [SELECT Id, Name, ChannelProgramName
                                         FROM Account
                                         WHERE Name IN ('Test Account maptst', 'Test Account map1', 'Test Account map2','Test Account map4')
                                         LIMIT 3]){
                    if(accRecord.Name == 'Test Account maptst'){
                        intelAcc = accRecord;
                    }
                    else if(accRecord.Name == 'Test Account map1'){
                        coacc1 = accRecord;
                        //coacc3 = accRecord;
                    }
                    else if(accRecord.Name == 'Test Account map2'){
                        coacc2 = accRecord;
                    }
                    else if(accRecord.Name == 'Test Account map4'){
                        coacc3 = accRecord;                       
                    }
                }
                
                Core_MDF_Bank__c testBank1; //[SELECT Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1234567891' limit 1];
                Core_MDF_Bank__c testBank2; //[SELECT Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1237784581' limit 1];
                Core_MDF_Bank__c testBank3; //[SELECT Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1237784584' limit 1];
                
                for(Core_MDF_Bank__c bankRecord: [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                                  FROM Core_MDF_Bank__c
                                                  WHERE Core_MDF_Supplier_Number__c IN ('1234567891', '1237784581','1234567894')]){
                    if(bankRecord.Core_MDF_Supplier_Number__c == '1234567891'){
                        testBank1 = bankRecord;
                    }
                    else if(bankRecord.Core_MDF_Supplier_Number__c == '1237784581'){
                        testBank2 = bankRecord;
                    }
                    else if(bankRecord.Core_MDF_Supplier_Number__c == '1234567894'){
                         testBank3 = bankRecord;                                
                    }
                }
        
                List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                List<Core_MDF_Account_Bank_Mapping__c> insertlist = new List<Core_MDF_Account_Bank_Mapping__c>();     
                
                
                System.runAs(usr){
                    
                    test.startTest();  
                    
                    // Create a Partner Node User Mapping with the above created Account
                    List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                    Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(coacc1.Id,usr1.Id,false);
                    Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(coacc1.Id,usr2.Id,false);
                    Core_MDF_Partner_Node_User_Mapping__c pnumRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(coacc2.Id,usr1.Id,false);
                    Core_MDF_Partner_Node_User_Mapping__c pnumRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(coacc2.Id,usr2.Id,false);
                    pnumList.add(pnumRecord);
                    pnumList.add(pnumRecord1);
                    pnumList.add(pnumRecord2);
                    pnumList.add(pnumRecord3);
                    
                    Database.insert(pnumList);
                    
                    Core_MDF_Account_Bank_Mapping__c pbankaccount = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: coacc1.Id ]; 
                    
                    deleteRecordList.add(pnumRecord);
                    deleteRecordList.add(pnumRecord1);
                    deleteRecordList.add(pnumRecord2);
                    deleteRecordList.add(pnumRecord3);
                    
                    Core_MDF_Account_Bank_Mapping__c bankacc = Core_MDF_CCP_TestDataUtility.createBankAccountMap(coacc1.Id,testBank2.Id, true);
                    bankacc.Core_MDF_Account__c = coacc2.Id;
                    bankacc.Core_MDF_Bank__c = testBank2.Id;
                    try{
                        Database.update(bankacc);
                    }catch(Exception e){
                        
                    }
                   	Core_MDF_Account_Bank_Mapping__c retailbankaccount = Core_MDF_CCP_TestDataUtility.createBankAccountMap(coacc3.Id,testBank3.Id, false);
                    
                    retailbankaccount.Core_MDF_Account__c = coacc3.Id;
                    retailbankaccount.Core_MDF_Bank__c = testBank3.Id;
                    Database.insert(retailbankaccount); 
                    
                    Core_MDF_Account_Bank_Mapping__c bankacc1 = Core_MDF_CCP_TestDataUtility.createBankAccountMap(coacc2.Id,testBank1.Id, true);
                    Database.delete(bankacc1);
                    
                    Database.delete(deleteRecordList);
                 
                    try{
                        Database.delete(pbankaccount);
                    }catch(Exception e){System.debug(''+e.getMessage());
                    System.assert(e != NULL );}
                    test.stopTest();
                }
            }
            @isTest static void createRetailMapping(){
                
                User usr = new User();//[SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
                Test.startTest();
                for(User userRecord : [SELECT Id,Email
                                       FROM User
                                       WHERE Email IN ('paymentadmin@example.com')
                                       LIMIT 1]){
                    if(userRecord.Email == 'paymentadmin@example.com'){
                        usr = userRecord;
                    }
                }
                
        
               Account intelAcc;//[SELECT Id from Account where Name='Test Account maptst' limit 1];
               Account coacc3;//[SELECT Id from Account where Name='Test Account map4' limit 1];
                
                for(Account accRecord : [SELECT Id, Name, ChannelProgramName
                                         FROM Account
                                         WHERE Name IN ('Test Account maptst','Test Account map4')
                                         LIMIT 1]){
                    if(accRecord.Name == 'Test Account maptst'){
                        intelAcc = accRecord;
                    }
                    else if(accRecord.Name == 'Test Account map4'){
                        coacc3 = accRecord;                       
                    }
                }
                
                Core_MDF_Bank__c testBank3; //[SELECT Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1234567894' limit 1];
                
                for(Core_MDF_Bank__c bankRecord: [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                                  FROM Core_MDF_Bank__c
                                                  WHERE Core_MDF_Supplier_Number__c IN ('1234567894')]){
                  if(bankRecord.Core_MDF_Supplier_Number__c == '1234567894'){
                         testBank3 = bankRecord;                                
                    }
                }
        
                List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                
                System.runAs(usr){ 
                   
                    
                        Core_MDF_Account_Bank_Mapping__c retailbankaccount = Core_MDF_CCP_TestDataUtility.createBankAccountMap(coacc3.Id,testBank3.Id, false);
                        retailbankaccount.Core_MDF_Account__c = coacc3.Id;
                        retailbankaccount.Core_MDF_Bank__c = testBank3.Id;
                       
                   
                   try{
                        Database.insert(retailbankaccount); 
                    }catch(Exception e){
                        System.debug(''+e.getMessage());
                        System.assert(e != NULL );
                    }
                    Test.stopTest();
                }
            }
        
            @isTest
            static void ABMDuplicateCheckTest(){
                User paymentAdmin = [Select Id FROM User Where Email = 'paymentadmin@example.com' LIMIT 1];
                System.runAs(paymentAdmin){
        
                    Test.startTest();
                    Account testAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
                    Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testAccount.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234561111');
                    newBank.Core_MDF_Bank_Status__c = 'Active';
                    newBank.Core_MDF_DUNS__c = '578299333';
                    newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
                    newBank.Core_MDF_Bank_Location__c = 'IN';
                    newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                    newBank.Core_MDF_Intermediary_Indicator__c = 'N';
                    newBank.Core_MDF_Routing_Number__c = '123456';
                    newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                    newBank.Core_MDF_Effective_Date__c = system.today();
                    newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
                    newBank.Core_MDF_Bank_Location__c = 'IN';
                    newBank.Name = 'TEST BANK'; 
                    insert newBank;
               	}
                //Sharing with Account Budget Admins
                User accBudgetAdmin = [Select Id FROM User Where Email = 'test1@example.com' LIMIT 1];
                Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_Bank_Status__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234561111' LIMIT 1];
                bank1.Core_MDF_Bank_Status__c = 'Active';
                update(bank1);
                
                System.assert(bank1.Core_MDF_Bank_Status__c == 'Active');
                
                
                Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
                bankShare.ParentId = bank1.Id;
                bankShare.UserOrGroupId = accBudgetAdmin.Id; 
                bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
                bankShare.AccessLevel = Label.Core_MDF_Read_Access;
                insert bankShare;
                
                Core_MDF_ShareBanktoBudgetAdmins obj = new Core_MDF_ShareBanktoBudgetAdmins();
                DataBase.executeBatch(obj);
                
                Account testCoCCFAccount = [Select Id FROM Account WHERE Name = 'Test Account map1' LIMIT 1];
                Account testCoCCFAccount2 = [Select Id FROM Account WHERE Name ='Test Account map2' LIMIT 1];
                
                //Sharing testCoCCFAccount with Budget Admin
                AccountShare accshareRecordCCF = new AccountShare();
                accshareRecordCCF.AccountId = testCoCCFAccount.Id;
                accshareRecordCCF.UserOrGroupId = accBudgetAdmin.Id;
                accshareRecordCCF.RowCause = 'Manual';
                accshareRecordCCF.AccountAccessLevel = 'Read';
                accshareRecordCCF.OpportunityAccessLevel = 'None';
                accshareRecordCCF.CaseAccessLevel = 'None';
                Database.Insert(accshareRecordCCF);
                
                //Sharing testCoCCFAccount2 with Budget Admin
                AccountShare accshareRecordCCF2 = new AccountShare();
                accshareRecordCCF2.AccountId = testCoCCFAccount2.Id;
                accshareRecordCCF2.UserOrGroupId = accBudgetAdmin.Id;
                accshareRecordCCF2.RowCause = 'Manual';
                accshareRecordCCF2.AccountAccessLevel = 'Read';
                accshareRecordCCF2.OpportunityAccessLevel = 'None';
                accshareRecordCCF2.CaseAccessLevel = 'None';
                Database.Insert(accshareRecordCCF2);
        
                System.runAs(accBudgetAdmin){
        
                   
                    Core_MDF_Bank__c bankCCF = [Select Id,Core_MDF_Bank_Status__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234561111' LIMIT 1];
                    
                    
                    //Creating ABM List
                    List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        
                    //Creating ABM record using utility class
                    Core_MDF_Account_Bank_Mapping__c abm1CCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount.Id, bankCCF.Id, FALSE);
                    abm1CCF.Core_MDF_Active_ind__c = true;
                    
                    abmList.add(abm1CCF);            
                    
                    //Trying to insert same ABM's in one insert operation
                    try{
                        Core_MDF_Account_Bank_Mapping__c abmCCF2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount.Id, bankCCF.Id, FALSE);
                        abmCCF2.Core_MDF_Active_ind__c = true;
                    
                        abmList.add(abmCCF2);
                    
                        insert abmList;
                    }
                    catch(Exception ex){
                        Boolean expectedExceptionThrown =  ex.getMessage().contains('duplicates value on record with id') ? true : false;
                        System.assertEquals(expectedExceptionThrown, true);
                    }
                    //Trying to create the existing record 
                    try{
                        Core_MDF_Account_Bank_Mapping__c abmCCF3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount.Id, bankCCF.Id, FALSE);
                        abmCCF3.Core_MDF_Active_ind__c = true;
        
                        insert abmCCF3;
                    }
                    catch(Exception ex){
                        Boolean expectedExceptionThrown =  ex.getMessage().contains('This Bank Mapping already exists') ? true : false;
                            System.assertEquals(expectedExceptionThrown, true);
                        }
                    
                    //Updating the ABM and trying to insert existing record 
                    Core_MDF_Account_Bank_Mapping__c abmCCF4 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount2.Id, bankCCF.Id, FALSE);
                    abmCCF4.Core_MDF_Active_ind__c = true;
        
                    insert abmCCF4;
                    
                    try{
                        abmCCF4.Core_MDF_Account__c = testCoCCFAccount.id;
                        abmCCF4.Core_MDF_Bank__c = bankCCF.Id;
                        update abmCCF4;
                    }
                    catch(Exception ex){
                        //System.assertEquals(abmCCF4.Core_MDF_Account__c.id != testCoCCFAccount.id);
                    }
                }
                 Test.stopTest();
        	}
            @isTest
            static void testROSharing(){
                ChannelProgram cp = [Select Id FROM ChannelProgram WHERE Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'];
                User usr = [SELECT Id,Email from User where Email='paymentadmin@example.com' limit 1];
                Test.startTest();
                Account intelAcc = [SELECT Id from Account where Name='Test Account' limit 1];
                Account coaccCCF = [SELECT Id from Account where Name='Test Account map1' limit 1];
                Account coaccDCF = [SELECT Id from Account where Name='Test Account mapDCF' limit 1];
                PartnerMarketingBudget budget = [SELECT Id from PartnerMarketingBudget where Title='Test Budget' limit 1];
                Campaign camp = [SELECT Id from Campaign where Name='TestCamp' limit 1];
                PartnerFundRequest pfr = [SELECT Id, Core_MDF_Region_cd__c, Core_MDF_Program__c from PartnerFundRequest where Title='Test' limit 1];
                Core_MDF_Bank__c testBank = [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                             FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567891'];
                
               Core_MDF_Account_Bank_Mapping__c abmCCF1;
                System.RunAs(usr){
                     abmCCF1 = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: coaccCCF.Id ]; 
                }
        
               Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                             From Core_MDF_ProgramGeoGroupMap__mdt
                                                             WHERE Core_MDF_Region__c = :pfr.Core_MDF_Region_cd__c
                                                             AND Core_MDF_Program__c = :pfr.Core_MDF_Program__c];
                        
                Boolean isAPJShared = false;
        
                try{
                 	List<Core_MDF_Account_Bank_Mapping__Share> abmShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                               FROM Core_MDF_Account_Bank_Mapping__Share 
                                                               WHERE parentId = :abmCCF1.Id];
                    
                    for(Core_MDF_Account_Bank_Mapping__Share shareRec : abmShareList)
                    {
                        if(shareRec.UserOrGroup.Name.equals(metaRec.Core_MDF_Group_Name__c)){
                            isAPJShared = true;
                        }
                    }
                    if(!isAPJShared){
                        System.assert(isAPJShared);
                    }
                    
               
                    test.stopTest();
                    }catch(Exception e){
                        System.debug('Error');
                    }
            
            }
                        
        }