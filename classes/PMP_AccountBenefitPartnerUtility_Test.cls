@isTest
public class PMP_AccountBenefitPartnerUtility_Test {

   
  @isTest()
  public static void  insertUtility() { 
      
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
      Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

      PMP_Static_Constants__c basicAccess = new PMP_Static_Constants__c();
      basicAccess.Name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
      basicAccess.PMP_Value__c = 'BNFTSMBA';
      insert basicAccess;

      PMP_Static_Constants__c basicProfile = new PMP_Static_Constants__c();
      basicProfile.Name = 'PMP_BENEFIT_BASIC_PROFILE';
      basicProfile.PMP_Value__c = 'BFTMKTPLBC';
      insert basicProfile;

      PMP_Static_Constants__c Enhanced = new PMP_Static_Constants__c();
      Enhanced.Name = 'PMP_BENEFIT_ENHANCED_CODE';
      Enhanced.PMP_Value__c = 'BFTMKTPLED';
      insert Enhanced;
      
      prm_skip_trigger__c rec = new prm_skip_trigger__c();
      rec.Name = 'ABA_Trigger';
      rec.inactive__c = false;
      insert rec;

      Account newAccount = new Account();//Account
      newAccount.RecordTypeId = recordTypeIdAccount;
      newAccount.Name='Greg Thomas';
      newAccount.BillingCity='City';
      newAccount.BillingStreet='Street';
      newAccount.BillingCountry='India';
      newAccount.BillingPostalCode='Postal code';
      newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount;
      
      Account newPagAccount = new Account();//Account
      newPagAccount.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount.Name='Greg Thomas';
      newPagAccount.BillingCity='City';
      newPagAccount.BillingStreet='Street';
      newPagAccount.BillingCountry='India';
      newPagAccount.BillingPostalCode='Postal code';
      newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount;
      system.assertEquals('Greg Thomas',newPagAccount.Name);
      
      Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
      coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
      coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
      insert coreAccnt;
      
      //Set<Id> accIds = new Set<Id> { newAccount.Id };
      Map<Id,Boolean> accIdsMap = new Map<Id,Boolean>();
      accIdsMap.put(newAccount.Id,false);
        
      
       //custom Setting
      PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
      cust.Name='BatchFieldValues';
      cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
      cust.PRM_PartnerRole__c= 'Service Provider';
      cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
      insert cust;
      
      Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
      tiggerCust.Name ='Sync_Published_Copy';
      tiggerCust.Core_Active__c = false;
      tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust.Core_Object__c ='PMP_Company__c';
      tiggerCust.Core_Trigger_Events__c ='After update';
      insert tiggerCust;
      
      Contact cont = new Contact();  //Contact  
      cont.AccountId=newAccount.Id;
      cont.lastName='Grill';
      cont.FirstName='Adam';
      cont.email='AdamGrill@rediff.com';
      cont.Core_Job_Function__c='Branch Manager';
      cont.Core_eRPM_Language_Code__c='Eng';
     // cont.Core_IPA_Partner_Role__c = 'Service Provider';
      cont.Core_IPA_PartnerRole__c = 'Service Provider';
      cont.MailingCountry = 'India';
      insert cont;
      
      ChannelProgram cp = new ChannelProgram(); //Channel Program
      cp.Name='Intel Partner Alliance';
      cp.PRM_programCode__c='IPA';
      insert cp;
          
      ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
      cpl.Name='Titanium';
      cpl.ProgramId=cp.Id;
      insert cpl;
      
      ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
      cpl1.Name='Member';
      cpl1.ProgramId=cp.Id;
      insert cpl1;
      
      ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
      cpl2.Name='Gold';
      cpl2.ProgramId=cp.Id;
      insert cpl2;        
      
      PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
      contRelation.Name='Primary Contact';
      contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
      contRelation.PRM_Channel_Program_Id__c = cp.Id;
      contRelation.PRM_Default_Relationship_Ind__c = true;
      insert contRelation;
      
      PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel.PRM_Account_Id__c=newAccount.Id;
      acctContRel.PRM_Contact_Id__c=cont.Id;
      acctContRel.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel.PRM_InActive_Ind__c=false;
      insert acctContRel;
      
      PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm.PRM_Account_Id__c=newAccount.id;
      acm.PRM_Status_Nm__c='Approved';
      acm.PRM_Channel_Program_Id__c=cp.Id;
      acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm.PRM_Partner_Role__c='Service Provider';
      acm.PRM_Status_Reason_Txt__c='Testing';
      insert acm;
      
      PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm1.PRM_Account_Id__c=newPagAccount.id;
      acm1.PRM_Status_Nm__c='Approved';
      acm1.PRM_Channel_Program_Id__c=cp.Id;
      acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm1.PRM_Partner_Role__c='Distributor';
       acm1.PRM_Status_Reason_Txt__c='Testing';
      insert acm1;
      
      PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cp.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
      
      PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb1.Name = 'Partner University1';
      pb1.PRM_Channel_Program_Id__c = cp.id;
      pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb1.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb1;
      
      PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb2.Name = 'Partner University1';
      pb2.PRM_Channel_Program_Id__c = cp.id;
      pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      pb2.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb2;
      
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cp.Id;
      insert pt;
      
      PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem.PRM_Approval_Type_Nm__c='Automatic';
      bem.PRM_Channel_Program_Id__c=cp.Id;
      bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem.PRM_Covered_Account_Ind__c=True;
      bem.PRM_IsActive_Ind__c=True;
      bem.PRM_Partner_Benefit_Id__c=pb.Id;
      bem.PRM_Partner_Type_Id__c=pt.Id;
      bem.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem;
      
      PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem1.PRM_Approval_Type_Nm__c='Automatic';
      bem1.PRM_Channel_Program_Id__c=cp.Id;
      bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem1.PRM_Covered_Account_Ind__c=True;
      bem1.PRM_IsActive_Ind__c=True;
      bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem1.PRM_Partner_Type_Id__c=pt.Id;
      bem1.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem1;
      
      PRM_VXBnftMatrix__c bem3=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem3.PRM_Approval_Type_Nm__c='Automatic';
      bem3.PRM_Channel_Program_Id__c=cp.Id;
      bem3.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem3.PRM_Covered_Account_Ind__c=True;
      bem3.PRM_IsActive_Ind__c=True;
      bem3.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem3.PRM_Partner_Type_Id__c=pt.Id;
      bem3.PRM_Partner_Role_Nm__c='Distributor';
      insert bem3;

      Test.startTest();
      
      PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newPagAccount.Id;
      aba.PRM_Partner_Benefit_Id__c = pb1.id;
      aba.PRM_Status_Nm__c = 'Active';
	  aba.PRM_Status_Reason_Txt__c='Testing';
      insert aba;

      PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
      aba1.PRM_Account_Id__c = newAccount.Id;
      aba1.PRM_Partner_Benefit_Id__c = pb.id;
      aba1.PRM_Status_Nm__c = 'Active';
	  aba1.PRM_Status_Reason_Txt__c='Testing';
      insert aba1;

      
      
      List<PMP_OPID_MPI_Rel__c> listJunction = PMP_Utility.getJunctionAccountToMpiByAccountId(new Set<Id>{newPagAccount.id});
      listJunction[0].Is_Active__c = false;
      update listJunction[0];    
    
      Test.stopTest();
  }
    
    
    @isTest
    public static void testCalculateBadgeTier(){
        
         Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        insert opidAcc;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
       // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry = 'India';
        insert cont;

        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
         acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        system.assertEquals('Service Provider', acm.PRM_Partner_Role__c);
        
        PRM_AccountChannelMembership__c opidacm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm.PRM_Account_Id__c=opidAcc.id;
        opidacm.PRM_Status_Nm__c='Approved';
        opidacm.PRM_Channel_Program_Id__c=cp.Id;
        opidacm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm.PRM_Partner_Role__c='Service Provider';
         opidacm.PRM_Status_Reason_Txt__c='Testing';
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(opidacm);
        acmList.add(acm);
        
        Test.startTest();
        PMP_AccountBenefitPartnerUtility.calculateIpaBadgeTier(acmList);
        Test.stopTest();
    }

