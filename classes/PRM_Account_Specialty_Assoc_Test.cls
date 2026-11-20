@isTest()
public class PRM_Account_Specialty_Assoc_Test {
    
    static testmethod void testduplicateRecordCheck(){
        Test.startTest();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.Name='Johngoth Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Reddick Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.RecordTypeId=intelAccRecTypeId;
        insert newAccount;
        System.debug('first account'+newAccount);
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.name='Select Benefits';
        spec.recordtypeId = specid;
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.recordtypeId = specid;
        spec1.name='Addition Select Benefit';
        spec1.PRM_Description_Txt__c='This is description1';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount.id;
        asa1.PRM_Specialty_Id__c= spec.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        
        try{ 
            insert asa1;
        }
        catch(exception e){
            System.debug('Exception occured' +e.getMessage());   
        }
        
        Test.stopTest();    
        System.assertEquals('Service Provider',asa1.PRM_Partner_Role__c,'Value does not match');
    }
    static testmethod void updatetestduplicateRecordCheck(){
        Test.startTest();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.RecordTypeId=intelAccRecTypeId;
        insert newAccount;
        System.debug('first account'+newAccount);
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.recordtypeId = specid;
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.recordtypeId = specid;
        spec1.name='Addition Select Benefit';
        spec1.PRM_Description_Txt__c='This is description1';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        insert asa1;
        try{ 
            asa1.PRM_Specialty_Id__c = spec.id;
            update asa1;
        }
        catch(exception e){
            System.debug('Exception occured' +e.getMessage());     
        }
        Test.stopTest();  
        System.assertEquals(spec.id,asa1.PRM_Specialty_Id__c,'Value does not match');
    }
    
