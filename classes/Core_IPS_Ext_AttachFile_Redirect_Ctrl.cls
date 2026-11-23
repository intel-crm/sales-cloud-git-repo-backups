/***************************************************************************************************
Apex Class Name:  Core_IPS_Ext_AttachFile_Redirect_Ctrl.
US no          :  Iteration 13,US108333.
Version        :  1.0 
Created Date   :  19/06/2018
Function       :  Controller for VF page to Add Attachments on the Case Detail Page Button.
Modification Log :
*Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------              
* Raj Kommera            19/06/2018                Created
****************************************************************************************************/
public class Core_IPS_Ext_AttachFile_Redirect_Ctrl{
    public string caseid{get;set;} 
    @TestVisible public String privateToPartnerURL{get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;}}
    public String publicFileURL{get{ return '/IPS/Core_IPS_File_AttachToCase?id='+caseid+'&&Type='+Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}}
    public Boolean isPartnerFAE{get;set;}
    public PageReference requestPage;
    
    public Core_IPS_Ext_AttachFile_Redirect_Ctrl(ApexPages.StandardController controller){
        caseid = controller.getId();
    }
    
    //Action Method to redirect page
    public PageReference redirectPage(){//Verify the Profile from the Util method
        //PageReference requestPage;
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(userinfo.getProfileId().substring(0,15))){
            system.debug('User: IPS External Customer');
            requestPage =  new pagereference(publicFileURL);//IPS External Customer User 
        }
        else{
            isPartnerFAE = (Core_Utility.getPartnerUserType(userinfo.getuserId())).contains('Partner - DFAE');
            if(isPartnerFAE){
                system.debug('User: FAE Partner');
                requestPage =  null;//FAE Partner 
            }else{
                system.debug('User: IPS Partner');
                requestPage =  new pagereference(publicFileURL);//IPS Partner
            }
        }
        return requestPage;
    }
    
    //Return to Case Button
    public PageReference returnToCasePage(){
        PageReference returnToCase;
        // The page will be redirected to the selected case.
        if (System.currentPageReference().getParameters().get('id') != null) {
            returnToCase = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            returnToCase.setRedirect(true);
        }
        return returnToCase;
    }
}