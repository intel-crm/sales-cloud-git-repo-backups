/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditSelectionHelper 
* Version     : 1.0 
* Created Date: 10-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P         10/23/2018                   Created Core_MDF_AuditSelectionHelper for Random Audit Selection
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AuditSelectionHelper_BatchTest implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    //Static Variable declarations
    public static Boolean runOnce=true;
    public static Http objhttp;
    public static HttpRequest req ;
    public static HttpResponse res ;
    public static Boolean isError = false; 
    public static String logEntryMsg = '';
    public static Integer retryInd = 1;
    public static Map<Id,PartnerFundClaim> mapClaimPredResult = new Map<Id,PartnerFundClaim>{};
    public static Map<Id,PartnerFundClaim> mapClaimPredError = new Map<Id,PartnerFundClaim>{};
    public static Map<Id,String> mapPFCId = new Map<Id,String>{};
    public static Map<PartnerFundClaim,String> selectedForPredictiveAud = new Map<PartnerFundClaim,String>{};
    public static Map<Id,PartnerFundClaim> claimToPFCMapping = new Map<id,PartnerFundClaim>{};    
    public List<PartnerFundClaim> objListClaim;
    // Parameterised contructor to get the List of object to be handled
    public Core_MDF_AuditSelectionHelper_BatchTest(List<PartnerFundClaim> clmList){
        this.objListClaim = clmList;
    }    
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
        String query = 'SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,requestId,Amount,Core_MDF_Criteria_Hold_No_Id__c,Core_MDF_Criteria_Hold_Ref_No_Txt__c,ChannelPartnerId,'+
                                                    'Core_MDF_Activity_Types__c,Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Status__c,'+
                                                    'LastModifiedDate,request.ChannelPartner.Core_MDF_Channel_Program__c,CreatedById,Core_MDF_Program__c,'+
                                                    'request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,'+
                                                    'Core_MDF_Activity_Category__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_Audit_Type__c,'+
                                                    'Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Hold__c,Core_MDF_AuditSelectionInProgress__c,Core_MDF_Predictive_Audit_Error__c,'+
                                                    'Core_MDF_Predictive_Audit_Retries__c,Core_MDF_Pred_ModelTimeStamp__c,Core_MDF_Pred_PredictionResult__c,Core_MDF_Pred_PredictionScore__c,'+
                                                    'Core_MDF_Pred_Probability__c,Core_MDF_Pred_ThresholdFlag__c,Core_MDF_Pred_IdealModelResult__c,Core_MDF_AccountCompany__c'+  
                                                    'FROM partnerfundClaim where ID IN:objListClaim FOR UPDATE';
        */        
        return Database.getQueryLocator('SELECT Id from Core_MDF_ChannelProgram__mdt'); 
        
    }
/****************************************************************************************************************************************
Method Name:                                             randomAuditSelection
@return  :                                               return map
@parameters:                                             List of claims                                
Description:                                             US177816 - Random Audit Selection
Added By:                                                Accenture – Harika P  -  10/23/2018
Modified By:                  Date:                      Changes: 
Accenture – Harika P        10/23/2018                   Created. 
*****************************************************************************************************************************************/
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static Map<String,Map<PartnerFundClaim, String>> randomAuditSelection(List<PartnerFundClaim> pfcList){ 
        
        System.debug('PFC List in random method:'+pfcList);
        //Variable declarations
        boolean isExceptionOccured  = false;
        Map<String, Core_MDF_CCP_Claim_Window__mdt> claimWindowMap = new Map<String, Core_MDF_CCP_Claim_Window__mdt>();
        Map<PartnerFundClaim,String> pfcMap = new Map<PartnerFundClaim,String>{};
            Map<String,Map<PartnerFundClaim,String>> returnList = new Map<String,Map<PartnerFundClaim,String>>{};
                Core_MDF_CCP_Claim_Window__mdt claimData = new Core_MDF_CCP_Claim_Window__mdt();
        Integer rand;
        
        //get the target percentage,enable random audit flag,random audit baseline number fields program wise from the metadata.
        for(Core_MDF_CCP_Claim_Window__mdt claimWindow : [SELECT Id, toLabel(Core_MDF_Program__c), Core_MDF_Enable_Random_Audit__c, Core_MDF_Amount__c, 
                                                          Core_MDF_Baseline_Random_Number__c, Core_MDF_Target_Percentage__c 
                                                          FROM Core_MDF_CCP_Claim_Window__mdt WHERE Core_MDF_Program__c LIKE '%Co-Marketing%' LIMIT 10000]){
                                                              claimWindowMap.put(claimWindow.Core_MDF_Program__c, claimWindow);
                                                          }      
        try{
            //itearate though the list of Claims.
            for(PartnerFundClaim clm: pfcList){
                if(claimWindowMap.containsKey(clm.Core_MDF_Program__c)){
                    //get the target percentage,enable random audit flag,random audit baseline number and the amount field based on Claim's program.
                    System.debug('claimWindowMap.get(clm.Core_MDF_Program__c):'+claimWindowMap.get(clm.Core_MDF_Program__c));
                    claimData = claimWindowMap.get(clm.Core_MDF_Program__c); 
                    // Replaced clm.Core_MDF_Total_Invoice_Amount_Local__c*clm.Core_MDF_Exchange_rate__c with clm.Amount as per Sushma's inputs
                    If(clm.Amount >= claimData.Core_MDF_Amount__c){
                        // Generating Random number when creating and updating the claim
                        rand = Math.round(Math.random()*(100 / claimData.Core_MDF_Target_Percentage__c));
                        while(rand == 0){
                            rand = Math.round(Math.random()*(100 /claimData.Core_MDF_Target_Percentage__c));
                        }
                        // Checking whether baseline random number equals rand
                        // If yes, then add it to the internal Map with Random as the value
                        if(claimData.Core_MDF_Baseline_Random_Number__c == rand){
                            pfcMap.put(clm,'Random');
                            mapPFCId.put(clm.Id,'Random');
                        }
                        else{                                       
                            // If no, then add it to the internal Map with CheckForPredictiveAudit as the value
                            pfcMap.put(clm,'CheckForPredictiveAudit');
                            mapPFCId.put(clm.Id,'CheckForPredictiveAudit');
                        }
                   }
                   else{                                       
                        // If no, then add it to the internal Map with CheckForPredictiveAudit as the value
                        pfcMap.put(clm,'CheckForPredictiveAudit');
                        mapPFCId.put(clm.Id,'CheckForPredictiveAudit');
                   }
                }
            }
            //need to remove this code.Its just for QA people to test and see the claims picked up for random audit.
            for(PartnerFundClaim pfc : pfcMap.keySet()){
            }
            //preparing the external map.
            returnList = groupClaimsBasedOnAuditType(pfcMap , 'Random');          
        }
        
        //Error handling
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'randomAuditSelection Audit selection method Invocation'); //system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        
        if(isError){
            return null;
        }else{
            //returing the map with random audit selected claims as well as CheckForPredictiveAudit claims marked
            return  returnList;
        }        
    }
    */
