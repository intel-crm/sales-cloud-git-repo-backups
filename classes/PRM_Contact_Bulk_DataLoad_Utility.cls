/******************************************************************************************************************************
Apex Class Name:  PRM_Contact_Bulk_DataLoad_Utility
Version     : 1.0 
Created Date: 01 OCT 2021
Function    : Utility Class for Contact Bulk Upload Capability  

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/10/2021           Utility Class for Contact Bulk Upload Capability
****************************************************************************************************************************************/
public class PRM_Contact_Bulk_DataLoad_Utility {
    
    public static Boolean contactBulkLoad =false;
    public static Boolean isAGSTrigger = false;
    public static final String LOG_ENTRY_ORIGIN = 'Bulk Data Upload Batch';
    public static final String LOG_ENTRY_PROJECT = 'Bulk Data Upload';
    public static final String LOG_ENTRY_SCOPE = 'processContactRecords';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String PRM_PROCESSINBOUNDCLASS = 'PRM_Contact_Bulk_DataLoad_Utility';
    public static Map<id, String> commentMap = new Map<id, String>();
    public static Map<id, String> initiatedByMap = new Map<id, id>();
    public static Map<String, String> contactToEmail = new Map<String, String>();
    public static Map<String, String> objectToPrimaryField = new Map<String, String>{'PRM_Bulk_Data_Upload__c'=>'PRM_ContactEmail__c',
                                                            'Contact'=>'Email' };
    public static Map<String,Contact> contactMapping =new Map<String,Contact>();
    public static Map<String, String> processingStackTrace = new Map<String, String>();

    public static Map<id, PRM_Bulk_Data_Upload__c> mapIdToBulkUploadObject = new Map<id, PRM_Bulk_Data_Upload__c>();
    public static String logEntryMsg='';
    
    public static Map<String,Boolean> emailToDomain=new Map<String,Boolean>();  //IPA2.0 TWC727-2962

