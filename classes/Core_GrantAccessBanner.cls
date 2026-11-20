/*********************************************************************************************************************************
Apex Class Name : Core_GrantAccessBanner
Created Date : April'2022
Function : Logic to display the required message on Grant Access Banner

Modification Log
Developer                       Date                     Description
*Shubham Khandelwal            April'2022          Added getBannerDetails method to fetch the active GA Banner records
*********************************************************************************************************************************/

public without sharing class Core_GrantAccessBanner {
    
    @AuraEnabled(cacheable=true)
    public static List<Core_GA_Banner__c> getBannerDetails() {
        Date d1 = System.today();

        List<Core_GA_Banner__c> bannerList = new List<Core_GA_Banner__c>();
        For(Core_GA_Banner__c ban : [SELECT Id, Name, Core_Message__c, Core_Start_Date__c, Core_End_Date__c from Core_GA_Banner__c Order by createdDate desc]){            
           
            If(ban.Core_End_Date__c >= d1 && d1 >= ban.Core_Start_Date__c ){
                bannerList.add(ban);
            }            
        }
        if(bannerList.size()>0){
            return bannerList;
        }
        else
            return null;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean checkContactGec(Id recordId){
        Boolean flag;
        List<Contact> contRec = [Select id, Name, Core_Contact_Export_Compliance_Block__c from Contact where Id=: recordId];
        
        For(Contact con : contRec){
        if(con.Core_Contact_Export_Compliance_Block__c == true){
            flag = true;
        }
        else{flag= false;}
        }
         return flag;   
    }
    
}