/****************************************************************************************************************************************
* Class Name        : PMP_Offering_Image_Upload
* Created Date      : 08-07-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek       08-07-2019          Batch class to upload Partner or Company Offering Image.
*****************************************************************************************************************************************/

public without sharing class PMP_Offering_Image_Upload implements Database.Batchable<sObject>,Database.AllowsCallouts 
{
	
    public string queryString;
    public string imgType;
   // public List<string> ContentIdLst = new list<string>();
    public Map<Id,blob> docIdlst = new Map<Id,blob>();
    public List<PMP_Partner_Offering_Resource__c> objPartnerOfferingLst = new List<PMP_Partner_Offering_Resource__c>();
    public List<PMP_Company_Resource__c> objCompanyOfferingLst = new List<PMP_Company_Resource__c>();
    //public List<ContentVersion> lstContVer = new List<ContentVersion>();
    
    //Constructor call for getting the object type for image download    
    public PMP_Offering_Image_Upload(string btchType)
    {
        imgType = btchType;
    }
        
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        queryString = buildQuery(imgType);
        System.debug('Query '+ queryString);
        return Database.getQueryLocator(queryString); 
    }        
    
    public void execute(Database.BatchableContext bc, List<sObject> imgObj)
    {
        string objType = string.valueof(imgObj.getSObjectType());
        Map<Id,string> imgLst = new Map<Id,string>();
        
        
        try
        {
            
            /* test code begins
            integer i = 1;
            objPartnerOfferingLst = (List<PMP_Partner_Offering_Resource__c>)imgObj; 
            System.debug('No of records processed - ' + objPartnerOfferingLst.size());
            
            for(PMP_Partner_Offering_Resource__c por:objPartnerOfferingLst)
            {
                //if(string.valueOf(por.PMP_Partner_Offering_Resource_URL_Txt__c).equalsIgnoreCase('www.google.com'))
                    //por.PMP_Partner_Offering_Resource_URL_Txt__c = null;
                System.debug('URL#' + i + ''+ por.PMP_Partner_Offering_Resource_URL_Txt__c);
                i+=1;
                
            }
           
            update objPartnerOfferingLst; 
            //test code ends */
            
            
            if(objType.equalsIgnoreCase('PMP_Partner_Offering_Resource__c')) //Check the object type and cast the query result
        	{
                objPartnerOfferingLst = (List<PMP_Partner_Offering_Resource__c>)imgObj; 
                    
                  for(PMP_Partner_Offering_Resource__c lst:objPartnerOfferingLst)
                        imgLst.put(lst.Id,lst.PMP_Partner_Offering_Resource_URL_Txt__c);                                       
       		 }
       	   else
           {
         	objCompanyOfferingLst = (List<PMP_Company_Resource__c>)imgObj; 
            
            for(PMP_Company_Resource__c lst:objCompanyOfferingLst)
               	imgLst.put(lst.Id,lst.PMP_Company_Resource_URL_txt__c);
           }
            
        System.debug('List of images to be processed: ' + imgLst);
            
        docIdlst = downloadImage(imgLst);
                                    
        uploadImage(docIdlst); // Call the UploadImage function  
            
        
            
        }
        
        catch(Exception e){system.debug('Error occured due to '+ e.getMessage());}
                
    }
    
    
    public void finish(Database.BatchableContext bc) 
    {
        System.debug('Offerimg Image Upload Batch complete');
        
    }
    
    //Build the query to fetch image URL
    public string buildQuery(string imgType)
    {
       
        if(imgType.equalsIgnoreCase('PMP_Partner_Offering_Resource__c'))
            return 'Select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Resource_URL_Txt__c, PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c FROM PMP_Partner_Offering_Resource__c '+ 
            'WHERE PMP_Partner_Offering_Image__c=NULL and PMP_Partner_Offering_Resource_URL_Txt__c <> NULL AND PMP_Partner_Offering_Resource_URL_Txt__c <> \'NULL\' and PMP_Resource_Type_Nm__c = \'Image\''; 
        
        return 'SELECT Id, Name, PMP_Company_Id__c, PMP_Company_Resource_Sequence_Nbr__c, PMP_Company_Image__c, PMP_Company_Resource_URL_txt__c, PMP_Company_Resource_Type_Nm__c FROM PMP_Company_Resource__c '+
            'WHERE PMP_Company_Image__c =NULL and PMP_Company_Resource_URL_txt__c  <> NULL AND PMP_Company_Resource_URL_txt__c  <> \'NULL\' and PMP_Company_Resource_Type_Nm__c =\'Image\''; 
        
       /* return 'SELECT Id, Name, PMP_Company_Id__c, PMP_Company_Resource_Sequence_Nbr__c, PMP_Company_Image__c, PMP_Company_Resource_URL_txt__c, PMP_Company_Resource_Type_Nm__c FROM PMP_Company_Resource__c WHERE PMP_Company_Resource_URL_txt__c  <> NULL and PMP_Company_Resource_Type_Nm__c =\'Image\''; */
       
        
       /* return 'Select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Resource_URL_Txt__c, PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c FROM PMP_Partner_Offering_Resource__c WHERE  PMP_Resource_Type_Nm__c = \'Image\' and PMP_Partner_Offering_Resource_URL_Txt__C = null';*/
    }
    
 
    public Map<Id,blob> downloadImage( Map<Id,string> IdUrlLst)
    {
        
        string imgURL;
        Map<Id,blob> ImageIdlst = new Map<Id,blob>(); 
        
        try
        {
            for(Id idlst: IdUrlLst.keyset()) //Iterate throught the list and download the images
            {
            	            	
            	Http h = new Http(); 
        		HttpRequest req = new HttpRequest();
            
            	imgURL = IdUrlLst.get(idlst);
                    
                imgURL = imgURL.replace(' ', '%20');
                req.setEndpoint(imgURL);
                req.setMethod('GET'); //If you want to get a PDF file the Content Type would be 'application/pdf' 
                req.setHeader('Content-Type', 'image/jpeg'); req.setCompressed(true);
                req.setTimeout(60000); 
                HttpResponse res = null; 
                res = h.send(req); //These next three lines can show you the actual response for dealing with error situations
                string responseValue = ''; 
                responseValue = res.getBody(); 
                //system.debug('Response Body for File: ' + responseValue); 
                blob image = res.getBodyAsBlob();
            	
            	ImageIdlst.put(idlst, image); 		
                
                                        	
            } 
        }
         catch(Exception e){system.debug('Error occured due to '+ e.getMessage());}
       		                
        	 return ImageIdlst;
    }
    
    //Function to update content version and Id     
    public void uploadImage(Map<Id,blob> imgLst)
    {
        List<ContentVersion> lstContVer = new List<ContentVersion>();
        Map<string,Id> contIdlst = new Map<string,Id>();
        string ParentId;
        
         try
         {
             //Network Id of Partner Solutions Market place community
            Network psmNetwork = [SELECT Id FROM Network WHERE Name =: PMP_Utility.getValue('Marketplace_Community_Name') ];
            Id networkId;
            if(psmNetwork != null){
              networkId = psmNetwork.Id;
            }
             for(Id idlst:imgLst.keyset())
             {
                 ContentVersion cont = new ContentVersion();
                 cont.Title = 'Title for this contentVersion' + '_' + idlst;
                 cont.PathOnClient = 'file_' + Datetime.now().getTime() + '.png';
                 cont.VersionData = imgLst.get(idlst);
                 cont.Origin = 'H';
                 cont.NetworkId = networkId; //ID of the community that this file originated from
                 lstContVer.add(cont);
             }
             
             insert lstContVer; //Insert into Content version
             
             //Fetch parent Id and ContentDocument Id
             for(ContentVersion cont:[select Title,ContentDocumentId from ContentVersion where CreatedDate= TODAY])
             {
                 parentId = cont.Title.split('_').get(1);
                 contIdlst.put(parentId, cont.ContentDocumentId);
             }
             
             //Update ContentDocumentId into parent object
             if(imgType.equalsIgnoreCase('PMP_Partner_Offering_Resource__c'))
             {
                  for(PMP_Partner_Offering_Resource__c por:objPartnerOfferingLst)
      			  {
	        		    if(ContIdlst.containsKey(por.Id))
           			    {
              			  por.PMP_Partner_Offering_Image__c = ContIdlst.get(por.Id);
               			  por.PMP_Partner_Offering_Resource_URL_Txt__c = null;
                        }
                  }
                 PMP_OfferingResourceTriggerHelper.createContentDistribution(objPartnerOfferingLst);//method call added by raj to create contentDistribution records for offering resources
                 update objPartnerOfferingLst;
             }
             else
             {
                 for(PMP_Company_Resource__c por:objCompanyOfferingLst)
      			  {
	        		    if(ContIdlst.containsKey(por.Id))
           			    {
              			  por.PMP_Company_Image__c = ContIdlst.get(por.Id);
               			  por.PMP_Company_Resource_URL_txt__c = null;
                        }
                  }
                 update objCompanyOfferingLst;
             }
           		  
             
         }
        
        	catch(Exception e){system.debug('Error occured due to '+ e.getMessage());}
        
                
       /*  for(String lst:ContentIdLst)
       	 {
          	System.debug('List of Ids ' + lst);
         } */
    }
    
    
}