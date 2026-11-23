public without sharing class Core_MDF_Payment_FileHelperPOC {

   /*public static Core_MDF_CCP_Payment_File_Particulars__mdt fileParticulars;
   public static string geo;
   public static string pRunNumber;  */  

/****************************************************************************************************** 
Method Name:        fileGenerator
@return  :          void 
@parameters:        List of groups for which there should be an entry in the payment file
Description:        This method is used for generating the lineitems to used to create the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    /*public static void fileGenerator(Map<String,Core_MDF_PaymentWrapper> grps,Core_MDF_Payment_Run__c pRunInstance, string program){
        
            //Get the metadata for the given program
            fileParticulars = [SELECT Id, Label, Core_MDF_Batch_Header_Record__c, Core_MDF_Batch_Trailer_Record__c, Core_MDF_Invoice_Header_Record__c, Core_MDF_Invoice_Line_Item__c, 
                               Core_MDF_Program__c, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_Cost_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, 
                               Core_MDF_Approver_WWID__c, Core_MDF_City__c, Core_MDF_Region__c, Core_MDF_Country__c, Core_MDF_Postal_Code__c, Core_MDF_Payment_File_Code__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt
                               where Label =:program Limit 1];
            system.debug('fileparticularscc'+fileParticulars);
            geo = pRunInstance.Core_MDF_Geo_Txt__c;
            Core_MDF_CCP_Geo_wise_Payment_Approvers__mdt paymentApprover = [SELECT Id, Core_MDF_Approver_WWID__c, Core_MDF_Program__c, Core_MDF_Geo__c 
                                                                            FROM Core_MDF_CCP_Geo_wise_Payment_Approvers__mdt
                                                                            WHERE Core_MDF_Program__c = :program AND Core_MDF_Geo__c = :geo Limit 1];
            system.debug('paymentApproverVf'+paymentApprover);
            pRunNumber = pRunInstance.Name;
            //Beginning of the file
            //Final string to be inserted into the file
            string finalPayRunRecord = generateHeader() + Core_MDF_PaymentUtilityPOC.newline;
            string intelCode = '';
            string paymentMethod;
            Integer rowNumber = 0;
            
            //To generate line items for the file for each payment record
            if(grps != NULL && grps.size() > 0){
                for(String k : grps.keySet()) {
                    rowNumber++;
                    if(grps.get(k).claimsToBeProcessed != Null && grps.get(k).claimsToBeProcessed.size() > 0 && paymentApprover != Null)
                    {
                        PartnerFundCLaim claim = grps.get(k).claimsToBeProcessed[0];
                        intelCode = claim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                        paymentMethod = claim.Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c;
                        List<string> line1 = new List<string>();
                        line1.add(fileParticulars.Core_MDF_Invoice_Header_Record__c);
                        line1.add(fileParticulars.Core_MDF_Invoice_Type__c);
                        line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c != null ? claim.Core_MDF_Bank__r.Core_MDF_Supplier_Name__c.remove(',') : Core_MDF_PaymentUtilityPOC.blank);                        
                        line1.add(claim.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c);
                        line1.add(Core_MDF_PaymentUtilityPOC.blank);
                        line1.add(fileParticulars.Core_MDF_Region__c);
                        line1.add(intelCode == '' ? Core_MDF_PaymentUtilityPOC.intelLegalCode : intelCode);
                        line1.add(grps.get(k).paymentForClaims.Core_MDF_Payment_No_Txt__c);
                        line1.add(system.today().format());
                        line1.add(string.valueOf(grps.get(k).paymentForClaims.Core_MDF_Paid_Amt__c));
                        line1.add(Core_MDF_PaymentUtilityPOC.curr);
                        line1.add(Core_MDF_PaymentUtilityPOC.blank);
                        line1.add(Core_MDF_PaymentUtilityPOC.blank);
                        line1.add(Core_MDF_PaymentUtilityPOC.zero);
                        line1.add(Core_MDF_PaymentUtilityPOC.zero);
                        line1.add(Core_MDF_PaymentUtilityPOC.blank);
                        line1.add(paymentMethod == 'None' ? Core_MDF_PaymentUtilityPOC.blank : paymentMethod);
                        line1.add(Core_MDF_PaymentUtilityPOC.blank);
                        line1.add(fileParticulars.Core_MDF_City__c);
                        line1.add(fileParticulars.Core_MDF_Region__c);
                        line1.add(fileParticulars.Core_MDF_Postal_Code__c);
                        line1.add(fileParticulars.Core_MDF_Country__c);
                        
                        List<string> line2 = new List<string>();
                        line2.add(fileParticulars.Core_MDF_Invoice_Line_Item__c);
                        line2.add(string.valueOf(rowNumber));
                        line2.add(fileParticulars.Core_MDF_Profit_Center__c == null ? Core_MDF_PaymentUtilityPOC.blank : fileParticulars.Core_MDF_Profit_Center__c);
                        line2.add(fileParticulars.Core_MDF_Cost_Center__c == null ? Core_MDF_PaymentUtilityPOC.blank : fileParticulars.Core_MDF_Cost_Center__c);
                        line2.add(fileParticulars.Core_MDF_GL_Account__c);
                        line2.add(string.valueOf(grps.get(k).paymentForClaims.Core_MDF_Paid_Amt__c));
                        line2.add(Core_MDF_PaymentUtilityPOC.zero);
                        line2.add(Core_MDF_PaymentUtilityPOC.zero);
                        if(intelCode == Core_MDF_PaymentUtilityPOC.blank || intelCode == Core_MDF_PaymentUtilityPOC.intelLegalCode || intelCode == Core_MDF_PaymentUtilityPOC.intelCoCode)
                        {
                            line2.add(Core_MDF_PaymentUtilityPOC.iOne);
                        }
                        else
                        {
                            line2.add(Core_MDF_PaymentUtilityPOC.iZero);
                        }
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(fileParticulars.Core_MDF_City__c);
                        line2.add(fileParticulars.Core_MDF_Region__c);
                        line2.add(fileParticulars.Core_MDF_Postal_Code__c );
                        line2.add(fileParticulars.Core_MDF_Country__c);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(paymentApprover.Core_MDF_Approver_WWID__c);
                        line2.add(fileParticulars.Core_MDF_Commodity_Code__c);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank);
                        line2.add(Core_MDF_PaymentUtilityPOC.blank); 
                        
                        string paymentRunRecord = fileLineItemToString(line1) + Core_MDF_PaymentUtilityPOC.newline + fileLineItemToString(line2) + Core_MDF_PaymentUtilityPOC.newline;
                        finalPayRunRecord = finalPayRunRecord +paymentRunRecord ;
                    }
                    
                }
            }
            //End of the file
            finalPayRunRecord = finalPayRunRecord + generateFooter() + Core_MDF_PaymentUtilityPOC.newline;
            
            List<string> fileTypes = Label.Core_MDF_Payment_File_Types.split(';');
            List<Id> contentDocIds = createContentFile(fileTypes, finalPayRunRecord);
            attachFileToPRun(contentDocIds, pRunInstance);
       
    }*/
    
    /****************************************************************************************************** 
    Method Name:        createContentFile
    @return  :          List<Id> - content document id's of the generated files
    @parameters:        List of type of files to be generated and the content of the file in string
    Description:        This method is used to create content file.
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static List<Id> createContentFile(List<String> fileType, string content)
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
        
    }*/
    
    /****************************************************************************************************** 
    Method Name:        createContentVersion
    @return  :          List<Id> - content document id's of the generated files
    @parameters:        List of type of files to be generated and the content of the file in binary
    Description:        This method is used for generating the ContentVersions and Content Documents
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static List<Id> createContentVersion(List<String> fileType, String binaryStringInput){               
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
                conVersion.ReasonForChange = Label.Core_MDF_ContentVersion_ReasonForChange;
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
    }*/
    
     /****************************************************************************************************** 
    Method Name:        attachFileToPRun
    @return  :          void
    @parameters:        List of id's of the ContentDocument and the Payment Run instance that it has to be attached to.
    Description:        This method is used for attaching a Payment File to the Payment Run instance
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static void attachFileToPRun(List<Id> contentDocId, Core_MDF_Payment_Run__c pRunInstance)
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
        
    }*/
  
    /****************************************************************************************************** 
    Method Name:        fileLineItemToString
    @return  :          string
    @parameters:        List of string
    Description:        Method to convert List of string to a string to be inserted into the file along with Tabs.
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static string fileLineItemToString(List<string> line)
    {
        string finalString = '';
        for(string lineItem : line){
            finalString = finalString + lineItem + Core_MDF_PaymentUtility.tab;
        }
        return finalString;
    }*/
    
    /****************************************************************************************************** 
    Method Name:        generateHeader
    @return  :          string
    @parameters:        
    Description:        Method to generating the header for the payment file
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/  
    /*public static string generateHeader()
    {
        List<string> header = new List<string>();
        header.add(fileParticulars.Core_MDF_Batch_Header_Record__c);
        header.add(fileParticulars.Core_MDF_Payment_File_Code__c);
        header.add(system.today().format());
        header.add(system.now().format('HH:mm:ss'));
        header.add(fileParticulars.Core_MDF_Program__c);
        return fileLineItemToString(header);
    }*/
    
    /****************************************************************************************************** 
    Method Name:        generateFooter
    @return  :          string
    @parameters:        
    Description:        Method to generating the footer for the payment file
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/  
    /*public static string generateFooter()
    {
        List<string> footer = new List<string>();
        footer.add(fileParticulars.Core_MDF_Batch_Trailer_Record__c);
        footer.add(fileParticulars.Core_MDF_Payment_File_Code__c);
        return fileLineItemToString(footer);
    }*/
    
    /****************************************************************************************************** 
    Method Name:        generateFileName
    @return  :          string
    @parameters:        
    Description:        Method to generating the name for the payment file
    Added By:           Intel - SM - 02/01/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/  
    /*public static string generateFileName()
    {
        string fileName = Core_MDF_PaymentUtility.batchName + geo + Core_MDF_PaymentUtility.underscore + pRunNumber + Core_MDF_PaymentUtility.underscore + Core_MDF_PaymentUtility.one +
                          Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm');
        return fileName;
    }*/
    
    /****************************************************************************************************** 
    Method Name:        generateRsaMdPaymentFile
    @return  :          void
    @parameters:        groups
    Description:        Method to generate and attach the RSA MD payment file
    Added By:           Krishna - Accenture - 01/13/2020
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    
    /*public static void generateRsaMdPaymentFile(Map<String,Core_MDF_PaymentWrapper> paymentWrapper,Core_MDF_Payment_Run__c pRunInstance){
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        //Payment Run Geo
        geo = pRunInstance.Core_MDF_Geo_Txt__c;
        // Final string to be inserted into the file
        String finalPaymentFileRecord = '';
        // Final string to preparing content
        String finalPaymentFileContent = '';
        // Column Headers
        string paymentFileHeader = Label.Core_MDF_AccountCompany +Core_MDF_PaymentUtility.tab +Label.Core_MDF_PaymentId +Core_MDF_PaymentUtility.tab +Label.Core_MDF_AccountNode +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ClaimID+Core_MDF_PaymentUtility.tab+Label.Core_MDF_ClaimName +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Program +Core_MDF_PaymentUtility.tab +Label.Core_MDF_CountryLocation +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ActivityId +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Activity_Types +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ClaimStartDate +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ClaimEndDate +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ClaimCreatedDate +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ClaimApprovalDate +Core_MDF_PaymentUtility.tab +Label.Core_MDF_LastPopReceivedDate +Core_MDF_PaymentUtility.tab +Label.Core_MDF_RequestedAmount +Core_MDF_PaymentUtility.tab +Label.Core_MDF_AuditAdjustmentAmount +Core_MDF_PaymentUtility.tab +Label.Core_MDF_ReimbursementAmount +Core_MDF_PaymentUtility.tab +Core_MDF_PaymentUtility.newline;
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
                        system.debug('sdsi::'+activityNumber);
                        line1.add(activityNumber);                        
                        line1.add(claim.Core_MDF_Activity_Types__c);
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_Start_Date__c));
                        line1.add(String.valueOf(claim.Core_MDF_Ad_Run_End_Date__c));
                        line1.add(String.valueOf((claim.CreatedDate).date()));
                        line1.add(String.valueOf((claim.Core_MDF_RMF_Claim_Approval_Dt__c)));//Claim Approval Date
                        line1.add(String.valueOf((claim.Core_MDF_RMF_Last_POP_Submission_Dt__c)));//Last POP Recd Date
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
        //File Types
        List<string> fileTypes = Label.Core_MDF_Payment_File_Types.split(';');
        //Create content file
        List<Id> contentDocIds = createContentFile(fileTypes, finalPaymentFileRecord);
        //attach file to Payment run
        attachFileToPRun(contentDocIds, pRunInstance);
    }*/
    /****************************************************************************************************** 
    Method Name:        generateRetailMdfPaymentFile
    @return  :          void
    @parameters:        List of groups for which there should be an entry in the payment file
    Description:        Method to generate and attach the Retail MDF payment file
    Added By:           Pranav - Accenture - 14/7/2020 
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    /*public static void generateRetailMdfPaymentFile(Map<String,Core_MDF_RMF_PaymentFileWrapper> paymentFileWrapper, Core_MDF_Payment_Run__c pRunInstance , string program){      
        //Payment Run Name
        pRunNumber = pRunInstance.Name;
        //Payment Run Geo
        geo = pRunInstance.Core_MDF_Geo_Txt__c;
        // Content of Payment File Excluding Headers
        string paymentFileContent = '';        
        // Final string to be inserted into the file
        String finalPaymentFileRecord = '';
        // Intel's Work Week
        String intelworkweek = '';              
        // Get All Geo And Geo Code as well as sales Org Code from Metadata
        Map<String, Core_MDF_Geo_code_Mapping__mdt>  geoMapping = new Map<String,Core_MDF_Geo_code_Mapping__mdt>();
       
        for(Core_MDF_Geo_code_Mapping__mdt geocode : [Select Id, MasterLabel, DeveloperName, Core_MDF_Geo_Sales_Org_Code_txt__c, Core_MDF_Geo_Code_txt__c FROM Core_MDF_Geo_code_Mapping__mdt ])
        {
            geoMapping.put(geocode.MasterLabel , geocode);
        }
        
        // Get Country's Geo, SubGeo from the metadata
        Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoSubGeoMap = new Map<String, Core_MDF_CCP_Country_Geo_Mapping__mdt>();
        
        for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [Select MasterLabel, DeveloperName, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt ]){
            countryGeoSubGeoMap.put(countryGeo.MasterLabel, countryGeo);
        }
        
        // Get Product Category Metadata records 
        Map<String, Core_MDF_Product_Category__mdt>  prodCategoryMapping = new Map<String,Core_MDF_Product_Category__mdt>();
        
        for(Core_MDF_Product_Category__mdt prodCategory : [Select Id, MasterLabel, Core_MDF_Material_Code_txt__c, Core_MDF_Profit_Center_txt__c, Core_MDF_Budget_Type_txt__c, Core_MDF_Program_txt__c FROM Core_MDF_Product_Category__mdt ])
        {
            prodCategoryMapping.put(prodCategory.MasterLabel , prodCategory);
        }
        
        // Get Intel Work Week for the payment run start date field
        intelworkweek = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
                        
        //Get the metadata for the given program
        fileParticulars = [SELECT Id, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, Core_MDF_Program_ID__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt where Label =:program Limit 1];
                               
        // Column Headers
        string paymentFileHeader = Label.Core_MDF_InvoiceType +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Customer_Number +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Reference_Number +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Legal_Entity +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Fund_Quarter +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Payment_Sequence +Core_MDF_PaymentUtility.tab +Label.Core_MDF_External_Comments +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Header_Description +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Payment_Method_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Payment_Method_Supplement_code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Currency_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Line_Amount +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Tax_VAT +Core_MDF_PaymentUtility.tab +Label.Core_MDF_GST_Amount +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Profit_Center +Core_MDF_PaymentUtility.tab +Label.Core_MDF_GL_Acct +Core_MDF_PaymentUtility.tab + Label.Core_MDF_SAP_Tax_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Commodity_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Line_Item_Description +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Internal_Comments +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Sales_Org_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Buy_From_City +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Buy_From_Region +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Buy_From_Postal_Code +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Buy_From_Country +Core_MDF_PaymentUtility.tab +Label.Core_MDF_Currency_Conversion_Reqd_Y_N + Core_MDF_PaymentUtility.tab +
            Label.Core_MDF_Material_Code + Core_MDF_PaymentUtility.tab + Label.Core_MDF_Geo_Code + Core_MDF_PaymentUtility.newline; 
         
        for(String k : paymentFileWrapper.keySet()) {
            if(paymentFileWrapper.get(k).claimsToBeProcessed != Null && paymentFileWrapper.get(k).claimsToBeProcessed.size() > 0 )
            {
                List<string> line1 = new List<string>();
                line1.add(fileParticulars.Core_MDF_Invoice_Type__c);
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Number__c);
                line1.add(paymentFileWrapper.get(k).quarterNum + paymentFileWrapper.get(k).fiscalYear.right(2) + '' + intelworkweek.subString(0,4) + '' + 'MDF');
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c);
                line1.add(paymentFileWrapper.get(k).fiscalYear + paymentFileWrapper.get(k).quarterNum.right(1).leftPad(2 , '0'));
                line1.add('1');
                line1.add(paymentFileWrapper.get(k).quarterNum + paymentFileWrapper.get(k).fiscalYear.right(2) + '' + intelworkweek.subString(0,4) + '' + 'MDF');
                line1.add('MDF');
                line1.add('');
                line1.add('');                    
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Currency_cd__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Currency_cd__c : '');                    
                line1.add(string.valueOf(paymentFileWrapper.get(k).sumOfConvertedAmount));
                line1.add('0');
                line1.add('0');
                line1.add(paymentFileWrapper.get(k).productCategory != NULL ? prodCategoryMapping.get(paymentFileWrapper.get(k).productCategory).Core_MDF_Profit_Center_txt__c : '');
                line1.add(fileParticulars.Core_MDF_GL_Account__c);
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Tax_codes_cd__c : '');
                line1.add(fileParticulars.Core_MDF_Commodity_Code__c);  
                line1.add(paymentFileWrapper.get(k).geoLocation == 'ASMO' ? paymentFileWrapper.get(k).quarterNum + paymentFileWrapper.get(k).fiscalYear.right(2) + '/MDF/RSA' + paymentFileWrapper.get(k).paymentForClaims.Name + '/' + paymentFileWrapper.get(k).subGeoLocation 
                          : paymentFileWrapper.get(k).quarterNum + paymentFileWrapper.get(k).fiscalYear.right(2) + '/MDF/RSA' + paymentFileWrapper.get(k).paymentForClaims.Name + '/' + paymentFileWrapper.get(k).geoLocation);
                line1.add(fileParticulars.Core_MDF_Program_ID__c);
                line1.add(geoMapping.get(countryGeoSubGeoMap.get(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c).Core_MDF_Geo__c).Core_MDF_Geo_Sales_Org_Code_txt__c);
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_City_txt__c : '');
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Region_txt__c : '');                  
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Postal_Code_cd__c : '' );
                line1.add(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c != NULL ? paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c : '');
                line1.add('N');
                line1.add(paymentFileWrapper.get(k).productCategory != NULL ? prodCategoryMapping.get(paymentFileWrapper.get(k).productCategory).Core_MDF_Material_Code_txt__c : '');
                line1.add(geoMapping.get(countryGeoSubGeoMap.get(paymentFileWrapper.get(k).claimsToBeProcessed[0].Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c).Core_MDF_Geo__c).Core_MDF_Geo_Code_txt__c);
                String tempPaymentFileContent = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline;
                //Preparing record content
                paymentFileContent = paymentFileContent +tempPaymentFileContent ;
            }
        }
                
        finalPaymentFileRecord = paymentFileHeader  + paymentFileContent ; 
        
        //File Types
        List<string> fileTypes = Label.Core_MDF_Payment_File_Types.split(';');
        //Create content file
        List<Id> contentDocIds = createContentFile(fileTypes, finalPaymentFileRecord);
        //attach file to Payment run
        attachFileToPRun(contentDocIds, pRunInstance);
    }*/
}