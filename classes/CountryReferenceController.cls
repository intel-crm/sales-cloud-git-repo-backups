/*********************************************************************************************************************
Apex Class Name  : CountryReferenceController
Author And Date  : Rohit Podder, 5 MAY 2026
Function         : This class is responsible for retrieving country-specific regional information and providing that data 
					to Lightning Web Components.
*********************************************************************************************************************/
public class CountryReferenceController {
    public static Boolean runningTest = False;
    @AuraEnabled
    public static Core_Country_Reference__c getCountryRegion(String isoCode) {
        try{
            if (runningTest) {
                throw new customException('Region has not returned successfully');
            }
            return [Select Core_Geo__c from Core_Country_Reference__c Where Core_ISO_Code__c =: isoCode];  
        }catch(Exception e){
            throw new AuraHandledException('Unable to fetch region data: ' + e.getMessage());            
        }
    }
    
    public class customException extends Exception{}
    
}