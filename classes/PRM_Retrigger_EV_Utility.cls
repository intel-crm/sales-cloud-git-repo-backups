/**************************************************************************************************************
Apex Class Name:  PRM_Retrigger_EV_Utility
Version     : 1.0 
Created Date: 10 March 2020
Function    : Utility class for Retrigger EV functionality
Modification Log :
* Developer                     Date              Description
* ----------------------------------------------------------------------------                 
* Keerthan Nanjunda         03/10/2020          Initial version
* GopiKrishna Vankadari     10/06/2021          Added new method reteriveNewEvToken to get fresh EV Token
***************************************************************************************************************/
public without sharing class PRM_Retrigger_EV_Utility {
    
    //@AuraEnabled
    /*Public static String Retrigger_EV(Date endDate,String LoginID,String BizOrgType,Boolean fromComponent,Id regRequestId)
    {
        List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
        Id emailLogID;
        String UImessage;  
        String retrievalStatus;
        if(fromComponent)
        {
            
            listRegReq = [Select ID,CreatedDate,PRM_Email_Log__c, Entitlement_Details__r.Name,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c, PRM_Contact_Country__c,PRM_EV_Token_Renewed_Date__c,PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c 
                          WHERE Id =: regRequestId];			
            //endDate = (listRegReq[0].CreatedDate).date().addDays(Integer.valueOf(System.label.PRM_RetriggerEV_NumberOfDaysComponent));
            
            //if(endDate < Date.today()){
            //    UImessage = 'EV Mail has expired';
            //    return UImessage;
            //}
            DateTime evTokenEndDate = listRegReq[0].CreatedDate;
            dateTime evEndDate = evTokenEndDate.addDays(Integer.valueOf(System.label.PRM_EV_Token_Expiry_Days));
            if(evEndDate>datetime.now()){
                UImessage = System.Label.PRM_RetriggerEV_Message_Before_24hrs;
                return UImessage;
            }
            else{
                retrievalStatus=reteriveNewEvToken(listRegReq[0]);
            }       
        }
        else
        {
            Id emailVerificationRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();			
            listRegReq = [Select ID,CreatedDate, Entitlement_Details__r.Name, PRM_Email_Log__c,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c, PRM_Contact_Country__c,PRM_EV_Token_Renewed_Date__c,PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c 
                          //WHERE CreatedDate >= : endDate
                          WHERE RecordTypeId =: emailVerificationRequestRT 
                          AND PRM_Email_ID__c  =: LoginID  //Substitute for PRM_Contact_Login_ID__c for the time being. will modify after the development design is finalized.
                          AND PRM_Partner_Type__c =: BizOrgType ORDER BY CreatedDate DESC LIMIT 1];			
            retrievalStatus = reteriveNewEvToken(listRegReq[0]);       
        }
        
        emailLogID = listRegReq[0].PRM_Email_Log__c;
        PRM_EmailLog__c emailLog = [SELECT ID,Email_Template_ID__c,Email_Template_Name__c,PRM_EmailContent__c,PRM_ToEmailID__c,Language__c,PRM_Email_API_Response__c,PRM_Subject__c FROM PRM_EmailLog__c WHERE ID =: emailLogID];
        
        if(emailLog != null && (retrievalStatus == System.label.PRM_EV_TOKEN_RETERIEVED)){
            UImessage = sendMail(listRegReq[0]);            
        }
        if(retrievalStatus ==System.label.PRM_UNABLE_TO_RETRIEVE_EV_TOKEN || Test.isRunningTest()){
            UImessage = 'Unable to retrieve New EV Token';
        }
        return UImessage;
    }*/
    
    public class Retrigger_EVWrapper{
        public Date endDate{get;set;}
        public String LoginID{get;set;}
        public String BizOrgType{get;set;}
        public Boolean fromComponent{get;set;}
        public Id regRequestId{get;set;}
    }//Athr fixes
	@AuraEnabled
    Public static String Retrigger_EV(Retrigger_EVWrapper att)
{
    List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
    Id emailLogID;
    String UImessage;  
    String retrievalStatus;
    if(att.fromComponent)
    {
        
        listRegReq = [Select ID,CreatedDate,PRM_Email_Log__c, Entitlement_Details__r.Name,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c, PRM_Contact_Country__c,PRM_EV_Token_Renewed_Date__c, PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c 
                      WHERE Id =: att.regRequestId];			
        //att.endDate = (listRegReq[0].CreatedDate).date().addDays(Integer.valueOf(System.label.PRM_RetriggerEV_NumberOfDaysComponent));
        
        //if(att.endDate < Date.today()){
        //    UImessage = 'EV Mail has expired';
        //    return UImessage;
        //}
        DateTime evTokenEndDate = listRegReq[0].CreatedDate;
        dateTime evEndDate = evTokenEndDate.addDays(Integer.valueOf(System.label.PRM_EV_Token_Expiry_Days));
        if(evEndDate>datetime.now()){
            UImessage = System.Label.PRM_RetriggerEV_Message_Before_24hrs;
            return UImessage;
        }
        else{
            retrievalStatus=reteriveNewEvToken(listRegReq[0]);
        }       
    }
    else
    {
        Id emailVerificationRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();			
        listRegReq = [Select ID,CreatedDate, Entitlement_Details__r.Name, PRM_Email_Log__c,PRM_Person_Phone_Number__c,RecordTypeId,PRM_Email_ID__c,PRM_Preferred_Language__c,PRM_Partner_Role__c, PRM_Contact_Country__c,PRM_EV_Token_Renewed_Date__c,PRM_Channel_Program_Level_txt__c FROM PRM_Registration_Request__c 
                      //WHERE CreatedDate >= : att.endDate
                      WHERE RecordTypeId =: emailVerificationRequestRT 
                      AND PRM_Email_ID__c  =: att.LoginID  //Substitute for PRM_Contact_Login_ID__c for the time being. will modify after the development design is finalized.
                      AND PRM_Partner_Type__c =: att.BizOrgType ORDER BY CreatedDate DESC LIMIT 1];			
        retrievalStatus = reteriveNewEvToken(listRegReq[0]);       
    }
    
    emailLogID = listRegReq[0].PRM_Email_Log__c;
    PRM_EmailLog__c emailLog = [SELECT ID,Email_Template_ID__c,Email_Template_Name__c,PRM_EmailContent__c,PRM_ToEmailID__c,Language__c,PRM_Email_API_Response__c,PRM_Subject__c FROM PRM_EmailLog__c WHERE ID =: emailLogID];
    
    if(emailLog != null && (retrievalStatus == System.label.PRM_EV_TOKEN_RETERIEVED)){
        UImessage = sendMail(listRegReq[0]);            
    }
    if(retrievalStatus == System.label.PRM_UNABLE_TO_RETRIEVE_EV_TOKEN || Test.isRunningTest()){
        UImessage = 'Unable to retrieve New EV Token';
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
            
                //objEmailNotif.BusinessEvent=System.label.PRM_Registration_request_for_new_User_EV; 
                objEmailNotif.BusinessEvent=regRequest.PRM_Channel_Program_Level_txt__c!=System.label.PSG_Licensing?System.label.PRM_Registration_request_for_new_User_EV:System.label.PRM_Registration_request_for_new_User_EV_PSG;  
                if(regRequest.PRM_Channel_Program_Level_txt__c=='PSG'){
                    String loginId = regRequest.PRM_Contact_Login_ID__c!=Null?regRequest.PRM_Contact_Login_ID__c:regRequest.PRM_Email_ID__c;
                    PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{{USERNAME}}' =>loginId};
                }
                //PRM_EmailUtility.sendEmail(objEmailNotif);  
                ////added as part of governor limit story:4380
				PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});            
            UImessage = System.label.PRM_RetriggerEmail_Success;
        }
        return UImessage;
    }    
    
    @AuraEnabled
    public static boolean isEVSuccess(String regRequestID){
        boolean isEVSuccess = false;
        if(String.IsNotBlank(regRequestID)){
			List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>();
            
            regReqList = [Select Id, Email_Verification_Status__c,PRM_Channel_Program_Level_txt__c from PRM_Registration_Request__c where id = :regRequestID and Email_Verification_Status__c = 'SUCCESS'];
            
            if(!regReqList.isEmpty()){
                isEVSuccess  = true;                
            }
            
        }
        
        return isEVSuccess;
    }
    
    @AuraEnabled
    public static String sendInviteEmail(String regRequestID){
        String statusMsg = '';
        try{
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            List<PRM_Registration_Request__c> regRequestList = [Select Id, PRM_Email_ID__c, PRM_Preferred_Language__c, recordTypeId, PRM_Contact_Country__c from PRM_Registration_Request__c where id = :regRequestID];
            if(String.isNotBlank(regRequestID) && !regRequestList.isEmpty() && regRequestList[0].recordTypeId == emailVerificationRT){
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail; 
                    List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];   //Added by Teja as per PMD Scan from Line 217
                    for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                        if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                            langCultureForEmail = mdtRec;
                        }
                        if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequestList[0].PRM_Contact_Country__c) && mdtRec.MasterLabel == regRequestList[0].PRM_Preferred_Language__c){
                            langCultureForEmail = mdtRec;
                        }
                    }
                    
                    PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                    objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;                 
                    objEmailNotif.EmailID= regRequestList[0].PRM_Email_ID__c ;
                    objEmailNotif.Language = regRequestList[0].PRM_Preferred_Language__c ;
                    Map<String,String> paramMap = new Map<String,String>();
                    paramMap.put('Registration_Request_ID',regRequestList[0].id);                
                    if(langCultureForEmail != null){
                        paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                    }
                    objEmailNotif.InputParameters=paramMap;                                                      
                    objEmailNotif.BusinessEvent=System.label.PRM_Resend_Registration_Request_Invite;   
                   // PRM_EmailUtility.sendEmail(objEmailNotif);  
                   // //added as part of governor limit story:4380
					PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});   
                    statusMsg = System.label.PRM_RetriggerEmail_Success;
                }
                
            //}
        }catch(Exception e){
            statusMsg = 'FAILED';
        }
        
        return statusMsg;
    }
    
    @AuraEnabled
    public static String reteriveNewEvToken(PRM_Registration_Request__c RegReq){       
        String newEVToken;
        String returnValue;        
        
        RegReq.PRM_EV_Token__c=newEVToken;
        RegReq.PRM_EV_Token_Renewed_Date__c=datetime.now();
        update RegReq;
        returnValue = System.label.PRM_EV_TOKEN_RETERIEVED;
        
        return returnValue;
    }
}