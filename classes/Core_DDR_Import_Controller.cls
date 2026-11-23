/****************************************************************************************************
Apex Class Name : Core_DDR_Import_Controller
Version         : 1.0 
Created Date    : 09/08/2017
Function        : This class is to used to create records from .csv file in the design registration stage
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             09/08/2017            Created
* Ramakrishna               10/16/2017            Added a method to encode the string to ISO 8859-1 standard
* Ramakrishna               10/27/2017            Added a method to handle the commas in the string
*****************************************************************************************************/
public Class  Core_DDR_Import_Controller
{
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}  
    public String stopText{get;set;}
    public boolean isDisplayingMessage {get;set;}
    public List<sobject> listDRStage{get;set;}
   
    public List<Core_Design_Registration_Batch__c> listDRStageBatch = new List<Core_Design_Registration_Batch__c>();
    String BatchMessage = '';
    String BatchId = '';
    
    List<Core_DDR_Special_Character_Replacement__c> lstSpecialCharacterMappings = new List<Core_DDR_Special_Character_Replacement__c>();
    
    Core_Design_Registration_Batch__c designBatch = new Core_Design_Registration_Batch__c();
    
    User loginUser = new User();
    
    //This flag is used to identify the login user is partner user to show/ hide partner account lookup
    Boolean isPartnerUser = FALSE;
    
    //To get the log switch details 
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    
    public Boolean getIsPartnerUser()
    {
        return isPartnerUser;
    }
    
    public Core_Design_Registration_Batch__c  getdesignBatch()
    {
        return designBatch;
    }
    
    public boolean showPartnerAccount()
    {
        //To autofill the partner account lookup for partner users
        loginUser = [SELECT id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        if(loginUser.AccountId == NULL)
        {
            isPartnerUser = TRUE;
        }
        else
        {
            designBatch.Core_Partner_Account_Id__c = loginUser.AccountId;
            System.debug(' designBatch.Core_Partner_Account_Id__c==>'+ designBatch.Core_Partner_Account_Id__c);
            isPartnerUser = FALSE;    
        }
        
        return isPartnerUser;
    }
    
    public  Core_DDR_Import_Controller()
    {
    
        showPartnerAccount();
    
        csvFileLines = new String[]{};
        listDRStage = New List<Core_Design_Registration_Stage__c>(); 
    }

    public String getBatchMessage()
    {
        return BatchMessage;
    }
    
    public String getBatchId()
    {
        return BatchId;
    }
    String CurrentColumnName = '';
    public void importCSVFile()
    {
        Savepoint sp;
        
        //query the custom setting to unsupported junk characters (Trademark symbol - ™)
        lstSpecialCharacterMappings = Core_DDR_Special_Character_Replacement__c.getAll().values();
        
        try
        {
            sp = Database.setSavepoint();
            System.debug('csvAsString==>'+csvAsString);
            
            if( csvAsString.right(3) != 'csv')
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'Please import a file with csv extension.');
                ApexPages.addMessage(errorMessage);  
              
            }
            else
            {
                designBatch.Id = null;
                listDRStageBatch.clear();
                listDRStage.clear();
                
                // Creating the design batch record 
                designBatch.Core_File_Nm__c = csvAsString;
                listDRStageBatch.add(designBatch);
                insert listDRStageBatch;
                
                List<Core_Design_Registration_Batch__c> listDRStageBatchGetAll = new List<Core_Design_Registration_Batch__c>();
                listDRStageBatchGetAll = [SELECT id,Name FROM Core_Design_Registration_Batch__c WHERE ID=:listDRStageBatch[0].Id LIMIT 1];
                 
                BatchMessage = listDRStageBatchGetAll[0].Name; 
                BatchId = '/'+listDRStageBatchGetAll[0].Id;
                
                //Attaching the file to the design batch 
                Attachment newAtt = new Attachment();
                newAtt.name = csvAsString;
                newAtt.body = csvFileBody;
                newAtt.parentID = listDRStageBatch[0].id;
                insert newAtt;
        
                //Converting the file to ISO standard to encryt the special charaters 
                csvAsString =blobToString(csvFileBody,'ISO 8859-1');

                csvFileLines = csvAsString.split('\n'); 
                
                //Querying the bulk upload field mapping to create the design registration using bulk upload .csv file
                List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = Core_Design_Registrations_Bulk_Upload__c.getAll().values();
                
                Map<String, String> mapColumnNameTOAPIName = new Map<String, String>();
                Map<Integer, String> mapColumnNumberTOColumnName = new Map<Integer, String>();
               
                //Creating a map to store bulk upload column name and Salesforce Object field API name
                for(Core_Design_Registrations_Bulk_Upload__c iBM : lstBulkUploadMappings)
                {
                    if(iBM.Core_CSV_Column_Nm__c!= NULL && iBM.Core_Stage_API_Field_Nm__c!= NULL)
                    {
                        mapColumnNameTOAPIName.put(iBM.Core_CSV_Column_Nm__c.trim().toUpperCase(), iBM.Core_Stage_API_Field_Nm__c.trim());
                    }
                }
                
                string[] csvHeaderData = csvFileLines[0].split(',');
                integer cellNumber = 0;
                
                //Setting the column number for column name
                while(cellNumber < csvHeaderData.size())
                {
                    
                    String strColumnHeader = csvHeaderData[cellNumber];
                    mapColumnNumberTOColumnName.put(cellNumber, strColumnHeader.trim().toUpperCase());
                    
                    cellNumber++;    
                }
                
                for(String iColumnHeaderName : mapColumnNumberTOColumnName.values())
                {
                    if(!mapColumnNameTOAPIName.containsKey(iColumnHeaderName))
                    {
                        Database.rollback(sp);
                        Batchmessage = '';
                        BatchId = '';
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Column name:'+iColumnHeaderName+' is not supported for upload. Please remove it and try again.'));                        
                        break;
                    }
                }
               
                for(Integer i=1;i<csvFileLines.size();i++)
                {
                
                
                    sObject DRSObj = new Core_Design_Registration_Stage__c() ;
                    
                    String strToAvoidSplChars =null;
                    strToAvoidSplChars =  csvFileLines[i];
                    
                    system.debug(strToAvoidSplChars);
                    
                    strToAvoidSplChars = strToAvoidSplChars.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
                    system.debug(strToAvoidSplChars);
                    strToAvoidSplChars  = strToAvoidSplChars.replaceAll('""','DBLQT');
                    system.debug(strToAvoidSplChars);
                
                    //To handle the comma values within the text
                    string[] csvRecordData = handleSplCharsInCSVColumnVal(strToAvoidSplChars);
                    
                    DRSObj.put('Core_Batch_ID__c',listDRStageBatch[0].id);
                    
                    //Assigning the file column values to actual record fields
                    for(Integer iColumnNumber : mapColumnNumberTOColumnName.keyset())
                    {
                        if(mapColumnNumberTOColumnName.containskey(iColumnNumber))
                        {
                        CurrentColumnName = mapColumnNumberTOColumnName.get(iColumnNumber);
                            String columnValue = csvRecordData[iColumnNumber];
                            for(Core_DDR_Special_Character_Replacement__c iSpecialCharReplace : lstSpecialCharacterMappings)
                            {
                                columnValue = columnValue.replace(iSpecialCharReplace.Junk_Character__c,iSpecialCharReplace.Actual_Character__c).trim();
                            }
                            DRSObj.put(mapColumnNameTOAPIName.get(mapColumnNumberTOColumnName.get(iColumnNumber).trim().toUpperCase()), columnValue); 
                        }      
                    }
                    system.debug('###DRSObj'+DRSObj);
                    listDRStage.add(DRSObj);      
                }
                
                if(listDRStage.size() > 0)
                { 
                    Boolean isError = FALSE;
                    String ErrorText = '';
                    
                    //Handling basic errors before starting the stage records creation 
                    for(Core_Design_Registration_Stage__c iDesignRegStg : (List<Core_Design_Registration_Stage__c>)listDRStage)
                    {                  
                        if(iDesignRegStg.Core_Group_Id__c == '' || iDesignRegStg.Core_Header_Or_Product_Ind__c == '')
                        {
                            isError = TRUE;
                            ErrorText = 'One or more rows in the file does not have the required field(s) (Group ID, Header/Product) populated. Please fix the data and try again.';
                            break;       
                        }
                        
                        if(!iDesignRegStg.Core_Group_Id__c.isNumeric())
                        {
                            isError = TRUE;
                            ErrorText = 'One or more rows in the file has non-numeric value in Group ID Column. Please fix the data and try again.';
                            break;  
                        }
                        
                        if(iDesignRegStg.Core_Header_Or_Product_Ind__c != 'Header' && iDesignRegStg.Core_Header_Or_Product_Ind__c != 'Product')
                        {
                            isError = TRUE;
                            ErrorText = 'One or more rows in the file has different value other than Header or Product in Header/Product Column. Please fix the data and try again.';
                            break;  
                        }
                                                
                    } // close for
                    
                    if(!isError)
                    {
                    
                        try
                        {
                            insert listDRStage;
                            Core_DDR_Stage_Validator createDesignRegAndDesignRegProd = new Core_DDR_Stage_Validator();
                            createDesignRegAndDesignRegProd.checkValidations(listDRStage);   
                            
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'File has been imported successfully.'));                        
                        }
                        catch(Exception e)
                        {
                            Database.rollback(sp);
                            Batchmessage = '';
                            BatchId = '';
                        
                            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An unexpected error has occured while importing the file. Please review the file before trying again.');
                            ApexPages.addMessage(errorMessage);
                               
                        }
                    }
                    else
                    {
                        Database.rollback(sp);
                        Batchmessage = '';
                        BatchId = '';
                        
                        System.debug('Data error in CSV file==>');
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, ErrorText);
                        ApexPages.addMessage(errorMessage);
                    }
                }
            }
           
        }
        catch (Exception e)
        {
            System.debug('Line number: ' + e.getLineNumber());   
            System.debug('Stack trace: ' + e.getStackTraceString());
            System.debug('Error Messge: ' + e.getMessage());
            
            Database.rollback(sp);
            Batchmessage = '';
            BatchId = '';
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An unexpected error has occured while importing the file. Check the column - '+CurrentColumnName+' for any line breaks or any other issue. Please review the file before trying again.');
            ApexPages.addMessage(errorMessage);
           
            if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
            {   
                Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c = 'Line number: ' + e.getLineNumber()+', Stack trace: ' + e.getStackTraceString(), Core_Origin__c='Core_DDR_Import_Controller', Core_Severity__c='High', Core_When__c = System.Now(), Core_Project__c = 'DDR', Core_sObjectId__c = '');
                insert ExcepLog;
            }
            
            //return null;
           
        }
    }
    
    /**
        This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
    */
    public static String blobToString(Blob input, String inCharset)
    {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    } 
    
    /*
    This method is to handle the commas in the string
    */
    public static  List<String> handleSplCharsInCSVColumnVal(String rowData)
    { 
        List<String> allFields = new List<String>();        
        // TODO: Deal with lines where all fields empty. Currently splits into an empty array.
        
        try
        {
       system.debug(rowData);
        List<String> fields = rowData.split(',', -1); 
         
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
         
         for(String field : fields) {
            if (field.startsWith('"') && field.endsWith('"')) {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            } else if (field.startsWith('"')) {
                makeCompositeField = true;
                compositeField = field;
            } else if (field.endsWith('"')) {
                compositeField += ',' + field;
                cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                makeCompositeField = false;
            } else if (makeCompositeField) {
                compositeField +=  ',' + field;
            } else {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            }
        }
        
        // Remove double quotes (if present) from start and end of each field
        List<String> noQuoteFields = new List<String>();
        
        for(String field : cleanFields) {
            if(field.startsWith('"') && field.endsWith('"')) {
                field = field.substring(1, field.length() - 1);
            }
            noQuoteFields.add(field);
        } // close for
        system.debug(noQuoteFields);
        system.debug(allFields);
        allFields.addAll(noQuoteFields);
            return allFields;
            
        }
        catch(Exception e)
        {
        
            System.debug('Line number: ' + e.getLineNumber());   
            System.debug('Stack trace: ' + e.getStackTraceString());

            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An unexpected error has occured while importing the file. Please check your file for unwanted comma values.');
            ApexPages.addMessage(errorMessage);
            
            return null;
        }
    } // close Method
}