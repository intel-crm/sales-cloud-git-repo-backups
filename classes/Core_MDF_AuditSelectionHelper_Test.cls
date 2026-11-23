/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditSelectionHelper_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        10/23/2018                    Created to test Random Audit Selection. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AuditSelectionHelper_Test{
/****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created setUpData() to prepare data for testing 
Added By:                                      Accenture – Harika P  -  10/23/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        10/23/2018         Created.
*****************************************************************************************************************************************/
    
    @TestSetup static void setUpData(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        System.runAs(usr){
            
            //Create Exchnage rates records
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today()-2;
            record1.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today()-2;
            record2.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today()-2;
            record3.Core_MDF_Intel_WW__c = 'WW 46';
            newValues.add(record3); 
            
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
            
            aObj.inputCurrency ='ZMK';
            aObj.inputAmount = 250.00;
            aObj.inputDate= date.newInstance(2018, 11, 13);
            bObj.inputCurrency ='INR';
            bObj.inputAmount = 350.00;
            bObj.inputDate= date.newInstance(2018, 11, 12);
            cObj.inputCurrency ='USD';
            cObj.inputAmount = 350.00;
            cObj.inputDate= date.newInstance(2018, 11, 12);
            listvar.add(aObj);
            listvar.add(bObj);
            listvar.add(cObj);
            Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
            
            database.insert(newValues);                     
            
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_MDF_CoMarketingAgency__c=true;
            Database.insert(acc1);
            
            // Creating Co-marketing Account with utility class
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            Database.insert(acc);  
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Database.insert(con);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.ContactId = con.Id;
            Database.insert(usr1);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today().addDays(5) ,
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', true);
            
            // Creating Budget using utility class
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110), 
                                                                                   true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
            
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                           'Desktop','Intel® Core™ i7+ Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 900000;
            pfr.Amount = 900000;
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c = system.today();
            Database.insert(pfr);
            test.startTest();
            // Creating Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
                        
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.id;
            pfrShare.AccessLevel = 'Edit';
            Database.insert(pfrShare);  

            Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
            bankShare.ParentId = bank.Id;
            bankShare.UserOrGroupId = usr1.id;
            bankShare.AccessLevel = 'Edit'; 
            Database.insert(bankShare);                         
                                       
            // Creating claims
            for(Integer i = 0; i < 11; i++) {                
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                if(i==10){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                    pfc.Core_MDF_IsClaimReviewEscalation_Ind__c = true;
                }                    
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                newClmList.add(pfc);
            }
        }
        
        User partnerUser = [SELECT Id, LastName FROM User WHERE LastName='User Test1'];
        //Creating claims as partner user
        System.runAs(partnerUser){
            Database.insert(newClmList);
        }
    }
    
