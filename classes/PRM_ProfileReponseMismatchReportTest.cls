@isTest
public class PRM_ProfileReponseMismatchReportTest {
     @isTest
    public static void Test(){ 
        
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdWithBnft = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('PRM_EntitlementWithBenefits').getRecordTypeId();
        Id recordTypeIdWithoutBnft = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('PRM_EntitlementWithoutBenefits').getRecordTypeId();
        Id recordTypeIdCommunityEnt = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('Community_Entitlements').getRecordTypeId();
        
        //opid account
        
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPagAccount;
        opidAcc.Name='OPID';
        //;;
        opidAcc.BillingCity='City1';
        opidAcc.BillingStreet='Street1';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        opidAcc.Core_IPA_Partner_Role__c='Service Provider;Distributor';
        opidAcc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        opidAcc.Website='www.abc.com';
        opidAcc.Core_User_Defined_Website__c='www.abc.com';
        insert opidAcc;
        
        
        //location account
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_IPA_Partner_Role__c='Service Provider;Distributor';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Website='www.abc.com';
        newAccount.Core_User_Defined_Website__c='www.abc.com';
        newAccount.Core_IPA_One_Partner_Id__c=opidAcc.id;
        insert newAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        
        Set<Id> accIds = new Set<Id> 
        { newAccount.Id };
          
        Set<Id> newSet = new Set<id>();
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=opidAcc.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        //cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        cont.Core_Login_Status__c = 'Active';
	cont.MailingCountryCode = 'IND';
        
        
        insert cont;
        newSet.add(cont.id);
        
        Contact cont2 = new Contact();  //Contact  
        cont2.AccountId=newAccount.Id;
        cont2.lastName='adam';
        cont2.FirstName='west';
        cont2.email='AdamGrill@wst.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        //cont2.Core_IPA_Partner_Role__c = 'Service Provider';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        cont2.Core_Login_Status__c = 'Active';
        cont2.MailingCountryCode = 'IND';
        insert cont2;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        list<ChannelProgramLevel> cpLst=new list<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        cpLst.add(cpl);
        
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        cpLst.add(cpl1);
        
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Titanium';
        cpl2.ProgramId=cp.Id;
        cpLst.add(cpl2);
        insert cpLst;
        
        list<PRM_ContactRelationships__c> conRelLst=new list<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c admin = new PRM_ContactRelationships__c();   //Contact Relationship
        admin.Name='Partner Admin';
        admin.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        admin.PRM_Channel_Program_Id__c = cp.Id;
        admin.PRM_Default_Relationship_Ind__c = true;
        conRelLst.add(admin);
        
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Partner Admin';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cp.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        conRelLst.add(employee);
        
        insert conRelLst;
        
        PRM_Account_Contact_Relationship__c acctContRelEmp=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp.PRM_Account_Id__c=opidAcc.Id;
        acctContRelEmp.PRM_Contact_Id__c=cont.Id;
        acctContRelEmp.PRM_Relationship_Id__c=employee.Id;
        acctContRelEmp.PRM_InActive_Ind__c=false;
        acctContRelEmp.PRM_Status_Nm__c = 'Complete';
        
        insert acctContRelEmp;
        
        PRM_Account_Contact_Relationship__c acctContRelEmp1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp1.PRM_Account_Id__c=newAccount.Id;
        acctContRelEmp1.PRM_Contact_Id__c=cont2.Id;
        acctContRelEmp1.PRM_Relationship_Id__c=employee.Id;
        acctContRelEmp1.PRM_InActive_Ind__c=false;
        acctContRelEmp1.PRM_Status_Nm__c = 'Complete';
        
		insert acctContRelEmp1;  
        

        
        //location account acm
        PRM_AccountChannelMembership__c newAccountAcm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        newAccountAcm.PRM_Account_Id__c=newAccount.id;
        newAccountAcm.PRM_Status_Nm__c='Approved';
        newAccountAcm.PRM_Channel_Program_Id__c=cp.Id;
        newAccountAcm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        newAccountAcm.PRM_Partner_Role__c='Service Provider';
        newAccountAcm.PRM_Status_Reason_Txt__c='Test01';
        insert newAccountAcm;
        
        list<sobject> testLst=new list<sobject>();
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Thomas';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount1.Core_IPA_Partner_Role__c='Service Provider;Distributor';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Website='www.abc.com';
        newAccount1.Core_IPA_One_Partner_Id__c=opidAcc.id;
        testLst.add(newAccount1);
        
        Contact cont1 = new Contact();  //Contact  
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Grill';
        cont1.FirstName='Adam';
        cont1.email='AdamGrill123@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        cont1.Core_Login_Status__c = 'Active';
	cont1.MailingCountryCode = 'IND';
        insert cont1;
        
        test.startTest();
        
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Partner University1';
        pbTest.PRM_Channel_Program_Id__c = cp.id;
        pbTest.PRM_Benefit_Cd__c = 'BFTTRGANI';
        pbTest.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
        insert pbTest;
        
        PRM_AccountBenefitAssociation__c abaTest= new PRM_AccountBenefitAssociation__c();
        abaTest.PRM_Account_Id__c = newAccount1.Id;
        abaTest.PRM_Partner_Benefit_Id__c = pbTest.id;
        abaTest.PRM_Source__c='Tier';
        abaTest.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        testLst.add(abaTest);
        
        PRM_AccountChannelMembership__c testACM= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        testACM.PRM_Account_Id__c=newAccount1.id;
        testACM.PRM_Channel_Program_Id__c=cp.Id;
        testACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        testACM.PRM_Partner_Role__c='Service Provider';
        testACM.PRM_Status_Reason_Txt__c='Test03';
        testLst.add(testACM);
        
        PRM_ACMUpdateUtility.upsertData(testLst);
               
        //OPID ACM
        PRM_AccountChannelMembership__c opidACM= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidACM.PRM_Account_Id__c=opidAcc.id;
        opidACM.PRM_Status_Nm__c='Approved';
        opidACM.PRM_Channel_Program_Id__c=cp.Id;
        opidACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidACM.PRM_Status_Reason_Txt__c='Test02';
        opidACM.PRM_Partner_Role__c='Service Provider';
        insert opidACM;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont1.Id;
        acctContRel.PRM_Relationship_Id__c=admin.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c = 'Complete';
        insert acctContRel;
        acctContRel.PRM_Status_Nm__c = 'Complete';
        update acctContRel;
       
        list<PRM_PartnerBenefit__c> pbLst=new list<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        pbLst.add(pb);
        
        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Test';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'TEST';
        pb2.PRM_Account_Type_Nm__c = 'both'; 
        pbLst.add(pb2);
        
        
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Partner University1';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        pbLst.add(pb1);
        
        
        PRM_PartnerBenefit__c wrBnft = new PRM_PartnerBenefit__c(); //Partner Benefit
        wrBnft.Name = 'Standard Warranty Replacement';
        wrBnft.PRM_Channel_Program_Id__c = cp.id;
        wrBnft.PRM_Benefit_Cd__c = 'SWR';
        wrBnft.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
        pbLst.add(wrBnft);
        insert pbLst;
        
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        list<PRM_VXBnftMatrix__c> benfitLst=new list<PRM_VXBnftMatrix__c>();
        PRM_VXBnftMatrix__c bem11=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem11.PRM_Approval_Type_Nm__c='Automatic';
        bem11.PRM_Channel_Program_Id__c=cp.Id;
        bem11.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem11.PRM_Covered_Account_Ind__c=True;
        bem11.PRM_IsActive_Ind__c=True;
        bem11.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem11.PRM_Partner_Type_Id__c=pt.Id;
        bem11.PRM_Partner_Role_Nm__c='Service Provider';
        benfitLst.add(bem11);
        
        PRM_VXBnftMatrix__c bmManual = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bmManual.PRM_Partner_Benefit_Id__c = pb.id;
        bmManual.PRM_Channel_Program_Id__c = cp.id;
        bmManual.PRM_Channel_Program_Level_Id__c = cpl.id;
        bmManual.PRM_Partner_Type_Id__c = pt.id;
        bmManual.PRM_Covered_Account_Ind__c  = true;
        bmManual.PRM_Approval_Type_Nm__c = 'Manual';
        
        insert bmManual;             
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        benfitLst.add(bem);
        
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        benfitLst.add(bem1);
        
        
        PRM_VXBnftMatrix__c bem111=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem111.PRM_Approval_Type_Nm__c='Automatic';
        bem111.PRM_Channel_Program_Id__c=cp.Id;
        bem111.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem111.PRM_Covered_Account_Ind__c=True;
        bem111.PRM_IsActive_Ind__c=True;
        bem111.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem111.PRM_Partner_Type_Id__c=pt.Id;
        bem111.PRM_Partner_Role_Nm__c='Guest';
        benfitLst.add(bem111);
        
        PRM_VXBnftMatrix__c bem112=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem112.PRM_Approval_Type_Nm__c='Automatic';
        bem112.PRM_Channel_Program_Id__c=cp.Id;
        bem112.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem112.PRM_Covered_Account_Ind__c=True;
        bem112.PRM_IsActive_Ind__c=True;
        bem112.PRM_Partner_Benefit_Id__c=pb.Id;
        bem112.PRM_Partner_Type_Id__c=pt.Id;
        bem112.PRM_Partner_Role_Nm__c='Guest';
        benfitLst.add(bem112);
        
        
        PRM_VXBnftMatrix__c bem1111=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1111.PRM_Approval_Type_Nm__c='Automatic';
        bem1111.PRM_Channel_Program_Id__c=cp.Id;
        bem1111.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem1111.PRM_Covered_Account_Ind__c=True;
        bem1111.PRM_IsActive_Ind__c=True;
        bem1111.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1111.PRM_Partner_Type_Id__c=pt.Id;
        bem1111.PRM_Partner_Role_Nm__c='Guest';
        benfitLst.add(bem1111);
        
        
        PRM_VXBnftMatrix__c bem113=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem113.PRM_Approval_Type_Nm__c='Automatic';
        bem113.PRM_Channel_Program_Id__c=cp.Id;
        bem113.PRM_Channel_Program_Level_Id__c=cpl2.Id;
        bem113.PRM_Covered_Account_Ind__c=True;
        bem113.PRM_IsActive_Ind__c=True;
        bem113.PRM_Partner_Benefit_Id__c=pb.Id;
        bem113.PRM_Partner_Type_Id__c=pt.Id;
        bem113.PRM_Partner_Role_Nm__c='Guest';
        benfitLst.add(bem113);
        insert benfitLst;
        
        List<PRM_AccountBenefitAssociation__c> abaLst = new List<PRM_AccountBenefitAssociation__c>();
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Source__c='Tier';
        aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        abaLst.add(aba);
        
        PRM_AccountBenefitAssociation__c abaSpec = new PRM_AccountBenefitAssociation__c();
        abaSpec.PRM_Account_Id__c = newAccount.Id;
        abaSpec.PRM_Partner_Benefit_Id__c = pb.id;
        abaSpec.PRM_Status_Nm__c = 'Active';
        abaSpec.PRM_Source__c='Select Benefit';
        abaSpec.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        abaLst.add(abaSpec);
        
        PRM_AccountBenefitAssociation__c aba11 = new PRM_AccountBenefitAssociation__c();
        aba11.PRM_Account_Id__c = newAccount.Id;
        aba11.PRM_Partner_Benefit_Id__c = wrBnft.id;
        aba11.PRM_Status_Nm__c = 'Active';        
        aba11.PRM_Source__c='Tier';
        aba11.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        abaLst.add(aba11);
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb1.id;
        aba1.PRM_Status_Nm__c = 'Active';
        aba1.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        aba1.PRM_Source__c='Tier';
        abaLst.add(aba1);
        
        PRM_PartnerBenefit__c pbTe = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTe.Name = 'Partner University1';
        pbTe.PRM_Channel_Program_Id__c = cp.id;
        pbTe.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTe.PRM_Account_Type_Nm__c = 'Both'; 
        pbLst.add(pbTe);
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        
        Contact cont3 = new Contact();  //Contact  
        cont3.AccountId=testAccount.Id;
        cont3.lastName='Grilla';
        cont3.FirstName='Adama';
        cont3.email='AdamGraill@rediff.com';
        cont3.Core_Job_Function__c='Branch aManager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_Partner_Community__c = 'Intel® IOT Solution Partner';
        cont3.Core_Login_Status__c = 'Active';
	cont3.MailingCountryCode = 'IND';
        insert cont3;
        
        //cont.Core_IPA_PartnerRole__c = 'Service Provider';
        PRM_AccountBenefitAssociation__c abaT = new PRM_AccountBenefitAssociation__c();
        abaT.PRM_Account_Id__c = testAccount.Id;
        abaT.PRM_Partner_Benefit_Id__c = pbTe.id;
        abaT.PRM_Status_Nm__c = 'Active';
        abaT.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        abaT.PRM_Source__c='Tier';
        abaLst.add(abaT);
        
        PRM_AccountChannelMembership__c testACM1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        testACM1.PRM_Account_Id__c=opidAcc.id;
        testACM1.PRM_Status_Nm__c='Approved';
        testACM1.PRM_Channel_Program_Id__c=cp.Id;
        testACM1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        testACM1.PRM_Partner_Role__c='Guest';
        testACM1.PRM_Status_Reason_Txt__c='Test04';
        insert testACM1;
            
        //PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaLst;
        //PRM_aba_TriggerHandler.executeTrigger = true; 
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        pq.PRM_Question_Display_Txt__c ='Points Not eligible';
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq.PRM_Question_Type_Nm__c = 'Text';
        pq.PRM_InActive_Ind__c = false;
        insert pq;
        
        PRM_Profile_Questions__c pq1 = new PRM_Profile_Questions__c();
        pq1.PRM_Channel_Program_Id__c = cp.Id;
        pq1.PRM_Question_Display_Txt__c ='Points Opt-in';
        //pq1.PRM_Partner_Role__c='Service Provider';       
        //pq1.PRM_Partner_Type_Id__c = pt.Id;
        pq1.PRM_Question_Type_Nm__c = 'Textarea';
        pq1.PRM_InActive_Ind__c = false;
        insert pq1;
        
        PRM_Profile_Questions__c pq2 = new PRM_Profile_Questions__c();
        pq2.PRM_Channel_Program_Id__c = cp.Id;
        pq2.PRM_Question_Display_Txt__c = 'Component Point earning excluded';
        //pq2.PRM_Partner_Role__c='Service Provider';
        //pq2.PRM_Partner_Type_Id__c = pt.Id;
        pq2.PRM_Question_Type_Nm__c = 'Multiselect';
        pq2.PRM_InActive_Ind__c = false;
        insert pq2;
        
        PRM_Profile_Questions__c pq3 = new PRM_Profile_Questions__c();
        pq3.PRM_Channel_Program_Id__c = cp.Id;
        pq3.PRM_Question_Display_Txt__c = 'Branded Point earning excluded';
        //pq3.PRM_Partner_Role__c='Service Provider';
        //pq3.PRM_Partner_Type_Id__c = pt.Id;
        pq3.PRM_Question_Type_Nm__c = 'Boolean';
        pq3.PRM_InActive_Ind__c = false;
        insert pq3;
        
        PRM_Profile_Questions__c pq4 = new PRM_Profile_Questions__c();
        pq4.PRM_Channel_Program_Id__c = cp.Id;
		pq4.PRM_Question_Display_Txt__c ='ODM whitebox Point earning excluded';
        //pq4.PRM_Partner_Role__c='Service Provider';
        //pq4.PRM_Partner_Type_Id__c = pt.Id;
        pq4.PRM_Question_Type_Nm__c = 'Picklist';
        pq4.PRM_InActive_Ind__c = false;
        insert pq4;
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Profile_Questions_Id__c = pq.Id;
        insert pa;
        
        PRM_Profile_Answer__c pa1 = new PRM_Profile_Answer__c();
        pa1.PRM_Profile_Questions_Id__c = pq1.Id;
        insert pa1;
        
        PRM_Profile_Answer__c pa2 = new PRM_Profile_Answer__c();
        pa2.PRM_Profile_Questions_Id__c = pq2.Id;
        insert pa2;
        
        PRM_Profile_Answer__c pa3 = new PRM_Profile_Answer__c();
        pa3.PRM_Profile_Questions_Id__c = pq3.Id;
        insert pa3;
        
        PRM_Profile_Answer__c pa4 = new PRM_Profile_Answer__c();
        pa4.PRM_Profile_Questions_Id__c = pq4.Id;
        insert pa4;
        
        List<PRM_Profile_Responses__c> prList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> presList = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = newAccount.Id;
        pr.PRM_Profile_Answer_Id__c = pa.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        pr.PRM_Response_Txt__c = 'true';
        insert pr;
        
        PRM_Profile_Responses__c pr1 = new PRM_Profile_Responses__c();
        pr1.PRM_Account_Id__c = newAccount.Id;
        pr1.PRM_Profile_Answer_Id__c = pa1.Id;
        pr1.PRM_Profile_Questions_Id__c = pq1.Id;
        pr1.PRM_Response_Txt__c = 'true';
        prList.add(pr1);
        
        PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
        pr2.PRM_Account_Id__c = newAccount.Id;
        pr2.PRM_Profile_Answer_Id__c = pa2.Id;
        pr2.PRM_Profile_Questions_Id__c = pq2.Id;
        pr2.PRM_Response_Txt__c = 'true';
        prList.add(pr2);
        
        PRM_Profile_Responses__c pr3 = new PRM_Profile_Responses__c();
        pr3.PRM_Account_Id__c = newAccount.Id;
        pr3.PRM_Profile_Answer_Id__c = pa3.Id;
        pr3.PRM_Profile_Questions_Id__c = pq3.Id;
        pr3.PRM_Response_Txt__c = 'true';
        presList.add(pr3);
        
        PRM_Profile_Responses__c pr4 = new PRM_Profile_Responses__c();
        pr4.PRM_Account_Id__c = newAccount.Id;
        pr4.PRM_Profile_Answer_Id__c = pa4.Id;
        pr4.PRM_Profile_Questions_Id__c = pq4.Id;
        pr4.PRM_Response_Txt__c = 'true';
        presList.add(pr4);
        //OPID
        PRM_Profile_Responses__c pr5 = new PRM_Profile_Responses__c();
        pr5.PRM_Account_Id__c = opidAcc.Id;
        pr5.PRM_Profile_Answer_Id__c = pa.Id;
        pr5.PRM_Profile_Questions_Id__c = pq.Id;
        pr5.PRM_Response_Txt__c = 'true';
        insert pr5;
        
        PRM_Profile_Responses__c pr6 = new PRM_Profile_Responses__c();
        pr6.PRM_Account_Id__c = opidAcc.Id;
        pr6.PRM_Profile_Answer_Id__c = pa1.Id;
        pr6.PRM_Profile_Questions_Id__c = pq1.Id;
        pr6.PRM_Response_Txt__c = 'true';
        prList.add(pr6);
        
        PRM_Profile_Responses__c pr7 = new PRM_Profile_Responses__c();
        pr7.PRM_Account_Id__c = opidAcc.Id;
        pr7.PRM_Profile_Answer_Id__c = pa2.Id;
        pr7.PRM_Profile_Questions_Id__c = pq2.Id;
        pr7.PRM_Response_Txt__c = 'true';
        prList.add(pr7);
        
        PRM_Profile_Responses__c pr8 = new PRM_Profile_Responses__c();
        pr8.PRM_Account_Id__c = opidAcc.Id;
        pr8.PRM_Profile_Answer_Id__c = pa3.Id;
        pr8.PRM_Profile_Questions_Id__c = pq3.Id;
        pr8.PRM_Response_Txt__c = 'true';
        presList.add(pr8);
        
        insert presList;
        
        /*PRM_Profile_Responses__c pr4 = new PRM_Profile_Responses__c();
        pr4.PRM_Account_Id__c = opidAcc.Id;
        pr4.PRM_Profile_Answer_Id__c = pa4.Id;
        pr4.PRM_Profile_Questions_Id__c = pq4.Id;
        presList.add(pr4);*/
        
        PRM_ProfileReponseMismatchReport.getProfileResponse(PRM_ProfileReponseMismatchReport.getOnePartnerIds());
        PRM_BenefitMisMatchReport.getAccountsAndBenefits(PRM_BenefitMisMatchReport.getAccountIds(), JSON.serialize(PRM_BenefitMisMatchReport.getRequiredBenefits()));
        
        
        test.stopTest();    
        
        
        

        
    }
}