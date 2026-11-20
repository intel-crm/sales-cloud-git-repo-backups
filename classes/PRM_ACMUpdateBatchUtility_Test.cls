@isTest
public class PRM_ACMUpdateBatchUtility_Test {
    // public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);
    
    @isTest
    public static void Test(){ 
        Map<Id, List<PRM_AccountBenefitAssociation__c>> actSpecificABAListMp = new  Map<Id, List<PRM_AccountBenefitAssociation__c>>();
        Map<Id, List<PRM_AccountBenefitAssociation__c>> abaMap = new Map<Id, List<PRM_AccountBenefitAssociation__c>>();
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        prm_skip_trigger__c sk = new prm_skip_trigger__c();
        sk.Name='ABA_Trigger';
        sk.inactive__c= false;
        insert sk;
        
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
        //;;
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
        
        Set<Id> accIds = new Set<Id> 
        { newAccount.Id };
            
            Contact cont = new Contact();  //Contact  
        cont.AccountId=opidAcc.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        //cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountryCode = 'USA';
        cont.MailingCountry='USA';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        list<ChannelProgramLevel> cpLst=new list<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        cpLst.add(cpl);
       
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Prestige';
        cpl1.ProgramId=cp.Id;
        cpLst.add(cpl1);
        
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Prestige';
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
        
        //location account acm
        PRM_AccountChannelMembership__c newAccountAcm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        newAccountAcm.PRM_Account_Id__c=newAccount.id;
        newAccountAcm.PRM_Status_Nm__c='Approved';
        newAccountAcm.PRM_Channel_Program_Id__c=cp.Id;
        newAccountAcm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        newAccountAcm.PRM_Partner_Role__c='Service Provider';
        newAccountAcm.PRM_Status_Reason_Txt__c = 'Test class';
        insert newAccountAcm;
        
        PRM_AccountChannelMembership__c opidACM1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidACM1.PRM_Account_Id__c=newAccount.id;
        opidACM1.PRM_Status_Nm__c='Inactive';
        opidACM1.PRM_Channel_Program_Id__c=cp.Id;
        opidACM1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidACM1.PRM_Status_Reason_Txt__c = 'Test class';
        opidACM1.PRM_Partner_Role__c='Guest';
        insert opidACM1;

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
       // newAccount1.Core_User_Defined_Website__c='www.abc.com';
        newAccount1.Core_IPA_One_Partner_Id__c=opidAcc.id;
        testLst.add(newAccount1);
        
        Contact cont1 = new Contact();  //Contact  
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Grill';
        cont1.FirstName='Adam';
        cont1.email='AdamGrill123@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.MailingCountryCode = 'USA';
        cont1.MailingCountry='USA';
        insert cont1;
        
        Contact cont122 = new Contact();  //Contact  
        cont122.AccountId=newAccount1.Id;
        cont122.lastName='Grill12';
        cont122.FirstName='Adam23';
        cont122.email='AdamGrill1213@rediff.com';
        cont122.Core_Job_Function__c='Branch Manager';
        cont122.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont122.Core_IPA_PartnerRole__c = 'Service Provider';
        cont122.MailingCountryCode = 'USA';
        cont122.MailingCountry='USA';
        
        testLst.add(cont122);
        
        PRM_Account_Contact_Relationship__c acctContRelEmp2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp2.PRM_Account_Id__c=opidAcc.Id;
        acctContRelEmp2.PRM_Contact_Id__c=cont.Id;
        acctContRelEmp2.PRM_Relationship_Id__c=admin.Id;
        acctContRelEmp2.PRM_InActive_Ind__c=false;
        acctContRelEmp2.PRM_Status_Nm__c = 'Complete';
        
        insert acctContRelEmp2;
       // test.startTest();
       
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Solutions Marketplace Enhanced';/*'Partner University1'*/
        pbTest.PRM_Channel_Program_Id__c = cp.id;
        pbTest.PRM_Benefit_Cd__c = 'BFTMKTPLED'/*'BFTTRGANI'*/;
        pbTest.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
        insert pbTest;
             
        PRM_AccountBenefitAssociation__c abaTest28= new PRM_AccountBenefitAssociation__c();
        abaTest28.PRM_Account_Id__c = opidAcc.Id;
        abaTest28.PRM_Partner_Benefit_Id__c = pbTest.id;
       // abaTest.PRM_Status_Nm__c = 'Active';
        abaTest28.PRM_Source__c='Tier';
        testLst.add(abaTest28);
        

        PRM_AccountBenefitAssociation__c abaTest= new PRM_AccountBenefitAssociation__c();
        abaTest.PRM_Account_Id__c = newAccount1.Id;
        abaTest.PRM_Partner_Benefit_Id__c = pbTest.id;
       // abaTest.PRM_Status_Nm__c = 'Active';
        abaTest.PRM_Source__c='Tier';
        testLst.add(abaTest);
        abaList.add(abaTest);
        actSpecificABAListMp.put(abaTest.PRM_Account_Id__c,abaList);
        
        
        
        PRM_AccountChannelMembership__c testACM= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        testACM.PRM_Account_Id__c=newAccount1.id;
       // testACM.PRM_Status_Nm__c='Approved';
        testACM.PRM_Channel_Program_Id__c=cp.Id;
        testACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        testACM.PRM_Partner_Role__c='Service Provider';
        testACM.PRM_Status_Reason_Txt__c = 'Test class';
        testLst.add(testACM);
        
        //abaMap = PRM_ACMUpdateUtilityNew.getAccountSpecificABA(actSpecificABAListMp,abaTest28,newAccount.Id);
        //abaMap = PRM_ACMUpdateUtilityNew.getAccountSpecificABA(actSpecificABAListMp,abaTest,newAccount1.Id);
        
        PRM_ACMUpdateUtility.upsertData(testLst);
        
        
        
       
        //OPID ACM
        PRM_AccountChannelMembership__c opidACM= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidACM.PRM_Account_Id__c=opidAcc.id;
        opidACM.PRM_Status_Nm__c='Approved';
        opidACM.PRM_Channel_Program_Id__c=cp.Id;
        opidACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidACM.PRM_Status_Reason_Txt__c = 'Test class';
        opidACM.PRM_Partner_Role__c='Service Provider';
        insert opidACM;
        
        
        PRM_IPA_Membership__c ipaMem1 = new PRM_IPA_Membership__c();
        ipaMem1.PRM_Account_Channel_Membership__c = opidACM.Id;
        ipaMem1.PRM_Old_Partner_Role__c=opidACM.PRM_Partner_Role__c;
        ipaMem1.PRM_Old_Partner_Tier__c=cpl.name;
        ipaMem1.PRM_Partner_Role__c = 'Distributor';
        ipaMem1.PRM_Partner_Tier__c = cpl1.Id;
        ipaMem1.PRM_Status__c='In Progress';
        insert ipaMem1;
        
        ipaMem1.PRM_Partner_Role__c = 'Guest';
        update ipaMem1;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont1.Id;
        acctContRel.PRM_Relationship_Id__c=admin.Id;
        acctContRel.PRM_InActive_Ind__c=false;
       // acctContRel.PRM_execute_trigger__c=true;
        acctContRel.PRM_Status_Nm__c = 'Complete';
       // acctContRel.PRM_Partner_Role__c=newAccountAcm.PRM_Partner_Role__c;
        insert acctContRel;
        System.debug('acctContRel inserted:'+[select id,PRM_InActive_Ind__c,PRM_Status_Nm__c, PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c ,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where id = :acctContRel.id]);
        acctContRel.PRM_Status_Nm__c = 'Complete';
        update acctContRel;
        System.debug('acctContRel inserted:'+[select id,PRM_InActive_Ind__c,PRM_Status_Nm__c, PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c ,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where id = :acctContRel.id]);        
        
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
        pb1.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
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
        bem111.PRM_Partner_Role_Nm__c='Distributor';
        benfitLst.add(bem111);
        
        PRM_VXBnftMatrix__c bem112=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem112.PRM_Approval_Type_Nm__c='Automatic';
        bem112.PRM_Channel_Program_Id__c=cp.Id;
        bem112.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem112.PRM_Covered_Account_Ind__c=True;
        bem112.PRM_IsActive_Ind__c=True;
        bem112.PRM_Partner_Benefit_Id__c=pb.Id;
        bem112.PRM_Partner_Type_Id__c=pt.Id;
        bem112.PRM_Partner_Role_Nm__c='Distributor';
        benfitLst.add(bem112);
       
        
        PRM_VXBnftMatrix__c bem1111=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1111.PRM_Approval_Type_Nm__c='Automatic';
        bem1111.PRM_Channel_Program_Id__c=cp.Id;
        bem1111.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem1111.PRM_Covered_Account_Ind__c=True;
        bem1111.PRM_IsActive_Ind__c=True;
        bem1111.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1111.PRM_Partner_Type_Id__c=pt.Id;
        bem1111.PRM_Partner_Role_Nm__c='Distributor';
        benfitLst.add(bem1111);
       
        
         PRM_VXBnftMatrix__c bem113=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem113.PRM_Approval_Type_Nm__c='Automatic';
        bem113.PRM_Channel_Program_Id__c=cp.Id;
        bem113.PRM_Channel_Program_Level_Id__c=cpl2.Id;
        bem113.PRM_Covered_Account_Ind__c=True;
        bem113.PRM_IsActive_Ind__c=True;
        bem113.PRM_Partner_Benefit_Id__c=pb.Id;
        bem113.PRM_Partner_Type_Id__c=pt.Id;
        bem113.PRM_Partner_Role_Nm__c='Distributor';
        benfitLst.add(bem113);
        insert benfitLst;
        
        List<PRM_AccountBenefitAssociation__c> abaLst = new List<PRM_AccountBenefitAssociation__c>();
        
        PRM_AccountBenefitAssociation__c aba22 = new PRM_AccountBenefitAssociation__c();
        aba22.PRM_Account_Id__c = opidAcc.Id;
        aba22.PRM_Partner_Benefit_Id__c = pb.id;
        aba22.PRM_Status_Nm__c = 'Active';
        aba22.PRM_Source__c='Tier';
         aba22.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
       
        abaLst.add(aba22); 
         PRM_AccountBenefitAssociation__c aba23 = new PRM_AccountBenefitAssociation__c();
        aba23.PRM_Account_Id__c = opidAcc.Id;
        aba23.PRM_Partner_Benefit_Id__c = pb.id;
        aba23.PRM_Status_Nm__c = 'Inactive';
        aba23.PRM_Source__c='Tier';
        aba23.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
       
        abaLst.add(aba23); 
        
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
         abaspec.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
       
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
        PRM_IPAR_ACMUpdateUtility.getListOfBenefits(abaLst);
        PRM_PartnerBenefit__c pbTe = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTe.Name = 'Partner University1';
        pbTe.PRM_Channel_Program_Id__c = cp.id;
        pbTe.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTe.PRM_Account_Type_Nm__c = 'Both'; 
        pbLst.add(pbTe);
        test.startTest();
         Account opidAcc1 = new Account();//Account
        opidAcc1.RecordTypeId = recordTypeIdPagAccount;
        opidAcc1.Name='OPID';
        //;;
        opidAcc1.BillingCity='City1';
        opidAcc1.BillingStreet='Street1';
        opidAcc1.BillingCountry='India';
        opidAcc1.BillingPostalCode='Postal code';
        opidAcc1.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        opidAcc1.Core_IPA_Partner_Role__c='Service Provider;Distributor';
        opidAcc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        opidAcc1.Website='www.abc.com';
        opidAcc1.Core_User_Defined_Website__c='www.abc.com';
        insert opidAcc1; 
        
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
        cont3.MailingCountryCode = 'USA';
        cont3.MailingCountry='USA';
        insert cont3;
        
        //cont.Core_IPA_PartnerRole__c = 'Service Provider';
        PRM_AccountBenefitAssociation__c abaT = new PRM_AccountBenefitAssociation__c();
        abaT.PRM_Account_Id__c = testAccount.Id;
        abaT.PRM_Partner_Benefit_Id__c = pbTe.id;
        abaT.PRM_Status_Nm__c = 'Inactive';
        abaT.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        abaT.PRM_Source__c='Tier';
        abaLst.add(abaT);
       
        PRM_AccountChannelMembership__c testACM1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        testACM1.PRM_Account_Id__c=testAccount.id;
        testACM1.PRM_Status_Nm__c='Approved';
        testACM1.PRM_Channel_Program_Id__c=cp.Id;
        testACM1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        testACM1.PRM_Partner_Role__c='Guest';
        testACM1.PRM_Status_Reason_Txt__c = 'Test class';
        insert testACM1;
         PRM_AccountChannelMembership__c testopidACM1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        testopidACM1.PRM_Account_Id__c=testAccount.id;
        testopidACM1.PRM_Status_Nm__c='Approved';
        testopidACM1.PRM_Channel_Program_Id__c=cp.Id;
        testopidACM1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        testopidACM1.PRM_Partner_Role__c='Guest';
        testopidACM1.PRM_Status_Reason_Txt__c = 'Test class';
        insert testopidACM1;

        PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaLst;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        // add entitlement
        //add value ex entitlement 
       
        
                
        /*PRM_Specialty__c spec1 = new PRM_Specialty__c();
       // spec1.recordtypeId = specid;
        spec1.name='Cloud Data Center Specialty';
        spec1.PRM_Description_Txt__c='This is description1';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c='Service Provider';
        asa.PRM_InActive_Ind__c=false;
        insert asa;
        */
        
    
        aba1.PRM_Status_Nm__c='Inactive';
        aba1.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
        update aba1;
        
        Core_AGS_Role__c ags = new Core_AGS_Role__c();
        ags.Name= 'Ags role';
        ags.Core_Technical_Name__c = 'Ags role';
        insert ags;
                                
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        list<Core_Entitlement__c> entLst=new list<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Sales PRM- Partner Points Redemption User';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        ed.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(ed);
       // insert ed;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        ed1.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(ed1);
        //insert ed1;
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Technology Sandbox';
        ed2.Core_Display_Name__c='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        ed2.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(ed2);
        //insert ed2;
        //
        Core_Entitlement__c entitlement1=new Core_Entitlement__c(); //Entitlement
        entitlement1.Name='FPGA Partner Program Titanium Tier Access';
        entitlement1.Core_Display_Name__c='FPGA Partner Program Titanium Tier Access';
        entitlement1.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement1.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement1);
      //  insert entitlement1;
        