    @isTest 
    public static void testMappingAttributeInsertion(){
        
        Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        //Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='testTier';
        company.PMP_Account_Specialty__c='None';
            company.PMP_Partner_Program_nm__c='Manufacturer';
        company.PMP_Partner_Segment_Nm__c='Client Computing';
        company.PMP_Account_Id__c=newAccount.Id;
        insert company;
        
        system.assertEquals('Client Computing', company.PMP_Partner_Segment_Nm__c);
        
        //PMP_Partner_Specialty__c spec = new PMP_Partner_Specialty__c(Name='testSpec',PMP_Is_Active_Ind__c = true);
        //PMP_Partner_Segment__c seg = new PMP_Partner_Segment__c(Name='testSeg',PMP_Is_Active_Ind__c = true);
        //PMP_Partner_Tier__c tier = new PMP_Partner_Tier__c(Name= 'testTier');
        //PMP_Partner_Program__c prog = new PMP_Partner_Program__c(Name = 'testProg',PMP_Is_Active_Ind__c = true);
        
        PMP_AccountBenefitPartnerUtility.InsertCompanyAttributeMappingRecords(new List<PMP_Company__c>{company});
        Test.stopTest();
    }
    /* @isTest
    public static void upgradeBaToBP(){
        
         prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        Test.startTest();
        
         //custom Setting
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
        insert cust;
        
        Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
        tiggerCust.Name ='Sync_Published_Copy';
        tiggerCust.Core_Active__c = false;
        tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
        tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
        tiggerCust.Core_Object__c ='PMP_Company__c';
        tiggerCust.Core_Trigger_Events__c ='After update';
        insert tiggerCust;
        
   /*     Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Manufacturer';
        pt.PRM_Role_Name__c='Manufacturer';
        pt.PRM_PartneryTypeCode__c='Manufacturer';
        pt.PRM_PartnerRoleCode__c='Manufacturer';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Solutions Marketplace Basic Profile';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        
        PRM_PartnerBenefit__c bp = new PRM_PartnerBenefit__c(); //Partner Benefit
        bp.Name = 'Solutions Marketplace Enhanced';
        bp.PRM_Channel_Program_Id__c = cp.id;
        bp.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        bp.PRM_Account_Type_Nm__c = 'Both'; 
        insert bp;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl2.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Manufacturer';
        insert bem;
        
        PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem2.PRM_Approval_Type_Nm__c='Automatic';
        bem2.PRM_Channel_Program_Id__c=cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem2.PRM_Covered_Account_Ind__c=True;
        bem2.PRM_IsActive_Ind__c=True;
        bem2.PRM_Partner_Benefit_Id__c=bp.Id;
        bem2.PRM_Partner_Type_Id__c=pt.Id;
        bem2.PRM_Partner_Role_Nm__c='Manufacturer';
        insert bem2;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        aba.PRM_Partner_Benefit_Id__c = bp.Id;
        update aba;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;


        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
            
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;        
                
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        system.assertEquals('Approved', acm.PRM_Status_Nm__c);
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        insert acm1;
        
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Partner University1';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb1;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem2.PRM_Approval_Type_Nm__c='Automatic';
        bem2.PRM_Channel_Program_Id__c=cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem2.PRM_Covered_Account_Ind__c=True;
        bem2.PRM_IsActive_Ind__c=True;
        bem2.PRM_Partner_Benefit_Id__c=pb.Id;
        bem2.PRM_Partner_Type_Id__c=pt.Id;
        bem2.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem2;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        aba.PRM_Partner_Benefit_Id__c = pb.Id;
        //update aba;

        Test.stopTest();
    } */
    
    /* @isTest static void insertUtilityTest(){
         
        //custom Setting
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
        insert cust;

        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
        List<Account> lstOfAcc = new List<Account>(); 
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Benzopid';
        parent1.BillingCity='New Town';
        parent1.BillingStreet='Street Major';
        parent1.BillingCountry='France';
        parent1.BillingPostalCode='9999991';
        parent1.Core_Account_Type__c = 'Distributor';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c = true; 
        parent1.Core_IPA_Badge_Tier__c = 'Gold';
        lstOfAcc.add(parent1);
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='Benzeid';
        testAccount.BillingCity='City Cross Site';
        testAccount.BillingStreet='Street alphano';
        testAccount.BillingCountry='Canada';
        testAccount.BillingPostalCode='Postal code1';
        testAccount.Core_Account_Type__c = 'Distributor';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Core_IPA_Badge_Tier__c = 'Gold';
        lstOfAcc.add(testAccount);
        insert lstOfAcc;
    
         
        PMP_Company__c company1=New PMP_Company__c();
        company1.PMP_Account_Id__c =  testAccount.Id;
        company1.Name='Company1';
        company1.PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile';
        company1.PMP_Is_Working_Copy_Ind__c=TRUE;
        insert company1;

          
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
         
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
         
         PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
         
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'IPA';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
         
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Sales PRM - Partner Points Viewer';
        ed.Core_Display_Name__c='Sales PRM - Partner Points Viewer';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id;
        insert coreAccnt;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest1);
        
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest);
        insert acmList;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Solution Marketplace Basic Access';
        pbTest2.PRM_Benefit_Cd__c = 'BNFTSMBA';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
       
         
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Solution Marketplace Basic Profile';
        pbTest3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);
                              
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solution Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        pbList[0].PRM_InActive_Ind__c=true;
        pbList[1].PRM_InActive_Ind__c=true;
        pbList[2].PRM_InActive_Ind__c=true;
        update pbList;
    
         
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest2.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Manual';
        insert em;
         
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        List<PRM_VXBnftMatrix__c> lstOfBnftMatrix = new List<PRM_VXBnftMatrix__c>();  
        PRM_VXBnftMatrix__c bmTest1 = new PRM_VXBnftMatrix__c();
        bmTest1.PRM_Partner_Benefit_Id__c = pbTest3.Id;
        bmTest1.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest1.PRM_Channel_Program_Level_Id__c = cplTest.Id;
      //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest1.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest1.PRM_Covered_Account_Ind__c = true;
        bmTest1.PRM_IsActive_Ind__c = true;
        bmTest1.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest1);
         
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
      //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest2);
         
        PRM_VXBnftMatrix__c bmTest3 = new PRM_VXBnftMatrix__c();
        bmTest3.PRM_Partner_Benefit_Id__c = pbTest2.Id;
        bmTest3.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest3.PRM_Channel_Program_Level_Id__c = cplTest.Id;
      //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest3.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest3.PRM_Covered_Account_Ind__c = true;
        bmTest3.PRM_IsActive_Ind__c = true;
        bmTest3.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest3); 
        insert lstOfBnftMatrix;
         
                  
         
         Test.startTest();
         List<PRM_AccountBenefitAssociation__c> lstOfAba = new List<PRM_AccountBenefitAssociation__c>();  
       
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = parent1.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        lstOfAba.add(abassociationTest1);
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent1.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        lstOfAba.add(abassociationTest2);       
        insert lstOfAba;
         
         Set<Id> accountIds=New Set<Id>();
         accountIds.add(testAccount.Id);
         accountIds.add(parent1.Id);
         
         PMP_AccountBenefitPartnerUtility.insertUtility(lstOfAba);
         PMP_AccountBenefitPartnerUtility.createEnhancedPartner(accountIds);
         
         test.stopTest();
    }*/
    
