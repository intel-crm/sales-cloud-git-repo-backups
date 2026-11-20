/****************************************************************************************************
Apex Class Name : Core_DDR_Stage_Validator
Version         : 1.0 
Created Date    : 10/12/2017
Function        : This class is to used to segregate the Design and product from design stage record, validate the records and create the respective records and log the errors(If any) in design registration stage 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Team Accenture              10/12/2017            Created
*****************************************************************************************************/

public with sharing Class Core_DDR_Stage_Validator
{
    
    Id PartnerAccountId;
    
    //To get the log switch details 
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    public static Map<string, string> picklistMap = new Map<string, string>();
    
    public Core_DDR_Stage_Validator()
    {
        
    }
    
    //To check the values in number fields are numeric
    public static Boolean isNumeric(String s)
    {
        Boolean ReturnValue;
        try
        {
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) 
        {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    //To check the picklist fields values are allowed or restricted 
    public Set<String> getPickListValuesIntoList(String ObjectName, String FieldName)
    {
        Set<String> pickListValuesList= new Set<String>();   
        
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(FieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            
            String pickListLabel = pickListVal.getLabel();
            pickListValuesList.add(pickListLabel);
            picklistMap.put(pickListVal.getLabel(),pickListVal.getValue());
            
        }
          
        return pickListValuesList;
    }
    
    //To check the date format
    public Boolean checkIsUSDatePattern(String DateValue)
    {
        String dateRegEx = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)';
        
        try
        {
            Pattern myPattern = Pattern.compile(dateRegEx);
            Matcher myMatcher = myPattern.matcher(DateValue);
            if(myMatcher.matches())
            {
                return TRUE;   
            }
            else
            {
                return FALSE;   
            }  
            
        }
        catch(Exception e)
        {
           // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
           
            return null;
        } 
    }
    
    //To check the basic validations before processing the Design registrations and its products
    public void checkValidations(List<Core_Design_Registration_Stage__c> lstDesignRegStage)
    {
        List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = [SELECT id, Name, Core_Active_Ind__c, 
                                                                                Core_CSV_Column_Nm__c, Core_Design_API_Field_Nm__c, Core_Design_Required_Ind__c, 
                                                                                Core_Field_Data_Type_Txt__c, Core_Header_Or_Product_Ind__c, Core_Stage_API_Field_Nm__c, 
                                                                                Core_Stage_Required_Ind__c FROM Core_Design_Registrations_Bulk_Upload__c 
                                                                                WHERE Core_Active_Ind__c = TRUE];
        
        List<Core_Design_Registration_Stage__c> lstUpdateDesignRegStg = new List<Core_Design_Registration_Stage__c>();
        List<Core_Design_Registration_Stage__c> lstDesignRegStgForIns = new List<Core_Design_Registration_Stage__c>();
        
        try
        {
            
            //Checking the required fields
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                String ErrorText = 'Following required field(s) are missing:';
                Boolean AddErrorText = TRUE;
                
                if(iDesignRegStg.Core_Message_Txt__c == NULL)
                {
                    iDesignRegStg.Core_Message_Txt__c = '';
                }
                
                //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be send to creation method
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && iDesignRegStg.get('Core_Design_Registration_Line_ID__c') == '')
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Design_Required_Ind__c == TRUE && (iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) == ''))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }
                    }
                    else if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Header' && iDesignRegStg.get('Core_Registration_Number_Id__c') == '')
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Design_Required_Ind__c == TRUE && (iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) == ''))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }
                    }
                }    
            }
            
            //Checking the number field values for non numeric values
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                String ErrorText = 'Please provide numeric value for the field(s):';
                Boolean AddErrorText = TRUE;
                
                if(iDesignRegStg.Core_Message_Txt__c == NULL){iDesignRegStg.Core_Message_Txt__c = '';}
                //Iterating all the fields for checking the number field values.
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && iDesignRegStg.get('Core_Design_Registration_Line_ID__c') == '' )
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Number' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && !(isNumeric((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }
                    }
                    else if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Header' && iDesignRegStg.get('Core_Registration_Number_Id__c') == '')
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Number' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && !(isNumeric((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }
                    }
                }    
            }            
            
            //Checking the date formats
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                String ErrorText = 'Please provide the date(s) with the format \'MM/DD/YYYY\':';
                Boolean AddErrorText = TRUE;
                
                if(iDesignRegStg.Core_Message_Txt__c == NULL){iDesignRegStg.Core_Message_Txt__c = '';}
                
                //Iterating all the fields for checking the required field is filled or not. Records which have all the required fields will be send to creation method
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && iDesignRegStg.get('Core_Design_Registration_Line_ID__c') == '')
                    {
                        /* //For Test coverage - In future, if you add date field to product uncomment this line
if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Date' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && (!checkIsUSDatePattern((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
{
iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';

if(AddErrorText)
{
iDesignRegStg.Core_Message_Txt__c += ErrorText;                            
AddErrorText = FALSE;
}
iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
}
*/    
                    }
                    else if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Header' && iDesignRegStg.get('Core_Registration_Number_Id__c') == '')
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Date' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && (!checkIsUSDatePattern((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;                            
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }                        
                    }
                }    
            }
            
            //Checking the picklist values to identify any restricted values are there in values
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                String ErrorText = 'Please check the picklist values entered:';
                Boolean AddErrorText = TRUE;
                
                if(iDesignRegStg.Core_Message_Txt__c == NULL){iDesignRegStg.Core_Message_Txt__c = '';}
                
                //Iterating all the fields for checking the picklists
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && iDesignRegStg.get('Core_Design_Registration_Line_ID__c') == '')
                    {
                        /*//For Test coverage - In future, if you add date field to product uncomment this line
if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Date' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && (!getPickListValuesIntoList('Core_Design_Registration__c',iBU.Core_Stage_API_Field_Nm__c).contains((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
{
iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';

if(AddErrorText)
{
iDesignRegStg.Core_Message_Txt__c += ErrorText;                            
AddErrorText = FALSE;
}
iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
}*/
                    }
                    else if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Header' && iDesignRegStg.get('Core_Registration_Number_Id__c') == '')
                    {
                        if(iBU.Core_Header_Or_Product_Ind__c == iDesignRegStg.get('Core_Header_Or_Product_Ind__c') && iBU.Core_Field_Data_Type_Txt__c == 'Picklist' && (String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c) != '' && (!getPickListValuesIntoList('Core_Design_Registration__c',iBU.Core_Stage_API_Field_Nm__c).contains((String)iDesignRegStg.get(iBU.Core_Stage_API_Field_Nm__c))))
                        {
                            iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                            
                            if(AddErrorText)
                            {
                                iDesignRegStg.Core_Message_Txt__c += ErrorText;                            
                                AddErrorText = FALSE;
                            }
                            iDesignRegStg.Core_Message_Txt__c += iBU.Core_CSV_Column_Nm__c +',';
                        }                        
                    }
                }    
            }
            
            //Checking product name for valid design eligible product
            Set<String> setProdName = new Set<String>();
            Map<String, Id> mapProdNameTOProdId = new Map<String, Id>();
            
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product' && (String)iDesignRegStg.get('Core_Product_Id__c') != '')
                {
                    setProdName.add((String)iDesignRegStg.get('Core_Product_Id__c'));  
                }
            }   
            
            if(setProdName.size() > 0)
            {
                for(Product2 iProd : [SELECT id, Name From Product2 WHERE  Name IN: setProdName AND Core_Design_Registration_Eligible_Ind__c = TRUE AND isActive = TRUE AND Core_Sales_Visible_Flag__c = TRUE with USER_MODE])
                {
                    mapProdNameTOProdId.put(iProd.Name.toUpperCase(), iProd.Id);
                }            
            }  
            
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                String ErrorText = 'Not a valid product name';
                Boolean AddErrorText = TRUE;
                
                if(iDesignRegStg.Core_Message_Txt__c == NULL){iDesignRegStg.Core_Message_Txt__c = '';}
                
                if(iDesignRegStg.get('Core_Header_Or_Product_Ind__c') == 'Product')
                {
                    if((String)iDesignRegStg.get('Core_Product_Id__c') != '' && (!mapProdNameTOProdId.containskey(((String)iDesignRegStg.get('Core_Product_Id__c')).toUpperCase())))
                    {
                        iDesignRegStg.Core_Processing_Status_Nm__c = 'Failed';
                        
                        if(AddErrorText)
                        {
                            iDesignRegStg.Core_Message_Txt__c += ErrorText;                            
                            AddErrorText = FALSE;
                        }
                    }
                }
            } 
            
            //Seperate the failed records from list for update stage records with proper message and adding the unfailed records for processing                                
            for(Core_Design_Registration_Stage__c iDesignRegStg : lstDesignRegStage)
            {
                if(iDesignRegStg.Core_Processing_Status_Nm__c == 'Failed')
                {
                    lstUpdateDesignRegStg.add(iDesignRegStg);
                }
                else
                {
                    if(iDesignRegStg.Core_Header_Or_Product_Ind__c == 'Header' && iDesignRegStg.Core_Owner_Txt__c == ''){iDesignRegStg.Core_Owner_Txt__c =  UserInfo.getUserEmail();   } 
                    
                    lstDesignRegStgForIns.add(iDesignRegStg);
                }
            }
            
        }
        catch(Exception e)
        {
           // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
           
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }         
        } 
        
        try
        {
            update lstUpdateDesignRegStg;
            //added for test
            if(Test.isRunningTest()){throw new System.DMLException();}
        }
        catch(Exception e)
        {
           // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }              
        }
        
        
        //Find the partner account Id
        if(lstDesignRegStgForIns.size() > 0 && lstDesignRegStgForIns[0].Core_Batch_ID__c != NULL)
        {
            
            Core_Design_Registration_Batch__c designBatch = new Core_Design_Registration_Batch__c();
            designBatch = [SELECT id, Name, Core_Partner_Account_Id__c FROM Core_Design_Registration_Batch__c WHERE Id =: lstDesignRegStgForIns[0].Core_Batch_ID__c with USER_MODE];
            
            PartnerAccountId = designBatch.Core_Partner_Account_Id__c;
            
            //To create the DR & DRLI records 
            createDesignReg(lstDesignRegStgForIns);
        }
        
    }
    
    //To retrieve users associated with the loggedin user's partner contact and users belongs to the same partner Account.
    private Map<String, String> getMapLoggedUserPartnerContacts()
    {
        List<User> lstUser = [SELECT Id, AccountId, ContactId, Email FROM User WHERE AccountId =: PartnerAccountId AND isActive = TRUE];
        Map<String, String> mapLoggedInUserAccountRelatedUserIds = new Map<String, String>();
        for(User iUser : lstUser)
        {
            mapLoggedInUserAccountRelatedUserIds.put(iUser.Email, iUser.Id);    
        }
        
        return mapLoggedInUserAccountRelatedUserIds;
    }
    
    public void createDesignReg(List<Core_Design_Registration_Stage__c> lstDRStages)
    {
        Map<String, Core_Design_Registration__c> mapGrpIdTODesignReg = new Map<String, Core_Design_Registration__c>();
        Map<String, List<Core_Design_Registration_Product__c>> mapGrpIdTODesignRegProd = new Map<String, List<Core_Design_Registration_Product__c>>();
        Map<String, String> mapHeadGrpIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignStgIdTODesignRegId = new Map<String, String>();
        Map<String, String> mapDesignRegIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignRegIdTODesignRegName = new Map<String, String>();
        Map<String, String> mapDesignRegProdIdTODesignStgId = new Map<String, String>();
        Map<String, String> mapDesignRegProdIdTODesignProdName = new Map<String, String>();
        Map<String, String> mapProductNameToProductId = new Map<String, String>();
        Map<String, String> mapLoggedInUserAccountRelatedUserIds = new Map<String, String>();
        
        //Query custom setting values to map stage records to design registration and its product records
        List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = [SELECT id, Name, Core_Active_Ind__c, 
                                                                                Core_CSV_Column_Nm__c, Core_Design_API_Field_Nm__c, Core_Design_Required_Ind__c, 
                                                                                Core_Field_Data_Type_Txt__c, Core_Header_Or_Product_Ind__c, Core_Stage_API_Field_Nm__c, 
                                                                                Core_Stage_Required_Ind__c FROM Core_Design_Registrations_Bulk_Upload__c 
                                                                                WHERE Core_Active_Ind__c = TRUE];
        
       // List<Core_Design_Registration__c> lstInsertDesign = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration_Product__c> lstProcessDesignProduct = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Stage__c> lstUpdateDesignRegStg = new List<Core_Design_Registration_Stage__c>();
        
        Set<Id> setDesignRegSuccessIds = new Set<Id>();
     //   Set<Id> setDesignRegFailedStageRecIds = new Set<Id>();
        Map<id,String> mapDesignRegFailedStageRecIdsAndErrMsg = new Map<id,String>();
       // Set<Id> setDesignRegProdFailedStageRecIds = new Set<Id>();
        Set<Id> setDesignRegProdSuccessIds = new Set<Id>();
        Set<String> setProductNames = new Set<String>();
        Set<String> setUsrEmailIds = new Set<String>();
        Map<String,Id> mapAllActiveUsrsEmailAndIds = new Map<String,Id>();
        Map<Id, Core_Design_Registration_Stage__c> mapUpdateDRStg = new Map<Id, Core_Design_Registration_Stage__c>();
        
        for(Core_Design_Registration_Stage__c DRSObj : lstDRStages)
        {
            setUsrEmailIds.add(DRSObj.Core_Owner_Txt__c);
            setProductNames.add(DRSObj.Core_Product_Id__c);
        }
        
        if(setUsrEmailIds.size() > 0)
        {
            for(User usrObj : [SELECT Id,email, Name,IsActive FROM User WHERE email IN: setUsrEmailIds And IsActive=true]) 
            {
                mapAllActiveUsrsEmailAndIds.put(usrObj.email, usrObj.id);
            }
        }
        
        if(setProductNames.size() > 0)
        {
            for(Product2 iProd : [SELECT id, Name From Product2 WHERE  Name IN: setProductNames AND Core_Design_Registration_Eligible_Ind__c = TRUE AND isActive = TRUE AND Core_Sales_Visible_Flag__c = TRUE WITH USER_MODE])
            {
                mapProductNameToProductId.put(iProd.Name.toUpperCase(), iProd.Id);
            }
        }
        
        //Get the map of user Id to whom the logged In user can upload the design registrations   
        mapLoggedInUserAccountRelatedUserIds = getMapLoggedUserPartnerContacts();
        
        for(Core_Design_Registration_Stage__c iDRS : lstDRStages)
        {
            Core_Design_Registration__c designReg = new Core_Design_Registration__c ();
            Core_Design_Registration_Product__c designRegProd = new Core_Design_Registration_Product__c();
            
            //Field value assignment for Design Registration Header record 
            if(iDRS.Core_Header_Or_Product_Ind__c == 'Header')
            {
                mapHeadGrpIdTODesignStgId.put(iDRS.Core_Group_Id__c, iDRS.Id);
                
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    designReg.put('Core_Design_Registration_Stage_Id__c', iDRS.get('Id'));
                    
                    if(iBU.Core_Stage_API_Field_Nm__c != NULL && iBU.Core_Stage_API_Field_Nm__c != '' && iBU.Core_Design_API_Field_Nm__c != NULL && iBU.Core_Design_API_Field_Nm__c != '' && iBU.Core_Header_Or_Product_Ind__c == 'Header')
                    {


                        if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != NULL)
                        {
                            if(iBU.Core_Field_Data_Type_Txt__c == 'Number' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, decimal.ValueOf((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Checkbox' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('YES') || ((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('Y'))
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, TRUE);
                                }
                                else if(((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('NO') || ((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)).toUpperCase().contains('N'))
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, FALSE);
                                }
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Text')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Date' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designReg.put(iBU.Core_Design_API_Field_Nm__c, date.ValueOf(Date.parse((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c))));    
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'ID' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(iBU.Core_Stage_API_Field_Nm__c == 'Core_Owner_Txt__c' )
                                {
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c)); 
                                }   
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Picklist')
                            {
                                if(iBU.Core_Design_API_Field_Nm__c == 'Core_Product_Group_Nm__c'){designReg.put(iBU.Core_Design_API_Field_Nm__c, picklistMap.get((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)));
                                                                                                  
                                                                                                 }
                                else{
                                    designReg.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                                }                            
                            }
                        }
                    }
                }
                
                mapGrpIdTODesignReg.put(iDRS.Core_Group_Id__c, designReg);    
                
            } // close if(iDRS.Core_Header_Or_Product_Ind__c == 'Header')
            
            //Field value assignment for Design Registration Product record 
            if(iDRS.Core_Header_Or_Product_Ind__c == 'Product')
            {
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    designRegProd.put('Core_Design_Registration_Stage_Id__c', iDRS.get('Id'));
                    
                    if(iBU.Core_Stage_API_Field_Nm__c != NULL && iBU.Core_Stage_API_Field_Nm__c != '' && iBU.Core_Design_API_Field_Nm__c != NULL && iBU.Core_Design_API_Field_Nm__c != '' && iBU.Core_Header_Or_Product_Ind__c == 'Product')
                    {
                        if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != NULL)
                        { 
                            if(iBU.Core_Field_Data_Type_Txt__c == 'Number' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                designRegProd.put(iBU.Core_Design_API_Field_Nm__c, decimal.ValueOf((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c)));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Checkbox' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {/* In future, if you add check box field to product uncomment this line
if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Y' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Yes')
{
designReg.put(iBU.Core_Design_API_Field_Nm__c, 'TRUE');
}
else if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'N' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'No')
{
designReg.put(iBU.Core_Design_API_Field_Nm__c, 'FALSE');
}
*/
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Text')
                            {
                                designRegProd.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                            }
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Date' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != ''){designRegProd.put(iBU.Core_Design_API_Field_Nm__c, date.ValueOf(Date.parse((String)iDRS.get(iBU.Core_Stage_API_Field_Nm__c))));    }   
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Lookup' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                
                                if(iBU.Core_Design_API_Field_Nm__c == 'Core_Product_Id__c')
                                {
                                    designRegProd.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));
                                }
                            } 
                            else if (iBU.Core_Field_Data_Type_Txt__c == 'Boolean' && iDRS.get(iBU.Core_Stage_API_Field_Nm__c) != '')
                            {
                                if(iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Y' || iDRS.get(iBU.Core_Stage_API_Field_Nm__c) == 'Yes')
                                {
                                    designRegProd.put(iBU.Core_Design_API_Field_Nm__c, 'Cancelled');
                                    //designRegProd.put('RecordTypeId', Label.Core_DDR_Design_Product_Locked_Record_Type_ID);
                                } 
                            } 
                            else if(iBU.Core_Field_Data_Type_Txt__c == 'Picklist'){designRegProd.put(iBU.Core_Design_API_Field_Nm__c, iDRS.get(iBU.Core_Stage_API_Field_Nm__c));}                                               
                        }
                    }
                } // close for  for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                
                
                if(!mapGrpIdTODesignRegProd.containskey(iDRS.Core_Group_Id__c))
                {
                    mapGrpIdTODesignRegProd.put(iDRS.Core_Group_Id__c, new List<Core_Design_Registration_Product__c>{});
                }
                
                List<Core_Design_Registration_Product__c> lstTdesignRegProd = mapGrpIdTODesignRegProd.get(iDRS.Core_Group_Id__c);
                lstTdesignRegProd.add(designRegProd);
                
                mapGrpIdTODesignRegProd.put(iDRS.Core_Group_Id__c, lstTdesignRegProd);    
                
            }    // close    if(iDRS.Core_Header_Or_Product_Ind__c == 'Product')
            
            
        } //Close for(Core_Design_Registration_Stage__c iDRS : lstDRStages)
        
        
        List<Core_Design_Registration__c> lstDesignRegToProcess = mapGrpIdTODesignReg.values(); // After splitting the stage object record into DR and Product to split whether its for insert or update
        
        List<Core_Design_Registration__c> lstDesignRegToInsert = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegToUpdate = new List<Core_Design_Registration__c>();
        
        Set<String> SetDesignRegName = new Set<String>();
        
        // Based on stage object records, split the design records to insert list aand update list   
        for(Core_Design_Registration__c iDesignReg : lstDesignRegToProcess)
        {
            if(iDesignReg.Core_Registration_Number_Id__c != '')
            { 
                
                SetDesignRegName.add(iDesignReg.Core_Registration_Number_Id__c);
                
                Core_Design_Registration__c designRegUpdate = new Core_Design_Registration__c();
                designRegUpdate.put('Core_Design_Registration_Stage_Id__c', iDesignReg.get('Core_Design_Registration_Stage_Id__c'));
                
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    if(iBU.Core_Header_Or_Product_Ind__c == 'Header' && iDesignReg.get(iBU.Core_Design_API_Field_Nm__c) != '' && iDesignReg.get(iBU.Core_Design_API_Field_Nm__c) != NULL)
                    {
                        designRegUpdate.put(iBU.Core_Design_API_Field_Nm__c, iDesignReg.get(iBU.Core_Design_API_Field_Nm__c));
                    } 
                }
                lstDesignRegToUpdate.add(designRegUpdate);
            }
            else
            {
                Boolean isError = FALSE;
                
                if(iDesignReg.OwnerId != NULL )
                {
                    if(mapLoggedInUserAccountRelatedUserIds.containskey(iDesignReg.OwnerId))
                    {
                        iDesignReg.OwnerId = mapLoggedInUserAccountRelatedUserIds.get(iDesignReg.OwnerId);
                    }
                    else
                    {
                        isError = TRUE;
                        Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                        DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = 'Owner email provided is not valid';
                        
                        mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);                  
                    }
                }
                
                if(!isError)
                {
                    lstDesignRegToInsert.add(iDesignReg);
                }
            }
        } // close for
        
        Map<String, String> mapDesignRegNameTOId = new Map<String, String>();
        Map<Id, Boolean> mapDesignIdTOisLockedRT = new Map<Id, Boolean>();
        
        List<Core_Design_Registration__c> lstDesignRegNotLockedToUpdate = new List<Core_Design_Registration__c>();
        Set<Id> setDesignRegIds = new Set<Id>();
        
        for(Core_Design_Registration__c iDesignReg : [SELECT Id, Name,Core_Registration_Number_Id__c,RecordTypeId FROM Core_Design_Registration__c WHERE Name IN: SetDesignRegName WITH USER_MODE]) // Is it for update?? Why this for loop????
        {
            mapDesignRegNameTOId.put(iDesignReg.Name, iDesignReg.Id);
            setDesignRegIds.add(iDesignReg.Id);
            
            if(iDesignReg.RecordTypeId != NULL && String.ValueOf(iDesignReg.RecordTypeId).substring(0, 15) == Label.Core_DDR_Design_Locked_Record_Type_ID){mapDesignIdTOisLockedRT.put(iDesignReg.Id, TRUE);}
            else
            {
                mapDesignIdTOisLockedRT.put(iDesignReg.Id, FALSE);
            }
        }
        
        //To identify whether the user has access to update the record
        Map<ID, UserRecordAccess> mapDesignRegIdTOUserAccess = new Map<ID,UserRecordAccess>( [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :setDesignRegIds] );
        
        for(Core_Design_Registration__c iDesignReg : lstDesignRegToUpdate) 
        {
            
            Boolean isError = FALSE;
            
            if(mapDesignRegNameTOId.containsKey(iDesignReg.Core_Registration_Number_Id__c))
            {
                iDesignReg.Id = mapDesignRegNameTOId.get(iDesignReg.Core_Registration_Number_Id__c); 
            }
            else
            {
                isError = TRUE;
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = 'Registration number provided is not a valid number.';
                
                mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);   
            }
            
            if(iDesignReg.OwnerId != NULL)
            {
                if(mapLoggedInUserAccountRelatedUserIds.containskey(iDesignReg.OwnerId))
                {
                    iDesignReg.OwnerId = mapLoggedInUserAccountRelatedUserIds.get(iDesignReg.OwnerId);
                }
                else
                {
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'Owner email provided is not valid';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);   
                }   
            }            
            
            if(iDesignReg.Id != NULL)
            {
                if(mapDesignRegIdTOUserAccess.get(iDesignReg.Id).HasEditAccess != TRUE)
                {
                    isError = TRUE;
                    
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = 'You do not have access to this Design Registartion.';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);    
                }
                
                /*
if(Approval.isLocked(iDesignReg.Id))
{
isError = TRUE;

Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
DRSObj.Core_Processing_Status_Nm__c = 'Failed';
DRSObj.Core_Message_Txt__c = 'This Design is locked after approval and cannot be updated';

mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);     
}
*/
                
                if(mapDesignIdTOisLockedRT.get(iDesignReg.Id))
                {
                    isError = TRUE;
                    
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignReg.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = 'This Design is locked after approval and cannot be updated';
                    
                    mapUpdateDRStg.put(iDesignReg.Core_Design_Registration_Stage_Id__c,DRSObj);                   
                }
            }
            
            if(!isError)
            {
                lstDesignRegNotLockedToUpdate.add(iDesignReg);
            }
            
        }
        
        try
        {
            // DML to save the design registrations
            List<Database.SaveResult> lstDesignRegSaveResult = Database.insert(lstDesignRegToInsert, false);
            List<Database.SaveResult> lstDesignRegSaveResultUpdate = Database.update(lstDesignRegNotLockedToUpdate, false);
            
            //To handle the run time failures in insert list and prepare list of errors to update stage record
            for (Integer i = 0; i < lstDesignRegSaveResult.size(); i++) 
            {
                String errorMsg = 'Error While Processing design record:';
                Database.SaveResult DbSaveResult = lstDesignRegSaveResult [i];
                Core_Design_Registration__c origRecord = lstDesignRegToInsert[i];
                
                if(DbSaveResult.isSuccess())
                {
                    setDesignRegSuccessIds.add(DbSaveResult.getId());
                }
                else if (!DbSaveResult.isSuccess()) 
                {
                    for (Database.Error err: DbSaveResult.getErrors()) 
                    {
                        errorMsg +=  (err.getFields() + '\n'+ err.getMessage());
                    }  
                    
                    mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
                } // close if 
            } // close for         
            
            //preparing a map to update error message in stage object
            if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
            {
                for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
                {
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                    
                    mapUpdateDRStg.put(stgRecId,DRSObj);
                } // Close For
                
            }// Close If
            
            
            //To handle the run time failures in update list and prepare list of errors to update stage record
            for (Integer i = 0; i < lstDesignRegSaveResultUpdate.size(); i++) 
            {
                String errorMsg = 'Error While Processing DR Update Records \n';
                Database.SaveResult DbSaveResult = lstDesignRegSaveResultUpdate [i];
                Core_Design_Registration__c origRecord = lstDesignRegToUpdate[i];
                
                if(DbSaveResult.isSuccess()){setDesignRegSuccessIds.add(DbSaveResult.getId());}
                else if (!DbSaveResult.isSuccess()) 
                {
                    for (Database.Error err: DbSaveResult.getErrors()) 
                    {
                        errorMsg += (err.getFields() + '\n'+ err.getMessage());
                    }  
                    
                    mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
                    
                } // close if 
                
            } // close for         
            
            //preparing a map to update error message in stage object
            if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
            {
                for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
                {
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                    
                    mapUpdateDRStg.put(stgRecId,DRSObj);
                } // Close For
                
            }// Close If
            
            
            
            for(Core_Design_Registration__c  iDesignReg : lstDesignRegToInsert)
            {
                mapDesignStgIdTODesignRegId.put(iDesignReg.Core_Design_Registration_Stage_Id__c, iDesignReg.Id);
                mapDesignRegIdTODesignStgId.put(iDesignReg.Id, iDesignReg.Core_Design_Registration_Stage_Id__c); 
            }
            
            for(Core_Design_Registration__c  iDesignReg : lstDesignRegToUpdate)
            {
                mapDesignStgIdTODesignRegId.put(iDesignReg.Core_Design_Registration_Stage_Id__c, iDesignReg.Id);
                mapDesignRegIdTODesignStgId.put(iDesignReg.Id, iDesignReg.Core_Design_Registration_Stage_Id__c);
                mapDesignRegIdTODesignRegName.put(iDesignReg.Id, iDesignReg.Name);  
            }  
            
            List<Core_Log_Entry__c> lstLogEntriesDesign = new List<Core_Log_Entry__c>();
            
            //To identify the name of created design registration product to update it in stage for reference
            for(Core_Design_Registration__c iDesignReg: [SELECT Id, Name FROM Core_Design_Registration__c WHERE Id IN: setDesignRegSuccessIds WITH USER_MODE])
            {
                mapDesignRegIdTODesignRegName.put(iDesignReg.Id, iDesignReg.Name);   
            }                        
            for(Id iDesignRegID : setDesignRegSuccessIds)
            {
                Core_Design_Registration_Stage__c iDRS = new Core_Design_Registration_Stage__c(Id=mapDesignRegIdTODesignStgId.get(iDesignRegID));
                iDRS.Core_Processing_Status_Nm__c = 'Successful';
                iDRS.Core_Message_Txt__c = 'Success';
                iDRS.Core_Converted_Design_Or_Product_Id__c = iDesignRegID;
                iDRS.Core_Converted_Design_Or_Product_Nm__c = mapDesignRegIdTODesignRegName.get(iDesignRegID);
                
                mapUpdateDRStg.put(iDesignRegID,iDRS);
                
                lstLogEntriesDesign.add(new Core_Log_Entry__c(Core_Message__c = 'Successfully Inserted', Core_Origin__c = 'Core_DDR_Stage_Validator', Core_Severity__c = 'Medium', Core_When__c=System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = mapDesignRegIdTODesignStgId.get(iDesignRegID)));
            }
            
            if(!lstLogEntriesDesign.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert lstLogEntriesDesign;
                }
            }  
            //added for test
            if(Test.isRunningTest()){throw new System.DMLException();}
        }
        catch(Exception e)
        {
           
            
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }             
        }        
        
        //Taking all the stage object available and eligible Products into list.
        for(String iGrpId : mapGrpIdTODesignRegProd.keySet())
        {
            for(Core_Design_Registration_Product__c iDesignRegProd : mapGrpIdTODesignRegProd.get(iGrpId))
            {
                Boolean isDesignRegProdErr = FALSE;  
                
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                DRSObj.Core_Message_Txt__c = '';
                
                if(!mapDesignStgIdTODesignRegId.containskey(mapHeadGrpIdTODesignStgId.get(iGrpId)))
                {
                    isDesignRegProdErr = TRUE;
                    DRSObj.Core_Message_Txt__c = 'Product creation failed due to failure of header creation';
                    
                }
                
                if(!isDesignRegProdErr)
                {
                    
                    iDesignRegProd.Core_Design_Registration_Id__c = mapDesignStgIdTODesignRegId.get(mapHeadGrpIdTODesignStgId.get(iGrpId));
                    
                    iDesignRegProd.Core_Product_Id__c = mapProductNameToProductId.get(string.ValueOf(iDesignRegProd.Core_Product_Id__c).toUpperCase());
                    
                    lstProcessDesignProduct.add(iDesignRegProd);    
                }
                else
                {
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);                   
                }
                
            }
        } // Close For
        
        List<Core_Design_Registration_Product__c> lstDesignRegProdToInsert = new List<Core_Design_Registration_Product__c>();
        List<Core_Design_Registration_Product__c> lstDesignRegProdToUpdate = new List<Core_Design_Registration_Product__c>();
        
        Set<String> SetDesignRegProdName = new Set<String>();
        
        // Based on stage object records, split the design product records to insert list aand update list           
        for(Core_Design_Registration_Product__c iDesignRegProd : lstProcessDesignProduct)
        {
            if(iDesignRegProd.Core_Design_Registration_Line_ID__c != '')
            {
                SetDesignRegProdName.add(iDesignRegProd.Core_Design_Registration_Line_ID__c);
                
                Core_Design_Registration_Product__c iDesignregProdForUpdate = new Core_Design_Registration_Product__c();
                
                for(Core_Design_Registrations_Bulk_Upload__c iBU : lstBulkUploadMappings)
                {
                    iDesignregProdForUpdate.put('Core_Design_Registration_Stage_Id__c', iDesignRegProd.get('Core_Design_Registration_Stage_Id__c'));
                    if(iBU.Core_Header_Or_Product_Ind__c == 'Product' && iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c) != '' && iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c) != NULL)
                    {
                        iDesignregProdForUpdate.put(iBU.Core_Design_API_Field_Nm__c, iDesignRegProd.get(iBU.Core_Design_API_Field_Nm__c));
                    }
                }
                
                lstDesignRegProdToUpdate.add(iDesignregProdForUpdate);
                
            }
            else
            {
                lstDesignRegProdToInsert.add(iDesignRegProd);
            }
            
        }
        
        Map<String, String> mapDesignRegProdNameTOId = new Map<String, String>();
        Map<Id, Boolean> mapProductIdToIsCancelled = new Map<Id, Boolean>();
        Map<Id, Boolean> mapDesignProductIdToIsLockedRT = new Map<Id, Boolean>();
        
        List<Core_Design_Registration_Product__c> lstDesignRegProdNotApprovedToUpdate = new List<Core_Design_Registration_Product__c>();
        
        Set<Id> setDesignRegProdIds = new Set<Id>();
        
        //Identify the cancelled status products
        for(Core_Design_Registration_Product__c iDesignRegProd : [SELECT Id, Name,Core_Product_Id__r.name, Core_Design_Product_Status_Nm__c, RecordTypeId FROM Core_Design_Registration_Product__c WHERE Name IN: SetDesignRegProdName WITH USER_MODE])
        {
            mapDesignRegProdNameTOId.put(iDesignRegProd.Name, iDesignRegProd.Id);
            setDesignRegProdIds.add(iDesignRegProd.Id);
            
            if(iDesignRegProd.Core_Design_Product_Status_Nm__c == 'Cancelled')
            {
                mapProductIdToIsCancelled.put(iDesignRegProd.Id,TRUE);
            }
            
            if(iDesignRegProd.RecordTypeId != NULL && String.ValueOf(iDesignRegProd.RecordTypeId).substring(0, 15) == Label.Core_DDR_Design_Product_Locked_Record_Type_ID)
            {
                mapDesignProductIdToIsLockedRT.put(iDesignRegProd.Id,TRUE);
            }
            else
            {
                mapDesignProductIdToIsLockedRT.put(iDesignRegProd.Id,FALSE);
            }
        }
        
        //To identify whether the user has access to update the record
        Map<ID, UserRecordAccess> mapDesignRegProdIdTOUserAccess = new Map<ID,UserRecordAccess>( [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :setDesignRegProdIds] );
        
        for(Core_Design_Registration_Product__c iDesignRegProd : lstDesignRegProdToUpdate) 
        {
            Boolean isError = FALSE;
            if(mapDesignRegProdNameTOId.containsKey(iDesignRegProd.Core_Design_Registration_Line_ID__c))
            {
                iDesignRegProd.Id = mapDesignRegProdNameTOId.get(iDesignRegProd.Core_Design_Registration_Line_ID__c);
            }            
            else
            {
                isError = TRUE;
                Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = 'Registration Line ID provided is not a valid number';
                
                mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);   
            }
            
            if(iDesignRegProd.Id != NULL)
            {
                if(mapDesignRegProdIdTOUserAccess.get(iDesignRegProd.Id).HasEditAccess != TRUE)
                {    
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';DRSObj.Core_Message_Txt__c = 'You do not have access to this Design Registartion Product';
                    
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);    
                }
                /*
if(iDesignRegProd.Core_Design_Product_Status_Nm__c != 'Cancelled' && Approval.isLocked(iDesignRegProd.Id))
{
isError = TRUE;
Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
DRSObj.Core_Processing_Status_Nm__c = 'Failed';
DRSObj.Core_Message_Txt__c = 'This Design Registartion Product is locked after approval and cannot be updated';

mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);            
}
*/
                if(iDesignRegProd.Core_Design_Product_Status_Nm__c != 'Cancelled' && mapDesignProductIdToIsLockedRT.get(iDesignRegProd.Id))
                {
                    isError = TRUE;
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = 'This Design Registartion Product is locked after approval and cannot be updated';
                    
                    mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj);                 
                }
                
                if(mapProductIdToIsCancelled.containskey(iDesignRegProd.Id))
                {
                    //if(iDesignRegProd.Core_Design_Product_Status_Nm__c != 'Cancelled' && mapProductIdToIsCancelled.get(iDesignRegProd.Id))
                    if(mapProductIdToIsCancelled.get(iDesignRegProd.Id))
                    {
                        isError = TRUE;
                        Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=iDesignRegProd.Core_Design_Registration_Stage_Id__c);
                        DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                        DRSObj.Core_Message_Txt__c = 'This Design Registartion Product is cancelled and cannot be updated';
                        
                        mapUpdateDRStg.put(iDesignRegProd.Core_Design_Registration_Stage_Id__c,DRSObj); 
                    }
                }
            }
            
            
            if(!isError)
            {
                if(iDesignRegProd.Core_Design_Product_Status_Nm__c == 'Cancelled')
                {
                    iDesignRegProd.RecordTypeId = Label.Core_DDR_Design_Product_Locked_Record_Type_ID;   
                }
                lstDesignRegProdNotApprovedToUpdate.add(iDesignRegProd);
            }
        }  
        
        try
        {
            // DML to save the design registrations
            List<Database.SaveResult> lstDesignRegProdSaveResult = Database.insert(lstDesignRegProdToInsert, false);
            List<Database.SaveResult> lstDesignRegProdSaveResultUpdate = Database.update(lstDesignRegProdNotApprovedToUpdate, false);
            
            
            //To handle the run time failures in insert list and prepare list of errors to update stage record
            for (Integer i = 0; i < lstDesignRegProdSaveResult.size(); i++) 
            {
                String errorMsg = 'Error While Processing/Creating DR-Product Records \n';
                Database.SaveResult DbSaveResult = lstDesignRegProdSaveResult [i];
                Core_Design_Registration_Product__c origRecord = lstDesignRegProdToInsert[i];
                
                if(DbSaveResult.isSuccess())
                {
                    setDesignRegProdSuccessIds.add(DbSaveResult.getId());
                    
                }
                else if (!DbSaveResult.isSuccess()) 
                {
                    for (Database.Error err: DbSaveResult.getErrors()) 
                    {
                        errorMsg += (err.getFields() + '\n'+ err.getMessage());
                    }  
                    
                    mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
                    
                } // close if 
                
            } // close for         
            
            //preparing a map to update error message in stage object
            if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
            {
                for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
                {
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                    
                    mapUpdateDRStg.put(stgRecId,DRSObj);
                } // Close For
                
            }// Close If
            
            
            
            //To handle the run time failures in update list and prepare list of errors to update stage record
            for (Integer i = 0; i < lstDesignRegProdSaveResultUpdate.size(); i++) 
            {
                String errorMsg = 'Error While Processing DR-Product Update Records \n';
                Database.SaveResult DbSaveResult = lstDesignRegProdSaveResultUpdate [i];
                Core_Design_Registration_Product__c origRecord = lstDesignRegProdToUpdate[i];
                
                if(DbSaveResult.isSuccess())
                {
                    setDesignRegProdSuccessIds.add(DbSaveResult.getId());
                }
                else if (!DbSaveResult.isSuccess())
                {
                    for (Database.Error err: DbSaveResult.getErrors()) 
                    {
                        errorMsg += (err.getFields() + '\n'+ err.getMessage());
                    }  
                    
                    mapDesignRegFailedStageRecIdsAndErrMsg.put(origRecord.Core_Design_Registration_Stage_Id__c,errorMsg);
                    
                } // close if 
                
            } // close for  
            //added for test
            if(Test.isRunningTest()){throw new System.DMLException();}
        }
        catch(Exception e)
        {
            
           // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }             
        }
        
        try
        {   
            
            //preparing a map to update error message in stage object
            if(mapDesignRegFailedStageRecIdsAndErrMsg.size() > 0)
            {
                for(Id stgRecId : mapDesignRegFailedStageRecIdsAndErrMsg.keySet())
                {
                    Core_Design_Registration_Stage__c DRSObj = new Core_Design_Registration_Stage__c(Id=stgRecId);
                    DRSObj.Core_Processing_Status_Nm__c = 'Failed';
                    DRSObj.Core_Message_Txt__c = mapDesignRegFailedStageRecIdsAndErrMsg.get(stgRecId);
                   
                    mapUpdateDRStg.put(stgRecId,DRSObj);
                    
                } // Close For
                
            }// Close If
            
            update mapUpdateDRStg.values(); 
            //added for test
            if(Test.isRunningTest()){throw new System.DMLException();}
            
        }
        catch(Exception e)
        {
             
           // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }  
        }
        
        try
        {
            for(Core_Design_Registration_Product__c  iDesignRegProd : lstDesignRegProdToInsert)
            {
                mapDesignRegProdIdTODesignStgId.put(iDesignRegProd.Id, iDesignRegProd.Core_Design_Registration_Stage_Id__c);
            }
            for(Core_Design_Registration_Product__c  iDesignRegProd : lstDesignRegProdToUpdate)
            {
                mapDesignRegProdIdTODesignStgId.put(iDesignRegProd.Id, iDesignRegProd.Core_Design_Registration_Stage_Id__c);  
            } 
            
           // List<Id> lstDesignProdIdsForLocking = new List<Id>();
            List<Core_Log_Entry__c> lstLogEntriesDesignProducts = new List<Core_Log_Entry__c>(); 
            //To identify the name of created design registration product
            for(Core_Design_Registration_Product__c  iDesignRegProd: [SELECT Id, Name, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Id IN: setDesignRegProdSuccessIds WITH USER_MODE])
            {
                mapDesignRegProdIdTODesignProdName.put(iDesignRegProd.Id, iDesignRegProd.Name); 
            }
            
            for(Id iDesignRegProdID : setDesignRegProdSuccessIds)
            {
                Core_Design_Registration_Stage__c iDRS = new Core_Design_Registration_Stage__c(Id=mapDesignRegProdIdTODesignStgId.get(iDesignRegProdID));
                iDRS.Core_Processing_Status_Nm__c = 'Successful';
                iDRS.Core_Message_Txt__c = 'Success';
                iDRS.Core_Converted_Design_Or_Product_Id__c = iDesignRegProdID;
                iDRS.Core_Converted_Design_Or_Product_Nm__c = mapDesignRegProdIdTODesignProdName.get(iDesignRegProdID);
                lstUpdateDesignRegStg.add(iDRS);
                
                lstLogEntriesDesignProducts.add(new Core_Log_Entry__c(Core_Message__c = 'Successfully Inserted', Core_Origin__c = 'Core_DDR_Stage_Validator', Core_Severity__c = 'Medium', Core_When__c=System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = mapDesignRegProdIdTODesignProdName.get(iDesignRegProdID)));
            }
            
            //update lstUpdateDesignRegStg;
             Database.update(lstUpdateDesignRegStg,false,AccessLevel.User_mode);
            
            if(!lstLogEntriesDesignProducts.isEmpty() && !logSwitch.isEmpty())
            {
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    insert lstLogEntriesDesignProducts;
                }
            }    
            //added for test
            if(Test.isRunningTest()){throw new System.DMLException();}
        }
        catch(Exception e)
        {
           //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            
            
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Stage_Validator', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }             
        }        
        
    }// Close Method createDesignReg
}