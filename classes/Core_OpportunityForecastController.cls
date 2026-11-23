/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityForecastController
Version     : 1.0 
Created Date: 10 Dec 2022
Function    : Opportunity Forecast Functionality
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             12/10/2022              Original Version
*****************************************************************************************************************************************************************************************************/
public without sharing class Core_OpportunityForecastController {
    
    Public Static Boolean isUpdate = false; 
    //TWC4767-462: Add Forecast Category LOV for "Cancel"
    public static List<string> excludedStatuses = new List<string>{'Cancel'};
        public static void createOppForecastAmount(List<Core_Opportunity_Forecast__c> oppForecastList) {
            
            Set<Id> oppId = new Set<Id>();
            List<String> foreQuarter  = new List<String>();
            Map<Id, Decimal> oppAmount  = new Map<Id, Decimal>();
            List<Core_Opportunity_Forecast__c> foreList = new List<Core_Opportunity_Forecast__c>();
            Date Today = system.Today();
            List<Opportunity> oppList = new List<Opportunity>();
            Map < String, Period > quarterData = new Map < String, Period > ();
            ID recordTypeId;
            ID recordTypeId_new;
            Date startDate;
            Date start7Date;
            Date endDate; 
            
            try {
                for(Core_Opportunity_Forecast__c fore:oppForecastList){
                    oppId.add(fore.Core_Opportunity__c);
                    foreQuarter.add(fore.Core_Forecast_Quarter__c);              
                } 
                if(oppId.size()>0) {
                    for (Period perd: [Select FiscalYearSettings.QuarterPrefix,Number,FiscalYearSettings.Name,startdate,EndDate  From Period Where type = 'Quarter' and Startdate >= 2022-12-01 order by startdate]) {
                        String quarter = perd.FiscalYearSettings.QuarterPrefix + ''+ perd.Number+' '+ perd.FiscalYearSettings.Name;
                        quarterData.put(quarter, perd);
                    }
                    //system.debug('quarterData: '+quarterData);Commented as a part of code scan : TWC3123-5398
                    //TWC4767-462: Add Forecast Category LOV for "Cancel"
                    foreList = [Select Id, Core_Opportunity__c, Core_Forecast__c, Core_Forecast_Quarter__c 
                                from Core_Opportunity_Forecast__c 
                                where Core_Forecast_Quarter__c =:foreQuarter 
                                AND Core_Opportunity__c =: oppId 
                                AND Core_Forecast__c NOT IN :excludedStatuses];
                    if(foreList.size()>0 && isUpdate == false){
                        for(Core_Opportunity_Forecast__c fore:oppForecastList){
                            fore.addError(Label.Core_Forecast_Validation);
                        }
                    }
                    Else {   
                        oppList = [Select Id,Amount,CloseDate from Opportunity where Id =:oppId];
                        recordTypeId = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_ReadOnly'].Id;
                        recordTypeId_new = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_OppForecastNew'].Id;
                        if(oppList.size()>0){
                            for(Opportunity opp :oppList){
                                oppAmount.put(opp.Id, opp.Amount); 
                            }
                            for(Core_Opportunity_Forecast__c updatefore:oppForecastList) {
                                startDate  = quarterData.get(updatefore.Core_Forecast_Quarter__c).startdate;
                                endDate    = quarterData.get(updatefore.Core_Forecast_Quarter__c).enddate;
                                start7Date = quarterData.get(updatefore.Core_Forecast_Quarter__c).startdate + integer.valueOf(Label.Opp_Forecast_Lock_Duration);
                                //TWC4767-462: Add Forecast Category LOV for "Cancel"
                                if(updatefore.Core_Forecast__c != 'Cancel'){
                                    updatefore.Core_Forecast_Amount__c = oppAmount.get(updatefore.Core_Opportunity__c);
                                }
                                updatefore.Core_Quarter_First_Weekend_Date__c = start7Date;
                                updatefore.Core_Quarter_Start_Date__c = startDate;
                                updatefore.Core_Quarter_End_Date__c = endDate;
                                if((foreQuarter.Contains(updatefore.Core_Forecast_Quarter__c) || Today > endDate)){
                                    if(Today > start7Date) {
                                      //  system.debug('Readonly' + start7Date);Commented as a part of code scan : TWC3123-5398
                                        updatefore.Core_Read_Only__c = True;
                                        updatefore.RecordTypeId = recordTypeId;  
                                    }
                                    else {   
                                        //system.debug('Not Readonly' + start7Date);Commented as a part of code scan : TWC3123-5398
                                        updatefore.Core_Read_Only__c = False;
                                        updatefore.RecordTypeId = recordTypeId_new;
                                    } 
                                } 
                            }
                        }
                    }               
                }
            }Catch(Exception ex) {System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
            
        }
    
    public static void uniqueOppForecastAmount(List<Core_Opportunity_Forecast__c> oppForecastList, map<Id,Core_Opportunity_Forecast__c> forMap) {
        List<String> foreQuarter  = new List<String>();
        Set<Id> oppId = new Set<Id>();
        List<Core_Opportunity_Forecast__c> foreList = new List<Core_Opportunity_Forecast__c>();
        
        try {
            for(Core_Opportunity_Forecast__c fore:oppForecastList) {
                if(fore.Core_Forecast_Quarter__c != forMap.get(fore.Id).Core_Forecast_Quarter__c || fore.Core_Forecast__c != forMap.get(fore.Id).Core_Forecast__c){
                    foreQuarter.add(fore.Core_Forecast_Quarter__c);
                    oppId.add(fore.Core_Opportunity__c);
                }                          
            }
            if(oppId.size()>0 && !forMap.isEmpty()) {
                //TWC4767-462: Add Forecast Category LOV for "Cancel"
                foreList = [Select Id, Core_Opportunity__c, Core_Forecast__c, Core_Forecast_Quarter__c from Core_Opportunity_Forecast__c 
                            where Core_Forecast_Quarter__c =:foreQuarter 
                            AND Core_Opportunity__c =: oppId 
                            AND Core_Forecast__c NOT IN :excludedStatuses 
                            AND Id NOT IN : forMap.KeySet()];
                for(Core_Opportunity_Forecast__c frids : oppForecastList) {
                    if(foreList.size()>0) { 
                        frids.addError(Label.Core_Forecast_Validation);
                    }
                    Else {
                        foreList.add(frids);
                        isUpdate = true;
                    }
                }
                if(isUpdate == true) {
                    createOppForecastAmount(foreList);
                }   
            }  
        }
        Catch(Exception ex) {System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}   
    } 
    
    public static void restrictDeleteOppForecast(List<Core_Opportunity_Forecast__c> oppForecastList) {
        try {
            String profileName = [Select Id,Name from Profile where Id =: userinfo.getProfileId()].Name;
            Set<String> allowedProfileSet = new Set<String>(Label.Core_Allowed_Profile_for_Opportunity_Change.split(';'));
            for(Core_Opportunity_Forecast__c oppFor:oppForecastList){
                if (!allowedProfileSet.contains(profileName) && oppFor.Core_Read_Only__c) {
                    oppFor.adderror(system.label.Core_Opportunity_Forecast_Restriction_Message);
                }
            }
        }Catch(Exception ex) {System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
    }
    
    //NP - Calculate the new forecast quarter values to be inserted
    public static List<string> calculateForecastQuarters(){
        string currentQ;
        List<string> forecastQuarters = new List<string>();
        integer quarterIncr = 3;
        integer forecastQtr;
        try{
            forecastQtr = integer.ValueOf(Core_CRM_Utility.getCRMLabel('Opportunity_Forecast_Quarters'));
            currentQ = determineQuarter(date.today()); 
            forecastQuarters.add(currentQ);
            for(integer i=0;i<forecastQtr;i++){
                string quarter = determineQuarter(date.today().addmonths(quarterIncr));
                //system.debug('date: '+date.today().addmonths(quarterIncr));Commented as a part of code scan : TWC3123-5398
                quarterIncr += 3;
                //system.debug('quarter: '+quarter);Commented as a part of code scan : TWC3123-5398
                forecastQuarters.add(quarter);
            }
           // system.debug(forecastQuarters);Commented as a part of code scan : TWC3123-5398
        }
        
        catch(Exception ex){System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
        
        return forecastQuarters;
    }
    
    //NP - Determine quarter
    public static string determineQuarter(Date input){
        string quarter;
        Map <String,Period> quarterData = new Map <String,Period> ();
        try{
            for (Period perd: [Select FiscalYearSettings.QuarterPrefix,Number,FiscalYearSettings.Name,Startdate,EndDate  From Period Where type = 'Quarter' and Startdate >= 2022-12-01 order by startdate]) {
                //String quarter = ;
                quarterData.put(perd.FiscalYearSettings.QuarterPrefix + ''+ perd.Number+' '+ perd.FiscalYearSettings.Name, perd);
            }
            for(string qtr:quarterData.keyset()){
                if(input >= quarterData.get(qtr).Startdate && input <= quarterData.get(qtr).EndDate){
                    quarter = qtr;
                    break;
                }
            }
           // system.debug('quarter: '+quarter);Commented as a part of code scan : TWC3123-5398
        }
        catch(Exception ex){System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
        return quarter;
    }
    
    //Create new forecast quarter records and add to New Record type
    public static void insertForecastQuarters(){
        List<string> forecastQuarters = new List<string>();
        PicklistManager.RecordTypeWrapperClass existingPLVals = new PicklistManager.RecordTypeWrapperClass();
        List<string> existingPLValues = new List<string>();
        Set<string> newPLValues = new Set<string>();
        PicklistManagerMetadataService.RecordType mdRecordTypes = new PicklistManagerMetadataService.RecordType();
        List<PicklistManagerMetadataService.RecordTypePicklistValue> picklistValues = new List<PicklistManagerMetadataService.RecordTypePicklistValue>();
        try{
            
            PicklistManagerMetadataService.MetadataPort service = PicklistManager.createService();
            
            forecastQuarters = calculateForecastQuarters();
            
            //Add new values if not there already
            if(forecastQuarters.size()>0){
                PicklistManager.PicklistWrapperClass input = new PicklistManager.PicklistWrapperClass();
                List<PicklistManager.PickListWrapper> vals = new List<PicklistManager.PickListWrapper>();
                for(string val:forecastQuarters){
                    PicklistManager.PickListWrapper ptval = new PicklistManager.PickListWrapper();
                    ptval.label = val;
                    ptval.value = val;
                    ptval.isActive = true;
                    ptval.isDefaultValue = false;
                    vals.add(ptval);
                }
                input.objectName = 'Core_Opportunity_Forecast__c';
                input.fieldAPIName = 'Core_Forecast_Quarter__c';
                input.fieldName = 'Forecast Quarter';
                input.sorted = false;
                input.picklistValues = vals;
                PicklistManager.createOrUpdatePLV(input,false);
            }
            List<PicklistManagerMetadataService.PicklistValue> pLVal = new List<PicklistManagerMetadataService.PicklistValue>();
            mdRecordTypes.label= 'New';
            mdRecordTypes.fullName= 'Core_Opportunity_Forecast__c.Core_OppForecastNew';
            mdRecordTypes.active = true;
            PicklistManagerMetadataService.RecordTypePicklistValue pV1 = new PicklistManagerMetadataService.RecordTypePicklistValue();
            pV1.picklist = 'Core_Forecast_Quarter__c';
            for(string quarter: forecastQuarters){                 
                PicklistManagerMetadataService.PicklistValue pvv1 = new PicklistManagerMetadataService.PicklistValue();
                pvv1.fullName=quarter;
                pvv1.default_x=false;
                pvv1.isActive = true;
                pLVal.add(pvv1);  
            } 
            pV1.values = pLVal;   
            picklistValues.add(pV1);
            mdRecordTypes.picklistValues = picklistValues; 
            //system.debug('mdRecordTypes: '+mdRecordTypes);Commented as a part of code scan : TWC3123-5398
            
            // Update the record type
            List<PicklistManagerMetadataService.SaveResult> results = service.updateRTMetadata(new PicklistManagerMetadataService.RecordType[] { mdRecordTypes });
            //system.debug('results: '+results);   Commented as a part of code scan : TWC3123-5398 
        }
        catch(Exception ex){System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
    }
    
    //NP - Check if today is start of quarter to populate new forecast quarter values
    public static void checkIfQtrStart(){
        Date qtrStartDate;
        String currentQuarter;
        Map <String,Period> quarterData = new Map <String,Period> ();
        integer extraDays;
        try{
            for (Period perd: [Select FiscalYearSettings.QuarterPrefix,Number,FiscalYearSettings.Name,Startdate,EndDate  From Period Where type = 'Quarter'  and Startdate >= 2022-12-01 order by Startdate]) {
                String quarter = perd.FiscalYearSettings.QuarterPrefix + ''+ perd.Number+' '+ perd.FiscalYearSettings.Name;
                quarterData.put(quarter, perd);
            }
            extraDays = integer.ValueOf(Core_CRM_Utility.getCRMLabel('Oppo_Forecast_Qtr_Extra_Days'));
            currentQuarter = Core_OpportunityForecastController.determineQuarter(System.today());
            qtrStartDate = quarterData.get(currentQuarter).Startdate;
            //date myDate = date.newInstance(2023, 3, 26);
            if(System.Today()==qtrStartDate || qtrStartDate.addDays(extraDays) > System.Today()){
                Core_OpportunityForecastController.insertForecastQuarters();
            }  
        }
        catch(Exception ex){System.debug('Exception::'+ex.getMessage() + ' '+ ex.getLineNumber());}
    }
    
}