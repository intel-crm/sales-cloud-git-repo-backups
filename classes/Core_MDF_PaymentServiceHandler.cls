/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentServiceHandler 
* Version     : 1.0 
* Created Date: 31-01-2019
* Modification Log :
* Developer           HA          Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza Akhtar                   31-01-2019                    Created Core_MDF_PaymentServiceHandler class to update payment details based on the payment number
*****************************************************************************************************************************************/

public with sharing class Core_MDF_PaymentServiceHandler{
    
    /*****************************************************************************************************************************************
    Method Name: updatePaymentRecords
    @return    :                                               
    @parameters: inboundMap
    Description: Updating the Payment records based on payment number from IIM                                            
    Added By   : Hamza Akhtar  -  31-01-2019
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/
    public static void updatePaymentRecords(Map<Id,Core_Integration_Inbound_Message__c> inboundMap){
        //Checks whether the trigger is Active
        if (TriggerHandler.isActive('Core_MDF_UpdatePaymentRecordsFromIIM')) {
            List<Core_MDF_PaymentJSONParser> jsonParsedList = new List<Core_MDF_PaymentJSONParser>();
            
            //Creates a new instance of the Map class. String is the data type of keys and the values is Custom Object.
            Map<String, Core_MDF_Payment__c> paymentNoIdPaymentMap = new Map<String, Core_MDF_Payment__c>();
            
            //Creates a new instance of the Map class. String is the data type of keys and the values is Custom Object.
            Map<String, Core_MDF_Payment__c> paymentNoIdPaymentMapToBeInserted = new Map<String, Core_MDF_Payment__c>();
            
            //Create set to add all updated paymentIds
            Set<Id> paymentIdSet = new Set<Id>();
            
            if(inboundMap.size() > 0){
                for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                    //Replaces ':null' with ':""' in the payload
                    String payLoad = ciim.Core_Payload__c;
                    String ignoreNull = payLoad.replaceAll(':null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':Null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':NULL', ':""');
                    try{
                        //Calling the Core_MDF_PaymentJSONParser class
                        jsonParsedList.addAll(Core_MDF_PaymentJSONParser.parse(ignoreNull));
                    }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
                                       }
                }
            }
            try{
                for(Core_MDF_PaymentJSONParser jsonParsed : jsonParsedList){
                    
                    if((Label.Core_MDF_Payment_Status_IIM).equalsIgnoreCase(jsonParsed.core_MDF_Payment_Status_Txt.trim())){//from IIM, it will come as PAID
                        //Calling the getConvertDate method to get the correct Date format
                        Date formattedDate = getConvertDate(jsonParsed.core_MDF_Payment_Made_Dt.trim());                        
                        //Creating new payment record and assigning the JSON parsed value to the Payment fields
                        Core_MDF_Payment__c paymentRecord = new Core_MDF_Payment__c();
                        paymentRecord.Core_MDF_EFT_Nbr__c = jsonParsed.core_MDF_EFT_Nbr.trim();
                        paymentRecord.Core_MDF_Payment_Status_Txt__c = Label.Core_MDF_Payment_Status_IIM;
                        paymentRecord.Core_MDF_Payment_Made_Dt__c = formattedDate;
                        paymentNoIdPaymentMap.put((jsonParsed.core_MDF_Payment_No_Txt.trim()).toUpperCase(),paymentRecord);
                    }                    
                }
                
                //Get all the payment records based on the payment number
                if(paymentNoIdPaymentMap.size() > 0){
                    for(Core_MDF_Payment__c paymentRecord : [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c,
                                                                    Core_MDF_Payment_Status_Txt__c
                                                             FROM Core_MDF_Payment__c
                                                             WHERE Core_MDF_Payment_No_Txt__c IN : paymentNoIdPaymentMap.keySet() AND 
                                                                   Core_MDF_Payment_Status_Txt__c = : label.Core_MDF_Payment_Status LIMIT 50000]){
                        Core_MDF_Payment__c paymentRec = paymentNoIdPaymentMap.get(paymentRecord.Core_MDF_Payment_No_Txt__c);
                        //Check for changes in the record to prevent dummy update                                         
                        if(paymentRec != NULL && 
                           (paymentRecord.Core_MDF_EFT_Nbr__c != paymentRec.Core_MDF_EFT_Nbr__c || 
                           paymentRecord.Core_MDF_Payment_Status_Txt__c != paymentRec.Core_MDF_Payment_Status_Txt__c || 
                           paymentRecord.Core_MDF_Payment_Made_Dt__c != paymentRec.Core_MDF_Payment_Made_Dt__c)){
                           paymentRec.Id = paymentRecord.Id;
                           paymentIdSet.add(paymentRec.Id);    
                            paymentNoIdPaymentMapToBeInserted.put(paymentRecord.Core_MDF_Payment_No_Txt__c,paymentRec);
                        }
                    }
                }
                paymentNoIdPaymentMap = NULL;
                if(paymentNoIdPaymentMapToBeInserted.size() > 0){
                    Database.update(paymentNoIdPaymentMapToBeInserted.values(), false);
                    Id batchJobId = Database.executeBatch(new Core_MDF_SendPaidPaymentEmailToAdmin(paymentIdSet),Integer.valueOf(Label.Core_MDF_BatchSize));
                }
            }
            catch(Exception e)
            {   String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
            }
        }
    }
    
    /*****************************************************************************************************************************************
    Method Name:   getConvertDate                                          
    @return    :   Date                                            
    @parameters:   dateFormatChange
    Description:   Parsing the date which is coming from Json as a string in different format.                                        
    Added By   :   Hamza Akhtar  -  31-01-2019
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/   
    public static Date getConvertDate(String dateFormatChange)
    {
        Map<String,String> mapMonthList = new Map<String,String>();
        mapMonthList.put('JAN','01');
        mapMonthList.put('FEB','02');
        mapMonthList.put('MAR','03');
        mapMonthList.put('APR','04');
        mapMonthList.put('MAY','05');
        mapMonthList.put('JUN','06');
        mapMonthList.put('JUL','07');
        mapMonthList.put('AUG','08');
        mapMonthList.put('SEP','09');
        mapMonthList.put('OCT','10');
        mapMonthList.put('NOV','11');
        mapMonthList.put('DEC','12');
        
        List<String> dateDivided = dateFormatChange.split('-');
        String day = dateDivided.get(0);
        String month = mapMonthList.get(dateDivided.get(1).toUpperCase());
        String year = dateDivided.get(2);
        String stringDate = year + '-' + month + '-' + day;
        return Date.valueOf(stringDate);
    }
    
    /***************************************************************************************************** 
    Method Name :   sendPaidPaymentEmail
    @return     :   NULL
    @parameters :   String PaymentId,String PaymentProgram, List of EmailIds
    Description :   It sends the email to specified emails when payment status is paid.
    Added By    :   Accenture - AS
    Created Date:   02-06-2019  
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
/*
    public static void sendPaidPaymentEmail(List<String> claimCPIdList,String paymentId,String paymentProg){
        
        //Create a Mapping of localekey of user to translated labels
        Map<String,Map<String,String>> localeKeyToTranslationMap = new Map<String,Map<String,String>>();
        
        //Create a Mapping of localekey to list of userIds
        Map<String,List<Id>> localeKeyToUserIdMap = new Map<String,List<Id>>();
        
        //This list stores the label to be translated
        List<String> labelAPINames = new List<String>();
        
        //Creating List of Email Instance
        List<Messaging.SingleEmailMessage> emaiList = new List<Messaging.SingleEmailMessage>();
        
        //Create Set of userIds
        Set<Id> userIdSet = new Set<Id>();
        
        //Filtering all budget Admins
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_User__c,Core_MDF_Account__c 
                                                          FROM Core_MDF_Partner_Node_User_Mapping__c
                                                          WHERE Core_MDF_Account__c IN :claimCPIdList
                                                          AND   Core_MDF_User__r.Contact.Core_Audience__c 
                                                                Like '%Account Budget Administrator%']){
    
            userIdSet.add(pnum.Core_MDF_User__c);
        }
        
        //Populate localeKeyToUserIdMap querying the user object
        for( USER userObj : [SELECT Id,languageLocalekey,Contact.Email
                             FROM USER
                             WHERE Id IN :userIdSet]){
        
            if(localeKeyToUserIdMap.containsKey(userObj.languageLocalekey)){
                localeKeyToUserIdMap.get(userObj.languageLocalekey).add(userObj.Id);
            }
            else{
                localeKeyToUserIdMap.put(userObj.languageLocalekey, new List<String>{userObj.Id});
            }
        }
        
        //populate labelAPINames by querying the metadata       
        for(CCP_BudgetAdminNotificationLabels_Map__mdt custLabel: [SELECT Core_MDF_BudgetAdminNotificationLabel__c
                                                                   FROM   CCP_BudgetAdminNotificationLabels_Map__mdt]){
            labelAPINames.add(custLabel.Core_MDF_BudgetAdminNotificationLabel__c);
        }
        
        //Populate localeKeyToTranslationMap by calling getLocalizedLabels with different localeKeys       
        for(String langCode : localeKeyToUserIdMap.KeySet()){
            
            //Create Map of customLabel to its translation
            Map<String,String> labelApiToTranslationMap = new Map<String,String>();
            String translatedLabelValue = getLocalizedLabels(langCode,labelAPINames);
            List<String> lstLabelsSets = translatedLabelValue.split('Label_Ended');
            for(String strLabel : lstLabelsSets){
                List<String> keyVal = strLabel.split(':');
                labelApiToTranslationMap.put(keyVal[0],keyVal[1]);
            }
            
            localeKeyToTranslationMap.put(langCode,labelApiToTranslationMap);
        }
        
        String recType;
        if(paymentProg == Label.Core_MDF_CCF_RecordType){
            recType = 'Core_MDF_CCF_RecordType';
        }
        if(paymentProg == Label.Core_MDF_DCF_RecordType){
            recType = 'Core_MDF_DCF_RecordType';
        }
        if(paymentProg == Label.Core_MDF_SPCF_RecordType){
            recType = 'Core_MDF_SPCF_RecordType';
        }
        
        //Preparing Email Object
        for(String langCode : localeKeyToUserIdMap.KeySet()){

            List<Id> UserId = localeKeyToUserIdMap.get(langCode);
            System.debug('UserIds-->'+UserId);
            for(Id u : UserId){
                Map<String,String> translationMap= localeKeyToTranslationMap.get(langCode);
                String mailContent1  = translationMap.get('Core_MDF_BudgetAdminEmailSubjectforPayment');
                String mailContent2  = translationMap.get('Core_MDF_BudgetAdminSalutationforNotification');
                String mailContent3  = translationMap.get('Core_MDF_MailBodyForBudgetAdminNotification');
                String mailContent4  = translationMap.get('Core_MDF_BodyforBudgetAdminNotification');
                String mailContent5  = translationMap.get('Core_MDF_MailBody3BudgetAdminNotification');
                String mailContent6  = translationMap.get('Core_MDF_MailBody4BudgetAdminNotification');
                String mailContent7  = translationMap.get('Core_MDF_MailBody1BudgetAdminNotification');
                String mailContent8  = translationMap.get('Core_MDF_MailBody2BudgetAdminNotification');
                String mailContent9  = translationMap.get('Core_MDF_FooterBudgetAdminNotification');
                String mailContent10  = translationMap.get('Core_MDF_FooterBudgetAdminNotification1');
                String mailContent11  = translationMap.get('Core_MDF_FooterBudgetAdminNotification2');
                String mailContent12  = translationMap.get('Core_MDF_FooterBudgetAdminNotification3');
                String mailContent13  = translationMap.get('Core_MDF_FooterBudgetAdminNotification4');
                String mailContent14  = translationMap.get(recType);
                
                //Creating body of Email
                String emailBody = mailContent2 + '</br></br>' + mailContent3 + ' ' + mailContent14 + ' ' +
                                   mailContent4 + ' <a href="' + Label.Core_MDF_PFRDetailLink + paymentId + '">' +
                                   mailContent5 + '</a> ' + mailContent6 + '</br></br>' +
                                   mailContent7 + '</br>' + mailContent14 + ' ' + mailContent8 + '</br></br>';
                
                //Creating footer for Email
                String emailFooter = mailContent9 + '</br>' + 
                                    '<a href="' + Label.Core_MDF_IntelCorpLink + '">' + mailContent10 + '</a>' + ' | ' +
                                    '<a href="' + Label.Core_MDF_TradeMarkLink + '">' + mailContent11 + '</a>' + ' | ' +
                                    '<a href="' + Label.Core_MDF_PrivacyPolicyLink + '">' + mailContent12 + '</a>' + ' | ' +
                                    '<a href="' + Label.Core_MDF_CookiesLink + '">' + mailContent13 + '</a>';
                
                Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
                emailObj.setTargetObjectId(u);
                emailObj.setSaveAsActivity(false);
                emailObj.setReplyTo('wsm-postmaster@intel.com');
                emailObj.setSenderDisplayName('Intel CCP <wsm-postmaster@intel.com>');
                emailObj.setSubject(mailContent1); 
                emailObj.setHTMLBody(emailBody + emailFooter); 
                emaiList.add(emailObj);
            }
        }
        Messaging.sendEmail(emaiList); 
    }
*/  
    /***************************************************************************************************** 
    Method Name :   getLocalizedLabels
    @return     :   NULL
    @parameters :   String langCode,List<String> labelAPINames
    Description :   It translates all the provided labels.
    Added By    :   Accenture - AS
    Created Date:   02-08-2019  
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
/*
    public static String getLocalizedLabels(String langCode,List<String> labelAPINames){
        
        List<string> lstParam = new List<string>();
        Pagereference pRef = Page.Core_MDF_LabelTranslatorPage;
        String labelValue,allstring;
        
        for(integer i = 0;i< LabelAPINames.size();i++){
            lstParam.add(LabelAPINames[i]);
        }
        
        pRef.getParameters().put('label_lang', langCode);
        allstring = String.join(lstParam,',');
        pRef.getParameters().put('labels', allstring);  
        labelValue = pRef.getContent().toString();  
        return labelValue;                      
    }
*/    
    /***************************************************************************************************** 
    Method Name :   invokeEmailIds
    @return     :   void
    @parameters :        
    Description :   This is an Invocable Method for Notification
    Added By    :   Accenture - AS 
    Created Date:   02-06-2019  
    Modified By :                   Date:                          Changes:None 
    ******************************************************************************************************/
 /*   
    @InvocableMethod
    public static void invokeEmailIds(List<EmailParameter> sendEmailParams)
    {
        sendPaidPaymentEmail(sendEmailParams[0].claimCPIds,sendEmailParams[0].paymentId,sendEmailParams[0].paymentProg);
    }

*/  
    /***************************************************************************************************** 
        Class Name :   EmailParameter
        @parameters :   
        Description :   This is a wrapper class.
        Added By    :   Accenture - AS
        Created Date:   02-06-2019  
        Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
/*
    public class EmailParameter{
        
        @InvocableVariable(label = 'Claim Channel Partner' required = true)
        public List<String> claimCPIds;
        
        @InvocableVariable(label = 'PaymentId' required = true)
        public String paymentId;
        
        @InvocableVariable(label = 'Payment Program' required = true)
        public String paymentProg;
        
        }
*/    
}