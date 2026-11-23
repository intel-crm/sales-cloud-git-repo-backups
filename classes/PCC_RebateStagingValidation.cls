public without sharing class PCC_RebateStagingValidation{

    @AuraEnabled
    public static List<PCC_Rebate_Claim_Stage__c> validateLineItems(List<PCC_Rebate_Claim_Stage__c> claimsLst){
        List<PCC_Rebate_Claim_Stage__c> childLst = new List<PCC_Rebate_Claim_Stage__c>();
        List<PCC_Rebate_Claim_Stage__c> stgLinesLst = new List<PCC_Rebate_Claim_Stage__c>();
        Map<String,SBQQ__QuoteLine__c> qlinesMap = new Map<String,SBQQ__QuoteLine__c>();
        Map<String,List<PCC_Rebate_Claim_Line_Item__c>> rebateClaimLinesMap = new Map<String,List<PCC_Rebate_Claim_Line_Item__c>>();
        List<String> stgQLNamesLst = new List<String>();
        List<String> objQLNamesLst = new List<String>();
        List<PCC_Rebate_Claim_Stage__c> updatedStgLst = new List<PCC_Rebate_Claim_Stage__c>();
        List<Id> quoteLinesIds = new List<Id>();
        List<PCC_Rebate_Claim_Line_Item__c> rebateLinesLst = new List<PCC_Rebate_Claim_Line_Item__c>();

        String quoteLine_ErrMsg = LabelConfiguration__mdt.getInstance('PCC_QL_Incorrect_ErrMsg').Value__c;
        String oppty_ErrMsg = LabelConfiguration__mdt.getInstance('PCC_QL_Oppty_Status_ErrMsg').Value__c;
        String oem_ErrMsg = LabelConfiguration__mdt.getInstance('PCC_QL_OEM_Name_ErrMsg').Value__c;
        String productName_ErrMsg = LabelConfiguration__mdt.getInstance('PCC_QL_Product_Name_ErrMsg').Value__c;
        String quantity_ErrMsg = LabelConfiguration__mdt.getInstance('PCC_QL_Qty_ErrMsg').Value__c;
        
        try{
		
             for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst){
                if(stagingRec.PCC_Quote_Line_Number__c != null){
                    stgQLNamesLst.add(stagingRec.PCC_Quote_Line_Number__c);
                }
            }
           system.debug('@@stgQLNamesLst=='+stgQLNamesLst);
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name,Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,Pricing_Product_Nm__c,Pricing_Product_Name__c, Pricing_Approved_Unit_Qty__c,
                                                  Pricing_Total_Volume_Qty__c,SBQQ__Quote__c, SBQQ__Quote__r.Pricing_End_Customer_Account__c,SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName,
                                                  Pricing_OEM_Name_FI_Nm__c, Pricing_FI_Write_In_OEM_Name_Txt__c,Pricing_FI_Net_RPU_Amt__c from SBQQ__QuoteLine__c where Pricing_Quote_Line_Number__c IN :stgQLNamesLst];
            
        
        system.debug('@@Query quoteLines=='+quoteLines);
            if(quoteLines.isEmpty()){
                 
				 for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst) {
                 Integer errorCount = 0;
                 errorCount = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c.split(PCC_Constants.RC_LINE_SEPERATOR).size()+1 : errorCount+1 ;
                 stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' : '+'Specified Invalid QuoteLine Number'+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' : '+'Specified Invalid QuoteLine Number'+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Incorrect_ErrMsg
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
           system.debug('@@qlinesMap=='+qlinesMap);
            //Set<String> stgQLNames = new Set<String>(stgQLNamesLst);
            //Set<String> objQLNames = new Set<String>(objQLNamesLst);
            Set<String> validQLNames = new Set<String>(stgQLNamesLst);
            Set<String> invalidQLNames = new Set<String>(stgQLNamesLst);
            
            validQLNames.retainAll(objQLNamesLst); //Get only common QLs
            invalidQLNames.removeAll(objQLNamesLst); //remove uncommon QLs
            
            rebateLinesLst = [SELECT Id,PCC_Quantity__c, PCC_Quote_Line_Number__c, PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c, PCC_Opportunity__c, PCC_Invoice__c, PCC_Status__c from PCC_Rebate_Claim_Line_Item__c where PCC_Quote_Line_Number__c IN :quoteLinesIds and PCC_Status__c IN ('Approved','Submitted')];
            for(PCC_Rebate_Claim_Line_Item__c rcLine : rebateLinesLst){
                if(rebateClaimLinesMap.containsKey(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c)) {
                rebateClaimLinesMap.get(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c).add(rcLine);
                }
                else {
                    rebateClaimLinesMap.put(rcLine.PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c,new List<PCC_Rebate_Claim_Line_Item__c>{rcLine});
                }
            }
            /*======================================================================== */
            
            for(PCC_Rebate_Claim_Stage__c stagingRec : claimsLst) {
                 Boolean errflag = false;
                 Integer claimableQty = 0;
                 Integer claimedQty = 0;
                 SBQQ__QuoteLine__c quoteLine = qlinesMap.get(stagingRec.PCC_Quote_Line_Number__c);
                 system.debug('@@quoteLine=='+quoteLine);
            if(quoteLine != null) { 
                 List<PCC_Rebate_Claim_Line_Item__c> claimedLst = new List<PCC_Rebate_Claim_Line_Item__c>();
                 /*Logic ---- To Calculate Claimable Qty & Claimed Qty */
                 if(!rebateClaimLinesMap.isEmpty()){
                     claimedLst =  rebateClaimLinesMap.get(stagingRec.PCC_Quote_Line_Number__c);
                    if( claimedLst!= null && claimedLst.size() > 0){
                        system.debug('@@claimedLst=='+claimedLst+'==Size=='+claimedLst.size());
                        for(integer i = 0;i<claimedLst.size();i++){
                        claimedQty = claimedQty+ Integer.valueOf(claimedLst[i].PCC_Quantity__c);
                        system.debug('@@claimedQty=='+claimedQty);
                    }
                    claimableQty = Integer.valueOf(quoteLine.Pricing_Approved_Unit_Qty__c) - claimedQty;
                    system.debug('@@claimableQty=='+claimableQty);
                    }
                 }
                 else {
                    //claimableQty = quoteLine.Pricing_Approved_Unit_Qty__c != null ? Integer.valueOf(quoteLine.Pricing_Approved_Unit_Qty__c ?? 0) : 0 ;
                    claimableQty = Integer.valueOf(quoteLine.Pricing_Approved_Unit_Qty__c ?? 0);
                 } 
                 Integer errorCount = 0;
                 system.debug('@@claimableQty=='+claimableQty);
                 system.debug('@@stagingRec.PCC_Error_Messages__c=='+stagingRec.PCC_Error_Messages__c);
                 errorCount = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c.split(PCC_Constants.RC_LINE_SEPERATOR).size()+1 : errorCount+1 ;
                
                if(invalidQLNames.contains(stagingRec.PCC_Quote_Line_Number__c)) {
                    stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+quoteLine_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+quoteLine_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Incorrect_ErrMsg
                    stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    errorCount++;
                }
                
                if(validQLNames.contains(stagingRec.PCC_Quote_Line_Number__c)) {  
                    if(quoteLine.Pricing_Status_Nm__c != 'Approved' &&quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Design Win') {
                    	stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+oppty_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+oppty_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Oppty_Status_ErrMsg
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                    }
                    /*if(!errflag && quoteLine.SBQQ__Quote__r.Pricing_End_Customer_Account__c != stagingRec.PCC_Partner__c ) {
                    	stagingRec.PCC_Error_Message__c = stagingRec.PCC_Error_Message__c != null ? stagingRec.PCC_Error_Message__c + '  End Customer Account is not matching' : 'End Customer Account is not matching';
                        stagingRec.PCC_Status__c = 'Failed';
                        errflag = true;
                       }*/
                    if((quoteLine.Pricing_OEM_Name_FI_Nm__c != 'Write In OEM Name' && quoteLine.Pricing_OEM_Name_FI_Nm__c != stagingRec.PCC_OEM__c) || (quoteLine.Pricing_OEM_Name_FI_Nm__c == 'Write In OEM Name' && quoteLine.Pricing_FI_Write_In_OEM_Name_Txt__c != stagingRec.PCC_OEM__c)) { //PCC_QL_OEM_Name_ErrMsg
                    	stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+oem_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+oem_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR;
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                       }
                       
                    if(quoteLine.Pricing_Product_Name__c.toLowerCase() != stagingRec.PCC_Product__c.toLowerCase()) {
                    	stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+productName_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+productName_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Product_Name_ErrMsg
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                       }
                        if(integer.valueOf(stagingRec.PCC_Quantity__c ?? '0') >  quoteLine.Pricing_Approved_Unit_Qty__c) {
                    	stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+quantity_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+quantity_ErrMsg+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Qty_ErrMsg
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                        }
                    
                    if((integer.valueOf(stagingRec.PCC_Quantity__c ?? '0') >  claimableQty)){
                        stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+'Claim Qty is greater than Claimable Qty'+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+'Claim Qty is greater than Claimable Qty'+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Qty_ErrMsg
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                    }

                    /*if((Date.parse(stagingRec.PCC_Invoice_Date__c) < quoteLine.Pricing_Start_Date_dt__c) || (Date.parse(stagingRec.PCC_Invoice_Date__c) > quoteLine.Pricing_End_Date_dt__c) ) {
                    	stagingRec.PCC_Error_Messages__c = stagingRec.PCC_Error_Messages__c != null ? stagingRec.PCC_Error_Messages__c + 'ERROR '+errorCount+' :'+'Invoice Date should be between Pricing Start/End Date'+PCC_Constants.RC_LINE_SEPERATOR : 'ERROR '+errorCount+' :'+'Invoice Date should be between Pricing Start/End Date'+PCC_Constants.RC_LINE_SEPERATOR; //PCC_QL_Qty_ErrMsg
                        stagingRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                        errflag = true;
                        errorCount++;
                        }*/
                }
                    
                    if(!errflag && stagingRec.PCC_Status__c != PCC_Constants.FAILED_STATUS) {
                        stagingRec.PCC_Status__c = PCC_Constants.SUCCESS_STATUS;
                        stagingRec.PCC_Opportunity__c = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                        stagingRec.PCC_ProductId__c = quoteLine.Pricing_Product_Nm__c;
                        stagingRec.PCC_Quote_Line_Id__c = quoteLine.Id;
                        stagingRec.PCC_Submitted_Claim_Rebate_Amount__c = quoteLine.Pricing_FI_Net_RPU_Amt__c*Integer.valueOf(stagingRec.PCC_Quantity__c); 
                    }

                updatedStgLst.add(stagingRec);
                system.debug('@@StagingRec=='+stagingRec);
                } //END -- QUOTELINE NULL
                }//END--ELSE
                }
            }  //END--TRY BLOCK
   
    catch (Exception e) {
           system.debug('@@Error=='+e.getMessage()+'==Cause=='+e.getStackTraceString()+'==Line=='+e.getLineNumber()+'=='+e.getTypeName());
        
    }
    return updatedStgLst;
    }

}