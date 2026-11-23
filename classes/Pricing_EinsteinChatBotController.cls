public class Pricing_EinsteinChatBotController {
    
    public class EmailInput { 
     
        @InvocableVariable( required=true ) 
        public String Employee_Name; 
        
        @InvocableVariable( required=true ) 
        public String employeeEmail; 
        
        @InvocableVariable( required=true ) 
        public String Employee_Company; 
        
        @InvocableVariable( required=true ) 
        public String Employee_Role; 
         
    }

    
	@InvocableMethod(label='Send Email for Contact Creation') 
    public static void sendEmailForContactCreation(List<EmailInput> listInputs ) { 
     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'biswaranjan.pradhan@intel.com','lakshmi.deepthi.duvvuri@intel.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Intel Quote Request Support');
        mail.setSubject('New Contact creation request');

        mail.setHtmlBody('Please find below details for NEW contact creation:<p>'+
                         'Name: <b>'+ listInputs[0].Employee_Name +' </b><p>'+
                         'Email: <b>'+ listInputs[0].employeeEmail +' </b><p>'+
                         'Company: <b>'+ listInputs[0].Employee_Company +' </b><p>'+
                         'Role: <b>'+ listInputs[0].Employee_Role +' </b><p>');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
 
}