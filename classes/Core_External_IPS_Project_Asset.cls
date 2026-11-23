/*--------------------------------------------------------------------------------------------------------------------------------------
* Page Name  : Core_External_IPS_Project_Asset
* Version     : 1.0
* Created Date: 8 Feb 2018
* Modification Log :
* Developer                 Date                   Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         2/8/2018               Page to validate Project status and redirct to  add products to Project page 
-----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class Core_External_IPS_Project_Asset{
    
    public String iPSProject {get;set;}    
    //Final ApexPages.StandardController controller;    
    public ApexPages.StandardSetController stdCntrlr {get; set;}
    
    public Core_External_IPS_Project_Asset(ApexPages.StandardSetController controller) {
        iPSProject  = ApexPages.currentPage().getParameters().get('id');
        system.debug('Project ID '+ iPSProject);
    }
    
    //Validate project Status and redirect to Products add page.
    public pagereference redirectPage(){
        PageReference p ; 
        Core_IPS_Project__c projectStatus = [Select id,Core_Status__c from Core_IPS_Project__c where Id =:iPSProject];
        if(projectStatus.Core_Status__c == 'Inactive'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You cannot add products to an inactive project.' 
                                                       +'/n/'+'If you want to add a new product, please set the project to Active.'));
        }
        else{
            p = new PageReference('/IPS/Core_ExternalUser_IPS_Project?id='+ipsProject+'&stepIndex=2&modeStr=add&editProj=true');
        }
        return p;
    }
    
    //Return to Project Detail Page
    public pagereference returnToProject(){
        PageReference projectPage;        
        projectPage = new PageReference('/IPS/'+ipsProject); 
        return projectPage;
    }
}