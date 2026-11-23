/****************************************************************************************************
Apex Class Name : PSG_EmailMessageLog
Version         : 1.0 
Created Date    : 8/18/2023
Function        : This class is used for storing all the Emails that are triggering from Apex
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               8/18/2023                Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_EmailMessageLog {
    /************************************************************************************************************
    *Method Name : createEmailMessageRecord
    *Created Date: 08/18/2023
    *Author: Bishal Singh
    *Description : Performs Insertion operation on Email Message Object
    ************************************************************************************************************/
    /*public static void createEmailMessageRecord(Map<String, List<String>> relatedValues, String fromAddress, String fromName, List<String> toIds, List<String> toAddressList, List<String> ccAddressList, List<String> bccAddressList) {
        try{
            if (relatedValues.isEmpty()) {
                return;
            }
            List<EmailMessage> emailMessages = new List<EmailMessage>();
            for (Integer i = 0; i < relatedValues.get('relatedToId').size(); i++) {
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.status = '3'; // email was sent
                emailMessage.relatedToId = relatedValues.get('relatedToId')[i];
                emailMessage.fromAddress = fromAddress;
                emailMessage.fromName = fromName;
                emailMessage.subject = relatedValues.get('subject')[i];
                emailMessage.htmlBody = relatedValues.get('htmlBody')[i];
                if (!toIds.isEmpty() && toIds != null) {
                    emailMessage.toIds = toIds;
                }
                emailMessage.toAddress = getEmailListFromList(toAddressList);
                emailMessage.CcAddress = getEmailListFromList(ccAddressList);
                emailMessage.BccAddress = getEmailListFromList(bccAddressList);
                emailMessages.add(emailMessage);
            }
            
            insert emailMessages;
            
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_EmailMessageLog','createEmailMessageRecord',e.getMessage(),'','EmailMessage','Low',relatedValues.get('relatedToId')[0]);
        }
    }
    
    private static String getEmailListFromList(List<String> addressList) {
        if (addressList == null || addressList.isEmpty()) {
            return '';
        }
        return String.join(addressList, ',');
    }*/
}