    static testmethod void updatePartnerSpecialityOnAccountTest(){
        List<PRM_Account_Specialty_Association__c> speciality = new List<PRM_Account_Specialty_Association__c>();
       
        Id intelid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id opid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Core_IPA_Partner_Role__c = 'Service Provider';
        newAccount.recordtypeId = intelid;
        insert newAccount;
        
       /* Account newAccount1 = new Account();//Account
        newAccount1.Name='John Rick';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.recordtypeId = opid;
        insert newAccount1;
        
        Core_Account_Group_Member__c cagm = new Core_Account_Group_Member__c();
        cagm.Core_Intel_Account_Id__c = newAccount.id;
        cagm.Core_Partner_Account_Id__c = newAccount1.id;
        cagm.Core_Inactive_Ind__c =false;
        insert cagm;*/
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.recordtypeId = specid;
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.recordtypeId = specid;
        spec1.name='Addition Select Benefit';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_InActive_Ind__c= false;
        speciality.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_InActive_Ind__c= false;
        speciality.add(asa1);
        
        PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c= newAccount.id;
        asa2.PRM_Specialty_Id__c= spec1.id;
        asa2.PRM_Partner_Role__c = spec1.PRM_Role_Nm__c;
        asa2.PRM_InActive_Ind__c= true;
        speciality.add(asa2);
        
        if(speciality.size() >0){
            insert speciality;
        }
        
        set<string> setOfId = new set<string>();
        setOfId.add(asa.Id);
        setOfId.add(asa1.Id);
        
        List<PRM_Account_Specialty_Association__c> lstOfASA = new List<PRM_Account_Specialty_Association__c>();
        
        for(PRM_Account_Specialty_Association__c testObj: [select id,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where id In: setOfId]){
            testObj.PRM_InActive_Ind__c =true;
            lstOfASA.add(testObj);   
        }
        
        if(lstOfASA.size() > 0){
            update lstOfASA;
        }
        
        System.assertNotEquals(Null,lstOfASA,'List of ASA should not be null'); 
        
    }
    static testmethod void testInactivateCriteria(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    Id recordTypeIdOpidAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> acclist = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.Name='Johngoth Rick';
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Reddick Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acclist.add(newAccount);
       // insert newAccount;
        
        Account newAccount1 = new Account();//Account
        newAccount1.Name='Johngoth Rick alpha';
        newAccount1.RecordTypeId = recordTypeIdOpidAccount;
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Reddick Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acclist.add(newAccount1);
        insert acclist;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp; 
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        Test.startTest();
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>(); 
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Reason_Txt__c='test';
        acmList.add(acm);
       // insert acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c=newAccount1.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Builder';
        acm1.PRM_Status_Reason_Txt__c='test';
        acmList.add(acm1);
        insert acmList;
        
        
        
        Core_Account_Group_Member__c cagm = new Core_Account_Group_Member__c();
        cagm.Core_Intel_Account_Id__c = newAccount.id;
        cagm.Core_Partner_Account_Id__c = newAccount1.id;
        insert cagm;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.recordtypeId = specid;
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider;FPGA Designer';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        insert bg;
        
        PRM_Benefit_Group__c bg1= new PRM_Benefit_Group__c();
        bg1.name = 'Benefitgroup tryTest';
        insert bg1;
        
        system.debug('bg========>'+bg);
        
        PRM_Specialty_Benefit_Group_Association__c sbga = new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c=bg.id;
        sbga.PRM_Specialty_Id__c=spec.id;
        sbga.PRM_Start_Date_Dt__c= system.today() + 5;
        sbga.PRM_End_Date_Dt__c= sbga.PRM_Start_Date_Dt__c + 7;
        insert sbga;
        
        PRM_Specialty_Benefit_Group_Association__c sbga1 = new PRM_Specialty_Benefit_Group_Association__c();
        sbga1.PRM_Benefit_Group_Id__c=bg1.id;
        sbga1.PRM_Specialty_Id__c=spec.id;
        sbga1.PRM_Start_Date_Dt__c= system.today() + 5;
        sbga1.PRM_End_Date_Dt__c= sbga.PRM_Start_Date_Dt__c + 7;
        insert sbga1;
        
        Id devRecordTypeId = Schema.SObjectType.PRM_Specialty_Criteria__c.getRecordTypeInfosByName().get('Qualitative').getRecordTypeId();
        PRM_Specialty_Criteria__c psaTest = new PRM_Specialty_Criteria__c();
        psaTest.Name='Test';
        psaTest.RecordTypeId=devRecordTypeId;
        psaTest.PRM_Start_Date_Dt__c = date.today();
        psaTest.PRM_Type_Nm__c = 'Qualitative';
        insert psaTest;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Solution Marketplace Basic Access';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
        insert pb;
        system.debug('pb========>'+pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Accruals – View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        insert pb1;
        
        PRM_Benefit_Group_Benefit_Association__c bgba = new PRM_Benefit_Group_Benefit_Association__c();
        bgba.PRM_Benefit_Id__c = pb.id;
        bgba.PRM_Benefit_Group_Id__c= bg.id;
        bgba.PRM_Status_Nm__c = 'Live';
        bgba.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba;
        
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb1.id;
        bgba1.PRM_Benefit_Group_Id__c= bg.id;
        bgba1.PRM_Status_Nm__c = 'Live';
        bgba1.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba1.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_InActive_Ind__c = FALSE;
        insert asa;
        
        
        PRM_Account_Specialty_Qual_Criteria__c asqc = new PRM_Account_Specialty_Qual_Criteria__c();
        asqc.PRM_Account_Specialty_Association_Id__c = asa.id;
        asqc.PRM_Specialty_Criteria_Id__c=psaTest.id;
        asqc.PRM_InActive_Ind__c=FALSE;
        insert asqc; 
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        //insert aba;
        
        
        
        
        try{ 
            asa.PRM_InActive_Ind__c = TRUE;   
            update asa;
        }
        catch(exception e){
            System.debug('Exception occured' +e.getMessage());    
        }
        
        Test.stopTest(); 
        System.assertEquals(true,asa.PRM_InActive_Ind__c,'Value does not match');
    }
    
    static testmethod void memberBenefitAssign(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Joshy Rick1';
        newAccount1.BillingCity='Cityu';
        newAccount1.BillingStreet='Streete';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.add(newAccount1);
        
        if(acc != null){
            insert acc;
        }
        //Entitlment flow Start
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry='USA';
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Grilladm';
        cont1.FirstName='Adamgril';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.MailingCountry='USA';
        insert cont1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
         
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c='test';
        insert acm1;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Solution Marketplace Basic Access';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
       // pb.PRM_Account_Type_Nm__c='Both'; 
        insert pb;
        system.debug('pb========>'+pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Accruals – View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
       // pb1.PRM_Account_Type_Nm__c='Both'; 
        insert pb1;
        
        List<PRM_AccountChannelMembership__c> acmrecords = new List<PRM_AccountChannelMembership__c>();
        Datetime lastModifyDate;
        String lastModifiedBy;
        acmrecords= [select LastModifiedById,Name,PRM_Status_Change_Dt__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c='Approved' limit 1];
        System.debug('acmrecords --->'+acmrecords);
        lastModifyDate = acmrecords[0].PRM_Status_Change_Dt__c;
        lastModifiedBy = acmrecords[0].LastModifiedById;
        System.debug('LM Date is ' +lastModifyDate);
        System.debug('LM Id is ' +lastModifiedBy);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium;Member';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider'; 
        insert bm;
        
         PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Status_Reason_Txt__c='test';
        insert acctContRel1;
        
        acctContRel1.PRM_Status_Nm__c='Complete';
        //update acctContRel1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Sales PRM- Partner Points Redemption User';
        ed.Core_Display_Name__c='Sales PRM- Partner Points Redemption User';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Sales PRM - Partner University User';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_Display_Name__c='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed2;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb1.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em1;
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Partner_Benefit_Id__c = pb1.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em2;
        
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont1.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        beList.add(be);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =cont1.Id;
        be1.PRM_Entitlement_Id__c =ed1.Id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = True;
        beList.add(be1);
        
        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be2.PRM_Contact_Id__c =cont1.Id;
        be2.PRM_Entitlement_Id__c =ed2.Id;
        be2.PRM_Status_Nm__c = 'New';
        beList.add(be2);
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont1.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        ceList.add(cce);
        
         Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee1.Name = 'Intel Partner Alliance';
        ee1.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee1.Core_Engagement_Type__c = 'SEC';
        insert ee1;
        
        Core_Entitlement__c ed3 = new Core_Entitlement__c(); //Entitlement
        ed3.Name='CIP VIP View';
        ed3.Core_Display_Name__c='CIP VIP View';
        ed3.Core_ERPM_Engagement_Id__c=ee1.id;
        insert ed3;
        
        PRM_VXEnttlmntMatrix__c em3 = new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix withou benefit
        em3.RecordTypeId = recordTypeIdEM;
        em3.PRM_Entitlement_Id__c = ed3.id;
        em3.PRM_Contact_Relationship_Id__c = contRelation.id;
        em3.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em3.PRM_Approval_Type_Nm__c='Automatic';
        em3.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em3;
        
        //List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be3 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be3.PRM_Contact_Id__c =cont.Id;
        be3.PRM_Entitlement_Id__c =ed.Id;
        be3.PRM_Status_Nm__c = 'New';
        beList.add(be3);
        
       // List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=cont.Id;
        cce1.Core_Entitlement_Id__c = ed.Id;
        cce1.Core_Status__c='Pending';
        cce1.Core_Selected__c = true;
        cce1.Core_Data_Loaded__c = true;
        cce1.Core_DontNotify__c = true;
        cce1.Core_From_Source__c = false;
        ceList.add(cce1);
        
             
         if(beList != null && !beList.IsEmpty()){
                insert beList;
                insert ceList;
            }
        
        //entitlment flow end
        
        // Speciality to benefit flow Start
        
        PRM_Specialty__c spec = new PRM_Specialty__c(); //speciality
        spec.recordtypeId = specid;
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider;FPGA Designer';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c(); //speciality
        spec1.recordtypeId = specid;
        spec1.name='Addition Select Benefit';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        insert bg;
        system.debug('bg========>'+bg);
        
        PRM_Specialty_Benefit_Group_Association__c sbga = new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c=bg.id;
        sbga.PRM_Specialty_Id__c=spec.id;
        sbga.PRM_Start_Date_Dt__c= system.today() + 5;
        sbga.PRM_End_Date_Dt__c= sbga.PRM_Start_Date_Dt__c + 7;
        insert sbga;
        
        Test.startTest();
      
        PRM_Benefit_Group_Benefit_Association__c bgba = new PRM_Benefit_Group_Benefit_Association__c();
        bgba.PRM_Benefit_Id__c = pb.id;
        bgba.PRM_Benefit_Group_Id__c= bg.id;
        bgba.PRM_Status_Nm__c = 'Live';
        bgba.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba;
        
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb1.id;
        bgba1.PRM_Benefit_Group_Id__c= bg.id;
        bgba1.PRM_Status_Nm__c = 'Live';
        bgba1.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba1.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba1;

        
        // Speciality to benefit flow End
        
        //Insertion of ASA
        List<PRM_Account_Specialty_Association__c> lstOfAsa = new List<PRM_Account_Specialty_Association__c>();
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa);
        
         PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa1);
        
       /*  PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c= newAccount1.id;
        asa2.PRM_Specialty_Id__c= spec.id;
        asa2.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa2);*/
        
        if(lstOfAsa != null && !lstOfAsa.isEmpty()){
            insert lstOfAsa;
            PRM_Account_Specialty_Assoc_Utility.DupeSpecialityCheck(newAccount.id,spec1.id,lstOfAsa);
        }
        System.assertEquals(FALSE,asa1.PRM_InActive_Ind__c,'Value does not match');
        Test.stopTest(); 
        
    } 
    
