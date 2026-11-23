@isTest
public class PRM_ABANotifMsgProcessBuilderTest {
	@testSetup
    private static void InsertABARec(){
        
        Id opidAccRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        Account opidAcc1 = new Account();//Account
        opidAcc1.RecordTypeId = opidAccRecordType;
        opidAcc1.Name='Test OPID Account1';
        opidAcc1.BillingCity='City';
        opidAcc1.BillingStreet='Street';
        opidAcc1.BillingCountry='India';
        opidAcc1.BillingPostalCode='Postal code';
        opidAcc1.Core_IPA_Partner_Role__c = 'Distributor';	
        opidAcc1.Core_CNDA_Number__c='';
        opidAcc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert opidAcc1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Gold';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = opidAcc1.Id;
        acm.PRM_Channel_Program_Id__c = cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        acm.PRM_Partner_Role__c = 'Manufacturer';
        acm.PRM_Status_Nm__c = 'Approved';
        insert acm;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Solution Marketplace Basic Profile';
        pb.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb.PRM_InActive_Ind__c = false;
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        pb.PRM_Benefit_Type_Nm__c = 'Marketing';
        pb.PRM_Channel_Program_Id__c = cp.Id;
        
        insert pb;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c();
        bm.PRM_Partner_Benefit_Id__c = pb.Id;
        bm.PRM_Channel_Program_Id__c = cp.Id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        bm.PRM_Approval_Type_Nm__c = 'Manual';
        bm.PRM_IsActive_Ind__c = true;
        bm.PRM_Partner_Role_Nm__c = 'Manufacturer';
        insert bm;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        	aba.PRM_Account_Id__c = opidAcc1.Id;
            aba.PRM_Partner_Benefit_Id__c = pb.Id;
            aba.PRM_Status_Nm__c = 'Active';
        
            insert aba;
    }
    
    @isTest
    private static void checkProcessFired(){
        Integer actualResult = [Select count() from PRM_AccountBenefitAssociation__c];
        System.assertEquals(1, actualResult);
    }
        
}