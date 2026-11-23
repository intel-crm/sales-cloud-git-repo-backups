/*****************************************************
Component Name    : Sales_UpdateAccountDetails
Created Date  : Jan 2022
Function      : <TWC3144-34> : DEV - Account text field is updated but license record still showing old one
Modification Log :
Developer                       Date                    Description
Dnyanada Argulwar             01/05/2022                 TWC3144-34
*****************************************************/
public without sharing class Sales_UpdateAccountDetails {
    public static final string ORIGIN = 'Sales_UpdateAccountDetails';
    public static final string PROJECT = 'PSG Sales';
    public static final string INFOSEVERITY = 'Info';
    public static void updateAccountDetails_License(List<Account> accountList){
        Set<String> accountName=new Set<String>();
        Set<id> accountId=new Set<Id>();
        for(Account acc:accountList){
            accountName.add(acc.Name);
            accountId.add(acc.Id);
        }
        System.enqueueJob(new Sales_UpdateAccountDetailsOnLicense(accountId,accountName)); 
    }
    public without sharing class Sales_UpdateAccountDetailsOnLicense implements System.Queueable{
        private set<Id> accountId;
        private Set<String> accountName;
        public Sales_UpdateAccountDetailsOnLicense(set<Id> accountId,Set<String> accountName){
            this.accountId=accountId;
            this.accountName=accountName;
        }
        public void execute(System.QueueableContext ctx){
    	    Sales_UpdateContactDetails.BypassTriggerForContactUpdate=true;
            Boolean successLicense;
            List<Sales_License__c> licenseList=[select id,Sales_License_Account__r.name,Sales_License_Account_Name_Txt__c,Sales_License_Account__c from Sales_License__c where Sales_License_Account__c=:accountId and (Sales_License_Account_Name_Txt__c not in :accountName) limit 9999 FOR UPDATE  ];
            if(licenseList.size()>0){
                try{
                    for (Sales_License__c lc : licenseList) {   
                        if(lc.Sales_License_Account_Name_Txt__c!=lc.Sales_License_Account__r.name){
                            lc.Sales_License_Account_Name_Txt__c=lc.Sales_License_Account__r.name;  
                        }
                    }
                    update licenseList;
                    System.enqueueJob(new Sales_UpdateAccountDetailsOnLicense(accountId,accountName)); 
                      successLicense=true;
                }
                catch (Exception e){
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateAccountDetails.ORIGIN, Sales_UpdateAccountDetails.PROJECT,'',Sales_UpdateAccountDetails.INFOSEVERITY,'','Error Occurred While Initialing the updation of account Details on license  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                    successLicense=false;
                }
            }
             if(successLicense==true ){                
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateAccountDetails.ORIGIN, Sales_UpdateAccountDetails.PROJECT,'',Sales_UpdateAccountDetails.INFOSEVERITY,'','Successfully Updated account Details on License for Account','','', '');    
             }
        }
    }
}