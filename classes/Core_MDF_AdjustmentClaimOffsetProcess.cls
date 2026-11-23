/****************************************************************************************************************************************
* Class Name  : Core_MDF_AdjustmentClaimOffsetProcess 
* Version     : 1.0   
* Created Date: 06/03/2018 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - AD     06/03/2018                    Class contains all the methods supporting the Adjustment Claim offset process
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AdjustmentClaimOffsetProcess {
    
    // Program Set 
    public static Set<String> programSet = new Set<String>();
    // Geo Set
    public static Set<String> geoSet = new Set<String>();
    //Map of channel program meta data
    public static Map<String,String> mapOfProgramMetadata = new Map<String,String>();
    /****************************************************************************************************** 
Method Name:        performClaimAdjustmentProcess
@return  :          N/A
@parameters:        List of payment run records
Description:        This method is used to perform claim offseting and send PD claims to payment process/update remaining claims
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<PartnerFundClaim> performClaimAdjustmentProcess(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        //List of payment run records
        List<PartnerFundClaim> paymentDueClaimsToBeProcessed;
        //Map of adjustment claims
        Map<String,List<PartnerFundClaim>> mapOfAccountToAdjustmentClaims =  groupAdjustmentClaimsforPayment(paymentRunRecordsTobeProcessed);
        //Map of remainig claims whose status PAF/PD
        Map<String,List<PartnerFundClaim>> mapOfAccountToClaims =  groupIncomingClaimsforPayment(paymentRunRecordsTobeProcessed);
        if(mapOfAccountToAdjustmentClaims!=null && mapOfAccountToClaims!=null){
            //payment due claims after offset process and pass same to payment process
            paymentDueClaimsToBeProcessed = performOffsetProcess(mapOfAccountToAdjustmentClaims,mapOfAccountToClaims);
        }
        system.debug('main method - PD claims '+paymentDueClaimsToBeProcessed);
        return paymentDueClaimsToBeProcessed;
    }   
    
    /****************************************************************************************************** 
Method Name:        groupAdjustmentClaimsforPayment
@return  :          Map of uniqueKey as key List of adjustments as value
@parameters:        List of payment run records
Description:        This method is used to query all adjustment claims based on program/ type = adjustment/status PAF and create map for same
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/ 
    public static Map<String,List<PartnerFundClaim>> groupAdjustmentClaimsforPayment(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        //Unique Key - company account node+program
        String uniqueKey = '';
        //Map of unique key and list of adjustment claims
        Map<String,List<PartnerFundClaim>> accountToListOfAdjustmentClaims = new Map<String,List<PartnerFundClaim>>();        
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');
        //create sets for query filter
        generateQueryFilters(paymentRunRecordsTobeProcessed);
        //List of adjustment claims to be processed
        List<PartnerFundClaim> adjustmentClaimsTobeProcessed =  
            [SELECT Id,ChannelPartnerId,Core_MDF_Program__c,Amount,Core_MDF_Status__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
             Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Payment_Id__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,
             Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
             ChannelPartner.Core_MDF_Channel_Program__c FROM PartnerFundClaim
             WHERE Core_MDF_Program__c IN:programSet
             AND Core_MDF_Status__c=:Label.Core_MDF_Status_Pending_Available_Fund 
             AND Core_MDF_Type_Txt__c =: Label.Core_MDF_NegativeClaim
             AND Core_MDF_Region_Cd__c IN:geoSet 
             AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded];
        system.debug('adjustmentClaimsTobeProcessed ' +adjustmentClaimsTobeProcessed);
        for(PartnerFundClaim claimRecord : adjustmentClaimsTobeProcessed){
            //Ex: IDxxxxx_CCF
            uniqueKey = claimRecord.ChannelPartnerId+'_'+mapOfProgramMetadata.get(claimRecord.Core_MDF_Program__c);
            if(accountToListOfAdjustmentClaims.containsKey(uniqueKey)){
                accountToListOfAdjustmentClaims.get(uniqueKey).add(claimRecord);
            }else{
                accountToListOfAdjustmentClaims.put(uniqueKey, new List<PartnerFundClaim>{claimRecord});
            }
        }
        system.debug('adj claims '+accountToListOfAdjustmentClaims);
        return accountToListOfAdjustmentClaims;               
    }
    /****************************************************************************************************** 
Method Name:        groupIncomingClaimsforPayment
@return  :          Map of uniqueKey as key List of claims as value
@parameters:        List of payment run records
Description:        This method is used to query all claims (other than adjustments) based on status PAF/PD, Geo/country,program and create map for same
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/ 
    public static Map<String,List<PartnerFundClaim>> groupIncomingClaimsforPayment(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        //Unique Key - company account node+program
        String uniqueKey = '';
        //Map of unique key and list of claims
        Map<String,List<PartnerFundClaim>> accountToListOfClaims = new Map<String,List<PartnerFundClaim>>();        
        //Production Test Account Ids to Be Excluded 
        List<String> testAccountIdstobeExcluded = Label.Core_MDF_TestAccountIdsToBeExcluded.split(',');
        //custom label for type of claims for offset processs  - Claim,Escalation Claim
        List<String> validClaimTypeForOffsetProcess = Label.Core_MDF_TypeOfClaimForOffsetProcess.split(',');
        //create sets for query filter
        generateQueryFilters(paymentRunRecordsTobeProcessed);
        //List of claims to be processed other than claims (other than adjustments)
        List<PartnerFundClaim> claimsTobeProcessed =  
            [SELECT Id,ChannelPartnerId,Core_MDF_Program__c,Amount,Core_MDF_Status__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
             Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,Core_MDF_Payment_Id__c,Core_MDF_Bank__r.Core_MDF_Payment_Method_Code__c,
             Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c,Core_MDF_Bank__r.Core_MDF_Supplier_Name__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c ,Request.ChannelPartner.Core_MDF_Channel_Program__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,
             ChannelPartner.Core_MDF_Channel_Program__c FROM PartnerFundClaim 
             WHERE Core_MDF_Program__c IN:programSet 
             AND Core_MDF_Type_Txt__c  IN:validClaimTypeForOffsetProcess
             AND Core_MDF_Region_Cd__c IN:geoSet
             AND Core_MDF_Status__c=:Label.Core_MDF_Status_Payment_Due
             AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN: testAccountIdstobeExcluded
             ORDER BY Core_MDF_Status__c DESC];
        system.debug('claimsTobeProcessed '+claimsTobeProcessed);
        for(PartnerFundClaim claimRecord : claimsTobeProcessed){
            //Ex: IDxxxxx_CCF
            uniqueKey = claimRecord.ChannelPartnerId+'_'+mapOfProgramMetadata.get(claimRecord.Core_MDF_Program__c);
            if(accountToListOfClaims.containsKey(uniqueKey)){
                accountToListOfClaims.get(uniqueKey).add(claimRecord);
            }else{
                accountToListOfClaims.put(uniqueKey, new List<PartnerFundClaim>{claimRecord});
            }
        }
        system.debug('other claims '+accountToListOfClaims);
        return accountToListOfClaims;             
    }
    /****************************************************************************************************** 
Method Name:        performOffsetProcess
@return  :          List of payment due claims
@parameters:        Map od adjustment claims and map of other claims(whose status is PAF/PD)
Description:        This method is used to offset claims and update accordingly and return PD claims for payment process
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/     
    public static List<PartnerFundClaim> performOffsetProcess(Map<String,List<PartnerFundClaim>> accountToAdjustmentClaims,Map<String,List<PartnerFundClaim>> accountToClaims){
        //List of Claim Offset to be created
        Set<Core_MDF_Claim_Offset__c> newClaimOffsetRecToBeCreated = new Set<Core_MDF_Claim_Offset__c>();
        //All Adjustment claims tobe updated
        Map<Id,PartnerFundClaim> adjustmentClaimsToBeUpdatedMap = new Map<Id,PartnerFundClaim>();
        //All remainig claims to be updated
        Map<Id,PartnerFundClaim> claimsToBeUpdatedMap = new Map<Id,PartnerFundClaim>();
        //Map of channel program meta data
        Map<String,String> mapOfProgramMetadata = new Map<String,String>();
        //Set of payment due claims
        Set<PartnerFundClaim> paymentDueClaimsToBeProcessed = new Set<PartnerFundClaim>();
        // final list of payment due claims for payment process
        List<PartnerFundClaim> listOfPaymentDueClaimsToBeProcessed;
        //Unique Key - company account node+program
        String uniqueKey = '';
        //Claim offset amount
        Decimal claimOffsetAmount;
        
        
        //Existing channel program meta data
        List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Label,Core_MDF_Program_Name__c FROM Core_MDF_ChannelProgram__mdt];
        for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
            mapOfProgramMetadata.put(cp.Label,cp.Core_MDF_Program_Name__c);
        }
        
        if(accountToAdjustmentClaims!=null && accountToAdjustmentClaims.size()>0){
            
            for(String uKey : accountToAdjustmentClaims.keySet()){
                //Getting list of adjustment claims from map by unique key
                List<PartnerFundClaim> adjustmentClaimList = accountToAdjustmentClaims.get(uKey);
                for(PartnerFundClaim adjustmentClaim : adjustmentClaimList){
                    //getting list of other claims from map
                    List<PartnerFundClaim> listOfClaims = accountToClaims.ContainsKey(uKey) ? accountToClaims.get(uKey) : null;
                    if(listOfClaims!=null && listOfClaims.size()>0){
                        for(PartnerFundClaim claimRecord : listOfClaims){
                            if (Math.abs(adjustmentClaim.Amount)>0 && claimRecord.Amount>0){
                                if((Math.abs(adjustmentClaim.Amount)) < claimRecord.Amount){
                                    claimOffsetAmount = Math.abs(adjustmentClaim.Amount);
                                    claimRecord.Amount = claimRecord.Amount - (Math.abs(adjustmentClaim.Amount));
                                    adjustmentClaim.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));
                                    break;
                                }else if((Math.abs(adjustmentClaim.Amount)) == claimRecord.Amount){
                                    claimOffsetAmount = Math.abs(adjustmentClaim.Amount);
                                    claimRecord.Amount = 0.0;
                                    adjustmentClaim.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    claimRecord.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));                           
                                    break;
                                }else{
                                    claimOffsetAmount = claimRecord.Amount;
                                    adjustmentClaim.Amount = -((Math.abs(adjustmentClaim.Amount)) - claimRecord.Amount);
                                    claimRecord.Amount =0.0;
                                    adjustmentClaim.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
                                    claimRecord.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
                                    //claim to be updated
                                    claimsToBeUpdatedMap.put(claimRecord.id,claimRecord);
                                    //New claim offset entry
                                    newClaimOffsetRecToBeCreated.add(createClaimOffsetEntry(claimRecord.Id,adjustmentClaim.Id,claimOffsetAmount));                           
                                }
                            }
                        }
                        adjustmentClaimsToBeUpdatedMap.put(adjustmentClaim.Id,adjustmentClaim);
                    }
                }
            }
            //conver set to list and update/insert list of claims
            if(claimsToBeUpdatedMap!=null && adjustmentClaimsToBeUpdatedMap!=null && newClaimOffsetRecToBeCreated!=null){
                database.update(claimsToBeUpdatedMap.values());
                database.update(adjustmentClaimsToBeUpdatedMap.values());           
                database.insert(new List<Core_MDF_Claim_Offset__c>(newClaimOffsetRecToBeCreated));      
            }
        }
        for(String uKey : accountToClaims.keySet()){
            //Getting list of other claims from map by unique key
            List<PartnerFundClaim> claimList = accountToClaims.get(uKey);
            for(PartnerFundClaim pfcRecord : claimList){
                //Checking PD claims
                if(Label.Core_MDF_Status_Payment_Due == pfcRecord.Core_MDF_Status__c){
                    paymentDueClaimsToBeProcessed.add(pfcRecord);
                }
            }
        }
        system.debug('PD claims '+paymentDueClaimsToBeProcessed);
        if(paymentDueClaimsToBeProcessed!=null){
            listOfPaymentDueClaimsToBeProcessed= new List<PartnerFundClaim>(paymentDueClaimsToBeProcessed);
        }
        //Send payment due claims to payment process
        return listOfPaymentDueClaimsToBeProcessed;
    }
    /****************************************************************************************************** 
Method Name:        createClaimOffsetEntry
@return  :          new claim offset record
@parameters:        offset claim Id, adjustment claim Id, offset amount
Description:        This method is used to create offset entry
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/      
    public static Core_MDF_Claim_Offset__c createClaimOffsetEntry(Id offsetClaimId,Id adjustmentClaimId,Decimal offsetAmount){
        //create new claim offest record
        Core_MDF_Claim_Offset__c newClaimOffset = new Core_MDF_Claim_Offset__c();
        newClaimOffset.Core_MDF_Offset_Claim_Nbr__c = offsetClaimId;
        newClaimOffset.Core_MDF_Adjustment_Claim_Nbr__c = adjustmentClaimId;
        newClaimOffset.Core_MDF_Offset_Amount_Amt__c = offsetAmount;
        return newClaimOffset;
    }
    /****************************************************************************************************** 
Method Name:        generateQueryFilters
@return  :          N/A
@parameters:        list of payment run records
Description:        This method is used to assign geo/countries, program, map of program meta data
Added By:           Accenture - AD - 06/03/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/     
    public static void generateQueryFilters(List<Core_MDF_Payment_Run__c> paymentRunRecordsTobeProcessed){
        
        //Existing channel program meta data
        List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Label,Core_MDF_Program_Name__c FROM Core_MDF_ChannelProgram__mdt];
        for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
            mapOfProgramMetadata.put(cp.Label,cp.Core_MDF_Program_Name__c);
        }
        
        for(Core_MDF_Payment_Run__c prun : paymentRunRecordsTobeProcessed){
            geoSet.add(prun.Core_MDF_Geo_Txt__c);
            programSet.add(prun.Core_MDF_Program_Id__r.Name);
        }
    }
}