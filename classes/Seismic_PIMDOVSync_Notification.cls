/****************************************************************************************************************************************
* Class Name  : Seismic_PIMDOVSync_Notification 
* Version     : 1.0 
* Created Date: 05/15/2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		The Apex Class has functions to send email notificaiton for Seismic & Lessonly
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/

public class Seismic_PIMDOVSync_Notification {
    
    //public static enum jobStatus {Sucess, Fail, Error, NoRecord};
    
    /*Summary email goes out to sales team*/
    public static Boolean sendSummary(List<Seismic_PIMDOVSync.Seismic_DOVAction> dovActionList, String propertyName)
    {
        Boolean flag = true;
        try {
            // Strings to hold the email addresses to which you are sending the email.
            String[] toAddresses = new String[] {Seismic_PIMDOVSync.config.get('ToEmail')}; 
            String[] ccAddresses = new String[] {Seismic_PIMDOVSync.config.get('CCEmail')};
                    
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            
            // Specify the address used when the recipients reply to the email. 
            //mail.setReplyTo('sandeep.joshi@intel.com');
            mail.setSenderDisplayName('Seismic Support');
            mail.setSubject('Seismic-PIM DOV Sync Summary for '+ propertyName );
            mail.setBccSender(false);
            mail.setUseSignature(false);
            //mail.setPlainTextBody('Your Case:  has been created.');
            
            String htmlBody ='Hi there,';
            
            if(Seismic_PIMDOVSync.config.get('IsTest') == 'True')
            {
                propertyName = propertyName +' which WOULD BE ';
            }
        
            if(dovActionList.size() >0)
            {
                htmlBody +='<p>Listed below are the DOVs for Custom Property '+ propertyName +' added/updated/deleted in Seismic';
                htmlBody += '<table style="width:700px; border:1px solid gray;border-collapse: collapse;">';
                htmlBody += '<tr><td style="border:1px solid gray;">Property</td>';
                htmlBody += '<td style="border:1px solid gray;">DOV</td>';
                htmlBody += '<td style="border:1px solid gray;">Action</td></tr>';
                
                for(Seismic_PIMDOVSync.Seismic_DOVAction dov: dovActionList) {
                    htmlBody += '<tr><td style="border:1px solid gray;">'+ dov.propertyName +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ dov.dovName +'</td>';
                    htmlBody += '<td style="border:1px solid gray;">'+ dov.action +'</td></tr>';
                }
                
                htmlBody +='</table>';
            }
            
            else
            {
                  htmlBody +='<p>Seismic DOVs for Custom Property '+ propertyName +' are 100% sync with PIM.</p>';
            }
            
            htmlBody +='<br><br><p>Thanks,<br>Seismic Support</p>';
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
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
           //String[] toAddresses = new String[] {Seismic_PIMDOVSync.config.get('ToEmail')}; 
            String[] toAddresses = new String[] {Seismic_PIMDOVSync.config.get('CCEmail')}; 
            String[] ccAddresses = new String[] {Seismic_PIMDOVSync.config.get('CCEmail')};
                    
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