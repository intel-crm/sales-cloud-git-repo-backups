public with sharing class UCD_ACM_ContactMoveHandler {

    public static void contactUpdateTrigger(System.TriggerOperation operation,List<Contact_Move_Governance__c> ContactMoveGovernances,Map<Id,Contact_Move_Governance__c> ContactMoveGovernanceTypeById){
        List<Contact> contacts = new List<Contact>();
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        if(operation == System.TriggerOperation.AFTER_UPDATE ){

            For(Contact_Move_Governance__c ContactMoveGovernance :ContactMoveGovernances){

                if(ContactMoveGovernance.Is_Approved__c == true && ContactMoveGovernanceTypeById.get(ContactMoveGovernance.Id).Is_Approved__c == false   ){
                    Contact currContact1 = new Contact();
                    currContact1.Id = ContactMoveGovernance.Contact__c;
                    currContact1.Core_ERPM_Integration_Status__c = 'Pending';
                    currContact1.Core_AGS_Integration_Status__c = 'Pending';
                    currContact1.AccountId = ContactMoveGovernance.Account__c;
                    currContact1.Core_Account_Changeable__c= true;
                    Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT = true;

                    contacts.add(currContact1);
                }

                if((ContactMoveGovernance.Is_Approved__c == true && ContactMoveGovernanceTypeById.get(ContactMoveGovernance.Id).Is_Approved__c == false) ||  
                (ContactMoveGovernance.Is_Rejected__c == true  && ContactMoveGovernanceTypeById.get(ContactMoveGovernance.Id).Is_Rejected__c == false )){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    List<String> sendTo = new List<String>();
                    sendTo.add('ankit1x.sharma@intel.com');
                    sendTo.add('anand.divakaran@intel.com');
                    mail.setToAddresses(sendTo);

                    mail.setReplyTo('ankit.sharma76@infosys.com');

                    List<String> ccTo = new List<String>();
                    ccTo.add('ankitsharmajb1@gmail.com');
                    mail.setCcAddresses(ccTo);

                    mail.setSubject('Contact move is Approved');
                    String body = 'Dear, ';
                    body += 'Contact '+ ContactMoveGovernance.Contact_Email__c+'move is Approved..';
                    body += 'Message==>'+ ContactMoveGovernance.New_Comments__c;
                    mail.setHtmlBody(body);

                    System.debug('mail==>'+mail);
                    mails.add(mail);

            }
                
            }


            if(contacts.size()>0){
                update contacts;
            }

            System.debug('mails.size()==>'+mails.size());
            /*if(mails.size()>0){
                try{
                    System.debug('try==>');
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.==>');
                    } else {
                        System.debug('The email failed to send:==>' + results[0].errors[0].message);
                    }
                    System.debug('try2==>');
                }catch(Exception ex){
                    System.debug('Excception==>'+ ex.getMessage());
                }
            }*/
        }

    }

    public static void contactMoveGovernanceUpdateTrigger(System.TriggerOperation operation,List<Contact_Move_Governance__c> ContactMoveGovernances,Map<Id,Contact_Move_Governance__c> ContactMoveGovernanceTypeById){
        List<Contact_Move_Governance__c> ContactMoveGovernanceList = new List<Contact_Move_Governance__c>();

        if(operation == System.TriggerOperation.BEFORE_UPDATE ){

            List<Id> contactMoveGovernanceIdList = new List<Id>();
            Map<Id,Id> custMoveGovIdProcessInstanceId = new Map<Id,Id>();
            Map<Id,List<ProcessInstanceStep>> piPiStepMap = new Map<Id,List<ProcessInstanceStep>>();

            For(Contact_Move_Governance__c ContactMoveGovernance :ContactMoveGovernances){

                if((ContactMoveGovernance.Is_Approved__c == true && ContactMoveGovernanceTypeById.get(ContactMoveGovernance.Id).Is_Approved__c == false) ||  
                    (ContactMoveGovernance.Is_Rejected__c == true  && ContactMoveGovernanceTypeById.get(ContactMoveGovernance.Id).Is_Rejected__c == false )){
                    contactMoveGovernanceIdList.add(ContactMoveGovernance.Id);
                }

            }

            for(ProcessInstance pi : [SELECT Id,TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN: contactMoveGovernanceIdList]){ 
                custMoveGovIdProcessInstanceId.put(pi.TargetObjectId, pi.Id);
            }

            System.debug('custMoveGovIdProcessInstanceId--->' + custMoveGovIdProcessInstanceId);

            for(ProcessInstanceStep piStep : [SELECT Id,ActorId,StepStatus,ProcessInstanceId,Comments FROM ProcessInstanceStep 
                                                WHERE ProcessInstanceId IN: custMoveGovIdProcessInstanceId.values() AND StepStatus != 'NoResponse' ORDER BY CreatedDate ASC]){
                if(piPiStepMap.containsKey(piStep.ProcessInstanceId)){
                    piPiStepMap.get(piStep.ProcessInstanceId).add(piStep);
                }else{
                    piPiStepMap.put(piStep.ProcessInstanceId, new List<ProcessInstanceStep>{piStep});
                }
            }

            System.debug('piPiStepMap--->' + piPiStepMap);
            System.debug('piPiStepMapSize--->' + piPiStepMap.Size());



            for(Contact_Move_Governance__c ContactMoveGovernance :ContactMoveGovernances){
                if(custMoveGovIdProcessInstanceId.containsKey(ContactMoveGovernance.Id) && custMoveGovIdProcessInstanceId.get(ContactMoveGovernance.Id) != NULL){
                    Id processInstanceId = custMoveGovIdProcessInstanceId.get(ContactMoveGovernance.Id);
                    if(piPiStepMap.containsKey(processInstanceId) && piPiStepMap.get(processInstanceId) != NULL){

                        for(integer i = 1; i < piPiStepMap.get(processInstanceId).Size() ; i++){
                            
                            if( piPiStepMap.get(processInstanceId)[i] != NULL){
                               // ContactMoveGovernance.New_Comments__c = piPiStepMap.get(processInstanceId)[i].Comments;
                            }
                        }
                    }
                }
            }

        }
    }

    public static void contactMoveGovernanceAfterInsertTrigger(System.TriggerOperation operation,List<Contact_Move_Governance__c> ContactMoveGovernances){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        if(operation == System.TriggerOperation.AFTER_INSERT ){
            For(Contact_Move_Governance__c ContactMoveGovernance :ContactMoveGovernances){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    List<String> sendTo = new List<String>();
                    sendTo.add('ankit1x.sharma@intel.com');
                    sendTo.add('anand.divakaran@intel.com');
                    sendTo.add('reshmax.rachita.mishra@intel.com');
                    sendTo.add('monishax.pandurangan@intel.com');
                    mail.setToAddresses(sendTo);

                    List<String> ccTo = new List<String>();
                    ccTo.add('ankit1x.sharma@intel.com');
                    mail.setCcAddresses(ccTo);

                    mail.setSubject(' Approval Request');
                    String body = 'Dear Approver, Please Approve/reject this request: ';
                   body += 'https://intel--crmdevsls3.lightning.force.com/lightning/r/Contact_Move_Governance__c/' + ContactMoveGovernance.Id +'/view' ;
                 
                    mail.setHtmlBody(body);

                    System.debug('mail==>'+mail);
                    mails.add(mail);




                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();

                    List<String> sendTo2 = new List<String>();
                    String currentuserEmail =  UserInfo.getUserEmail();
                    sendTo2.add(currentuserEmail);
                    mail2.setToAddresses(sendTo2);

                    List<String> ccTo2 = new List<String>();
                    ccTo2.add('ankit1x.sharma@intel.com');
                    ccTo2.add('anand.divakaran@intel.com');
                    ccTo2.add('reshmax.rachita.mishra@intel.com');
                    mail2.setCcAddresses(ccTo2);

                    mail2.setSubject(' Approval Request Submit Successfully');
                    String body2 = 'Approval Request Submit Successfully: for contact: '+ ContactMoveGovernance.Contact_Email__c;
                 
                    mail2.setHtmlBody(body2);

                    System.debug('mail2==>'+mail2);
                    mails.add(mail2);
            }

            if(mails.size()>0){
                    try{
                        System.debug('try==>');
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.==>');
                        } else {
                            System.debug('The email failed to send:==>' + results[0].errors[0].message);
                        }
                        System.debug('try2==>');
                    }catch(Exception ex){
                        System.debug('Excception==>'+ ex.getMessage());
                    }
            }
        }

    }

    public static void contactMoveGovernanceBeforeInsertTrigger(System.TriggerOperation operation,List<Contact_Move_Governance__c> ContactMoveGovernances){
        if(operation == System.TriggerOperation.BEFORE_INSERT ){
            For(Contact_Move_Governance__c ContactMoveGovernance :ContactMoveGovernances){

                Integer casewithproject = 0;
                Integer caseWithoutProject = 0;
                for(Case c:  [Select id,Product.name,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,
                      Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c, 
                      Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, 
                      Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name 
                      FROM Case  
                      Where contactId =: ContactMoveGovernance.Contact__c AND RecordType.Name != 'CEP Case' ])
                {
                    //See if it has any GEC case found, do not reset it is already set.
                    if( c.Core_IPS_GEC_Case__c && String.isNotBlank(c.Core_IPS_GEC_Status__c) &&  c.Core_IPS_GEC_Status__c.startsWith('On Hold')){
                       // ContactMoveGovernance.addError(' GEC Case Found, moving contact is not allowed.');
                        Continue;
                    }
                    if(c.Core_IPS_Project_Case__c != null){
                        casewithproject++;
                    }else {
                        caseWithoutProject++;
                    }             
                }

                ContactMoveGovernance.Case_with_Project__c = casewithproject;
                ContactMoveGovernance.Case_without_Project__c = caseWithoutProject;


                
            }
        }
    }

    
}