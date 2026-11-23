/****************************************************************************************************
*Class Name:  Core_IPS_AdminUtility
*Description:  Utility Class for Admin Context
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------       
* Yogesh                      12/18/2017                  Modified - US72415
* Aayushi					 1/03/2019					  modified- US253172
****************************************************************************************************/

Public without sharing class Core_IPS_AdminUtility
{  
 
 //Added By Yogesh Sharma
 public  static void  DeleteEnvDetails(List<Core_IPS_Response__c> LstEnvironmentDetail)
 {
     delete LstEnvironmentDetail;
 } 
 
 public  static void  DeleteEnvDetails(List<Core_IPS_Environment_Details__c> LstEnvironmentDetail)
 {
     delete LstEnvironmentDetail;
 } 
 
 public static void insertLineItems(List<Core_IPS_Map_Par_Line_Item__c> lineItems){   insert lineItems;  }
 
 public static void insertProdAccessAccJOs(List<Core_IPS_MAP_Account__c> coreMapAccToInsert){
     insert coreMapAccToInsert;
 }
 
 public static void insertProdAccessProdJOs(List<Core_IPS_MAP_Product__c> coreMapPrdToInsert){
     insert coreMapPrdToInsert;
 }
 
 public static void insertGECList(List<Core_IPS_GEC_Details__c> GECList){
     insert GECList;     
 } 
 
 //Addded By Yogesh Sharma
 public static void insertEnvDetailsToCreate(List<Core_IPS_Response__c> insertEnvDetails){
     insert insertEnvDetails;     
 }
 
 public static void insertEnvDetailsToCreate(List<Core_IPS_Environment_Details__c> insertEnvDetails){
     insert insertEnvDetails;     
 }
//Added by Ashutosh - US103890 - to insert new interested parties
 public static void insertInterestedParties(List<Core_IPS_Case_Interested_Party__c> interestedParties){
     insert interestedParties;
 } 
 
    //Added by Aayushi - US253172 - to update Contact
 public static void updateContact(Contact cont){
     try{update cont;}
     catch(Exception e){ System.debug('Error In Contact Update: '+e.getCause()+e.getLineNumber()); Core_IPS_ExceptionHandling.logEntryWithException(e, 'Contact', 'Core_IPS_AdminUtility');}
     
 } 
}