     /* @isTest static void updateUtilityTest(){
         
          prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
         
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Account_Id__c=newAccount.Id;
        insert company;
        
         //custom Setting
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
        insert cust;

        Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
        tiggerCust.Name ='Sync_Published_Copy';
        tiggerCust.Core_Active__c = false;
        tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
        tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
        tiggerCust.Core_Object__c ='PMP_Company__c';
        tiggerCust.Core_Trigger_Events__c ='After update';
        insert tiggerCust;    
         
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
       // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
            
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Solutions Marketplace Basic Profile';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb1;
                 
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
         
       Map<Id,PRM_AccountBenefitAssociation__c> Oldmap =new Map<Id,PRM_AccountBenefitAssociation__c>();
         List<PRM_AccountBenefitAssociation__c> abaList=new List<PRM_AccountBenefitAssociation__c>();
        
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb1.id;
        aba1.PRM_Status_Nm__c = 'active';
        insert aba1;
        
        Oldmap.put(aba1.id, aba1);
         
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c='testing';
         Test.startTest();
        update aba1;
         Test.stopTest();
         
        abaList.add(aba1);
         
         Map<Id,PRM_AccountBenefitAssociation__c> oldmap1 =new Map<Id,PRM_AccountBenefitAssociation__c>();
         oldmap1.put(aba1.id, new PRM_AccountBenefitAssociation__c(Id=aba1.Id, PRM_Status_Nm__c = 'Active'));
      
         PMP_AccountBenefitPartnerUtility.checkBeforeDeactivateIntelAccountBenefit(abaList, oldmap1);
       
        aba1.PRM_Status_Reason_Txt__c='testing';
        aba1.PRM_Status_Nm__c = 'Active';
        update aba1;
        abaList.add(aba1);
         
      system.assertEquals('Active', aba1.PRM_Status_Nm__c);

         
     } */
     @isTest static void updateUtilityTest1(){
        
      
      PMP_Static_Constants__c basicAccess = new PMP_Static_Constants__c();
      basicAccess.Name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
      basicAccess.PMP_Value__c = 'BNFTSMBA';
      insert basicAccess;

      PMP_Static_Constants__c basicProfile = new PMP_Static_Constants__c();
      basicProfile.Name = 'PMP_BENEFIT_BASIC_PROFILE';
      basicProfile.PMP_Value__c = 'BFTMKTPLBC';
      insert basicProfile;

      PMP_Static_Constants__c Enhanced = new PMP_Static_Constants__c();
      Enhanced.Name = 'PMP_BENEFIT_ENHANCED_CODE';
      Enhanced.PMP_Value__c = 'BFTMKTPLED';
      insert Enhanced;
      
      prm_skip_trigger__c rec = new prm_skip_trigger__c();
      rec.Name = 'ABA_Trigger';
      rec.inactive__c = false;
      insert rec;

       
         
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        //Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Account_Id__c=newAccount.Id;
        insert company;
        
         //custom Setting
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
        insert cust;

        Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
        tiggerCust.Name ='Sync_Published_Copy';
        tiggerCust.Core_Active__c = false;
        tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
        tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
        tiggerCust.Core_Object__c ='PMP_Company__c';
        tiggerCust.Core_Trigger_Events__c ='After update';
        insert tiggerCust;    
         
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
       // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry = 'India';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
            
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
          acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;

      PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cp.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Solutions Marketplace Basic Profile';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb1;
         
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Solutions Marketplace Enhanced';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb2.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb2;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
         
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
         
        PRM_VXBnftMatrix__c bem3=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem3.PRM_Approval_Type_Nm__c='Automatic';
        bem3.PRM_Channel_Program_Id__c=cp.Id;
        bem3.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem3.PRM_Covered_Account_Ind__c=True;
        bem3.PRM_IsActive_Ind__c=True;
        bem3.PRM_Partner_Benefit_Id__c=pb.Id;
        bem3.PRM_Partner_Type_Id__c=pt.Id;
        bem3.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem3;
         
      // Map<Id,PRM_AccountBenefitAssociation__c> Oldmap =new Map<Id,PRM_AccountBenefitAssociation__c>();
      // List<PRM_AccountBenefitAssociation__c> abaList=new List<PRM_AccountBenefitAssociation__c>();
        
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb.id;
        aba1.PRM_Status_Nm__c = 'Active';
          aba1.PRM_Status_Reason_Txt__c='Testing';
        insert aba1;
       
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c='testing';
        Test.startTest();
        update aba1;
        Test.stopTest();
         
     }
    
  /*      @isTest static void updateUtilityTest2(){
            
             prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
            
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Account_Id__c=newAccount.Id;
        insert company;
        
         //custom Setting
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
        insert cust;

        Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
        tiggerCust.Name ='Sync_Published_Copy';
        tiggerCust.Core_Active__c = false;
        tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
        tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
        tiggerCust.Core_Object__c ='PMP_Company__c';
        tiggerCust.Core_Trigger_Events__c ='After update';
        insert tiggerCust;    
         
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
       // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
            
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
            
         system.assertEquals('Service Provider', acm.PRM_Partner_Role__c);  
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Solutions Marketplace Basic Profile';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb1;
         
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Solutions Marketplace Enhanced';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb2.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb2;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
         
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
         
       Map<Id,PRM_AccountBenefitAssociation__c> Oldmap =new Map<Id,PRM_AccountBenefitAssociation__c>();
         List<PRM_AccountBenefitAssociation__c> abaList=new List<PRM_AccountBenefitAssociation__c>();
        
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb2.id;
        aba1.PRM_Status_Nm__c = 'Active';
        insert aba1;
        
        Oldmap.put(aba1.id, aba1);
         
        abaList.add(aba1);
         
         Map<Id,PRM_AccountBenefitAssociation__c> oldmap1 =new Map<Id,PRM_AccountBenefitAssociation__c>();
         oldmap1.put(aba1.id, new PRM_AccountBenefitAssociation__c(Id=aba1.Id, PRM_Status_Nm__c = 'Active'));
         //PMP_AccountBenefitPartnerUtility.checkBeforeDeactivateIntelAccountBenefit(abaList, oldmap1);
         
        aba1.PRM_Status_Reason_Txt__c='testing';
       // aba1.PRM_Status_Nm__c = 'Active';
        aba1.PRM_Partner_Benefit_Id__c = pb1.id;
        //update aba1;
        abaList.add(aba1);

         
        Test.startTest();
        PMP_AccountBenefitPartnerUtility.updateUtility(abaList,Oldmap);
        Test.stopTest();
         
     }

     */
    @isTest static void markRelationshipInactiveTest(){
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
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        /*PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;
*/
        
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
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;         //IPA: Benefit changes
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
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
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        PMP_AccountBenefitPartnerUtility.markRelationshipInactive(id);
        //PMP_AccountBenefitPartnerUtility.markPartnerAsDeleted(id);
       // PMP_AccountBenefitPartnerUtility.checkIfExistingBasicAccessPartner(id);
        
    }
    
