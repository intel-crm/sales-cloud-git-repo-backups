/**************************************************************************************************************
Apex Class Name:  ER_RetriggerEVMail_Utility
Version     : 1.0 
Created Date: 08 March 2022
Function    : Utility class for Retrigger EV functionality
Modification Log :
* Developer                     Date              Description
* ----------------------------------------------------------------------------                 
* Manjunatha Hegde			03/08/2022			Initial version

***************************************************************************************************************/
public without sharing class ER_RetriggerEVMail_Utility {
    //Method to handle EV request and send notifications based on entitlement/program
    public static ER_RetriggerEVMail_Model.ER_RetriggerEV_Response Retrigger_EV(ER_RetriggerEVMail_Model.ER_RetriggerEVMail_Input evInput)
    {
        String retrievalStatus;
        String message;
        ER_RetriggerEVMail_Model.ER_RetriggerEV_Response res=new ER_RetriggerEVMail_Model.ER_RetriggerEV_Response();
        List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
        Id emailVerificationRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        listRegReq=Database.query(buildQuery(evInput));
        //Check for request Size before sending the emails
        if(listRegReq.Size()>0){
            retrievalStatus=PRM_Retrigger_EV_Utility.reteriveNewEvToken(listRegReq[0]);
            if(retrievalStatus ==System.label.PRM_EV_TOKEN_RETERIEVED){  
                if(evInput.IsProgramBased){
                    message=sendMail(listRegReq[0]); 
                }
                else{
                    ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration(listRegReq); 
                }
                if(!String.isBlank(message) && message!=System.label.PRM_RetriggerEmail_Success){
                    res.Message=message;
                    res.IsSuccess=false;
                    res.StatusCode=500;
                }else{
                    res.Message=System.label.PRM_RetriggerEmail_Success;
                    res.IsSuccess=true;
                    res.StatusCode=200;
                }
            }
            if(retrievalStatus ==System.label.PRM_UNABLE_TO_RETRIEVE_EV_TOKEN || Test.isRunningTest()){
                res.Message='Unable to retrieve New EV Token'+'Login ID : '+ evInput.LoginId+' '+ ' Email ID : '+evInput.Email;
                res.IsSuccess=false;
                res.StatusCode=500;
            }
        }
        else{
            res.Message='Cannot Find Registration Request for the given inputs :'+ 'Login ID : '+evInput.LoginId+' '+' Email ID : '+evInput.Email;
            res.IsSuccess=false;
            res.StatusCode=400;
        }
        return res;
    }
    
    public static ER_RetriggerEVMail_Model.ER_RetriggerEV_Response ValidateInput(String LoginId,String EmailId,String IsProgramBased,String Name){
        ER_RetriggerEVMail_Model.ER_RetriggerEV_Response validation =new	ER_RetriggerEVMail_Model.ER_RetriggerEV_Response(); 
        string validMsg='';
        validation.IsSuccess=true;
        if((String.isEmpty(LoginID) && String.isEmpty(EmailId)) || (String.isEmpty(Name))){
            validation.Message= 'Invaid Request! LoginId or EmailId is mandatory.IsProgramBased and Name is mandatory :'+'Login ID : '+LoginId+' '+' Email ID : '+EmailId;
            validation.IsSuccess=false;
            validation.StatusCode=400;
        }
        return  validation;
    }
    public static ER_RetriggerEVMail_Model.ER_RetriggerEV_Response generateException(String ex){
        ER_RetriggerEVMail_Model.ER_RetriggerEV_Response res =new ER_RetriggerEVMail_Model.ER_RetriggerEV_Response();
        res.Message=ex;
        res.IsSuccess=false;
        res.StatusCode=500;
        return res;
    }
    //Query to generate Registration request based on the input.
    private static string buildQuery(ER_RetriggerEVMail_Model.ER_RetriggerEVMail_Input evInput)
    {
        String  query='Select ID,CreatedDate, Entitlement_Details__r.Name, PRM_Email_Log__c,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_EmailVerifiedDateTime__c,PRM_EV_Token__c,PRM_Partner_Role__c, PRM_Contact_Country__c,PRM_EV_Token_Renewed_Date__c,PRM_Contact_Login_ID__c FROM PRM_Registration_Request__c WHERE RecordTypeId =: emailVerificationRequestRT AND ';        
        string programCheck='';
        string emailIdOrLoginId='';
        emailIdOrLoginId=String.IsEmpty(evInput.Email)?' PRM_Contact_Login_ID__c= '+'\''+evInput.LoginId+'\'':'PRM_Email_ID__c ='+'\''+evInput.Email+'\'';
        programCheck=evInput.IsProgramBased?' PRM_Channel_Program__r.PRM_programCode__c ='+'\''+evInput.Name+'\'':'Entitlement_Details__r.Name='+'\''+evInput.Name+'\'';
        query=query+emailIdOrLoginId+' AND '+programCheck;
        return query;
    }
    
    //Need to revisit for Program based EV Retriggers
    private static String sendMail(PRM_Registration_Request__c regRequest){ 
        String UImessage;
        if(regRequest != null){
            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
            objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            objEmailNotif.EmailID= regRequest.PRM_Email_ID__c;
            objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
            PRM_Language_Culture_Mapping__mdt langCultureForEmail;       
            List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];   //Added by Teja as per PMD Scan from Line 217
            for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                    langCultureForEmail = mdtRec;
                }
                if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequest.PRM_Contact_Country__c) && mdtRec.MasterLabel == regRequest.PRM_Preferred_Language__c){
                    langCultureForEmail = mdtRec;
                }
            }
            Map<String,String> paramMap = new Map<String,String>();
            if(langCultureForEmail != null){
                paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
            }
            /*PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(regRequest.PRM_Partner_Role__c);
if(emailSetup != null){
paramMap.put('EmailContent_Setup',emailSetup.Id);    
} */
            paramMap.put('Registration_Request_ID',regRequest.id);
            objEmailNotif.InputParameters=paramMap;
            if(String.isNotBlank(String.valueOf(regRequest.PRM_EV_Token__c))){
                objEmailNotif.BusinessEvent=System.label.PRM_Registration_request_for_new_User_EV;   
                
               // PRM_EmailUtility.sendEmail(objEmailNotif);
               // //added as part of governor limit story:4380
				PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});       
            }
            UImessage = System.label.PRM_RetriggerEmail_Success;
        }
        return UImessage;
    }   
}