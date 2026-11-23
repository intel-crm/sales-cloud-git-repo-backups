/***************************************************************************************************
Apex Class Name:  Core_IPS_File_LinkToCase_Controller
Version     : 1.0 
Created Date: 15 Sept 2015
Function    : Controller class to Link Core IPS File to Case
Modification Log :
* Developer                      Date                   Description
* ----------------------------------------------------------------------------                 
* Prakash, Jyothi                09/15/2015             Created
* Johri, Sagar                   09/17/2015             Code fix
* Malhotra, Abhimanyu S          01/24/2016             Remove hardcoded messages and cleanup
****************************************************************************************************/
public class Core_IPS_File_LinkToCase_Controller {
    public List<uFile> FileList {get; set;} 
    public case currentcase{get;set;}
    public List <Core_IPS_File_Assignment__c> CoreIPSFILEAssignLst = new List<Core_IPS_File_Assignment__c>();
    public case CaseObj;
    public boolean recordAvailable {get; set;} 
    // Constructor for current case assignment
    public Core_IPS_File_LinkToCase_Controller(apexpages.standardcontroller  st){
        this.currentcase = (case)st.getRecord();
    } 
/***************************************************************************************************
Method Name:  getFiles    
Version     : 1.0 
Created Date: 23rd Jan 2016
Function    : getFiles
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                01/23/2016             Created
****************************************************************************************************/              
    public List<uFile> getFiles() {
        if(FileList == null) 
        {
            FileList = new List<uFile>();
            CaseObj = [Select Id, Core_IPS_Supported_Product__c from case where id =: currentcase.id];
            //Get File Uploads with same SP
            if(CaseObj.Core_IPS_Supported_Product__c != null){
                CoreIPSFILEAssignLst = [Select id, Core_IPS_File_Upload_Master__c from Core_IPS_File_Assignment__c 
                                        where Core_Supported_Product__c =: CaseObj.Core_IPS_Supported_Product__c];
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, errormessage('F104')));
                recordAvailable =false;
                return null;
            }            
            Set <ID> CIPSFAID = new Set<ID>();
            if(CoreIPSFILEAssignLst != null && CoreIPSFILEAssignLst.size() > 0){
                for(Core_IPS_File_Assignment__c CIPSFA : CoreIPSFILEAssignLst){
                    if(CIPSFA.Core_IPS_File_Upload_Master__c != null){
                        CIPSFAID.add(CIPSFA.Core_IPS_File_Upload_Master__c);
                    }
                }
            } else {
                //No Files found to link
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, errormessage('F105'))); 
                recordAvailable =false;
                return null;
            }
            Set <String> CoreFileGUID_Existing = new Set<String>();
            List<Core_IPS_Case_Attachments__c> ExistingCIPSCaseAttLst = [select Core_File_GUID__c from Core_IPS_Case_Attachments__c where Core_Case__c=:currentcase.id];
            for(Core_IPS_Case_Attachments__c CIPSFileAssignGUID : ExistingCIPSCaseAttLst){
                CoreFileGUID_Existing.add(CIPSFileAssignGUID.Core_File_GUID__c);
            }
            //Check File Upload Master for related records
            List<Core_IPS_File_Upload_Master__c> CIPSUpMasLst = new List<Core_IPS_File_Upload_Master__c>();            
            CIPSUpMasLst = [select id, Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, 
                            Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c, 
                            Core_File_Hyperlink__c from Core_IPS_File_Upload_Master__c
                            where id IN :CIPSFAID and Core_Upload_Status__c = 'Complete' and 
                            Core_Expiration_Date__c >: datetime.now() and 
                            Core_File_GUID__c not IN :CoreFileGUID_Existing order by lastmodifieddate];           
            //Check to see if entries found   
            if(CIPSUpMasLst.size() > 0){
                recordAvailable = true;
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, errormessage('F106')));
                recordAvailable = false;
                return null;
            }            
            // Catch Exception if the upload master is empty                 
            for(Core_IPS_File_Upload_Master__c  f: CIPSUpMasLst) {
                FileList.add(new ufile(f));
            }
        }
        return FileList;
    }
/***************************************************************************************************
Method Name:  Save    
Version     : 1.0 
Created Date: 23rd Jan 2016
Function    : Save Method  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                01/23/2016             Created
****************************************************************************************************/              
    public PageReference save() {
        List<Core_IPS_File_Upload_Master__c> selectedfiles = new List<Core_IPS_File_Upload_Master__c>();
        List<Core_IPS_Case_Attachments__c> selectedCaseAttachments = new  List<Core_IPS_Case_Attachments__c>();
        Core_IPS_Case_Attachments__c tempCase = new Core_IPS_Case_Attachments__c();
        
        // If the id is not null then the selected files will be inserted as case attachments, it will be redirected to cases pages otherwise.
        if(System.currentPageReference().getParameters().get('id')!=null)
        {        
            for(ufile f: getfiles()) {
                if(f.selected) {
                    tempCase = new Core_IPS_Case_Attachments__c();               
                    tempCase.Core_Case__c = id.valueof(System.currentPageReference().getParameters().get('id'));
                    tempCase.Core_IPS_File_Upload__c = f.file.id;
                    tempCase.Core_Type__c = 'Link';
                    tempCase.Core_Category__c = f.file.Core_Category__c;
                    tempCase.Core_File_Description__c = f.file.Core_File_Description__c;
                    tempCase.Core_File_GUID__c = f.file.Core_File_GUID__c;
                    tempCase.Core_File_Name__c = f.file.Core_File_Name__c;
                    tempCase.Core_File_URL__c = f.file.Core_File_URL__c;
                    tempCase.Core_Upload_Status__c = f.file.Core_Upload_Status__c;
                    tempCase.Core_Last_Status_Updated_At__c = f.file.Core_Last_Status_Updated_At__c;
                    tempCase.Core_Upload_UserId__c = f.file.Core_Upload_UserId__c; 
                    tempCase.Core_Upload_idsid__c = f.file.Core_Upload_idsid__c;
                    tempCase.Core_File_Size__c = f.file.Core_File_Size__c;
                    tempCase.Core_FileUploadedBy__c = f.file.Core_FileUploadedBy__c;
                    selectedCaseAttachments.add(tempCase);
                }
            }        
            // Inserting all selected files as case attachments 
            database.insert(selectedCaseAttachments, false);        
            FileList=null; 
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
/***************************************************************************************************
Method Name:  Cancel    
Version     : 1.0 
Created Date: 23rd Jan 2016
Function    : Cancel  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                01/23/2016             Created
****************************************************************************************************/          
    public PageReference Cancel() {
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
    
/***************************************************************************************************
Method Name:  errorMessage    
Version     : 1.0 
Created Date: 23rd Jan 2016
Function    : This method is used to get the error text from custom setting  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S       01/23/2016             Created
****************************************************************************************************/          
    public string errorMessage(string errorCode){
        string defaultMessage ='Invalid Entry';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultMessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultMessage;
    }
    
/***************************************************************************************************
Method Name:  Wrapper Class    
Version     : 1.0 
Created Date: 23rd Jan 2016
Function    : Wrapper class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                01/23/2016             Created
****************************************************************************************************/              
    public class uFile {
        public Core_IPS_File_Upload_Master__c file {get; set;}
        public Boolean selected {get; set;}
        public ufile(Core_IPS_File_Upload_Master__c f) 
        {
            file = f;
            selected = false;
        }
    }
    
}