/****************************************************************************************************************************************
Method Name:                                             async execute method called from claim
@return  :                                               return void
@parameters:                                             List of claims                                
Description:                                             Audit Selection Entry
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
     
/* Entry point for audit check.
* Accepts a list of claimids and processes it for audit based on selection order programwise.
* STEPS:
* 1). Get the list of claims.
* 2). Get the agency details if the claim is linked/created by an agency.
* 3). Get the selection order metadata for programs.
* 4). Form the xml for predictive audit check for each claims.
* 5). For each claim, check the program, match the program with the selection order metadata and get the audit selection order for the program.
* 6). Add the cliams to the list of either random or predictive based on the audit selection order.
* 7). Iterate though this list and call the corresponding methods to get back either the claims marked as Random/Predictive or claims need to be rechecked for audit.
* Example: In case the claims are checked for Random audit first and they are not marked for random audit the next they should be checked for predictive audit.
* 8). Call the recheck method passing the claims need to be rechecked.
* 9). Finally get the list of claims with the type of audit selected for.
* 10). Set the audit field on claim for the final list of claims selcted for audit.
*/
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimsTobeProcessed) {
        /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
        //variable declarations        
        //Map<Id,PartnerFundClaim> claimToPFCMapping = new Map<id,PartnerFundClaim>{};
        Map<String, Core_MDF_CCP_Claim_Window__mdt> auditSelectionOrder = new Map<String, Core_MDF_CCP_Claim_Window__mdt>();
        Map<String,String> countryGeoMapping = new Map<String,String>{};  
        Map<PartnerFundClaim,String> claimIdListSelectedForAudit = new Map<PartnerFundClaim,String>{};
        Map<Id,Id> userIdToContactIdMapping = new  Map<Id,Id>{};
        Map<Id,Id> userIdToAccountMapping = new  Map<Id,Id>{};
        Map<Id,String> accountIdToAgencyMapping = new  Map<Id,String>{};
        Map<Id,String> claimToXmlMapping = new Map<Id,String>{};     
        Map<PartnerFundClaim,String> claimIdToBeRecheckedForAudit = new Map<PartnerFundClaim,String>{};
        Map<String,Map<PartnerFundClaim,String>> afterRandomAuditCheck = new Map<String,Map<PartnerFundClaim,String>>{}; 
        Map<String,Map<PartnerFundClaim,String>> afterPredictiveAuditCheck = new Map<String,Map<PartnerFundClaim,String>>{};
        Map<PartnerFundClaim,String> returnedClaimsAfterRecheckingAudit = new Map<PartnerFundClaim,String>{};
        
        //If the claims need to be marked for predictive audit based on the flag.
        Map<Id,Boolean> markClaimForPredictiveAudit = new Map<Id,Boolean>{};
        Map<Id,String> userIdToNameMapping = new Map<Id,String>{};
        Map<Id,String> userIdToUserEmailMapping = new Map<Id,String>{};        
        Set<Id> userId = new Set<id>();
        Set<Id> accountId = new Set<id>();        
        List<PartnerFundClaim> claimIdListForRandom = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimIdListForPredictive = new List<PartnerFundClaim>();
        String agencyName = '';
        String geo = '';
        
        //logic started. 
        try{  
            
           String claimTypeNotToBeCheckedForAuditLabel = Label.Core_MDF_Claim_Type_prohibited_for_Audit;
           String[] claimTypeNotToBeCheckedForAudit =  claimTypeNotToBeCheckedForAuditLabel.split(',');
            
             // Calling Hold List Criteria Logic 
            List<PartnerFundClaim> claimsToBeProcessedList =  Core_MDF_HoldCriteriaListProcessHelper.processClaimsForCriteriaHold(objListClaim);         
            System.debug('claimsToBeProcessedList::'+claimsToBeProcessedList);
            for(PartnerFundClaim pfc : claimsToBeProcessedList)
            {
                //map<id,claim object>
                claimToPFCMapping.put(pfc.id,pfc);
                //add the user id in a set.
                userId.add(pfc.CreatedById);
                
            }
            System.debug('userId: '+userId);
            if(userId != null && userId.size() > 0)
            {
                //iterate through the user ids and get th contact id and store it in a map<contact id, user id> 
                for(User u : [select id,contactId,Name,Email from User where id in : userId]){
                    userIdToContactIdMapping.put(u.contactId,u.id);
                    userIdToNameMapping.put(u.id,u.Name);
                    userIdToUserEmailMapping.put(u.id,u.Email);
                }
                
                //iterate through the contact ids and get the account ids and store in a map<user id, account id>
                for(Contact c : [select id,accountId from Contact where id in : userIdToContactIdMapping.keySet()]){
                    userIdToAccountMapping.put(userIdToContactIdMapping.get(c.id),c.accountId);
                    //store the account ids in a set.
                    accountId.add(c.accountId);
                } 
                //iterate through the account ids and get the account names which is a agency and store in map<account id, account name>
                for(Account a : [select id,Name from Account where id in : accountId and Core_MDF_CoMarketingAgency__c=true]){
                    accountIdToAgencyMapping.put(a.id,a.Name);                   
                } 
                
            }        
            
            
            //get the country geo mapping metadata.
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeo : [SELECT MasterLabel,Core_MDF_Geo__c,Core_MDF_Sub_Geo__c from Core_MDF_CCP_Country_Geo_Mapping__mdt])
            {
                if(countryGeo.Core_MDF_Geo__c == 'ASMO')
                {
                //    system.debug('geo is asmo for:'+countryGeo.MasterLabel);
                    countryGeoMapping.put(countryGeo.MasterLabel, countryGeo.Core_MDF_Sub_Geo__c);
                }
                else
                {
                    countryGeoMapping.put(countryGeo.MasterLabel, countryGeo.Core_MDF_Geo__c);
                }
            } 
        //    system.debug('countryGeoMapping:'+countryGeoMapping);
            //get the audit selection order for each program and store the program and metadata in a map.
            for(Core_MDF_CCP_Claim_Window__mdt selection : [SELECT toLabel(core_mdf_program__c),core_mdf_random_audit__c,core_mdf_predictive_audit__c,Core_MDF_Mark_All_Claims_For_Predictive__c,Core_MDF_Enable_Predictive_Audit__c,Core_MDF_Enable_Random_Audit__c from Core_MDF_CCP_Claim_Window__mdt where core_mdf_program__c LIKE '%Co-Marketing%' LIMIT 10000])
            {
                auditSelectionOrder.put(selection.Core_MDF_Program__c, selection);
            } 
            //iterate through the claims in the map. 
            for(id claimId:claimToPFCMapping.keySet())
            {
                if(!claimToPFCMapping.get(claimId).Core_MDF_IsClaimReviewEscalation_Ind__c == true)
                {
                //get the user id for the claim.
                id uId = claimToPFCMapping.get(claimId).CreatedById;
                //get the account id from map<user id , account id>.
                id aId = userIdToAccountMapping.get(uId);
                //get the agency name if the account is an agency.
                agencyName = '';
                if(accountIdToAgencyMapping.containsKey(aId)){
                    agencyName = accountIdToAgencyMapping.get(aId);}
                
            //    system.debug('geo:'+geo);
                //form xml for predictive audit check.
                
                String xmlForPredAudCheck = formXmlForPredAuditCheck(claimToPFCMapping.get(claimId),agencyName,geo,userIdToNameMapping.get(uId),userIdToUserEmailMapping.get(uId));
            //    system.debug('xmlForPredAudCheck:'+xmlForPredAudCheck);
                //put the xml and the claim id into a map<claim id, xml>
                claimToXmlMapping.put(claimId,xmlForPredAudCheck);
                
                if(auditSelectionOrder.containsKey(claimToPFCMapping.get(claimId).Core_MDF_Program__c))
                {
                    //get the random audit and predictive audit order for the claim program.
                    Core_MDF_CCP_Claim_Window__mdt auditSelection = auditSelectionOrder.get(claimToPFCMapping.get(claimId).Core_MDF_Program__c);
                    //if random audit should be executed for the claim first the add it to random audit selected list otherwise viceversa.
                    if(auditSelection.Core_MDF_Enable_Predictive_Audit__c && auditSelection.core_mdf_random_audit__c>auditSelection.core_mdf_predictive_audit__c)
                    {
                        //add the claim objects to a list that needs to be checked for predictive audit.
                        claimIdListForPredictive.add(claimToPFCMapping.get(claimId));
                        
                    }
                    //add the claim objects to a list that needs to be checked for random audit.
                    else if(auditSelection.Core_MDF_Enable_Random_Audit__c){claimIdListForRandom.add(claimToPFCMapping.get(claimId));}
                    markClaimForPredictiveAudit.put(claimId,auditSelection.Core_MDF_Mark_All_Claims_For_Predictive__c);
                }
                }
            }
            
            system.debug('claimIdListForRandom: '+claimIdListForRandom); 
            system.debug('claimIdListForPredictive: '+claimIdListForPredictive);     
            
            //if random audit list contains claims then call random audit selection process first. 
            if(claimIdListForRandom != null && claimIdListForRandom.size()>0)
            {
                afterRandomAuditCheck = randomAuditSelection(claimIdListForRandom);
                //separate out the claims which are seleced for random audit into a map<claim,Random>
                if(afterRandomAuditCheck != null)
                {
                    claimIdListSelectedForAudit = afterRandomAuditCheck.get('Random');                                   
                    //separate out the claims which needs to be rechecked for predictive audit into a map<claim,CheckForPredictiveAudit>
                    claimIdToBeRecheckedForAudit = afterRandomAuditCheck.get('CheckForPredictiveAudit');
                }
            }
            
            //if predictive audit list contains claims then call predictive audit selection process first.
            if(claimIdListForPredictive != null && claimIdListForPredictive.size()>0)
            {
                afterPredictiveAuditCheck = predictiveAuditSelection(claimIdListForPredictive,claimToXmlMapping,markClaimForPredictiveAudit);
                //separate out the claims which are seleced for predictive audit into a map<claim,Predictive>            
                if(afterPredictiveAuditCheck != null)
                {
                    claimIdListSelectedForAudit = afterPredictiveAuditCheck.get('Predictive');
                    //separate out the claims which needs to be rechecked for random audit into a map<claim,CheckForRandomAudit>           
                    claimIdToBeRecheckedForAudit = afterPredictiveAuditCheck.get('CheckForRandomAudit');

                }
            }
            
            system.debug('claimIdListSelectedForAudit: '+claimIdListSelectedForAudit); 
            system.debug('claimIdToBeRecheckedForAudit: '+claimIdToBeRecheckedForAudit);     
            
            //if claimIdToBeRecheckedForAudit has some claims for rechecking then call recheck claim method for the claimIdToBeRecheckedForAudit map.
            if(claimIdToBeRecheckedForAudit != null && claimIdToBeRecheckedForAudit.size()>0)
            {
                returnedClaimsAfterRecheckingAudit = recheckClaims(claimIdToBeRecheckedForAudit,claimToXmlMapping,markClaimForPredictiveAudit);
                //if there are any other claims selected for audit after second round of check, then add it to the previous map<claim,Random/Predictive>
                if(returnedClaimsAfterRecheckingAudit != null && returnedClaimsAfterRecheckingAudit.size()>0)
                {
                    if(claimIdListSelectedForAudit==null){claimIdListSelectedForAudit = new Map<PartnerFundClaim,String>{};}
                    claimIdListSelectedForAudit.putAll(returnedClaimsAfterRecheckingAudit);
                }
            }
            //set up audit attributes.
            if(claimIdListSelectedForAudit != null && claimIdListSelectedForAudit.size()>0)
            {
                setAuditStatus(claimIdListSelectedForAudit);
            }
            else
            {
                claimIdListSelectedForAudit = new Map<PartnerFundClaim,String>{};
                    for(PartnerFundClaim p : objListClaim)
                {
                    claimIdListSelectedForAudit.put(p,null); 
                    mapPFCId.put(p.Id,null);                    
                }
                system.debug('claimIdListSelectedForAudit:'+claimIdListSelectedForAudit);
                setAuditStatus(claimIdListSelectedForAudit);
            }
        }
        catch(exception ex)
        {logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Audit selection method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        */
    }
    
