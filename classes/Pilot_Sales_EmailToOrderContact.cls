/*********************************************************************************************************************
Class Name    : Pilot_Sales_EmailToOrderContact
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Subhanku Ghosh		2/09/2021				Pilot Project for testing framework.
* *********************************************************************************************************************/
public without sharing class Pilot_Sales_EmailToOrderContact {
    public static final String TEMPLATE_NAME ='Sales_Order_Creation_VF';
    public static final String ORGWIDE_EMAIL='wsm-postmaster@intel.com';
    
    //This method will trigger email to primary contact of Order's sold to Account
    /* Commenting the code - Bharath - US1044910
    public static void sendEmails(List<Order> orderList){
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
        Set<Id> soldToAccIdSet = new Set<Id> ();//Account ID set.
        Map<Id,Id> accToContactMap = new Map<Id,Id>();//map of account Id and contact Id
        Map<Id,Set<String>> accToEmailMap =new  Map<Id,Set<String>>();//map of Account ID and set of email Id from primary contacts
        
        for(Order order:orderList){//loop start here...
            soldToAccIdSet.add(order.AccountId);//adding of order's Sold to Account 
        }//loop ends here..
        
        if(soldToAccIdSet.size()>0){
           for(Contact con :[Select Id, Email, Core_Primary_Contact__c ,AccountId from Contact where Core_Primary_Contact__c=true AND AccountId IN:soldToAccIdSet ] ){//loop start here..
            accToContactMap.put(con.AccountId,con.Id);//adding account Id and correspoding contact
            if(accToEmailMap.containsKey(con.AccountId)){//this block will add multiple primary contact email for an account.
                Set<String> emailSet= accToEmailMap.get(con.AccountId); 
                emailSet.add(con.Email);
                accToEmailMap.put(con.AccountId,emailSet);//updating Map of existing Account Id with Primary contact email set .
            }
            else{
                Set<String> emailSet= new Set<String>();
                emailSet.add(con.Email);//adding email of primary contact
                accToEmailMap.put(con.AccountId,emailSet);//Map of Account Id and Primary contact email for first time.
            }
        }//loop ends here..
         
        }
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];//query email address 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =:TEMPLATE_NAME];//querying email template
        
        for(Order order:orderList){//loop start here..
            if(accToEmailMap.containsKey(order.AccountId)){
                Set<String> emailSet = accToEmailMap.get(order.AccountId);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();//creating email message instance for primary contact on newly created order.
                List<String> sendTo = new List<String>();
                sendTo.addAll(emailSet);
                mail.setToAddresses(sendTo);
                mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
                mail.setTargetObjectId(accToContactMap.get(order.AccountId)); 
                mail.setWhatId(order.Id);
                mail.setUseSignature(false);
                mail.setBccSender(false);
                //mail.setSenderDisplayName('Intel Support');
                mail.setTemplateID(emailTemplate.Id); 
                mails.add(mail);
            }//loop ends here...

        }
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);//sending mail 
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
    }
    */
    // US1044910 - The method below will send emails to Order Creator with Products that are available in the Order
    public static void sendEmailToOrderCreator(List<Order> ordersList){

        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>(); 
        Map<Id,String> userIdToUserEmail = new Map<Id,String>();
        Set<Id> userIds = new Set<Id>();

        for(Order order: ordersList){            
            userIds.add(order.CreatedById);
        }
        if(!userIds.isEmpty()){
            Map<Id, User> userIdToUser = new Map<Id, User>(
            SEL_User.newInstance().selectById(userIds));

            for(Id id : userIdToUser.keySet()){
                User user= userIdToUser.get(id);
                userIdToUserEmail.put(id, user.Email);
            }             

        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];//query email address 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =:TEMPLATE_NAME];//querying email template
                  
        for(Order order: ordersList){  
            if(userIdToUser.containsKey(order.CreatedById)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(userIdToUserEmail.get(order.CreatedById)); 
            mail.setToAddresses(sendTo);
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id); 
            mail.setTargetObjectId(order.CreatedById); 
            mail.setWhatId(order.Id);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setTemplateID(emailTemplate.Id); 
            mails.add(mail);
            }
        }
      }
        if(mails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);//sending mail 
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
   
    }
    
}