    @isTest static void markPartnerAsDeletedTest(){
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
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        /*PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;
*/
        
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
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
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
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        
        PMP_AccountBenefitPartnerUtility.markPartnerAsDeleted(id);
       // PMP_AccountBenefitPartnerUtility.checkIfExistingBasicAccessPartner(id);
        
    }
    
    /*@isTest static void checkIfExistingBasicAccessPartnerTest(){
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
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        //PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        //p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        //p.PMP_Value__c = 'BNFTSMBA';
        //insert p;
		
        
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
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
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
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        
        
       PMP_AccountBenefitPartnerUtility.checkIfExistingBasicAccessPartner(id);
        
    }*/
    
    @isTest static void validateMultipleOPIDRelationsTest(){
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
        cplTitanium.Name='Titanium';
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
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
      
       PMP_AccountBenefitPartnerUtility.validateMultipleOPIDRelations(junctions);
        
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        update company;
        PMP_AccountBenefitPartnerUtility.validateMultipleOPIDRelations(junctions);
        
        company.PMP_Is_Working_Copy_Ind__c = true;
        update company;
        
        PMP_AccountBenefitPartnerUtility.validateMultipleOPIDRelations(junctions);
    }
    
    @isTest static void createBasicAccessPartnerTest(){
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
        cplTitanium.Name='Titanium';
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
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        
        
      // PMP_AccountBenefitPartnerUtility.createBasicAccessPartner(id);
        
    }
    
     @isTest static void createBasicProfilePartnerTest(){
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
        cplTitanium.Name='Titanium';
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
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        //Set<Id> id = new Set<Id>();
                 Map<Id,Boolean> idMap = new Map<Id,Boolean> ();
         idMap.put(ids,true);

        //id.add(ids);
                
       PMP_AccountBenefitPartnerUtility.createBasicProfilePartner(idMap);
        
    }
    
    @isTest static void deleteUtilityTest(){
        
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
        cplTitanium.Name='Titanium';
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
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;//IPA: Benefit changes
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
  /*        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cpIPA.id;
      pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;*/
       
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University1';
      pb.PRM_Channel_Program_Id__c = cpIPA.id;
      pb.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
      
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cpIPA.Id;
      insert pt;
        
      PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem1.PRM_Approval_Type_Nm__c='Automatic';
      bem1.PRM_Channel_Program_Id__c=cpIPA.Id;
      bem1.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
      bem1.PRM_Covered_Account_Ind__c=True;
      bem1.PRM_IsActive_Ind__c=True;
      bem1.PRM_Partner_Benefit_Id__c=pb.Id;
      bem1.PRM_Partner_Type_Id__c=pt.Id;
      bem1.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem1;
        
      PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newPagAccount.id;
      aba.PRM_Partner_Benefit_Id__c = pb.id;
      aba.PRM_Status_Nm__c = 'Active';
	  aba.PRM_Status_Reason_Txt__c='Testing';
      insert aba;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;

        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        //Map<Id,List<PRM_AccountBenefitAssociation__c>> MapAccountToBenefitObjects = PMP_AccountBenefitPartnerUtility.getMapAccountToBenefitObjects(id);
        
        List<PRM_AccountBenefitAssociation__c> listToBeDeleted = [SELECT Id FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c =: newPagAccount.Id];
        PMP_AccountBenefitPartnerUtility.deleteUtility(listToBeDeleted);
    }
   
    
    @isTest static void updateTierOnMPITest(){
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
        cplTitanium.Name='Titanium';
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
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        
        
       PMP_AccountBenefitPartnerUtility.updateTierOnMPI(id);
        
    }
    