/****************************************************************************************************************************************
Method Name:                                             formXmlForPredAuditCheck
@return  :                                               return String
@parameters:                                             claim object,agency name,geo name,user name,user email                                
Description:                                             Form Xml for predictive audit check
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
     
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static String formXmlForPredAuditCheck(PartnerFundClaim claim, String agencyName,String geo,String userName,String userEmail){
        String xml = null;
        try{
            xml =
                '<item><RequestID><![CDATA['+claim.Core_MDF_Claim_Ref_Number__c+']]></RequestID>'+
                '<RequestCreationDate>'+claim.CreatedDate+'</RequestCreationDate>'+
                '<CompanyID><![CDATA['+claim.Core_MDF_AccountCompany__c+']]></CompanyID>'+
                '<MediaID><![CDATA['+claim.Core_MDF_Activity_Category__c+']]></MediaID>'+
                '<GeoID><![CDATA['+geo+']]></GeoID>'+
                '<AdvertisementID><![CDATA['+claim.Core_MDF_Activity_Types__c+']]></AdvertisementID>'+
                '<ClaimedAmount>'+claim.Amount+'</ClaimedAmount>'+
                '<RandomSamplingFlag>No</RandomSamplingFlag>'+    
                '<SubmitterName><![CDATA['+userName+']]></SubmitterName>'+
                '<SubmitterEmail><![CDATA['+userEmail+']]></SubmitterEmail>';
            if(agencyName != '')
            {
                xml = xml + '<SubmitterCompany><![CDATA['+agencyName+']]></SubmitterCompany>'+
                    '<SubmitterAgency><![CDATA['+agencyName+']]></SubmitterAgency>';
            }
            else
            {
                xml = xml + '<SubmitterCompany><![CDATA['+claim.Core_MDF_AccountCompany__c+']]></SubmitterCompany>'+
                    '<SubmitterAgency></SubmitterAgency>';
            }
            xml = xml + '<Program><![CDATA['+claim.Core_MDF_Program__c+']]></Program></item>';
        }
        catch(exception ex)
        {
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'formXmlForPredAuditCheck Audit selection method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        return xml;
*/
    //}
    
    
    
