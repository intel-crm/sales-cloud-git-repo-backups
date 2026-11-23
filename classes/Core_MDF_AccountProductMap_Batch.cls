public without sharing class Core_MDF_AccountProductMap_Batch implements Database.Batchable<string>,Database.Stateful{
    Core_MDF_AccountProductMappingController.AccountProdMapWrapper accProdMapWrap = new Core_MDF_AccountProductMappingController.AccountProdMapWrapper();
    Public List<String> selectedProdIds = new List<String>();
    Public string program = '';
    Public string accountId = '';
    Public Boolean isAllAccount;
    Public List<string> uncheckedProdIds = new List<string>();
    Public set<string> productIds = new set<string>();
    Public static Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    
    public Core_MDF_AccountProductMap_Batch(string details) {
        Core_MDF_AccountProductMappingController.AccountProdMapWrapper accProdMapWrap = (Core_MDF_AccountProductMappingController.AccountProdMapWrapper) JSON.deserialize(details,Core_MDF_AccountProductMappingController.AccountProdMapWrapper.class); 
        this.accountId = string.isNotBlank(accProdMapWrap.accountId) ? accProdMapWrap.accountId : null;
        this.selectedProdIds = accProdMapWrap.selectedProdIds;
        this.program = accProdMapWrap.program;
        this.isAllAccount = accProdMapWrap.isAllAccount;
        this.uncheckedProdIds = accProdMapWrap.uncheckedProdIds;
    }
    
    /*start*/
    public Iterable<string> start(Database.BatchableContext bc) {
        Set<string> prods = new Set<string>();
        prods.addAll(selectedProdIds);
        if(selectedProdIds.isEmpty()){
            prods.addAll(uncheckedProdIds);
        }
        return prods;
    }
    
    /*execute*/
    public void execute(Database.BatchableContext bc, List<string> selectedProductIds) {
        
        Map<string,Core_MDF_Account_Product_Mapping__c> upsertKeyToAccProdMap = new Map<string,Core_MDF_Account_Product_Mapping__c>();
        Set<string> allProdIds = new Set<string>();
        allProdIds.addAll(selectedProductIds);
        allProdIds.addAll(uncheckedProdIds);
        Map<Id,List<string>> apmIdToErrorsMap = new Map<Id,List<string>>();
        Map<String, Core_MDF_Account_Product_Mapping__c> existingAccProdMap = new Map<String, Core_MDF_Account_Product_Mapping__c>();
        set<Id> specificAccApmIdSet = new set<Id>();
        Set<Id> existingAccIdSet = new Set<Id>();
        Set<Id> productsToRemoveSet = new Set<Id>();
        try {
            
            List<Core_MDF_Account_Product_Mapping__c> existingAPMList = [SELECT Id, Core_MDF_Account__c, Core_MDF_Product__c, Core_MDF_Active_ind__c, Core_MDF_Program_Account_Map__c,Core_MDF_All_Account_Ind__c
                                                                         FROM Core_MDF_Account_Product_Mapping__c
                                                                         WHERE Core_MDF_Program_Account_Map__c =: program
                                                                         AND Core_MDF_Product__c IN: allProdIds];
            
            for(Core_MDF_Account_Product_Mapping__c apm : existingAPMList) {
                string programProduct_key = apm.Core_MDF_Program_Account_Map__c + apm.Core_MDF_Product__c;
                programProduct_key +=  apm.Core_MDF_All_Account_Ind__c ? 'Yes' : apm.Core_MDF_Account__c + 'No';
                
                
                if(!uncheckedProdIds.isEmpty() && uncheckedProdIds.contains(apm.Core_MDF_Product__c) && !isAllAccount && !apm.Core_MDF_All_Account_Ind__c) {
                    specificAccApmIdSet.add(apm.Id);
                }
                
                existingAccProdMap.put(programProduct_key,apm);
                if(!apm.Core_MDF_All_Account_Ind__c && apm.Core_MDF_Account__c !=null && selectedProdIds.contains(apm.Core_MDF_Product__c)){
                    existingAccIdSet.add(apm.Core_MDF_Account__c);
                }
                
                if((string.isNotBlank(accountId) && accountId == apm.Core_MDF_Account__c) || (isAllAccount && apm.Core_MDF_All_Account_Ind__c && apm.Core_MDF_Active_ind__c)) {
                    //Avoid Deeply Nested IF Statements
                    // if(selectedProdIds.isEmpty() || (!selectedProdIds.isEmpty() && !selectedProdIds.contains(apm.Core_MDF_Product__c))) {
                    //     apm.Core_MDF_Active_ind__c = false;
                    //     upsertKeyToAccProdMap.put(programProduct_key,apm);
                    //     if(isAllAccount && apm.Core_MDF_All_Account_Ind__c){
                    //         productsToRemoveSet.add(apm.Core_MDF_Product__c);
                    //     }
                    // }
                    Boolean selectedProdIdsCheck = (selectedProdIds.isEmpty() || (!selectedProdIds.isEmpty() && !selectedProdIds.contains(apm.Core_MDF_Product__c)));
                    if(selectedProdIdsCheck) {
                        apm.Core_MDF_Active_ind__c = false;
                        upsertKeyToAccProdMap.put(programProduct_key,apm);
                    }
                    if(selectedProdIdsCheck && isAllAccount && apm.Core_MDF_All_Account_Ind__c) {
                        productsToRemoveSet.add(apm.Core_MDF_Product__c);
                    }
                }
            }
            
            for(Core_MDF_Account_Product_Mapping__c apm : existingAPMList) {
                string programProduct_key = program + apm.Core_MDF_Product__c; 
                programProduct_key +=  apm.Core_MDF_All_Account_Ind__c ? 'Yes' : apm.Core_MDF_Account__c + 'No';
                if(productsToRemoveSet.contains(apm.Core_MDF_Product__c) && !apm.Core_MDF_All_Account_Ind__c && apm.Core_MDF_Active_ind__c) {
                    apm.Core_MDF_Active_ind__c = false;
                    upsertKeyToAccProdMap.put(programProduct_key,apm);
                }
                
                if(!specificAccApmIdSet.isEmpty() & uncheckedProdIds.contains(apm.Core_MDF_Product__c) && !isAllAccount && apm.Core_MDF_All_Account_Ind__c && !specificAccApmIdSet.contains(apm.Id)) {
                    string accSpecific_Key = program + apm.Core_MDF_Product__c + accountId + 'No';
                    if(!existingAccProdMap.containsKey(accSpecific_Key)){
                        upsertKeyToAccProdMap.put(programProduct_key,Core_MDF_AccountProductMappingController.createAccountProdMapInstance(accountId,false,apm.Core_MDF_Product__c,program,false));
                    }
                }
                
            }   
            
            if(!selectedProdIds.isEmpty()){ 
                for(Id productId : selectedProductIds){
                    string programProduct_key = program + productId; 
                    programProduct_key +=  (isAllAccount == true) ? 'Yes' : accountId + 'No';
                    if(!existingAccProdMap.containsKey(programProduct_key)) {
                        upsertKeyToAccProdMap.put(programProduct_key,Core_MDF_AccountProductMappingController.createAccountProdMapInstance(accountId,isAllAccount,productId,program,true));
                    }else{
                        if(existingAccProdMap.containsKey(programProduct_key) && !existingAccProdMap.get(programProduct_key).Core_MDF_Active_ind__c ){
                            Core_MDF_Account_Product_Mapping__c apm = existingAccProdMap.get(programProduct_key);
                            apm.Core_MDF_Active_ind__c = true;
                            upsertKeyToAccProdMap.put(programProduct_key,apm);
                        }
                    }
                    
                    //US - TWC702-14285 - Begin
                    if(!existingAccIdSet.isEmpty() && isAllAccount){
                        for(Id accId: existingAccIdSet){
                            string programProduct_Acc_key = program + productId + accId + 'No';
                            if(!existingAccProdMap.containsKey(programProduct_Acc_key)){
                                upsertKeyToAccProdMap.put(programProduct_Acc_key,Core_MDF_AccountProductMappingController.createAccountProdMapInstance(accId,false,productId,program,true));
                                continue;
                            }

                            // Case 2: Key exists but is inactive
                            Core_MDF_Account_Product_Mapping__c apm = existingAccProdMap.get(programProduct_Acc_key);
                            if(!apm.Core_MDF_Active_ind__c) {
                                apm.Core_MDF_Active_ind__c = true;
                                upsertKeyToAccProdMap.put(programProduct_Acc_key,apm);
                            }
                        }
                    }
                    //US - TWC702-14285 - End
                }
            } 
            //Avoid Deeply Nested IF Statements
            // if(upsertKeyToAccProdMap != null && !upsertKeyToAccProdMap.values().isEmpty()) {
            //     if(upsertKeyToAccProdMap.values().size() < 9000){

            //         Database.upsertResult[] srList = Database.upsert(upsertKeyToAccProdMap.values(),false); 
                     
            //         for (Database.upsertResult sr : srList) {
            //             if(!sr.isSuccess()) {
            //                 List<string> errorMsgs = new List<string>();
            //                 for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage();
            //                                                           errorMsgs.add(errorMsg);
            //                                                          }
            //                 if(sr.getId() != null){apmIdToErrorsMap.put(sr.getId(),errorMsgs);   
            //                 }
            //             }
            //         }
            //         if(apmIdToErrorsMap != null && !apmIdToErrorsMap.values().isEmpty()) {createLogEntry(apmIdToErrorsMap);
            //         }
            //     }
            // } 
            if(upsertKeyToAccProdMap != null && !upsertKeyToAccProdMap.values().isEmpty() && upsertKeyToAccProdMap.values().size() < 9000) {
                    Database.upsertResult[] srList = Database.upsert(upsertKeyToAccProdMap.values(),false); 
                    for (Database.upsertResult sr : srList) {
                        List<string> errorMsgs = new List<string>();
                        if(!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage();
                                                                      errorMsgs.add(errorMsg);
                                                                     }
                        }
                        if(!sr.isSuccess() && sr.getId() != null) {
                            apmIdToErrorsMap.put(sr.getId(),errorMsgs);
                        }
                    }
                    if(apmIdToErrorsMap != null && !apmIdToErrorsMap.values().isEmpty()){
                            createLogEntry(apmIdToErrorsMap);
                    }
                
            } 
            
        }
        catch(DmlException ex) {Core_MDF_CCP_UtilityClass.logError(ex);
        }      
    }
    
    /*finish*/
    public void finish(Database.BatchableContext bc) {
        try{
            notifyUser(program);
        }Catch(Exception ex){
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    
    public static void createLogEntry(Map<Id,List<string>> apmIdToErrorsMap) {
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put('Core_Origin__c','Core_MDF_AccountProductMap_Batch');
        coreLogMap.put('Core_Severity__c','Low');
        coreLogMap.put('Core_sObjectType__c','Core_MDF_Account_Product_Mapping__c');
        coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');
        
        final Integer strLength = JSON.serialize(apmIdToErrorsMap).length();
        string details;
        coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(apmIdToErrorsMap.keySet()));
        details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(apmIdToErrorsMap) : JSON.serialize(apmIdToErrorsMap).substring(0,LONG_TEXT_AREA_LIMIT);
        coreLogMap.put('Core_Details__c',details);
        Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap); 
    }
    
    public static void notifyUser(string program){   
        String htmlBody;String subject;
        List<string> emailUsers = new List<string>{UserInfo.getUserEmail()};
            
            try{
                List<EmailTemplate> emailTemplate = [SELECT Id,Body,Subject,HtmlValue, Name 
                                                     FROM EmailTemplate 
                                                     WHERE Name = 'Core_MDF_Request_Completed_Email_Notification' LIMIT 1]; 
                
                Messaging.SingleEmailMessage notifyMail = new Messaging.SingleEmailMessage();
                // replacing Email Body with program name
                if(!emailTemplate.isEmpty()){
                    htmlBody = emailTemplate[0].HtmlValue;
                    subject = emailTemplate[0].Subject;
                    
                    if(htmlBody.contains('##programName')){
                        htmlBody = htmlBody.replace('##programName',program);
                    }
                    
                    htmlBody.stripHtmlTags();
                    
                }
                if(!emailUsers.isEmpty()){
                    notifyMail.setToAddresses(emailUsers);
                }
                notifyMail.setHtmlBody(htmlBody);
                notifyMail.setSubject(subject);
                notifyMail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                
                if(notifyMail !=null){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {notifyMail});
                }  
                
            }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    
}