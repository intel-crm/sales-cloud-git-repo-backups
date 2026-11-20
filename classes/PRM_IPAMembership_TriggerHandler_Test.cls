@isTest
public class PRM_IPAMembership_TriggerHandler_Test {
    @testSetup
    public static void setupData(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<account> acclist1  = new List<account>();
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        acclist1.add(opidAcc) ;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Test Intel Account';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount.Core_Business_Party_Id__c = '9456456' ; //TWC729-1292
        
        acclist1.add(newAccount);
        insert acclist1;
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert pb;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opidAcc.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
        insert aba;
    }
    @isTest
    public static void test1(){
        Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        Account newAccount = [Select id,name from account where Name ='Test Intel Account' limit 1];
        Account opidAcc = [Select id,name from Account where name ='vista' limit 1];
        List<PRM_IPAMembership_Attributes__c> ipaMemList = new List<PRM_IPAMembership_Attributes__c>();
        PRM_IPAMembership_Attributes__c ipaMem = new PRM_IPAMembership_Attributes__c();
        ipaMem.PRM_Account_Id__c = newAccount.Id;
        ipaMem.RecordTypeId = inteIpaMemAttrRecordId;
        ipaMem.PRM_Registration_Source_Txt__c = 'Web';
        ipaMem.PRM_Points_Opt_in_Ind__c =true;
        ipaMem.PRM_Points_Opt_in_Dt__c = System.today();
        ipaMem.PRM_Point_Status_Txt__c = 'Active';
        ipaMem.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMem);
        
        PRM_IPAMembership_Attributes__c ipaMemOpid = new PRM_IPAMembership_Attributes__c();
        ipaMemOpid.PRM_Account_Id__c = opidAcc.Id;
        ipaMemOpid.RecordTypeId = opidIpaMemAttrRecordId;
        ipaMemOpid.PRM_Registration_Source_Txt__c = 'Web';
        ipaMemOpid.PRM_Points_Not_Eligible_Ind__c =true ;
        ipaMemOpid.PRM_Points_Not_Eligible_Dt__c = System.today();
        ipaMemOpid.PRM_Point_Status_Txt__c = 'Not Eligible';
        ipaMemOpid.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMemOpid);
        
        Test.startTest();
        Insert ipaMemList;
        Test.stopTest();
        
    }

}