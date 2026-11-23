/***************************************************************************************************
*Class Name:  Core_IPS_ViewCase_Controller
*Version     : 1.0 
*Created Date: Nov 23 2017
*Description:  Extension for Core_IPS_ViewCase VF
*Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                   11/23/2017              Created - US72553
****************************************************************************************************/ 

public with sharing class Core_IPS_ViewCase_Controller {
    
    Public Boolean hideCaseDetails{get;set;}
    
    public Core_IPS_ViewCase_Controller(ApexPages.StandardController stdcon) {
        //stdcon.addFields(new List<String> {'Core_IPS_Customer_Visible__c'});
        
        hideCaseDetails = false;
        Id CaseId = stdcon.getId();
        //Case objCase = (Case) stdcon.getRecord();
        Case objCase = [SELECT Id, Core_IPS_Customer_Visible__c,RecordTypeId FROM Case WHERE Id=:CaseId];
        if(objCase!=null) {
            Id loggedInUserId = UserInfo.getUserId();
            Integer loginUserAsPortalUser = [SELECT COUNT() FROM CaseShare WHERE RowCause = 'RelatedPortalUser' And caseId=:objCase.Id AND UserOrGroupId=:loggedInUserId];               
            if((loginUserAsPortalUser>0 || Test.isRunningTest()) && objCase.Core_IPS_Customer_Visible__c==false && 
               (objCase.RecordTypeId == System.Label.Core_IPS_Case_Create_RecordType_Id || objCase.RecordTypeId == System.Label.Core_IPS_Closed_Case_RT_Id || 
                objCase.RecordTypeId == System.Label.Core_IPS_No_Assigned_Contact_Case_RT_Id ||  objCase.RecordTypeId == System.Label.Core_IPS_GEC_ReadOnly_RT_Id)
              ) {
                  hideCaseDetails = true; //hide the case detail page if Customer tries to see NOT "Customer visible" IPS Case
              }
        }
        
        
    }

}