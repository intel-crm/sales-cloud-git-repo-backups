/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdatePaymentRunClaims  
* Version     : 1.0    
* Created Date: 05-11-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Pranav      05/11/2020      This batch Updates Status and Payment Id on Claim After Successful Payment Run and Generates 
                                          Payment file ; In Case of any Error/Exception It would Invoke other batch which will revert back all the
                                          changes
*************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_UpdatePaymentRunClaims implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    // Payment Wrapper Used for Generating CCP/ RSA MD Payment file
    public Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap;
    // Payment File Wrapper Used for generating CSAR file
    public Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap;
    // Current Payment Run Record
    public Core_MDF_Payment_Run__c prunInstance;
    // Program Of Current Payment Run
    public String paymentRunProgram ;
    // List of Incoming Claims to be processed for Updating Status and Payment Field
    public List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
    // Boolean flag Used for 
    public Boolean errorFlag = false;
    // Exception Object
    public Exception exceptionObject;
    //List of All the Claims with updated Status and Payment Field
    public List<PartnerFundClaim> updatedClaimList = new List<PartnerFundClaim>();
    // Map of claim Id to Payment Id
    public Map<Id, Id> claimIdtoPaymentId = new Map<Id ,Id>();
    // List of BU Split records to be inserted
    public List<Core_MDF_Claim_BU_Split__c> claimsBUSplitList = new List<Core_MDF_Claim_BU_Split__c>();
    public Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
    Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
    public Map<Id,String> claimToCostCenterMap  = new Map<Id,String>();
    public Map<Id, Core_MDF_Account_Node_Attributes__c> accountNodeAttributesMap = new Map<Id, Core_MDF_Account_Node_Attributes__c>();
    private static String CoGTMProgram = Core_MDF_CustomLabelConfig.getTextValues('Co_GTM');
    public Map<String, String> buProdTypeMap = new Map<String, String>();
    public Map<String, Integer> buPriorityRankingMap = new Map<String, Integer>();
    
    public Core_MDF_Batch_UpdatePaymentRunClaims(Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap,Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap,Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper, List<PartnerFundClaim> listOfClaims ,Core_MDF_Payment_Run__c prunInstance, List<Core_MDF_Claim_BU_Split__c> claimsBUSplitList,Map<String,List<PartnerFundClaim>> paymentTypeToClaims, Map<Id,String> claimToCostCenterMap, Map<Id, Core_MDF_Account_Node_Attributes__c> accountNodeAttributesMap){
        this.paymentWrapperMap = paymentWrapperMap;
        this.paymentFileWrapperMap = paymentFileWrapperMap;
        this.prunInstance = prunInstance;
        this.listOfClaims = listOfClaims;
        this.claimsBUSplitList = claimsBUSplitList;
        paymentRunProgram = prunInstance.Core_MDF_Program_Id__r.Name;
        this.paymentTypeToFileWrapper = paymentTypeToFileWrapper;
        this.paymentTypeToClaims = paymentTypeToClaims;
        this.claimToCostCenterMap = claimToCostCenterMap;
        this.accountNodeAttributesMap = accountNodeAttributesMap;
        
        // Query metadata 
        if(paymentRunProgram == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) {
        initializeMetadataMaps();
        }
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return listOfClaims;
    }
    
    /****************************************************************************************************** 
     Method Name:        initializeMetadataMaps
     @return  :          void
     @parameters:        
     Description:        This method queries metadata.Only initializes when the program is CoGTM.
     Added By:           Performance Optimization - 04/14/2026
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    private void initializeMetadataMaps() {
        // Only query metadata if the program is CoGTM
        for(Core_MDF_CCP_Custom_Metadata_Utility__c buSplits : [SELECT Core_MDF_Field_3_txt__c, Core_MDF_Field_5_txt__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c  WHERE Core_MDF_Program__c =: Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM  AND Core_MDF_Category__c = 'BU Splits' AND Core_MDF_Field_3_txt__c != null]) {
            if (!buProdTypeMap.containsKey(buSplits.Core_MDF_Field_3_txt__c)) {
                buProdTypeMap.put(buSplits.Core_MDF_Field_3_txt__c, buSplits.Core_MDF_Field_5_txt__c);
            }
        }
        
        // Query BU Priority Rankings once for CoGTM program
        for (Core_MDF_BUPriorityRanking__c pr : [SELECT Core_MDF_Label__c, Core_MDF_Ranking_nbr__c   FROM Core_MDF_BUPriorityRanking__c  WHERE Core_MDF_Program_Name__c = :Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM]) {
            if (pr.Core_MDF_Label__c != null) {
                buPriorityRankingMap.put(pr.Core_MDF_Label__c, (Integer)pr.Core_MDF_Ranking_nbr__c);
            }
        }
    }
    
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimList) {
        try{
            //ATHR - Deeply Nested if 16209
            if (errorFlag) {
                return;
            }               
                // Grouping Logic Used as key for Creating Payment Records; The Key depends on Program or Budget Type
                String paymentKey = '';
                for(PartnerFundClaim claim : claimList)
                {
                    paymentKey = getPaymentKeyForClaim(claim);
                    //ATHR - Deeply Nested if 16209
		            if(!paymentWrapperMap.containsKey(paymentKey)){
		    	        continue;
		            }
                        // Update Claim Status to Pending Payment
                        claim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Payment');
                        // Update Payment Field on the claim

                        claim.Core_MDF_Payment_Id__c = paymentWrapperMap.get(paymentKey).paymentForClaims.Id;
                        if(paymentRunProgram == 'Intel Partner Alliance' || paymentRunProgram == CoGTMProgram){
                            claim.Core_MDF_Paid_By_Payment_Type_nm__c = claim.Core_MDF_Payment_Type_nm__c;
                        }
                        //Update Payment Rollback Reason as empty
                        claim.Core_MDF_Payment_Rollback_Reason_nm__c = '';
                        // Map of claim Id to Payment Id
                        claimIdtoPaymentId.put(claim.Id, claim.Core_MDF_Payment_Id__c);
                    }
                    
                // Update List of Claims
                if(claimList != NULL && claimList.size()>0){
                    Database.update(claimList);
                }
                
        }
        catch(Exception e){
            errorFlag = true;
            exceptionObject = e;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        try{
            // If No error in any of the transaction
            if(errorFlag == false){
                // Call file generation function
               
                
              
              // Update Payment Id in Claims of Payment Wrapper
                updateClaimsInPaymentWrapper();
              // Share Payment Records with Internal / External Users
                sharePaymentRecords();
                generatePaymentFile();
                // Update Payment Run Status to Completed
                Core_MDF_PaymentProcess.updatePaymentRunRecord(new List<Core_MDF_Payment_Run__c>{prunInstance},Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PayRunStatus_Completed')); 
                // insert new buSplit records if list is non empty
                //if(claimsBUSplitList != NULL && claimsBUSplitList.size()>0){ insert claimsBUSplitList; }
            }
            else{
                // In case of any error, Revert back all the changes like Claim Status and Delete Payment records
                callPaymentRunRollbackBatch(exceptionObject);
            }
        }
        catch(Exception e){
            // In case of any error, Revert back all the changes like Claim Status and Delete Payment records
            callPaymentRunRollbackBatch(e);
        }
    }
    
    /****************************************************************************************************** 
     Method Name:        generatePaymentFile
     @return  :          void
     @parameters:        
     Description:        This Function calls file generator methods depending on the Program/Budget Type
     Added By:           Pranav - Accenture - 05/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public void generatePaymentFile(){
        //ATHR - Deeply Nested if 16209
        if (paymentWrapperMap == null || paymentWrapperMap.isEmpty()) {
            return;
        }
        String runType = getRunType(prunInstance);
        switch on runType {
            when 'RSA_MD' {
                Core_MDF_Payment_FileHelper.generateRsaMdPaymentFile(paymentWrapperMap, prunInstance);
            }
            when 'RETAIL_MDF' {
                Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentFileWrapperMap, prunInstance, paymentRunProgram);
            }
            when 'IPA_MDF' {
                for (String key : paymentTypeToFileWrapper.keySet()) {
                    switch on key {
                        when 'Expense' {
                            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                        }
                        when 'CSAR Cash' {
                            Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                        }
                        when 'CSAR Credit Memo' {
                            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                        }
                        when else {
                            // no-op
                        }
                    }
                }
            }
            when 'COGTM_CSAR' {
                for (String key : paymentTypeToFileWrapper.keySet()) {
                    switch on key {
                        when 'CSAR Cash' {
                            Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                        }
                        when 'CSAR Credit Memo' {
                            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                        }
                    }
                }
            }
            when 'COGTM_VISTEX' {
                if (!Core_MDF_Utility.byPassFeature('Bypass_MDF_Vistex_File_Generation')) {
                    Core_MDF_Payment_FileHelper.generateMDFVistexPaymentFile(paymentWrapperMap, prunInstance, paymentRunProgram);
                }
                if (!Core_MDF_Utility.byPassFeature('Bypass_MDF_Generic_File_Generation')) {
                    Core_MDF_Payment_FileHelper.generateMDFGenericPaymentFile(paymentWrapperMap, prunInstance, paymentRunProgram);
                }
            }
            when 'COGTM_EXPENSE' {
                for (String key : paymentTypeToFileWrapper.keySet()) {
                    if (key == 'Expense') {
                        Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                    }
                }
            }
            when 'MDF_OR_MDF_PLUS' {
                if (!Core_MDF_Utility.byPassFeature('Bypass_MDF_Vistex_File_Generation')) {
                    Core_MDF_Payment_FileHelper.generateMDFVistexPaymentFile(paymentWrapperMap, prunInstance, paymentRunProgram);
                }
                if (!Core_MDF_Utility.byPassFeature('Bypass_MDF_Generic_File_Generation')) {
                    Core_MDF_Payment_FileHelper.generateMDFGenericPaymentFile(paymentWrapperMap, prunInstance, paymentRunProgram);
                }
            }
            when else {
                Core_MDF_Payment_FileHelper.ccpFileGenerator(paymentWrapperMap, prunInstance, paymentRunProgram);
            }
        }
    }
        /*if(Core_MDF_PaymentUtility.isRsaMd(prunInstance)){
                // Payment file for RSA MD
                Core_MDF_Payment_FileHelper.generateRsaMdPaymentFile(paymentWrapperMap,prunInstance); 
            }
            else if(Core_MDF_PaymentUtility.isRetailMdf(prunInstance))
            {
                Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentFileWrapperMap,prunInstance,paymentRunProgram);
            }
            else if(Core_MDF_PaymentUtility.isIPAMdf(prunInstance)){

               for(String key : paymentTypeToFileWrapper.keySet())
                {
                    if(key =='Expense')
                    {
                        Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentTypeToFileWrapper.get(key),prunInstance,paymentRunProgram);
                    }
                    else if(key =='CSAR Cash')
                    {
                      Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentTypeToFileWrapper.get(key),prunInstance,paymentRunProgram);
                    } 
                    else if(key =='CSAR Credit Memo'){
                    Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentTypeToFileWrapper.get(key),prunInstance,paymentRunProgram); 
                    }  
                } 
            } else if(Core_MDF_PaymentUtility.isCoGTMCSARPaymentRun(prunInstance)){
               for(String key : paymentTypeToFileWrapper.keySet()) {
                    if(key == 'CSAR Cash') {
                        Core_MDF_Payment_FileHelper.generateRetailMdforIPAPaymentFile(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram);
                    } else if(key == 'CSAR Credit Memo') {
                        Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentTypeToFileWrapper.get(key), prunInstance, paymentRunProgram); 
                    }
                } 
            } else if(Core_MDF_PaymentUtility.isCoGTMVistexPaymentRun(prunInstance)){
                if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Vistex_File_Generation')){
                    Core_MDF_Payment_FileHelper.generateMDFVistexPaymentFile(paymentWrapperMap,prunInstance,paymentRunProgram);
                }
                
                if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Generic_File_Generation')){
                    Core_MDF_Payment_FileHelper.generateMDFGenericPaymentFile(paymentWrapperMap,prunInstance,paymentRunProgram);
                } 
            } else if(Core_MDF_PaymentUtility.isCoGTMExpensePaymentRun(prunInstance)){
               for(String key : paymentTypeToFileWrapper.keySet()) {
                    if(key == 'Expense') {
                        Core_MDF_Payment_FileHelper.generateIPAPaymentFileForExpense(paymentTypeToFileWrapper.get(key),prunInstance,paymentRunProgram);
                    }
                } 
            }
            //start- MDF&MDF+ code
            else if(Core_MDF_PaymentUtility.isMdfOrMdfPlus(pRunInstance)){
                // Payment file for MDF and MDF+
                if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Vistex_File_Generation'))
                    Core_MDF_Payment_FileHelper.generateMDFVistexPaymentFile(paymentWrapperMap,prunInstance,paymentRunProgram);
                if(!Core_MDF_Utility.byPassFeature('Bypass_MDF_Generic_File_Generation'))
                    Core_MDF_Payment_FileHelper.generateMDFGenericPaymentFile(paymentWrapperMap,prunInstance,paymentRunProgram);
            }
            //end- MDF&MDF+
            else{
                // Payment file for CCP program 
                Core_MDF_Payment_FileHelper.ccpFileGenerator(paymentWrapperMap,prunInstance,paymentRunProgram); 
    }*/
    private String getRunType(Core_MDF_Payment_Run__c prunInstance) {        
        if (Core_MDF_PaymentUtility.isRsaMd(prunInstance)) {
            return 'RSA_MD';
            }
        if (Core_MDF_PaymentUtility.isRetailMdf(prunInstance)) {
            return 'RETAIL_MDF';
        }
        if (Core_MDF_PaymentUtility.isIPAMdf(prunInstance)) {
            return 'IPA_MDF';
        }
        if (Core_MDF_PaymentUtility.isCoGTMCSARPaymentRun(prunInstance)) {
            return 'COGTM_CSAR';
        }
        if (Core_MDF_PaymentUtility.isCoGTMVistexPaymentRun(prunInstance)) {
            return 'COGTM_VISTEX';
        }
        if (Core_MDF_PaymentUtility.isCoGTMExpensePaymentRun(prunInstance)) {
            return 'COGTM_EXPENSE';
        }
        if (Core_MDF_PaymentUtility.isMdfOrMdfPlus(prunInstance)) {
            return 'MDF_OR_MDF_PLUS';
        }
        return 'DEFAULT';
    }
    
    /****************************************************************************************************** 
     Method Name:        getPaymentKeyForClaim
     @return  :          String
     @parameters:        Claim
     Description:        This Function returns Respective Payment Grouping key for a Claim
     Added By:           Pranav - Accenture - 05/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public String getPaymentKeyForClaim(PartnerFundClaim claim){
        String paymentGroupingKey = '';
        List<String> mdfBudgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_BANK_HIDE').Core_MDF_Value__c.split(',');
        List<String> ccfdcfprograms = Core_MDF_Configuration__c.getValues('Programs_For_MDF_PaymentRun').Core_MDF_Value__c.split(',');

        if(claim.Core_MDF_Budget_Type_Options_Nm__c == Label.Core_MDF_RetailMDF_BudgetType){
            if(claim.Core_MDF_VAT_Eligibility_Ind__c)
            {
            paymentGroupingKey = claim.Id+'_'+claim.Core_MDF_C_Type_Ind__c;    
            }
            else{
            // If Budget Type is Retail MDF ;Key Used for Creating Payment Record
            paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c;
            }
            
        }
        else if((claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')  )){

      // GL account changes
            Core_MDF_CCP_Payment_File_Particulars__mdt defaultFileParticulars = [SELECT Core_MDF_GL_Account__c, Core_MDF_GL_Account_CSAR__c, Core_MDF_GL_Account_Customer_NonPO__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt WHERE Core_MDF_Program__c = 'Intel Partner Alliance' LIMIT 1];
            String glAccount = null;
            Core_MDF_Account_Node_Attributes__c nodeAttr = accountNodeAttributesMap.get(claim.ChannelPartnerId);
            if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) {
                glAccount = (nodeAttr != null && nodeAttr.Core_MDF_Final_NonPO_GL_Account_nbr__c != null) ? String.valueOf(nodeAttr.Core_MDF_Final_NonPO_GL_Account_nbr__c) : defaultFileParticulars.Core_MDF_GL_Account__c;
            } else if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO) {
                glAccount = (nodeAttr != null && nodeAttr.Core_MDF_Final_Cust_NonPO_GL_Acc_nbr__c != null) ? String.valueOf(nodeAttr.Core_MDF_Final_Cust_NonPO_GL_Acc_nbr__c) : defaultFileParticulars.Core_MDF_GL_Account_Customer_NonPO__c;
            } else {
                glAccount = (nodeAttr != null && nodeAttr.Core_MDF_Final_CSAR_GL_Account_nbr__c != null) ? String.valueOf(nodeAttr.Core_MDF_Final_CSAR_GL_Account_nbr__c) : defaultFileParticulars.Core_MDF_GL_Account_CSAR__c;
            }
                if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.distributorCreditMemo || claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerPassThrough)
                {
                    paymentGroupingKey = claim.Id+'_'+claim.Core_MDF_C_Type_Ind__c; 
                }
                else{
                    if(claim.Core_MDF_VAT_Eligibility_Ind__c)
                    {
                            paymentGroupingKey = claim.Id+'_'+claim.Core_MDF_C_Type_Ind__c + '_' + glAccount;
                    }
                    else 
                    {
                        if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer)
                        {
                                paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +   '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c+'_'+ claim.Request.Core_MDF_BU_Split__c + '_' + claimToCostCenterMap.get(claim.Id) + '_' + glAccount; 
                        } else if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerNonPO) {
                          paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +   '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c+'_'+ claim.Request.Core_MDF_BU_Split__c + '_' + glAccount; 
                      } else {
                            paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c + '_' + glAccount; 
                        }   
                    }
                       
                }
            
        }
  else if((claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Co_GTM'))) {
            Core_MDF_CCP_Payment_File_Particulars__mdt defaultFileParticulars = [SELECT Core_MDF_GL_Account__c, Core_MDF_GL_Account_CSAR__c, Core_MDF_GL_Account_Customer_NonPO__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt WHERE Core_MDF_Program__c = 'CoGTM' LIMIT 1];
            String glAccount = null;
            if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) {
                glAccount = defaultFileParticulars.Core_MDF_GL_Account__c;
            } else {
                glAccount = defaultFileParticulars.Core_MDF_GL_Account_CSAR__c;
            }

            if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customerCreditMemo) {
                paymentGroupingKey = claim.Id+'_'+claim.Core_MDF_C_Type_Ind__c;
            }
            else if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCash){
                paymentGroupingKey = claim.Core_MDF_Budget_Type_Options_Nm__c != null ? claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c
                                                                         : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c;
            }
            else if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.vistexCreditMemo){
                paymentGroupingKey = claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_' +claim.Core_MDF_Type_Txt__c;   
            }
            else {

                if(claim.Core_MDF_VAT_Eligibility_Ind__c) {
                    paymentGroupingKey = claim.Id+'_'+claim.Core_MDF_C_Type_Ind__c + (glAccount != null ? ('_' + glAccount) : '');
                } else {
                    if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.noncustomer) {
                        paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +   '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c+'_'+ claim.Request.Core_MDF_BU_Split__c + '_' + claimToCostCenterMap.get(claim.Id) + (glAccount != null ? ('_' + glAccount) : ''); 
                    } else {
                    // Customer payment type
                        paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c + '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c + '_' + claim.Core_MDF_Quarter_Year_Txt__c +'_'+claim.Core_MDF_C_Type_Ind__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c + (glAccount != null ? ('_' + glAccount) : '');
                    }

                    // Append Business Unit for non-VAT customer payments
                    if(claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer) {
                        // Derive Business Unit using class-level maps queried once in constructor
                        if(claim != null) {
                            String businessUnit = Core_MDF_PaymentProcessRetailMdfIPA.deriveBUForClaim(claim, buPriorityRankingMap, buProdTypeMap);
                            if(businessUnit != null) {
                                paymentGroupingKey = paymentGroupingKey + '_' + businessUnit;
                            }
                        }
                    }

                    // Append MMID for non-VAT customer payments
                    if (claim.Core_MDF_Payment_Type_nm__c == Core_MDF_PaymentUtility.customer && claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c != null) {
                        paymentGroupingKey = paymentGroupingKey + '_' + claim.Core_MDF_Campaign_Id__r.Core_MDF_MMID__c;
                    }
                }
            }
        }
        else if(claim.Core_MDF_Budget_Type_Options_Nm__c == Label.Core_MDF_Retail_RSA_MD_Budget_Type) {
            // If Budget Type is RSA MD ;Key Used for Creating Payment Record 
            paymentGroupingKey = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
        }
      else if((mdfBudgetTypes.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)) && ccfdcfprograms.contains(claim.Core_MDF_Program__c)){
          // If Budget Type is mdf/mdf+;Key used for Creating Payment Record
            paymentGroupingKey = claim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +'_' +claim.Core_MDF_Type_Txt__c;   
        }
        else{
            // If Program is of any other Comarketing Type - Added Budget type as part of CMP Payment US-US1017409
            paymentGroupingKey = claim.Core_MDF_Budget_Type_Options_Nm__c!= null ? claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c+'_'+claim.Core_MDF_Budget_Type_Options_Nm__c
                                                                         : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + '_' + claim.Core_MDF_Bank__c +  '_' + claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c;
        }
        return paymentGroupingKey;
    }
    
    /****************************************************************************************************** 
     Method Name:        sharePaymentRecords
     @return  :          void
     @parameters:        
     Description:        This Function shares Payment Records with Internal and External Users
     Added By:           Pranav - Accenture - 25/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public void sharePaymentRecords(){
        if(paymentWrapperMap != NULL && paymentWrapperMap.size() > 0)
        {                    
            // This method shares the payment records with Internal Account Manager
            Core_MDF_Payment_Sharing.sharePaymentRecordsToInternalUsers(paymentWrapperMap,'Trigger');
      
            // This method shares the payment records with external users
            //Core_MDF_Payment_Sharing.sharePaymentRecordsToPartner(paymentWrapperMap);
                                   
        }
    }
    
    /****************************************************************************************************** 
     Method Name:        callPaymentRunRollbackBatch
     @return  :          void
     @parameters:        
     Description:        This Function calls Batch Class for Rollbacking Payment Run Changes in Case of Error
     Added By:           Pranav - Accenture - 05/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    public void callPaymentRunRollbackBatch(Exception exceptionObj){
        if(listOfClaims != NULL && listOfClaims.size()>0){
            Core_MDF_Batch_RollbackPaymentRunChanges rollbackPRunChangeBatch = new Core_MDF_Batch_RollbackPaymentRunChanges(listOfClaims, paymentWrapperMap);
            Database.executeBatch(rollbackPRunChangeBatch, 200);
        }
        // Update the Payment Run Status to failed
        Core_MDF_PaymentProcess.updatePaymentRunStatusAndErrorDetails(new List<Core_MDF_Payment_Run__c>{prunInstance},Label.Core_MDF_PayRunStatus_Error,exceptionObj.getMessage()); 
        Core_MDF_CCP_UtilityClass.logError(exceptionObj);
    }
    
    /****************************************************************************************************** 
     Method Name:        updateClaimsInPaymentWrapper
     @return  :          void
     @parameters:        
     Description:        This Function updates Claim's Payment Id in Payment Wrapper Map
     Added By:           Pranav - Accenture - 05/11/2020 
     Modified By:        Date:       Changes: 
    *******************************************************************************************************/

    public void updateClaimsInPaymentWrapper(){
        // Update Claim's Payment Id in Payment Wrapper Map
        if(paymentWrapperMap != NULL && paymentWrapperMap.size()>0){
            for(Core_MDF_PaymentWrapper wrapperObject: paymentWrapperMap.values()){
                for(PartnerFundClaim claim : wrapperObject.claimsToBeProcessed){
                    if(claimIdtoPaymentId.containsKey(claim.Id)){                
                        claim.Core_MDF_Payment_Id__c = claimIdtoPaymentId.get(claim.Id);
                    }
                }
            }
        }
    }
}