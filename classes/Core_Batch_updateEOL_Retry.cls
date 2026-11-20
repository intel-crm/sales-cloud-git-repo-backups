/********************************************************************************************************************
Apex Class Name:  Core_Batch_updateEOL_Retry
Version     : 1.0 
Created Date: 19 Nov 2021
Function    : Batch class to update eol flag on Opp Product when sales assist updates the products.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Sanket Mahajan            11/29/21                Initial Creation
*********************************************************************************************************************/

global class Core_Batch_updateEOL_Retry implements Database.Batchable<sObject>,Database.Stateful {
    Set<String> batchfailedIds = new Set<String>();
    List<product2> prdList = new List<product2>();
    map<id, String> mapErr = new map<id, String>();
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    
    
    global Core_Batch_updateEOL_Retry(Set<String> failedIds,List<product2> prList){
        batchfailedIds = failedIds;
        prdList = prList;
    } 
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT id,product2Id,product2.Core_SA_Is_EOL__c from Opportunitylineitem where id in : batchfailedIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Opportunitylineitem> scope){
        set<id> prIdSet= new Set<id>();
        for(Opportunitylineitem o : scope){
            prIdSet.add(o.Product2Id);
        }
        Map<id,List<OpportunityLineItem>> ProdOppLineMap = new Map<id,List<OpportunityLineItem>>();
        List<Product2> prdListnew = [select id,Core_SA_Is_EOL__c from product2 where id in:prIdSet];
        //List<OpportunityLineItem> OppItemList  = [select id,product2Id,product2.Core_SA_Is_EOL__c from Opportunitylineitem where product2id in : prIdSet and core_status__c in ('On Hold','Pending')];
        //system.debug('OppLineList->'+OppItemList.size());
        //if(OppItemList.size()>0){
            for(OpportunityLineItem oppLineRec : scope) {
                if(ProdOppLineMap.containsKey(oppLineRec.product2Id)) {
                    ProdOppLineMap.get(oppLineRec.product2Id).add(oppLineRec);
                } else {
                    ProdOppLineMap.put(oppLineRec.product2Id,new List<OpportunityLineItem>{oppLineRec});
                }
            }
        //}
        system.debug('ProdOppLineMap->'+ProdOppLineMap);
        
        system.debug('prdListnew->'+prdListnew);
        List<Opportunitylineitem> oliList = new List<Opportunitylineitem>();
        for(Product2 p : prdListnew){
            if(ProdOppLineMap.containskey(p.id)){
                if(!ProdOppLineMap.isEmpty() && ProdOppLineMap.get(p.id).size()>0){
                    List<OpportunityLineItem> oList = ProdOppLineMap.get(p.id);
                    if(oList.size()>0){
                        for(OpportunityLineItem o : oList){
                            system.debug('current opp-'+o.id);
                            o.Core_Is_Product_EOL__c = p.Core_SA_Is_EOL__c;
                            oliList.add(o);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] srList = database.update(oliList,false);
        Integer i=0;

        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) { 
                    System.debug(oliList.get(i).Id + ': ' + err.getMessage());
                    if(mapErr.containsKey(oliList.get(i).product2id)){
                    }
                    else{
                        mapErr.put(oliList.get(i).id,oliList.get(i).id+' : '+err.getMessage());
                    }
                }
            }
        i++;
        }
    }
    global void finish(Database.BatchableContext BC){
        if(Test.isRunningTest()){
            mapErr.put('0062D00000Fu000','33');
        }
        if(!mapErr.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
            
            List<User> userList = [SELECT Id, Name, Email, isActive, Profile.Name, userrole.name, usertype 
                                   FROM User 
                                   WHERE Id IN (SELECT userorgroupid FROM groupmember WHERE group.name = 'Core_EOLUpdate_EmailNotify_list')];
            for(User u : userList){           
                toAddresses.add(u.email);
            }
            if(Test.isRunningTest()){
                User U=[Select id,Email from User Where isActive=true limit 1];
                toAddresses.add(u.email);
            }
            system.debug('List'+toAddresses);
            String body='Hi All,'+'<br/>'+'<br/>';
            body +='Please find the summary of Opportunity Line Items which were failed to update the EOL flag during Sales Assist update process.'+'<br/>'+'<br/>';
            body +='Kindly update the EOL flag on the Opportunity Line Items as per the product records.'+'<br/>';
            body +='Total records failed : '+ mapErr.values().size()+'<br/>';
           
            for(String s : mapErr.values()){
                body += s+'<br/>';
            }
            body +='<br/>'+'<br/>'+'<br/>'+'Thanks,'+'<br/>'+'Intel Support team';
            mail.setToAddresses(toAddresses);
            mail.setSubject('EOL Update Failed on Opportunity Product');
            mail.setHtmlBody(body);  
            mail.setSaveAsActivity(false); 
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(fromEmailAddress);
            system.debug('mail-->'+mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}