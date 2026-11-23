/****************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForCompanyInfo 
* Version     : 1.0 
* Created Date: 03/19/2020
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh                                03/19/2020           This class is for sending Emails when company is created
*****************************************************************************************************************************************/
public class PMP_SendEmailAlertsForCompanyInfo {
   @InvocableMethod 
    public static void PMP_SendEmailAlertsForCompanyInfo(List<string> CompanyInfoIds){ 
        system.debug('inputParam' + CompanyInfoIds[0]);
        string companyInfoId = CompanyInfoIds[0].substringBefore('|');
        string metadataName = CompanyInfoIds[0].substringAfter('|');
        
        list<Messaging.SingleEmailMessage> sendemaillist;
        list<String> toaddress;
        String templateName;
        String subjectFARForReview;
        String bodyFAEForReview;
        
        Core_Account_Group_Member__c pagMember = new Core_Account_Group_Member__c();
        List<Core_Account_Group_Member__c> pagMemberList = new List<Core_Account_Group_Member__c>();
        Set<Id> intelAccountIds = new Set<Id>();
        Set<Id> partnerUserIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        
        try
        {        
            
            
            PMP_Company__c comInfo = [select id,PMP_Account_Id__c   from PMP_Company__c where Id=:CompanyInfoId];
            
            // to get the core intel account of the partner account record [Core_Account_Group_Member__c is a junction object b/w partner account and Intel account]
            pagMember = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: comInfo.PMP_Account_Id__c  Limit 1];            
            //one core account can have multiple accounts under it, get the list of all such junction records
            pagMemberList = [SELECT id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Partner_Account_Id__c=:pagMember.Core_Partner_Account_Id__c];
            
            //To get the type of benifit assigned. (To differentiate from storefront and Profile)
            string companyInfoType = PMP_SearchUtilityController.getCompanyInfoType(comInfo);            
            PMP_Alert_To_Email_Setting__mdt metaSetting = New PMP_Alert_To_Email_Setting__mdt();            
           
            metadataName = metadataName +'_'+ companyInfoType ;  //appeniding the type to the metadata name to fetch the relavant record
           
            //querying metadata to get the email template name and permission sets required on user to send email
            metaSetting = [Select PMP_Allowed_Permission_Set__c, PMP_Email_Template_Name__c From  PMP_Alert_To_Email_Setting__mdt
                             Where MasterLabel =: metadataName and PMP_Object_Subtype__c =: companyInfoType  limit 1];
            
                     
            List<string> allowedPermissionSets = New List<string>(); //allowed permission sets are stored in the metadata as comma seperate values    
            allowedPermissionSets = metaSetting.PMP_Allowed_Permission_Set__c.split(',');
            //system.debug('permissionSets' +allowedPermissionSets);
            
            EmailTemplate companyInfoEmail = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName =: metaSetting.PMP_Email_Template_Name__c  ];            
            sendemaillist = new list<Messaging.SingleEmailMessage>();            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            if(!test.isRunningTest()){
                mail = Messaging.renderStoredEmailTemplate((string)companyInfoEmail.id , null , companyInfoId );
            }            
            toaddress = new list<String>(); 
            
            //get all the accounts under the Core Intel Account
            for(Core_Account_Group_Member__c mem : pagMemberList){
                intelAccountIds.add(mem.Core_Intel_Account_Id__c);
            }
        
            //query all users belonging to the account having the required permission sets
            List<PermissionSetAssignment> permissionAssignmentList = New List<PermissionSetAssignment>();
            permissionAssignmentList = [SELECT Assignee.email, Id,AssigneeId FROM PermissionSetAssignment WHERE Assignee.AccountId  in:intelAccountIds  AND PermissionSet.Name =:allowedPermissionSets ];
            for(PermissionSetAssignment pa : permissionAssignmentList){
                userIds.add(pa.AssigneeId);
                toaddress.add(pa.Assignee.email);
            }
            
            //fetching orgwide email address to set the to address           
            OrgWideEmailAddress owa = New OrgWideEmailAddress ();            
            owa =  [select id, Address, DisplayName from OrgWideEmailAddress Where Address =  'wsm-postmaster@intel.com' limit 1];      
            if(toaddress.size()>0){ 
                mail.setToAddresses(toaddress);
                if(owa == null){
                    mail.setSenderDisplayName(PMP_StaticConstants_Offering.Intel_MP_Admin);       
                }
                else{
                    mail.setOrgWideEmailAddressId(owa.id);       
                }           
                       
                mail.setBccSender(false);
                mail.setUseSignature(false);                
                mail.saveAsActivity = false;
                sendemaillist.add(mail);
                Messaging.sendEmail(sendemaillist);
            } 
     }  
     catch(Exception e)
     {
         system.debug('Exception caught==>'+e+' at line '+e.getlinenumber());
     }               
    }    
}