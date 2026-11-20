/**************************************************************************************
Apex Class Name:  Core_EloquaProfilerController
Version     : 1.0 
Created Date: 19 JUNE 2020
Function    : Controller class for Eloqua Profiler Component
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             06/19/2020              Original Version

*************************************************************************************/
public without sharing class Core_EloquaProfilerController {
    
    /*************
    * Method name  : getUserSessionData
    * Description  : Get the email from the record to make the full URL
    * Return Type  : STRING
    * Parameter    : Id rId
    **************/
    @AuraEnabled
    public static String getUserSessionData(Id rId){
        String email=''; 
        String sObjName = rId.getSObjectType().getDescribe().getName();
        if(sObjName == 'contact'){
            List<contact> cn = [Select id,email from contact where id =:rId limit 1];
            email = cn[0].email;
        }    
        else if(sObjName == 'lead'){
            List<lead> ld = [Select id,email from lead where id =:rId limit 1];
            email = ld[0].email;
        }        
        return (email);
    }
       
}