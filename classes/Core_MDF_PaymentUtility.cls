public without sharing class Core_MDF_PaymentUtility {
    
    public static string blank = '';
    public static string zero = '0';
    public static string curr = 'USD';
    public static string intelLegalCode = '100';
    public static string intelCoCode = '760';
    public static string iZero = 'I0';
    public static string iOne = 'I1';    
    public static string tab = '\t';
    public static string newline = '\r\n';
    public static string underscore = '_';
    public static string batchName = 'AP';
    public static string one = '1';
    public static string customer = 'Customer';
    public static string noncustomer = 'Non-Customer';
    public static string distributorCash = 'Distributor (Cash)';
    public static string distributorCreditMemo ='Distributor (Credit Memo)';
    public static string customerPassThrough = 'Customer (Pass Through)';
    public static string customerCreditMemo = 'Customer (Credit Memo)';
    public static string vistexCash = 'Vistex (Cash)';
    public static string vistexCreditMemo = 'Vistex (Credit Memo)';
    public static string cogtmVistex = 'CoGTM Vistex';
    public static string cogtmContraCSAR = 'Contra CSAR';
    public static string cogtmContraVistex = 'Contra Vistex';
    public static string expense ='Expense';
    public static string csarCash = 'CSAR Cash';
    public static string csarCreditMemo ='CSAR Credit Memo';
    public static string creditMemoFileName = 'CSAR_CREDIT';
    public static string space =' ';
    public static string indiaComments='_US';
    public static string customerNonPO = 'Customer-NonPO';

    // IPA Credit Memo File headers
    public static string creditHeader1 ='Sold-To Number';
    public static string creditHeader2 = 'Ship-To Number';
    public static string creditHeader3 ='Sales Org';
    public static string creditHeader4 ='Distribution Channel';
    public static string creditHeader5 ='Material ID';
    public static string creditHeader6 = 'Adjust amt/unit';
    public static string creditHeader7 ='Unit Qty';
    public static string creditHeader8 ='Reference #';
    public static string creditHeader9 ='Relevant Intel Qtr (YYYYQQ)';
    public static string creditHeader10 ='Internal Comments';
    public static string creditHeader11 ='External Comments';
    public static string creditHeader12 ='Actual Unit Qty';
    public static string creditHeader13 ='Channel Program Id';
    //End
    
    public static string distributionChannel = '02';
    private static String IPAProgram=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
    private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
    private static String paymentDue=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Payment_Due');
    public static Map<String,String> acctProgIdToPGMRec = new Map<String,String>();
    public static String surePay = Label.Core_MDF_nonTranslate_Sure_Pay;
    public static string REVIEW_COMPLETED = Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED ;
    /****************************************************************************************************** 
Method Name:        fetchMetaDataRecord
@return  :          Map of string and metadata object
@parameters:        N/A
Description:        This method is used to get metadata records and create map
Added By:           Accenture - VD - 03/15/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    /*public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> fetchMetaDataRecord(){
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Payment_RecordType_txt__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_Name_txt__c,recTypeMetaData);  
                                                                       }
        return mapOfRecordTypes;
        
    }*/
    
    /****************************************************************************************************** 
Method Name:        queryPaymentDueClaimsForPayment
@return  :          list of payment due claims
@parameters:        List of payment run records
Description:        This method is used to query payment due claims for payment process
Added By:           Accenture - AD - 06/10/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/   
    public static List<PartnerFundClaim> queryPaymentDueClaimsForPayment(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        // Geo Set
        Set<String> geoSet = new Set<String>();
        // Subgeo Set
        Set<String> subgeoSet = new Set<String>();
        // Program Set 
        Set<String> programSet = new Set<String>();
        // payment start date set
        Set<Date> payStartDt = new Set<Date>();
        // payment end date set
        Set<Date> payEndDt = new Set<Date>();
        // Budget Type Set
        Set<String> budgetTypeSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');   
        List<String> validClaimTypeForOffsetProcess = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Claim_Type',',');
        //Pending Available Fund Label
        String pafLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Available_Fund') ;
        //Adjustment Label
        String adjusTypeLabel = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Adjustment_Type') ;
        Set<String> paymentType = new Set<String>();
        List<Id> setOfSelAccounts = new List<Id>();
        for(Core_MDF_Payment_Run__c prun : paymentRunRecordsTobeProcessed){
            geoSet.add(prun.Core_MDF_Geo_Txt__c);
            programSet.add(prun.Core_MDF_Program_Id__r.Name);
            //start date, end date, budget type and subgeo will be only available for Retail program, Channel MDF and not for CCP program
            if(prun!=null && prun.Core_MDF_Program_Id__r.Name !=null && (prun.Core_MDF_Program_Id__r.Name == Label.Core_MDF_Retail_Program_Name || prun.Core_MDF_Program_Id__r.Name == IPAProgram || prun.Core_MDF_Program_Id__r.Name == CoGTMProgram)){
                payStartDt.add(prun.Core_MDF_Start_Dt__c);
                payEndDt.add(prun.Core_MDF_End_Dt__c);
                if(prun.Core_MDF_Budget_Type_nm__c!=null){
                List<String> budgetTypes = prun.Core_MDF_Budget_Type_nm__c.split(';');
                budgetTypeSet.addAll(budgetTypes );
                
                }
              subgeoSet.add(prun.Core_MDF_Subgeo_Txt__c);
              if(String.isNotBlank(prun.Core_MDF_Payment_Types_txt__c))
              {
                paymentType.addAll(prun.Core_MDF_Payment_Types_txt__c.split(';')); 
              }
              if(prun.Core_MDF_Program_Id__r.Name == CoGTMProgram && prun.Core_MDF_Payment_run_for_Accounts__c == null && prun.Core_MDF_Account_Id__c != null){
                setOfSelAccounts.add(prun.Core_MDF_Account_Id__c);
              }
              
            }
              
        }
        
        //List of payment due claims to be processed
        List<PartnerFundClaim> paymentDueClaimsTobeProcessed = new List<PartnerFundClaim>();
        if(programSet.contains(Label.Core_MDF_Retail_Program_Name) || programSet.contains(IPAProgram) || programSet.contains(CoGTMProgram)){
            //Payment Due label
            String paymentDueLabel = paymentDue;
            //Existing Retail Payment Due Claims
            String paymentDueClaimsQuery = 'Select Id, Core_MDF_AccountCompany__c,Core_MDF_Applicable_VAT_Percentage_nm__c,Core_MDF_Bank__r.Core_MDF_Bank_Location__c,Core_MDF_Bank__r.Core_MDF_Currency_cd__c,Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Sub_Region_Cd__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Bank__r.Core_MDF_Bank_Beneficiary_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c,Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c,Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c,Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c,ChannelPartner.Name,ChannelPartner.Core_MDF_Group_Id__c,Title,Core_MDF_Program__c,Core_MDF_Status__c,Status,Core_MDF_Country_Location_nm__c,Request.Core_MDF_Activity_Number__c,Core_MDF_Activity_Types__c,Core_MDF_Ad_Run_Start_Date__c,Core_MDF_Ad_Run_End_Date__c,CreatedDate,Request.ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Audit_Adjustment_Amount__c,Amount,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Region_Cd__c,ChannelPartnerId,Core_MDF_Payment_Id__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_RMF_Claim_Approval_Dt__c,Core_MDF_RMF_Last_POP_Submission_Dt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c, Core_MDF_Bank__r.Core_MDF_VAT_pct__c, Core_MDF_Claim_Ref_Number__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_Quarter_Year_txt__c,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_VAT_Amt__c,Core_MDF_C_Type_Ind__c, Core_MDF_Total_Claim_Recovery_Amount__c, Request.Core_MDF_BU1_Split_Percent_nbr__c,Request.Core_MDF_BU2_Split_Percent_nbr__c,Request.Core_MDF_BU3_Split_Percent_nbr__c,Request.Core_MDF_BU_Split__c,Request.Core_MDF_BU4_Split_Percent_nbr__c,Request.Core_MDF_BU5_Split_Percent_nbr__c,Request.Core_MDF_BU6_Split_Percent_nbr__c,Request.Core_MDF_BU7_Split_Percent_nbr__c,Request.Core_MDF_BU8_Split_Percent_nbr__c,Request.Core_MDF_BU9_Split_Percent_nbr__c,Request.Core_MDF_BU10_Split_Percent_nbr__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Type_Txt__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id,Request.Campaign.Name,Request.Title, Request.Core_MDF_Intel_Activity_Owner_Id__r.Name, Request.Core_MDF_Member_Owner_txt__c,Request.Core_MDF_Priorities__c,Request.Core_MDF_ProductType__c,Request.Core_MDF_TargetAudience__c,Budget.Title, Request.Campaign.Core_MDF_Member_Acceptor_id__c,Request.Campaign.Core_MDF_Member_Acceptor_id__r.Name, Core_MDF_Claim_Approval_Dt__c, Request.Campaign.Core_MDF_Product_Type__c, Request.Core_MDF_End_Date__c, Core_MDF_Campaign_Id__r.Core_MDF_Intel_Owner_id__c,Core_MDF_Campaign_Id__r.Core_MDF_Intel_Owner_id__r.Name,Core_MDF_Campaign_Id__r.Core_MDF_Priority__c,Core_MDF_Campaign_Id__r.Core_MDF_MMID__c,Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c FROM PartnerFundClaim WHERE Core_MDF_Region_Cd__c IN: geoSet AND Core_MDF_Program__c IN: programSet AND (Core_MDF_Status__c=:paymentDueLabel AND Core_MDF_Type_Txt__c  IN:validClaimTypeForOffsetProcess) AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded AND Core_MDF_Recovery_Hold_Ind__c = FALSE AND (Core_MDF_Processing_Preference_nm__c !=: surePay OR (Core_MDF_Processing_Preference_nm__c =: surePay AND (Core_MDF_VAT_Eligibility_Ind__c = TRUE OR (Core_MDF_Claim_Review_Case__c = NULL OR (Core_MDF_Claim_Review_Case__c != NULL AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c =: REVIEW_COMPLETED)))))';
            if(subgeoSet != Null && subgeoSet.size()>0)
            {
                paymentDueClaimsQuery += ' AND Core_MDF_Sub_Region_Cd__c IN : subgeoSet';                         
            }
            
            if(payStartDt != NULL && payStartDt.size()>0)
            {
                paymentDueClaimsQuery+= ' AND Core_MDF_Ad_Run_Start_Date__c >=:payStartDt';
            }
            if(payEndDt != NULL && payEndDt.size()>0)
            {
                paymentDueClaimsQuery+= ' AND Core_MDF_Ad_Run_End_Date__c <=:payEndDt';
            }
            if(programSet.contains(IPAProgram) || programSet.contains(CoGTMProgram)){
                paymentDueClaimsQuery += ' AND Core_MDF_Payment_Type_nm__c IN : paymentType';
            }
            if(programSet.contains(CoGTMProgram) && setOfSelAccounts != null && setOfSelAccounts.size() > 0){
                paymentDueClaimsQuery += ' AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN : setOfSelAccounts';
            }
            paymentDueClaimsTobeProcessed = Database.query(String.escapeSingleQuotes(paymentDueClaimsQuery));            
        }
        else{
            //Existing CCP Payment Due Claims
            paymentDueClaimsTobeProcessed =  
                [SELECT Id,Title,Core_MDF_Country_Location_nm__c,ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Program__c,Core_MDF_AccountCompany__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Amount,Status,Core_MDF_Status__c,
                Core_MDF_Bank__r.Core_MDF_Bank_Beneficiary_Name__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c, Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Budget_Type_Options_Nm__c,Request.Core_MDF_Product_Category_txt__c, Core_MDF_Quarter_Year_txt__c,Core_MDF_Payment_Id__c,Core_MDF_C_Type_Ind__c,Core_MDF_VAT_Eligibility_Ind__c
                ,Request.Title,
                Request.Core_MDF_Intel_Activity_Owner_Id__c,
                Request.Core_MDF_Intel_Activity_Owner_Id__r.Name,Request.Core_MDF_Member_Owner_txt__c,Request.Core_MDF_Priorities__c,
                Request.Core_MDF_ProductType__c,Request.Core_MDF_TargetAudience__c,Request.Campaign.Name  FROM PartnerFundClaim WHERE Core_MDF_Region_Cd__c IN:geoSet AND Core_MDF_Program__c =:programSet AND Core_MDF_Status__c=:paymentDue AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded AND Core_MDF_Recovery_Hold_Ind__c = FALSE AND (Core_MDF_Processing_Preference_nm__c !=: surePay OR (Core_MDF_Processing_Preference_nm__c =: surePay AND (Core_MDF_VAT_Eligibility_Ind__c = TRUE OR (Core_MDF_Claim_Review_Case__c = NULL OR (Core_MDF_Claim_Review_Case__c != NULL AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c =: REVIEW_COMPLETED)))))];
        }
        return paymentDueClaimsTobeProcessed;
    }

/****************************************************************************************************** 
Method Name:        getPaymentTypeToClaimList
@return  :          Map of Payment Type To List of Claims
@parameters:        List of payment due claims
Description:        This method is used to create map of payment type to claims
Added By:           Mayuri Dhanjani
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
public static Map<String,List<PartnerFundClaim>> getPaymentTypeToClaimList(List<PartnerFundClaim> claimsList)
{
    
    Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
    String Key ;
    String paymentType;
    for(PartnerFundClaim claim : claimsList) 
    { 
        if(String.isNotBlank(claim.Core_MDF_Payment_Type_nm__c))
        {  
            Key = getPaymentTypeKey(claim.Core_MDF_Payment_Type_nm__c);
            if(paymentTypeToClaims.containsKey(Key)){ 
                paymentTypeToClaims.get(Key).add(claim);
            }
            else {
                paymentTypeToClaims.put(Key, new List<PartnerFundClaim>{claim});
            }
        }
    }
    return paymentTypeToClaims;
}
/****************************************************************************************************** 
Method Name:        getPaymentTypeKey
@return  :          String
@parameters:        String
Description:        This method is used to return key based on payment type
Added By:           Mayuri Dhanjani
Modified By:        Date:       Changes: 
*******************************************************************************************************/  

public static String getPaymentTypeKey(String paymentType)
{ 
    //Create Key based on Payment Type
    String PaymentTypekey='';
    if(paymentType == Core_MDF_PaymentUtility.noncustomer || paymentType == Core_MDF_PaymentUtility.customerNonPO){
        PaymentTypekey = 'Expense';
    }
    else if(paymentType == Core_MDF_PaymentUtility.customer || paymentType == Core_MDF_PaymentUtility.distributorCash)
    {
        PaymentTypekey = 'CSAR Cash';
    }
    else if(paymentType == Core_MDF_PaymentUtility.distributorCreditMemo  || paymentType == Core_MDF_PaymentUtility.customerPassThrough || paymentType == Core_MDF_PaymentUtility.customerCreditMemo){
        
        PaymentTypekey = 'CSAR Credit Memo';
    }
    else if(paymentType == Core_MDF_PaymentUtility.vistexCash || paymentType == Core_MDF_PaymentUtility.vistexCreditMemo){
        PaymentTypekey = Core_MDF_PaymentUtility.cogtmVistex;
    }
    return PaymentTypekey;

}
/****************************************************************************************************** 
Method Name:        getPaymentTypeKey
@return  :          String
@parameters:        String
Description:        This method is used to return key based on payment type
Added By:           Mayuri Dhanjani
Modified By:        Date:       Changes: 
*******************************************************************************************************/ 
public static Map<Id,Core_MDF_Comarketing_CMF_Map__c> getCMFRecords(List<PartnerFundClaim> paymentDueClaimsTobeProcessed)
{
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmpMap = new Map<Id,Core_MDF_Comarketing_CMF_Map__c>();
    for(PartnerFundClaim pfc :paymentDueClaimsTobeProcessed)
    {
        accountIdSet.add(pfc.ChannelPartnerId);
    }
    if(!accountIdSet.isEmpty())
    {
        for(Core_MDF_Comarketing_CMF_Map__c  cmf : [Select Id,Core_MDF_Account_Id__c,Core_MDF_Ship_To_Number_Id__c,Core_MDF_Sold_To_Number_Id__c,Core_MDF_Sales_Org_cd__c,Core_MDF_Distribution_Channel_cd__c from Core_MDF_Comarketing_CMF_Map__c where Core_MDF_Account_Id__c IN : accountIdSet and Core_MDF_Active_Ind__c = true])
        {
            String key = String.valueOf(cmf.Core_MDF_Account_Id__c);
            cmpMap.put(key,cmf);
        }
    
    }
    return cmpMap;   
}
    /****************************************************************************************************** 
Method Name:        restrictOnUploadContentFile
@return  :          N/A
@parameters:        list of content document link obj
Description:        This method is used to restrict payment upload content file manually
Added By:           Accenture - AD - 07/23/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
    public static void restrictOnUploadPaymentFile(List<ContentDocumentLink> newContentFiles){
        //To hold object api name
        String sObjectName;
        //set of content document ids
        Set<Id> contentDocumentIdSet = new Set<Id>();
        //Map of content document id to content verion reason for change
        Map<Id,ContentVersion> mapOfContentVersion = new Map<Id,ContentVersion>();
        //List of object to restrict file upload
        List<String> objectsToRestrictFileUpload = (System.Label.Core_ObjectCodeForRestrictUploadFiles).split(',');
        for(ContentDocumentLink contentDocumentLink : newContentFiles){
            contentDocumentIdSet.add(contentDocumentLink.ContentDocumentId);            
        }
        //fetching content versions for corresponding to content document and creating map of it
        for(ContentVersion contentVersion : [SELECT ContentDocumentId,ReasonForChange 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId IN:contentDocumentIdSet
                                             AND ReasonForChange=:Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange')]){
                                                 mapOfContentVersion.put(contentVersion.ContentDocumentId,contentVersion);
                                             }
        for(ContentDocumentLink contentDocumentLink : newContentFiles){
            //Object record Id
            Id objectRecordId = contentDocumentLink.LinkedEntityId;
            if(String.valueOf(objectRecordId)!=null && String.valueOf(objectRecordId)!=''){
                //Getting object api name by Id
                sObjectName = String.valueOf(objectRecordId.getSObjectType());
            }
            if(sObjectName!=null && objectsToRestrictFileUpload !=null &&
               objectsToRestrictFileUpload.contains(sObjectName)){
                   if(mapOfContentVersion == null || mapOfContentVersion.isEmpty() ||
                      !mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId) ||
                     (mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId) &&
                     mapOfContentVersion.get(contentDocumentLink.ContentDocumentId).ReasonForChange == null)){                       
                       contentDocumentLink.addError(System.Label.Core_ContentFileUploadErrorMsg);
                   }else{
                       if(mapOfContentVersion.ContainsKey(contentDocumentLink.ContentDocumentId)){
                       mapOfContentVersion.get(contentDocumentLink.ContentDocumentId).ReasonForChange = '';
                       }
                   }
               }
        }
        if (String.isNotBlank(sObjectName) &&
            objectsToRestrictFileUpload !=null &&
            objectsToRestrictFileUpload.contains(sObjectName)
            && mapOfContentVersion != null && !mapOfContentVersion.isEmpty()
            && mapOfContentVersion.values() != null && !mapOfContentVersion.values().isEmpty()) {
                try{
                  Database.update(mapOfContentVersion.values());  
                }catch(Exception e){
                    Core_MDF_CCP_UtilityClass.logError(e);
                }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        fetchBudgetTypeAndRecTypeMetaData
@return  :          Map of budget type and its corresponding record type
@parameters:        N/A
Description:        This method is used to get budget type and record type metadata records and create map
Added By:           Accenture - AD - 05/12/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<String,String> fetchBudgetTypeAndRecTypeMetaData(){
        //Map of budget type to record type
        Map<String,String> budgetTypeAndRecordTypeMap = new Map<String,String>();
        for(Core_MDF_Program_Budget_RecordType__mdt budgetTypeAndRecTypeMetaData:[Select Core_MDF_BudgetType__c,Core_MDF_RecordType__c,Core_MDF_Program__c from Core_MDF_Program_Budget_RecordType__mdt LIMIT 1000 ]){
            if(budgetTypeAndRecTypeMetaData.Core_MDF_BudgetType__c != NULL){
                String programBudgetType = budgetTypeAndRecTypeMetaData.Core_MDF_Program__c+budgetTypeAndRecTypeMetaData.Core_MDF_BudgetType__c;
                budgetTypeAndRecordTypeMap.put(programBudgetType,budgetTypeAndRecTypeMetaData.Core_MDF_RecordType__c);
            }
            else{
                budgetTypeAndRecordTypeMap.put(budgetTypeAndRecTypeMetaData.Core_MDF_Program__c,budgetTypeAndRecTypeMetaData.Core_MDF_RecordType__c);
            }
        }
        return budgetTypeAndRecordTypeMap;
        
    }
    
/****************************************************************************************************** 
Method Name:        isRsaMd
@return  :          boolean
@parameters:        N/A
Description:        This method is used to check whether RSA MD or not
Added By:           Accenture - AD - 06/2/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Boolean isRsaMd(Core_MDF_Payment_Run__c pRunInstance){
        //to hold flag result
        Boolean isRsaMd = false;
        //Checking if budget type is RSA MD
        if(pRunInstance!=null && pRunInstance.Core_MDF_Budget_Type_nm__c!=null &&
           pRunInstance.Core_MDF_Budget_Type_nm__c==Label.Core_MDF_Retail_RSA_MD_Budget_Type){
               isRsaMd = true;
           }
        return isRsaMd;
    }
    
    /****************************************************************************************************** 
Method Name:        isRetailMdf
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether Retail MDF/IPA  or not
Added By:           Pranav - Accenture - 14/07/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    /*public static Boolean isRetailMdfOrIPA(Core_MDF_Payment_Run__c pRunInstance){
        //to hold flag result
        Boolean isRetailMdfIpa = false;
        //Checking if budget type is Retail MDF
        if((pRunInstance!=null && pRunInstance.Core_MDF_Budget_Type_nm__c!=null &&
            pRunInstance.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType)) 
           || (pRunInstance!=null && pRunInstance.Core_MDF_Program_Id__r.Name == IPAProgram)){
               isRetailMdfIpa = true;
           }
        return isRetailMdfIpa;
    }*/
  /****************************************************************************************************** 
Method Name:        isIPAMDF
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether IPA  or not
Added By:           Mayuri Dhanjani
Modified By:        Date:       Changes: 
*******************************************************************************************************/
public static Boolean isIPAMdf(Core_MDF_Payment_Run__c pRunInstance){
    //to hold flag result
    Boolean isIpa = false;
    //Checking if budget type is Retail MDF
    if(pRunInstance!=null && pRunInstance.Core_MDF_Program_Id__r.Name == IPAProgram){
        isIpa = true;
       }
    return isIpa;
}
/****************************************************************************************************** 
Method Name:        isCoGTMCSARPaymentRun
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether payment run is of Co-GTM CSAR Type
Added By:           Vikas Soni  Date: 25/07/2025
Modified By:        Date:       Changes: 
*******************************************************************************************************/
public static Boolean isCoGTMCSARPaymentRun(Core_MDF_Payment_Run__c pRunInstance){
    //to hold flag result
    Boolean isCoGTMCSAR = false;

    //Checking if budget type is Retail MDF
    if(pRunInstance != null && pRunInstance.Core_MDF_Program_Id__r.Name == CoGTMProgram && pRunInstance.Core_MDF_Payment_Nature_nm__c == Core_MDF_PaymentUtility.cogtmContraCSAR) {
        isCoGTMCSAR = true;
    }
    return isCoGTMCSAR;
}
/****************************************************************************************************** 
Method Name:        isCoGTMVistexPaymentRun
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether payment run is of Co-GTM Vistex Type
Added By:           Vikas Soni  Date: 07/08/2025
Modified By:        Date:       Changes: 
*******************************************************************************************************/
public static Boolean isCoGTMVistexPaymentRun(Core_MDF_Payment_Run__c pRunInstance){
    //to hold flag result
    Boolean isCoGTMVistex = false;

    //Checking if budget type is Retail MDF
    if(pRunInstance != null && pRunInstance.Core_MDF_Program_Id__r.Name == CoGTMProgram && pRunInstance.Core_MDF_Payment_Nature_nm__c == Core_MDF_PaymentUtility.cogtmContraVistex) {
        isCoGTMVistex = true;
    }
    return isCoGTMVistex;
}
/****************************************************************************************************** 
Method Name:        isCoGTMExpensePaymentRun
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether payment run is of Co-GTM Expense Type
Added By:           Vikas Soni  Date: 10/10/2025
Modified By:        Date:       Changes: 
*******************************************************************************************************/
public static Boolean isCoGTMExpensePaymentRun(Core_MDF_Payment_Run__c pRunInstance){
    //to hold flag result
    Boolean isCoGTMExpense = false;

    //Checking if budget type is Retail MDF
    if(pRunInstance != null && pRunInstance.Core_MDF_Program_Id__r.Name == CoGTMProgram && pRunInstance.Core_MDF_Payment_Nature_nm__c == Core_MDF_PaymentUtility.expense) {
        isCoGTMExpense = true;
    }
    return isCoGTMExpense;
}
/****************************************************************************************************** 
Method Name:        isRetailMdf
@return  :          boolean
@parameters:        Payment Run Instance
Description:        This method is used to check whether Retail MDF or not
Added By:           Mayuri Dhanjani
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Boolean isRetailMdf(Core_MDF_Payment_Run__c pRunInstance){
   
          //to hold flag result
          Boolean isRetailMdf = false;
          //Checking if budget type is Retail MDF
          if((pRunInstance!=null && pRunInstance.Core_MDF_Budget_Type_nm__c!=null &&
              pRunInstance.Core_MDF_Budget_Type_nm__c.contains(Label.Core_MDF_RetailMDF_BudgetType))){
                isRetailMdf = true;
             }
          return isRetailMdf;

    }
    /****************************************************************************************************** 
    Method Name:        isChannelMDF
    @return  :          Boolean
    @parameters:        Payment Run Instance
    Description:        This method is used to check if the program is Channel MDF
    Added By:           JB - Accenture - 03/29/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static Boolean isChannelMDF(Core_MDF_Payment_Run__c pRunInstance){

        Boolean isChannelMDFProgram = false;
        //Checking if Prograam is Channel MDF
        if(pRunInstance != null && pRunInstance.Core_MDF_Program_Id__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name')){
            isChannelMDFProgram = true;
        }
        return isChannelMDFProgram;
    }*/
  
/****************************************************************************************************** 
Method Name:        isMdfOrMdfPlus
@return  :          boolean
@parameters:        PaymentRun instance
Description:        This method is used to check whether MDF and MDF+
Added By:           Accenture - RG - 14/9/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Boolean isMdfOrMdfPlus(Core_MDF_Payment_Run__c pRunInstance){
        //to hold flag result
        Boolean isMdfOrMdfPlus = false;
        //Checking if budget type is MDF or MDF+
        if(pRunInstance!=null && pRunInstance.Core_MDF_Budget_Type_nm__c!=null && (pRunInstance.RecordType.DeveloperName == 'Client_Co_Marketing_Fund_MDF' || pRunInstance.RecordType.DeveloperName == 'Data_Center_Co_Marketing_Fund_MDF')){
               isMdfOrMdfPlus = true;
           }
        return isMdfOrMdfPlus;
    } 


/****************************************************************************************************** 
Method Name:        fetchDistinctBudgetTypes
@return  :          String
@parameters:        Claims List
Description:        This method is used to fetch the distinct budget types from list of claims
Added By:           Accenture - RG - 03/11/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
        public static String fetchDistinctBudgetTypes(List<PartnerFundClaim> claimsToBeProcessed){
            List<String> budgetTypesList = new List<String>();
            String distinctBudgetTypes = '';
            if(claimsToBeProcessed != null){
                for(PartnerFundClaim claim : claimsToBeProcessed){
                    if(!budgetTypesList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)){
                        budgetTypesList.add(claim.Core_MDF_Budget_Type_Options_Nm__c);
                    }
                }
                distinctBudgetTypes = String.Join(budgetTypesList,';');
            }
            return distinctBudgetTypes;
        }
/****************************************************************************************************** 
Method Name:        getPaymentSubCategoryMap
@return  :          paymentSubCategoryWrapper
@parameters:        Program,Geo
Description:        This method is used to get Payment Sub Category key value pair
Added By:           Accenture - AN - 29/07/2024
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static paymentSubCategoryWrapper getPaymentSubCategoryMap(String program,String geo){
        paymentSubCategoryWrapper paymentSubCatWrapper = new paymentSubCategoryWrapper();
        Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> paymentApproverKeyMap = new Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>>();
        Map<string,Core_MDF_CCP_Custom_Metadata_Utility__c> costCenterkeyMap = new Map<String,Core_MDF_CCP_Custom_Metadata_Utility__c>();  
        try{
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> mdtList=[Select id, Core_MDF_Sub_Category__c,Core_MDF_Region_Country__c, Core_MDF_Name_Criteria__c, Core_MDF_Value__c from Core_MDF_CCP_Custom_Metadata_Utility__c where Core_MDF_Category__c = 'Payment' and Core_MDF_Program__c =: program order by Name];
            if(mdtList !=null){
              for(Core_MDF_CCP_Custom_Metadata_Utility__c mdt : mdtList){
                  String paymentSubCategoryKey = mdt.Core_MDF_Sub_Category__c;
                if(paymentSubCategoryKey == 'GEO_APPR' && mdt.Core_MDF_Region_Country__c == geo){
                    if(!paymentApproverKeyMap.containsKey(paymentSubCategoryKey)){  
                        paymentApproverKeyMap.put(paymentSubCategoryKey,new List<Core_MDF_CCP_Custom_Metadata_Utility__c>{mdt});
                    }   
                    else{
                        paymentApproverKeyMap.get(paymentSubCategoryKey).add(mdt);
                    }
                }
                else if(paymentSubCategoryKey == 'COST_CENTER'){
                     costCenterkeyMap.put(mdt.Core_MDF_Region_Country__c,mdt);
                }
              }
              paymentSubCatWrapper.paymentApproverKeyValueMap = paymentApproverKeyMap; 
              paymentSubCatWrapper.costCenterKeyValueMap = costCenterkeyMap;
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
      return paymentSubCatWrapper;

    }
    public class paymentSubCategoryWrapper{
        public Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> paymentApproverKeyValueMap { get; set; }
        public Map<String,Core_MDF_CCP_Custom_Metadata_Utility__c> costCenterKeyValueMap { get; set; }
    }
/****************************************************************************************************** 
Method Name:        getAccountNodeAttributes
@return  :          Map
@parameters:        Claims list
Description:        This method is used to get Account Node Attribute key value pair
Added By:           Accenture - RP - 24/12/2024
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static Map<Id, Core_MDF_Account_Node_Attributes__c> getAccountNodeAttributes(List<PartnerFundClaim> claimsToBeProcessed) {
        Set<Id> channelPartnerIds = new Set<Id>();
        for (PartnerFundClaim claim : claimsToBeProcessed) {
            if (claim.ChannelPartnerId != null) {
                channelPartnerIds.add(claim.ChannelPartnerId);
            }
        }
        
        Map<Id, Core_MDF_Account_Node_Attributes__c> accountNodeAttributesMap = new Map<Id, Core_MDF_Account_Node_Attributes__c>();
        if (!channelPartnerIds.isEmpty()) {
            for (Core_MDF_Account_Node_Attributes__c attr : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Final_CSAR_GL_Account_nbr__c,Core_MDF_Final_NonPO_GL_Account_nbr__c, Core_MDF_Final_Cust_NonPO_GL_Acc_nbr__c, Core_MDF_Program_id__c 
            FROM Core_MDF_Account_Node_Attributes__c WHERE Core_MDF_Account_id__c IN :channelPartnerIds]) {
                accountNodeAttributesMap.put(attr.Core_MDF_Account_id__c, attr);
            }
        }
        return accountNodeAttributesMap;
    }
}