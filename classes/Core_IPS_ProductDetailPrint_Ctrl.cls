/****************************************************************************************************************************************
* Class Name  : Core_IPS_ProductDetailPrint_Ctrl 
* Version     : 1.0 
* Created Date:  28/03/2022  
* Modification Log :
* Developer: Vishal Suryavanshi                    Date                          Description: 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps                               28/03/2022                     Controller for Core_IPS_ProductDetailPrint_Page.vfp
*****************************************************************************************************************************************/

public with sharing class Core_IPS_ProductDetailPrint_Ctrl {
    
    public Asset assetObj{get; set;}
    public String currentRecordId{get; set;}
    
    public Core_IPS_ProductDetailPrint_Ctrl(){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('recordId');
        assetObj = [SELECT Id, Name, Core_IPS_Project_Name__c, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Status FROM ASSET WHERE Id =: currentRecordId];    
    }
    
    public List<Case> getAllCases(){
        return [SELECT id, CaseNumber, Core_Contact_Name__c, Subject, CreatedDate, Status FROM Case WHERE assetId =:assetObj.Id  order by CaseNumber asc];
    } 
}