/******************************************************************************************************************************************
Class Name  : Core_CloneSolutionArea
Version     : 1.0 
Function    : Clone of solution area to record
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Shijas KM       03/17/2023   Original version
*****************************************************************************************************************************************/

public without sharing class Core_CloneSolutionArea {
    
    @AuraEnabled public List<Core_Solution_Areas__c> Solution_Area;
    
    @AuraEnabled(cacheable=true)
    public static List<Core_Solution_Areas__c> getRecord(Id Solution_AreaId) {
        try{
            
            List<Core_Solution_Areas__c> solns= new List<Core_Solution_Areas__c>();
            
            solns = [select Id, OwnerId,  Name,  Core_Deal_Visible__c, Core_Design_Visible__c,  Core_Solution_Type__c,  Core_Solution_Description__c, Core_Version__c,  Core_Industry_Use_Case__c,  Core_Technology_Enabled__c, Core_Solution_owner_email__c, Core_Content_Link__c, Core_Industry__c, Core_Region_of_availability__c,  Core_Region_Deployed__c, Core_Application_Workload__c, Core_Solution_Long__c,  Core_End_Customer_Solution__c, Core_Solution_Title__c, Core_Status__c, Core_Most_Recent_Status_Change_Date__c from Core_Solution_Areas__c where Id =: Solution_AreaId];
            solns =  Validate_Solution_PValues(solns);          
            return solns;
        }
        catch(exception ex)
        {
            PMP_Utility.logError(ex, 'Core_CloneSolutionArea.getRecord');                  
            return null; 
        }
    }
    @AuraEnabled
    public static String CreateRecord(Id Solution_AreaId,Core_Solution_Areas__c Solution, Boolean create_partner ) {
        String status= null;
        try{      
            String ValidationMsgStatic='Please select below details \n ';
            String str_validation  = ValidateSolutionData(Solution);
            if (str_validation.length()>0)
            {
                status=   ValidationMsgStatic  + str_validation;
                throw new AuraHandledException(status);
                
            }
            
            
            String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
            Integer usrPermissionsetCnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Core_CRM_Special_Access'];
            
            if((usrProfileName == 'IT Admin' || usrProfileName == 'System Administrator' || usrProfileName == 'Data Ops' || usrPermissionsetCnt > 0 ) && (Solution!= null && Solution_AreaId!= null))
            {
                // any solution already exist with this name and version number
                Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :Solution.Core_Version__c  and name= :Solution.Name];
                if ( SolnCnt == 0)
                {
                    status=  insertSolution(Solution, Solution_AreaId, create_partner );
                }
                else
                {
                    status= Label.Core_Solution_exist;
                    
                    throw new AuraHandledException(status);
                    
                }
            }
            else{
                status= 'Your profile is not allowed to create a new solution';
                throw new AuraHandledException(status);
                
            }
            
        }
        catch(AuraHandledException ex)
        {
            PMP_Utility.logError(ex, 'Core_CloneSolutionArea.CreateRecord');    
            throw ex;
            
        }
        
        catch(exception ex)
        {
            status= 'Error occured please try again';
            String errorMsg = '_EXCEPTION,' + ex.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(status);
            
        }
        return status;
        
    }
    /*
@AuraEnabled (cacheable=true)
public static Core_Solution_Areas__c getObjectInfo(){
return [SELECT Id, Core_Industry_Use_Case__c, Core_Application_Workload__c, Core_Technology_Enabled__c FROM Core_Solution_Areas__c limit 1];
}
*/
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Application_Workload(){
        
        List<String>  Application_Workload = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Application_Workload.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return Application_Workload;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_Application_Workload');
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Industry_UseCase(){
        
        List<String>  Industry_UseCase = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Industry_UseCase.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return Industry_UseCase;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_Industry_UseCase');
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Industry(){
        
        List<String>  Industry = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Industry__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Industry.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return Industry;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_Industry');
            return null;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Region_Availability(){
        
        List<String>  Region_Availability = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Region_of_availability__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            //System.debug('Get_Types_Region_Availability PicklistValues' +PicklistValues.size());
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Region_Availability.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return Region_Availability;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_Region_Availability');
            return null;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_TechnologyEnabled(){
        
        List<String>  TechnologyEnabled = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            //System.debug('Get_Types_TechnologyEnabled PicklistValues' +PicklistValues.size());
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                TechnologyEnabled.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return TechnologyEnabled;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_TechnologyEnabled');
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Status(){
        
        List<String>  Status = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Status__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            //System.debug('Get_Types_Status PicklistValues' +PicklistValues.size());
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Status.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return Status;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_Status');
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_SolutionType(){
        
        List<String>  SolutionType = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Solution_Type__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            //System.debug('Get_Types_SolutionType PicklistValues' +PicklistValues.size());
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                SolutionType.add(picklistValue.getLabel()+'|'+ picklistValue.getValue());
            } 
            
            return SolutionType;
        } catch (Exception e) {
            PMP_Utility.logError(e, 'Core_CloneSolutionArea.Get_Types_SolutionType');
            return null;
        }
    }
    /*
* Method name  : insertClonedSolution
* Description  : This method will be insert the Clone solution 
* Return Type  : String 
* Parameter    :
*/         
    public static String insertSolution(Core_Solution_Areas__c solnRec,Id Solution_AreaId, Boolean create_partner ){
        String strError='';
        try{      
            
            solnRec.Id  = NULL;      
            //solnRec.Name  = 'Clone of ' + solnRec.Name;      
            solnRec.Core_Status__c= 'Active';
            solnRec.OwnerId = UserInfo.getUserId();
            solnRec.Core_Most_Recent_Status_Change_Date__c= null;
            if(!create_partner){
                solnRec.Core_Concatenated_Solution_Partners__c = NULL;           
            }
            Database.SaveResult  response = Database.insert(solnRec, true);
            if (response.isSuccess() ) {
                
                strError= response.getId();
                // add partner to the solution
                List<Core_Solution_Area_Partner__c> Soln_Partners= new List<Core_Solution_Area_Partner__c>();
                List<Core_Solution_Area_Partner__c> Insert_Soln_Partners= new List<Core_Solution_Area_Partner__c>();
                Soln_Partners = [select  Core_Solution_Area__c, Solution_Partner_Type__c, Core_Solution_Partner_Role__c, Core_Solution_Partner__c from Core_Solution_Area_Partner__c where Core_Solution_Area__c= :Solution_AreaId]; 
                if(Soln_Partners.size()>0 && create_partner){
                    for(Core_Solution_Area_Partner__c soln_Partner: Soln_Partners){ 
                        
                        Core_Solution_Area_Partner__c Partner= new Core_Solution_Area_Partner__c();
                        Partner.Core_Solution_Area__c    = response.getId();
                        Partner.Solution_Partner_Type__c= soln_Partner.Solution_Partner_Type__c;
                        Partner.Core_Solution_Partner_Role__c = soln_Partner.Core_Solution_Partner_Role__c;
                        Partner.Core_Solution_Partner__c= soln_Partner.Core_Solution_Partner__c;
                        
                        Insert_Soln_Partners.add(Partner);
                    }
                    
                    Database.insert(Insert_Soln_Partners, true);
                }
                else{
                    //System.debug('CloneSolution--No partners for insertion ');
                }
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : response.getErrors()) {
                    strError= 'Error Occured Pls try again.';                   
                }
            }
        }catch (Exception e) {
            strError= '_EXCEPTION, Error Occured Pls try again.'; 
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(pureErrorMsg);
            
        }
        return strError;
    }
    //Validate Solution Picklist Values
    public static List<Core_Solution_Areas__c> Validate_Solution_PValues (List<Core_Solution_Areas__c> solns)
    {
        //List<Core_Solution_Areas__c> solnsResponse= new List<Core_Solution_Areas__c>(); 
        //------------ for Core_Application_Workload__c validation starting ---------------
        List<String>  Data = new List<String>();
        List<Map<String,String>> selectOpt = new List<Map<String,String>>();
        List<selectOption> options = new List<selectOption>();
        Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
        Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
        List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
        //System.debug('Get_Types_Application_Workload PicklistValues' +PicklistValues.size());
        for (Schema.PicklistEntry picklistValue : PicklistValues) {
            // Data.add(picklistValue.getLabel());
            Data.add(picklistValue.getValue());
            
        }
        for(Core_Solution_Areas__c Sol : solns){ 
            if (Sol.Core_Application_Workload__c!= null)
            {
                string strApplication_Workload='';
                List<String> App_workload = Sol.Core_Application_Workload__c.split(';');                
                for (string app_wl : App_workload) {
                    if (Data.contains(app_wl))
                    {
                        if(strApplication_Workload.length()>0)
                        {
                            strApplication_Workload = strApplication_Workload + ';' + app_wl;  
                        }
                        else
                        {
                            strApplication_Workload =  app_wl;
                        }
                    }
                }
                Sol.Core_Application_Workload__c= strApplication_Workload;
            }
            
            // -------------for Core_Application_Workload__c validation ending -------------------
            List<String>  TechnologyEnabled = new List<String>();
            selectOpt = new List<Map<String,String>>();
            options = new List<selectOption>();
            
            
            Describe = Schema.sObjectType.Core_Solution_Areas__c;
            FieldDescribe = Describe.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
            PicklistValues = FieldDescribe.getPicklistValues();
            //System.debug('Get_Types_TechnologyEnabled PicklistValues' +PicklistValues.size());
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                //  TechnologyEnabled.add(picklistValue.getLabel());
                TechnologyEnabled.add(picklistValue.getValue());
                
            } 
            
            
            if (Sol.Core_Technology_Enabled__c!= null)
            {
                string strTechnology_Enabled ='';
                List<String> Tech_Enabled = Sol.Core_Technology_Enabled__c.split(';');                
                for (string strValue : Tech_Enabled) {                      
                    if (TechnologyEnabled.contains(strValue))
                    {
                        if (strTechnology_Enabled.length()>0)
                        {
                            strTechnology_Enabled = strTechnology_Enabled + ';' + strValue;  
                        }
                        else
                        {
                            strTechnology_Enabled =  strValue;
                        }
                        
                    } 
                }
                Sol.Core_Technology_Enabled__c= strTechnology_Enabled;
            }
            
            
            // -------------for Core_Technology_Enabled__c validation ending -------------------
            List<String>  Industry_UseCase = new List<String>();
            selectOpt = new List<Map<String,String>>();
            options = new List<selectOption>();            
            
            Describe = Schema.sObjectType.Core_Solution_Areas__c;
            FieldDescribe = Describe.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
            PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                // Industry_UseCase.add(picklistValue.getLabel());
                Industry_UseCase.add(picklistValue.getValue());
                
            } 
            
            
            if (Sol.Core_Industry_Use_Case__c!= null)
            {
                string strIndustry_Use_Case='';
                List<String> Tech_Enabled = Sol.Core_Industry_Use_Case__c.split(';');                
                for (string strValue : Tech_Enabled) {                      
                    if (Industry_UseCase.contains(strValue))
                    {
                        if (strIndustry_Use_Case.length()>0)
                        {
                            strIndustry_Use_Case = strIndustry_Use_Case + ';' + strValue;  
                        }
                        else
                        {
                            strIndustry_Use_Case =  strValue;
                        }
                        
                    } 
                }
                Sol.Core_Industry_Use_Case__c= strIndustry_Use_Case;
            }
            
            
            // -------------for Core_Industry_Use_Case__c validation ending -------------------
            List<String>  Region_Availability = new List<String>();
            selectOpt = new List<Map<String,String>>();
            options = new List<selectOption>();            
            
            Describe = Schema.sObjectType.Core_Solution_Areas__c;
            FieldDescribe = Describe.fields.getMap().get('Core_Region_of_availability__c').getDescribe();
            PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                // Region_Availability.add(picklistValue.getLabel());
                Region_Availability.add(picklistValue.getValue());
            } 
            
            
            if (Sol.Core_Region_of_availability__c!= null)
            {
                string strRegion_of_availability='';
                List<String> Tech_Enabled = Sol.Core_Region_of_availability__c.split(';');                
                for (string strValue : Tech_Enabled) {                      
                    if (Region_Availability.contains(strValue))
                    {
                        if (strRegion_of_availability.length()>0)
                        {
                            strRegion_of_availability = strRegion_of_availability + ';' + strValue;  
                        }
                        else
                        {
                            strRegion_of_availability =  strValue;
                        }
                        
                    } 
                }
                Sol.Core_Region_of_availability__c= strRegion_of_availability;
            }
            
            
            // -------------for Core_Region_of_availability__c validation ending -------------------          
            List<String>  Industry = new List<String>();
            selectOpt = new List<Map<String,String>>();
            options = new List<selectOption>();
            
            Describe = Schema.sObjectType.Core_Solution_Areas__c;
            FieldDescribe = Describe.fields.getMap().get('Core_Industry__c').getDescribe();
            PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                // Industry.add(picklistValue.getLabel());
                Industry.add(picklistValue.getValue());
            } 
            
            
            if (Sol.Core_Industry__c!= null)
            {
                string strCore_Industry='';
                List<String> Core_Industry = Sol.Core_Industry__c.split(';');                
                for (string strValue : Core_Industry) {                      
                    if (Industry.contains(strValue))
                    {
                        if (strCore_Industry.length()>0)
                        {
                            strCore_Industry = strCore_Industry + ';' + strValue;  
                        }
                        else
                        {
                            strCore_Industry =  strValue;
                        }
                        
                    } 
                }
                Sol.Core_Industry__c= strCore_Industry;
            }
            
        }        
        // -------------for Core_Industry__c validation ending ------------------- 
        
        return solns;
    }
    
    public static String ValidateSolutionData(Core_Solution_Areas__c Solution)
    {
        String ValidationError='';
        try
        {
            
            if (Solution.Core_Solution_Type__c== null )
            {
                ValidationError = ValidationError + 'Solution Type  ,';
                
            }
            
            if (Solution.Core_Solution_Description__c== null )
            {
                
                ValidationError = ValidationError + 'Solution Description , ';
                
            }
            
            if (Solution.Core_Technology_Enabled__c== null )
            {
                
                ValidationError = ValidationError + 'Technology Enabled , ';
                
            }
            
            if (Solution.Core_Solution_owner_email__c== null )
            {
                
                ValidationError = ValidationError + 'Solution Owner E-mail , ';
                
            }
            
            if (Solution.Name== null )
            {
                
                ValidationError = ValidationError + 'Solution name , ';
                
            }
            /*
if (Solution.Core_Industry__c== null )
{

ValidationError = ValidationError + 'Industry \n ';

}
*/
            if (Solution.Core_Application_Workload__c== null )
            {
                
                ValidationError = ValidationError + 'Application Workload  ,';
                
            }
            
            
            if (Solution.Name== null )
            {
                
                ValidationError = ValidationError + 'Solution Name , ';
                
            }
            
            
            if (Solution.Core_Solution_Description__c== null )
            {
                
                ValidationError = ValidationError + 'Solution Description , ';
                
            }
            
            if (Solution.Core_Solution_owner_email__c== null )
            {
                
                ValidationError = ValidationError + 'Solution Owner Email , ';
                
            }
            
        }
        catch (Exception ex)
        {
            PMP_Utility.logError(ex, 'Core_CloneSolutionArea.ValidateSolutionData');
        }
        
        return ValidationError;
        
        
        
    }
    
    
}