/**
* @description       : Class containing all the validation related to Ver>2 API
* @author            : Accenture
* @group             : Gravity
* @last modified on  : 11-10-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class Pricing_RestAPI_QuotesUtilityV2 extends TriggerHandler {
    
    public static Map<String,List<String>> consumptionTypeToValueMap = new Map<String,List<String>>();
    public Map<String,Schema.SObjectField> sObjQuoteLineFieldMap;
    public Map<String,Schema.SObjectField> sObjQuoteFieldMap;
    public Map<String,Schema.SObjectField> sObjPerformanceMatrixFieldMap;
    public Map<String,Schema.SObjectField> SObjectCommentsMap;
    public static Map<Id, Product2> productIdMap = new Map<Id, Product2>();
    public static Map<Id, Pricing_Competitor_Product__c> compProductIdMap = new Map<Id, Pricing_Competitor_Product__c>(); 
    public static Map<String, String> errorMap = new Map<String, String>();
    public static User currentUser = new User();
    public static boolean isValid = true;
    //public static List<boolean> isValidQuotelineList = new List<boolean>();
    public Static Integer NUMBER_FIELD_MAX_LENGTH = 16;
    public static Integer TEXT_FIELD_MAX_LENGTH = 100;
    public Static Map<Decimal, String> errorMsgMap = new Map<Decimal, String>();
    public static List<Pricing_Comments__c> qComms = new List<Pricing_Comments__c>();
    //public static Set<String> jsonRecIds = new Set<String>();
    public static Map<String,Id> validFSEEmailIdMap = new Map<String,Id>();
    public static Map<String,Id> validAeEmailIdMap = new Map<String,Id>();
    public static String primaryFSEEMail = '';
    public static String primaryAEEMail = '';
    public static List<User> AEEmailUserList = new List<User>();
    public static List<User> ITSEmailUserList = new List<User>();
    public static boolean isCreateDraftQuote = false;
    public static boolean isQuotelineDraftQuote = false;
    public static boolean isUpdateDraftQuote = false;
    public static String quoteId;
    public static Id quoteTeamRecordTypeId;
    public static Id quoteCreateRecordTypeId;
    public static Id quoteLineCreateRecordTypeId;
    public static Map<String, Set<String>> quotelineIdPerfMap = new Map<String, Set<String>>();
    public static String updateQuotelineId;
    public static Boolean isPerfMetricsAvailable = false;
    public static Map<Id, SBQQ__QuoteLine__c> patchQuotelineMap;
    public static Map<String, List<Pricing_Quote_Team__c>> createNewQTMMap = new Map<String, List<Pricing_Quote_Team__c>>();
    public static String writeInUnifiedId = '';
    public static Decimal overallQuantity = 0;
    public static Decimal overallQuantityCPU = 0;
    public static List<String> qtmUserEmailsList = new List<String>();
    public static String assignedRecordTypeId = '';
    public static Boolean calledFromQuote = false;
    public static Boolean isOverAllQtyLess = false;
    public static Boolean isSubmitQuote = false;
    public static List<SBQQ__Quoteline__c> quotelineList;
    public static String marketSegmentValue = '';
    
    //recordTypeId variables
    public static String quoteLineSVDCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Create);
    public static String quoteLineClientCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_CCG_Quote_Line_Create);
    public static String quoteLineSSDCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SSD_Quote_Line_Create);
    public static String quoteLinePMemCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_PMem_Quote_Line_Create);
    public static String quoteLineEthernetCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_NIC_Quote_Line_Create);
    public static String quoteLineDatacenterGPUCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_GPU_DataCenter_QuoteLine_Create);
    
    
    //static variable for Quote Type
    public static boolean isSvd = false;
    public static boolean isClient = false;
    public static boolean isDataCenterCPU = false;
    public static boolean isDataCenterQuote = false;
    
    //Added as per US871923
    public static boolean isValidAE = true;
    
    //Added as per US936155
    //public static String currentUserAccountId = '';
    
    /**
    * @description Constructor to assign default variables
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    **/
    public Pricing_RestAPI_QuotesUtilityV2(){
        sObjQuoteLineFieldMap = Schema.sObjectType.SBQQ__QuoteLine__c.fields.getMap();
        sObjQuoteFieldMap = Schema.sObjectType.SBQQ__Quote__c.fields.getMap();
        sObjPerformanceMatrixFieldMap = Schema.sObjectType.Pricing_Performance_Metric__c.fields.getMap();
        SObjectCommentsMap=Schema.SObjectType.Pricing_Comments__c.fields.getMap();
        currentUser = [SELECT id,Name,AccountId,ContactId,Email FROM User WHERE id= :UserInfo.getUserId()];
        List<Pricing_Rest_API_Validation_Error_Msgs__mdt> errorMdts  = [SELECT Error_Code__c,Error_Message__c FROM Pricing_Rest_API_Validation_Error_Msgs__mdt limit 500];
        for(Pricing_Rest_API_Validation_Error_Msgs__mdt errMdt : errorMdts){
            errorMsgMap.put( ((Integer) errMdt.Error_Code__c), errMdt.Error_Message__c);
        }
        //currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
        quoteTeamRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Team__c',Label.Pricing_Tender_Quote_Team_RecordType);
        quoteCreateRecordTypeId = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='SBQQ__Quote__c' and DeveloperName = 'Pricing_Tender_Quote_Create' limit 1].Id;
        quoteLineCreateRecordTypeId = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='SBQQ__QuoteLine__c' and DeveloperName = 'Pricing_Tender_Quote_Line_Create' limit 1].Id;
        writeInUnifiedId = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where Name = :Label.Pricing_IQR_API_WriteInEndCustomer limit 1].Id;
    }
    
    /*************************** validate Quote details **********************************/
    //this method validates only quote details is isSubmit is false otherwise validates quotelines of respective quote
    public boolean validateQuote(QuoteWrapper quoteWrapper, QuoteErrorMsg quoteMsgs, boolean isSubmit){
        quoteMsgs.quoteErrors = new Map<String, ErrorMsg>();
        QuoteDetails quoteDetails = quoteWrapper.quoteDetails;
        Set<String> aeEmailList = new Set<String>();
        Set<String> fseEmailList = new Set<String>();
        Set<String> itsEmailList = new Set<String>();
        boolean duplicateEmail = false;
        List<SBQQ__Quote__c> quote = new List<SBQQ__Quote__c>();
        if(isUpdateDraftQuote || Pricing_RestAPI_QuotesV2.isCreateQuoteTeam){
            quote = [Select Id, SBQQ__Status__c,Pricing_Program_Type_Nm__c, (Select id, Pricing_Quote_Team_Member_Id__r.Email, Pricing_Role_Nm__c from Quote_Teams__r) from SBQQ__Quote__c where Id = :quoteWrapper.quoteId];
        }
        if(isUpdateDraftQuote){
            isClient = quote[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote;
            isDataCenterCPU = quote[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote;
            isSvd = quote[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote;
        }
        if(isSvd && !Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed(currentUser.AccountId)){
            addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1072, null);
            isValid=false;
        }
        else{
            if(isSvd && Pricing_Manage_Small_Volume_Deal.capSizeCheck(currentUser.AccountId).split(':')[0] == 'false'){
                addValidationError(quoteMsgs.quoteErrors, 'svdCapSize', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1070, new Map<String,String>{'{value}'=>String.ValueOf(Integer.valueOf(Pricing_Manage_Small_Volume_Deal.capSizeCheck(currentUser.AccountId).split(':')[1]))});
                isValid=false;
            }
            else{
                Map<String,List<String>> qtmRoleEmailMap = new Map<String,List<String>>();
                if(isUpdateDraftQuote || Pricing_RestAPI_QuotesV2.isCreateQuoteTeam){
                    if(quote.size() > 0){                
                        List<Pricing_Quote_Team__c> aeEmail = new List<Pricing_Quote_Team__c>();
                        List<Pricing_Quote_Team__c> fseEmail = new List<Pricing_Quote_Team__c>();
                        List<Pricing_Quote_Team__c> itsEmail = new List<Pricing_Quote_Team__c>();
                        for(Pricing_Quote_Team__c qtm: quote[0].Quote_Teams__r){
                            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_FSE){
                                fseEmail.add(qtm);
                            }
                            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive){
                                aeEmail.add(qtm);
                            }
                            if(qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS){
                                itsEmail.add(qtm);
                            }
                            qtmUserEmailsList.add(qtm.Pricing_Quote_Team_Member_Id__r.Email);
                            if(!qtmRoleEmailMap.containsKey(qtm.Pricing_Role_Nm__c)){
                                qtmRoleEmailMap.put(qtm.Pricing_Role_Nm__c, new List<String>());
                            }
                            qtmRoleEmailMap.get(qtm.Pricing_Role_Nm__c).add(qtm.Pricing_Quote_Team_Member_Id__r.Email);
                        }
                        createNewQTMMap.put('AE', aeEmail);
                        createNewQTMMap.put('FSE', fseEmail);
                        createNewQTMMap.put('ITS', itsEmail);
                        quoteId = quoteWrapper.quoteId;
                        if(isUpdateDraftQuote && quote[0].SBQQ__Status__c != Label.Pricing_RestAPI_Status_Draft){
                            addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1043, null);
                            isValid = false;
                        }
                        if(quote[0].Pricing_Program_Type_Nm__c==Label.Pricing_Tender_Small_Volume_Quote){
                            Pricing_RestAPI_QuotesV2.isSvdQuote=true;
                        }
                    }else if(quoteWrapper.quoteId == null || String.isBlank(quoteWrapper.quoteId.trim())){
                        addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
                        isValid = false;
                    }else{
                        addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                        isValid = false;
                    }
                }
                if((quoteDetails.intelSalesRepEmail!=null && !String.isBlank(quoteDetails.intelSalesRepEmail.trim())) ||
                   (quoteDetails.intelAccountExecutiveEmail!=null && !String.isBlank(quoteDetails.intelAccountExecutiveEmail.trim())) || 
                   (quoteDetails.industryTechnicalSpecialistEmail!=null && !String.isBlank(quoteDetails.industryTechnicalSpecialistEmail.trim()))){
                       
                       if(quoteDetails.intelSalesRepEmail!=null && quoteDetails.intelSalesRepEmail.trim() != ''){                            
                           for(String email: getSplitedEmailList(quoteDetails.intelSalesRepEmail)){                            
                               if( (qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive).contains(email.toLowerCase().trim())) 
                                  ||(qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS).contains(email.toLowerCase().trim()))
                                  || ((qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE).contains(email.toLowerCase().trim())) && Pricing_RestAPI_QuotesV2.isCreateQuoteTeam)
                                 ){
                                     duplicateEmail = true;
                                     break;
                                 }
                               if(email.trim().length() > 0){
                                   fseEmailList.add(email.toLowerCase().trim());
                               }
                           }
                       }
                       if(quoteDetails.intelAccountExecutiveEmail!=null && quoteDetails.intelAccountExecutiveEmail.trim() != ''){
                           for(String email: getSplitedEmailList(quoteDetails.intelAccountExecutiveEmail)){ 
                               if( fseEmailList.contains(email.toLowerCase().trim()) 
                                  || (qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE).contains(email.toLowerCase().trim())) 
                                  ||(qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS).contains(email.toLowerCase().trim()))
                                  || ((qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive).contains(email.toLowerCase().trim())) && Pricing_RestAPI_QuotesV2.isCreateQuoteTeam)
                                 ){
                                     duplicateEmail = true;
                                     break;
                                 }
                               if(email.trim().length() > 0){
                                   aeEmailList.add(email.toLowerCase().trim());
                               }
                           }
                       }
                       if(!duplicateEmail && quoteDetails.industryTechnicalSpecialistEmail!=null && quoteDetails.industryTechnicalSpecialistEmail.trim() != ''){
                           for(String email: getSplitedEmailList(quoteDetails.industryTechnicalSpecialistEmail)){ 
                               if(fseEmailList.contains(email.toLowerCase().trim()) || aeEmailList.contains(email.toLowerCase().trim())
                                  || (qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_FSE).contains(email.toLowerCase().trim())) 
                                  ||(qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_Account_Executive).contains(email.toLowerCase().trim()))
                                  || ((qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS) != null && qtmRoleEmailMap.get(Label.Pricing_Quote_Team_Role_ITS).contains(email.toLowerCase().trim())) && Pricing_RestAPI_QuotesV2.isCreateQuoteTeam)
                                 ){
                                     duplicateEmail = true;
                                     break;
                                 }
                               if(email.trim().length() > 0){
                                   itsEmailList.add(email.toLowerCase().trim());
                               }
                           }
                       }
                   }
                if(Pricing_RestAPI_QuotesV2.isCreateQuoteTeam){
                    if(quoteDetails.intelSalesRepEmail==null && 
                       quoteDetails.intelAccountExecutiveEmail==null && 
                       quoteDetails.industryTechnicalSpecialistEmail==null){
                           addValidationError(quoteMsgs.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1056, null);
                           isValid = false;
                       }else if((quoteDetails.intelSalesRepEmail!=null && 
                                 quoteDetails.intelAccountExecutiveEmail!=null && 
                                 quoteDetails.industryTechnicalSpecialistEmail!=null) &&
                                String.isEmpty(quoteDetails.intelSalesRepEmail.trim()) && 
                                String.isEmpty(quoteDetails.intelAccountExecutiveEmail.trim()) && 
                                String.isEmpty(quoteDetails.industryTechnicalSpecialistEmail.trim())){
                                    addValidationError(quoteMsgs.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1056, null);
                                    isValid = false;
                                }else{
                                    if(duplicateEmail){
                                        addValidationError(quoteMsgs.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1055, null);
                                        isValid = false;
                                    }else{
                                        if(quote.size() > 0){
                                            if(quoteDetails.intelSalesRepEmail != null && quoteDetails.intelSalesRepEmail != '' && !validateSalesRep(quoteDetails.intelSalesRepEmail, quoteMsgs.quoteErrors, (isSubmit && !isCreateDraftQuote))){
                                                isValid = false;
                                            }
                                            
                                            if(!validateAccountExecutive(quoteDetails.intelAccountExecutiveEmail, quoteMsgs.quoteErrors)){
                                                isValidAE = isValid = false;
                                            }
                                            
                                            //validating ITS Email Id if it is not empty
                                            if(!validateITSEmail(quoteDetails.industryTechnicalSpecialistEmail, quoteMsgs.quoteErrors)){
                                                isValid = false;
                                            }
                                            
                                        }else{
                                            addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                                            isValid = false;
                                        }
                                    }
                                }
                    return isValid;
                }
                
                if(duplicateEmail){
                    addValidationError(quoteMsgs.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1055, null);
                    isValid = false;
                }
                boolean isProposalDueDateValid = validateBidPricingDates(quoteDetails.proposalDueDate, 'proposalDueDate', quoteMsgs.quoteErrors);
                boolean isIntelResponseDateValid = validateBidPricingDates(quoteDetails.intelResponseRequestedDate, 'intelResponseRequestedDate', quoteMsgs.quoteErrors);
                if(isProposalDueDateValid && isIntelResponseDateValid && (Date.parse(quoteDetails.intelResponseRequestedDate) > Date.parse(quoteDetails.proposalDueDate))){
                    isValid = false;
                    addValidationError(quoteMsgs.quoteErrors, 'intelResponseRequestedDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1073, null); 
                }
                boolean isPricingStartDateValid = validateBidPricingDates(quoteDetails.pricingStartDate, 'pricingStartDate', quoteMsgs.quoteErrors);
                boolean isPricingEndDateValid = validateBidPricingDates(quoteDetails.pricingEndDate, 'pricingEndDate', quoteMsgs.quoteErrors);
                if( isPricingStartDateValid && isPricingEndDateValid){
                    Date pricingStartDate = Date.parse(quoteDetails.pricingStartDate);
                    Date pricingEndDate = Date.parse(quoteDetails.pricingEndDate);
                    if(pricingEndDate < pricingStartDate){
                        isValid = false;
                        addValidationError(quoteMsgs.quoteErrors, 'pricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1001, null);
                    }
                    if(!isCreateDraftQuote && pricingEndDate == pricingStartDate){
                        isValid = false;
                        addValidationError(quoteMsgs.quoteErrors, 'pricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1088, null); 
                    }
                }
                if(isUpdateDraftQuote && isPricingStartDateValid){
                    quotelineList = [select id, Pricing_End_Date_dt__c,Pricing_Quote_Line_Number__c,Pricing_Original_Submitted_Date_dt__c,SBQQ__Quote__r.SBQQ__Status__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteWrapper.quoteId order by Pricing_Quote_Line_Number__c  asc];
                    for(SBQQ__Quoteline__c ql : quotelineList){
                        if(ql.Pricing_End_Date_dt__c < Date.parse(quoteDetails.pricingStartDate)){
                            addValidationError( quoteMsgs.quoteErrors, 'pricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1058, null);
                            isValid = false;
                            break;
                        }
                    }
                }
                //validate salesRep email if it is not empty
                if(!validateSalesRep(quoteDetails.intelSalesRepEmail, quoteMsgs.quoteErrors, (isSubmit && !isCreateDraftQuote))){
                    isValid = false;
                }
                
                //validating accountExecutiveEmail Id if it is not empty
                if(!validateAccountExecutive(quoteDetails.intelAccountExecutiveEmail, quoteMsgs.quoteErrors)){
                    
                    //Commented as per US871923
                    isValidAE = false;
                    if(isUpdateDraftQuote){
                        isValid = false;
                    }
                }
                
                validateITSEmail(quoteDetails.industryTechnicalSpecialistEmail, quoteMsgs.quoteErrors);
                
                
                //Validate all Text fields
                validateQuoteTextFields(quoteDetails, sObjQuoteFieldMap, quoteMsgs.quoteErrors);
                
                if(!validateEndCustomer(quoteDetails,quoteMsgs.quoteErrors)){
                    isValid=false;
                }
                //application value validation for svd and ssd
                validateApplication(quoteDetails,quoteMsgs.quoteErrors);
                
                //checking Application Picklist 
                isValid = !isClient ? validatePicklistValues(sObjQuoteFieldMap,'Pricing_Server_Deal_Type_Nm__c',quoteDetails.application, true, quoteMsgs.quoteErrors, 'application') ? isValid : false : validatePicklistValues(sObjQuoteFieldMap,'Pricing_Market_Segment_values_Nm__c',quoteDetails.marketSegment, true, quoteMsgs.quoteErrors, 'marketSegment') ? isValid : false;  
                //validate End Customer Country
                if(!validatePicklistValues(sObjQuoteFieldMap,'Pricing_End_Customer_Country_Nm__c',quoteDetails.endCustomerCountry, true, quoteMsgs.quoteErrors, 'endCustomerCountry')){
                    isValid=false;
                }
                else{
                    Map<String, List<String>> countryRegionMap = new Map<String, List<String>>(getFieldDependencies('SBQQ__Quote__c', 'Pricing_End_Customer_Country_Nm__c', 'Pricing_Region_Nm__c')); 
                    String region = countryRegionMap.get(quoteDetails.endCustomerCountry)[0];
                    if(Label.Pricing_Tender_SVD_Restrict_Region.split(',').contains(region) && isSvd){
                        addValidationError( quoteMsgs.quoteErrors, 'endCustomerRegion', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1068, null);
                        isValid = false;
                    }
                }
                
                //validate primary contact email
                if(!String.isBlank(quoteDetails.primaryContactEmail) && !validatePrimaryContact(quoteDetails.primaryContactEmail, quoteDetails.primaryContactEmail, quoteMsgs.quoteErrors)){
                    isValid = false;
                }
                String regex = Label.Pricing_Tender_QuoteLetterRecepient_Regex;
                List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();//TextFieldValueWrapper
                textFldValues.add(new TextFieldValueWrapper('Pricing_AdditionalRecipients__c',quoteDetails.additionalQuoteLetterRecipients, 'additionalQuoteLetterRecipients', false));
                if(!String.isBlank(quoteDetails.additionalQuoteLetterRecipients) && validTextFields(sObjQuoteFieldMap, textFldValues, quoteMsgs.quoteErrors)){
                    if(!Pattern.matches(regex, quoteDetails.additionalQuoteLetterRecipients.trim()) || quoteDetails.additionalQuoteLetterRecipients.trim().contains('@intel.com') ){
                        addValidationError( quoteMsgs.quoteErrors, 'additionalQuoteLetterRecipients', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1076, null);
                        isValid = false;
                    }
                }
                
                /* 
                //validate End Customer URL using Regex
                String regexendCustomerUrl = '^(https?://)?(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(/.*)?$';
                if(!String.isBlank(quoteDetails.endCustomerUrl)){
                    if(!Pattern.matches(regexendCustomerUrl, quoteDetails.endCustomerUrl.trim()) ){
                    addValidationError( quoteMsgs.quoteErrors, 'endCustomerUrl', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1102, null);
                    isValid = false;
                    }
                }
                */

                if(isSubmit){
                    //validate quotelines and quote comments if isSubmit is true(submit quote API-action=submit)
                    quoteMsgs.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>();
                    calledFromQuote=true;
                    validateQuoteLines(quoteDetails.quoteLines,(isPricingStartDateValid ? Date.parse(quoteDetails.pricingStartDate) : null), quoteMsgs, isSubmit, quoteDetails.marketSegment);
                    validateQuoteComments(quoteDetails.quoteComments, quoteMsgs,Pricing_RestAPI_QuotesV2.isResubmit?quoteWrapper.quoteId.trim():null);
                }
            }
        }
        return isValid;
    }
    
    /**
    * @description adding quote text field to wrapper to validate lenght, latin character and required value
    * @author Accenture | 05-24-2022 
    * @param quoteDetails 
    * @param sObjQuoteFieldMap 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateQuoteTextFields(QuoteDetails quoteDetails, Map<String,Schema.SObjectField> sObjQuoteFieldMap, Map<String,ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();//TextFieldValueWrapper
        textFldValues.add(new TextFieldValueWrapper('Pricing_Customer_Nm__c',quoteDetails.endCustomer, 'endCustomer', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Project_Name_Nm__c',quoteDetails.projectName, 'projectName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Customer_Reference_Id__c',quoteDetails.referenceRequestID, 'referenceRequestID',true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_SecondaryContact_Nm__c',quoteDetails.secondaryContact, 'secondaryContact',false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Partner_Name_Nm__c',quoteDetails.partnerName, 'partnerName',false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_End_Customer_URL__c',quoteDetails.endCustomerUrl, 'endCustomerUrl',false));
        return validTextFields(sObjQuoteFieldMap, textFldValues, errorMsgs);        
    }
    
    /**
    * @description validating Applicatioin values for SVD quote
    * @author Accenture | 05-24-2022 
    * @param quoteDetails 
    * @param errorMsgs 
    **/
    public static void validateApplication(QuoteDetails quoteDetails,Map<String,ErrorMsg> errorMsgs){
        if(quoteDetails.application!=null && (quoteDetails.application!=Label.Pricing_Application_HPC && quoteDetails.application!=Label.Pricing_Application_Enterprise) && isSvd){
            addValidationError( errorMsgs, 'application', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1071, null);
            isValid = false;    
        }
    }
    
    /**
    * @description validating date fields for future date and format
    * @author Accenture | 05-24-2022 
    * @param bidPricingDate 
    * @param fldLabel 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateBidPricingDates(String bidPricingDate, String fldLabel, Map<String,ErrorMsg> errorMsgs){
        boolean isDateValid = true;//validate proposal Due Date
        if(validateDateFormat(bidPricingDate,true,fldLabel, errorMsgs)){
            Date dtBidPricingDate = Date.parse(bidPricingDate);
            if((fldLabel == 'intelResponseRequestedDate' || fldLabel == 'proposalDueDate') && dtBidPricingDate <=  (Date.today()+1)){
                isDateValid = isValid = false;
                //Date has already passed. Please enter a Date more than one day in the future.
                addValidationError(errorMsgs, fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1002, null);
            }else if(dtBidPricingDate <  (System.today()+1)){
                isDateValid = isValid = false;
                //Date has already passed. Please enter a Date more than one day in the future.
                addValidationError(errorMsgs, fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1002, null);
            }
        }else{
            //Date value is not a valid one            
            isDateValid = isValid = false;
        }
        return isDateValid;
    }
    
    /**
    * @description validating end customer for correct id or write in end customer
    * @author Accenture | 05-24-2022 
    * @param quoteDetails 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateEndCustomer(QuoteDetails quoteDetails, Map<String,ErrorMsg> errorMsgs){
        boolean isValidEndCustomer = true;
        if(quoteDetails.endCustomer != null && quoteDetails.endCustomer.contains('|')){
            addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1103, null); 
            isValidEndCustomer = false;
        }
        if(quoteDetails.endCustomer != null && quoteDetails.endCustomer.toLowerCase().equals('any')){
            addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1064, null); 
            isValidEndCustomer = false;
        }
        if(quoteDetails.unifiedEndCustomerId != null && quoteDetails.unifiedEndCustomerId.trim() != ''){
            if(quoteDetails.unifiedEndCustomerId.trim().equals(writeInUnifiedId)){
                if(String.isBlank(quoteDetails.endCustomer)){
                    addValidationError(errorMsgs, 'unifiedEndCustomerId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1065, null);
                    isValidEndCustomer = false;
                }
            }else{                    
                List<Pricing_UnifiedEndCustomerAccountMapping__c> endCustmr = [select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Id = :quoteDetails.unifiedEndCustomerId and Pricing_Account_Nm__c = :currentUser.AccountId];
                if(endCustmr.size() == 0){
                    addValidationError(errorMsgs, 'unifiedEndCustomerId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, new Map<String, String>{'Quote' => 'Unified End Customer'});
                    isValidEndCustomer = false;
                }else if(!quoteDetails.unifiedEndCustomerId.trim().equals(writeInUnifiedId) && (!String.isBlank(quoteDetails.endCustomer))){
                    addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1066, null);
                    isValidEndCustomer = false;
                }else{
                    writeInUnifiedId = endCustmr[0].Id;
                }                    
            }
        }
        if((quoteDetails.unifiedEndCustomerId == null || quoteDetails.unifiedEndCustomerId.trim() == '') && (quoteDetails.endCustomer == null || quoteDetails.endCustomer.trim() == '')){
            addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            isValidEndCustomer = false;
        }
        return isValidEndCustomer;
    }
    
    /**
    * @description validating the email format with @intel.com
    * @author Accenture | 05-24-2022 
    * @param emailids 
    * @param fldLabel 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateEmailIds(Set<String> emailids, String fldLabel, Map<String,ErrorMsg> errorMsgs){
        Boolean isValidEmail=true;
        for(String emailId : emailids){
            //validate if input Email ID is of intel domain(intel.com)
            if(!Pattern.matches(Label.Pricing_IQR_IntelEmail_Regex, emailId.toLowerCase()))
            {
                addValidationError(errorMsgs, fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1003, null); 
                isValidEmail=false;
                isValid=false;
                break;
            }
        }
        return isValidEmail;
    }
    
    /**
    * @description validating FSE in request
    * @author Accenture | 05-24-2022 
    * @param salesRepEmail 
    * @param errorMsgs 
    * @param isSubmit 
    * @return boolean 
    **/
    public static boolean validateSalesRep(String salesRepEmail, Map<String,ErrorMsg> errorMsgs, boolean isSubmit){
        boolean isSalesRepValid = true;
        //intelSalesRepEmail
        if(salesRepEmail == null && isCreateDraftQuote){
            return true;
        }
        if(isSubmit && (salesRepEmail == null || String.isEmpty(salesRepEmail.trim()))){      //Sales Rep Email Id cant be blank is isSubmit=true
            addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
            isSalesRepValid = false;
        }else if(!String.isBlank(salesRepEmail)){
            Set<String> oemEmailIds = new Set<String>(getSplitedEmailList(salesRepEmail.toLowerCase()));  
            Set<String> trimmedEmailIds = new Set<String>();
            for(String email : oemEmailIds){
                if(email.trim() != ''){
                    trimmedEmailIds.add(email.trim());
                }  
            }
            if(validateEmailIds(trimmedEmailIds, 'intelSalesRepEmail', errorMsgs) || trimmedEmailIds.size() > 1){
                Map<Id,Set<String>> accountIdToSalesRepEmailMap = new Map<Id,Set<String>>();
                Map<Id,Set<String>> accountToValidEmailMap = new Map<Id,Set<String>>();
                Map<String, PermissionSetAssignment> salesRepAssignment = new Map<String, PermissionSetAssignment>(); 
                Id acctId = currentUser.AccountId;
                accountIdToSalesRepEmailMap.put(acctId, trimmedEmailIds);
                
                accountToValidEmailMap = getSalesrepMap(trimmedEmailIds, accountIdToSalesRepEmailMap, salesRepAssignment);
                if(accountToValidEmailMap.containsKey(acctId)){
                    //validate if Sales Rep Email Id is associated to a right SalesRep User in salesforce
                    Set<String> validFSEEmails = accountToValidEmailMap.get(acctId);
                    for(String emailid : trimmedEmailIds){
                        if(validFSEEmails.contains(emailid.toLowerCase())){
                            validFSEEmailIdMap.put(emailid.toLowerCase(),salesRepAssignment.get(emailid.toLowerCase()).AssigneeId);
                            if(validFSEEmails.size()>0){
                                primaryFSEEMail = (String.isBlank(primaryFSEEMail) && !Pricing_RestAPI_QuotesV2.isCreateQuoteTeam) ? emailid.toLowerCase() : primaryFSEEMail;
                            }
                            //break;
                        }
                    }
                }
                if(validFSEEmailIdMap.size() == 0){//&& !isUpdateDraftQuote){
                    isSalesRepValid = false;
                    addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
                }
            }else{
                isSalesRepValid = false;
                addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
            }
        }
        return isSalesRepValid;
    }
    
    /**
    * @description validating AE in request
    * @author Accenture | 05-24-2022 
    * @param AEemail 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateAccountExecutive(String AEemail, Map<String,ErrorMsg> errorMsgs){
        //this method validates Account Executive Email Id if it is not empty
        //Account Executive email id should be a valid intel email id and of a active salesforce User
        Boolean isValidAE=true;
        if(!String.isBlank(AEemail)){
            List<String> trimmedAEemailList = new List<String>();
            Set<String> emailIds =  new Set<String>(getSplitedEmailList(AEemail.toLowerCase())); 
            Set<String> trimmedEmailIds = new Set<String>();
            for(String email : emailIds){
                if(email.trim() != ''){
                    trimmedAEemailList.add(email.trim()); 
                    trimmedEmailIds.add(email.trim()); 
                }
            }
            if(validateEmailIds(trimmedEmailIds, 'intelAccountExecutiveEmail', errorMsgs) || trimmedEmailIds.size() > 1){
                Set<String> validAEEmailIdSet = getAccountExecutiveMap(trimmedEmailIds);
                Integer i = trimmedAEemailList.size();
                boolean validEmails = false;
                for(String validAe: validAEEmailIdSet){                    
                    if(trimmedAEemailList.contains(validAe)){
                        if(trimmedAEemailList.indexOf(validAe) < i){
                            i=trimmedAEemailList.indexOf(validAe);
                            validEmails = true;
                        }                        
                    }
                }
                if(validEmails == true){
                    primaryAEEmail = trimmedAEemailList[i];
                }                
            }else{
                isValidAE = false; 
            }
        }
        return isValidAE;
    }
    
    /**
    * @description validate ITS in request
    * @author Accenture | 05-24-2022 
    * @param ITSEmail 
    * @param errorMsgs 
    * @return boolean 
    **/
    public static boolean validateITSEmail(String ITSEmail, Map<String,ErrorMsg> errorMsgs){
        Boolean isValidITS=true;
        if(!String.isBlank(ITSEmail)){
            Set<String> emailIds = new Set<String>(getSplitedEmailList(ITSEmail.toLowerCase())); 
            Set<String> trimmedEmailIds = new Set<String>();
            for(String email : emailIds){
                if(email.trim() != ''){
                    trimmedEmailIds.add(email.trim());
                }
            }
            if(validateEmailIds(trimmedEmailIds, 'industryTechnicalSpecialistEmail', errorMsgs) || trimmedEmailIds.size() > 1){
                Set<String> validITSEmailIdSet = getITSMap(trimmedEmailIds);
            }else{
                isValidITS = false; 
            }
        }
        return isValidITS;
    }
    
    
    /**
    * @description retriving FSE Map from quote and Account Team
    * @author Accenture | 05-24-2022 
    * @param oemEmailIds 
    * @param accountIdToSalesRepEmailMap 
    * @param salesRepAssignment 
    * @return Map<Id, Set<String>> 
    **/
    public static Map<Id,Set<String>> getSalesrepMap(Set<String> oemEmailIds, Map<Id,Set<String>> accountIdToSalesRepEmailMap , Map<String, PermissionSetAssignment> salesRepAssignment){
        //get map of active User permission set(SalesRep permission set) assignment based on the given email id's and account id's
        Set<Id> userIdSet = new Set<Id>();
        Map<Id,Set<String>> accountToValidEmailMap = new Map<Id,Set<String>>();
        List<PermissionSetAssignment> salesRepAssignmentDtl = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                 FROM PermissionSetAssignment 
                                                                                                 WHERE Assignee.Email IN :oemEmailIds AND Assignee.IsActive = true
                                                                                                 AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser]);
        for(PermissionSetAssignment sea:salesRepAssignmentDtl){
            userIdSet.add(sea.AssigneeId);
            salesRepAssignment.put(sea.Assignee.Email,sea);
        }
        List<String> qtmEmails = new List<String>();
        if(isUpdateDraftQuote){
            List<Pricing_Quote_Team__c> qtm = createNewQTMMap.get('FSE');
            if(qtm!=null && qtm.size() > 0){
                for(Pricing_Quote_Team__c q: qtm){
                    qtmEmails.add(q.Pricing_Quote_Team_Member_Id__r.Email);
                }
            }
        }
        if(!userIdSet.isEmpty() && !accountIdToSalesRepEmailMap.isEmpty()){
            for(AccountTeamMember accTeam : [SELECT Id,User.Email,AccountId from AccountTeamMember where AccountId IN : 
                                             accountIdToSalesRepEmailMap.keySet() AND UserId IN: userIdSet]){
                                                 if(!accountToValidEmailMap.containsKey(accTeam.AccountId)){                                      
                                                     accountToValidEmailMap.put(accTeam.AccountId, new Set<String>{accTeam.User.Email}); 
                                                 }else{
                                                     accountToValidEmailMap.get(accTeam.AccountId).add(accTeam.User.Email);
                                                 }
                                             }
        }
        return accountToValidEmailMap;
    }
    
    /**
    * @description forming MAP of AE from quote team
    * @author Accenture | 05-24-2022 
    * @param accountExecutiveEmailId 
    * @return Set<String> 
    **/
    public static Set<String> getAccountExecutiveMap(Set<String> accountExecutiveEmailId){
        // Get active user email ids based on given list of email ids 
        Set<String> validEmailIdSet = new Set<String>();
        List<User> UserList =  new List<User>([SELECT Id, Email FROM User 
                                               where Email IN: accountExecutiveEmailId and IsActive = true]);
        
        if(Pricing_RestAPI_QuotesV2.isCreateQuoteTeam){
            List<PermissionSetAssignment> accountExecutiveAssignment = new List<PermissionSetAssignment>([SELECT Assignee.Email,PermissionSet.Name,AssigneeId
                                                                                                          FROM PermissionSetAssignment 
                                                                                                          WHERE Assignee.Email IN :accountExecutiveEmailId AND Assignee.IsActive = true
                                                                                                          AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderAccountExecutive]);
            
            for(PermissionSetAssignment aeAssignment:accountExecutiveAssignment){
                validAeEmailIdMap.put(aeAssignment.Assignee.Email,aeAssignment.AssigneeId);
            }
        }                                       
        
        List<String> qtmEmails = new List<String>();
        if(isUpdateDraftQuote){
            List<Pricing_Quote_Team__c> qtm = createNewQTMMap.get('AE');
            if(qtm!=null && qtm.size() > 0){
                for(Pricing_Quote_Team__c q: qtm){
                    qtmEmails.add(q.Pricing_Quote_Team_Member_Id__r.Email);
                }
            }
        }
        AEEmailUserList =  new List<User>();
        for(User userRec: UserList ){
            if(isUpdateDraftQuote){
                if(!qtmEmails.contains(userRec.Email)){
                    AEEmailUserList.add(userRec);
                    validEmailIdSet.add(userRec.Email); 
                }
            }else{
                AEEmailUserList.add(userRec);
                validEmailIdSet.add(userRec.Email); 
            }
        }
        return validEmailIdSet;
    }
    
    /**
    * @description forming Map of ITS from quoteTeam
    * @author Accenture | 05-24-2022 
    * @param itsEmailId 
    * @return Set<String> 
    **/
    public static Set<String> getITSMap(Set<String> itsEmailId){
        // Get active user email ids based on given list of email ids 
        Set<String> validEmailIdSet = new Set<String>();
        List<User> UserList =  new List<User>([SELECT Id, Email FROM User where Email IN: itsEmailId and IsActive = true]);
        List<String> qtmEmails = new List<String>();
        if(isUpdateDraftQuote){
            List<Pricing_Quote_Team__c> qtm = createNewQTMMap.get('ITS');
            if(qtm!=null && qtm.size() > 0){
                for(Pricing_Quote_Team__c q: qtm){
                    qtmEmails.add(q.Pricing_Quote_Team_Member_Id__r.Email);
                }
            }
        }
        ITSEmailUserList = new List<User>();
        for(User userRec: UserList ){
            if(isUpdateDraftQuote){
                if(!qtmEmails.contains(userRec.Email)){
                    ITSEmailUserList.add(userRec);
                    validEmailIdSet.add(userRec.Email); 
                }
            }else{
                ITSEmailUserList.add(userRec);
                validEmailIdSet.add(userRec.Email); 
            }
        }
        return validEmailIdSet;
    }
    
    /**
    * @description validating primary contact on request
    * @author Accenture | 05-24-2022 
    * @param quoteId 
    * @param primaryContactEmail 
    * @param errorMsgs 
    * @return boolean 
    **/
    public boolean validatePrimaryContact(String quoteId, String primaryContactEmail, Map<String,ErrorMsg> errorMsgs){
        boolean isValid = true;
        String regex = Label.Pricing_IQR_PrimaryContactEmail_Regex;
        //checking weather its valid intel email or not
        if(!Pattern.matches(regex, primaryContactEmail.toLowerCase())){
            isValid = false;
            addValidationError(errorMsgs, 'primaryContactEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1051, null);
        }
        List<Contact> contact = [Select Id from Contact where Email= :primaryContactEmail and Account.Id = :currentUser.AccountId];
        if(contact.size()>0){
            //checking weather user is having permission set or not
            if(!hasPartnerPermissionSet(primaryContactEmail) || contact == null){
                isValid = false;
                addValidationError(errorMsgs, 'primaryContactEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1051, null);
            }
        }else{
            isValid = false;
            addValidationError(errorMsgs, 'primaryContactEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1051, null);
        }
        return isValid;
    }
    
    /**
    * @description checking if primary contact provided is valid user
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @param primaryContactEmail 
    * @return boolean 
    **/
    public static boolean hasPartnerPermissionSet(String primaryContactEmail){
        List<User> primaryContactUser = [Select Id from User where Email = :primaryContactEmail AND isActive = true];
        boolean hasAPIPermissionSet = false;
        if(primaryContactUser.size()>0){
            List<PermissionSetAssignment> listUserPerSet =new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name, AssigneeId
                                                                                             FROM PermissionSetAssignment
                                                                                             WHERE AssigneeId = :primaryContactUser[0].Id and Assignee.IsActive = true ]);
            
            List<String> apiUserPermissionSets = label.Pricing_IQR_API_PrimaryContactPermissionSets.split(',');
            for (PermissionSetAssignment psa : listUserPerSet){
                if(apiUserPermissionSets.contains(psa.PermissionSet.Name)){
                    hasAPIPermissionSet = true;
                }
            }
        }
        return hasAPIPermissionSet;
    }
    
    public static String quarterStartEndDate(){
        String dateValue;
        Integer quarter = System.today().month()<=3?1:System.today().month()<=6?2:System.today().month()<=9?3:4;
        switch on quarter{
            when 1{
                dateValue = '01/01/'+String.valueOf(System.today().year())+':'+'03/31/'+String.valueOf(System.today().year());
            }
            when 2{
                dateValue = '04/01/'+String.valueOf(System.today().year())+':'+'06/30/'+String.valueOf(System.today().year());
            }
            when 3{
                dateValue = '07/01/'+String.valueOf(System.today().year())+':'+'09/30/'+String.valueOf(System.today().year());
            }
            when 4{
                dateValue = '10/01/'+String.valueOf(System.today().year())+':'+'12/31/'+String.valueOf(System.today().year());
            }
        }
        return dateValue;
    }
    
    public  boolean validateSVDQuota(QuoteErrorMsg quoteMsgs){
        quoteMsgs.quoteErrors = new Map<String,ErrorMsg>();
        if(Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllow(currentUser.AccountId).isEmpty()){
            addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1075, null);
            isValid=false;  
        }
        return isValid;
    }
    
    //validating endDate filter format for getallquote API
    public  boolean validateGetAllQuoteDate(String input,String field,Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> quoteMsgs){
        List<String> acceptedOperator = Label.Pricing_RestAPI_AcceptedOperators.split(',');
        String regex = '^(19|20)\\d\\d[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$';//checking format is YYYY-MM-DD
        String regexEmail = Label.Pricing_IQR_PrimaryContactEmail_Regex;//checking format is correct email
        if((field == 'endDate' || field == 'approvedorrejecteddate' || field == 'createddate')  && !Pattern.matches(regex, input)){
            addValidationError(quoteMsgs, field, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1077, null);
            isValid=false;  
        }
        if(field == 'notcreatedbyemail' && !Pattern.matches(regexEmail, input)){
            addValidationError(quoteMsgs, field, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1086, null);
            isValid=false;
        }
        if(field == 'operator' && !acceptedOperator.contains(input)){
            addValidationError(quoteMsgs, 'operator', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1082, null);
            isValid=false;  
        }
        return isValid;
    }
    
    /**
    * @description validate delete access and rec id
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @param recId, quoteMsgs 
    * @return boolean 
    **/
    public boolean validateQuoteDelete(Id recId, QuoteErrorMsg quoteMsgs){
        quoteMsgs.quoteErrors = new Map<String, ErrorMsg>();
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>([SELECT id,CreatedbyId,SBQQ__PrimaryContact__c,OwnerId,SBQQ__Status__c from SBQQ__Quote__c where Id =:recId and SBQQ__Account__c = :currentUser.AccountId]);
        if(quoteLst.isEmpty()){
            addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
            isValid=false;
        }else{
            if(quoteLst[0].SBQQ__Status__c != Label.Pricing_Tender_Quote_Status_Draft){
                addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1043, null);
                isValid=false;
            }
            if(quoteLst[0].CreatedbyId != Userinfo.getUserId() && quoteLst[0].OwnerId != Userinfo.getUserId()){
                addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1083, new Map<String,String>{'{{type}}' => 'Quote'});
                isValid=false;
            }
        }
        return isValid;
    }
    
    public boolean validateFileUploadDetails(Pricing_RestAPI_FileUpload.UploadFile uploadFile, QuoteErrorMsg quoteMsgs){
        quoteMsgs.quoteErrors = new Map<String, ErrorMsg>();
        if(String.isBlank(uploadFile.quoteId)){
            addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
            isValid=false;
        }
        else {
            List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>([SELECT id,CreatedbyId,SBQQ__PrimaryContact__c,OwnerId,SBQQ__Status__c from SBQQ__Quote__c where Id =:uploadFile.quoteId and SBQQ__Account__c = :currentUser.AccountId]);
            if(quoteLst.isEmpty()){
                addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                isValid=false;
            }
            if(String.isBlank(uploadFile.fileName)){
                addValidationError(quoteMsgs.quoteErrors, 'fileName', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid=false;
            }
            else{ 
                if(uploadFile.fileName.trim().length()>255){
                    addValidationError(quoteMsgs.quoteErrors, 'fileName', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, new Map<String,String>{'{{dataMaxLimit}}'=> '255'});
                    isValid=false;
                }
                if(!Label.Pricing_UploadFile_AllowedTypes.split(',').contains(uploadFile.fileName.trim().subString(uploadFile.fileName.trim().lastIndexOf('.') + 1).toLowerCase())){
                    addValidationError(quoteMsgs.quoteErrors, 'fileName', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1084, new Map<String,String>{'{{type}}'=> Label.Pricing_UploadFile_AllowedTypes});
                    isValid=false;
                }
            }
            if(String.isBlank(uploadFile.file)){
                addValidationError(quoteMsgs.quoteErrors, 'file', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid=false;
            }
            if(!String.isBlank(uploadFile.comment) && uploadFile.comment.length()>8000){
                addValidationError(quoteMsgs.quoteErrors, 'comment', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, new Map<String,String>{'{{dataMaxLimit}}'=> '8000'});
                isValid=false;
            }
        }
        return isValid;
    }
    
    /*************************** validate Quote Lines Starts Here **********************************/
    public boolean validateQuoteLineWrapper(QuoteLineWrapper quoteLineWrapper, QuoteErrorMsg qErrorMsg, boolean isSubmit){
        //this method is called from submit quoteline API to validate input quoteline JSON with performance metrics
        try{
            Set<Id> quoteIds = new Set<Id>();
            List<String> productIdList = new List<String>();
            List<String> compProductIdList = new List<String>();
            qErrorMsg.quoteErrors = new Map<String, ErrorMsg>();
            if(!String.isBlank(quoteLineWrapper.quoteId)){
                qErrorMsg.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>();
                List<SBQQ__Quote__c> quoteList = [Select Id, Pricing_ShipmentStDate_Dt__c, SBQQ__Status__c, SBQQ__Account__c,Pricing_Overall_Quote_Quantity__c,Pricing_Overall_Quote_Quantity_CPU__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c where Id =:quoteLineWrapper.quoteId and SBQQ__Account__c = :currentUser.AccountId];
                if(quoteList.size()>0){
                    isSvd =  quoteList[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote;
                    isClient = quoteList[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote;
                    if(quoteList[0].Pricing_Program_Type_Nm__c==Label.Pricing_Tender_Small_Volume_Quote){
                        Pricing_RestAPI_QuotelinesV2.isSvdQuoteLine = true;
                    }
                }
                if(quoteList[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote || TriggerHandler.isActive('Pricing_SVD_QuoteLine_Disabled')){
                    QuoteLines quoteLineList = quoteLineWrapper.quoteLines;
                    quoteIds.add(quoteLineWrapper.quoteId);
                    if(quoteList.size()>0){
                        quoteId = quoteLineWrapper.quoteId;
                        overallQuantity = quoteList[0].Pricing_Overall_Quote_Quantity__c;
                        isQuotelineDraftQuote = quoteList[0].SBQQ__Status__c == Label.Pricing_RestAPI_Status_Draft;
                        if(isSubmit && isQuotelineDraftQuote){
                            //checking for parent quote status if it is already submitted or not
                            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1032, null);
                            isValid = false;
                        }
                        if(quoteLineList!=null && !((quoteLineList.DataCenterCPU == null || quoteLineList.DataCenterCPU.isEmpty()) && (quoteLineList.OptaneSSD == null || quoteLineList.OptaneSSD.isEmpty()) && (quoteLineList.OptanePMem == null || quoteLineList.OptanePMem.isEmpty()) && (quoteLineList.Ethernet == null || quoteLineList.Ethernet.isEmpty()) && (quoteLineList.Client == null || quoteLineList.Client.isEmpty()) && ((quoteLineList.DataCenterGPU == null || quoteLineList.DataCenterGPU.isEmpty())))){
                            validateQuoteLines(quoteLineList,quoteList[0].Pricing_ShipmentStDate_Dt__c,qErrorMsg,isSubmit,marketSegmentValue);		//validate quotelines and its performance metrics if isSubmit=true
                        }else{
                            addValidationError(qErrorMsg.quoteErrors, 'quoteLine', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
                            isValid = false;
                        }
                        if(Pricing_Publish_Quote.validateQtmFse(quoteIds).size()==0){
                            addValidationError(qErrorMsg.quoteErrors, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
                            isValid=false;
                        }
                    }else{
                        addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                        isValid = false;
                    }
                }else{
                    return false;
                }
            }else{
                addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
                isValid = false;
            }
            if(qErrorMsg.quoteErrors.isEmpty()){
                qErrorMsg.quoteErrors = null;
            }
            if(qErrorMsg.quoteErrors == null && qErrorMsg.quoteLineErrorMsgs == null){
                return true;
            }else{
                return false;
            }
        }
        catch(Exception ex){
            qErrorMsg.quoteLineErrorMsgs = null;
            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
            isValid = false; 
            return false;
        }
    }
    
    public boolean validateQuoteLineCRWonLostWrapper(QLICRWonLostWrapper quoteLineWrapper, QuoteErrorMsg qErrorMsg, boolean isSubmit){
        try
        {
            if(Pricing_RestAPI_QuotelinesV2.isStatusChange){
                return validateWonLostQuotelineWrapper(quoteLineWrapper, qErrorMsg, sObjQuoteLineFieldMap);
            }
            else if(Pricing_RestAPI_QuotelinesV2.isChangeReq ){
                qErrorMsg.quoteErrors = new Map<String, ErrorMsg>(); 
                List<Id> qliAPIIds = new List<Id>();
                if(quoteLineWrapper.quoteId == null || String.isEmpty(quoteLineWrapper.quoteId.trim())){
                    addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
                    isValid = false;
                }
                else{
                    if(quoteLineWrapper.quoteId.trim() instanceOf Id ){
                        quoteId = quoteLineWrapper.quoteId.trim();
                        Map<Id,Set<Id>> quoteIdQTMMemberIdMap = Pricing_Publish_Quote.validateQtmFse(new Set<Id>{quoteId});
                        if(quoteIdQTMMemberIdMap.size() == 0){
                            addValidationError(qErrorMsg.quoteErrors, 'quoteTeamMember', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004,null);
                            isValid = false;
                        }
                        qErrorMsg.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>();       
                        for(QLICRWonLost quoteline: quoteLineWrapper.quoteLines){
                            if(quoteline.quotelineId == null || String.isEmpty(quoteline.quotelineId.trim()))
                            {
                                QuoteLineErrorMsg qle = new QuoteLineErrorMsg();
                                qle.quoteLineErrors = new Map<String,ErrorMsg>();
                                qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
                                addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null); 
                                qErrorMsg.quoteLineErrorMsgs.add(qle);
                            }
                            else if(quoteLine.quotelineId.trim() instanceOf Id ){
                                qliAPIIds.add(quoteline.quotelineId.trim());
                            }
                            else{
                                QuoteLineErrorMsg qle = new QuoteLineErrorMsg();
                                qle.quoteLineErrors = new Map<String,ErrorMsg>();
                                qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
                                addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null); 
                                qErrorMsg.quoteLineErrorMsgs.add(qle);
                            }  
                        }
                        List<SBQQ__QuoteLine__c> hasCR = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c
                                                          where Pricing_Reference_Quote_Line_Nbr__c IN : qliAPIIds and Pricing_Status_Nm__c != 'Rejected' and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId];
                        Map<Id,String> hasCRMap = new Map<Id,String>();
                        for(SBQQ__QuoteLine__c qli: hasCR){
                            hasCRMap.put(qli.Pricing_Reference_Quote_Line_Nbr__c,qli.Pricing_Quote_Line_Number__c);
                        }   
                        Map<Id,SBQQ__QuoteLine__c> quotelineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id,Pricing_Status_Nm__c,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_ECAP_Price_Amt__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Platform__c ,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where Id IN :qliAPIIds and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId]);
                                for(QLICRWonLost quoteline: quoteLineWrapper.quoteLines){
                                    validateChangeReqQuoteline(quoteline,qErrorMsg.quoteLineErrorMsgs, sObjQuoteLineFieldMap,quotelineMap,hasCRMap);
                                }
                        }
                        else{
                            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                            isValid = false; 
                        }       
                    }
                }
                    if(qErrorMsg.quoteErrors.isEmpty() && qErrorMsg.quoteLineErrorMsgs.isEmpty() ){
                        return true;
                    }else{
                        if(qErrorMsg.quoteErrors.isEmpty()){
                            qErrorMsg.quoteErrors=null;
                        }
                        return false;
                    }
        }
        catch(Exception ex){
            qErrorMsg.quoteLineErrorMsgs = null;
            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
            isValid = false; 
            return false;
        }
    }
    
    public boolean validateQuoteLines(QuoteLines quoteLines, Date pricingStartDate, QuoteErrorMsg qErrorMsg, boolean isSubmit, String marketSegmentValue){
        //this method is called from submit quote API to validate quoteline and its performance metrics
        List<String> productNameList = new List<String>();
        List<String> compProductNameList = new List<String>();
        List<String> compProductClientNameList = new List<String>();
        List<String> quotelinesIds = new List<String>();
        Set<String> quotelineIdsSet = new Set<String>();
        if(quoteLines!=null && !((quoteLines.DataCenterCPU == null || quoteLines.DataCenterCPU.isEmpty()) && (quoteLines.OptaneSSD == null || quoteLines.OptaneSSD.isEmpty()) && (quoteLines.OptanePMem == null || quoteLines.OptanePMem.isEmpty()) && (quoteLines.Ethernet == null || quoteLines.Ethernet.isEmpty()) && (quoteLines.Client == null || quoteLines.Client.isEmpty()) && (quoteLines.DataCenterGPU == null || quoteLines.DataCenterGPU.isEmpty()))){
            quoteLines.DataCenterCPU = quoteLines.DataCenterCPU != null && !isClient ? quoteLines.DataCenterCPU : new List<QuotelineCPU>();
            quoteLines.OptaneSSD = quoteLines.OptaneSSD != null && !isSvd && !isClient ? quoteLines.OptaneSSD : new List<QuotelineSSD>();
            quoteLines.OptanePMem = quoteLines.OptanePMem != null && !isSvd && !isClient ? quoteLines.OptanePMem : new List<QuotelinePMem>();
            quoteLines.Ethernet = quoteLines.Ethernet != null && !isSvd && !isClient ? quoteLines.Ethernet : new List<QuotelineEthernet>();
            quoteLines.Client = quoteLines.Client != null && isClient ? quoteLines.Client : new List<QuotelineClient>();
            quoteLines.DataCenterGPU = quoteLines.DataCenterGPU != null && !isClient ? quoteLines.DataCenterGPU : new List<QuotelineGPU>();
            
            
            for(QuoteLineCPU q : quoteLines.DataCenterCPU){
                if(q.noOfCPUsPerSystem>0 && q.noOfSystems>0 && !Pricing_RestAPI_QuotelinesV2.isResubmit)
                    overallQuantity = overallQuantity+(q.noOfCPUsPerSystem * q.noOfSystems);
                compProductNameList.add(q.competitorProductId);                  
            }
            
            //Validating for GPU QL
            for(QuoteLineGPU q : quoteLines.DataCenterGPU){
                if(q.noOfGPUsPerSystem>0 && q.noOfSystems>0 && !Pricing_RestAPI_QuotelinesV2.isResubmit)
                    overallQuantity = overallQuantity+(q.noOfGPUsPerSystem * q.noOfSystems);
                compProductNameList.add(q.competitorProductId);                  
            }
            for(QuoteLineClient q : quoteLines.Client){
               if(q.quantity>0 &&  !Pricing_RestAPI_QuotelinesV2.isResubmit){
                    overallQuantity = overallQuantity+q.quantity ;
                }
                compProductNameList.add(q.competitorProductId);                  
            }
            if(compProductNameList.size()>0){
                getCompetitorProducts(compProductNameList,isClient ? Label.Pricing_Tender_CCG_Quote : Label.Pricing_Tender_Standard_Quote);
            }
            
            setActiveConsumptionMap(currentUser);
            
            patchQuotelineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id, Name,Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,Pricing_Unit_Qty__c,RecordTypeId,Pricing_Program_Type_Nm__c, (SELECT id FROM Performance_Metrics__r) from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId]);
            if(patchQuotelineMap.size()>0){
                for(Id qliId: patchQuotelineMap.keySet()){
                    assignedRecordTypeId = patchQuotelineMap.get(qliId).RecordTypeId;
                    SBQQ__QuoteLine__c q = patchQuotelineMap.get(qliId);
                    Set<String> pmIds = new Set<String>();
                    for(Pricing_Performance_Metric__c pm: q.Performance_Metrics__r){
                        pmIds.add(pm.id);
                    }
                    quotelineIdPerfMap.put(q.Id, pmIds);
                }
                
                //Update            
                if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit){
                    for(QuoteLineCPU q : quoteLines.DataCenterCPU){
                        SBQQ__QuoteLine__c quotelinePatch = !String.isBlank(q.quotelineId) ? patchQuotelineMap.get(q.quotelineId) : null;
                        if(quotelinePatch != null){
                            if(q.noOfSystems != null && q.noOfCPUsPerSystem != null && quotelinePatch.Pricing_Unit_Qty__c!=(q.noOfCPUsPerSystem * q.noOfSystems) && Pricing_RestAPI_QuotelinesV2.isResubmit){
                                overallQuantity = overallQuantity+(q.noOfCPUsPerSystem * q.noOfSystems)-quotelinePatch.Pricing_Unit_Qty__c;
                            }
                        }
                    }
                } 
                //Updating GPU QL
                if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit){
                    for(QuoteLineGPU q : quoteLines.DataCenterGPU){
                        SBQQ__QuoteLine__c quotelinePatch = !String.isBlank(q.quotelineId) ? patchQuotelineMap.get(q.quotelineId) : null;
                        if(quotelinePatch != null){
                            if(q.noOfSystems != null && q.noOfGPUsPerSystem != null && quotelinePatch.Pricing_Unit_Qty__c!=(q.noOfGPUsPerSystem * q.noOfSystems) && Pricing_RestAPI_QuotelinesV2.isResubmit){
                                overallQuantity = overallQuantity+(q.noOfGPUsPerSystem * q.noOfSystems)-quotelinePatch.Pricing_Unit_Qty__c;
                            }
                        }
                    }
                }
            }
            if(!quoteLines.DataCenterCPU.isEmpty()){
                validateQuoteLineCPU(quoteLines.DataCenterCPU, pricingStartDate, qErrorMsg, isSubmit);
            }
            //Validating GPU QL
            if(!quoteLines.DataCenterGPU.isEmpty()){
                validateQuoteLineGPU(quoteLines.DataCenterGPU, pricingStartDate, qErrorMsg, isSubmit);
            }
            if(!quoteLines.OptaneSSD.isEmpty()){
                validateQuoteLineSSD(quoteLines.OptaneSSD, pricingStartDate, qErrorMsg, isSubmit);
            }
            if(!quoteLines.OptanePMem.isEmpty()){
                validateQuoteLinePMem(quoteLines.OptanePMem, pricingStartDate, qErrorMsg, isSubmit);
            }
            if(!quoteLines.Ethernet.isEmpty()){
                validateQuoteLineEthernet(quoteLines.Ethernet, pricingStartDate, qErrorMsg, isSubmit);
            }
            if(!quoteLines.Client.isEmpty()){
                validateQuoteLineClient(quoteLines.Client, pricingStartDate, qErrorMsg, isSubmit, marketSegmentValue);
            }
        }else if(!isCreateDraftQuote){
            addValidationError(qErrorMsg.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1028, null);
            isValid = false;
        }
        else{
            if(quoteLines != null){
                quoteLines.DataCenterCPU = new List<QuotelineCPU>();
                quoteLines.OptaneSSD = new List<QuotelineSSD>();
                quoteLines.OptanePMem = new List<QuotelinePMem>();
                quoteLines.Ethernet = new List<QuotelineEthernet>();
                quoteLines.Client = new List<QuotelineClient>();
                quoteLines.DataCenterGPU = new List<QuotelineGPU>();
            }
        }
        if(qErrorMsg.quoteLineErrorMsgs.isEmpty()){
            qErrorMsg.quoteLineErrorMsgs = null;
        }
        return isValid;
    }
    
    public boolean validateQuoteLineCPU(List<QuoteLineCPU> quoteLinesCPU, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit){ 
        getProducts(Label.Pricing_Tender_Processor_Product);
        //validate quoteline [and its performance metrics if isSubmit=true]
        for(QuoteLineCPU quoteLineDetails:quoteLinesCPU){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,isSvd ? Label.Pricing_Tender_Small_Volume_Quote : Label.Pricing_Tender_Standard_QuoteLine);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            
            //validate all number fields of quoteline
            if(!validateQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            
            //validate all fields of quoteline
            if(isSvd){
                if(!validateSVDQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                    isValid = false;
                } 
                validateSVDQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            }
            else{
                if(!validateQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                    isValid = false;
                }
                validateQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            }
            
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_Standard_QuoteLine);
            validateCompProduct(quoteLineDetails.competitorProductId, quoteLineDetails.competitorWriteInProduct, qlErrorMsg.quoteLineErrors);        
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(isSubmit){
                if(!isCreateDraftQuote && (overallQuantity<Decimal.valueOf(Label.Pricing_Overall_Quantity_Min)  || overallQuantity>Decimal.valueOf(Label.Pricing_Overall_Quantity_Max) ) && isSvd){
                    addValidationError(qlErrorMsg.quoteLineErrors, 'overallQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1069, new Map<String,String>{'{value}'=>String.valueOf(overallQuantity)});
                    isValid = false;
                }
                if(!isCreateDraftQuote && !isSvd){//do not validate while creating draft quote/quotelines
                    validateDiscountField(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
                }
                validatePerformanceMetricsList(quoteLineDetails.performanceMetrics, qlErrorMsg);
            }else if(!isQuotelineDraftQuote || quoteLineDetails.performanceMetrics != null){
                validatePerformanceMetricsList(quoteLineDetails.performanceMetrics, qlErrorMsg);
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
            isPerfMetricsAvailable = false;
        }
        if(isSubmitQuote || (Pricing_RestAPI_QuotesV2.isResubmit && quotelineList.size() > 0 && quotelineList[0].Pricing_Original_Submitted_Date_dt__c == null && quotelineList[0].SBQQ__Quote__r.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft)){
            List<String> productSeriesList = Label.Pricing_Product_Series_Exclude.split(',');
            for(QuoteLineCPU q : quoteLinesCPU){

                if(productIdMap.containsKey(q.productId)){
                    String productSeries = productIdMap.get(q.productId).Name == Label.Pricing_Tender_Write_In_Product ? Label.Pricing_Tender_Write_In_Product : productIdMap.get(q.productId).Core_Product_Series__c;
                    if(q.noOfCPUsPerSystem>0 && q.noOfSystems>0 && (!productSeriesList.contains(productIdMap.get(q.productId).Core_Product_Series__c) && productSeries != null && productSeries != '' && !productSeries.startswith('Intel Atom® Processor'))){
                        overallQuantityCPU = overallQuantityCPU+(q.noOfCPUsPerSystem * q.noOfSystems);                    
                    }
                }
            }
            validateExceptionQuotaCheck(qErrorMsg.quoteErrors);
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    } 
    
    /**
    * @description validate Data Center GPU quoteline
    * @author Suraj Govindrao Barade | 07-17-2024  
    * @return boolean 
    **/
    public boolean validateQuoteLineGPU(List<QuoteLineGPU> quoteLineGPU, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit){   //from where did i get quote pricing start date
        getProducts(Label.Pricing_Tender_Graphics_Product);
        String query = Label.Pricing_RestAPI_PairedCPU_Products_Query;
        List<Product2> productList = Database.query(query);
        //validate Data Center GPU quoteline ]
        for(QuoteLineGPU quoteLineDetails:quoteLineGPU){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_DataCenter_GPU);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            if(!validateGPUQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            if(!validateGPUQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            validateGPUQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_DataCenter_GPU);
            validateCompProduct(quoteLineDetails.competitorProductId, quoteLineDetails.competitorWriteInProduct, qlErrorMsg.quoteLineErrors);
            
            validatePairedCPUProduct(quoteLineDetails.pairedCPUId, quoteLineDetails.writeInPairedCPU, qlErrorMsg.quoteLineErrors,productList);
            //For checking multi picklist values
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            //Paired CPU field is Mandatory
            if(String.isBlank(quoteLineDetails.pairedCPUId)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'pairedCPUId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(isSubmit){
                if(!isCreateDraftQuote && (overallQuantity<Decimal.valueOf(Label.Pricing_Overall_Quantity_Min)  || overallQuantity>Decimal.valueOf(Label.Pricing_Overall_Quantity_Max) ) && isSvd){
                    addValidationError(qlErrorMsg.quoteLineErrors, 'overallQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1069, new Map<String,String>{'{value}'=>String.valueOf(overallQuantity)});
                    isValid = false;
                }
                if(!isCreateDraftQuote){//do not validate while creating draft quote/quotelines
                    validateDiscountFieldGPU(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
                }
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    }
    
    public static void validateExceptionQuotaCheck(Map<String,ErrorMsg> errorMsgs){
        if((isDataCenterCPU && overallQuantityCPU != 0 && overallQuantityCPU < Integer.valueOf(Label.Pricing_DataCenterCPU_Overall_Quantity_Min)) || (isClient && overallQuantity < Integer.valueOf(Label.Pricing_Client_Overall_Quantity_Min))){
            //Pricing_RestAPI_QuotesV2.isOverAllQtyLess = true;
            Map<String,String> quoteCreationAllowed = new Map<String,String>(Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{currentUser.AccountId},false)); 
            if(!quoteCreationAllowed.isEmpty()){
                isOverAllQtyLess = isClient && quoteCreationAllowed.containsKey(Label.Pricing_Tender_CCG_Quote) ? true : isDataCenterCPU && quoteCreationAllowed.containsKey(Label.Pricing_Tender_Standard_Quote) ? true : false;
                if(isClient  && quoteCreationAllowed.containsKey(Label.Pricing_Tender_CCG_Quote) && quoteCreationAllowed.get(Label.Pricing_Tender_CCG_Quote).split(':')[0] == 'false'){
                    Map<String, String> textReplaceWithValue = new Map<String, String>{
                        '{{QuoteQuantity}}' => String.valueOf(overallQuantity),
                        '{{ExceptionQuantity}}'  => String.valueOf(Label.Pricing_Client_Overall_Quantity_Min)
                    };
                    addValidationError(errorMsgs, 'CapSize', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1101, textReplaceWithValue);
                    isValid=false;
                }else if(isDataCenterCPU && quoteCreationAllowed.containsKey(Label.Pricing_Tender_Standard_Quote) && quoteCreationAllowed.get(Label.Pricing_Tender_Standard_Quote).split(':')[0] == 'false'){
                    Map<String, String> textReplaceWithValue = new Map<String, String>{
                        '{{QuoteQuantity}}' => String.valueOf(overallQuantityCPU),
                        '{{ExceptionQuantity}}'  => String.valueOf(Label.Pricing_DataCenterCPU_Overall_Quantity_Min)
                    };
                    addValidationError(errorMsgs, 'CapSize', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1101, textReplaceWithValue);
                    isValid=false;
                }
            }
        }
    }

    public boolean validateQuoteLineSSD(List<QuoteLineSSD> quoteLineSSD, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit){   //from where did i get quote pricing start date
        getProducts(Label.Pricing_RestAPI_Products_SSD_Param);
        //validate SSD quoteline 
        for(QuoteLineSSD quoteLineDetails:quoteLineSSD){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_SSD_Quote);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            if(!validateSSDQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            if(!validateSSDQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            validateSSDQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);       
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_SSD_Quote);
            //For checking multi picklist values
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    } 
    
    public boolean validateQuoteLinePMem(List<QuoteLinePMem> quoteLinePMem, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit){   //from where did i get quote pricing start date
        getProducts(Label.Pricing_RestAPI_Products_PMem_Param);
        //validate PMem quoteline 
        for(QuoteLinePMem quoteLineDetails:quoteLinePMem){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_PMem_Quote);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            
            if(quoteLineDetails.serverIntegration != null && !String.isBlank(quoteLineDetails.serverIntegration) && (quoteLineDetails.serverIntegration != 'Virtualized' && quoteLineDetails.serverIntegration != 'Bare Metal')){
                addValidationError(qlErrorMsg.quoteLineErrors, 'serverIntegration', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1080, null);
                isValid = false;
            }
            if(!validatePMemQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            if(!validatePMemQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            validatePMemQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_PMem_Quote);
            //For checking multi picklist values
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    } 
    
    public boolean validateQuoteLineEthernet(List<QuoteLineEthernet> quoteLineEthernet, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit){   //from where did i get quote pricing start date
        getProducts(Label.Pricing_RestAPI_Products_NIC_Param);
        //validate Ethernet quoteline ]
        for(QuoteLineEthernet quoteLineDetails:quoteLineEthernet){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_NIC_Quote);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            if(!validateNICQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            if(!validateNICQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            validateNICQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_NIC_Quote);
            
            //For checking multi picklist values
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    } 
    
    public boolean validateQuoteLineClient(List<QuoteLineClient> quoteLineClient, Date quotePricingStartDate,QuoteErrorMsg qErrorMsg, boolean isSubmit, String marketSegmentValue){   //from where did i get quote pricing start date
        getProducts(Label.Pricing_Tender_CCG_Quote);
        //validate Ethernet quoteline ]
        for(QuoteLineClient quoteLineDetails : quoteLineClient){
            QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
            qlErrorMsg.quotelineReferenceID = quoteLineDetails.quotelineReferenceID;
            qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
            Map<String, boolean> fldValidMap = new Map<String, boolean>();
            updateQuotelineId = quoteLineDetails.quotelineId;
            if(Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine || Pricing_RestAPI_QuotelinesV2.isResubmit || (isUpdateDraftQuote && (!Pricing_RestAPI_QuotesV2.isResubmit || (Pricing_RestAPI_QuotesV2.isResubmit && !(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())))))){
                validateUpdateIds(updateQuotelineId,qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_CCG_Quote);
            }
            if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
                if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                    isValid = false;
                    addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                }
            }else if(!isUpdateDraftQuote){
                isValid = false;
            }
            if(!validateClientQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            if(!validateClientQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
            validateClientQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            
            validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors,Label.Pricing_Tender_CCG_Quote);
            validateCompProduct(quoteLineDetails.competitorProductId, quoteLineDetails.competitorWriteInProduct, qlErrorMsg.quoteLineErrors);
            
            //For checking multi picklist values
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_End_Customer_Country__c',quoteLineDetails.consumptionCountry, false, qlErrorMsg.quoteLineErrors, 'consumptionCountry') ? false : isValid;
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Consumption_Region__c',quoteLineDetails.consumptionRegion, false, qlErrorMsg.quoteLineErrors, 'consumptionRegion') ? false : isValid;        
            isValid = !validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Form_Factor_Nm__c',quoteLineDetails.formFactor, true, qlErrorMsg.quoteLineErrors, 'formFactor') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionPlatform, 'Consumption Platform', qlErrorMsg.quoteLineErrors, 'consumptionPlatform') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSalesGeo, 'Consumption Sales Geo', qlErrorMsg.quoteLineErrors, 'consumptionSalesGeo') ? false : isValid;
            isValid = !validateConsumptionParameter(quoteLineDetails.consumptionSegment, 'Consumption Segment', qlErrorMsg.quoteLineErrors, 'consumptionSegment') ? false : isValid;
            
            //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
            if(!String.isBlank(quoteLineDetails.consumptionSalesGeo) && ((!String.isBlank(quoteLineDetails.consumptionCountry) || !String.isBlank(quoteLineDetails.consumptionRegion)))){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
            }
            
            //referenceField is mendatory
            if(String.isBlank(quoteLineDetails.quotelineReferenceID)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                isValid = false;
            }
            
            if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
                qlErrorMsg.quoteLineErrors = null;
            }
            
            if(qlErrorMsg.quoteLineErrors != null){                    
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
                qErrorMsg.quoteLineErrorMsgs.add(qlErrorMsg);
            }
        }
        if((isSubmitQuote && marketSegmentValue != 'Consumer Retail Pull') || (Pricing_RestAPI_QuotesV2.isResubmit && quotelineList.size() > 0 && quotelineList[0].Pricing_Original_Submitted_Date_dt__c == null && quotelineList[0].SBQQ__Quote__r.SBQQ__Status__c == Label.Pricing_Tender_Quote_Status_Draft && marketSegmentValue != 'Consumer Retail Pull')){
            validateExceptionQuotaCheck(qErrorMsg.quoteErrors);
        }
        productIdMap = new Map<Id,Product2>();
        return isValid;
    }
    
    /**
    * @description validating updated API parameters
    * @author Accenture | 05-24-2022 
    * @param updateQuotelineId 
    * @param quoteLineErrors 
    * @param qliType 
    **/
    public void validateUpdateIds(String updateQuotelineId, Map<String,ErrorMsg> quoteLineErrors,String qliType){
        try{            
            if(updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())){
                addValidationError(quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null);
                isValid = false;
            }
            else if(patchQuotelineMap.get(updateQuotelineId) == null){
                addValidationError(quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1037, new Map<String, String>{'Performance metrics' => 'Quote line', 'quote line' => 'quote'});
                isValid = false;
            }
            else{
                SBQQ__QuoteLine__c quotelinePatch = patchQuotelineMap.get(updateQuotelineId);
                if(quotelinePatch != null){
                    //List<Pricing_Performance_Metric__c> perfMetricList = [Select id from Pricing_Performance_Metric__c where Pricing_Quote_Line__c = :quotelinePatch.id];
                    if(quotelinePatch.Performance_Metrics__r.size()>0){
                        isPerfMetricsAvailable = true;
                    }
                    if(quotelinePatch.Pricing_Status_Nm__c != 'Draft'){
                        addValidationError(quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1048, new Map<String, String>{'Approved' => 'Draft'});
                        isValid = false;
                    }
                    if(quotelinePatch.Pricing_Program_Type_Nm__c != qliType){
                        addValidationError(quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1081, new Map<String, String>{'{{qliType}}' => qliType});
                        isValid = false;
                    }
                }else{
                    addValidationError(quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
                    isValid = false;
                }
            }
        }catch(Exception ex){
            addValidationError(quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1037, new Map<String, String>{'Performance metrics' => 'Quote line', 'quote line' => 'quote'});
            isValid = false;
        }
    }
    
    /**
    * @description validate delete access and rec id
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @param  recId, quoteMsgs
    * @return boolean 
    **/
    public boolean validateQuoteLineDelete(Id recId, QuoteErrorMsg quoteMsgs){
        quoteMsgs.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>();
        QuoteLineErrorMsg qlErrorMsg = new QuoteLineErrorMsg();
        qlErrorMsg.quotelineReferenceID = null;
        qlErrorMsg.quoteLineErrors = new Map<String,ErrorMsg>();
        List<SBQQ__QuoteLine__c> quoteLineLst = new List<SBQQ__QuoteLine__c>([SELECT id,CreatedbyId,Pricing_Primary_Contact_Nm__c,SBQQ__Quote__r.OwnerId,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where Id =:recId and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId]);
        if(quoteLineLst.isEmpty()){
            addValidationError(qlErrorMsg.quoteLineErrors, 'quoteline', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
            isValid=false;
        }else{
            if(quoteLineLst[0].Pricing_Status_Nm__c != Label.Pricing_Tender_Quote_Status_Draft){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quoteline', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1045, null);
                isValid=false;
            }
            if(quoteLineLst[0].CreatedbyId != Userinfo.getUserId() && quoteLineLst[0].SBQQ__Quote__r.OwnerId != Userinfo.getUserId() && quoteLineLst[0].Pricing_Primary_Contact_Nm__c != Userinfo.getUserId()){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quoteline', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1083,  new Map<String,String>{'{{type}}' => 'Quote Line'});
                isValid=false;
            }
        }
        if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
            qlErrorMsg.quoteLineErrors = null;
        }
        
        if(qlErrorMsg.quoteLineErrors != null){                    
            quoteMsgs.quoteLineErrorMsgs.add(qlErrorMsg);
        }else if(qlErrorMsg.perfMetricsErrorMsgs != null){
            quoteMsgs.quoteLineErrorMsgs.add(qlErrorMsg);
        }
        return isValid;
    }
    /*public void validateClientPM(QuoteLineClient quoteLineDetails, Map<String,ErrorMsg> errorMsgs){
        if(quoteLineDetails.performanceMetricUsed == Label.Pricing_Write_In_Performance_Metrics && String.isEmpty(quoteLineDetails.writeInPerformanceMetric)){
        isValid = false; 
        addValidationError(errorMsgs, 'writeInPerformanceMetric', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1082, null);
        }
        else if(quoteLineDetails.performanceMetricUsed != Label.Pricing_Write_In_Performance_Metrics && !String.isEmpty(quoteLineDetails.writeInPerformanceMetric)){
        isValid = false; 
        addValidationError(errorMsgs, 'writeInPerformanceMetric', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1082, null);
        }
    }*/
    
    /**
    * @description field wrappers to validte the corresponding values
    * @author Accenture | 05-24-2022 
    * @param quoteLineDetails 
    * @param sObjQuoteLineFieldMap 
    * @param errorMsgs 
    * @return boolean 
    **/
    public boolean validateQuoteLineTextFields(QuoteLineCPU quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_OEM_System_Model_Nm__c',quoteLineDetails.systemModel, 'systemModel', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_System_Model_Nm__c',quoteLineDetails.competitorSystemModel, 'competitorSystemModel', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName, 'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validateGPUQuoteLineTextFields(QuoteLineGPU quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_OEM_System_Model_Nm__c',quoteLineDetails.systemModel, 'systemModel', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_System_Model_Nm__c',quoteLineDetails.competitorSystemModel, 'competitorSystemModel', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName, 'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validateSVDQuoteLineTextFields(QuoteLineCPU quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validateSSDQuoteLineTextFields(QuoteLineSSD quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName,'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Comp_Product_Txt__c',quoteLineDetails.competitorProduct, 'competitorProduct', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_VolumeByQuarterAndReasoning_Txt__c',quoteLineDetails.volumeByQuarterAndReasoning, 'volumeByQuarterAndReasoning', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validatePMemQuoteLineTextFields(QuoteLinePMem quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_OEM_System_Model_Nm__c',quoteLineDetails.systemModel, 'systemModel', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_CPU_Txt__c',quoteLineDetails.pairedCPU, 'pairedCPU', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName,'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Server_Integration_Nm__c',quoteLineDetails.serverIntegration, 'serverIntegration', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Workload_Txt__c',quoteLineDetails.workload, 'workload', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_POC_testing_results_Txt__c',quoteLineDetails.pocTestingResults, 'pocTestingResults', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validateNICQuoteLineTextFields(QuoteLineEthernet quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Comp_Product_Txt__c',quoteLineDetails.competitorProduct, 'competitorProduct', true));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public boolean validateClientQuoteLineTextFields(QuoteLineClient quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_OEM_System_Model_Nm__c',quoteLineDetails.systemModel, 'systemModel', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_System_Model_Nm__c',quoteLineDetails.competitorSystemModel, 'competitorSystemModel', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName, 'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        //textFldValues.add(new TextFieldValueWrapper('Pricing_Write_In_Performance_Metric_Nm__c',quoteLineDetails.writeInPerformanceMetric, 'writeInPerformanceMetric', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    
    public void validateProduct(String productId, String writeInProduct, Map<String,ErrorMsg> errorMsgs,String qliType){
        //check if the product is available in salesforce using product Id
        if(!String.isBlank(productId)){
            try{
                Id recId = Id.valueOf(productId);
                writeInProduct = !String.isEmpty(writeInProduct) ?writeInProduct.trim() : writeInProduct;
                if(productIdMap.containsKey(recId)){
                    String prodType =  Label.Pricing_Tender_SSD_BU_OpCode.split(',').contains(productIdMap.get(productId).Core_Profit_Center__c) ? Label.Pricing_Tender_SSD_Quote :
                    Label.Pricing_Tender_PMem_BU_OpCode.split(',').contains(productIdMap.get(productId).Core_Profit_Center__c)? Label.Pricing_Tender_PMem_Quote :
                    Label.Pricing_Tender_Ethernet_BU_OpCode.split(',').contains(productIdMap.get(productId).Core_Profit_Center__c)? Label.Pricing_Tender_NIC_Quote : 
                    qliType == Label.Pricing_Tender_CCG_Quote && (Label.Pricing_Tender_CCG_ProdType.split(',').contains(productIdMap.get(productId).Core_VerticalSegment__c) || productIdMap.get(productId).Core_Cross_Selling_Product_Type_Nm__c == Label.Pricing_Tender_CCG_Quote) ? Label.Pricing_Tender_CCG_Quote :  
                    productIdMap.get(productId).Core_Product_Type__c == Label.Pricing_Tender_Processor_Product ? Label.Pricing_Tender_Standard_QuoteLine : 
                    productIdMap.get(productId).Core_Product_Type__c == Label.Pricing_Tender_Graphics_Product ? Label.Pricing_Tender_DataCenter_GPU : 
                    (productIdMap.get(productId).Name == Label.Pricing_Write_In_Product) ? Label.Pricing_Write_In_Product : null;
                    //if the given product is a "Write in Product" then writeInProduct field is mandatory
                    if(productIdMap.get(recId).Name == label.Pricing_Write_In_Product && String.isBlank(writeInProduct)){
                        isValid = false;
                        addValidationError(errorMsgs, 'writeInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1039, null);                 
                    }
                    else if(prodType != label.Pricing_Write_In_Product && qliType != prodType){
                        isValid = false;
                        addValidationError(errorMsgs, 'productId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1009, null);
                    }
                    else if(productIdMap.get(recId).Name != label.Pricing_Write_In_Product && !String.isBlank(writeInProduct)){
                        isValid = false;
                        addValidationError(errorMsgs, 'writeInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1052, null);                 
                    }
                    
                }
                else{
                    isValid = false;
                    addValidationError(errorMsgs, 'productId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1009, null);
                }  
            }catch(Exception exp){
                isValid = false;
                addValidationError(errorMsgs, 'productId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1027, 
                                   new Map<String, String>{'{{ID}}' => productId});
            }                      
        }else{
            isValid = false;
            addValidationError(errorMsgs, 'productId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'Product Id'});
        }
    }
    
    public void validateCompProduct(String productId, String writeInProduct, Map<String,ErrorMsg> errorMsgs){
        //check if the competitor product is available in salesforce using competitor product Id
        if(!String.isBlank(productId)){
            try {
                Id recId = Id.valueOf(productId);    
                writeInProduct = !String.isEmpty(writeInProduct)?writeInProduct.trim() : writeInProduct;
                if(compProductIdMap.containsKey(recId)){
                    //if the given competitor product is a "Write in Product" then competitorWriteInProduct field is mandatory
                    if(compProductIdMap.get(recId).Name == label.Pricing_Write_In_Product && String.isBlank(writeInProduct)){
                        isValid = false; 
                        addValidationError(errorMsgs, 'competitorWriteInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1040, null);
                    }
                    else if(compProductIdMap.get(recId).Name != label.Pricing_Write_In_Product && !String.isBlank(writeInProduct)){
                        isValid = false; 
                        addValidationError(errorMsgs, 'competitorWriteInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1053, null);
                    }
                }else{
                    isValid = false;
                    addValidationError(errorMsgs, 'competitorProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1012, null);
                }                
            }catch(Exception exp){
                isValid = false;
                addValidationError(errorMsgs, 'competitorProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1027, 
                                   new Map<String, String>{'{{ID}}' => productId});
            }                   
        }else{
            isValid = false;
            addValidationError(errorMsgs, 'competitorProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'Competitor Product Id'});
        }    
    }  
    
    /**
    * @description Method to validate Paired CPU for GPU QuoteLines
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 07-29-2024 
    * @param productId 
    * @param writeInProduct 
    * @param errorMsgs 
    **/
    public void validatePairedCPUProduct(String productId, String writeInProduct, Map<String,ErrorMsg> errorMsgs,List<Product2> productList){
        if(!String.isBlank(productId)){
            try{
                Map<Id, Product2> pairedCPUProductsMap = new Map<Id, Product2>();
                Id recId = Id.valueOf(productId);
                writeInProduct = !String.isEmpty(writeInProduct) ?writeInProduct.trim() : writeInProduct;

                pairedCPUProductsMap = new Map<Id,Product2>(productList);
                if(pairedCPUProductsMap.containsKey(recId)){
                    //if the given PairedCPU is a "Write in Product" then writeInPairedCPU field is mandatory
                    if(pairedCPUProductsMap.get(recId).Name == label.Pricing_Write_In_Product && String.isBlank(writeInProduct)){
                        isValid = false;
                        addValidationError(errorMsgs, 'writeInPairedCPU', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1095, null);                 
                    }
                    else if(pairedCPUProductsMap.get(recId).Name != label.Pricing_Write_In_Product && !String.isBlank(writeInProduct)){
                        isValid = false;
                        addValidationError(errorMsgs, 'writeInPairedCPU', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1094, null);                 
                    }
                }else{
                    isValid = false;
                    addValidationError(errorMsgs, 'pairedCPUProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1009, null);
                }  
            }catch(Exception exp){
                isValid = false;
                addValidationError(errorMsgs, 'pairedCPUProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1027, 
                                   new Map<String, String>{'{{ID}}' => productId});
            }                      
        }else{
            isValid = false;
            addValidationError(errorMsgs, 'pairedCPUProductId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'Product Id'});
        }
    }
    
    /**
    * @description retrive all product from org
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    **/
    public static void getProducts(String quoteLineType){
        quoteLineType = String.escapeSingleQuotes(quoteLineType);
        String whereClause = (quoteLineType == Label.Pricing_Tender_Processor_Product)?
            ' WHERE (' + Label.Pricing_RestAPI_Products_CommonFilter + ')':
        ' ' + ((Pricing_RestAPI_Products.getMetadataWhereClause(quoteLineType))[0]);
        String query = Label.Pricing_RestAPI_Prodcuts_Query + whereClause;
        List<Product2> productList = Database.query(query);
        productIdMap = new Map<Id,Product2>(productList);
    } 

    /**
    * @description retrive the competitor product
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @param productId 
    **/
    public static void getCompetitorProducts(List<String> productId,String recName){
        compProductIdMap =new Map<Id, Pricing_Competitor_Product__c>([Select Id,Name from Pricing_Competitor_Product__c where Id in :productId and (RecordType.Name =: recName or Name =: label.Pricing_Write_In_Product) and Pricing_Active_cb__c = True]);
    }
    
    //Validating number fields of quoteline
    public boolean validateQuoteLineNumberFields(QuoteLineCPU quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Systems_qty__c',quoteLineDetails.noOfSystems, 'noOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_CPUs_per_system_qty__c',quoteLineDetails.noOfCPUsPerSystem,  'noOfCPUsPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Competitor_Systems_Cnt__c',quoteLineDetails.competitorNoOfSystems, 'competitorNoOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_CPUs_per_system_Cnt__c',quoteLineDetails.competitorNoOfCPUsPerSystem, 'competitorNoOfCPUsPerSystem', true));  
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    //Validating number fields of GPU quoteline
    public boolean validateGPUQuoteLineNumberFields(QuoteLineGPU quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Systems_qty__c',quoteLineDetails.noOfSystems, 'noOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_CPUs_per_system_qty__c',quoteLineDetails.noOfCPUsPerSystem,  'noOfCPUsPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_No_of_GPUs_per_system_nbr__c',quoteLineDetails.noOfGPUsPerSystem,  'noOfGPUsPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Competitor_Systems_Cnt__c',quoteLineDetails.competitorNoOfSystems, 'competitorNoOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_CPUs_per_system_Cnt__c',quoteLineDetails.competitorNoOfUnitsPerSystem, 'competitorNoOfUnitsPerSystem', true)); 
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_No_of_GPUs_per_Sys__c',quoteLineDetails.competitorNoOfGPUsPerSystem, 'competitorNoOfGPUsPerSystem', true));
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateSSDQuoteLineNumberFields(QuoteLineSSD quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Total_Volume_Qty__c',quoteLineDetails.quantity, 'quantity', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_Density_Nbr__c',quoteLineDetails.competitorDensity,  'competitorDensity', true));  
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validatePMemQuoteLineNumberFields(QuoteLinePMem quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Systems_qty__c',quoteLineDetails.noOfSystems, 'noOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Units_per_system_qty__c	',quoteLineDetails.noOfUnitsPerSystem,  'noOfUnitsPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_Density_Nbr__c',quoteLineDetails.competitorDensity,  'competitorDensity', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_CPU_Quantity_per_System_qty__c',quoteLineDetails.noOfCPUsPerSystem,  'noOfCPUsPerSystem', false));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_DRAM_Density_Nbr__c',quoteLineDetails.dramDensity,  'dramDensity', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_DRAM_per_System_qty__c',quoteLineDetails.noOfDRAMPerSystem,  'noOfDRAMPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Competitor_Systems_Cnt__c',quoteLineDetails.competitorNoOfSystems,  'competitorNoOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_CPUs_per_system_Cnt__c',quoteLineDetails.competitorNoOfUnitsPerSystem,  'competitorNoOfUnitsPerSystem', true));
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateNICQuoteLineNumberFields(QuoteLineEthernet quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Total_Volume_Qty__c',quoteLineDetails.quantity, 'quantity', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Competitor_Quantity_nbr__c',quoteLineDetails.competitorQuantity,  'competitorQuantity', true));
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateClientQuoteLineNumberFields(QuoteLineClient quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Total_Volume_Qty__c',quoteLineDetails.quantity, 'quantity', true));
        //numFldValues.add(new NumberFieldValueWrapper('Pricing_Intel_SKU_Performance_Nbr__c',quoteLineDetails.intelScore,  'intelScore', false));
        //numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_SKU_Performance_Nbr__c',quoteLineDetails.compScore,  'compScore', false));
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateQuoteLineCurrencyFields(QuoteLineCPU quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Single_System_Price_Amt__c',quoteLineDetails.singleSystemPricePoint, 'singleSystemPricePoint',  true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_OEM_Standard_Unit_Price_Amt__c',quoteLineDetails.customerStdUnitPrice,'customerStdUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Additional_OEM_Discount_Amt__c',quoteLineDetails.additionalDiscount,'additionalDiscount', true, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Single_System_Price_Amt__c',quoteLineDetails.competitorSingleSystemPrice,'competitorSingleSystemPrice', false, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Additional_OEM_Disc_Amt__c',quoteLineDetails.competitorAdditionalDiscount,'competitorAdditionalDiscount', false, true));        
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateGPUQuoteLineCurrencyFields(QuoteLineGPU quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Single_System_Price_Amt__c',quoteLineDetails.singleSystemPricePoint, 'singleSystemPricePoint',  true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_OEM_Standard_Unit_Price_Amt__c',quoteLineDetails.customerStdUnitPrice,'customerStdUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Additional_OEM_Discount_Amt__c',quoteLineDetails.additionalDiscount,'additionalDiscount', true, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Single_System_Price_Amt__c',quoteLineDetails.competitorSingleSystemPrice,'competitorSingleSystemPrice', false, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Additional_OEM_Disc_Amt__c',quoteLineDetails.competitorAdditionalDiscount,'competitorAdditionalDiscount', false, true));        
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateSVDQuoteLineCurrencyFields(QuoteLineCPU quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));       
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateSSDQuoteLineCurrencyFields(QuoteLineSSD quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Unit_Price_Amt__c',quoteLineDetails.competitorSingleSystemPricePoint,'competitorSingleSystemPricePoint', false, true));       
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validatePMemQuoteLineCurrencyFields(QuoteLinePMem quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Unit_Price_Amt__c',quoteLineDetails.competitorSingleSystemPricePoint,'competitorSingleSystemPricePoint', false, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_OEM_Standard_Unit_Price_Amt__c',quoteLineDetails.customerStdUnitPrice,'customerStdUnitPrice', true, false));       
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateNICQuoteLineCurrencyFields(QuoteLineEthernet quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Unit_Price_Amt__c',quoteLineDetails.competitorSingleSystemPricePoint,'competitorSingleSystemPricePoint', true, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public boolean validateClientQuoteLineCurrencyFields(QuoteLineClient quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Single_System_Price_Amt__c',quoteLineDetails.singleSystemPricePoint, 'singleSystemPricePoint',  false, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_OEM_Standard_Unit_Price_Amt__c',quoteLineDetails.customerStdUnitPrice,'customerStdUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedUnitPrice,'requestedUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Unit_Price_Amt__c',quoteLineDetails.competitorSingleSystemPricePoint,'competitorSingleSystemPricePoint', false, true));        
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public static void validateDiscountField(QuoteLineCPU quoteline, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        //validate auto-calculated fields in case of quote or quoteline submission
        if(fldValidMap != null){
            if(fldValidMap.isEmpty() && !fldValidMap.containsKey('singleSystemPricePoint') && !fldValidMap.containsKey('noOfSystems') 
               && !fldValidMap.containsKey('requestedUnitPrice') && !fldValidMap.containsKey('customerStdUnitPrice')
              ){
                  Decimal totalBidWithoutDiscount = quoteline.singleSystemPricePoint * quoteline.noOfSystems; 									
                  Decimal quantity = quoteline.noOfCPUsPerSystem * quoteline.noOfSystems;														
                  Decimal totalIntelDiscount = (quoteline.customerStdUnitPrice - quoteline.requestedUnitPrice) * quantity;			
                  Decimal netIntelBidPrice = totalBidWithoutDiscount - totalIntelDiscount - quoteline.additionalDiscount;
                  //intel discount percentage check
                  Decimal intelDiscountPercentage = ((quoteline.customerStdUnitPrice - quoteline.requestedUnitPrice)/quoteline.customerStdUnitPrice)*100;
                  if(intelDiscountPercentage < 0 || intelDiscountPercentage > 100){
                      isValid = false;
                      addValidationError(errorMsgs, 'requestedUnitPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1031, new Map<String,String>{'{{VALUE}}' => Label.Pricing_IQR_API_IntelDiscountPercentage});
                  }
                  
                  //customer discount percentage check
                  Decimal divisor = (totalBidWithoutDiscount - (quoteline.customerStdUnitPrice * quantity));
                  
                  if(divisor<=0){
                      isValid = false;
                      addValidationError(errorMsgs,'customerDiscountPercentage',Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1093,null);
                  }else{
                      Decimal customerDiscountPercentage = (quoteline.additionalDiscount / divisor) * 100;
                      if(customerDiscountPercentage < 0 || customerDiscountPercentage > 100){
                          isValid = false;
                          addValidationError(errorMsgs, 'additionalDiscount', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1031, new Map<String,String>{'{{VALUE}}' => Label.Pricing_IQR_API_AdditionalDiscount});
                      }
                  }
              }
        }
    }
    
    public static void validateDiscountFieldGPU(QuoteLineGPU quoteline, Map<String, boolean> fldValidMap, Map<String,ErrorMsg> errorMsgs){
        //validate auto-calculated fields in case of quote or quoteline submission
        if(fldValidMap != null){
            if(fldValidMap.isEmpty() && !fldValidMap.containsKey('singleSystemPricePoint') && !fldValidMap.containsKey('noOfSystems') 
               && !fldValidMap.containsKey('requestedUnitPrice') && !fldValidMap.containsKey('customerStdUnitPrice')
              ){
                  Decimal totalBidWithoutDiscount = quoteline.singleSystemPricePoint * quoteline.noOfSystems; 									
                  Decimal quantity = quoteline.noOfGPUsPerSystem * quoteline.noOfSystems;														
                  Decimal totalIntelDiscount = (quoteline.customerStdUnitPrice - quoteline.requestedUnitPrice) * quantity;			
                  Decimal netIntelBidPrice = totalBidWithoutDiscount - totalIntelDiscount - quoteline.additionalDiscount;
                  //intel discount percentage check
                  Decimal intelDiscountPercentage = ((quoteline.customerStdUnitPrice - quoteline.requestedUnitPrice)/quoteline.customerStdUnitPrice)*100;
                  if(intelDiscountPercentage < 0 || intelDiscountPercentage > 100){
                      isValid = false;
                      addValidationError(errorMsgs, 'requestedUnitPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1031, new Map<String,String>{'{{VALUE}}' => Label.Pricing_IQR_API_IntelDiscountPercentage});
                  }
              }
        }
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Performnce Metrics Starts Here **********************************/
    public boolean validatePerformanceMetricsList(List<PerformanceMetrics> perfMetrics, QuoteLineErrorMsg qlErrors){ 
        //called from submit quote API to validate performance metrics of a perticular quoteline
        qlErrors.perfMetricsErrorMsgs = new List<PerformanceMetricsErrorMsg>();
        if(perfMetrics!=null && perfMetrics.size()>0){
            for(PerformanceMetrics pm : perfMetrics){
                PerformanceMetricsErrorMsg perErrMsg = new PerformanceMetricsErrorMsg();
                perErrMsg.performanceMetricsReferenceId = pm.performanceMetricsReferenceId;
                validatePerformanceMetrics(pm, perErrMsg, new Set<String>());
                if(perErrMsg.perfMetricsErrors != null && perErrMsg.perfMetricsErrors.isEmpty()){
                    perErrMsg.perfMetricsErrors = null;
                }
                if(perErrMsg.perfMetricsErrors != null){
                    qlErrors.perfMetricsErrorMsgs.add(perErrMsg);
                }
            }
        }else if((perfMetrics==null && Pricing_RestAPI_QuotelinesV2.isCreateDraftQuoteLine) || isCreateDraftQuote){
            //for all create conditions
        }else if(isPerfMetricsAvailable){
            
        }else{
            addValidationError(qlErrors.quoteLineErrors, 'quoteLines', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1029, null);
            isValid = false;
        }
        if(qlErrors.perfMetricsErrorMsgs.isEmpty()){
            qlErrors.perfMetricsErrorMsgs = null;
        }
        if(qlErrors.quoteLineErrors.size() == 0){
            qlErrors.quoteLineErrors = null;
        }
        if(qlErrors.perfMetricsErrorMsgs == null){
            return false;
        }else{
            return true;
        }        
    }
    
    public boolean validatePerformanceMetrics(PerformanceMetrics performanceMetrics, PerformanceMetricsErrorMsg perfMetricsError, Set<String> perfMetricsIds){
        //validate a single performance metrics
        perfMetricsError.perfMetricsErrors = new Map<String, ErrorMsg>();
        perfMetricsIds = quotelineIdPerfMap.get(updateQuotelineId);
        if((perfMetricsIds != null && !String.isBlank(performanceMetrics.performanceMetricsId) && !perfMetricsIds.contains(performanceMetrics.performanceMetricsId)) || (perfMetricsIds!=null && perfMetricsIds.size() == 0 && !String.isBlank(performanceMetrics.performanceMetricsId))){
            addValidationError(perfMetricsError.perfMetricsErrors , 'performanceMetricsId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1037, null);
            isValid = false;
        }
        //validate all number fields
        if(!validatePMNumberFields(performanceMetrics, perfMetricsError.perfMetricsErrors)){            
            isValid = false;
        }
        
        if(!validatePMDecimalFields(performanceMetrics, perfMetricsError.perfMetricsErrors)){            
            isValid = false;
        }
        
        //validate picklist values of performance metrics used
        if(!validatePicklistValues(sObjPerformanceMatrixFieldMap, 'Pricing_Performance_Metric_Nm__c',performanceMetrics.performanceMetricsUsed, true, perfMetricsError.perfMetricsErrors, 'performanceMetricsUsed')){
            isValid = false;
        }
        //check if performanceMetricsUsed = Other then validate otherText field is empty or not
        if(performanceMetrics.performanceMetricsUsed == 'Other'){
            performanceMetrics.otherText = String.isBlank(performanceMetrics.otherText) ? null : performanceMetrics.otherText.trim();
            if(String.isBlank(performanceMetrics.otherText)){
                isValid = false;
                addValidationError(perfMetricsError.perfMetricsErrors, 'otherText', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1041, null);
            }else if(!validatePMTextFields(performanceMetrics, sObjPerformanceMatrixFieldMap, perfMetricsError.perfMetricsErrors)){
                isValid = false;                
            }
        }else{
            performanceMetrics.otherText = String.isBlank(performanceMetrics.otherText) ? null : performanceMetrics.otherText.trim();
            if(!String.isBlank(performanceMetrics.otherText)){
                isValid = false;
                addValidationError(perfMetricsError.perfMetricsErrors, 'otherText', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1050, null);
            }
        }
        
        //if ispatch then id is mendatory
        if(Pricing_RestAPI_PerformanceMetrics.isPatch){
            if(performanceMetrics.performanceMetricsId == null || String.isEmpty(performanceMetrics.performanceMetricsId)){
                isValid = false;
                addValidationError(perfMetricsError.perfMetricsErrors, 'performanceMetricsId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'Performance Metrics Id'});
            }else{
                try{
                    Id perfId = (Id)performanceMetrics.performanceMetricsId;
                }catch(Exception ex){
                    isValid = false;
                    addValidationError(perfMetricsError.perfMetricsErrors, 'performanceMetricsId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1027, 
                                       new Map<String, String>{'{{ID}}' => performanceMetrics.performanceMetricsId});
                }
            }
        }
        
        
        //referenceField is mendatory
        if(String.isBlank(performanceMetrics.performanceMetricsReferenceId)){
            addValidationError(perfMetricsError.perfMetricsErrors, 'performanceMetricsReferenceId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            isValid = false;
        }
        
        validateWeighting(performanceMetrics.weighting, perfMetricsError.perfMetricsErrors);
        validateIntelScore(performanceMetrics.intelScore, perfMetricsError.perfMetricsErrors);
        validateCompScore(performanceMetrics.compScore, perfMetricsError.perfMetricsErrors);
        if(perfMetricsError.perfMetricsErrors.size() == 0){
            perfMetricsError.perfMetricsErrors = null;
        }
        return isValid;
    }
    
    //Validate Performance Matrics text fields
    public boolean validatePMTextFields(PerformanceMetrics performanceMetrics, Map<String,Schema.SObjectField> sObjPerformanceMatrixFieldMap, Map<String,ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Nm__c',performanceMetrics.otherText, 'otherText', true));      
        return validTextFields(sObjPerformanceMatrixFieldMap, textFldValues, errorMsgs); 
    }
    
    public static void validateWeighting(Decimal percent, Map<String,ErrorMsg> errorMsgs){
        //check if Weighting is between 1 to 100
        if(percent > 100 || percent < 1){
            isValid = false;
            addValidationError(errorMsgs, 'weighting', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1015, null);
        }
    }
    
    public static void validateIntelScore(Decimal intelscore, Map<String,ErrorMsg> errorMsgs){
        //check if intel score is a positive value
        if(intelscore < 0.01){
            isValid = false;
            addValidationError(errorMsgs, 'intelScore', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
        }
    }
    
    public static void validateCompScore(Decimal compscore, Map<String,ErrorMsg> errorMsgs){
        //check if comp score is a positive value
        if(compscore < 0.01){
            isValid = false;
            addValidationError(errorMsgs, 'compScore', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
        }
    }   
    
    public boolean validatePMNumberFields(PerformanceMetrics performanceMetrics, Map<String, ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>(); 
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Weighting_Pct__c',performanceMetrics.weighting, 'weighting', false));  
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        return validNumberFields(sObjPerformanceMatrixFieldMap, numFldValues, fldValidMap, errorMsgs);
    }
    
    public boolean validatePMDecimalFields(PerformanceMetrics performanceMetrics, Map<String, ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_SKU_Performance_Nbr__c',performanceMetrics.compScore, 'compScore',  true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Intel_SKU_Performance_Nbr__c',performanceMetrics.intelScore, 'intelScore',  true, false));
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        return validateCurrencyFields(sObjPerformanceMatrixFieldMap, currencyFldValues, fldValidMap, errorMsgs);
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Quote Comments Starts Here **********************************/
    
    public boolean validateQuoteComments(List<QuoteComment> quoteComments, QuoteErrorMsg quoteErrors,String quoteId){
        //this method validates quote comments from input JSON for yet to be created quote. Uses Core_CPQ_Tender_Comments__mdt to validate questions and answers
        quoteErrors.quoteCommentsErrors = new Map<String, ErrorMsg>();
        if(quoteComments!=null && quoteComments.size() > 0 ){
            
            List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
            List<String> questionList = new List<String>();
            List<String> quoteQuestLst = new List<String>();
            Map<String, String> questIdMap = new Map<String, String>();
            String productType = (isClient)?Label.Pricing_Tender_CCG_Quote:Label.Pricing_Tender_DCG_Product_Type;
            for(Core_CPQ_Tender_Comments__mdt qcMdt : [SELECT Pricing_Question__c,Pricing_Comment_Ref_Id__c FROM Core_CPQ_Tender_Comments__mdt 
                                                       WHERE Pricing_Business_Unit_Pkl__c =: productType]){
                                                           quoteQuestLst.add(qcMdt.Pricing_Comment_Ref_Id__c);
                                                           questIdMap.put(qcMdt.Pricing_Comment_Ref_Id__c,qcMdt.Pricing_Question__c);
                                                       }
            isValid = performQuoteCommentsValidation(quoteComments,questionList,quoteQuestLst,quoteErrors.quoteCommentsErrors,textFldValues,questIdMap,SObjectCommentsMap);
        }else if(!isCreateDraftQuote && !isSvd){
            addValidationError(quoteErrors.quoteCommentsErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1030, null);
            isValid = false;
        }else if(Pricing_RestAPI_QuotesV2.isResubmit && !isSvd){
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            List<Pricing_Comments__c> lstComment = [SELECT Id,Pricing_Answer__c,Pricing_Required_Ind__c,Pricing_Question__c FROM Pricing_Comments__c WHERE Pricing_Quote__c =: quoteId and recordtypeid=:commentRecordTypeId];
            if(Pricing_publish_Quote.quoteCommentsValidation(lstComment)){
                addValidationError(quoteErrors.quoteCommentsErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1036, null);
                isValid = false;
            }
        }
        if(quoteErrors.quoteCommentsErrors.size() == 0){
            quoteErrors.quoteCommentsErrors = null;
        }
        if(quoteErrors.quoteErrors.size() == 0){
            quoteErrors.quoteErrors = null;
        }
        return isValid;
    }
    
    public static boolean performQuoteCommentsValidation(List<QuoteComment> quoteComments,List<String> questionList,List<String> quoteQuestLst,Map<String, ErrorMsg> quoteErrors,List<TextFieldValueWrapper> textFldValues,Map<String, String> questIdMap,Map<String,Schema.SObjectField> SObjectCommentsMap){
        if(quoteComments.size() < quoteQuestLst.size() && !isCreateDraftQuote && !isSvd){
            isValid=false;
            addValidationError(quoteErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1036, null);
        }
        for(QuoteComment qc: quoteComments){
            if(!String.isBlank(qc.quoteCommentReferenceId)){
                if(!questionList.contains(qc.quoteCommentReferenceId)){
                    if(!String.isBlank(qc.quoteCommentReferenceId) && !quoteQuestLst.contains(qc.quoteCommentReferenceId)){ 	//check if quote comment is already existing or not
                        addValidationError(quoteErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1044, null);
                        isValid=false;
                    }else if(!questIdMap.get(qc.quoteCommentReferenceId).contains(Label.Pricing_Tender_Comments_NoMinLengthQuest) && !questIdMap.get(qc.quoteCommentReferenceId).contains(Label.Pricing_Client_Comment_Question_noMinLength)){    	//if question does not contain "incumbent" the anwer text length should be >=10                    
                        isValid = performQuoteCommentsAnswerValidation(qc.answer,questIdMap.get(qc.quoteCommentReferenceId),qc.quoteCommentReferenceId,textFldValues,quoteErrors,SObjectCommentsMap);
                    }else{
                        textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',qc.answer, qc.quoteCommentReferenceId,!isSvd));                   
                    }
                }else{
                    isValid=false;
                    addValidationError(quoteErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1046, new Map<String,String>{'{{REFID}}' => qc.quoteCommentReferenceId});
                }
            }else{
                isValid=false;
                addValidationError(quoteErrors, 'quoteCommentReferenceId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'quoteCommentReferenceId'});
            }
            questionList.add(qc.quoteCommentReferenceId);
        }
        if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors)){
            isValid = false;
        }
        return isValid;
    }
    
    public static boolean performQuoteCommentsAnswerValidation(String answer,String question,String quoteCommentReferenceId,List<TextFieldValueWrapper> textFldValues,Map<String, ErrorMsg> quoteErrors,Map<String,Schema.SObjectField> SObjectCommentsMap){
        if(!String.isBlank(answer)){
            textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',answer, quoteCommentReferenceId, !isSvd));
            if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors)){
                isValid = false;
            }
            boolean isMinLengthValid = (answer.trim().length() < 10) ? false : true;                        
            if(!isMinLengthValid){
                isValid = false;
                addValidationError(quoteErrors, quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1018, null);
            } 
        }else if (!isSvd){
            isValid = false;
            addValidationError(quoteErrors, quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
        }
        return isValid;
    }
    
    /***********************************************************************************************/	
    
    /*************************** Misc. Common validation methods starts here **********************************/
    
    public static boolean validTextFields(Map<String,Schema.SObjectField> objectMap, List<TextFieldValueWrapper> txtFlds, Map<String,ErrorMsg> errorMsgs){
        boolean isTxtValid = true;        
        if(txtFlds.size() > 0){
            for(TextFieldValueWrapper txtFld : txtFlds){
                if(!txtFld.isMandatory && (txtFld.fldValue == null || String.isEmpty(txtFld.fldValue.trim()))){
                    //do nothing - value can be blank if the field is not mandatory
                } else {
                    //if field is mandatory or field has a value
                    if(!String.isBlank(txtFld.fldValue) && (txtFld.fldValue.length() > 0)){           
                        Integer fieldLength = objectMap.get(txtFld.fldName).getDescribe().getLength();
                        if(fieldLength < txtFld.fldValue.length()){
                            //checking if input text length is more than field max limit
                            isTxtValid = isValid = false;
                            addValidationError(errorMsgs, txtFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, 
                                               new Map<String,String>{'{{dataMaxLimit}}' => String.valueOf(fieldLength)});                            
                        }
                        //check if text fields contain non-latin character
                        Set<String> quoteTextFields = new Set < String > ((Label.Pricing_Tender_Quote_Text_Fields).split(':'));
                        Set<String> quoteLineTextFields = new Set < String > ((Label.Pricing_Tender_Quote_Line_Text_Fields).split(':'));
                        Set<String> perMetricCommentTextFields = new Set < String > ((Label.Pricing_Tender_PerMetric_Other_Text_Field).split(':'));
                        if(quoteTextFields.contains(txtFld.fldName) || quoteLineTextFields.contains(txtFld.fldName) || perMetricCommentTextFields.contains(txtFld.fldName)){
                            if(Pricing_Tender_Utility.validateNonLatinChars(txtFld.fldValue)){
                                isTxtValid = isValid = false;
                                addValidationError(errorMsgs, txtFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1059, null); 
                            }
                        } 
                    }else{
                        //if field text is empty for mandatory field
                        isTxtValid = isValid = false;
                        addValidationError(errorMsgs, txtFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                    }    
                } 
            }            
        }
        return isTxtValid;
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
                            addValidationError(errorMsgs, numFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
                        }else{
                            String[] fldValueArr = String.valueOf(numFld.fldValue).split('\\.');   
                            if(fldValueArr.size()>1 && Decimal.valueOf('.'+fldValueArr[1]) > 0){	//number fields can only accept whole number
                                isNumValid = isValid = false;
                                fldValidMap.put(numFld.fldName, false);
                                addValidationError(errorMsgs, numFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
                            }else if(fldValueArr[0].length() > NUMBER_FIELD_MAX_LENGTH){
                                //checking if input number field length is more than field max limit
                                isNumValid = isValid = false;
                                fldValidMap.put(numFld.fldName, false);
                                addValidationError(errorMsgs, numFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1022, 
                                                   new Map<String,String>{'{{numberOfDigits}}' => String.valueOf(NUMBER_FIELD_MAX_LENGTH)});
                            }
                        }                        
                    }else{
                        //if field is empty for mandatory field
                        fldValidMap.put(numFld.fldName, false);
                        addValidationError(errorMsgs, numFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1023, null);
                        isNumValid = isValid = false;
                    }                    
                } 
            }
        }
        return isNumValid;
    }
    
    public static boolean validateDateFormat(String inputDate, boolean isMandatory, String fldLabel, Map<String,ErrorMsg> errorMsgs){
        boolean isDateValid = true;
        if(!isMandatory && String.isBlank(inputDate)){
            // Date can be empty if it is not mandatory
        }else{
            try {
                Date d = Date.parse(inputDate);		//check if date is a valid format(mm/dd/yyyy)
            }catch(Exception e){
                if(errorMsgs!=null){
                    addValidationError(errorMsgs, fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1024, null);
                }                
                isDateValid = isValid = false;
            }
        }
        return isDateValid;
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
                            addValidationError(errorMsgs, currencyFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1021, null);
                        }else if(currencyFld.allowZero && currencyFld.fldValue < 0){
                            isCurrencyValid = isValid = false;
                            addValidationError(errorMsgs, currencyFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1025, null);
                        }else{
                            String[] fldValArr = String.valueOf(currencyFld.fldValue).split('\\.');
                            if(fldValArr[0].replace('-','').length() > NUMBER_FIELD_MAX_LENGTH){
                                //checking if input number field length is more than field max limit
                                isCurrencyValid = isValid = false;
                                fldValidMap.put(currencyFld.fldName, false);
                                addValidationError(errorMsgs, currencyFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1022, 
                                                   new Map<String,String>{'{{numberOfDigits}}' => String.valueOf(NUMBER_FIELD_MAX_LENGTH)});
                            }
                        }
                    }else {
                        //if field is empty for mandatory field
                        isCurrencyValid = isValid = false;
                        fldValidMap.put(currencyFld.fldName, false);
                        addValidationError(errorMsgs, currencyFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1023, null);
                    }
                } 
            }
        }
        return isCurrencyValid;
    }
    
   /* public static boolean validatePicklistValues(Map<String,Schema.SObjectField> objectMap, String fieldName, String fldValue, boolean isMandatory, Map<String,ErrorMsg> errorMsgs, String jsonLabel){
        boolean isFldValid = false;
        boolean isEmpty = false;
        if(!isMandatory && String.isBlank(fldValue)){
            isFldValid = true;
            //do nothing - value can be blank if the field is not mandatory
        }else{
            Schema.DescribeFieldResult fldRes = objectMap.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fldRes.getPicklistValues();
            if(!String.isBlank(fldValue) && !fldValue.contains(',')){               
                for( Schema.PicklistEntry f : ple)
                {
                    if(f.isActive() && f.getValue() == fldValue){
                        isFldValid =  true; 
                        break;
                    }
                }
            }
            //For checking Multi Picklist values for consumption country and region.
            else if(!String.isBlank(fldValue) && fldValue.contains(',')){
                List<String> multiFldValue = fldValue.split(',');
                integer count = 0;
                for( Schema.PicklistEntry f : ple)
                {
                    if(f.isActive() && multiFldValue.contains(f.getValue())){
                        count++;
                    }
                }
                if(count == multiFldValue.size()){
                    isFldValid =  true;
                }
                else{
                    isFldValid = false;
                }  
            }
            else {
                isEmpty = true;
                addValidationError(errorMsgs, jsonLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            }
            if(!isEmpty && !isFldValid){
                addValidationError(errorMsgs, jsonLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1026, 
                                   new Map<String,String>{'{{fieldValue}}' => fldValue});
            }
        }
        return isFldValid;
    }*/
    public static Boolean validatePicklistValues(
    Map<String, Schema.SObjectField> objectMap,
    String fieldName,
    String fldValue,
    Boolean isMandatory,
    Map<String, ErrorMsg> errorMsgs,
    String jsonLabel
) {
    Boolean isFldValid = false;
    Boolean isEmpty = false;
    Map<String, String> consumptionCountryStoreMap = new Map<String, String>();
    
    if (!isMandatory && String.isBlank(fldValue)) {
        isFldValid = true;
    } else {
        Schema.DescribeFieldResult fldRes =
            objectMap.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fldRes.getPicklistValues();
 
        if (String.isBlank(fldValue)) {
            isEmpty = true;
            addValidationError(
                errorMsgs,
                jsonLabel,
                Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020,
                null
            );
        }
        else if (jsonLabel == 'consumptionCountry') {
            consumptionCountryStoreMap.remove(fldValue);
 
            Set<String> activeValues = new Set<String>();
 
            for (Schema.PicklistEntry entry : ple) {
                if (entry.isActive()) {
                    activeValues.add(entry.getValue());
                }
            }
 
            List<String> tokens = fldValue.split(',');
            List<String> selected = new List<String>();
            Integer tokenIndex = 0;
 
            isFldValid = !fldValue.trim().endsWith(',');
 
            while (isFldValid && tokenIndex < tokens.size()) {
                String matchedValue = null;
                Integer matchedTokens = 0;
                String candidate = '';
 
                for (Integer j = tokenIndex; j < tokens.size(); j++) {
                    candidate = j == tokenIndex
                        ? tokens[j].trim()
                        : candidate + ',' + tokens[j].trim();
 
                    // Preserve commas inside the longest valid country value.
                    if (activeValues.contains(candidate)) {
                        matchedValue = candidate;
                        matchedTokens = j - tokenIndex + 1;
                    }
                }
 
                if (matchedValue == null) {
                    isFldValid = false;
                    break;
                }
 
                selected.add(matchedValue);
                tokenIndex += matchedTokens;
            }
 
            if (isFldValid) {
                consumptionCountryStoreMap.put(
                    fldValue,
                    String.join(selected, ', ')
                );
            }
        }
        else if (fldRes.getType() != Schema.DisplayType.MultiPicklist ||
             !fldValue.contains(',')) {
            for (Schema.PicklistEntry entry : ple) {
                if (entry.isActive() && entry.getValue() == fldValue) {
                    isFldValid = true;
                    break;
                }
            }
        }
        else if (fldValue.contains(',')) {
            List<String> multiFldValue = fldValue.split(',');
            Integer count = 0;
 
            for (Schema.PicklistEntry entry : ple) {
                if (entry.isActive() &&
                    multiFldValue.contains(entry.getValue())) {
                    count++;
                }
            }
 
            isFldValid = count == multiFldValue.size();
        }
 
        if (!isEmpty && !isFldValid) {
            addValidationError(
                errorMsgs,
                jsonLabel,
                Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1026,
                new Map<String, String>{ '{{fieldValue}}' => fldValue }
            );
        }
    }
 
    return isFldValid;
}    
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();        
        Schema.SObjectType objType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingInfo.put(currControllingValue.getValue(), new List<String>());
        }
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;            
            for(Integer curr : hexString.getChars()){
                Integer val = 0;                
                if(curr >= 65){
                    val = curr - 65 + 10;
                }else{
                    val = curr - 48;
                }
                if((val & 8) == 8){
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4){
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2){
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1){
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getLabel());                    
                }                
                baseCount += 4;
            }            
        }        
        return controllingInfo;
    }
    
    public static void addValidationError(Map<String,ErrorMsg> qErrorMap, String fldName, Decimal errCode, Map<String,String> placeHolders){
        
        if(errorMsgMap.containsKey(errCode)){
            String errMsg = errorMsgMap.get(errCode);
            if(placeHolders!=null && placeHolders.size() > 0){
                for(String key : placeHolders.keySet()){
                    errMsg = errMsg.replace(key, placeHolders.get(key));  
                }  
            }
            qErrorMap.put(fldName, new ErrorMsg((Integer) errCode, errMsg));
        }else{
            qErrorMap.put(fldName, new ErrorMsg(0, 'Unknown Error'));
        }
    }
    
    /***********************************************************************************************/
    
    /*************************** Record Creation methods starts here **********************************/
    public static SBQQ__Quote__c createQuoteRecord(QuoteDetails quote){
        
        //User  usr = [Select AccountId, ContactId from User where Id = :UserInfo.getUserId()];      
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Account__c = currentUser.AccountId;
        newQuote.SBQQ__PrimaryContact__c = currentUser.ContactId;
        newQuote.Pricing_Customer_Reference_Id__c = quote.referenceRequestID;
        newQuote.Pricing_Project_Name_Nm__c = quote.projectName;
        newQuote.Pricing_ShipmentStDate_Dt__c = Date.parse(quote.pricingStartDate);
        newQuote.Pricing_ShipmentEndDate_Dt__c = Date.parse(quote.pricingEndDate);
        newQuote.Pricing_SecondaryContact_Nm__c = quote.secondaryContact;
        newQuote.Pricing_Partner_Name_Nm__c = quote.partnerName;
        newQuote.Pricing_End_Customer_URL__c = quote.endCustomerUrl;
        if((primaryFSEEMail != null && !String.isBlank(primaryFSEEMail)) && isUpdateDraftQuote){
            newQuote.Pricing_Intel_Sales_Rep_Email_Txt__c = primaryFSEEMail;
            newQuote.SBQQ__SalesRep__c = validFSEEmailIdMap.containsKey(primaryFSEEMail) ? validFSEEmailIdMap.get(primaryFSEEMail) :newQuote.SBQQ__SalesRep__c;    
        }else if(!isUpdateDraftQuote){
            newQuote.Pricing_Intel_Sales_Rep_Email_Txt__c = String.isBlank(primaryFSEEMail) ? null : primaryFSEEMail;
            newQuote.SBQQ__SalesRep__c = validFSEEmailIdMap.containsKey(primaryFSEEMail) ? validFSEEmailIdMap.get(primaryFSEEMail) :newQuote.SBQQ__SalesRep__c; 
        }
        
        if((primaryAEEMail != null && !String.isBlank(primaryAEEMail)) && isUpdateDraftQuote){
            newQuote.Pricing_Intel_Account_Exec_Email_Txt__c = isValidAE ? primaryAEEMail : null;
        }else if(!isUpdateDraftQuote){
            newQuote.Pricing_Intel_Account_Exec_Email_Txt__c = (isValidAE ? String.isBlank(primaryAEEMail) ? null : primaryAEEMail : null);
        }
        
        //overall quantity is less then minimum quantity for datacenter and client check the check.
        if((isSubmitQuote || Pricing_RestAPI_QuotesV2.isResubmit) && isOverAllQtyLess){
            newQuote.Pricing_Volume_Exception_Quota_Cb__c = true;
        }
        //get End Customer Region Based on End Customer Country
        Map<String, List<String>> countryRegionMap = getFieldDependencies('SBQQ__Quote__c', 'Pricing_End_Customer_Country_Nm__c', 'Pricing_Region_Nm__c'); 
        newQuote.Pricing_Region_Nm__c = countryRegionMap.containsKey(quote.endCustomerCountry)?countryRegionMap.get(quote.endCustomerCountry)[0] : null;
        newQuote.Pricing_End_Customer_Country_Nm__c = quote.endCustomerCountry;
        newQuote.Pricing_Customer_Nm__c = quote.endCustomer;
        newQuote.Pricing_Bid_Dt__c = Date.parse(quote.proposalDueDate);
        newQuote.Pricing_Intel_Response_Requested_By_Date__c = Date.parse(quote.intelResponseRequestedDate);
        if(isClient){
            newQuote.Pricing_Market_Segment_values_Nm__c = quote.marketSegment;
        }else{
            newQuote.Pricing_Server_Deal_Type_Nm__c = quote.application;
        }
        newQuote.Pricing_End_Customer__c = writeInUnifiedId;
        newQuote.Pricing_AdditionalRecipients__c = quote.additionalQuoteLetterRecipients;
        if (!isUpdateDraftQuote && isSvd)
        {
            newQuote.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create);
        }
        else if (!isUpdateDraftQuote && isClient)
        {
            newQuote.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Client_Quote_RecordType_Create);
        }
        else if(!isUpdateDraftQuote){
            newQuote.RecordTypeId = quoteCreateRecordTypeId;
        }
        return newQuote;
    }
    
    public static List<Pricing_Quote_Team__c> createFSEQuoteTeam(Id newQuoteId){
        Set<id> userIds = new Set<Id>();
        List<Pricing_Quote_Team__c> fseQTM = new List<Pricing_Quote_Team__c>();
        if(Pricing_RestAPI_QuotesV2.isCreateQuoteTeam){
            List<SBQQ__Quote__c> quoteList = [Select id, Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c where id =:newQuoteId];
            primaryFSEEmail = quoteList[0].Pricing_Intel_Sales_Rep_Email_Txt__c;
        }
        if(createNewQTMMap.get('FSE') != null){
            for(Pricing_Quote_Team__c q: createNewQTMMap.get('FSE')){
                if(validFSEEmailIdMap.containsKey(q.Pricing_Quote_Team_Member_Id__r.Email)){
                    validFSEEmailIdMap.remove(q.Pricing_Quote_Team_Member_Id__r.Email);
                }
            }
        }
        for(String fseEmail : validFSEEmailIdMap.keySet()){
            Id userId = validFSEEmailIdMap.get(fseEmail);
            if(!userIds.contains(userId) && (String.isblank(primaryFSEEmail) || !primaryFSEEmail.equalsIgnoreCase(fseEmail))){
                userIds.add(userId);
                fseQTM.add(new Pricing_Quote_Team__c(Pricing_Quote_Id__c=newQuoteId, Pricing_Quote_Team_Member_Id__c=userId, 
                                                     Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_FSE,
                                                     Pricing_Grant_Access_Ind__c=True, RecordTypeId = quoteTeamRecordTypeId));
            }
        }
        return fseQTM;
    }
    
    public static List<Pricing_Quote_Team__c> createAEQuoteTeam(Id newQuoteId){
        Set<id> userIds = new Set<Id>();
        List<Pricing_Quote_Team__c> aeQTM = new List<Pricing_Quote_Team__c>();
        for(User aeUser : AEEmailUserList){
            Id userId = aeUser.Id;
            if(!userIds.contains(userId) && (!primaryAEEmail.equalsIgnoreCase(aeUser.Email) || Pricing_RestAPI_QuotesV2.isCreateQuoteTeam)){
                userIds.add(userId);
                aeQTM.add(new Pricing_Quote_Team__c(Pricing_Quote_Id__c=newQuoteId, Pricing_Quote_Team_Member_Id__c=userId, 
                                                    Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_Account_Executive, RecordTypeId = quoteTeamRecordTypeId));
            }
        }
        return aeQTM;
    }
    
    public static List<Pricing_Quote_Team__c> createITSQuoteTeam(Id newQuoteId){
        Set<id> userIds = new Set<Id>();
        List<Pricing_Quote_Team__c> itsQTM = new List<Pricing_Quote_Team__c>();
        for(User itsUser : ITSEmailUserList){
            Id userId = itsUser.Id;
            if(!userIds.contains(userId)){
                userIds.add(userId);
                itsQTM.add(new Pricing_Quote_Team__c(Pricing_Quote_Id__c=newQuoteId, Pricing_Quote_Team_Member_Id__c=userId, 
                                                     Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_ITS, RecordTypeId = quoteTeamRecordTypeId));
            }
        }
        return itsQTM;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineRecords(Id quoteId, QuoteLines quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        quoteLineList.addAll(!quoteLines.DataCenterCPU.isEmpty() ? createQuoteLineCPU(quoteId,quoteLines.DataCenterCPU):new List<SBQQ__QuoteLine__c>());
        quoteLineList.addAll(!quoteLines.DataCenterGPU.isEmpty() ? createQuoteLineGPU(quoteId,quoteLines.DataCenterGPU):new List<SBQQ__QuoteLine__c>()); //Creating Records for GPU QL
        quoteLineList.addAll(!quoteLines.OptaneSSD.isEmpty() ? createQuoteLineSSD(quoteId,quoteLines.OptaneSSD):new List<SBQQ__QuoteLine__c>());
        quoteLineList.addAll(!quoteLines.OptanePMem.isEmpty() ? createQuoteLinePMem(quoteId,quoteLines.OptanePMem):new List<SBQQ__QuoteLine__c>());
        quoteLineList.addAll(!quoteLines.Ethernet.isEmpty() ? createQuoteLineEthernet(quoteId,quoteLines.Ethernet):new List<SBQQ__QuoteLine__c>());
        quoteLineList.addAll(!quoteLines.Client.isEmpty() ? createQuoteLineClient(quoteId,quoteLines.Client):new List<SBQQ__QuoteLine__c>());
        return quoteLineList;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineCPU(Id quoteId,List<QuoteLineCPU> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineCPUList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineCPU q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineSVDCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineSVDCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_Systems_qty__c = q.noOfSystems;
            newQuoteLine.Pricing_CPUs_per_system_qty__c = q.noOfCPUsPerSystem;
            newQuoteLine.Pricing_Competetor_Product__c =(Id) q.competitorProductId;
            newQuoteLine.Pricing_Other_Competitor_Product_Nm__c = String.isEmpty(q.competitorWriteInProduct) ? null : q.competitorWriteInProduct.trim();
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = q.competitorNoOfSystems;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = q.competitorNoOfCPUsPerSystem;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            if(!isSvd){
                newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineCreateRecordTypeId : assignedRecordTypeId;
                newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
                newQuoteLine.Pricing_Single_System_Price_Amt__c = q.singleSystemPricePoint;
                newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
                newQuoteLine.Pricing_Additional_OEM_Discount_Amt__c = q.additionalDiscount;
                newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
                newQuoteLine.Pricing_Competitor_System_Model_Nm__c = q.competitorSystemModel;
                newQuoteLine.Pricing_Comp_Single_System_Price_Amt__c = q.competitorSingleSystemPrice;
                newQuoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c = q.competitorAdditionalDiscount;
            }
            quoteLineCPUList.add(newQuoteLine);
        }        
        return quoteLineCPUList;
    }
    //Creation of GPU QL List
    public static List<SBQQ__QuoteLine__c> createQuoteLineGPU(Id quoteId,List<QuoteLineGPU> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineGPUList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineGPU q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Paired_CPU_Nm__c =(Id) q.pairedCPUId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineDatacenterGPUCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineDatacenterGPUCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_Systems_qty__c = q.noOfSystems;
            newQuoteLine.Pricing_Write_In_Paired_CPU_Nm__c = q.writeInPairedCPU;
            //newQuoteLine.Pricing_No_of_GPUs__c= q.noOfGPUs;
            newQuoteLine.Pricing_No_of_GPUs_per_system_nbr__c = q.noOfGPUsPerSystem;
            newQuoteLine.Pricing_CPUs_per_system_qty__c = q.noOfCPUsPerSystem;
            newQuoteLine.Pricing_Competetor_Product__c =(Id) q.competitorProductId;
            newQuoteLine.Pricing_Other_Competitor_Product_Nm__c = String.isEmpty(q.competitorWriteInProduct) ? null : q.competitorWriteInProduct.trim();
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = q.competitorNoOfSystems;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = q.competitorNoOfUnitsPerSystem;
            newQuoteLine.Pricing_Comp_No_of_GPUs_per_Sys__c = q.competitorNoOfGPUsPerSystem;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
            newQuoteLine.Pricing_Single_System_Price_Amt__c = q.singleSystemPricePoint;
            newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
            newQuoteLine.Pricing_Additional_OEM_Discount_Amt__c = q.additionalDiscount;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
            newQuoteLine.Pricing_Competitor_System_Model_Nm__c = q.competitorSystemModel;
            newQuoteLine.Pricing_Comp_Single_System_Price_Amt__c = q.competitorSingleSystemPrice;
            newQuoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c = q.competitorAdditionalDiscount;
            quoteLineGPUList.add(newQuoteLine);
        }        
        return quoteLineGPUList;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineClient(Id quoteId,List<QuoteLineClient> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineClientList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineClient q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineClientCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineClientCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_Total_Volume_Qty__c = q.quantity;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Competetor_Product__c =(Id) q.competitorProductId;
            newQuoteLine.Pricing_Other_Competitor_Product_Nm__c = String.isEmpty(q.competitorWriteInProduct) ? null : q.competitorWriteInProduct.trim();
            newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
            newQuoteLine.Pricing_Form_Factor_Nm__c = q.formFactor;
            newQuoteLine.Pricing_Single_System_Price_Amt__c = q.singleSystemPricePoint;
            newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
            newQuoteLine.Pricing_Competitor_System_Model_Nm__c = q.competitorSystemModel;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = q.competitorSingleSystemPricePoint;
            //newQuoteLine.Pricing_Performance_Metric_Nm__c = q.performanceMetricUsed;
            //newQuoteLine.Pricing_Write_In_Performance_Metric_Nm__c = q.writeInPerformanceMetric;
            //newQuoteLine.Pricing_Intel_SKU_Performance_Nbr__c = q.intelScore;
            //newQuoteLine.Pricing_Comp_SKU_Performance_Nbr__c = q.compScore;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            quoteLineClientList.add(newQuoteLine);
        }        
        return quoteLineClientList;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineSSD(Id quoteId, List<QuoteLineSSD> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineSSDList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineSSD q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineSSDCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineSSDCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
            newQuoteLine.Pricing_Total_Volume_Qty__c = q.quantity;
            newQuoteLine.Pricing_Comp_Product_Txt__c = q.competitorProduct;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = q.competitorSingleSystemPricePoint;
            newQuoteLine.Pricing_Comp_Density_Nbr__c = q.competitorDensity;
            newQuoteLine.Pricing_VolumeByQuarterAndReasoning_Txt__c = q.volumeByQuarterAndReasoning;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            quoteLineSSDList.add(newQuoteLine);
        }
        return quoteLineSSDList;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLinePMem(Id quoteId, List<QuoteLinePMem> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLinePMemList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLinePMem q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLinePMemCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLinePMemCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
            newQuoteLine.Pricing_Systems_qty__c = q.noOfSystems;
            newQuoteLine.Pricing_Units_per_system_qty__c = q.noOfUnitsPerSystem;
            newQuoteLine.Pricing_CPU_Txt__c = q.pairedCPU;
            newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
            newQuoteLine.Pricing_CPU_Quantity_per_System_qty__c = q.noOfCPUsPerSystem;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
            newQuoteLine.Pricing_Comp_Density_Nbr__c = q.competitorDensity;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = q.competitorSingleSystemPricePoint;
            newQuoteLine.Pricing_Server_Integration_Nm__c = q.serverIntegration;
            newQuoteLine.Pricing_Workload_Txt__c = q.workload;
            newQuoteLine.Pricing_POC_testing_results_Txt__c = q.pocTestingResults;
            newQuoteLine.Pricing_DRAM_Density_Nbr__c = q.dramDensity;
            newQuoteLine.Pricing_DRAM_per_System_qty__c = q.noOfDRAMPerSystem;
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = q.competitorNoOfSystems;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = q.competitorNoOfUnitsPerSystem;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            quoteLinePMemList.add(newQuoteLine);
        }
        return quoteLinePMemList;
    }
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineEthernet(Id quoteId, List<QuoteLineEthernet> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineEthernetList = new List<SBQQ__QuoteLine__c>();
        for(QuoteLineEthernet q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedUnitPrice;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_QuotelinesV2.isUpdateDraftQuoteLine && !Pricing_RestAPI_QuotelinesV2.isResubmit ? quoteLineEthernetCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineEthernetCreateRecordTypeId : assignedRecordTypeId;
            newQuoteLine.Pricing_Total_Volume_Qty__c = q.quantity;
            newQuoteLine.Pricing_Comp_Product_Txt__c = q.competitorProduct;
            newQuoteLine.Pricing_Competitor_Quantity_nbr__c = q.competitorQuantity;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = q.competitorSingleSystemPricePoint;
            newQuoteLine.Pricing_Consumption_Country__c = !String.isBlank(q.consumptionCountry) ? q.consumptionCountry.replace(',',', ') : q.consumptionCountry;
            newQuoteLine.Pricing_Consumption_Platform__c = !String.isBlank(q.consumptionPlatform) ? q.consumptionPlatform.replace(',',', ') : q.consumptionPlatform;
            newQuoteLine.Pricing_Consumption_Region__c = !String.isBlank(q.consumptionRegion) ? q.consumptionRegion.replace(',',', ') : q.consumptionRegion;
            newQuoteLine.Pricing_Consumption_Sale_Geo__c = !String.isBlank(q.consumptionSalesGeo) ? q.consumptionSalesGeo.replace(',',', ') : q.consumptionSalesGeo;
            newQuoteLine.Pricing_Consumption_Segment__c = !String.isBlank(q.consumptionSegment) ? q.consumptionSegment.replace(',',', ') : q.consumptionSegment;
            quoteLineEthernetList.add(newQuoteLine);
        }
        return quoteLineEthernetList;
    }
    
    public static List<Pricing_Performance_Metric__c> createPerformanceMetricsRecordDetails(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDetails permets){
        List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
        for(PerformanceMetrics permet : permets.performanceMetrics){
            Pricing_Performance_Metric__c metric = new Pricing_Performance_Metric__c();
            metric.Pricing_Weighting_Pct__c = permet.weighting;
            metric.Pricing_Performance_Metric_Nm__c = permet.performanceMetricsUsed;
            metric.Pricing_Intel_SKU_Performance_Nbr__c = permet.intelScore;
            metric.Pricing_Comp_SKU_Performance_Nbr__c = permet.compScore;
            metric.Pricing_Other_Nm__c=permet.otherText;
            metric.Pricing_Quote_Line__c=permets.quoteLineId;
            perfMetrics.add(metric);
        }
        return perfMetrics;
    }
    
    public static void createPerformanceMetricsRecord(Id quoteLineId, List<PerformanceMetrics> permets, List<Pricing_Performance_Metric__c> perfMetricsLst){
        List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
        for(PerformanceMetrics permet : permets){
            Pricing_Performance_Metric__c metric = new Pricing_Performance_Metric__c();
            if(permet.performanceMetricsId != null && !String.isBlank(permet.performanceMetricsId)){
                metric.Id = permet.performanceMetricsId; //Update record if Id is provided
            }
            else{
                metric.Pricing_Quote_Line__c=quoteLineId;	//set quoteline id if it is new performance metrics
            }
            metric.Pricing_Weighting_Pct__c = permet.weighting;
            metric.Pricing_Performance_Metric_Nm__c = permet.performanceMetricsUsed;
            metric.Pricing_Intel_SKU_Performance_Nbr__c = permet.intelScore;
            metric.Pricing_Comp_SKU_Performance_Nbr__c = permet.compScore;
            metric.Pricing_Other_Nm__c=permet.otherText;
            perfMetricsLst.add(metric);
        }
    }
    
    public static List<Pricing_Comments__c> createQuoteComments(Id quoteId, List<QuoteComment> quoteComments){
        List<Pricing_Comments__c> commsTobeUpserted = new List<Pricing_Comments__c>();
        if(qComms.isEmpty()){
            qComms = [SELECT id,Pricing_Answer__c,Pricing_Question__c,Pricing_Comment_Ref_Id__c FROM Pricing_Comments__c WHERE Pricing_Quote__c= : quoteId AND RecordType.DeveloperName =: Label.Pricing_Tender_Comment_RecordType_Quote_Comment AND Pricing_Quote__r.SBQQ__Account__c = :currentUser.AccountId]; 
        }
        if(quoteComments != null && quoteComments.size() > 0){
            for(QuoteComment qComment : quoteComments){
                boolean qFlag = false;               
                for(Pricing_Comments__c qComm : qComms){                    
                    if(qComment.quoteCommentReferenceId == qComm.Pricing_Comment_Ref_Id__c){                       
                        qFlag = true;
                        commsTobeUpserted.add(new Pricing_Comments__c(Id=qComm.Id,Pricing_Answer__c=qComment.answer,Pricing_Question__c=qComm.Pricing_Question__c,Pricing_Comment_Ref_Id__c=qComm.Pricing_Comment_Ref_Id__c));                       
                    }
                }
            }       
        }
        return commsTobeUpserted;
    }
    
    public static void publishQuoteAndQuoteLines(Id recId, String primaryContactEmailId, Id accountId,Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap, Map<String,Id> FSEEmailIdMap, Set<Id> quoteLineIds, String objectName){
        try{
            String recordTypeId;
            List<SBQQ__QuoteLine__c> lstQuoteLine = new List<SBQQ__QuoteLine__c>();
            if(quoteLineIdMap.values()[0].Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted);
            }else{
                recordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
            }
            for (SBQQ__QuoteLine__c quoteLine: quoteLineIdMap.values()){
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview; 
                if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                    quoteLine.RecordTypeId = recordTypeId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted);
                }else{
                    quoteLine.RecordTypeId = recordTypeId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
                }
                quoteLine.Pricing_Ready_for_Review_cb__c = false;
                if(quoteLine.Pricing_Original_Submitted_By_Id__c == null){
                    quoteLine.Pricing_Original_Submitted_By_Id__c = UserInfo.getUserId();
                }
                if(quoteLine.Pricing_Original_Submitted_Date_dt__c == null){
                    quoteLine.Pricing_Original_Submitted_Date_dt__c = Datetime.now();
                }
                quoteLine.Pricing_Last_Submitted_Date_dt__c = Datetime.now();
                quoteLine.Pricing_Last_Submitted_By_Id__c = UserInfo.getUserId();
                lstQuoteLine.add(quoteLine);
            }
            if(!lstQuoteLine.isEmpty()){
                update lstQuoteLine;
                
                //checking if quotelines are not auto rejected.
                Set<Id> pifrQuoteLineId = new Set<Id>();
                for(SBQQ__QuoteLine__c qli: [select id from SBQQ__QuoteLine__c where id In :quoteLineIds and Pricing_Status_Nm__c =:Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview]){
                    pifrQuoteLineId.add(qli.Id);
                }
                //call submit for approval method here 
                createApprovalProcess(pifrQuoteLineId,recId,primaryContactEmailId,accountId,objectName);                        
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        }        
    }
    
    @future
    Public static void createApprovalProcess(Set<Id> quoteLineIds,Id recId, String primaryContactEmailId, Id accountId,String objType){        
        try{  
            if(quoteLineIds.size()>0){
                Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(quoteLineIds);
            }
            if(objType=='SBQQ__Quote__c'&&(!String.isBlank(primaryContactEmailId) && currentUser.Email != primaryContactEmailId)){
                List<User> usrs = [SELECT Id,ContactId FROM User WHERE Email = :primaryContactEmailId AND AccountId= :accountId];
                if(usrs.size() > 0){
                    List<SBQQ__Quote__c> quotes = [SELECT Id,SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE Id = :recId ]; // FOR UPDATE
                    if(quotes.size() > 0){
                        quotes[0].SBQQ__PrimaryContact__c = usrs[0].ContactId;
                        SBQQ.TriggerControl.disable();
                        update quotes[0];
                        SBQQ.TriggerControl.enable();
                    }
                }
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            if(TriggerHandler.isActive('Pricing_Regenerate_Approval_Record_Check')){ 
                handleRecordApprovalRegenerate(exp,recId);
            }
        }
    }

    /**
    * @description : Regerate Aprroval records if got issue UNABLE_TO_LOCK_ROW // TWC1972-7919 [KIIT] 
    * @author Vrushabh Uprikar | 02-11-2025 
    * @param exp Error
    **/
    private static void handleRecordApprovalRegenerate(Exception exp, Id recId){        
        Boolean isRecordLockIssue = false;
        Set<Id> quoteLinesSet = new Set<Id>();
        List<ProcessInstance> approvalRecords = new List<ProcessInstance>();
        for (Integer i = 0; i < exp.getNumDml(); i++) {
            if (exp.getDmlMessage(i).contains('UNABLE_TO_LOCK_ROW')) {
                isRecordLockIssue = true;
                break;
            }
        }

        if(isRecordLockIssue){  
            for(SBQQ__QuoteLine__c ql : [Select Id from SBQQ__QuoteLine__c Where SBQQ__Quote__c =: recId AND Pricing_Status_Nm__c =:Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview]){
                quoteLinesSet.add(ql.Id);
            }
        }
        if(quoteLinesSet.size() > 0){
            approvalRecords = [SELECT Id, TargetObjectId, Status, CreatedDate, LastModifiedDate FROM ProcessInstance WHERE TargetObjectId IN : quoteLinesSet AND ProcessInstance.Status Not IN ('Pending','Reassigned') ORDER BY CreatedDate DESC Limit 200];
        }
        
        // not having approval Records 
        if(approvalRecords.isEmpty() && quoteLinesSet.size() > 0){
            Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(quoteLinesSet);
        }

        if(!approvalRecords.isEmpty()){
            Set<Id> idToRemove = new Set<Id>();
            for(ProcessInstance appRecords : approvalRecords){
                idToRemove.add(appRecords.TargetObjectId);
            }
            quoteLinesSet.removeAll(idToRemove);
            if(!quoteLinesSet.isEmpty()){
                Pricing_Publish_Quote.publishQuoteLinesToMultipleFSE(quoteLinesSet);
            }
        }
    }
    
    /**
    * @description return List<String> emails excluding /n 
    * @param String email
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 03-02-2022 
    **/
    public static List<String> getSplitedEmailList(String emails){
        
        List<String> emailList = new List<String>();
        emails = emails.replace('\\n\\r', '');
        if(emails.contains(';')){
            emails = emails.replace(';', ',');
        }
        if(emails.contains(',')){
            emailList.addAll(emails.split(','));
        }    	
        if(emailList.size() == 0){
            emailList.add(emails);
        }
        return emailList;
    }
    
    private static Boolean validateConsumptionParameter(String consumptionValue, String consumptionType, Map<String,ErrorMsg> errorMsgs, String jsonLabel){
        boolean isvalid = true;
        if(!String.isBlank(consumptionValue)){
            String invalidValues;
            List<String> consumptionValueList = consumptionValue.split(',');
            for(String str : consumptionValueList){
                if(consumptionTypeToValueMap.containsKey(consumptionType) && !(consumptionTypeToValueMap.get(consumptionType).contains(str))){
                    invalidValues = invalidValues != null ? invalidValues + ',' +str  :str;
                }
            }
            if((invalidValues == null || invalidValues == '') && consumptionTypeToValueMap.containsKey(consumptionType)){
                isvalid = true; 
            }
            else{
                addValidationError(errorMsgs, jsonLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1026, 
                                   new Map<String,String>{'{{fieldValue}}' => consumptionTypeToValueMap.containsKey(consumptionType) ? invalidValues : consumptionValue});
                isvalid = false;
            }
        }
        return isValid;
    }
    
    /**
    * @description Method to return active/valid consumption values and removes invalid/inactive
    * @author Vrushabh | 11-08-2024 
    * @param consumptionValue 
    * @param consumptionType 
    * @return String (Valid Consumption Values) 
    **/
    private static String removeInvalidateConsumptionParameter(String consumptionValue, String consumptionType) {
        String validValues = '';
        if (!String.isBlank(consumptionValue)) {
            List<String> consumptionValueList = consumptionValue.split(', ');
            for (String str : consumptionValueList) {
                if (consumptionTypeToValueMap.containsKey(consumptionType) && consumptionTypeToValueMap.get(consumptionType).contains(str)) {
                    if(String.isNotBlank(validValues)){
                        validValues =   str + ',' + validValues ;
                    }else{
                        validValues = str;
                    }
                }
            }
        }
        return validValues;
    }    
    
    /**
* @description Method to validate Primary contact and salesRep update wrapper
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-20-2024 
* @param quoteWrapForContactupt 
* @param qErrorMsg 
* @return boolean 
**/
    public boolean validateQuoteContactDtlsWrapper(QuotesWrapperForContactDtlsUpt quoteWrapForContactupt,  QuoteErrorMsg qErrorMsg, Map<Id,SBQQ__Quote__C> quoteIdToRecordMap){
        List<Id> quoteAPIIds = new List<Id>();
        qErrorMsg.quoteErrors = new Map<String,ErrorMsg>();
        
        if(quoteWrapForContactupt.quoteId == null || String.isEmpty(quoteWrapForContactupt.quoteId.trim())){
            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
            isValid = false;
        }
        else if(quoteWrapForContactupt.quoteId.trim() instanceOf Id ){
            quoteAPIIds.add(quoteWrapForContactupt.quoteId.trim());
        }
        else{
            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
            isValid = false; 
        }
        
        if(quoteAPIIds.size() > 0){
            if(quoteWrapForContactupt.primaryContactEmail != null && !String.isEmpty(quoteWrapForContactupt.primaryContactEmail.trim()) && !validatePrimaryContact(quoteWrapForContactupt.quoteId, quoteWrapForContactupt.primaryContactEmail, qErrorMsg.quoteErrors)){
                isValid = false;
            }else if (quoteWrapForContactupt.primaryContactEmail == null || String.isEmpty(quoteWrapForContactupt.primaryContactEmail.trim())){
                addValidationError(qErrorMsg.quoteErrors, 'PrimaryContactEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1096, null);
                isValid = false;
            }
            
            String regex = Label.Pricing_Tender_QuoteLetterRecepient_Regex;
            List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();//TextFieldValueWrapper
            textFldValues.add(new TextFieldValueWrapper('Pricing_AdditionalRecipients__c',quoteWrapForContactupt.additionalQuoteLetterRecipients, 'additionalQuoteLetterRecipients', false));
            if(quoteWrapForContactupt.additionalQuoteLetterRecipients != null && !String.isEmpty(quoteWrapForContactupt.additionalQuoteLetterRecipients.trim()) && validTextFields(sObjQuoteFieldMap, textFldValues, qErrorMsg.quoteErrors)){
                if(!Pattern.matches(regex, quoteWrapForContactupt.additionalQuoteLetterRecipients.trim()) || quoteWrapForContactupt.additionalQuoteLetterRecipients.trim().contains('@intel.com') ){
                    addValidationError(qErrorMsg.quoteErrors, 'additionalQuoteLetterRecipients', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1076, null);
                    isValid = false;
                }
            }
            
            if(quoteWrapForContactupt.referenceRequestID != null && !String.isEmpty(quoteWrapForContactupt.referenceRequestID.trim())){
                textFldValues.add(new TextFieldValueWrapper('Pricing_Customer_Reference_Id__c',quoteWrapForContactupt.referenceRequestID, 'referenceRequestID', false)); 
                if(!validTextFields(sObjQuoteFieldMap, textFldValues, qErrorMsg.quoteErrors)){
                    isValid = false;
                }
            }
            
            if(quoteWrapForContactupt.secondaryContact != null && !String.isEmpty(quoteWrapForContactupt.secondaryContact.trim())){
                textFldValues.add(new TextFieldValueWrapper('Pricing_SecondaryContact_Nm__c',quoteWrapForContactupt.secondaryContact, 'secondaryContact', false)); 
                if(!validTextFields(sObjQuoteFieldMap, textFldValues, qErrorMsg.quoteErrors)){
                    isValid = false;
                }
            }
            
            if(quoteWrapForContactupt.intelSalesRepEmail != null && !String.isEmpty(quoteWrapForContactupt.intelSalesRepEmail.trim()))
            {
                
                if(quoteIdToRecordMap.get(quoteAPIIds[0]).Pricing_Intel_Account_Exec_Email_Txt__c != null){
                    List<Pricing_Quote_Team__c> quoteTeamMembersList = [Select Id,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Team_Member_Id__r.Name,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Id__c,Pricing_Role_Nm__c from Pricing_Quote_Team__c where Pricing_Quote_Id__c IN :quoteAPIIds];
                    for(Pricing_Quote_Team__c qtm : quoteTeamMembersList){ 
                        if(qtm.Pricing_Quote_Team_Member_Id__r.Email == quoteWrapForContactupt.intelSalesRepEmail && (qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_Account_Executive || qtm.Pricing_Role_Nm__c == Label.Pricing_Quote_Team_Role_ITS)){
                            addValidationError(qErrorMsg.quoteErrors, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1099, null);
                            isValid = false;
                        }
                    }
                }
                
                //update sales Rep only when no Ql's are in PIFR for that Quote.
                List<SBQQ__QuoteLine__c> quoteLineList = [select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c In :quoteAPIIds and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId];
                Boolean isQLPIFR = false;
                if(quoteLineList.size()> 0){
                    for(SBQQ__QuoteLine__c ql :quoteLineList){
                        if(ql.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview){
                            isQLPIFR = true;
                            break;
                        }
                    }
                }
                if(isQLPIFR){
                    addValidationError(qErrorMsg.quoteErrors, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1097, null);
                    isValid = false;
                }
                else if(!validateSalesRep(quoteWrapForContactupt.intelSalesRepEmail, qErrorMsg.quoteErrors, true)){
                    isValid = false;
                }
            }
        }
        return isValid;
    }
    
    /*************************** validate WON/LOST QLI Starts Here **********************************/
    public static boolean validateWonLostQuotelineWrapper(QLICRWonLostWrapper quoteLineWrapper, QuoteErrorMsg qErrorMsg, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap){
        qErrorMsg.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>();
        Set<Id> quotelineIdSet = new Set<Id>();
        for(QLICRWonLost qline: quoteLineWrapper.quoteLines){
            if(qline.quotelineId != null && !String.isEmpty(qline.quotelineId.trim()) && qline.quotelineId.trim() instanceOf Id ){
                quotelineIdSet.add(qline.quotelineId.trim());
            }
        }
        Map<Id, SBQQ__QuoteLine__c> quotelineRecMap = new Map<Id, SBQQ__QuoteLine__c>([Select Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,
                                                                                       SBQQ__Product__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,
                                                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c from SBQQ__QuoteLine__c where Id IN :quotelineIdSet 
                                                                                       AND SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId]);
        List<SBQQ__QuoteLine__c> hasCR = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c
                                          where Pricing_Reference_Quote_Line_Nbr__c IN : quotelineIdSet and Pricing_Status_Nm__c != 'Rejected' and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId
                                         ];
        Map<Id, String> qlIdMsgMap = Pricing_QuoteLineController.isNotUnifiedQuoteLineBulk(quotelineIdSet);
        Set<Id> hasCRSet = new Set<Id>();
        for(SBQQ__QuoteLine__c qli: hasCR){
            hasCRSet.add(qli.Pricing_Reference_Quote_Line_Nbr__c);
        }    
        for(QLICRWonLost qline: quoteLineWrapper.quoteLines){
            validateWonLostQuoteline(qline, qErrorMsg.quoteLineErrorMsgs,quotelineRecMap,hasCRSet,sObjQuoteLineFieldMap,qlIdMsgMap);
        }
        return true;
    }
    
    public static void validateWonLostQuoteline(QLICRWonLost quoteLine, List<QuoteLineErrorMsg> qlErrorMsg, Map<Id, SBQQ__QuoteLine__c> quotelineRecMap,Set<Id> hasCRSet,Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id, String> qlIdMsgMap){
        QuoteLineErrorMsg qle = new QuoteLineErrorMsg();
        qle.quoteLineErrors = new Map<String,ErrorMsg>();     
        qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
        try{
            if(quoteLine.quotelineId == null || String.isEmpty(quoteLine.quotelineId.trim())){
                addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null);
            }
            
            if(hasCRSet!=null && hasCRSet.size()>0 && hasCRSet.contains(quoteLine.quotelineId.trim())){
                addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1049, null);
            }
            else{
                if(quotelineRecMap.keySet().contains(quoteLine.quotelineId.trim())){
                    //check the status of quoteline
                    String quotelineStatus = quoteLine.status;
                    if(quotelineStatus == null || String.isEmpty(quotelineStatus.trim())){
                        addValidationError(qle.quoteLineErrors, 'status', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, new Map<String, String>{'This value' => 'Status'});
                    }else if(quotelineStatus.trim().toLowerCase() != 'won' && quotelineStatus.trim().toLowerCase() != 'lost'){
                        addValidationError(qle.quoteLineErrors, 'status', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1027, new Map<String, String>{'Id: {{ID}}' => 'Status'});
                    }        
                    //validate won lost comment
                    List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
                    textFldValues.add(new TextFieldValueWrapper('Pricing_Won_Lost_Comments_Txt__c',quoteLine.wonLostComments,'wonLostComments',quoteLine.lostReason == Label.Pricing_Lost_reason_other_value ? true : false));
                    validTextFields(sObjQuoteLineFieldMap, textFldValues, qle.quoteLineErrors);
                    if(!validatePicklistValues(sObjQuoteLineFieldMap,'Pricing_Lost_Reason_Nm__c',quoteLine.lostReason, false, qle.quoteLineErrors, 'lostReason')){
                        isValid=false;
                    }
                    if(quotelineStatus.trim().toLowerCase() == 'won' && !String.isBlank(quoteLine.lostReason)){
                        addValidationError(qle.quoteLineErrors, 'lostReason', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1087, null);
                    }
                    //to check that quoteline should be in approved status 
                    if(quotelineRecMap.size()>0){
                        if(quotelineRecMap.get(quoteLine.quotelineId.trim()).Pricing_Status_Nm__c != 'Approved'){
                            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1048, null);
                        }else if (qlIdMsgMap.containsKey(quoteLine.quotelineId.trim()) && quotelineStatus.trim().toLowerCase() == 'won')  { // to check if the won is allowed 
                            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1067, new Map<String, String>{'{{wonErrorMessage}}' => qlIdMsgMap.get(quoteLine.quotelineId.trim())});
                        }
                    }
                }
                else{
                    addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
                }
            }
        }catch(Exception ex){
            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
        }
        if(qle.quoteLineErrors.size() > 0){
            qlErrorMsg.add(qle);
        }else{
            Pricing_RestAPI_QuotelinesV2.statusChangeQuotelines.add(quoteLine);
        }
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Quote Comments Starts Here **********************************/
    public boolean validateQuoteCommentsWrapper(QuoteCommentWrapperDetails quoteCommentWrapper, QuoteErrorMsg quoteErrors){
        //this method validates the input quote comments JSON based on the existing quote comments records
        quoteErrors.quoteErrors = new Map<String, ErrorMsg>();
        Map<String,Pricing_Comments__c> commsMap = new Map<String,Pricing_Comments__c>();
        if(!String.isEmpty(quoteCommentWrapper.quoteId)){
            quoteErrors.quoteCommentsErrors = new Map<String, ErrorMsg>();
            //get quote and respective quote comment details Pricing_Comment_Ref_Id__c
            List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__Status__c, SBQQ__Account__c,Pricing_Program_Type_Nm__c, (SELECT id,Pricing_Answer__c,Pricing_Comment_Ref_Id__c,Pricing_Question__c  FROM Comments__r) FROM SBQQ__Quote__c WHERE Id =:quoteCommentWrapper.quoteId and SBQQ__Account__c = :currentUser.AccountId];
            List<QuoteComment> commentList = quoteCommentWrapper.quoteComments;
            List<String> questionList = new List<String>();
            if(quoteList.size()>0){
                if(commentList.size()>0 ){
                    List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
                    
                    String quoteStatus = quoteList[0].SBQQ__Status__c;
                    qComms = quoteList[0].Comments__r;
                    for(Pricing_Comments__C qc : qComms){
                        commsMap.put(qc.Pricing_Comment_Ref_Id__c, qc);
                    }
                    if(quoteStatus != Label.Pricing_RestAPI_Status_Draft){		//update comments of only draft quote
                        addValidationError(quoteErrors.quoteCommentsErrors,'quoteStatus', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1033, 
                                           new Map<String,String>{'{{status}}' => String.valueOf(quoteStatus)});
                        isValid=false;
                    }
                    for(QuoteComment qc: commentList){  
                        if(qc.quoteCommentReferenceId!=null && !String.isEmpty(qc.quoteCommentReferenceId.trim())){
                            if(!questionList.contains(qc.quoteCommentReferenceId)){
                                if(!commsMap.containsKey(qc.quoteCommentReferenceId)){		//check if quote comment is already existing or not
                                    addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1044, null);
                                    isValid=false;
                                }else {
                                    if(!commsMap.get(qc.quoteCommentReferenceId).Pricing_Question__c.contains(Label.Pricing_Tender_Comments_NoMinLengthQuest)){             //if question does not contain "incumbent" the anwer text length should be >=10     
                                        if(qc.answer != null && !String.isEmpty(qc.answer.trim())){
                                            textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',qc.answer, qc.quoteCommentReferenceId, true));
                                            if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors.quoteCommentsErrors)){
                                                isValid = false;
                                            } 
                                            boolean isTextLenValid = (qc.answer.trim().length() < 10) ? false : true;                              
                                            if(!isTextLenValid){// && quoteList[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote){
                                                isValid=false;
                                                addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1018, null);
                                            }    
                                        }else if(quoteList[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote){
                                            isValid = false;
                                            addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                                        }
                                    }else{
                                        textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',qc.answer, qc.quoteCommentReferenceId,quoteList[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote?true:false));
                                        
                                    }                        
                                    if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors.quoteCommentsErrors)){
                                        isValid = false;
                                    }
                                }
                            }else{
                                isValid=false;
                                addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1046, new Map<String,String>{'{{REFID}}' => qc.quoteCommentReferenceId});
                            }
                        }else{
                            isValid=false;
                            addValidationError(quoteErrors.quoteCommentsErrors, 'quoteCommentReferenceId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1010, new Map<String, String>{'{{PRODUCT}}' => 'quoteCommentReferenceId'});
                        }
                        questionList.add(qc.quoteCommentReferenceId);                    
                    }
                }else{
                    addValidationError(quoteErrors.quoteCommentsErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1030, null);
                    isValid = false;
                }
            }
            else{
                addValidationError(quoteErrors.quoteErrors, 'quoteId ', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                isValid = false;
            }
            
            if(quoteErrors.quoteCommentsErrors.size() == 0){
                quoteErrors.quoteCommentsErrors = null;
            }
        }else{
            addValidationError(quoteErrors.quoteErrors, 'quoteId ', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
            isValid = false;
        }
        if(quoteErrors.quoteErrors.size() == 0){
            quoteErrors.quoteErrors = null;
        }
        return isValid;
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Performnce Metrics Starts Here **********************************/
    public boolean validatePerformanceMetricsWrapper(PerformanceMetricsWrapperDetails performanceMetricWrapper, QuoteErrorMsg quoteErrors){
        //this is called from performance metrics API. Validates performance metrics of a quoteline
        quoteErrors.quoteLineErrorMsgs = new List<QuoteLineErrorMsg>(); 
        Set<String> perfMetricsIds = new Set<String>();        
        QuoteLineErrorMsg qlErrors = new QuoteLineErrorMsg();
        qlErrors.perfMetricsErrorMsgs = new List<PerformanceMetricsErrorMsg>();
        qlErrors.quoteLineErrors = new Map<String,ErrorMsg>();
        if(!String.isEmpty(performanceMetricWrapper.quoteLineId)){
            List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name,Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c, (SELECT id FROM Performance_Metrics__r) from SBQQ__QuoteLine__c where Id =:performanceMetricWrapper.quoteLineId and SBQQ__Quote__r.SBQQ__Account__c = :currentUser.AccountId];
            List<PerformanceMetrics> performanceMetricsList=performanceMetricWrapper.performanceMetrics;
            
            if(quoteLineList.size()>0){
                String quoteLineStatus = quoteLineList[0].Pricing_Status_Nm__c;
                if(quoteLineStatus!= Label.Pricing_RestAPI_Status_Draft){
                    addValidationError(qlErrors.quoteLineErrors,'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1034, 
                                       new Map<String,String>{'{{status}}' => String.valueOf(quoteLineStatus)});
                    isValid=false;
                }
                for(Pricing_Performance_Metric__c pm : quoteLineList[0].Performance_Metrics__r){
                    perfMetricsIds.add(String.valueOf(pm.Id));
                }                
                for(PerformanceMetrics pm : performanceMetricsList){
                    PerformanceMetricsErrorMsg perErrMsg = new PerformanceMetricsErrorMsg();
                    perErrMsg.performanceMetricsReferenceId = pm.performanceMetricsReferenceId;                   
                    validatePerformanceMetrics(pm, perErrMsg, perfMetricsIds);
                    if(perErrMsg.perfMetricsErrors != null){
                        qlErrors.perfMetricsErrorMsgs.add(perErrMsg);
                    }
                }
            }else{                
                addValidationError(qlErrors.quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);    
                isValid = false;
            }
        }else{
            addValidationError(qlErrors.quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null);
            isValid = false;
        }
        if(qlErrors.quoteLineErrors.size()==0){
            qlErrors.quoteLineErrors = null;
        }
        quoteErrors.quoteLineErrorMsgs.add(qlErrors);
        return isValid;  
    }
    
    /******************************Validate Change Request Fields*************************************/
    public void validateChangeReqQuoteline(QLICRWonLost quoteline, List<QuoteLineErrorMsg> qlErrorMsg, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id,SBQQ__QuoteLine__c> quotelineMap,Map<Id,String> hasCRMap){
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        QuoteLineErrorMsg qle = new QuoteLineErrorMsg();
        qle.quoteLineErrors = new Map<String,ErrorMsg>();
        String newRequestedType = 'New Requested Price';
        qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
        quoteline.consumptionPlatform = String.isBlank(quoteline.consumptionPlatform) ? null : quoteline.consumptionPlatform;
        quoteline.consumptionCountry = String.isBlank(quoteline.consumptionCountry) ? null : quoteline.consumptionCountry;
        quoteline.consumptionSalesGeo = String.isBlank(quoteline.consumptionSalesGeo) ? null : quoteline.consumptionSalesGeo;
        quoteline.consumptionRegion = String.isBlank(quoteline.consumptionRegion) ? null : quoteline.consumptionRegion;
        quoteline.consumptionSegment = String.isBlank(quoteline.consumptionSegment) ? null : quoteline.consumptionSegment;
        quoteline.additionalComment = String.isBlank(quoteline.additionalComment) ? null : quoteline.additionalComment;
        try{
            if(quoteLine.quotelineId != null && !String.isEmpty(quoteLine.quotelineId.trim()) && (quoteLine.quotelineId.trim() instanceOf Id)){
                if(quotelineMap.get(quoteline.quotelineId).SBQQ__Quote__c != quoteId){
                    addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1074, null);
                }
                else{
                    if(quotelineMap.get(quoteline.quotelineId).Pricing_Status_Nm__c != 'Won' && quotelineMap.get(quoteline.quotelineId).Pricing_Status_Nm__c != 'Approved'){
                        addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1048, new Map<String, String>{'Approved' => 'Approved or Won'});
                    }
                    else{                        
                        if(hasCRMap !=null && hasCRMap.size()>0 && hasCRMap.containsKey(quoteLine.quotelineId.trim())){
                            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1063,new Map<String,String>{'value'=>hasCRMap.get(quoteLine.quotelineId.trim())});
                        }
                        else{
                            Integer noOfDays = quotelineMap.get(quoteline.quotelineId).Pricing_Approved_End_Date_Dt__c.daysBetween(System.today());
                            if (noOfDays > 91){
                                addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1062, null);
                            }
                            else{
                                if(quoteline.newQuantity == null){
                                    addValidationError(qle.quoteLineErrors, 'newQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                                }
                                else{
                                    List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
                                    numFldValues.add(new NumberFieldValueWrapper('Pricing_New_Quantity_qty__c',quoteline.newQuantity, 'newQuantity', true));
                                    validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, qle.quoteLineErrors);
                                }
                                validatedCRRequestedPrice(quoteline.quotelineId,quoteline.newRequestedPrice,'newRequestedPrice',sObjQuoteLineFieldMap,quotelineMap,qle.quoteLineErrors);
                                
                                if (validateBidPricingDates(quoteline.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qle.quoteLineErrors)){
                                    if(date.parse(quoteline.quoteLinePricingEndDate) < quotelineMap.get(quoteline.quotelineId).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c){
                                        addValidationError(qle.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                                    }
                                    
                                    if ((quoteline.newRequestedPrice == quotelineMap.get(quoteline.quotelineId).Pricing_ECAP_Price_Amt__c) 
                                        && quoteline.newQuantity == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Unit_Qty__c
                                        && quoteline.consumptionPlatform == quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Platform__c
                                        && quoteline.consumptionSalesGeo == quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Sale_Geo__c
                                        && quoteline.consumptionCountry == quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Country__c
                                        && quoteline.consumptionRegion == quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Region__c
                                        && quoteline.consumptionSegment == quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Segment__c
                                        && date.parse(quoteline.quoteLinePricingEndDate) == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_End_Date_Dt__c
                                        && (String.isEmpty(quoteline.quoteLinePricingStartDate) || (String.isNotEmpty(quoteline.quoteLinePricingStartDate) && date.parse(quoteline.quoteLinePricingStartDate) == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Start_Date_Dt__c))){
                                            addValidationError(qle.quoteLineErrors, 'newRequestedPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => 'New Requested Price'});
                                            addValidationError(qle.quoteLineErrors, 'newQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            // Consumption error added.
                                            addValidationError(qle.quoteLineErrors, 'consumptionPlatform', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            addValidationError(qle.quoteLineErrors, 'consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            addValidationError(qle.quoteLineErrors, 'consumptionCountry', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            addValidationError(qle.quoteLineErrors, 'consumptionRegion', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            addValidationError(qle.quoteLineErrors, 'consumptionSegment', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});

                                            if(String.isNotEmpty(quoteline.quoteLinePricingStartDate)){
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, new Map<String, String>{'{{newRequestedType}}' => newRequestedType});
                                            }
                                        }
                                }
                                
                                //  Consumption inactive check 
                                setActiveConsumptionMap(currentUser);
                                validateConsumptionParameter(quoteline.consumptionPlatform, 'Consumption Platform', qle.quoteLineErrors, 'consumptionPlatform');
                                validateConsumptionParameter(quoteline.consumptionSalesGeo, 'Consumption Sales Geo', qle.quoteLineErrors, 'consumptionSalesGeo');
                                validateConsumptionParameter(quoteline.consumptionSegment, 'Consumption Segment', qle.quoteLineErrors, 'consumptionSegment');
                                
                                //to check that consumptionSalesGeo,consumptionCountry,consumptionRegion all 3 together should not be given.
                                if(!String.isBlank(quoteline.consumptionSalesGeo) && ((!String.isBlank(quoteline.consumptionCountry) || !String.isBlank(quoteline.consumptionRegion)))){
                                    addValidationError(qle.quoteLineErrors,'consumptionCountry,consumptionRegion,consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1092, null);
                                }
                                //TWC1972-7314 : Lock down deletion of parameters once the deal is WON
                                // validation for locking 
                                if(quotelineMap.get(quoteline.quotelineId).Pricing_Status_Nm__c == 'Won'){
                                    // remove invalid consumption values
                                    quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Platform__c = removeInvalidateConsumptionParameter(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Platform__c, 'Consumption Platform');
                                    quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Sale_Geo__c = removeInvalidateConsumptionParameter(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Sale_Geo__c, 'Consumption Sales Geo');
                                    quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Segment__c = removeInvalidateConsumptionParameter(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Segment__c, 'Consumption Segment');
                                    
                                    if(!String.isBlank(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Sale_Geo__c) && validateConsumptionValuesForCR(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Sale_Geo__c,quoteline.consumptionSalesGeo)){
                                        addValidationError(qle.quoteLineErrors,'consumptionSalesGeo', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1098, new Map<String, String>{'{{consumptionFields}}' => 'Consumption Sales Geo'});
                                    }
                                    if(!String.isBlank(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Platform__c) && validateConsumptionValuesForCR(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Platform__c,quoteline.consumptionPlatform)){
                                        addValidationError(qle.quoteLineErrors,'consumptionPlatform', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1098, new Map<String, String>{'{{consumptionFields}}' => 'Consumption Platform'});
                                    }
                                    if(!String.isBlank(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Segment__c) && validateConsumptionValuesForCR(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Segment__c,quoteline.consumptionSegment)){
                                        addValidationError(qle.quoteLineErrors,'consumptionSegment', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1098, new Map<String, String>{'{{consumptionFields}}' => 'Consumption Segment'});
                                    }
                                    if(!String.isBlank(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Country__c) && validateConsumptionValuesForCR(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Country__c,quoteline.consumptionCountry)){
                                        addValidationError(qle.quoteLineErrors,'consumptionCountry', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1098, new Map<String, String>{'{{consumptionFields}}' => 'Consumption Country'});
                                    }
                                    if(!String.isBlank(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Region__c) && validateConsumptionValuesForCR(quotelineMap.get(quoteline.quotelineId).Pricing_Consumption_Region__c,quoteline.consumptionRegion)){
                                        addValidationError(qle.quoteLineErrors,'consumptionRegion', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1098, new Map<String, String>{'{{consumptionFields}}' => 'Consumption Region'});
                                    }
                                }
                                
                                // TWC1972-4068 [API]: Add New Quote Line Pricing Start Date in GET and Change request API
                                
                                if(String.isNotBlank(quoteline.quoteLinePricingStartDate)){
                                    if(validateDateFormat(quoteline.quoteLinePricingStartDate,false,'quoteLinePricingStartDate', qle.quoteLineErrors)){
                                        
                                        if(quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Start_Date_Dt__c < System.today()  && date.parse(quoteline.quoteLinePricingStartDate) != quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Start_Date_Dt__c){
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1089, null);
                                        }
                                        if(date.parse(quoteline.quoteLinePricingStartDate) < System.today() && !(quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Start_Date_Dt__c < System.today())){
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1091, null);
                                        }                                        
                                        if(date.parse(quoteline.quoteLinePricingStartDate) > date.parse(quoteline.quoteLinePricingEndDate)){
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1090, null);
                                        }
                                    }                                            
                                }                                    
                                
                                List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
                                textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteline.additionalComment, 'additionalComments', false));
                                validTextFields(sObjQuoteLineFieldMap, textFldValues, qle.quoteLineErrors);
                            }
                        }
                    }
                }
                if(qle.quoteLineErrors.size() != 0){
                    qlErrorMsg.add(qle);
                    //return false;
                }                
            }    //return true;
        }catch(Exception ex){
            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
            qlErrorMsg.add(qle);
            //return false;
        }        
    }
    
    /**
* @description Method to validate consumption value for change request TWC1972-7314 : Lock down deletion of parameters once the deal is WON
* @author Vrushabh | 11-08-2024 
* @param oldValuesString 
* @param newValuesString 
* @return boolean 
**/
    public static Boolean validateConsumptionValuesForCR(String oldValuesString, String newValuesString) {
        try{
            Boolean result;
            if (String.isBlank(newValuesString)) {
                return true; // Return true if either string is null or empty
            }
            List<String> oldValues = oldValuesString.split(',');
            List<String> newValues = newValuesString.split(',');
            // Check if each old value exists in the new values list
            for (String oldValue : oldValues) {
                if(newValues.contains(oldValue)) {
                    result = false;
                }else{
                    result = true;
                    break;
                }
            }
            return result; // Return false if all old values are present
        }catch(Exception ex){
            return true;
        }        
    }
    
    //Method to validate newRequestedPrice during Change Request
    public void validatedCRRequestedPrice(Id quotelineId, Decimal fieldValue,String fieldName, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id,SBQQ__QuoteLine__c> quotelineMap,Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> quoteLineErrors){
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        if (quotelineMap.get(quotelineId).Pricing_Approved_End_Date_Dt__c<System.today() && fieldValue != null)
        {
            addValidationError(quoteLineErrors, fieldName, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1060, new Map<String, String>{'{{newRequestedType}}' => 'New Requested Price'});
        }
        else{
            
            if (fieldValue == null && quotelineMap.get(quotelineId).Pricing_Approved_End_Date_Dt__c>System.today()){
                addValidationError(quoteLineErrors, fieldName, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            }  
            else if (fieldValue != null){
                List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
                currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Request_Discount_Unit_Price_qty__c',fieldValue, fieldName,  true, false));
                validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, quoteLineErrors);
            }
        }
    }
    
    // method will return active consumption param for user Account
    public void setActiveConsumptionMap(User currentUser){
        
        for(Pricing_ConsumptionAccountMapping__c rec : [SELECT Id,Name,Pricing_Active_ind__c, Pricing_Consumption_Type_Nm__c,Pricing_Account_Nm__r.Name 
                                                        FROM Pricing_ConsumptionAccountMapping__c 
                                                        WHERE Pricing_Account_Nm__c =: currentUser.AccountId AND Pricing_Active_ind__c = true]){
                                                            if(consumptionTypeToValueMap.containsKey(rec.Pricing_Consumption_Type_Nm__c)){
                                                                consumptionTypeToValueMap.get(rec.Pricing_Consumption_Type_Nm__c).add(rec.Name);
                                                            } else{
                                                                consumptionTypeToValueMap.put(rec.Pricing_Consumption_Type_Nm__c,new List<String>{rec.Name});
                                                            }
                                                        }
    }    
    /***********************************************************************************************/
    
    /*************************** Wrapper classes starts here **********************************/
    global class QuoteWrapper {
        public QuoteDetails quoteDetails {set; get;}
        public String quoteId {set;get;}
    }
    
    public class QuoteDetails {
        public String referenceRequestID {set;get;}
        public String projectName {set;get;}
        public String pricingStartDate {set;get;}
        public String pricingEndDate {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String intelAccountExecutiveEmail {set;get;}
        public String industryTechnicalSpecialistEmail {set;get;}
        public String primaryContactEmail {set; get;}
        public String endCustomerCountry {set;get;}
        public String endCustomer {set;get;}
        public String unifiedEndCustomerId {set;get;}
        public String proposalDueDate {set;get;}
        public String intelResponseRequestedDate {set;get;}
        public String application {set;get;}
        public String marketSegment {set;get;}
        public String secondaryContact {set;get;}
        public String partnerName {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public QuoteLines quoteLines {set;get;}
        public List<QuoteComment> quoteComments {set;get;}
        public String endCustomerUrl {set;get;}
    }
    
    public class QuoteLineWrapper {
        public String quoteId {set;get;}
        public QuoteLines quoteLines {set;get;}
    }
    
    public class QuoteLines {
        public List<QuoteLineCPU> DataCenterCPU {set;get;}
        public List<QuoteLineClient> Client {set;get;}
        public List<QuoteLineSSD> OptaneSSD {set;get;}
        public List<QuoteLinePMem> OptanePMem {set;get;}
        public List<QuoteLineEthernet> Ethernet {set;get;}
        public List<QuoteLineGPU> DataCenterGPU {set;get;}
        
    }
    
    public class QuoteLineCPU {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}
        public String productId {set;get;}
        public String quoteLinePricingStartDate {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public Decimal singleSystemPricePoint {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public Decimal additionalDiscount {set;get;}
        public String competitorName {set;get;}
        public String competitorSystemModel {set;get;}
        public String competitorProductId {set;get;}
        public String competitorWriteInProduct {set;get;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfCPUsPerSystem {set;get;}
        public Decimal competitorSingleSystemPrice {set;get;}
        public Decimal competitorAdditionalDiscount {set;get;}
        public String additionalComment {set;get;}
        public List<PerformanceMetrics> performanceMetrics {set;get;}
        public String unifiedEndCustomer {set;get;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
    }
    
    public class QuoteLineClient {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal quantity {set;get;}
        public Decimal singleSystemPricePoint {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public String formFactor {set;get;}
        public String competitorName {set;get;}
        public String competitorSystemModel {set;get;}
        public String competitorProductId {set;get;}
        public String competitorWriteInProduct {set;get;}
        public Decimal competitorSingleSystemPricePoint {set;get;}
        public String additionalComment {set;get;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
    }
    
    public class QuoteLineSSD {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public String competitorName {set;get;}
        public String competitorProduct {set;get;}
        public Decimal competitorSingleSystemPricePoint {set;get;}
        public Decimal competitorDensity {set;get;}
        public String volumeByQuarterAndReasoning {set;get;}
        public Decimal quantity {set;get;}
        public String additionalComment {set;get;} 
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}  
        public String consumptionSegment {get;set;}     
    }
    
    public class QuoteLinePMem {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}//defines the qli type.
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfUnitsPerSystem {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public String pairedCPU {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public Integer dramDensity {set;get;}
        public Integer noOfDRAMPerSystem {set;get;}
        public String competitorName {set;get;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfUnitsPerSystem {set;get;}
        public Decimal competitorSingleSystemPricePoint {set;get;}
        public String additionalComment {set;get;}
        public Integer competitorDensity {set;get;}
        public String serverIntegration {set;get;}
        public String workload {set;get;}
        public String pocTestingResults {set;get;} 
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
    }
    
    public class QuoteLineEthernet {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public Decimal quantity {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public String competitorProduct {set;get;}
        public Integer competitorQuantity {set;get;}
        public Decimal competitorSingleSystemPricePoint {set;get;}
        public String additionalComment {set;get;}  
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}      
    }
    
    public class QuoteLineGPU {
        public String quotelineId {set;get;}
        public String quoteLineType {set;get;}
        public String productId {set;get;}
        public String quoteLinePricingStartDate {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public String writeInPairedCPU {set;get;}
        public Decimal noOfGPUs {set;get;}
        public Decimal noOfGPUsPerSystem {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public Decimal singleSystemPricePoint {set;get;}
        public String pairedCPUId {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedUnitPrice {set;get;}
        public Decimal additionalDiscount {set;get;}
        public String competitorName {set;get;}
        public String competitorSystemModel {set;get;}
        public String competitorProductId {set;get;}
        public String competitorWriteInProduct {set;get;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfUnitsPerSystem {set;get;}
        public Decimal competitorNoOfGPUsPerSystem {set;get;}
        public Decimal competitorSingleSystemPrice {set;get;}
        public Decimal competitorAdditionalDiscount {set;get;}
        public String additionalComment {set;get;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
    }    
    
    public class QLICRWonLostWrapper {
        public String quoteId {set;get;}
        public List<QLICRWonLost> quoteLines {set;get;}
    }
    
    public class QLICRWonLost {
        public String quotelineReferenceID {set;get;}
        //won/lost wrapper
        public String quotelineId {set;get;}
        public String status {set;get;}
        public String wonLostComments {set;get;}
        public String lostReason {set;get;}
        //change request wrapper
        public String quoteLinePricingEndDate {set;get;}
        public String quoteLinePricingStartDate {set;get;}
        public Decimal newRequestedPrice {set;get;}
        public Decimal newQuantity {set;get;}
        public String additionalComment {set;get;}
        // Consumption
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        
    }
    
    public class PerformanceMetricsWrapperDetails {
        public String quoteLineId {set;get;}
        public List<PerformanceMetrics> performanceMetrics {set;get;}
    }
    
    public class QuoteCommentWrapperDetails {
        public String quoteId {set;get;}
        public List<QuoteComment> quoteComments {set;get;}
    }
    
    public class PerformanceMetrics {
        public String performanceMetricsId {set;get;}
        public String performanceMetricsUsed {set;get;}
        public Decimal weighting {set;get;}
        public Decimal intelScore {set;get;}
        public Decimal compScore {set;get;}
        public String otherText {set;get;}
        public String performanceMetricsReferenceId {set;get;}
    }
    
    public class QuoteComment {        
        public String quoteCommentReferenceId {set;get;}
        public String answer {set;get;}           
    } 
    
    public class TextFieldValueWrapper {
        public String fldName {set;get;}
        public String fldValue {set;get;}
        public String fldLabel {set;get;}
        public boolean isMandatory {set;get;}
        public TextFieldValueWrapper(String name, String val, boolean isMandatry){
            fldName = name;
            fldValue = val;
            isMandatory = isMandatry;
        }
        public TextFieldValueWrapper(String name, String val,String label, boolean isMandatry){
            fldName = name;
            fldValue = val;
            isMandatory = isMandatry;
            fldLabel = label;
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
    
    public class ErrorMsg {
        public Integer errorCode {set;get;} 
        public String errorMsg  {set;get;} 
        public ErrorMsg(Integer code, String Msg){
            errorCode = code;
            errorMsg = Msg;
        }
    }
    
    global class QuoteErrorMsg implements Pricing_RestAPI_QuoteValidationErrors{
        public Map<String,ErrorMsg> quoteErrors {set;get;}   
        public List<QuoteLineErrorMsg> quoteLineErrorMsgs {set; get;}
        public Map<String,ErrorMsg> quoteCommentsErrors {set; get;}
    }
    
    global class QuoteLineErrorMsg {
        public String quotelineReferenceID {set;get;} 
        public Map<String,ErrorMsg> quoteLineErrors {set;get;}        
        public List<PerformanceMetricsErrorMsg> perfMetricsErrorMsgs {set;get;}         
    }
    
    global class PerformanceMetricsErrorMsg {
        public String performanceMetricsReferenceId {set;get;}
        public Map<String,ErrorMsg> perfMetricsErrors {set;get;}
    }
    
    public class MyPickListInfo {
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public MyPickListInfo(){ 
        }
    }
    
    //Request Wrapper for updating Contact and salesRep Details on Quote
    public class QuotesWrapperForContactDtlsUpt {
        public String quoteId {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String primaryContactEmail {set; get;}
        public String secondaryContact {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public String referenceRequestID {set;get;}
    }
    /***********************************************************************************************/
}