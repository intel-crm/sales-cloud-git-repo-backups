/****************************************************************************************************
Apex Class Name : PSG_QuoteBusinessLogicTest 
Version         : 1.0 
Created Date    : 4/26/2021
Function        : Test class for PSG_QuoteBusinessLogic
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijaykanth                 4/26/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_QuoteBusinessLogicTest{
    /*@testSetup static void testSetup(){
        SBQQ.TriggerControl.disable();
        Test.startTest();
        Core_Contact_Bypass_Validation_Rule__c triggerExecList = new Core_Contact_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        Account dc = PSG_Test_Utility.createDirectAccount();
        System.assert(dc!=null, 'Account');
        Account ac=PSG_Test_Utility.createAccount();
        ac.Core_Direct_Pricing_Parent_Id__c=dc.id;
        ac.Core_Direct_Legal_Parent_Id__c=dc.id;
        update ac;
        Contact con = PSG_Test_Utility.createContact(ac.Id);
        //List<Account> accLst = PSG_Test_Utility.createRegionBasedAccount();
        List<Account> acclst = new list<Account>();
        
        Account accAPJ = new Account();
        accAPJ.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accAPJ.Name = 'Test Account'+math.random();
        accAPJ.Core_Account_Type__c = 'Distributor;End Customer';//added
        accAPJ.Industry = 'Banking';
        accAPJ.BillingCity = 'Texas';
        accAPJ.BillingCountry = 'USA';
        accAPJ.BillingStreet = 'G-2101'; 
        accAPJ.Core_Sales_Groups__c = 'APJ Taiwan Sales Group';//fixed for cpu 
        accAPJ.Core_Geo__c = 'APJ';
        accAPJ.Core_Sub_Geo__c = 'IJKK';
        accAPJ.Core_PSG_Account__c = true;
        accAPJ.Core_Account_Tier__c ='PSG-Tier 4';
        acclst.add(accAPJ);
        insert acclst;
        Contact con1 = PSG_Test_Utility.createContactWithEmail(accLst[0].Id,'FirstName2@intel.com');
        Opportunity opp = PSG_Test_Utility.createOpportunity(ac.Id);
        Opportunity opp1 = PSG_Test_Utility.createOpportunity(ac.Id);
        List<core_cpq_bm_assignment_config__c> approverList = PSG_Test_Utility.createApprvRecord(dc.Id);
        PriceBook2 pb = PSG_Test_Utility.createPriceBook('apj');
        Test.stopTest();
    }
    
    public static testmethod void createQuoteRecords(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<User> bmUser = PSG_Test_Utility.createBMUser();
        PriceBook2 pb = [SELECT id FROM Pricebook2 limit 1];
        list<Opportunity> opp = [Select Id,AccountId FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        Account accLst = [SELECT ID from Account limit 1];
        Contact con = [SELECT Id from Contact limit 1];
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
                
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Test.startTest();
           // Account a2=PSG_Test_Utility.createDirectAccount();
            Account a2 = new Account();
            a2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();      
        	a2.Name = 'Test Account'+math.random();
        	a2.Core_Account_Type__c = 'Distributor;End Customer';//added
        	a2.Industry = 'Banking';
        	a2.BillingCity = 'Texas';
        	a2.BillingCountry = 'USA';
        	a2.BillingStreet = 'G-2101'; 
        	a2.Core_Sales_Group_New__c = 'US Sales Group'; 
        	a2.Core_Geo__c = 'APJ';
        	a2.Core_Sub_Geo__c = 'IJKK';
        	a2.Core_PSG_Account__c = true;
        	a2.Core_Account_Tier__c ='PSG-Tier 4';
        	a2.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        	a2.Core_Is_Pricing_Parent_ChkBox__c=true;
        
            insert a2;
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_disty_group_name__c='PSG_ALTIMA';
            try{PSG_Test_Utility.createCpQuote(accsToUpdate[0].id, con.Id, 1);}catch(Exception e){}
            quote.core_cpq_origin_txt__c='Oppty';
            quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
             
            quoteList.add(quote);
            insert quoteList;
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id},null);
            QLList[0].core_cpq_quote_line_type_txt__c ='AVP';
            List<price_prid__c> prId = new List<price_prid__c>();
            price_prid__c prIdRec = new price_prid__c(); 
            prIdRec.core_cpq_active_cb__c = true;
            prIdRec.core_cpq_device__c = product[0].Id;
            prIdRec.core_cpq_sap_ecp_nm__c = accLst.Id;
            prIdRec.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec.core_cpq_type__c =Label.PSG_PRID_Type_AVP;
            prIdRec.price_amt__c = 200;
            prIdRec.core_cpq_quantity_eau_nbr__c = 100;
            prIdRec.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec.core_cpq_active_cb__c =false;
            prIdRec.core_cpq_active_pricing_cb__c = false;
            price_prid__c prIdRec2 = new price_prid__c();
            prIdRec2.core_cpq_active_cb__c = true;
            prIdRec2.core_cpq_device__c = product[0].Id;
            prIdRec2.core_cpq_sap_ecp_nm__c = accLst.Id;
            prIdRec2.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec2.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec2.core_cpq_type__c ='Flat';
            prIdRec2.price_amt__c = 200;
            prIdRec2.core_cpq_quantity_eau_nbr__c = 200;
            prIdRec2.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec2.core_cpq_active_pricing_cb__c = true;
            prId.add(prIdRec);
            prId.add(prIdRec2);
            insert prId;
            Test.stopTest();
            QLList[0].core_cpq_PRID__c = prId[0].Id;
            insert QLList;
            PSG_QuoteBusinessLogic.createPRIDRecords(quoteList[0].Id);
            quoteList[0].SBQQ__Status__c  = 'Approved'; 
            quoteList[0].core_cpq_price_book_nm__c = pb.Id ;
            quoteList[0].SBQQ__Opportunity2__c = opp[1].Id;  
            //quoteList[0].core_cpq_requestor_nm__c = sosUser[0].id;  
            quoteList[0].core_cpq_assigned_to_nm__c = sosUser[0].id;  
            quoteList[0].core_cpq_assigned_to_nm__c = sosUser[0].id;  
            quoteList[0].core_cpq_quote_type_nm__c  = 'Design Win';
            core_user_delegation__c delegateUser = new core_user_delegation__c();
            delegateUser.core_cpq_delegated_For__c = sosUser[0].Id;
            delegateUser.Start_Date__c = System.today();
            delegateUser.End_Date__c = System.today();
            delegateUser.core_cpq_delegated_to__c = bmUser[0].Id;
            insert delegateUser;
            //PSG_QuoteBusinessLogic.pendingQuoteEmailNotification(quoteList);
            PSG_QuoteBusinessLogic.sendAVPPRIDEmailAlert(new Set<Id>{QLList[0].Id},'PRC');
            
        }
    }
    
    public static testmethod void updateToPendingQuote(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            Test.startTest();
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            //SBQQ__Quote__C lstquote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            //quote.core_cpq_ultimate_parent_quote__c =lstquote.id;
            quote.core_cpq_origin_txt__c='Oppty';
            quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
            quote.core_cpq_assigned_to_nm__c = sosUser[0].Id;
            quote.core_cpq_ready_for_submission__c = true;
            quoteList.add(quote);
            insert quoteList;
            opp[1].AccountId=accsToUpdate[0].id;
            update opp[1];
            List<sbaa__Approval__c> appr =  PSG_Test_Utility.createApproval(quoteList[0].id);
            quoteList[0].SBQQ__Status__c = 'Pending';   
            quoteList[0].ApprovalStatus__c = 'Pending';  
            quoteList[0].SBQQ__Opportunity2__c = opp[1].Id;    
           // quoteList[0].core_cpq_active_cb__c = false; //added 
            string ex;
            try{update quoteList[0];}catch(exception e){
                 ex=e.getMessage();
            }
            assert.areNotEqual(ex, 'Please click Edit Lines and check \'Ready for Submission\' in-order to submit the Quote for Approval');
            
            Test.stopTest();
        }
            
      
    }
    
    public static testmethod void updateToSubmitQuote(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<User> bmUser = PSG_Test_Utility.createBMUser();
        list<Opportunity> opp = [Select Id,AccountId FROM Opportunity limit 1];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Test.startTest();
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;            
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quote.core_cpq_assigned_to_nm__c = sosUser[0].Id;
            quoteList.add(quote);
            insert quoteList;
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLines(quoteList[0].Id,2);
            Test.stopTest();
        }
        System.runAs(bmUser[0]){
            quoteList[0].SBQQ__Status__c = 'Approved';
            quoteList[0].core_cpq_assigned_to_nm__c = bmUser[0].Id;
            quoteList[0].core_cpq_end_customer_nm__c = opp[0].AccountId;
            update quoteList[0];
        } 
    }
    
    
    
    public static testmethod void inactiveQuote(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<User> bmUser = PSG_Test_Utility.createBMUser();
        list<Opportunity> opp = [Select Id FROM Opportunity limit 1];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        Account a1=PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId=recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c=true;
        a1.Core_Direct_Account_Active_Ind__c=true;
        update a1;
        Account a2=PSG_Test_Utility.createDirectAccount();
        a2.RecordTypeId=recordtypeId;
        a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a2.Core_Is_Pricing_Parent_ChkBox__c=true;
        a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
        a2.Core_Direct_Account_Active_Ind__c=true;
        update a2;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            Test.startTest();
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quoteList.add(quote);
            insert quoteList;
            //List<sbaa__Approval__c> appr =  PSG_Test_Utility.createApproval(quoteList[0].id); 
            //PSG_QuoteBusinessLogic.getApprovers(appr); 
            Test.stopTest();
        }
        quoteList[0].SBQQ__Status__c = 'Rejected';
        quoteList[0].ApprovalStatus__c = 'Rejected';
        quoteList[0].core_cpq_active_cb__c = false;
        update quoteList[0];
    }
    
    @isTest
    public static void testCreatePRID(){
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        Map<ID,ID> quoteToOwnerId=new Map<Id,Id>();
        System.RunAs(sosUser[0]){
            SBQQ.TriggerControl.disable();
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;    
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;   
            Test.startTest();
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quoteList.add(quote);            
            insert quoteList;            
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id},null);            
            insert QLList;
            Test.stopTest();
            PSG_QuoteBusinessLogic.createPRIDRecords(quoteList[0].Id);
        }
    }
   
    
   @isTest
    public static void testSendEmailNotification(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();        
        PriceBook2 pb = [SELECT id FROM Pricebook2 limit 1];
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        Opportunity opp1 = PSG_Test_Utility.createOpportunity(accs[1].Id);
        List<Account> accsToUpdate=new List<Account>();
        Id UserId=UserInfo.getUserId();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account'); 
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            pricebook2 pb1=PSG_Test_Utility.createPriceBook('Intel processor2');
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quote.core_cpq_assigned_to_nm__c=sosUser[0].Id;
            quote.core_cpq_price_book_nm__c=pb1.Id;
            quote.core_cpq_assigned_on__c=System.now();
            quoteList.add(quote);
            insert quoteList;
            //PSG_QuoteBusinessLogic.sendEmailNotification(quoteList);
            //PSG_QuoteBusinessLogic.sendQuoteAssignedNotification(quoteList, Label.PSG_Quote_Re_Assigned_To_Notification);
            quoteList[0].core_cpq_assigned_to_nm__c=UserId;
            quoteList[0].core_cpq_active_cb__c=true;
            Test.startTest();
            update quoteList;
            //PSG_QuoteBusinessLogic.createQuoteHistory(new Map<Id,SBQQ__Quote__C>(quoteList),new Map<Id,SBQQ__Quote__C>(quoteList));
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id},null);
            insert QLList;
            PricebookEntry pbe=new PricebookEntry();
            pbe.Product2Id=product[0].Id;
            pbe.Pricebook2Id=pb1.Id;
            pbe.UnitPrice=500;
            pbe.IsActive=true;
            insert pbe;
            //PSG_QuoteBusinessLogic.goalandSuggestedResaleValidation(quoteList[0]);
            quoteList[0].core_cpq_quote_type_nm__c='Budgetary';
            //PSG_QuoteBusinessLogic.goalandSuggestedResaleValidation(quoteList[0]);
            core_cpq_list_price__c cCpq=new core_cpq_list_price__c();
            ccpq.Pricebookentry__c=pbe.Id;
            ccpq.core_cpq_lowerbound_qty__c=10;
            ccpq.core_cpq_upperbound_qty__c=20;
            ccpq.core_cpq_list_price_amt__c=15;
            insert ccpq;
            PSG_QuoteBusinessLogic.updateRelatedQuoteLines(new Map<Id,SBQQ__Quote__C>(quoteList),new set<Id>{pb1.Id});
            //PSG_QuoteBusinessLogic.createQuoteHistory(new Map<Id,SBQQ__Quote__C>(quoteList),new Map<Id,SBQQ__Quote__C>(quoteList));
            Test.stopTest(); 
        }
    } 
    
    @isTest
    public static void testCreateQuoteHistory(){
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id UserId=UserInfo.getUserId();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            pricebook2 pb1=PSG_Test_Utility.createPriceBook('Intel processor2');
            Test.startTest();
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quote.core_cpq_assigned_to_nm__c=sosUser[0].Id;
            quote.core_cpq_assigned_to_nm__c=sosUser[0].Id;
            quote.core_cpq_assigned_on__c=System.now();
            quoteList.add(quote);
            SBQQ__Quote__C quote1 = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote1.core_cpq_origin_txt__c='Oppty';
            quote1.core_cpq_assigned_to_nm__c=sosUser[0].Id;
            quote1.core_cpq_assigned_to_nm__c=sosUser[0].Id;
            quote1.core_cpq_assigned_on__c=System.now();
            quoteList.add(quote1);
            insert quoteList;
            SBQQ__Quote__C q=new SBQQ__Quote__C();
            q.Id=quoteList[0].Id;
            q.core_cpq_assigned_on__c=System.now()+1;
            q.core_cpq_assigned_to_nm__c=quoteList[0].core_cpq_assigned_to_nm__c;
            SBQQ__Quote__C q1=new SBQQ__Quote__C();
            q1.Id=quoteList[1].Id;
            q1.core_cpq_assigned_on__c=quoteList[1].core_cpq_assigned_on__c;
            q1.core_cpq_assigned_by_nm__c=quoteList[1].core_cpq_assigned_by_nm__c;
            q1.core_cpq_assigned_to_nm__c=UserId;
            Map<Id,SBQQ__Quote__C> newMap=new Map<Id,SBQQ__Quote__C>();
            newMap.put(q.Id,q);
            newMap.put(q1.Id,q1);
            //PSG_QuoteBusinessLogic.createQuoteHistory(new Map<Id,SBQQ__Quote__C>(quoteList),newMap);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getApproversTest(){
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        List<sbaa__Approver__c> approvers=new List<sbaa__Approver__c>();
        List<sbaa__Approval__c> approvals=new List<sbaa__Approval__c>();
        List<GroupMember> gms=new List<GroupMember>();
        List<Group> groups=[Select Id from Group where developername='ags_business_admin'];
        List<Account> accs=[SELECT Id from Account limit 10];
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        Group g=new Group(Name='Test Group',DeveloperName='ags_test_group');
        insert g;
        GroupMember gm=new GroupMember();
        gm.GroupId=groups[0].Id;
        gm.UserOrGroupId=sosUser[0].Id;
        GroupMember gm1=new GroupMember();
        gm1.GroupId=groups[0].Id;
        gm1.UserOrGroupId=g.Id;
        gms.add(gm1);
        insert gms;
        System.runAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            SBQQ__Quote__c quote=PSG_Test_Utility.createQuoteRecord(opp[0].Id,accs[0].Id);
            sbaa__Approver__c app1=new sbaa__Approver__c();
            app1.Name='Test Approver';
            app1.sbaa__GroupId__c=groups[0].Id;
            app1.sbaa__User__c=sosUser[0].Id;
            approvers.add(app1);
            sbaa__Approver__c app2=new sbaa__Approver__c();
            app2.Name='Delegated Approver';
            app2.sbaa__User__c=sosUser[0].Id;
            approvers.add(app2);
            sbaa__Approver__c app3=new sbaa__Approver__c();
            app3.Name='Test Approver1';
            app3.sbaa__GroupId__c=g.Id;
            app3.sbaa__User__c=sosUser[0].Id;
            approvers.add(app3);
            Test.startTest();
            insert approvers;
            sbaa__Approval__c approval=new sbaa__Approval__c();
            approval.sbaa__Approver__c=app1.Id;
            approval.sbaa__DelegatedApprover__c=app2.Id;
            approval.sbaa__Status__c='Requested';
            approval.sbaa__ApprovalStep__c=1;
            approval.sbaa__RecordField__c='Quote__c';
            approval.Quote__c=quote.id;
            approvals.add(approval);
            sbaa__Approval__c approval1=new sbaa__Approval__c();
            approval1.sbaa__Approver__c=app3.Id;
            approval1.sbaa__DelegatedApprover__c=app2.Id;
            approval1.sbaa__Status__c='Requested';
            approval1.sbaa__ApprovalStep__c=1;
            approval1.sbaa__RecordField__c='Quote__c';
            approval1.Quote__c=quote.id;
            approvals.add(approval1);
            insert approvals;
            //PSG_QuoteBusinessLogic.getApprovers(approvals);
            Test.stopTest(); 
        }  
    }
   
    @isTest
    public static void opptyChangeTest(){
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        SBQQ.TriggerControl.disable();
        List<User> bmUser = PSG_Test_Utility.createBMUser();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();        
        System.runAs(bmUser[0]){
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            Account a3=PSG_Test_Utility.createDirectAccount();
            a3.RecordTypeId=recordtypeId;
            a3.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a3.Core_Is_Pricing_Parent_ChkBox__c=true;
            a3.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a3.Core_Direct_Account_Active_Ind__c=true;
            update a3;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            SBQQ__Quote__C quote1 = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote1.core_cpq_origin_txt__c='Oppty';
            quote1.core_cpq_assigned_on__c=System.now();
            insert quote1;
            Test.startTest();
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quote1.Id,new Set<Id>{product[0].Id},null);
            insert QLList;
            accsToUpdate[0].Core_Direct_Pricing_Parent_Id__c=a3.Id;
            update  accsToUpdate[0];
            quote1.SBQQ__Opportunity2__c=null;
            update quote1;
            Test.stopTest();
        }
    }
    @isTest
    public static void testApprovalLevel(){
        SBQQ.TriggerControl.disable();
        List<User> bmUser = PSG_Test_Utility.createBMUser();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 1];
        Account a1 = PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId=recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c=true;
        a1.Core_Direct_Account_Active_Ind__c=true;
        update a1;
        List<sbaa__Approval__c> apprList = new List<sbaa__Approval__c>();
        //List<Opportunity> opp = [Select Id FROM Opportunity limit 1];
        //Contact con = PSG_Test_Utility.createContact(accs[0].id);
        //List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Test.startTest();
        System.runAs(bmUser[0]){
            List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(accs[0].Id,null,1);
            quoteList[0].core_cpq_ready_for_submission__c = true;
            update quoteList;
            List<Product2> product = PSG_Test_Utility.createProduct(2);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id,product[1].Id},null);
            QLList[0].price_brokencost_amt__c = 15;
            QLList[1].price_brokencost_amt__c = 18;
            insert QLList;
            Test.stopTest();
            List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
            approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'BM Approval Rule', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
            insert approverRuleList;
            List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
            sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = bmUser[0].Id, Quote__c = quoteList[0].Id, sbaa__Rule__c = approverRuleList[0].Id);
            approvalList.add(appr1);
            insert approvalList;
            List<core_cpq_bm_approval_threshold__c> threshold = new List<core_cpq_bm_approval_threshold__c>();
            core_cpq_bm_approval_threshold__c threshold1 = new core_cpq_bm_approval_threshold__c();
            threshold1.core_cpq_bm_level_txt__c = 'Level 1';
            threshold1.core_cpq_business_unit_nm__c = 'Test';
            threshold1.core_cpq_intel_margin_pct__c = 30.00;
            threshold1.price_peak_annual_amt__c = 2000;
            threshold.add(threshold1);
            insert threshold;
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList); 
            QLList[0].price_brokencost_amt__c = 30;
            QLList[0].SBQQ__Quantity__c = 10;
            update QLList;
            quoteList[0].core_cpq_business_unit_nm__c = 'Test';
            update quoteList;
            List<SBQQ__Quote__c> quoteList1 = [Select Id,core_cpq_business_unit_nm__c,core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c WHERE Id IN : quoteList];
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList1);
            SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accs[0].Id,null);
            quote.SBQQ__Type__c = 'Renewal';
            insert quote;
        }
    }
	//new test methods
	@isTest
    public static void testCreatePRIDCP(){
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        list<Opportunity> opp = [Select Id FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        Map<ID,ID> quoteToOwnerId=new Map<Id,Id>();
        System.RunAs(sosUser[0]){
            SBQQ.TriggerControl.disable();
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account accLst = [SELECT ID from Account limit 1];
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;   
            Test.startTest();
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            SBQQ__Quote__C quote = PSG_Test_Utility.createCPQuoteRecord(accsToUpdate[0].id, opp[0].id);
            quote.core_cpq_origin_txt__c='Oppty';
            quoteList.add(quote);            
            insert quoteList;
			
            List<Product2> product = PSG_Test_Utility.createProduct(1);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id},null);
			/*QLList[0].Delete_OPN__c = true;
            List<price_prid__c> prId = new List<price_prid__c>();
            price_prid__c prIdRec = new price_prid__c(); 
            prIdRec.core_cpq_active_cb__c = true;
            prIdRec.core_cpq_device__c = product[0].Id;
            prIdRec.core_cpq_sap_ecp_nm__c = accLst.Id;
            prIdRec.core_cpq_lower_bound_qty_nbr__c =  1;
            prIdRec.core_cpq_upper_bound_qty_nbr__c = 100;
            prIdRec.core_cpq_type__c =Label.PSG_PRID_Type_AVP;
            prIdRec.price_amt__c = 200;
            prIdRec.core_cpq_quantity_eau_nbr__c = 100;
            prIdRec.core_cpq_update_underlying_quotelines_cb__c =true;
            prIdRec.core_cpq_active_cb__c =false;
            prIdRec.core_cpq_active_pricing_cb__c = false;
      		prId.add(prIdRec);
            insert prId;
            QLList[0].core_cpq_PRID__c = prId[0].Id;*/
            /*insert QLList[0];
            Test.stopTest();
            PSG_QuoteBusinessLogic.createPRIDRecords(quoteList[0].Id);
        }
    }
	@isTest
    public static void testApprovalLevel2(){
        SBQQ.TriggerControl.disable();
        List<User> boUser = PSG_Test_Utility.createBOUser();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 1];
        Account a1 = PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId=recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c=true;
        a1.Core_Direct_Account_Active_Ind__c=true;
        update a1;
        List<sbaa__Approval__c> apprList = new List<sbaa__Approval__c>();
        //List<Opportunity> opp = [Select Id FROM Opportunity limit 1];
        //Contact con = PSG_Test_Utility.createContact(accs[0].id);
        //List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Test.startTest();
        System.runAs(boUser[0]){
            List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(accs[0].Id,null,1);
            quoteList[0].core_cpq_ready_for_submission__c = true;
            update quoteList;
            List<Product2> product = PSG_Test_Utility.createProduct(2);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id,product[1].Id},null);
            QLList[0].price_brokencost_amt__c = 15;
            QLList[1].price_brokencost_amt__c = 18;
            insert QLList;
            Test.stopTest();
            List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
            approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'BO Approval Rule', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
            insert approverRuleList;
            List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
            sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = boUser[0].Id, Quote__c = quoteList[0].Id, sbaa__Rule__c = approverRuleList[0].Id);
            approvalList.add(appr1);
            insert approvalList;
            List<core_cpq_bm_approval_threshold__c> threshold = new List<core_cpq_bm_approval_threshold__c>();
            core_cpq_bm_approval_threshold__c threshold1 = new core_cpq_bm_approval_threshold__c();
            threshold1.core_cpq_bm_level_txt__c = 'Level 1';
            threshold1.core_cpq_business_unit_nm__c = 'Test';
            threshold1.core_cpq_intel_margin_pct__c = 30.00;
            threshold1.price_peak_annual_amt__c = 2000;
            threshold.add(threshold1);
            insert threshold;
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList); 
            QLList[0].price_brokencost_amt__c = 30;
            QLList[0].SBQQ__Quantity__c = 10;
            update QLList;
            quoteList[0].core_cpq_business_unit_nm__c = 'Test';
            update quoteList;
            List<SBQQ__Quote__c> quoteList1 = [Select Id,core_cpq_business_unit_nm__c,core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c WHERE Id IN : quoteList];
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList1);
            SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accs[0].Id,null);
            quote.SBQQ__Type__c = 'Renewal';
            insert quote;
        }
    }

    @isTest
    public static void testApprovalLevel3(){
        SBQQ.TriggerControl.disable();
        List<User> sosUser = PSG_Test_Utility.createSOSUser();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 1];
        Account a1 = PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId=recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c=true;
        a1.Core_Direct_Account_Active_Ind__c=true;
        update a1;
        List<sbaa__Approval__c> apprList = new List<sbaa__Approval__c>();
        //List<Opportunity> opp = [Select Id FROM Opportunity limit 1];
        //Contact con = PSG_Test_Utility.createContact(accs[0].id);
        //List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Test.startTest();
        System.runAs(sosUser[0]){
            List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(accs[0].Id,null,1);
            quoteList[0].core_cpq_ready_for_submission__c = true;
            update quoteList;
            List<Product2> product = PSG_Test_Utility.createProduct(2);
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLinesWithoutInsert(quoteList[0].Id,new Set<Id>{product[0].Id,product[1].Id},null);
            QLList[0].price_brokencost_amt__c = 15;
            QLList[1].price_brokencost_amt__c = 18;
            insert QLList;
            Test.stopTest();
            List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
            approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'SOS Approval Rule', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
            insert approverRuleList;
            List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
            sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = sosUser[0].Id, Quote__c = quoteList[0].Id, sbaa__Rule__c = approverRuleList[0].Id);
            approvalList.add(appr1);
            insert approvalList;
            List<core_cpq_bm_approval_threshold__c> threshold = new List<core_cpq_bm_approval_threshold__c>();
            core_cpq_bm_approval_threshold__c threshold1 = new core_cpq_bm_approval_threshold__c();
            threshold1.core_cpq_bm_level_txt__c = 'Level 1';
            threshold1.core_cpq_business_unit_nm__c = 'Test';
            threshold1.core_cpq_intel_margin_pct__c = 30.00;
            threshold1.price_peak_annual_amt__c = 2000;
            threshold.add(threshold1);
            insert threshold;
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList); 
            QLList[0].price_brokencost_amt__c = 30;
            QLList[0].SBQQ__Quantity__c = 10;
            update QLList;
            quoteList[0].core_cpq_business_unit_nm__c = 'Test';
            update quoteList;
            List<SBQQ__Quote__c> quoteList1 = [Select Id,core_cpq_business_unit_nm__c,core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c WHERE Id IN : quoteList];
            PSG_QuoteBusinessLogic.calculateApprovalLevel(quoteList1);
            SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accs[0].Id,null);
            quote.SBQQ__Type__c = 'Renewal';
            insert quote;
        }
    }*/
}