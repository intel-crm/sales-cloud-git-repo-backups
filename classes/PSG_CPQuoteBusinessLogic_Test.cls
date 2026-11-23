@isTest(seeAllData = false)
Public class PSG_CPQuoteBusinessLogic_Test {
    /*
    @testSetup
    public static void testsetUpData(){
        SBQQ.TriggerControl.disable();
        
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        Account acc = PSG_Test_Utility.createAccount();
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
        acc.Core_PSG_Account__c=true;
        acc.Core_Direct_Pricing_Parent_Id__c=a2.id;
        acc.Core_Direct_Legal_Parent_Id__c=a1.Id;
        update acc;
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        List<User> users = PSG_Test_Utility.createBOUser();
        System.runAs(users[0]){
            System.assert(!users.isEmpty(),'User');
            List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createCpQuote(acc.Id, con.Id, 1);
            lstquote[0].SBQQ__Status__c='Approved';
            update lstquote;
           Test.StartTest();
            List < SBQQ__QuoteLine__c > lstquoteLines = PSG_Test_Utility.createCpQuoteLines(lstquote[0].id, 1);
            List<SBQQ__Quote__Share> lstQuoteShare = PSG_Test_Utility.createQuoteShare(acc.Id, lstquote[0].Id);
            List<SBQQ__Quote__c> lstquoteUpdate=PSG_Test_Utility.updateQuote(lstquote); 
            
            Opportunity opp = PSG_Test_Utility.createOpportunity(acc.Id);
            SBQQ__Quote__c lstTPquote = PSG_Test_Utility.createQuoteRecord(acc.Id, opp.id);
            lstTPquote.core_cpq_quote_type_nm__c = 'Transfer Pricing';
            lstTPquote.SBQQ__Status__c='In Progress';
            insert lstTPquote;
            List<SBQQ__QuoteLine__c> QLList = PSG_Test_Utility.createQuoteLines(lstTPquote.Id,2);
            Test.StopTest();
        }
    }
    
    @isTest
    public static void testcpquote(){
        SBQQ.TriggerControl.disable();
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [Select Id from SBQQ__Quote__c];
        System.assert(lstquote[0].Id!=null,'Quote creation successfull');
        lstquote[0].SBQQ__Status__c='In Progress'; 
        update lstquote[0];
        lstquote[0].ApprovalStatus__c='Pending';
        update lstquote[0];
        lstquote[0].SBQQ__Status__c ='Approved';
        lstquote[0].core_cpq_active_cb__c=true;
        lstquote[0].core_cpq_Process_flag__c=false;
        lstquote[0].core_cpq_pricing_start_date_dt__c=Date.newInstance(2021, 07, 01);
        lstquote[0].ApprovalStatus__c='Approved';
        update lstquote[0];
        Test.stopTest();
    }
    
    @isTest
    public static void testcpquote_new(){
        SBQQ.TriggerControl.disable();
        Test.startTest();
        List<SBQQ__Quote__c> lstquote = [Select Id from SBQQ__Quote__c];
        System.assert(lstquote[0].Id!=null,'Quote creation successfull');
        lstquote[0].core_cpq_active_cb__c=true;
        lstquote[0].core_cpq_Process_flag__c=false;
        lstquote[0].core_cpq_pricing_start_date_dt__c=Date.newInstance(2021, 07, 01);
        lstquote[0].ApprovalStatus__c='Rejected';
        update lstquote[0];
        lstquote[0].ApprovalStatus__c='Recalled';
        update lstquote[0];
        Test.stopTest();
        lstquote[0].SBQQ__Status__c ='Cancelled';
        //lstquote[0].core_cpq_extended_cp_quote_cb__c =true;
        //update lstquote;
    }
    
    @istest 
    public static void testparentquote(){
        List<SBQQ__Quote__c> lstquote = [Select Id from SBQQ__Quote__c where core_cpq_quote_type_nm__c = 'Contract Pricing'];
        SBQQ__Quote__c lstTPquote =[Select Id from SBQQ__Quote__c where core_cpq_quote_type_nm__c = 'Transfer Pricing' limit 1];
        List<SBQQ__QuoteLine__c> QLList = [select id from SBQQ__QuoteLine__c where SBQQ__Quote__r.core_cpq_quote_type_nm__c='Transfer Pricing' limit 1];
        QLList[0].core_cpq_parent_quote__c=lstquote[0].Id;
        Test.startTest();
        update QLList;
        Map<String,String> newCPTOOldCPMap=new Map<String,String>();
        newCPTOOldCPMap.put(lstquote[0].Id, lstTPquote.Id);
        //PSG_CPQuoteBusinessLogic.ReplaceParentQuoteInTP(newCPTOOldCPMap);
        System.assert(lstquote[0].Id!=null,'Quote creation successfull');
        Test.stopTest();
    }
    */
}