    public static void processContactRecords(Map<String,PRM_Bulk_Data_Upload__c>inputBulkLoadMap){

       //IPA2.0 TWC727-2962 starts here
       for(PRM_Bulk_Data_Upload__c val:inputBulkLoadMap.values())
        {
            string bulkemailDomain;
                
            if(String.IsNotBlank(val.PRM_ContactEmail__c) && val.PRM_ContactEmail__c.contains('@')){
                            bulkemailDomain= val.PRM_ContactEmail__c.split('@')[1];    
            }
            
            if(String.IsNotBlank(bulkemailDomain) && val.PRM_AccountId__r.Core_Geo__c=='PRC'){
                        
                    if(label.Blocked_Domains_Prc1.split(';').contains(bulkemailDomain) 
                       || label.Blocked_Domains_Prc2.split(';').contains(bulkemailDomain)){
                         emailToDomain.put(val.PRM_ContactEmail__c,true);
                       }
            } else if(String.IsNotBlank(bulkemailDomain) && (label.Blocked_Domains_Non_Prc1.split(';').contains(bulkemailDomain) || 
                      label.Blocked_Domains_Non_Prc2.split(';').contains(bulkemailDomain) ||label.Blocked_Domains_Non_Prc3.split(';').contains(bulkemailDomain)))
            {
                    emailToDomain.put(val.PRM_ContactEmail__c,true);
            }
            else {
                emailToDomain.put(val.PRM_ContactEmail__c,false);
            }

        }
        // IPA2.0 TWC727-2962 ends here
        try{
            logEntryMsg+='\nprocessContactRecords Method Invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
            contactBulkLoad =true;
            Map<String,Set<String>> partnerRelationShipMap = new Map<String,Set<String>>();
            Set<Id> contactRecordId =new Set<Id>();      
            List<PRM_Bulk_Data_Upload__c> recordsToUpdate = new List<PRM_Bulk_Data_Upload__c>();

            List<RecordType> recType = [select id, DeveloperName from RecordType where DeveloperName =: 'Core_Intel_Contact' limit 1];
            for(PRM_Bulk_Data_Upload__c inpreq :inputBulkLoadMap.values()){
                String stackTraceMethodEntryComment = 'processContactRecords Method Invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@; ';
                processingStackTrace.put(inpreq.PRM_ContactEmail__c,stackTraceMethodEntryComment);

                //IPA2.0 TWC727-2962 starts here
                /*string bulkemailDomain;
                Boolean isBlocked = false;
                if(String.IsNotBlank(inpreq.PRM_ContactEmail__c) && inpreq.PRM_ContactEmail__c.contains('@')){
                             bulkemailDomain= inpreq.PRM_ContactEmail__c.split('@')[1];    
                }
                 
              if(String.IsNotBlank(bulkemailDomain) && inpreq.PRM_AccountId__r.Core_Geo__c=='PRC'){
                        
                    if(label.Blocked_Domains_Prc1.split(';').contains(bulkemailDomain) 
                       || label.Blocked_Domains_Prc2.split(';').contains(bulkemailDomain)){
                           isBlocked = true;
                       }
                }else if(String.IsNotBlank(bulkemailDomain)){
                    if(label.Blocked_Domains_Non_Prc1.split(';').contains(bulkemailDomain) 
                       || label.Blocked_Domains_Non_Prc2.split(';').contains(bulkemailDomain)
                       || label.Blocked_Domains_Non_Prc3.split(';').contains(bulkemailDomain)){
                           isBlocked = true;
                       }
                }*/
                //IPA2.0 TWC727-2962 ends here
                
                if(inpreq.PRM_OperationType__c=='Insert' && emailToDomain.get(inpreq.PRM_ContactEmail__c)==false){ //IPA2.0  TWC727-2962
                    Contact con = new Contact();
                    con.AccountId =inpreq.PRM_AccountId__c!=Null ? inpreq.PRM_AccountId__c :null;
                    con.FirstName =inpreq.PRM_First_Name__c!=Null ? inpreq.PRM_First_Name__c:null;
                    con.LastName  =inpreq.PRM_Last_Name__c!=Null ? inpreq.PRM_Last_Name__c:null;
                    con.Email     =inpreq.PRM_ContactEmail__c!=Null ? inpreq.PRM_ContactEmail__c:null;
                    con.Core_IPA_PartnerRole__c =inpreq.PRM_IPA_Partner_Role__c!=Null?inpreq.PRM_IPA_Partner_Role__c:null; 
                    con.Core_Preferred_Language__c =inpreq.PRM_Preferred_Language__c;
                    con.RecordTypeId = recType[0].id;
                    con.Phone = inpreq.PRM_Contact_Phone__c;
                    try{
                    con.MailingCountryCode=Core_Country_Code_Mapping__c.getInstance(inpreq.PRM_Mailing_Country__c) != null ? Core_Country_Code_Mapping__c.getInstance((inpreq.PRM_Mailing_Country__c).capitalize()).ISO_Code__c :'';
                    }catch (Exception e) {system.debug(e);}
                    contactMapping.put(con.Email,con);
                }
                else if(emailToDomain.get(inpreq.PRM_ContactEmail__c)==false){ // IPA2.0  TWC727-2962
                    contactRecordId.add(inpreq.PRM_Contact_Id__c);
                    mapIdToBulkUploadObject.put(inpreq.PRM_Contact_Id__c, inpreq);
                } 
                if(inpreq.PRM_Partner_Program__c=='IPA'  && emailToDomain.get(inpreq.PRM_ContactEmail__c)==false){   //IPA2.0  TWC727-2962
                    Set<String> partnerRelations = new Set<String>();
                    if((inpreq.PRM_Partner_Relationship__c).contains(';')){
                        partnerRelations.addAll(inpreq.PRM_Partner_Relationship__c.split(';'));
                    }else{
                        partnerRelations.add(inpreq.PRM_Partner_Relationship__c);
                    }                 
                    if(!partnerRelations.contains('Employee')){
                        partnerRelations.add('Employee');
                    }              
                    partnerRelationShipMap.put(inpreq.PRM_ContactEmail__c,partnerRelations);                  
                }

            }      
            if(!contactMapping.isEmpty()){  
                Set<Id> contactsInserted = upsertOperation(contactMapping.values(),'Contact');
                if(contactsInserted!=null && !contactsInserted.isEmpty()){
                    contactRecordId.addAll(contactsInserted);  
                }
            }  
            
            //Add ACR for IPA Contacts
            if(contactRecordId !=Null && !contactRecordId.isEmpty() && !partnerRelationShipMap.isEmpty() && partnerRelationShipMap!=null){
                Map<Id,Contact> finalcontactMap =updateContactFields(contactRecordId,inputBulkLoadMap);
                if(!finalcontactMap.isEmpty()){
                    insertACRforBulkContactLoad(finalcontactMap,partnerRelationShipMap,inputBulkLoadMap);
                }
            }
        }
        catch(Exception ex){
           System.debug('Error Msg--'+ ex.getMessage());
           logEntryMsg+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(ex);//Added error log statement
           
       }
       finally{  
        for(String email : inputBulkLoadMap.keySet()){
            PRM_Bulk_Data_Upload__c bulkObject = inputBulkLoadMap.get(email);
            List<Schema.PicklistEntry> entries = Account.BillingCountryCode.getDescribe().getPicklistValues();
                list<string> countryList=new list<string>();
                for (Schema.PicklistEntry entry : entries) {
                    countryList.add(entry.getLabel());  
                }
                //string countries= String.join(countryList,';'); //IPA2.0 TWC727-2962
                system.debug('countrylist'+countryList);
                //system.debug('countries'+countries);
        
            System.debug('processingStackTrace=== '+processingStackTrace);
            if(processingStackTrace.containsKey(email)){
                bulkObject.PRM_Stack_Trace__c = processingStackTrace.get(email);
                if(processingStackTrace.get(email).contains('upsert failed')){
                    bulkObject.PRM_Status__c = 'Failed';
                }else{
                    if(bulkObject.PRM_OperationType__c=='Insert' && contactMapping.containsKey(email)){
                        //if(string.isnotblank(email) && contactMapping.containskey(email)){
                          bulkObject.PRM_Contact_Id__c= contactMapping.get(email).id;
                        //}
                    }
                    bulkObject.PRM_Status__c = 'Completed';
                   
                }
            }else{
                bulkObject.PRM_Stack_Trace__c = 'Caught in Unhandeled logic';
                bulkObject.PRM_Status__c = 'Failed';
            }
            // Region Logic:
            //IPA2.0 TWC727-2962 starts here
            /*string bulkemailDomain;
            if(String.IsNotBlank(email) && email.contains('@')){
                bulkemailDomain= email.split('@')[1];  
            }
            
            if(String.isNotBlank(bulkemailDomain) && bulkObject.PRM_AccountId__r.Core_Geo__c=='PRC'){
                        
                if(label.Blocked_Domains_Prc1.split(';').contains(bulkemailDomain) 
                   || label.Blocked_Domains_Prc2.split(';').contains(bulkemailDomain)){
                       bulkObject.PRM_Status__c = 'Failed';
                       bulkObject.PRM_Comments__c='Invalid_Domain';
                       system.debug('bulkObject.PRM_Status__c if-->'+bulkObject.PRM_Status__c);
                   }
            }
            else if(String.isNotBlank(bulkemailDomain)){
                if(label.Blocked_Domains_Non_Prc1.split(';').contains(bulkemailDomain) 
                   || label.Blocked_Domains_Non_Prc2.split(';').contains(bulkemailDomain)
                   || label.Blocked_Domains_Non_Prc3.split(';').contains(bulkemailDomain)){
                       bulkObject.PRM_Status__c = 'Failed';
                       bulkObject.PRM_Comments__c='Invalid_Domain';
                   }
            }*/
          
            // if(emailToDomain.get(email)){
            //     bulkObject.PRM_Status__c = 'Failed';
            //     bulkObject.PRM_Comments__c='Invalid_Domain';
            // }
            //IPA2.0 TWC727-2962 ends here
            if(emailToDomain != null && email !=null && emailToDomain.containsKey(email)&& emailToDomain.get(email)==true){
                bulkObject.PRM_Status__c = 'Failed';
                bulkObject.PRM_Comments__c='Invalid_Domain';
            }//updated IPA2.0
             
            if(!(countryList.contains(bulkObject.PRM_Mailing_Country__c))){  // IPA2.0 TWC727-2962 using directly countryList
                bulkObject.PRM_Status__c = 'Failed';
                bulkObject.PRM_Comments__c='Invalid_Country';
            }
            if(bulkObject.PRM_Mailing_Country__c==null || string.isEmpty(bulkObject.PRM_Mailing_Country__c) ){
                bulkObject.PRM_Status__c = 'Failed';
                bulkObject.PRM_Comments__c='Blank_Country';
            }
        }
        if(!inputBulkLoadMap.isEmpty()){
            try {
                upsert(inputBulkLoadMap.values());    
            } catch (Exception ex) {
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',ex);        
            }
        } 
            createLogEntry(logEntryMsg);
        }
    }
    