/****************************************************************************************************************************************
Method Name:                                   testAuditSelectionMethod
Description:                                   Created to test random audit
Added By:                                      Accenture – Harika P  -  10/23/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        10/23/2018         Created.
*****************************************************************************************************************************************/  
    
    @isTest static void testAuditSelectionMethod(){
        // To cover exception in randomAuditSelection method
        // Excluded Core_MDF_Total_Invoice_Amount_Local__c field in below SOQL
        list<PartnerFundClaim> exceptionPFC = [SELECT Id, Title, Core_MDF_Program__c,Core_MDF_Exchange_rate__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 1];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(exceptionPFC);
        PartnerFundClaim isEscalationTypeClm = new PartnerFundClaim();
        //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
        

        //
        list<PartnerFundClaim> pfcList = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,
                                          Core_MDF_Pred_PredictionResult__c,
                                          Core_MDF_AuditSelectionInProgress__c,
                                          Core_MDF_FlaggedForAudit__c,
                                          Core_MDF_Audit_Type__c,Title, Core_MDF_Program__c,
                                          Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                          CreatedById,Core_MDF_Country_Location_nm__c,
                                          Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                          Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,
                                          Core_MDF_Predictive_Audit_Retries__c FROM PartnerFundClaim WHERE Title LIKE 'Test Claim%' LIMIT 11];
        for(PartnerFundClaim p:pfcList){
            if(p.Core_MDF_IsClaimReviewEscalation_Ind__c == true){
                isEscalationTypeClm.Id = p.Id;
                isEscalationTypeClm.Core_MDF_Pred_PredictionResult__c = p.Core_MDF_Pred_PredictionResult__c;
                isEscalationTypeClm.Core_MDF_AuditSelectionInProgress__c = p.Core_MDF_AuditSelectionInProgress__c;
                isEscalationTypeClm.Core_MDF_FlaggedForAudit__c = p.Core_MDF_FlaggedForAudit__c;
                isEscalationTypeClm.Core_MDF_Audit_Type__c = p.Core_MDF_Audit_Type__c;
            }
        }
        Map<String,Map<PartnerFundClaim, String>> randomSelectionResult = Core_MDF_AuditSelectionHelper.randomAuditSelection(pfcList);
        if(randomSelectionResult != null){
            System.assert(randomSelectionResult.containsKey('Random') || randomSelectionResult.containsKey('CheckForPredictiveAudit'));
        }

        Core_MDF_AuditSelectionHelper auditSelection = new Core_MDF_AuditSelectionHelper(pfcList);
        //to cover Exception
        Core_MDF_AuditSelectionHelper.groupClaimsBasedOnAuditType(null,null);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(null,null,null);
        
        Test.startTest();
        
        // Invoke mock respnse
        Test.setMock(HttpCalloutMock.class, new Core_MDF_MockHttpResponseGenerator_Test());
        System.enqueueJob(auditSelection);
        
        //
        Map<PartnerFundClaim,String> claimToBeChecked = new Map<PartnerFundClaim,String>();
        claimToBeChecked.put(pfcList[0],'Random');
        claimToBeChecked.put(pfcList[1],'Random');
        claimToBeChecked.put(pfcList[2],'Random');
        claimToBeChecked.put(pfcList[3],'Predictive');
        claimToBeChecked.put(pfcList[4],'Predictive');
        claimToBeChecked.put(pfcList[5],'Predictive');
                
        User partnerUser = [SELECT Id, User.Name,LastName,email FROM User WHERE LastName='User Test1'];
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping = new Map<Id,String>{};
        String tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping.put(pfcList[3].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping.put(pfcList[4].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping.put(pfcList[5].Id,tempString);
            
        
        
        Map<Id,boolean> claimWithBoolean = new Map<Id,boolean>{};
        claimWithBoolean.put(pfcList[3].Id,true);
        claimWithBoolean.put(pfcList[4].Id,true);
        claimWithBoolean.put(pfcList[5].Id,true);
        claimWithBoolean.put(pfcList[0].Id,false);
        claimWithBoolean.put(pfcList[1].Id,false);
        claimWithBoolean.put(pfcList[2].Id,false);
    
        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked,xmlClaimMapping,claimWithBoolean);
//Core_MDF_AuditSelectionHelper.recheckClaims(null,null,null);
        //Create fake response
        String response = '<AdvancedBI>'+
                        '<header>'+
                        '<CycleID>07122018032444</CycleID>'+
                        '<RecordsNumber>1</RecordsNumber>'+
                        '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                        '</header>'+
                        '<Request>'+
                        '<Line Number="1">'+
                        '<ProjectId ID="118">'+
                        '<RequestID>'+pfcList[0].Core_MDF_Claim_Ref_Number__c+'</RequestID>'+
                        '<Program>Client Co-Marketing Fund</Program>'+
                        '<PredictionResult>Non-compliant High</PredictionResult>'+
                        '<PredictionScore>0.921954</PredictionScore>'+
                        '<ThresholdFlag>Yes</ThresholdFlag>'+
                        '<Probability>0.5666667</Probability>'+
                        '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                        '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                        '</ProjectId>'+
                        '</Line>'+
                        '</Request>'+
                        '</AdvancedBI>';

            //Reading xml response
            Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcList);
        Test.stopTest();

        String outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Predictive');
        System.AssertEquals('CAP',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Random');
        System.AssertEquals('Random',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Manual');
        System.AssertEquals('Manual',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist(NULL);

        //check escalation claim
        list<PartnerFundClaim> pfcEscalationList = [SELECT Id, Title, Core_MDF_Pred_PredictionResult__c, 
                                                    Core_MDF_IsClaimReviewEscalation_Ind__c,
                                                    Core_MDF_AuditSelectionInProgress__c,
                                                    Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,
                                                    Core_MDF_Audit_Type__c,
                                                    Core_MDF_FlaggedForAudit__c,Core_MDF_Exchange_rate__c,Amount,
                                                    CreatedById,Core_MDF_Predictive_Audit_Error__c,
                                                    Core_MDF_Predictive_Audit_Retries__c FROM PartnerFundClaim
                                            WHERE Title LIKE 'Test Claim%' LIMIT 11];
        for(PartnerFundClaim pfcEscalation:pfcEscalationList){
            if(pfcEscalation.Core_MDF_IsClaimReviewEscalation_Ind__c == true){
                System.AssertEquals(true,String.isEmpty(isEscalationTypeClm.Core_MDF_Pred_PredictionResult__c));
                System.AssertEquals(false,isEscalationTypeClm.Core_MDF_AuditSelectionInProgress__c);
                System.AssertEquals(false,isEscalationTypeClm.Core_MDF_FlaggedForAudit__c);
                System.AssertEquals(true,String.isEmpty(isEscalationTypeClm.Core_MDF_Audit_Type__c));
            }
            
        }
       
      
        
        //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
            
        // Covering exception of all the method by passing negative data 
        list<PartnerFundClaim> pfcExceptionList = [SELECT Id, Title, Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,Amount,
                                            CreatedById,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c FROM PartnerFundClaim
                                            WHERE Title LIKE 'Test Claim%' LIMIT 11];
                                            
                    //
        Map<PartnerFundClaim,String> claimToBeChecked1 = new Map<PartnerFundClaim,String>();
        claimToBeChecked1.put(pfcExceptionList[0],'Random');
        claimToBeChecked1.put(pfcExceptionList[1],'Random');
        claimToBeChecked1.put(pfcExceptionList[2],'Random');
        claimToBeChecked1.put(pfcExceptionList[3],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[4],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[5],'Predictive');            
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping1 = new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping1.put(pfcExceptionList[3].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[4].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[5].Id,tempString);
        /*
        Map<Id,String> xmlClaimMapping2 = new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping2.put(pfcExceptionList[0].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping2.put(pfcExceptionList[1].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping2.put(pfcExceptionList[2].Id,tempString);*/
        
        Map<Id,boolean> claimWithBoolean1 = new Map<Id,boolean>{};
        claimWithBoolean1.put(pfcExceptionList[3].Id,true);
        claimWithBoolean1.put(pfcExceptionList[4].Id,true);
        claimWithBoolean1.put(pfcExceptionList[5].Id,true);
        claimWithBoolean1.put(pfcExceptionList[0].Id,false);
        claimWithBoolean1.put(pfcExceptionList[1].Id,false);
        claimWithBoolean1.put(pfcExceptionList[2].Id,false);
        /*
        Map<Id,boolean> claimWithBoolean2 = new Map<Id,boolean>{};
        
        claimWithBoolean2.put(pfcExceptionList[0].Id,true);
        claimWithBoolean2.put(pfcExceptionList[1].Id,true);
        claimWithBoolean2.put(pfcExceptionList[2].Id,true);*/
        
        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked1,xmlClaimMapping1,claimWithBoolean1);
		//Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked2,xmlClaimMapping2,claimWithBoolean2);

        //Reading xml response
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcExceptionList);    
        
        // Calling getDateTimeForString method
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11/1/2018 3:17:30 PM ');
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11-1-2018 3:17:30:20 PM ');
		//Core_MDF_AuditSelectionHelper.setAuditStatus(null);
    }       
}