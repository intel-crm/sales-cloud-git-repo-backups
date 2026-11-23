public without sharing class Test_SH {
private static final String PENDING = 'Pending';
private static final String CLOSED = 'Closed';
private static final String SUCCESS = 'Success';
    
    public static void testMth(){
        String strReturn;
        Contact currContact1;
            
        Account targetAccountObj = [select Id, Name, Core_IsODM__c, Core_CNDA_Number__c, Core_CIM_ID__c, Core_English_Only_Name__c, Core_Export_Compliance_Block__c , 
                                        Core_IPS_Active__c, Core_B2B_Entitlement__c, Core_Export_Compliance_Block_Reason__c, Owner.UserRole.Name, Core_PSG_Account__c
                                        FROM Account where ID = '0013b00001r4kUHAAY' Limit 1];
                
        Contact currContact = [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                           Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c, Account.Core_IPS_Active__c,Account.Core_PSG_Account__c,
                           Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                           Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName, Account.Core_B2B_Entitlement__c, Core_Contact_B2B_Indicator__c 
                           From Contact Where id = '0032i000018z1JRAAY']; 
                           
        List<Case> casewithoutProj = [Select id,Product.name,caseNumber,status,ContactId,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,
                              Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c,Asset.Name,Account.Name,
                              Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,AssetId,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, 
                              Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name 
                              FROM Case Where contactId = '0032i000018z1JRAAY' AND RecordType.Name != 'CEP Case'];
                              
        Id accountId = '0013b00001r4kUHAAY';
        
        List<Case> lCaseToUpdateContact = new List<Case>();
        
        if (!casewithoutProj.isEmpty()) {
                    strReturn = Core_IPS_MoveContactWithCases_Controller.updateAssetsToCase(lCaseToUpdateContact, casewithoutProj, accountId, targetAccountObj, currContact);
                }
        
                if(SUCCESS.equalsIgnoreCase(strReturn)){
                    if(Contact.SObjectType.getDescribe().isAccessible()){
                         currContact1 = [Select Id,Name,Core_ERPM_Integration_Status__c,Core_AGS_Integration_Status__c,AccountId,Core_Account_Changeable__c,Core_IPS_Active__c from contact where id =: currContact.id limit 1];
                        }
                        // if(keepEntitlements == false){
                        //     currContact1.Core_AGS_Integration_Status__c = PENDING;
                        // }
                        
                        currContact1.Core_ERPM_Integration_Status__c = PENDING;
                        //currContact1.Core_AGS_Integration_Status__c = PENDING;
                        currContact1.AccountId = accountId;
                        currContact1.Core_Account_Changeable__c= true;
                        Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;
                        update currContact1;
                }
    }
}