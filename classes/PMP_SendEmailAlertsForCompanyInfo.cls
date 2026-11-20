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
public with sharing class PMP_SendEmailAlertsForCompanyInfo { 
    @InvocableMethod 
     public static void PMP_SendEmailAlertsForCompanyInfo(List<string> CompanyInfoIds){ 
 
         string companyInfoId = CompanyInfoIds[0].substringBefore('|');
         string apexEmailRecName = CompanyInfoIds[0].substringAfter('|');
         /*list<Messaging.SingleEmailMessage> sendemaillist;
         list<String> toaddress;
         String templateName;
         String subjectFARForReview;
         String bodyFAEForReview;
         
         Core_Account_Group_Member__c pagMember = new Core_Account_Group_Member__c();
         List<Core_Account_Group_Member__c> pagMemberList = new List<Core_Account_Group_Member__c>();
         Set<Id> intelAccountIds = new Set<Id>();
         Set<Id> partnerUserIds = new Set<Id>();
         Set<Id> userIds = new Set<Id>();*/
        
             try
             {         
                 //  Set<user> userIds = New set<user>();
                 //Set<id> accountId = New set<id>();
                 List<PMP_Company__c> comInfoList ;   
                 string companyInfoType;
                 //List<Id> companyIds= new List<Id>{};
                 comInfoList = [select id,PMP_Partner_Benefit_Type__c,PMP_Suppress_Email_Ind__c,PMP_Published_Copy_Id__c from PMP_Company__c where Id=:CompanyInfoId];
                 //To get the type of benefit assigned. (To differentiate from storefront and Profile)
                 if(!comInfoList.isEmpty()){
                     companyInfoType = comInfoList[0].PMP_Partner_Benefit_Type__c == 'Solutions Marketplace Enhanced'? 'Storefront': 'Profile';
                  //   companyInfoType = comInfoList[0].PMP_Partner_Benefit_Type__c == 'Solutions Marketplace Basic Profile'? 'Storefront': 'Profile';
                 }                  
                 
                 sendEmail(comInfoList,apexEmailRecName,companyInfoType);
                 
             }  
             catch(Exception e)
             {
                 system.debug('Exception caught==>'+e+' at line '+e.getlinenumber());
             }  
             
         }

        public static void sendEmail(List<PMP_Company__c> comInfoList, string apexEmailRecName, string companyInfoType){
            Map<id,id> userCompanyMap = New Map<id,id>();
            if(!comInfoList[0].PMP_Suppress_Email_Ind__c){
                        Core_Apex_EmailNotification__c apexEmailRec = New Core_Apex_EmailNotification__c();            
                        
                        apexEmailRecName = apexEmailRecName +'_'+ companyInfoType ;  //appeniding the type to the metadata name to fetch the relavant record
                        
                        //querying apexEmail to get the email template name and permission sets required on user to send email
                        apexEmailRec = PMP_Utility.getApexEmailRecord(apexEmailRecName);
                        
                        
                        List<string> allowedPermissionSets = New List<string>(); //allowed permission sets are stored in the metadata as comma seperate values    
                        allowedPermissionSets = apexEmailRec.Core_Allowed_Permission_Nm__c.split(',');
                        
                        //fetch users to send the email
                        userCompanyMap = PMP_Utility.fetchUsersMapFromPagMember(comInfoList, allowedPermissionSets);
                        
                        //Send emails
                        if(!userCompanyMap.keySet().isEmpty()){
                            PMP_Utility.sendEmailAndLogData(apexEmailRec.Core_Email_Template_Nm__c, userCompanyMap);    
                        } 
                        
                    }
                    
                    //For Suppress Email Functionality
                    else{
                        // select id, name,PRM_Emails_to_be_Suppressed__c, PRM_Contact__c, PRM_Event__c from  PRM_Email_Handler__c 
                        PRM_Email_Handler__c emailHandler= new PRM_Email_Handler__c();
                        emailHandler.PRM_Event__c='Benefit Addition';
                        emailHandler.PRM_Email_Handler_Status__c='Completed';
                        emailHandler.PRM_Suppress_Email__c=true;
                        emailHandler.PMP_Marketing_Profile_Information__c=comInfoList[0].Id;
                        emailHandler.PMP_Suppressed_Email_Desc__c=comInfoList[0].PMP_Partner_Benefit_Type__c == PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile? PMP_StaticConstants_Partner.ONBOARDING_EMAIL_SUPPRESS:PMP_StaticConstants_Partner.OFFERING_CREATION_SUPPRESS;
                        insert emailHandler;
                        
                        if(comInfoList[0].PMP_Partner_Benefit_Type__c == PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile && comInfoList[0].PMP_Suppress_Email_Ind__c == true){
                            //The below static constant added by Krishna Ch for 101 SOQL issue.
                            Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
                            if(companyTriggerFlagMap!=null && companyTriggerFlagMap.isEMpty() && companyTriggerFlagMap.containsKey('Sync_Published_Copy') 
                                && !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ // check added by dinesh to avoid de-ref error
                                    PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
                            }
                        
                            comInfoList[0].PMP_Suppress_Email_Ind__c=false;
                            PMP_Company__c partnerPublishedCopy= new PMP_Company__c(Id=comInfoList[0].PMP_Published_Copy_Id__c,PMP_Suppress_Email_Ind__c=false);
                            comInfoList.add(partnerPublishedCopy);                        
                            //update comInfoList;
                            Database.SaveResult[] ciList = Database.update(comInfoList, false);
                            PMP_Utility.logDmlErrors((Object[]) ciList, 'PMP_SendEmailAlertsForCompanyInfo-sendEmail');
                        }   
                    }
            }
     }