global class Core_IPS_MoveContactWithBatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    public Set<Id> allProcessedcaseId=null; 
    public Set<Id> allFailedcaseId=null; 
    public Map<Id,Case> mapAllProcessedCase=new Map<Id,Case>();
    
    public  Contact currContact=null;
    public  Contact targetAccount=null;
    public  String currContactName=null;
    public  String targetAccountName=null;
    
    //code added as per US120420
    public ID targetContId{get;set;}
    public String targetContactName=null;
   
    // Trigger Variables
    public set<Id> stAccId = new set<Id>();
    public set<Id> stConId = new set<Id>();
    public String batchProcessedFrom='';
    Public String errorOccured='The following exception has occurred: ';
    Public Integer failedRun=0;
    Public Integer totalNum=0;
    Public Boolean failedCase=false;
    public Core_IPS_MoveContactWithBatch(Contact currContact,Contact targetAccount){
        this.currContact=currContact;
        this.targetAccount=targetAccount;
        this.stConId=new Set<Id>{currContact.id};
        this.stAccId=new Set<Id>{targetAccount.accountid};
        this.currContactName=currContact.name;
        batchProcessedFrom='PageController';
    }
    
    public Core_IPS_MoveContactWithBatch(set<Id> stConId, set<Id> stAccId){
        this.stConId=stConId;
        this.stAccId=stAccId;
        batchProcessedFrom='ContactTrigger';
    }
   
    //Code modified as per US120420 
    public Core_IPS_MoveContactWithBatch(Contact currContact,Contact targetAccount,Id targetContId){
        
        this.currContact=currContact;
        this.targetContId=targetContId;
        this.targetAccount=targetAccount;
        this.stConId=new Set<Id>{currContact.id};
        this.stAccId=new Set<Id>{targetAccount.accountid};
        this.currContactName=currContact.name;
        batchProcessedFrom='PageContact';
    }
       
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        allProcessedcaseId=new Set<Id>();
        allFailedcaseId=new Set<Id>();
        String str='';
       /* if(failedCase){*/
            str='Select id,Product.name,subject,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,'+
                      'Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c, '+
                      'Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, '+
                      'Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name '+
                      'FROM Case Where contactId IN :stConId AND AccountId NOT IN :stAccId AND RecordType.Name != \'CEP Case\' and (Core_IPS_Project_Case__c=\'\' OR Core_IPS_Project_Case__c = null) limit 10000';
       /* }else{
            str='Select id,Product.name,subject,caseNumber,status,Contactid,Core_IPS_Supported_Product__r.Name,Contact.Name,contact.Accountid,Core_IPS_Product_Org1__r.Name,'+
                      'Core_IPS_Project_Case__r.Name,Core_IPS_Project_Case__c,AccountId,Core_IPS_Product_Org1__c, Core_IPS_GEC_Case__c, '+
                      'Core_IPS_Supported_Product__c,Core_IPS_GEC_Status__c,asset.status,asset.recordtypeid,Core_IPS_Supported_Product__r.Core_IPS_Public_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c, '+
                      'Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Owner.Name '+
                      'FROM Case Where contactId IN :stConId AND RecordType.Name != \'CEP Case\' and (Core_IPS_Project_Case__c=\'\' OR Core_IPS_Project_Case__c = null) limit 10000';
        }*/
        return Database.getQueryLocator(str);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        // process each batch of records
        Map<Id,Case> mapprocessedCase=new Map<Id,Case>(caseList);
        mapAllProcessedCase.putAll(mapprocessedCase);
       
        if('PageController'.equals(batchProcessedFrom)){
            Core_IPS_MoveContactWithLargeCases.allCaseList=new List<case>();
            Core_IPS_MoveContactWithLargeCases.updateAssetsToCase(caseList,targetAccount.accountid);
            if(Core_IPS_MoveContactWithLargeCases.allCaseList.size()>0){
                try{
                    totalNum +=1;
                    /* if(totalNum>0)
                        throw new BatchException();*/
                    allProcessedcaseId.addAll(mapprocessedCase.keySet());
                    update Core_IPS_MoveContactWithLargeCases.allCaseList; 
                }catch(Exception e){
                     errorOccured += e.getMessage();
                     failedRun +=1;
                     allFailedcaseId.addAll(mapprocessedCase.keySet());
                     allProcessedcaseId.removeAll(allFailedcaseId);
                }
            }
        }
        //code modified as per US120420
        if('PageContact'.equals(batchProcessedFrom)){
            List<Case> updateCases = new List<Case>();
            for(Case c : CaseList){
                c.contactId = targetContId;
                updateCases.add(c);
            }
            try{
                totalNum +=1;
                /*if(totalNum>0)
                    throw new BatchException();*/
                allProcessedcaseId.addAll(mapprocessedCase.keySet());
                update updateCases;
            }catch(Exception e){
                     errorOccured += e.getMessage();
                     failedRun +=1;
                     allFailedcaseId.addAll(mapprocessedCase.keySet());
                     allProcessedcaseId.removeAll(allFailedcaseId);
            }
        }
        
      /*  if('ContactTrigger'.equals(batchProcessedFrom)){
            Core_Contact_AccountChange_Handler.caseListTobeUpdated=new List<case>(); 
            Core_Contact_AccountChange_Handler.updateAssetsToCase(caseList,stAccId);
            if(Core_Contact_AccountChange_Handler.caseListTobeUpdated.size()>0 || Test.isRunningTest()){
                try{
                    //if(totalNum>0)
                      //  throw new BatchException();
                    totalNum +=1;
                    update Core_Contact_AccountChange_Handler.caseListTobeUpdated; 
                }catch(Exception e){
                     allProcessedcaseId.addAll(mapprocessedCase.keySet());
                     errorOccured += e.getMessage();
                     failedRun +=1;
                }
            }
        }*/
    }    
    global void finish(Database.BatchableContext bc){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            if(Account.SObjectType.getDescribe().isAccessible()){  //Fls-Read-Applied-Suresh-30/09/2022
            targetAccountName=[select name from Account where id=:stAccId].name;
            }
            sendTo.addAll(getMailAddresses());
            User activeUser = [Select Email From User where Username = : UserInfo.getUserName() limit 1];
            sendTo.add(activeUser.Email);
            mail.setToAddresses(sendTo);
            //code added as per US120420
            if(targetContId!=null){
            if(Contact.SObjectType.getDescribe().isAccessible()){  //Fls-Read-Applied-Suresh-30/09/2022
                targetContactName = [select name from contact where id =: targetContId].name;
            }
            }
            //Add the total # of cases moved from old to new contact
            //Add the case number/case subject for each of the contacts moved
            //String htmlBody = 'The Case update batch for contact Name: "' + currContactName + '" to Account Name: "' +targetAccountName + '" ran into some issues.<br/><br/> Error Occured :'+errorOccured+' <br/><br/>Total: '+allProcessedcaseId.size()+' cases moved from old to new contact and total failed: '+allFailedcaseId.size()+'.<br/> <b>Below are the list for failed cases</b><br/>'+getCaseDetails(allFailedcaseId)+'<br/><hr/><br/><b>Here is the list of success cases</b><br/>'+getCaseDetails(allProcessedcaseId) ; /*'+ failedRun +' batches failed out of '+ totalNum + '*/
            String htmlBody = 'The Case update batch for contact Name: "' + currContactName + '" to Account Name: "' +targetAccountName + '" ran into some issues.<br/><br/> Error Occured :'+errorOccured+' <br/><br/>Total: '+allProcessedcaseId.size()+' cases moved from old to new contact and total failed: '+allFailedcaseId.size()+'.<br/> <b>Below are the list for failed cases</b><br/>'+getCaseDetails(allFailedcaseId)+'<br/><hr/><br/><b>Here is the list of success cases</b><br/>'+getCaseDetails(allProcessedcaseId) ; /*'+ failedRun +' batches failed out of '+ totalNum + '*/
            String emailSubject='Move Case Batch Update';
            mail.setSubject(emailSubject);
            AsyncApexJob asyncjob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];        
            if(asyncjob.Status == 'Completed') {
                if(allFailedcaseId.size()>0){
                    if(targetContactName!=null){
                        htmlBody = 'The Case update batch for contact Name: "' + currContactName + '"to new Contact "' +targetContactName + '" , and contact "'+ currContactName+'" is moved to Account "'+targetAccountName + '". ran into some issues.<br/><br/> Error Occured :'+errorOccured+' <br/><br/>Total: '+allProcessedcaseId.size()+' cases moved from old to new contact and total failed: '+allFailedcaseId.size()+'.<br/> <b>Below are the list for failed cases</b><br/>'+getCaseDetails(allFailedcaseId)+'<br/><hr/><br/><b>Here is the list of success cases</b><br/>'+getCaseDetails(allProcessedcaseId) ; /*'+ failedRun +' batches failed out of '+ totalNum + '*/
                    }
                }else{
                    if(targetContactName==null){
                        htmlBody = 'All cases moved successfully for contact Name: "' + currContactName + '" to Account Name: "' +targetAccountName + '"<br/>Total '+allProcessedcaseId.size()+' cases moved from old to new contact. <br/> Here is the case details: <br/>'+getCaseDetails(allProcessedcaseId);
                     }
                     else{
                        htmlBody = 'All cases moved successfully for contact Name: "' + currContactName + '"to new Contact "' +targetContactName + '" , and contact "'+ currContactName + '" is moved to Account "' +targetAccountName + '"<br/>Total '+allProcessedcaseId.size()+' cases moved from old to new contact. <br/> Here is the case details: <br/>'+getCaseDetails(allProcessedcaseId);
                     }
                 }
                mail.setHtmlBody(htmlBody );
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
    }  
    //get all group member from this Core_IPS_Move_Contact_Batch
    public List<String> getMailAddresses()
    {
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName= 'Core_IPS_Move_Contact_Batch'];
        for (GroupMember gm : g.groupMembers) 
        {
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
            mailAddresses.add(u.email);
        } 
        return mailAddresses;
    }
    
    public String getCaseDetails(Set<Id> CaseIds){
       String caseDetails='';
       for(Id caseId:CaseIds){
           case cs=mapAllProcessedCase.get(caseId);
           caseDetails+=('<tr><td>'+cs.casenumber+' </td><td>'+cs.subject+'</td></tr>');
       }
       caseDetails='<table>'+caseDetails+'</table>';
       return caseDetails;
    }
}