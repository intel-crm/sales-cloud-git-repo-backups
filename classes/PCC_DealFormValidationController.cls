/******************************************************************************************************************
    *Method Name : validateDealRegForm
    *@author : Sandhya
    *Created Date: 22-02-2024
    *Description : validate Deal Reg Form 
    * @param regId - Deal Registration Id
*******************************************************************************************************************/  
public with sharing class PCC_DealFormValidationController {
    public class applicationException extends Exception {}
   
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_DealFormValidationController';
    public static final String LOG_ENTRY_PROJECT  = 'Deal Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR Records';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'Info';
    //public static String dealSLAConfig = LabelConfiguration__mdt.getInstance('PCC_DealDateSLA').Value__c; 

    @AuraEnabled
    public static DealErrorWrapper validateDealRegValues(Id recId,Boolean isSubmit){
        DealErrorWrapper deWrapper; 
    try{
        Map<String,List<String>> customErrorMap = new Map<String,List<String>>();
        String dealSLAConfig = LabelConfiguration__mdt.getInstance('PCC_DealDateSLA').Value__c;
        // Create a new Date object
        Date dateStr = System.today();
        // Add SLA days to the date
        Date pastDate = dateStr.addDays(Integer.valueOf(dealSLAConfig));
        
        customErrorMap = PCC_DealFormValidationController.checkErrorDRPAndFiles(recId, isSubmit);
                
        //Iterate over the list of deals - Perform validations
        Core_Design_Registration__c dealRec = Core_DDR_Design_Handler_Utility.getDealDesignRecDetails(recId);
        customErrorMap = PCC_DealFormValidationController.checkErrorforPricingDate(dealRec,customErrorMap,dateStr);
        customErrorMap = PCC_DealFormValidationController.checkErrorforDates(dealRec,customErrorMap,pastDate);
        customErrorMap = PCC_DealFormValidationController.checkErrorforLength(dealRec,customErrorMap);
            if(customErrorMap.isEmpty()){
                deWrapper = new DealErrorWrapper(customErrorMap,dealRec.Name,null);
                if(isSubmit){
                      String dealLogErrStr = PCC_DealFormValidationController.submitDealRegValues(recId,dealRec);
                      if(!String.isEmpty(dealLogErrStr)){
                        deWrapper.customError = dealLogErrStr;
                      }
                    }
            }
            else{
                deWrapper = new DealErrorWrapper(customErrorMap,dealRec.Name,null);
            }
        }catch(Exception e){
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,recId ,'Core_Design_Registration__c' ,'' ,e);
        }
        return deWrapper;    
        } 
        
       
        /**
        * @author Sandhya
        */
        @AuraEnabled
        public static String submitDealRegValues(Id recId,Core_Design_Registration__c dealRec) {
            String logEntryMsg = '';
            String logErrStr='';
            try{
                List<PRM_AccountLegalAgreemntAssociation__c> updateInsertPartnerLegalAgreement = new List<PRM_AccountLegalAgreemntAssociation__c>();
                Core_Design_Registration__c dealRecUpdated = new Core_Design_Registration__c();
                String userId = UserInfo.getUserId();
                User userValues = new User();
                if (Schema.sObjectType.User.isAccessible()) {
                    userValues =[select id,name,ContactId,Contact.AccountId from User Where Id =:userId];
                }
                    // Change status and Record type of Deal if all Validations are passed and submit for approval
                    if(dealRec.Core_Design_Registration_Status_Nm__c!=null && dealRec.Core_Design_Registration_Status_Nm__c=='Draft'){
                        dealRecUpdated = PCC_DealFormValidationController.submitDealRegValuesUtility(recId,dealRec);
                        updateInsertPartnerLegalAgreement = PCC_DealFormValidationController.updateDealAgreement(dealRecUpdated.Id,userValues);
                      system.debug('some user'+ UserInfo.getUserId());
            system.debug('OWNER'+ dealRecUpdated.OwnerId);
                    }
                  
                if(UserInfo.getUserId() == dealRecUpdated.OwnerId){
                    if(Schema.sObjectType.Core_Design_Registration__c.isUpdateable() &&Schema.sObjectType.PRM_AccountLegalAgreemntAssociation__c.isUpdateable()) {
                        upsert updateInsertPartnerLegalAgreement;
                        update dealRecUpdated;
                        //upsert updateInsertPartnerLegalAgreement;
                        PCC_DealFormValidationController.callDealApprovalProcess(recId);      
                    }
                    else{
                        logEntryMsg = 'Core_Design_Registration__c or PRM_AccountLegalAgreemntAssociation__c CRUD Missing';
                        throw new applicationException(logEntryMsg); 
                    }
                }
                else {
                    logEntryMsg = 'Non deal owner '+UserInfo.getUserId()+' tries to submit deal';
                    throw new applicationException(logEntryMsg); 
                }
            }
            catch(Exception e) {
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsg, '' ,recId ,'Core_Design_Registration__c' ,'' ,e);
                if(logEntryMsg.contains('Non deal owner')){
                    logErrStr = PCC_Constants.DEAL_CUSTERR;
                }else{
                    logErrStr = PCC_Constants.LOG_ENTRY_MSG;
                }
            }
            return logErrStr;
    }
    /**
        * @author Utkarsh
    */
    public static List<PRM_AccountLegalAgreemntAssociation__c> updateDealAgreement(String dealRecId,User userValues) {
    List<PRM_AccountLegalAgreemntAssociation__c> dealLegalAgreement = new List<PRM_AccountLegalAgreemntAssociation__c>();
    List<id> dealLegalAgreementList = new List<id>();   
    List<PRM_AccountLegalAgreemntAssociation__c> updateInsertPartnerLegalAgreement = new List<PRM_AccountLegalAgreemntAssociation__c>();
    PRM_PartnerAgreement__c partnerAgreement = [Select id, name from PRM_PartnerAgreement__c where name = 'Deal_Registration_Terms_and_Conditions'];
        if (Schema.sObjectType.PRM_AccountLegalAgreemntAssociation__c.isAccessible() && userValues.ContactId!=null) {
            dealLegalAgreement = [Select Id, Name, PRM_Contact__c,PCC_Design_Deal_Registration__c,PRM_Account_Id__c,PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__c,PCC_Design_Deal_Registration__r.Core_Design_Registration_Status_Nm__c From PRM_AccountLegalAgreemntAssociation__c where PRM_Contact__c=:userValues.ContactId AND PRM_Partner_Agreement_Id__c=:partnerAgreement.Id];
        }
        for(PRM_AccountLegalAgreemntAssociation__c ala :dealLegalAgreement){
            dealLegalAgreementList.add(ala.PCC_Design_Deal_Registration__c);
        }
        if(dealLegalAgreement != null && !dealLegalAgreement.IsEmpty()){
            //for(PRM_AccountLegalAgreemntAssociation__c PLA :dealLegalAgreement){
                if(dealLegalAgreement.size() == 1 && dealLegalAgreement[0].PCC_Design_Deal_Registration__c == null){
                    dealLegalAgreement[0].PCC_Design_Deal_Registration__c = dealRecId;
                    updateInsertPartnerLegalAgreement.add(dealLegalAgreement[0]);
                    system.debug('updateInsertPartnerLegalAgreement if-->'+updateInsertPartnerLegalAgreement);
                }
                /*else if(!dealLegalAgreementList.contains(dealRecId)){
                     //if(dealLegalAgreement[0].PCC_Design_Deal_Registration__r.Core_Design_Registration_Status_Nm__c == 'Draft'){
                         PRM_AccountLegalAgreemntAssociation__c partnerLegalAgreement = new PRM_AccountLegalAgreemntAssociation__c();
                         partnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
                         partnerLegalAgreement.PRM_Contact__c = userValues.ContactId;
                         partnerLegalAgreement.PRM_Account_Id__c = userValues.Contact.AccountId;
                         partnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
                         partnerLegalAgreement.PCC_Design_Deal_Registration__c = dealRecId;
                         updateInsertPartnerLegalAgreement.add(partnerLegalAgreement);
                    // }
                     system.debug('updateInsertPartnerLegalAgreement-->'+updateInsertPartnerLegalAgreement);
                }*/
                
            //}
            
        }
        
        return updateInsertPartnerLegalAgreement;
    }
    public static Core_Design_Registration__c submitDealRegValuesUtility(Id recId,Core_Design_Registration__c dealRec) {
                        String dealRecordTypeIDLocked = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByName().get('Deal Registration - Locked').getRecordTypeId();
                        String dealRecordTypeIDPartner = Schema.getGlobalDescribe().get('Core_Design_Registration__c').getDescribe().getRecordTypeInfosByName().get('Deal Registration - Partner').getRecordTypeId(); 
                         if(dealRec.PCC_Approval_Level__c == null && dealRec.Core_Accepted_By_Id__c == null){
                            dealRec.Core_Design_Registration_Status_Nm__c=PCC_Constants.DEAL_SUBMITTED_STATUS;
                            dealRec.recordTypeId = dealRecordTypeIDLocked;
                        }
                        else if(dealRec.Core_Accepted_By_Id__c!= null && dealRec.PCC_Approval_Level__c == null){
                            dealRec.Core_Design_Registration_Status_Nm__c = 'Precheck Pending';
                            dealRec.recordTypeId = dealRecordTypeIDPartner;
                        }
                    else if(dealRec.PCC_Approval_Level__c == 'Level 1'){
                        if(dealRec.Core_Partner_Account_Id__r.Core_Covered_Account__c == false && dealRec.Core_Intel_Technical_Owner_Id__c ==null){
                            dealRec.Core_Design_Registration_Status_Nm__c= 'Pre-Approved';
                        }
                        else if(dealRec.Core_Partner_Account_Id__r.Core_Covered_Account__c == true){
                                dealRec.Core_Design_Registration_Status_Nm__c=  'Deal accepted';
                        }
                        else if(dealRec.Core_Intel_Technical_Owner_Id__c !=null){
                            dealRec.Core_Design_Registration_Status_Nm__c=  'Deal accepted';
                        }
                        dealRec.recordTypeId = dealRecordTypeIDPartner;
                    }
                    return dealRec;
                }
   public class DealErrorWrapper {
        @AuraEnabled public Map<String,List<String>> errorFieldMap{get;set;}
        @AuraEnabled public String dealRegName{get;set;}
        @AuraEnabled public String customError{get;set;}
        public DealErrorWrapper(Map<String,List<String>> errorFieldMap, String dealRegName,String customError){
            this.errorFieldMap = errorFieldMap;
            this.dealRegName = dealRegName;
            this.customError = customError;
        }
    }

    public static List<ContentDocumentLink> getContentDocLink(String recordId){
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        if (Schema.sObjectType.ContentDocumentLink.isAccessible() && Schema.sObjectType.ContentDocument.isAccessible()) {
            // Query content documents related to the record
                documentLinks = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, ContentDocument.ContentSize, ContentDocument.FileExtension 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId = :recordId];
            }
            return documentLinks;
    }

    public static List<String> getFileDetails(Id recordId) {
        Map<String, String> fileErrors = new Map<String, String>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        documentLinks = PCC_DealFormValidationController.getContentDocLink(recordId);
        List<String> result=new List<string>();
         // Check if at least one file is uploaded
         if (documentLinks.isEmpty()) {
            result.add(PCC_Constants.NO_FILE_UPLOADED);
        }
        else{
            // Perform validation for each file
            for(ContentDocumentLink link : documentLinks) {
                String fileName = link.ContentDocument.Title;
                String fileType = link.ContentDocument.FileExtension;
                Integer fileSize = link.ContentDocument.ContentSize;
                
                // Validate file type
                if (fileType==null || !isValidFileType(fileType.toLowercase())) {
                    fileErrors.put(fileName, PCC_Constants.INVALID_TYPE);
                }
                
                // Validate file size
                if (!isValidFileSize(fileSize)) {
                    String errorMessage = fileErrors.containsKey(fileName) ? fileErrors.get(fileName) + ', '+PCC_Constants.SIZE_EXCEEDS : PCC_Constants.SIZE_EXCEEDS;
                    fileErrors.put(fileName, errorMessage);
                }
            }
            for (String key : fileErrors.keySet()) {
                result.add(key + ' : ' + fileErrors.get(key) + '\n');
            }
        }
    
        return result;
    }
    
    // Method to validate file type
    private static Boolean isValidFileType(String fileType) {
        // Specify the list of acceptable file types
        String filetypestr = System.label.PCC_File_Type_Limit;
        List<String> specifiedTypes = filetypestr.split(',');
        return !specifiedTypes.contains(fileType);
    }
    
    // Method to validate file size
    private static Boolean isValidFileSize(Integer fileSize) {
        // Specify the required file size (in bytes)
        Integer specifiedSize = Integer.valueOf(System.label.PCC_File_Size_Limit);
        return fileSize <= specifiedSize;
    }


    /******************************************************************************************************************
    *Method Name : callDealApprovalProcess
    *@author : Chaithaly
    *Created Date: 03/04/2024
    *Description : call the Deal Approval Process 
    * @param regId - Deal Registration Id
    *******************************************************************************************************************/  
   
    public static  void callDealApprovalProcess(id regId){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval');
        req1.setObjectId(regId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('PCC_Deal_Reg_Approval_Process');
        //req1.setSkipEntryCriteria(true);
        // Submit the approval request
        Approval.process(req1);
    }
    public static Map<String,List<String>> checkErrorDRPAndFiles(string recId,Boolean isSubmit){
        List<Core_Design_Registration_Product__c> dealRegProductList = new List<Core_Design_Registration_Product__c>();
        List<String> dealRegProdList = new List<String>();
        List<String> notDealRegEligibleList = new List<String>(); 
        Map<String,List<String>> customErrorMap = new Map<String,List<String>>();
        List<String> custErrList = new List<String>();
        custErrList = PCC_DealFormValidationController.getFileDetails(recId); 
        if (Schema.sObjectType.Core_Design_Registration_Product__c.isAccessible()) {
                dealRegProductList =[SELECT id,recordTypeId,name,PCC_Product_Additional_Attribute__r.Eligible_for_Deal_Reg__c FROM Core_Design_Registration_Product__c where Core_Design_Registration_Id__c=:recId];
            }
            if(dealRegProductList.isEmpty() && dealRegProductList.size()<1){
                dealRegProdList.add(PCC_Constants.DEALPROD_RECORD_ERRORS);
            }
            for(Core_Design_Registration_Product__c dealRegProduct : dealRegProductList){
                if(dealRegProduct.PCC_Product_Additional_Attribute__r.Eligible_for_Deal_Reg__c == false){
                    notDealRegEligibleList.add(dealRegProduct.Name);
                }
            }
            if(notDealRegEligibleList.size()>0){
                dealRegProdList.add(PCC_Constants.DRP_NON_FIN_ERROR_MSG+String.join(notDealRegEligibleList, ','));
            }
            
            if(dealRegProdList.size()>=1 && isSubmit){
                customErrorMap.put(PCC_Constants.DEAL_REG_PRODUCT,dealRegProdList);    
            }
            if(custErrList.size()==1 && custErrList[0] == PCC_Constants.NO_FILE_UPLOADED && isSubmit){
                customErrorMap.put(PCC_Constants.FILE_ERROR,custErrList);    
            }   
            if(custErrList.size()>0 && custErrList[0] != PCC_Constants.NO_FILE_UPLOADED){
                customErrorMap.put(PCC_Constants.FILE_ERRORS,custErrList);
            }  
            return customErrorMap;
    }

    public static Map<String,List<String>> checkErrorforPricingDate(Core_Design_Registration__c dealRec,Map<String,List<String>> customErrorMap,Date pastDate){
        List<String> custErrList;
    if(dealRec.PCC_Pricing_Start_Date__c!=null && dealRec.Core_Opportunity_Decision_Dt__c!=null && dealRec.PCC_Pricing_End_Date__c!=null){
        custErrList =  new List<String>();
        if(dealRec.PCC_Pricing_Start_Date__c < pastDate){
            custErrList.add(PCC_Constants.DEAL_PRICING_START_DATE_VALIDATION);
        }        
        if(dealRec.PCC_Pricing_Start_Date__c > dealRec.PCC_Pricing_End_Date__c){
            custErrList.add(PCC_Constants.DEAL_PRICING_END_DATE_VALIDATION);
        }
        if(dealRec.PCC_Pricing_Start_Date__c < dealRec.Core_Opportunity_Decision_Dt__c){
            custErrList.add(PCC_Constants.DEAL_PRICINGSD_OPPTYDECISIONDATE);
        }
        if(custErrList.size()>0){
            customErrorMap.put(PCC_Constants.DEAL_PRICING_START_DATE,custErrList);
        } 
        if(dealRec.PCC_Pricing_End_Date__c < pastDate){
            custErrList = new List<string>();
            custErrList.add(PCC_Constants.DEAL_PRICING_END_DATE_FUTURE_VALIDATION);
            customErrorMap.put(PCC_Constants.DEAL_PRICING_END_DATE,custErrList);        
        }               
        
    }
    return customErrorMap;
}
    public static Map<String,List<String>> checkErrorforDates(Core_Design_Registration__c dealRec,Map<String,List<String>> customErrorMap,Date pastDate){
        List<String> custErrList;
   
    if(dealRec.Core_Opportunity_Decision_Dt__c!=null && dealRec.Core_Opportunity_Decision_Dt__c < pastDate){ 
        custErrList =  new List<String>{PCC_Constants.DEAL_OPPTYDECISIONDATE_PASTDATE};
        customErrorMap.put(PCC_Constants.DEAL_DECISIONDATE,custErrList);
    }
    
    return customErrorMap;
}
    public static Map<String,List<String>> checkErrorforLength(Core_Design_Registration__c dealRec,Map<String,List<String>> customErrorMap){
        List<String> custErrList;
    if(dealRec.PCC_Deal_Description__c!= null && dealRec.PCC_Deal_Description__c.length()<10){   
            custErrList =  new List<String>{PCC_Constants.DEAL_DESCRIPTION_VALIDATION};
            customErrorMap.put(PCC_Constants.DEAL_DESCRIPTION,custErrList);
        }
        if(dealRec.PCC_Competition_Assumptions__c!= null && dealRec.PCC_Competition_Assumptions__c.length() < 10){
            custErrList =  new List<String>{PCC_Constants.DEAL_COMPETITION_ASSUMPTIONS_VALIDATION};
            customErrorMap.put(PCC_Constants.DEAL_COMPETITION_ASSUMPTIONS,custErrList);
        }
        return customErrorMap;
    }
}