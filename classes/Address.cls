/*********************************************************************************************************************
Apex Class Name  : Address
Version          : 1.0
Created Date     : FEB 2020
Function         : Wrapper class for Address to hold for request and response 

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Prasant Sahu               03/02/2020             Test class for Address

*********************************************************************************************************************/

global class Address{
        public String AddressLine2;
        public String CountryCode2;
        public String PostalCode;
        public String StateCode2;
        public String AddressLine1;
    	public String City;
        public Address(String inputStreet, String inputStreet2, String inputCity, String inputCountryCode, String inputState, String inputPostalCode){
            AddressLine2 = inputStreet2;
            CountryCode2 = inputCountryCode;
            PostalCode = inputPostalCode;
            StateCode2 = inputState;
            AddressLine1 = inputStreet;
            City = inputCity;
        }
}