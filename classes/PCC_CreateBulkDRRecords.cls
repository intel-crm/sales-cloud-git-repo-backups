/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateBulkDRRecords
Version             : 
Created Date        : May 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                May- 2023        Added a methods (saveFile) to read data from csv file and create DR stage, DR and DRP records.
************************************************************************************************************************************************/
public with sharing class PCC_CreateBulkDRRecords {
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_CreateBulkDRRecords';
    public static final String LOG_ENTRY_PROJECT  = 'DDR bulk';
    public static final String LOG_ENTRY_SCOPE    = 'Create DDR bulk Records';
    public static final String LOG_ENTRY_SCOPE_1  = 'Create DDR bulk Records';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    @AuraEnabled
    public static List<Core_Design_Registration_Stage__c> saveFile(String base64Data, String csvFileName) {
        
        String data = JSON.deserializeUntyped(base64Data).toString();
        list<Core_Design_Registration_Stage__c> drStageListToInsert = new list<Core_Design_Registration_Stage__c>();
        List<Core_Design_Registration_Batch__c> listDRStageBatch = new List<Core_Design_Registration_Batch__c>();
        list<String> lstCSVLines = data.split('\n');
        
        User loginUser = new User();
        loginUser = [SELECT id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        string csvname= csvFileName;
        Core_Design_Registration_Batch__c db = new Core_Design_Registration_Batch__c();
        db.Core_Partner_Account_Id__c = loginUser.AccountId;
        db.Id = null;
        // Creating the design batch record 
        db.Core_File_Nm__c = csvname;
        listDRStageBatch.add(db);
        //insert listDRStageBatch;
        Database.insert(listDRStageBatch,false,AccessLevel.USER_MODE);
        List<Core_Design_Registration_Batch__c> listDRStageBatchGetAll = new List<Core_Design_Registration_Batch__c>();
        listDRStageBatchGetAll = [SELECT id,Name FROM Core_Design_Registration_Batch__c WHERE ID=:listDRStageBatch[0].Id WITH USER_MODE LIMIT 1];
        
        //try{
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_Design_Registration_Stage__c drs = new Core_Design_Registration_Stage__c();
                String csvLine = lstCSVLines[i];
                //String prevLine = csvLine;
                Integer startIndex;
                Integer endIndex;
                
                while(csvLine.indexOf('"') > -1){
                
                    if(startIndex == null){
                        startIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                    }else{
                        if(endIndex == null){
                            endIndex = csvLine.indexOf('"');
                            csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                        }
                    }
                    
                    if(startIndex != null && endIndex != null){
                        String sub = csvLine.substring(startIndex, endIndex);
                        sub = sub.replaceAll(',', ':comma:');
                        csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                        startIndex = null;
                        endIndex = null;
                    }
                }
                
                List<String> csvRowData = new List<String>();
                for(String column : csvLine.split(',')){
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    csvRowData.add(column);
                }
                /*if(csvRowData[39] == '' || csvRowData[39] == null){
                    throw new AuraHandledException('Please provide End Customer URL value.');
                }*/
                
                if(csvRowData[0] == '' || csvRowData[1] == ''){
                  
                    throw new AuraHandledException('One or more rows in the file does not have the required field(s) (Group ID, Header/Product) populated. Please fix the data and try again.');
                }
                //if(csvRowData[0].isNumeric()){
                    //throw new AuraHandledException('One or more rows in the file has non-numeric value in Group ID Column. Please fix the data and try again.');
                //}
                if(csvRowData[1] != 'Header' && csvRowData[1] != 'Product'){
                    throw new AuraHandledException('One or more rows in the file has different value other than Header or Product in Header/Product Column. Please fix the data and try again.');
                }
                drs.Core_Batch_ID__c = listDRStageBatchGetAll[0].Id;
                drs.Core_Group_Id__c = csvRowData[0];
                drs.Core_Header_Or_Product_Ind__c = csvRowData[1];
                drs.Core_Design_Registration_Line_Id__c = csvRowData[2];
                drs.Core_Product_Id__c = csvRowData[3];
                drs.Core_Full_Year_Qty__c = csvRowData[4];
                drs.Core_Target_Resale_Amt__c = csvRowData[5];
                drs.Core_Partner_Tracking_Cd__c = csvRowData[6];
                drs.Core_Cancelled_Ind__c = csvRowData[7];
                drs.Core_Comment_Txt__c = csvRowData[8];
                drs.Core_Registration_Number_Id__c = csvRowData[9];
                drs.Core_Owner_Txt__c = csvRowData[10];
                drs.Core_Product_Group_Nm__c = csvRowData[11];
                drs.Core_Design_Registration_Nm__c = csvRowData[12];
                drs.Core_Design_Registration_Dsc__c = csvRowData[13];
                drs.Core_Opportunity_Volume_Cnt__c = csvRowData[14];
                drs.Core_Partner_FAE_Nm__c = csvRowData[15];
                drs.Core_Partner_FSR_Nm__c = csvRowData[16];
                drs.Core_End_Customer_Nm__c = csvRowData[17];
                drs.Core_End_Customer_Street_Addr_Line1_Txt__c = csvRowData[18];
                drs.Core_End_Customer_Street_Addr_Line2_Txt__c = csvRowData[19];
                drs.Core_End_Customer_City_Nm__c = csvRowData[20];
                drs.Core_End_Customer_Country_Subdivision_Nm__c = csvRowData[21];
                drs.Core_End_Customer_Postal_Cd__c = csvRowData[22];
                drs.PCC_End_Customer_Country__c = csvRowData[23];
                drs.Core_End_Customer_Contact_Title_Txt__c = csvRowData[24];
                drs.Core_End_Customer_Contact_Nm__c = csvRowData[25];
                drs.Core_End_Customer_Contact_Email_Txt__c = csvRowData[26];
                drs.Core_End_Customer_Contact_Phone_Txt__c = csvRowData[27];
                drs.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = csvRowData[28];
                drs.Core_Opportunity_Decision_Dt__c = csvRowData[29];
                drs.Core_First_Customer_Ship_Dt__c = csvRowData[30];
                drs.Core_Production_End_Dt__c = csvRowData[31];
                drs.Core_Vertical_Market_Nm__c = csvRowData[32];
                drs.Core_Intel_Platform_Nm__c = csvRowData[33];
                drs.Core_Product_Segment_Nm__c = csvRowData[34];
                drs.Core_Product_Application_Nm__c = csvRowData[35];
                drs.Core_Manufacturing_Region_Cd__c = csvRowData[36];
                drs.Core_End_Customer_URL__c = csvRowData[37];
                drs.DDR_Partner_FAE_Email__c = csvRowData[38];
                drStageListToInsert.add(drs);
            }
            //insert drStageListToInsert;
            Database.insert(drStageListToInsert,false,AccessLevel.USER_MODE);
            Core_DDR_Stage_Validator createDesignRegAndDesignRegProd = new Core_DDR_Stage_Validator();
            createDesignRegAndDesignRegProd.checkValidations(drStageListToInsert);
            return [Select Id,Core_Batch_ID__c,Core_Group_Id__c,Core_Header_Or_Product_Ind__c,Core_Design_Registration_Line_Id__c,Core_Product_Id__c,Core_Full_Year_Qty__c,Core_Target_Resale_Amt__c, Core_Partner_Tracking_Cd__c,Core_Cancelled_Ind__c,Core_Comment_Txt__c,Core_Registration_Number_Id__c,Core_Owner_Txt__c,Core_Product_Group_Nm__c,Core_Design_Registration_Nm__c,Core_Design_Registration_Dsc__c,Core_Opportunity_Volume_Cnt__c,Core_Partner_FAE_Nm__c,Core_Partner_FSR_Nm__c,Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_City_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,PCC_End_Customer_Country__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Opportunity_Decision_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Vertical_Market_Nm__c,Core_Intel_Platform_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_Manufacturing_Region_Cd__c,Core_End_Customer_URL__c From Core_Design_Registration_Stage__c Where CreatedDate>=:Date.TODAY() with USER_MODE ];
        //}
        /*catch(Exception e){
            system.debug('e.message-->'+e.);
            throw new AuraHandledException('An unexpected error has occured while importing the file. Please review the file before trying again.');
            //Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_CreateDesignRegistrationUtility_V1' ,'' ,ex); 
        }*/
    }
}