    public static void insertACRforBulkContactLoad(Map<Id,Contact> newContactMap, Map<String,Set<String>> contactRelationShipMap, Map<String,PRM_Bulk_Data_Upload__c>inputBulkLoadRecords){               
        Map<String,Contact> contactMap = new Map<String,Contact>();                
        Map<Id,List<String>> inputContactMap = new Map<Id,List<String>>();                              
        List<PRM_Account_Contact_Relationship__c> acrListToInsert=new List<PRM_Account_Contact_Relationship__c>();        
        /*Map<Id, Map<Id, String>> ctIdActIdRole =  new Map<id, Map<Id, String>>();    
          Set<String> partnerroles = new Set<String>();  
        */ //IPA TWC727-2962 
         List<PRM_Account_Contact_Relationship__c> acrListToProcess = new List<PRM_Account_Contact_Relationship__c>();
       
         //IPA2.0  TWC727-2962 starts here
        /*for(Contact cont:newContactMap.values()){            
            ctIdActIdRole.put(cont.Id, new Map<Id,String>{cont.AccountId=>cont.Core_IPA_PartnerRole__c});                 
            partnerroles.add(cont.Core_IPA_PartnerRole__c);
            contactMap.put(cont.Email,cont);
            if(inputContactMap.size()>0 && inputContactMap.containsKey(cont.AccountId) && inputContactMap.get(cont.AccountId)!=null){
                inputContactMap.get(cont.AccountId).add(cont.Core_IPA_PartnerRole__c);
            }else{
                inputContactMap.put(cont.AccountId, new List<String>{cont.Core_IPA_PartnerRole__c});                  
            }                                         
        }    

        if(inputContactMap.size()>0){                 
            //CREATE ACR for insert | Account with Partner User Cnt, contact with account and Partner role
            Map<String,Contact> contactMap1 = contactMap.clone(); 
            acrListToProcess.addAll(checkContactACRAssociation(newContactMap.keySet(),contactMap,contactRelationShipMap));
           acrListToInsert = createACRLists(contactMap,contactRelationShipMap,inputBulkLoadRecords);   
            acrListToProcess.addAll(acrListToInsert);
            if(acrListToInsert.size()>0){                
                upsertOperation(acrListToInsert,'Account Contact Relationship'); 
            }                  
        } */ //IPA2.0 TWC727-2962 ends here

        //IPA2.0 TWC727-2962 starts here - Optimised code for above commented code.
         for(Contact cont:newContactMap.values()){ 
            if(cont.Core_IPA_PartnerRole__c!=null && cont.AccountId!=null)                          
            {   
                contactMap.put(cont.Email,cont);     
            }                                  
        }    
        
        if(contactMap.size()>0){                 
            //CREATE ACR for insert | Account with Partner User Cnt, contact with account and Partner role
            Map<String,Contact> contactMap1 = contactMap.clone(); 
            //acrListToProcess.addAll(checkContactACRAssociation(newContactMap.keySet(),contactMap,contactRelationShipMap));
            acrListToProcess.addAll(checkContactACRAssociation(newContactMap.keySet(),contactRelationShipMap));
           acrListToInsert = createACRLists(contactMap,contactRelationShipMap,inputBulkLoadRecords);   
            acrListToProcess.addAll(acrListToInsert);
            if(acrListToInsert.size()>0){                
                upsertOperation(acrListToInsert,'Account Contact Relationship'); 
            }                  
        } 
        // IPA2.0 TWC727-2962 ends here
    }
    
