@isTest
public class PRM_TimelineController_Test {

      @isTest static void fetchHistory_Test()
    {
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> lstAccts = new List<Account>();
        
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
                                              ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
        lstAccts.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        lstAccts.add(intelAccount1);
        Database.insert(lstAccts);
        
        //Get Contact Record Type
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=partnerAccount1.Id,RecordTypeId=IntelContRecTypeId,
                                  MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456');
        insert cnt;
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;
        
        ChannelProgramLevel partnerTier = new ChannelProgramLevel(Name='Member',ProgramId=cp.Id,PRM_programlevelcode__c='IPAMember',Rank=100);
        insert partnerTier;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(PRM_Account_Id__c=partnerAccount1.Id,PRM_Channel_Program_Id__c=cp.Id,PRM_Partner_Role__c='Service Provider',PRM_Channel_Program_Level_Id__c=partnerTier.Id,PRM_Status_Nm__c='Approved');
        insert acm;

        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cp.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cp.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
         PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cp.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = partnerTier.Id;
        bmTest2.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest2;
       
        //List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = partnerAccount1.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        insert abassociationTest2;
       // abaList.add(abassociationTest2);
        
        //Account Contact Relationship
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Works for';
        contRel.PRM_Contact_Relationship_Cd__c = 'CONTRELWORKSFOR';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount1.Id;
        acr.PRM_Contact_Id__c = cnt.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        Test.startTest();
        List<PRM_TimelineController.History> results=new List<PRM_TimelineController.History>();
        results=PRM_TimelineController.fetchHistory(partnerAccount1.Id);
        Test.stopTest();
        
    }
}