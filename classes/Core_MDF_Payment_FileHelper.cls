public without sharing class Core_MDF_Payment_FileHelper {

   public static Core_MDF_CCP_Payment_File_Particulars__mdt fileParticulars;
   public static string geo;
   public static string pRunNumber;    

/****************************************************************************************************** 
Method Name:        fileGenerator
@return  :          void 
@parameters:        List of groups for which there should be an entry in the payment file
Description:        This method is used for generating the lineitems to used to create the payment file
Added By:           Intel - SM - 02/01/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void fileGenerator(Map<String,Core_MDF_PaymentWrapper> grps,Core_MDF_Payment_Run__c pRunInstance, string program){
        
            //Get the metadata for the given program
            fileParticulars = [SELECT Id, Label, Core_MDF_Batch_Header_Record__c, Core_MDF_Batch_Trailer_Record__c, Core_MDF_Invoice_Header_Record__c, Core_MDF_Invoice_Line_Item__c, 
                               Core_MDF_Program__c, Core_MDF_Invoice_Type__c, Core_MDF_Profit_Center__c, Core_MDF_Cost_Center__c, Core_MDF_GL_Account__c, Core_MDF_Commodity_Code__c, 
                               Core_MDF_Approver_WWID__c, Core_MDF_City__c, Core_MDF_Region__c, Core_MDF_Country__c, Core_MDF_Postal_Code__c, Core_MDF_Payment_File_Code__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt
                               where Label =:program Limit 1];
        
            geo = pRunInstance.Core_MDF_Geo_Txt__c;
            Core_MDF_CCP_Geo_wise_Payment_Approvers__mdt paymentApprover = [SELECT Id, Core_MDF_Approver_WWID__c, Core_MDF_Program__c, Core_MDF_Geo__c 
                                                                            FROM Core_MDF_CCP_Geo_wise_Payment_Approvers__mdt
                                                                            WHERE Core_MDF_Program__c = :program AND Core_MDF_Geo__c = :geo Limit 1];
            
            pRunNumber = pRunInstance.Name;
            //Beginning of the file
            //Final string to be inserted into the file
            string finalPayRunRecord = generateHeader() + Core_MDF_PaymentUtility.newline;
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
                        line2.add(string.valueOf(rowNumber));
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
                        line2.add(fileParticulars.Core_MDF_Postal_Code__c );
                        line2.add(fileParticulars.Core_MDF_Country__c);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(paymentApprover.Core_MDF_Approver_WWID__c);
                        line2.add(fileParticulars.Core_MDF_Commodity_Code__c);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank);
                        line2.add(Core_MDF_PaymentUtility.blank); 
                        
                        string paymentRunRecord = fileLineItemToString(line1) + Core_MDF_PaymentUtility.newline + fileLineItemToString(line2) + Core_MDF_PaymentUtility.newline;
                        finalPayRunRecord = finalPayRunRecord +paymentRunRecord ;
                    }
                    
                }
            }
            //End of the file
            finalPayRunRecord = finalPayRunRecord + generateFooter() + Core_MDF_PaymentUtility.newline;
            
            List<string> fileTypes = Label.Core_MDF_Payment_File_Types.split(';');
            List<Id> contentDocIds = createContentFile(fileTypes, finalPayRunRecord);
            attachFileToPRun(contentDocIds, pRunInstance);
       
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
    public static string generateFileName()
    {
        string fileName = Core_MDF_PaymentUtility.batchName + geo + Core_MDF_PaymentUtility.underscore + pRunNumber + Core_MDF_PaymentUtility.underscore + Core_MDF_PaymentUtility.one +
                          Core_MDF_PaymentUtility.underscore + system.now().format('yyyyMMddHHmm');
        return fileName;
    }
    
}