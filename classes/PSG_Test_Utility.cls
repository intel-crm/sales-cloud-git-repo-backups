@isTest
public without sharing class PSG_Test_Utility {
    /*Public static PermissionSet permissionRec;
    Static{
        permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User  OR Name=:Label.PSG_CPQ_AA_License Limit 1];
    }
    
    
    public static list<Account> createRegionBasedAccount(){
        list<Account> acclst = new list<Account>();
        
        Account accAPJ = new Account();
        accAPJ.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accAPJ.Name = 'Test Account'+System.now();
        accAPJ.Core_Account_Type__c = 'Distributor;End Customer';//added
        accAPJ.Industry = 'Banking';
        accAPJ.BillingCity = 'Texas';
        accAPJ.BillingCountry = 'USA';
        accAPJ.BillingStreet = 'G-2101'; 
        accAPJ.Core_Sales_Groups__c = 'US Sales Group'; 
        accAPJ.Core_Geo__c = 'APJ';
        accAPJ.Core_Sub_Geo__c = 'IJKK';
        accAPJ.Core_PSG_Account__c = true;
        accAPJ.Core_Account_Tier__c ='PSG-Tier 4';
        acclst.add(accAPJ);
        
        Account accEMEA = new Account();
        accEMEA.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accEMEA.Name = 'Test Account'+System.now();
        accEMEA.Core_Account_Type__c = 'Distributor;End Customer';//added
        accEMEA.Industry = 'Banking';
        accEMEA.BillingCity = 'Texas';
        accEMEA.BillingCountry = 'USA';
        accEMEA.BillingStreet = 'G-2101'; 
        accEMEA.Core_Sales_Groups__c = 'US Sales Group'; 
        accEMEA.Core_Geo__c = 'EMEA';
        accEMEA.Core_Sub_Geo__c = 'IJKK';
        accEMEA.Core_PSG_Account__c = true;
        accEMEA.Core_Account_Tier__c ='PSG-Tier 4';
        acclst.add(accEMEA);
        
        Account accASMO = new Account();
        accASMO.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accASMO.Name = 'Test Account'+System.now();
        accASMO.Core_Account_Type__c = 'Distributor;End Customer';//added
        accASMO.Industry = 'Banking';
        accASMO.BillingCity = 'Texas';
        accASMO.BillingCountry = 'USA';
        accASMO.BillingStreet = 'G-2101'; 
        accASMO.Core_Sales_Groups__c = 'US Sales Group'; 
        accASMO.Core_Geo__c = 'ASMO';
        accASMO.Core_Sub_Geo__c = 'IJKK';
        accASMO.Core_PSG_Account__c = true;
        accASMO.Core_Account_Tier__c ='PSG-Tier 4';
        acclst.add(accASMO);
        
        Account accPRC = new Account();
        accPRC.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accPRC.Name = 'Test Account'+System.now();
        accPRC.Core_Account_Type__c = 'Distributor;End Customer';//added
        accPRC.Industry = 'Banking';
        accPRC.BillingCity = 'Texas';
        accPRC.BillingCountry = 'USA';
        accPRC.BillingStreet = 'G-2101'; 
        accPRC.Core_Sales_Groups__c = 'US Sales Group'; 
        accPRC.Core_Geo__c = 'PRC';
        accPRC.Core_Sub_Geo__c = 'IJKK';
        accPRC.Core_PSG_Account__c = true;
        accPRC.Core_Account_Tier__c ='PSG-Tier 4';
        acclst.add(accPRC);
        insert acclst; 
        
        return accLst;
    }
    
    public static List<core_cpq_dpa_aln__c> createDPA(Id quoteId){
        List<core_cpq_dpa_aln__c> dpaList = new List<core_cpq_dpa_aln__c>();
        for(core_cpq_dpa_aln__c dpa: dpaList){
            dpa.core_cpq_active_quote__c = quoteId; 
            dpa.core_cpq_status_txt__c = 'New'; 
            dpaList.add(dpa);
        }
        insert dpaList;
        return dpaList;
    }
    
    
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.Name = 'Test Account'+ math.random();
        acc.Core_Account_Type__c = 'Distributor;End Customer';//added
        acc.Industry = 'Banking';
        acc.BillingCity = 'Texas';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'G-2101'; 
        acc.Core_Sales_Groups__c = 'EMEA Sales Group'; 
        acc.Core_Geo__c = 'APJ';
        acc.Core_Sub_Geo__c = 'IJKK';
        acc.Core_PSG_Account__c = true;
        acc.Core_Account_Tier__c ='PSG-Tier 4';
        acc.Core_Partner_Alliance_Program__c ='PSG Demand Creation - PSG';
        acc.Core_Account_BU_Focus__c='PSG-CM;PSG-DISTI';
        
        insert acc;
        System.assert(acc.Id!=null,'New Account created sucessfully');
        return acc;   
    }
    
    public static Account createDistyAccount(){
        Account acct = new Account();
        acct.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        acct.Name = 'Test Account2'+System.now();
        acct.Core_Account_Type__c = 'Distributor;End Customer';//added
        acct.Industry = 'Banking';
        acct.BillingCity = 'Texas';
        acct.BillingCountry = 'USA';
        acct.BillingStreet = 'G-2101'; 
        acct.Core_Sales_Groups__c = 'PRC Sales Group'; 
        acct.Core_Geo__c = 'PRC';
        acct.Core_Sub_Geo__c = 'IJKK';
        acct.Core_PSG_Account__c = true;
        acct.Core_Account_Tier__c ='PSG-Tier 4';
        
        insert acct;
        System.assert(acct.Id!=null,'New Account created sucessfully');
        return acct;   
    }
    
    public static Account createDirectAccount(){
        Account directacc = new Account();
        directacc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();      
        directacc.Name = 'Test Account';
        directacc.Core_Account_Type__c = 'Distributor;End Customer';//added
        directacc.Industry = 'Banking';
        directacc.BillingCity = 'Texas';
        directacc.BillingCountry = 'USA';
        directacc.BillingStreet = 'G-2101'; 
        directacc.Core_Sales_Groups__c = 'PRC Sales Group'; 
        directacc.Core_Geo__c = 'APJ';
        directacc.Core_Sub_Geo__c = 'IJKK';
        directacc.Core_PSG_Account__c = true;
        directacc.Core_Account_Tier__c ='PSG-Tier 4';
        directacc.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        directacc.Core_Is_Pricing_Parent_ChkBox__c=true;
        
        insert directacc;
        System.assert(directacc.Id!=null,'New Account created sucessfully');
        return directacc;   
    }
    
    public static List<Group> createGroup(){
        List<Group> grpList = new List<Group>();
        for(Group grpRec: grpList){
            grpRec.Name = 'PSG ASMO';
            grpList.add(grpRec);
        }
        insert grpList;
        return grpList;
    }
    
    public static List<GroupMember> createGroupMember(){
        List<GroupMember> memberList = new List<GroupMember>();
        for(GroupMember grpMemberRec: memberList){
            List<Group> grp = createGroup();
            grpMemberRec.Id = grp[0].Id;
            memberList.add(grpMemberRec);
        }
        insert memberList;
        return memberList;
    }
    
    public static List<core_cpq_bm_assignment_config__c> createApprvRecord(Id directaccId){
        List<core_cpq_bm_assignment_config__c> apprvList = new List<core_cpq_bm_assignment_config__c>();
        Account directacc = new Account();
        core_cpq_bm_assignment_config__c apprvRec = new core_cpq_bm_assignment_config__c();
        List<User> uL = createBMUser();
        apprvRec.core_cpq_end_customer_parent__c = directaccId;
        apprvRec.core_cpq_business_unit_nm__c = 'Wireless';
        apprvRec.core_cpq_account_tier_nm__c = 'PSG-Tier 4';
        apprvRec.core_cpq_asmo_txt__c = uL[0].Id;
        apprvRec.core_cpq_emea_txt__c = uL[0].Id; 
        apprvRec.core_cpq_apj_prc_txt__c = uL[0].Id; 
        apprvRec.core_cpq_japan_txt__c = uL[0].Id;
        
        apprvList.add(apprvRec);
        insert apprvList;
        System.assert( apprvList!=null,'New Approved Record created sucessfully');
        
        return apprvList;
    }
    
    
    public static List<core_cpq_bm_level__c> createBMLevel(){
        List<core_cpq_bm_level__c> bmlist = new List<core_cpq_bm_level__c>();
        core_cpq_bm_level__c bmrecc = new core_cpq_bm_level__c();
        List<User> uL = createBMUser();
        bmrecc.core_cpq_bm_level_nm__c = 'Level 5';
        bmrecc.core_cpq_bm_name__c = uL[0].Id ;
        bmlist.add(bmrecc);
        insert bmlist;
        System.assert( bmlist[0].Id!=null,'New BM level created sucessfully');
        return bmlist;
    }
    
    public static void createProductDetails(){
        core_cpq_product_details__c prodDetails = new core_cpq_product_details__c(
            core_cpq_segment_nm__c = 'Diagnostic Imaging',
            core_cpq_product_segment_nm__c = 'Client Computing',
            core_cpq_product_application_nm__c = 'Business Desktop'           
        );
        insert prodDetails;
        System.assert( prodDetails.Id!=null,'Product details inserted sucessfully');
    }
    public static List<core_cpq_bm_approval_threshold__c> createBMApprThres(){
        List<core_cpq_bm_approval_threshold__c> bmApprThresList = new List<core_cpq_bm_approval_threshold__c>();
        core_cpq_bm_approval_threshold__c bmApprRecc = new core_cpq_bm_approval_threshold__c();
        List<User> uL = createBMUser();
        bmApprRecc.core_cpq_bm_level_txt__c = 'Level 5';
        bmApprRecc.core_cpq_business_unit_nm__c = 'Automotive';
        bmApprRecc.core_cpq_intel_margin_pct__c = 12.34;
        bmApprRecc.price_peak_annual_amt__c = 34.56;
        bmApprThresList.add(bmApprRecc);
        insert bmApprThresList;
        System.assert(bmApprThresList[0].Id!=null,' bmApprThresList inserted sucessfully');
        return bmApprThresList;
    }
    
    public static Opportunity createOpportunity(Id accId){
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Id DesignOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Opportunity opp = new Opportunity();
        opp.name = 'test opp'; 
        opp.RecordTypeId = DesignOppRecTypeId;
        opp.AccountId = accId;
        opp.StageName = 'Qualify';
        opp.CloseDate = System.today();
        opp.Opportunity_Focus__c = 'Core';
        opp.Core_Technical_Owner__c = userInfo.getUserId();
        opp.Core_Opportunity_Type__c ='Design: Original';
        insert opp;
        System.assert(opp.Id!=null,' opportunity inserted sucessfully');
        return opp;
    }
    
    Public static List<AccountTeamMember> createAccountTeamMember(Id accId, Id userId){
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        List<AccountShare> lstAccountShare  = new List<AccountShare>();
        for(Integer i=0;i<4;i++);{
            AccountShare accShare = new AccountShare(AccountId = accId,
                                                     AccountAccessLevel ='Edit',
                                                     OpportunityAccessLevel ='Edit',
                                                     CaseAccessLevel='Edit',
                                                     UserOrGroupId = userId);
            lstAccountShare.add(accShare);
            System.assert(lstAccountShare[0].AccountId!=null,'Account team member created sucessfully');
        }
        for(Integer i=0;i<4;i++);{
            AccountTeamMember accountTeamMember = new AccountTeamMember(AccountId = accId,
                                                                        TeamMemberRole = 'Team Member (100%)',
                                                                        AccountAccessLevel ='Edit',
                                                                        OpportunityAccessLevel ='Edit',
                                                                        CaseAccessLevel='Edit',
                                                                        UserId = userId);
            lstAccountTeamMember.add(accountTeamMember);
        }
        insert lstAccountShare;
        insert lstAccountTeamMember;
        System.assert(lstAccountShare[0].Id!=null,'Account team member inserted sucessfully');
        return lstAccountTeamMember;
    }
    
    public static Contact createContact(Id accId){
        Contact con = new Contact();
        Account acc = new Account();
        acc.Id = accId;
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
        con.FirstName = 'FirstName'+System.now();
        con.LastName = 'LastName';
        con.Email = 'FirstName@intel.com';
        con.AccountId = acc.Id;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        System.assert(con.Id!=null,'New Account created sucessfully');
        return con;
    }

    public static Contact createContactWithEmail(Id accId,String emailStr){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName'+System.now();
        con.LastName = 'LastName';
        con.Email = emailStr;
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        System.assert(con.Id!=null,'New Account created sucessfully');
        return con;
    }

    public static List<Contact> createTestContact(Id accId , Integer count){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<count;i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);     
            con.FirstName = 'FirstName'+System.now();
            con.LastName = 'LastName '+i;
            con.Email = 'FirstName'+i+'@intel.com';
            con.AccountId = accId;
            conList.add(con);
        }
        insert conList;
        System.assert(conList[0].Id!=null,'Contact List inserted sucessfully');
        return conList;
    }
    
    public static PriceBook2 createPriceBook(String name){
        
        PriceBook2 p = new PriceBook2(
            name = name,
            core_cpq_program__c ='PSG',
            isActive=true
        );
        insert p;
        System.assert(p.Id!=null,'PriceBook Created sucessfully');
        return p;
    }

    public static List<SBQQ__Quote__c> updateQuote(List<SBQQ__Quote__c> lstQuote){
        List<SBQQ__Quote__c>ql =new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor2'); 
        for(SBQQ__Quote__c sbq : lstQuote){
            sbq.core_cpq_assigned_to_nm__c = null;
            sbq.core_cpq_assigned_by_nm__c   = null;
            sbq.core_cpq_assigned_on__c  = System.now();
            sbq.core_cpq_price_book_nm__c = pb.id;
            sbq.core_cpq_extended_cp_quote_cb__c=true;
            ql.add(sbq);
        }
        update ql;
        System.assert(ql!=null,'Quote Updated sucessfully');
        return ql;
    }
    
    public static SBQQ__Quote__c createQuoteRecord(Id accId , Id oppId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
        quote.SBQQ__Account__c = accId;
        quote.core_cpq_end_customer_nm__c =accId;
        quote.core_cpq_revision_nbr__c =  1;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Distributor__c = accId;
        quote.core_cpq_quote_type_nm__c = 'Design Win';
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.core_cpq_account_tier__c = 'PSG-Tier 4';
        quote.Pricing_Quote_Program_Nm__c = 'PSG';
        //quote.core_cpq_requestor_nm__c = accId;
        //quote.core_cpq_assigned_by_nm__c = quote.core_cpq_requestor_nm__c;
        return quote;
    }
    
    public static SBQQ__Quote__c createCPQuoteRecord(Id accId , Id oppId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_Contract_Pricing');
        quote.SBQQ__Account__c = accId;
        quote.core_cpq_end_customer_nm__c =accId;
        quote.core_cpq_revision_nbr__c =  1;
        quote.SBQQ__Status__c = 'In Progress';
        quote.SBQQ__Distributor__c = accId;
        quote.core_cpq_quote_type_nm__c = 'Contract Pricing';
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.core_cpq_account_tier__c = 'PSG-Tier 4';
        quote.Pricing_Quote_Program_Nm__c = 'PSG';
        return quote;
    }
    
    public static List<core_cpq_dpa_aln__c> createDPARecord(SBQQ__Quote__c quoterec,Id acc){
        List<core_cpq_dpa_aln__c> dpaToInsert =  new List<core_cpq_dpa_aln__c>(); 
        core_cpq_dpa_aln__c dpa = new core_cpq_dpa_aln__c();  
        dpa.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
        dpa.core_cpq_active_quote__c = quoterec.Id;
        dpa.core_cpq_record_type_identifier__c = 'DPA';        
        dpaToInsert.add(dpa);
        insert dpaToInsert;
        return dpaToInsert;
    }
    
    public static List<SBQQ__Quote__c> createQuote(Id accId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor');  
        List<User> uL = createSOSUser();
        Opportunity opp = createOpportunity(accId);
        List<String> status = new List<String>();
        status.add('New');
        status.add('Approved');
        status.add('Rejected');
        status.add('In Progress');
        status.add('Pending');
        status.add('Recalled');
        status.add('In Review');
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_revision_nbr__c =  1;
            if(numberOfQuotes == 1){
                quote.SBQQ__Status__c = 'Approved';
            }else{
                quote.SBQQ__Status__c = status[i];
            }
            quote.core_cpq_next_approver_nm__c = uL[0].id;
            quote.core_cpq_assigned_to_nm__c = uL[0].id;
            quote.core_cpq_assigned_by_nm__c = uL[0].id;
            quote.core_cpq_assigned_on__c = System.now();
            quote.SBQQ__Distributor__c = accId;
            quote.core_cpq_quote_type_nm__c = 'Design Win';
            quote.core_cpq_end_customer_country_disty_nm__c = 'India';
            quote.core_cpq_active_cb__c = true;
            quote.core_cpq_business_unit_nm__c = 'Military';
            quote.core_cpq_quote_owner_disty_txt__c = 'SOS Korea';
            quote.core_cpq_account_tier__c = 'PSG-Tier 4';
            quote.core_cpq_first_bm_approver__c = uL[0].id;
            quote.core_cpq_revision_nbr__c = 1;
            quote.SBQQ__StartDate__c=Date.today();
            quote.SBQQ__EndDate__c= quote.SBQQ__StartDate__c.addMonths(4);
            quote.core_cpq_price_eligibility_date_dt__c=Date.today();
            quote.core_cpq_pricing_end_date_dt__c=Date.today();
            quote.core_cpq_pricing_start_date_dt__c=Date.today();
            quote.core_cpq_review_date_dt__c=Date.today();
            quote.core_cpq_reviewer__c = uL[0].id;
            quote.core_cpq_Process_flag__c = false;
            lstQuote.add(quote);
            
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote List added sucessfully');
        return lstQuote;
        
    }
    
    public static List<SBQQ__Quote__c> createCPQuotes(Id accId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor');  
        List<User> uL = createSOSUser();
        List<User> bM = createBMUser();
        List<String> status = new List<String>();
        status.add('New');
        status.add('Approved');
        status.add('Rejected');
        status.add('In Progress');
        status.add('Pending');
        status.add('Recalled');
        status.add('In Review');
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_Contract_Pricing');
            quote.SBQQ__Account__c = accId;
            quote.core_cpq_end_customer_nm__c =accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_revision_nbr__c =  1;
            if(numberOfQuotes == 1){
                quote.SBQQ__Status__c = 'Approved';
            }else{
                quote.SBQQ__Status__c = status[i];
            }
            quote.core_cpq_next_approver_nm__c = uL[0].id;
            quote.core_cpq_assigned_to_nm__c = uL[0].id;
            quote.core_cpq_assigned_by_nm__c = uL[0].id;
            quote.core_cpq_assigned_on__c = System.now();
            quote.SBQQ__Distributor__c = accId;
            quote.core_cpq_quote_type_nm__c = 'Contract Pricing';
            quote.core_cpq_end_customer_country_disty_nm__c = 'India';
            quote.core_cpq_active_cb__c = true;
            quote.core_cpq_business_unit_nm__c = 'Military';
            quote.core_cpq_quote_owner_disty_txt__c = 'SOS Korea';
            quote.core_cpq_account_tier__c = 'PSG-Tier 4';
            quote.core_cpq_first_bm_approver__c = uL[0].id;
            quote.core_cpq_revision_nbr__c = 1;
            quote.SBQQ__StartDate__c=Date.today();
            quote.SBQQ__EndDate__c= quote.SBQQ__StartDate__c.addMonths(4);
            quote.core_cpq_price_eligibility_date_dt__c=Date.today();
            quote.core_cpq_pricing_end_date_dt__c=Date.today();
            quote.core_cpq_pricing_start_date_dt__c=Date.today();
            quote.core_cpq_review_date_dt__c=Date.today();
            quote.core_cpq_reviewer__c = bM[0].id;
            quote.core_cpq_Process_flag__c = true;
            quote.core_cpq_extended_cp_quote_cb__c = false;
            lstQuote.add(quote);
            
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote List added sucessfully');
        return lstQuote;
        
    }
    
    public static List<SBQQ__Quote__c> createCpQuote(Id accId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor');  
        List<User> uL = createSOSUser();
        List<User> bM = createBMUser();
        Opportunity opp = createOpportunity(accId);
        List<String> status = new List<String>();
        status.add('New');
        status.add('Approved');
        status.add('Rejected');
        status.add('In Progress');
        status.add('Pending');
        status.add('Recalled');
        status.add('Cancelled');
        status.add('In Review');
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_Contract_Pricing');
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_quote_type_nm__c = 'Contract Pricing';
            quote.core_cpq_revision_nbr__c =  1;
            quote.SBQQ__Distributor__c=accId;
            if(numberOfQuotes == 1){
                quote.SBQQ__Status__c = 'In Progress';
            }else{
                quote.SBQQ__Status__c = status[i];
            }
            quote.core_cpq_end_customer_nm__c=accId;
            quote.SBQQ__Distributor__c = accId;
            quote.core_cpq_end_customer_country_disty_nm__c = 'India';
            quote.core_cpq_active_cb__c = true;
            quote.core_cpq_revision_nbr__c = 1;
            quote.core_cpq_price_eligibility_date_dt__c=Date.today();
            quote.core_cpq_pricing_end_date_dt__c=Date.today();
            quote.core_cpq_pricing_start_date_dt__c=Date.today();
            quote.core_cpq_review_date_dt__c=Date.today();
            quote.core_cpq_reviewer__c = bM[0].id;
            quote.core_cpq_account_tier__c = 'PSG-Tier 4' ;
            quote.core_cpq_margin_geo_txt__c = 'APJ';
            lstQuote.add(quote);
            
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote List added sucessfully');
        return lstQuote;
        
    }
    
    public static List<SBQQ__Quote__c> createQuoteTaiwan(Id directaccId,Id conId, Integer numberOfQuotes){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        pricebook2 pb = createPriceBook('Intel processor');  
        List<String> status = new List<String>();
        status.add('New');
        status.add('Approved');
        status.add('Rejected');
        status.add('In Progress');
        status.add('Pending');
        status.add('Recalled');
        status.add('In Review');
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New');
            quote.SBQQ__Account__c = directaccId;
            quote.SBQQ__PrimaryContact__c = conId;
            quote.core_cpq_price_book_nm__c =  pb.Id;
            quote.core_cpq_revision_nbr__c =  1;
            quote.SBQQ__Status__c = status[i];
            quote.core_cpq_assigned_on__c = System.now();
            quote.core_cpq_quote_type_nm__c = 'Design Win';
            quote.core_cpq_end_customer_country_disty_nm__c = 'Taiwan';
            quote.core_cpq_active_cb__c = true;
            lstQuote.add(quote);
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote Taiwan created sucessfully');
        return lstQuote;
        
    }

    public static List<SBQQ__Quote__c> createQuoteWithParam(Id accId,Id conId, Integer numberOfQuotes, String salesRepEmail, String accountExecutiveEmail){
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(Integer i=0;i<numberOfQuotes;i++){ 
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accId;
            quote.SBQQ__PrimaryContact__c = conId;
            
            lstQuote.add(quote);
        }
        insert lstQuote;
        System.assert(lstQuote[0].Id!=null,'Quote Create with param sucessfully');
        return lstQuote;
    }
    
    public static List<SBQQ__Quote__Share> createQuoteShare (Id accId, Id quoteId){
        List<User> uL = createSOSUser();
        List<SBQQ__Quote__Share> lstQuoteShare = new List<SBQQ__Quote__Share>();
        for(SBQQ__Quote__Share QuoteShare: lstQuoteShare){
            QuoteShare.Parentid = quoteId; 
            QuoteShare.AccessLevel = 'Read'; 
            QuoteShare.UserOrGroupId = uL[0].Id;
            QuoteShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;
            lstQuoteShare.add(QuoteShare);
        }
        insert lstQuoteShare;
        return lstQuoteShare; 
    }
    
    public static List<core_cpq_disty_visibility__c> createDistyVisibility (Id acctId, Id quoteId,Integer noOfRec){
        List<core_cpq_disty_visibility__c> lstDV = new List<core_cpq_disty_visibility__c>();
        for(Integer i=0;i<noOfRec;i++){
            core_cpq_disty_visibility__c newDV=new core_cpq_disty_visibility__c();
            newDV.core_cpq_quote__c = quoteId; 
            lstDV.add(newDV);
        }
        insert lstDV;
        return lstDV; 
    }
    
    public static List<Product2> createProduct(Integer numOfProducts){
        Core_Opp_Bypass_Validation_Rule__c bypass = new Core_Opp_Bypass_Validation_Rule__c();
        bypass.Bypass__c=TRUE;
        insert bypass;
        List<Product2> product = new List<Product2>();
        for(numOfProducts=0;numOfProducts<5;numOfProducts++){
            product.add(new Product2(Name = 'Test Product' + numOfProducts,IsActive = true,Core_OPN__c = '1SG00'+ numOfProducts,Core_Sales_Visible_Flag__c = true, Core_Item_Orderable_Ind__c = true,Core_Item_Quotable_Ind__c = true, Core_Hierarchy_ID__c = '43', Core_Product_Type__c = 'Intel® FPGAs', Core_Item_Class_Nm__c='BD', Core_BU_Operation_Code__c='KP', Core_Product_Org__c = 'Sales')); 
        }
        
        insert product;
        for(Product2 p: product){
            p.Core_Sales_Visible_Flag__c=true;
            p.Core_Item_Orderable_Ind__c=true;
            p.Core_Item_Quotable_Ind__c=true;
        }
        update product;
        System.assert(product[0]!=null,'New Product  is created sucessfully');
        List<PriceBookEntry> pbe = new List<PriceBookEntry>();
        pricebook2 pb = [Select id from pricebook2 limit 1];
        Integer MaxLimit = 0;
        MaxLimit = numOfProducts - 1;
        for(Product2 prod : [Select Id from Product2 limit :MaxLimit])
        {
            pbe.add(new PriceBookEntry (Product2Id =prod.Id  , Pricebook2Id= Test.getStandardPricebookId(),price_disty_cost__c= 36,UnitPrice=235,IsActive = true));
            pbe.add(new PriceBookEntry (Product2Id =prod.Id  , Pricebook2Id= pb.Id,price_disty_cost__c= 32,UnitPrice=234,IsActive = true));
        }
        insert pbe;
        return product;
    }
    
    
    public static List<SBQQ__QuoteLine__c> createQuoteLines(Id quoteId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct1'+ i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Item_Signal_Cd__c='E4',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c=true,
                                         Core_OPN__c = 'OPN'+i,
                                         Core_Item_Class_Nm__c='BD',
                                         Core_BU_Operation_Code__c='KP',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
        for(Product2 prod1 : products){
            prod1.Core_Sales_Visible_Flag__c=true;
            prod1.Core_Item_Orderable_Ind__c=true;
            prod1.Core_Item_Quotable_Ind__c=true;
            prod1.IsActive=true;
        }
        update products;
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 prod1 : products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.price_suggested_resale_amt__c = 100;
            quoteLine.core_cpq_previous_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_quote_line_type_txt__c = 'Flat';
            quoteLine.core_cpq_requested_qty__c = 10;
            quoteLine.SBQQ__Quantity__c = null;
            quoteLine.core_cpq_lower_bound_qty_qty__c = 5;
            quoteLine.core_cpq_upper_bound_qty_nbr__c = 25;
            quoteLine.price_disty_cost_nbr__c = 100;
            quoteLine.core_cpq_internal_comments_txt__c = 'Hello';
            quoteLine.core_cpq_comments_for_customer_txt__c = 'Hi';
            quoteLine.core_cpq_comments_for_disty_txt__c = 'Yes';
            quoteLine.price_requested_resale_amt__c = 80;
            quoteLine.price_suggested_resale_amt__c = 110;
            quoteLine.price_std_fwd_cost_amt__c = 200;
            quoteLine.price_goal_price_amt__c = 60;
            quoteLine.core_cpq_years_nbr__c  = null;
            quoteLine.core_cpq_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_altera_reg_txt__c = 'ABCDE';
            quoteLine.core_cpq_competitor_price_amt__c = 75;
            quoteLine.core_cpq_competitor_part_txt__c = 'Test';
            quoteLine.core_cpq_margin_exception_txt__c = 'eASIC';
            quoteLine.price_msvp_l1_amt__c = 20;
            quoteLine.price_msvp_l2_amt__c = 25;
            quoteLine.SBQQ__ListPrice__c = 55;
            quoteLine.core_cpq_reg_status__c = 'Pending';
            quoteLine.core_cpq_product_nm__c = prod1.Id;
            quoteLine.core_cpq_quantity_nm__c =1234;
            quoteLine.core_cpq_gp_msvpl2_nm__c = 35;
            quoteLine.core_cpq_opn__c = 'Abc123';
            quoteLine.core_cpq_production_dt__c = System.today();
            quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
            quoteLine.core_cpq_pricing_start_date_dt__c = System.today() + 5;
            quoteLine.core_cpq_dollar_change_flag_cb__c = false;
            quoteLine.price_brokencost_amt__c = 10;
            quoteLine.price_std_fwd_cost_amt__c = 21;
            quoteLines.add(quoteLine);
        }
        
        insert quoteLines;
        System.assert(quoteLines[0]!=null,'Quote Lines are created sucessfully');
        return quoteLines;
    }
    
    public static List<SBQQ__QuoteLine__c> createCpQuoteLines(Id quoteId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct1'+ i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                         //Core_Item_Class_Nm__c = 'IC',
                                         IsActive = true,
                                         Core_OPN__c = 'TESTXYZ123' + Math.random());
            products.add(prod);
        }
        insert products;
        for(Product2 prod: products){
            prod.Core_Item_Orderable_Ind__c = true;
            prod.Core_Item_Quotable_Ind__c = true;
        }
        update products;
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for(Product2 prod1 : products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'psg_cp_quote_line');
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.core_cpq_quote_line_type_txt__c = 'Time Limited';
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.core_cpq_lower_bound_qty_qty__c = 5;
            quoteLine.core_cpq_upper_bound_qty_nbr__c = 25;
            quoteLine.core_cpq_internal_comments_txt__c = 'Hello';
            quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
            quoteLine.core_cpq_years_nbr__c  = 1;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.price_suggested_resale_amt__c=12;
            quoteLine.core_cpq_distributor_margin_pct__c=1;
            quoteLines.add(quoteLine);
        }
        
        insert quoteLines;
        System.assert(quoteLines[0]!=null,'Quote Lines are created sucessfully');        
        return quoteLines;
    }
    //create DPA Lines
    public static List<core_cpq_dpa_aln_line__c>  createDPALines(Id dpaId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct1'+ i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                         Core_Item_Class_Nm__c='BD', 
                                         Core_BU_Operation_Code__c='KP',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
        products = [Select Id from Product2];
        List<core_cpq_dpa_aln_line__c> dpaLinesToInsert =  new List<core_cpq_dpa_aln_line__c>();  
        for(Product2 prod1 : products){
            core_cpq_dpa_aln_line__c dpaLines = new core_cpq_dpa_aln_line__c();  
            
            dpaLines.core_cpq_device_nm__c = prod1.Id;
            dpaLines.core_cpq_cis_no_nbr__c = dpaId;
            dpaLines.core_cpq_approved_qty_nbr__c = 11;
            
            dpaLines.price_disty_value_added_amt__c =17.1;
            dpaLinesToInsert.add(dpaLines);
        }
        
        insert dpaLinesToInsert;
        return dpaLinesToInsert;
    }
    public static List<core_cpq_dpa_aln_line__c>  createDPALinesWithoutInsert(Id dpaId, Integer numquoteLines){
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<numquoteLines;i++) {
            Product2 prod = new Product2(Name='TestProduct1'+ i,
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                         Core_Item_Class_Nm__c='BD',
										 Core_BU_Operation_Code__c='KP',
                                         IsActive = true);
            products.add(prod);
        }
        insert products;
        products = [Select Id from Product2];
        List<core_cpq_dpa_aln_line__c> dpaLinesToInsert =  new List<core_cpq_dpa_aln_line__c>();  
        for(Product2 prod1 : products){
            core_cpq_dpa_aln_line__c dpaLines = new core_cpq_dpa_aln_line__c();  
            
            dpaLines.core_cpq_device_nm__c = prod1.Id;
            dpaLines.core_cpq_cis_no_nbr__c = dpaId;
            dpaLines.price_disty_value_added_amt__c =17.1;
            dpaLinesToInsert.add(dpaLines);
        }
        return dpaLinesToInsert;
    }
    public static List<SBQQ__QuoteLine__c> createQuoteLinesWithoutInsert(Id quoteId, Set<Id> productIdSet,Id prid){
        List<Product2> products = new List<Product2>();
        products = [Select Id from Product2 where Id IN : productIdSet];
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 prod1 : products){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
            quoteLine.SBQQ__Product__c = prod1.Id;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLine.price_suggested_resale_amt__c = 100;
            quoteLine.core_cpq_previous_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_quote_line_type_txt__c = 'AVP';
            quoteLine.core_cpq_requested_qty__c = 10;
            quoteLine.SBQQ__Quantity__c = null;
            quoteLine.core_cpq_lower_bound_qty_qty__c = 5;
            quoteLine.core_cpq_upper_bound_qty_nbr__c = 25;
            quoteLine.price_disty_cost_nbr__c = 100;
            quoteLine.core_cpq_internal_comments_txt__c = 'Hello';
            quoteLine.core_cpq_comments_for_customer_txt__c = 'Hi';
            quoteLine.core_cpq_comments_for_disty_txt__c = 'Yes';
            quoteLine.price_requested_resale_amt__c = 80;
            quoteLine.price_suggested_resale_amt__c = 110;
            quoteLine.price_std_fwd_cost_amt__c = 20;
            quoteLine.price_goal_price_amt__c = 60;
            quoteLine.core_cpq_years_nbr__c  = null;
            quoteLine.core_cpq_distributor_margin_pct__c = 10;
            quoteLine.core_cpq_altera_reg_txt__c = 'ABCDE';
            quoteLine.core_cpq_competitor_price_amt__c = 75;
            quoteLine.core_cpq_competitor_part_txt__c = 'Test';
            quoteLine.core_cpq_margin_exception_txt__c = 'eASIC';
            quoteLine.price_msvp_l1_amt__c = 20;
            quoteLine.price_msvp_l2_amt__c = 25;
            quoteLine.SBQQ__ListPrice__c = 55;
            quoteLine.core_cpq_reg_status__c = 'Approved';
            quoteLine.core_cpq_product_nm__c = prod1.Id;
            quoteLine.core_cpq_quantity_nm__c =1234;
            quoteLine.core_cpq_gp_msvpl2_nm__c = 35;
            quoteLine.core_cpq_opn__c = 'Abc123';
            quoteLine.core_cpq_production_dt__c = System.today();
            quoteLine.Pricing_Quote_Program_Nm__c = 'PSG';
            quoteLine.core_cpq_pricing_start_date_dt__c = System.today() + 5;
            quoteLine.core_cpq_price_eligibility_date_dt__c = System.today() + 20;
            quoteLine.core_cpq_PRID__c = prid;
            quoteLine.SBQQ__Quote__c = quoteId;
            quoteLines.add(quoteLine);
        }
        
        //System.assert(quoteLines[0]!=null,'Quote Lines are created sucessfully');
        return quoteLines;
    }
    
    
    public static List<PRID_POS_Stage__c> createPridPos(Price_PRID__c prid){
        Product2 prod = new Product2(Name='TestProduct1i6',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG',
                                         Core_Item_Orderable_Ind__c = true,
                                         Core_Item_Quotable_Ind__c = true,
                                         Core_Item_Class_Nm__c='BD',
                                         Core_BU_Operation_Code__c='KP',
                                         IsActive = true);
        insert prod;
        List<PRID_POS_Stage__c> pridPosList = new List<PRID_POS_Stage__c>();
        PRID_POS_Stage__c pridPosRec1 = new PRID_POS_Stage__c(Price_PRID__c = prid.Id, core_cpq_pos_quantity__c=30, core_cpq_opn__c = prod.id);
        PRID_POS_Stage__c pridPosRec2 = new PRID_POS_Stage__c(Price_PRID__c = prid.Name, core_cpq_pos_quantity__c=50, core_cpq_opn__c = prod.id);
        pridPosList.add(pridPosRec2);        
        insert pridPosList;
        return pridPosList;
    }
    
    
    public static List<price_prid__c> createPrid(Id accId, Id quoteId, Id quoteLineId, Id prodId){
        List<price_prid__c> prids = new List<price_prid__c>();
        price_prid__c pridTest = new price_prid__c();
        pridTest.core_cpq_active_cb__c = true;
        pridTest.core_cpq_active_pricing_cb__c = true;
        pridTest.core_cpq_comments_txt__c = 'Test Comments';
        pridTest.core_cpq_device__c = prodId;
        pridTest.core_cpq_lower_bound_qty_nbr__c = 30;
        pridTest.core_cpq_no_of_active_quotes_nbr__c = 5;
        pridTest.core_cpq_price_end_date_dt__c = System.today();
        pridTest.core_cpq_price_start_date_dt__c = System.today() + 1;
        pridTest.core_cpq_sap_ec_code__c = 'abc123';
        pridTest.core_cpq_sap_ecp_nm__c = accId;
        pridTest.core_cpq_prid_eligiblity_date_dt__c =  System.today() + 5;
        pridTest.core_cpq_prid_pos__c = 20;
        pridTest.core_cpq_quantity_eau_nbr__c = 10;
        pridTest.core_cpq_quote__c = quoteId;
        pridTest.core_cpq_quoteline__c = quoteLineId;
        pridTest.core_cpq_review__c = true;
        pridTest.core_cpq_src_sys_id__c  = 'test src';
        pridTest.price_amt__c = 50;
        pridTest.core_cpq_type__c = 'Flat';
        pridTest.core_cpq_update_underlying_quotelines_cb__c = true;
        pridTest.core_cpq_upper_bound_qty_nbr__c     = 100;
        prids.add(pridTest);
        
        insert prids;
        System.assert(prids[0]!=null,'PRIDs are created sucessfully');
        return prids;
    }
    
    public static List<price_forward_cost__c> createfwdcost(Id prodId){
        List<price_forward_cost__c> fwdcostList = new List<price_forward_cost__c>();
        price_forward_cost__c fwdcostRec = new price_forward_cost__c();
        fwdcostRec.Name = 'Test Fc'; 
        fwdcostRec.price_forward_cost_amt__c = 100;
        fwdcostRec.core_cpq_product_opn_txt__c = '1SG000';
        fwdcostRec.core_cpq_fc_start_date_dt__c = System.Today() - 5;
        fwdcostRec.core_cpq_fc_end_date_dt__c = System.Today().addDays(2);
        fwdcostRec.core_cpq_product_nm__c = prodId;
        fwdcostList.add(fwdcostRec);
        insert fwdcostList;
        System.assert(fwdcostList[0]!=null,'fwdcost is created sucessfully');
        return fwdcostList;
    }
    
    public static List<price_msvp__c> createMSVP(Id prodId){
        List<price_msvp__c> msvpList = new List<price_msvp__c>();
        price_msvp__c msvpRec = new price_msvp__c();
        msvpRec.core_cpq_product_nm__c = prodId;
        msvpRec.price_10ku_y_amt__c = 100;
        msvpRec.price_1ku_y_amt__c = 20;
        msvpRec.core_cpq_product_opn__c = '1SG000';
        msvpRec.price_2_5ku_y_amt__c = 25;
        msvpRec.price_250u_y_amt__c = 30;
        msvpRec.price_500u_y_amt__c = 35;
        msvpRec.price_5ku_y_amt__c = 45;
        msvpRec.price_level_1_amt__c = 35;
        msvpRec.price_level_2_amt__c = 32;
        msvpRec.price_prototype_amt__c = 20;
        msvpRec.core_cpq_effective_date_dt__c = System.Today() - 1;
        
        msvpList.add(msvpRec);
        insert msvpList;
        System.assert(msvpList[0]!=null,'MSVP is created sucessfully');
        return msvpList;
    }
    
    public static List<core_cpq_list_price__c> createlp(Id prodId, Id pbId){
        List<core_cpq_list_price__c> lpList = new List<core_cpq_list_price__c>();
        core_cpq_list_price__c lpRec = new core_cpq_list_price__c ();
        List<pricebookentry> pdeList = [SELECT id from pricebookentry where Product2Id =: pbId];
        lpRec.core_cpq_list_price_amt__c = 50;
        lpRec.core_cpq_product_name__c = prodId;
        lpRec.core_cpq_lowerbound_qty__c = 1;
        if(!pdeList.isEmpty()){
            lpRec.Pricebookentry__c = pdeList[0].Id;
        }
        lpRec.core_cpq_upperbound_qty__c = 100;
        lpList.add(lpRec);
        
        insert lpList;
        System.assert(lpList[0]!=null,'List Price is created sucessfully');
        return lpList;
    }

    public static List<contentVersion> createContentVersion(Id quoteId, Integer numcontentVersion){
        List<contentVersion> contentVersions = new List<contentVersion>();
        contentVersion contentVersionTest = new contentVersion(); 
        contentVersionTest.Title = 'TestDoc';
        contentVersionTest.PathOnClient = '.doc';
        contentVersionTest.FirstPublishLocationId = quoteId;
        contentVersionTest.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');           
        contentVersions.add(contentVersionTest);
        
        insert contentVersions;
        System.assert(contentVersions[0]!=null,'New Document is created sucessfully');
        return contentVersions;
    }
    
    
    public static List<PermissionSetAssignment> createPermissionSets(){
        List<PermissionSetAssignment> lstUserPermSets = new List<PermissionSetAssignment>();
        PermissionSetAssignment UserPermSets = new PermissionSetAssignment();
        UserPermSets.id = 'a9Y2D000000CuEpXQP';
        lstUserPermSets.add(UserPermSets);
        insert lstUserPermSets;
        System.assert(lstUserPermSets[0]!=null,'Permission set is created sucessfully');
        return lstUserPermSets;
    }
    
    public static List<User> createSOSUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_SOS_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId() limit 1];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameSOS9562@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameSOS9565Q@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(PermissionSet ps :[SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }
    
    public static List<User> createBOUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_BO_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId()];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameBO257@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameBO257@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();   
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }
    
    public static List<User> createBMUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_Quote_BM_PermissionSet];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId()];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameBM135@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameBMs143@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License  OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps1.Id));
            insert permissionList;
        }  
        return lstUser;
    }
    public static List<User> createPMSUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        List<PermissionSet> ps1 = [SELECT Id FROM PermissionSet WHERE Name ='PSG_Internal_PMS' OR Name = 'AdvancedApprovalsUser'];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameBM13@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameBMs16@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                for(PermissionSet ps : ps1){
                    permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
                }
            } 
            if(!permissionList.isEmpty()){
                insert permissionList;
            }   
        }  
        return lstUser;
    }
    
    public static List<User> createDistyUser(){
        
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        List<PermissionSet> ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_PermissionSets_PSG_Distributor or Name=:Label.Pricing_CPQ_Managed_License_User];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id, accountId FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user14', Email= 'firstNameDisty1@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameDisty1@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            insert lstUser;
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            System.assert(lstUser[0]!=null,'Disty user is created sucessfully');
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1[0].Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1[1].Id));
            } 
            if(!permissionList.isEmpty()){
                insert permissionList;
            }   
        }  
        return lstUser;
    }
    
    public static User createDistyTestUser(Id accountId){
        List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.PSG_PermissionSets_PSG_Distributor or Name=:Label.Pricing_CPQ_Managed_License_User];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2'+System.now();
        con.LastName = 'LastName2';
        con.Email = 'FirstName2+'+'one'+'@intel.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        
        User user = new User(alias = 'test123', email='partner'+con.Id+'@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username=con.Id+'FirstName@Intel.com');
        insert user;
        PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
        PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
        psla.AssigneeId = user.Id;
        psla.PermissionSetLicenseId = psl.Id;
        insert psla;
        System.assert(user!=null,'Disty  test user is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps[0].Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps[1].Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return user;        
    }
    
    public static List<User> createCommunityUser(){
        List<User> lstUser = new List<User>();
        List<User> lstUser2 = createAdminUser();
        
        System.runAs(lstUser2[0]){
            Account acc = createAccount();
            Contact con = createContact(acc.Id);
            Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_Partner}; 
                Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_PartnerCommunityUser].id;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
            Set<Id> userProfileIdSet=new Set<Id>();
            for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
                userProfileIdSet.add(proId.Id);
            }
            
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user15', Email= 'firstName'+profileId+'@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US',ProfileId = p,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName'+profileId+'@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
            insert lstUser;
            System.assert(lstUser[0]!=null,'Community user is created sucessfully');
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
            }
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }
        return lstUser;
    }
    
    public static List<User> createAdminUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId()];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user16', Email = 'firstName16@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='testing admin', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId, UserRoleId = role.Id,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName1@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);             
            }
            
            insert lstUser;
            System.assert(lstUser[0]!=null,'BM1 user is created sucessfully');
            PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
            PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
            psla.AssigneeId = lstUser[0].Id;
            psla.PermissionSetLicenseId = psl.Id;
            insert psla;
            list<user> u1 = [Select Id from User where Id =: lstUser];
            list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[0].id);
            insert new UserPackageLicense(UserId = lstUser[0].id, PackageLicenseId = pl[1].id);
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License OR Name = 'AdvancedApprovalsUser' Limit 3]){
                permissionList.add(new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = ps.Id));
            }
            insert permissionList;
        }  
        return lstUser;
    }
    
    public static List<User> createAdminUser2(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
            
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user17', Email= 'firstName17@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='testing admin', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
                
            }
        }
        insert lstUser;
        System.assert(lstUser[0]!=null,'Admin user 3 is created sucessfully');
        return lstUser;
    }
    
    public static User createPartnerUser(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='USA';
        insert con;
        
        User user = new User(alias = 'test123', email='partner@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstName123@Intel.com');
        insert user;
        System.assert(user!=null,'Partner User is created sucessfully');
        PermissionSetLicense psl=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesforceCPQ_CPQAAPerm' LIMIT 1];
        PermissionSetLicenseAssign psla=new PermissionSetLicenseAssign();
        psla.AssigneeId = User.Id;
        psla.PermissionSetLicenseId = psl.Id;
        insert psla;
        list<user> u1 = [Select Id from User where Id =: user.Id];
        list<PackageLicense> pl = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'sbaa' or NamespacePrefix = 'SBQQ']; 
        insert new UserPackageLicense(UserId = User.id, PackageLicenseId = pl[0].id);
        insert new UserPackageLicense(UserId = User.id, PackageLicenseId = pl[1].id);
        list<PermissionSet> permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User OR Name=:Label.PSG_CPQ_AA_License Limit 2];
        
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();           
        list<UserPackageLicense> upl = [select id , UserId, PackageLicense.NamespacePrefix from UserPackageLicense where userId=:User.Id];
        insert new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = permissionRec[0].Id);
        insert new PermissionSetAssignment(AssigneeId = u1[0].Id, PermissionSetId = permissionRec[1].Id);
        return User;
    }
    
    public static Contact createPrimaryContact(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'primarycontact2';
        con.LastName = 'primarycontactLastName2';
        con.Email = 'primarycontact@noemail.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        insert con;
        
        User user = new User(alias = 'test23', email='primarycontact@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles',username='FirstNameprimarycontact@Intel.com');
        insert user;
        System.assert(user!=null,'Primary Contact is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return con;        
    }
    
    
    public static List<Contact> createPrimaryContact(Id accountId,Integer numberOfRec){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;  
        List<User> userList = new List<User>(); 
        List<Contact> contactList = new List<Contact>(); 
        for(Integer i=0; i < numberOfRec; i++){
            Contact con = new Contact();
            con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
            con.FirstName = 'primarycontact2'+i;
            con.LastName = 'primarycontactLastName2'+i;
            con.Email = 'primarycontact'+i+'@noemail.com';
            con.AccountId = accountId;
            con.Core_Primary_Contact__c = true;
            contactList.add(con);
            
        }
        insert contactList;
        System.assert(contactList[0]!=null,'Primary Contact  List is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(Integer i=0; i<numberOfRec; i++){
            User user = new User(alias = 'test123', email='primarycontact'+i+'@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, IsActive =true,
                                 ContactId = contactList[i].Id,
                                 timezonesidkey='America/Los_Angeles', username='FirstNameprimarycontact'+i+'@Intel.com');
            userList.add(user);
        }
        insert userList;
        
        for(Integer i=0; i<numberOfRec; i++){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userList[i].id, PermissionSetId = ps.Id));
        }
        
        insert permissionList;
        return contactList;        
    }

    public static List<User> createExternalUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SystemAdministrator};            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderPartner];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'user18', Email= 'firstName18@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US',ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        System.assert(lstUser!=null,'External user is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return lstUser;
    }
    
    public static List<User> createPartner(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB}; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'user19', Email= 'firstName19@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US',ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);            
        }
        insert lstUser;
        System.assert(lstUser[0]!=null,'Partner user is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return lstUser;
    }
    
    public static List<User> createPricingMangerUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user20', Email= 'firstName20@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            System.assert(lstUser[0]!=null,'Pricing Manager USer is created sucessfully');
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    public static List<User> createPricingMangerUser2(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user21', Email= 'firstNameRPM@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,
                                   TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstName@Intel.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);
            }
            insert lstUser;
            System.assert(lstUser[0]!=null,'Pricing Manager USer 2 is created sucessfully');
            List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
            for(user userId : lstUser){
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
                permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
            }   
            if(!permissionList.isEmpty()){
                insert permissionList;
            }
        }  
        return lstUser;
    }
    
    public static List<User> createAEUser(){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'user22', Email= 'firstNameAE22@intel.com',
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameAE1@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        System.assert(lstUser[0]!=null,'AE1 USer is created sucessfully');
        List<PermissionSetAssignment> PermissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            PermissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            PermissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }
        if(!PermissionList.isEmpty()){
            insert PermissionList;
        }
        return lstUser;
    }   
    
    public static List<User> createAEUserWithParam(String emailValue){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'user23', Email = emailValue,
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameAE11@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
        }
        insert lstUser;
        System.assert(lstUser[0]!=null,'AE1 USer  with param is created sucessfully');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        }  
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return lstUser;
    } 
    
    public static List<sbaa__Approval__c> createApproval(Id quoteId){
        List<User> uL1 = createBMUser();
        //Added By Bishal Singh 
        List<core_cpq_bm_level__c> bmlist = new List<core_cpq_bm_level__c>();
        core_cpq_bm_level__c bmrecc = new core_cpq_bm_level__c();
        bmrecc.core_cpq_bm_level_nm__c = 'Level 5';
        bmrecc.core_cpq_bm_name__c = uL1[0].Id ;
        bmlist.add(bmrecc);
        insert bmlist;
        
        Group grp = new Group();
        grp.name = 'Test Group1';
        grp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert grp; 
        }
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = uL1[0].Id;
        grpMem1.GroupId = grp.Id;
        
        System.runAs(uL1[0]){
            Insert grpMem1;
        }
        
        Group subGrp  = new Group();
        subGrp.name = 'Test Group2';
        subGrp.Type = 'Regular'; 
        System.runAs(uL1[0]){
            Insert subGrp; 
        }
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        System.runAs(uL1[0]){
            Insert grpMem2;  
        }
        
        
        
        List<sbaa__Approver__c> approverList = new List<sbaa__Approver__c>();
        approverList.add(new sbaa__Approver__c(Name = 'test approver',sbaa__Unanimous__c=true,sbaa__User__c = uL1[0].Id,
                                               sbaa__GroupId__c = grp.Id));
        insert approverList;
        System.assert( approverList[0].Name!=null,'Approval is created sucessfully');
        
        List<sbaa__ApprovalRule__c> approverRuleList = new List<sbaa__ApprovalRule__c>();
        approverRuleList.add(new sbaa__ApprovalRule__c(Name = 'test approver rule', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverRuleList;
        
        //Added by Bishal Singh
        List<sbaa__ApprovalChain__c> approverChainList = new List<sbaa__ApprovalChain__c>();
        approverChainList.add(new sbaa__ApprovalChain__c(Name = 'BM Chain', sbaa__TargetObject__c = 'SBQQ__Quote__c'));
        insert approverChainList;
        
        List<sbaa__Approval__c> approvalList = new List<sbaa__Approval__c>();
        
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.core_cpq_first_bm_approver__c = uL1[0].Id;
        
        sbaa__Approval__c appr1 = new sbaa__Approval__c(sbaa__RecordField__c = 'test',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = quoteId, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,/* Added By Bishal Singh*/ /*sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr1);
        
        sbaa__Approval__c appr2 = new sbaa__Approval__c(sbaa__RecordField__c = 'test2',sbaa__ApprovalStep__c=1,sbaa__Status__c ='Requested', 
                                                        sbaa__AssignedTo__c = uL1[0].Id, Quote__c = quoteId, sbaa__Approver__c = approverList[0].Id, sbaa__Rule__c = approverRuleList[0].Id,
                                                        sbaa__DelegatedApprover__c = approverList[0].Id,/* Added By Bishal Singh*/ /*sbaa__ApprovalChain__c = approverChainList[0].Id);
        approvalList.add(appr2);
        insert approvalList;
        
        
        approvalList[0].sbaa__Status__c = 'Approved';
        approvalList[0].sbaa__ApprovedBy__c=uL1[0].id;
        update approvalList;
        
        return approvalList;
        
    }
    
    public static List<sbaa__Approver__c> createApprover(Id userid){
        List<sbaa__Approver__c> lstapprover = new List<sbaa__Approver__c>(); 
        List<User> uL = createBMUser(); 
        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.Name = 'Emea Approver';
        approver.sbaa__User__c = userid; 
        lstapprover.add(approver);
        System.runAs(uL[0]){
            Insert lstapprover; 
        }
        return lstapprover;
    }
    
    public static list<core_cpq_list_price__c> createlistprice(integer num, String pricebookId){
        list<core_cpq_list_price__c> lpListToInsert = new list<core_cpq_list_price__c>();
        for(integer i = 0;i<num ; i++){
            core_cpq_list_price__c lp = new core_cpq_list_price__c();
            lp.core_cpq_list_price_amt__c = 1000;
            lp.core_cpq_lowerbound_qty__c = 1;
            lp.core_cpq_upperbound_qty__c = 100;
            if(i > 0){
                lp.core_cpq_list_price_amt__c = 1000 * 10 *i;
                lp.core_cpq_lowerbound_qty__c = lp.core_cpq_upperbound_qty__c + 1;
                lp.core_cpq_upperbound_qty__c = 100*10*i;
            }
            lp.Pricebookentry__c =pricebookId;
            lpListToInsert.add(lp);
            
        }
        
        database.insert(lpListToInsert);
        System.assert(lpListToInsert[0]!=null,'List Price is created sucessfully');
        return lplistToInsert;
    }
    
    public static void shareQuoteWithUser(Id quoteId, Id userId){
        SBQQ__Quote__Share quoteShare = new SBQQ__Quote__Share();
        quoteShare.ParentId = quoteId;
        quoteShare.UserOrGroupId = userId;
        quoteShare.AccessLevel = 'Edit';
        quoteShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual;
        insert quoteShare;
        System.assert(quoteShare.ParentId!=null,'Quote Shared with user');
    }
    
    public static User createPartnerAdminUser(Id accountId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_PartnerAdministrator];
        
        Id p = [select id from profile where name =: Label.Pricing_Tender_Profiles_Partner].id;        
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName2';
        con.LastName = 'LastName2';
        con.Email = 'FirstName2@intel.com';
        con.AccountId = accountId;
        con.Core_Primary_Contact__c = true;
        insert con;
        
        User user = new User(alias = 'test123', email='partner@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='FirstName@Intel.com');
        insert user;
        System.assert(user.alias!=null,'Partner User with Admin is Created');
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionRec.Id));
        permissionList.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        return user;        
    }
    public static EmailTemplate createEmailTemplate(String name){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = name;
        validEmailTemplate.DeveloperName = name;
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
        System.assert(validEmailTemplate.Name!=null,'Email Template is Created');
        return validEmailTemplate;
        
    }
    
    public static List<core_cpq_distributor_margin__c> createDistiMargin(Id pId, Integer count){
        List<core_cpq_distributor_margin__c> distributorMarginList = new List<core_cpq_distributor_margin__c>();
        for(Integer i=0;i<count;i++){
            core_cpq_distributor_margin__c distiMargin = new core_cpq_distributor_margin__c();
            distiMargin.core_cpq_Account_Tier_Txt__c = 'PSG-Tier 1';
            distiMargin.core_cpq_Active_Cb__c = True;
            distiMargin.core_cpq_Approved_Registration_Txt__c = 'Yes';
            distiMargin.core_cpq_Disty_Margin_Pct__c = 20;
            distiMargin.core_cpq_Margin_GEO_Txt__c = 'EMEA';
            distiMargin.core_cpq_Partner_Program_Txt__c = 'PSG Demand Creation - PSG';
            distiMargin.core_cpq_Registered_Product_Txt__c = True;
            distiMargin.core_cpq_Price_Book__c = pId;
            distributorMarginList.add(distiMargin);
        }
        insert distributorMarginList;
        System.assert( distributorMarginList[0]!=null,'Disty Margin List is Created');
        return distributorMarginList;
    }*/
}