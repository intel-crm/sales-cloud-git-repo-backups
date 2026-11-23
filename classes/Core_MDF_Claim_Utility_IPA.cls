/****************************************************************************************************************************************
* Class Name  : Core_MDF_Claim_Utility 
* Version     : 1.0   
* Created Date: 11-13-2018
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         11/13/2018                    Created Core_MDF_Claim_Utility for Common Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Claim_Utility_IPA {
    //To hold all record type meta data
    public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecTypeMetadata;
    public static Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = new Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper>();
    public static Map<Id,PartnerFundRequest> pfrInstance;    
    //Assign all record type meta data
    static{
        mapOfRecTypeMetadata = fetchRecordTypeMetaData();
        wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap(); 
    }
    
    /***************************************************************************************************** 
Method Name:        releaseHold 
@return  :          void 
@parameters:        
Description:        This method is used to release the claims that are on hold
Added By:           Intel - SM - 11/13/2018
Modified By:        Date:       Changes:  
******************************************************************************************************/
    public static void releaseHold(List<PartnerFundClaim> inputClaims, List<String> releaseReason)
    {
        //To get the fields of the list of claims passed as input
        processReleaseHold(inputClaims,releaseReason);
        Database.update(inputClaims);        
    }      
    
    /***************************************************************************************************** 
Method Name:        processReleaseHold
@return  :          void
@parameters:        
Description:        This method is used to release the claims that are on hold
Added By:           Intel - SM - 11/13/2018assign
Modified By:        Date:       Changes: 
******************************************************************************************************
*  VS               4/4/2019       Added condition to check Payment Hold reason
******************************************************************************************************/
    public static void processReleaseHold(List<PartnerFundClaim> claims, List<String> releaseReason)
    {
        //To Store the Updated claims
        List<PartnerFundClaim> claimListToUpdate = new List<PartnerFundClaim>();
        
        //To Uncheck the Hold Reason
        if(claims != NULL && claims.size() > 0)
        {
            for(PartnerFundClaim claim : claims)
            {
                for(String reason : releaseReason)
                {
                    if(reason == Label.Core_MDF_ESD_Hold)
                    { 
                        claim.Core_MDF_ESD_Hold__c = false; 
                    }
                    if(reason == Label.Core_MDF_Audit_Hold)
                    {
                        claim.Core_MDF_Audit_Hold__c = false; 
                    }
                    if(reason == Label.Core_MDF_Payment_Hold)
                    {
                        claim.Core_MDF_Payment_Hold_ind__c = false;                        
                    }
                    if(reason == Label.Core_MDF_Criteria_Hold)
                    {
                        claim.Core_MDF_Criteria_Hold_Ind__c = false;                        
                    }
                    if(reason == Label.Core_MDF_Intel_Manual_Hold)
                    {
                        claim.Core_MDF_Intel_Manual_Hold_Ind__c = false;                        
                    }
                    if(reason == Label.Core_MDF_Member_Manual_Hold)
                    {
                        claim.Core_MDF_Member_Manual_Hold_Ind__c = false;                        
                    }
                }
                
                if(!claim.Core_MDF_Audit_Hold__c && !claim.Core_MDF_ESD_Hold__c && !claim.Core_MDF_Payment_Hold_ind__c && !claim.Core_MDF_Intel_Manual_Hold_Ind__c && !claim.Core_MDF_Member_Manual_Hold_Ind__c
                   && !claim.Core_MDF_Criteria_Hold_Ind__c && claim.Core_MDF_Status__c == Label.Core_MDF_Status_Hold){
                       String tempPrevStatus = claim.Core_MDF_Claim_Previous_Status__c;
                       if(tempPrevStatus!=null && (tempPrevStatus == Label.Core_MDF_Status_Pending_Available_Fund || tempPrevStatus == Label.Core_MDF_Status_Submitted)){
                            claim.Core_MDF_Status__c = tempPrevStatus;    
                       }else{
                            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Submitted;
                       }                  
                   }
            }
        }        
    } 
    
    /***************************************************************************************************** 
Method Name:        invokeReleaseHold
@return  :          void
@parameters:        
Description:        This is an Invocable Method for the Release Hold method
Added By:           Intel - SM - 11/20/2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    @InvocableMethod
    public static void invokeReleaseHold(List<ReleaseHoldParams> releaseParams)
    {
        releaseHold(releaseParams[0].inputClaims,releaseParams[0].releaseReason);
    }
    
    /***************************************************************************************************** 
ClassName:        ReleaseHoldParams
@parameters:        
Description:        This is a wrapper class to be used to send parameters to the Invocable Method
Added By:           Intel - SM - 11/20/2018
******************************************************************************************************/    
    public class ReleaseHoldParams
    {
        @InvocableVariable(label = 'Claims' required = true)
        public List<PartnerFundClaim> inputClaims;
        @InvocableVariable(label = 'Release Reason' required = true)
        public List<String> releaseReason;
    }
    
    /***************************************************************************************************** 
Method Name:        updateClaimStatus
@return  :          void
@parameters:        newClaimList and oldClaimMap
Description:        This method is used to set the claim previous and standard Status on the basic of custom status 
Added By:           Accenture - JV
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateClaimStatus(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){ 
        
        for(PartnerFundClaim pfc : newClaimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            if(oldClaimMap!=null && oldClaimMap.size() > 0  && oldClaimMap.get(pfc.ID).Core_MDF_Status__c != pfc.Core_MDF_Status__c){
                
                // To set the claim previous status field before changing claim current status
                pfc.Core_MDF_Claim_Previous_Status__c = oldClaimMap.get(pfc.ID).Core_MDF_Status__c;
                
                if (pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Available_Fund 
                    || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Submitted
                    || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Hold) {
                        pfc.Status = Label.Core_MDF_Status_Submitted;
                    }
                else if(pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Payment_Due || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Pending_Payment){
                    pfc.Status = Label.Core_MDF_Status_Approved;
                }
                else if(pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Denied || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Cancelled || pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Adjusted){
                    pfc.Status = Label.Core_MDF_Status_Rejected;
                }
                else if(pfc.Core_MDF_Status__c == Label.Core_MDF_Status_Paid){
                    pfc.Status = Label.Core_MDF_Status_Paid;
                }
                
            }
        }
    }
    
    /***************************************************************************************************** 
Class Name:         ClaimWrapperClass 
Description:        Wrapper to check duplicate claims
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public class ClaimWrapperClass {
        public String activityNumber;
        public Date adRunStartDate;
        public Date adRunEndDate;
        public String countryLocation;
        public String mediaVehicle;
        public String accountCompany;
        public string invoiceNumber;
        //IPA
        public string activityType;
        public decimal amount; 
        public string currencyType;
        public string program;
        
        public ClaimWrapperClass(String activityNumber, Date adRunStartDate, Date adRunEndDate, String countryLocation, 
                                 String mediaVehicle, String accountCompany, String invoiceNumber,String activityType,decimal amount,string currencyType,string program){
                                     this.activityNumber = activityNumber;
                                     this.adRunStartDate = adRunStartDate;
                                     this.adRunEndDate = adRunEndDate;
                                     this.countryLocation = countryLocation;
                                     this.mediaVehicle = mediaVehicle;
                                     this.accountCompany = accountCompany;
                                     this.invoiceNumber = invoiceNumber;
                                     this.activityType = activityType;
                                     this.amount = amount;
                                     this.currencyType = currencyType;
                                     this.program = program;
                                 }
        
        public Boolean equals(Object obj) {
            if (obj instanceof ClaimWrapperClass){
                ClaimWrapperClass p = (ClaimWrapperClass)obj;
                return ((activityNumber==p.activityNumber) && 
                        (adRunStartDate==p.adRunStartDate) && 
                        (adRunEndDate==p.adRunEndDate) && 
                        (countryLocation==p.countryLocation) &&
                        (mediaVehicle==p.mediaVehicle) && 
                        (accountCompany==p.accountCompany) && 
                        (invoiceNumber==p.invoiceNumber) &&
                        ((p.program== Label.Core_MDF_IPA_Program_Name)?((activityType==p.activityType) && (amount == p.amount) && (currencyType==p.currencyType)) :true));
            }
            return false;
        }
        
        public Integer hashCode() {
            Integer hashCode = 0;
            hashCode = activityNumber!=null ? (hashCode + System.hashCode(activityNumber)):hashCode;
            hashCode = adRunStartDate!=null ? (hashCode + System.hashCode(adRunStartDate)):hashCode;
            hashCode = adRunEndDate!=null ? (hashCode + System.hashCode(adRunEndDate)):hashCode;
            hashCode = countryLocation!=null ? (hashCode + System.hashCode(countryLocation)):hashCode;
            hashCode = mediaVehicle!=null ? (hashCode + System.hashCode(mediaVehicle.toLowerCase())):hashCode;
            hashCode = accountCompany!=null ? (hashCode + System.hashCode(accountCompany)):hashCode;
            hashCode = invoiceNumber!=null ? (hashCode + System.hashCode(invoiceNumber.toLowerCase())):hashCode;
            
            //IPA
            hashCode = (activityType!=null && program==Label.Core_MDF_IPA_Program_Name) ? (hashCode + System.hashCode(activityType.toLowerCase())):hashCode;
            hashCode = (amount!=null && program==Label.Core_MDF_IPA_Program_Name) ? (hashCode + System.hashCode(amount)):hashCode;
            hashCode = (currencyType!=null && program==Label.Core_MDF_IPA_Program_Name) ? (hashCode + System.hashCode(currencyType.toLowerCase())):hashCode;
            return hashCode;
        }
    }
    
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheckOnInsert
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        Whenever a record is inserted of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<PartnerFundClaim> duplicateClaimCheckOnInsert(List<PartnerFundClaim> claimList) {    
        
        List<PartnerFundClaim> partnerFundClaimList = new List<PartnerFundClaim>();
            
        // This set is required to store Requests
        Set<Id> requestIdSet = new Set<id>();
        if(claimList != Null && claimList.size()>0)
        {
            for(PartnerFundClaim newClaim : claimList){
                //check if adjustment then break
                if(!Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
                {
                    requestIdSet.add(newClaim.RequestId);
                }
            }
        }
        
        if(requestIdSet != NULL && requestIdSet.size() > 0){
            partnerFundClaimList = duplicateProcess(requestIdSet,claimList);
        }
        return partnerFundClaimList;
        }  
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheckOnUpdate
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        this method checks if any of the duplicate field over claim is changed
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
     @AuraEnabled
    public static Void duplicateClaimCheckOnUpdate(List<PartnerFundClaim> claimList,Map<Id,PartnerFundClaim> oldClaimMap) {    
        
        // This set is required to store Requests
        Set<Id> requestIdSet = new Set<id>();
        
        //To hold IPA record type Id
        Id IPARecTypeId = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_RecordType).getRecordTypeId();    
        system.debug('IPARecTypeId:::' +IPARecTypeId);
        
        //check for Start Date or End Date or Media Vehicle or Invoice Number is changed 
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            if(newClaim.Core_MDF_Ad_Run_Start_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_Start_Date__c
               || newClaim.Core_MDF_Ad_Run_End_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_End_Date__c
               || (newClaim.Core_MDF_Media_Vehicle__c!=null && newClaim.Core_MDF_Media_Vehicle__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Media_Vehicle__c.toLowerCase())
               || (newClaim.Core_MDF_Invoice_Number__c!=null && newClaim.Core_MDF_Invoice_Number__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Number__c.toLowerCase())
               || (newClaim.Core_MDF_Country_Location_nm__c !=null && newClaim.Core_MDF_Country_Location_nm__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Country_Location_nm__c.toLowerCase())
               || newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Total_Invoice_Amount_Local__c
               //IPA
               || (newClaim.Core_MDF_Activity_Types__c!=null && newClaim.Core_MDF_Activity_Types__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Activity_Types__c.toLowerCase())
               || (newClaim.Core_MDF_AccountCompany__c!=null && newClaim.Core_MDF_AccountCompany__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_AccountCompany__c.toLowerCase())
               || (newClaim.Core_MDF_Currency__c!=null && newClaim.Core_MDF_Currency__c.toLowerCase() != oldClaimMap.get(newClaim.ID).Core_MDF_Currency__c.toLowerCase())
              ){
                  requestIdSet.add(newClaim.RequestId);
              }
        }
        
        if(requestIdSet != NULL && requestIdSet.size() > 0){
            duplicateProcess(requestIdSet,claimList);
        }
    }      
    
    /***************************************************************************************************** 
Method Name:        duplicateProcess
@return  :          List of Duplicate Claims from Database
@parameters:        requestIdSet and claimList 
Description:        Whenever a record is updated of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static List<PartnerFundClaim> duplicateProcess(Set<Id> requestIdSet,List<PartnerFundClaim> claimList){
        
        // Sets for all the fields against which duplicate needs to be checked
        Set<String> newActivityNumber = new Set<String>();
        Set<Date> newAdRunStartDate = new Set<Date>();
        Set<Date> newAdRunEndDate = new Set<Date>();
        Set<String> newCountryLocation = new Set<String>();
        Set<String> newMediaVehicle = new Set<String>();
        Set<String> newAccountCompany = new Set<String>();
        Set<String> newInvoiceNumber = new Set<String>();
        Set<String> newClamIds = new Set<String>();
        //IPA
        Set<String> newActyType = new Set<String>();
        Set<Decimal> newAmount = new Set<Decimal>();
        Set<String> newCurrencyType = new Set<String>();
        //To hold IPA record type Id
        Id IPARecTypeId = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_RecordType).getRecordTypeId(); 
         
        // Set for Claim Wrapper : New Claims Wrapper and Existing PFC Claims Wrapper
        Set<ClaimWrapperClass> dbWrapperSet = new Set<ClaimWrapperClass>();
        Set<ClaimWrapperClass> newWrapperSet = new Set<ClaimWrapperClass>();
        
        //This List contains the dbDuplicate Claims
        List<PartnerFundClaim> duplicateClaimList = new List<PartnerFundClaim>();
        
        //This Map stores dbClaimWrapper and Corresponding db Claim : will be used to capture db duplicate claims        
        Map<ClaimWrapperClass,List<PartnerFundClaim>> mapClaimWrapper = new Map<ClaimWrapperClass,List<PartnerFundClaim>>();       
        
        
        // This is to get the Request fields , as the Formula fields over Claim are not available during before Insert         
        Map<Id,PartnerFundRequest> pfrMap= new Map<Id,PartnerFundRequest>([Select Core_MDF_Activity_Number__c,
                                                                           ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name
                                                                           from PartnerFundRequest where Id IN: requestIdSet]);
        
        // To find the duplicate claims withing the List of claims to be inserted
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type)){   continue; }
            //IPA adding ActivityType, Amount & its currencyType 
            ClaimWrapperClass iKey = new ClaimWrapperClass(pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c , 
                                                           newClaim.Core_MDF_Ad_Run_Start_Date__c , newClaim.Core_MDF_Ad_Run_End_Date__c , 
                                                           newClaim.Core_MDF_Country_Location_nm__c, newClaim.Core_MDF_Media_Vehicle__c , 
                                                           pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name , 
                                                           newClaim.Core_MDF_Invoice_Number__c,
                                                           newclaim.Core_MDF_Activity_Types__c,
                                                           newclaim.Core_MDF_Total_Invoice_Amount_Local__c,newclaim.Core_MDF_Currency__c,newclaim.Core_MDF_Program__c);
            system.debug('iKey:::' +iKey);
            if(newWrapperSet.contains(iKey)){
                newClaim.Core_MDF_Duplicate_Claim__c = true;
            } else {
                newActivityNumber.add((pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c)!=null ?
                                      pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c.trim() : '');
                newAdRunStartDate.add(newClaim.Core_MDF_Ad_Run_Start_Date__c);
                newAdRunEndDate.add(newClaim.Core_MDF_Ad_Run_End_Date__c);
                newCountryLocation.add(newClaim.Core_MDF_Country_Location_nm__c !=null ?
                                       newClaim.Core_MDF_Country_Location_nm__c : '');
                newMediaVehicle.add((newClaim.Core_MDF_Media_Vehicle__c)!=null ?
                                    newClaim.Core_MDF_Media_Vehicle__c.trim() : '');
                newAccountCompany.add((pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r)!=null 
                                      ? pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name.trim() : '');
                newInvoiceNumber.add((newClaim.Core_MDF_Invoice_Number__c)!=null ?
                                     newClaim.Core_MDF_Invoice_Number__c.trim() : '');
                newActyType.add((newClaim.Core_MDF_Activity_Types__c)!=null ?
                                    newClaim.Core_MDF_Activity_Types__c.trim() : '');  
                newAmount.add(newClaim.Core_MDF_Total_Invoice_Amount_Local__c);
                newCurrencyType.add((newClaim.Core_MDF_Currency__c)!=null ?
                                    newClaim.Core_MDF_Currency__c.trim() : '');
                newWrapperSet.add(iKey);
            }
            
            newClamIds.add(newClaim.Id);
        }
        // To find duplicate claims against Claims in db
        for(PartnerFundClaim dbClaim : [select Id,Title,Request.Core_MDF_Activity_Number__c, Core_MDF_Ad_Run_Start_Date__c, 
                                        Core_MDF_Ad_Run_End_Date__c,Core_MDF_Country_Location_nm__c,Core_MDF_Media_Vehicle__c,
                                        Core_MDF_AccountCompany__c,Core_MDF_Invoice_Number__c,Core_MDF_Activity_Types__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Currency__c,Core_MDF_Program__c
                                        from PartnerFundClaim where ((Request.Core_MDF_Activity_Number__c IN: newActivityNumber AND Core_MDF_Ad_Run_Start_Date__c IN: newAdRunStartDate  AND Core_MDF_Ad_Run_End_Date__c IN: newAdRunEndDate AND Core_MDF_Country_Location_nm__c IN: newCountryLocation AND Core_MDF_Media_Vehicle__c IN: newMediaVehicle AND Core_MDF_AccountCompany__c IN: newAccountCompany AND Core_MDF_Invoice_Number__c IN: newInvoiceNumber) AND (Id NOT IN:newClamIds)) order by CreatedDate desc]){
            
            ClaimWrapperClass dbWrapperInstance = new ClaimWrapperClass(dbClaim.Request.Core_MDF_Activity_Number__c , 
                                                                        dbClaim.Core_MDF_Ad_Run_Start_Date__c , 
                                                                        dbClaim.Core_MDF_Ad_Run_End_Date__c , 
                                                                        dbClaim.Core_MDF_Country_Location_nm__c , 
                                                                        dbClaim.Core_MDF_Media_Vehicle__c , 
                                                                        dbClaim.Core_MDF_AccountCompany__c , 
                                                                        dbClaim.Core_MDF_Invoice_Number__c,                                                                        
                                                                        dbClaim.Core_MDF_Activity_Types__c,
                                                                        dbClaim.Core_MDF_Total_Invoice_Amount_Local__c,
                                                                        dbclaim.Core_MDF_Currency__c,
                                                                        dbclaim.Core_MDF_Program__c);
            system.debug('dbWrapperInstance:::'+dbWrapperInstance);
                                            
            dbWrapperSet.add(dbWrapperInstance);
            if(mapClaimWrapper.containsKey(dbWrapperInstance)){
                //clone and 2nd claim claim onwords should come here
                system.debug('inside if mapClaimWrapper.containsKey(dbWrapperInstance)'+dbWrapperInstance);
                mapClaimWrapper.get(dbWrapperInstance).add(dbClaim);
            }
            else{
                //first claim
                system.debug('inside else block : dbWrapperInstance');
                mapClaimWrapper.put(dbWrapperInstance, new List<PartnerFundClaim>{dbClaim});
            }
        }
        system.debug('mapClaimWrapper:::'+mapClaimWrapper);
        //Areefa : Please do not delete this below debug. It needed for IPA Clone claim duplicate check.
        system.debug('DO NOT DELETE THIS DEBUG- dbWrapperSet::::>'+dbWrapperSet);
        for(PartnerFundClaim newClaim : claimList){
            
            system.debug('inside for:::'+claimList);
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            ClaimWrapperClass iKey = new ClaimWrapperClass(pfrMap.get(newClaim.RequestId).Core_MDF_Activity_Number__c , 
                                                           newClaim.Core_MDF_Ad_Run_Start_Date__c , 
                                                           newClaim.Core_MDF_Ad_Run_End_Date__c , 
                                                           newClaim.Core_MDF_Country_Location_nm__c , 
                                                           newClaim.Core_MDF_Media_Vehicle__c , 
                                                           pfrMap.get(newClaim.RequestId).ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name , 
                                                           newClaim.Core_MDF_Invoice_Number__c,                                                          
                                                           newClaim.Core_MDF_Activity_Types__c,
                                                           newclaim.Core_MDF_Total_Invoice_Amount_Local__c,
                                                           newclaim.Core_MDF_Currency__c, newclaim.Core_MDF_Program__c);
            System.debug('ClaimWrapperClass iKey'+iKey);
            if(dbWrapperSet.contains(iKey)){
                system.debug('inside if dbWrapperSet.contains(iKey)' +iKey);
                newClaim.Core_MDF_Duplicate_Claim__c = true;
                // Currently we need to get the duplicate claim list against single record , therefore list would meet our requirement
                // Incase we need List of Duplicate Claims against Multiple Claims to be Inserted, then we would need one more map here to save the claim to be inserted and duplicate claims list from DB 
                duplicateClaimList = mapClaimWrapper.get(iKey);
                system.debug('inside duplicate process duplicateClaimList:::'+duplicateClaimList);
                system.debug('mapClaimWrapper_2:::'+mapClaimWrapper);
                system.debug('mapClaimWrapper.get(iKey):::'+mapClaimWrapper.get(iKey));
            }
            // added null check on Id for handling bulk claim scenario
            if(duplicateClaimList.size()==0 && newClaim.Core_MDF_Duplicate_Claim__c==true && newClaim.Id != null){ 
                system.debug('inside newClaim.Core_MDF_Duplicate_Claim__c = false');
                newClaim.Core_MDF_Duplicate_Claim__c = false;
            }
        }
        system.debug('duplicateClaimList_1:::>'+duplicateClaimList);
        return duplicateClaimList;
        
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimAmtFieldsOnInsert
@return  :          void
@parameters:        newclaimList
Description:        Method internally calls calculateClaimFields for new claims to be inserted
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimAmtFieldsOnInsert(List<PartnerFundClaim> newclaimList) {
        // calculate claim fields during insert
        calculateClaimFieldsForInsert(newclaimList);
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimAmtFieldsOnUpdate 
@return  :          void
@parameters:        inputClaimList and oldClaimList
Description:        Method to determine which all claims got updated and calculation is required
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimAmtFieldsOnUpdate(Map<Id,PartnerFundClaim> newclaimMap,Map<Id,PartnerFundClaim> oldClaimMap) {
        
        // Perform necessary checks here
        List<PartnerFundClaim> claimListToUpdateStatusToSubmitted = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListAmountToBeProcessed = new List<PartnerFundClaim>();
        for(PartnerFundClaim newClaim: newclaimMap.values()){            
            Boolean isAmountChanged = false;
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            // if amt chnage 
            if(newClaim.Id == oldClaimMap.get(newClaim.Id).Id 
               &&((newClaim.Core_MDF_Total_Invoice_Amount_Local__c!=null && newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Total_Invoice_Amount_Local__c)
                  || (newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c!=null && newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_OtherCostsnotReimbursable_Local__c)
                  || (newClaim.Core_MDF_Taxes_Local__c!=null && newClaim.Core_MDF_Taxes_Local__c != oldClaimMap.get(newClaim.Id).Core_MDF_Taxes_Local__c)
                  || (newClaim.Core_MDF_Audit_Adjustment_Amount__c!=null && newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.Id).Core_MDF_Audit_Adjustment_Amount__c)
                  || (newClaim.Core_MDF_Currency__c!=null && newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.Id).Core_MDF_Currency__c )   )){ isAmountChanged = true;   claimListAmountToBeProcessed.add(newClaim); }
            
            if(isAmountChanged || (oldClaimMap.get(newClaim.Id).Core_MDF_To_Be_Audited_Ind__c  && !newClaim.Core_MDF_To_Be_Audited_Ind__c))
            { claimListToUpdateStatusToSubmitted.add(newClaim);}      }
        
        if(claimListAmountToBeProcessed != NULL && claimListAmountToBeProcessed.size()>0) 
        {   calculateClaimFieldsForUpdate(newclaimMap,oldClaimMap,claimListAmountToBeProcessed);  }
        
        if(claimListToUpdateStatusToSubmitted != NULL && claimListToUpdateStatusToSubmitted.size()>0)  
        {   //Prevent claim update if claim amount exceeds the remaining Activity Budget Amount
            checkClaimAmtAgainstActivityBudgetAmt(claimListAmountToBeProcessed);
            updateStatusToSubmitted(newclaimMap,claimListToUpdateStatusToSubmitted);   }
        
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimFieldsForInsert
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to Calculate the Claims fields like Amount based on the exchange rates,
taxes, reimbursement amount etc
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimFieldsForInsert(List<PartnerFundClaim> claimListToBeProcessed) {
        
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
            claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c = claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c!=null 
                && claimObj.Core_MDF_Taxes_Local__c!=null ?  claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c) : claimObj.Core_MDF_Total_Invoice_Amount_Local__c;
            //claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c = claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c);
            //Passing the Reimbursable_TransactionAmt_Loc to the multicurrency method to get the USD equivalent
            input.inputCurrency = claimObj.Core_MDF_Currency__c;
            input.inputAmount = claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c;
            input.inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
            inputList.add(input);
        }
        if(inputList != null && inputList.size() > 0){
            Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);
            for(PartnerFundClaim claimObj : claimListToBeProcessed){
                //check if adjustment then break
                if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
                {
                    continue;
                }
                String reimbursementPercent = claimObj.Core_MDF_Reimbursement_Percent__c.removeEnd('%');
                Date inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                String key = string.valueof(claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c) + '\t' +
                    claimObj.Core_MDF_Currency__c + '\t' + string.valueof(inputDate);
                if(usdAmount.containsKey(key) && usdAmount.get(key).conversionRate != Null)
                {
                    claimObj.Core_MDF_Exchange_rate__c = usdAmount.get(key).conversionRate;
                    claimObj.Core_MDF_Reimbursable_Transaction_Amount__c = usdAmount.get(key).convertedAmount;
                    claimObj.Core_MDF_Requested_Reimbursement_Amt__c =  claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    claimObj.Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    claimObj.Amount = (claimObj.Core_MDF_Requested_Reimbursement_Amt__c - claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
                }
                else{claimObj.Amount = null;}
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        calculateClaimFieldsforUpdate
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to Calculate the Claims fields like Amount based on the exchange rates,
taxes, reimbursement amount etc
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void calculateClaimFieldsforUpdate(Map<Id,PartnerFundClaim> inputClaimMap, Map<Id,PartnerFundClaim> oldClaimMap, List<PartnerFundClaim> claimListToBeProcessed) {
        //hold parameter needed for multicurrancy function
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> inputList = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        //List of claims to be processed with new exchange rate
        List<PartnerFundClaim> claimListToBeProcessedWithNewExcRate = new List<PartnerFundClaim>();
        //To hold return value of exchange rate function
        Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount;
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
            {continue;}
            if(claimObj == inputClaimMap.get(claimObj.Id)){                
                //check if currency change - call exchange rate function
                if(inputClaimMap.get(claimObj.Id).Core_MDF_Currency__c != oldClaimMap.get(claimObj.Id).Core_MDF_Currency__c){
                    Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount input = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();                                       
                    //total invoice amoiunt - (other cost not reimburble + tax)
                    Decimal reimTransactionAmtLocal = claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c != null && claimObj.Core_MDF_Taxes_Local__c != null? claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c):claimObj.Core_MDF_Total_Invoice_Amount_Local__c;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c = reimTransactionAmtLocal;
                    input.inputCurrency = claimObj.Core_MDF_Currency__c;
                    input.inputAmount = inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c;
                    input.inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                    inputList.add(input);
                    claimListToBeProcessedWithNewExcRate.add(claimObj);
                }
            }
        }
        if(inputList != null && inputList.size() > 0){usdAmount = Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(inputList);
        }
        //Calculate amount fields with or without currency change
        calculateAmountWithExistingExcRate(claimListToBeProcessed,inputClaimMap,claimListToBeProcessedWithNewExcRate,usdAmount);
    }
    
    /***************************************************************************************************** 
Method Name:        calculateAmountWithExistingExcRate
@return  :          void
@parameters:        claimListToBeProcessed,newClaimMap,oldClaimMap,list of claims with new exchange rate,exchange rate and amount map
Description:        Method to Calculate amount fields with or without currency change
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void calculateAmountWithExistingExcRate(List<PartnerFundClaim> claimListToBeProcessed,Map<Id,PartnerFundClaim> inputClaimMap,List<PartnerFundClaim> claimListToBeProcessedWithNewExcRate,Map<string,Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> usdAmount){
        
        for(PartnerFundClaim claimObj : claimListToBeProcessed){            
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
            {continue;}
            String reimbursementPercent = claimObj.Core_MDF_Reimbursement_Percent__c.removeEnd('%');
            if(claimObj == inputClaimMap.get(claimObj.Id) && claimListToBeProcessedWithNewExcRate.contains(claimObj)){               
                Date inputDate = claimObj.CreatedDate == NULL ? System.today() : claimObj.CreatedDate.Date();
                String key = string.valueof(claimObj.Core_MDF_Reimbursable_TransactionAmt_Loc__c) + '\t' + claimObj.Core_MDF_Currency__c + '\t' + string.valueof(inputDate);
                if(usdAmount.containsKey(key) && usdAmount.get(key).conversionRate != Null)
                {
                    inputClaimMap.get(claimObj.Id).Core_MDF_Exchange_rate__c = usdAmount.get(key).conversionRate;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_Transaction_Amount__c = usdAmount.get(key).convertedAmount;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c = claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                    inputClaimMap.get(claimObj.Id).Amount = (inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c - inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);                    
                }
                else{inputClaimMap.get(claimObj.Id).Amount = null;}
            }else{
                //calculate fields with existing exchange rate
                Decimal reimTransactionAmtLocal = claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c != null && claimObj.Core_MDF_Taxes_Local__c != null? claimObj.Core_MDF_Total_Invoice_Amount_Local__c - (claimObj.Core_MDF_OtherCostsnotReimbursable_Local__c + claimObj.Core_MDF_Taxes_Local__c):claimObj.Core_MDF_Total_Invoice_Amount_Local__c;
                inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_TransactionAmt_Loc__c = reimTransactionAmtLocal;
                inputClaimMap.get(claimObj.Id).Core_MDF_Reimbursable_Transaction_Amount__c = (reimTransactionAmtLocal *inputClaimMap.get(claimObj.Id).Core_MDF_Exchange_rate__c).setScale(2);            
                inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c = claimObj.Core_MDF_Reimbursable_Transaction_Amount__c != NULL ? ((double.valueOf(reimbursementPercent)/100)*claimObj.Core_MDF_Reimbursable_Transaction_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c = claimObj.Core_MDF_Audit_Adjustment_Amount__c != NULL ? (claimObj.Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP) : 0;
                inputClaimMap.get(claimObj.Id).Amount = (inputClaimMap.get(claimObj.Id).Core_MDF_Requested_Reimbursement_Amt__c - inputClaimMap.get(claimObj.Id).Core_MDF_Audit_Adjustment_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
            }
        }
    }
    /***************************************************************************************************** 
Method Name:        updateStatusToSubmitted
@return  :          void
@parameters:        inputClaimList and claimListToBeProcessed
Description:        Method to update claim status to submitted
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void updateStatusToSubmitted(Map<Id,PartnerFundClaim> inputClaimMap, List<PartnerFundClaim> claimListToBeProcessed) {
        
        for(PartnerFundClaim claimObj : claimListToBeProcessed){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            if(claimObj == inputClaimMap.get(claimObj.Id) &&
               claimObj.Core_MDF_Status__c!= Label.Core_MDF_Status_Hold && claimObj.Core_MDF_Status__c!= Label.Core_MDF_Claim_Denied_status){
                   inputClaimMap.get(claimObj.Id).Core_MDF_Status__c = Label.Core_MDF_Status_Submitted;
               }
        }
    }
    
    /*************************************************************************************************************************
* @description : Method to assign the Record Type to Claim based on the Record Type assigned to its respective Activity
* @param claimList 
******************************************************************************************************************************/
    public static void assignClaimRecordType(List<PartnerFundClaim> claimList){
        
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        // flag saying whether the Audit functionality is ON or OFF
        Boolean isAuditRequired = (mapFunctionalityNameTriggerExecution.containsKey('checkAndSendClaimsToAudit') 
                                   && mapFunctionalityNameTriggerExecution.get('checkAndSendClaimsToAudit').Core_Active__c)
            ? true : false;
        
        //Set of request Ids
        Set<ID> requestIDs = new Set<ID>();
        
        for(PartnerFundClaim pfc: claimList){
            requestIDs.add(pfc.RequestId);
            assignClaimType(pfc);
        }
        //existing PFRs specific to request IDs
        //Map<Id,PartnerFundRequest> 
            pfrInstance = new Map<ID,PartnerFundRequest>([SELECT ID,RecordType.DeveloperName/*,Core_MDF_Budget_Type_txt__c*/ FROM PartnerFundRequest WHERE ID IN:requestIDs]);
        
        //Record Type Info Map
        Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName(); 
        for(PartnerFundClaim claimObj : claimList){
            if(mapOfRecTypeMetadata !=null && mapOfRecTypeMetadata.containsKey((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName)){
                String claimRecTypeDevName = mapOfRecTypeMetadata.get((pfrInstance.get(claimObj.RequestId)).RecordType.DeveloperName).Core_MDF_Claim_RecordType_txt__c;
                claimObj.RecordtypeId =  claimRecordTypeMap.get(claimRecTypeDevName).getRecordTypeId(); 
            }
            //check if adjustment then break
            if(!Core_MDF_Claim_Utility.isType(claimObj, Label.Core_MDF_Claim_Adjustment_Type))
            {
                // Setting status field at time of claim creation
                claimObj.Core_MDF_Status__c= Label.Core_MDF_Status_Submitted;
                claimObj.Status = Label.Core_MDF_Status_Submitted;
                claimObj.Core_MDF_Claim_Previous_Status__c = Label.Core_MDF_Status_Submitted;
            }
            
            // setting the audit In progress flag to True if Audit Functionality is Set, Areefa: If StraightToPay=False,send claim for Audit            
            if(isAuditRequired && claimObj.Core_MDF_To_Be_Audited_Ind__c==false){ 
                claimObj.Core_MDF_AuditSelectionInProgress__c = true;
            }
        } 
    }
    
    
    /***************************************************************************************************** 
Method Name:        updateAuditProgressFlag
@return  :          void
@parameters:        claimList and oldClaimMap
Description:        Method to Check if the editable fields on the Claims are updated 
And accordingly change the Audit In progress flag to True
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void updateAuditProgressFlag(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        for(partnerFundClaim newClaim: claimList){
            ///check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            if(isClaimEdited(newClaim,oldClaimMap) && !newClaim.Core_MDF_FlaggedForAudit__c && !newClaim.Core_MDF_To_Be_Audited_Ind__c){
                newClaim.Core_MDF_AuditSelectionInProgress__c = true;
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        sendClaimsToAudit
@return  :          void
@parameters:        claimList and oldClaimMap
Description:        Method to Send the Claims to Audit if the corresponding In Progress flag is true
and expected editable fields are updated
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void sendClaimsToAudit(List<PartnerFundClaim> claimList, Map<Id,PartnerFundClaim> oldClaimMap){
        
        List<PartnerFundClaim> claimListToBeSentToAudit = new List<PartnerFundClaim>();
        //Map<Id,PartnerFundClaim> claimListToBeSentToAudit = new Map<Id,PartnerFundClaim>();
        for(PartnerFundClaim newClaim : claimList){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(newClaim, Label.Core_MDF_Claim_Adjustment_Type))
            {
                continue;
            }
            if( newClaim.Core_MDF_AuditSelectionInProgress__c && isClaimEdited(newClaim,oldClaimMap)){
                claimListToBeSentToAudit.add(newClaim);
                //claimListToBeSentToAudit.put(newClaim.Id,newClaim);
            }
        }
        if(claimListToBeSentToAudit != NULL && claimListToBeSentToAudit.size() > 0){
            //ID jobID = System.enqueueJob(new Core_MDF_AuditSelectionHelper(claimListToBeSentToAudit));
            // ID jobID = System.enqueueJob(new Core_MDF_HoldCriteriaListProcessHelper(claimListToBeSentToAudit));
        }
    }
    
    /***************************************************************************************************** 
Method Name:        isClaimEdited
@return  :          Boolean
@parameters:        NewClaim and oldClaimMap
Description:        Method to check if any of the ediatble fields on the claim is getting changed
@Added By:          Accenture - JV 
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static Boolean isClaimEdited(PartnerFundClaim newClaim, Map<Id,PartnerFundClaim> oldClaimMap){
        
        if(newClaim.Core_MDF_Ad_Run_Start_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_Start_Date__c
           || newClaim.Core_MDF_Ad_Run_End_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Ad_Run_End_Date__c
           || newClaim.Core_MDF_Media_Vehicle__c != oldClaimMap.get(newClaim.ID).Core_MDF_Media_Vehicle__c
           || newClaim.Core_MDF_Bank__c != oldClaimMap.get(newClaim.ID).Core_MDF_Bank__c
           || newClaim.Core_MDF_Invoice_Number__c != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Number__c
           || newClaim.Core_MDF_Invoice_Date__c != oldClaimMap.get(newClaim.ID).Core_MDF_Invoice_Date__c
           || newClaim.Core_MDF_Total_Invoice_Amount_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Total_Invoice_Amount_Local__c
           || newClaim.Core_MDF_OtherCostsnotReimbursable_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_OtherCostsnotReimbursable_Local__c
           || newClaim.Core_MDF_Taxes_Local__c != oldClaimMap.get(newClaim.ID).Core_MDF_Taxes_Local__c
           || (newClaim.Core_MDF_Audit_Adjustment_Amount__c != oldClaimMap.get(newClaim.ID).Core_MDF_Audit_Adjustment_Amount__c && newClaim.Core_MDF_Status__c!=Label.Core_MDF_Claim_Denied_status)
           || newClaim.Core_MDF_Currency__c != oldClaimMap.get(newClaim.ID).Core_MDF_Currency__c
           || newClaim.Core_MDF_To_Be_Audited_Ind__c != oldClaimMap.get(newClaim.ID).Core_MDF_To_Be_Audited_Ind__c){ //  If there is change in StraightToPay
               
               return true;    
           }
        else{
            return false;
        }
    }
    /***************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of string and metadata object
@parameters:        N/A
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> fetchRecordTypeMetaData(){
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Region_cd__c,Core_MDF_Channel_Program_txt__c ,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Activity_RecordType_txt__c,recTypeMetaData);  
                                                                       }
        system.debug('mapOfRecordTypes::'+mapOfRecordTypes);
        return mapOfRecordTypes;
    }
    /***************************************************************************************************** 
Method Name:        getRecordTypeSet
@return  :          Set of record type Id
@parameters:        Map of record type info
Description:        Method to query all metadata records and create a map
@Added By:          Accenture - AD 
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static Set<Id> getRecordTypeSet(Map<String,Schema.RecordTypeInfo> claimRecordTypeMap){
        // To hold CoMarketing Record Types for Claims
        Set<Id> recordTypeSet = new Set<Id>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recordTypeMetaData : mapOfRecTypeMetadata.values()){
            if(recordTypeMetaData.Core_MDF_Claim_RecordType_txt__c!=null && recordTypeMetaData.Core_MDF_Enable_Fund_Reservation_chk__c == TRUE){
                recordTypeSet.add(claimRecordTypeMap.get(recordTypeMetaData.Core_MDF_Claim_RecordType_txt__c).getRecordTypeId());   
            }
        }
        return recordTypeSet;
    } 
    
    /***************************************************************************************************** 
Method Name:        isType
@return  :          Boolean value to indicate whether the given claim belongs to a given type 
@parameters:        Claim and type to be checked for
Description:        Method to check whether the given claim belongs to a given type
@Added By:          Intel - SM 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    
    @AuraEnabled
    public static Boolean isType(PartnerFundClaim claim, String types)
    {
        //List of types to be checked - from a label of different types to be checked
        List<String> claimType = types.split(';');
        if(claim.Core_MDF_Type_Txt__c != NULL && claimType.contains(claim.Core_MDF_Type_Txt__c))
        {
            return true;
        }
        else
        {
            return false;
        }
    } 
    
    /***************************************************************************************************** 
Method Name:        assignClaimType
@return  :          void 
@parameters:        Claim 
Description:        Method to assign Claim Type to a claim
@Added By:          Intel - SM 
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    
    public static void assignClaimType(PartnerFundClaim claim)
    {
        claim.Core_MDF_Type_Txt__c = claim.Core_MDF_Type_Txt__c == null ? claim.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type : claim.Core_MDF_Type_Txt__c;
    } 
    
    
    
    /****************************************************************************************************** 
Method Name:        isInternalAuditUser
@return  :          Boolean
@parameters:        String userId,String permissionName
Description:        This method is used to check the permission set over logged in user
Added By:           Accenture - AD - 11/26/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isInternalAuditUser(String custPermissionName){
        Boolean isAuditUser = false;
        try {
            Boolean hasCustomPermission = FeatureManagement.checkPermission(custPermissionName);
            if(hasCustomPermission){isAuditUser=true;}
            return isAuditUser;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    /****************************************************************************************************** 
Method Name:        updateClaimIdOnEscalation
@return  :          N/A
@parameters:        List of claims to be processed
Description:        This method is used to update claim id over escalation
Added By:           Accenture - AD - 06/25/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/    
    public static void updateClaimIdOnEscalation(List<PartnerFundClaim> claimsToBeProcessed){
        system.debug('claimsToBeProcessed -- '+claimsToBeProcessed);
        //Map of escalations to be updated
        Map<Id,Core_MDF_Escalation__c> escalationsToBeUpdatedMap = new Map<Id,Core_MDF_Escalation__c>();
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            if(pfcRecord.Core_MDF_Escalation_Id__c !=null){
                //New escalation instance
                Core_MDF_Escalation__c escalationRecord = new Core_MDF_Escalation__c(id=pfcRecord.Core_MDF_Escalation_Id__c);
                //null check for escalation record
                if(escalationRecord!=null){
                    //Assign claim id on escalation record
                    escalationRecord.Core_MDF_Claim_Number_id__c = pfcRecord.Id;
                    //Add updated escalation
                    escalationsToBeUpdatedMap.put(escalationRecord.Id,escalationRecord);
                }
            }   
        }
        system.debug('escalationsToBeUpdatedMap -- '+escalationsToBeUpdatedMap);
        if(escalationsToBeUpdatedMap!=null && escalationsToBeUpdatedMap.size()>0){
            //Update escalations
            Database.update(escalationsToBeUpdatedMap.values());
        }
    }
    
/****************************************************************************************************** 
Method Name:        populateOwnerLangLocalonclaimcreate
@return  :          N/A
@parameters:        List of claims
Description:        This method is used to update language local key on claim when owner is changed
Added By:           Accenture - AS - 07/22/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void populateOwnerLangLocalOnClaim(List<PartnerFundClaim> newClaimList, Map<Id,PartnerFundClaim> oldClaimMap){
        //Map of claim owner Id and Claim Id
        Map<Id,Id> ownerIdToClaimIDMap = new Map<Id,Id>();
        for(PartnerFundClaim pfc : newClaimList){
            //check for New and Owner updated claim
            if((oldClaimMap == null && pfc.Core_MDF_Owner_LanguageLocaleKey_Cd__c == null) || (oldClaimMap != null && (pfc.OwnerId != oldClaimMap.get(pfc.Id).OwnerId)) ){
                ownerIdToClaimIDMap.put(pfc.OwnerId,pfc.Id);   
            }
        }
        if(ownerIdToClaimIDMap!=null && ownerIdToClaimIDMap.size()>0){
            //Map of existing user
            Map<Id,User> userLocalMap = new Map<Id,User>([Select id,LanguageLocaleKey from User where Id IN:ownerIdToClaimIDMap.Keyset()]);
            for(PartnerFundClaim newpfc : newClaimList){
                if(ownerIdToClaimIDMap.values().contains(newpfc.Id)){
                    //to store owner's language locale key
                    newpfc.Core_MDF_Owner_LanguageLocaleKey_Cd__c = userLocalMap.containsKey(newpfc.OwnerId) ? userLocalMap.get(newpfc.OwnerId).LanguageLocaleKey : Label.Core_English_Language_Locale_Key;
                    
                }                
            }
        }
    }

/****************************************************************************************************** 
Method Name:        updateRegionFieldOverClaimOnInsert
@return  :          NA
@parameters:        List of claims to be updated with Geo values
Description:        This method will update Region field on claim as per country selected on claim creation.
Added By:           Accenture - VD - 11-Oct-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateRegionFieldOverClaimOnInsert(List<PartnerFundClaim> newclaimList) {
        // update Region field according to country on claim record
        if(newclaimList != NULL && newclaimList.size() > 0){
            for(PartnerFundClaim pfc : newclaimList){
                if(wrapperMapOfCountryRegion!=Null && wrapperMapOfCountryRegion.size()>0 && wrapperMapOfCountryRegion.containskey(pfc.Core_MDF_Country_Location_nm__c)){
                    pfc.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).geo;
                    //Getting Region field from metadata to check it's value
                    if(mapOfRecTypeMetadata !=null && mapOfRecTypeMetadata.containsKey((pfrInstance.get(pfc.RequestId)).RecordType.DeveloperName)){
                        String metadataRegion = mapOfRecTypeMetadata.get((pfrInstance.get(pfc.RequestId)).RecordType.DeveloperName).Core_MDF_Region_cd__c;
                        //Checking if claim is of retail program
                        if(metadataRegion!='' && metadataRegion!=NULL && metadataRegion.contains(pfc.Core_MDF_Region_Cd__c)){
                            //updating subgeo field
                            pfc.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(pfc.Core_MDF_Country_Location_nm__c).subGeo;
                        }
                    }
                }
            }
        }
    }
/****************************************************************************************************** 
Method Name:        updateRegionFieldOverClaimOnUpdate
@return  :          NA
@parameters:        New claim map and old claim map
Description:        This method will update Region field on claim if claim country is updated
Added By:           Accenture - VD - 14-Oct-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void updateRegionFieldOverClaimOnUpdate(Map<Id,PartnerFundClaim> newClaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        //Map of Program and Region
        Map<String,String> mapOfProgramTypeAndRegion = new Map<String,String>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt mapOfRecType : mapOfRecTypeMetadata.values()){
            mapOfProgramTypeAndRegion.put(mapOfRecType.Core_MDF_Channel_Program_txt__c,mapOfRecType.Core_MDF_Region_cd__c);
        }
        for(PartnerFundClaim claim : newClaimMap.values()){
            if(claim.Id == oldClaimMap.get(claim.Id).Id 
               && claim.Core_MDF_Country_location_nm__c != oldClaimMap.get(claim.Id).Core_MDF_Country_location_nm__c 
               && wrapperMapOfCountryRegion!=Null && wrapperMapOfCountryRegion.size()>0 && wrapperMapOfCountryRegion.containskey(claim.Core_MDF_Country_Location_nm__c)){
                   //Updating Region field
                   claim.Core_MDF_Region_Cd__c = wrapperMapOfCountryRegion.get(claim.Core_MDF_Country_Location_nm__c).geo;
                    //Checking if it is retail program
                    if(mapOfProgramTypeAndRegion !=null && mapOfProgramTypeAndRegion.containsKey(claim.Core_MDF_Program__c)
                      && mapOfProgramTypeAndRegion.get(claim.Core_MDF_Program__c)!=NULL && mapOfProgramTypeAndRegion.get(claim.Core_MDF_Program__c).contains(claim.Core_MDF_Region_Cd__c)){
                          //Updating Sub Region field
                          claim.Core_MDF_Sub_Region_Cd__c = wrapperMapOfCountryRegion.get(claim.Core_MDF_Country_Location_nm__c).subGeo;
                    }
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        validateABM
@return  :          NA
@parameters:        List of claims to be processed
Description:        This method will check for active ABM
Added By:           Accenture - AD - 10-Feb-2020
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void validateABM(List<PartnerFundClaim> claimsToBeProcessed){
        system.debug('claimsToBeProcessed -- '+claimsToBeProcessed);
        //Bank Id Set
        Set<Id> bankIdSet = new Set<Id>();
        //Request Id Set
        Set<Id> requestIdSet = new Set<Id>();
        //unique  key  and active flag map
        Map<String,Boolean> accountBankMappingMap = new Map<String,Boolean>();
        //PFR to channel partner ID
        Map<Id,Id> pfrToChannelPartnerMap = new Map<Id,Id>();
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            requestIdSet.add(pfcRecord.requestId);
            bankIdSet.add(pfcRecord.Core_MDF_Bank__c);
        }
        //Query exisitng PFR and creating pfr to channel partner map    
        for(PartnerFundRequest pfrRecord : [Select Id,ChannelPartnerId from PartnerFundRequest where Id IN:requestIdSet]){
            pfrToChannelPartnerMap.put(pfrRecord.Id,pfrRecord.ChannelPartnerId);
        }
        //Query exisitng account bank mapping based on account and bank   
        for(Core_MDF_Account_Bank_Mapping__c abmRecord : [SELECT Id,Core_MDF_Active_ind__c,Core_MDF_Bank__c,Core_MDF_Account__c from Core_MDF_Account_Bank_Mapping__c where Core_MDF_Bank__c IN:bankIdSet 
                                                          and Core_MDF_Account__c IN:pfrToChannelPartnerMap.values()]){
                                                              accountBankMappingMap.put(abmRecord.Core_MDF_Bank__c+'-'+abmRecord.Core_MDF_Account__c,abmRecord.Core_MDF_Active_ind__c);
                                                          }
        for(PartnerFundClaim pfcRecord : claimsToBeProcessed){
            if(pfcRecord!=null && pfcRecord.Core_MDF_Type_Txt__c != Label.Core_MDF_NegativeClaim
               && pfcRecord.Core_MDF_Budget_Type_Options_Nm__c != Label.Core_MDF_Retail_RSA_MD_Budget_Type){
                //Unique Key [bank Id - ChannelPartnerId]
                String uniqueKey = String.valueOf(pfcRecord.Core_MDF_Bank__c+'-'+
                                                  (pfrToChannelPartnerMap.containsKey(pfcRecord.requestId) ? pfrToChannelPartnerMap.get(pfcRecord.requestId) : ''));
                if(!accountBankMappingMap.containsKey(uniqueKey) || (accountBankMappingMap.containsKey(uniqueKey) && !accountBankMappingMap.get(uniqueKey))){
                    //Showing bank related error
                    pfcRecord.addError(Label.Core_MDF_Claim_Stage_Bank_Error);
                }
            }
        }
    }
    
    /****************************************************************************************************** 
Method Name:        checkClaimAmtAgainstActivityBudgetAmt
@return  :          NA
@parameters:        List of input claims
Description:        This method is used to check the Claim Amount Against the Activity Budget Amount
Added By:           Intel - SM      -   13-Feb-2020
Modified By:        Intel - Areefa  -   14-Sept-2020    -   Some of Claim amount for IPA sholud be within Core_MDF_Activity_Reimbursement_Amt_nbr__c.
*******************************************************************************************************/
    
   /*public static void checkClaimAmtAgainstActivityBudgetAmt(List<PartnerFundClaim> inputClaims)
    {
        System.debug('Inside checkClaimAmtAgainstActivityBudgetAmt_IPA' + inputClaims);
        Set<String> programsForActBudgetAmtCheck = new Set<String>();
        //To check if the Activity Budget Amount Check is Required for a given Program
        for(Core_MDF_ChannelProgram__mdt program : [Select Label from Core_MDF_ChannelProgram__mdt
                                                    where Core_MDF_Act_Budget_Amt_Chk_Reqd__c= true])
        {
            programsForActBudgetAmtCheck.add(program.Label);
        }
        system.debug('programsForActBudgetAmtCheck_IPA'+programsForActBudgetAmtCheck);
        List<PartnerFundClaim> listOfClaimsToBeProcessed = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc : inputClaims)
        {
            if(programsForActBudgetAmtCheck.contains(pfc.Core_MDF_Program__c) && pfc.Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Claim_Type)) //check claim type
            {
                listOfClaimsToBeProcessed.add(pfc); 
            }
        }
        
        if(listOfClaimsToBeProcessed!= null && listOfClaimsToBeProcessed.size() > 0)
        { 
            //Label.Core_MDF_InactiveStatusForClaim = 'Cancelled;Denied;Adjusted'
            List<String> claimStatusToBeExcluded = Label.Core_MDF_InactiveStatusForClaim.split(';');
            //Map to store the Activity as key and list of its new claims to be inserted
            Map<Id, List<PartnerFundClaim>> mapNewClaimwithAct = new Map<Id,List<PartnerFundClaim>>();
            for(PartnerFundClaim pfc : listOfClaimsToBeProcessed)
            {
                if(mapNewClaimwithAct.containsKey(pfc.RequestId)){
                    mapNewClaimwithAct.get(pfc.RequestId).add(pfc);
                }
                else{
                    mapNewClaimwithAct.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
                }
            }
            //Map to store the Activity as key and its Available Budget Amount for Retail.
            Map<Id,Decimal> mapofActwithAvailableBudget = new Map<Id,Decimal>();
            
            //Map to store the Activity as key and its Available Budget Amount for IPA.
            Map<Id,Decimal> mapofActwithAvailableBudgetForIPA = new Map<Id,Decimal>();
            
            for(PartnerFundRequest pfr : [Select Id,Core_MDF_Program__c,RequestedAmount,Core_MDF_Activity_Reimbursement_Amt_nbr__c from PartnerFundRequest where Id IN : mapNewClaimwithAct.keySet()])
            {
                
                if(pfr.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name){
                    mapofActwithAvailableBudgetForIPA.put(pfr.Id, pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                }else{
                    mapofActwithAvailableBudget.put(pfr.Id, pfr.RequestedAmount);
                    
                    //try using one MAP
                    // R1 and IPA1
                }
                
            }
            //Aggregate result to the Sum of Claims Amount on an Activity
            List<AggregateResult> sumofClaimsAmount = [SELECT RequestID, SUM(Amount) claimedAmt, MAX(Request.RequestedAmount) requestedAmount,MAX(Request.Core_MDF_Activity_Reimbursement_Amt_nbr__c) requestedIPAAmount 
                                                       from PartnerFundClaim 
                                                       WHERE RequestId IN :mapNewClaimwithAct.keySet()
                                                       AND Core_MDF_Status__c <> :claimStatusToBeExcluded 
                                                       AND Core_MDF_Type_Txt__c = :Label.Core_MDF_Claim_Type 
                                                       AND Id Not IN :inputClaims
                                                       GROUP BY RequestId]; //dynamic query
            //To Obtain the Available Amount by decducting the sum of the claims Amount from the Activity Budget Amount
            if(sumofClaimsAmount!= null && sumofClaimsAmount.size() > 0){ 
                for(AggregateResult agg:sumofClaimsAmount){ 
                    Decimal requestedAmount =(Decimal)agg.get('requestedAmount');
                    Decimal requestedIPAAmount =(Decimal)agg.get('requestedIPAAmount');
                    Decimal claimedAmt=(decimal)agg.get('claimedAmt'); 
                    mapofActwithAvailableBudget.put((id)agg.get('RequestID'), requestedAmount - claimedAmt);
                    mapofActwithAvailableBudgetForIPA.put((id)agg.get('RequestID'), requestedIPAAmount - claimedAmt);
                } 
            }
            //Loop thro the Incoming Claims List to check 
            //their Amount lies within the corresponding Activity's Budget Amount
            for(Id reqId : mapNewClaimwithAct.keySet())
            { 
                //get the list of claims for a given activity from the list of incoming claims 
                List<PartnerFundClaim> claimLst = mapNewClaimwithAct.get(reqId);
                for(PartnerFundClaim pfc : claimLst)
                {
                    //Get the corresponding Actvity's Available Budget Amount
                    Decimal availableAmount = mapofActwithAvailableBudget.get(pfc.RequestId);
                    Decimal availableIPAAmount = mapofActwithAvailableBudgetForIPA.get(pfc.RequestId);
                    if(pfc.Amount > availableIPAAmount || pfc.Amount > availableAmount){
                        //Add error if claims amount is more than the activity's available amount
                        pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt);                     
                    }else if(pfc.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name && pfc.Amount <= availableIPAAmount){
                        mapofActwithAvailableBudgetForIPA.put(pfc.RequestId, availableIPAAmount - pfc.Amount);
                    }else{
                        mapofActwithAvailableBudget.put(pfc.RequestId, availableAmount - pfc.Amount);
                    }
                    
                    
                    /*if(pfc.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name)
                    {
                        if(pfc.Amount > availableIPAAmount)
                        {
                            //Add error if claims amount is more than the activity's available amount
                            pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt);
                        }
                        else
                        {
                            //If claim amount is lesser than or equal to the activity's available amount,
                            //process it by deducting claim amount from the available amount
                            mapofActwithAvailableBudgetForIPA.put(pfc.RequestId, availableIPAAmount - pfc.Amount);
                        }
                        
                    }else{
                        if(pfc.Amount > availableAmount)
                        {
                            //Add error if claims amount is more than the activity's available amount
                            pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt);
                        }
                        else
                        {
                            //If claim amount is lesser than or equal to the activity's available amount,
                            //process it by deducting claim amount from the available amount
                            mapofActwithAvailableBudget.put(pfc.RequestId, availableAmount - pfc.Amount);
                        }
                    }//
                }
                
            }
        }
        
    }*/
    
    public static void checkClaimAmtAgainstActivityBudgetAmt(List<PartnerFundClaim> inputClaims)    
    {
        //System.debug('Inside checkClaimAmtAgainstActivityBudgetAmt' + inputClaims);
        Set<String> programsForActBudgetAmtCheck = new Set<String>();
        //To check if the Activity Budget Amount Check is Required for a given Program
        for(Core_MDF_ChannelProgram__mdt program : [Select Label from Core_MDF_ChannelProgram__mdt
                                                    where Core_MDF_Act_Budget_Amt_Chk_Reqd__c= true])
        {
            programsForActBudgetAmtCheck.add(program.Label);
        }
        List<PartnerFundClaim> listOfClaimsToBeProcessed = new List<PartnerFundClaim>();
        
        for(PartnerFundClaim pfc : inputClaims)
        {
            if(programsForActBudgetAmtCheck.contains(pfc.Core_MDF_Program__c) && pfc.Core_MDF_Type_Txt__c.equals(Label.Core_MDF_Claim_Type)) //check claim type
            {
                listOfClaimsToBeProcessed.add(pfc); 
            }
        }
        
        if(listOfClaimsToBeProcessed!= null && listOfClaimsToBeProcessed.size() > 0)
        { 
            //Label.Core_MDF_InactiveStatusForClaim = 'Cancelled;Denied;Adjusted'
            List<String> claimStatusToBeExcluded = Label.Core_MDF_InactiveStatusForClaim.split(';');
            //Map to store the Activity as key and list of its new claims to be inserted
            Map<Id, List<PartnerFundClaim>> mapNewClaimwithAct = new Map<Id,List<PartnerFundClaim>>();
            for(PartnerFundClaim pfc : listOfClaimsToBeProcessed)
            {
                if(mapNewClaimwithAct.containsKey(pfc.RequestId)){
                    mapNewClaimwithAct.get(pfc.RequestId).add(pfc);
                }
                else{
                    mapNewClaimwithAct.put(pfc.RequestId, new List<PartnerFundClaim>{pfc});
                }
            }
            //Map to store the Activity as key and its Available Budget Amount.
            Map<Id,Decimal> mapofActwithAvailableBudget = new Map<Id,Decimal>();
            
            for(PartnerFundRequest pfr : [Select Id, RequestedAmount,Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Program__c from PartnerFundRequest where Id IN : mapNewClaimwithAct.keySet()])
            {
                if(pfr.Core_MDF_Program__c==Label.Core_MDF_IPA_Program_Name){
                    
                mapofActwithAvailableBudget.put(pfr.Id, pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                }else{
                mapofActwithAvailableBudget.put(pfr.Id, pfr.RequestedAmount);
                }
            }
            
            //Aggregate result to the Sum of Claims Amount on an Activity
            List<AggregateResult> sumofClaimsAmount = [SELECT RequestID, SUM(Amount) claimedAmt, MAX(Request.RequestedAmount) requestedAmount,
                                                       MAX(Request.Core_MDF_Activity_Reimbursement_Amt_nbr__c) activiyReimAmount,MAX(Request.Core_MDF_Program__c) Program 
                                                       from PartnerFundClaim 
                                                       WHERE RequestId IN :mapNewClaimwithAct.keySet()
                                                       AND Core_MDF_Status__c <> :claimStatusToBeExcluded 
                                                       AND Core_MDF_Type_Txt__c = :Label.Core_MDF_Claim_Type 
                                                       AND Id Not IN :inputClaims
                                                       GROUP BY RequestId];
            //To Obtain the Available Amount by decducting the sum of the claims Amount from the Activity Budget Amount
            if(sumofClaimsAmount!= null && sumofClaimsAmount.size() > 0){ 
                for(AggregateResult agg:sumofClaimsAmount){ 
                    Decimal requestedAmount =(Decimal)agg.get('requestedAmount'); 
                    Decimal activiyReimAmount =(Decimal)agg.get('activiyReimAmount'); 
                    Decimal claimedAmt=(decimal)agg.get('claimedAmt'); 
                    mapofActwithAvailableBudget.put((id)agg.get('RequestID'), requestedAmount - claimedAmt);
                    if(agg.get('Program')==Label.Core_MDF_IPA_Program_Name){
                     mapofActwithAvailableBudget.put((id)agg.get('RequestID'), activiyReimAmount - claimedAmt);
                    }else{
                    mapofActwithAvailableBudget.put((id)agg.get('RequestID'), requestedAmount - claimedAmt);
                    }
                } 
            }
            //Loop thro the Incoming Claims List to check 
            //their Amount lies within the corresponding Activity's Budget Amount
            for(Id reqId : mapNewClaimwithAct.keySet())
            { 
                //get the list of claims for a given activity from the list of incoming claims 
                List<PartnerFundClaim> claimLst = mapNewClaimwithAct.get(reqId);
                for(PartnerFundClaim pfc : claimLst)
                {
                    //Get the corresponding Actvity's Available Budget Amount
                    Decimal availableAmount = mapofActwithAvailableBudget.get(pfc.RequestId);
                    if(pfc.Amount > availableAmount)
                    {
                        //Add error if claims amount is more than the activity's available amount
                        pfc.addError(Label.Core_MDF_Retail_Claim_Amount_ShdBeWithIn_ActyBudgetAmt);
                    }
                    else
                    {
                        //If claim amount is lesser than or equal to the activity's available amount,
                        //process it by deducting claim amount from the available amount
                        mapofActwithAvailableBudget.put(pfc.RequestId, availableAmount - pfc.Amount);
                    }
                    
                }
                
            }
        }
    }
    
    
}