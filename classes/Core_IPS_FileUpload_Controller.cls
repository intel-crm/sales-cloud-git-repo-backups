/***************************************************************************************************
Apex Class Name:  Core_IPS_FileUpload_Controller
Version     : 1.0 
Created Date: 23 Sept 2015
Function    : IPS Admin File Upload
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/

public with sharing class Core_IPS_FileUpload_Controller {    
    public Boolean noDataFlag { get; set; }
    public string fileId {get;set;}
    public string URL {get;set;}
    private String vfUserId;
    public String fUpldmMasterPrefix {get;set;}
    public String fAssignPrefix {get;set;}
    private Map<Id,Core_IPS_File_Upload_Master__c> mFileMap = new Map<Id,Core_IPS_File_Upload_Master__c>(); 
    
    public Core_IPS_FileUpload_Controller() {
        noDataFlag = true;
        Schema.Describesobjectresult fUpldmMasterObj = Schema.Sobjecttype.Core_IPS_File_Upload_Master__c;
        fUpldmMasterPrefix = '/' + fUpldmMasterObj.getKeyPrefix() + '/o';
        Schema.Describesobjectresult fAssignObj = Schema.Sobjecttype.Core_IPS_File_Assignment__c;
        fAssignPrefix = '/' + fAssignObj.getKeyPrefix() + '/o';        
        //URL = System.Label.Core_IPS_File_SCFT_URL; existing url
        URL = System.Label.Core_IPS_File_SCFT_URL+'&console=true'; //TWC745-321 - IPS: Update upload URLs and field mappings [KIIT] - 16/09/2021 - Popcornapps
    }
    
    //Get File Upload details
    public void addfileId() {
        Set<String> fields = new Set<String>{'Id', 'Name', 'Core_FileUploadedBy__c'};        
            String queryString = 'select Id, Name, Core_FileUploadedBy__c';
        //Current User Id
        vfUserId = UserInfo.getUserId(); 
        //Read Field Set
        for(Schema.FieldSetMember fsm : SObjectType.Core_IPS_File_Upload_Master__c.FieldSets.Core_Admin_Upload_Screen.getFields()) {
            if(!fields.contains(fsm.getFieldPath())){
                fields.add(fsm.getFieldPath());
                queryString += ', ' + fsm.getFieldPath();
            }
        }       
        //Query string where clause
        queryString += ' from Core_IPS_File_Upload_Master__c ' + ' where Id =:fileId';
        //Execute Query  
        List<Core_IPS_File_Upload_Master__c> lstfupld = Database.query(queryString);
        if (lstfupld != null && lstfupld.size() > 0) {
            Core_IPS_File_Upload_Master__c fupld = lstfupld[0]; 
            if (fupld.Core_FileUploadedBy__c == vfUserId) {
                mFileMap.put(fupld.Id, fupld);
                noDataFlag = false;
            }  
        } else {
            if (mFileMap.get(fileId)!= null) {
                mFileMap.remove(fileId); 
            }
        }
    }
    
    //Return Uploaded Files
    public List<Core_IPS_File_Upload_Master__c> uploadedFiles {
        get {
            uploadedFiles = mFileMap.values();
            return uploadedFiles;
        }
        set;
    }
    
    //Navigate to the File Upload Master List view page
    public PageReference GotoIPSFileUploadMaster() {
        PageReference pageRef = new PageReference(fUpldmMasterPrefix);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}