        Core_Entitlement__c entitlement2=new Core_Entitlement__c(); //Entitlement
        entitlement2.Name='FPGA Partner Program Gold Tier Access';
        entitlement2.Core_Display_Name__c='FPGA Partner Program Gold Tier Access';
        entitlement2.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement2.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement2);
        //insert entitlement2;
        
        
        Core_Entitlement__c entitlement3=new Core_Entitlement__c(); //Entitlement
        entitlement3.Name='Partner Admin';
        entitlement3.Core_Display_Name__c='Partner Admin';
        entitlement3.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement3.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement3);
        //insert entitlement3;
        
        Core_Entitlement__c entitlement4=new Core_Entitlement__c(); //Entitlement
        entitlement4.Name='Employee';
        entitlement4.Core_Display_Name__c='Employee';
        entitlement4.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement4.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement4);
        
        Core_Entitlement__c entitlement41=new Core_Entitlement__c(); //Entitlement
        entitlement41.Name='IOT Community User';
        entitlement41.Core_Display_Name__c='IOT Community User';
        entitlement41.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement41.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement41);
        
        //insert entitlement4;
        
        Core_Entitlement__c entitlement5=new Core_Entitlement__c(); //Entitlement
        entitlement5.Name='Points View';
        entitlement5.Core_Display_Name__c='Points View';
        entitlement5.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement5.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement5);
       // insert entitlement5;
            
        Core_Entitlement__c entitlement6=new Core_Entitlement__c(); //Entitlement
        entitlement6.Name='Warranty Requestor';
        entitlement6.Core_Display_Name__c='Warranty Requestor';
        entitlement6.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement6.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement6);
        
        Core_Entitlement__c entitlement51=new Core_Entitlement__c(); //Entitlement
        entitlement51.Name='Points Manager';
        entitlement51.Core_Display_Name__c='Points Manager';
        entitlement51.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement51.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement51);
       // insert entitlement5;
        
        Core_Entitlement__c entitlement61=new Core_Entitlement__c(); //Entitlement
        entitlement61.Name='FPGA Design Services Customer Project Registration';
        entitlement61.Core_Display_Name__c='FPGA Design Services Customer Project Registration';
        entitlement61.Core_ERPM_Engagement_Id__c=ee.id;
        entitlement61.Core_AGS_Role_Id__c = ags.Id;
        entLst.add(entitlement61);
        
        //insert entitlement6;
        
        insert entLst;
        
        List<Core_Contact_Entitlement__c>corConEntitInertList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = cont3.id;
        coreCon.Core_Entitlement_Id__c = entitlement5.id;
        coreCon.Core_Status__c = 'Complete';
        coreCon.Core_Selected__c = true;
        corConEntitInertList.add(coreCon);
        
        
        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = cont.id;
        coreCon1.Core_Entitlement_Id__c = entitlement6.id;
        coreCon1.Core_Status__c = 'Complete';
        coreCon1.Core_Selected__c = true;
        corConEntitInertList.add(coreCon1);
        
        Core_Contact_Entitlement__c coreCon13 = new Core_Contact_Entitlement__c();
        coreCon13.Core_Contact_Id__c = cont.id;
        coreCon13.Core_Entitlement_Id__c = entitlement61.id;
        coreCon13.Core_Status__c = 'Complete';
        coreCon13.Core_Selected__c = false;
        
        corConEntitInertList.add(coreCon13);
        
        
        Core_Contact_Entitlement__c coreCon2 = new Core_Contact_Entitlement__c();
        coreCon2.Core_Contact_Id__c = cont1.id;
        coreCon2.Core_Entitlement_Id__c = entitlement51.id;
        coreCon2.Core_Status__c = 'Complete';
        coreCon2.Core_Selected__c = true;
        corConEntitInertList.add(coreCon2);
        
        Core_Contact_Entitlement__c coreCon20 = new Core_Contact_Entitlement__c();
        coreCon20.Core_Contact_Id__c = cont1.id;
        coreCon20.Core_Entitlement_Id__c = entitlement41.id;
        coreCon20.Core_Status__c = 'Complete';
        coreCon20.Core_Selected__c = true;
        corConEntitInertList.add(coreCon20);
        
        insert corConEntitInertList;
        
        test.stopTest();
        
        List<PRM_VXEnttlmntMatrix__c> vxentLst = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c seller1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller1.RecordTypeId = recordTypeIdWithBnft;
        seller1.PRM_Partner_Benefit_Id__c = wrBnft.id;
        seller1.PRM_Entitlement_Id__c = entitlement6.id;
        seller1.PRM_Contact_Relationship_Id__c = admin.id;
        seller1.PRM_Approval_Type_Nm__c='Automatic';
        seller1.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller1.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller1.PRM_Channel_Program_Id__c = cp.Id;
        // seller1.PRM_IPARefreshCheck__c = True;
        vxentLst.add(seller1);
        
         Id recordTypeIdCommunityEnt = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByDeveloperName().get('Community_Entitlements').getRecordTypeId();
        
        PRM_VXEnttlmntMatrix__c seller19= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller19.RecordTypeId = recordTypeIdCommunityEnt;
        
        seller19.PRM_Entitlement_Id__c = entitlement41.id;
        seller19.PRM_Contact_Relationship_Id__c = admin.id;
        seller19.PRM_Approval_Type_Nm__c='Automatic';
        seller19.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller19.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller19.PRM_Channel_Program_Id__c = cp.Id;
        // seller19.PRM_IPARefreshCheck__c = True;
        vxentLst.add(seller19);
        
        PRM_VXEnttlmntMatrix__c seller112= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller112.RecordTypeId = recordTypeIdWithBnft;
        seller112.PRM_Partner_Benefit_Id__c = pb1.id;
        seller112.PRM_Entitlement_Id__c = ed2.id;
        seller112.PRM_Contact_Relationship_Id__c = employee.id;
        seller112.PRM_Approval_Type_Nm__c='Automatic';
        seller112.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller112.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller112.PRM_Channel_Program_Id__c = cp.Id;
        // seller112.PRM_IPARefreshCheck__c = True;
        vxentLst.add(seller112);
        
        PRM_VXEnttlmntMatrix__c seller111= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller111.RecordTypeId = recordTypeIdWithBnft;
        seller111.PRM_Partner_Benefit_Id__c = pb1.id;
        seller111.PRM_Entitlement_Id__c = entitlement6.id;
        seller111.PRM_Contact_Relationship_Id__c = employee.id;
        seller111.PRM_Approval_Type_Nm__c='Automatic';
        seller111.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller111.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller111.PRM_Channel_Program_Id__c = cp.Id;
        // seller111.PRM_IPARefreshCheck__c = True;
        vxentLst.add( seller111);
        
        PRM_VXEnttlmntMatrix__c seller114= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller114.RecordTypeId = recordTypeIdWithBnft;
        seller114.PRM_Partner_Benefit_Id__c = pb1.id;
        seller114.PRM_Entitlement_Id__c = entitlement6.id;
        seller114.PRM_Contact_Relationship_Id__c = employee.id;
        seller114.PRM_Approval_Type_Nm__c='Automatic';
        seller114.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        seller114.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller114.PRM_Channel_Program_Id__c = cp.Id;
        // seller114.PRM_IPARefreshCheck__c = True;
        vxentLst.add( seller114);
        
        PRM_VXEnttlmntMatrix__c seller3= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller3.RecordTypeId = recordTypeIdWithoutBnft;        
        seller3.PRM_Entitlement_Id__c = entitlement3.id;
        seller3.PRM_Contact_Relationship_Id__c = admin.id;
        seller3.PRM_Approval_Type_Nm__c='Automatic';
        seller3.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller3.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller3.PRM_Channel_Program_Id__c = cp.Id;
        // seller3.PRM_IPARefreshCheck__c = True;
        vxentLst.add(seller3);
        
        
        PRM_VXEnttlmntMatrix__c seller31= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller31.RecordTypeId = recordTypeIdWithoutBnft;        
        seller31.PRM_Entitlement_Id__c = ed2.id;
        seller31.PRM_Contact_Relationship_Id__c = admin.id;
        seller31.PRM_Approval_Type_Nm__c='Automatic';
        seller31.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller31.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller31.PRM_Channel_Program_Id__c = cp.Id;
        // seller31.PRM_IPARefreshCheck__c = True;
        vxentLst.add(seller31);
        
        PRM_VXEnttlmntMatrix__c seller4= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller4.RecordTypeId = recordTypeIdWithoutBnft;        
        seller4.PRM_Entitlement_Id__c = entitlement4.id;
        seller4.PRM_Contact_Relationship_Id__c = admin.id;
        seller4.PRM_Approval_Type_Nm__c='Automatic';
        seller4.PRM_IPA_Partner_Role_Nm__c='Guest';
        seller4.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        seller4.PRM_Channel_Program_Id__c = cp.Id;
        // seller4.PRM_IPARefreshCheck__c = True;
        vxentLst.add( seller4);
        //insert vxentLst;
        
        PRM_VXEnttlmntMatrix__c seller5= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        seller5.RecordTypeId = recordTypeIdWithoutBnft;        
        seller5.PRM_Entitlement_Id__c = entitlement4.id;
        seller5.PRM_Contact_Relationship_Id__c = admin.id;
        seller5.PRM_Approval_Type_Nm__c='Automatic';
        seller5.PRM_IPA_Partner_Role_Nm__c='Distributor';
        seller5.PRM_Channel_Program_Level_Id__c = cpl2.Id;
        seller5.PRM_Channel_Program_Id__c = cp.Id;
        // seller5.PRM_IPARefreshCheck__c = True;
        vxentLst.add( seller5);
        insert vxentLst;

        PRM_IPA_Membership__c opidacmmem = new PRM_IPA_Membership__c();
        opidacmmem.PRM_Account_Channel_Membership__c = opidACM1.Id;
        opidacmmem.PRM_Old_Partner_Role__c=opidACM1.PRM_Partner_Role__c;
        opidacmmem.PRM_Old_Partner_Tier__c=cpl.name;
        opidacmmem.PRM_Partner_Role__c = 'Distributor';
        opidacmmem.PRM_Partner_Tier__c = cpl1.Id;
        opidacmmem.PRM_Status__c='In Progress';
        
        insert opidacmmem;
        Database.executeBatch(new PRM_ACMUpdateBatchUtility());
        
    }
}