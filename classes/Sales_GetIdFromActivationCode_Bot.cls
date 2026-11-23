@isTest
public with sharing class Sales_GetIdFromActivationCode_Bot {
    
    /*public class LicenseOutput {
        @InvocableVariable
        public Id licenseId;
        @InvocableVariable
        public String computerName;
        @InvocableVariable
        public String Sales_ProductName;
        @InvocableVariable
        public String SalesMaintainenceExpDate;
        @InvocableVariable
        public String Sales_LicenseExpirationDate;
        @InvocableVariable
        public String licenseType;
    }
    
    public class LicenseInput {
        @InvocableVariable
        public Sales_ShowRenewalLicense_Bot.licensewrapper licenseObject;
        @InvocableVariable
        public Sales_GetComputerDetails.wrapperClass licenseObjectUnlicensed;
    }    
    
    @InvocableMethod(label='Get License Id from Code')
    public static List<LicenseOutput> getLicenseId(List<LicenseInput> input){
        List<LicenseOutput> outputList = new List<LicenseOutput>();
        LicenseOutput output = new LicenseOutput();
        Set<Id> licenseIds = new Set<Id>();
        for(LicenseInput lcinput : input){
            if(lcinput.licenseObject!=null){
                licenseIds.add(lcinput.licenseObject.Id);
            }else if(lcinput.licenseObjectUnlicensed!=null){
                licenseIds.add(lcinput.licenseObjectUnlicensed.Id);
            }
        }
        
        Map<Id, Sales_License__c> licenseRecordMap = new Map<Id, Sales_License__c>(); 
        //iterating license records and storing in map and adminId set
        for (Sales_License__c licItem : [SELECT Id,Name, Sales_License_Product__r.Name, Sales_License_Maintenance_Exp_Dt__c, Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c, Sales_License_Order__r.Sales_Order_Reason__c, 
                                         Sales_License_Primary_Admin_Contact__c, Sales_License_Web_Display_Flag__c, Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                         Sales_License_Expiration_Date_Dt__c, Sales_License_Lic_User_Contact_ID__c, Sales_Tool_License_Type__c FROM Sales_License__c where Id IN:licenseIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'and Sales_Tool_License_Type__c!=null]){
                                             licenseRecordMap.put(licItem.Id, licItem);
                                         }
        
        for(LicenseInput lcinput : input){
            if(lcinput.licenseObject!=null){
                if (licenseRecordMap.containsKey(lcinput.licenseObject.Id)){
                    output.computerName = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
                    output.licenseId = lcinput.licenseObject.Id;
                    output.Sales_ProductName = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Product__r.Name;
                    output.Sales_LicenseExpirationDate= String.valueOf(licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Expiration_Date_Dt__c);
                    Date expirationDate = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_License_Maintenance_Exp_Dt__c;
                    output.SalesMaintainenceExpDate   = String.valueOf(expirationDate);
                    
                    String licType = licenseRecordMap.get(lcinput.licenseObject.Id).Sales_Tool_License_Type__c;
                    if(licType == 'FIXED'){
                        output.licenseType = 'FIXED';               //Fixed license records will have Host License Type as as Fixed
                    }else if( licType == 'FLOAT' ||licType == 'N-A' ){
                        output.licenseType = 'FLOAT';               // Non fixed license records will have Host License Type as as Float
                    }else if( licType == 'NEUTRAL'){//added curly braces as part of static code scan fix
                        output.licenseType = 'NEUTRAL';
                    }if(output.Sales_ProductName ==null){output.Sales_ProductName = ' ';
                                                       }
                    if(output.SalesMaintainenceExpDate ==null){ output.SalesMaintainenceExpDate = ' ';
                                                               
                                                              }if(output.Sales_LicenseExpirationDate ==null){output.Sales_LicenseExpirationDate = ' ';
                                                                                                            }
                    outputList.add(output);
                }
            }else if(lcinput.licenseObjectUnlicensed!=null && licenseRecordMap.containsKey(lcinput.licenseObjectUnlicensed.Id)){
                //nested if condition combined as part static code scan fix
               // if (licenseRecordMap.containsKey(lcinput.licenseObjectUnlicensed.Id)){
                    output.computerName = licenseRecordMap.get(lcinput.licenseObjectUnlicensed.Id).Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
                    output.licenseId = lcinput.licenseObjectUnlicensed.Id;
                    output.Sales_ProductName = licenseRecordMap.get(lcinput.licenseObjectUnlicensed.Id).Sales_License_Product__r.Name;
                    output.Sales_LicenseExpirationDate= String.valueOf(licenseRecordMap.get(lcinput.licenseObjectUnlicensed.Id).Sales_License_Expiration_Date_Dt__c);
                    Date expirationDate = licenseRecordMap.get(lcinput.licenseObjectUnlicensed.Id).Sales_License_Maintenance_Exp_Dt__c;
                    output.SalesMaintainenceExpDate   = String.valueOf(expirationDate);
                    
                    String licType = licenseRecordMap.get(lcinput.licenseObjectUnlicensed.Id).Sales_Tool_License_Type__c;
                    if(licType == 'FIXED'){
                        output.licenseType = 'FIXED';               //Fixed license records will have Host License Type as as Fixed
                    }else if( licType == 'FLOAT' || licType == 'N-A' ){output.licenseType = 'FLOAT';                // Non fixed license records will have Host License Type as as Float
                                                                                              }
                    else if( licType == 'NEUTRAL'){//added curly braces as part of static code scan fix
                        output.licenseType = 'NEUTRAL';
                    }    
                    if(output.Sales_ProductName ==null){output.Sales_ProductName = ' ';
                                                       }
                    if(output.SalesMaintainenceExpDate ==null){ output.SalesMaintainenceExpDate = ' ';
                                                               
                                                              }if(output.Sales_LicenseExpirationDate ==null){output.Sales_LicenseExpirationDate = ' ';
                                                                                                            }
                    outputList.add(output);
              //  }
            }
        }
        return outputList; 
    }*/
}