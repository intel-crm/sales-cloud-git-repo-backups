/****************************************************************************************************************************************
* Class Name  : PMP_RetryCalloutInterface 
* Version     : 1.0 
* Created Date: 08-01-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Prakash                         Aug-01-2019                    Interface to make a callout or any processing
* ****************************************************************************************************************************************/

public interface PMP_RetryCalloutInterface {
    
    Boolean retryCallout(Id recordId); // to process single record
    Map<Id,Boolean> retryCallout(List<Id> recordIds); // to process bulk records
}