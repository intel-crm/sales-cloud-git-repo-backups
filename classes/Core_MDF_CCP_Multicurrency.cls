/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_Multicurrency 
* Version     : 1.0 
* Created Date: 10-17-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10-17-2018                    Created Core_MDF_CCP_Multicurrency to mimic the OOTB functionality of Multicurrency 
* NP(11630236)					05-05-2020					  Removed 180 days filter from the SOQL queries to allow Activites/Claims to be edited more than 6 months
* Labels used:
* 1. Label.Core_MDF_Multicurrency_APIKey  
* 2. Label.Core_MDF_Multicurrency_Retry_Batch_Delay
**************************************************************************************************************************************************************************************/

public without sharing class Core_MDF_CCP_Multicurrency {
    public static String logEntryMsg = '';
    public static Boolean isError = false; 
    public static Boolean retryIndicator = true;
    public static integer retryCount = 0;
    public static exception ex;
    
    
    /************************************************************************************************************************************************************************************
* Method Name : callHttp 
* Version     : 1.0 
* Created Date: 10-17-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10/17/2018                    Method calls the Multicurrency API which gets the currency codes from the Treasury system
* Intel - Narayani Perachi      12/26/2018                    Added If condition to return the number of records inserted/updated if the API call is successful else to return
*                                                             to return the Error message 
* Intel - Narayani Perachi      04/02/2019                    Handled Error messages from API and retry option in case of URL timeout upto three times
* Intel - NP                    03/06/2019                    Added logic to retrigger the batch after an hour incase it fails with Error or NULL response
**************************************************************************************************************************************************************************************/
    public static string callHttp()
    {
        integer valuesUpdated;
        string apiKey = Label.Core_MDF_Multicurrency_APIKey;
        HttpRequest req = new HttpRequest();
        //Getting the Sunday date of the week
        date datevalue = system.today().toStartOfWeek();
        //system.debug('datevalue' + datevalue);
        string dateToUrl = appendDigitsToInputValue(string.valueof(datevalue.year()),4) + appendDigitsToInputValue(string.valueOf(datevalue.month()),2) + appendDigitsToInputValue(string.valueOf(datevalue.day()),2);
        //string dateToUrl = '20190608';
        try
        {
            if(dateToUrl != null && dateToUrl != '')
            {
                req.setEndpoint('callout:Core_MDF_Multicurrency_URL?dates=' + dateToUrl);
                req.setMethod('GET');
                req.setHeader('API_Key', apiKey);
                system.debug('Req' + req);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                //system.debug('res.getBody()'+res.getBody());
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
            else {
                throw ex;
            }
        }
        catch(exception ex)
        {
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
            //system.debug('logEntryMsg' + logEntryMsg );
            
            if(retryIndicator && retryCount < 3 && !Test.isRunningTest())
            {
                callHttp();
                retryCount += 1;
            }
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Multicurrency URL Invocation');
        }        
        if(logEntryMsg == ''){
            string successMessage = string.valueOf(valuesUpdated) + ' records have been inserted/updated successfully for the current week from Multicurrency method.';
            return successMessage;
        }
        else{
            string errorMessage = 'Error from Multicurrency method:' + logEntryMsg; 
            system.debug('errorMessage' + errorMessage);
            return errorMessage; 
        }
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : parseJSONoutput 
* Version     : 1.0 
* Created Date: 10-17-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10/17/2018                    Parses the API response Json and stores it in the custom object Core_MDF_Currency_Exchange_Rates__c
* Intel - Narayani Perachi      12/26/2018                    Added variable to return the number of records updated
* Intel - Narayani Perachi      01/03/2019                    Made changes to store Year along with WW to field Core_MDF_Intel_WW__c
**************************************************************************************************************************************************************************************/
    
    public static integer parseJSONoutput(HTTPResponse input)
    {
        integer updatedValues; 
        List<currencyExchangeObj> currencyExList = new List<currencyExchangeObj>();
        List<Core_MDF_Currency_Exchange_Rates__c> currencyExInsertObjs = new List<Core_MDF_Currency_Exchange_Rates__c>();
        
        try{
            currencyExList= (List<currencyExchangeObj>)JSON.deserialize(input.getBody(), List<currencyExchangeObj>.class);
            //system.debug('currencyExList' + currencyExList);
            
            //Loop through the JSON and set values to Core_MDF_Currency_Exchange_Rates__c objects
            for(currencyExchangeObj rec:currencyExList)
            {
                if(rec!=Null)
                {
                    Core_MDF_Currency_Exchange_Rates__c newobj = new Core_MDF_Currency_Exchange_Rates__c();
                    newobj.Name = rec.weeklyCurrencyCode;
                    newobj.Core_MDF_Exchange_Rate__c = rec.weeklyRateDetails.setScale(10);
                    newobj.Core_MDF_Market_Date__c = setStringToDateFormat(rec.marketDate,'-');
                    string WWWithYear = calculateIntelWorkWeek(newobj.Core_MDF_Market_Date__c);
                    newobj.Core_MDF_Intel_WW__c = WWWithYear.substring(0, 4);
                    newobj.Core_MDF_Unique_Key__c = newobj.Name + WWWithYear;
                    currencyExInsertObjs.add(newobj);
                }
            }
            
            Schema.SObjectField externalID = Core_MDF_Currency_Exchange_Rates__c.Fields.Core_MDF_Unique_Key__c; 
            //Insert unique exchange values for Currency code for a given WW
            Database.UpsertResult [] saveResult = Database.upsert(currencyExInsertObjs,externalID,true); 
            updatedValues = currencyExInsertObjs.size();
            //system.debug('saveResult' + saveResult);           
        }
        
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Parsing the Multicurrency URL - parseJSONoutput()');
            //system.debug('logEntryMsg' + logEntryMsg +isError );
        }
        
        
        return updatedValues;
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : getUSDExchangeRateBasedOnDate 
* Version     : 1.0 
* Created Date: 10-17-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10-17-2018                    Converts any currency to USD based on the current excahnge date
* Intel - Narayani Perachi      12-05-2018                    Made changes to lessen the records returned from SOQL by using Core_MDF_Unique_Key__c and a Map
* Intel - Naraynai Perachi      01-03-2019                    Made changes to calculateIntelWorkWeek() to add Year along with WW for the unique keys
**************************************************************************************************************************************************************************************/    
    public static Map<string,getExchangeRateAndAmount> getUSDExchangeRateBasedOnDate(List<getExchangeRateAndAmount> inputList)
    {
        
        List<string> allInputUniqueKeys = new List<string>();       
        List<getExchangeRateAndAmount> outputList = new List<getExchangeRateAndAmount>();
        Map<string,Core_MDF_Currency_Exchange_Rates__c> exchangeMap = new Map<string,Core_MDF_Currency_Exchange_Rates__c>();
        Map<string,getExchangeRateAndAmount> outputMap = new Map<string,getExchangeRateAndAmount>();
        string inputUniqueKey;
        
        //system.debug('inputList' + inputList);
        
        try{
            //Loop through the Input list
            for(getExchangeRateAndAmount record: inputList)
            {
                //Creating a Unique key with combination of Input Currency, WW and Year
                if(record.inputCurrency != 'USD' && !allInputUniqueKeys.contains(record.inputCurrency))
                {
                    inputUniqueKey = record.inputCurrency + calculateIntelWorkWeek(record.inputDate);
                    allInputUniqueKeys.add(inputUniqueKey.trim());
                }
                //If USD, default the Conversion rate to 1
                else
                {
                    record.conversionRate = 1;
                    record.convertedAmount = record.inputAmount;
                    string key = string.valueof(record.inputAmount) + '\t' + record.inputCurrency + '\t' + string.valueof(record.inputDate);                     
                    outputMap.put(key,record);
                }
            }
            
            //system.debug('allInputUniqueKeys' + allInputUniqueKeys);
            
            //Query the Core_MDF_Currency_Exchange_Rates__c for all the excahnge rates of the input currency for last 180 days 
            if(allInputUniqueKeys.size()>0)
            {
                List<Core_MDF_Currency_Exchange_Rates__c> exchangeRates = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c 
                                                                           FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                           where Core_MDF_Unique_Key__c in :allInputUniqueKeys];
                //and Core_MDF_Market_Date__c= LAST_N_DAYS: 180
                
                //Create a map with the Excahnge rates
                for(Core_MDF_Currency_Exchange_Rates__c exchangeRecord:exchangeRates)
                {
                    exchangeMap.put(exchangeRecord.Core_MDF_Unique_Key__c,exchangeRecord);                      
                }
                
                //system.debug('exchangeMap' + exchangeMap);
                
                //Construct the output object
                for(getExchangeRateAndAmount output: inputList)
                {
                    
                    string inputListUniqueKey = output.inputCurrency + calculateIntelWorkWeek(output.inputDate);                        
                    Core_MDF_Currency_Exchange_Rates__c outputRecord = exchangeMap.get(inputListUniqueKey);
                    
                    if(outputRecord!= NULL)
                    {
                        output.conversionRate = outputRecord.Core_MDF_Exchange_Rate__c;
                        output.convertedAmount = (output.inputAmount * output.conversionRate).setScale(2);
                        
                    }
                    output.outputCurrency = 'USD';
                    string key = string.valueof(output.inputAmount) + '\t' + output.inputCurrency + '\t' + string.valueof(output.inputDate);                            
                    outputMap.put(key,output);                   
                }
                
            }
            
            //system.debug('outputMap'+ outputMap);
            
        }
        catch(exception ex){logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'USD Exchange rate - getUSDExchangeRateBasedOnDate()');}
        
        return outputMap;
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : getExchangeRateForAnyInputAndOutputCurrency 
* Version     : 1.0 
* Created Date: 10-23-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10-23-2018                    Converts any input currency to any desired output currency value
*                                                             This method contains exchange loss since we convert input currency to USD to output currency
*                               12-05-2018                    Made changes to lessen the records returned from SOQL by using Core_MDF_Unique_Key__c and a Map
**************************************************************************************************************************************************************************************/ 
    
    public static getExchangeRateAndAmount getExchangeRateForAnyInputAndOutputCurrency(date dateValue,string inputCurrency,decimal amountToBeConverted, string outputCurrency)
    {
        getExchangeRateAndAmount output = new getExchangeRateAndAmount();
        try{
            Map<string,Core_MDF_Currency_Exchange_Rates__c> inputExchangeMap = new Map<string,Core_MDF_Currency_Exchange_Rates__c>();
            Map<string,Core_MDF_Currency_Exchange_Rates__c> outputExchangeMap = new Map<string,Core_MDF_Currency_Exchange_Rates__c>();
            
            //Create key for Input and Output currency with combination of Input Currency, WW and Year
            String inputCurrencyKey = inputCurrency + calculateIntelWorkWeek(dateValue);
            String outputCurrencyKey = outputCurrency + calculateIntelWorkWeek(dateValue);
            
            //Query Core_MDF_Currency_Exchange_Rates__c for USD exchange rate of input currencies
            List<Core_MDF_Currency_Exchange_Rates__c> inputExchangeRateList = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c
                                                                               FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                               where Core_MDF_Unique_Key__c =:inputCurrencyKey];
            
            
            //Query Core_MDF_Currency_Exchange_Rates__c for USD exchange rate of output currencies
            List<Core_MDF_Currency_Exchange_Rates__c> outputExchangeRateList = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name, Core_MDF_Unique_Key__c 
                                                                                FROM Core_MDF_Currency_Exchange_Rates__c 
                                                                                where Core_MDF_Unique_Key__c =:outputCurrencyKey];
            
            //Create respective Maps for Input and Output currency with the Unique key as key
            for(Core_MDF_Currency_Exchange_Rates__c exchangeRecord:inputExchangeRateList){
                inputExchangeMap.put(exchangeRecord.Core_MDF_Unique_Key__c,exchangeRecord);                      
            }
            for(Core_MDF_Currency_Exchange_Rates__c exchangeRecord:outputExchangeRateList){
                outputExchangeMap.put(exchangeRecord.Core_MDF_Unique_Key__c,exchangeRecord);                      
            }
            
            //Get the exchange rate of the given input date for input currencies
            Core_MDF_Currency_Exchange_Rates__c inputRecord = inputExchangeMap.get(inputCurrencyKey);
            decimal inputExchangeRate = inputRecord.Core_MDF_Exchange_Rate__c;
            //system.debug('inputExchangeRate' + inputExchangeRate);
            
            //Get the exchange rate of the given input date for output currencies
            Core_MDF_Currency_Exchange_Rates__c outputRecord = outputExchangeMap.get(outputCurrencyKey);
            decimal outputExchangeRate = outputRecord.Core_MDF_Exchange_Rate__c;
            //system.debug('outputExchangeRate' + outputExchangeRate);
            
            if (amountToBeConverted != 0){
                //Formula to calculate Input currency -> USD -> Output currency
                output.convertedAmount = ((amountToBeConverted*inputExchangeRate)/outputExchangeRate).setScale(2);
            }
            
            else{
                output.convertedAmount = 0;
            }
            
            output.conversionRate = (inputExchangeRate/outputExchangeRate).setScale(10);
            output.inputAmount = amountToBeConverted;
            output.inputCurrency = inputCurrency;
            output.outputCurrency = outputCurrency;
            output.inputDate = dateValue;
            
        }
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Getting Exchange rate based on date - getExchangeRateBasedOnDate()');
        }
        return output;       
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : exchangeRateBasedOnDate 
* Version     : 1.0 
* Created Date: 10-26-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10-26-2018                    Fetches the excahnge rate from the custom object Core_MDF_Currency_Exchange_Rates__c based on the input date
*                               12-06-2018                    No longer using this method as we have incorporated this functionality in the respective methods
**************************************************************************************************************************************************************************************/    
    public static decimal exchangeRateBasedOnDate(List<Core_MDF_Currency_Exchange_Rates__c> inputList,string inputcurrency, date inputDate)
    {
        decimal dollarConversionRate;
        
        //system.debug('inputList' + inputList + 'inputDate' + inputDate);
        
        try{
            //Loops through the input list against the input date to find the exchange rate of the given date
            for(Core_MDF_Currency_Exchange_Rates__c rec: inputList)
            {
                if(rec.Core_MDF_Market_Date__c != NULL && rec.Core_MDF_Market_Date__c <= inputDate && rec.Core_MDF_End_Date__c > inputDate && rec.Name ==inputcurrency )
                {
                    dollarConversionRate = rec.Core_MDF_Exchange_Rate__c;
                    break;
                }
                
                //If the input date does not lie within the range of any of the exchange rates, it returns null                   
                else if(inputDate >= rec.Core_MDF_End_Date__c && rec.Name ==inputcurrency)
                {   
                    dollarConversionRate = null;
                }
            }
            //system.debug(dollarConversionRate);                          
        }
        
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Exchange Rate Based on Date - exchangeRateBasedOnDate()');
        }
        
        return dollarConversionRate;
    }
    
    /*Generic Classes*/
    
    /************************************************************************************************************************************************************************************
* Method Name : appendDigitsToInputValue
* Version     : 1.0 
* Created Date: 12-03-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      12-03-2018                    Append zeros preceding the input value based on the output length expected
**************************************************************************************************************************************************************************************/
    
    public static string appendDigitsToInputValue(string value, integer digit)   
    {
        try{
            while(value.length() < digit){
                value = '0' + value;               
            }  
        }
        catch(exception ex){logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Multicurrency- appendDigitsToInputValue()');} 
        return value;      
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : setStringToDateFormat 
* Version     : 1.0 
* Created Date: 10-17-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      10-17-2018                    Generic method to convert a String containing any date format to Salesforce Date format (YYYY-MM-DD)
**************************************************************************************************************************************************************************************/    
    
    public static Date setStringToDateFormat(String myDate,String separator) 
    {
        
        Date outputDate;
        try
        {
            String[] myDateOnly = myDate.split(' ');
            //Separates the date value based on the separater
            String[] strDate = myDateOnly[0].split(separator);
            Integer myIntDate = integer.valueOf(strDate[1]);
            Integer myIntMonth = integer.valueOf(strDate[0]);
            Integer myIntYear = integer.valueOf(strDate[2]);
            outputDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);           
        }
        
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Set string to Date Format - setStringToDateFormat()');
        }
        
        return outputDate; 
    }
    
    
    /************************************************************************************************************************************************************************************
* Method Name : calculateIntelWorkWeek 
* Version     : 1.0 
* Created Date: 11-12-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      11-12-2018                    Gives the Intel WW on which the input date lies
* Intel - Narayani Perachi      03-01-2019                    Appended the year to the Workweek 
**************************************************************************************************************************************************************************************/
    
    public static string calculateIntelWorkWeek(Datetime inputDate)
    {
        string workWeek;
        try
        {
            Datetime dt = inputDate.addHours(12);
            //system.debug('dt' + dt.formatGmt('YYYY'));
            Integer week = Integer.valueOf(dt.formatGmt('w'));
            workWeek = 'WW' + appendDigitsToInputValue(string.valueof(week),2) + dt.formatGmt('YYYY');
            //system.debug(workWeek);                     
        }
        
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Intel Work Week Calculation');
        }
        return workWeek;
    }
    
    /************************************************************************************************************************************************************************************
* Method Name : scheduleMulticurrencyRetryBatch 
* Version     : 1.0 
* Created Date: 3-6-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi      3/6/2019                      Schedules a Multicurreny Retry Batch after an hour
**************************************************************************************************************************************************************************************/
    
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
            //system.debug('dateVal' + dateVal);  
        }
        
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Multicurrency Retrigger Batch');
        }  
    }
    
    /************************************************************************************************************************************************************************************
* Wrapper Classes
* Version     : 1.0 
* Created Date: 10-17-2018
* Modified Date: 02-04-2018 Added errorHandling()
**************************************************************************************************************************************************************************************/
    
    public class currencyExchangeObj
    {
        public string weeklyCurrencyCode {get;set;}
        public decimal weeklyRateDetails {get;set;}
        public string marketDate {get;set;}       
    }
    
    public class getExchangeRateAndAmount
    {
        public decimal inputAmount{get;set;}
        public string inputCurrency{get;set;}
        public string outputCurrency{get;set;}
        public date inputDate{get;set;}
        public decimal conversionRate {get;set;}
        public decimal convertedAmount{get;set;}
    }
    
    public class errorHandling
    {
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
    }
    
}