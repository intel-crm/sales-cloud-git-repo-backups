/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_Multicurrency_Test 
* Version     : 1.0 
* Created Date: 12-05-2018
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Narayani Perachi 		12-05-2018					  Test class for all methods in Core_MDF_CCP_Multicurrency
**************************************************************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_CCP_Multicurrency_Test 
    {
        
       @isTest static void testCallHttp()
           {            
               Core_MDF_CCP_Multicurrency.errorHandling test = new Core_MDF_CCP_Multicurrency.errorHandling();
               Core_MDF_CCP_Multicurrency.callHttp();
           }
        
       @isTest static void testAppendDigitsToInputValue()
           {
              string result = Core_MDF_CCP_Multicurrency.appendDigitsToInputValue('1',4); 
              system.assertEquals('0001', result);
           }
        
       @isTest static void testParseJSONoutput()
           {
                HTTPResponse res1 = new HTTPResponse();
                HTTPResponse res2 = new HTTPResponse();
                HTTPResponse res3 = new HTTPResponse();
                res1.setBody('[{"WeeklyCurrencyCode": "ADP","WeeklyRateDetails": 0.0069092958,"MarketDate": "02-06-2019"},{"WeeklyCurrencyCode": "AED","WeeklyRateDetails": 0.2722570106,"MarketDate": "10-07-2018"}]');
                res2.setBody('[{""}]');
                res3.setBody('[{"WeeklyCurrencyCode": "ADP","WeeklyRateDetails": 0.0069092958,"MarketDate": "10072018"}]');
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res1);
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res2);
                Core_MDF_CCP_Multicurrency.parseJSONoutput(res3);
            }
        
       @isTest static void testGetUSDExchangeRateBasedOnDate()
           {
                
                 Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                 User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                 usr.profileId = sysAdminProfile.Id;
                 Database.insert(usr);
                
                 System.runAs(usr)
                    {
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount dObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount eObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
                        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
                        
                        aObj.inputCurrency ='ZMK';
                        aObj.inputAmount = 250.00;
                        aObj.inputDate= date.newInstance(2019, 06, 04);
                        bObj.inputCurrency ='INR';
                        bObj.inputAmount = 350.00;
                        bObj.inputDate= date.newInstance(1990, 11, 12);
                        cObj.inputCurrency ='USD';
                        cObj.inputAmount = 350.00;
                        cObj.inputDate= date.newInstance(2019, 06, 02);
                        dObj.inputCurrency = null;
                        dObj.inputAmount = 350.00;
                        dObj.inputDate= date.newInstance(2019, 06, 02);
                        eObj.inputCurrency = null;
                        eObj.inputAmount = null;
                        eObj.inputDate= null;
                        listvar.add(aObj);
                        listvar.add(bObj);
                        listvar.add(cObj);
                        listvar.add(dObj);
                        listvar.add(eObj);
                        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);  
                        system.assertEquals(0.0000850159000000, aObj.conversionRate);
                        system.assertEquals(null,bObj.conversionRate);
                        system.assertEquals(1,cObj.conversionRate);
                        system.assertEquals(null,dObj.conversionRate);                                               
                        //system.debug('listvar' + listvar);
                    }          
            }
        
       @isTest static void testGetExchangeRateForAnyInputAndOutputCurrency()
           {
                
                Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);
                
                System.runAs(usr)
                    {		
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount result1 = Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency(date.newInstance(2019,06,04),'ZMK', 7500.23, 'INR');    
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount result2 = Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency(date.newInstance(2019,06,02),'ZMK', 0, 'INR');
                        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount result3 = Core_MDF_CCP_Multicurrency.getExchangeRateForAnyInputAndOutputCurrency(date.newInstance(2019,06,02),'', 0, '');
                        system.debug('result1' + result1 + 'result2' + result2 + 'result3' + result3);
                        system.assertEquals(0.0062064838, result1.conversionRate);
                        system.assertEquals(0.0062064838, result2.conversionRate);
                        system.assertEquals(null, result3.conversionRate);
                        
                    }
            }
        
        @isTest static void testExchangeRateBasedOnDate()
            {	
                List<Core_MDF_Currency_Exchange_Rates__c> inputList1 = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name FROM Core_MDF_Currency_Exchange_Rates__c where Name = 'ZMK'];
                List<Core_MDF_Currency_Exchange_Rates__c> inputList2 = [SELECT Core_MDF_Exchange_Rate__c, Core_MDF_Market_Date__c, Core_MDF_End_Date__c, Name FROM Core_MDF_Currency_Exchange_Rates__c where Name = 'ABC'];
                
                decimal result1 = Core_MDF_CCP_Multicurrency.exchangeRateBasedOnDate(inputList1,'ZMK',date.newInstance(2019,06,06)); 
                decimal result2 = Core_MDF_CCP_Multicurrency.exchangeRateBasedOnDate(inputList1,'ZMK',date.newInstance(2019,08,04));
                decimal result3 = Core_MDF_CCP_Multicurrency.exchangeRateBasedOnDate(inputList2,'',date.newInstance(2019,06,06));
                decimal result4 = Core_MDF_CCP_Multicurrency.exchangeRateBasedOnDate(null,null,null);
                
                system.debug('result1' + result1 + 'result2' + result2 + 'result3' + result3);
                system.assertEquals(0.0000850159000000, result1);
                system.assertEquals(null, result2);
                system.assertEquals(null, result3);
                
            }
        @isTest static void testScheduleMulticurrencyRetryBatch(){
            Core_MDF_CCP_Multicurrency.scheduleMulticurrencyRetryBatch();
        }
        
        @TestSetup static void createTestData()
            {
                Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
                // Creating User with utility class 
                User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
                usr.profileId = sysAdminProfile.Id;
                Database.insert(usr);
                
                System.runAs(usr)
                    {
                        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
                        
                        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
                        record1.Name= 'ZMK';
                        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
                        record1.Core_MDF_Market_Date__c =date.newInstance(2019, 06, 02);
                        record1.Core_MDF_Intel_WW__c = 'WW23';
                        record1.Core_MDF_Unique_Key__c = 'ZMKWW232019';
                        newValues.add(record1);
                        
                        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
                        record2.Name= 'INR';
                        record2.Core_MDF_Exchange_Rate__c = 0.0136979171;
                        record2.Core_MDF_Market_Date__c =date.newInstance(2019, 06, 02);
                        record2.Core_MDF_Intel_WW__c = 'WW23';
                        record2.Core_MDF_Unique_Key__c = 'INRWW232019';
                        newValues.add(record2); 
                        
                        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
                        record3.Name= 'USD';
                        record3.Core_MDF_Exchange_Rate__c = 1;
                        record3.Core_MDF_Market_Date__c =date.newInstance(2019, 06, 02);
                        record3.Core_MDF_Intel_WW__c = 'WW23';
                        record3.Core_MDF_Unique_Key__c = 'USDWW232019';
                        newValues.add(record3); 
                                           
                        database.insert(newValues);
                    }
                
            }
        
    }