    @isTest static void opidRollupTest(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdOpidAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        
        List<Account> acclist = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.Name='Johngoth Rick';
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Reddick Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acclist.add(newAccount);
       // insert newAccount;
        
        Account newAccount1 = new Account();//Account
        newAccount1.Name='Johngoth Rick alpha';
        newAccount1.RecordTypeId = recordTypeIdOpidAccount;
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Reddick Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_IPA_Partner_Role__c='Builder';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acclist.add(newAccount1);
        insert acclist;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp; 
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        Test.startTest();
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>(); 
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Reason_Txt__c='test';
        acmList.add(acm);
       // insert acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c=newAccount1.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Builder';
        acm1.PRM_Status_Reason_Txt__c='test';
        acmList.add(acm1);
        insert acmList;
        
        Core_Account_Group_Member__c cagm = new Core_Account_Group_Member__c();
        cagm.Core_Intel_Account_Id__c = newAccount.id;
        cagm.Core_Partner_Account_Id__c = newAccount1.id;
        cagm.Core_Inactive_Ind__c = false;
        insert cagm;
    
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.recordtypeId = specid; 
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Solution Integrator';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
    
    PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_Partner_Role__c = spec.PRM_Role_Nm__c;
        asa.PRM_InActive_Ind__c = FALSE;
        insert asa;
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount1.id;
        asa1.PRM_Specialty_Id__c= spec.id;
        asa1.PRM_Partner_Role__c = spec.PRM_Role_Nm__c;
        asa1.PRM_InActive_Ind__c = false;
        insert asa1;
        
        asa.PRM_InActive_Ind__c =true;
        update asa;
        Test.stopTest();
        System.assertEquals(True,asa.PRM_InActive_Ind__c,'Value does not match');
    }
}