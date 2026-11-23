public class Core_IPS_EoisErrorController {
   public string ErrorMsg{get;set;}
   public string ErrorCode{get;set;}
   public string retURL{get;set;}
   private User CurrentUser ;
   public Core_IPS_EoisErrorController()
   {
      if(ApexPages.currentPage().getParameters().get('ErrCode') !=null)
      {
        ErrorCode  = ApexPages.currentPage().getParameters().get('ErrCode');
        system.debug('########'+ErrorCode);
      }
      else
      {
       ErrorCode = 'Default101';
      }
      
      CurrentUser = [select Id,ProfileId,Profile.Name from User  where id= :userInfo.getUserID()];
      
      if(ApexPages.currentPage().getParameters().get('retURL') !=null && (userinfo.getusertype() == 'PowerCustomerSuccess' || userinfo.getusertype() =='PowerPartner'))
      {
        retURL = ApexPages.currentPage().getParameters().get('retURL').split('/')[ApexPages.currentPage().getParameters().get('retURL').split('/').size()-1];  
        system.debug('########'+retURL);  
        retURL  = '/IPS/' + retURL;
      }
      else if(ApexPages.currentPage().getParameters().get('retURL') !=null){
        retURL  =  ApexPages.currentPage().getParameters().get('retURL');  
      }
      else
      {
        retURL = returnURLUpdate();
      }
      ErrorMsg = '' ;
   }
    public void PageInit()
    {
        ErrorMsg = errormessage(ErrorCode);
    }
    public pagereference goBack()
    {
       //string CurrentUrl = Apexpages.currentPage().getUrl();
       //system.debug('>>>>>>>>>>>>>' + CurrentUrl);
       //string strUrl = URL.getSalesforceBaseUrl().getHost();
       //string CurrentUrl = 'https://'+strUrl+ retURL;
       system.debug('@@@@@@@@@@@@'+retURL);
       pagereference Pg = new  pagereference(retURL) ;
       pg.setredirect(true);
       return Pg;
         
    }
   /***************************************************************************************************
    Method Name:  errormessage
    Method Type: Helper Method 
    Version     : 1.0 
    Created Date: 01 Jul 2015
    Function    : This method Gets the error message from Core_IPS_Error_Code custom setting.
    Input Parameters: Error code
    Output Parameters: Returns error message
    Description: All the error messages are added in Custom setting and this method gets the error message from error code.
    Used in     : Case Creation
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Jayaprakash T              07/01/2015              Created
    ****************************************************************************************************/    
    public string errormessage(string errorCode){
        string defaultmessage ='';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultmessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultmessage;
    }
    private string returnURLUpdate()
    {
     string  retURL;
     if(userinfo.getusertype() =='Standard')
        {
            retURL = '/home/home.jsp';
        }
        else if(userinfo.getusertype() == 'PowerCustomerSuccess'|| userinfo.getusertype() =='PowerPartner')
        {
            retURL = '/500/o';
        }
        else if(userinfo.getusertype() =='PowerPartner' || userinfo.getusertype() =='CustomerSuccess' || userinfo.getusertype() == 'PowerCustomerSuccess')
        {
             retURL = '/home/home.jsp';
        }
        else
        {
           retURL = '/home/home.jsp';
        }
      return retURL;
    }
}