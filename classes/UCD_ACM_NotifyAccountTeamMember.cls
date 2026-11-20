/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_NotifyAccountTeamMember
Author And Date  : Rohit Podder, 14 DEC 2025
Function         : This class is for sending email notification to the Account Team Members if the account owner gets inactivated
*********************************************************************************************************************/
public without sharing class UCD_ACM_NotifyAccountTeamMember{
    //public static Map<Id,String> mapAccountTeamMemberIdName = new Map<Id,String>();
    
    @invocableMethod(label = 'Send email to Account Team Members' Description = 'If the account owner gets inactivated then all account team members will receive an email')
    public static void getAccountTeamMembers(List<Id> userId) {
        //System.debug(userId);
        Map<Id,List<Account>> mapUserEmailAccounts = new Map<Id,List<Account>>();
        List<Account> listAccounts = [Select ID,Name, OwnerId, Owner.Name, (Select Id,userId, user.FirstName, user.IsActive from AccountTeamMembers) From Account 
                                      Where ownerId In :userId];
        //System.debug(listAccounts);
        try{
            if (!listAccounts.isEmpty() && listAccounts.size() > 0) {
                for (Account acc : listAccounts) {
                    if (acc.AccountTeamMembers != null && acc.AccountTeamMembers.size() > 0) {
                        for (AccountTeamMember acm : acc.AccountTeamMembers) {
                            if (acm.user.IsActive == true) {
                                //mapAccountTeamMemberIdName.put(acm.userId, acm.user.FirstName);
                                if (mapUserEmailAccounts.containsKey(acm.userId)){
                                    mapUserEmailAccounts.get(acm.userId).add(acc);
                                } else {
                                    mapUserEmailAccounts.put(acm.userId, new List<Account>{acc});
                                }
                            }
                        }
                    }
                }
                if(!mapUserEmailAccounts.isEmpty() && mapUserEmailAccounts.size()>0) {
                    sendNotificationEmails(mapUserEmailAccounts);
                }
            }
        }catch(Exception e){
            //System.debug(e.getMessage());
            UCD_ACM_Logger.error('UCD_ACM_NotifyAccountTeamMember','execute',e.getMessage(), null);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    private static void sendNotificationEmails(Map<Id,List<Account>> mapUserEmailAccounts) {
        //Send emails if there are account team members
        List<String> listFailedEmails = new List<String>();
        String htmlEmailBodytoSent;
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String recordUrl;
        String subject = 'Action Required: Account Owner Inactivated – Ownership Review Needed';
        
        for (Id userId : mapUserEmailAccounts.keySet()){
            htmlEmailBodytoSent = 'Hello Account Team,'+'<br> We’re writing to inform you that the Account Owner for the account listed below has been inactivated.'+'<br><br><b>Account Details :</b>';
            
            htmlEmailBodytoSent += '<table style="width:100%; Border:1px Solid Black; border-collapse: collapse"><tr><th style="Border:1px Solid Black; border-collapse: collapse">Account Name</th><th style="Border:1px Solid Black; border-collapse: collapse">Account Id</th><th style="Border:1px Solid Black; border-collapse: collapse">Previous Account Owner</th><th style="Border:1px Solid Black; border-collapse: collapse">Owner Status</th><th style="Border:1px Solid Black;border-collapse: collapse">Effective Date</th></tr>';
            
            for (Account acc : mapUserEmailAccounts.get(userId)) {
                recordUrl = baseUrl + '/lightning/r/Account/' + acc.Id + '/view';
                htmlEmailBodytoSent += '<tr><td style="Border:1px Solid Black; border-collapse: collapse"><a href='+recordUrl+'>'+acc.Name+'</a></td><td style="Border:1px Solid Black; border-collapse: collapse">'+acc.Id+'</td><td style="Border:1px Solid Black; border-collapse: collapse">'+acc.Owner.Name+'</td><td style="Border:1px Solid Black; border-collapse: collapse">Inactive</td><td style="Border:1px Solid Black; border-collapse: collapse">'+DateTime.now().format('dd-MM-yyyy')+'</td></tr>';
            }
            htmlEmailBodytoSent += '</table>';
            htmlEmailBodytoSent += label.Email_notification_template;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(userId);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHTMLBody(htmlEmailBodytoSent);
            email.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
            listEmails.add(email);
        }
        
        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(listEmails);
        
        for (Messaging.SendEmailResult ms : emailResult) {
            if(!ms.isSuccess()) {
                listFailedEmails.add(String.join(ms.getErrors(),' '));
            }
        }
        if (!listFailedEmails.isEmpty() && listFailedEmails.size() > 0) {
            UCD_ACM_Logger.information('UCD_ACM_NotifyAccountTeamMember','finish',String.join(listFailedEmails,','), null);
            UCD_ACM_Logger.setLogDetails();
        }
    }
}