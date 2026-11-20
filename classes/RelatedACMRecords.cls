/**************************************************************************************************************
Apex Class Name:  RelatedACMRecords
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : It act as wrapper class for to hold Related ACM records for the Account
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         02/06/2020        Initial version
***************************************************************************************************************/

global class RelatedACMRecords{
     public List<PRM_AccountChannelMembership__c> listOfACM;
     public String ipaBadge;
     public RelatedACMRecords(List<PRM_AccountChannelMembership__c> acms, String badge){
         listOfACM = acms;
         ipaBadge = badge;
     }        
}