/****************************************************************************************************************************************
Method Name:                                             recheckClaims
@return  :                                               return Map<PartnerFundClaim,String>
@parameters:                                             map of claims to be rechecked,xml for the claims,mark claim for predictive audit flag values       
Description:                                             claims to be rechecked for audit
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
   /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization   
    
    public static Map<PartnerFundClaim,String> recheckClaims(Map<PartnerFundClaim,String> claimIdToBeRecheckedForAudit,Map<Id,String> claimToXmlMapping, Map<Id,Boolean> markClaimForPredictiveAudit){
        /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
        List<PartnerFundClaim> claimIdListForRandom = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimIdListForPredictive = new List<PartnerFundClaim>();
        Map<PartnerFundClaim,String> claimIdListSelectedForAudit = new Map<PartnerFundClaim,String>{};
        Map<String,Boolean> enablePredictiveAudit = new Map<String,Boolean>{};
        Map<String,Boolean> enableRandomAudit = new Map<String,Boolean>{};
        //get the audit selection order for each program and store the program and metadata in a map.
        for(Core_MDF_CCP_Claim_Window__mdt selection : [SELECT toLabel(core_mdf_program__c),Core_MDF_Enable_Predictive_Audit__c,Core_MDF_Enable_Random_Audit__c from Core_MDF_CCP_Claim_Window__mdt where core_mdf_program__c LIKE '%Co-Marketing%' LIMIT 10000]){
            enablePredictiveAudit.put(selection.Core_MDF_Program__c, selection.Core_MDF_Enable_Predictive_Audit__c);
            enableRandomAudit.put(selection.Core_MDF_Program__c, selection.Core_MDF_Enable_Random_Audit__c);
        }     
        
        System.debug('claimIdToBeRecheckedForAudit.keySet() :' + claimIdToBeRecheckedForAudit.keySet());
        System.debug('claimIdToBeRecheckedForAudit.size() :' + claimIdToBeRecheckedForAudit.size());
        
        try{
            if(claimIdToBeRecheckedForAudit != null && claimIdToBeRecheckedForAudit.size()>0){
                //iterate through the map<claim,CheckForRandomAudit/CheckForPredictiveAudit> and call the required audit check method
                for (PartnerFundClaim claim:claimIdToBeRecheckedForAudit.keySet())
                { 
                    if(claimIdToBeRecheckedForAudit.get(claim) == 'CheckForRandomAudit' && enableRandomAudit.get(claim.core_mdf_program__c))
                    {
                        //if needs to go for random audit check, add to random audit claim object list.    
                        claimIdListForRandom.add(claim);
                    }
                    else if(enablePredictiveAudit.get(claim.core_mdf_program__c))
                    {
                        //if needs to go for predictive audit check, add to predictive audit claim object list.                    
                        claimIdListForPredictive.add(claim);
                    }
                    
                }
                //call the predictive audit method for claimIdListForPredictive
                if(claimIdListForPredictive != null && claimIdListForPredictive.size()>0){
                    Map<String,Map<PartnerFundClaim,String>> afterPredictiveAuditCheck = predictiveAuditSelection(claimIdListForPredictive,claimToXmlMapping,markClaimForPredictiveAudit);
                    if(afterPredictiveAuditCheck != null && afterPredictiveAuditCheck.size() > 0){
                        claimIdListSelectedForAudit = afterPredictiveAuditCheck.get('Predictive');           
                    }
                    
                }
                //call the random audit method for claimIdListForRandom      
                if(claimIdListForRandom != null && claimIdListForRandom.size()>0){
                    Map<String,Map<PartnerFundClaim,String>> afterRandomAuditCheck = randomAuditSelection(claimIdListForRandom);
                    if(afterRandomAuditCheck != null && afterRandomAuditCheck.size() > 0){
                        claimIdListSelectedForAudit = afterRandomAuditCheck.get('Random');       
                    }
                    
                }
                
            }
            //if not selected for any audit, put the claims in the map with value as map<claim,null>
            //Need to do the above process since we need to update all the claims with audit in progress flag to false 
            //irrespective of whether they are selected for audit or not.
            
            for(PartnerFundClaim pfc:claimIdToBeRecheckedForAudit.keySet()){
                if(claimIdListSelectedForAudit != null && !claimIdListSelectedForAudit.containsKey(pfc)){
                    claimIdListSelectedForAudit.put(pfc,null); 
                    mapPFCId.put(pfc.Id,null);                  
                } 
                else if(claimIdListSelectedForAudit == null){
                    claimIdListSelectedForAudit = new Map<PartnerFundClaim,String>{};
                    claimIdListSelectedForAudit.put(pfc,null);
                    mapPFCId.put(pfc.Id,null);
                }
            }
            
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'recheckClaims Audit selection method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        //return the map<claim,Random/Predictive> after rechecking
        system.debug('recheck logic: '+claimIdListSelectedForAudit);
        return claimIdListSelectedForAudit;
    }
    */
