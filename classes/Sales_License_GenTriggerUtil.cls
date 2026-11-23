/***************************************************************************
Class Name    : Sales_License_GenTriggerUtil
Version       : 1.0
Created Date  : May 2021
Function      : Blocking to delete the license generator which are associated to License group

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           13-May-2021              Switch Trigger Handler Util
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_License_GenTriggerUtil {
    
    //Added by Ali : US871108 : To get the all license generator record associated to license group and block deletion
    /*public static Void blockLicenseGeneratorDeletion(List<Sales_License_Generator__c> generatorList){
        map<id,Sales_License_Generator__c> mapofLicenseGenidvsLicenseGen = new map<id,Sales_License_Generator__c>();
        list<Sales_License_Generator__c> relatedGeneratorList = new list<Sales_License_Generator__c>();
        if(generatorList.size()>0){ 
            //iterating on the list of license generator and adding to map
            for(Sales_License_Generator__c salesLicenseGen:generatorList){
                mapofLicenseGenidvsLicenseGen.put(salesLicenseGen.id,salesLicenseGen);
            }
            //getting the list of licenese group associated to license generator
            for(Sales_License_Group__c licenseGroup :[SELECT id,Sales_License_Generator__c FROM Sales_License_Group__c WHERE Sales_License_Generator__c =:mapofLicenseGenidvsLicenseGen.keySet()]){
                Sales_License_Generator__c relatedLicenseGen = mapofLicenseGenidvsLicenseGen.get(licenseGroup.Sales_License_Generator__c);
                relatedGeneratorList.add(relatedLicenseGen);
            }
            if(relatedGeneratorList.size()>0){
                //showing error of those licnese generator which are associated to license group
                for(Sales_License_Generator__c salesLicenseGenerator :relatedGeneratorList){
                    salesLicenseGenerator.addError('You cannot delete this Generator as it is associated to License group');
                }
                
            }
        }
        
        
    }*/
}