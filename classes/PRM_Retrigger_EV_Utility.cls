/**************************************************************************************************************
Apex Class Name:  PRM_Retrigger_EV_Utility
Version     : 1.0 
Created Date: 10 March 2020
Function    : Utility class for Retrigger EV functionality
Modification Log :
* Developer             		Date              Description
* ----------------------------------------------------------------------------                 
* Keerthan Nanjunda         03/10/2020        	Initial version
***************************************************************************************************************/
public class PRM_Retrigger_EV_Utility {

    @AuraEnabled
    public static String retrigger_EV(Date endDate,String LoginID,String BizOrgType,Boolean fromComponent,Id regRequestId)
    {
        List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
        Id emailLogID;
        String UImessage;
        if(fromComponent)
        {
        	listRegReq = [Select ID,CreatedDate,PRM_Email_Log__c,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_EmailVerifiedDateTime__c,PRM_EV_Token__c,PRM_Partner_Role__c FROM PRM_Registration_Request__c 
                                            WHERE Id =: regRequestId];
            endDate = (listRegReq[0].CreatedDate).date().addDays(Integer.valueOf(System.label.PRM_RetriggerEV_NumberOfDaysComponent));
            System.debug('listRegReq--->'+listRegReq+'endDate--->'+endDate);
            System.debug('endDate--->'+endDate);
            if(endDate < Date.today()){
                UImessage = 'EV Mail has expired';
                return UImessage;
            }
        }
        else
        {
            Id emailVerificationRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            listRegReq = [Select ID,CreatedDate, PRM_Email_Log__c,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_EmailVerifiedDateTime__c,PRM_EV_Token__c,PRM_Partner_Role__c FROM PRM_Registration_Request__c 
                                            WHERE CreatedDate >= : endDate
                                          	AND RecordTypeId =: emailVerificationRequestRT 
                                           	AND PRM_Contact_Login_ID__c =: LoginID 
                                            AND PRM_Partner_Type__c =: BizOrgType ORDER BY CreatedDate DESC LIMIT 1];            
        }
        
        emailLogID = listRegReq[0].PRM_Email_Log__c;
        PRM_EmailLog__c emailLog = [SELECT ID,Email_Template_ID__c,Email_Template_Name__c,PRM_EmailContent__c,PRM_ToEmailID__c,Language__c,PRM_Email_API_Response__c,PRM_Subject__c
                                       	FROM PRM_EmailLog__c WHERE ID =: emailLogID];
        if(emailLog != null){
        	System.debug('Contain email log !!!');
            UImessage = sendMail(listRegReq[0]);            
        }
        return UImessage;
    }
    
    private static String sendMail(PRM_Registration_Request__c regRequest){	
        String UImessage;
        if(regRequest != null){
		 PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                objEmailNotif.EmailID= regRequest.PRM_Email_ID__c;
                objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
                Map<String,String> paramMap = new Map<String,String>();
            	PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(regRequest.PRM_Partner_Role__c);
            	if(emailSetup != null){
                    paramMap.put('EmailContent_Setup',emailSetup.Id);    
                }
                paramMap.put('Registration_Request_ID',regRequest.id);
                objEmailNotif.InputParameters=paramMap;
				if(String.isNotBlank(String.valueOf(regRequest.PRM_EV_Token__c))){
                        objEmailNotif.BusinessEvent=System.label.PRM_Registration_request_for_new_User_EV;   
                        PRM_EmailUtility.sendEmail(objEmailNotif);  
                        system.debug('Mail sent for new User!!!');
                    }
            UImessage = 'Email sent successfully';
        }
        return UImessage;
    }    
}