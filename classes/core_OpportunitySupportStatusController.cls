/****************************************************************************************************************************************
* Class Name  : core_OpportunitySupportStatusController 
* Version     : 1.0 
* Created Date: 19-06-2023
* Modification Log :
* Developer                         Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hira Khan(Accenture - Unicorn)    12-06-2023         Controller Class for core_OpportunitySupporStatus LWC(TWC3123-4568)
*****************************************************************************************************************************************/
public without sharing class core_OpportunitySupportStatusController { //TWC3123-5759 Added without sharing keyword to fix code scan issue
    
/*****************************************************
* Method name  : pullSeedsSamples
* Description  : Method to pull Seeds and Samples Data
* Return Type  : SeedSampleWrap
* Parameter    : Id sOppId
******************************************************/    
    @AuraEnabled(cacheable=true)
    public static SeedSampleWrap pullSeedsSamples(Id sOppId) {
        Map<String,Core_System_Credentials__c> mapStringToCS=new Map<String,Core_System_Credentials__c>();
        for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values())
            mapStringToCS.put(sobjCS.Name, sobjCS);
        
        // List to deserialize seeds JSON response, and the (potentially) filtered results for the user
        List<SeedWebserviceWrapper> lstSeeds =new List<SeedWebserviceWrapper>();
        List<SeedWebserviceWrapper> lstFilteredSeeds=new List<SeedWebserviceWrapper>();
        
        // List to deserialize samples JSON response, and the (potentially) filtered results for the user
        List<SampleWebserviceWrapper> lstSamples=new List<SampleWebserviceWrapper>();
        List<SampleWebserviceWrapper> lstFilteredSamples=new List<SampleWebserviceWrapper>();
        
        //Wrapping Seed and Sample Together
        SeedSampleWrap SeedSampleWrapData=new SeedSampleWrap(); 
        SeedSampleWrapData.bSeedsErrorFlag=false;
        SeedSampleWrapData.bSeedsErrorMessage=''; 
        SeedSampleWrapData.bSamplesErrorFlag=false;
        SeedSampleWrapData.bSamplesErrorMessage='';
        
        //SeedSampleWrapData.ucdSwitch=Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch
        Opportunity OppData = [select id, Account.Core_CIM_ID__c, Account.Core_Business_Party_Id__c from Opportunity where Id = :sOppId]; //TWC4767-3983
        SeedSampleWrapData.ucdSwitch = (String.isBlank(OppData.Account.Core_Business_Party_Id__c)) ? false : true; //TWC4767-3983
            
        //SeedSampleWrapData.kcrGlobalAccNameTemp = [select id, Account.KCR_Global_Account_Name_Temp__c from Opportunity where Id = :sOppId].Account.KCR_Global_Account_Name_Temp__c; //TWC4767-3983
            
         // Intialize the declared variables
         lstSeeds = new List<seedWebserviceWrapper> {};
         List<String> lstOppID = new List<String>{};
         List<String> lstAcctID = new List<String>{};
         Map<String,String> mapOppNametoID = new Map<String,String>{};
         Map<String,String> mapAcctNametoID = new Map<String,String>{};
         Map<String,seedWebserviceWrapper> mapOrderNoToSeed = new Map<String,seedWebserviceWrapper>{};
         List<String> lstOrderNo =new List<String>{};
         try {
             // Make the callout to the service
             HTTPResponse httpResp = new HTTPResponse();
             
             
             
             httpResp = Core_WebServiceUtility.restServiceCallout('', 
                                                                  'callout:SalesCRM_Apigee' +  System.Label.Core_SeedsURLOpp +sOppId+'/ALL', 'Get', System.Label.Core_TimeOut,
                                                                  System.Label.Core_SeedsWebservice); 
                
             
             
             // Display an error message if we're not getting an OK response
             if (httpResp.getStatusCode() != 200) {
                 SeedSampleWrapData.bSeedsErrorFlag = true;
                 SeedSampleWrapData.bSeedsErrorMessage=System.Label.Core_Exception;
             }
                          
             // Use the parser to get the response as JSONParser type
             system.JSONParser parser = JSON.createParser(httpResp.getbody()); 
             
             while (parser.nextToken() != NULL) {
                 // Start at the array of Records.
                 if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                     while (parser.nextToken() != NULL) {
                         // Advance to the start object marker to find the next seed object
                         if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                             // Read entire seed object, including its array of line items
                            
                             seedWebserviceWrapper seed  = (seedWebserviceWrapper) parser.readValueAs(seedWebserviceWrapper.class);
                             
                             // Add the record to the list of Apex Objects
                             lstSeeds.add(seed);
                             parser.skipChildren();
                         }
                     }
                 }
             }
                                                
             // If the list of the Apex Object records to be rendered isn't empty, pull the opportunity & account IDs in them
             if (!lstSeeds.isEmpty()) {
                 for (seedWebserviceWrapper seed : lstSeeds) {
                     lstOppID.add(seed.OpportunityID);
                     lstAcctID.add(seed.AccountID);

                 }                
                 if (!lstOppID.isEmpty()) {
                     for(Opportunity sObjOpp : [select Id, Name from Opportunity where Id in :lstOppID]) {
                         mapOppNametoID.put(sObjOpp.ID, sObjOpp.Name);
                     }
                 }
                 //As part of TWC3123-6731 checking Account id & cim id both
				if (!lstAcctID.isEmpty()) {
                        for(Account sObjAcct : [select Id,Core_CIM_ID__c, Name from Account where Id in :lstAcctID or(Core_CIM_ID__c in :lstAcctID and Core_CIM_ID__c != null)]){
                            if(sObjAcct.Id != null){
                            mapAcctNametoID.put(sObjAcct.Id, sObjAcct.Name);    
                            }if(sObjAcct.Core_CIM_ID__c != null){
   							mapAcctNametoID.put(sObjAcct.Core_CIM_ID__c, sObjAcct.Name);
                            }else if (sObjAcct.Core_CIM_ID__c != null) {
            				mapAcctNametoID.put(sObjAcct.Core_CIM_ID__c, sObjAcct.Name);
       						}
                        }
                    }   
             }
             
             // Convert the format of the Date from external source format to the salesforce format,
             // fetch opportunity & account names, map order numbers, and ensure the rendering flag is set
             for (seedWebserviceWrapper seed: lstSeeds) {
                 Date dt;
                 if (seed.RequestedDeliveryDate != NULL) {
                     dt = Date.Valueof(seed.RequestedDeliveryDate);
                     seed.RequestedDeliveryDate = dt.format();
                 }
                 if (seed.EstimatedShipDate != NULL && seed.EstimatedShipDate != '') {
                  
                     dt = Date.Valueof(seed.EstimatedShipDate);
                     seed.EstimatedShipDate = dt.format();
                 }
                 if (seed.ReturnPickupDate != NULL) {
                     dt = Date.Valueof(seed.ReturnPickupDate);
                     seed.ReturnPickupDate = dt.format();
                 }
                 
                 if(mapOppNametoID.containsKey(seed.OpportunityID))
                     seed.OpportunityName = mapOppNametoID.get(seed.OpportunityID);
                 if(mapAcctNametoID.containsKey(seed.AccountID))
                     seed.AccountName = mapAcctNametoID.get(seed.AccountID);
                 
                 lstOrderNo.add(seed.OrderNumber + seed.productname);
                 mapOrderNoToSeed.put(seed.OrderNumber + seed.productname, seed);
                 seed.hideBool=false;
                 seed.chevronChange='utility:chevronright';
                 
             }
             
             // Sort the list by the descending order
             lstSeeds = new list < seedWebserviceWrapper > {};
                 for(Integer iRow = lstOrderNo.Size()-1; iRow>=0; iRow--) {
                     lstSeeds.add(mapOrderNoToSeed.get(lstOrderNo[iRow]));
                 }
            
             // If the list of the seeds to be rendered is empty, display an error message
             if (lstSeeds.isEmpty()) {
                 SeedSampleWrapData.SeedsDataEmpty=true;
                   
             }
             
         }
        catch(Exception e){
           
            SeedSampleWrapData.bSeedsErrorFlag = true;
            SeedSampleWrapData.bSeedsErrorMessage=System.Label.Core_Exception +e.getMessage();
        }
            
        lstFilteredSeeds.addAll(lstSeeds);
        
            
       //********************PULL SAMPLES**************************
        
   
        Set<String> setOppID = new Set<String>{};
            Set<String> setAcctCIMID = new Set<String>{};
                lstFilteredSamples=new List<SampleWebserviceWrapper>();
        Map<String,String> mapOppIDtoName = new Map<String,String>{};
            Map<String,String> mapOppIDtoStage = new Map<String,String>{};
                Map<String,String> mapAcctCIMIDtoID = new Map<String,String>{};
                    Map<String,String> mapAcctCIMIDtoName = new Map<String,String>{};
                        Map<String,Integer> mapRequestIDLineToApprovedQty = new Map<String,Integer>();
        
        try {
            // Make the callout to the service
            HTTPResponse httpResp2 = new HTTPResponse();
            If(Boolean.valueOf(Label.Core_CRM_MySamples_Call_Basic))
            {
                httpResp2 = Core_WebServiceUtility.ServiceCallout('', mapStringToCS.get('My Samples Service').Core_End_Point_URL__c +
                                                                  '/opportunity/' + sOppId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');  
            }
            else
            {
                httpResp2 = Core_WebServiceUtility.restServiceCallout('', 'callout:SalesCRM_Apigee' +
                                                                      '/opportunity/' + sOppId, 'Get', System.Label.Core_TimeOut, 'My Samples Service');  
                
            }  
            
            // Display an error message if we're not getting an OK response
            if (httpResp2.getStatusCode() != 200) {
                SeedSampleWrapData.bSamplesErrorFlag = true;
                SeedSampleWrapData.bSamplesErrorMessage = System.Label.Core_Exception;
            }
            
           
            
            // Use the parser to get the response as JSONParser type
            system.JSONParser parser = JSON.createParser(httpResp2.getbody());
            
            while (parser.nextToken() != NULL) {
                // Start at the array of Records.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != NULL) {
                        // Advance to the start object marker to find the next sample object
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire object
                            
                            SampleWebserviceWrapper sample  = (SampleWebserviceWrapper) parser.readValueAs(SampleWebserviceWrapper.class);
                            
                            // Add the record to the list of Apex Objects
                            lstSamples.add(sample);
                            parser.skipChildren();
                        }
                    }
                }
            }
            
            // If the list of the samples records to be rendered isn't empty, pull the opportunity association data
            // (including account data) for each of them. Start by adding all oppty/acct IDs to sets, then pull names,
            // stages, etc. using those sets.
            if (!lstSamples.isEmpty()) {
                
                for (SampleWebserviceWrapper sample : lstSamples) {
                    sample.hideBool=false;
                    sample.chevronChange='utility:chevronright';
                    for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                        if ((oppAssoc.OpportunityID != null) && (oppAssoc.OpportunityID != ''))
                            setOppID.add(oppAssoc.OpportunityID);
                        if ((oppAssoc.AccountCIMID != null) && (oppAssoc.AccountCIMID != ''))
                            setAcctCIMID.add(oppAssoc.AccountCIMID);
                    }
                    
                    if ((sample.CustomerCIMID != null) && (sample.CustomerCIMID != '')) setAcctCIMID.add(sample.CustomerCIMID);
                    if ((sample.DefaultCIM    != null) && (sample.DefaultCIM    != '')) setAcctCIMID.add(sample.DefaultCIM);    // Remove this line later, once attribute name is fixed
                    if ((sample.DefaultCIMID  != null) && (sample.DefaultCIMID  != '')) setAcctCIMID.add(sample.DefaultCIMID);
                    
                    // For any approved requests, keep a running total of how many for that Request ID & Line have
                    // been approved, so we can use that to adjust requested numbers for non-approved lines later
                    if (sample.ApproverName != '') {
                        String key = sample.RequestID + sample.Line;
                        Integer approvedVal = 0;
                        if (mapRequestIDLineToApprovedQty.containsKey(key))
                            approvedVal = mapRequestIDLineToApprovedQty.get(key);
                        approvedVal += Integer.valueOf(sample.ApprovedQty);
                        mapRequestIDLineToApprovedQty.put(key, approvedVal);
                    }
                }
                
                if (!setOppID.isEmpty()) {
                    for(Opportunity opp : [select Id, Name, StageName from Opportunity where Id in :setOppID]) {
                        mapOppIDtoName.put(opp.ID, opp.Name);
                        mapOppIDtoStage.put(opp.ID, opp.StageName);
                    }
                }
                if (!setAcctCIMID.isEmpty()) {
                    // Get account info, regardless of covered/non-covered, but order it by: non-covered then covered, so we can just
                    // iterate through it and be assured that if there's multiple accounts with the same CIM ID, we overwrite non-covered
                    // account info with the covered account
                    /*if(SeedSampleWrapData.ucdSwitch == true){ //TWC4767-3431 - implementation of UCD and CIM logic switch
                        List<Account> accounts = [select Id, Core_Business_Party_Id__c, Name, Core_Covered_Account__c from Account
                                                  where Core_Business_Party_Id__c in :setAcctCIMID order by Core_Covered_Account__c, Core_Business_Party_Id__c];
                        
                        for (Account a : accounts) {
                            mapAcctCIMIDtoID.put(a.Core_Business_Party_Id__c, a.Id);
                            mapAcctCIMIDtoName.put(a.Core_Business_Party_Id__c, a.Name);
                        }
                    }
                    else { //TWC4767-3431 - implementation of UCD and CIM logic switch
                        List<Account> accounts = [select Id, Core_CIM_ID__c, Name, Core_Covered_Account__c from Account
                                                  where Core_CIM_ID__c in :setAcctCIMID order by Core_Covered_Account__c, Core_CIM_ID__c];
                        
                        for (Account a : accounts) {
                            mapAcctCIMIDtoID.put(a.Core_CIM_ID__c, a.Id);
                            mapAcctCIMIDtoName.put(a.Core_CIM_ID__c, a.Name);
                        }
                    }*/
                    //TWC4767-3983
                    List<Account> accounts = [select Id, Core_CIM_ID__c,Core_Business_Party_Id__c, Name, Core_Covered_Account__c,KCR_Global_Account_Name_Temp__c from Account
                                              where Core_CIM_ID__c in :setAcctCIMID or Core_Business_Party_Id__c in :setAcctCIMID 
                                              order by Core_Covered_Account__c, Core_CIM_ID__c];
                    
                    for (Account a : accounts) {
                        if(setAcctCIMID.contains(a.Core_CIM_ID__c)) {
                            mapAcctCIMIDtoID.put(a.Core_CIM_ID__c, a.Id);
                            mapAcctCIMIDtoName.put(a.Core_CIM_ID__c, a.Name);
                        }
                        else if(setAcctCIMID.contains(a.Core_Business_Party_Id__c)) {
                            mapAcctCIMIDtoID.put(a.Core_Business_Party_Id__c, a.Id);
                            mapAcctCIMIDtoName.put(a.Core_Business_Party_Id__c, a.Name);
                        }
                    }
                }
                
                // Loop back through all of the samples to set everything the way we want it displayed
                for (SampleWebserviceWrapper sample : lstSamples) {
                    
                    Set<String> acctNames = new Set<String>();
                    Set<String> oppNames = new Set<String>();
                    Set<String> oppStages = new Set<String>();
                    
                    // Account & opportunity data
                    for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                        oppAssoc.AccountId = mapAcctCIMIDtoID.get(oppAssoc.AccountCIMID);
                        oppAssoc.AccountName = mapAcctCIMIDtoName.get(oppAssoc.AccountCIMID);
                        oppAssoc.OpportunityName = mapOppIDtoName.get(oppAssoc.OpportunityID);
                        oppAssoc.OpportunityStage = mapOppIDtoStage.get(oppAssoc.OpportunityID);
                        
                        if (String.isNotBlank(oppAssoc.AccountName)) acctNames.add(oppAssoc.AccountName);
                        if (String.isNotBlank(oppAssoc.OpportunityName)) oppNames.add(oppAssoc.OpportunityName);
                        if (String.isNotBlank(oppAssoc.OpportunityStage)) oppStages.add(oppAssoc.OpportunityStage);
                    }
                    
                    // If we don't have account name via the opportunity association, see if we have it via one of the other fields
                    if (acctNames.size() == 0) {
                        if (sample.CustomerCIMID != '') acctNames.add(mapAcctCIMIDtoName.get(sample.CustomerCIMID));
                        else if (sample.DefaultCIM != '') acctNames.add(mapAcctCIMIDtoName.get(sample.DefaultCIM));  // Remove this line later, once attribute name is fixed
                        else if (sample.DefaultCIMID != '') acctNames.add(mapAcctCIMIDtoName.get(sample.DefaultCIMID));
                    }
                    
                    // Set the grid view display to one or "Multiple" depending on how many there are
                    if (acctNames.size() == 1)
                        sample.GridViewAccountName = new List<String>(acctNames)[0];
                    else if (acctNames.size() > 1)
                        sample.GridViewAccountName = 'Multiple';
                    
                    if (oppNames.size() == 1)
                        sample.GridViewOpportunityName = new List<String>(oppNames)[0];
                    else if (oppNames.size() > 1)
                        sample.GridViewOpportunityName = 'Multiple';
                    
                    if (oppStages.size() == 1)
                        sample.GridViewOpportunityStage = new List<String>(oppStages)[0];
                    else if (oppStages.size() > 1)
                        sample.GridViewOpportunityStage = 'Multiple';
                    
                    if (sample.Opportunity.size() >= 1) {
                        sample.DetailViewCIMIDs = '';
                        sample.DetailViewOppIDs = '';
                        for (SampleOpportunityAssociation oppAssoc : sample.Opportunity) {
                            if (String.isNotBlank(oppAssoc.AccountCIMID)) sample.DetailViewCIMIDs += oppAssoc.AccountCIMID + ', ';
                            if (String.isNotBlank(oppAssoc.OpportunityId)) sample.DetailViewOppIDs += oppAssoc.OpportunityId + ', ';
                        }
                        sample.DetailViewCIMIDs = sample.DetailViewCIMIDs.left(sample.DetailViewCIMIDs.length() - 2);
                        sample.DetailViewOppIDs = sample.DetailViewOppIDs.left(sample.DetailViewOppIDs.length() - 2);
                    }
                    else if (sample.CustomerCIMID != '') sample.DetailViewCIMIDs = sample.CustomerCIMID;
                    else if (sample.DefaultCIM != '') sample.DetailViewCIMIDs = sample.DefaultCIM;  // Remove this line later, once attribute name is fixed
                    else if (sample.DefaultCIMID != '') sample.DetailViewCIMIDs = sample.DefaultCIMID;
                    
                    // Adjust the numbers from the My Samples physical DB numbers to the user-friendly
                    // numbers that match the My Samples UI
                    if (sample.ApproverName == '') {
                        sample.ApprovedQty = '0';
                        String key = sample.RequestID + sample.Line;
                        if (mapRequestIDLineToApprovedQty.containsKey(key))
                            sample.RequestQty = (Integer.valueOf(sample.RequestQty) - mapRequestIDLineToApprovedQty.get(key)).format();
                    }
                    
                    // Convert the format of the Date from external source format to the salesforce format
                    if(sample.RDD != NULL) {
                        Date dt = Date.Valueof(sample.RDD);
                        sample.RDD = dt.format();
                    }
                }
            }
            // Sort the samples based on our implementation of the Comparable interface, which essentially sorts
            // in descending order of Request ID + Line ID + the ordering of Status we want within the same ID
            lstSamples.sort();
            
            // If the list of the samples to be rendered is empty, display an error
            if (lstSamples.isEmpty()) {
                SeedSampleWrapData.SamplesDataEmpty=true;
            }
        }
        catch (Exception e) {
            SeedSampleWrapData.bSamplesErrorFlag=true;
            SeedSampleWrapData.bSamplesErrorMessage=System.Label.Core_Exception +e.getMessage();
        }
      
        // Set the List of records to be shown on the VF page
        lstFilteredSamples.addAll(lstSamples);
        
        //Setting the Wrapper Variables to pass from Apex to LWC
        SeedSampleWrapData.SeedWrapper=lstFilteredSeeds;
        SeedSampleWrapData.SampleWrapper=lstFilteredSamples; 
        //}
        //}
        return SeedSampleWrapData;
    }
  