    //Method to Insert/Update Data
    public static Set<id> upsertOperation(List<SObject> newLst, String ObjectType) {
        Set<Id> successRecordId = new Set<Id>();
        List<PRM_Bulk_Data_Upload__c> listToUpdate = new List<PRM_Bulk_Data_Upload__c>();

        if(newLst!=null && !newLst.isEmpty()) {
            Database.UpsertResult[] urList = Database.upsert(newLst, false);
            logEntryMsg+= PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(newLst,urList,ObjectType);            
            Integer index = 0;
            for(Database.UpsertResult ur : urList){
                String existingComment = '';
                String emailAddress = '';
                if(objectToPrimaryField.containsKey(ObjectType)){
                    emailAddress = (String)newLst[index].get(objectToPrimaryField.get(ObjectType));
                }
                if(emailAddress != null && processingStackTrace.containsKey(emailAddress)  ){
                    existingComment = processingStackTrace.get(emailAddress);
                }
                if(ur.isSuccess()){
                    String newComment = '; '+ObjectType+' '+ur.getId()+' upserted succesfully';
                    String updatedComment = existingComment + newComment+'; ';
                    if(objectToPrimaryField.containsKey(ObjectType)){
                        if(processingStackTrace.containskey(emailAddress)){
                            processingStackTrace.put(emailAddress,updatedComment);
                        }
                        else{
                            processingStackTrace.put(emailAddress,newComment); 
                        }
                    }
                    successRecordId.add(ur.getId());
                }else{
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err : ur.getErrors()){
                        String newComment = '; '+ObjectType+' upsert failed'+ ' Error Reason: '+err.getMessage();
                        String updatedComment = existingComment + newComment+'; ';
                        if(objectToPrimaryField.containsKey(ObjectType)){
                            if(processingStackTrace.containskey(emailAddress)){
                                processingStackTrace.put(emailAddress,updatedComment);
                            }
                            else{
                                processingStackTrace.put(emailAddress,newComment); 
                            }}
                        sId = newLst[index].Id;
                        if(sId != null)
                        {
                            sObjectType = sId.getSObjectType().getDescribe().getName();
                        }
                    }
                }
                index++;
            }
        }     
        return successRecordId;
    }
    
    /*public static PRM_Account_Contact_Relationship__c createACR(Id bulkId, Id actId, Id ctId, id relationshipId, String inputComment, Boolean suppressEmail, Id createdBy, String uploadType, id campaignId){
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.Bulk_Data_Upload__c = bulkId;
        acr.PRM_Account_Id__c = actId;
        acr.PRM_Contact_Id__c = ctid;
        acr.PRM_Relationship_Id__c = relationshipId;
        acr.PRM_isActive__c = true;
        acr.PRM_Status_Nm__c = uploadType == 'Bulk Invite' ? 'Pending Action' : 'Complete';
        acr.PRM_Start_Date_Dt__c = Date.today();
        acr.PRM_Status_Reason_Txt__c =inputComment;
        acr.PRM_Suppress_Email__c=suppressEmail;
        acr.PRM_Source_Agent__c = uploadType;
        acr.PRM_CampaignId__c = campaignId;
        acr.PRM_Initiated_By__c = createdBy;
        return acr;
    }*/ //IPA2.0 TWC727-2962
     
    //IPA2.0 TWC727-2962 starts here
    public static PRM_Account_Contact_Relationship__c createACR(Contact con, id relationshipId,PRM_Bulk_Data_Upload__c bulkrec){
       
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.Bulk_Data_Upload__c = bulkrec.id;
        acr.PRM_Account_Id__c = con.AccountId;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = relationshipId;
        acr.PRM_isActive__c = true;
        acr.PRM_Status_Nm__c = bulkrec.PRM_Upload_Type__c == 'Bulk Invite' ? 'Pending Action' : 'Complete';
        acr.PRM_Start_Date_Dt__c = Date.today();
        acr.PRM_Status_Reason_Txt__c =bulkrec.PRM_Status_Reason__c;
        acr.PRM_Suppress_Email__c=bulkrec.PRM_Suppress_Email__c;
        acr.PRM_Source_Agent__c = bulkrec.PRM_Upload_Type__c;
        acr.PRM_CampaignId__c =   bulkrec.PRM_CampaignId__c;
        acr.PRM_Initiated_By__c = bulkrec.CreatedById;
        return acr;
    }
    //IPA2.0 TWC727-2962 ends here

    public static List<PRM_Account_Contact_Relationship__c> createACRLists(Map<String,Contact> contEmailMap, Map<String,Set<String>> partnerRelationMap,Map<String,PRM_Bulk_Data_Upload__c> inputBulkrecords){
        List<PRM_Account_Contact_Relationship__c> newACRList = new List<PRM_Account_Contact_Relationship__c>(); 
        Map<String, Integer> actUserExitsMp =new Map<String, Integer>();
        Map<String,PRM_Contact_Relationship__c> relationshipIdsCs = PRM_Contact_Relationship__c.getAll(); //created custom setting to store value
        for(Contact con:contEmailMap.values()){  
            //if(partnerRelationMap.containskey(con.Email) && partnerRelationMap.get(con.Email)!=null){         
            for(String partnerRelation :partnerRelationMap.get(con.Email)){                
                if(inputBulkrecords.containsKey(con.Email)){
                    if(relationshipIdsCs.containsKey(partnerRelation)){
                       /*newACRList.add(createACR(
                                        inputBulkrecords.get(con.Email).id,
                                        con.AccountId,
                                        con.Id,
                                        relationshipIdsCs.get(partnerRelation).PRM_Relationship_Id__c,
                                        inputBulkrecords.get(con.Email).PRM_Comments__c,
                                        inputBulkrecords.get(con.Email).PRM_Suppress_Email__c,
                                        inputBulkrecords.get(con.Email).CreatedById, 
                                        inputBulkrecords.get(con.Email).PRM_Upload_Type__c,
                                        inputBulkrecords.get(con.Email).PRM_CampaignId__c
                                         )); 
                        */ //IPA2.0 TWC727-2962
                        
                        //IPA2.0 TWC727-2962 starts here
                       PRM_Bulk_Data_Upload__c bulkrec=inputBulkrecords.get(con.Email);
                       newACRList.add(createACR(
                                        con,
                                        relationshipIdsCs.get(partnerRelation).PRM_Relationship_Id__c,
                                        bulkrec
                                         )); 
                        // IPA2.0 TWC727-2962 ends here
                        
                    } 
                }
            //} 
        }           
        }       
        return newACRList;
    }    
    
    public static List<PRM_Account_Contact_Relationship__c> checkContactACRAssociation(Set<Id> contactIds,Map<String,Set<String>> partnerRelationMap){
        Map<Id,PRM_Account_Contact_Relationship__c> acrRecAssociations = new Map<Id,PRM_Account_Contact_Relationship__c>([select PRM_Contact_Id__c,PRM_Contact_Id__r.Email,PRM_Relationship_Id__r.Name,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Partner_Role__c  from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c in :contactIds]);
        Set<Id> contactsWithACR = new Set<Id>();        
        List<PRM_Account_Contact_Relationship__c> acrListToUpdate = new List<PRM_Account_Contact_Relationship__c>();
        if(acrRecAssociations.size()>0){
            for(Id contId :contactIds){
                for(PRM_Account_Contact_Relationship__c acrRecord :acrRecAssociations.values()){
                    String status = '';
                    if(mapIdToBulkUploadObject.containskey(contId)){
                            if(mapIdToBulkUploadObject.get(contId).PRM_Upload_Type__c == 'Bulk Invite'){
                                status = 'Pending Action';
                            }
                            else{
                                status = 'Complete';
                            }
                        if(acrRecord.PRM_Contact_Id__c == contId&& partnerRelationMap.containsKey(acrRecord.PRM_Contact_Id__r.Email)
                            && partnerRelationMap.get(acrRecord.PRM_Contact_Id__r.Email).contains(acrRecord.PRM_Relationship_Id__r.Name)
                        ){
                            if(acrRecord.PRM_InActive_Ind__c==true){
                                acrRecord.PRM_InActive_Ind__c=false;
                                acrRecord.PRM_Status_Nm__c = status;
                                acrRecord.PRM_End_Date_Dt__c = null;
                                acrRecord.PRM_Status_Reason_Txt__c = mapIdToBulkUploadObject.get(contId).PRM_Status_Reason__c;
                                acrRecord.PRM_Source_Agent__c = mapIdToBulkUploadObject.get(contId).PRM_Upload_Type__c;
                                acrRecord.PRM_Initiated_By__c = mapIdToBulkUploadObject.get(contId).CreatedById;
                                acrRecord.PRM_CampaignId__c = mapIdToBulkUploadObject.get(contId).PRM_CampaignId__c;
                                acrRecord.Bulk_Data_Upload__c = mapIdToBulkUploadObject.get(contId).id;
                                acrListToUpdate.add(acrRecord);
                                contactsWithACR.add(contId);
                                partnerRelationMap.get(acrRecord.PRM_Contact_Id__r.Email).remove(acrRecord.PRM_Relationship_Id__r.Name);
                            }
                            
                        }   
                    }                
                }
            }
            if(acrListToUpdate.size()>0){
                upsertOperation(acrListToUpdate,'Account Contact Relationship');
            }
        }
        return acrListToUpdate;
    }  
    

     
    
    public static Map<Id,Contact> updateContactFields(Set<Id> contactId, Map<String,PRM_Bulk_Data_Upload__c>inputBulkLoadMap){
        List<Contact> contactsToUpdate= new List<Contact>();
        Map<Id,Contact> contactMap =new Map<Id,Contact>([SELECT Id,Email,AccountId,OwnerId,Core_IPA_PartnerRole__c FROM Contact WHERE Id IN:contactId]);
        for(Contact con : contactMap.values()){
            if(con.Core_IPA_PartnerRole__c==null){      
                con.Core_IPA_PartnerRole__c =inputBulkLoadMap.get(con.Email).PRM_IPA_Partner_Role__c;                      
            }
            contactsToUpdate.add(con);
        }
        upsertOperation(contactsToUpdate,'Contact');  
        return contactMap;
    }

    
    //Create a log entry record for DML operations and Exceptions 
    public static void createLogEntry(String logEntryMsgString){
        if(logEntryMsgString!=''){// this block will create error log records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
           for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsgString.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
    }
}