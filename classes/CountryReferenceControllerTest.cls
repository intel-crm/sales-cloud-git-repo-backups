/*********************************************************************************************************************
Apex Class Name  : CountryReferenceControllerTest
Author And Date  : Rohit Podder, 11 MAY 2026
Function         : Test class to cover CountryReferenceController
*********************************************************************************************************************/
@isTest
private class CountryReferenceControllerTest {
    
    @testSetup
    static void createCustomdata(){
        Core_Country_Reference__c cr = new Core_Country_Reference__c();
        cr.Name = 'India';
        cr.Core_Geo__c = 'APJ';
        cr.Core_Has_States__c = True;
        cr.Core_ISO_Code__c = 'IND';
        cr.Core_Sub_Geo__c = 'INDIA';
        
        INSERT cr;
    }
    
    @isTest
    static void positiveTestCountryRegion(){
        Assert.areEqual(CountryReferenceController.getCountryRegion('IND').Core_Geo__c, 'APJ', 'Region has not been returened as expected');     
    }
    
    @isTest
    static void negativeTestCountryRegion(){
        CountryReferenceController.runningTest = True;
        try{
            CountryReferenceController.getCountryRegion('IND');
        }catch(Exception e){
            Assert.areEqual(e.getMessage(), 'Script-thrown exception');
        }
    }
}