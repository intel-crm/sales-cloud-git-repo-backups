/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_OpportunitiesUtility 
* Version     : 1.0 
* Created Date: 31/8/2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			         31/8/2023             Apex class for Core_RestAPI_OpportunitiesUtility class
*****************************************************************************************************************************************/
global with sharing class Core_RestAPI_OpportunitiesUtility {

    public static boolean isValid = true;
    public Static Map<Decimal, String> errorMsgMap = new Map<Decimal, String>();
    List<String> allowedStatusList = new List<String>();
    public Map<String,Schema.SObjectField> sObjOppFieldMap;
    public Map<String,Schema.SObjectField> sObjOppProdFieldMap;
    public Static Integer NUMBER_FIELD_MAX_LENGTH = 16;
    public static OpportunityErrorMsg oppErrMsgs {set; get;}
    public static Map<Id, OpportunityLineItem> putOppProductMap;
    public static List<Opportunity> opportunity = new List<Opportunity>();
    public static String opportunityId;
    
    public Core_RestAPI_OpportunitiesUtility(){
        sObjOppFieldMap = Schema.sObjectType.opportunity.fields.getMap();
        sObjOppProdFieldMap = Schema.sObjectType.OpportunityLineItem.fields.getMap();
        allowedStatusList = Label.Core_Opportunity_AllowedStatuses_API.split(',');
        List<Core_Rest_API_Validation_Error_Msgs__mdt> errorMdts  = [SELECT Core_Error_Code__c,Core_Error_Message__c FROM Core_Rest_API_Validation_Error_Msgs__mdt];
        for(Core_Rest_API_Validation_Error_Msgs__mdt errMdt : errorMdts){
            errorMsgMap.put( ((Integer) errMdt.Core_Error_Code__c), errMdt.Core_Error_Message__c);
        }
    }

    global class OpportunityWrapper {
        public String opportunityId {set;get;}
        public String stage {set;get;} 
        public String decisionDate {set;get;}
        public String competitiveArchitecture {set;get;}
        public String statusUpdate {set;get;}        
        public String architectureConversion {set;get;}
        //public String intelPlatform {set;get;}        
        public Decimal volume {set;get;}
        public String firstCustomerShipDate {set;get;}
        public String productionEndDate {set;get;}
        public String manufacturingRegion {set;get;}        
        public List<OpportunityProducts> opportunityProducts {set;get;}
        public List<OpportunityPoP> opportunityPoP {set;get;}
    }
    
    public class OpportunityProducts {
        public String opportunityProductId {get; set;}
        public String status {get; set;}
        public Decimal quantity {set;get;}
        public Decimal salesPrice {get;set;}
    }
    
    public class OpportunityPoP {
        public String fileRefNo {get; set;}
        public String title {get; set;}
        public String data {get; set;}
    }
    
    global class OpportunityErrorMsg implements Core_SalesCRM_RestAPI_OppValErrors{
        public Map<String,ErrorMsg> opportunityErrorMsgs {set;get;}
        public List<OpportunityProductErrorMsg> opportunityProductErrorMsgs {set; get;}
        public List<OpportunityPoPErrorMsg> opportunityPoPErrorMsgs {set; get;}
    }
    
    global class OpportunityProductErrorMsg {
        public String opportunityProductId {set;get;} 
        public Map<String,ErrorMsg> opportunityProductErrors {set;get;}        
    }
    
    global class OpportunityPoPErrorMsg {
        public Map<String,ErrorMsg> opportunityPoPErrors {set;get;}        
    }
    
    public class ErrorMsg {
        public Integer errorCode {set;get;} 
        public String errorMsg  {set;get;} 
        public ErrorMsg(Integer code, String Msg){
            errorCode = code;
            errorMsg = Msg;
        }
    }
    
    public static void addValidationError(Map<String,ErrorMsg> oErrorMap, String fldName, Decimal errCode, Map<String,String> placeHolders){
        if(errorMsgMap.containsKey(errCode)){
            String errMsg = errorMsgMap.get(errCode);
            if(placeHolders!=null && placeHolders.size() > 0){
                for(String key : placeHolders.keySet()){
                    errMsg = errMsg.replace(key, placeHolders.get(key));  
                }  
            }
            oErrorMap.put(fldName, new ErrorMsg((Integer) errCode, errMsg));
        }else{
            oErrorMap.put(fldName, new ErrorMsg(0, 'Unknown Error'));
        }
    }
    
    public class NumberFieldValueWrapper {
        public String fldName {set;get;}
        public Decimal fldValue {set;get;}
        public String fldLabel  {set;get;}
        public boolean isMandatory {set;get;}
        public NumberFieldValueWrapper(String name, Decimal val, boolean isMandatry){
            fldName = name;
            fldValue = val;            
            isMandatory = isMandatry;
        }
        public NumberFieldValueWrapper(String name, Decimal val, String fldLabl, boolean isMandatry){
            fldName = name;
            fldValue = val;
            fldLabel = fldLabl;
            isMandatory = isMandatry;
        }
    }
    
    Map<String, Integer> statusPrecedence = new Map<String, Integer>{
        'Qualify' => 1,
        'Define' => 2,
        'Develop' => 3,
        'Design' => 4,
		'Design Win' => 5
	};
    /////////////////////////////////////
    public static Opportunity createOpportunityRecord(OpportunityWrapper opp){
        Opportunity newOpp = new Opportunity();
        if(opportunity[0].stagename == 'Design Win'){
            newOpp.Core_First_Customer_Ship_Date__c=Date.parse(opp.firstCustomerShipDate);  
        }else{
            newOpp.stagename=opp.stage;
            newOpp.CloseDate=Date.parse(opp.decisionDate);  
            newOpp.Core_Competitive_Architecture__c=opp.competitiveArchitecture;  
            newOpp.Core_Status_Update__c = opportunity[0].Core_Status_Update__c == null ? opp.statusUpdate : opp.statusUpdate + '\n' + opportunity[0].Core_Status_Update__c;
            //newOpp.Core_Architecture_Conversion__c= Boolean.valueOf(opp.architectureConversion);  
            //newOpp.Core_Intel_Platform__c=opp.intelPlatform;       
            newOpp.Core_Architecture_Conversion__c= opp.architectureConversion;
            newOpp.Core_Volume__c=opp.volume;  
            newOpp.Core_First_Customer_Ship_Date__c=Date.parse(opp.firstCustomerShipDate);  
            newOpp.Core_Production_End_Date__c=Date.parse(opp.productionEndDate);  
            newOpp.Core_Manufacturing_Geo__c=opp.manufacturingRegion; 
        }        
        return newOpp;
    }
    
    public static List<OpportunityLineItem> createOpportunityProdctRecords(List<OpportunityProducts> opportunityProducts){
        List<OpportunityLineItem> OppProducts = new List<OpportunityLineItem>();
        for(OpportunityProducts q: opportunityProducts){
            OpportunityLineItem OppProd = new OpportunityLineItem();
            OppProd.Id = q.opportunityProductId;
            //OppProd.Core_Status__c = q.status;
            OppProd.Quantity = q.quantity;
            OppProd.UnitPrice = q.salesPrice;
            OppProducts.add(OppProd);
        }
        return OppProducts;
    }
    
    public boolean validateOpportunity(OpportunityWrapper oppWrapper, OpportunityErrorMsg oppMsgs, boolean isUpdate){
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        oppMsgs.opportunityErrorMsgs = new Map<String, ErrorMsg>();     
        Set<String> validBooleanValues = new Set<String>{'true', 'false'};
        if(isUpdate){
            opportunityId = oppWrapper.opportunityId;
            opportunity = [Select Id, stagename, Core_Status_Update__c, Core_Design_Registration_Id__c from Opportunity where Id = :oppWrapper.opportunityId];
            if(opportunity.size() > 0){
                Boolean isStatusValid = false;
                for (String allowedStatus : allowedStatusList) {
                    if (opportunity[0].stagename == allowedStatus) {
                        isStatusValid = true;
                        break; // No need to continue checking if the status is valid
                    }
                }
                if(opportunity[0].Core_Design_Registration_Id__c == null){
                    addValidationError(oppMsgs.opportunityErrorMsgs, 'opportunityId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1005, null);
                    isValid = false;
                }
                if(!isStatusValid && opportunity[0].stagename != 'Design Win'){
                    addValidationError(oppMsgs.opportunityErrorMsgs, 'stage', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1011, null);
                    isValid = false;
                }
                if (statusPrecedence.containsKey(opportunity[0].stagename) && statusPrecedence.containsKey(oppWrapper.stage)) {
                    if (statusPrecedence.get(oppWrapper.stage) < statusPrecedence.get(opportunity[0].stagename)) {
                        addValidationError(oppMsgs.opportunityErrorMsgs, 'stage', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
                    	isValid = false;
                    }
                } else if(!statusPrecedence.containsKey(opportunity[0].stagename)){
                    addValidationError(oppMsgs.opportunityErrorMsgs, 'stage', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1011, null);
                	isValid = false;
                } else{
                    addValidationError(oppMsgs.opportunityErrorMsgs, 'stage', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                	isValid = false;
                }                
                
            }else if(oppWrapper.opportunityId == null || String.isBlank(oppWrapper.opportunityId.trim())){
                addValidationError(oppMsgs.opportunityErrorMsgs, 'opportunityId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
                isValid = false;
            }else{
                addValidationError(oppMsgs.opportunityErrorMsgs, 'opportunityId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                isValid = false;
            }
            
            boolean isDecisionDateValid = validateDates(oppWrapper.decisionDate, 'decisionDate', oppMsgs.opportunityErrorMsgs);
            boolean isProductionEndDateValid = validateDates(oppWrapper.productionEndDate, 'productionEndDate', oppMsgs.opportunityErrorMsgs);
            boolean isFirstCustomerShipDateValid = validateDates(oppWrapper.firstCustomerShipDate, 'firstCustomerShipDate', oppMsgs.opportunityErrorMsgs);
            boolean isCompetitiveArchitectureValid = validatePicklistValues(sObjOppFieldMap,'Core_Competitive_Architecture__c',oppWrapper.competitiveArchitecture, true, oppMsgs.opportunityErrorMsgs, 'competitiveArchitecture');
            //boolean isIntelPlatformValid = validatePicklistValues(sObjOppFieldMap,'Core_Intel_Platform__c',oppWrapper.intelPlatform,oppWrapper.stage == 'Design' ? true :false, oppMsgs.opportunityErrorMsgs, 'intelPlatform');
            boolean isManufacturingRegionValid = validatePicklistValues(sObjOppFieldMap,'Core_Manufacturing_Geo__c',oppWrapper.manufacturingRegion, true, oppMsgs.opportunityErrorMsgs, 'manufacturingRegion');
            boolean isArchitectureValid = validatePicklistValues(sObjOppFieldMap,'Core_Architecture_Conversion__c',oppWrapper.architectureConversion, true, oppMsgs.opportunityErrorMsgs, 'architecture');
            if(!isCompetitiveArchitectureValid || !isManufacturingRegionValid || !isArchitectureValid){
                isValid = false;
            }
            if(!validateOpportunityNumberFields(oppWrapper, fldValidMap, oppMsgs.opportunityErrorMsgs)){
                isValid = false;
            }
            /*
            if(!validBooleanValues.contains(oppWrapper.architectureConversion)){
                addValidationError(oppMsgs.opportunityErrorMsgs, 'architectureConversion', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1009, null);
                isValid = false;
            }*/
            oppMsgs.opportunityProductErrorMsgs = new List<OpportunityProductErrorMsg>();
            oppMsgs.opportunityPoPErrorMsgs = new List<OpportunityPoPErrorMsg>();
            validateOpportunityProducts(oppWrapper.opportunityProducts, oppMsgs, isUpdate );
            validateOpportunityDocuments(oppWrapper.opportunityPoP, oppMsgs, isUpdate );
        }
        
        return isValid; 
    }
    
    public boolean validateOpportunityProducts(List<OpportunityProducts> oppProducts, OpportunityErrorMsg oppMsgs, boolean isUpdate){
        OpportunityProductErrorMsg oppProdErrorMsg = new OpportunityProductErrorMsg();        
        if(oppProducts.size() > 0){
            putOppProductMap = new Map<Id,OpportunityLineItem>([SELECT id,Product2.Id,Core_Status__c,Quantity,UnitPrice,Core_Design_Registration_Product_Id__c from OpportunityLineItem 
                                                                where OpportunityId = :opportunityId]);
            for(OpportunityProducts oppProd:oppProducts){
                Boolean isKeyPresent = false;
                oppProdErrorMsg.opportunityProductId = oppProd.opportunityProductId;
                oppProdErrorMsg.opportunityProductErrors = new Map<String,ErrorMsg>();
                Map<String, boolean> fldValidMap = new Map<String, boolean>();
                
                for (Id mapKey : putOppProductMap.keySet()) {
                    if (String.valueOf(mapKey) == oppProd.opportunityProductId) {
                        isKeyPresent = true;
                        break; // No need to continue searching if found
                    }
                }
                
                if(oppProd.opportunityProductId == null || String.isBlank(oppProd.opportunityProductId.trim())){
                    addValidationError(oppProdErrorMsg.opportunityProductErrors, 'opportunityProductId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1012, null);
                    isValid = false;
                } else if(!isKeyPresent){
                    addValidationError(oppProdErrorMsg.opportunityProductErrors, 'opportunityProductId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013	, null);
                    isValid = false;
                }
                if(isKeyPresent){
                    OpportunityLineItem q = putOppProductMap.get(oppProd.opportunityProductId);
                    if(q.Core_Design_Registration_Product_Id__c == null){
                        addValidationError(oppProdErrorMsg.opportunityProductErrors, 'opportunityProductId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, null);
                        isValid = false;
                    }
                    if(q.Core_Status__c != 'Pending'){
                        addValidationError(oppProdErrorMsg.opportunityProductErrors, 'status', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1045, null);
                        isValid = false;
                    } 
                }                
                
                validateOppProductCurrencyFields(oppProd, fldValidMap, oppProdErrorMsg.opportunityProductErrors);
                if(!validateOpportunityProdNumberFields(oppProd, fldValidMap, oppProdErrorMsg.opportunityProductErrors)){
                    isValid = false;
                }
                if(oppProdErrorMsg.opportunityProductErrors != null && oppProdErrorMsg.opportunityProductErrors.isEmpty()){
                    oppProdErrorMsg.opportunityProductErrors = null;
                }
                
                if(oppProdErrorMsg.opportunityProductErrors != null){                    
                    oppMsgs.opportunityProductErrorMsgs.add(oppProdErrorMsg);
                }
            } 
                       
        }
        return isValid;
    }
    
    public boolean validateOpportunityDocuments(List<OpportunityPoP> oppDocs, OpportunityErrorMsg oppMsgs, boolean isUpdate){
        OpportunityPoPErrorMsg oppPoPErrorMsg = new OpportunityPoPErrorMsg();  
        oppPoPErrorMsg.opportunityPoPErrors = new Map<String,ErrorMsg>();
        if(oppDocs.size() > 0){
            if(oppDocs.size() > 10){
                addValidationError(oppPoPErrorMsg.opportunityPoPErrors, 'opportunityId', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1040, null);
                isValid = false;
            }
            for(OpportunityPoP oppDoc:oppDocs){
                if(String.isEmpty(oppDoc.fileRefNo)){
                    addValidationError(oppPoPErrorMsg.opportunityPoPErrors, 'fileRefNo', Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                    isValid = false;
                }else{
                    if(oppDoc.data == null || oppDoc.data.trim() == ''){
                        addValidationError(oppPoPErrorMsg.opportunityPoPErrors, oppDoc.fileRefNo, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1041, null);
                        isValid = false;
                    } else if(oppDoc.title == null || oppDoc.title.trim() == ''){
                        addValidationError(oppPoPErrorMsg.opportunityPoPErrors, oppDoc.fileRefNo, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1044, null);
                        isValid = false;
                    }else{
                        Boolean isValidExtension = false;
                        Blob fileBlob = EncodingUtil.base64Decode(oppDoc.data);
                        String fileName = oppDoc.title; // Extract filename from payload if available
                        String extractedExtension = fileName.substringAfterLast('.');
                        List<String> allowedExtensions = new List<String>{'msg'}; // Add your allowed extensions
                            
                            for (String extension : allowedExtensions) {
                                if (extractedExtension.equalsIgnoreCase(extension)) {
                                    isValidExtension = true;
                                    break;
                                }
                            }
                        if (!isValidExtension) {
                            addValidationError(oppPoPErrorMsg.opportunityPoPErrors, oppDoc.fileRefNo, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1042, null);
                            isValid = false;
                        }
                        Integer maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB maximum size
                        Integer fileSizeBytes = fileBlob.size();
                        if (fileSizeBytes > maxFileSizeBytes) {
                            // File size exceeds the allowed limit
                            addValidationError(oppPoPErrorMsg.opportunityPoPErrors, oppDoc.fileRefNo, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1043, null);
                            isValid = false;
                        }
                    }
                }  
            }    
            
            if(oppPoPErrorMsg.opportunityPoPErrors != null){                    
                oppMsgs.opportunityPoPErrorMsgs.add(oppPoPErrorMsg);
            }
        }
        return isValid;
    }
    
    //////////////////////
    public boolean validateOpportunityProdNumberFields(OpportunityProducts oppProd, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Quantity',oppProd.quantity, 'quantity', true));  
        return validNumberFields(sObjOppProdFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateOppProductCurrencyFields(OpportunityProducts oppProd, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('UnitPrice',oppProd.salesPrice, 'salesPrice',  true, true));
        return validateCurrencyFields(sObjOppProdFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateCurrencyFields(Map<String,Schema.SObjectField> objectMap, List<CurrencyFieldValueWrapper> currencyFldValues, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        boolean isCurrencyValid = true;
        if(currencyFldValues.size() > 0){
            for(CurrencyFieldValueWrapper currencyFld : currencyFldValues){
                if(!currencyFld.isMandatory && currencyFld.fldValue == null){
                    //do nothing - value can be blank if the field is not mandatory
                } else {
                    if(currencyFld.fldValue != null){
                        if(!currencyFld.allowZero && currencyFld.fldValue <= 0){
                            //if field value is negative or zero
                            isCurrencyValid = isValid = false;
                            fldValidMap.put(currencyFld.fldName, false);
                            addValidationError(errorMsgs, currencyFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
                        }else if(currencyFld.allowZero && currencyFld.fldValue < 0){
                            isCurrencyValid = isValid = false;
                            addValidationError(errorMsgs, currencyFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1025, null);
                        }else{
                            String[] fldValArr = String.valueOf(currencyFld.fldValue).split('\\.');
                            if(fldValArr[0].replace('-','').length() > NUMBER_FIELD_MAX_LENGTH){
                                //checking if input number field length is more than field max limit
                                isCurrencyValid = isValid = false;
                                fldValidMap.put(currencyFld.fldName, false);
                                addValidationError(errorMsgs, currencyFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1022, 
                                                   new Map<String,String>{'{{numberOfDigits}}' => String.valueOf(NUMBER_FIELD_MAX_LENGTH)});
                            }
                        }
                    }else {
                        //if field is empty for mandatory field
                        isCurrencyValid = isValid = false;
                        fldValidMap.put(currencyFld.fldName, false);
                        addValidationError(errorMsgs, currencyFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1023, null);
                    }
                } 
            }
        }
        return isCurrencyValid;
    }
    
    public class CurrencyFieldValueWrapper {
        public String fldName {set;get;}
        public String fldLabel {set;get;}
        public Decimal fldValue {set;get;}
        public boolean isMandatory {set;get;}
        public boolean allowZero {set; get;}
        public CurrencyFieldValueWrapper(String name, Decimal val, boolean isMandatry){
            fldName = name;
            fldValue = val;
            isMandatory = isMandatry;
        }
        public CurrencyFieldValueWrapper(String name, Decimal val, String fldLbl, boolean isMandatry, boolean allowZeroFlag){
            fldName = name;
            fldValue = val;
            fldLabel = fldLbl;
            isMandatory = isMandatry;
            allowZero = allowZeroFlag;
        }
    }
    
    public static boolean validateDates(String validateDate, String fldLabel, Map<String,ErrorMsg> errorMsgs){
        boolean isDateValid = true;
        if(validateDateFormat(validateDate,true,fldLabel, errorMsgs)){
            Date dtDate = Date.parse(validateDate);
            if(dtDate < (System.today()+1)){
                isDateValid = isValid = false;
                //Date has already passed. Please enter a Date more than one day in the future.
                addValidationError(errorMsgs, fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1002, null);
            }
        }else{
            //Date value is not a valid one            
            isDateValid = isValid = false;
        }
        return isDateValid;
    }
    
    public static boolean validateDateFormat(String inputDate, boolean isMandatory, String fldLabel, Map<String,ErrorMsg> errorMsgs){
        boolean isDateValid = true;
        if(!isMandatory && String.isEmpty(inputDate)){
            // Date can be empty if it is not mandatory
        }else{
            try {
                Date d = Date.parse(inputDate);		//check if date is a valid format(mm/dd/yyyy)
            }catch(Exception e) {
                if(errorMsgs!=null){
                    addValidationError(errorMsgs, fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1024, null);
                }                
                isDateValid = isValid = false;
            }
        }
        return isDateValid;
    }
    
    public static boolean validatePicklistValues(Map<String,Schema.SObjectField> objectMap, String fieldName, String fldValue, boolean isMandatory, Map<String,ErrorMsg> errorMsgs, String jsonLabel){
        boolean isFldValid = false;
        boolean isEmpty = false;
        if(!isMandatory && String.isEmpty(fldValue)){
            isFldValid = true;
            //do nothing - value can be blank if the field is not mandatory
        }else{
            Schema.DescribeFieldResult fldRes = objectMap.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fldRes.getPicklistValues();
            if(fldValue!=null && !String.isEmpty(fldValue.trim())){               
                for( Schema.PicklistEntry f : ple)
                {
                    if(f.isActive() && f.getValue() == fldValue){
                        isFldValid =  true; 
                        break;
                    }
                }
            }else {
                isEmpty = true;
                addValidationError(errorMsgs, jsonLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            }
            if(!isEmpty && !isFldValid){
                addValidationError(errorMsgs, jsonLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1026, 
                                   new Map<String,String>{'{{fieldValue}}' => fldValue});
            }
        }
        return isFldValid;
    }
    
    public boolean validateOpportunityNumberFields(OpportunityWrapper oppWrapper, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Core_Volume__c',oppWrapper.volume, 'volume', true));  
        return validNumberFields(sObjOppFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validNumberFields(Map<String,Schema.SObjectField> objectMap, List<NumberFieldValueWrapper> numberFldValues, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){       
        boolean isNumValid = true;
        if(numberFldValues.size() > 0){
            for(NumberFieldValueWrapper numFld : numberFldValues){
                if(!numFld.isMandatory && (numFld.fldValue == null || numFld.fldValue == 0)){
                    //do nothing - value can be blank if the field is not mandatory 
                } else {
                    if(numFld.fldValue != null){
                        if(numFld.fldValue <= 0){
                            //if field value is negative or zero
                            isNumValid = isValid = false;
                            fldValidMap.put(numFld.fldName, false);
                            addValidationError(errorMsgs, numFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
                        }else{
                            String[] fldValueArr = String.valueOf(numFld.fldValue).split('\\.');   
                            if(fldValueArr.size()>1 && Decimal.valueOf('.'+fldValueArr[1]) > 0){	//number fields can only accept whole number
                                isNumValid = isValid = false;
                                fldValidMap.put(numFld.fldName, false);
                                addValidationError(errorMsgs, numFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1039, null);
                            }else if(fldValueArr[0].length() > NUMBER_FIELD_MAX_LENGTH){
                                //checking if input number field length is more than field max limit
                                isNumValid = isValid = false;
                                fldValidMap.put(numFld.fldName, false);
                                addValidationError(errorMsgs, numFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1022, 
                                                   new Map<String,String>{'{{numberOfDigits}}' => String.valueOf(NUMBER_FIELD_MAX_LENGTH)});
                            }
                        }                        
                    }else{
                        //if field is empty for mandatory field
                        fldValidMap.put(numFld.fldName, false);
                        addValidationError(errorMsgs, numFld.fldLabel, Core_RestAPI_ResponseCodes.VALID_ERROR_CODE_1023, null);
                        isNumValid = isValid = false;
                    }                    
                } 
            }
        }
        return isNumValid;
    }
}