/****************************************************************************************************************************************
Method Name:                                             setAuditStatus
@return  :                                               return void
@parameters:                                             Map<PartnerFundClaim,String>       
Description:                                             method to set audit status for the claim ids.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
       
   /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization 
    public static void setAuditStatus(Map<PartnerFundClaim,String> claimIdListSelectedForAudit)
    {
        
        system.debug('claimIdListSelectedForAudit: '+claimIdListSelectedForAudit);
        system.debug('mapPFCId: '+mapPFCId);
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        try{
            //iterarte through the claim and set the audit fields for claim object.    
            for(Id pfcId : mapPFCId.keySet()){  
                PartnerFundClaim updatePfc = new PartnerFundClaim();
                updatePfc.id = pfcId;   
                updatePFC.Core_MDF_Criteria_Hold_No_Id__c = claimToPFCMapping.get(pfcId).Core_MDF_Criteria_Hold_No_Id__c;
                updatePfc.Core_MDF_Criteria_Hold_Ref_No_Txt__c = claimToPFCMapping.get(pfcId).Core_MDF_Criteria_Hold_Ref_No_Txt__c;
                updatePfc.Core_MDF_Criteria_Hold_Ind__c = claimToPFCMapping.get(pfcId).Core_MDF_Criteria_Hold_Ind__c;
                updatePfc.Core_MDF_Status__c = claimToPFCMapping.get(pfcId).Core_MDF_Status__c;
                if(runOnce){                      
                    if(mapPFCId.get(pfcId) != null){
                        //get the audit type from map<claim,auditType>
                        string auditType = getValueForAuditTypePicklist(mapPFCId.get(pfcId));    
                        system.debug('returnAuditTypeValue'+auditType);
                        updatePfc.Core_MDF_Audit_Type__c = auditType;            
                        updatePfc.Core_MDF_FlaggedForAudit__c = true; 
                        updatePfc.Core_MDF_Audit_Hold__c = true;
                        updatePfc.Core_MDF_Status__c = 'Hold';
                    }
                    
                    //updating audit in progress flag for all claims to false if no error.
                    system.debug('mapClaimPredError:'+mapClaimPredError);
                    if(mapClaimPredError.containsKey(pfcId)){
                        if(!mapClaimPredError.get(pfcId).Core_MDF_Predictive_Audit_Error__c){
                         updatePfc.Core_MDF_AuditSelectionInProgress__c = false;
                         updatePfc.Core_MDF_Predictive_Audit_Error__c = mapClaimPredError.get(pfcId).Core_MDF_Predictive_Audit_Error__c;
                        }
                        else if(mapClaimPredError.get(pfcId).Core_MDF_Predictive_Audit_Error__c){
                         updatePfc.Core_MDF_AuditSelectionInProgress__c = true;
                         updatePfc.Core_MDF_Predictive_Audit_Error__c = mapClaimPredError.get(pfcId).Core_MDF_Predictive_Audit_Error__c;
                         updatePfc.Core_MDF_Predictive_Audit_Retries__c = mapClaimPredError.get(pfcId).Core_MDF_Predictive_Audit_Retries__c;
                        }
                    }
                    //added in case prediction is switched off.
                    else{
                         updatePfc.Core_MDF_AuditSelectionInProgress__c = false;
                    }
                    
                    system.debug('mapClaimPredResult:'+mapClaimPredResult);
                    if(mapClaimPredResult.containsKey(pfcId)){
                        updatePfc.Core_MDF_Pred_ModelTimeStamp__c = mapClaimPredResult.get(pfcId).Core_MDF_Pred_ModelTimeStamp__c;
                        updatePfc.Core_MDF_Pred_PredictionResult__c = mapClaimPredResult.get(pfcId).Core_MDF_Pred_PredictionResult__c;
                        updatePfc.Core_MDF_Pred_PredictionScore__c= mapClaimPredResult.get(pfcId).Core_MDF_Pred_PredictionScore__c;
                        updatePfc.Core_MDF_Pred_Probability__c= mapClaimPredResult.get(pfcId).Core_MDF_Pred_Probability__c;
                        updatePfc.Core_MDF_Pred_ThresholdFlag__c= mapClaimPredResult.get(pfcId).Core_MDF_Pred_ThresholdFlag__c;
                        updatePfc.Core_MDF_Pred_IdealModelResult__c= mapClaimPredResult.get(pfcId).Core_MDF_Pred_IdealModelResult__c;                               
                    }
                    
                    claimsToBeUpdated.add(updatePfc);                
                    system.debug('pfc to be edited: '+updatePfc);  
                    
                }                
            }
           // system.debug('claimsToBeUpdated:'+claimsToBeUpdated);
            runOnce=false;
            if(claimsToBeUpdated.size()>0){
                list<Database.SaveResult> results = Database.update(claimsToBeUpdated); 
                //system.debug('results: '+results);
            }         
            //system.debug('updated successfully!!');           
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'setAuditStatus Audit selection method Invocation');
            //system.debug('logEntryMsg' + logEntryMsg +isError );
        }
    }
*/

