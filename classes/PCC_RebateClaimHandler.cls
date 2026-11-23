/****************************************************************************************************
Apex Class Name : PCC_RebateClaimHandler
Version         : 1.0 
Created Date    : 06/Jun/2024
Function        : This class is used to create Rebate Claim object from Staging 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    06/Jun/2024               Created
* Shijas KM                     29/Jun/2024             TWC4767-2144
* Pranjal Rajput                30/Jun/2024             createContentdocumentLink,shareRebateClaim
*****************************************************************************************************/

public with sharing class PCC_RebateClaimHandler { 
    public List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    
    /***************************************************************************************************
* Method Name : createContentdocumentLink
* Purpose     : This method is used to create ContentDocumentLink records for Rebate Claim
****************************************************************************************************/
    public static List<ContentDocumentLink> createContentdocumentLink(String claimId, String rcStageId,Map<String,String> linkedEntityMap){
        
        List<ContentDocumentLink> cdlList =new List<ContentDocumentLink>();
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = linkedEntityMap.get(rcStageId);
        cdl.LinkedEntityId = claimId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        cdlList.add(cdl);
        return cdlList;
    }
    
    
    /***************************************************************************************************
* Method Name : rebateClaimStgQuery
* Purpose     : This method is used to fetch Rebate Claim records from Staging
****************************************************************************************************/
    public static String rebateClaimStgQuery(List<Id> headerIdList) {
        String stageStatus = 'Pending';
        String baseQuery = 'SELECT Id, PCC_Error_Messages__c, Name, PCC_Parent_Record__r.Name, PCC_Partner__c, PCC_Partner__r.Core_Geo__c, PCC_Country__c, PCC_Quote_Line_Id__c, PCC_OEM__c, PCC_ProductId__c, PCC_Opportunity__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastViewedDate, LastReferencedDate, RecordTypeId, IsDeleted, PCC_Quote_Line_Number__c,  PCC_Invoice_Date__c, PCC_Product__c, PCC_Quantity__c, PCC_Quote_Invoice_Number__c, PCC_Status__c, PCC_Parent_Record__c, OwnerId, PCC_Submitted_Claim_Rebate_Amount__c FROM PCC_Rebate_Claim_Stage__c WHERE PCC_Parent_Record__r.PCC_Status__c = \'' + stageStatus + '\'';
        String query = baseQuery + (headerIdList != null && !headerIdList.isEmpty() ? ' AND PCC_Parent_Record__c IN :headerIdList' : '');
        return query;
    }
    
    /***************************************************************************************************
* Method Name : createRebateClaim
* Purpose     : This method is used to create Rebate Claim and Line Item records from Staging
****************************************************************************************************/
    public static void createRebateClaim(Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessMap) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try{
            
            List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLineToInsert = new List<PCC_Rebate_Claim_Line_Item__c>();
            
            Map<Id,PCC_Rebate_Claim__c> createRebateMap = new Map<Id,PCC_Rebate_Claim__c>();
          //  String rebateRecType = 'PCC_Rebate_Claim';
            String lineItemRecType = 'Rebate_Claim_Line_Item';
            Id lineItemRecTypeId = Schema.SObjectType.PCC_Rebate_Claim_Line_Item__c.getRecordTypeInfosByDeveloperName().get(lineItemRecType).getRecordTypeId();
            
            
            createRebateMap = insertRebateClaim(stgSuccessMap);
            string claimID;
            PCC_Rebate_Claim_Stage__c rcStage;
            List<ContentDocumentLink> cdlList =new List<ContentDocumentLink>();
            List<PCC_Rebate_Claim_Stage__c> rcStageList = new List<PCC_Rebate_Claim_Stage__c>();
            List<ContentDocumentLink> listCDL = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :stgSuccessMap.keySet()];
            Map<String,String> linkedEntityMap = new Map<String,String>();
            for(ContentDocumentLink cdl:listCDL){
                linkedEntityMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
            }
            for (Id stgRCId : stgSuccessMap.keySet()) {
                if(createRebateMap.containsKey(stgRCId)){      
                    claimID =  createRebateMap.get(stgRCId).Id; // to get the Claim ID
                    rcStage = new PCC_Rebate_Claim_Stage__c(Id = stgRCId, PCC_Rebate_Claim__c = claimID);
                    rcStageList.add(rcStage);
                    for(PCC_Rebate_Claim_Stage__c rcLineItem: stgSuccessMap.get(stgRCId)){
                        PCC_Rebate_Claim_Line_Item__c rebatelineItem = new PCC_Rebate_Claim_Line_Item__c();
                        rebatelineItem.PCC_Rebate_Claim__c = claimID; // populating claim ID on stage Record
                        rebatelineItem.PCC_Product__c = rcLineItem.PCC_ProductId__c;
                        rebatelineItem.PCC_Invoice__c = rcLineItem.PCC_Quote_Invoice_Number__c;
                        rebatelineItem.PCC_Opportunity__c = rcLineItem.PCC_Opportunity__c;
                        rebatelineItem.PCC_Quote_Line_Number__c = rcLineItem.PCC_Quote_Line_Id__c;
                        rebatelineItem.RecordTypeId = lineItemRecTypeId;
                        rebatelineItem.PCC_Claimed_Rebate_Amount__c=rcLineItem.PCC_Submitted_Claim_Rebate_Amount__c; // copying the claim amount to Rebate Claim Line Item
                        rebatelineItem.PCC_OEM_Name__c=rcLineItem.PCC_OEM__c;
                        rebatelineItem.PCC_Country__c=rcLineItem.PCC_Country__c;
                        rebatelineItem.PCC_Quantity__c = Decimal.valueOf(rcLineItem.PCC_Quantity__c);
                        rebatelineItem.PCC_Invoice_Date__c = Date.parse(rcLineItem.PCC_Invoice_Date__c);
                        rebatelineItem.PCC_Status__c = PCC_Constants.RC_SUBMITTED;
                        rebateClaimLineToInsert.add(rebatelineItem);   
                    }
                    //Create ContentDocumentLink from staging to Rebate Claim Object
                    cdlList = createContentdocumentLink(claimID, stgRCId,linkedEntityMap);
                }
            }
            
            List<PCC_Rebate_Claim__c> rebateClaimsToUpdate = new List<PCC_Rebate_Claim__c>();
            
            rebateClaimsToUpdate=insertRebateClaimLineItems(rebateClaimLineToInsert,stgSuccessMap,createRebateMap);
            if(!rcStageList.isEmpty()){
                Database.update(rcStageList);
            }
            if (!rebateClaimsToUpdate.isEmpty()) {
                Database.update(rebateClaimsToUpdate);
                PCC_RebateClaimApproveController.updateQtyOn6QPS(rebateClaimLineToInsert);
            }   
            
            if(!cdlList.isEmpty()){
                insert cdlList;
            }
        }catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='System Exception', Core_Origin__c='PCC_RebateClaimHandler.createRebateClaim', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
        }finally{ insert logEntries;}
    }
    
    
    
    public static List<PCC_Rebate_Claim_Stage__c> validateLineItems(List<PCC_Rebate_Claim_Stage__c> claimsLst){
        
        Map<String,SBQQ__QuoteLine__c> qlinesMap = new Map<String,SBQQ__QuoteLine__c>();
        Map<String,List<PCC_Rebate_Claim_Line_Item__c>> rebateClaimLinesMap = new Map<String,List<PCC_Rebate_Claim_Line_Item__c>>();
        List<String> stgQLNamesLst = new List<String>();
        List<String> objQLNamesLst = new List<String>();
        List<PCC_Rebate_Claim_Stage__c> updatedStgLst = new List<PCC_Rebate_Claim_Stage__c>();
        List<Id> quoteLinesIds = new List<Id>();
        List<PCC_Rebate_Claim_Line_Item__c> rebateLinesLst = new List<PCC_Rebate_Claim_Line_Item__c>();
        Map<String,Integer> claimQtyMap = new Map<String,Integer>();
        
        try{
            
            for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst){
                if(stagingRec.PCC_Quote_Line_Number__c != null){
                    stgQLNamesLst.add(stagingRec.PCC_Quote_Line_Number__c);
                }
            }
            
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Product_Nm__c,Pricing_Product_Name__c, Pricing_Approved_Unit_Dup_Qty__c,
                                                   SBQQ__Quote__c, SBQQ__Quote__r.Pricing_End_Customer_Account__c,SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Approval_Status__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c,Pricing_OEM_Name_FI_Nm__c, 
                                                   Pricing_FI_Write_In_OEM_Name_Txt__c,Pricing_FI_Net_RPU_Amt__c,Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c 
                                                   FROM SBQQ__QuoteLine__c WHERE Pricing_Quote_Line_Number__c IN :stgQLNamesLst];
            
            
            if(quoteLines.isEmpty()){
                for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst) {
                    Integer errorCount = 0;
                    errorCount = stagingRec.PCC_Error_Messages__c == null ? errorCount+1 : stagingRec.PCC_Error_Messages__c.split(PCC_Constants.RC_LINE_SEPERATOR).size()+1;
                    stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_QLN_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : !stagingRec.PCC_Error_Messages__c.contains(PCC_Constants.RC_QLN_INVALID) && !stagingRec.PCC_Error_Messages__c.contains(PCC_Constants.RC_QLN_BLANK) ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.RC_QLN_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c;
                    stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    updatedStgLst.add(stagingRec);
                }
                
            } 
            
            else {
                
                for(SBQQ__QuoteLine__c qlRec : quoteLines){
                    quoteLinesIds.add(qlRec.Id);
                    objQLNamesLst.add(qlRec.Pricing_Quote_Line_Number__c); //get Quote Lines in a List
                    qlinesMap.put(qlRec.Pricing_Quote_Line_Number__c,qlRec);
                }
                
                Set<String> validQLNames = new Set<String>(stgQLNamesLst);
                Set<String> invalidQLNames = new Set<String>(stgQLNamesLst);
                
                validQLNames.retainAll(objQLNamesLst); //Get only common QLs
                invalidQLNames.removeAll(objQLNamesLst); //remove uncommon QLs
                
                
                //QUERY Rebate Claim Line Item --- To check if any claim submitted for the same Quote Line# 
                rebateLinesLst = [SELECT Id,PCC_Quantity__c, PCC_Quote_Line_Number__c, PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c, 
                                  PCC_Opportunity__c, PCC_Invoice__c, PCC_Status__c FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Quote_Line_Number__c IN :quoteLinesIds 
                                  AND PCC_Status__c IN ('Approved','Submitted')];
                for(PCC_Rebate_Claim_Line_Item__c rcLine : rebateLinesLst){
                    if(rebateClaimLinesMap.containsKey(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c)) {
                        rebateClaimLinesMap.get(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c).add(rcLine);
                    }
                    else {
                        rebateClaimLinesMap.put(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c,new List<PCC_Rebate_Claim_Line_Item__c>{rcLine});
                    }
                }
                /*======================================================================== */
                //Claim Date Validation -- Pricing QL End Date's Quarter Last Date + 30 Days 
                List<Period> qtrList;
                if(Schema.sObjectType.Period.isAccessible()) {
                    qtrList = [SELECT FullyQualifiedLabel,StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType = 'Custom' and Type = 'Quarter'];
                }
                Boolean errflag;
                Integer claimableQty;
                Integer claimedQty;
                Boolean typeError;
                Integer errorCount;
                Date claimLastDate;
                SBQQ__QuoteLine__c quoteLine;
                
                for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst) {
                    errflag = false; 
                    claimableQty = 0; 
                    claimedQty = 0; 
                    typeError = false; 
                    errorCount = 0; 
                    claimLastDate = Date.today();
                    quoteLine = qlinesMap.get(stagingRec.PCC_Quote_Line_Number__c);
                    
                    errorCount = stagingRec.PCC_Error_Messages__c == null ? errorCount+1 : stagingRec.PCC_Error_Messages__c.split(PCC_Constants.RC_LINE_SEPERATOR).size()+1;
                    typeError = stagingRec.PCC_Error_Messages__c == null ? false : true;
                    
                    if(((typeError && (!stagingRec.PCC_Error_Messages__c.contains('Quote Line'))) || !typeError) && (stagingRec.PCC_Quote_Line_Number__c == null || invalidQLNames.contains(stagingRec.PCC_Quote_Line_Number__c))) {
                        
                        stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_QLN_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.RC_QLN_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errorCount++;
                    } 
                    else if(validQLNames.contains(stagingRec.PCC_Quote_Line_Number__c) && quoteLine != null){
                        List<PCC_Rebate_Claim_Line_Item__c> claimedLst = new List<PCC_Rebate_Claim_Line_Item__c>();
                        
                        claimedLst =  rebateClaimLinesMap.get(stagingRec.PCC_Quote_Line_Number__c);
                        
                        /*********** Logic ---- To Calculate Claimable Qty & Claimed Qty ************/
                        if( claimedLst!= null && claimedLst.size() > 0 && !claimQtyMap.containsKey(stagingRec.PCC_Quote_Line_Number__c) ){   
                            
                            
                            for(integer i = 0;i<claimedLst.size();i++){
                                claimedQty = claimedQty+ Integer.valueOf(claimedLst[i].PCC_Quantity__c);
                                
                            }
                            claimableQty = Integer.valueOf(quoteLine.Pricing_Approved_Unit_Dup_Qty__c) > claimedQty ? Integer.valueOf(quoteLine.Pricing_Approved_Unit_Dup_Qty__c) - claimedQty : 0;
                            claimQtyMap.put(stagingRec.PCC_Quote_Line_Number__c,claimableQty);                                
                            
                        }
                        
                        else {
                            claimableQty = Integer.valueOf(quoteLine.Pricing_Approved_Unit_Dup_Qty__c ?? 0);
                            claimQtyMap.put(stagingRec.PCC_Quote_Line_Number__c,claimableQty);
                        } 
                        
                        /* Invoice Date -- Pricing QL End Date's Qtr + 30 days Calculation */
                        for(Period p : qtrList){
                            if((p.startdate <= quoteLine.Pricing_Approved_End_Date_Dup_Dt__c) && (p.enddate >= quoteLine.Pricing_Approved_End_Date_Dup_Dt__c)) {
                                claimLastDate = p.enddate.addDays(30);
                            }  
                        }
                        //Opportunity & Quote Line Status Validation
                        if(quoteLine.Pricing_Status_Nm__c != PCC_Constants.RC_QLSTATUS || quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != PCC_Constants.RC_OPPTYSTAGE || quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Approval_Status__c != PCC_Constants.RC_OPPTYSTATUS ||
                           quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c != PCC_Constants.RC_OPPTYCOVERAGE || quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c != PCC_Constants.RC_COVERAGETYPE) {
                               stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_OPPTY_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.RC_OPPTY_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                               stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                               errflag = true;
                               errorCount++;
                           }
                        
                        //OEM Name Validation
                        if(((typeError && (!stagingRec.PCC_Error_Messages__c.contains('OEM'))) || !typeError) && ((quoteLine.Pricing_OEM_Name_FI_Nm__c == null) || (quoteLine.Pricing_OEM_Name_FI_Nm__c != null && quoteLine.Pricing_OEM_Name_FI_Nm__c != 'Write In OEM Name' && quoteLine.Pricing_OEM_Name_FI_Nm__c != stagingRec.PCC_OEM__c) || (quoteLine.Pricing_OEM_Name_FI_Nm__c == 'Write In OEM Name' && quoteLine.Pricing_FI_Write_In_OEM_Name_Txt__c != null && quoteLine.Pricing_FI_Write_In_OEM_Name_Txt__c != stagingRec.PCC_OEM__c))) { 
                            stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_OEM_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' : '+PCC_Constants.RC_OEM_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR;
                            stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                            errflag = true;
                            errorCount++;
                        }
                        
                        //Product Name Validation
                        if(((typeError && (!stagingRec.PCC_Error_Messages__c.contains('Product Name'))) || !typeError)  && quoteLine.Pricing_Product_Name__c != null && quoteLine.Pricing_Product_Name__c.toLowerCase() != stagingRec.PCC_Product__c.toLowerCase()) {
                            stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_Prod_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' : '+PCC_Constants.RC_Prod_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                            stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                            errflag = true;
                            errorCount++;
                        }
                        
                        //Approved Qty && Claimable Qty Validation
                        if((typeError && (!stagingRec.PCC_Error_Messages__c.contains('Claim Quantity'))) || !typeError){
                            if(integer.valueOf(stagingRec.PCC_Quantity__c) == 0){
                                stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_Qty_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' : '+PCC_Constants.RC_Qty_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                                errflag = true;
                                errorCount++;
                            }else if(integer.valueOf(stagingRec.PCC_Quantity__c) >  claimQtyMap.get(stagingRec.PCC_Quote_Line_Number__c)){
                                stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.RC_CLAIMQTY_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' : '+PCC_Constants.RC_CLAIMQTY_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                                errflag = true;
                                errorCount++;
                            }
                        }
                        
                        //Invoice Date with QL Pricing Start & End Date Range Validation
                        //if(((typeError && (!stagingRec.PCC_Error_Messages__c.contains('Invoice Date '))) || !typeError) && ((stagingRec.PCC_Invoice_Date__c != null && quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c != null && quoteLine.Pricing_Approved_End_Date_Dup_Dt__c != null) && ((Date.parse(stagingRec.PCC_Invoice_Date__c) < quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c) || (Date.parse(stagingRec.PCC_Invoice_Date__c) > quoteLine.Pricing_Approved_End_Date_Dup_Dt__c)))) {
                        if(((typeError && (!stagingRec.PCC_Error_Messages__c.contains('Invoice Date'))) || !typeError) && 
                           ((stagingRec.PCC_Invoice_Date__c != null && quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c != null && quoteLine.Pricing_Approved_End_Date_Dup_Dt__c != null) && 
                            ((Date.parse(stagingRec.PCC_Invoice_Date__c) < quoteLine.Pricing_Approved_Start_Date_Dup_Dt__c) || 
                             (Date.parse(stagingRec.PCC_Invoice_Date__c) > quoteLine.Pricing_Approved_End_Date_Dup_Dt__c)))) {
                                 stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+' :'+PCC_Constants.RC_INVDATE_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+PCC_Constants.RC_INVDATE_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                 stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                                 errflag = true;
                                 errorCount++;
                             }
                        
                        //Claim Submission Date Validation
                        if(Date.today() > claimLastDate){
                            stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+' :'+PCC_Constants.RC_CLAIMDATE_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR : stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+PCC_Constants.RC_CLAIMDATE_INVALID+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                            stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                            errflag = true;
                            errorCount++;
                        }
                        
                        
                        System.debug('Child status>>'+ stagingRec.PCC_Status__c);
                        //Record passed all validation -- Success for Rebate Claim
                        if(!errflag && ( String.isNotBlank(stagingRec.PCC_Status__c) && stagingRec.PCC_Status__c != PCC_Constants.FAILED_STATUS)) {
                            stagingRec.PCC_Status__c = PCC_Constants.SUCCESS_STATUS;
                            stagingRec.PCC_Opportunity__c = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                            stagingRec.PCC_ProductId__c = quoteLine.Pricing_Product_Nm__c;
                            stagingRec.PCC_Quote_Line_Id__c = quoteLine.Id;
                            stagingRec.PCC_Submitted_Claim_Rebate_Amount__c = quoteLine.Pricing_FI_Net_RPU_Amt__c == null ? 0 : quoteLine.Pricing_FI_Net_RPU_Amt__c*Integer.valueOf(stagingRec.PCC_Quantity__c); 
                            
                            Integer tempVar = claimQtyMap.get(stagingRec.PCC_Quote_Line_Number__c);
                            claimableQty =  tempVar >= Integer.valueOf(stagingRec.PCC_Quantity__c ?? '0') ? tempVar - Integer.valueOf(stagingRec.PCC_Quantity__c ?? '0') : claimableQty;  
                            claimQtyMap.put(stagingRec.PCC_Quote_Line_Number__c,claimableQty);
                        }
                        
                    }
                    updatedStgLst.add(stagingRec);
                    
                }
            }//END--ELSE
        }  //END--TRY BLOCK
        
        catch (Exception e) {
            insert new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = e.getMessage() + '\n'+ e.getStackTraceString(), Core_Origin__c='PCC_RebateClaimHandler.validateLineItems', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Rebate Claim');
            
        }
        
        return updatedStgLst;
    }
    
    public static Map<Id,PCC_Rebate_Claim__c> insertRebateClaim(Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessMap){
        
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<Id,PCC_Rebate_Claim__c> createRebateMap = new Map<Id,PCC_Rebate_Claim__c>();
        List<PCC_Rebate_Claim_Stage__c> stageRecords = new List<PCC_Rebate_Claim_Stage__c>();
        try{
            for (Id stgRebateClaimId : stgSuccessMap.keySet()) {
                PCC_Rebate_Claim__c rebateClaimRec = new PCC_Rebate_Claim__c();
                stageRecords = stgSuccessMap.get(stgRebateClaimId);
                rebateClaimRec.PCC_Partner__c = stageRecords[0].PCC_Partner__c;
                rebateClaimRec.PCC_Submitted_By__c =stageRecords[0].CreatedById;
                rebateClaimRec.PCC_Partner_Account_Region__c = stageRecords[0].PCC_Partner__r.Core_Geo__c;
                
                createRebateMap.put(stgRebateClaimId,rebateClaimRec);
            }
            
            if(!createRebateMap.isEmpty()){
                Database.SaveResult[] srList = new Database.SaveResult[] {};
                    srList = Database.insert(createRebateMap.values(),true);    
                for(Database.SaveResult res : srList){
                    if(!res.isSuccess()){
                        for(Database.Error err : res.getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Details__c ='Issue in Insert of Creation of Rebate Claim', Core_Origin__c='PCC_RebateClaimHandler.insertRebateClaim', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
                        }
                    }
                }   
            }
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='System Exception', Core_Origin__c='PCC_RebateClaimHandler.insertRebateClaim', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));
        }finally{
            insert logEntries;
        }
        return createRebateMap;
    }
    
    public static List<PCC_Rebate_Claim__c> insertRebateClaimLineItems(List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLineToInsert,Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessMap,Map<Id,PCC_Rebate_Claim__c> createRebateMap){
        
        String rebateRecType = 'PCC_Rebate_Claim';
        List<PCC_Rebate_Claim__c> rebateClaimsToUpdate = new List<PCC_Rebate_Claim__c>();
        Id rebateRecTypeId = Schema.SObjectType.PCC_Rebate_Claim__c.getRecordTypeInfosByDeveloperName().get(rebateRecType).getRecordTypeId();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        try{
            
            if (!rebateClaimLineToInsert.isEmpty()) {
                Database.SaveResult[] srList = new Database.SaveResult[] {};
                    srList = Database.insert(rebateClaimLineToInsert,true);
                Boolean allLineItemSubmitted = true;
                for(Database.SaveResult res : srList){
                    if(res.isSuccess()){
                        PCC_Rebate_Claim_Line_Item__c insertedLIRecord = rebateClaimLineToInsert[srList.indexOf(res)];
                        if (insertedLIRecord.PCC_Status__c != PCC_Constants.RC_SUBMITTED) {
                            allLineItemSubmitted = false; 
                        }
                    }else{
                        allLineItemSubmitted = false;
                        for(Database.Error err : res.getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Details__c ='Issue in Insert of Creation of Rebate Claim Line Item', Core_Origin__c='PCC_RebateClaimHandler.insertRebateClaimLineItems', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
                        }
                        
                    }
                } 
                
                if (allLineItemSubmitted) {
                    for (Id stgRCId : stgSuccessMap.keySet()) {
                        if (createRebateMap.containsKey(stgRCId)) {
                            PCC_Rebate_Claim__c rebateClaimToUpdate = createRebateMap.get(stgRCId);
                            rebateClaimToUpdate.PCC_Claim_Status__c = PCC_Constants.RC_CLAIM_SUBMITTED;
                            rebateClaimToUpdate.PCC_Submission_Date__c = System.Now();
                            // rebateClaimToUpdate.PCC_Partner__c = stageRecords[0].PCC_Partner__c;
                            //  rebateClaimToUpdate.PCC_Submitted_By__c =stageRecords[0].CreatedById;
                            //  rebateClaimToUpdate.PCC_Partner_Account_Region__c = stageRecords[0].PCC_Partner__r.Core_Geo__c; 
                            rebateClaimToUpdate.RecordTypeId =rebateRecTypeId;
                            rebateClaimsToUpdate.add(rebateClaimToUpdate);
                        }
                    }
                }       
            } 
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='System Exception', Core_Origin__c='PCC_RebateClaimHandler.insertRebateClaimLineItems', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));
            
        }finally{
            insert logEntries;
            
        }
        return rebateClaimsToUpdate;	
        
    }
    
    
}