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

 public with sharing class Core_IPS_Attachment_Extension{
    
    public boolean showAction{get;set;}
    public integer total{get;set;}
    public string showLink{get;set;}
    public string caseid{get;set;} 
    public String partnerVal{get;set;}
    public list<Core_IPS_Case_Attachments__c> myListFilter{get;set;} // list to display public attachments depending on the user's profile
      
    // Added by Aparna on 28/2/2018 for DE36696,DE36701-Release 3
    public String privateFileURL {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}}
    public String publicFileURL  {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}}
    Public string publicURL{get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}}
   //end  by Aparna on 5/3/2018 for DE36696,DE36701-Release 3
   
   //Added by Aparna on 26/4/2018 for US104151-R4.3
    public String privateToPartnerURL{get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;}}
    public String partnerFileURL {get{ return '/apex/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;}}
   //end by Aparna on 26/4/2018 for US104151-R4.3
    
    // Added by Prem on 28/2/2018 for Partner Agent Changes
    public String partnerAgentPrivateFileURL {get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}}
    public String partnerAgentPublicFileURL  {get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}}
    //end  by Prem on 28/2/2018  for for Partner Agent Changes
       
     //Added by Aparna for partner changes on 19/4/2018
     public string uploadpartnerProfileType{get;set;}  
     public String partnerType{get;set;}
     public String PartnerProf{get;set;}{PartnerProf  = System.Label.Core_IPS_Partner_Profile_Id;}
       
    public Core_IPS_Attachment_Extension(ApexPages.StandardController controller){
    
         caseid=controller.getId();
         
         showAction=System.Label.Core_IPS_ActionVisibility_Check.Contains(String.valueOf(userInfo.getProfileId()).substring(0,15));
         
         if(ApexPages.currentPage().getParameters().get('list')!=null)
         showLink = ApexPages.currentPage().getParameters().get('list');
           
         if(Core_IPS_Labels__c.getValues('Partner').value__c!=null)
         {
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

           if((System.Label.Core_IPS_External_Customer_Profile.contains(String.valueOf(userObj.Profile.Name)) )) // modified code by Prem for Exact Profile Check removed "System.Label.Core_IPS_Internal_Profiles_for_Attachments.contains".
           {
               strQuery += ' AND Core_IPS_Attachment_Visibility__c=\'Public to Customers\'';
               total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid AND Core_IPS_Attachment_Visibility__c = 'Public to Customers' ];
           } 
           else if(internalProfileChkSet.contains(String.valueOf(userObj.Profile.Name)))  
           {
               total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid ]; 
           }
           
           //Added for partner changes on 19/4/2018 by Aparna
          
         else if(PartnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15)))
         {  
           String uploadpartnerProfileType= Core_Utility.getPartnerUserType(userinfo.getuserid()); 
             if(uploadpartnerProfileType.length()>0)
             {
               partnerType = uploadpartnerProfileType.split(';')[0];
             }                                                       
             if(partnerType !=null && String.isNotBlank(partnerType)) 
             {                
                if(partnerType == 'Partner - DFAE')
                {
                    strQuery += ' AND (Core_IPS_Attachment_Visibility__c=\'Private to Partner\' OR Core_IPS_Attachment_Visibility__c = \'Public to Customers\')';  
                    total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid AND (Core_IPS_Attachment_Visibility__c = 'Private to Partner' OR Core_IPS_Attachment_Visibility__c = 'Public to Customers')];                
                 }
                 else if(partnerType == 'Partner')
                 {
                    strQuery += ' AND Core_IPS_Attachment_Visibility__c=\'Public to Customers\' ';
                    total = [select count() from core_ips_case_attachments__c where core_case__c =:caseid AND Core_IPS_Attachment_Visibility__c = 'Public to Customers'];
                 }
             }
           
          }         
           //end by Aparna
           
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
    
    /*public Pagereference editAttachments()
    {
        String attachmentId= ApexPages.currentPage().getParameters().get('attachmentId'); 
        return new PageReference('/'+attachmentId+'/e?retURL=/apex/Core_IPS_ViewCase?id='+caseid);
        
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