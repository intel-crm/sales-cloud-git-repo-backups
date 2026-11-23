/*********************************************************************************************************************
Class Name    : Sales_LicenseGenerationUtlity_Chatbot
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           May-2021				 CHATBOT 
* Shalini Kumari           May-2021              Delegate/Primary Admin Logic
* Pooja Jadhav             May-2021            	 Retrieve licensed Details	
* ************************************************************************************************************************************************/
public with sharing class Sales_LicenseGenerationUtlity_Chatbot {
    private static final string ORIGIN = 'Sales_LicenseGenerationUtlity_Chatbot';
    public class LicenseOutput {
        @InvocableVariable
        public Boolean isRenewalAddSeatMsg;
        @InvocableVariable
        public Boolean isValidationErrorMsg;
    }
    public class LicenseInput {
        @InvocableVariable
        public String Sales_Activation_Code;
        @InvocableVariable
        public Id Sales_ContactId;
    }
    @InvocableMethod(label='Fetch License Details')
    public static List<LicenseOutput> getLicenseDetails(List<LicenseInput> licenseInputs) {
        Id LoggedinuserContact;
        String activationCode;
        List<LicenseOutput> licenseOutputs = new List<LicenseOutput>();
        for (LicenseInput lcInput : licenseInputs) {
            LoggedinuserContact = lcInput.Sales_ContactId;
            activationCode = lcInput.Sales_Activation_Code;
        }
        LicenseOutput licenseOutput = new licenseOutput();
        List<Sales_License__c> licenseList = [SELECT Sales_License_Activation_Code__c from Sales_License__c WHERE Sales_License_Activation_Code__c=:activationCode];
        if(licenseList.isEmpty()){
            licenseOutput.isValidationErrorMsg = true;
        }
        List<Sales_GenLicByActivationCondeController.wrapperforActivationLicense> wrapperClass= Sales_GenLicByActivationCondeController.fetchLicenseDetails(activationCode);
        if(!wrapperClass.isEmpty()){
            if(wrapperClass[0].licType=='Add Seat' || wrapperClass[0].licType=='Renewal' || wrapperClass[0].productToolType=='ADD SEAT' || wrapperClass[0].productToolType=='RENEWAL'){
                licenseOutput.isRenewalAddSeatMsg = true;
            }
        }                              
        licenseOutputs.add(licenseOutput);
        return licenseOutputs; 
    }
    public static List<LicenseOutput> getComputerDetails (List<LicenseInput> licenseInputs, Map<String,Sales_License__c>licenseRecordMap){
        List<LicenseOutput> licenseOutputs = new List<LicenseOutput>();
        LicenseOutput licenseOutput = new LicenseOutput();
        for (LicenseInput licnseInput : licenseInputs) {
            if (licenseRecordMap.containsKey(licnseInput.Sales_Activation_Code)) {
            }
            licenseOutputs.add(licenseOutput);
        }
        return licenseOutputs;
    }
}