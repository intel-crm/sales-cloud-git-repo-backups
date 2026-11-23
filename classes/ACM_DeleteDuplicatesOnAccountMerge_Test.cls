@isTest
public class ACM_DeleteDuplicatesOnAccountMerge_Test{
    @TestSetup
    private static void setCommonData(){
        Core_Account_Bypass_Validation_Rule__c bypass= new Core_Account_Bypass_Validation_Rule__c();
        bypass.ByPass__c = true;
        bypass.SetupOwnerId = UserInfo.getOrganizationId();
        insert bypass;
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        List<Account> accountListToInsert = new List<Account>();
        
        Account account1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Acct1','Intel Account','UNFD_CTRY_CUST');
        account1.Core_Business_Party_Id__c = '1234568';
        insert account1;
        insert new AccountHistory(AccountId=account1.Id, Field= 'accountMerged');
        
        Account account2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('IPAAcct','Intel Account','UNFD_CTRY_CUST');
        account2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        account2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;        
        //insert account2;
        accountListToInsert.add(account2);
        
        Account account3 = new Account();
        account3.RecordTypeId = accountRTPartnerAccountGroup;
        account3.Name='Amazon';
        account3.Core_Account_Type__c ='Distributor';
        //insert account3;
        accountListToInsert.add(account3);
        
        Account account6 = new Account();
        account6.RecordTypeId = accountRTPartnerAccountGroup;
        account6.Name='Amazon';
        account6.Core_Account_Type__c ='Distributor';
        //insert account6;
        accountListToInsert.add(account6);
        
        Account account7 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Acct4','Intel Account','UNFD_CTRY_CUST');
        account7.Core_Business_Party_Id__c = '1234568';
        account7.Core_Is_PAG_Member_Ind__c = false;
        //insert account7;
        accountListToInsert.add(account7);
        
        Account account4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Acct2','Intel Account','UNFD_CTRY_CUST');
        account4.Core_Business_Party_Id__c = '1234568';
        //insert account4;
        accountListToInsert.add(account4);
        
        Account account5 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Acct3','Intel Account','UNFD_CTRY_CUST');
        account5.Core_Business_Party_Id__c = '1234568';
        //insert account5;
        accountListToInsert.add(account5);
        
        insert accountListToInsert;
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@outlook.com';
        con.Mailing_Country_Region__c='AUS';
        con.MailingCountry='AUS';
        
        con.AccountId=account1.Id;
        insert con;
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_PartnerAgreement__c p=new PRM_PartnerAgreement__c();
        p.Name='Intel Partner Alliance Terms & Condition';
        p.PRM_InActive_Ind__c=false;
        p.PRM_Agreement_Cd__c='IPA_TANDC';
        p.PRM_Channel_Program_Id__c=cpIPATest.id;
        insert p;
        
        List<PRM_AccountLegalAgreemntAssociation__c> alaList = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c alaa = new PRM_AccountLegalAgreemntAssociation__c();
        alaa.PRM_Account_Id__c = account1.Id;
        alaa.PRM_Partner_Agreement_Id__c = p.Id;
        alaa.PRM_Contact__c = con.Id;
        alaa.PRM_InActive_Ind__c=FALSE;
        alaa.PRM_Agreement_Sign_Dt__c=system.now();
        alaa.CreatedDate=system.now();
        //alaa.PRM_Partner_Agreement_Id__r.name='CSP_TNC_NA_EN';
       // insert alaa;
        alaList.add(alaa);
        PRM_AccountLegalAgreemntAssociation__c alaa1 = new PRM_AccountLegalAgreemntAssociation__c();
        alaa1.PRM_Account_Id__c = account1.Id;
        alaa1.PRM_Partner_Agreement_Id__c = p.Id;
        alaa1.PRM_Contact__c = con.Id;
        alaa1.PRM_InActive_Ind__c=FALSE;
        alaa1.PRM_Agreement_Sign_Dt__c=system.now();
        alaa1.CreatedDate=system.now();
        //alaa1.PRM_Partner_Agreement_Id__r.name='CSP_TNC_NA_EN';
        //insert alaa1;
        alaList.add(alaa1);
       insert alaList;
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points View';
        pb.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = account1.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb.id;
        aba1.PRM_Status_Nm__c = 'active';
        aba1.PRM_Status_Reason_Txt__c = 'test';
        aba1.CreatedDate=system.now();
        //insert aba1;
        abaList.add(aba1);
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c();
        aba2.PRM_Account_Id__c = account1.Id;
        aba2.PRM_Partner_Benefit_Id__c = pb.id;
        aba2.PRM_Status_Nm__c = 'active';
        aba2.PRM_Status_Reason_Txt__c = 'test';
        aba2.CreatedDate=system.now();
        //insert aba2;
        abaList.add(aba2);
        insert abaList;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.recordtypeId = specid;
        spec.name='SM Select Benfit';
        spec.PRM_Description_Txt__c='Test';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Distributor';
        spec.PRM_Tier_Nm__c='Member';
        spec.PRM_Start_Date_Dt__c= system.today();
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        List<PRM_Account_Specialty_Association__c> asaList = new List<PRM_Account_Specialty_Association__c>(); // Account Speciality Association
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= account2.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_Partner_Role__c='Service Provider';
        asa.PRM_InActive_Ind__c= FALSE;
        asa.CreatedDate= system.now();
        //insert asa;
        asalist.add(asa);
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= account2.id;
        asa1.PRM_Specialty_Id__c= spec.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        asa1.PRM_InActive_Ind__c= FALSE;
        asa1.CreatedDate= system.now();
       // insert asa1;
        asalist.add(asa1);
        insert asaList;
         List<Core_Account_Group_Member__c> agmList = new List<Core_Account_Group_Member__c>(); //OPID Group Member
        Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Partner_Account_Id__c = account6.Id;
        agm1.Core_Intel_Account_Id__c = account7.Id;
        agm1.Core_MDA_Ind__c = true;
        agm1.Core_Inactive_Ind__c = false;
        agm1.CreatedDate = system.now();
       agmList.add(agm1);
        //insert agmList;
        
     Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = account6.Id;
        agm2.Core_Intel_Account_Id__c = account7.Id;
        //agm2.Core_MDA_Ind__c = true;
        agm2.Core_Inactive_Ind__c = false;
        agm2.CreatedDate = system.now();
       // insert agm2;
        agmList.add(agm2);
        insert agmList;
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>(); 
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=account1.Id;
        acr1.PRM_Relationship_Id__c = cr1.Id;
        acr1.PRM_Contact_Id__c=con.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Reason_Txt__c='test';
        //insert acr1;        
        acrList.add(acr1);
        
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=account1.Id;
        acr2.PRM_Relationship_Id__c = cr1.Id;
        acr2.PRM_Contact_Id__c=con.Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Status_Reason_Txt__c='test';
        //insert acr2;
        acrList.add(acr2);
		insert acrList;
        
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=account1.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Inactive';
        acctChnlMemTest.CreatedDate = system.now();
        acctChnlMemTest.PRM_Status_Reason_Txt__c='test';
       // insert acctChnlMemTest;
        acmList.add(acctChnlMemTest);
       PRM_AccountChannelMembership__c acctChnlMemTest1=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=account4.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Pending';
        acctChnlMemTest1.CreatedDate = system.now();
        acctChnlMemTest1.PRM_Status_Reason_Txt__c='test';
       // insert acctChnlMemTest1;
        acmList.add(acctChnlMemTest1);
        PRM_AccountChannelMembership__c acctChnlMemTest2=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=account5.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.CreatedDate = system.now();
        acctChnlMemTest2.PRM_Status_Reason_Txt__c='test';
        //insert acctChnlMemTest2;
        acmList.add(acctChnlMemTest2);
        insert acmList;
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        insert profileQues;
       PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        insert profileQues1;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c(); //profile response
        response.PRM_Account_Id__c = account1.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Response_Txt__c='true';
        response.PRM_InActive_Ind__c = false;
        response.CreatedDate = system.now();
        insert response;
       PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c(); //profile response
        response1.PRM_Account_Id__c = account1.Id;
        response1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response1.PRM_Response_Txt__c='false';
        response1.PRM_InActive_Ind__c = false;
        response1.CreatedDate = system.now();
        insert response1;
        
        Business_Types__c bussType = new Business_Types__c();
        bussType.Name = 'Demo Test';
        bussType.Business_Type_Code__c = 'SLS_CRM';
        insert bussType;
        
        List<Account_Business_Types__c> accBussTypeList  = new List<Account_Business_Types__c>();
        Account_Business_Types__c accBussType = new Account_Business_Types__c();
        accBussType.Account__c = account1.Id;
        accBussType.Business_Types__c = bussType.Id;
        accBussTypeList.add(accBussType);
        Account_Business_Types__c accBusType = new Account_Business_Types__c();
        accBusType.Account__c = account1.Id;
        accBusType.Business_Types__c = bussType.Id;
        accBussTypeList.add(accBusType);
        insert accBussTypeList;
        
        List<Core_Account_Compliance_Watch_List__c> cwlList  = new List<Core_Account_Compliance_Watch_List__c>();
        Core_Account_Compliance_Watch_List__c cwl1 = new Core_Account_Compliance_Watch_List__c();
        cwl1.Core_Account_Id__c = account1.Id;
        cwl1.Core_Type__c = 'EC';
        insert cwl1;
        
        Core_Account_Compliance_Watch_List__c cwl2 = new Core_Account_Compliance_Watch_List__c();
        cwl2.Core_Account_Id__c = account1.Id;
        cwl2.Core_Type__c = 'EC';
        insert cwl2;


    }
    
    @isTest
    private static void execute(){
    
        Test.startTest();
        Database.executeBatch(new ACM_DeleteDuplicatesOnAccountMerge());
        Test.stopTest();    
    }
    @isTest
    Private static void schedulerclass(){
        Test.startTest(); 
        ACM_DeleteDuplicatesOnAccountMerge batchschedule = new ACM_DeleteDuplicatesOnAccountMerge();
        String cronExpression = '0 0 0/1 1/1 * ? *';
        system.schedule('Batch Test' , cronExpression , batchschedule);    
        Test.stopTest();        
    }
    
    
  
 
}