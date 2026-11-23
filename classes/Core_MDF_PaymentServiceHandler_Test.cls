/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentServiceHandler_Test
* Version     : 1.0 
* Created Date: 02-05-2019
* Modification Log :
* Developer           HA          Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza Akhtar                   02-05-2019                    Test class for Core_MDF_PaymentServiceHandler class
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PaymentServiceHandler_Test {
    
    //Method for creating activity, claim and bank for associating it to a payment record
    @TestSetUp
    static void creatingPaymentRecords(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            //test.startTest();
         
            Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
            triggerActive.NAME = 'processInboundMessagesERPM';
            triggerActive.Core_Active__c = TRUE;
            triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
            triggerActive.Core_Description__c = 'Process inbound ERPM messages from iPaaS';
            triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
            triggerActive.Core_Trigger_Events__c = 'after insert, after update';
            insert triggerActive;
            
            
            List<Core_MDF_CCP_EmailContentTranslationMap__mdt> metaData = [SELECT Id, Core_MDF_MailSubject__c, Core_MDF_MailBody1__c, 
                                                                           Core_MDF_MailBody2__c,Core_MDF_MailBody3__c, Core_MDF_MailBody4__c, 
                                                                           Core_MDF_MailBody5__c, Core_MDF_MailBody6__c,  Core_MDF_MailBody7__c,
                                                                           Core_MDF_MailFooter1__c, Core_MDF_MailFooter2__c, Core_MDF_MailFooter3__c, 
                                                                           Core_MDF_MailFooter4__c, Core_MDF_MailFooter5__c, Core_MDF_Program__c,  
                                                                           Core_MDF_MailBody8__c,Core_MDF_MailBody9__c, Core_MDF_LocaleKey__c,
                                                                           Core_MDF_Translated_Program__c,Core_MDF_MailBody8_1__c
                                                                           FROM   Core_MDF_CCP_EmailContentTranslationMap__mdt];
            Test.startTest();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            
            
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            
            
            Id contactRecordTypeIntel = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            conRecord1.Core_Audience_List__c = 'CCF Account Budget Administrator;CCF User';
            conRecord1.RecordTypeId = contactRecordTypeIntel;
            insert conRecord1;
            
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = profileId;
            usr1.isActive = true;
            Database.insert(usr1);
            
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id,usr1.Id, true);
            
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank1.Id, true);
            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,10000,System.today() -20,System.today().addDays(40), true);
            
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,10000,true);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
            
            Test.stopTest();
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(acc2.id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c  = system.today();
            pfr.Amount = 0;
            insert pfr;
            
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today();
            record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record2);
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today();
            record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record3);
            database.insert(newValues);
            
            list<PartnerFundClaim> claimList = new list<PartnerFundClaim>();
            for(integer i=1; i<=4; i++){
                PartnerFundClaim newClaim = new PartnerFundClaim();
                newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                    Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                    System.today(), System.today(), 122, 
                                                                    System.today(), bank1.Id, false);
                newClaim.Core_MDF_Currency__c = 'USD';
                newClaim.Core_MDF_Type_Txt__c = 'Claim';
                newClaim.Core_MDF_Taxes_Local__c = 0;
                newClaim.Core_MDF_Type_Txt__c = System.Label.Core_MDF_Claim_Type;
                claimList.add(newClaim);
            }
            insert claimList;
            
            
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            
            List<PartnerFundClaim> updatedClaimList = [SELECT Id, Core_MDF_Payment_Id__c, Core_MDF_Status__c, Status FROM PartnerFundClaim LIMIT 50];
            Core_MDF_Payment__c newPayment = new Core_MDF_Payment__c();
            newPayment.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            insert newPayment;
            
            Core_MDF_Payment__c newPayment1 = new Core_MDF_Payment__c();
            newPayment1.Core_MDF_Payment_Status_Txt__c = 'Pending Payment';
            newPayment1.Core_MDF_Payment_Run_Id__c = payRunRecord.Id;
            insert newPayment1;
            
            Integer count = 0;
            List<PartnerFundClaim> paymentDueClaimList = new list<PartnerFundClaim>();
            for(PartnerFundClaim pfc : updatedClaimList){
                count++;
                //if(pfc.Core_MDF_Status__c == 'Submitted'){
                pfc.Core_MDF_Status__c = 'Pending Payment';
                pfc.Core_MDF_Payment_Id__c = newPayment.Id;
                if(count > 1){
                    pfc.Core_MDF_Payment_Id__c = newPayment1.Id;
                }
                paymentDueClaimList.add(pfc);
                //}
            }
            
            if(paymentDueClaimList.size() > 0){
                update paymentDueClaimList;
            }            
        }
    }
    
    //Method for bulk testing the payment and claim
    
    @isTest
    static void bulkTesting(){
        
        List<PartnerFundClaim> fundClaim = [SELECT Id, Core_MDF_Status__c, Status, Core_MDF_Payment_Id__c
                                            FROM PartnerFundClaim
                                            WHERE Core_MDF_Status__c = 'Pending Payment' LIMIT 50];
        
        List<Core_MDF_Payment__c> pendingPayment = [SELECT Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c, Core_MDF_Payment_No_Txt__c
                                                    FROM Core_MDF_Payment__c
                                                    WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 50];
        String constructingPayload = '[';
        for(integer index=0; index < pendingPayment.size(); index++){
            constructingPayload +=  '{"Core_MDF_Payment_No_Txt": "' + pendingPayment[index].Core_MDF_Payment_No_Txt__c + 
                '","Core_MDF_EFT_Nbr": "ABCD123123","Core_MDF_Payment_Made_Dt": "31-Jan-2019",' +
                '"Core_MDF_Payment_Status_Txt": "PAID"},';
        }
        String payload = constructingPayload.removeEnd(',') + ']';
        
        test.startTest();
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Payload__c = payload;
        iim.Core_Message_Type__c = 'Payment';
        iim.Core_Source_System__c = 'EDW';
        insert iim;
        
        List<PartnerFundClaim> paidFundClaims = [SELECT Id, Core_MDF_Status__c, Status, Core_MDF_Payment_Id__c
                                                 FROM PartnerFundClaim
                                                 LIMIT 50];
        
        System.assert(paidFundClaims[0].Id != NULL);
        test.stopTest();
    }
    //Checking the exception block by updating the incorrect payload
    
    @isTest
    static void updateIncorrectPaymentRecord(){        
        Core_MDF_Payment__c correctPaymentRecord = [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                    FROM Core_MDF_Payment__c 
                                                    WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 1];
        test.startTest();
        Core_Integration_Inbound_Message__c payLoad = new Core_Integration_Inbound_Message__c();
        payLoad.Core_Payload__c = '[{"Core_MDF_Payment_No_Txt": "' + correctPaymentRecord.Core_MDF_Payment_No_Txt__c + 
            '","Core_MDF_EFT_Nbr": "ABCD123123","Core_MDF_Payment_Made_Dt": "31-January-2019",' +
            '"Core_MDF_Payment_Status_Txt": "Paid"}]';
        payLoad.Core_Message_Type__c = 'Payment';
        payLoad.Core_Source_System__c = 'EDW';
        insert payLoad;
        
        Core_MDF_Payment__c incorrectUpdatedPaymentRecord = [SELECT Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                             FROM Core_MDF_Payment__c
                                                             WHERE Id =: correctPaymentRecord.Id];        
        System.assertEquals('Pending Payment',incorrectUpdatedPaymentRecord.Core_MDF_Payment_Status_Txt__c);
        test.stopTest();
    }
    
    //Check for the dummy payment update
    
    @isTest
    static void dummyPaymentCheck(){  
              
        Core_MDF_Payment__c paymentRecord = [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                             FROM Core_MDF_Payment__c 
                                             WHERE Core_MDF_Payment_Status_Txt__c = 'Pending Payment' LIMIT 1];      
        test.startTest();
        
        Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
        iim.Core_Payload__c = '[{"Core_MDF_Payment_No_Txt": "' + paymentRecord.Core_MDF_Payment_No_Txt__c + 
            '","Core_MDF_EFT_Nbr": "","Core_MDF_Payment_Made_Dt": "31-Jan-2019",' +
            '"Core_MDF_Payment_Status_Txt": "Pending Payment"}]';
        iim.Core_Message_Type__c = 'Payment';
        iim.Core_Source_System__c = 'EDW';
        insert iim;
        
        Core_MDF_Payment__c correctUpdatedPaymentRecord = [SELECT Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c 
                                                           FROM Core_MDF_Payment__c
                                                           WHERE Id =:paymentRecord.Id];
        System.assertEquals('Pending Payment',correctUpdatedPaymentRecord.Core_MDF_Payment_Status_Txt__c);   
        test.stopTest();   
    }
    
    //Methods to check the Integration Inbound Message payload
    
    @isTest
    static void insertPayLoadForContact(){
        Core_Integration_Inbound_Message__c contactPayLoad = new Core_Integration_Inbound_Message__c();
        contactPayLoad.Core_Message_Type__c = 'Contact';
        contactPayLoad.Core_Source_System__c = 'ERPM';
        insert contactPayLoad;
        System.assert(contactPayLoad.Core_Source_System__c == 'ERPM');
    }
    
    @isTest
    static void insertPayLoadForAccount(){
        Core_Integration_Inbound_Message__c accountPayLoad = new Core_Integration_Inbound_Message__c();
        accountPayLoad.Core_Message_Type__c = 'Account';
        accountPayLoad.Core_Source_System__c = 'ERPM';
        insert accountPayLoad;
        System.assert(accountPayLoad.Core_Source_System__c == 'ERPM');
    }
    
    @isTest
    static void insertPayLoadForBlackBox(){
        Core_Integration_Inbound_Message__c blackBoxPayLoad = new Core_Integration_Inbound_Message__c();
        blackBoxPayLoad.Core_Message_Type__c = 'Blackbox';
        blackBoxPayLoad.Core_Source_System__c = 'ERPM';
        insert blackBoxPayLoad;
        System.assert(blackBoxPayLoad.Core_Source_System__c == 'ERPM');
    }
    
    @isTest
    static void insertPayLoadForAGS(){
        
        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessagesAGS';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound AGS messages from iPaaS';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'after insert, after update';
        insert triggerActive;
        
        Core_Integration_Inbound_Message__c rolePayLoad = new Core_Integration_Inbound_Message__c();
        rolePayLoad.Core_Message_Type__c = 'Role';
        rolePayLoad.Core_Source_System__c = 'AGS';
        insert rolePayLoad;
        System.assert(rolePayLoad.Core_Source_System__c == 'AGS');
    }
    
    @isTest
    static void insertPayLoadForQuote(){
        
        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessages';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound messages from iPaas';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'before insert, before update';
        insert triggerActive;
        
        Core_Integration_Inbound_Message__c quotePayLoad = new Core_Integration_Inbound_Message__c();
        quotePayLoad.Core_Message_Type__c = 'Quote';
        insert quotePayLoad;
        System.assert(quotePayLoad.Core_Message_Type__c == 'Quote');
    }
    
}