/*************************************************************************
* Method name  : filterSeeds
* Description  : Method to Filter Seeds
* Return Type  : List<SeedWebserviceWrapper>
* Parameter    : String[] sSeedSearch,List<seedWebserviceWrapper> lstSeeds
**************************************************************************/   
    @AuraEnabled
    public static List<SeedWebserviceWrapper> filterSeeds(String[] sSeedSearch,List<seedWebserviceWrapper> lstSeeds) {   
       
        List<SeedWebserviceWrapper> lstFilteredSeeds=new List<SeedWebserviceWrapper>();
        // If no search text has been entered, return the full original result set
        if (String.isEmpty(sSeedSearch[0]) && String.isEmpty(sSeedSearch[1]) && String.isEmpty(sSeedSearch[2]) && String.isEmpty(sSeedSearch[3]) 
            && String.isEmpty(sSeedSearch[4]) && String.isEmpty(sSeedSearch[5]) && String.isEmpty(sSeedSearch[6]) && String.isEmpty(sSeedSearch[7]) 
            && String.isEmpty(sSeedSearch[8])) {
                if(lstSeeds!=null){
                    lstFilteredSeeds.addAll(lstSeeds);
                }
            }
        else {
            // Otherwise iterate through the list and return only the samples containing the search text
            if(lstSeeds!=null){
                for (seedWebserviceWrapper seed : lstSeeds) {
                    if(seedMatchesFilters(seed,sSeedSearch)) {
                       
                        lstFilteredSeeds.add(seed);
                      
                        
                    }
                }
            }
        }
        return lstFilteredSeeds;
    }
    
    @AuraEnabled
    public static String getAiInferenceDynamicViewURL(){
        Core_System_Credentials__c sysCred = Core_System_Credentials__c.getValues('AI inference Dynamic View');
        String dynamicURL =  sysCred.Core_End_Point_URL__c;
        return dynamicURL;
    }
    
    @AuraEnabled
    public static Boolean seedMatchesFilters(seedWebserviceWrapper seed,String[] sSeedSearch) {
        if ((String.isEmpty(sSeedSearch[0])  || (String.isNotEmpty(sSeedSearch[0])  && seed.OrderNumber != NULL && String.ValueOf(seed.OrderNumber).containsIgnoreCase(sSeedSearch[0]))) &&
            (String.isEmpty(sSeedSearch[1]) || (String.isNotEmpty(sSeedSearch[1]) && seed.ProductName != NULL &&  String.ValueOf(seed.ProductName).containsIgnoreCase(sSeedSearch[1]))) &&
            (String.isEmpty(sSeedSearch[2]) || (String.isNotEmpty(sSeedSearch[2]) && seed.EstimatedShipDate != NULL && String.ValueOf(seed.EstimatedShipDate).containsIgnoreCase(sSeedSearch[2]))) &&
            (String.isEmpty(sSeedSearch[3]) || (String.isNotEmpty(sSeedSearch[3]) && seed.RequestedDeliveryDate != NULL && String.ValueOf(seed.RequestedDeliveryDate).containsIgnoreCase(sSeedSearch[3]))) &&
            (String.isEmpty(sSeedSearch[4]) || (String.isNotEmpty(sSeedSearch[4]) && seed.LineItemStatus != NULL && String.ValueOf(seed.LineItemStatus).containsIgnoreCase(sSeedSearch[4]))) &&
            (String.isEmpty(sSeedSearch[5]) || (String.isNotEmpty(sSeedSearch[5]) && seed.ReturnPickupDate != NULL && String.ValueOf(seed.ReturnPickupDate).containsIgnoreCase(sSeedSearch[5]))) &&
            (String.isEmpty(sSeedSearch[6]) || (String.isNotEmpty(sSeedSearch[6]) && seed.Requestor != NULL && String.ValueOf(seed.Requestor).containsIgnoreCase(sSeedSearch[6]))) &&
            (String.isEmpty(sSeedSearch[7]) || (String.isNotEmpty(sSeedSearch[7]) && seed.RequestedQty != NULL && String.ValueOf(seed.RequestedQty).containsIgnoreCase(sSeedSearch[7]))) &&
            (String.isEmpty(sSeedSearch[8]) || (String.isNotEmpty(sSeedSearch[8]) && seed.AccountName != NULL && seed.AccountName.containsIgnoreCase(sSeedSearch[8]))))
            return true;
        else
            return false;
    }
    