/****************************************************************************************************************************************
Method Name:                                             getValueForAuditTypePicklist
@return  :                                               return string
@parameters:                                             audit type string value      
Description:                                             based on the picklist api name gets the label for audit type.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
           
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static String getValueForAuditTypePicklist(String auditType){
        Map<String,String> auditTypePicklistApi = new Map<String,String>{};
        String returnAuditTypeValue = '';
        try{
            Schema.DescribeFieldResult field = PartnerFundClaim.Core_MDF_Audit_Type__c.getDescribe();
            //gets all the picklist values in a map<api name,label>
            for (Schema.PicklistEntry f : field.getPicklistValues())
                auditTypePicklistApi.put(f.getValue(),f.getLabel());//stores the map<api name,label>
            
            if(auditType=='Predictive')
                returnAuditTypeValue = auditTypePicklistApi.get('CAP');
            else if(auditType=='Random')
                returnAuditTypeValue = auditTypePicklistApi.get('Random');
            else
                returnAuditTypeValue = auditTypePicklistApi.get('Manual');
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'getValueForAuditTypePicklist method Invocation'); //system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        return returnAuditTypeValue;
    }
*/

/****************************************************************************************************************************************
Method Name:                                             createRequestId
@return  :                                               return string
@parameters:                                             N/A      
Description:                                             create request ID for predictive request yyyymmddhhmmss.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
   
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static String createRequestId(){
        String requestId = null;
        try{
            String todaysDate = String.valueOf(DateTime.Now());
            String[] myDateTime = todaysDate.split(' ');
            String[] myDateOnly = myDateTime[0].split('-');
            String[] myTimeOnly = myDateTime[1].split(':');
              
            String myIntMonth = String.valueOf(myDateOnly[1]);
            String myIntYear = String.valueOf(myDateOnly[0]);
            String myIntDate = String.valueOf(myDateOnly[2]);
            String myHour = String.valueOf(myTimeOnly[0]);
            String myMin = String.valueOf(myTimeOnly[1]);
            String mySec = String.valueOf(myTimeOnly[2]);
            
            requestId = myIntYear+myIntMonth+myIntDate+myHour+myMin+mySec;
        }
        catch(exception ex){logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'requ id creation method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );}
        return requestId;
    }
*/

/****************************************************************************************************************************************
Method Name:                                             callCAPSApi
@return  :                                               return string
@parameters:                                             list of claims,xml for the claim      
Description:                                             call CAPS API.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
   
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static String callCAPSApi(List<PartnerFundClaim> pfcIdList,Map<Id,String> claimToXmlMapping){
        string apiKey = Label.Core_MDF_CAPS_APIKey;
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        String xml = null;
        string response = null;
        List<PartnerFundClaim> ListOfClaims = pfcIdList;
        Map<Id,String> xmlMapping = claimToXmlMapping;

        try{
            req.setEndpoint('callout:Core_MDF_Predictive_API');
            req.setMethod('POST');
            req.setHeader('API_Key', apiKey);
            req.setHeader('Content-Type', 'text/xml');
            //xml formation
            xml = '<AdvancedBI><MinnindTask><ProjectId Desc="CAPS_SFDC" ID="'+Label.Core_MDF_CapsCCPProjID+'" /></MinnindTask><Request><ID>'+createRequestId()+'</ID><Lines>';
            
            //iterate through the claims and add the xml for each claims passed.
            for(PartnerFundClaim claim:pfcIdList){
                xml = xml + claimToXmlMapping.get(claim.Id);                                 
            }
            //adding the end tags   
            xml = xml + '</Lines></Request></AdvancedBI>';            
            system.debug('xml: '+xml);
            req.setBody(xml);
            
            system.debug('Req:' + req);
            //calls CAPS api
            if(retryInd<3){
                system.debug('retry:'+retryInd); 
                HTTPResponse res = http.send(req);
                //sets the response in proper xml    
                //response = res.getBody().replace('&lt;', '<');
                //response = response.replace('&gt;', '>');
                response = res.getBody();
                system.debug('response:'+response);
            }
            else { 
                response = null; 
            }
        }
*/    
/* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
        catch(exception ex){
        //    system.debug('exception:'+ex);

            if(retryInd<3){
                retryInd = retryInd+1;
                response = callCAPSApi(ListOfClaims,xmlMapping);
            }
            else{
                logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'callCAPSApi method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
            }
        }
        return response;
    }
*/

