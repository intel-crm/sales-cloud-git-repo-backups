/*********************************************************************************************************************
Class Name    : Sales_RenewalLogic_Bot
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           May-2021         CHATBOT 
* ************************************************************************************************************************************************/
@isTest
public with sharing class Sales_RenewalLogic_Bot {
/*
    public class LicenseInput {
        @InvocableVariable
        public String noOfSeatsToRenew;
        @InvocableVariable
        public String renewalLic;
        @InvocableVariable
        public Sales_ApplyRenewal_Chatbot.licensewrapper baseLicObj;
        @InvocableVariable
        public String contactId;
    }
    public class LicenseOutput{
        @InvocableVariable
        public Boolean outputString;
        @InvocableVariable
        public Id licenseId;
        @InvocableVariable
        public String Computer_SalesforceId;  
    }
    @InvocableMethod(label='Renewal Logic')
    public static List<LicenseOutput> getRenewalLicense(List<LicenseInput> inputs){
        List<LicenseOutput> outputList = new List<LicenseOutput>();
        String pageURL = System.label.Sales_HostDetailUrl ;                
        String loggedIndContactId='';
        String contactforfile='';
        Set<id> licIdSet = new Set<id>();
        Id renewalLicId;Integer noOfSeats;
        for (LicenseInput lcInput : inputs) {
            licIdSet.add(lcInput.baseLicObj.id);
            renewalLicId = Id.valueof(lcInput.renewalLic);
            noOfSeats = Integer.valueof(lcInput.noOfSeatsToRenew);
            loggedIndContactId=lcInput.contactId;          
        }        
        Contact con=[Select id,Name,Email from Contact where id=:loggedIndContactId];
        contactforfile=','+con.Name+','+con.Email;
        List<Sales_License__c> licensesList = [SELECT Id,Sales_License_Primary_Admin_Contact__c from Sales_License__c WHERE Id IN : licIdSet];
        Sales_ApplyRenewalController.applyRenewals(licensesList, noOfSeats, renewalLicId,contactforfile);
        List<Sales_License_Order_Product__c> NewLicenseData = new List<Sales_License_Order_Product__c>();
        NewLicenseData= [SELECT Id, Sales_License__c,Sales_Renewable_license__c,Sales_Renewable_license__r.Name from 
                         Sales_License_Order_Product__c where Sales_Renewable_license__c=:renewalLicId order by CreatedDate desc LIMIT 1];
        Id newlicenseId=null;
        if(!NewLicenseData.isEmpty())
            newlicenseId = NewLicenseData[0].Sales_License__c;
        LicenseOutput ot = new LicenseOutput();
        ot.outputString = true;
        if(newlicenseId!=null){
            ot.licenseId = newlicenseId;
            Id hostRecordId = [SELECT Id,Sales_License_Host_Node_Id__c from Sales_License__c where Id=:newlicenseId Limit 1].Sales_License_Host_Node_Id__c;
            ot.Computer_SalesforceId = pageURL + hostRecordId;
        }
        outputList.add(ot);
        return outputList;
    }   
*/    
}