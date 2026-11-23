/****************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForCompanyInfo 
* Version     : 1.0 
* Created Date: 03/19/2020
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Manjula                               05/12/2020           This class is for sending Emails for Enhanced profile users to create offering 
*****************************************************************************************************************************************/
public With Sharing class PMP_SendEmailAlertForCreateOffering {
    
    // @InvocableMethod
    // public static void PMP_SendEmailAlertForCreateOfferingInfo(List<String> accountInfoIds) {
    //     try {
    //         String accountInfoId = accountInfoIds[0].substringBefore('|');
    //         String metadataName = accountInfoIds[0].substringAfter('|');
    //         //system.debug('accountInfoId-->'+accountInfoId);
	// 		//system.debug('metadataName-->'+metadataName);
    //         PMP_Company__c comInfo = [SELECT Id, PMP_Account_Id__c, PMP_Working_Copy_Id__c, PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c, PMP_Company_Lifecycle_Status_Nm__c
    //                                 FROM PMP_Company__c 
    //                                   WHERE PMP_Account_Id__c = :accountInfoId AND PMP_Is_Published_Ind__c = true];

    //         if (comInfo.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c != 'Draft' 
    //             && comInfo.PMP_Company_Lifecycle_Status_Nm__c == 'Published') {
    //             Core_Account_Group_Member__c pagMember = [SELECT Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
    //                                                       FROM Core_Account_Group_Member__c 
    //                                                       WHERE Core_Intel_Account_Id__c = :comInfo.PMP_Account_Id__c LIMIT 1];
    //             List<Core_Account_Group_Member__c> pagMemberList = [SELECT Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
    //                                                                 FROM Core_Account_Group_Member__c 
    //                                                                 WHERE Core_Partner_Account_Id__c = :pagMember.Core_Partner_Account_Id__c];

    //             PMP_Alert_To_Email_Setting__mdt metaSetting = [SELECT PMP_Allowed_Permission_Set__c, PMP_Email_Template_Name__c 
    //                                                            FROM PMP_Alert_To_Email_Setting__mdt 
    //                                                            WHERE DeveloperName = :metadataName LIMIT 1];

    //             List<String> allowedPermissionSets = metaSetting.PMP_Allowed_Permission_Set__c.split(',');

    //             EmailTemplate companyInfoEmail = [SELECT Id, Subject, Body 
    //                                               FROM EmailTemplate 
    //                                               WHERE DeveloperName = :metaSetting.PMP_Email_Template_Name__c];
    //             List<String> toAddresses = new List<String>();
    //             Set<Id> intelAccountIds = new Set<Id>();
    //             Set<Id> userIds = new Set<Id>();

    //             for (Core_Account_Group_Member__c mem : pagMemberList) {
    //                 intelAccountIds.add(mem.Core_Intel_Account_Id__c);
    //             }

    //             List<PermissionSetAssignment> permissionAssignmentList = [SELECT Assignee.Email, AssigneeId 
    //                                                                       FROM PermissionSetAssignment 
    //                                                                       WHERE Assignee.AccountId IN :intelAccountIds AND PermissionSet.Name IN :allowedPermissionSets];

    //             for (PermissionSetAssignment pa : permissionAssignmentList) {
    //                 userIds.add(pa.AssigneeId);
    //                 toAddresses.add(pa.Assignee.Email);
    //             }

    //             OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName 
    //                                        FROM OrgWideEmailAddress 
    //                                        WHERE Address = 'wsm-postmaster@intel.com' LIMIT 1];

    //             if (toAddresses.size()>0) {
    //                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //                 //system.debug('companyInfoEmail-->'+(String)companyInfoEmail.Id);
    //                 //system.debug('comInfoPMP_Working_Copy_Id__c-->'+comInfo.PMP_Working_Copy_Id__c);
    //                 mail = Messaging.renderStoredEmailTemplate((String)companyInfoEmail.Id, null, comInfo.PMP_Working_Copy_Id__c);
	// 				//System.debug('Mail-->'+mail);
    //                 mail.setToAddresses(toAddresses);
	// 				//System.debug('Mail toaddress-->'+toAddresses);
    //                 if (owa == null) {
    //                     mail.setSenderDisplayName(PMP_StaticConstants_Offering.Intel_MP_Admin);
    //                 } else {
    //                     mail.setOrgWideEmailAddressId(owa.Id);
    //                 }

    //                 mail.setBccSender(false);
    //                 mail.setUseSignature(false);
    //                 mail.saveAsActivity = false;

    //                 List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
    //                 sendEmailList.add(mail);

    //                 Messaging.sendEmail(sendEmailList);
    //             }
    //         }
    //     } catch (Exception e) {
    //         //System.debug('Exception caught==> ' + e + ' at line ' + e.getLineNumber());
    //     }
    // }    
    
}