     @isTest static void onAccountMpiRelationStatusChangeTest(){
      //System.debug('limit queries:'+Limits.getQueries());
      Test.startTest();
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
      Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

      PMP_Static_Constants__c basicAccess = new PMP_Static_Constants__c();
      basicAccess.Name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
      basicAccess.PMP_Value__c = 'BNFTSMBA';
      insert basicAccess;

      PMP_Static_Constants__c basicProfile = new PMP_Static_Constants__c();
      basicProfile.Name = 'PMP_BENEFIT_BASIC_PROFILE';
      basicProfile.PMP_Value__c = 'BFTMKTPLBC';
      insert basicProfile;

      PMP_Static_Constants__c Enhanced = new PMP_Static_Constants__c();
      Enhanced.Name = 'PMP_BENEFIT_ENHANCED_CODE';
      Enhanced.PMP_Value__c = 'BFTMKTPLED';
      insert Enhanced;

      
      
      prm_skip_trigger__c rec = new prm_skip_trigger__c();
      rec.Name = 'ABA_Trigger';
      rec.inactive__c = false;
      insert rec;

      Account newAccount = new Account();//Account
      newAccount.RecordTypeId = recordTypeIdAccount;
      newAccount.Name='Greg Thomas';
      newAccount.BillingCity='City';
      newAccount.BillingStreet='Street';
      newAccount.BillingCountry='India';
      newAccount.BillingPostalCode='Postal code';
      newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount;
      
      Account newPagAccount = new Account();//Account
      newPagAccount.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount.Name='Greg Thomas';
      newPagAccount.BillingCity='City';
      newPagAccount.BillingStreet='Street';
      newPagAccount.BillingCountry='India';
      newPagAccount.BillingPostalCode='Postal code';
      newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount;

      Account newAccount2 = new Account();//Account
      newAccount2.RecordTypeId = recordTypeIdAccount;
      newAccount2.Name='Greg Thomas2';
      newAccount2.BillingCity='City';
      newAccount2.BillingStreet='Street';
      newAccount2.BillingCountry='India';
      newAccount2.BillingPostalCode='Postal code';
      newAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount2;

      Account newPagAccount2 = new Account();//Account
      newPagAccount2.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount2.Name='Greg Thomas2';
      newPagAccount2.BillingCity='City';
      newPagAccount2.BillingStreet='Street';
      newPagAccount2.BillingCountry='India';
      newPagAccount2.BillingPostalCode='Postal code';
      newPagAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount2;

     /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
      coreAccnt.Core_Partner_Account_Id__c = newPagAccount2.id;
      coreAccnt.Core_Intel_Account_Id__c = newAccount2.id;
      insert coreAccnt;*/

  
      
      /*Core_Account_Group_Member__c coreAccnt2 = new Core_Account_Group_Member__c();
      coreAccnt2.Core_Partner_Account_Id__c = newPagAccount.id;
      coreAccnt2.Core_Intel_Account_Id__c = newAccount.id;
      insert coreAccnt2;*/
      
      
      //custom Setting
      PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
      cust.Name='BatchFieldValues';
      cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
      cust.PRM_PartnerRole__c= 'Service Provider';
      cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
      insert cust;
      
      Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
      tiggerCust.Name ='Sync_Published_Copy';
      tiggerCust.Core_Active__c = false;
      tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust.Core_Object__c ='PMP_Company__c';
      tiggerCust.Core_Trigger_Events__c ='After update';
      insert tiggerCust;


      Core_Trigger_Executions__c tiggerCust1 = new Core_Trigger_Executions__c();
      tiggerCust1.Name ='OPID_MPI_Junction_Status_Handler';
      tiggerCust1.Core_Active__c = true;
      tiggerCust1.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust1.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust1.Core_Object__c ='PMP_Company__c';
      tiggerCust1.Core_Trigger_Events__c ='After update';
      insert tiggerCust1;

      Core_Trigger_Executions__c tiggerCust2 = new Core_Trigger_Executions__c();
      tiggerCust2.Name ='MPI_Benefit_Backfill_Handler';
      tiggerCust2.Core_Active__c = true;
      tiggerCust2.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust2.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust2.Core_Object__c ='PMP_Company__c';
      tiggerCust2.Core_Trigger_Events__c ='After update';
      insert tiggerCust2;
      

    
      
      ChannelProgram cp = new ChannelProgram(); //Channel Program
      cp.Name='Intel Partner Alliance';
      cp.PRM_programCode__c='IPA';
      insert cp;
          
      ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
      cpl.Name='Titanium';
      cpl.ProgramId=cp.Id;
      insert cpl;
      
      ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
      cpl1.Name='Member';
      cpl1.ProgramId=cp.Id;
      insert cpl1;
      
      ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
      cpl2.Name='Gold';
      cpl2.ProgramId=cp.Id;
      insert cpl2;        
      
     /* PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
      contRelation.Name='Primary Contact';
      contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
      contRelation.PRM_Channel_Program_Id__c = cp.Id;
      contRelation.PRM_Default_Relationship_Ind__c = true;
      insert contRelation;
      
      PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel.PRM_Account_Id__c=newAccount.Id;
      acctContRel.PRM_Contact_Id__c=cont.Id;
      acctContRel.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel.PRM_InActive_Ind__c=false;
      insert acctContRel;

      PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel2.PRM_Account_Id__c=newAccount2.Id;
      acctContRel2.PRM_Contact_Id__c=cont2.Id;
      acctContRel2.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel2.PRM_InActive_Ind__c=false;
      insert acctContRel2;*/

     
      
      PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm.PRM_Account_Id__c=newAccount.id;
      acm.PRM_Status_Nm__c='Approved';
      acm.PRM_Channel_Program_Id__c=cp.Id;
      acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm.PRM_Partner_Role__c='Service Provider';
	  acm.PRM_Status_Reason_Txt__c='Testing';
      insert acm;
      
      PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm1.PRM_Account_Id__c=newPagAccount.id;
      acm1.PRM_Status_Nm__c='Approved';
      acm1.PRM_Channel_Program_Id__c=cp.Id;
      acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm1.PRM_Partner_Role__c='Distributor';
	   acm1.PRM_Status_Reason_Txt__c='Testing';
      insert acm1;

      PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm2.PRM_Account_Id__c=newPagAccount2.id;
      acm2.PRM_Status_Nm__c='Approved';
      acm2.PRM_Channel_Program_Id__c=cp.Id;
      acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm2.PRM_Partner_Role__c='Distributor';
	   acm2.PRM_Status_Reason_Txt__c='Testing';
      insert acm2;
      
     /* PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cp.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;*/
      
      PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb1.Name = 'Partner University1';
      pb1.PRM_Channel_Program_Id__c = cp.id;
      pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb1.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb1;
      
      /*PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb2.Name = 'Partner University1';
      pb2.PRM_Channel_Program_Id__c = cp.id;
      pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      pb2.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb2;*/
      
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cp.Id;
      insert pt;
      
      /*PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem.PRM_Approval_Type_Nm__c='Automatic';
      bem.PRM_Channel_Program_Id__c=cp.Id;
      bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem.PRM_Covered_Account_Ind__c=True;
      bem.PRM_IsActive_Ind__c=True;
      bem.PRM_Partner_Benefit_Id__c=pb.Id;
      bem.PRM_Partner_Type_Id__c=pt.Id;
      bem.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem;*/
      
      PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem1.PRM_Approval_Type_Nm__c='Automatic';
      bem1.PRM_Channel_Program_Id__c=cp.Id;
      bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem1.PRM_Covered_Account_Ind__c=True;
      bem1.PRM_IsActive_Ind__c=True;
      bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem1.PRM_Partner_Type_Id__c=pt.Id;
      bem1.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem1;
         
      PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem2.PRM_Approval_Type_Nm__c='Automatic';
      bem2.PRM_Channel_Program_Id__c=cp.Id;
      bem2.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem2.PRM_Covered_Account_Ind__c=True;
      bem2.PRM_IsActive_Ind__c=True;
      bem2.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem2.PRM_Partner_Type_Id__c=pt.Id;
      bem2.PRM_Partner_Role_Nm__c='Distributor';
      insert bem2;
      
      PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newPagAccount.Id;
      aba.PRM_Partner_Benefit_Id__c = pb1.id;
      aba.PRM_Status_Nm__c = 'Active';
	  aba.PRM_Status_Reason_Txt__c='Testing';
      insert aba;

     /* PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
      aba1.PRM_Account_Id__c = newAccount.Id;
      aba1.PRM_Partner_Benefit_Id__c = pb.id;
      aba1.PRM_Status_Nm__c = 'Active';
      insert aba1;*/

      PMP_Company__c company = [select id from PMP_Company__c where PMP_Is_Published_Ind__c=true and PMP_Partner_Benefit_Type__c = :PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile limit 1];
       
      PMP_OPID_MPI_Rel__c junc = new PMP_OPID_MPI_Rel__c();
      junc.PMP_One_partner_ID__c = newPagAccount2.id;
      junc.PMP_Marketing_Profile_Id__c = company.id;
      junc.Is_Active__c = true;
      insert junc;
    
      Test.stopTest();
      // System.debug('limit queries:'+Limits.getQueries());
        
      // PMP_AccountBenefitPartnerUtility.onAccountMpiRelationStatusChange(newMap,oldMap,false);
        
    }
    @isTest static void onAccountMpiRelationStatusChangeTest2(){
      
      
      // System.debug('limit queries:'+Limits.getQueries());
      Test.startTest();
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
      //Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

      PMP_Static_Constants__c basicAccess = new PMP_Static_Constants__c();
      basicAccess.Name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
      basicAccess.PMP_Value__c = 'BNFTSMBA';
      insert basicAccess;

      PMP_Static_Constants__c basicProfile = new PMP_Static_Constants__c();
      basicProfile.Name = 'PMP_BENEFIT_BASIC_PROFILE';
      basicProfile.PMP_Value__c = 'BFTMKTPLBC';
      insert basicProfile;

      PMP_Static_Constants__c Enhanced = new PMP_Static_Constants__c();
      Enhanced.Name = 'PMP_BENEFIT_ENHANCED_CODE';
      Enhanced.PMP_Value__c = 'BFTMKTPLED';
      insert Enhanced;

      
      
      prm_skip_trigger__c rec = new prm_skip_trigger__c();
      rec.Name = 'ABA_Trigger';
      rec.inactive__c = false;
      insert rec;
	
      Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
  
      Account newAccount = new Account();//Account
     // newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.RecordTypeId = recordTypeIdPagAccount;
      newAccount.Name='Greg Thomas';
      newAccount.BillingCity='City';
      newAccount.BillingStreet='Street';
      newAccount.BillingCountry='India';
      newAccount.BillingPostalCode='Postal code';
      newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount;
      
     /* Account newPagAccount = new Account();//Account
      newPagAccount.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount.Name='Greg Thomas';
      newPagAccount.BillingCity='City';
      newPagAccount.BillingStreet='Street';
      newPagAccount.BillingCountry='India';
      newPagAccount.BillingPostalCode='Postal code';
      newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount;*/

     /* Account newAccount2 = new Account();//Account
      newAccount2.RecordTypeId = recordTypeIdAccount;
      newAccount2.Name='Greg Thomas2';
      newAccount2.BillingCity='City';
      newAccount2.BillingStreet='Street';
      newAccount2.BillingCountry='India';
      newAccount2.BillingPostalCode='Postal code';
      newAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount2;

      Account newPagAccount2 = new Account();//Account
      newPagAccount2.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount2.Name='Greg Thomas2';
      newPagAccount2.BillingCity='City';
      newPagAccount2.BillingStreet='Street';
      newPagAccount2.BillingCountry='India';
      newPagAccount2.BillingPostalCode='Postal code';
      newPagAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount2;*/

     /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
      coreAccnt.Core_Partner_Account_Id__c = newPagAccount2.id;
      coreAccnt.Core_Intel_Account_Id__c = newAccount2.id;
      insert coreAccnt;*/

  
      
      /*Core_Account_Group_Member__c coreAccnt2 = new Core_Account_Group_Member__c();
      coreAccnt2.Core_Partner_Account_Id__c = newPagAccount.id;
      coreAccnt2.Core_Intel_Account_Id__c = newAccount.id;
      insert coreAccnt2;*/
      
      
      //custom Setting
      PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
      cust.Name='BatchFieldValues';
      cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
      cust.PRM_PartnerRole__c= 'Service Provider';
      cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
      insert cust;
      
      Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
      tiggerCust.Name ='Sync_Published_Copy';
      tiggerCust.Core_Active__c = false;
      tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust.Core_Object__c ='PMP_Company__c';
      tiggerCust.Core_Trigger_Events__c ='After update';
      insert tiggerCust;


      Core_Trigger_Executions__c tiggerCust1 = new Core_Trigger_Executions__c();
      tiggerCust1.Name ='OPID_MPI_Junction_Status_Handler';
      tiggerCust1.Core_Active__c = true;
      tiggerCust1.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust1.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust1.Core_Object__c ='PMP_Company__c';
      tiggerCust1.Core_Trigger_Events__c ='After update';
      insert tiggerCust1;
      

    
      
      ChannelProgram cp = new ChannelProgram(); //Channel Program
      cp.Name='Intel Partner Alliance';
      cp.PRM_programCode__c='IPA';
      insert cp;
          
      ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
      cpl.Name='Titanium';
      cpl.ProgramId=cp.Id;
      insert cpl;
      
      ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
      cpl1.Name='Member';
      cpl1.ProgramId=cp.Id;
      insert cpl1;
      
      ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
      cpl2.Name='Gold';
      cpl2.ProgramId=cp.Id;
      insert cpl2;        
      
     /* PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
      contRelation.Name='Primary Contact';
      contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
      contRelation.PRM_Channel_Program_Id__c = cp.Id;
      contRelation.PRM_Default_Relationship_Ind__c = true;
      insert contRelation;
      
      PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel.PRM_Account_Id__c=newAccount.Id;
      acctContRel.PRM_Contact_Id__c=cont.Id;
      acctContRel.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel.PRM_InActive_Ind__c=false;
      insert acctContRel;

      PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel2.PRM_Account_Id__c=newAccount2.Id;
      acctContRel2.PRM_Contact_Id__c=cont2.Id;
      acctContRel2.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel2.PRM_InActive_Ind__c=false;
      insert acctContRel2;*/

     
      
      PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm.PRM_Account_Id__c=newAccount.id;
      acm.PRM_Status_Nm__c='Approved';
      acm.PRM_Channel_Program_Id__c=cp.Id;
      acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm.PRM_Partner_Role__c='Service Provider';
	   acm.PRM_Status_Reason_Txt__c='Testing';
      insert acm;
      
      /*PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm1.PRM_Account_Id__c=newPagAccount.id;
      acm1.PRM_Status_Nm__c='Approved';
      acm1.PRM_Channel_Program_Id__c=cp.Id;
      acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm1.PRM_Partner_Role__c='Distributor';
      insert acm1;*/

     /*PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm2.PRM_Account_Id__c=newPagAccount.id;
      acm2.PRM_Status_Nm__c='Approved';
      acm2.PRM_Channel_Program_Id__c=cp.Id;
      acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm2.PRM_Partner_Role__c='Service Provider';
      insert acm2;*/
      
      PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cp.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
      
     /* PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb1.Name = 'Partner University1';
      pb1.PRM_Channel_Program_Id__c = cp.id;
      pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb1.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb1;*/
      
      /*PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb2.Name = 'Partner University1';
      pb2.PRM_Channel_Program_Id__c = cp.id;
      pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      pb2.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb2;*/
      
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cp.Id;
      insert pt;
      
      /*PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem.PRM_Approval_Type_Nm__c='Automatic';
      bem.PRM_Channel_Program_Id__c=cp.Id;
      bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem.PRM_Covered_Account_Ind__c=True;
      bem.PRM_IsActive_Ind__c=True;
      bem.PRM_Partner_Benefit_Id__c=pb.Id;
      bem.PRM_Partner_Type_Id__c=pt.Id;
      bem.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem;*/
      
      PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem1.PRM_Approval_Type_Nm__c='Automatic';
      bem1.PRM_Channel_Program_Id__c=cp.Id;
      bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem1.PRM_Covered_Account_Ind__c=True;
      bem1.PRM_IsActive_Ind__c=True;
      bem1.PRM_Partner_Benefit_Id__c=pb.Id;
      bem1.PRM_Partner_Type_Id__c=pt.Id;
      bem1.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem1;
      
      PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newAccount.Id;
      aba.PRM_Partner_Benefit_Id__c = pb.id;
      aba.PRM_Status_Nm__c = 'Active';
	  aba.PRM_Status_Reason_Txt__c='Testing';
      insert aba;
	
         PMP_Company__c company=new PMP_Company__c();
        company.Name=newAccount.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);

