@isTest
public without sharing class Sales_RenewSeats_Chatbot {
/*
    public class LicenseInput {
        @InvocableVariable
        public String Sales_renewLicId;
        @InvocableVariable
        public Sales_ApplyRenewal_Chatbot.licensewrapper Sales_baseLicId;
        @InvocableVariable
        public String Sales_seatsToRenew;  
    }
    public class LicenseOutput {
        @InvocableVariable
        public Boolean isValidationMsg1;
        @InvocableVariable
        public Boolean isValidationMsg2;
        @InvocableVariable
        public Boolean isValidationMsg3;
        @InvocableVariable
        public Boolean isValidationMsg4;
        @InvocableVariable
        public Boolean applyFullRenewal;
    }
    @InvocableMethod(label='Seats To Renew Apex')
    public static List<LicenseOutput> getLicenseForRenewal(List<LicenseInput> inputs){
        //Set<Id> contactId = new Set<Id>();--Unused
        String renewLicIds;
        Id baseLicIds;
        Integer seatsToRenew;
        Boolean isValid;
        List<LicenseOutput> licenseOutputs = new List<LicenseOutput>();
        LicenseOutput licenseOutput = new LicenseOutput();
        List<Sales_License__c> baseLicList = new List<Sales_License__c>();
        for (LicenseInput lcInput : inputs) {
            seatsToRenew = Integer.valueof(lcInput.Sales_seatsToRenew);
            renewLicIds = lcInput.Sales_renewLicId;
            baseLicIds = lcInput.Sales_baseLicId.Id;
        }
        List<Sales_License__c> renewalLicList = [SELECT Id, Name, Sales_License_Avbl_Qty_Nbr__c,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c FROM Sales_License__c where Id=:renewLicIds ];
        if(renewalLicList.size()>0){
            for(Sales_License__c renewalLicItem : renewalLicList){
                if((seatsToRenew < renewalLicItem.Sales_License_Avbl_Qty_Nbr__c) && (renewalLicItem.Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'RENEWAL') && (renewalLicItem.Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!='ADD SEAT'))
                {  
                    licenseOutput.isValidationMsg4 = true;
                }
                else if(seatsToRenew > renewalLicItem.Sales_License_Avbl_Qty_Nbr__c){
                    licenseOutput.isValidationMsg1 = true;
                }
            }
        }
        baseLicList = [SELECT Id, Name, Sales_License_Quantity__c FROM Sales_License__c where Id=:baseLicIds];
        for(Sales_License__c lc : baseLicList){
            if(seatsToRenew == lc.Sales_License_Quantity__c){
                licenseOutput.applyFullRenewal = true;
            }
            else if(seatsToRenew > lc.Sales_License_Quantity__c){
                licenseOutput.isValidationMsg2 = true;
                licenseOutput.applyFullRenewal = false;
            }
            else if(seatsToRenew <= 0){
                licenseOutput.isValidationMsg3=true;
            }
        }
        licenseOutputs.add(licenseOutput);
        return licenseOutputs;
    }
*/
}