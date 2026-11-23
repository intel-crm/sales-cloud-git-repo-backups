/*********************************************************************************************************************
Class Name    : PRM_profileResponse_Test
Version       : 1.0
Created Date  : June 2019
Function      : Test Class for 'PRM_ProfileResponse'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              14 June,2019            Test Class for 'PRM_ProfileResponse'

*********************************************************************************************************************/
@isTest
public class PRM_ProfileResponse_Test {
    @testSetup
    /*Test data creation*/
    static void setupDataCreation(){  
        
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_ConAAS}';
        insert rr;

        
        /*  
Account acc = PRM_TestUtility.getAccount();
acc.BillingCity='Bengaluru';
acc.BillingCountryCode='IND';
acc.BillingStreet='4th Floor,ITPL,Brookfield';
acc.BillingPostalCode='560037';
insert acc;

Contact con = PRM_TestUtility.getContact();
con.FirstName='Samuel';
con.LastName='Johnson';
con.Email='samuel@spamok.com';
con.AccountId=acc.Id;
insert con;



ChannelProgram cp = new ChannelProgram(); //Channel Program
cp.Name='Intel Partner Alliance';
cp.PRM_programCode__c='IPA';
insert cp;


PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
pb.Name = 'Points Redeem';
pb.PRM_Channel_Program_Id__c = cp.id;
pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
pb.PRM_Account_Type_Nm__c='Mastered_Account';
insert pb;

PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
pb1.Name = 'Points View';
pb1.PRM_Channel_Program_Id__c = cp.id;
pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
pb1.PRM_Account_Type_Nm__c='Mastered_Account';
insert pb1;


List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
aba.PRM_Account_Id__c = acc.Id;
aba.PRM_Partner_Benefit_Id__c = pb.id;
aba.PRM_Status_Nm__c = 'Inactive';
aba.PRM_Status_Reason_Txt__c = 'Not interested';

PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
aba1.PRM_Account_Id__c = acc.Id;
aba1.PRM_Partner_Benefit_Id__c = pb1.id;
aba1.PRM_Status_Nm__c = 'Inactive';
aba1.PRM_Status_Reason_Txt__c = 'Not interested';

ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
cpl1.Name='Titanium';
cpl1.ProgramId=cp.Id;
insert cpl1;

PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
bem1.PRM_Approval_Type_Nm__c='Automatic';
bem1.PRM_Channel_Program_Id__c=cp.Id;
bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
bem1.PRM_Covered_Account_Ind__c=True;
bem1.PRM_IsActive_Ind__c=True;
bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
bem1.PRM_Partner_Role_Nm__c='Service Provider';
insert bem1;



PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
profileQues.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
insert profileQues;

PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
profileAns.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
insert profileAns;

PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
response.PRM_Account_Id__c = acc.Id;
response.PRM_Profile_Questions_Id__c = profileQues.Id;
response.PRM_Profile_Answer_Id__c = profileAns.Id;
insert response;
*/
    }
    
    static testMethod void activateInactiveBenefitTestprofile(){
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;  
        
        prm_skip_trigger__c skipTrig = new prm_skip_trigger__c();
        skipTrig.Name = 'ABA_Trigger'; 
        skipTrig.inactive__c = true;
        insert skipTrig;
        
        Account testAccount00 = new Account();
        testAccount00.RecordTypeId = recordTypeIdAccount;
        testAccount00.Name='John Wick 0';
        testAccount00.BillingCity='City';
        testAccount00.BillingStreet='Street';
        testAccount00.BillingCountry='India';
        testAccount00.BillingPostalCode='Postal code';
        testAccount00.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount00.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount00;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
        
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@spamok.com';
        con.AccountId=testAccount00.Id;
        con.MailingCountry='USA';
        insert con;
        
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount00.id;
        insert coreAccnt;
        
        
        
        Test.startTest();
        
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points View';
        pb.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Redeem';
        pb1.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb1;
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        test.stopTest();
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount00.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = testAccount00.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb.id;
        aba1.PRM_Status_Nm__c = 'active';
        aba1.PRM_Status_Reason_Txt__c = 'Test';
        insert aba1;
        abaList.add(aba1);
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = parent1.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'active';
        aba.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(aba);
        insert aba; 
        
        
        // Insert abaList;
        
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = testAccount00.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
        response.PRM_Response_Txt__c='true';
        insert response;
        
        update response;
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        insert profileQues1;
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns1;
        
        PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c();
        response1.PRM_Account_Id__c = testaccount00.Id;
        response1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response1.PRM_Profile_Answer_Id__c = profileAns1.Id;
        response1.PRM_Response_Txt__c='false';
        insert response1;
        
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        PRM_Registration_Request__c regReq = [Select Id,PRM_First_Name__c,PRM_Profile_Response__c from PRM_Registration_Request__c];
        Account act = testaccount00;
        Contact cont = con;
        regList.add(regReq);
        accList.add(act);
        conList.add(cont);
        //  try{
        PRM_profileResponse.createResponse(regList, accList, conList,true);
        // PRM_profileResponse.createResponse(regList, accList, conList,false);
        ///  }catch(Exception ex){
        //  System.assertEquals('Script-thrown exception', ex.getMessage());
        // }
        System.assertEquals(regReq.PRM_First_Name__c, 'Test Request','Value does not match');
        
    }  
    
    static testMethod void inactiveBenefitTestprofile(){
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;  
        
        prm_skip_trigger__c skipTrig = new prm_skip_trigger__c();
        skipTrig.Name = 'ABA_Trigger'; 
        skipTrig.inactive__c = true;
        insert skipTrig;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick 1';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        
        Account testAccount12 = new Account();
        testAccount12.RecordTypeId = recordTypeIdAccount;
        testAccount12.Name='John test 2';
        testAccount12.BillingCity='Pune';
        testAccount12.BillingStreet='Street';
        testAccount12.BillingCountry='India';
        testAccount12.BillingPostalCode='611015';
        testAccount12.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount12.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount12;
        
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@spamok.com';
        con.AccountId=testAccount.Id;
        con.MailingCountry='USA';
        insert con;
        
        Contact con1 = new contact();
        con1.FirstName='test';
        con1.LastName='cont';
        con1.Email='testcont@spamok.com';
        con1.AccountId=testAccount12.Id;
        con1.MailingCountry='USA';
        insert con1;
        
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id;
        insert coreAccnt;
        
        Test.startTest();
        
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points View';
        pb.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Redeem';
        pb1.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb1;
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        //   test.stopTest();   
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = testAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb.id;
        aba1.PRM_Status_Nm__c = 'active';
        aba1.PRM_Status_Reason_Txt__c = 'Test'; 
        insert aba1;
        abaList.add(aba1);
        //insert bem;
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = parent1.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'active';
        aba.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(aba);
        insert aba; 
        //    Insert abaList;
        
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = testAccount.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
        response.PRM_Response_Txt__c='';
        insert response;
        
        update response;
        
        PRM_Profile_Questions__c profileQues2 =  new PRM_Profile_Questions__c();
        profileQues2.PRM_Question_Cd__c = 'CSPx2_Role';
        insert profileQues2;
        
        PRM_Profile_Answer__c profileAns2 = new PRM_Profile_Answer__c();
        profileAns2.PRM_Answer_Cd__c = 'CSPx2_Role_ServiceDeployment';
        profileAns2.PRM_Profile_Questions_Id__c = profileQues2.Id;
        insert profileAns2;
        
        PRM_Profile_Responses__c response3 = new PRM_Profile_Responses__c();
        response3.PRM_Account_Id__c = testAccount.Id;
        response3.PRM_Profile_Questions_Id__c = profileQues2.Id;
        response3.PRM_Profile_Answer_Id__c = profileAns2.Id;
        response3.PRM_Response_Txt__c='false';
        insert response3;
        
        update response3;
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        insert profileQues1;
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns1;
        
        PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c();
        response1.PRM_Account_Id__c = testaccount.Id;
        response1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response1.PRM_Profile_Answer_Id__c = profileAns1.Id;
        response1.PRM_Response_Txt__c='true';
        insert response1;
        
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> regList1 = new List<PRM_Registration_Request__c>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Account> accList1 = new List<Account>();
        List<Contact> conList1 = new List<Contact>();
        
        PRM_Registration_Request__c regReq = [Select Id,PRM_First_Name__c,PRM_Profile_Response__c from PRM_Registration_Request__c limit 1];
        PRM_Registration_Request__c regreq1 = PRM_TestUtility.getPRMRegistrationRequest();
        Account act = testaccount;
        Contact cont = con;
        regList.add(regReq);
        regList1.add(regReq1);
        accList.add(act);
        conList.add(cont);
        accList1.add(testAccount12);
        conList1.add(con1);
        
        PRM_profileResponse.createResponse(regList, accList, conList,true);
        PRM_profileResponse.createResponse(regList1, accList1, conList1, false);
        PRM_profileResponse.createResponse_IPAR(regList1,accList1);
        System.assertEquals(regReq.PRM_First_Name__c, 'Test Request','Value does not match');
        map<id,PRM_Profile_Responses__c> map1= new map<id,PRM_Profile_Responses__c>();       
        map1.put(response.id,response);
        list<PRM_Profile_Responses__c> l1=new list<PRM_Profile_Responses__c>();
        l1.add(response1);
        map<id,PRM_Profile_Responses__c> map2= new map<id,PRM_Profile_Responses__c>();       
        map2.put(response.id,response3);
        list<PRM_Profile_Responses__c> l2=new list<PRM_Profile_Responses__c>();
        l2.add(response1);
        PRM_profileResponse.activateInactiveBenefit(l1,map1);
        PRM_profileResponse.activateInactiveBenefit(l2,map2);
        System.assertEquals(regReq.PRM_First_Name__c, 'Test Request','Value does not match');
        System.assertEquals(aba1.PRM_Status_Nm__c, 'active',false);
        try{
            PRM_profileResponse.createResponse(regList, accList, conList,false);
        }catch(Exception e){
        }
        
    }  
    
    static testMethod void testProfileResponseTrue(){
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;  
        
        prm_skip_trigger__c skipTrig = new prm_skip_trigger__c();
        skipTrig.Name = 'ABA_Trigger'; 
        skipTrig.inactive__c = true;
        insert skipTrig;
        
        Test.startTest();
        Account testAccount11 = new Account();
        testAccount11.RecordTypeId = recordTypeIdAccount;
        testAccount11.Name='John Wick 2';
        testAccount11.BillingCity='City';
        testAccount11.BillingStreet='Street';
        testAccount11.BillingCountry='India';
        testAccount11.BillingPostalCode='Postal code';
        testAccount11.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount11.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount11;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@spamok.com';
        con.AccountId=testAccount11.Id;
        con.MailingCountry='USA';
        insert con;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount11.id;
        insert coreAccnt;   
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points View';
        pb.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Redeem';
        pb1.PRM_Channel_Program_Id__c = cpIPATest.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb1;
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        test.stopTest();   
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount11.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = testAccount11.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb.id;
        aba1.PRM_Status_Nm__c = 'active';
        aba1.PRM_Status_Reason_Txt__c = 'Test';
        insert aba1;
        abaList.add(aba1);
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = parent1.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'active';
        aba.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(aba);
        insert aba; 
        // Insert abaList;
        
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = testAccount11.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
        response.PRM_Response_Txt__c='true';
        insert response;
        list<PRM_Profile_Responses__c> prl = new list<PRM_Profile_Responses__c>();
        PRM_ProfileResponse.activateInactiveBenefit(prl,null);  
        
        update response;
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        insert profileQues1;
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns1;
        
        PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c();
        response1.PRM_Account_Id__c = testaccount11.Id;
        response1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response1.PRM_Profile_Answer_Id__c = profileAns1.Id;
        insert response1;
        
        PRM_Registration_Request__c rr1 = PRM_TestUtility.getPRMRegistrationRequest();
        rr1.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_ConAAS}';
        //insert rr1;
        
        Account acc = new Account();
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Name='John Wick'+System.now();
        acc.BillingCity='City1';
        acc.BillingStreet='Street1';
        acc.BillingCountry='India';
        acc.BillingPostalCode='11111';
        acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert acc;
        
        Contact con1 = PRM_TestUtility.getContact();
        con1.FirstName='Samuel';
        con1.LastName='Johnson';
        con1.Email='samuel@spamok.com';
        con1.AccountId=acc.Id;
        con1.MailingCountry='USA';
        insert con1;
        
        
        //regList.add(rr1);
        accList.add(acc);
        conList.add(con1);
        
        //  PRM_profileResponse.createResponse(regList, accList, conList,false);
       // System.assertEquals(rr1.PRM_First_Name__c, 'Test Request','Value does not match');   
        
        /*  PRM_Profile_Responses__c response2 = new PRM_Profile_Responses__c();
response2.PRM_Account_Id__c = testaccount11.Id;
response2.PRM_Profile_Questions_Id__c = profileQues.Id;
response2.PRM_Profile_Answer_Id__c = profileAns.Id;
response2.PRM_Response_Txt__c ='false';
insert response2;*/
        
        
    }
    
    //activate Benefit Test
    static testMethod void activeBenefitTest(){
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<Core_Contact_Entitlement__c>corConEntitInertList = new List<Core_Contact_Entitlement__c>();
        List<Account> accntInsertList = new List<Account>();
        List<PRM_PartnerBenefit__c>benifitInsertList = new List<PRM_PartnerBenefit__c>();
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;  
        
        prm_skip_trigger__c skipTrig = new prm_skip_trigger__c();
        skipTrig.Name = 'ABA_Trigger'; 
        skipTrig.inactive__c = true;
        insert skipTrig;
        
        Account testAccount22 = new Account();
        testAccount22.RecordTypeId = recordTypeIdAccount;
        testAccount22.Name='John Wick 3';
        testAccount22.BillingCity='City';
        testAccount22.BillingStreet='Street';
        testAccount22.BillingCountry='India';
        testAccount22.BillingPostalCode='Postal code';
        testAccount22.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount22.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accntInsertList.add(testAccount22);
        //insert testAccount;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent1);
        //insert parent1;
        if(accntInsertList.size() > 0){
            insert accntInsertList;
        }
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@spamok.com';
        con.AccountId=testAccount22.Id;
        con.MailingCountry='USA';
        insert con;

        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;

         PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        insert cr2;

        
         PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=testAccount22.Id;
        acr.PRM_Relationship_Id__c = cr2.Id;
        acr.PRM_Contact_Id__c=con.Id;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acr.PRM_Source_Agent__c='Partner Invite';
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Status_Reason_Txt__c = 'Test';
        acr.PRM_CampaignId__c=null;
        insert acr;
        
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount22.id;
        insert coreAccnt;
        
        Test.startTest();
        
        
        
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        //pb.Name = 'Points View';
        pb.Name ='Points Accruals View';
        pb.PRM_Channel_Program_Id__c = cpIPATest.id;
        //pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        benifitInsertList.add(pb);
        //insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        //pb1.Name = 'Points Redeem';
        pb1.Name ='Points Redemption';
        pb1.PRM_Channel_Program_Id__c = cpIPATest.id;
        //pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        //pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        pb1.PRM_Account_Type_Nm__c='Core_Partner_Account_Group';
        benifitInsertList.add(pb1);
        //insert pb1;
        
        if(benifitInsertList.size() > 0){
            insert benifitInsertList;
        }
        
        List<PRM_VXBnftMatrix__c>benMatrInsertList = new List<PRM_VXBnftMatrix__c>();
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        benMatrInsertList.add(bem1);
        //insert bem1;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        bem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        benMatrInsertList.add(bem);
        //insert bem;
        
        if(benMatrInsertList.size() > 0){
            insert benMatrInsertList;
        }
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount22.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        List<PRM_AccountBenefitAssociation__c> abaUpdateList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = parent1.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb1.id;
        aba1.PRM_Status_Nm__c = 'Active';
        aba1.PRM_Status_Reason_Txt__c = 'Test';
        //insert aba1;
        abaList.add(aba1);
        
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = testAccount22.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c = 'Test';
        
        abaList.add(aba);
        //insert aba; 
        insert abaList;
        
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c = 'test';
        abaUpdateList.add(aba1);
        
        
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'test';
        abaUpdateList.add(aba);
        
        update abaUpdateList;
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Points View';
        ent.Core_Display_Name__c = 'Points View';
        ent.Core_IsActive__c = true;
        corEntitInertList.add(ent);
        
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Points Redeem';
        ent1.Core_Display_Name__c = 'Points Manager';
        ent1.Core_IsActive__c = true;
        corEntitInertList.add(ent1);
        
        
        
        if(corEntitInertList.size() > 0){
            insert corEntitInertList;
        }
        
        Core_Contact_Entitlement__c coreCon = new Core_Contact_Entitlement__c();
        coreCon.Core_Contact_Id__c = con.id;
        coreCon.Core_Entitlement_Id__c = ent.id;
        coreCon.Core_Status__c = 'Complete';
        coreCon.Core_Selected__c = true;
        corConEntitInertList.add(coreCon);
        
        
        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = con.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Status__c = 'Pending';
        coreCon1.Core_Selected__c = false;
        corConEntitInertList.add(coreCon1);
        
        
        if(corConEntitInertList.size() > 0){
            insert corConEntitInertList;
        }
        
        
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        profileQues.PRM_Question_Display_Txt__c ='Points Not eligible';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = testAccount22.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
        response.PRM_Response_Txt__c='false';
        insert response;
        
        update response;
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        insert profileQues1;
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns1;
        
        PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c();
        response1.PRM_Account_Id__c = testaccount22.Id;
        response1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response1.PRM_Profile_Answer_Id__c = profileAns1.Id;
        response1.PRM_Response_Txt__c='true';
        insert response1;
        
        
        
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        PRM_Registration_Request__c regReq = [Select Id,PRM_First_Name__c,PRM_Profile_Response__c from PRM_Registration_Request__c];
        Account act = testaccount22;
        Contact cont = con;
        regList.add(regReq);
        accList.add(act);
        conList.add(cont); 
        
        map<id,PRM_Profile_Responses__c> map1= new map<id,PRM_Profile_Responses__c>();       
        map1.put(response.id,response);
        list<PRM_Profile_Responses__c> l1=new list<PRM_Profile_Responses__c>();
        l1.add(response1);
        PRM_profileResponse.createResponse(regList, accList, conList,true);
        // PRM_profileResponse.OPIDToLoctionRollDown(l1,map1);
        PRM_profileResponse.activateInactiveBenefit(l1,map1);
        PRM_profileResponse.activateInactiveBenefit(l1,null);
        
        System.assertEquals(regReq.PRM_First_Name__c, 'Test Request','Value does not match');
        System.assertEquals(aba1.PRM_Status_Nm__c, 'Inactive',True);
        test.stopTest();   
        
    }
    
    
    static testMethod void OPIDToLoctionRollDown(){
        
        Test.startTest();
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Core_Entitlement__c> corEntitInertList = new List<Core_Entitlement__c>();
        List<Core_Contact_Entitlement__c>corConEntitInertList = new List<Core_Contact_Entitlement__c>();
        List<Account> accntInsertList = new List<Account>();
        List<PRM_PartnerBenefit__c>benifitInsertList = new List<PRM_PartnerBenefit__c>();
        List<Core_Account_Group_Member__c>LocationList = new List<Core_Account_Group_Member__c>();
        set<id> OPIDSet = new set<id>();
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent1);
        OPIDSet.add(parent1.id);
        
        Account parent4 = new Account();
        parent4.RecordTypeId = OpidAccRecordTypeId;
        parent4.Name='Cello Ltd-PARENT4';
        parent4.BillingCity='New City';
        parent4.BillingStreet='New Street';
        parent4.BillingCountry='India';
        parent4.BillingPostalCode='999999';
        parent4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent4);
        OPIDSet.add(parent4.id);
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accntInsertList.add(testAccount);
        
        Account IntelAccount = new Account();
        IntelAccount.RecordTypeId = recordTypeIdAccount;
        IntelAccount.Name='John Wick2';
        IntelAccount.BillingCity='City';
        IntelAccount.BillingStreet='Street';
        IntelAccount.BillingCountry='India';
        IntelAccount.BillingPostalCode='Postal code';
        IntelAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        IntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accntInsertList.add(IntelAccount);
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Cello Ltd - Version2';
        parent2.BillingCity='New City';
        parent2.BillingStreet='New Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='888888';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent2);
        OPIDSet.add(parent2.id);
        
        Account parent3 = new Account();
        parent3.RecordTypeId = OpidAccRecordTypeId;
        parent3.Name='Cello Ltd - Version3';
        parent3.BillingCity='New City';
        parent3.BillingStreet='New Street';
        parent3.BillingCountry='India';
        parent3.BillingPostalCode='8888883';
        parent3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent3);
        OPIDSet.add(parent3.id);
        
        Account acc2 = new Account();
        acc2.Name='Intel Account - Two';
        acc2.RecordTypeId = recordTypeIdAccount;
        acc2.Core_Account_Type__c ='Distributor';
        acc2.Industry='Agriculture';
        acc2.BillingCity='Chennai';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor,New Road';
        acc2.BillingPostalCode='110037';
        acc2.BillingStateCode='TN';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accntInsertList.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name='Intel Account - Three';
        acc3.RecordTypeId = recordTypeIdAccount;
        acc3.Core_Account_Type__c ='Distributor';
        acc3.Industry='Agriculture';
        acc3.BillingCity='Chennai';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='4th Floor,New Road';
        acc3.BillingPostalCode='110037';
        acc3.BillingStateCode='TN';
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accntInsertList.add(acc3);
        
        insert accntInsertList;
        set<id> accIdSet =  new set<id>();
        for(account accList: accntInsertList){
            if(accList.RecordTypeId == OpidAccRecordTypeId ){
                accIdSet.add(accList.id);
            }
        }
        list<account> displayAccounts  = new List<account>();
        for(account getAccounts : [select id,name from account where id in :accIdSet]){
            displayAccounts.add(getAccounts);
        }
        String responseQuestions = System.Label.PRM_Response_Questions;
        Set<String> responseQuestionsIdSet = new Set<String>();
        
        for(String str: responseQuestions.split(';')){
            responseQuestionsIdSet.add(str);
        }
        
        Contact con = new contact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samueldsaiodada@spamok.com';
        con.AccountId=testAccount.Id;
        con.MailingCountry='USA';
        insert con;
        
        list<Core_Account_Group_Member__c>  listCag =  new list<Core_Account_Group_Member__c>() ; 
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = parent1.Id;
        agm.Core_Intel_Account_Id__c = testAccount.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        listCag.add(agm);
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = parent2.Id;
        agm2.Core_Intel_Account_Id__c = acc2.Id;
        agm2.Core_Inactive_Ind__c = false;
        listCag.add(agm2);
        
        Core_Account_Group_Member__c agm3 = new Core_Account_Group_Member__c();
        agm3.Core_Partner_Account_Id__c = parent4.Id;
        agm3.Core_Intel_Account_Id__c = IntelAccount.Id;
        agm3.Core_Inactive_Ind__c = false;
        listCag.add(agm3);
        
        insert listCag;
        
        //input has both opid and loc. But we will get output only for OPID.
        for(Core_Account_Group_Member__c Check : [SELECT Name,Core_Partner_Account_Id__c,Core_Inactive_Ind__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c  WHERE Core_Partner_Account_Id__c IN:accIdSet AND Core_Inactive_Ind__c=false AND Core_Intel_Partner_Alliance_PartnerGroup__c=true ]){
            LocationList.add(check);
        }
        
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        List<PRM_AccountChannelMembership__c> listAcm = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=parent1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Status_Reason_Txt__c = 'test';
        acctChnlMem.PRM_Partner_Role__c='Distributor';
        listAcm.add(acctChnlMem);
        
        PRM_AccountChannelMembership__c acctChnlMem1 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem1.PRM_Account_Id__c=parent2.Id;
        acctChnlMem1.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem1.PRM_Status_Nm__c = 'Approved';
        acctChnlMem1.PRM_Partner_Role__c='Distributor';
        acctChnlMem1.PRM_Status_Reason_Txt__c = 'test';
        listAcm.add(acctChnlMem1);
        
        PRM_AccountChannelMembership__c acctChnlMem12 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem12.PRM_Account_Id__c=parent3.Id;
        acctChnlMem12.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem12.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem12.PRM_Status_Nm__c = 'Approved';
        acctChnlMem12.PRM_Status_Reason_Txt__c = 'test';
        acctChnlMem12.PRM_Partner_Role__c='Distributor';
        listAcm.add(acctChnlMem12);
        
        PRM_AccountChannelMembership__c acctChnlMem13 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem13.PRM_Account_Id__c=acc2.Id;
        acctChnlMem13.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem13.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem13.PRM_Status_Nm__c = 'Approved';
        acctChnlMem13.PRM_Status_Reason_Txt__c = 'test';
        acctChnlMem13.PRM_Partner_Role__c='Distributor';
        listAcm.add(acctChnlMem13);
        
        PRM_AccountChannelMembership__c acctChnlMem14 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem14.PRM_Account_Id__c=testAccount.Id;
        acctChnlMem14.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem14.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem14.PRM_Status_Nm__c = 'Approved';
        acctChnlMem14.PRM_Status_Reason_Txt__c = 'test';
        acctChnlMem14.PRM_Partner_Role__c='Distributor';
        listAcm.add(acctChnlMem14);
        
        PRM_AccountChannelMembership__c acctChnlMem15 = new PRM_AccountChannelMembership__c(); 
        acctChnlMem15.PRM_Account_Id__c=IntelAccount.Id;
        acctChnlMem15.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem15.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem15.PRM_Status_Nm__c = 'Approved';
        acctChnlMem15.PRM_Status_Reason_Txt__c = 'test';
        acctChnlMem15.PRM_Partner_Role__c='Distributor';
        listAcm.add(acctChnlMem15);
        
        insert listAcm;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        //pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cpIPATest.Id;
        insert pt;
        
        list<PRM_Profile_Questions__c> listQuestion = new list<PRM_Profile_Questions__c>();
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cpIPATest.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq.PRM_Question_Type_Nm__c = 'Text';
        pq.PRM_Question_Cd__c='PRM_Point_Not_Eligible' ;
        pq.PRM_Question_Display_Txt__c = 'Points Not eligible';
        pq.PRM_InActive_Ind__c = false;
        listQuestion.add(pq);
        
        PRM_Profile_Questions__c pq1 = new PRM_Profile_Questions__c();
        pq1.PRM_Channel_Program_Id__c = cpIPATest.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq1.PRM_Question_Type_Nm__c = 'Text';
        pq1.PRM_Question_Cd__c='PRM_Opt_In' ;
        pq1.PRM_Question_Display_Txt__c = 'Points Opt-in';
        pq1.PRM_InActive_Ind__c = false;
        listQuestion.add(pq1);
        
        PRM_Profile_Questions__c pq3 = new PRM_Profile_Questions__c();
        pq3.PRM_Channel_Program_Id__c = cpIPATest.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq3.PRM_Question_Type_Nm__c = 'Text';
        pq3.PRM_Question_Cd__c='PRM_Component_point' ;
        pq3.PRM_Question_Display_Txt__c = 'Component Point earning excluded';
        pq3.PRM_InActive_Ind__c = false;
        listQuestion.add(pq3);
        
        insert listQuestion;
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Profile_Questions_Id__c = pq.Id;
        insert pa;
        List<PRM_Profile_Responses__c> prList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList1 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList2 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList3 = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c pr11 = new PRM_Profile_Responses__c();
        pr11.PRM_Account_Id__c = parent2.Id;
        pr11.PRM_Profile_Answer_Id__c = pa.Id;
        pr11.PRM_Profile_Questions_Id__c = pq3.Id;
        pr11.PRM_Response_Txt__c='true';
        pr11.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList.add(pr11);  
        prList2.add(pr11);
        
        /* PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
pr.PRM_Account_Id__c = parent1.Id;
pr.PRM_Profile_Answer_Id__c = pa.Id;
pr.PRM_Profile_Questions_Id__c = pq.Id;
pr.PRM_Response_Txt__c='true';
pr.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
prList.add(pr);*/
        //          prList2.add(pr);
        
        PRM_Profile_Responses__c pr0 = new PRM_Profile_Responses__c();
        pr0.PRM_Account_Id__c = parent1.Id;
        pr0.PRM_Profile_Answer_Id__c = pa.Id;
        pr0.PRM_Profile_Questions_Id__c = pq1.Id;
        pr0.PRM_Response_Txt__c='true';
        pr0.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList.add(pr0);
        //           prList2.add(pr0);
        
        /* PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
pr2.PRM_Account_Id__c = testAccount.Id;
pr2.PRM_Profile_Answer_Id__c = pa.Id;
pr2.PRM_Profile_Questions_Id__c = pq.Id;
pr2.PRM_Response_Txt__c='true';
pr2.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
prList.add(pr2);
*/
        
        PRM_Profile_Responses__c pr3 = new PRM_Profile_Responses__c();
        pr3.PRM_Account_Id__c = acc2.Id;
        pr3.PRM_Profile_Answer_Id__c = pa.Id;
        pr3.PRM_Profile_Questions_Id__c = pq.Id;
        pr3.PRM_Response_Txt__c='true';
        pr3.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList.add(pr3);
        
        PRM_Profile_Responses__c pr4 = new PRM_Profile_Responses__c();
        pr4.PRM_Account_Id__c = parent4.Id;
        pr4.PRM_Profile_Answer_Id__c = pa.Id;
        pr4.PRM_Profile_Questions_Id__c = pq.Id;
        pr4.PRM_Response_Txt__c='true';
        pr4.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList.add(pr4);
        prList2.add(pr4);
        
        PRM_Profile_Responses__c pr5 = new PRM_Profile_Responses__c();
        pr5.PRM_Account_Id__c = acc2.Id;
        pr5.PRM_Profile_Answer_Id__c = pa.Id;
        pr5.PRM_Profile_Questions_Id__c = pq3.Id;
        pr5.PRM_Response_Txt__c='false';
        pr5.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList1.add(pr5);
        
        insert prList;    
        
        // delete prList2;
        
        for(PRM_Profile_Responses__c response : [select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c, PRM_View_History__c,
                                                 PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId  from PRM_Profile_Responses__c
                                                 where PRM_Account_Id__c in :accIdSet and PRM_Question_Display_Text__c in:responseQuestionsIdSet order by  CreatedDate desc ]){
                                                     
                                                 }
        
        map<id,PRM_Profile_Responses__c> oldmap = new map<id,PRM_Profile_Responses__c>();
        oldmap.put(pr5.id,pr5);
        
        // pr.PRM_Response_Txt__c='false';
        // pr.PRM_Reason_Text__c='Updated Record';
        
        // update pr;
        try{
            PRM_ProfileResponse.OPIDToLoctionRollDown(prList3,null);
            PRM_ProfileResponse.OPIDToLoctionRollDown(prList1,null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        test.stopTest();   
    }
    
    static testMethod void testPointsCalculation(){
        
        Test.startTest();
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Account> accntInsertList = new List<Account>();
        List<Core_Account_Group_Member__c>LocationList = new List<Core_Account_Group_Member__c>();
        set<id> OPIDSet = new set<id>();
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent1);
        OPIDSet.add(parent1.id);
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Cello Ltdqwe';
        parent2.BillingCity='New City ff';
        parent2.BillingStreet='New Street new';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='999991';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent2);
        OPIDSet.add(parent2.id); 
        
        Account parent3 = new Account();
        parent3.RecordTypeId = OpidAccRecordTypeId;
        parent3.Name='Cello Ltdqwe';
        parent3.BillingCity='New City ff';
        parent3.BillingStreet='New Street new';
        parent3.BillingCountry='India';
        parent3.BillingPostalCode='999991';
        parent3.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent3);
        OPIDSet.add(parent3.id); 
        
        Account parent4 = new Account();
        parent4.RecordTypeId = OpidAccRecordTypeId;
        parent4.Name='Cello Ltdqw11e';
        parent4.BillingCity='New City ff1';
        parent4.BillingStreet='New Street new1';
        parent4.BillingCountry='India';
        parent4.BillingPostalCode='999993';
        parent4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent4);
        OPIDSet.add(parent4.id);
        
        Account parent5 = new Account();
        parent5.RecordTypeId = OpidAccRecordTypeId;
        parent5.Name='Cello Ltdqw11e';
        parent5.BillingCity='New City ff1';
        parent5.BillingStreet='New Street new1';
        parent5.BillingCountry='India';
        parent5.BillingPostalCode='999993';
        parent5.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accntInsertList.add(parent5);
        OPIDSet.add(parent5.id);
        
        Account IntelAccount = new Account();
        IntelAccount.RecordTypeId = recordTypeIdAccount;
        IntelAccount.Name='John Wick2';
        IntelAccount.BillingCity='City';
        IntelAccount.BillingStreet='Street';
        IntelAccount.BillingCountry='India';
        IntelAccount.BillingPostalCode='Postal code';
        IntelAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        IntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accntInsertList.add(IntelAccount);
        
        insert accntInsertList;
        
        list<Core_Account_Group_Member__c>  listCag =  new list<Core_Account_Group_Member__c>() ; 
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = parent1.Id;
        agm.Core_Intel_Account_Id__c = IntelAccount.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        listCag.add(agm); 
        
        insert listCag;
        
        Contact con = new Contact();
        con.firstname='Partner';
        con.lastname='Contact1';
        con.AccountId=IntelAccount.Id;
        con.Email='dellco1234@dell.com';
        con.MailingCountry='USA';
        insert con;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_PartnerAgreement__c p=new PRM_PartnerAgreement__c();
        p.Name='Intel Partner Alliance Terms & Condition';
        p.PRM_InActive_Ind__c=false;
        p.PRM_Agreement_Cd__c='IPA_TANDC';
        p.PRM_Channel_Program_Id__c=cp.id;
        insert p;
        List<PRM_AccountLegalAgreemntAssociation__c> alaList = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c alaa = new PRM_AccountLegalAgreemntAssociation__c();
        alaa.PRM_Account_Id__c = IntelAccount.Id;
        alaa.PRM_Partner_Agreement_Id__c = p.Id;
        alaa.PRM_Contact__c = con.Id;
        alaa.PRM_InActive_Ind__c=FALSE;
        alaa.PRM_Agreement_Sign_Dt__c=system.now();
        alaList.add(alaa);
        PRM_AccountLegalAgreemntAssociation__c ala1 = new PRM_AccountLegalAgreemntAssociation__c();
        ala1.PRM_Account_Id__c = parent1.Id;
        ala1.PRM_Partner_Agreement_Id__c = p.Id;
        ala1.PRM_Contact__c = con.Id;
        ala1.PRM_InActive_Ind__c=FALSE;
        ala1.PRM_Agreement_Sign_Dt__c=system.now();
        alaList.add(ala1);
        
        PRM_AccountLegalAgreemntAssociation__c ala2 = new PRM_AccountLegalAgreemntAssociation__c();
        ala2.PRM_Account_Id__c = parent3.Id;
        ala2.PRM_Partner_Agreement_Id__c = p.Id;
        ala2.PRM_Contact__c = con.Id;
        ala2.PRM_InActive_Ind__c=FALSE;
        ala2.PRM_Agreement_Sign_Dt__c=system.now();
        alaList.add(ala2);
        
        insert alaList;
        
        
        list<PRM_Profile_Questions__c> listQuestion = new list<PRM_Profile_Questions__c>();
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        //pq.PRM_Channel_Program_Id__c = cpIPATest.Id;
        pq.PRM_Question_Type_Nm__c = 'Text';
        pq.PRM_Question_Cd__c='PRM_Point_Not_Eligible' ;
        pq.PRM_Question_Display_Txt__c = 'Points Not eligible';
        pq.PRM_InActive_Ind__c = false;
        listQuestion.add(pq);
        PRM_Profile_Questions__c pqopt = new PRM_Profile_Questions__c();
        // pqopt.PRM_Channel_Program_Id__c = cpIPATest.Id;
        pqopt.PRM_Question_Type_Nm__c = 'Text';
        pqopt.PRM_Question_Cd__c='PRM_Opt_In' ;
        // pqopt.PRM_Account_Id__c = parent1.ID;
        pqopt.PRM_Question_Display_Txt__c = 'Points Opt In';
        pqopt.PRM_InActive_Ind__c = false;
        listQuestion.add(pqopt);
        PRM_Profile_Questions__c pqStatus = new PRM_Profile_Questions__c();
        //pq.PRM_Channel_Program_Id__c = cpIPATest.Id;
        pqStatus.PRM_Question_Type_Nm__c = 'Text';
        pqStatus.PRM_Question_Cd__c='PRM_Status' ;
        pqStatus.PRM_Question_Display_Txt__c = 'Point Status';
        pqStatus.PRM_InActive_Ind__c = false;
        listQuestion.add(pqStatus);
        PRM_Profile_Questions__c pqStatusDate = new PRM_Profile_Questions__c();
        //pq.PRM_Channel_Program_Id__c = cpIPATest.Id;
        pqStatusDate.PRM_Question_Type_Nm__c = 'Text';
        pqStatusDate.PRM_Question_Cd__c='PRM_Status_date' ;
        pqStatusDate.PRM_Question_Display_Txt__c = 'Point Status Date';
        pqStatusDate.PRM_InActive_Ind__c = false;
        listQuestion.add(pqStatusDate);
        
        
        insert listQuestion;
        
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Profile_Questions_Id__c = pqopt.Id;
        insert pa;
        List<PRM_Profile_Responses__c> prList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList2 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList3 = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c pr1 = new PRM_Profile_Responses__c();
        pr1.PRM_Account_Id__c = IntelAccount.Id;
        pr1.PRM_Profile_Answer_Id__c = pa.Id;
        pr1.PRM_Profile_Questions_Id__c = pqopt.Id;
        pr1.PRM_Response_Txt__c='true';
        pr1.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList3.add(pr1);
        
        PRM_Profile_Responses__c prlst = new PRM_Profile_Responses__c();
        prlst.PRM_Account_Id__c = parent5.Id;
        prlst.PRM_Profile_Answer_Id__c = pa.Id;
        prlst.PRM_Profile_Questions_Id__c = pqopt.Id;
        prlst.PRM_Response_Txt__c='false';
        prlst.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList3.add(prlst);  
        
        PRM_Profile_Responses__c prnew = new PRM_Profile_Responses__c();
        prnew.PRM_Account_Id__c = parent1.Id;
        prnew.PRM_Profile_Answer_Id__c = pa.Id;
        prnew.PRM_Profile_Questions_Id__c = pqopt.Id;
        prnew.PRM_Response_Txt__c='true';
        prnew.PRM_Reason_Text__c='tst';
        prList3.add(prnew);
        
        PRM_Profile_Responses__c pr11 = new PRM_Profile_Responses__c();
        pr11.PRM_Account_Id__c = parent2.Id;
        pr11.PRM_Profile_Answer_Id__c = pa.Id;
        pr11.PRM_Profile_Questions_Id__c = pq.Id;
        pr11.PRM_Response_Txt__c='true';
        pr11.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList3.add(pr11);  
        
        PRM_Profile_Responses__c pr12 = new PRM_Profile_Responses__c();
        pr12.PRM_Account_Id__c = parent3.Id;
        pr12.PRM_Profile_Answer_Id__c = pa.Id;
        pr12.PRM_Profile_Questions_Id__c = pqopt.Id;
        pr12.PRM_Response_Txt__c='true';
        pr12.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList3.add(pr12);
        
        PRM_Profile_Responses__c pr13 = new PRM_Profile_Responses__c();
        pr13.PRM_Account_Id__c = parent4.Id;
        pr13.PRM_Profile_Answer_Id__c = pa.Id;
        pr13.PRM_Profile_Questions_Id__c = pqopt.Id;
        pr13.PRM_Response_Txt__c='true';
        pr13.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
        prList3.add(pr13);  
        
        /* PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
pr2.PRM_Account_Id__c = IntelAccount.Id;
pr2.PRM_Profile_Answer_Id__c = pa.Id;
pr2.PRM_Profile_Questions_Id__c = pq.Id;
pr2.PRM_Response_Txt__c='true';
pr2.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
prList.add(pr2);
PRM_Profile_Responses__c pr3 = new PRM_Profile_Responses__c();
pr3.PRM_Account_Id__c = IntelAccount.Id;
pr3.PRM_Profile_Answer_Id__c = pa.Id;
pr3.PRM_Profile_Questions_Id__c = pqopt.Id;
pr3.PRM_Response_Txt__c='true';
pr3.PRM_Reason_Text__c='New Roll Up - testing- During DSU222222222222222222';
prList.add(pr3); */
        
        PRM_Profile_Responses__c pr4 = new PRM_Profile_Responses__c();
        pr4.PRM_Account_Id__c = parent1.Id;
        pr4.PRM_Profile_Answer_Id__c = pa.Id;
        pr4.PRM_Profile_Questions_Id__c = pqStatusDate.Id;
        pr4.PRM_Response_Txt__c='22/09/2022';
        pr4.PRM_Reason_Text__c='status date';
        prList.add(pr4); 
        
        PRM_Profile_Responses__c pr5 = new PRM_Profile_Responses__c();
        pr5.PRM_Account_Id__c = parent1.Id;
        pr5.PRM_Profile_Answer_Id__c = pa.Id;
        pr5.PRM_Profile_Questions_Id__c = pqStatus.Id;
        pr5.PRM_Response_Txt__c='Eligible';
        pr5.PRM_Reason_Text__c='status';
        prList.add(pr5);
        
        PRM_Profile_Responses__c prNE1 = new PRM_Profile_Responses__c();
        prNE1.PRM_Account_Id__c = parent2.Id;
        prNE1.PRM_Profile_Answer_Id__c = pa.Id;
        prNE1.PRM_Profile_Questions_Id__c = pqStatusDate.Id;
        prNE1.PRM_Response_Txt__c='22/09/2022';
        prNE1.PRM_Reason_Text__c='status date';
        prList.add(prNE1); 
        
        PRM_Profile_Responses__c prNE2 = new PRM_Profile_Responses__c();
        prNE2.PRM_Account_Id__c = parent2.Id;
        prNE2.PRM_Profile_Answer_Id__c = pa.Id;
        prNE2.PRM_Profile_Questions_Id__c = pqStatus.Id;
        prNE2.PRM_Response_Txt__c='Eligible';
        prNE2.PRM_Reason_Text__c='status';
        prList.add(prNE2); 
        
        PRM_Profile_Responses__c prNE3 = new PRM_Profile_Responses__c();
        prNE3.PRM_Account_Id__c = parent4.Id;
        prNE3.PRM_Profile_Answer_Id__c = pa.Id;
        prNE3.PRM_Profile_Questions_Id__c = pqStatusDate.Id;
        prNE3.PRM_Response_Txt__c='22/09/2022';
        prNE3.PRM_Reason_Text__c='status date';
        prList.add(prNE3); 
        
        PRM_Profile_Responses__c prNE4 = new PRM_Profile_Responses__c();
        prNE4.PRM_Account_Id__c = parent4.Id;
        prNE4.PRM_Profile_Answer_Id__c = pa.Id;
        prNE4.PRM_Profile_Questions_Id__c = pqStatus.Id;
        prNE4.PRM_Response_Txt__c='Not Eligible';
        prNE4.PRM_Reason_Text__c='status';
        prList.add(prNE4); 
        
        PRM_Profile_Responses__c prNE31 = new PRM_Profile_Responses__c();
        prNE31.PRM_Account_Id__c = parent5.Id;
        prNE31.PRM_Profile_Answer_Id__c = pa.Id;
        prNE31.PRM_Profile_Questions_Id__c = pqStatusDate.Id;
        prNE31.PRM_Response_Txt__c='22/09/2022';
        prNE31.PRM_Reason_Text__c='status date';
        prList.add(prNE31); 
        
        PRM_Profile_Responses__c prNE41 = new PRM_Profile_Responses__c();
        prNE41.PRM_Account_Id__c = parent5.Id;
        prNE41.PRM_Profile_Answer_Id__c = pa.Id;
        prNE41.PRM_Profile_Questions_Id__c = pqStatus.Id;
        prNE41.PRM_Response_Txt__c='Eligible';
        prNE41.PRM_Reason_Text__c='status';
        prList.add(prNE41);   
        insert prlist;
        
        insert prList3;    
        PRM_ProfileResponse.pointsCalculation(prList3,null);
        PRM_ProfileResponse.activateInactiveBenefit(prList3,null);  
        test.stopTest();   
    }
    public static testmethod void OPIDToLoctionRollDown_IPARTest(){
        Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
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
        newAccount.Name='Test Intel Account';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount.Core_Business_Party_Id__c = '9456456' ; //TWC729-1292
        insert newAccount;

        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_AccountChannelMembership__c> acmList= new List<PRM_AccountChannelMembership__c> ();
        PRM_AccountChannelMembership__c acctChnlMemTest=new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=newAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cp.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'test';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=opidAcc.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cp.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'test';
        acmList.add(acctChnlMemTest2);
        insert acmList;

         Contact con = new Contact();
        con.firstname='Partner';
        con.lastname='Contact1';
        con.AccountId=newAccount.Id;
        con.Email='dellco1234@dell.com';
        con.MailingCountry='USA';
        insert con;

        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        insert cr2;

        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = cr2.Id;
        acr.PRM_Contact_Id__c=con.Id;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acr.PRM_Source_Agent__c='Partner Invite';
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_Status_Reason_Txt__c = 'test';
        acr.PRM_CampaignId__c=null;
        insert acr;
        

        Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
        cag.Core_Intel_Account_Id__c= newAccount.id;
        cag.Core_Partner_Account_Id__c = opidAcc.id;
        cag.Core_Inactive_Ind__c = false;
        insert cag;

        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert pb;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opidAcc.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'inactivated';
        insert aba;
        List<PRM_IPAMembership_Attributes__c> ipaMemList = new List<PRM_IPAMembership_Attributes__c>();
        PRM_IPAMembership_Attributes__c ipaMem = new PRM_IPAMembership_Attributes__c();
        ipaMem.PRM_Account_Id__c = opidAcc.Id;
        ipaMem.RecordTypeId = opidIpaMemAttrRecordId;
        ipaMem.PRM_Registration_Source_Txt__c = 'Web';
        ipaMem.PRM_Points_Opt_in_Ind__c =true;
        ipaMem.PRM_Points_Opt_in_Dt__c = System.today();
        ipaMem.PRM_Point_Status_Txt__c = 'Active';
        ipaMem.PRM_Point_Status_Dt__c = System.today();
        insert ipaMem;
        
        PRM_IPAMembership_Attributes__c ipaMemOpid = new PRM_IPAMembership_Attributes__c();
        ipaMemOpid.PRM_Account_Id__c = newAccount.id;
        ipaMemOpid.RecordTypeId = inteIpaMemAttrRecordId;
        ipaMemOpid.PRM_Registration_Source_Txt__c = 'Web';
        ipaMemOpid.PRM_Points_Not_Eligible_Ind__c =true ;
        ipaMemOpid.PRM_Points_Not_Eligible_Reason_Txt__c ='Test';
        ipaMemOpid.PRM_Points_Not_Eligible_Dt__c = System.today();
        ipaMemOpid.PRM_Point_Status_Txt__c = 'Not Eligible';
        ipaMemOpid.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMemOpid);
        Insert ipaMemList;

        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Points Redeem';
        ent1.Core_Display_Name__c = 'Points Manager';
        ent1.Core_IsActive__c = true;
        insert ent1;

        Core_Contact_Entitlement__c coreCon1 = new Core_Contact_Entitlement__c();
        coreCon1.Core_Contact_Id__c = con.id;
        coreCon1.Core_Entitlement_Id__c = ent1.id;
        coreCon1.Core_Status__c = 'Complete';
        coreCon1.Core_Selected__c = false;
        insert coreCon1;

        Set<Id> contactIdsForCompPCR = new Set<Id>();
        contactIdsForCompPCR.add(con.id);
        Set<Id> abaAccIdsUpdated = new Set<Id>();
        abaAccIdsUpdated.add(opidAcc.id);
        Set<Id> inactivateBenefitAccIds = new Set<Id>();
        inactivateBenefitAccIds.add(opidAcc.id);
        Set<Id> activateBenefitAccIds = new Set<Id>();
        

        Test.startTest();
        PRM_ProfileResponse.OPIDToLoctionRollDown_IPAR(ipaMemList, null);
        PRM_ProfileResponse.activateInactiveBenefit_IPAR(ipaMemList,null);
        Test.stopTest();
        
    }
    
    
    
}