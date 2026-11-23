/****************************************************************************************************************************************
* Class Name  : PMP_GLSTranslationIssueBatch 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022            
*****************************************************************************************************************************************/
global class PMP_GLSTranslationIssueBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String sObjectType;
    //IPA2.0:US-4497-1631_OfferingEOL
    //global List<PMP_Partner_Offering__c> offTransList;
    global List<PMP_Company__c> partnerTransList;
    
    public PMP_GLSTranslationIssueBatch(String sObjectType)
    {
        this.sObjectType = sObjectType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('sObjectType----'+ sObjectType);
        String query =   '';
        if(sObjectType=='PMP_Company__c')
        {
            query = 'Select Id,PMP_Company_Information_Language_Nm__c,Name,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c from PMP_Company__c' +
                     ' where PMP_Company_Lifecycle_Status_Nm__c =\'Admin Review\'';
        }
        //IPA2.0:US-4497-1631_OfferingEOL
        /*if(sObjectType=='PMP_Partner_Offering__c')
        {
            query = 'Select Id,PMP_Offering_Language_Nm__c,Name,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c';
        }*/
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope !=null && sObjectType=='PMP_Company__c'){
            partnerTransList = new List<PMP_Company__c>();            
            for(PMP_Company__c partner : (List<PMP_Company__c>) scope)
            {
                if(partner.PMP_Company_Information_Language_Nm__c!=null && partner.Name!=null && partner.PMP_Account_Tag_Line__c!=null && partner.PMP_Account_Dsc__c!=null)
                {
                    if(partner.PMP_Company_Information_Language_Nm__c=='English' && ( matchString(partner.Name) || matchString(partner.PMP_Account_Tag_Line__c) || matchString(partner.PMP_Account_Dsc__c)))
                    {
                        partnerTransList.add(partner);
                    }
                    if(partner.PMP_Company_Information_Language_Nm__c=='Japanese' && ( !matchString(partner.Name) || !matchString(partner.PMP_Account_Tag_Line__c) || !matchString(partner.PMP_Account_Dsc__c)))
                    {
                        partnerTransList.add(partner); 
                    }
                    if(partner.PMP_Company_Information_Language_Nm__c=='Simplified Chinese' && ( !matchString(partner.Name) || !matchString(partner.PMP_Account_Tag_Line__c) || !matchString(partner.PMP_Account_Dsc__c)))
                    {
                        partnerTransList.add(partner);
                    }
                }
            }
        }     
        //IPA2.0:US-4497-1631_OfferingEOL
        /*if(scope !=null && sObjectType=='PMP_Partner_Offering__c'){
            offTransList = new List<PMP_Partner_Offering__c>();            
            for(PMP_Partner_Offering__c off : (List<PMP_Partner_Offering__c>) scope)
            {
                if(off.PMP_Offering_Language_Nm__c!=null && off.Name!=null && off.PMP_Partner_Offering_Tag_Line_Txt__c!=null && off.PMP_Partner_Offering_Dsc__c!=null)
                {
                    if(off.PMP_Offering_Language_Nm__c=='English' && ( matchString(off.Name) || matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                    if(off.PMP_Offering_Language_Nm__c=='Japanese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                    if(off.PMP_Offering_Language_Nm__c=='Simplified Chinese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                }
            }
        }*/
        try {
            
            Batch_Progress__e bpEvent = new Batch_Progress__e();
            
            AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
            ];
            
            bpEvent.Batch_Id__c = bc.getJobId();
            bpEvent.Class_Name__c = 'PMP_GLSTranslationIssueBatch';
            bpEvent.Count__c = Integer.valueOf(job.JobItemsProcessed);
            bpEvent.DML_Type__c = '';
            bpEvent.IsSucess__c = true;
            //bpEvent.ObjectApiName__c = 'PMP_Partner_Offering__c';//IPA2.0:US-4497-1631_OfferingEOL
            
            Database.SaveResult results = EventBus.publish(bpEvent);
            
            if (results.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : results.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
            
        } catch(Exception e) {
            system.debug(e);
        }
    }   
    
    global void finish(Database.BatchableContext bc){
        //IPA2.0:US-4497-1631_OfferingEOL
        /*if(offTransList!=null)
        {
            for(PMP_Partner_Offering__c off : offTransList)
            {
                System.debug('offTransList--->'+offTransList);
            }
        }*/
        if(partnerTransList!=null)
        {
            for(PMP_Company__c partner : partnerTransList)
            {
                System.debug('partnerTransList--->'+partnerTransList);
            }
        }
    }
    
    public static Boolean matchString(String inputText)
    {
        String regex = '[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(inputText);
        return regexMatcher.find();
    }
}