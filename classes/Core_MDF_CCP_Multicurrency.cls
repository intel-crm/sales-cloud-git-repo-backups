public without sharing class Core_MDF_CCP_Multicurrency {
    public static String logEntryMsg = '';
    public static Boolean isError = false; 
    public static Boolean retryIndicator = true;
    public static integer retryCount = 0;
    public static exception ex;

    public static string callHttp()
    {
        integer valuesUpdated;
        string apiKey = Label.Core_MDF_Multicurrency_APIKey;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        //Getting the Sunday date of the week
        date datevalue = system.today().toStartOfWeek();
        string dateToUrl = appendDigitsToInputValue(string.valueof(datevalue.year()),4) + appendDigitsToInputValue(string.valueOf(datevalue.month()),2) + appendDigitsToInputValue(string.valueOf(datevalue.day()),2);
        //string dateToUrl = '20190608';
        try
        {
            if(dateToUrl != null && dateToUrl != '')
            {
                if(System.Label.Core_MDF_Apigee_Enabled == 'true'){
                    req.setEndpoint('callout:APIJEE_Multicurrency_URL?dates=' + dateToUrl);
                }
                else{
                    req.setEndpoint('callout:Core_MDF_Multicurrency_URL?dates=' + dateToUrl);
                    req.setHeader('API_Key', apiKey);
                }
                
                req.setMethod('GET');
                HTTPResponse res = http.send(req);
                if(res.getBody().contains('Error') || res.getBody() == NULL){                          
                    errorHandling error= (errorHandling)JSON.deserialize(res.getBody(), errorHandling.class);
                    logEntryMsg += error.errorMessage;
                    isError = true;
                    scheduleMulticurrencyRetryBatch();                    
                }
                else{
                    retryIndicator = false;
                    valuesUpdated = parseJSONoutput(res);  
                }                           
            }
            else {throw ex;}
        }
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
           
            
            if(retryIndicator && retryCount < 3 && !Test.isRunningTest()){
                callHttp();
                retryCount += 1;
            }
            Core_MDF_CCP_UtilityClass.logError(ex);
        }        
        if(logEntryMsg == ''){
            string successMessage = string.valueOf(valuesUpdated) + ' records have been inserted/updated successfully for the current week from Multicurrency method.';
            return successMessage;
        }
        else{
            string errorMessage = 'Error from Multicurrency method:' + logEntryMsg; 
            
            return errorMessage; 
        }
    }
       
    public static integer parseJSONoutput(HTTPResponse input){
        integer updatedValues; 
        List<currencyExchangeObj> currencyExList = new List<currencyExchangeObj>();
        List<Core_MDF_Currency_Exchange_Rates__c> currencyExInsertObjs = new List<Core_MDF_Currency_Exchange_Rates__c>();
        
        String marketDateValue;
        Map<String,Core_MDF_Currency_Exchange_Rates__c> mapOfCurrencyExchangeRate =  new Map<String,Core_MDF_Currency_Exchange_Rates__c>();
        try{
            currencyExList= (List<currencyExchangeObj>)JSON.deserialize(input.getBody(), List<currencyExchangeObj>.class);
            
            //Loop through the JSON and set values to Core_MDF_Currency_Exchange_Rates__c objects
            for(currencyExchangeObj rec:currencyExList)
            {
                if(rec!=Null)
                {
                    Core_MDF_Currency_Exchange_Rates__c newobj = new Core_MDF_Currency_Exchange_Rates__c();
                    newobj.Name = rec.weeklyCurrencyCode;
                    newobj.Core_MDF_Exchange_Rate__c = rec.weeklyRateDetails.setScale(10);
                    marketDateValue = rec.marketDate;
                    newobj.Core_MDF_Market_Date__c = setStringToDateFormat(rec.marketDate,'-');
                    string WWWithYear = calculateIntelWorkWeek(newobj.Core_MDF_Market_Date__c);
                    newobj.Core_MDF_Intel_WW__c = WWWithYear.substring(0, 4);
                    newobj.Core_MDF_Unique_Key__c = newobj.Name + WWWithYear;
                    
                    mapOfCurrencyExchangeRate.put(newobj.Core_MDF_Unique_Key__c,newobj);
                    //currencyExInsertObjs.add(newobj);
                }
            }
            
            if(!Core_MDF_Utility.byPassFeature('Bypass_USD_Currency_Insertion')){
                Core_MDF_Currency_Exchange_Rates__c newobjUSD = new Core_MDF_Currency_Exchange_Rates__c();
                newobjUSD.Name = 'USD';
                newobjUSD.Core_MDF_Exchange_Rate__c = 1;
                newobjUSD.Core_MDF_Market_Date__c = setStringToDateFormat(marketDateValue,'-');
                string WWWithYear = calculateIntelWorkWeek(newobjUSD.Core_MDF_Market_Date__c);
                newobjUSD.Core_MDF_Intel_WW__c = WWWithYear.substring(0, 4);
                newobjUSD.Core_MDF_Unique_Key__c = newobjUSD.Name + WWWithYear;
                mapOfCurrencyExchangeRate.put(newobjUSD.Core_MDF_Unique_Key__c,newobjUSD);
                //currencyExInsertObjs.add(newobjUSD);
            }
            

            Schema.SObjectField externalID = Core_MDF_Currency_Exchange_Rates__c.Fields.Core_MDF_Unique_Key__c; 
            //Insert unique exchange values for Currency code for a given WW
            if(mapOfCurrencyExchangeRate!=null && !mapOfCurrencyExchangeRate.isEmpty()){
                Database.UpsertResult [] saveResult = Database.upsert(mapOfCurrencyExchangeRate.values(),externalID,true); 
            }
            updatedValues = mapOfCurrencyExchangeRate.size();          
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return updatedValues;
    }


    
    public static Map<string,getExchangeRateAndAmount> getUSDExchangeRateBasedOnDate(List<getExchangeRateAndAmount> inputList){
        
        List<string> allInputUniqueKeys = new List<string>();       
        List<getExchangeRateAndAmount> outputList = new List<getExchangeRateAndAmount>();
        Map<string,Core_MDF_Currency_Exchange_Rates__c> exchangeMap = new Map<string,Core_MDF_Currency_Exchange_Rates__c>();
        Map<string,getExchangeRateAndAmount> outputMap = new Map<string,getExchangeRateAndAmount>();
        string inputUniqueKey;
        
        try{
            //Loop through the Input list
            for(getExchangeRateAndAmount record: inputList){
                //Creating a Unique key with combination of Input Currency, WW and Year
                if(record.inputCurrency != 'USD' && !allInputUniqueKeys.contains(record.inputCurrency)){
                    inputUniqueKey = record.inputCurrency + calculateIntelWorkWeek(record.inputDate);
                    allInputUniqueKeys.add(inputUniqueKey.trim());
                }
                //If USD, default the Conversion rate to 1
                else{
                    record.conversionRate = 1;
                    record.convertedAmount = record.inputAmount;
                    string key = string.valueof(record.inputAmount) + '\t' + record.inputCurrency + '\t' + string.valueof(record.inputDate);                     
                    outputMap.put(key,record);
                }
            }
            //Query the Core_MDF_Currency_Exchange_Rates__c for all the excahnge rates of the input currency for last 180 days 
            if(allInputUniqueKeys.size()>0){
                List<Core_MDF_Currency_Exchange_Rates__c> exchangeRates = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c 
                                                                           FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                           where Core_MDF_Unique_Key__c in :allInputUniqueKeys];
                //and Core_MDF_Market_Date__c= LAST_N_DAYS: 180
                
                //Create a map with the Excahnge rates
                for(Core_MDF_Currency_Exchange_Rates__c exchangeRecord:exchangeRates){
                    exchangeMap.put(exchangeRecord.Core_MDF_Unique_Key__c,exchangeRecord);                      
                }
                
                //Construct the output object
                for(getExchangeRateAndAmount output: inputList){
                    
                    string inputListUniqueKey = output.inputCurrency + calculateIntelWorkWeek(output.inputDate);                        
                    Core_MDF_Currency_Exchange_Rates__c outputRecord = exchangeMap.get(inputListUniqueKey);
                    
                    if(outputRecord!= NULL){
                        output.conversionRate = outputRecord.Core_MDF_Exchange_Rate__c;
                        output.convertedAmount = (output.inputAmount * output.conversionRate).setScale(2);
                        
                    }
                    output.outputCurrency = 'USD';
                    string key = string.valueof(output.inputAmount) + '\t' + output.inputCurrency + '\t' + string.valueof(output.inputDate);                            
                    outputMap.put(key,output);                   
                }
                
            } 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
       
        return outputMap;
    }

    public static Map<string,getExchangeRateAndAmount> getExchangeRateForAnyInputAndOutputCurrency(List<getExchangeRateAndAmount> inputList){

        List<string> allUniqueKeys = new List<string>();
        Map<string,decimal> uniqueKeyToConversionRateMap = new Map<String,Decimal>();
        Map<string,getExchangeRateAndAmount> outputList =  new Map<string,getExchangeRateAndAmount>();

        try{
            if(inputList !=null){
                for(getExchangeRateAndAmount record: inputList){
                    allUniqueKeys.add((record.inputCurrency + calculateIntelWorkWeek(record.inputDate)).trim());
                    allUniqueKeys.add((record.outputCurrency + calculateIntelWorkWeek(record.inputDate)).trim());
                }

                for(Core_MDF_Currency_Exchange_Rates__c exchangeRateRecord :[SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Unique_Key__c 
                                                                        FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                        where Core_MDF_Unique_Key__c in :allUniqueKeys]){
                                                                            uniqueKeyToConversionRateMap.put(exchangeRateRecord.Core_MDF_Unique_Key__c,exchangeRateRecord.Core_MDF_Exchange_Rate__c);
                                                                        }
            
                for(getExchangeRateAndAmount output:inputList){
                    output.conversionRate = (uniqueKeyToConversionRateMap.get((output.inputCurrency + calculateIntelWorkWeek(output.inputDate)).trim())/uniqueKeyToConversionRateMap.get((output.outputCurrency+ calculateIntelWorkWeek(output.inputDate)).trim())).setScale(10);
                    output.convertedAmount = (output.inputAmount * output.conversionRate).setScale(2);
                    output.outputCurrency = output.outputCurrency;
                    string key = string.valueof(output.inputAmount) + '\t' + output.inputCurrency + '\t' + string.valueof(output.inputDate) + '\t' + string.valueof(output.outputCurrency); 
                    outputList.put(key,output);
                }
            } 
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 

        return outputList;
    }
       
    /*Generic Classes*/
    //Append zeros preceding the input value based on the output length expected
    public static string appendDigitsToInputValue(string value, integer digit)   
    {
        try{
            while(value.length() < digit){value = '0' + value;}  
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return value;      
    }
    
    //Generic method to convert a String containing any date format to Salesforce Date format (YYYY-MM-DD)
    public static Date setStringToDateFormat(String myDate,String separator) 
    {
        
        Date outputDate;
        try{
            String[] myDateOnly = myDate.split(' ');
            //Separates the date value based on the separater
            String[] strDate = myDateOnly[0].split(separator);
            Integer myIntDate = integer.valueOf(strDate[1]);
            Integer myIntMonth = integer.valueOf(strDate[0]);
            Integer myIntYear = integer.valueOf(strDate[2]);
            outputDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);           
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
        return outputDate; 
    }
    
    //Gives the Intel WW on which the input date lies
    public static string calculateIntelWorkWeek(Datetime inputDate){
        string workWeek;
        try{
            Datetime dt = inputDate.addHours(12);
            Integer week = Integer.valueOf(dt.formatGmt('w'));
            workWeek = 'WW' + appendDigitsToInputValue(string.valueof(week),2) + dt.formatGmt('YYYY');
                              
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
        return workWeek;
    }
    
    //Schedules a Multicurreny Retry Batch after an hour
    public static void scheduleMulticurrencyRetryBatch(){
        
        try{            
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour() + integer.valueof(Label.Core_MDF_Multicurrency_Retry_Batch_Delay));
            String minute = string.valueOf(system.now().minute());
            String second = string.valueOf(system.now().second());
            String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
            Core_MDF_SchedulerClass_Multicurrency sch = new Core_MDF_SchedulerClass_Multicurrency();
            system.schedule('Multicurrency Batch Retrigger: ' + system.now(),strSchedule,sch); 
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }
      
    public class currencyExchangeObj{
        public string weeklyCurrencyCode {get;set;}
        public decimal weeklyRateDetails {get;set;}
        public string marketDate {get;set;}       
    }
    
    public class getExchangeRateAndAmount{
        public decimal inputAmount{get;set;}
        public string inputCurrency{get;set;}
        public string outputCurrency{get;set;}
        public date inputDate{get;set;}
        public decimal conversionRate {get;set;}
        public decimal convertedAmount{get;set;}
    }
    
    public class errorHandling{
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
    }
    
}