/******************************************************************************
* Method name  : filterSamples
* Description  : Method to Filter Samples
* Return Type  : List<SampleWebserviceWrapper>
* Parameter    : String[] sSampleSearch,List<SampleWebserviceWrapper> lstSamples
********************************************************************************/  
    @AuraEnabled
    public static List<SampleWebserviceWrapper> filterSamples(String[] sSampleSearch,List<SampleWebserviceWrapper> lstSamples) {   
        
        List<SampleWebserviceWrapper> lstFilteredSamples = new List<SampleWebserviceWrapper>();
        
        // If no search text has been entered, return the full original result set
        if (String.isEmpty(sSampleSearch[0]) && String.isEmpty(sSampleSearch[1]) && String.isEmpty(sSampleSearch[2]) && String.isEmpty(sSampleSearch[3]) &&
            String.isEmpty(sSampleSearch[4]) && String.isEmpty(sSampleSearch[5]) && String.isEmpty(sSampleSearch[6]) && String.isEmpty(sSampleSearch[7]) &&
            String.isEmpty(sSampleSearch[8]) && String.isEmpty(sSampleSearch[9]) && String.isEmpty(sSampleSearch[10]) && String.isEmpty(sSampleSearch[11])) {
                
                lstFilteredSamples.addAll(lstSamples);
            }
        else {
            // Otherwise iterate through the list and return only the samples containing the search text
            for (sampleWebserviceWrapper sample : lstSamples) {
                if(sampleMatchesFilters(sample,sSampleSearch)) {
                    lstFilteredSamples.add(sample);
                }
            }
        }
        return lstFilteredSamples;
    }
    
    @AuraEnabled
    public static Boolean sampleMatchesFilters(sampleWebserviceWrapper sample,String[] sSampleSearch) {
        if ((String.isEmpty(sSampleSearch[0])  || (String.isNotEmpty(sSampleSearch[0])  && sample.RequestID != NULL                && String.ValueOf(sample.RequestID).containsIgnoreCase(sSampleSearch[0]))) &&
            (String.isEmpty(sSampleSearch[1])  || (String.isNotEmpty(sSampleSearch[1])  && sample.Line != NULL                     && String.ValueOf(sample.Line).containsIgnoreCase(sSampleSearch[1]))) &&
            (String.isEmpty(sSampleSearch[2])  || (String.isNotEmpty(sSampleSearch[2])  && sample.RequestedEPMName != NULL         && String.ValueOf(sample.RequestedEPMName).containsIgnoreCase(sSampleSearch[2]))) &&
            (String.isEmpty(sSampleSearch[3])  || (String.isNotEmpty(sSampleSearch[3])  && sample.RDD != NULL                      && String.ValueOf(sample.RDD).containsIgnoreCase(sSampleSearch[3]))) &&
            (String.isEmpty(sSampleSearch[4])  || (String.isNotEmpty(sSampleSearch[4])  && sample.Status != NULL                   && String.ValueOf(sample.Status).containsIgnoreCase(sSampleSearch[4]))) &&
            (String.isEmpty(sSampleSearch[5])  || (String.isNotEmpty(sSampleSearch[5])  && sample.Requester != NULL                && String.ValueOf(sample.Requester).containsIgnoreCase(sSampleSearch[5]))) &&
            (String.isEmpty(sSampleSearch[6])  || (String.isNotEmpty(sSampleSearch[6])  && sample.RequestQty != NULL               && String.ValueOf(sample.RequestQty).containsIgnoreCase(sSampleSearch[6]))) &&
            (String.isEmpty(sSampleSearch[7])  || (String.isNotEmpty(sSampleSearch[7])  && sample.ApprovedQty != NULL              && String.ValueOf(sample.ApprovedQty).containsIgnoreCase(sSampleSearch[7]))) &&
            (String.isEmpty(sSampleSearch[8])  || (String.isNotEmpty(sSampleSearch[8])  && sample.GridViewAccountName != NULL      && String.ValueOf(sample.GridViewAccountName).containsIgnoreCase(sSampleSearch[8]))) &&
            (String.isEmpty(sSampleSearch[9])  || (String.isNotEmpty(sSampleSearch[9])  && sample.GridViewOpportunityName != NULL  && String.ValueOf(sample.GridViewOpportunityName).containsIgnoreCase(sSampleSearch[9]))) &&
            (String.isEmpty(sSampleSearch[10]) || (String.isNotEmpty(sSampleSearch[10]) && sample.GridViewOpportunityStage != NULL && String.ValueOf(sample.GridViewOpportunityStage).containsIgnoreCase(sSampleSearch[10]))) &&
            (String.isEmpty(sSampleSearch[11]) || (String.isNotEmpty(sSampleSearch[11]) && sample.ApproverName != NULL             && String.ValueOf(sample.ApproverName).containsIgnoreCase(sSampleSearch[11]))))
            return true;
        else
            return false;
    }
    
    // Wrapper Class/Apex Object to hold seeds JSON response
    public class SeedWebserviceWrapper {
        @AuraEnabled
        public String AccountID { get; set; }
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public String OpportunityID { get; set; }
        @AuraEnabled
        public String OpportunityName { get; set; }
        @AuraEnabled
        public Integer OrderNumber { get; set; }
        @AuraEnabled
        public String OrderStatus { get; set; }
        @AuraEnabled
        public String RequestedDeliveryDate { get; set; }
        @AuraEnabled
        public String ReturnPickupDate { get; set; }
        @AuraEnabled
        public String Requestor { get; set; }
        @AuraEnabled
        public String Submitter { get; set; }
        @AuraEnabled
        public String ProductCode { get; set; }
        @AuraEnabled
        public String LineItemStatus { get; set; }
        @AuraEnabled
        public String ProductName { get; set; }
        @AuraEnabled
        public String EstimatedShipDate { get; set; }
        @AuraEnabled
        public String ActualShipDate { get; set; }
        @AuraEnabled
        public Integer RequestedQty { get; set; }
        @AuraEnabled
        public Integer ShippedQty { get; set; }
        @AuraEnabled
        public String ProductDesc { get; set; }
        @AuraEnabled
        public String ProductListDesc { get; set; }
        @AuraEnabled
        public String CompanyName { get; set; }
        @AuraEnabled
        public String StreetAddress1 { get; set; }
        @AuraEnabled
        public String StreetAddress2 { get; set; }
        @AuraEnabled
        public String MailStop { get; set; }
        @AuraEnabled
        public String City { get; set; }
        @AuraEnabled
        public String State { get; set; }
        @AuraEnabled
        public String ZipCode { get; set; }
        @AuraEnabled
        public String Country { get; set; }
        @AuraEnabled
        public String AttentionName { get; set; }
        @AuraEnabled
        public String AttentionNumber { get; set; }
        @AuraEnabled
        public String Notes { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String Message { get; set; }
        @AuraEnabled
        public Boolean bRenderCSection { get; set; }
        @AuraEnabled
        public Boolean hideBool { get; set; }
        @AuraEnabled
        public String chevronChange { get; set; }
        
     
    }
    
    public class SampleOpportunityAssociation {
        @AuraEnabled
        public String AccountId;
        @AuraEnabled
        public String AccountName;
        @AuraEnabled
        public String AccountCIMID;
        @AuraEnabled
        public String OpportunityId;
        @AuraEnabled
        public String OpportunityName;
        @AuraEnabled
        public String OpportunityStage;
    }
    
    // Wrapper class to hold samples JSON response
    public class SampleWebserviceWrapper implements Comparable {
        @AuraEnabled
        public String RequestProductID { get; set; }
        @AuraEnabled
        public String RequestID { get; set; }
        @AuraEnabled
        public String RDD { get; set; }
        @AuraEnabled
        public String Line { get; set; }
        @AuraEnabled
        public String RequestedMM { get; set; }
        @AuraEnabled
        public String RequestedEPMName { get; set; }
        @AuraEnabled
        public String ApprovedMM { get; set; }
        @AuraEnabled
        public String ApprovedEPMName { get; set; }
        @AuraEnabled
        public String Requester { get; set; }
        @AuraEnabled
        public String RequestQty { get; set; }
        @AuraEnabled
        public String ApprovedQty { get; set; }
        @AuraEnabled
        public String OBO { get; set; }
        @AuraEnabled
        public String ApproverName { get; set; }
        @AuraEnabled
        public String ApproverEmail { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String Socket { get; set; }
        @AuraEnabled
        public String Media { get; set; }
        @AuraEnabled
        public String Stepping { get; set; }
        @AuraEnabled
        public String QDF { get; set; }
        @AuraEnabled
        public String BoxQuantity { get; set; }
        @AuraEnabled
        public String Contact { get; set; }
        @AuraEnabled
        public String CustomerName { get; set; }
        @AuraEnabled
        public String CustomerCMFID { get; set; }
        @AuraEnabled
        public String ShiptoCustomerName { get; set; }
        @AuraEnabled
        public String ShipToCustomerCMFID { get; set; }
        @AuraEnabled
        public String StreetAddress1 { get; set; }
        @AuraEnabled
        public String StreetAddress2 { get; set; }
        @AuraEnabled
        public String City { get; set; }
        @AuraEnabled
        public String StateName { get; set; }
        @AuraEnabled
        public String ZipCode { get; set; }
        @AuraEnabled
        public String Country { get; set; }
        @AuraEnabled
        public String ActualShipDtm { get; set; }
        @AuraEnabled
        public String TrackingIdForCarrier1Txt { get; set; }
        @AuraEnabled
        public String TrackingIdForCarrier2Txt { get; set; }
        @AuraEnabled
        public String CustomerCIMID { get; set; }
        @AuraEnabled
        public String DefaultCIM { get; set; }
        @AuraEnabled
        public String DefaultCIMID { get; set; }
        @AuraEnabled
        public List<SampleOpportunityAssociation> Opportunity { get; set; }
        @AuraEnabled
        public String GridViewAccountName { get; set; }
        @AuraEnabled
        public String GridViewOpportunityName { get; set; }
        @AuraEnabled
        public String GridViewOpportunityStage { get; set; }
        @AuraEnabled
        public String DetailViewCIMIDs { get; set; }
        @AuraEnabled
        public String DetailViewOppIDs { get; set; }
        @AuraEnabled
        public Boolean hideBool { get; set; }
        @AuraEnabled
        public String chevronChange { get; set; }
        
        //public String Message { get; set; }
        @AuraEnabled
        public Boolean bRenderCSection { get; set; }
        
        // When sorting, ensure they're sorted in descending order, by Request ID + Line + the ordering we want for Approval Status,
        // so when sorted in descending order, they would appear like: 438-100-Approved, 423-100-Approved, 423-100 Requested, 238-100 Approved.
        // Also, we need to zero-pad the numbers, so the sorting works regardless of number of digits.  And "Line" needs to be flipped, in
        // terms of sort order, so it goes 100, 200, 300 for a given Request ID, even though overall it's sorted in reverse order.
        public Integer compareTo(Object compareTo) {
            SampleWebserviceWrapper compareToSample = (SampleWebserviceWrapper) compareTo;
            
            String statusSortVal = '';
            if (Status == 'Requested') statusSortVal = 'A'; else if (Status == 'Approved') statusSortVal = 'ZZZZZZZZ';
            String sortString = pad(RequestID, 12, '0') + pad(String.valueOf(1000000-Integer.valueOf(Line)), 6, '0') + statusSortVal;
            
            if (compareToSample.Status == 'Requested') statusSortVal = 'A';
            else if (compareToSample.Status == 'Approved') statusSortVal = 'ZZZZZZZZ';
            String compareToSortString = pad(compareToSample.RequestID, 12, '0') +
                pad(String.valueOf(1000000-Integer.valueOf(compareToSample.Line)), 6, '0') + statusSortVal;
            
            Integer returnValue = 0;
            if (sortString < compareToSortString)
                returnValue = 1;
            else if (sortString > compareToSortString)
                returnValue = -1;
            return returnValue;
        }
        
        private String pad(String nonPaddedStr, Integer paddedLen, String padChar) {
            return padChar.repeat(paddedLen-nonPaddedStr.length()) + nonPaddedStr;
        }
    }
    
    public class SeedSampleWrap{
        @AuraEnabled
        public List<SeedWebserviceWrapper> SeedWrapper{get;set;}
        @AuraEnabled
        public List<SampleWebserviceWrapper> SampleWrapper{get;set;}
        @AuraEnabled
        public Boolean bSeedsErrorFlag { get; set; }
        @AuraEnabled
        public String bSeedsErrorMessage { get; set; }
        @AuraEnabled
        public Boolean bSamplesErrorFlag { get; set; }
        @AuraEnabled
        public String bSamplesErrorMessage { get; set; }
        @AuraEnabled
        public Boolean SeedsDataEmpty { get; set; }
        @AuraEnabled
        public Boolean SamplesDataEmpty { get; set; }
        @AuraEnabled
        public Boolean ucdSwitch {get; set;} //TWC4767-3431 - implementation of UCD and CIM logic switch     
    }
}