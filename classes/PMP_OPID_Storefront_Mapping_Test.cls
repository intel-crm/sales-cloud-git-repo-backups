/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_OPID_Storefront_Mapping
* Description : API returnining publised storefront id
* Version     : 1.0 
* Created Date: Aug-2022
* Modification Log :  
* Created By  : DINESH MENGADE
********************************************************************************************************************************************************************************************************/
@isTest
public class PMP_OPID_Storefront_Mapping_Test {
    
    @isTest
    public static void getPartnerDetailsTest(){
        // Account, OPID, Contact, Contact Entilement, OPID Account Benefit, MPI Relationships
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
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newPagAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Reason_Txt__c='Test';
        insert acm1;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Solutions Marketplace Basic Profile';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb1.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb1;
        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Solutions Marketplace Basic Access';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb2.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb2;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newPagAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
        insert aba;
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb2.id;
        aba1.PRM_Status_Nm__c = 'Active';
        aba1.PRM_Status_Reason_Txt__c='Test';
        insert aba1;
        
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'India';
        company.PMP_Company_Lifecycle_Status_Nm__c ='published';
        company.PMP_Benefit_Update_Ind__c = false;
        company.PMP_Is_Published_Ind__c = true;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        insert company;
        
        PMP_OPID_MPI_Rel__c newOpid = new PMP_OPID_MPI_Rel__c();
        newOpid.PMP_Marketing_Profile_Id__c = company.id;
        newOpid.PMP_One_Partner_ID__c = newPagAccount.id;
        newOpid.Is_Active__c = true;        
        insert newOpid;               
        
        test.startTest();
        PMP_OPID_Storefront_Mapping.PartnerResponse response = PMP_OPID_Storefront_Mapping.getPartnerDetails(newPagAccount.Id);
        PMP_OPID_Storefront_Mapping.getPartnerDetails(null);
        System.assert(response!=null,'Error Occured!');
        test.stopTest();
    }
}