/****************************************************************************************************************************************
Method Name:                                             readXmlResponseAfterCAPSApiCall
@return  :                                               return Map<PartnerFundClaim,String>
@parameters:                                             response string,list of claims,markClaimForPredictiveAudit value for the claim      
Description:                                             read xml response after the CAPS API call.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
    
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static Map<PartnerFundClaim,String> readXmlResponseAfterCAPSApiCall(String response,List<PartnerFundClaim> pfcIdList){
        Dom.Document doc = new Dom.Document();
        Map<String,PartnerFundClaim> claimRefNumberToClaimObjMap = new Map<String,PartnerFundClaim>{};
        try{
            
            
            for(PartnerFundClaim claim:pfcIdList){
               claimRefNumberToClaimObjMap.put(claim.Core_MDF_Claim_Ref_Number__c,claim); 
            }
            
            system.debug('claimRefNumberToClaimObjMap:'+claimRefNumberToClaimObjMap);
            
            
            doc.load(response);
            if(doc.getRootElement().getName() == 'AdvancedBI'){
                for(Dom.XMLNode line: doc.getRootElement().getChildElement('Request',null).getChildElements()){
                    Dom.XMLNode ProjectID = line.getChildElement('ProjectId',null);
                    String RequestID = ProjectID.getChildElement('RequestID', null).getText();
                    system.debug('RequestID:'+RequestID); 
                    //for(PartnerFundClaim pfc:pfcIdList){
                            
                        //checks if the returned request id from caps matches to the input claim id. if yes, gets rest predictive audit fields to be set.
                            if(claimRefNumberToClaimObjMap.containsKey(RequestID))
                            {                                
                            PartnerFundClaim pfc = new PartnerFundClaim();
                            PartnerFundClaim p = new PartnerFundClaim();                                
                            pfc = claimRefNumberToClaimObjMap.get(RequestID);    
                            p.Id = pfc.Id;
                            system.debug('request id matched with ref number for :'+p);
                            p.Core_MDF_Pred_ModelTimeStamp__c = getDateTimeForString(ProjectId.getChildElement('ModelTimeStamp',null).getText());                   
                            p.Core_MDF_Pred_PredictionResult__c=ProjectId.getChildElement('PredictionResult',null).getText();
                            p.Core_MDF_Pred_PredictionScore__c=Decimal.valueOf(ProjectId.getChildElement('PredictionScore',null).getText());
                            p.Core_MDF_Pred_Probability__c=decimal.valueOf(ProjectId.getChildElement('Probability',null).getText());
                            p.Core_MDF_Pred_ThresholdFlag__c=ProjectId.getChildElement('ThresholdFlag',null).getText();
                            p.Core_MDF_Pred_IdealModelResult__c=ProjectId.getChildElement('IdealModelResult',null).getText();
                            //form the internal map<claim,Predictive/CheckForRandomAudit>
                            if(p.Core_MDF_Pred_ThresholdFlag__c == 'Yes'){
                                selectedForPredictiveAud.put(p,'Predictive');
                                mapPFCId.put(p.Id,'Predictive');
                            }
                            else{
                                selectedForPredictiveAud.put(p,'CheckForRandomAudit');
                                mapPFCId.put(p.Id,'CheckForRandomAudit');
                            }
                             mapClaimPredResult.put(pfc.Id,p);
                             system.debug('mapClaimPredResult added:'+mapClaimPredResult);   
                            //mapClaimPredResult.put(pfc.Id,p);
                            }                       
                       
                    //} 
                    
                }                
            }
             system.debug('mapClaimPredResult final:'+mapClaimPredResult);
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'readXmlResponseAfterCAPSApiCall method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        return selectedForPredictiveAud;
    }
*/
    
