/* Created By - Harsh Mishra
 Created Date -12/09/2022
*/
@isTest
public class PMP_MismatchRecordsTest {
    @testSetup static void setup() {
        // Create common test accounts 
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account pagAcc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Account pagAcc1 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
        Account pagAcc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount3', devRecordTypeId, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', pagAcc.Id, true);
        PMP_Company__c cmp2 = PMP_TestDataUtility.createCompanyInformation('TestCompany2', pagAcc1.Id, true);
        cmp1.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        cmp1.PMP_Company_Lifecycle_Status_Nm__c='Published';
        update cmp1;
        
        cmp2.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        cmp2.PMP_Benefit_Update_Ind__c=false;
        cmp2.PMP_Company_Lifecycle_Status_Nm__c='Published';
        update cmp2;
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= pagAcc.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun; 
        PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
        jun1.PMP_One_Partner_ID__c= pagAcc1.Id;
        jun1.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun1.Is_Active__c=true;     
        insert jun1;
        PMP_OPID_MPI_Rel__c jun2= new PMP_OPID_MPI_Rel__c();
        jun2.PMP_One_Partner_ID__c= pagAcc2.Id;
        jun2.PMP_Marketing_Profile_Id__c= cmp2.Id;
        jun2.Is_Active__c=false;     
        insert jun2;
        
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
        acctContRel.PRM_Account_Id__c=acc1.Id;
        acctContRel.PRM_Contact_Id__c=con1.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=pagAcc.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;  
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=pagAcc.id;
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
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = pagAcc.Id;
        aba.PRM_Partner_Benefit_Id__c = pb1.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
    }
    @isTest
    public static void opidBadgeTierCheckTest(){
        PMP_MismatchRecords.opidBadgeTierCheck();
    }
}