@IsTest
public class PMP_MPDQBatchFix_Test {
    @TestSetup static void batchTest(){
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;
        
        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Prestige';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company.PMP_Is_Published_Ind__c=true;
        
        insert company;
        System.assertNotEquals(company, Null);
        PMP_Company__c companyw=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw.PMP_Benefit_Update_Ind__c=true;
        companyw.PMP_Partner_Inactive_Ind__c = False;
        companyw.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw.PMP_Is_Working_Copy_Ind__c=true;
        companyw.PMP_Published_Copy_Id__c=company.id;
        
        insert companyw;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        PMP_Company__c compInfo = [SELECT Id, Name FROM PMP_Company__c WHERE Name = 'test class Account'];
        //system.debug('compInfo'+compInfo);
       
    }
    @isTest static void batchTestInactiveMPI1(){ prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = [SELECT Id,Name,PRM_programCode__c from ChannelProgram limit 1];
    ChannelProgramLevel cplTitanium=[SELECT Id,Name,ProgramId from ChannelProgramLevel limit 1];
        
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account2',devRecordTypeId,true);
        
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company.PMP_Is_Published_Ind__c=true;
        
        insert company;
        System.assertNotEquals(company, Null);
        PMP_Company__c companyw=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw.PMP_Benefit_Update_Ind__c=true;
        companyw.PMP_Partner_Inactive_Ind__c = False;
        companyw.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw.PMP_Is_Working_Copy_Ind__c=true;
        companyw.PMP_Published_Copy_Id__c=company.id;
        
        insert companyw;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        PMP_Company__c compInfo = [SELECT Id, Name FROM PMP_Company__c WHERE Name = 'test class Account2'];
        //system.debug('compInfo'+compInfo);
        Test.startTest();
        
        Database.executeBatch(new PMP_MPDQBatchFix(), 10);
        
        
        Test.stopTest();}
    @isTest static void batchTestInactiveMPI(){
        
        
        
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
       /* ChannelProgram cpIPA1 = new ChannelProgram(); //Channel Program
        cpIPA1.Name='Intel Partner Alliance';
        cpIPA1.PRM_programCode__c='IPA';
        insert cpIPA1;
        
        ChannelProgramLevel cplTitanium1=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium1.Name='Titanium';
        cplTitanium1.ProgramId=cpIPA1.Id;
        insert cplTitanium1;
        */
         ChannelProgram cpIPA1 = [SELECT Id,Name,PRM_programCode__c from ChannelProgram limit 1];
    ChannelProgramLevel cplTitanium1=[SELECT Id,Name,ProgramId from ChannelProgramLevel limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account1',devRecordTypeId,true);
        
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company.PMP_Is_Published_Ind__c=true;
        company.PMP_Partner_Program_nm__c='';
        company.PMP_Account_Program_Membership__c='';
        company.PMP_IPA_Badge_Tier_Txt__c='';
        insert company;
        System.assertNotEquals(company, Null);
        PMP_Company__c companyw=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw.PMP_Benefit_Update_Ind__c=False;
        companyw.PMP_Partner_Inactive_Ind__c = False;
        companyw.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw.PMP_Is_Working_Copy_Ind__c=true;
        companyw.PMP_Published_Copy_Id__c=company.id;
        companyw.PMP_Partner_Program_nm__c='';
        companyw.PMP_Account_Program_Membership__c='';
        companyw.PMP_IPA_Badge_Tier_Txt__c='';
        insert companyw;
        company.PMP_Working_Copy_Id__c=companyw.id;
        update company;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA1.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        PMP_Company__c compInfo = [SELECT Id, Name FROM PMP_Company__c WHERE Name = 'test class Account1'];
        //system.debug('compInfo'+compInfo);
        Test.startTest();
        
        Database.executeBatch(new PMP_MPDQBatchFix(), 10);
        
        
        Test.stopTest();
    }
/*
@IsTest
static void testActivateLatestInactiveRel() {

    prm_skip_trigger__c rec = new prm_skip_trigger__c(
        Name = 'ABA_Trigger',
        inactive__c = false
    );
    insert rec;

    PRM_BatchCustomSetting__c cust = new PRM_BatchCustomSetting__c(
        Name='BatchFieldValues',
        PRM_MP_Benefits__c='Solution Marketplace Enhanced',
        PRM_PartnerRole__c='Service Provider',
        PRM_PartnerType__c='Cloud Service Provider (CSP)'
    );
    insert cust;

    ChannelProgram cpIPA2 = [SELECT Id,Name,PRM_programCode__c from ChannelProgram limit 1];
    ChannelProgramLevel cplTitanium2=[SELECT Id,Name,ProgramId from ChannelProgramLevel limit 1];
    Id devRecordTypeId =
        Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Intel Account')
        .getRecordTypeId();

    Id pagRtId =
        Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Partner Account Group')
        .getRecordTypeId();

    Account intelAcc =
        PMP_TestDataUtility.createIntelAccount(
            'Intel Test Account',
            devRecordTypeId,
            true
        );

    Account pag = new Account(
        RecordTypeId = pagRtId,
        Name = 'Test PAG',
        BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='12345',
        Core_Account_Type__c='Intel Authorized Distributor (IAD)'
    );
    insert pag;

    Core_Account_Group_Member__c grp =
        new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = pag.Id,
            Core_Intel_Account_Id__c = intelAcc.Id
        );
    insert grp;

    PMP_Company__c mpi1 = new PMP_Company__c(
        Name='MPI1',
        PMP_Company_Lifecycle_Status_Nm__c='Published',
        PMP_Is_Published_Ind__c=true,
        PMP_Benefit_Update_Ind__c=false
    );
    insert mpi1;

    PMP_Company__c mpi2 = new PMP_Company__c(
        Name='MPI2',
        PMP_Company_Lifecycle_Status_Nm__c='Published',
        PMP_Is_Published_Ind__c=true,
        PMP_Benefit_Update_Ind__c=false
    );
    insert mpi2;
     PMP_Company__c mpi3=new PMP_Company__c();
        mpi3.Name='accObj.Name';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        mpi3.PMP_Benefit_Update_Ind__c=False;
        mpi3.PMP_Partner_Inactive_Ind__c = False;
        mpi3.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        mpi3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        mpi3.PMP_Is_Published_Ind__c=true;
        mpi3.PMP_Partner_Program_nm__c='';
        mpi3.PMP_Account_Program_Membership__c='';
        mpi3.PMP_IPA_Badge_Tier_Txt__c='';
        insert mpi3;
        System.assertNotEquals(mpi3, Null);
        PMP_Company__c companyw=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw.PMP_Benefit_Update_Ind__c=False;
        companyw.PMP_Partner_Inactive_Ind__c = False;
        companyw.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw.PMP_Is_Working_Copy_Ind__c=true;
        companyw.PMP_Published_Copy_Id__c=mpi3.id;
        companyw.PMP_Partner_Program_nm__c='';
        companyw.PMP_Account_Program_Membership__c='';
        companyw.PMP_IPA_Badge_Tier_Txt__c='';
        insert companyw;
        mpi3.PMP_Working_Copy_Id__c=companyw.id;
        update mpi3;

    PRM_AccountChannelMembership__c acm =
        new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = pag.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Channel_Program_Id__c=cpIPA2.Id,
            PRM_Channel_Program_Level_Id__c=cplTitanium2.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='Test'
        );
    insert acm;
    PMP_OPID_MPI_Rel__c rel3 = new PMP_OPID_MPI_Rel__c(
        PMP_One_Partner_ID__c = pag.Id,
        PMP_Marketing_Profile_Id__c = mpi3.Id,
        Is_Active__c = true
    );

    insert new List<PMP_OPID_MPI_Rel__c>{
        rel3
    };
    rel3.Is_Active__c = false;
    update rel3;

    acm.PRM_Status_Reason_Txt__c = 'Batch Trigger';
    update acm;

    Test.startTest();

    Database.executeBatch(
        new PMP_MPDQBatchFix(),
        10
    );

    Test.stopTest();

    List<PMP_OPID_MPI_Rel__c> relResults = [
        SELECT Id, Is_Active__c
        FROM PMP_OPID_MPI_Rel__c
        WHERE Id IN :new Set<Id>{
            rel3.Id
        }
    ];

    Integer activeCount = 0;

    for(PMP_OPID_MPI_Rel__c r : relResults){
        if(r.Is_Active__c){
            activeCount++;
        }
    }
}
    @IsTest
static void testReactivateLatestInactivePagRelationship() {

    prm_skip_trigger__c rec = new prm_skip_trigger__c(
        Name = 'ABA_Trigger',
        inactive__c = false
    );
    insert rec;

    PRM_BatchCustomSetting__c cust = new PRM_BatchCustomSetting__c(
        Name='BatchFieldValues',
        PRM_MP_Benefits__c='Solution Marketplace Enhanced',
        PRM_PartnerRole__c='Service Provider',
        PRM_PartnerType__c='Cloud Service Provider (CSP)'
    );
    insert cust;

    ChannelProgram cpIPA =
        [SELECT Id, Name FROM ChannelProgram LIMIT 1];

    ChannelProgramLevel cpl =
        [SELECT Id, Name, ProgramId
         FROM ChannelProgramLevel
         LIMIT 1];

    Id intelRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Intel Account')
        .getRecordTypeId();

    Id pagRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Partner Account Group')
        .getRecordTypeId();

    Account intelAcc =
        PMP_TestDataUtility.createIntelAccount(
            'Coverage Intel Account',
            intelRt,
            true
        );

    Account pag = new Account(
        RecordTypeId = pagRt,
        Name = 'Coverage PAG',
        BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='12345',
        Core_Account_Type__c =
            'Intel Authorized Distributor (IAD)'
    );
    insert pag;

    insert new Core_Account_Group_Member__c(
        Core_Partner_Account_Id__c = pag.Id,
        Core_Intel_Account_Id__c = intelAcc.Id
    );

    PMP_Company__c pubCompany = new PMP_Company__c(
        Name='Coverage MPI',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Published',
        PMP_Is_Published_Ind__c=true,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile',
        PMP_Partner_Program_nm__c='',
        PMP_Account_Program_Membership__c='',
        PMP_IPA_Badge_Tier_Txt__c=''
    );
    insert pubCompany;

    PMP_Company__c wc = new PMP_Company__c(
        Name='Coverage WC',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Approved',
        PMP_Is_Working_Copy_Ind__c=true,
        PMP_Published_Copy_Id__c=pubCompany.Id,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile'
    );
    insert wc;

    pubCompany.PMP_Working_Copy_Id__c = wc.Id;
    update pubCompany;

    PRM_AccountChannelMembership__c acm =
        new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = pag.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Channel_Program_Id__c=cpIPA.Id,
            PRM_Channel_Program_Level_Id__c=cpl.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='Initial'
        );
    insert acm;

    PMP_OPID_MPI_Rel__c rel =
        new PMP_OPID_MPI_Rel__c(
            PMP_One_Partner_ID__c = pag.Id,
            PMP_Marketing_Profile_Id__c = pubCompany.Id,
            Is_Active__c = true
        );
    insert rel;

    rel.Is_Active__c = false;
    update rel;

    acm.PRM_Status_Reason_Txt__c = 'Force Batch';
    update acm;

    Test.startTest();

    Database.executeBatch(
        new PMP_MPDQBatchFix(),
        10
    );

    Test.stopTest();

    PMP_OPID_MPI_Rel__c relAfter =
        [SELECT Id, Is_Active__c
         FROM PMP_OPID_MPI_Rel__c
         WHERE Id = :rel.Id];

}
    @IsTest
static void testInactivateMPIWhenNoApprovedACM() {

       prm_skip_trigger__c rec = new prm_skip_trigger__c(
        Name = 'ABA_Trigger',
        inactive__c = false
    );
    insert rec;

    PRM_BatchCustomSetting__c cust = new PRM_BatchCustomSetting__c(
        Name='BatchFieldValues',
        PRM_MP_Benefits__c='Solution Marketplace Enhanced',
        PRM_PartnerRole__c='Service Provider',
        PRM_PartnerType__c='Cloud Service Provider (CSP)'
    );
    insert cust;

    ChannelProgram cpIPA =
        [SELECT Id, Name FROM ChannelProgram LIMIT 1];

    ChannelProgramLevel cpl =
        [SELECT Id, Name, ProgramId
         FROM ChannelProgramLevel
         LIMIT 1];

    Id intelRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Intel Account')
        .getRecordTypeId();

    Id pagRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Partner Account Group')
        .getRecordTypeId();

    Account intelAcc =
        PMP_TestDataUtility.createIntelAccount(
            'Coverage Intel Account',
            intelRt,
            true
        );

    Account pag = new Account(
        RecordTypeId = pagRt,
        Name = 'Coverage PAG',
        BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='12345',
        Core_Account_Type__c =
            'Intel Authorized Distributor (IAD)'
    );
    insert pag;

    insert new Core_Account_Group_Member__c(
        Core_Partner_Account_Id__c = pag.Id,
        Core_Intel_Account_Id__c = intelAcc.Id
    );

    PMP_Company__c pubCompany = new PMP_Company__c(
        Name='Coverage MPI',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Published',
        PMP_Is_Published_Ind__c=true,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile',
        PMP_Partner_Program_nm__c='',
        PMP_Account_Program_Membership__c='',
        PMP_IPA_Badge_Tier_Txt__c=''
    );
    insert pubCompany;

    PMP_Company__c wc = new PMP_Company__c(
        Name='Coverage WC',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Approved',
        PMP_Is_Working_Copy_Ind__c=true,
        PMP_Published_Copy_Id__c=pubCompany.Id,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile'
    );
    insert wc;

    pubCompany.PMP_Working_Copy_Id__c = wc.Id;
    update pubCompany;

    PRM_AccountChannelMembership__c acm =
        new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = pag.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Channel_Program_Id__c=cpIPA.Id,
            PRM_Channel_Program_Level_Id__c=cpl.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='Initial'
        );
    insert acm;

    PMP_OPID_MPI_Rel__c rel =
        new PMP_OPID_MPI_Rel__c(
            PMP_One_Partner_ID__c = pag.Id,
            PMP_Marketing_Profile_Id__c = pubCompany.Id,
            Is_Active__c = true
        );
    insert rel;

    rel.Is_Active__c = false;
    update rel;

    /*acm.PRM_Status_Reason_Txt__c = 'Force Batch';
    update acm;*/
/*
    Test.startTest();
     acm.PRM_Status_Nm__c = 'Pending';
    update acm;
    Database.executeBatch(new PMP_MPDQBatchFix(),10);
    Test.stopTest();

    PMP_Company__c companyAfter =
        [SELECT PMP_Benefit_Update_Ind__c
         FROM PMP_Company__c
         WHERE Id=:pubCompany.Id];

  /*  System.assertEquals(
        true,
        companyAfter.PMP_Benefit_Update_Ind__c
    );*/

  /*  @IsTest
static void testInactivateMPIWhenNoApprovedACMScenario3() {

       prm_skip_trigger__c rec = new prm_skip_trigger__c(
        Name = 'ABA_Trigger',
        inactive__c = false
    );
    insert rec;

    PRM_BatchCustomSetting__c cust = new PRM_BatchCustomSetting__c(
        Name='BatchFieldValues',
        PRM_MP_Benefits__c='Solution Marketplace Enhanced',
        PRM_PartnerRole__c='Service Provider',
        PRM_PartnerType__c='Cloud Service Provider (CSP)'
    );
    insert cust;

    ChannelProgram cpIPA =
        [SELECT Id, Name FROM ChannelProgram LIMIT 1];

    ChannelProgramLevel cpl =
        [SELECT Id, Name, ProgramId
         FROM ChannelProgramLevel
         LIMIT 1];

    Id intelRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Intel Account')
        .getRecordTypeId();

    Id pagRt =
        Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Partner Account Group')
        .getRecordTypeId();

    Account intelAcc =
        PMP_TestDataUtility.createIntelAccount(
            'Coverage Intel Account',
            intelRt,
            true
        );

    Account pag = new Account(
        RecordTypeId = pagRt,
        Name = 'Coverage PAG',
        BillingCity='City',
        BillingStreet='Street',
        BillingCountry='India',
        BillingPostalCode='12345',
        Core_Account_Type__c =
            'Intel Authorized Distributor (IAD)'
    );
    insert pag;

    insert new Core_Account_Group_Member__c(
        Core_Partner_Account_Id__c = pag.Id,
        Core_Intel_Account_Id__c = intelAcc.Id
    );

    PMP_Company__c pubCompany = new PMP_Company__c(
        Name='Coverage MPI',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Published',
        PMP_Is_Published_Ind__c=true,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile',
        PMP_Partner_Program_nm__c='',
        PMP_Account_Program_Membership__c='',
        PMP_IPA_Badge_Tier_Txt__c=''
    );
    insert pubCompany;

    PMP_Company__c wc = new PMP_Company__c(
        Name='Coverage WC',
        PMP_Benefit_Update_Ind__c=false,
        PMP_Partner_Inactive_Ind__c=false,
        PMP_Company_Lifecycle_Status_Nm__c='Approved',
        PMP_Is_Working_Copy_Ind__c=true,
        PMP_Published_Copy_Id__c=pubCompany.Id,
        PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile'
    );
    insert wc;

    pubCompany.PMP_Working_Copy_Id__c = wc.Id;
    update pubCompany;

    PRM_AccountChannelMembership__c acm =
        new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = pag.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Channel_Program_Id__c=cpIPA.Id,
            PRM_Channel_Program_Level_Id__c=cpl.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='Initial'
        );
    insert acm;

    PMP_OPID_MPI_Rel__c rel =
        new PMP_OPID_MPI_Rel__c(
            PMP_One_Partner_ID__c = pag.Id,
            PMP_Marketing_Profile_Id__c = pubCompany.Id,
            Is_Active__c = true
        );
    insert rel;

     /*rel.Is_Active__c = false;
    update rel;

   acm.PRM_Status_Reason_Txt__c = 'Force Batch';
    update acm;*/
  /*  Test.startTest();   
    acm.PRM_Status_Nm__c = 'Pending';
    update acm;
    Database.executeBatch(new PMP_MPDQBatchFix(),10);
    Test.stopTest();

    PMP_Company__c companyAfter =
        [SELECT PMP_Benefit_Update_Ind__c
         FROM PMP_Company__c
         WHERE Id=:pubCompany.Id];
}*/
     @isTest static void batchTestSendwarningemail(){ prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = [SELECT Id,Name,PRM_programCode__c from ChannelProgram limit 1];
    ChannelProgramLevel cplTitanium=[SELECT Id,Name,ProgramId from ChannelProgramLevel limit 1];
        
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account2',devRecordTypeId,true);
        Account accObj2 = PMP_TestDataUtility.createIntelAccount('test class Account3',devRecordTypeId,true);
                                                     Account accObj3 = PMP_TestDataUtility.createIntelAccount('test class Account4',devRecordTypeId,true);
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company.PMP_Is_Published_Ind__c=true;
        
        insert company;
        System.assertNotEquals(company, Null);
        PMP_Company__c companyw=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw.PMP_Benefit_Update_Ind__c=true;
        companyw.PMP_Partner_Inactive_Ind__c = False;
        companyw.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw.PMP_Is_Working_Copy_Ind__c=true;
        companyw.PMP_Published_Copy_Id__c=company.id;
        
        insert companyw;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='test';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
                                                     
        List<Account> accts2 = new List<Account>();
        Account newPagAccount2 = new Account();//Account
        newPagAccount2.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount2.Name='Greg Thomas2';
        newPagAccount2.BillingCity='City2';
        newPagAccount2.BillingStreet='Street2';
        newPagAccount2.BillingCountry='India';
        newPagAccount2.BillingPostalCode='Postal code';
        newPagAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts2.add(newPagAccount2);
        insert accts2;
        
        
        PMP_Company__c company2=new PMP_Company__c();
        company2.Name=accObj2.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company2.PMP_Benefit_Update_Ind__c=true;
        company2.PMP_Partner_Inactive_Ind__c = False;
        company2.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company2.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company2.PMP_Is_Published_Ind__c=true;
        
        insert company2;
        System.assertNotEquals(company2, Null);
        PMP_Company__c companyw2=new PMP_Company__c();
        companyw2.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw2.PMP_Benefit_Update_Ind__c=true;
        companyw2.PMP_Partner_Inactive_Ind__c = False;
        companyw2.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw2.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw2.PMP_Is_Working_Copy_Ind__c=true;
        companyw2.PMP_Published_Copy_Id__c=company2.id;
        
        insert companyw2;
        
        PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=newPagAccount2.id;
        acm2.PRM_Status_Nm__c='Approved';
        acm2.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Reason_Txt__c='test';
        insert acm2;
        
        Core_Account_Group_Member__c coreAccnt2 = new Core_Account_Group_Member__c();
        coreAccnt2.Core_Partner_Account_Id__c = newPagAccount2.id;
        coreAccnt2.Core_Intel_Account_Id__c = accObj2.id; 
        insert coreAccnt2;
        
        PMP_OPID_MPI_Rel__c jun2= new PMP_OPID_MPI_Rel__c();
        jun2.PMP_One_Partner_ID__c= newPagAccount2.Id;
        jun2.PMP_Marketing_Profile_Id__c= company2.Id;
        jun2.Is_Active__c=true;     
        insert jun2;
                                                     
      /*  List<Account> accts3 = new List<Account>();
        Account newPagAccount3 = new Account();//Account
        newPagAccount3.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount3.Name='Greg Thomas3';
        newPagAccount3.BillingCity='City3';
        newPagAccount3.BillingStreet='Street3';
        newPagAccount3.BillingCountry='India';
        newPagAccount3.BillingPostalCode='Postal code';
        newPagAccount3.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts3.add(newPagAccount3);
        insert accts3;
        
        
        PMP_Company__c company3=new PMP_Company__c();
        company3.Name=accObj3.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company3.PMP_Benefit_Update_Ind__c=true;
        company3.PMP_Partner_Inactive_Ind__c = False;
        company3.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        company3.PMP_Is_Published_Ind__c=true;
        
        insert company3;
        System.assertNotEquals(company, Null);
        PMP_Company__c companyw3=new PMP_Company__c();
        companyw.Name='wORKIGN COPY';
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        companyw3.PMP_Benefit_Update_Ind__c=true;
        companyw3.PMP_Partner_Inactive_Ind__c = False;
        companyw3.PMP_Company_Lifecycle_Status_Nm__c ='Approved';
        companyw3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyw3.PMP_Is_Working_Copy_Ind__c=true;
        companyw3.PMP_Published_Copy_Id__c=company.id;
        
        insert companyw3;
        
        PRM_AccountChannelMembership__c acm3= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm3.PRM_Account_Id__c=newPagAccount.id;
        acm3.PRM_Status_Nm__c='Approved';
        acm3.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm3.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm3.PRM_Partner_Role__c='Service Provider';
        acm3.PRM_Status_Reason_Txt__c='test';
        insert acm3;
        
        Core_Account_Group_Member__c coreAccnt3 = new Core_Account_Group_Member__c();
        coreAccnt3.Core_Partner_Account_Id__c = newPagAccount3.id;
        coreAccnt3.Core_Intel_Account_Id__c = accObj3.id; 
        insert coreAccnt3;
        
        PMP_OPID_MPI_Rel__c jun3= new PMP_OPID_MPI_Rel__c();
        jun3.PMP_One_Partner_ID__c= newPagAccount3.Id;
        jun3.PMP_Marketing_Profile_Id__c= company3.Id;
        jun3.Is_Active__c=true;     
        insert jun3;                                             
        */
        list<PMP_Company__c> compInfo = [SELECT Id, Name FROM PMP_Company__c WHERE Name = 'test class Account2' or Name = 'test class Account3' or Name ='test class Account4'];
        //system.debug('compInfo'+compInfo);
        Test.startTest();
        
        Database.executeBatch(new PMP_MPDQBatchFix(), 10);
        
        
                                                     Test.stopTest();}}