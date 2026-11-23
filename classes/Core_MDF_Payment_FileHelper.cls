public without sharing class Core_MDF_Payment_FileHelper {
    
    
    
    public static Core_MDF_CCP_Payment_File_Particulars__mdt fileParticulars;
    public static Map<String, Core_MDF_Geo_code_Mapping__mdt>  geoMapping;
    public static Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoSubGeoMap;
    //public static Map<String, Core_MDF_Product_Category__mdt>  prodCategoryMapping;
    public static Map<Integer, String> vatPaymentFileMap=new Map<Integer,String>();
    public static Map<Integer, String> nonVatPaymentFileMap=new Map<Integer,String>();
    public static Map<String,String> mapOfInvoiceNoToClaims = new Map<String,String>();
    //public static Map<String, String> paymentFileMapChannelMDF=new Map<String,String>();
    //public static Map<String, Integer> fileCounterChannelMDFMap=new Map<String,Integer>();
    //public static Map<String, Integer> lineCounterChannelMDFMap=new Map<String,Integer>();
    public static Decimal vatLineCounter = 0;
    public static Decimal nonVatLineCounter = 0;
    public static Boolean isVatFile;
    public static String budgetType='';
    public static String programName='';
    public static String subGeo='';
    public final static String VAT='VAT';
    public final static string MDF = 'MDF';
    public final static string CM = 'CM';
    public final static string MDF_RSA = '/MDF/RSA';
    public final static string MDF_IPA = '/MDF/IPA';
    public final static string MDF_CoGTM = '/MDF/COGTM';
    //TWC3117-17274 - Aditya
    public final static string NRE = 'NRE';
    //public final static string MDF_CMDF = '/MDF/CMDF';
    public final static string CTYPE= 'C';
    public final static string NO = 'N';
    public final static string HYPHEN = '-';
    public final static string RSAMD = 'RSAMD';
    public final static string RetailMDF = 'Retail_MDF';
    public final static string IPA = 'IPA';
    public final static string CoGTM = 'Co-GTM';
    //public final static string ChannelMDF = 'Channel_MDF';
    public final static string materialCode='';
    public final static string claimType ='claim';
    
    public final static string CLIENT = 'Client';
    public final static string DATACENTER = 'Datacenter';
    public static string Vistex='Vistex';
    public static string Generic  = 'Generic';
    public static String Zero = '0';
    public static String filePrefix ='';
    // Intel's Work Week
    public static String intelWorkWeek = '';
    public static String geo;
    public static String pRunNumber;
    public static Integer versionNum=0;
    private static String IPAProgram=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
    private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
    private static String contentversionReasonForChange=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
    private static List<String> fileTypes = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Payment_File_Types');
    private static String ASMORegion = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ASMO_Region');

    //Tax code Mapping for Non-VAT Claims
    private static List<String> bankLegalEntity_150_420 = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BankLegalEntity_150_420');
    private static List<String> bankLegalEntity_650_760 = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_BankLegalEntity_650_760');
    private static String taxCode_150_420 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonVatTaxCode_150_420');
    private static String taxCode_650_760 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonVatTaxCode_650_760');

    public static Map<String,String> countryToSalesCodeMapping = new Map<String,String>();
    public static Map<String,String> countryToGeoCodeMapping = new Map<String,String>();

    
    /****************************************************************************************************** 
Method Name:        ccpFileGenerator
@return  :          void 
@parameters:        List of groups for which there should be an entry in the payment file
Description:        This method is used for generating the lineitems to used to create the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static void ccpFileGenerator(Map<String,Core_MDF_PaymentWrapper> grps,Core_MDF_Payment_Run__c pRunInstance, string program){
        
        clearStaticVariables();
        Map<String,String> mapOfbudgetTypeToFileContent = new Map<String,String>();
        Map<String,Integer> mapOfBudgTypeToRowNumber = new Map<String,integer>();
        List<ContentVersion> contentVersList = new List<ContentVersion>(); 
        pRunNumber = pRunInstance.Name;
        string intelCode = '';
        string paymentMethod;
        //Get the metadata for the given program
        fileParticulars = [SELECT Id, Label, Core_MDF_Batch_Header_Record__c, Core_MDF_Batch_Trailer_Record__c, Core_MDF_Invoice_Header_Record__c, Core_MDF_Invoice_Line_Item__c, 
                           Core_MDF_Program__c, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_Cost_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, 
                           Core_MDF_Approver_WWID__c, Core_MDF_City__c, Core_MDF_Region__c, Core_MDF_Country__c, Core_MDF_Postal_Code__c, Core_MDF_Ship_to_Postal_Code__c, Core_MDF_Payment_File_Code__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt
                           where Label =:program Limit 1];

        geo = pRunInstance.Core_MDF_Geo_Txt__c;
       
        Core_MDF_PaymentUtility.paymentSubCategoryWrapper pytWrapper = new Core_MDF_PaymentUtility.paymentSubCategoryWrapper();
        pytWrapper = Core_MDF_PaymentUtility.getPaymentSubCategoryMap(program,geo);
       
        Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> paymentApproverKeyValueMap = pytWrapper.paymentApproverKeyValueMap;
        //To generate line items for the file for each payment record
        if(grps != NULL && grps.size() > 0){
            for(String k : grps.keySet()) {
                String budgetType = '';
                //ATHR - Deeply Nested if 16209
                if(grps.get(k).claimsToBeProcessed == Null || grps.get(k).claimsToBeProcessed.isEmpty() || paymentApproverKeyValueMap == Null) continue;
                //if(grps.get(k).claimsToBeProcessed != Null && grps.get(k).claimsToBeProcessed.size() > 0 && paymentApproverKeyValueMap != Null)
                //{
                    budgetType = grps.get(k).budgetType;
                    //Assign row number in each budget type specific file content
                    if(mapOfbudgetTypeToFileContent.containsKey(budgetType)){
                        Integer exisRowNr= mapOfBudgTypeToRowNumber.get(budgetType);
                        exisRowNr++; //increment existing row number value
                        mapOfBudgTypeToRowNumber.put(budgetType,exisRowNr);
                    }
                    else {
                        Integer rowNumber = 1; //default rownumber value for new budget type file
                        mapOfBudgTypeToRowNumber.put(budgetType,rowNumber); 
                    }
                    PartnerFundCLaim claim = grps.get(k).claimsToBeProcessed[0];
                    intelCode = claim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                    paymentMethod = claim.Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c;
                    List<string> line1 = new List<string>();
                    line1.add(fileParticulars.Core_MDF_Invoice_Header_Record__c);
                    line1.add(fileParticulars.Core_MDF_Invoice_Type__c);
                    line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c != null ? claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c.remove(',') : Core_MDF_PaymentUtility.blank);                        
                    line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c);
                    line1.add(Core_MDF_PaymentUtility.blank);
                    line1.add(fileParticulars.Core_MDF_Region__c);
                    line1.add(intelCode == '' ? Core_MDF_PaymentUtility.intelLegalCode : intelCode);
                    line1.add(grps.get(k).paymentForClaims.Core_MDF_Payment_No_Txt__c);
                    line1.add(system.today().format());
                    line1.add(string.valueOf(grps.get(k).paymentForClaims.Core_MDF_Paid_Amt__c));
                    line1.add(Core_MDF_PaymentUtility.curr);
                    line1.add(Core_MDF_PaymentUtility.blank);
                    line1.add(Core_MDF_PaymentUtility.blank);
                    line1.add(Core_MDF_PaymentUtility.zero);
                    line1.add(Core_MDF_PaymentUtility.zero);
                    line1.add(Core_MDF_PaymentUtility.blank);
                    line1.add(paymentMethod == 'None' ? Core_MDF_PaymentUtility.blank : paymentMethod);
                    line1.add(Core_MDF_PaymentUtility.blank);
                    line1.add(fileParticulars.Core_MDF_City__c);
                    line1.add(fileParticulars.Core_MDF_Region__c);
                    line1.add(fileParticulars.Core_MDF_Postal_Code__c);
                    line1.add(fileParticulars.Core_MDF_Country__c);
                    
                    List<string> line2 = new List<string>();
                    line2.add(fileParticulars.Core_MDF_Invoice_Line_Item__c);
                    if(mapOfBudgTypeToRowNumber.get(budgetType)!=null){
                        line2.add(string.valueOf(mapOfBudgTypeToRowNumber.get(budgetType))); //Assign row number value
                    }
                    line2.add(fileParticulars.Core_MDF_Profit_Center__c == null ? Core_MDF_PaymentUtility.blank : fileParticulars.Core_MDF_Profit_Center__c);
                    line2.add(fileParticulars.Core_MDF_Cost_Center__c == null ? Core_MDF_PaymentUtility.blank : fileParticulars.Core_MDF_Cost_Center__c);
                    line2.add(fileParticulars.Core_MDF_GL_Account__c);
                    line2.add(string.valueOf(grps.get(k).paymentForClaims.Core_MDF_Paid_Amt__c));
                    line2.add(Core_MDF_PaymentUtility.zero);
                    line2.add(Core_MDF_PaymentUtility.zero);
                    if(intelCode == Core_MDF_PaymentUtility.blank || intelCode == Core_MDF_PaymentUtility.intelLegalCode || intelCode == Core_MDF_PaymentUtility.intelCoCode)
                    {
                        line2.add(Core_MDF_PaymentUtility.iOne);
                    }
                    else
                    {
                        line2.add(Core_MDF_PaymentUtility.iZero);
                    }
                    line2.add(Core_MDF_PaymentUtility.blank);
                    line2.add(fileParticulars.Core_MDF_City__c);
                    line2.add(fileParticulars.Core_MDF_Region__c);
                    line2.add(fileParticulars.Core_MDF_Ship_to_Postal_Code__c);
                    line2.add(fileParticulars.Core_MDF_Country__c);
                    line2.add(Core_MDF_PaymentUtility.blank);
                    line2.add(Core_MDF_PaymentUtility.blank);
                    //for TWC3117-5375- Add Approver WWID in payment file for CCF/DCF
                    String approverWWID = getApproversBasedOnThreshold(grps.get(k).paymentForClaims.Core_MDF_Paid_Amt__c,paymentApproverKeyValueMap.get('GEO_APPR'));
                    
                    line2.add(approverWWID != null ? approverWWID : Core_MDF_PaymentUtility.blank);
                    
                    line2.add(fileParticulars.Core_MDF_Commodity_Code__c);
                    line2.add(Core_MDF_PaymentUtility.blank);
                    line2.add(Core_MDF_PaymentUtility.blank);
                    line2.add(Core_MDF_PaymentUtility.blank);
                    line2.add(Core_MDF_PaymentUtility.blank); 
                    
                    string paymentRunRecord = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline + fileLineItemToString(line2) + Core_MDF_PaymentUtility.newline;
                    //Create a map with key as budget type and value as file content
                    if(mapOfbudgetTypeToFileContent.containsKey(budgetType)){
                        String finalPayRunRecord = mapOfbudgetTypeToFileContent.get(budgetType);
                        finalPayRunRecord+= paymentRunRecord;
                        mapOfbudgetTypeToFileContent.put(budgetType,finalPayRunRecord);
                    }
                    else{
                        mapOfbudgetTypeToFileContent.put(budgetType,paymentRunRecord); //mapping budget type & its specific line item
                    }
                //}
                
            }
        }
        for(String eachBudgetType : mapOfbudgetTypeToFileContent.keySet()){
            //Header of the file
            String finalPaymentRunRecord = generateHeader() + Core_MDF_PaymentUtility.newline + mapOfbudgetTypeToFileContent.get(eachBudgetType);
            //End of the file - Appending footer
            finalPaymentRunRecord = finalPaymentRunRecord + generateFooter() + Core_MDF_PaymentUtility.newline;
            contentVersList.addAll(createContentFileForCCP(fileTypes, finalPaymentRunRecord,eachBudgetType,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP'))); //Call createContentFileForCCP Method
        }
        List<Id> contentDocIds = updateContentDocOwner(contentVersList);//update document owner
        attachFileToPRun(contentDocIds, pRunInstance); //To attach files to payment run record
        
    }
    public static void generateIPAPaymentFileForExpense(Map<String,Core_MDF_PaymentFileWrapper> grps,Core_MDF_Payment_Run__c pRunInstance, string program){
        
            clearStaticVariables();
            Map<String,String> mapOfbudgetTypeToFileContent = new Map<String,String>();
            Map<String,Integer> mapOfBudgTypeToRowNumber = new Map<String,integer>();
            pRunNumber = pRunInstance.Name;
            geo = pRunInstance.Core_MDF_Geo_Txt__c;
            string intelCode = '';
            string paymentMethod;
            Integer rowNbr =0;
            Integer rowNbrVAT =0;
            String vatPaymentList = '' ;
            String nonVatPaymentList = '';
            string paymentRunRecord ='';
            Map<Integer,String> paymentMap = new  Map<Integer,String>(); 
            List<ContentVersion> contentVersList = new List<ContentVersion>(); 
            Map<Integer,String> vatPaymentMap=new Map<Integer,String>(); 
            Map<Integer,String> nonVatPaymentMap=new Map<Integer,String>(); 
            Decimal splitLimit= Decimal.valueOf(Label.Core_MDF_Split_Limit_Expense);
            Boolean isCoGTMPaymentRun = (program == CoGTMProgram) ? true : false;
            //Get the metadata for the given program
            fileParticulars = [SELECT Id, Label, Core_MDF_Batch_Header_Record__c, Core_MDF_Batch_Trailer_Record__c, Core_MDF_Invoice_Header_Record__c, Core_MDF_Invoice_Line_Item__c, 
                               Core_MDF_Program__c, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_Cost_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, 
                               Core_MDF_Approver_WWID__c, Core_MDF_City__c, Core_MDF_Region__c, Core_MDF_Country__c, Core_MDF_Postal_Code__c, Core_MDF_Ship_to_Postal_Code__c, Core_MDF_Payment_File_Code__c,
                               Core_MDF_GL_Account_Customer_NonPO__c, Core_MDF_Commodity_Code_Customer_NonPO__c  FROM Core_MDF_CCP_Payment_File_Particulars__mdt
                               where Label =:program Limit 1];

           
          
                                                                           
            geoMapping= new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
            for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_Txt__c, Core_MDF_Geo_Code_Txt__c FROM Core_MDF_Geo_code_Mapping__mdt LIMIT 1000 ])
                                                                            {
                                                                                geoMapping.put(geocode.MasterLabel , geocode);
                                                                            }
                                                                            
                                                                            // Get Country's Geo, SubGeo from the metadata
            countryGeoSubGeoMap= new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();
                                                                            
                                                                            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [Select Core_MDF_Code_2_Digits__c, DeveloperName, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000]){
                                                                                countryGeoSubGeoMap.put(countryGeo.Core_MDF_Code_2_Digits__c, countryGeo);
                                                                            }
            intelWorkWeek = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
             
           
            Core_MDF_PaymentUtility.paymentSubCategoryWrapper pytWrapper = new Core_MDF_PaymentUtility.paymentSubCategoryWrapper();
            pytWrapper = Core_MDF_PaymentUtility.getPaymentSubCategoryMap(program,geo);
            Map<String,List<Core_MDF_CCP_Custom_Metadata_Utility__c>> paymentApproverKeyValueMap = pytWrapper.paymentApproverKeyValueMap;
           //Get all invoice numbers for VAT claims
           getVatInvoiceNumbers(grps);
            //To generate line items for the file for each payment record
            if(grps != NULL && grps.size() > 0){
                for(String k : grps.keySet()) {
                    String budgetType = '';
                    //ATHR - Deeply Nested if 16209
                    if(grps.get(k).claimsToBeProcessed == Null || grps.get(k).claimsToBeProcessed.isEmpty() || paymentApproverKeyValueMap == Null) continue;
                    //if(grps.get(k).claimsToBeProcessed != Null && grps.get(k).claimsToBeProcessed.size() > 0 && paymentApproverKeyValueMap != Null)
                    //{
                       
                        PartnerFundCLaim claim = grps.get(k).claimsToBeProcessed[0];
                        Boolean isClaimPaymentTypeCustomerNonPO = (claim.Core_MDF_Payment_Type_nm__c != null && claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO) ? true : false;
                        intelCode = claim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                   
                        paymentMethod = claim.Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c;
                        List<string> line1 = new List<string>();
                        line1.add(fileParticulars.Core_MDF_Invoice_Header_Record__c);
                        // Invoice Type
                        if(grps.get(k).isCtypeInd || grps.get(k).isRecoveryIncluded)
                        {
                            line1.add('C');
                        }
                        else
                        {
                            line1.add('I');
                        }
                        line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c != null ? claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c.remove(',') : Core_MDF_PaymentUtility.blank);                        
                        line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c);
                        line1.add(Core_MDF_PaymentUtility.blank);
                        line1.add(fileParticulars.Core_MDF_Region__c);
                        line1.add(intelCode == '' ? Core_MDF_PaymentUtility.intelLegalCode : intelCode);
                        //line1.add(grps.get(k).paymentForClaims.Core_MDF_Payment_No_Txt__c);
                       
                        if(grps.get(k).isVatEligible){
                            String vatExtComm = generateExternalCommentsForVat(grps.get(k));
                            if(String.isNotBlank(vatExtComm)){
                                line1.add(vatExtComm);
                            }else{
                                String paymentNumber =  grps.get(k).paymentForClaims.Core_MDF_Payment_No_Txt__c.replace('IPA','MDF') + (grps.get(k).isRecoveryIncluded ? '/AR' : '');
                                line1.add(paymentNumber);
                            }
                        }
                        else{ //External comments for Non VAT Claims
                            String paymentNumberOrNonVatExtCom = isClaimPaymentTypeCustomerNonPO ? generateExternalCommentsForNonVat(grps.get(k)) : (grps.get(k).paymentForClaims.Core_MDF_Payment_No_Txt__c.replace('IPA','MDF') + (grps.get(k).isRecoveryIncluded ? '/AR' : ''));
                            line1.add(paymentNumberOrNonVatExtCom);
                        }
                        line1.add(system.today().format()); 
                        Decimal grossAmount = (Math.abs(grps.get(k).sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN))) + (grps.get(k).isVatEligible ? Math.abs(grps.get(k).totalVatAmt.setScale(2,System.RoundingMode.DOWN)) : Decimal.valueOf(Core_MDF_PaymentUtility.zero));
                        line1.add(String.valueOf(grossAmount));
                        line1.add(Core_MDF_PaymentUtility.curr);
                        line1.add(Core_MDF_PaymentUtility.blank);
                        line1.add(Core_MDF_PaymentUtility.blank);
                        //Tax/VAT Column
                        line1.add(grps.get(k).isVatEligible ? String.valueOf(Math.abs(grps.get(k).totalVatAmt.setScale(2,System.RoundingMode.DOWN))): Core_MDF_PaymentUtility.zero);
                        line1.add(Core_MDF_PaymentUtility.zero);
                        
                        String headerDesc = populateNVAT(grps.get(k)) + MDF + (grps.get(k).isRecoveryIncluded ? '/AR' : '');
                        line1.add(headerDesc);
                        
                        line1.add(paymentMethod == 'None' ? Core_MDF_PaymentUtility.blank : paymentMethod);
                        line1.add(Core_MDF_PaymentUtility.blank);

                        line1.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c : Core_MDF_PaymentUtility.blank);
                        line1.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c : Core_MDF_PaymentUtility.blank);                  
                         
                        //WW05 - Buy From Postal Code
                        String filePostalCode= determinePostalCode(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c);
                        line1.add(filePostalCode);
      
                        line1.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c :Core_MDF_PaymentUtility.blank);
                        
                        List<string> line2 = new List<string>();
                        line2.add(fileParticulars.Core_MDF_Invoice_Line_Item__c);
                        
                        line2.add(Core_MDF_PaymentUtility.one);
                        //line2.add(fileParticulars.Core_MDF_Profit_Center__c == null ? Core_MDF_PaymentUtility.blank : fileParticulars.Core_MDF_Profit_Center__c);
                        line2.add(isClaimPaymentTypeCustomerNonPO ? grps.get(k).profitcenter : Core_MDF_PaymentUtility.blank);
                        line2.add(isClaimPaymentTypeCustomerNonPO ? Core_MDF_PaymentUtility.blank : (grps.get(k).costCenter != null ? grps.get(k).costCenter :'' ));
                        line2.add(grps.get(k).glAccount);  // Stamping GL value from wrapper

                        //IPA Claims - For C Type claims, Amount to be displayed as positive in CSAR File
                        line2.add(String.valueOf(Math.abs(grps.get(k).sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN))));

                        //Tax/VAT column
                        line2.add(grps.get(k).isVatEligible ? ((grps.get(k).businessUnit != '' || isCoGTMPaymentRun) ? String.valueOf(Math.abs(grps.get(k).totalVatAmt.setScale(2,System.RoundingMode.DOWN))):
                                                      String.valueOf(Math.abs(grps.get(k).totalConvertedVatAmt))) : Core_MDF_PaymentUtility.zero);

                        line2.add(Core_MDF_PaymentUtility.zero);
      
                        //SAP Tax code
                        //WW05 - Standartized tax code as I1
                        line2.add(Core_MDF_PaymentUtility.iOne);
                        line2.add(Core_MDF_PaymentUtility.blank);

                        line2.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c : Core_MDF_PaymentUtility.blank);
                        line2.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c : Core_MDF_PaymentUtility.blank);                  
                         
                        //WW05 - Buy From Postal Code
                        line2.add(filePostalCode);
            
                        line2.add(grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? grps.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c :Core_MDF_PaymentUtility.blank);
                        //Line Item Description for IPA
                        line2.add(grps.get(k).geoLocation == ASMORegion ? grps.get(k).quarterNum + grps.get(k).fiscalYear.right(2) +MDF_IPA+ grps.get(k).paymentForClaims.Name +HYPHEN+ grps.get(k).subGeoLocation 
                                      : grps.get(k).quarterNum + grps.get(k).fiscalYear.right(2) +(isCoGTMPaymentRun ? MDF_CoGTM : MDF_IPA)+ grps.get(k).paymentForClaims.Name + (isCoGTMPaymentRun ? Core_MDF_PaymentUtility.blank : (HYPHEN + grps.get(k).geoLocation)));
                        
                        line2.add(Core_MDF_PaymentUtility.blank);
                        
                        //Add Approvers based on thresold limit.
                        String approverWWID = getApproversBasedOnThreshold(grps.get(k).sumOfClaimsAmount,paymentApproverKeyValueMap.get('GEO_APPR'));
                        line2.add(approverWWID != null ? approverWWID : Core_MDF_PaymentUtility.blank);
                        line2.add(isClaimPaymentTypeCustomerNonPO ? fileParticulars.Core_MDF_Commodity_Code_Customer_NonPO__c : fileParticulars.Core_MDF_Commodity_Code__c);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank); 
                        
                         String tempPaymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline + fileLineItemToString(line2) + Core_MDF_PaymentUtility.newline;
                        if(grps.get(k).isVatEligible){
                            //calls a method to return vatEligibleRecords
                            vatPaymentMap = getVATPaymentFileContentAfterSplit(tempPaymentFileContent, '',splitLimit, grps.get(k).includeOnlyClaimAmountForPayment);
                        }
                        else{
                            //calls a method to return nonVatEligibleRecords
                            nonVatPaymentMap=getNonVATPaymentFileContentAfterSplit(tempPaymentFileContent, '',splitLimit, grps.get(k).includeOnlyClaimAmountForPayment);
                        }
                    //}                                               
                    
                }
            }
            String paymentType = isCoGTMPaymentRun ? 'Co-GTM Expense' : 'IPA Expense';
            //Looping VAT Payment Map & passing final content as parameters 
            if(vatPaymentMap!=Null && vatPaymentMap.size()>0){ isVatFile=true; 
                for(Integer uniqueKey : vatPaymentMap.keySet()){ //Iterating over each set of Vat & Non Vat Claim Maps
                    versionNum++; //incrementing version Number to append it to the fileNames
                    String paymentFileContent = vatPaymentMap.get(uniqueKey);
                    //Create content file
                   //Header of the file
                 String finalPaymentRunRecord = generateHeader() + Core_MDF_PaymentUtility.newline + paymentFileContent;
                 //End of the file - Appending footer
                 finalPaymentRunRecord = finalPaymentRunRecord + generateFooter() + Core_MDF_PaymentUtility.newline;
                 String xmlString = generatePaymentFileForExpense(finalPaymentRunRecord, paymentType);
                 contentVersList.addAll(createContentFileForCCP(fileTypes,xmlString,'',paymentType)); //Call createContentFileForCCP Method
                    
                } 
            }                                                  
                                                             
            if(nonVatPaymentMap!=Null && nonVatPaymentMap.size()>0){
                    isvatFile =false;
                    versionNum=0;  
                    for(Integer uniqueKey : nonVatPaymentMap.keySet()){ //Iterating over each set of Vat & Non Vat Claim Maps
                        versionNum++; //incrementing version Number to append it to the fileNames
                        String paymentFileContent = nonVatPaymentMap.get(uniqueKey);
                        //Create content file
                       //Header of the file
                     String finalPaymentRunRecord = generateHeader() + Core_MDF_PaymentUtility.newline + paymentFileContent;
                     //End of the file - Appending footer
                     finalPaymentRunRecord = finalPaymentRunRecord + generateFooter() + Core_MDF_PaymentUtility.newline;
                     String xmlString = generatePaymentFileForExpense(finalPaymentRunRecord, paymentType);
                     contentVersList.addAll(createContentFileForCCP(fileTypes, xmlString,'',paymentType)); //Call createContentFileForCCP Method
                        
                    } 
            }
            List<Id> contentDocIds = updateContentDocOwner(contentVersList);//update document owner
            attachFileToPRun(contentDocIds, pRunInstance); //To attach files to payment run record  
          
}

//WW05 - Handle special characters in Bank Postal Code field
public static String determinePostalCode(String supplierPostalCode) {
     if(String.isBlank(supplierPostalCode) || supplierPostalCode.contains('*')  || supplierPostalCode.contains('?') ) {
        return Core_MDF_PaymentUtility.zero;
    }
    else {
        return supplierPostalCode;
    }  
}
                
public static String generatePaymentFileForExpense(String fileContent, String paymentType)
{
    List<String> rowData=new List<String>();
    List<String> cellData=new List<String>();
    List<List<String>> vatRecords=new List<List<String>>();
    rowData = fileContent.split('\r\n');
   for(String rD:rowData){
        cellData=rD.split('\t');
        vatRecords.add(cellData);
    }
    String worksheetName = generateCCPFileName('',paymentType).left(30);
    String xmlString =Core_MDF_PaymentXMLGenerator.xmlStringGenerator(vatRecords,worksheetName);
    return xmlString;
}
public static String getApproversBasedOnThreshold(Decimal amount,List<Core_MDF_CCP_Custom_Metadata_Utility__c> paymentApprover)
    {
          String approverWWID = '';
                     
        if(amount > 0){
            for(Core_MDF_CCP_Custom_Metadata_Utility__c payRec:paymentApprover){
                if(Integer.valueOf(payRec.Core_MDF_Name_Criteria__c) == 0){
                    approverWWID = payRec.Core_MDF_Value__c;
                    break;
                }
                else{
                    if(amount <= Integer.valueOf(payRec.Core_MDF_Name_Criteria__c)){
                        approverWWID = payRec.Core_MDF_Value__c;
                        break;
                    }
                }
            }
             
        }   
            return approverWWID;
            
    }
    /****************************************************************************************************** 
Method Name:        createContentFileForCCP
@return  :          List<ContentVersion>
@parameters:        List of type of files to be generated and the content of the file in string
Description:        This method is used to create content file
Added By:           Accenture - TS - 25-AUG-2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<ContentVersion> createContentFileForCCP(List<String> fileType, string content,string  budgTypeOrAcctName, String paymentType){
        string pRunBinary;
        List<ContentVersion> conVersionLst = new List<ContentVersion>();
        blob payRunBlob = Blob.valueOf(content);
        //Blob payRunBlob = Crypto.generateDigest('MD5', payRunBlobTemp);
        pRunBinary = EncodingUtil.base64Encode(payRunBlob);
        for(string type : fileType){
            String fileExtn = type.toLowerCase();
            //Create Content Version
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.PathOnClient = generateCCPFileName(budgTypeOrAcctName,paymentType)+'.'+fileExtn;
            conVersion.Title = generateCCPFileName(budgTypeOrAcctName,paymentType);
            conVersion.ReasonForChange = contentversionReasonForChange;
            conVersion.VersionData = EncodingUtil.base64Decode(pRunBinary); //EncodingUtil.base64Decode(payRunBlob);
            conVersionLst.add(conVersion);
        }
        return conVersionLst;
    }
    /****************************************************************************************************** 
Method Name:        updateContentDocOwner
@return  :          List<Ids> contet document ids to attach them in payment run record
@parameters:        List of Content versions to be inserted
Description:        This method is used to insert content versions and update owner of content document record.
Added By:           Accenture - TS - 25-AUG-2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Id> updateContentDocOwner(List<ContentVersion> conVersionLst){
        List<Id> contentDocIds = new List<Id>();
        if(conVersionLst!=null && conVersionLst.size()>0){
            Database.insert(conVersionLst); //Insert contentversion list
            List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst];
            for(ContentVersion conVer : contentVersions)
            {
                contentDocIds.add(conVer.ContentDocumentId);   
            }
        }
        if(contentDocIds!=null && contentDocIds.size()>0){
            Map<Id,ContentDocument> conDocMap = new Map<Id,ContentDocument>([SELECT Id,OwnerId FROM ContentDocument 
                                                                             WHERE Id IN : contentDocIds]);
            if(conDocMap !=null & conDocMap.size()>0){
                for(ContentDocument conDoc : conDocMap.values()){
                    conDoc.OwnerId = Label.Core_MDF_Dummy_Account_Owner_Id; 
                } 
                Database.update(conDocMap.values()); //update owner of content document
            }
        }
        return contentDocIds;
    }
    /****************************************************************************************************** 
Method Name:        generateCCPFileName
@return  :          string fileName
@parameters:        String budget type
Description:        Method to generate the name for the CCP payment file
Added By:           Accenture - TS - 25-AUG-2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateCCPFileName(string budgetTypeorAccName, String PaymentType){  
        String fileName=''; 
        String budgetTypeorAccNameWithoutSpace;
        if(budgetTypeorAccName!=null){
            budgetTypeorAccNameWithoutSpace= budgetTypeorAccName.replace(' ','_');
        }
        //For CCF/DCF-MDF, generating the file names -
        
        if(paymentType != Null && paymentType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CMP')){
            fileName= Core_MDF_PaymentUtility.batchName+geo+Core_MDF_PaymentUtility.underscore + pRunNumber + Core_MDF_PaymentUtility.underscore;
            fileName+=Core_MDF_PaymentUtility.one+ Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm');
            if(budgetTypeorAccNameWithoutSpace!=null){
                fileName += Core_MDF_PaymentUtility.underscore+budgetTypeorAccNameWithoutSpace;        
            }
        }
        // Ex : CCF_Abacus_Inc_20211005040811_Generic ; CCF_Abacus_Inc_20211005040811_Vistex
        else if(paymentType != null && paymentType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFVistex_PaymentType')){
            fileName = generateMDFFileName(budgetTypeorAccNameWithoutSpace,Vistex);
        }
        else if(paymentType != null && paymentType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFGeneric_PaymentType')){
            fileName = generateMDFFileName(budgetTypeorAccNameWithoutSpace,Generic);
        }
        else if(paymentType != null && paymentType == 'IPA Expense'){
            fileName = Core_MDF_PaymentUtility.batchName + geo + Core_MDF_PaymentUtility.underscore + 'IPA' + Core_MDF_PaymentUtility.underscore + (isVatFile ?  'VAT' + Core_MDF_PaymentUtility.underscore : '') + pRunNumber + Core_MDF_PaymentUtility.underscore + Core_MDF_PaymentUtility.one + Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm') + Core_MDF_PaymentUtility.underscore +  versionNum ;
        }
        else if(paymentType != null && paymentType == 'Co-GTM Expense'){
            fileName = Core_MDF_PaymentUtility.batchName + Core_MDF_PaymentUtility.underscore + 'Co-GTM' + Core_MDF_PaymentUtility.underscore + (isVatFile ?  'VAT' + Core_MDF_PaymentUtility.underscore : '') + pRunNumber + Core_MDF_PaymentUtility.underscore + Core_MDF_PaymentUtility.one + Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm') + Core_MDF_PaymentUtility.underscore +  versionNum ;
        }
        return fileName;
    }
    /****************************************************************************************************** 
Method Name:        generateMDFFileName
@return  :          string fileName
@parameters:        String budget type
Description:        Method to generate MDF Payment File
Added By:           Accenture - TS - 06-OCT-2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateMDFFileName(String ultimateAccName, String MDFfileType){
        String ccfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name');//Client Co-Marketing Fund
        String dcfProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name');//Data Center Co-Marketing Fund
        String mdfFileName = '';
        if(MDFfileType == Vistex)
        {
            List<String> accNameWithClaimType = ultimateAccName.split(':');
           mdfFileName = (programName!= null && programName!='' && programName == ccfProgramName) ? CLIENT : (programName!= null && programName!='' && programName == dcfProgramName) ? DATACENTER : (programName!= null && programName!='' && programName == CoGTMProgram) ? CoGTM : Core_MDF_PaymentUtility.underscore;
            mdfFileName += accNameWithClaimType[0] != null && accNameWithClaimType[0]!='' ? Core_MDF_PaymentUtility.underscore + accNameWithClaimType[0] +Core_MDF_PaymentUtility.underscore : Core_MDF_PaymentUtility.underscore;
            mdfFileName +=  accNameWithClaimType[1] != null && accNameWithClaimType[1]!='' ? system.now().format('yyyyMMddHHmmss') + Core_MDF_PaymentUtility.underscore+ MDFfileType+ Core_MDF_PaymentUtility.underscore+ accNameWithClaimType[1] : system.now().format('yyyyMMddHHmmss') + Core_MDF_PaymentUtility.underscore+ MDFfileType;
        }
        else
        {
           mdfFileName = (programName!= null && programName!='' && programName == ccfProgramName) ? CLIENT : (programName!= null && programName!='' && programName == dcfProgramName) ? DATACENTER : (programName!= null && programName!='' && programName == CoGTMProgram) ? CoGTM : Core_MDF_PaymentUtility.underscore;
            mdfFileName += ultimateAccName != null && ultimateAccName!='' ? Core_MDF_PaymentUtility.underscore + ultimateAccName +Core_MDF_PaymentUtility.underscore : Core_MDF_PaymentUtility.underscore;
            mdfFileName += system.now().format('yyyyMMddHHmmss') + Core_MDF_PaymentUtility.underscore+ MDFfileType;
        }
        
        return mdfFileName;   
    }
    /****************************************************************************************************** 
Method Name:        createContentFile
@return  :          List<Id> - content document id's of the generated files
@parameters:        List of type of files to be generated and the content of the file in string
Description:        This method is used to create content file.
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Id> createContentFile(List<String> fileType, string content)
    {   
        string pRunBinary;
        blob payRunBlob = Blob.valueOf(content);
        //convert BLOB file into base64 format
        pRunBinary = EncodingUtil.base64Encode(payRunBlob);
        List<Id> contentDocIds = createContentVersion(fileType, pRunBinary);
        Map<Id,ContentDocument> conDocMap = new Map<Id,ContentDocument>([SELECT Id,OwnerId FROM ContentDocument 
                                                                         WHERE Id IN : contentDocIds]);
        if(conDocMap !=null & conDocMap.size()>0){
            for(ContentDocument conDoc : conDocMap.values())
            {
                conDoc.OwnerId = Label.Core_MDF_Dummy_Account_Owner_Id; 
            } 
            Database.update(conDocMap.values());
        }
        return contentDocIds;
        
    }
    
    /****************************************************************************************************** 
Method Name:        createContentVersion
@return  :          List<Id> - content document id's of the generated files
@parameters:        List of type of files to be generated and the content of the file in binary
Description:        This method is used for generating the ContentVersions and Content Documents
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Id> createContentVersion(List<String> fileType, String binaryStringInput){               
        List<Id> contentDocIds = new List<Id>();
        List<ContentVersion> conVersionLst = new List<ContentVersion>();
        for(string type : fileType)
        {
            String fileExtn = type.toLowerCase();
            //Create Content Version
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.PathOnClient = generateFileName()+'.'+fileExtn;
            conVersion.Title = generateFileName();
            //Feature: To restrict payment file upload manually
            //Desc: To distinguish from where file is getting attach i.e payment batch or manually
            conVersion.ReasonForChange = contentversionReasonForChange;
            //conVersion.FileExtension = fileExtn;
            // converting binary string to Blob
            conVersion.VersionData = EncodingUtil.base64Decode(binaryStringInput);//binaryStringInput;//EncodingUtil.base64Encode(binaryStringInput); //EncodingUtil.base64Decode(binaryStringInput);
            conVersionLst.add(conVersion); 
        }
        insert conVersionLst;
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst];
        for(ContentVersion conVer : contentVersions)
        {
            contentDocIds.add(conVer.ContentDocumentId);   
        }
        return contentDocIds;
    }
    
    /****************************************************************************************************** 
Method Name:        attachFileToPRun
@return  :          void
@parameters:        List of id's of the ContentDocument and the Payment Run instance that it has to be attached to.
Description:        This method is used for attaching a Payment File to the Payment Run instance
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void attachFileToPRun(List<Id> contentDocId, Core_MDF_Payment_Run__c pRunInstance)
    {   
        List<ContentDocumentLink> contentDocLst = new List<ContentDocumentLink>();
        for(Id docId : contentDocId){
            //Create Content Document Link
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = docId;
            conDocLink.LinkedEntityId = pRunInstance.Id;
            conDocLink.ShareType = 'V';
            // conDocLink.Visibility = 'SharedUsers';
            contentDocLst.add(conDocLink);
        }
        insert contentDocLst;
        
    }
    
    /****************************************************************************************************** 
Method Name:        fileLineItemToString
@return  :          string
@parameters:        List of string
Description:        Method to convert List of string to a string to be inserted into the file along with Tabs.
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static string fileLineItemToString(List<string> line)
    {
        string finalString = '';
        for(string lineItem : line){
            finalString = finalString + lineItem + Core_MDF_PaymentUtility.tab;
        }
        return finalString;
    }
    
    /****************************************************************************************************** 
Method Name:        generateHeader
@return  :          string
@parameters:        
Description:        Method to generating the header for the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateHeader()
    {
        List<string> header = new List<string>();
        header.add(fileParticulars.Core_MDF_Batch_Header_Record__c);
        header.add(fileParticulars.Core_MDF_Payment_File_Code__c);
        header.add(system.today().format());
        header.add(system.now().format('HH:mm:ss'));
        header.add(fileParticulars.Core_MDF_Program__c);
        return fileLineItemToString(header);
    }
    
    /****************************************************************************************************** 
Method Name:        generateFooter
@return  :          string
@parameters:        
Description:        Method to generating the footer for the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateFooter()
    {
        List<string> footer = new List<string>();
        footer.add(fileParticulars.Core_MDF_Batch_Trailer_Record__c);
        footer.add(fileParticulars.Core_MDF_Payment_File_Code__c);
        return fileLineItemToString(footer);
    }
    
    /****************************************************************************************************** 
Method Name:        generateFileName
@return  :          string
@parameters:        
Description:        Method to generating the name for the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateFileName(){  
        String fileName='';

        fileName = generateRetailorIPAFileName();
    
        return fileName;
    }
    /****************************************************************************************************** 
Method Name:        generateRetailorIPAFileName
@return  :          string
@parameters:        
Description:        Method to generating the name for the payment file for RMF Program / IPA
Added By:           Tejasree - 17/11/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/  
    public static string generateRetailorIPAFileName(){
        String fileName='';
        //If Retail Program and budget type is Retail MDF / IPA
        if(budgetType == Label.Core_MDF_RetailMDF_BudgetType || programName == IPAProgram || programName == CoGTMProgram){
            //If Geo is ASMO, then SubGeo to be included in FileName
            fileName= returnGeoForFileName();
            
            if(programName == Label.Core_MDF_Retail_Program_Name){
                fileName+=  RetailMDF+Core_MDF_PaymentUtility.underscore;
            }
            else if(programName == IPAProgram)
            {
                fileName += IPA + Core_MDF_PaymentUtility.underscore + (String.isNotBlank(filePrefix) ? filePrefix + Core_MDF_PaymentUtility.underscore : '') ;
            }
            else if(programName == CoGTMProgram)
            {
                fileName = CoGTM + Core_MDF_PaymentUtility.underscore + (String.isNotBlank(filePrefix) ? filePrefix + Core_MDF_PaymentUtility.underscore : '') ;
            }
            //Check if it is VAT File or not
            fileName+= isVatFile ? VAT+Core_MDF_PaymentUtility.underscore+pRunNumber+Core_MDF_PaymentUtility.underscore+system.now().format('yyyyMMddHHmm') :
            pRunNumber+Core_MDF_PaymentUtility.underscore+system.now().format('yyyyMMddHHmm');
            
            //File sequence number for VAT/Non Vat in case of multiple files
            if(versionNum>0){
                fileName+=Core_MDF_PaymentUtility.underscore+versionNum;
            }
            //Sample File name for Non VAT IPA: APJ_IPA_001219_202012150515_1 ; In case of ASMO as Geo: ASMO_LAR_IPA_001219_202012150515_1
            //Sample File name for VAT IPA : APJ_IPA_VAT_001219_202012150515_1 ; In case of ASMO as Geo: ASMO_LAR_IPA_VAT_001219_202012150515_1
        } 
        //If budget type is RSA MD
        else if(budgetType == Label.Core_MDF_Retail_RSA_MD_Budget_Type){
            //If Geo is ASMO, then SubGeo to be included in FileName
            fileName= returnGeoForFileName();
            
            fileName+= RSAMD+Core_MDF_PaymentUtility.underscore+pRunNumber+
                Core_MDF_PaymentUtility.underscore+system.now().format('yyyyMMddHHmm');
        }
        return fileName;
    }
    public static string returnGeoForFileName()
    {
        String retailorIPAFileName = (String.isNotBlank(subGeo)) ? geo+Core_MDF_PaymentUtility.underscore+subGeo+Core_MDF_PaymentUtility.underscore:
        geo+Core_MDF_PaymentUtility.underscore;
        
        return retailorIPAFileName;
    }
    
    /****************************************************************************************************** 
Method Name:        generateRsaMdPaymentFile
@return  :          void
@parameters:        groups
Description:        Method to generate and attach the RSA MD payment file
Added By:           Krishna - Accenture - 01/13/2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static void generateRsaMdPaymentFile(Map<String,Core_MDF_PaymentWrapper> paymentWrapper,Core_MDF_Payment_Run__c pRunInstance){
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        //Payment Run Geo
        geo = pRunInstance.Core_MDF_Geo_Txt__c;
        //Payment Run Budget Type
        budgetType =pRunInstance.Core_MDF_Budget_Type_nm__c;
        //Payment Run Program
        programName = pRunInstance.Core_MDF_Program_Id__r.Name;
        //Payment Run SubGeo in case of ASMO Region
        subGeo = pRunInstance.Core_MDF_Subgeo_Txt__c;
        // Final string to be inserted into the file
        String finalPaymentFileRecord = '';
        // Final string to preparing content
        String finalPaymentFileContent = '';
        // Column Headers
        string paymentFileHeader = Label.Core_MDF_AccountCompany +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentId') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AccountNode') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimID')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimName') +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Program +Core_MDF_PaymentUtility.tab +Label.Core_MDF_CountryLocation +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActivityId') +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Activity_Types +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStartDate')+Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEndDate')+Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimCreatedDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_LastPopReceivedDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimApprovalDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RequestedAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AuditAdjustmentAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ReimbursementAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_PaymentUtility.newline;
        //To generate line items for the file for each payment record
        if(paymentWrapper != NULL && paymentWrapper.size() > 0){
            for(String uniqueKey : paymentWrapper.keySet()) {
                //List of claims to be processed
                List<PartnerFundClaim> listOfPfc = paymentWrapper.get(uniqueKey).claimsToBeProcessed;
                //List of Payments for Claims
                Core_MDF_Payment__c paymentRecord = paymentWrapper.get(uniqueKey).paymentForClaims;
                if(listOfPfc != Null && listOfPfc.size() > 0)
                {
                    for(PartnerFundClaim claim : listOfPfc) {
                        String activityNumber = String.valueOf(claim.Request.Core_MDF_Activity_Number__c).leftPad(8, '0');
                        List<string> line1 = new List<string>();
                        line1.add(claim.Core_MDF_AccountCompany__c);
                        line1.add(paymentRecord.Core_MDF_Payment_No_Txt__c);                        
                        line1.add(claim.ChannelPartner.Name);
                        line1.add(claim.Core_MDF_Claim_Ref_Number__c);
                        line1.add(claim.Title);
                        line1.add(claim.Core_MDF_Program__c);
                        line1.add(claim.Core_MDF_Country_Location_nm__c);
                        //line1.add(activityNumber);    
                        line1.add('\''+activityNumber);                      
                        line1.add(claim.Core_MDF_Activity_Types__c);
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_Start_Date__c));
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_End_Date__c));
                        line1.add(String.valueOf((claim.CreatedDate).date()));
                        line1.add(String.valueOf((claim.Core_MDF_RMF_Last_POP_Submission_Dt__c)));//Last POP Submission Date
                        line1.add(String.valueOf((claim.Core_MDF_RMF_Claim_Approval_Dt__c)));//Claim Approval Date                        
                        line1.add(String.valueOf(claim.Core_MDF_Requested_Reimbursement_Amt__c));
                        line1.add(String.valueOf(claim.Core_MDF_Audit_Adjustment_Amount__c));
                        line1.add(String.valueOf(claim.amount));
                        string paymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                        //Preparing record content
                        finalPaymentFileContent = finalPaymentFileContent +paymentFileContent ;
                    }
                } 
            }
            //Cheking content is not null
            if(finalPaymentFileContent!=null){
                //Appending header and final content
                finalPaymentFileRecord = paymentFileHeader+finalPaymentFileContent;
            }
        }
        
        //Create content file
        List<Id> contentDocIds = createContentFile(fileTypes, finalPaymentFileRecord);
        //attach file to Payment run
        attachFileToPRun(contentDocIds, pRunInstance);
    }
    
    /****************************************************************************************************** 
Method Name:        generateRetailMdforIPAPaymentFile
@return  :          void
@parameters:        Map of Payment file Wrapper, Payment Run Instance, Program
Description:        Method to generate and attach the Retail MDF payment file
Added By:           Pranav - Accenture - 14/7/2020 
Modified By:        Tejasree- Accenture  Date:30/10/2020 
Changes:            US812140: To Split Payment file into two for VAT Claims & Non Vat Claims. 
And also to generate a new file once it exceeds 400 rows
*******************************************************************************************************/
    
    public static void generateRetailMdforIPAPaymentFile(Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapper, Core_MDF_Payment_Run__c pRunInstance , string program){      
        
        clearStaticVariables();
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        //Payment Run Geo
        geo = pRunInstance.Core_MDF_Geo_Txt__c;
        //Payment Run Budget Type
        budgetType =pRunInstance.Core_MDF_Budget_Type_nm__c;
        //Payment Run Program
        programName = pRunInstance.Core_MDF_Program_Id__r.Name;
        //Payment Run SubGeo in case of ASMO Region
        subGeo = pRunInstance.Core_MDF_Subgeo_Txt__c;
        // Content of Payment File Excluding Headers
        string paymentFileHeader='';
        Decimal splitLimit=Decimal.valueOf(Label.Core_MDF_Split_Limit); //Limit for splitting vat & non Vat Payment Files
        Map<Integer,String> vatPaymentMap=new Map<Integer,String>(); 
        Map<Integer,String> nonVatPaymentMap=new Map<Integer,String>(); 

        //Get Country Geo Mapping Records
        List<Core_MDF_CCP_Country_Geo_Mapping__mdt>  CountryMappingRecords = Core_MDF_GenericMetadata.getCountryGeoMappingMdt('');

        // Get All Geo And Geo Code as well as sales Org Code from Metadata
        geoMapping= new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
        
        for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_Txt__c, Core_MDF_Geo_Code_Txt__c FROM Core_MDF_Geo_code_Mapping__mdt LIMIT 1000 ])
        {
            geoMapping.put(geocode.MasterLabel , geocode);
        }
        
        // Get Country's Geo, SubGeo from the metadata
        countryGeoSubGeoMap= new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();

        
         //WW15 - Sales Org and Geo Code Changes for India and JAPAN
        for(Core_MDF_CCP_Country_Geo_Mapping__mdt rec : CountryMappingRecords) {
        countryGeoSubGeoMap.put(rec.Core_MDF_Code_2_Digits__c, rec);
        countryToSalesCodeMapping.put(rec.Core_MDF_Code_2_Digits__c,rec.Core_MDF_Geo_Sales_Org_Code_cd__c);
        countryToGeoCodeMapping.put(rec.Core_MDF_Code_2_Digits__c,rec.Core_MDF_Geo_Code_cd__c);
        }
        
        // Get Product Category Metadata records 
        /* prodCategoryMapping= new Map<String,Core_MDF_Product_Category__mdt>();

for(Core_MDF_Product_Category__mdt prodCategory : [Select Id, MasterLabel, Core_MDF_Product_Category_Txt__c,Core_MDF_Material_Code_Txt__c, Core_MDF_Profit_Center_Txt__c, Core_MDF_Program_Txt__c FROM Core_MDF_Product_Category__mdt ]){
prodCategoryMapping.put(prodCategory.Core_MDF_Program_Txt__c+prodCategory.Core_MDF_Product_Category_Txt__c, prodCategory);
}*/
        
        // Get Intel Work Week for the payment run start date field
        intelWorkWeek = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());                       
        //Get the metadata for the given program
        fileParticulars = [SELECT Id, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_GL_Account_CSAR__c,Core_MDF_Commodity_Code_CSAR__c , Core_MDF_Program_ID__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt where Label =:program Limit 1];
        
        // Column Headers

           paymentFileHeader = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InvoiceType') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Customer_Number') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Reference_Number') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Legal_Entity') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Fund_Quarter') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Sequence') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_Comments') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Header_Description') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Method_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Method_Supplement_code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Currency_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Line_Amount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Tax_VAT') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GST_Amount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Profit_Center') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GL_Acct') +Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SAP_Tax_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Commodity_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Line_Item_Description') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Internal_Comments') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Sales_Org_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_City') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Region') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Postal_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Country') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Currency_Conversion_Reqd_Y_N') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Material_Code') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Geo_Code') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_Program_Id') +Core_MDF_PaymentUtility.newline; 
        
        
        //Get all invoice numbers for VAT claims
        getVatInvoiceNumbers(paymentFileWrapper);
        //ATHR - Deeply Nested if 16209
        if(paymentFileWrapper == NULL || paymentFileWrapper.isEmpty()) return;
        //if(paymentFileWrapper != NULL && paymentFileWrapper.size() > 0){
            for(String k : paymentFileWrapper.keySet()) {
                if(paymentFileWrapper.get(k).claimsToBeProcessed != Null && paymentFileWrapper.get(k).claimsToBeProcessed.size() > 0 ){
                    String tempPaymentfileContent='';
                    //Calling method to return paymentFileContent
                    tempPaymentfileContent =getPaymentFileContent(paymentFileWrapper.get(k));
                    //checks if claim is vat eligible 
                    if(paymentFileWrapper.get(k).isVatEligible){
                        //calls a method to return vatEligibleRecords
                        vatPaymentMap = getVATPaymentFileContentAfterSplit(tempPaymentFileContent,paymentFileHeader,splitLimit, paymentFileWrapper.get(k).includeOnlyClaimAmountForPayment);
                    }
                    else{
                        //calls a method to return nonVatEligibleRecords
                        nonVatPaymentMap=getNonVATPaymentFileContentAfterSplit(tempPaymentFileContent,paymentFileHeader,splitLimit, paymentFileWrapper.get(k).includeOnlyClaimAmountForPayment);
                    }
                }    
            }//Loop ends here                                 
        //} 
        //Looping VAT Payment Map & passing final content as parameters 
        if(vatPaymentMap!=Null && vatPaymentMap.size()>0){ isVatFile=true;
                                                          generateFinalPaymentFileToAttach(vatPaymentMap,pRunInstance);
                                                         }
        //Looping Non-VAT Payment Map & passing final content as parameters 
        if(nonVatPaymentMap!=Null && nonVatPaymentMap.size()>0){
            isvatFile =false;
            versionNum=0;
            generateFinalPaymentFileToAttach(nonVatPaymentMap,pRunInstance);
        }
    }

    public static void generateIPAPaymentFileForCreditMemo(Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapper, Core_MDF_Payment_Run__c pRunInstance , string program){      
        
            clearStaticVariables();
            filePrefix = Core_MDF_PaymentUtility.creditMemoFileName;
            //Payment Run Name
            pRunNumber = pRunInstance.Name;
            //Payment Run Geo
            geo = pRunInstance.Core_MDF_Geo_Txt__c;
            //Payment Run Budget Type
            budgetType =pRunInstance.Core_MDF_Budget_Type_nm__c;
            //Payment Run Program
            programName = program;
            //Payment Run SubGeo in case of ASMO Region
            subGeo = pRunInstance.Core_MDF_Subgeo_Txt__c;
            // Content of Payment File Excluding Headers
            string paymentFileHeader='';
            Map<Integer,String> PaymentFileMap=new Map<Integer,String>();
            Decimal splitLimit=Decimal.valueOf(Label.Core_MDF_Split_Limit); //Limit for splitting vat & non Vat Payment Files
            
            // Get All Geo And Geo Code as well as sales Org Code from Metadata
            geoMapping= new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
            
            for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_Txt__c, Core_MDF_Geo_Code_Txt__c FROM Core_MDF_Geo_code_Mapping__mdt LIMIT 1000])
            {
                geoMapping.put(geocode.MasterLabel , geocode);
            }
            
            // Get Country's Geo, SubGeo from the metadata
            countryGeoSubGeoMap= new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();
            
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [Select Core_MDF_Code_2_Digits__c, DeveloperName, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000]){
                countryGeoSubGeoMap.put(countryGeo.Core_MDF_Code_2_Digits__c, countryGeo);
            }
          
            // Get Intel Work Week for the payment run start date field
            intelWorkWeek = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());

            //Get the metadata for the given program
            fileParticulars = [SELECT Id, Core_MDF_Invoice_Type__c, Core_MDF_Program_ID__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt where Label =:program Limit 1];

            paymentFileHeader = Core_MDF_PaymentUtility.creditHeader1 + Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.creditHeader2 +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader3 +Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.creditHeader4 +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader5 +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader6 +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader7 +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader8 +Core_MDF_PaymentUtility.tab+  
            Core_MDF_PaymentUtility.creditHeader9 + Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader10  +Core_MDF_PaymentUtility.tab + Core_MDF_PaymentUtility.creditHeader11  +Core_MDF_PaymentUtility.tab+  Core_MDF_PaymentUtility.creditHeader12  +Core_MDF_PaymentUtility.tab+ Core_MDF_PaymentUtility.creditHeader13 +Core_MDF_PaymentUtility.newline;

            
            if(paymentFileWrapper != NULL && paymentFileWrapper.size() > 0){
                for(String k : paymentFileWrapper.keySet()) {
                    if(paymentFileWrapper.get(k).claimsToBeProcessed != Null && paymentFileWrapper.get(k).claimsToBeProcessed.size() > 0 ){
                        String tempPaymentfileContent='';
                        //Calling method to return paymentFileContent
                        tempPaymentfileContent =getPaymentFileContentForCreditMemo(paymentFileWrapper.get(k));
                        PaymentFileMap=getNonVATPaymentFileContentAfterSplit(tempPaymentFileContent,paymentFileHeader,splitLimit, paymentFileWrapper.get(k).includeOnlyClaimAmountForPayment);
                        }
                    }    
                }//Loop ends here                                 

            //Attach payment file to payment run
            if(PaymentFileMap!=Null && PaymentFileMap.size()>0){ 
                isVatFile=false;
                generateFinalPaymentFileToAttach(PaymentFileMap,pRunInstance);
                }
        
        }
    
    /****************************************************************************************************** 
Method Name:        getVatInvoiceNumbers
@return  :          void
@parameters:        Payment file Wrapper
Description:        Method to Map invoice numbers of VAT records against each vat eligible claim record.
Added By:           TejaSree - Accenture - 13/11/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static void getVatInvoiceNumbers(Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapper){
        Set<Id> claimIds = new Set<Id>();
        //Adding all vat related claim Ids to Set
        if(paymentFileWrapper != NULL && paymentFileWrapper.size()>0){
            for(String k : paymentFileWrapper.keySet()) {
                if(paymentFileWrapper.get(k).claimsToBeProcessed != Null && paymentFileWrapper.get(k).claimsToBeProcessed.size() > 0  && paymentFileWrapper.get(k).isVatEligible){
                    //@@@vikas - invoice defect
                    String claimIdForInvoiceNo = (paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Program__c == IPAProgram && paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Claim_Id__c != null) ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Claim_Id__c : paymentFileWrapper.get(k).claimsToBeProcessed[0].Id;
                    claimIds.add(claimIdForInvoiceNo);
                }
            }
        }
        
        for(Core_MDF_Claim_VAT_Info__c vatInfo:[Select id,Core_MDF_Claim_Id__c,Core_MDF_VAT_Invoice_Number_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c IN:claimIds]){
            mapOfInvoiceNoToClaims.put(vatInfo.Core_MDF_Claim_Id__c, vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c);
            
        }
    }
    
    /****************************************************************************************************** 
Method Name:        getPaymentFileContent
@return  :          String
@parameters:        Payment file Wrapper
Description:        Method to return single payment record.
Added By:           TejaSree - Accenture - 30/10/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static String getPaymentFileContent(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        List<string> line1 = new List<string>();
        //For Adjustment claims,Populating invoice Type as 'C'
        if(paymentFileWrapper.isCtypeInd || paymentFileWrapper.isRecoveryIncluded){ line1.add(CTYPE); 
                                         }
        else{ // Populating 'I' as Invoice Type for positive claims
            line1.add(fileParticulars.Core_MDF_Invoice_Type__c);
        }
        
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Number__c);
        line1.add(paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + '' + intelWorkWeek.subString(0,4) +Core_MDF_PaymentUtility.blank+ 
                  (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram ? NRE : MDF)); //aditya
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c);
        line1.add(paymentFileWrapper.fiscalYear + paymentFileWrapper.quarterNum.right(1).leftPad(2 , '0'));
        line1.add(Core_MDF_PaymentUtility.one);
        //External Comments for VAT Claims
        if(paymentFileWrapper.isVatEligible){
            String vatExtComm = generateExternalCommentsForVat(paymentFileWrapper);
            if(String.isNotBlank(vatExtComm)){
                line1.add(vatExtComm);
            }else{
                String nonVatExtCom=generateExternalCommentsForNonVat(paymentFileWrapper);
                line1.add(nonVatExtCom);
            }                        
        }
        else{ //External comments for Non VAT Claims
            String nonVatExtCom=generateExternalCommentsForNonVat(paymentFileWrapper);
            line1.add(nonVatExtCom);
        }
        //aditya
        String headerDesc = populateNVAT(paymentFileWrapper) + (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram ? NRE : MDF) + (paymentFileWrapper.isRecoveryIncluded ? '/AR' : '');
        line1.add(headerDesc);
        line1.add(Core_MDF_PaymentUtility.blank);//For Payment Method Code
        line1.add(Core_MDF_PaymentUtility.blank);//For Payment Method Supplement Code
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c : Core_MDF_PaymentUtility.blank);
        //IPA Claims - For C Type claims, Amount to be displayed as positive in CSAR File
        if(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == IPAProgram || paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram){
            line1.add(String.valueOf(Math.abs(paymentFileWrapper.sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN))));
        }
        //Retail Claims - For C Type claims, Amount to be displayed as positive in CSAR File
        else{
            line1.add(paymentFileWrapper.isCtypeInd ? String.valueOf(Math.abs(paymentFileWrapper.sumOfConvertedAmount)):String.valueOf(paymentFileWrapper.sumOfConvertedAmount));
        }

        // Tax/VAT column
        /*if(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name')){ //Channel MDF Program
            line1.add(paymentFileWrapper.isVatEligible ? String.valueOf(Math.abs(paymentFileWrapper.totalVatAmt.setScale(2,System.RoundingMode.DOWN))) : Core_MDF_PaymentUtility.zero);
        }else{*/// IPA / Retail Program
            line1.add(paymentFileWrapper.isVatEligible ? ((paymentFileWrapper.businessUnit != '' || paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram) ? String.valueOf(Math.abs(paymentFileWrapper.totalVatAmt.setScale(2,System.RoundingMode.DOWN))):
                                                              String.valueOf(Math.abs(paymentFileWrapper.totalConvertedVatAmt))) : Core_MDF_PaymentUtility.zero);
        //}

        line1.add(Core_MDF_PaymentUtility.zero);
        line1.add(paymentFileWrapper.profitcenter);
		line1.add(paymentFileWrapper.glAccount);  // Stamping GL value from wrapper


         //WW05 - Standartized tax code as I1
       // For IPA and RMF Program
         line1.add(Core_MDF_PaymentUtility.iOne);

        
        //line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c :Core_MDF_PaymentUtility.blank);
        line1.add(fileParticulars.Core_MDF_Commodity_Code_CSAR__c); 
        if(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == IPAProgram){ //Line Item Description for IPA
            line1.add(paymentFileWrapper.geoLocation == ASMORegion ? paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.subGeoLocation 
                      : paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.geoLocation);
        }
        
        else if(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram){
            line1.add(paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + MDF_CoGTM + paymentFileWrapper.paymentForClaims.Name);
        }
        else{ //Line Item Description for Retail MDF
            line1.add(paymentFileWrapper.geoLocation == ASMORegion ? paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_RSA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.subGeoLocation 
                      : paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_RSA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.geoLocation);
        }
        //line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c :Core_MDF_PaymentUtility.blank);
         line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c == 'IN' ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c + Core_MDF_PaymentUtility.indiaComments 
         : paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c :Core_MDF_PaymentUtility.blank);
        
        //WW15 - Sales Org and Geo Code Changes for India and JAPAN
        //line1.add(geoMapping.get(countryGeoSubGeoMap.get(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c).Core_MDF_Geo__c).Core_MDF_Geo_Sales_Org_Code_Txt__c);
        line1.add(countryToSalesCodeMapping.get(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c));
        
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c : Core_MDF_PaymentUtility.blank);
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c : Core_MDF_PaymentUtility.blank);                  
        
        //WW05 - Postal Code Changes
        String filePostalCode= determinePostalCode(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c);
        line1.add(filePostalCode);
  
        line1.add(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c :Core_MDF_PaymentUtility.blank);
        line1.add(NO);

        line1.add(paymentFileWrapper.materialCode);
        
         //WW15 - Sales Org and Geo Code Changes for India and JAPAN
        //line1.add(geoMapping.get(countryGeoSubGeoMap.get(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c).Core_MDF_Geo__c).Core_MDF_Geo_Code_Txt__c);
        line1.add(countryToGeoCodeMapping.get(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c));
        
        line1.add(fileParticulars.Core_MDF_Program_ID__c != NULL ? fileParticulars.Core_MDF_Program_ID__c : Core_MDF_PaymentUtility.blank);

        String tempPaymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
        return tempPaymentFileContent;
    }
    
    public static String getPaymentFileContentForCreditMemo(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        List<string> line1 = new List<string>();

        line1.add(paymentFileWrapper.soldToNumber !=null ? paymentFileWrapper.soldToNumber : Core_MDF_PaymentUtility.blank);
        line1.add(paymentFileWrapper.shipToNumber !=null ? paymentFileWrapper.shipToNumber : Core_MDF_PaymentUtility.blank);
        
        line1.add(paymentFileWrapper.salesOrg != null ? paymentFileWrapper.salesOrg : Core_MDF_PaymentUtility.blank);
     
        line1.add(paymentFileWrapper.distributionChannel != null ? paymentFileWrapper.distributionChannel : Core_MDF_PaymentUtility.blank);
        line1.add(paymentFileWrapper.materialCode);
        
        //IPA Claims - For C Type claims, Amount to be displayed as positive in CSAR File
        line1.add(String.valueOf(Math.abs(paymentFileWrapper.sumOfClaimsAmount.setScale(2,System.RoundingMode.DOWN))));

        line1.add(Core_MDF_PaymentUtility.one);
        String refNumber = generateReferenceNumber(paymentFileWrapper);
        line1.add(refNumber);
        
        String intelQtr = generateRelevantIntelQtr(paymentFileWrapper);
        line1.add(intelQtr);
        
        //TWC3117-17274 - Aditya
        if(paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram){
            line1.add(paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + MDF_CoGTM + paymentFileWrapper.paymentForClaims.Name);
            
            line1.add(paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + MDF_CoGTM + paymentFileWrapper.paymentForClaims.Name);           
        } else{
            line1.add(paymentFileWrapper.geoLocation == ASMORegion ? paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.subGeoLocation
            : paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.geoLocation);
        
            line1.add(paymentFileWrapper.geoLocation == ASMORegion ? paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.subGeoLocation
            : paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +MDF_IPA+ paymentFileWrapper.paymentForClaims.Name +HYPHEN+ paymentFileWrapper.geoLocation);
        }
        
        line1.add(Core_MDF_PaymentUtility.one);
        
        line1.add(fileParticulars.Core_MDF_Program_ID__c != NULL ? fileParticulars.Core_MDF_Program_ID__c : Core_MDF_PaymentUtility.blank);
    
        String tempPaymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
        return tempPaymentFileContent;
    }
    
    /****************************************************************************************************** 
Method Name:        generateExternalCommentsForNonVat
@return  :          String 
@parameters:        Payment file Wrapper
Description:        Method to return Extenal Comments for Non Vat Eligible Claims 
Added By:           TejaSree - Accenture - 17/11/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
public static string generateExternalCommentsForNonVat(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        String extnlCom='';
        Boolean isCoGTMContraCSARClaim =  paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram && (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Payment_Type_nm__c == 'Customer' || paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Payment_Type_nm__c == 'Customer (Credit Memo)');
        if(paymentFileWrapper.isCtypeInd){ extnlCom=paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + '' + intelWorkWeek.subString(0,4) +Core_MDF_PaymentUtility.blank+ (isCoGTMContraCSARClaim ? NRE : MDF) +CM; //aditya
                                         }
        else if(!paymentFileWrapper.isCtypeInd){
            extnlCom=paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + '' + intelWorkWeek.subString(0,4) +Core_MDF_PaymentUtility.blank+ (isCoGTMContraCSARClaim ? NRE : MDF) + (paymentFileWrapper.isRecoveryIncluded ? '/AR' : '');
        }
        return extnlCom;
    }

// public static string generateExtINTComments(Core_MDF_PaymentFileWrapper paymentFileWrapper){
//         String extnlCom='';
//         extnlCom=paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) +'/MDF/'+'C:'+paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Claim_Ref_Number__c;
//         return extnlCom;
//     }
public static string generateRelevantIntelQtr(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        String intelQtr='';
        intelQtr= paymentFileWrapper.fiscalYear.right(4) + paymentFileWrapper.quarterNum.right(1).leftPad(2 , '0');
        return intelQtr;
    }
public static string generateReferenceNumber(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        String refNumber='';
        refNumber= (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram ? Core_MDF_PaymentUtility.blank : (paymentFileWrapper.geoLocation + Core_MDF_PaymentUtility.space)) + paymentFileWrapper.quarterNum + paymentFileWrapper.fiscalYear.right(2) + Core_MDF_PaymentUtility.underscore + intelWorkWeek.subString(0,4) + Core_MDF_PaymentUtility.space+ (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == CoGTMProgram ? NRE : MDF); //aditya
        
        if(paymentFileWrapper.isCtypeInd)
        {
            refNumber += '/AR';
        }
        return refNumber;
    }

    /****************************************************************************************************** 
Method Name:        generateExternalCommentsForVat
@return  :          String 
@parameters:        Payment file Wrapper
Description:        Method to return Extenal Comments for Vat Eligible Claims 
Added By:           TejaSree - Accenture - 17/11/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static string generateExternalCommentsForVat(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        String extlComments='';
        //@@@vikas - invoice defect
        String claimIdForInvoiceNo = (paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Program__c == IPAProgram && paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Claim_Id__c != null) ? paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Claim_Id__c : paymentFileWrapper.claimsToBeProcessed[0].id;
        //mapOfInvoiceNoToClaims --->Key= Claim Id, value= VAT Invoice number
        if(!paymentFileWrapper.isCtypeInd && mapOfInvoiceNoToClaims.containsKey(claimIdForInvoiceNo)){
            extlComments=mapOfInvoiceNoToClaims.get(claimIdForInvoiceNo) !=null ? mapOfInvoiceNoToClaims.get(claimIdForInvoiceNo) + (paymentFileWrapper.isRecoveryIncluded ? '/AR' : ''): Core_MDF_PaymentUtility.blank;
        }
        else if(paymentFileWrapper.isCtypeInd && mapOfInvoiceNoToClaims.containsKey(claimIdForInvoiceNo)){
            extlComments=mapOfInvoiceNoToClaims.get(claimIdForInvoiceNo) !=null ? mapOfInvoiceNoToClaims.get(claimIdForInvoiceNo)+CM : Core_MDF_PaymentUtility.blank;
        }
        return extlComments;
    }
    
    /****************************************************************************************************** 
Method Name:        getVATPaymentFileContentAfterSplit
@return  :          Map<Integer,String> vatPaymentFileMap;
@parameters:        Payment file Wrapper, PaymentFileHeader & SplitLimit
Description:        Method to return vat Eligible Claims after Splitting.
Added By:           TejaSree - Accenture - 30/10/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static Map<Integer,String> getVATPaymentFileContentAfterSplit(String tempPaymentContent,String paymentFileHeader,Decimal splitLimit, Boolean claimHasRecovery){
        VatLineCounter++;

        //Ignore row addtion if the claim has recovery row
        if(claimHasRecovery && Math.mod(Integer.valueOf(VatLineCounter),Integer.valueOf(splitLimit)) == 0 ){
            VatLineCounter++;
        }

        //To calcuate vat claims count and split once it reaches 400, there by generating uniqueKey 
        Integer vatFileNum=(math.ceil(vatLineCounter/splitLimit)).intValue();  
        //if map contains key then append new Vat claim to existing string and put it into Map.
        if(vatPaymentFileMap.containsKey(vatFileNum)){ tempPaymentContent= vatPaymentFileMap.get(vatFileNum)+tempPaymentContent;
                                                      vatPaymentFileMap.put(vatFileNum,tempPaymentContent);
                                                     }
        else{
            tempPaymentContent=paymentFileHeader + tempPaymentContent; //Append Header to Content
            vatPaymentFileMap.put(vatFileNum,tempPaymentContent);
        }
        return vatPaymentFileMap;                 
    }
    
    /****************************************************************************************************** 
Method Name:        getVATPaymentFileContentAfterSplit
@return  :          Map<Integer,String> nonVatPaymentFileMap;
@parameters:        Payment file Wrapper, PaymentFileHeader & SplitLimit
Description:        Method to return Non Vat Eligible Claims after Splitting
Added By:           TejaSree - Accenture - 30/10/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static Map<Integer,String> getNonVATPaymentFileContentAfterSplit(String tempPaymentContent,String paymentFileHeader,Decimal splitLimit, Boolean claimHasRecovery){
        nonVatLineCounter++; 

        //Ignore row addtion if the claim has recovery row
        if(claimHasRecovery && Math.mod(Integer.valueOf(nonVatLineCounter),Integer.valueOf(splitLimit)) == 0 ){
            nonVatLineCounter++;
        }

        //To calcuate non vat claims count and split once it reaches 400, there by generating uniqueKey 
        Integer nonVatFileNum=(math.ceil(nonVatLineCounter/splitLimit)).intValue(); 
        if(nonVatpaymentFileMap.containsKey(nonVatFileNum)){ tempPaymentContent= nonVatpaymentFileMap.get(nonVatFileNum)+tempPaymentContent; //Appending new string to existing
                                                            nonVatpaymentFileMap.put(nonVatFileNum,tempPaymentContent);
                                                           }
        else{
            tempPaymentContent=paymentFileHeader + tempPaymentContent; //Appending Header to content
            nonVatpaymentFileMap.put(nonVatFileNum,tempPaymentContent); 
        }
        return nonVatpaymentFileMap;                 
    }
    
    /****************************************************************************************************** 
Method Name:        generateFinalPaymentFileToAttach
@return  :          void
@parameters:        Payment file Wrapper Content, Payment Run Instance
Description:        Method to attach RetailMDF Vat & Non Vat Claim Files
Added By:           TejaSree - Accenture - 30/10/2020 
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void generateFinalPaymentFileToAttach(Map<Integer,String> paymentFileMap,Core_MDF_Payment_Run__c pRunInstance){
        List<Id> contentDocIds = new List<Id>();
        
        for(Integer key : paymentFileMap.keySet()){//Iterating over each set of Vat & Non Vat Claim Maps
                        versionNum++; //incrementing version Number to append it to the fileNames
                    List<String> rowData=new List<String>();
                  List<String> cellData=new List<String>();
                  List<List<String>> vatRecords=new List<List<String>>();
        
                            if(paymentFileMap.get(key) != null ){
                            rowData=paymentFileMap.get(key).split('\r\n');
                            
                            }
                    for(String rD:rowData){
                                cellData=rD.split('\t');
                    
                            
                    vatRecords.add(cellData);
                            }
                           
                        String worksheetName=generateFileName().left(30);//Truncating worksheet name to accomodate with max character limit 
                        String xmlString =Core_MDF_PaymentXMLGenerator.xmlStringGenerator(vatRecords,worksheetName);    
                        contentDocIds=createContentFile(fileTypes, xmlString);
                        
                         
                         if(contentDocIds!=Null && contentDocIds.size()>0){
                                attachFileToPRun(contentDocIds, pRunInstance);
                            }
                        }
    }
    
    /****************************************************************************************************** 
Method Name:        generateMDFVistexPaymentFile
@return  :          void
@parameters:        
Description:        Method to generate and attach the MDF or MDF+ payment file
Added By:           RG - Accenture - 14/9/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static void generateMDFVistexPaymentFile(Map<String,Core_MDF_PaymentWrapper> paymentWrapper,Core_MDF_Payment_Run__c pRunInstance, String program){
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        //To get programs - CCF & DCF
        List<String> ccfdcfprograms = Core_MDF_Configuration__c.getValues('Programs_For_MDF_PaymentRun').Core_MDF_Value__c.split(',');
        //Payment Run Budget Type
        //budgetType =pRunInstance.Core_MDF_Budget_Type_nm__c;
        //Payment Run Program
        programName = pRunInstance.Core_MDF_Program_Id__r.Name;
        // Final string to be inserted into the file
        String finalPaymentFileRecord = '';
        Integer fileNumber=0;
        // Final string to preparing content
        //String finalPaymentFileContent = '';
        
        Map<String,list<list<String>>> mapOfAccToStringForXMLConversion = new Map<String,list<list<String>>>();
        Map<String,String> mapOfAccIdToAccNameForXMLConversion = new Map<String,String>();
        Map<String,String> mapOfAccToFileContent = new Map<String,String>();
        Map<String,String> mapOfAccIdToAccName = new Map<String,String>();
        List<ContentVersion> contentVersList =new List<ContentVersion>();
        List<String> claimTypeValues = Core_MDF_Configuration__c.getValues('Core_MDF_ClaimTypeValues').Core_MDF_Value__c.split(',');
        string salesUnit=Core_MDF_Configuration__c.getValues('Core_MDF_Sales_Unit').Core_MDF_Value__c; 
        List<String> rowHeaders = Core_MDF_Configuration__c.getValues('Core_MDF_Row_Headers').Core_MDF_Value__c.split(',');
        Boolean isCoGTMVistexClaim = false;
        // Get All Geo And Geo Code as well as sales Org Code from Metadata
        geoMapping= new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
        for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_Txt__c, Core_MDF_Geo_Code_Txt__c FROM Core_MDF_Geo_code_Mapping__mdt LIMIT 1000 ])
        {
            geoMapping.put(geocode.MasterLabel , geocode);
        }
        
        // Get Country's Geo, SubGeo from the metadata
        countryGeoSubGeoMap= new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();
        
        for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [Select MasterLabel,Core_MDF_Code_2_Digits__c, DeveloperName, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt LIMIT 1000]){
            countryGeoSubGeoMap.put(countryGeo.MasterLabel, countryGeo);
        }
        // Column Headers
        string paymentFileHeader =' '+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimType')+Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Sub_Date') +Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Sales_Org') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Dist_Channel')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Division')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Sold_To_Party')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ref_No')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Currency')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Agr_Req')+Core_MDF_PaymentUtility.newline+' '+Core_MDF_PaymentUtility.tab+ Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MateralCode') + Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Quantity') + Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SalesUnit')+ Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Amount')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DealID')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_TrackerId')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Ship_To') + Core_MDF_PaymentUtility.newline;
        //Adding Column Headers to list
        List<String> paymentFileHeaderRows = paymentFileHeader.split('\r\n');
        List<String> headerLine1 = paymentFileHeaderRows[0].split('\t');
        List<String> headerLine2 = paymentFileHeaderRows[1].split('\t');
        
        //To generate line items for the file for each payment record
        if(paymentWrapper != NULL && paymentWrapper.size() > 0){
            for(String uniqueKey : paymentWrapper.keySet()) {
                String ultimateAccWithClaimType ='';// uniqueKey.substringBefore('_');
                String uniqKeyForFileSplit='';
                //List of claims to be processed
                List<PartnerFundClaim> listOfPfc = paymentWrapper.get(uniqueKey).claimsToBeProcessed;
                //ATHR - Deeply Nested if 16209
                if(listOfPfc == Null || listOfPfc.isEmpty()) continue;
                //if(listOfPfc != Null && listOfPfc.size() > 0)
                //{
                    for(PartnerFundClaim claim : listOfPfc) {
                        if(program == CoGTMProgram){
                            isCoGTMVistexClaim = (claim.Core_MDF_Payment_Type_nm__c != null && (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCash || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCreditMemo)) ? true : false;

                            uniqKeyForFileSplit = (claim.Core_MDF_Payment_Type_nm__c != Core_MDF_PaymentUtility.vistexCash ? String.valueOf(claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(claim.Core_MDF_Type_Txt__c)
                            : (claim.Core_MDF_Budget_Type_Options_Nm__c != null ? claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c
                                                                            : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c));
                        } else {
                            uniqKeyForFileSplit = String.valueOf(claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(claim.Core_MDF_Type_Txt__c);
                        }
                        
                        //ultimateAccForFileSplit = claim.Core_MDF_AccountCompany__c.left(16);
                        String activityNumber = String.valueOf(claim.Request.Core_MDF_Activity_Number__c).leftPad(8, '0');
                        List<string> line1 = new List<string>();
                        line1.add(rowHeaders[0]);
                        if(claim.Core_MDF_Type_Txt__c==claimType){
                            line1.add(claimTypeValues[0]); 
                            ultimateAccWithClaimType = claim.Core_MDF_AccountCompany__c.left(16)+':'+claimTypeValues[0];
                        }
                        else{
                            line1.add(claimTypeValues[1]);
                            ultimateAccWithClaimType = claim.Core_MDF_AccountCompany__c.left(16)+':'+claimTypeValues[1];
                        }
  
            String claimCreatedDate = String.valueOf(claim.CreatedDate.month()).leftPad(2,'0')+'/'+String.valueOf(claim.CreatedDate.day()).leftPad(2,'0')+'/'+String.valueOf(claim.CreatedDate.year());                        
                        line1.add(claimCreatedDate);
                        //line1.add(SaleOrg);
                        line1.add(!isCoGTMVistexClaim ? geoMapping.get(countryGeoSubGeoMap.get(claim.Core_MDF_Country_Location_nm__c).Core_MDF_Geo__c).Core_MDF_Geo_Sales_Org_Code_Txt__c : Core_MDF_PaymentUtility.blank);
                        line1.add(String.valueOf(Core_MDF_Configuration__c.getValues('Core_MDF_Vistex_Distribution_Channel').Core_MDF_Value__c.leftPad(2,'0')));
                        line1.add(String.valueOf(Core_MDF_Configuration__c.getValues('Core_MDF_Vistex_Division').Core_MDF_Value__c.leftPad(2,'0')));
                        line1.add(Core_MDF_PaymentUtility.blank);
                        line1.add(Core_MDF_PaymentUtility.blank);
                        line1.add(Core_MDF_PaymentUtility.curr);
                        line1.add(Core_MDF_PaymentUtility.blank);
                        
                        List<string> line2 = new List<string>();
                        line2.add(rowHeaders[1]);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.one);
                        line2.add(salesUnit);
                        line2.add(String.valueOf(Math.abs(claim.Amount)));  
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        
                        // Creating Map for converting XML to XLS
                        if(Core_MDF_Utility.byPassFeature('Core_MDF_XMLToXLSGenerationFlag'))
                        {
                            //Create a map with ultimate account as key and list of lines as value
                            if(mapOfAccToStringForXMLConversion.containsKey(uniqKeyForFileSplit)){
                                List<list<String>> finalPayRunRecordsForXMLConversion = mapOfAccToStringForXMLConversion.get(uniqKeyForFileSplit);
                                finalPayRunRecordsForXMLConversion.add(line1);
                                finalPayRunRecordsForXMLConversion.add(line2);
                                mapOfAccToStringForXMLConversion.put(uniqKeyForFileSplit,finalPayRunRecordsForXMLConversion);   
                            }
                            else{
                                mapOfAccIdToAccNameForXMLConversion.put(uniqKeyForFileSplit,ultimateAccWithClaimType);
                                list<list<String>> stringForXMLConversion = new list<list<String>>();
                                stringForXMLConversion.add(headerLine1);
                                stringForXMLConversion.add(headerLine2);
                                stringForXMLConversion.add(line1);
                                stringForXMLConversion.add(line2);
                                mapOfAccToStringForXMLConversion.put(uniqKeyForFileSplit,stringForXMLConversion);
                            }
                        }
                        
                        // Creating payment file content string and mapping it with ultimate acc id as key
                        if(Core_MDF_Utility.byPassFeature('Core_MDF_StringToXLSGenerationFlag'))
                        {
                            string paymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline + fileLineItemToString(line2) + Core_MDF_PaymentUtility.newline;
                            
                            //Create a map with key as ultimate acc Id and value as file content
                            if(mapOfAccToFileContent.containsKey(uniqKeyForFileSplit)){
                                String finalPayRunRecord = mapOfAccToFileContent.get(uniqKeyForFileSplit);
                                finalPayRunRecord+= paymentFileContent;
                                mapOfAccToFileContent.put(uniqKeyForFileSplit,finalPayRunRecord);   
                            }
                            else{
                                //fileVersionNo++;
                                mapOfAccIdToAccName.put(uniqKeyForFileSplit,ultimateAccWithClaimType);
                                String paymentFileLineItemWithHeader=paymentFileHeader +paymentFileContent;
                                mapOfAccToFileContent.put(uniqKeyForFileSplit,paymentFileLineItemWithHeader);
                            }
                        }
                    }
                //} 
                
            }
            
        }
        
        
        if(Core_MDF_Utility.byPassFeature('Core_MDF_XMLToXLSGenerationFlag'))
        {
            for(String uniqKey : mapOfAccToStringForXMLConversion.keySet()){
                String accountNameWithClaimType='';
                //String finalXMLString = Core_MDF_PaymentXMLGenerator.xmlStringGenerator(mapOfAccToStringForXMLConversion.get(uniqKey));
                if(mapOfAccIdToAccNameForXMLConversion.containsKey(uniqKey)){
                    accountNameWithClaimType = mapOfAccIdToAccNameForXMLConversion.get(uniqKey);
                }
                String worksheetName = generateCCPFileName(accountNameWithClaimType,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFVistex_PaymentType')).left(30);//Truncating worksheet name to accomodate with max character limit 
                String finalXMLString = Core_MDF_PaymentXMLGenerator.xmlStringGenerator(mapOfAccToStringForXMLConversion.get(uniqKey),worksheetName);
                contentVersList.addAll(createContentFileForCCP(fileTypes, finalXMLString,accountNameWithClaimType,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFVistex_PaymentType'))); //Call createContentFileForCCP Method
            }
        }
        
        if(Core_MDF_Utility.byPassFeature('Core_MDF_StringToXLSGenerationFlag'))
        {
            for(String uniqueKey : mapOfAccToFileContent.keySet()){
                String accNameWithClaimType='';
                String finalPaymentFileContent = mapOfAccToFileContent.get(uniqueKey);
                if(mapOfAccIdToAccName.containsKey(uniqueKey)){
                    accNameWithClaimType = mapOfAccIdToAccName.get(uniqueKey);
                }
                contentVersList.addAll(createContentFileForCCP(fileTypes, finalPaymentFileContent,accNameWithClaimType,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFVistex_PaymentType'))); //Call createContentFileForCCP Method
            }
        }
        
        List<Id> contentDocIds = updateContentDocOwner(contentVersList);//update document owner
        attachFileToPRun(contentDocIds, pRunInstance); //To attach files to payment run record
        
    }
    
    /****************************************************************************************************** 
Method Name:        generateMDFGenericPaymentFile
@return  :          void
@parameters:        
Description:        Method to generate and attach the MDF or MDF+ generic payment file
Added By:           RG - Accenture - 4/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    
    public static void generateMDFGenericPaymentFile(Map<String,Core_MDF_PaymentWrapper> paymentWrapper,Core_MDF_Payment_Run__c pRunInstance, String program){
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        Map<String,String> mapOfAccToFileContent = new Map<String,String>();
        Map<String,String> mapOfAccIdToAccName = new Map<String,String>();
        List<ContentVersion> contentVersList =new List<ContentVersion>();
        Core_MDF_CCP_Submission_Window__mdt cogtmClaimWindowQueryRecord = new Core_MDF_CCP_Submission_Window__mdt();
        // Column Headers
        string paymentFileHeader = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Quarter')+Core_MDF_PaymentUtility.tab+Label.Core_MDF_AccountCompany +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentId') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AccountNode') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimID')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimName') +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Program +Core_MDF_PaymentUtility.tab +Label.Core_MDF_CountryLocation  +Core_MDF_PaymentUtility.tab  + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CampaignName') +Core_MDF_PaymentUtility.tab 
        +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActivityName') +Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActivityId') + Core_MDF_PaymentUtility.tab +Label.Core_MDF_Activity_Types +Core_MDF_PaymentUtility.tab
  +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelOwner') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MemberOwner') +Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActivityPriority') +Core_MDF_PaymentUtility.tab
        +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ProductType') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Target_Audience') +Core_MDF_PaymentUtility.tab
        +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Name')+ Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Type')+Core_MDF_PaymentUtility.tab+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStartDate')+Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimEndDate')+Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimCreatedDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_LastPopReceivedDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimApprovalDate') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RequestedAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AuditAdjustmentAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ReimbursementAmount') +Core_MDF_PaymentUtility.tab +Core_MDF_PaymentUtility.newline;
        Boolean isCoGTMVistexClaim = false;
        String claimWindowQueryString = 'SELECT DeveloperName, Core_MDF_Claim_Submission_Window_days__c from Core_MDF_CCP_Submission_Window__mdt where DeveloperName = \'Core_MDF_CoGTM_CoEngineering_Rule\' LIMIT 1';
        cogtmClaimWindowQueryRecord = Database.query(claimWindowQueryString);
        Integer cogtmClaimSubmissionWindowDays = (cogtmClaimWindowQueryRecord != null && cogtmClaimWindowQueryRecord.Core_MDF_Claim_Submission_Window_days__c != null) ? Integer.valueOf(cogtmClaimWindowQueryRecord.Core_MDF_Claim_Submission_Window_days__c) : 0;
        
        //To generate line items for the file for each payment record
        if(paymentWrapper != NULL && paymentWrapper.size() > 0){
            for(String uniqueKey : paymentWrapper.keySet()) {
                String ultimateAccForFileSplit ='';// uniqueKey.substringBefore('_');
                String uniqKeyForFileSplit='';
                Core_MDF_Payment__c paymentRecord = paymentWrapper.get(uniqueKey).paymentForClaims;
                //List of claims to be processed
                List<PartnerFundClaim> listOfPfc = paymentWrapper.get(uniqueKey).claimsToBeProcessed;
                //ATHR - Deeply Nested if 16209
                if(listOfPfc == Null || listOfPfc.isEmpty()) continue;
                //if(listOfPfc != Null && listOfPfc.size() > 0)
                //{
                    for(PartnerFundClaim claim : listOfPfc) {
                        if(program == CoGTMProgram){
                            isCoGTMVistexClaim = (claim.Core_MDF_Payment_Type_nm__c != null && (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCash || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCreditMemo)) ? true : false;
                        }
                        uniqKeyForFileSplit =String.valueOf(claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                        ultimateAccForFileSplit = claim.Core_MDF_AccountCompany__c.left(16);
                        String activityNumber = String.valueOf(claim.Request.Core_MDF_Activity_Number__c).leftPad(8, '0');
                        List<string> line1 = new List<string>();
                        String quarterYear = '';
                        if(claim.Core_MDF_Quarter_Year_Txt__c != null && claim.Core_MDF_Quarter_Year_Txt__c != ''){
                            List<String> quarterStringList = claim.Core_MDF_Quarter_Year_Txt__c.split('-');
                            if(quarterStringList[0].length()>1 && quarterStringList[1].length()>1){
                                quarterStringList[0] = quarterStringList[0].replace('Q','0');
                                quarterYear = quarterStringList[1] + quarterStringList[0];
                            }
                            else{
                                quarterYear = Core_MDF_PaymentUtility.blank;
                            }
                        }
                        else{
                            quarterYear = Core_MDF_PaymentUtility.blank;
                        }
                        String requestedReimbursementAmt = claim.Core_MDF_Requested_Reimbursement_Amt__c != NULL ? String.valueOf(claim.Core_MDF_Requested_Reimbursement_Amt__c) : Zero;
                        line1.add(quarterYear);
                        line1.add(claim.Core_MDF_AccountCompany__c);
                        line1.add(paymentRecord.Core_MDF_Payment_No_Txt__c);                        
                        line1.add(claim.ChannelPartner.Name);
                        line1.add(claim.Core_MDF_Claim_Ref_Number__c);
                        line1.add(claim.Title);
                        line1.add(claim.Core_MDF_Program__c);
                        line1.add(!isCoGTMVistexClaim ? claim.Core_MDF_Country_Location_nm__c : Core_MDF_PaymentUtility.blank);
                        
                        //Campaign Name 
                        line1.add(claim.Request.Campaign.Name);

                        //Activity Name
                        line1.add(claim.Request.Title);
       
                        line1.add('\''+activityNumber);                      
                        line1.add(claim.Core_MDF_Activity_Types__c);

                        //Intel Owner
                        line1.add(!isCoGTMVistexClaim ? getValidFieldValue(claim.Request.Core_MDF_Intel_Activity_Owner_Id__r.Name) : ((claim.Core_MDF_Campaign_Id__r.Core_MDF_Intel_Owner_id__c != null && claim.Core_MDF_Campaign_Id__r.Core_MDF_Intel_Owner_id__r.Name != null) ? claim.Core_MDF_Campaign_Id__r.Core_MDF_Intel_Owner_id__r.Name : Core_MDF_PaymentUtility.blank));
                        
                        //Member Owner
                        String memberOwner = (!isCoGTMVistexClaim ? claim.Request.Core_MDF_Member_Owner_txt__c : ((claim.Request.Campaign.Core_MDF_Member_Acceptor_id__c != null && claim.Request.Campaign.Core_MDF_Member_Acceptor_id__r.Name != null) ? claim.Request.Campaign.Core_MDF_Member_Acceptor_id__r.Name : Core_MDF_PaymentUtility.blank));
                        String memberOwnerWithoutTabSpace =  memberOwner != NULL ? memberOwner.replaceAll('\\t',' ') : Core_MDF_PaymentUtility.blank;
                        line1.add(memberOwnerWithoutTabSpace);

                        //Activity Priority
                        line1.add(!isCoGTMVistexClaim ? getValidFieldValue(claim.Request.Core_MDF_Priorities__c) : getValidFieldValue(claim.Core_MDF_Campaign_Id__r.Core_MDF_Priority__c));

                        //Activity Product Type
                        line1.add(getValidFieldValue(!isCoGTMVistexClaim ? claim.Request.Core_MDF_ProductType__c : claim.Request.Campaign.Core_MDF_Product_Type__c));

                        //Activity Target Audience
                        line1.add(getValidFieldValue(!isCoGTMVistexClaim ? claim.Request.Core_MDF_TargetAudience__c : Core_MDF_PaymentUtility.blank));

                        line1.add(claim.Budget.Title);
                        line1.add(claim.Core_MDF_Budget_Type_Options_Nm__c);
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_Start_Date__c));
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_End_Date__c));
                        line1.add(String.valueOf((claim.CreatedDate).date()));
                        line1.add(!isCoGTMVistexClaim ? String.valueOf(claim.Core_MDF_RMF_Last_POP_Submission_Dt__c) : String.valueOf(claim.Request.Core_MDF_End_Date__c.addDays(cogtmClaimSubmissionWindowDays)));//Last POP Submission Date
                        line1.add(!isCoGTMVistexClaim ? String.valueOf((claim.Core_MDF_RMF_Claim_Approval_Dt__c)) : getValidFieldValue(String.valueOf(claim.Core_MDF_Claim_Approval_Dt__c)));//Claim Approval Date
                        line1.add(requestedReimbursementAmt);
                        line1.add(!isCoGTMVistexClaim ? String.valueOf(claim.Core_MDF_Audit_Adjustment_Amount__c) : Core_MDF_PaymentUtility.blank);
                        line1.add(String.valueOf(claim.amount));
                        
                        string paymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                        //Create a map with key as ultimate acc Id and value as file content
                        if(mapOfAccToFileContent.containsKey(uniqKeyForFileSplit)){
                            String finalPayRunRecord = mapOfAccToFileContent.get(uniqKeyForFileSplit);
                            finalPayRunRecord+= paymentFileContent;
                            mapOfAccToFileContent.put(uniqKeyForFileSplit,finalPayRunRecord);   
                        }
                        else{
                            mapOfAccIdToAccName.put(uniqKeyForFileSplit,ultimateAccForFileSplit);
                            String paymentFileLineItemWithHeader=paymentFileHeader +paymentFileContent;
                            mapOfAccToFileContent.put(uniqKeyForFileSplit,paymentFileLineItemWithHeader);
                        }
                    }
                //} 
                
            }
            
        }
        for(String uniqueKey : mapOfAccToFileContent.keySet()){
            String accName='';
            String finalPaymentFileContent = mapOfAccToFileContent.get(uniqueKey);
            if(mapOfAccIdToAccName.containsKey(uniqueKey)){
                accName = mapOfAccIdToAccName.get(uniqueKey);
            }
            contentVersList.addAll(createContentFileForCCP(fileTypes, finalPaymentFileContent,accName,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDFGeneric_PaymentType'))); //Call createContentFileForCCP Method
        }
        
        List<Id> contentDocIds = updateContentDocOwner(contentVersList);//update document owner
        attachFileToPRun(contentDocIds, pRunInstance); //To attach files to payment run record
        
    }

//WW27 - Method to check if field data is not null and return it else return blank 
public static String getValidFieldValue(String fieldData) {

    return ((fieldData != NULL && fieldData != '') ? fieldData : Core_MDF_PaymentUtility.blank);

}
    
    /****************************************************************************************************** 
    Method Name:        generateChannelMDFPaymentFile
    @return  :          void
    @parameters:        Map of Payment file Wrapper, Payment Run Instance, Program
    Description:        Method to generate and attach the Channel MDF payment file
    Added By:           JB - Accenture - 03/21/2022
    *******************************************************************************************************/
    
    // public static void generateChannelMDFPaymentFile(Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapper, Core_MDF_Payment_Run__c pRunInstance , String program){      
    //     //Payment Run Name
    //     pRunNumber = pRunInstance.Name;
    //     //Payment Run Geo
    //     geo = pRunInstance.Core_MDF_Geo_Txt__c;
    //     //Payment Run Budget Type
    //     budgetType =pRunInstance.Core_MDF_Budget_Type_nm__c;
    //     //Payment Run Program
    //     programName = pRunInstance.Core_MDF_Program_Id__r.Name;
    //     //Payment Run SubGeo in case of ASMO Region
    //     subGeo = pRunInstance.Core_MDF_Subgeo_Txt__c;
    //     // Content of Payment File Excluding Headers
    //     string paymentFileHeader='';
    //     Decimal splitLimit=Decimal.valueOf(Label.Core_MDF_Split_Limit); //Limit for splitting vat & non Vat Payment Files
        
    //     Map<String,String> paymentFileNameToFileContentMap =new Map<String,String>();
    //     List<ContentVersion> contentVersionListToInsert  = new List<ContentVersion>();
        
    //     // Get All Geo And Geo Code as well as sales Org Code from Metadata
    //     geoMapping= new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
        
    //     for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_Txt__c, Core_MDF_Geo_Code_Txt__c FROM Core_MDF_Geo_code_Mapping__mdt ])
    //     {
    //         geoMapping.put(geocode.MasterLabel , geocode);
    //     }
        
    //     // Get Country's Geo, SubGeo from the metadata
    //     countryGeoSubGeoMap= new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();
        
    //     for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [Select Core_MDF_Code_2_Digits__c, DeveloperName, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt ]){
    //         countryGeoSubGeoMap.put(countryGeo.Core_MDF_Code_2_Digits__c, countryGeo);
    //     }
        
    //     // Get Intel Work Week for the payment run start date field
    //     intelWorkWeek = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());                      
    //     //Get the metadata for the given program
    //     fileParticulars = [SELECT Id, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, Core_MDF_Program_ID__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt where Label =:program Limit 1];
        
    //     // Column Headers
    //     paymentFileHeader = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InvoiceType') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Customer_Number') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Reference_Number') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Legal_Entity') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Fund_Quarter') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Sequence') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_Comments') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Header_Description') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Method_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Method_Supplement_code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Currency_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Line_Amount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Tax_VAT') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GST_Amount') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Profit_Center') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_GL_Acct') +Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SAP_Tax_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Commodity_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Line_Item_Description') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Internal_Comments') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Sales_Org_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_City') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Region') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Postal_Code') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Buy_From_Country') +Core_MDF_PaymentUtility.tab +Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Currency_Conversion_Reqd_Y_N') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Material_Code') + Core_MDF_PaymentUtility.tab + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Geo_Code') + Core_MDF_PaymentUtility.newline; 
        
    //     //Get all invoice numbers for VAT claims
    //     getVatInvoiceNumbers(paymentFileWrapper);
        
    //     if(paymentFileWrapper != NULL && paymentFileWrapper.size() > 0){
    //         for(String k : paymentFileWrapper.keySet()) {
    //             if(paymentFileWrapper.get(k).claimsToBeProcessed != Null && paymentFileWrapper.get(k).claimsToBeProcessed.size() > 0 ){
    //                 String tempPaymentfileContent='';
    //                 //Calling method to return paymentFileContent
    //                 tempPaymentfileContent =getPaymentFileContent(paymentFileWrapper.get(k));

    //                 paymentFileNameToFileContentMap = getPaymentFileContentAfterSplitChannelMDF(tempPaymentFileContent,paymentFileHeader,splitLimit,paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Budget_Type_Options_Nm__c, paymentFileWrapper.get(k).isVatEligible);
    //             }    
    //         }//Loop ends here                                 
    //     } 
    //     //Looping Payment Map & passing final content as parameters 
    //     if(paymentFileNameToFileContentMap != null && !paymentFileNameToFileContentMap.isEmpty()){ 
    //         contentVersionListToInsert = generateFinalPaymentFileToAttachChannelMDF(paymentFileNameToFileContentMap, pRunInstance);
    //     }
        
    //     if(!contentVersionListToInsert.isEmpty()){
    //         //To insert Content Version and to update Content Document Owner
    //         List<Id> contentDocIds = updateContentDocOwner(contentVersionListToInsert);
    //         attachFileToPRun(contentDocIds, pRunInstance); //To attach files to payment run record
    //     }
    // }
    
    
    /****************************************************************************************************** 
    Method Name:        getVATPaymentFileContentAfterSplitChannelMDF
    @return  :          Map<String,String> paymentFileMapChannelMDF
    @parameters:        Payment file Wrapper, PaymentFileHeader & SplitLimit
    Description:        Method to return Eligible Claims after Splitting.
    Added By:           JB - Accenture - 03/21/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    // public static Map<String,String> getPaymentFileContentAfterSplitChannelMDF(String tempPaymentContent,String paymentFileHeader,Decimal splitLimit, String budgetType, Boolean isVatFile){
        
    //     budgetType = '_' + budgetType + '_';
    //     budgetType = isVatFile ? 'VAT_' + budgetType : budgetType; //Adding 'VAT_' string infront of String if its a VAT file.
        
    //     //To increase line count and File count
    //     if(lineCounterChannelMDFMap != null && lineCounterChannelMDFMap.containsKey(budgetType)){
    //         if(lineCounterChannelMDFMap.get(budgetType) == Integer.valueOf(splitLimit)){
    //             lineCounterChannelMDFMap.put(budgetType, 0);
    //             fileCounterChannelMDFMap.put(budgetType, fileCounterChannelMDFMap.get(budgetType) + 1);
    //         }
    //         lineCounterChannelMDFMap.put(budgetType, lineCounterChannelMDFMap.get(budgetType) + 1);
    //     }else {
    //         lineCounterChannelMDFMap.put(budgetType, 1);
    //         fileCounterChannelMDFMap.put(budgetType, 1);
    //     }
        
    //     //Append File Count to the Budget Type
    //     budgetType += fileCounterChannelMDFMap.get(budgetType);
        
    //     //If map contains key then append new claim to existing string and put it into Map.
    //     if(paymentFileMapChannelMDF.containsKey(budgetType)){ 
    //         tempPaymentContent = paymentFileMapChannelMDF.get(budgetType) + tempPaymentContent;
    //         paymentFileMapChannelMDF.put(budgetType, tempPaymentContent);
    //     }
    //     else{
    //         tempPaymentContent = paymentFileHeader + tempPaymentContent; //Append Header to Content
    //         paymentFileMapChannelMDF.put(budgetType, tempPaymentContent);
    //     }
        
    //     return paymentFileMapChannelMDF;                 
    // }
    
    /****************************************************************************************************** 
    Method Name:        generateFinalPaymentFileToAttachChannelMDF
    @return  :          List<ContentVersion>
    @parameters:        Payment file Wrapper Content, Payment Run Instance
    Description:        Method to attach RetailMDF Vat & Non Vat Claim Files
    Added By:           JB - Accenture - 03/21/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    // public static List<ContentVersion> generateFinalPaymentFileToAttachChannelMDF(Map<String,String> paymentFileMap,Core_MDF_Payment_Run__c pRunInstance){
        
    //     List<ContentVersion> contentVersionListToInsert  = new List<ContentVersion>();

    //     for(String uniqueKey : paymentFileMap.keySet()){
    //         String baseFileName = '';
    //         Boolean isVat = false;
    //         if(uniqueKey.startsWith('VAT_')){//VAT file name
    //             isVat = true;
    //             baseFileName = uniqueKey.removeStart('VAT_');
    //         }else{//Non-Vat file name
    //             baseFileName = uniqueKey;
    //         }
            
    //         String paymentFileContent = paymentFileMap.get(uniqueKey);
    //         //Generate content file
    //         if(paymentFileContent != null){
    //             List<ContentVersion> contentVersionList =  generateContentVersionToInsert(fileTypes, paymentFileContent, baseFileName, isVat);
    //             if(!contentVersionList.isEmpty()){
    //                 contentVersionListToInsert.addAll(contentVersionList);
    //             }
    //         }
    //     }

    //     return !contentVersionListToInsert.isEmpty() ? contentVersionListToInsert : null ;
    // }
    
    /****************************************************************************************************** 
    Method Name:        generateContentVersionToInsert
    @return  :          List<ContentVersion>
    @parameters:        List of type of files to be generated and the content of the file in string
    Description:        This method is used to generate Content Version Instance.
    Added By:           JB - Accenture - 03/23/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    // public static List<ContentVersion> generateContentVersionToInsert(List<String> fileType, String content, String baseFileName, Boolean isVat){
        
    //     List<ContentVersion> contentVersionListToInsert  = new List<ContentVersion>();
    //     String pRunBinary;
    //     Blob payRunBlob = Blob.valueOf(content);
    //     //convert BLOB file into base64 format
    //     pRunBinary = EncodingUtil.base64Encode(payRunBlob);
        
    //     for(String type : fileType){
    //         String fileExtn = type.toLowerCase();
            
    //         //To get Valid file name
    //         String fileName = generateChannelMdfFileName(baseFileName, isVat);
    //         fileName = removeUnsupportedFileNameChars(fileName);
    //         fileName = getValidFileName(fileName, 250);
            
    //         //Create Content Version
    //         ContentVersion conVersion = new ContentVersion();
    //         conVersion.ContentLocation = 'S';
    //         conVersion.PathOnClient = fileName + '.'+ fileExtn;
    //         conVersion.Title = fileName;
    //         //Feature: To restrict payment file upload manually
    //         //Desc: To distinguish from where file is getting attach i.e payment batch or manually
    //         conVersion.ReasonForChange = contentversionReasonForChange;
    //         // converting binary string to Blob
    //         conVersion.VersionData = EncodingUtil.base64Decode(pRunBinary);
    //         contentVersionListToInsert.add(conVersion);
    //     }

    //     return !contentVersionListToInsert.isEmpty() ? contentVersionListToInsert : null ;
    // }

    /****************************************************************************************************** 
    Method Name:        generateChannelMdfFileName
    @return  :          String
    @parameters:        
    Description:        Method to generating the name for the payment file for Channel MDF
    Added By:           JB - 03/29/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/  
    // public static String generateChannelMdfFileName(String baseFileName, Boolean isVat){
    //     String fileName='';
    //     //Only for Channel MDF
    //     if(programName == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name')){
    //         //If Geo is ASMO, then SubGeo to be included in FileName
    //         fileName= returnGeoForFileName();
            
    //         //Add Program name to File name
    //         fileName +=  ChannelMDF + Core_MDF_PaymentUtility.underscore;

    //         //Check if it is VAT File or not
    //         fileName += (isVat ? VAT + Core_MDF_PaymentUtility.underscore + pRunNumber + Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm') :
    //         pRunNumber + Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm'));
            
    //         //To add Channel MDF Budget Type in the file name.
    //         fileName += String.isNotBlank(baseFileName) ? baseFileName.replace(' ', '_') : '' ;
            
    //     }

    //     return fileName;
    // }
    
    /****************************************************************************************************** 
    Method Name:        removeUnsupportedFileChars
    @return  :          String
    @parameters:        fileName
    Description:        This method is used to remove unsupported File name Characters.
    Added By:           JB - Accenture - 03/25/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static String removeUnsupportedFileNameChars(String fileName){
        return String.isNotBlank(fileName) ? fileName.replaceAll('[/\\\\:*?"><|]', '') : '' ;
    }
    
    
    /****************************************************************************************************** 
    Method Name:        getValidFileName
    @return  :          String
    @parameters:        fileName, length
    Description:        This method is used to return new String based on the input Length.
    Added By:           JB - Accenture - 03/25/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static String getValidFileName(String fileName, Integer length){
        
        String validFileName = '';
        if(String.isNotBlank(fileName)){
            if(fileName.contains('_')){
                validFileName = fileName.substringBeforeLast('_')?.left(length) + '_' + fileName.substringAfterLast('_');
            }else{
                validFileName = fileName.left(length);
            }
        }

        return validFileName;
    }
/****************************************************************************************************** 
    Method Name:        clearStaticVariables
    @return  :          void
    @parameters:        Void
    Description:        Method to clear all the static variable 
    Added By:           Mayuri Dhanjani
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void  clearStaticVariables(){
        
        vatPaymentFileMap.clear();
        nonVatPaymentFileMap.clear();
        mapOfInvoiceNoToClaims.clear();
        //paymentFileMapChannelMDF.clear();
        //fileCounterChannelMDFMap.clear();
        //lineCounterChannelMDFMap.clear();
        pRunNumber ='';
        versionNum=0;
        vatLineCounter = 0;
        nonVatLineCounter = 0;
        isVatFile =false;
        budgetType='';
        programName='';
        subGeo='';
        filePrefix = '';
    intelWorkWeek = '';
    geo ='';
    }


    /****************************************************************************************************** 
    Method Name:        populateNVAT
    @return  :          String
    @parameters:        Core_MDF_PaymentFileWrapper
    Description:        Method to add NVAT text for the header Description coulmn for IPA/RMF.
    Added By:           JB - Accenture - 11/02/2023
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static String populateNVAT(Core_MDF_PaymentFileWrapper paymentFileWrapper){
        return ((paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == '420' 
    || paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c == '650') && 
            ((!paymentFileWrapper.isVatEligible) || (paymentFileWrapper.isVatEligible && paymentFileWrapper.claimsToBeProcessed[0].Core_MDF_VAT_Amt__c == 0))) ? 'NVAT/' : '';
    }

}