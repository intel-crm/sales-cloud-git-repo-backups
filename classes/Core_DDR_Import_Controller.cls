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
    String BatchMessage = 'Batch ID: ';
    String BatchId = '';
    
    List<Core_DDR_Special_Character_Replacement__c> lstSpecialCharacterMappings = new List<Core_DDR_Special_Character_Replacement__c>();
    
    
    public  Core_DDR_Import_Controller()
    {
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
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please Choose & Upload a .csv extension file');
                ApexPages.addMessage(errorMessage);  
              
            }
            else
            {
                // Creating the design batch record 
                Core_Design_Registration_Batch__c tDRStageBatch = new Core_Design_Registration_Batch__c(Core_File_Nm__c = csvAsString);
                listDRStageBatch.add(tDRStageBatch);
                insert listDRStageBatch;
                
                List<Core_Design_Registration_Batch__c> listDRStageBatchGetAll = new List<Core_Design_Registration_Batch__c>();
                listDRStageBatchGetAll = [SELECT id,Name FROM Core_Design_Registration_Batch__c WHERE ID=:listDRStageBatch[0].Id LIMIT 1];
                 
                BatchMessage = 'BatchID:' + listDRStageBatchGetAll[0].Name; 
                BatchId = '/'+listDRStageBatchGetAll[0].Id;
                
                //Attaching the file to the design batch 
                Attachment newAtt = new Attachment();
                newAtt.name = csvAsString;
                newAtt.body = csvFileBody;
                newAtt.parentID = listDRStageBatch[0].id;
                insert newAtt;
        
                csvAsString =blobToString(csvFileBody,'ISO 8859-1');
                csvFileLines = csvAsString.split('\n'); 
                
                //Querying the bulk upload field mapping to create the design registration using bulk upload .csv file
                List<Core_Design_Registrations_Bulk_Upload__c> lstBulkUploadMappings = Core_Design_Registrations_Bulk_Upload__c.getAll().values();
                
                Map<String, String> mapColumnNameTOAPIName = new Map<String, String>();
                Map<Integer, String> mapColumnNumberTOColumnName = new Map<Integer, String>();
               
                for(Core_Design_Registrations_Bulk_Upload__c iBM : lstBulkUploadMappings)
                {
                    if(iBM.Core_CSV_Column_Nm__c!= NULL && iBM.Core_Stage_API_Field_Nm__c!= NULL)
                    {
                        mapColumnNameTOAPIName.put(iBM.Core_CSV_Column_Nm__c.trim().toUpperCase(), iBM.Core_Stage_API_Field_Nm__c.trim());
                    }
                }
                
                string[] csvHeaderData = csvFileLines[0].split(',');
                integer cellNumber = 0;
                
                while(cellNumber < csvHeaderData.size())
                {
                    
                    String strColumnHeader = csvHeaderData[cellNumber];
                    mapColumnNumberTOColumnName.put(cellNumber, strColumnHeader.trim().toUpperCase());
                    
                    cellNumber++;    
                }
                
               
                for(Integer i=1;i<csvFileLines.size();i++)
                {
                
                    sObject DRSObj = new Core_Design_Registration_Stage__c() ;
                    
                    String strToAvoidSplChars =null;
                    strToAvoidSplChars =  csvFileLines[i];
                    strToAvoidSplChars = strToAvoidSplChars.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
                    strToAvoidSplChars  = strToAvoidSplChars.replaceAll('""','DBLQT');
                    
                    string[] csvRecordData = handleSplCharsInCSVColumnVal(strToAvoidSplChars);
                    
                    DRSObj.put('Core_Batch_ID__c',listDRStageBatch[0].id);
                    
                    for(Integer iColumnNumber : mapColumnNumberTOColumnName.keyset())
                    {
                        if(mapColumnNumberTOColumnName.containskey(iColumnNumber))
                        {
                            for(Core_DDR_Special_Character_Replacement__c iSpecialCharReplace : lstSpecialCharacterMappings)
                            {
                                DRSObj.put(mapColumnNameTOAPIName.get(mapColumnNumberTOColumnName.get(iColumnNumber).trim().toUpperCase()), csvRecordData[iColumnNumber].replace(iSpecialCharReplace.Junk_Character__c,iSpecialCharReplace.Actual_Character__c).trim()); 
                            }
                        }      
                    }
                    
                    listDRStage.add(DRSObj);      
                }
                
                if(listDRStage.size() > 0)
                { 
                    Boolean isError = FALSE;
                    for(Core_Design_Registration_Stage__c iDesignRegStg : (List<Core_Design_Registration_Stage__c>)listDRStage)
                    {                  
                        if(iDesignRegStg.Core_Group_Id__c == '' || iDesignRegStg.Core_Header_Or_Product_Ind__c == '')
                        {
                            isError = TRUE;
                            break;       
                        }    
                    } // close for
                    
                    if(!isError)
                    {
                        insert listDRStage;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));

                        Core_DDR_Stage_Validator createDesignRegAndDesignRegProd = new Core_DDR_Stage_Validator();
                        createDesignRegAndDesignRegProd.checkValidations(listDRStage);                                  
                    }
                    else
                    {
                        Database.rollback(sp);
                        System.debug('Data error in CSV file==>');
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'One or more rows may not have the required field (Group Id/ Header or Product) values. Please fill and reupload the file');
                        ApexPages.addMessage(errorMessage);
                    }
                }
            }
           
        }
        catch (Exception e)
        {
            System.debug('Line number: ' + e.getLineNumber());   
            System.debug('Stack trace: ' + e.getStackTraceString());
            
            Database.rollback(sp);
            
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getmessage()+'An error occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
            //return null;
           
        }
        
        finally{
        //createDesignRegAndDesignRegProd.createDesignReg(listDRStage);      
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
        
        allFields.addAll(noQuoteFields);
           

            return allFields;
        
    } // close Method
    
  
}