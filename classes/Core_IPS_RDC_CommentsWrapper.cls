/****************************************************************************************************************************************
* Class Name  : Core_IPS_RDC_Comments
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*Aparna                    9/9/2019                 This class defines the JSON structure to add comments to a case-US460268
****************************************************************************************************************************************/

global class Core_IPS_RDC_CommentsWrapper extends Core_RestAPI_Request{
    
    public string caseNumber{get;set;}
    public string comments{get;set;}
    public string contactEmail{get;set;} 
    
}