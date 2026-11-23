@isTest
public class acm_utility_sample_Test {
    public static List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
    public static List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
    public static  boolean firstRun = true;
    public static  boolean mPFirstRun =true;
    
    @testSetup
    static void setup(){
        prm_skip_trigger__c sk = new prm_skip_trigger__c();
        sk.Name='ABA_Trigger';
        sk.inactive__c= false;
        insert sk;
    }
    static testmethod void test_CreateOPIDRecomndtn1(){
        
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
        List<account> acclist1  = new List<account>();
        acclist1.add(opidAcc);
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.Core_CIM_ID__c = '9456456' ; //TWC729-1292
        acclist1.add(newAccount);
        //insert acclist1;
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Greg';
        newAccount1.BillingCity='Greg';
        newAccount1.BillingStreet='Greg';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c='www.Greg.com';
        newAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount1.Core_CIM_ID__c = null ; //TWC729-1292
        acclist1.add(newAccount1);
        TriggerHandler.bypass('Core_AccountTriggerHandler');
        insert acclist1;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        //cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry='India';
        TriggerHandler.bypass('Core_ContactHandler');
        insert cont;
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Grill';
        cont1.FirstName='Adam';
        cont1.email='AdamGrill00@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        //cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.MailingCountry='India';
        TriggerHandler.bypass('Core_ContactHandler');
        insert cont1;
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
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cp.id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        insert pt;
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation; 
        List<PRM_Account_Contact_Relationship__c> acctContRelList=new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel);
        
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acctContRelList;
        List<PRM_AccountChannelMembership__c> AcmList1 = new List<PRM_AccountChannelMembership__c>(); //TWC729-1292        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Inactive';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Suppress_Email__c= true;
        AcmList1.add(acm);
        /*PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
acm1.PRM_Account_Id__c=opidAcc.id;
acm1.PRM_Status_Nm__c='Approved';
acm1.PRM_Channel_Program_Id__c=cp.Id;
acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
acm1.PRM_Partner_Role__c='Service Provider';
AcmList1.add(acm1);*/
        insert AcmList1;
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt;     
        /*Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
        coreAccnt1.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt1.Core_Intel_Account_Id__c = newAccount.id;
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt1;     */
        //PRM_ACM_Utility.UpsertOPIDACM(AcmList1,null);
        List<PRM_AccountChannelMembership__c> AcmList2 = new List<PRM_AccountChannelMembership__c>();       
        PRM_AccountChannelMembership__c opidacm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm1.PRM_Account_Id__c=newAccount1.id;
        opidacm1.PRM_Status_Nm__c='Inactive';
        opidacm1.PRM_Channel_Program_Id__c=cp.Id;
        opidacm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm1.PRM_Partner_Role__c='Service Provider';
        opidacm1.PRM_Suppress_Email__c= true;
        AcmList2.add(opidacm1);
        PRM_AccountChannelMembership__c opidacm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm2.PRM_Account_Id__c=opidAcc.id;
        opidacm2.PRM_Status_Nm__c= 'Approved';
        opidacm2.PRM_Channel_Program_Id__c=cp.Id;
        opidacm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm2.PRM_Partner_Role__c='Service Provider';
        opidacm2.PRM_Suppress_Email__c= true;
        AcmList2.add(opidacm2);
        PRM_AccountChannelMembership__c opidacm3= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm3.PRM_Account_Id__c=opidAcc.id;
        opidacm3.PRM_Status_Nm__c= 'Approved';
        opidacm3.PRM_Channel_Program_Id__c=cp.Id;
        opidacm3.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm3.PRM_Partner_Role__c='Distributor';
        opidacm3.PRM_Suppress_Email__c= true;
        AcmList2.add(opidacm3);
        insert AcmList2;  
        PRM_AccountChannelMembership__c oldAcm = acm.clone(true, false, true, true);
        oldAcm.id = acm.id;
        oldAcm.PRM_Status_Nm__c='Active';
        oldAcm.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        oldAcm.PRM_Partner_Role__c='Distributor';
        Map<Id, PRM_AccountChannelMembership__c> oldACMMap = new Map<Id, PRM_AccountChannelMembership__c>();
        oldACMMap.put(oldAcm.id, oldAcm);
        Map<Id, PRM_AccountChannelMembership__c> oldACMMap2 = new Map<Id, PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c oldopidAcm = opidacm2.clone(true, false, true, true);
        oldopidAcm.id = opidacm2.id; 
        AcmList2[0].PRM_Channel_Program_Level_Id__c = cpl2.id;
        oldACMMap2.put(oldopidAcm.id, oldopidAcm);
        //PRM_ACM_Utility.UpdateLocationAccACM(AcmList2,oldACMMap2);
        
        //PRM_ACM_Utility.duplicateRecordCheck(AcmList1,oldACMMap.values()); 
        //PRM_ACM_Utility.duplicateRecordCheck(AcmList1,null); 
        //PRM_ACM_Utility.UpsertOPIDACM(AcmList1,oldACMMap);
        PRM_ACM_Utility.CreateOPIDRecomndtn(AcmList2,oldACMMap); //TWC729-6800 EOL activities
        AcmList2[0].PRM_Channel_Program_Level_Id__c = cpl2.id; 
        
        //PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);
        oldACMMap.values()[0].PRM_Status_Nm__c='Active';
        AcmList1[0].PRM_Status_Nm__c='Active';
        //PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);   
        AcmList2[0].PRM_Status_Nm__c='Active';      
        //PRM_ACM_Utility.suppressEmail(AcmList1);
        //PRM_ACM_Utility.suppressEmail(AcmList2);
        //PRM_ACM_Utility.updateSuppressEmail(AcmList1, oldACMMap);
        oldAcm.PRM_Status_Nm__c='Active';
        //PRM_ACM_Utility.updateACMStatusChangeDate(AcmList1, oldACMMap);
        // //PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);
        oldAcm.PRM_Status_Nm__c='Active';
        oldAcm.PRM_Partner_Role__c='Distributor';
        acm.PRM_Suppress_Email__c = true;
        //PRM_ACM_Utility.createTrackerMilestonesForMembershipUpdate(AcmList1, oldACMMap);              
        oldopidAcm.PRM_Partner_Role__c='Distributor';       
        List<PRM_AccountChannelMembership__c> opidACMList = new List<PRM_AccountChannelMembership__c>();
        opidACMList.add(opidacm2);
        //PRM_ACM_Utility.createTrackerMilestonesForMembershipUpdate(opidACMList, oldACMMap2);
    }
    
}