@isTest
public class PRM_ACMBatchUtilityTest { 
    @isTest
    public static void Test(){
        
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
	        
    	Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdAccount;
        childAccount.Name='Greg Thomas'+System.now();
        childAccount.BillingCity='City1';
        childAccount.BillingStreet='Street1';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code1';
        childAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert childAccount;    
        
        Account childAccount2 = new Account();//Account
        childAccount2.RecordTypeId = recordTypeIdAccount;
        childAccount2.Name='Greg Thomas'+System.now();
        childAccount2.BillingCity='City1';
        childAccount2.BillingStreet='Street1';
        childAccount2.BillingCountry='India';
        childAccount2.BillingPostalCode='Postal code1';
        childAccount2.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert childAccount2;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = childAccount.id;
        insert coreAccnt;
        
        Set<Id> accIds = new Set<Id> 
        { newAccount.Id };
            
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
        
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry ='USA';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Gold';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Titanium';
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
        
        Test.startTest();
        PRM_AccountChannelMembership__c newAccountAcm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        newAccountAcm.PRM_Account_Id__c=newAccount.id;
        newAccountAcm.PRM_Status_Nm__c='Approved';
        newAccountAcm.PRM_Channel_Program_Id__c=cp.Id;
        newAccountAcm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        newAccountAcm.PRM_Partner_Role__c='Service Provider';
        insert newAccountAcm;
        
        PRM_AccountChannelMembership__c oPIDAcm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        oPIDAcm.PRM_Account_Id__c=newPagAccount.id;
        oPIDAcm.PRM_Status_Nm__c='Approved';
        oPIDAcm.PRM_Channel_Program_Id__c=cp.Id;
        oPIDAcm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        oPIDAcm.PRM_Partner_Role__c='Service Provider';
        insert oPIDAcm;
        
        PRM_AccountChannelMembership__c childAccountAcm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccountAcm.PRM_Account_Id__c=childAccount.id;
        childAccountAcm.PRM_Status_Nm__c='Approved';
        childAccountAcm.PRM_Channel_Program_Id__c=cp.Id;
        childAccountAcm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        childAccountAcm.PRM_Partner_Role__c='Service Provider';
        insert childAccountAcm;
        
        PRM_AccountChannelMembership__c childAccount2Acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccount2Acm.PRM_Account_Id__c=childAccount2.id;
        childAccount2Acm.PRM_Status_Nm__c='Approved';
        childAccount2Acm.PRM_Channel_Program_Id__c=cp.Id;
        childAccount2Acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        childAccount2Acm.PRM_Partner_Role__c='Seller';
        insert childAccount2Acm;
        
        
        PRM_IPA_Membership__c ipaMem1 = new PRM_IPA_Membership__c();
        ipaMem1.PRM_Account_Channel_Membership__c = newAccountAcm.Id;
        ipaMem1.PRM_Old_Partner_Role__c=newAccountAcm.PRM_Partner_Role__c;
        ipaMem1.PRM_Old_Partner_Tier__c=cpl.name;
        ipaMem1.PRM_Partner_Role__c = 'Service Provider';
        ipaMem1.PRM_Partner_Tier__c = cpl1.Id;
        insert ipaMem1;
        
        PRM_IPA_Membership__c ipaMem = new PRM_IPA_Membership__c();
        ipaMem.PRM_Account_Channel_Membership__c = oPIDAcm.Id;
        ipaMem.PRM_Old_Partner_Role__c = oPIDAcm.PRM_Partner_Role__c;
        ipaMem.PRM_Old_Partner_Tier__c=cpl.Name;
        ipaMem.PRM_Partner_Role__c = 'Service Provider';
        ipaMem.PRM_Partner_Tier__c = cpl1.Id;
        insert ipaMem;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        insert acm1;
        
        PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=newAccount.id;
        acm2.PRM_Status_Nm__c='Approved';
        acm2.PRM_Channel_Program_Id__c=cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm2.PRM_Partner_Role__c='Seller';
        insert acm2;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Test';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'TEST';
        pb2.PRM_Account_Type_Nm__c = 'both'; 
        insert pb2;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Partner University1';
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
        
        PRM_VXBnftMatrix__c bem11=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem11.PRM_Approval_Type_Nm__c='Automatic';
        bem11.PRM_Channel_Program_Id__c=cp.Id;
        bem11.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem11.PRM_Covered_Account_Ind__c=True;
        bem11.PRM_IsActive_Ind__c=True;
        bem11.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem11.PRM_Partner_Type_Id__c=pt.Id;
        bem11.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem11;
        
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
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        aba.PRM_Status_Reason_Txt__c='testing';
        aba.PRM_Status_Nm__c = 'Inactive';
        update aba;
        
        aba.PRM_Status_Reason_Txt__c='testing';
        aba.PRM_Status_Nm__c = 'Active';
        //update aba;
        update aba;
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb1.id;
        aba1.PRM_Status_Nm__c = 'Active';
        insert aba1;
        
        aba1.PRM_Status_Reason_Txt__c='testing';
        aba1.PRM_Status_Nm__c = 'Inactive';
        update aba1;
        
        aba1.PRM_Status_Reason_Txt__c='testing';
        aba1.PRM_Status_Nm__c = 'Active';        
        update aba1;
        
        
        Database.executeBatch(new PRM_ACMUpdateBatchUtility());
        Test.stopTest();
    }
}