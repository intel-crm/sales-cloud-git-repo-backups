/***************************************************************************************************
Apex Class Name:  Core_IPS_Attachment_Extension
US no          :  US67638,US67639
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Controller to restrict Attachments visibility on a 
                  case based on logged in user's profile
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
* Aparna                 28/2/2018                  Modified for DE36696,DE36701-Release 3
****************************************************************************************************/

 public with sharing class Core_IPS_Attachment_Extension_Dup{
     
    
    public boolean showAction{get;set;}
    public integer total{get;set;}
    public string showLink{get;set;}
    public string caseid{get;set;} 
    public String partnerVal{get;set;}
    Public Boolean isInConsole{get;set;}
    Public String retURL{get{return '/apex/Core_IPS_ViewCase?id='+caseid;}}
    
    
    public list<Core_IPS_Case_Attachments__c> myListFilter{get;set;} // list to display public attachments depending on the user's profile
    
    // Added by Aparna on 28/2/2018 for DE36696,DE36701-Release 3
    public String privateFileURL {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}}
    public String publicFileURL  {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}}
    public String partnerFileURL  {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;}}
   //end by Aparna on 5/3/2018 for DE36696,DE36701-Release 3
   
    public Core_IPS_Attachment_Extension_Dup(ApexPages.StandardController controller){
     caseid=controller.getId();
     
     
     showAction=System.Label.Core_IPS_ActionVisibility_Check.Contains(String.valueOf(userInfo.getProfileId()).substring(0,15));
     
     if(ApexPages.currentPage().getParameters().get('list')!=null)
     showLink = ApexPages.currentPage().getParameters().get('list');
       
     if(Core_IPS_Labels__c.getValues('Partner').value__c!=null){
         partnerVal=Core_IPS_Labels__c.getValues('Partner').value__c;
     }
      if(!string.isBlank(caseid))
         fetchattachmentList();
         
              
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
            List<string> internalProfileChk=System.Label.Core_IPS_Internal_Profiles_for_Attachments.split(',');
            /*  Code Added for Splitting Profile by Prem because we have multiple profile name Contains "Partner" */
            Set<String> internalProfileChkSet =new Set<String>();
            for (String element : internalProfileChk) {
                String trimmedElement = element.trim();
                internalProfileChkSet.add(trimmedElement);
            }
            /*  end Code */
            User userObj = [SELECT id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            
            total = 0;
          
                     
           String strQuery = 'SELECT NAME,CreatedByID,Createdby.name,CreatedDate,Core_File_Hyperlink__c,Core_Upload_Status__c,core_case__c,Core_File_Size__c,Core_Category__c,Core_File_Description__c,Core_File_Name__c,Core_FileUploadedBy__c,Core_FileUploadedBy__r.name,Core_Upload_UserId__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE core_case__c=:caseid'; // Query Modified added Createdby.name and Core_FileUploadedBy__r.name in the below Query too By Prem

           if((System.Label.Core_IPS_External_Customer_Profile.contains(String.valueOf(userObj.Profile.Name)))) // modified code by Prem for Exact Profile Check removed "System.Label.Core_IPS_Internal_Profiles_for_Attachments.contains".
           {
               strQuery += ' AND Core_IPS_Attachment_Visibility__c=\'Public to Customers\'';
               total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid AND Core_IPS_Attachment_Visibility__c = 'Public to Customers'];
           } 
          
          //partenr poc
          else if((System.Label.Core_IPS_Partner_AE_ProfileName.contains(String.valueOf(userObj.Profile.Name)))){
              strQuery += ' AND Core_IPS_Attachment_Visibility__c=\'Private to Partners\'';
              
               total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid AND Core_IPS_Attachment_Visibility__c = 'Private to Partners'];
              system.debug('PPPPPPPPP'+total );
          }
          //end
           else if(internalProfileChkSet.contains(String.valueOf(userObj.Profile.Name)))  
           {
               total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid]; 
           }
           
           strQuery += ' ORDER BY CreatedDate DESC';
           
           if(ApexPages.currentPage().getParameters().get('list')==null) {
               strQuery += ' LIMIT 5';
           }
           
           myListFilter = Database.Query(strQuery);
           
           if(myListFilter == null) {
               myListFilter = new List<Core_IPS_Case_Attachments__c>(); 
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
* Aparna                 28/2/2018                  Modified for DE36696,DE36701-Release 3
********************************************************************************/
    
    /*public PageReference URL(){
        string publicParameter=ApexPages.currentPage().getParameters().get('id');
         if(publicParameter!=null){
            PageReference pageRef=new  PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
            return new  PageReference('/apex/Core_IPS_File_AttachToCase?id='+publicParameter+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c);
            }
         
        return null;
    }*/
    
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
* Aparna                 28/2/2018                  Modified for DE36696,DE36701-Release 3
********************************************************************************/
    
    /*public pagereference URL1(){
        string privateParameter=ApexPages.currentPage().getParameters().get('id');
        if(privateParameter!=null){
            PageReference pageRef=new  PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
            return new  PageReference('/apex/Core_IPS_File_AttachToCase?id='+privateParameter+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c);
        }
        return null;
    }*/
    
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
* Aparna                 28/2/2018                  Modified for DE36696,DE36701-Release 3
********************************************************************************/
    
   /* public Pagereference editAttachments()
    {
        String attachmentId= ApexPages.currentPage().getParameters().get('attachmentId'); 
        return new PageReference('/'+attachmentId+'/e?retURL=apex/Core_IPS_ViewCase?id='+caseid);
        
    }*/

/***************************************************************************************************
Method Name    :  deleteAttachments()
Version        :  1.0 
Created Date   :  11/11/2017
Function       :  Method deletes a selected attachment
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 11/11/2017                 Created
* Aparna                  2/1//2018                 Modified to include exception handling and null check
********************************************************************************/
    public Pagereference deleteAttachments()
    { 
    //Added by Aparna to include exception handling and null check on 2/1/2018
        try{
            String attachmentId= ApexPages.currentPage().getParameters().get('attachmentId');
            Core_IPS_Case_Attachments__c a = [Select name from Core_IPS_Case_Attachments__c where id =:attachmentId limit 1];
            if(a!=null && a.id !=null && attachmentId !=null){
            delete a;
              }
       }catch(Exception Ex){
       } //end by Aparna on 2/1/2018
        return null;
       
    }
 
 

}

//end by aparna on 14/12/2017