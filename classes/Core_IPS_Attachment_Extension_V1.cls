/***************************************************************************************************
Apex Class Name:  Core_IPS_Attachment_Extension_V1
US no          :  US67638,US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Controller to restrict Attachments visibility on a 
                  case based on logged in user's profile
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
****************************************************************************************************/

 public with sharing class Core_IPS_Attachment_Extension_V1{

    public string caseid{get;set;} 
    public String partnerVal{get;set;}
    public boolean externalUser{get;set;}{externalUser=Network.getNetWorkid()!= null? True:false;}
    public list<Core_IPS_Case_Attachments__c> attachmentList{get;set;}
    public list<Core_IPS_Case_Attachments__c> myListFilter{get;set;} // list to display public attachments depending on the user's profile
    public list<Core_IPS_Case_Attachments__c> myPublicAttachFilter {get;set;} // list to display public attachments for External User
    public Core_IPS_Attachment_Extension_V1(ApexPages.StandardController controller){
     caseid=controller.getId();
     if(Core_IPS_Labels__c.getValues('Partner').value__c!=null){
         partnerVal=Core_IPS_Labels__c.getValues('Partner').value__c;
     }
      if(!string.isBlank(caseid))
         fetchattachmentList();
     externalUser=Network.getNetWorkid()!= null? True:false;   
     
    }
    
/***************************************************************************************************
Method Name    :  fetchattachmentList()
US no          :  US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Restricts Attachments visibility on a 
                  case based on logged in user's profile
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
****************************************************************************************************/

    
    public void fetchattachmentList(){
        try{
            List<string> internalProfileChk=System.Label.Core_IPS_Internal_Profiles_fot_Attachments.split(',');
            User userObj = [SELECT id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            attachmentList=[SELECT NAME,CreatedByID,CreatedDate,Core_File_Hyperlink__c,Core_Upload_Status__c,core_case__c,Core_File_Size__c,Core_Category__c,Core_File_Description__c,Core_File_Name__c,Core_FileUploadedBy__c,Core_Upload_UserId__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE core_case__c=:caseid];
            myListFilter=new  list<Core_IPS_Case_Attachments__c>();
            myPublicAttachFilter=new  list<Core_IPS_Case_Attachments__c>();
            if(attachmentList.size()>0 && attachmentList!=null && userObj !=null ){
                
                for(Core_IPS_Case_Attachments__c vr:attachmentList){
                   /* if(vr.Core_IPS_Attachment_Visibility__c!=null && System.Label.Core_IPS_Internal_Profiles_for_Attachments.contains(String.valueOf(userObj.Profile.Name)))
                       myListFilter.add(vr);
                    else if(vr.Core_IPS_Attachment_Visibility__c==Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && System.Label.Core_IPS_External_Customer_Profile.contains(String.valueOf(userObj.Profile.Name))) 
                      myListFilter.add(vr);*/
                      
                      myListFilter.add(vr);
                      if(vr.Core_IPS_Attachment_Visibility__c=='Public to Customers' || vr.Core_IPS_Attachment_Visibility__c=='' )
                         myPublicAttachFilter.add(vr);
                }
            }
        }catch(Exception ex){
        
        }
    }
    
        
    
/********************************************************************************
Method Name    :  URL()
US no          :  US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method redirects to upload page with a public header
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
********************************************************************************/
    
    public PageReference URL(){
        string publicParameter=ApexPages.currentPage().getParameters().get('id');
         if(publicParameter!=null){
            PageReference pageRef=new  PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
            return new  PageReference('/apex/Core_IPS_File_AttachToCase?id='+publicParameter+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);
            }
         
        return null;
    }
    
/*****************************************************************************
Method Name    :  URL1()
US no          :  US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method redirects to upload page with a private header
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
********************************************************************************/
    
    public pagereference URL1(){
        string privateParameter=ApexPages.currentPage().getParameters().get('id');
        if(privateParameter!=null){
            PageReference pageRef=new  PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
            return new  PageReference('/apex/Core_IPS_File_AttachToCase?id='+privateParameter+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c);
        }
        return null;
    }
    
/***************************************************************************************************
Method Name    :  URL2()
US no          :  US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method redirects to upload page for customers
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
********************************************************************************/

    public PageReference URL2(){
        PageReference pageRef=new  PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        return new  PageReference('/apex/Core_IPS_File_AttachToCase?id='+caseid);
      
    }
    
/***************************************************************************************************
Method Name    :  editAttachments()
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method redirects to edit page for an attachment
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
********************************************************************************/
    
    public Pagereference editAttachments()
    {
        String attachmentId= ApexPages.currentPage().getParameters().get('attachmentId'); 
        return new PageReference('/apex/Core_IPS_AttachmentsEdit_Page?id='+attachmentId+'&retURL=apex/Core_IPS_ViewCase?id='+caseid);
        
    }

/***************************************************************************************************
Method Name    :  deleteAttachments()
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method deletes a selected attachment
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
********************************************************************************/
    public Pagereference deleteAttachments()
    {
        String attachmentId= ApexPages.currentPage().getParameters().get('attachmentId'); 
        Core_IPS_Case_Attachments__c a = [Select name from Core_IPS_Case_Attachments__c where id =:attachmentId limit 1];
        if(a!=null && a.id !=null){
        delete a;
        
        }
       
        return null;
    }
    
    
}

//end by aparna on 14/12/2017//