/****************************************************************************************************************************************
Method Name:                                             predictiveAuditSelection
@return  :                                               return Map<String,Map<PartnerFundClaim, String>>
@parameters:                                             list of claims,xml for the claims,markClaimForPredictiveAudit value for the claim      
Description:                                             Predictive audit check.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
    
   /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization   
    public static Map<String,Map<PartnerFundClaim, String>> predictiveAuditSelection(List<PartnerFundClaim> pfcIdList,Map<Id,String> claimToXmlMapping, Map<Id,Boolean> markClaimForPredictiveAudit)
    { 
        Map<String,Map<PartnerFundClaim,String>> returnList = new Map<String,Map<PartnerFundClaim,String>>{};
        Core_MDF_CCP_Multicurrency multicurrencyObj = new Core_MDF_CCP_Multicurrency();
        List<PartnerFundClaim> claimsToBeCheckedForPredAudit = new List<PartnerFundClaim>();
        Map<Id,PartnerFundClaim> mapClaimsToBeCheckedForPredAudit = new Map<Id,PartnerFundClaim>{};        
        String response;
            
        try{
            system.debug('inside predictive audit check');
            
            //check the mark for predictive flag for the claims. if true then dont call api otherwise call predictive api.
            for(PartnerFundClaim pfc:pfcIdList){
                if(markClaimForPredictiveAudit.containsKey(pfc.Id) && markClaimForPredictiveAudit.get(pfc.Id)){
                            selectedForPredictiveAud.put(pfc,'Predictive');
                            mapPFCId.put(pfc.Id,'Predictive');
                }
                else{
                    claimsToBeCheckedForPredAudit.add(pfc);  
                    mapClaimsToBeCheckedForPredAudit.put(pfc.Id, pfc);
                }
            }
            
            system.debug('claimsToBeCheckedForPredAudit:'+claimsToBeCheckedForPredAudit);
            system.debug('mapClaimsToBeCheckedForPredAudit:'+mapClaimsToBeCheckedForPredAudit);
            
            if(claimsToBeCheckedForPredAudit != null && claimsToBeCheckedForPredAudit.size() > 0){
            //cal caps api
            response = callCAPSApi(claimsToBeCheckedForPredAudit,claimToXmlMapping);
                 
            //read xml response and set whether selected for predictive audit or not
            if(response != null){
                selectedForPredictiveAud = readXmlResponseAfterCAPSApiCall(response,claimsToBeCheckedForPredAudit);
            }
            }
                            
            system.debug('selectedForPredictiveAud: '+selectedForPredictiveAud);
                
            Map<PartnerFundClaim,String> markedForPredictiveAud = new Map<PartnerFundClaim,String>{};
           
            //if any error while getting response from CAPS or xml format, then set the error flag as true else set to false.
            //We need to set this field since based on this flag the claims will be retried by the batch.               
            for(PartnerFundClaim pfc:pfcIdList){
                PartnerFundClaim p = new PartnerFundClaim();
                p.Id=pfc.Id;
                system.debug('selectedForPredictiveAud size:'+selectedForPredictiveAud.size());
                
                if(mapClaimsToBeCheckedForPredAudit.containsKey(pfc.Id) && (response == null || !mapPFCId.containsKey(pfc.Id))){
                    system.debug('its an error');
                    p.Core_MDF_Predictive_Audit_Error__c = true;
                    p.Core_MDF_Predictive_Audit_Retries__c = pfc.Core_MDF_Predictive_Audit_Retries__c + 1;
                             
                }
                else{                            
                    system.debug('not an error');
                    p.Core_MDF_Predictive_Audit_Error__c = false;
                    System.debug('mapPFCId.get(pfc.Id): '+mapPFCId.get(pfc.Id));
                    markedForPredictiveAud.put(pfc,mapPFCId.get(pfc.Id));
                }
                   mapClaimPredError.put(pfc.Id,p);             
                }
                
                                  
                
                           
            system.debug('markedForPredictiveAud:' + markedForPredictiveAud);
                
            if(markedForPredictiveAud != null && markedForPredictiveAud.size() > 0){
                returnList = groupClaimsBasedOnAuditType(markedForPredictiveAud , 'Predictive');
            }
            //else
            //{
                //for(PartnerFundClaim pfc:pfcIdList) 
               //     selectedForPredictiveAud.put(pfc,'CheckForRandomAudit');
               // returnList = groupClaimsBasedOnAuditType(selectedForPredictiveAud , 'CheckForRandomAudit');
            //}
            
        }
        catch(exception ex){            
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Predictive Audit selection method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        
        system.debug('returnList: '+returnList);
        return returnList;
    }
*/
/****************************************************************************************************************************************
Method Name:                                             groupClaimsBasedOnAuditType
@return  :                                               return Map<String,Map<PartnerFundClaim, String>>
@parameters:                                             map of claims with audit selected type,audit selection string    
Description:                                             groups claims based on audit type.Forms the outer map.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/
      
   /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization 
    public static Map<String,Map<PartnerFundClaim,String>> groupClaimsBasedOnAuditType(Map<PartnerFundClaim,String> selectedForAud, String auditSelection){
        Map<String,Map<PartnerFundClaim,String>> returnList = new Map<String,Map<PartnerFundClaim,String>>{};       
        String recheckForAuditType = '';
        
        try{
            if(auditSelection == 'Predictive'){
                recheckForAuditType = 'CheckForRandomAudit';
            }           
            else{
                recheckForAuditType = 'CheckForPredictiveAudit';
            }
                
            //iterate through the claims and group them for the external maps    
            for(PartnerFundClaim c:selectedForAud.keySet()){
                
                //group the claims thats are marked for predictive/random audit in a map<claim,Predictive> or map<claim,Random>       
                if(selectedForAud.get(c) == auditSelection){
                    if(returnList.ContainsKey(auditSelection)){
                        Map<PartnerFundClaim,String> tempMap1= new Map<PartnerFundClaim,String>{};        
                        tempMap1=returnList.get(auditSelection);
                        tempMap1.put(c,auditSelection);
                        returnList.put(auditSelection,tempMap1);
                    }
                    else{
                        Map<PartnerFundClaim,String> tempMap2= new Map<PartnerFundClaim,String>{};
                        tempMap2.put(c,auditSelection);
                        returnList.put(auditSelection,tempMap2);
                    }                   
                }
                
                //group the claims thats are marked for CheckForRandomAudit/CheckForPredictiveAudit audit in a map<claim,CheckForRandomAudit> or map<claim,CheckForPredictiveAudit>        
                if(selectedForAud.get(c) == recheckForAuditType){
                    if(returnList.ContainsKey(recheckForAuditType)){
                        Map<PartnerFundClaim,String> tempMap1 = new Map<PartnerFundClaim,String>{};        
                        tempMap1=returnList.get(recheckForAuditType);
                        tempMap1.put(c,recheckForAuditType);
                        returnList.put(recheckForAuditType,tempMap1);
                    }
                    else{
                        Map<PartnerFundClaim,String> tempMap2= new Map<PartnerFundClaim,String>{};
                        tempMap2.put(c,recheckForAuditType);
                        returnList.put(recheckForAuditType,tempMap2);
                    }
                    
                }                
            }
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'groupClaimsBasedOnAuditType method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        return returnList;
    }
*/

/****************************************************************************************************************************************
Method Name:                                             getDateTimeForString
@return  :                                               return DateTime
@parameters:                                             string To Be Converted to datetime
Description:                                             converts string of the format mm/dd/yyyy hh:min:sec to datetime.
Added By:                                                Ealisha Chatterjee
Modified By:                  Date:                      Changes: 
Ealisha Chatterjee          10/23/2018                   Created. 
*****************************************************************************************************************************************/    
    /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
    public static DateTime getDateTimeForString(string stringToBeConverted){
        DateTime outputDate = null;
        try{
            String[] myDateTime = stringToBeConverted.split(' ');
            String[] myDateOnly = myDateTime[0].split('/');
            String[] myTimeOnly = myDateTime[1].split(':');
            Integer myIntDate = integer.valueOf(myDateOnly[1]);
            Integer myIntMonth = integer.valueOf(myDateOnly[0]);
            Integer myIntYear = integer.valueOf(myDateOnly[2]);
            Integer myHour = integer.valueOf(myTimeOnly[0]);
            Integer myMin = integer.valueOf(myTimeOnly[1]);
            Integer mySec = integer.valueOf(myTimeOnly[2]);
            outputDate = DateTime.newInstance(myIntYear, myIntMonth, myIntDate,myHour,myMin,mySec);
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);isError = true;Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'getDateTimeForString method Invocation');system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        return outputDate;
    }
*/
    public void finish(Database.BatchableContext bc) {}
}