 List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
     
     // PMP_OPID_MPI_Rel__c junc = [select id from PMP_OPID_MPI_Rel__c where PMP_One_partner_ID__c=:newAccount.Id ];
     // PMP_Company__c company = [select id from PMP_Company__c where PMP_Is_Published_Ind__c=true and PMP_Partner_Benefit_Type__c = :PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile limit 1];
     
          PMP_Company__c company22 = new PMP_Company__c();
        company22.Name='company22';
        company22.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company22.PMP_Partner_Country_Txt__c = 'India';
        company22.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company22.PMP_Is_Published_Ind__c = true;
        company22.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        insert company22;

        PMP_OPID_MPI_Rel__c NewOpid22 = new PMP_OPID_MPI_Rel__c();
        NewOpid22.PMP_Marketing_Profile_Id__c = company22.id;
        NewOpid22.PMP_One_Partner_ID__c = newAccount.id;
        NewOpid22.Is_Active__c = true;
        insert NewOpid22;

      NewOpid22.Is_Active__c = false;
      update NewOpid22;

      NewOpid22.Is_Active__c = true;
      update NewOpid22;
  
      Test.stopTest();
      // System.debug('limit queries:'+Limits.getQueries());
        
      // PMP_AccountBenefitPartnerUtility.onAccountMpiRelationStatusChange(newMap,oldMap,false);
        
    
    
    }

 

    @isTest static void onMPIBenefitChangeTest(){
         
      // System.debug('limit queries:'+Limits.getQueries());
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
      Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

      PMP_Static_Constants__c basicAccess = new PMP_Static_Constants__c();
      basicAccess.Name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
      basicAccess.PMP_Value__c = 'BNFTSMBA';
      insert basicAccess;

      PMP_Static_Constants__c basicProfile = new PMP_Static_Constants__c();
      basicProfile.Name = 'PMP_BENEFIT_BASIC_PROFILE';
      basicProfile.PMP_Value__c = 'BFTMKTPLBC';
      insert basicProfile;

      PMP_Static_Constants__c Enhanced = new PMP_Static_Constants__c();
      Enhanced.Name = 'PMP_BENEFIT_ENHANCED_CODE';
      Enhanced.PMP_Value__c = 'BFTMKTPLED';
      insert Enhanced;

      
      
      prm_skip_trigger__c rec = new prm_skip_trigger__c();
      rec.Name = 'ABA_Trigger';
      rec.inactive__c = false;
      insert rec;

      Account newAccount = new Account();//Account
      newAccount.RecordTypeId = recordTypeIdAccount;
      newAccount.Name='Greg Thomas';
      newAccount.BillingCity='City';
      newAccount.BillingStreet='Street';
      newAccount.BillingCountry='India';
      newAccount.BillingPostalCode='Postal code';
      newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newAccount;
      
      Account newPagAccount = new Account();//Account
      newPagAccount.RecordTypeId = recordTypeIdPagAccount;
      newPagAccount.Name='Greg Thomas';
      newPagAccount.BillingCity='City';
      newPagAccount.BillingStreet='Street';
      newPagAccount.BillingCountry='India';
      newPagAccount.BillingPostalCode='Postal code';
      newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
      insert newPagAccount;

     /* Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
      coreAccnt.Core_Partner_Account_Id__c = newPagAccount2.id;
      coreAccnt.Core_Intel_Account_Id__c = newAccount2.id;
      insert coreAccnt;*/

  
      
      /*Core_Account_Group_Member__c coreAccnt2 = new Core_Account_Group_Member__c();
      coreAccnt2.Core_Partner_Account_Id__c = newPagAccount.id;
      coreAccnt2.Core_Intel_Account_Id__c = newAccount.id;
      insert coreAccnt2;*/
      
      
      //custom Setting
      PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
      cust.Name='BatchFieldValues';
      cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
      cust.PRM_PartnerRole__c= 'Service Provider';
      cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
      insert cust;
      
      Core_Trigger_Executions__c tiggerCust = new Core_Trigger_Executions__c();
      tiggerCust.Name ='Sync_Published_Copy';
      tiggerCust.Core_Active__c = false;
      tiggerCust.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust.Core_Object__c ='PMP_Company__c';
      tiggerCust.Core_Trigger_Events__c ='After update';
      insert tiggerCust;


      Core_Trigger_Executions__c tiggerCust1 = new Core_Trigger_Executions__c();
      tiggerCust1.Name ='OPID_MPI_Junction_Status_Handler';
      tiggerCust1.Core_Active__c = true;
      tiggerCust1.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust1.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust1.Core_Object__c ='PMP_Company__c';
      tiggerCust1.Core_Trigger_Events__c ='After update';
      insert tiggerCust1;

      Core_Trigger_Executions__c tiggerCust2 = new Core_Trigger_Executions__c();
      tiggerCust2.Name ='MPI_Benefit_Backfill_Handler';
      tiggerCust2.Core_Active__c = true;
      tiggerCust2.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust2.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust2.Core_Object__c ='PMP_Company__c';
      tiggerCust2.Core_Trigger_Events__c ='After update';
      insert tiggerCust2;
      
      Core_Trigger_Executions__c tiggerCust3 = new Core_Trigger_Executions__c();
      tiggerCust3.Name ='MPI_Auto_Benefit_Handler';
      tiggerCust3.Core_Active__c = true;
      tiggerCust3.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust3.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust3.Core_Object__c ='PMP_Company__c';
      tiggerCust3.Core_Trigger_Events__c ='After update';
      insert tiggerCust3;

      Core_Trigger_Executions__c tiggerCust4 = new Core_Trigger_Executions__c();
      tiggerCust4.Name ='OPID_MPI_Validation_Handler';
      tiggerCust4.Core_Active__c = true;
      tiggerCust4.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust4.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust4.Core_Object__c ='PMP_Company__c';
      tiggerCust4.Core_Trigger_Events__c ='After update';
      insert tiggerCust4;

    
      
      ChannelProgram cp = new ChannelProgram(); //Channel Program
      cp.Name='Intel Partner Alliance';
      cp.PRM_programCode__c='IPA';
      insert cp;
          
      ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
      cpl.Name='Titanium';
      cpl.ProgramId=cp.Id;
      insert cpl;
      
      ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
      cpl1.Name='Member';
      cpl1.ProgramId=cp.Id;
      insert cpl1;
      
      ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
      cpl2.Name='Gold';
      cpl2.ProgramId=cp.Id;
      insert cpl2;        
      
     /* PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
      contRelation.Name='Primary Contact';
      contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
      contRelation.PRM_Channel_Program_Id__c = cp.Id;
      contRelation.PRM_Default_Relationship_Ind__c = true;
      insert contRelation;
      
      PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel.PRM_Account_Id__c=newAccount.Id;
      acctContRel.PRM_Contact_Id__c=cont.Id;
      acctContRel.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel.PRM_InActive_Ind__c=false;
      insert acctContRel;

      PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
      acctContRel2.PRM_Account_Id__c=newAccount2.Id;
      acctContRel2.PRM_Contact_Id__c=cont2.Id;
      acctContRel2.PRM_Relationship_Id__c=contRelation.Id;
      acctContRel2.PRM_InActive_Ind__c=false;
      insert acctContRel2;*/

     
      
      PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm.PRM_Account_Id__c=newAccount.id;
      acm.PRM_Status_Nm__c='Approved';
      acm.PRM_Channel_Program_Id__c=cp.Id;
      acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm.PRM_Partner_Role__c='Service Provider';
	   acm.PRM_Status_Reason_Txt__c='Testing';
      insert acm;
      
      PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
      acm1.PRM_Account_Id__c=newPagAccount.id;
      acm1.PRM_Status_Nm__c='Approved';
      acm1.PRM_Channel_Program_Id__c=cp.Id;
      acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      acm1.PRM_Partner_Role__c='Distributor';
	   acm1.PRM_Status_Reason_Txt__c='Testing';
      insert acm1;

     
      
     /* PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Partner University';
      pb.PRM_Channel_Program_Id__c = cp.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;*/
      
      PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb1.Name = 'Solutions Marketplace Basic Profile';
      pb1.PRM_Channel_Program_Id__c = cp.id;
      pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb1.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb1;
      
     /* PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb2.Name = 'Solutions Marketplace Enhanced';
      pb2.PRM_Channel_Program_Id__c = cp.id;
      pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      pb2.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb2;
     */ 
      PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
      pt.Name='Cloud Service Provider (CSP)';
      pt.PRM_Role_Name__c='Service Provider';
      pt.PRM_PartneryTypeCode__c='CSP';
      pt.PRM_PartnerRoleCode__c='SPR';
      pt.PRM_channelprogram__c=cp.Id;
      insert pt;
      
      /*PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem.PRM_Approval_Type_Nm__c='Automatic';
      bem.PRM_Channel_Program_Id__c=cp.Id;
      bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem.PRM_Covered_Account_Ind__c=True;
      bem.PRM_IsActive_Ind__c=True;
      bem.PRM_Partner_Benefit_Id__c=pb.Id;
      bem.PRM_Partner_Type_Id__c=pt.Id;
      bem.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem;*/

     /* PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem2.PRM_Approval_Type_Nm__c='Automatic';
      bem2.PRM_Channel_Program_Id__c=cp.Id;
      bem2.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem2.PRM_Covered_Account_Ind__c=True;
      bem2.PRM_IsActive_Ind__c=True;
      bem2.PRM_Partner_Benefit_Id__c=pb2.Id;
      bem2.PRM_Partner_Type_Id__c=pt.Id;
      bem2.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem2;
     */ 
      PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem1.PRM_Approval_Type_Nm__c='Automatic';
      bem1.PRM_Channel_Program_Id__c=cp.Id;
      bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem1.PRM_Covered_Account_Ind__c=True;
      bem1.PRM_IsActive_Ind__c=True;
      bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem1.PRM_Partner_Type_Id__c=pt.Id;
      bem1.PRM_Partner_Role_Nm__c='Service Provider';
      insert bem1;
        
       PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
      bem2.PRM_Approval_Type_Nm__c='Automatic';
      bem2.PRM_Channel_Program_Id__c=cp.Id;
      bem2.PRM_Channel_Program_Level_Id__c=cpl.Id;
      bem2.PRM_Covered_Account_Ind__c=True;
      bem2.PRM_IsActive_Ind__c=True;
      bem2.PRM_Partner_Benefit_Id__c=pb1.Id;
      bem2.PRM_Partner_Type_Id__c=pt.Id;
      bem2.PRM_Partner_Role_Nm__c='Distributor';
      insert bem2;
      
      PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
      aba.PRM_Account_Id__c = newPagAccount.Id;
      aba.PRM_Partner_Benefit_Id__c = pb1.id;
      aba.PRM_Status_Nm__c = 'Active';
	  aba.PRM_Status_Reason_Txt__c='Testing';
      insert aba;

     /* PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
      aba1.PRM_Account_Id__c = newAccount.Id;
      aba1.PRM_Partner_Benefit_Id__c = pb.id;
      aba1.PRM_Status_Nm__c = 'Active';
      insert aba1;*/
    
        Test.startTest();
      PMP_OPID_MPI_Rel__c junc = [select id,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_partner_ID__c=:newPagAccount.Id ];

      junc.Is_Active__c = false;
      update junc;
     // pb1.Name = 'Solutions Marketplace Enhanced';
      //pb1.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      //update pb1;
      aba.PRM_Status_Nm__c = 'Inactive';
      update aba;
    junc.Is_Active__c = true;
      update junc;
        
        pb1.Name = 'Solutions Marketplace Enhanced';
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        update pb1;

      Test.stopTest();
      // System.debug('limit queries:'+Limits.getQueries());
        
         PMP_Company__c company = [select id from PMP_Company__c where PMP_Is_Published_Ind__c=false and PMP_Partner_Benefit_Type__c = :PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile limit 1];
       
      //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
      company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
      update company;

      // PMP_AccountBenefitPartnerUtility.onAccountMpiRelationStatusChange(newMap,oldMap,false);
        
    }



    

    
    @isTest static void InsertCompanyAttributeMappingRecordsTest(){
        
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
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        Core_Trigger_Executions__c tiggerCust3 = new Core_Trigger_Executions__c();
      tiggerCust3.Name ='MPI_Auto_Benefit_Handler';
      tiggerCust3.Core_Active__c = true;
      tiggerCust3.Core_Class_Name__c ='PMP_AccountBenefitPartnerUtility';
      tiggerCust3.Core_Description__c ='This record is used to execute or control the sync published copy from PMP_AccountBenefitPartnerUtility controller';
      tiggerCust3.Core_Object__c ='PMP_Company__c';
      tiggerCust3.Core_Trigger_Events__c ='After update';
      insert tiggerCust3;
        
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
        
        List<PMP_Company__c> newPartners = new List<PMP_Company__c>();
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        newPartners.add(company);
        insert newPartners;
       // System.assertNotEquals(company, Null);
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb.Name = 'Solution Marketplace Basic Access';
      pb.PRM_Channel_Program_Id__c = cpIPA.id;
      pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
      pb.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb;
      
      PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb1.Name = 'Solutions Marketplace Basic Profile';
      pb1.PRM_Channel_Program_Id__c = cpIPA.id;
      pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
      pb1.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb1;
      
      PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
      pb2.Name = 'Solutions Marketplace Enhanced';
      pb2.PRM_Channel_Program_Id__c = cpIPA.id;
      pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
      pb2.PRM_Account_Type_Nm__c = 'Both'; 
      insert pb2;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Status_Reason_Txt__c='Testing';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        
       List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
       PMP_AccountBenefitPartnerUtility.InsertCompanyAttributeMappingRecords(newPartners);
      // PMP_AccountBenefitPartnerUtility.createPartnerWorkingCopyRecord(newPartners);
      
        //For formatAndPopulateMultiPicklistForProgramMembership
        
        String mainProgramMembership = '1 - Member;2 - Gold';
        String addedProgram = '1 - Titanium';
        PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklistForProgramMembership(mainProgramMembership,addedProgram);
        
        Set<Id> activeAccounts = new Set<Id>{newPagAccount.Id};
            Map<Id,String> mapAccountToPartnerDetails = new Map<Id,String>{newPagAccount.Id=>'a;b;c'};
                Set<String> allowedValues = new Set<String>{'a','b','c'};
        PMP_AccountBenefitPartnerUtility.rollUpMultiPicklist(activeAccounts,mapAccountToPartnerDetails,allowedValues);
        
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        update company;
        
    }

}