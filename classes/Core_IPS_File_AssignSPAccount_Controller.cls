/***************************************************************************************************
Apex Class Name:  Core_IPS_File_AssignSPAccount_Controller
Version : 1.0 
Created Date: 16 Sept 2015
Function    : Controller class to Assign Supported Products and Accounts to IPS File
Used in : Core_IPS_File_AssignSPAccount Page
Modification Log :
* Developer               Date                   Description
* ----------------------------------------------------------------------------         
* Johri, Sagar                09/16/2015             Created
* Malhotra, Abhimanyu S       01/23/2016             Add errorMessage Method & RemoveHardcoded messages
****************************************************************************************************/       

public class Core_IPS_File_AssignSPAccount_Controller{
    public List<Core_IPS_File_Assignment__c> Existing_core_IPS_FASS_Lst = new List<Core_IPS_File_Assignment__c>();
    public List<Core_IPS_File_Assignment__c> IPDFAssLst = new List<Core_IPS_File_Assignment__c>();
    public boolean delButtonDisabled{get;set;}
    public boolean renderParent{get;set;}
    public List<Wrapper> wrplist{get;set;}
    public Id IPSFileUploadID;
    
    public Core_IPS_File_AssignSPAccount_Controller(ApexPages.StandardController controller) 
    {
        IPSFileUploadID = ApexPages.currentPage().getParameters().get('id'); 
        wrplist = new List<Wrapper>();
        Wrapper wrp = new Wrapper();
        wrplist.add(wrp);                
        renderParent=false;
        delButtonDisabled=true;
    }
    
    public void addRow()
    {
        wrplist.add(new Wrapper());        
        if(wrplist.size()<2)
            delButtonDisabled=true;
        else
            delButtonDisabled=false;        
    }
    
    public void delRow()
    {    
        Integer i = 0;        
        for(Wrapper wrp : wrplist)
        {
            if(wrp.flag)
                break;
            i++;
        }        
        if(wrplist.size() > i)
            wrplist.remove(i);
        
        if(wrplist.size()<2)
            delButtonDisabled=true;
        else
            delButtonDisabled=false;
    }
    
/***************************************************************************************************
Method Name:  saveRecord    
Version     : 1.0 
Created Date: 16Sept 2015
Function    : This method is used to save the record of object Core_IPS_File_Assignment__c with Supported Products and Account.  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                09/16/2015             Created
****************************************************************************************************/         
    public PageReference saveRecord() {            
        List<String> ConcatExistingSuppProdANDAccount = new List<String>();
        List<String> ConcatNewSuppProdANDAccount = new List<String>();
        String existingSuppProdName;
        String existingAccountName;        
        String newSuppProdName;
        String newAccountName;
        
        Existing_core_IPS_FASS_Lst = [Select Id, Core_Account__c, Core_Supported_Product__c from Core_IPS_File_Assignment__c 
                                      where Core_IPS_File_Upload_Master__c =: IPSFileUploadID];        
        
        for(Core_IPS_File_Assignment__c IPSFA : Existing_core_IPS_FASS_Lst)
        {            
            if(IPSFA.Core_Supported_Product__c != null){
                existingSuppProdName = IPSFA.Core_Supported_Product__c;
            }
            else{
                existingSuppProdName = 'NoSuppProd';
            }
            
            if(IPSFA.Core_Account__c != null){
                existingAccountName = IPSFA.Core_Account__c;
            }
            else{
                existingAccountName = 'NoAccount';
            }
            ConcatExistingSuppProdANDAccount.add(existingSuppProdName+existingAccountName);
        }
        
        for(Wrapper wrpl : wrplist)
        {            
            if(wrpl.fps.Core_Supported_Product__c != null){
                newSuppProdName = wrpl.fps.Core_Supported_Product__c;
            }
            else{
                newSuppProdName = 'NoSuppProd';
            }
            if(wrpl.fps.Core_Account__c != null){
                newAccountName = wrpl.fps.Core_Account__c;
            }
            else{
                newAccountName = 'NoAccount';
            }
            ConcatNewSuppProdANDAccount.add(newSuppProdName+newAccountName);
            
            IPDFAssLst.add(wrpl.fps);
        }   
        
        for(String cnspaa : ConcatNewSuppProdANDAccount)
        {
            if(cnspaa == 'NoSuppProdNoAccount')
            {
                //Supported Product and Account, both can not be blank
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errormessage('F100')));
                IPDFAssLst.clear();
                return null;
            }
        }
        if(IPDFAssLst.size() > 0){
            Integer existingSystemcount = 0;
            boolean recordFoundInSystem = false;
            for(String nw : ConcatNewSuppProdANDAccount){
                existingSystemcount++;
                for(String ex : ConcatExistingSuppProdANDAccount){
                    if(ex == nw){
                        //Record entered at S No.: '+existingSystemcount+' already associated to this IPS File Upload
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errormessage('F101') + ' ' + existingSystemcount+ ' ' + errormessage('F102')));
                        IPDFAssLst.clear();        
                        recordFoundInSystem = true;
                        return null;
                    }
                }
            }        
            if(!recordFoundInSystem){
                Integer newRecordcount = 0;
                integer newRecCount = ConcatNewSuppProdANDAccount.size();            
                for(String nw1 : ConcatNewSuppProdANDAccount){
                    for(String nw2 : ConcatNewSuppProdANDAccount){
                        if(nw1 == nw2){
                            newRecordcount++;
                            if(newRecordcount > newRecCount){
                                //Similar record has been added multiple times.
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errormessage('F103')));                                
                                IPDFAssLst.clear();
                                recordFoundInSystem = true;
                                return null;
                            }
                        }
                    }
                }
            }
            
            if(IPDFAssLst.size()>0){
                insert IPDFAssLst;
            }
            
            if(IPSFileUploadID!=null)
            { 
                PageReference parentIPSFileUploadPage = new PageReference('/' + IPSFileUploadID);
                parentIPSFileUploadPage.setRedirect(true);
                return parentIPSFileUploadPage;
            }
            
            else 
            {
                Schema.Describesobjectresult IPSFileUploadPage = Schema.Sobjecttype.Core_IPS_File_Upload_Master__c;
                String prefix = IPSFileUploadPage.getKeyPrefix();
                PageReference pageRef = new PageReference('/' + prefix + '/o');
                pageRef.setRedirect(true);
                return pageRef;                
            }
        }
        else{
            return null;
        }
        
    }
/***************************************************************************************************
Method Name:  cancelRecord    
Version     : 1.0 
Created Date: 16Sept 2015
Function    : This method is used to Cancel out the File assignment process  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar                09/16/2015             Created
****************************************************************************************************/         
    
    public PageReference cancelRecord() {        
        if(IPSFileUploadID!=null)
        { 
            PageReference parentIPSFileUploadPage = new PageReference('/' + IPSFileUploadID);
            parentIPSFileUploadPage.setRedirect(true);
            return parentIPSFileUploadPage;
        }        
        else 
        {
            Schema.Describesobjectresult IPSFileUploadPage = Schema.Sobjecttype.Core_IPS_File_Upload_Master__c;
            String prefix = IPSFileUploadPage.getKeyPrefix();
            PageReference pageRef = new PageReference('/' + prefix + '/o');
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
        
    public class Wrapper{
        public boolean flag{get;set;}
        public Core_IPS_File_Assignment__c fps{get;set;}
        wrapper()
        {
            flag = false;
            fps = new Core_IPS_File_Assignment__c(Core_IPS_File_Upload_Master__c = ApexPages.currentPage().getParameters().get('id'));
        }
    }
}