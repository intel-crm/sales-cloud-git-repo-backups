/*********************************************************************************************************************
Class Name    : Sales_EmailToOrderContact
Version       : 1.0
Created Date  : Feb 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           05-Feb-2021              US862251:Email to Contact after order creation
* Bharath Kumar Indla      07-Jun-2021              US1044910 - Email to Order Creator after order creation.
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_EmailToOrderContact {
    /*public static final String TEMPLATE_NAME ='Sales_Order_Creation_VF';
    public static final String ORGWIDE_EMAIL='wsm-postmaster@intel.com';
    public static void sendEmailToOrderCreator(List<Order> ordersList){
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>(); 
        Map<Id,String> userIdToUserEmail = new Map<Id,String>();
        List<Id> userIds = new List<Id>();
        for(Order order: ordersList){            
            userIds.add(order.CreatedById);
        }
        if(!userIds.isEmpty()){
            Map<Id, User> userIdToUser = new Map<Id, User>(
                [SELECT Id, Email FROM User WHERE Id IN:userIds]);
            for(Id id : userIdToUser.keySet()){
                User user= userIdToUser.get(id);
                userIdToUserEmail.put(id, user.Email);
            }             
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =:TEMPLATE_NAME];
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
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        }
    }*/
}