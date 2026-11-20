@isTest
public class Core_MDF_Batch_PNUMRefresh_Test {
 @TestSetup static void setUpData(){
     ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
     List<Account> accList = new List<Account>();
     List<Account> updateAccList = new List<Account>();
     Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
     insert intelAcc;
     Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc1.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        accList.add(acc1);
     
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        acc2.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        accList.add(acc2);
     Database.insert(accList);
        
        intelAcc.IsPartner = true;
        updateAccList.add(intelAcc);
        acc1.IsPartner = true;
        updateAccList.add(acc1);
        acc2.IsPartner = true;
        updateAccList.add(acc2);
        
        Database.update(updateAccList);
     List<Contact> conList = new List<Contact>();
      Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord3 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
     conList.add(conRecord1);
      conList.add(conRecord2);
      conList.add(conRecord3);
      Database.insert(conList);
     
      List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF User',agsRoleCCF.Id ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client Co-Marketing Fund (CCF)',false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF Claim Submitter',agsRoleCCFClaimSub.Id ,'Consolidated Co-marketing Platform','CCF Claim Submitter',erpmEngagementCCF.Id , true,'Client Co-Marketing Fund (CCF)',false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Core_Contact_Entitlement__c contactEntitlementCCF2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF2);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub2);
     
      Core_Contact_Entitlement__c contactEntitlementCCF3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord3.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF3);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub3 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord3.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub3);
 
        Database.insert(contEntList); 
     
 }
}