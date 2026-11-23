/**
* @description       : Class containing all the validation related to Ver>1 API
* @author            : Accenture
* @group             : Gravity
* @last modified on  : 02-09-2024
* @last modified by  : Bharath Chandrashekar
**/
global without sharing class Pricing_RestAPI_QuotesUtility {
    
    public Map<String,Schema.SObjectField> sObjQuoteLineFieldMap;
    public Map<String,Schema.SObjectField> sObjQuoteFieldMap;
    public Map<String,Schema.SObjectField> sObjPerformanceMatrixFieldMap;
    public Map<String,Schema.SObjectField> SObjectCommentsMap;
    public static Map<Id, Product2> productIdMap = new Map<Id, Product2>();
    public static Map<Id, Pricing_Competitor_Product__c> compProductIdMap = new Map<Id, Pricing_Competitor_Product__c>();    
    public static Map<String, String> errorMap = new Map<String, String>();
    public static User currentUser = new User();
    public static boolean isValid = true;
    public static List<boolean> isValidQuotelineList = new List<boolean>();
    public Static Integer NUMBER_FIELD_MAX_LENGTH = 16;
    public static Integer TEXT_FIELD_MAX_LENGTH = 100;
    public Static Map<Decimal, String> errorMsgMap = new Map<Decimal, String>();
    public static List<Pricing_Comments__c> qComms = new List<Pricing_Comments__c>();
    public static Set<String> jsonRecIds = new Set<String>();
    public static Map<String,Id> validFSEEmailIdMap = new Map<String,Id>();
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
    public static String crQLINo = '';
    public static Map<Id, SBQQ__QuoteLine__c> patchQuotelineMap;
    public static Map<String, List<Pricing_Quote_Team__c>> createNewQTMMap = new Map<String, List<Pricing_Quote_Team__c>>();
    public static String writeInUnifiedId = '';
    public static Decimal overallQuantity = 0;
    public static Boolean calledFromQuote = false;
    public static List<String> qtmUserEmailsList = new List<String>();
    public static String assignedRecordTypeId = '';
    public static String quoteLineSVDCreateRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Create);
    
    //Added as per US871923
    public static boolean isValidAE = true;
    
    //Added as per US936155
    public static String currentUserAccountId = '';
    
    /**
* @description Constructor to assign default variables
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
**/
    public Pricing_RestAPI_QuotesUtility(){
        sObjQuoteLineFieldMap = Schema.sObjectType.SBQQ__QuoteLine__c.fields.getMap();
        sObjQuoteFieldMap = Schema.sObjectType.SBQQ__Quote__c.fields.getMap();
        sObjPerformanceMatrixFieldMap = Schema.sObjectType.Pricing_Performance_Metric__c.fields.getMap();
        SObjectCommentsMap=Schema.SObjectType.Pricing_Comments__c.fields.getMap();
        currentUser = [SELECT id,Name,AccountId,ContactId,Email FROM User WHERE id= :UserInfo.getUserId()];
        List<Pricing_Rest_API_Validation_Error_Msgs__mdt> errorMdts  = [SELECT Error_Code__c,Error_Message__c FROM Pricing_Rest_API_Validation_Error_Msgs__mdt];
        for(Pricing_Rest_API_Validation_Error_Msgs__mdt errMdt : errorMdts){
            errorMsgMap.put( ((Integer) errMdt.Error_Code__c), errMdt.Error_Message__c);
        }
        currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
        quoteTeamRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Quote_Team__c',Label.Pricing_Tender_Quote_Team_RecordType);
        quoteCreateRecordTypeId = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='SBQQ__Quote__c' and DeveloperName = 'Pricing_Tender_Quote_Create' limit 1].Id;
        quoteLineCreateRecordTypeId = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='SBQQ__QuoteLine__c' and DeveloperName = 'Pricing_Tender_Quote_Line_Create' limit 1].Id;
        writeInUnifiedId = [Select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Name = :Label.Pricing_IQR_API_WriteInEndCustomer limit 1].Id;
    }
    
    /*************************** validate Quote details **********************************/
    //this method validates only quote details is isSubmit is false otherwise validates quotelines of respective quote
    public boolean validateQuote(Pricing_RestAPI_QuotesUtilityV2.QuoteWrapperDCAI quoteWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteMsgs, boolean isSubmit){
        quoteMsgs.quoteErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        Pricing_RestAPI_QuotesUtilityV2.QuoteDetailsDCAI quoteDetails = quoteWrapper.quoteDetails;
        List<String> aeEmailList = new List<String>();
        List<String> fseEmailList = new List<String>();
        List<String> itsEmailList = new List<String>();
        boolean duplicateEmail = false;
        if(Pricing_RestAPI_Quotes.isSvdQuote && !Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed(currentUser.AccountId)){
            addValidationError(quoteMsgs.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1072, null);
            isValid=false;
        }
        else{
            if(Pricing_RestAPI_Quotes.isSvdQuote && Pricing_Manage_Small_Volume_Deal.capSizeCheck(currentUser.AccountId).split(':')[0] == 'false'){
                addValidationError(quoteMsgs.quoteErrors, 'svdCapSize', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1070, new Map<String,String>{'{value}'=>String.ValueOf(Integer.valueOf(Pricing_Manage_Small_Volume_Deal.capSizeCheck(currentUser.AccountId).split(':')[1]))});
                isValid=false;
            }
            else{
                if((quoteDetails.intelSalesRepEmail!=null && !String.isBlank(quoteDetails.intelSalesRepEmail.trim())) ||
                   (quoteDetails.intelAccountExecutiveEmail!=null && !String.isBlank(quoteDetails.intelAccountExecutiveEmail.trim())) || 
                   (quoteDetails.industryTechnicalSpecialistEmail!=null && !String.isBlank(quoteDetails.industryTechnicalSpecialistEmail.trim()))){
                       
                       if(quoteDetails.intelSalesRepEmail!=null && quoteDetails.intelSalesRepEmail.trim() != ''){
                           for(String email: quoteDetails.intelSalesRepEmail.split(',')){
                               if(email.trim().length() > 0){
                                   fseEmailList.add(email.trim());
                               }
                           }
                       }
                       if(quoteDetails.intelAccountExecutiveEmail!=null && quoteDetails.intelAccountExecutiveEmail.trim() != ''){
                           
                           for(String email: quoteDetails.intelAccountExecutiveEmail.split(',')){
                               if(fseEmailList.contains(email.trim())){
                                   duplicateEmail = true;
                                   break;
                               }
                               if(email.trim().length() > 0){
                                   aeEmailList.add(email.trim());
                               }
                           }
                       }
                       if(!duplicateEmail && quoteDetails.industryTechnicalSpecialistEmail!=null && quoteDetails.industryTechnicalSpecialistEmail.trim() != ''){
                           for(String email: quoteDetails.industryTechnicalSpecialistEmail.split(',')){
                               if(fseEmailList.contains(email.trim()) || aeEmailList.contains(email.trim())){
                                   duplicateEmail = true;
                                   break;
                               }
                               if(email.trim().length() > 0){
                                   itsEmailList.add(email.trim());
                               }
                           }
                       }
                   }
                List<SBQQ__Quote__c> quote = new List<SBQQ__Quote__c>();
                if(isUpdateDraftQuote || Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                    quote = [Select Id, SBQQ__Status__c,Pricing_Program_Type_Nm__c, (Select id, Pricing_Quote_Team_Member_Id__r.Email, Pricing_Role_Nm__c from Quote_Teams__r) from SBQQ__Quote__c where Id = :quoteWrapper.quoteId];
                    
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
                            Pricing_RestAPI_Quotes.isSvdQuote=true;
                        }
                    }else if(quoteWrapper.quoteId == null || String.isBlank(quoteWrapper.quoteId.trim())){
                        addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1008, null);
                        isValid = false;
                    }else{
                        addValidationError(quoteMsgs.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                        isValid = false;
                    }
                }
                if(Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                    
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
                                            if(quoteDetails.intelSalesRepEmail != null && !validateSalesRep(quoteDetails.intelSalesRepEmail, quoteMsgs.quoteErrors, (isSubmit && !isCreateDraftQuote))){
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
                    List<SBQQ__Quoteline__c> quotelineList = [select id, Pricing_End_Date_dt__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteWrapper.quoteId];
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
                if(!validatePicklistValues(sObjQuoteFieldMap,'Pricing_Server_Deal_Type_Nm__c',quoteDetails.application, true, quoteMsgs.quoteErrors, 'application')){
                    isValid=false;
                }        
                //validate End Customer Country
                if(!validatePicklistValues(sObjQuoteFieldMap,'Pricing_End_Customer_Country_Nm__c',quoteDetails.endCustomerCountry, true, quoteMsgs.quoteErrors, 'endCustomerCountry')){
                    isValid=false;
                }
                else{
                    Map<String, List<String>> countryRegionMap = getFieldDependencies('SBQQ__Quote__c', 'Pricing_End_Customer_Country_Nm__c', 'Pricing_Region_Nm__c'); 
                    String region = countryRegionMap.get(quoteDetails.endCustomerCountry)[0];
                    if(Label.Pricing_Tender_SVD_Restrict_Region.split(',').contains(region) && Pricing_RestAPI_Quotes.isSvdQuote){
                        addValidationError( quoteMsgs.quoteErrors, 'endCustomerRegion', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1068, null);
                        isValid = false;
                    }
                }
                
                //validate primary contact email
                if(quoteDetails.primaryContactEmail != null && !String.isEmpty(quoteDetails.primaryContactEmail.trim()) && !validatePrimaryContact(quoteDetails.primaryContactEmail, quoteDetails.primaryContactEmail, quoteMsgs.quoteErrors)){
                    isValid = false;
                }
                String regex = Label.Pricing_Tender_QuoteLetterRecepient_Regex;
                List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();//TextFieldValueWrapper
                textFldValues.add(new TextFieldValueWrapper('Pricing_AdditionalRecipients__c',quoteDetails.additionalQuoteLetterRecipients, 'additionalQuoteLetterRecipients', false));
                if(quoteDetails.additionalQuoteLetterRecipients != null && !String.isEmpty(quoteDetails.additionalQuoteLetterRecipients.trim()) && validTextFields(sObjQuoteFieldMap, textFldValues, quoteMsgs.quoteErrors)){
                    if(!Pattern.matches(regex, quoteDetails.additionalQuoteLetterRecipients.trim()) || quoteDetails.additionalQuoteLetterRecipients.trim().contains('@intel.com') ){
                        addValidationError( quoteMsgs.quoteErrors, 'additionalQuoteLetterRecipients', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1076, null);
                        isValid = false;
                    }
                }
                
                if(isSubmit){
                    //validate quotelines and quote comments if isSubmit is true(submit quote API-action=submit)
                    quoteMsgs.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();
                    calledFromQuote=true;
                    validateQuoteLines( quoteDetails.quoteLines, (isPricingStartDateValid ? Date.parse(quoteDetails.pricingStartDate) : null), quoteMsgs, isSubmit );
                    validateQuoteComments(quoteDetails.quoteComments, quoteMsgs,Pricing_RestAPI_Quotes.isResubmit?quoteWrapper.quoteId.trim():null);
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
    public static boolean validateQuoteTextFields(Pricing_RestAPI_QuotesUtilityV2.QuoteDetailsDCAI quoteDetails, Map<String,Schema.SObjectField> sObjQuoteFieldMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();//TextFieldValueWrapper
        textFldValues.add(new TextFieldValueWrapper('Pricing_Customer_Nm__c',quoteDetails.endCustomer, 'endCustomer', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Project_Name_Nm__c',quoteDetails.projectName, 'projectName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Customer_Reference_Id__c',quoteDetails.referenceRequestID, 'referenceRequestID',true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_SecondaryContact_Nm__c',quoteDetails.secondaryContact, 'secondaryContact',false));
        return validTextFields(sObjQuoteFieldMap, textFldValues, errorMsgs);        
    }  
    
    /**
* @description validating Applicatioin values for SVD quote
* @author Accenture | 05-24-2022 
* @param quoteDetails 
* @param errorMsgs 
**/
    public static void validateApplication(Pricing_RestAPI_QuotesUtilityV2.QuoteDetailsDCAI quoteDetails,Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        if(quoteDetails.application!=null && (quoteDetails.application!=Label.Pricing_Application_HPC && quoteDetails.application!=Label.Pricing_Application_Enterprise) && Pricing_RestAPI_Quotes.isSvdQuote){
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
    public static boolean validateBidPricingDates(String bidPricingDate, String fldLabel, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
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
    public static boolean validateEndCustomer(Pricing_RestAPI_QuotesUtilityV2.QuoteDetailsDCAI quoteDetails, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        boolean isValidEndCustomer = true;
        if(quoteDetails.endCustomer != null){
            if(quoteDetails.endCustomer.toLowerCase().equals('any')){
                addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1064, null); 
                isValidEndCustomer = false;
            }
            if(quoteDetails.unifiedEndCustomerId != null && quoteDetails.unifiedEndCustomerId.trim() != ''){
                if(quoteDetails.unifiedEndCustomerId.trim().equals(writeInUnifiedId)){
                    if(quoteDetails.endCustomer.trim() == ''){
                        addValidationError(errorMsgs, 'unifiedEndCustomerId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1065, null);
                        isValidEndCustomer = false;
                    }
                }else{                    
                    List<Pricing_UnifiedEndCustomerAccountMapping__c> endCustmr = [select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Id = :quoteDetails.unifiedEndCustomerId and Pricing_Account_Nm__c = :currentUserAccountId];
                    if(endCustmr.size() == 0){
                        addValidationError(errorMsgs, 'unifiedEndCustomerId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, new Map<String, String>{'Quote' => 'Unified End Customer'});
                        isValidEndCustomer = false;
                    }else if(!quoteDetails.unifiedEndCustomerId.trim().equals(writeInUnifiedId) && (quoteDetails.endCustomer != null && !(quoteDetails.endCustomer == ''))){
                        addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1066, null);
                        isValidEndCustomer = false;
                    }else{
                        writeInUnifiedId = endCustmr[0].Id;
                    }                    
                }
            }
        }
        if((quoteDetails.unifiedEndCustomerId == null || quoteDetails.unifiedEndCustomerId.trim() == '') && (quoteDetails.endCustomer == null || quoteDetails.endCustomer.trim() == '')){
            addValidationError(errorMsgs, 'endCustomer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            isValidEndCustomer = false;
        }
        if(!String.isEmpty(quoteDetails.unifiedEndCustomerId) && quoteDetails.unifiedEndCustomerId.trim().equals(writeInUnifiedId) && quoteDetails.endCustomer == null){
            addValidationError(errorMsgs, 'unifiedEndCustomerId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1065, null);
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
    public static boolean validateEmailIds(Set<String> emailids, String fldLabel, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
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
    public static boolean validateSalesRep(String salesRepEmail, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs, boolean isSubmit){
        boolean isSalesRepValid = true;
        //intelSalesRepEmail
        if(salesRepEmail == null && isCreateDraftQuote){
            return true;
        }
        if(isSubmit && (salesRepEmail == null || String.isEmpty(salesRepEmail.trim())) && !Pricing_RestAPI_Quotes.isCreateQuoteTeam){      //Sales Rep Email Id cant be blank is isSubmit=true
            addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1004, null);
            isSalesRepValid = false;
        }else if(salesRepEmail != null && !String.isEmpty(salesRepEmail.trim())){
            Set<String> oemEmailIds = new Set<String>(salesRepEmail.toLowerCase().split(','));
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
                            if(validFSEEmails.size()>0 && !Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                                primaryFSEEMail = String.isEmpty(primaryFSEEMail) ? emailid.toLowerCase() : primaryFSEEMail;
                            }
                            //break;
                        }
                    }
                    
                    if(validFSEEmails.size() == 0 && Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                        addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1057, new Map<String, String>{'{{USER}}' => salesRepEmail});
                        isSalesRepValid = false;
                    }
                    if(Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                        
                        if(qtmUserEmailsList.size() > 0){
                            String emails = '';
                            for(String e: validFSEEmails){
                                if(qtmUserEmailsList.contains(e)){
                                    emails += e+', ';
                                    isSalesRepValid = false;
                                }
                            }
                            if(emails.length()>=2){
                                emails = emails.substring(0, emails.length() - 2);
                                addValidationError(errorMsgs, 'intelSalesRepEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1054, new Map<String, String>{'{{EMAIL}}' => emails});
                            }    
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
    public static boolean validateAccountExecutive(String AEemail, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //this method validates Account Executive Email Id if it is not empty
        //Account Executive email id should be a valid intel email id and of a active salesforce User
        Boolean isValidAE=true;
        if(!String.isEmpty(AEemail)){
            List<String> AEemailList = new List<String>(AEemail.toLowerCase().split(','));
            List<String> trimmedAEemailList = new List<String>();
            Set<String> emailIds = new Set<String>(AEemail.toLowerCase().split(','));
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
                if(Pricing_RestAPI_Quotes.isCreateQuoteTeam){                    
                    if(qtmUserEmailsList.size() > 0){
                        String emails = '';
                        for(String e: validAEEmailIdSet){
                            if(qtmUserEmailsList.contains(e)){
                                emails += e+', ';
                                isValidAE = false;
                            }
                        }
                        if(emails.length()>=2){
                            emails = emails.substring(0, emails.length() - 2);
                            addValidationError(errorMsgs, 'intelAccountExecutiveEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1054, new Map<String, String>{'{{EMAIL}}' => emails});
                        }    
                    }
                }
                if(validAEEmailIdSet.size() == 0 && Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                    addValidationError(errorMsgs, 'intelAccountExecutiveEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1057, new Map<String, String>{'{{USER}}' => AEemail});
                    isValidAE = false;
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
    public static boolean validateITSEmail(String ITSEmail, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        Boolean isValidITS=true;
        if(!String.isEmpty(ITSEmail)){
            Set<String> emailIds = new Set<String>(ITSEmail.toLowerCase().split(','));
            Set<String> trimmedEmailIds = new Set<String>();
            for(String email : emailIds){
                if(email.trim() != ''){
                    trimmedEmailIds.add(email.trim());
                }
            }
            if(validateEmailIds(trimmedEmailIds, 'industryTechnicalSpecialistEmail', errorMsgs) || trimmedEmailIds.size() > 1){
                Set<String> validITSEmailIdSet = getITSMap(trimmedEmailIds);
                if(Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                    
                    if(qtmUserEmailsList.size() > 0){
                        String emails = '';
                        for(String e: validITSEmailIdSet){
                            if(qtmUserEmailsList.contains(e)){
                                emails += e+', ';
                                isValidITS = false;
                            }
                        }
                        if(emails.length()>=2){
                            emails = emails.substring(0, emails.length() - 2);
                            addValidationError(errorMsgs, 'industryTechnicalSpecialistEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1054, new Map<String, String>{'{{EMAIL}}' => emails});
                        }    
                    }
                }
                if(validITSEmailIdSet.size() == 0 && Pricing_RestAPI_Quotes.isCreateQuoteTeam){
                    addValidationError(errorMsgs, 'industryTechnicalSpecialistEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1057, new Map<String, String>{'{{USER}}' => ITSEmail});
                    isValidITS = false;
                }
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
    public boolean validatePrimaryContact(String quoteId, String primaryContactEmail, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        boolean isValid = true;
        String regex = Label.Pricing_IQR_PrimaryContactEmail_Regex;
        //checking weather its valid intel email or not
        if(!Pattern.matches(regex, primaryContactEmail.toLowerCase())){
            isValid = false;
            addValidationError(errorMsgs, 'primaryContactEmail', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1051, null);
        }
        List<Contact> contact = [Select Id, Account.Id from Contact where Email= :primaryContactEmail and Account.Id = :currentUserAccountId];
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
                                                                                             WHERE Assignee.IsActive = true and AssigneeId = :primaryContactUser[0].Id]);
            
            List<String> apiUserPermissionSets = label.Pricing_IQR_API_PrimaryContactPermissionSets.split(',');
            for (PermissionSetAssignment psa : listUserPerSet) {
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
    
    public  boolean validateSVDQuota(Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteMsgs){
        quoteMsgs.quoteErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        if(Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed(currentUserAccountId)==false){
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
    
    /***************************************************************************************/
    
    /*************************** validate Quote Lines Starts Here **********************************/
    public boolean validateQuoteLineWrapper(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLineWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg, boolean isSubmit){
        //this method is called from submit quoteline API to validate input quoteline JSON with performance metrics
        if(Pricing_RestAPI_Quotelines.isStatusChange){
            return validateWonLostQuotelineWrapper(quoteLineWrapper, qErrorMsg, sObjQuoteLineFieldMap);
        }else if(Pricing_RestAPI_Quotelines.isChangeReq ){
            qErrorMsg.quoteErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>(); 
            Set<Id> qliAPIIds = new Set<Id>();
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
                    qErrorMsg.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();       
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteline: quoteLineWrapper.quoteLines){
                        if(quoteline.quotelineId == null || String.isEmpty(quoteline.quotelineId.trim()))
                        {
                            Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qle = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                            qle.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                            qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
                            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null); 
                            qErrorMsg.quoteLineErrorMsgs.add(qle);
                        }
                        else if(quoteLine.quotelineId.trim() instanceOf Id ){
                            qliAPIIds.add(quoteline.quotelineId.trim());
                        }
                        else{
                            Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qle = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                            qle.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                            qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
                            addValidationError(qle.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null); 
                            qErrorMsg.quoteLineErrorMsgs.add(qle);
                        }  
                    }
                    List<SBQQ__QuoteLine__c> hasCR = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c
                                                      where Pricing_Reference_Quote_Line_Nbr__c IN : qliAPIIds and Pricing_Status_Nm__c != 'Rejected' and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId];
                    Map<Id,String> hasCRMap = new Map<Id,String>();
                    for(SBQQ__QuoteLine__c qli: hasCR){
                        hasCRMap.put(qli.Pricing_Reference_Quote_Line_Nbr__c,qli.Pricing_Quote_Line_Number__c);
                    }   
                    Map<Id,SBQQ__QuoteLine__c> quotelineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id,Pricing_Status_Nm__c,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_ECAP_Price_Amt__c,Pricing_Approved_Start_Date_Dt__c from SBQQ__QuoteLine__c where Id IN :qliAPIIds and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId]);
                    
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteline: quoteLineWrapper.quoteLines){
                        
                        validateChangeReqQuoteline(quoteline,qErrorMsg.quoteLineErrorMsgs, sObjQuoteLineFieldMap,quotelineMap,hasCRMap);
                    }
                }
                else{
                    addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                    isValid = false; 
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
            
        }else{
            try{
                Set<Id> quoteIds = new Set<Id>();
                
                List<String> productIdList = new List<String>();
                List<String> compProductIdList = new List<String>();
                qErrorMsg.quoteErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                if(quoteLineWrapper.quoteId != null && !String.isEmpty(quoteLineWrapper.quoteId.trim())){
                    qErrorMsg.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();
                    List<SBQQ__Quote__c> quoteList = [Select Id, Pricing_ShipmentStDate_Dt__c, SBQQ__Status__c, SBQQ__Account__c,Pricing_Overall_Quote_Quantity__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c where Id =:quoteLineWrapper.quoteId and SBQQ__Account__c = :currentUserAccountId];
                    List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI> quoteLineList = quoteLineWrapper.quoteLines;
                    quoteIds.add(quoteLineWrapper.quoteId);
                    if(quoteList.size()>0){
                        quoteId = quoteLineWrapper.quoteId;
                        overallQuantity = quoteList[0].Pricing_Overall_Quote_Quantity__c;
                        isQuotelineDraftQuote = quoteList[0].SBQQ__Status__c == Label.Pricing_RestAPI_Status_Draft;
                        if(quoteList[0].Pricing_Program_Type_Nm__c==Label.Pricing_Tender_Small_Volume_Quote){
                            Pricing_RestAPI_Quotelines.isSvdQuoteLine = true;
                        }
                        if(isSubmit && isQuotelineDraftQuote){
                            //checking for parent quote status if it is already submitted or not
                            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1032, null);
                            isValid = false;
                        }
                        if(quoteLineList.size()>0){
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q : quoteLineList){
                                if(q.noOfCPUsPerSystem>0 && q.noOfSystems>0 && !Pricing_RestAPI_Quotelines.isResubmit)
                                    overallQuantity=overallQuantity+(q.noOfCPUsPerSystem * q.noOfSystems);
                                productIdList.add(q.productId);
                                compProductIdList.add(q.competitorProductId); 
                            }
                            if(productIdList.size()>0){
                                getProducts(productIdList);
                            }
                            if(compProductIdList.size()>0){
                                getCompetitorProducts(compProductIdList);
                            }
                            validateQuoteLines(quoteLineList,quoteList[0].Pricing_ShipmentStDate_Dt__c,qErrorMsg,isSubmit);		//validate quotelines and its performance metrics if isSubmit=true
                        }else{
                            addValidationError(qErrorMsg.quoteErrors, 'quoteId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, null);
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
    }
    /*************************** validate WON/LOST Starts Here **********************************/
    public static boolean validateWonLostQuotelineWrapper(Pricing_RestAPI_QuotesUtilityV2.QuoteLineWrapperDCAI quoteLineWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap){
        qErrorMsg.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>();
        Set<Id> quotelineIdSet = new Set<Id>();
        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qline: quoteLineWrapper.quoteLines){
            if(qline.quotelineId != null && !String.isEmpty(qline.quotelineId.trim()) && qline.quotelineId.trim() instanceOf Id ){
                quotelineIdSet.add(qline.quotelineId.trim());
            }
        }
        Map<Id, SBQQ__QuoteLine__c> quotelineRecMap = new Map<Id, SBQQ__QuoteLine__c>([Select Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,
                                                                                       SBQQ__Product__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,
                                                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c from SBQQ__QuoteLine__c where Id IN :quotelineIdSet 
                                                                                       AND SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId]);
        List<SBQQ__QuoteLine__c> hasCR = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c
                                          where Pricing_Reference_Quote_Line_Nbr__c IN : quotelineIdSet and Pricing_Status_Nm__c != 'Rejected' and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId
                                         ];
        Map<Id, String> qlIdMsgMap = Pricing_QuoteLineController.isNotUnifiedQuoteLineBulk(quotelineIdSet);
        Set<Id> hasCRSet = new Set<Id>();
        for(SBQQ__QuoteLine__c qli: hasCR){
            hasCRSet.add(qli.Pricing_Reference_Quote_Line_Nbr__c);
        }    
        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI qline: quoteLineWrapper.quoteLines){
            validateWonLostQuoteline(qline, qErrorMsg.quoteLineErrorMsgs,quotelineRecMap,hasCRSet,sObjQuoteLineFieldMap,qlIdMsgMap);
        }
        return true;
    }
    
    public static void validateWonLostQuoteline(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLine, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> qlErrorMsg, Map<Id, SBQQ__QuoteLine__c> quotelineRecMap,Set<Id> hasCRSet,Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id, String> qlIdMsgMap){
        Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qle = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
        qle.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();     
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
            Pricing_RestAPI_Quotelines.statusChangeQuotelines.add(quoteLine);
        }
    }
    
    
    /******************************Validate Change Request Fields*************************************/
    public void validateChangeReqQuoteline(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteline, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg> qlErrorMsg, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id,SBQQ__QuoteLine__c> quotelineMap,Map<Id,String> hasCRMap){
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qle = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
        qle.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        qle.quotelineReferenceID = quoteLine.quotelineReferenceID;
        try{
            if(quoteLine.quotelineId != null && !String.isEmpty(quoteLine.quotelineId.trim()) && (quoteLine.quotelineId.trim() instanceOf Id)){
                if(quotelineMap.get(quoteline.quotelineId).SBQQ__Quote__c != quoteId)
                {
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
                                switch on Pricing_RestAPI_ChangeRequestQuoteLine.version {
                                    when  'v1.0' {
                                        validatedCRRequestedPrice(quoteline.quotelineId,quoteline.newRequestedDiscountUnitPrice,'newRequestedDiscountUnitPrice',sObjQuoteLineFieldMap,quotelineMap,qle.quoteLineErrors);
                                    }
                                    when  'v2.0' {
                                        validatedCRRequestedPrice(quoteline.quotelineId,quoteline.newRequestedPrice,'newRequestedPrice',sObjQuoteLineFieldMap,quotelineMap,qle.quoteLineErrors);
                                    }
                                }
                                
                                if (validateBidPricingDates(quoteline.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qle.quoteLineErrors)){
                                    if(date.parse(quoteline.quoteLinePricingEndDate) < quotelineMap.get(quoteline.quotelineId).SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c){
                                        addValidationError(qle.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
                                    }
                                    if ((quoteline.newRequestedDiscountUnitPrice == quotelineMap.get(quoteline.quotelineId).Pricing_ECAP_Price_Amt__c 
                                         || quoteline.newRequestedPrice == quotelineMap.get(quoteline.quotelineId).Pricing_ECAP_Price_Amt__c)
                                        && quoteline.newQuantity == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Unit_Qty__c
                                        && date.parse(quoteline.quoteLinePricingEndDate) == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_End_Date_Dt__c
                                        && (String.isEmpty(quoteline.quoteLinePricingStartDate) || (String.isNotEmpty(quoteline.quoteLinePricingStartDate) && date.parse(quoteline.quoteLinePricingStartDate) == quotelineMap.get(quoteline.quotelineId).Pricing_Approved_Start_Date_Dt__c))) {
                                            if(Pricing_RestAPI_ChangeRequestQuoteLine.version == 'v2.0'){
                                                addValidationError(qle.quoteLineErrors, 'newRequestedPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, null);
                                            } else{
                                                addValidationError(qle.quoteLineErrors, 'newRequestedDiscountUnitPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, null); 
                                            }                                        
                                            addValidationError(qle.quoteLineErrors, 'newQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, null);
                                            addValidationError(qle.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, null);
                                            if(String.isNotEmpty(quoteline.quoteLinePricingStartDate)){
                                                addValidationError(qle.quoteLineErrors, 'quoteLinePricingStartDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1061, null);
                                            }                                                                               
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
    
    //Method to validate newRequestedDiscountUnitPrice/newRequestedPrice during Change Request
    public void validatedCRRequestedPrice(Id quotelineId, Decimal fieldValue,String fieldName, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap,Map<Id,SBQQ__QuoteLine__c> quotelineMap,Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> quoteLineErrors){
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        if (quotelineMap.get(quotelineId).Pricing_Approved_End_Date_Dt__c<System.today() && fieldValue != null)
        {
            addValidationError(quoteLineErrors, fieldName, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1060, null);
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
    
    public boolean validateQuoteLines(List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI> quoteLines, Date pricingStartDate, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg, boolean isSubmit){
        //this method is called from submit quote API to validate quoteline and its performance metrics
        List<String> productNameList = new List<String>();
        List<String> compProductNameList = new List<String>();
        List<String> quotelinesIds = new List<String>();
        Set<String> quotelineIdsSet = new Set<String>(); 
        if(quoteLines!=null && quoteLines.size()>0){
            
            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q : quoteLines){
                if(q.noOfCPUsPerSystem>0 && q.noOfSystems>0 && calledFromQuote)
                    overallQuantity = overallQuantity+(q.noOfCPUsPerSystem * q.noOfSystems);
                quotelineIdsSet.add(q.quotelineId);
                productNameList.add(q.productId);
                compProductNameList.add(q.competitorProductId);                  
            }
            if(productNameList.size()>0){
                getProducts(productNameList);
            }
            if(compProductNameList.size()>0){
                getCompetitorProducts(compProductNameList);
            }
            
            patchQuotelineMap = new Map<Id,SBQQ__QuoteLine__c>([Select Id, Name,Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,Pricing_Unit_Qty__c,RecordTypeId,Pricing_Program_Type_Nm__c, (SELECT id FROM Performance_Metrics__r) from SBQQ__QuoteLine__c where Id IN :quotelineIdsSet and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId and SBQQ__Quote__c = :quoteId]);
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
                if(Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine || Pricing_RestAPI_Quotelines.isResubmit){
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q : quoteLines){
                        SBQQ__QuoteLine__c quotelinePatch = patchQuotelineMap.get(q.quotelineId);
                        if(quotelinePatch != null){
                            //List<Pricing_Performance_Metric__c> perfMetricList = [Select id from Pricing_Performance_Metric__c where Pricing_Quote_Line__c = :quotelinePatch.id];
                            if(quotelinePatch.Performance_Metrics__r.size()>0){
                                isPerfMetricsAvailable = true;
                            }
                            if(quotelinePatch.Pricing_Status_Nm__c != 'Draft'){
                                Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                                qlErrMsg.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                                addValidationError(qlErrMsg.quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1048, new Map<String, String>{'Approved' => 'Draft'});
                                qErrorMsg.quoteLineErrorMsgs.add(qlErrMsg);
                                isValid = false;
                            }
                            if(q.noOfSystems != null && q.noOfCPUsPerSystem != null && quotelinePatch.Pricing_Unit_Qty__c!=(q.noOfCPUsPerSystem * q.noOfSystems) && Pricing_RestAPI_Quotelines.isResubmit){
                                overallQuantity = overallQuantity+(q.noOfCPUsPerSystem * q.noOfSystems)-quotelinePatch.Pricing_Unit_Qty__c;
                            }
                        }else{
                            Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                            qlErrMsg.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
                            addValidationError(qlErrMsg.quoteLineErrors, 'quoteLineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1013, new Map<String, String>{'Approved' => 'Draft'});
                            qErrorMsg.quoteLineErrorMsgs.add(qlErrMsg);
                            isValid = false;
                        }
                    }                
                }
            }
            
            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q : quoteLines){
                Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
                qlErrMsg.quotelineReferenceID = q.quotelineReferenceID;
                validateQuoteLine(q, pricingStartDate, qlErrMsg, isSubmit);
                if(qlErrMsg.quoteLineErrors != null){                    
                    qErrorMsg.quoteLineErrorMsgs.add(qlErrMsg);
                }else if(qlErrMsg.perfMetricsErrorMsgs != null){
                    qErrorMsg.quoteLineErrorMsgs.add(qlErrMsg);
                }
            }
        }else if(!isCreateDraftQuote){
            addValidationError(qErrorMsg.quoteErrors, 'quoteDetails', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1028, null);
            isValid = false;
        }
        if(qErrorMsg.quoteLineErrorMsgs.isEmpty()){
            qErrorMsg.quoteLineErrorMsgs = null;
        }
        return isValid;
    }
    public boolean validateQuoteLine(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Date quotePricingStartDate, Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrorMsg, boolean isSubmit){   //from where did i get quote pricing start date
        //validate quoteline [and its performance metrics if isSubmit=true]
        qlErrorMsg.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        updateQuotelineId = quoteLineDetails.quotelineId;
        try{
            String quotelineId = quoteLineDetails.quotelineId;
            if(/*Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine && */(updateQuotelineId!=null && !String.isBlank(updateQuotelineId.trim())) && patchQuotelineMap.get(updateQuotelineId) == null){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1037, new Map<String, String>{'Performance metrics' => 'Quote line', 'quote line' => 'quote'});
                isValid = false;
            }
            
            if((Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine || Pricing_RestAPI_Quotelines.isResubmit) && (updateQuotelineId == null || String.isBlank(updateQuotelineId.trim()))){
                addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null);
                isValid = false;
            }
        }catch(Exception ex){
            addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1037, new Map<String, String>{'Performance metrics' => 'Quote line', 'quote line' => 'quote'});
            isValid = false;
        }
        if((updateQuotelineId == null || String.isBlank(updateQuotelineId.trim())) && isUpdateDraftQuote && !Pricing_RestAPI_Quotes.isResubmit){ //change for resubmit API
            addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineId', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1014, null);
            isValid = false;
        }
        
        if(quotePricingStartDate!=null && validateBidPricingDates(quoteLineDetails.quoteLinePricingEndDate, 'quoteLinePricingEndDate', qlErrorMsg.quoteLineErrors)){            
            if(Date.parse(quoteLineDetails.quoteLinePricingEndDate) < quotePricingStartDate){
                isValid = false;
                addValidationError(qlErrorMsg.quoteLineErrors, 'quoteLinePricingEndDate', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1006, null);
            }
        }else if(!isUpdateDraftQuote){
            isValid = false;
        }
        //validate all text fields of quoteline
        if(!Pricing_RestAPI_Quotes.isSvdQuote && !Pricing_RestAPI_Quotelines.isSvdQuoteLine){
            if(!validateQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            }
        }
        else
        {
            if(!validateSVDQuoteLineTextFields(quoteLineDetails, sObjQuoteLineFieldMap, qlErrorMsg.quoteLineErrors)){
                isValid = false;
            } 
        }
        
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        //validate all number fields of quoteline
        if(!validateQuoteLineNumberFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors)){
            isValid = false;
        }
        //valid all currency fields
        if(!Pricing_RestAPI_Quotes.isSvdQuote && !Pricing_RestAPI_Quotelines.isSvdQuoteLine){
            validateQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
        }
        else
        {
            validateSVDQuoteLineCurrencyFields(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);    
        }
        
        validateProduct(quoteLineDetails.productId, quoteLineDetails.writeInProduct, qlErrorMsg.quoteLineErrors);
        
        validateCompProduct(quoteLineDetails.competitorProductId, quoteLineDetails.competitorWriteInProduct, qlErrorMsg.quoteLineErrors);        
        
        //referenceField is mendatory
        if(String.isEmpty(quoteLineDetails.quotelineReferenceID)){
            addValidationError(qlErrorMsg.quoteLineErrors, 'quotelineReferenceID', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            isValid = false;
        }
        
        if(isSubmit){
            if(!isCreateDraftQuote && (overallQuantity<Decimal.valueOf(Label.Pricing_Overall_Quantity_Min)  || overallQuantity>Decimal.valueOf(Label.Pricing_Overall_Quantity_Max) ) && (Pricing_RestAPI_Quotes.isSvdQuote || Pricing_RestAPI_QuoteLines.isSvdQuoteLine)){
                addValidationError(qlErrorMsg.quoteLineErrors, 'overallQuantity', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1069, new Map<String,String>{'{value}'=>String.valueOf(overallQuantity)});
                isValid = false;
            }
            if(!isCreateDraftQuote&&!(Pricing_RestAPI_Quotes.isSvdQuote || Pricing_RestAPI_Quotelines.isSvdQuoteLine)){//do not validate while creating draft quote/quotelines
                validateDiscountField(quoteLineDetails, fldValidMap, qlErrorMsg.quoteLineErrors);
            }
            
            validatePerformanceMetricsList(quoteLineDetails.performanceMetrics, qlErrorMsg);
        }else if(!isQuotelineDraftQuote || quoteLineDetails.performanceMetrics != null){
            validatePerformanceMetricsList(quoteLineDetails.performanceMetrics, qlErrorMsg);
        }
        
        if(qlErrorMsg.quoteLineErrors != null && qlErrorMsg.quoteLineErrors.isEmpty()){
            qlErrorMsg.quoteLineErrors = null;
        }
        return isValid;
    }     
    /**
* @description field wrappers to validte the corresponding values
* @author Accenture | 05-24-2022 
* @param quoteLineDetails 
* @param sObjQuoteLineFieldMap 
* @param errorMsgs 
* @return boolean 
**/
    public boolean validateQuoteLineTextFields(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_OEM_System_Model_Nm__c',quoteLineDetails.systemModel, 'systemModel', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_System_Model_Nm__c',quoteLineDetails.competitorSystemModel, 'competitorSystemModel', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Competitor_OEM_Nm__c',quoteLineDetails.competitorName, 'competitorName', true));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    public boolean validateSVDQuoteLineTextFields(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Map<String,Schema.SObjectField> sObjQuoteLineFieldMap, Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Product_Nm__c',quoteLineDetails.writeInProduct,'writeInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Competitor_Product_Nm__c',quoteLineDetails.competitorWriteInProduct, 'competitorWriteInProduct', false));
        textFldValues.add(new TextFieldValueWrapper('Pricing_Additional_Comments_Txt__c',quoteLineDetails.additionalComment, 'additionalComment', false));
        return validTextFields(sObjQuoteLineFieldMap, textFldValues, errorMsgs); 
    }
    public void validateProduct(String productId, String writeInProduct, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //check if the product is available in salesforce using product Id
        if(productId != null && !String.isEmpty(productId.trim())){
            try{
                Id recId = Id.valueOf(productId);
                writeInProduct = !String.isEmpty(writeInProduct) ?writeInProduct.trim() : writeInProduct;
                if(productIdMap.containsKey(recId)){
                    //if the given product is a "Write in Product" then writeInProduct field is mandatory
                    if(productIdMap.get(recId).Name == label.Pricing_Write_In_Product && String.isEmpty(writeInProduct)){
                        isValid = false;
                        addValidationError(errorMsgs, 'writeInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1039, null);                 
                    }
                    else if(productIdMap.get(recId).Name != label.Pricing_Write_In_Product && !String.isEmpty(writeInProduct)){
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
    public void validateCompProduct(String productId, String writeInProduct, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //check if the competitor product is available in salesforce using competitor product Id
        if(productId != null && !String.isEmpty(productId.trim())){
            try {
                Id recId = Id.valueOf(productId);    
                writeInProduct = !String.isEmpty(writeInProduct)?writeInProduct.trim() : writeInProduct;
                if(compProductIdMap.containsKey(recId)){
                    //if the given competitor product is a "Write in Product" then competitorWriteInProduct field is mandatory
                    if(compProductIdMap.get(recId).Name == label.Pricing_Write_In_Product && String.isEmpty(writeInProduct)){
                        isValid = false; 
                        addValidationError(errorMsgs, 'competitorWriteInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1040, null);
                    }
                    else if(compProductIdMap.get(recId).Name != label.Pricing_Write_In_Product && !String.isEmpty(writeInProduct)){
                        isValid = false; 
                        addValidationError(errorMsgs, 'competitorWriteInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1053, null);
                    }
                }else{
                    isValid = false;
                    addValidationError(errorMsgs, 'competitorWriteInProduct', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1012, null);
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
* @description retrive all product from org
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
**/
    public static void getProducts(List<String> productIds){
        String query = Label.Pricing_RestAPI_Prodcuts_Query+' Where Id in :productIds and '+ Label.Pricing_RestAPI_Products_CommonFilter;
        List<Product2> productList = Database.query(query);
        productIdMap = new Map<Id,Product2>(productList);
        //productIdMap =new Map<Id,Product2>([Select Id,Name from Product2 where Id in :productIds]);
    }   
    /**
* @description retrive the competitor product
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param productId 
**/
    public static void getCompetitorProducts(List<String> productId){
        compProductIdMap =new Map<Id, Pricing_Competitor_Product__c>([Select Id,Name from Pricing_Competitor_Product__c where Id in :productId and Pricing_Active_cb__c = True]);
    }
    //Validating number fields of quoteline
    public boolean validateQuoteLineNumberFields(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>();
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Systems_qty__c',quoteLineDetails.noOfSystems, 'noOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_CPUs_per_system_qty__c',quoteLineDetails.noOfCPUsPerSystem,  'noOfCPUsPerSystem', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Competitor_Systems_Cnt__c',quoteLineDetails.competitorNoOfSystems, 'competitorNoOfSystems', true));
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Comp_CPUs_per_system_Cnt__c',quoteLineDetails.competitorNoOfCPUsPerSystem, 'competitorNoOfCPUsPerSystem', true));  
        return validNumberFields(sObjQuoteLineFieldMap, numFldValues, fldValidMap, errorMsgs); 
    }
    public boolean validateQuoteLineCurrencyFields(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Single_System_Price_Amt__c',quoteLineDetails.singleSystemPrice, 'singleSystemPrice',  true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_OEM_Standard_Unit_Price_Amt__c',quoteLineDetails.customerStdUnitPrice,'customerStdUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedDiscountUnitPrice,'requestedDiscountUnitPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Additional_OEM_Discount_Amt__c',quoteLineDetails.additionalDiscount,'additionalDiscount', true, true));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Single_System_Price_Amt__c',quoteLineDetails.competitorSingleSystemPrice,'competitorSingleSystemPrice', true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_Additional_OEM_Disc_Amt__c',quoteLineDetails.competitorAdditionalDiscount,'competitorAdditionalDiscount', true, true));        
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    public boolean validateSVDQuoteLineCurrencyFields(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteLineDetails, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Req_Discounted_Unit_Price__c',quoteLineDetails.requestedDiscountUnitPrice,'requestedDiscountUnitPrice', true, false));       
        return validateCurrencyFields(sObjQuoteLineFieldMap, currencyFldValues, fldValidMap, errorMsgs); 
    }
    
    public static void validateDiscountField(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI quoteline, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //validate auto-calculated fields in case of quote or quoteline submission
        if(fldValidMap != null){
            if(fldValidMap.isEmpty() && !fldValidMap.containsKey('singleSystemPrice') && !fldValidMap.containsKey('noOfSystems') 
               && !fldValidMap.containsKey('requestedDiscountUnitPrice') && !fldValidMap.containsKey('customerStdUnitPrice')
              ){
                  Decimal totalBidWithoutDiscount = quoteline.singleSystemPrice * quoteline.noOfSystems; 									
                  Decimal quantity = quoteline.noOfCPUsPerSystem * quoteline.noOfSystems;														
                  Decimal totalIntelDiscount = (quoteline.customerStdUnitPrice - quoteline.requestedDiscountUnitPrice) * quantity;			
                  Decimal netIntelBidPrice = totalBidWithoutDiscount - totalIntelDiscount - quoteline.additionalDiscount;
                  //intel discount percentage check
                  Decimal intelDiscountPercentage = ((quoteline.customerStdUnitPrice - quoteline.requestedDiscountUnitPrice)/quoteline.customerStdUnitPrice)*100;
                  if(intelDiscountPercentage < 0 || intelDiscountPercentage > 100){
                      isValid = false;
                      addValidationError(errorMsgs, 'requestedDiscountUnitPrice', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1031, new Map<String,String>{'{{VALUE}}' => Label.Pricing_IQR_API_IntelDiscountPercentage});
                  }
                  
                  //customer discount percentage check
                  Decimal customerDiscountPercentage = (quoteline.additionalDiscount/(totalBidWithoutDiscount - (quoteline.customerStdUnitPrice * quantity)))*100;
                  
                  if(customerDiscountPercentage < 0 || customerDiscountPercentage > 100){
                      isValid = false;
                      addValidationError(errorMsgs, 'additionalDiscount', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1031, new Map<String,String>{'{{VALUE}}' => Label.Pricing_IQR_API_AdditionalDiscount});
                  }
              }
        }
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Performnce Metrics Starts Here **********************************/
    public boolean validatePerformanceMetricsWrapper(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDCAI performanceMetricWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors){
        //this is called from performance metrics API. Validates performance metrics of a quoteline
        quoteErrors.quoteLineErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg>(); 
        Set<String> perfMetricsIds = new Set<String>();        
        Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg();
        qlErrors.perfMetricsErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg>();
        qlErrors.quoteLineErrors = new Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        if(!String.isEmpty(performanceMetricWrapper.quoteLineId)){
            List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, Name,Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Account__c, (SELECT id FROM Performance_Metrics__r) from SBQQ__QuoteLine__c where Id =:performanceMetricWrapper.quoteLineId and SBQQ__Quote__r.SBQQ__Account__c = :currentUserAccountId];
            List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics> performanceMetricsList=performanceMetricWrapper.performanceMetrics;
            
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
                for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : performanceMetricsList){
                    Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg perErrMsg = new Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg();
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
    public boolean validatePerformanceMetricsList(List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics> perfMetrics, Pricing_RestAPI_QuotesUtilityV2.QuoteLineErrorMsg qlErrors){ 
        //called from submit quote API to validate performance metrics of a perticular quoteline
        qlErrors.perfMetricsErrorMsgs = new List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg>();
        if(perfMetrics!=null && perfMetrics.size()>0){
            for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : perfMetrics){
                Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg perErrMsg = new Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg();
                perErrMsg.performanceMetricsReferenceId = pm.performanceMetricsReferenceId;
                validatePerformanceMetrics(pm, perErrMsg, new Set<String>());
                if(perErrMsg.perfMetricsErrors != null && perErrMsg.perfMetricsErrors.isEmpty()){
                    perErrMsg.perfMetricsErrors = null;
                }
                if(perErrMsg.perfMetricsErrors != null){
                    qlErrors.perfMetricsErrorMsgs.add(perErrMsg);
                }
            }
        }else if((perfMetrics==null && Pricing_RestAPI_Quotelines.isCreateDraftQuoteLine) || isCreateDraftQuote){
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
    public boolean validatePerformanceMetrics(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics performanceMetrics, Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsErrorMsg perfMetricsError, Set<String> perfMetricsIds){
        //validate a single performance metrics
        perfMetricsError.perfMetricsErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        perfMetricsIds = quotelineIdPerfMap.get(updateQuotelineId);
        if((perfMetricsIds != null && !String.isEmpty(performanceMetrics.performanceMetricsId) && !perfMetricsIds.contains(performanceMetrics.performanceMetricsId)) || (perfMetricsIds!=null && perfMetricsIds.size() == 0 && !String.isEmpty(performanceMetrics.performanceMetricsId))){
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
            performanceMetrics.otherText = String.isEmpty(performanceMetrics.otherText) ? null : performanceMetrics.otherText.trim();
            if(String.isEmpty(performanceMetrics.otherText)){
                isValid = false;
                addValidationError(perfMetricsError.perfMetricsErrors, 'otherText', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1041, null);
            }else if(!validatePMTextFields(performanceMetrics, sObjPerformanceMatrixFieldMap, perfMetricsError.perfMetricsErrors)){
                isValid = false;                
            }
        }else{
            performanceMetrics.otherText = String.isEmpty(performanceMetrics.otherText) ? null : performanceMetrics.otherText.trim();
            if(!String.isEmpty(performanceMetrics.otherText)){
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
        if(String.isEmpty(performanceMetrics.performanceMetricsReferenceId)){
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
    public boolean validatePMTextFields(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics performanceMetrics, Map<String,Schema.SObjectField> sObjPerformanceMatrixFieldMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
        textFldValues.add(new TextFieldValueWrapper('Pricing_Other_Nm__c',performanceMetrics.otherText, 'otherText', true));      
        return validTextFields(sObjPerformanceMatrixFieldMap, textFldValues, errorMsgs); 
    }
    public static void validateWeighting(Decimal percent, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //check if Weighting is between 1 to 100
        if(percent > 100 || percent < 1){
            isValid = false;
            addValidationError(errorMsgs, 'weighting', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1015, null);
        }
    }
    public static void validateIntelScore(Decimal intelscore, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //check if intel score is a positive value
        if(intelscore < 0.01){
            isValid = false;
            addValidationError(errorMsgs, 'intelScore', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
        }
    }
    public static void validateCompScore(Decimal compscore, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        //check if comp score is a positive value
        if(compscore < 0.01){
            isValid = false;
            addValidationError(errorMsgs, 'compScore', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1038, null);
        }
    }    
    public boolean validatePMNumberFields(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics performanceMetrics, Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<NumberFieldValueWrapper> numFldValues = new List<NumberFieldValueWrapper>(); 
        numFldValues.add(new NumberFieldValueWrapper('Pricing_Weighting_Pct__c',performanceMetrics.weighting, 'weighting', false));  
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        return validNumberFields(sObjPerformanceMatrixFieldMap, numFldValues, fldValidMap, errorMsgs);
    }
    
    public boolean validatePMDecimalFields(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics performanceMetrics, Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        List<CurrencyFieldValueWrapper> currencyFldValues = new List<CurrencyFieldValueWrapper>();
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Comp_SKU_Performance_Nbr__c',performanceMetrics.compScore, 'compScore',  true, false));
        currencyFldValues.add(new CurrencyFieldValueWrapper('Pricing_Intel_SKU_Performance_Nbr__c',performanceMetrics.intelScore, 'intelScore',  true, false));
        Map<String, boolean> fldValidMap = new Map<String, boolean>();
        return validateCurrencyFields(sObjPerformanceMatrixFieldMap, currencyFldValues, fldValidMap, errorMsgs);
    }
    
    /***********************************************************************************************/
    
    /*************************** validate Quote Comments Starts Here **********************************/
    public boolean validateQuoteCommentsWrapper(Pricing_RestAPI_QuotesUtilityV2.QuoteCommentWrapperDCAI quoteCommentWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors){
        //this method validates the input quote comments JSON based on the existing quote comments records
        quoteErrors.quoteErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        Map<String,Pricing_Comments__c> commsMap = new Map<String,Pricing_Comments__c>();
        if(!String.isEmpty(quoteCommentWrapper.quoteId)){
            quoteErrors.quoteCommentsErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            //get quote and respective quote comment details Pricing_Comment_Ref_Id__c
            List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__Status__c, SBQQ__Account__c,Pricing_Program_Type_Nm__c, (SELECT id,Pricing_Answer__c,Pricing_Comment_Ref_Id__c,Pricing_Question__c  FROM Comments__r) FROM SBQQ__Quote__c WHERE Id =:quoteCommentWrapper.quoteId and SBQQ__Account__c = :currentUserAccountId];
            List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment> commentList = quoteCommentWrapper.quoteComments;
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
                    for(Pricing_RestAPI_QuotesUtilityV2.QuoteComment qc: commentList){  
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
    
    public boolean validateQuoteComments(List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment> quoteComments, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors,String quoteId){
        //this method validates quote comments from input JSON for yet to be created quote. Uses Core_CPQ_Tender_Comments__mdt to validate questions and answers
        quoteErrors.quoteCommentsErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
        if(quoteComments!=null && quoteComments.size() > 0 ){
            
            List<TextFieldValueWrapper> textFldValues = new List<TextFieldValueWrapper>();
            List<String> questionList = new List<String>();
            List<String> quoteQuestLst = new List<String>();
            Map<String, String> questIdMap = new Map<String, String>();
            for(Core_CPQ_Tender_Comments__mdt qcMdt : [SELECT Pricing_Question__c,Pricing_Comment_Ref_Id__c FROM Core_CPQ_Tender_Comments__mdt where Pricing_Business_Unit__c =: Label.Pricing_Tender_DCG_Product_Type]){
                quoteQuestLst.add(qcMdt.Pricing_Comment_Ref_Id__c);
                questIdMap.put(qcMdt.Pricing_Comment_Ref_Id__c,qcMdt.Pricing_Question__c);
            }
            if(quoteComments.size() < quoteQuestLst.size() && !isCreateDraftQuote && !Pricing_RestAPI_Quotes.isSvdQuote){
                isValid=false;
                addValidationError(quoteErrors.quoteCommentsErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1036, null);
            }
            for(Pricing_RestAPI_QuotesUtilityV2.QuoteComment qc: quoteComments){
                if(qc.quoteCommentReferenceId!=null && !String.isEmpty(qc.quoteCommentReferenceId.trim())){
                    if(!questionList.contains(qc.quoteCommentReferenceId)){
                        if(!String.isEmpty(qc.quoteCommentReferenceId) && !quoteQuestLst.contains(qc.quoteCommentReferenceId)){ 	//check if quote comment is already existing or not
                            addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1044, null);
                            isValid=false;
                        }else if(!questIdMap.get(qc.quoteCommentReferenceId).contains(Label.Pricing_Tender_Comments_NoMinLengthQuest)){    	//if question does not contain "incumbent" the anwer text length should be >=10                    
                            if(qc.answer != null && !String.isEmpty(qc.answer.trim())){
                                textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',qc.answer, qc.quoteCommentReferenceId,  Pricing_RestAPI_Quotes.isSvdQuote?false:true));
                                if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors.quoteCommentsErrors)){
                                    isValid = false;
                                }
                                boolean isMinLengthValid = (qc.answer.trim().length() < 10) ? false : true;                        
                                if(!isMinLengthValid){// && !Pricing_RestAPI_Quotes.isSvdQuote){
                                    isValid = false;
                                    addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1018, null);
                                } 
                            }else if (!Pricing_RestAPI_Quotes.isSvdQuote){
                                isValid = false;
                                addValidationError(quoteErrors.quoteCommentsErrors, qc.quoteCommentReferenceId, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
                            }
                        }else{
                            textFldValues.add(new TextFieldValueWrapper('Pricing_Answer__c',qc.answer, qc.quoteCommentReferenceId, Pricing_RestAPI_Quotes.isSvdQuote?false:true));                   
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
            if(!validTextFields(SObjectCommentsMap, textFldValues, quoteErrors.quoteCommentsErrors)){
                isValid = false;
            }
        }else if(!isCreateDraftQuote && !Pricing_RestAPI_Quotes.isSvdQuote){
            addValidationError(quoteErrors.quoteCommentsErrors, 'quoteComments', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1030, null);
            isValid = false;
        }else if(Pricing_RestAPI_Quotes.isResubmit && !Pricing_RestAPI_Quotes.isSvdQuote){
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
    
    /***********************************************************************************************/	
    
    /*************************** Misc. Common validation methods starts here **********************************/
    public boolean validateQuoteStatus(QuoteCommentWrapper quoteCommentsWrapper, Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg){
        //validate the quote is in draft status or not
        qErrorMsg.quoteCommentsErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>(); 
        boolean isValid=true;
        List<Pricing_Comments__c> commentsList = [Select Id,Pricing_Question__c,Pricing_Answer__c,Pricing_Quote__r.SBQQ__Status__c,Pricing_Quote__r.SBQQ__Account__c, Pricing_Quote__c from Pricing_Comments__c where Pricing_Quote__c = :quoteCommentsWrapper.quoteId and Pricing_Quote__r.SBQQ__Account__c = :currentUserAccountId];
        String quoteStatus= commentsList[0].Pricing_Quote__r.SBQQ__Status__c;
        if(quoteStatus != Label.Pricing_RestAPI_Status_Draft){
            addValidationError(qErrorMsg.quoteCommentsErrors,'Answer', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1033, 
                               new Map<String,String>{'{{status}}' => String.valueOf(quoteStatus)});
            isValid=false;
        }
        return isValid;
    }
    
    public static boolean validTextFields(Map<String,Schema.SObjectField> objectMap, List<TextFieldValueWrapper> txtFlds, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        boolean isTxtValid = true;        
        if(txtFlds.size() > 0){
            for(TextFieldValueWrapper txtFld : txtFlds){
                if(!txtFld.isMandatory && (txtFld.fldValue == null || String.isEmpty(txtFld.fldValue.trim()))){
                    //do nothing - value can be blank if the field is not mandatory
                } else {
                    //if field is mandatory or field has a value
                    if(!String.isEmpty(txtFld.fldValue) && ( txtFld.fldValue.length() > 0  && !String.isEmpty(txtFld.fldValue.trim()))) {           
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
    
    public boolean validNumberFields(Map<String,Schema.SObjectField> objectMap, List<NumberFieldValueWrapper> numberFldValues, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){       
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
                        addValidationError(errorMsgs, numFld.fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1023, null);
                        isNumValid = isValid = false;
                        fldValidMap.put(numFld.fldName, false);
                    }                    
                } 
            }
        }
        return isNumValid;
    }
    
    public static boolean validateDateFormat(String inputDate, boolean isMandatory, String fldLabel, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
        boolean isDateValid = true;
        if(!isMandatory && String.isEmpty(inputDate)){
            // Date can be empty if it is not mandatory
        }else{
            try {
                Date d = Date.parse(inputDate);		//check if date is a valid format(mm/dd/yyyy)
            }catch(Exception e) {
                if(errorMsgs!=null){
                    addValidationError(errorMsgs, fldLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1024, null);
                }                
                isDateValid = isValid = false;
            }
        }
        return isDateValid;
    }  
    
    public boolean validateCurrencyFields(Map<String,Schema.SObjectField> objectMap, List<CurrencyFieldValueWrapper> currencyFldValues, Map<String, boolean> fldValidMap, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs){
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
    
    public static boolean validatePicklistValues(Map<String,Schema.SObjectField> objectMap, String fieldName, String fldValue, boolean isMandatory, Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> errorMsgs, String jsonLabel){
        boolean isFldValid = false;
        boolean isEmpty = false;
        if(!isMandatory && String.isEmpty(fldValue)){
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
                addValidationError(errorMsgs, jsonLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1020, null);
            }
            if(!isEmpty && !isFldValid){
                addValidationError(errorMsgs, jsonLabel, Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1026, 
                                   new Map<String,String>{'{{fieldValue}}' => fldValue});
            }
        }
        return isFldValid;
    }
    
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
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
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4){
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2){
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1){
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }                
                baseCount += 4;
            }            
        }        
        return controllingInfo;
    }
    
    public static void addValidationError(Map<String,Pricing_RestAPI_QuotesUtilityV2.ErrorMsg> qErrorMap, String fldName, Decimal errCode, Map<String,String> placeHolders){
        
        if(errorMsgMap.containsKey(errCode)){
            String errMsg = errorMsgMap.get(errCode);
            if(placeHolders!=null && placeHolders.size() > 0){
                for(String key : placeHolders.keySet()){
                    errMsg = errMsg.replace(key, placeHolders.get(key));  
                }  
            }
            qErrorMap.put(fldName, new Pricing_RestAPI_QuotesUtilityV2.ErrorMsg((Integer) errCode, errMsg));
        }else{
            qErrorMap.put(fldName, new Pricing_RestAPI_QuotesUtilityV2.ErrorMsg(0, 'Unknown Error'));
        }
    }
    
    /***********************************************************************************************/
    
    /*************************** Record Creation methods starts here **********************************/
    public static SBQQ__Quote__c createQuoteRecord(Pricing_RestAPI_QuotesUtilityV2.QuoteDetailsDCAI quote){
        
        User  usr = [Select AccountId, ContactId from User where Id = :UserInfo.getUserId()];        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Account__c = usr.AccountId;
        newQuote.SBQQ__PrimaryContact__c = usr.ContactId;
        newQuote.Pricing_Customer_Reference_Id__c = quote.referenceRequestID;
        newQuote.Pricing_Project_Name_Nm__c = quote.projectName;
        newQuote.Pricing_ShipmentStDate_Dt__c = Date.parse(quote.pricingStartDate);
        newQuote.Pricing_ShipmentEndDate_Dt__c = Date.parse(quote.pricingEndDate);
        newQuote.Pricing_SecondaryContact_Nm__c = quote.secondaryContact;
        if((primaryFSEEMail != null && !String.isEmpty(primaryFSEEMail)) && isUpdateDraftQuote){
            newQuote.Pricing_Intel_Sales_Rep_Email_Txt__c = primaryFSEEMail;
        }else if(!isUpdateDraftQuote){
            newQuote.Pricing_Intel_Sales_Rep_Email_Txt__c = String.isEmpty(primaryFSEEMail) ? null : primaryFSEEMail;
        }
        
        if((primaryAEEMail != null && !String.isEmpty(primaryAEEMail)) && isUpdateDraftQuote){
            newQuote.Pricing_Intel_Account_Exec_Email_Txt__c = isValidAE ? primaryAEEMail : null;
        }else if(!isUpdateDraftQuote){
            newQuote.Pricing_Intel_Account_Exec_Email_Txt__c = (isValidAE ? String.isEmpty(primaryAEEMail) ? null : primaryAEEMail : null);
        }
        
        //get End Customer Region Based on End Customer Country
        Map<String, List<String>> countryRegionMap = getFieldDependencies('SBQQ__Quote__c', 'Pricing_End_Customer_Country_Nm__c', 'Pricing_Region_Nm__c'); 
        newQuote.Pricing_Region_Nm__c = countryRegionMap.containsKey(quote.endCustomerCountry)?countryRegionMap.get(quote.endCustomerCountry)[0] : null;
        newQuote.Pricing_End_Customer_Country_Nm__c = quote.endCustomerCountry;
        newQuote.Pricing_Customer_Nm__c = quote.endCustomer;
        newQuote.Pricing_Bid_Dt__c = Date.parse(quote.proposalDueDate);
        newQuote.Pricing_Intel_Response_Requested_By_Date__c = Date.parse(quote.intelResponseRequestedDate);
        newQuote.Pricing_Server_Deal_Type_Nm__c = quote.application;
        newQuote.Pricing_End_Customer__c = writeInUnifiedId;
        newQuote.Pricing_AdditionalRecipients__c = quote.additionalQuoteLetterRecipients;
        if(!isUpdateDraftQuote && !Pricing_RestAPI_Quotes.isSvdQuote){
            newQuote.RecordTypeId = quoteCreateRecordTypeId;
        }
        else
        {
            newQuote.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create);
        }
        return newQuote;
    }
    
    public static List<Pricing_Quote_Team__c> createFSEQuoteTeam(Id newQuoteId){
        Set<id> userIds = new Set<Id>();
        //validFSEEmailIdMap
        List<Pricing_Quote_Team__c> fseQTM = new List<Pricing_Quote_Team__c>();
        if(createNewQTMMap.get('FSE') != null){
            for(Pricing_Quote_Team__c q: createNewQTMMap.get('FSE')){
                if(validFSEEmailIdMap.containsKey(q.Pricing_Quote_Team_Member_Id__r.Email)){
                    validFSEEmailIdMap.remove(q.Pricing_Quote_Team_Member_Id__r.Email);
                }
            }
        }
        for(String fseEmail : validFSEEmailIdMap.keySet()){
            Id userId = validFSEEmailIdMap.get(fseEmail);
            if(!userIds.contains(userId) && !primaryFSEEmail.equalsIgnoreCase(fseEmail)){
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
        //validFSEEmailIdMap
        List<Pricing_Quote_Team__c> aeQTM = new List<Pricing_Quote_Team__c>();
        for(User aeUser : AEEmailUserList){
            Id userId = aeUser.Id;
            if(!userIds.contains(userId) && !primaryAEEmail.equalsIgnoreCase(aeUser.Email)){
                userIds.add(userId);
                aeQTM.add(new Pricing_Quote_Team__c(Pricing_Quote_Id__c=newQuoteId, Pricing_Quote_Team_Member_Id__c=userId, 
                                                    Pricing_Role_Nm__c = Label.Pricing_Quote_Team_Role_Account_Executive, RecordTypeId = quoteTeamRecordTypeId));
            }
        }
        return aeQTM;
    }
    
    public static List<Pricing_Quote_Team__c> createITSQuoteTeam(Id newQuoteId){
        Set<id> userIds = new Set<Id>();
        //validFSEEmailIdMap
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
    
    public static List<SBQQ__QuoteLine__c> createQuoteLineRecords(Id quoteId, List<Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI> quoteLines){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineDCAI q: quoteLines){
            SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
            newQuoteLine.SBQQ__Quote__c = quoteId;
            newQuoteLine.Pricing_End_Date_dt__c = Date.parse(q.quoteLinePricingEndDate);
            newQuoteLine.SBQQ__Product__c =(Id) q.productId;
            newQuoteLine.Pricing_Product_Nm__c =(Id) q.productId;
            newQuoteLine.Pricing_Other_Product_Nm__c = String.isEmpty(q.writeInProduct) ? null : q.writeInProduct.trim();
            //newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
            newQuoteLine.Pricing_Systems_qty__c = q.noOfSystems;
            newQuoteLine.Pricing_CPUs_per_system_qty__c = q.noOfCPUsPerSystem;
            //newQuoteLine.Pricing_Single_System_Price_Amt__c = q.singleSystemPrice;
            //newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = q.requestedDiscountUnitPrice;
            //newQuoteLine.Pricing_Additional_OEM_Discount_Amt__c = q.additionalDiscount;
            //newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
            //newQuoteLine.Pricing_Competitor_System_Model_Nm__c = q.competitorSystemModel;
            newQuoteLine.Pricing_Competetor_Product__c =(Id) q.competitorProductId;
            newQuoteLine.Pricing_Other_Competitor_Product_Nm__c = String.isEmpty(q.competitorWriteInProduct) ? null : q.competitorWriteInProduct.trim();
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = q.competitorNoOfSystems;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = q.competitorNoOfCPUsPerSystem;
            //newQuoteLine.Pricing_Comp_Single_System_Price_Amt__c = q.competitorSingleSystemPrice;
            //newQuoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c = q.competitorAdditionalDiscount;
            newQuoteLine.Pricing_Additional_Comments_Txt__c = q.additionalComment;
            if(!Pricing_RestAPI_Quotelines.isSvdQuoteLine && !Pricing_RestAPI_Quotes.isSvdQuote){
                newQuoteLine.Pricing_OEM_System_Model_Nm__c = q.systemModel;
                newQuoteLine.Pricing_Single_System_Price_Amt__c = q.singleSystemPrice;
                newQuoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = q.customerStdUnitPrice;
                newQuoteLine.Pricing_Additional_OEM_Discount_Amt__c = q.additionalDiscount;
                newQuoteLine.Pricing_Competitor_OEM_Nm__c = q.competitorName;
                newQuoteLine.Pricing_Competitor_System_Model_Nm__c = q.competitorSystemModel;
                newQuoteLine.Pricing_Comp_Single_System_Price_Amt__c = q.competitorSingleSystemPrice;
                newQuoteLine.Pricing_Comp_Additional_OEM_Disc_Amt__c = q.competitorAdditionalDiscount;
            }
            if(Pricing_RestAPI_Quotelines.isCreateDraftQuoteLine || isUpdateDraftQuote){
                if(Pricing_RestAPI_Quotelines.isSvdQuoteLine || Pricing_RestAPI_Quotes.isSvdQuote) {
                    newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine ? quoteLineSVDCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineSVDCreateRecordTypeId : assignedRecordTypeId;
                }
                else
                    newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine ? quoteLineCreateRecordTypeId : isUpdateDraftQuote && (q.quoteLineId == null || String.isBlank(q.quoteLineId.trim())) ? quoteLineCreateRecordTypeId : assignedRecordTypeId;
            }
            else if(Pricing_RestAPI_Quotelines.isSvdQuoteLine || Pricing_RestAPI_Quotes.isSvdQuote) {
                newQuoteLine.RecordTypeId = !isUpdateDraftQuote && !Pricing_RestAPI_Quotelines.isUpdateDraftQuoteLine ? quoteLineSVDCreateRecordTypeId : assignedRecordTypeId;
            }
            quoteLineList.add(newQuoteLine);
        }        
        return quoteLineList;
    }
    
    public static List<Pricing_Performance_Metric__c> createPerformanceMetricsRecord(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetricsWrapperDCAI permets){
        List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
        for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics permet : permets.performanceMetrics){
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
    public static void createPerformanceMetricsRecord(Id quoteLineId, List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics> permets, List<Pricing_Performance_Metric__c> perfMetricsLst){
        List<Pricing_Performance_Metric__c> perfMetrics = new List<Pricing_Performance_Metric__c>();
        for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics permet : permets){
            Pricing_Performance_Metric__c metric = new Pricing_Performance_Metric__c();
            if(permet.performanceMetricsId != null && !String.isEmpty(permet.performanceMetricsId)){
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
    
    public static List<Pricing_Comments__c> createQuoteComments(Id quoteId, List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment> quoteComments){
        List<Pricing_Comments__c> commsTobeUpserted = new List<Pricing_Comments__c>();
        if(qComms.isEmpty()){
            qComms = [SELECT id,Pricing_Answer__c,Pricing_Question__c,Pricing_Comment_Ref_Id__c FROM Pricing_Comments__c WHERE Pricing_Quote__c= : quoteId and Pricing_Quote__r.SBQQ__Account__c = :currentUserAccountId]; 
        }       
        if(quoteComments != null && quoteComments.size() > 0){
            for(Pricing_RestAPI_QuotesUtilityV2.QuoteComment qComment : quoteComments){
                boolean qFlag = false;               
                for(Pricing_Comments__c qComm : qComms){                    
                    if(qComment.quoteCommentReferenceId == qComm.Pricing_Comment_Ref_Id__c) {                       
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
            List<SBQQ__QuoteLine__c> lstQuoteLine = new List<SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c quoteLine: quoteLineIdMap.values()){
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview; 
                if(quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                    quoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SVD_Quote_Line_Submitted);
                }else{
                    quoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
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
                for(SBQQ__QuoteLine__c qli: [select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where id In :quoteLineIds and Pricing_Status_Nm__c =:Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview]){
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
            if(objType=='SBQQ__Quote__c'&&(!String.isEmpty(primaryContactEmailId) && currentUser.Email != primaryContactEmailId)){
                List<User> usrs = [SELECT id,ContactId FROM User WHERE Email = :primaryContactEmailId AND AccountId= :accountId];
                if(usrs.size() > 0){
                    List<SBQQ__Quote__c> quotes = [SELECT Id,SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE Id= :recId] ;
                    if(quotes.size() > 0){
                        quotes[0].SBQQ__PrimaryContact__c = usrs[0].ContactId;
                        update quotes[0];
                    }
                }
            }
        }catch(Exception exp){Pricing_Tender_Utility.logError(exp);}
        
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
        public String secondaryContact {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public List<QuoteLine> quoteLines {set;get;}
        public List<QuoteComment> quoteComments {set;get;}
    }
    public class QuoteLineWrapper {
        public String quoteId {set;get;}
        public List<QuoteLine> quoteLines {set;get;}
    }
    public class QuoteLine {
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quoteLinePricingStartDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public Decimal singleSystemPrice {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedDiscountUnitPrice {set;get;}
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
        
        //won/lost wrapper
        public String quotelineId {set;get;}
        public String status {set;get;}
        public String wonLostComments {set;get;}
        public String lostReason {set;get;}
        
        //change request wrapper
        public Decimal newRequestedDiscountUnitPrice {set;get;}
        public Decimal newRequestedPrice {set;get;}
        public Decimal newQuantity {set;get;}
    }
    
    public class PerformanceMetricsWrapper {
        public String quoteLineId {set;get;}
        public List<PerformanceMetrics> performanceMetrics {set;get;}
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
    public class QuoteCommentWrapper {
        public String quoteId {set;get;}
        public List<QuoteComment> quoteComments {set;get;}
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
    
    public class MyPickListInfo{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
        public MyPickListInfo(){ 
        }
    }
    /***********************************************************************************************/
}