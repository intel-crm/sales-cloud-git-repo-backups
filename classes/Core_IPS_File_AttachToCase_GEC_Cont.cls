/***************************************************************************************************
Apex Class Name:  Core_IPS_File_AttachToCase_GEC_Controller
Version     : 1.0 
Created Date: 24 Sept 2015
Function    : Controller class to Attach IPS File to case
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                 09/24/2015              Created
****************************************************************************************************/

public with sharing class Core_IPS_File_AttachToCase_GEC_Cont{
    
    public string URL {get;set;}
    public Boolean gecCase{get;set;}
    public Boolean  NormalCase{get;set;}
    
    public Core_IPS_File_AttachToCase_GEC_Cont(ApexPages.StandardController controller) {
        ID recID = System.currentPageReference().getParameters().get('id');
        URL = System.Label.Core_IPS_File_SCFT_URL + '?caseId=' + recID;
        
    }
    public Core_IPS_File_AttachToCase_GEC_Cont()
    {
    }
    
    public PageReference OkButton() {
        // The page will be redirected to the selected case.
        if(System.currentPageReference().getParameters().get('id')!=null)
        { 
            PageReference pageRef = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }    
    
    public PageReference saveAndReturn() {
        // The page will be redirected to the selected case.
        if(System.currentPageReference().getParameters().get('id')!=null)
        { 
            PageReference pageRef = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        else 
        {
            // Redirecting to cases pages if the id is NULL
            PageReference pageRef = new PageReference('/500/o');
            pageRef.setRedirect(true);
            return pageRef;
        }
        
    }

}