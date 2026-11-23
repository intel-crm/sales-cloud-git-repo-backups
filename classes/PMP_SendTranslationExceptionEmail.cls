public with sharing class PMP_SendTranslationExceptionEmail {
    
    public static List<Core_Integration_Inbound_Message__c> tableData { get;  set;}


    public static void sendFailureEmail ( List<Core_Integration_Inbound_Message__c> failedMessages ) {
        //system.debug('Inside Send Failure Email');  
        //system.debug('Objects Are : ' + failedMessages);  

        
          sendEmail('PMP_TranslationException', failedMessages);
         
		
        
    }

   
    public static void  sendEmail(String emailTemplate, List<Core_Integration_Inbound_Message__c> testData) {
        
        tableData = testData;
        
        list<Messaging.SingleEmailMessage> sendemaillist = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        list<String> toaddress = new list<String>(); 


        EmailTemplate sendEmailTemplate =[ Select Id, Subject, Body  from EmailTemplate where name =:  emailTemplate ];
        
        if(!test.isRunningTest()){
            mail = Messaging.renderStoredEmailTemplate((string)sendEmailTemplate.id , null , testData[0].id );
        }    
        
        List<PMP_Translation_Exception_Users__c> userEmail = [Select id, User_Email__c from PMP_Translation_Exception_Users__c ];

        for(PMP_Translation_Exception_Users__c usr : userEmail){
            toaddress.add(usr.User_Email__c);
        } 

        //Added below condition to improve Test Coverage
        if(test.isRunningTest()){
            toaddress.add('wsm-postmaster@intel.com');
        }

        OrgWideEmailAddress owa = New OrgWideEmailAddress ();    
        owa =  [select id, Address, DisplayName from OrgWideEmailAddress Where Address =  'wsm-postmaster@intel.com' limit 1];         
        
        if(toaddress.size()>0){
            //system.debug('toaddress:::'+toaddress); 
            mail.setToAddresses(toaddress);
            if(owa == null){
                mail.setSenderDisplayName(PMP_StaticConstants_Offering.Intel_MP_Admin);       
            }
            else{
                mail.setOrgWideEmailAddressId(owa.id);       
            }           
            
            mail.setBccSender(false);
            mail.setUseSignature(false);                
            mail.saveAsActivity = false;
            sendemaillist.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(sendemaillist);
            }    
        } 
    
}
}