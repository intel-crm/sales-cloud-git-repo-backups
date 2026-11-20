/****************************************************************************************************************************************
* Class Name  : Seismic_UserDeletionNotification 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex Class has functions to send email notificaiton for Seismic & Lessonly 
*****************************************************************************************************************************************/

public class Seismic_UserDeletionNotification {
    
    //public static enum jobStatus {Sucess, Fail, Error, NoRecord};
    
    /*Summary email goes out to sales team*/
    public static Boolean sendSummary(Integer loadID)
    {
        Boolean flag = true;
        try {
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {Seismic_UserDeletion.config.get('SalesContentEmablement_Dlist')}; 
            String[] ccAddresses = new String[] {Seismic_UserDeletion.config.get('CCEmail')};
                    
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            // Specify the address used when the recipients reply to the email. 
            //mail.setReplyTo('sandeep.joshi@intel.com');
            mail.setSenderDisplayName('Seismic Support');
            mail.setSubject('Seismic & Lessonly User Deletion Summary' );
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setPlainTextBody('Your Case:  has been created.');
            
            String htmlBody ='Hi there,';
            
            List<SeismicUserDeletion_User__c> userList = [SELECT Email__c FROM SeismicUserDeletion_User__c WHERE Load_ID__c =: loadID AND Deleted_In_Seismic__c = true];
            List<SeismicUserDeletion_User__c> userList2 = [SELECT Email__c FROM SeismicUserDeletion_User__c WHERE Load_ID__c =: loadID AND Deleted_In_Lessonly__c = true];

            if(userList.size() >0 ||  userList2.size() >0)
            {
                htmlBody +='<p>Listed below are the users who were deleted from Seismic.';
                htmlBody += '<table style="width:700px; border:1px solid gray;border-collapse: collapse;"><tr><td>Email</td></tr>';
                
                for(SeismicUserDeletion_User__c item: userList) {
                    htmlBody += '<tr><td style="border:1px solid gray;">'+ item.Email__c +'</td></tr>';
                }
                
                htmlBody +='</table><br><br>';
                
                if(userList2.size() >0){
                    htmlBody +='<p>Listed below are the users who were deleted from Lessonly.';
                    htmlBody += '<table style="width:700px; border:1px solid gray;border-collapse: collapse;"><tr><td>Email</td></tr>';
                    
                    for(SeismicUserDeletion_User__c item2: userList2) {
                        htmlBody += '<tr><td style="border:1px solid gray;">'+ item2.Email__c +'</td></tr>';
                    }
                    
                    htmlBody +='</table>';
                }
            }
            
            else
            {
                  htmlBody +='<p>Seismic & Azure AD Groups are 100% sync. No record found to syn & no action required.';
            }
            
            htmlBody +='<br><br><p>Thanks,<br>Seismic Support</p>';
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest() && loadID == 1) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred in sendSummary: ' + e.getMessage());
            flag = false;
        }
        return flag;
    }
    
    /*Summary email to development team*/
    public static Boolean sendDevTeamSummary(Integer loadID)
    {
        Boolean flag = true;
        try {
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {Seismic_UserDeletion.config.get('DeveloperEmail')}; 
            String[] ccAddresses = new String[] {Seismic_UserDeletion.config.get('CCEmail')};
                    
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            // Specify the address used when the recipients reply to the email. 
            //mail.setReplyTo('sandeep.joshi@intel.com');
            mail.setSenderDisplayName('Seismic Support');
            mail.setSubject('Seismic & Lessonly User Deletion Summary' );
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setPlainTextBody('Your Case:  has been created.');
            
            String htmlBody ='Hi there,';
            
            List<SeismicUserDeletion_User__c> userList = [SELECT Load_ID__c, Email__c, Deleted_In_Seismic__c, Deleted_In_Lessonly__c, Status__c FROM SeismicUserDeletion_User__c WHERE Load_ID__c =: loadID];
         
            if(userList.size() >0)
            {
                htmlBody +='<p>Seismic & Lessonly Sync Summary';
                htmlBody += '<table style="width:700px; border:1px solid gray;border-collapse: collapse;"><tr><td style="border:1px solid gray;">Load #</td> <td>Email</td> <td style="border:1px solid gray;">Deleted in Seismic</td> <td style="border:1px solid gray;">Deleted in Lessonly</td> <td style="border:1px solid gray;">Status</td></tr>';
                
                for(SeismicUserDeletion_User__c item: userList) {
                    htmlBody += '<tr>';
                    htmlBody += '<td style="border:1px solid gray;">'+ item.Load_ID__c +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ item.Email__c +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ item.Deleted_In_Seismic__c +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ item.Deleted_In_Lessonly__c +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ item.Status__c +'</td>';
                    htmlBody += '</tr>';
                }
                
                htmlBody +='</table><br><br>';
            }
            else
            {
                  htmlBody +='<p>Seismic & Azure AD Groups are 100% sync. No record found to syn & no action required.';
            }
            
            htmlBody +='<br><br><p>Thanks,<br>Seismic Support</p>';
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest() && loadID == 1) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(Exception e) {
            System.debug('The following exception has occurred in sendSummary: ' + e.getMessage());
            flag = false;
        }
        return flag;
    }
    
    /*Error email goes out to developer to take */
    public static Boolean senderrorEmail(String subject, String errorMessage)
    {
        Boolean flag = true;
        try {
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {Seismic_UserDeletion.config.get('DeveloperEmail')}; 
            String[] ccAddresses = new String[] {Seismic_UserDeletion.config.get('CCEmail')};
                    
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            // Specify the address used when the recipients reply to the email. 
            //mail.setReplyTo('sandeep.joshi@intel.com');
            mail.setSenderDisplayName('Seismic Support');
            mail.setSubject(subject);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setPlainTextBody('Your Case:  has been created.');
            
            String htmlBody ='Hi there,';
            htmlBody += '<table style="width:700px; border:1px solid gray;border-collapse: collapse;">';
            htmlBody += '<tr><td>'+ errorMessage +'</td></tr>';
            htmlBody +='</table>';
            
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest() && subject == 'Test Exception Block') {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } 
        catch(Exception e) {
            System.debug('The following exception has occurred in notifyFailure: ' + e.getMessage());
            flag = false;
        }
        return flag;
    }
}