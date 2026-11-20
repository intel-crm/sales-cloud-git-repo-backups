/***************************************************************************************************
Apex Class Name:  Core_IPS_File_AttachToCase_Controller
Version     : 1.0 
Created Date: 24 Sept 2015
Function    : Controller class to Attach IPS File to case
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------  
* Johri,Sagar                  09/24/2015              Created                
* Aparna                       22/11/2017              Modified to accomodate changes for US79603,US67638
* Aparna                       19/4/2018               Modified- Added logic for US104151-R4.3
****************************************************************************************************/

public with sharing class Core_IPS_File_AttachToCase_Controller{
    
    public string URL {get;set;}
    
    //added by aparna on 22/11/2017
    private string publicParameter {
        get;
        set;
    }
    private string privateParameter {
        get;
        set;
    }
    public boolean publicFiles {
        get;
        set;
    }
    public boolean privateFiles {
        get;
        set;
    }
    public Map < String, String > mapJsonList;
    public String visibilityType ;
    //end by Aparna on 10/12/2017
    
    //added by Aparna on 19/4/2018 for US104151-R4.3
    public boolean partnerFiles {
        get;
        set;
    }
    
    private string partnerParameter {
        get;
        set;
    }
    //end by Aparna for US104151
    // added by Orion--vamsi on 09/10/2018 for US182118
    public string profileName{set;get;}
    public List<PermissionSetAssignment> faeId{get;set;} 
    public Boolean partnerFAE{get;set;} 
    public String permissionFAE = System.Label.Core_IPS_FAE_Permission_Set_Id;
    
    public Core_IPS_File_AttachToCase_Controller(ApexPages.StandardController controller) {
        // start---added by Orion--vamsi on 09/10/2018 for US182118
        User loggedUser = [Select Id, Name, Profile.id, Profile.Name From User Where Id =:UserInfo.getUserId()]; 
        profileName=loggedUser.Profile.Name;
        //End---- Orion--vamsi on 09/10/2018 for US182118
        ID recID = System.currentPageReference().getParameters().get('id');
        
        try{
            partnerFAE = false;
            PermissionSetAssignment faeId = [select id,AssigneeId from PermissionSetAssignment where AssigneeId=:UserInfo.getUserId() and PermissionSetId =:permissionFAE LIMIT 1];
            if(faeId!=null) partnerFAE = true; 
        }
        catch(Exception e){
        }
        //added by aparna on 22/11/2017 for US79603,US67638
        mapJsonList = new Map < String, String > ();
        privateFiles = false;
        publicFiles = false;
        publicParameter = System.currentPageReference().getParameters().get('id');
        privateParameter = System.currentPageReference().getParameters().get('id');
        
        //Added by Aparna on 19/4/2018 for US104151-R4.3
        partnerParameter = System.currentPageReference().getParameters().get('id');
        //end for US104151
        
        String typeoffile = System.currentPageReference().getParameters().get('Type');
        if (String.isNotBlank(typeoffile) || (typeoffile != null)) {
            mapJsonList.put('visibility', typeoffile);
            visibilityType =typeoffile.replaceAll('(\\s+)', '_');
        }
        
        if (!String.isBlank(publicParameter) && (typeoffile==Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c)) 
        {
            publicFiles = true;
        } 
        else if (!String.isBlank(privateParameter) && (typeoffile == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c)) 
        {
            privateFiles = true;
        }
        //Added for Partner Changes on 19/4/2018 by Aparna
        else if (!String.isBlank(partnerParameter) && (typeoffile == Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c)) 
        {
            partnerFiles = true;
        }
        //end 
        
        String jsonString = JSON.serialize(mapJsonList);
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        String visibilityTypeEncode = EncodingUtil.urlEncode(visibilityType, 'UTF-8'); //TWC745-321 - IPS: Update upload URLs and field mappings [KIIT] - 16/09/2021 - Popcornapps
        
       // if(externalUser){
            URL = System.Label.Core_IPS_File_SCFT_URL + '&caseId=' + recID + '&visibility=' + visibilityTypeEncode; //TWC745-321 - IPS: Update upload URLs and field mappings [KIIT] - 16/09/2021 - Popcornapps
       /* }else{
            URL = System.Label.Core_IPS_File_SCFT_URL_Azure_Migration+ EncodingUtil.urlEncode(System.Label.Core_IPS_File_SCFT_URL + '&caseId=' + recID + '&visibility=' + visibilityTypeEncode, 'UTF-8'); //TWC745-321 - IPS: Update upload URLs and field mappings [KIIT] - 16/09/2021 - Popcornapps
        }*/
        
        
    }
    //end by aparna on 14/12/2017
    
    // this method will be called from LWC
    @auraEnabled
    public static string prepareUrl(ID caseId, string typeoffile){
        Map < String, String > mapJsonList = new Map < String, String >();
        
        if (String.isNotBlank(typeoffile) || (typeoffile != null)) {
            mapJsonList.put('visibility', typeoffile);
        }
        
        String jsonString = JSON.serialize(mapJsonList);
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        string URL = null;
        Core_IPS_File_AttachToCase_Controller controler = new Core_IPS_File_AttachToCase_Controller();
        //if(controler.externalUser){
            URL = System.Label.Core_IPS_File_SCFT_URL + '&caseId=' + caseId + '&visibility=' + typeoffile;    
        /*}else{
            URL = URL = System.Label.Core_IPS_File_SCFT_URL_Azure_Migration+ EncodingUtil.urlEncode(System.Label.Core_IPS_File_SCFT_URL + '&caseId=' + caseId + '&visibility=' + typeoffile, 'UTF-8');
        }*/
        return URL;
        
        
    }
    
    public Core_IPS_File_AttachToCase_Controller() {}
    public boolean externalUser {
        get;
        set;
    } {
        externalUser = Network.getNetWorkid() != null ? True : false; 
    }
    public PageReference saveAndReturn() {
        // The page will be redirected to the selected case.
        if (System.currentPageReference().getParameters().get('id') != null) {
            PageReference pageRef = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            // Redirecting to cases pages if the id is NULL
            PageReference pageRef = new PageReference('/500/o');
            pageRef.setRedirect(true);
            return pageRef;
        }
        
    }
    
}