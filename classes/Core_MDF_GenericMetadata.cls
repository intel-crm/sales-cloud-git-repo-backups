/****************************************************************************************************************************************
* Class Name  : Core_MDF_GenericMetadata 
* Test Class  : Core_MDF_GenericMetadata_Test
* Version     : 1.0 
* Created Date: 23-01-2024
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sandesh H        23/01/2024                    Created Core_MDF_GenericMetadata class to get all any Metadata from one class.
*****************************************************************************************************************************************/
public Without Sharing class Core_MDF_GenericMetadata {
 /***************************************************************************************************** 
Method Name   :        getObjectRecords
@return       :        List
@parameters   :        objectApiName and whereClause
Description   :        To return metadata records.
Added By      :        Accenture - Sandesh - 19/02/2024
Modified By   :        Date:       		Changes: 
******************************************************************************************************/ 
    
    
     @AuraEnabled(cacheable=true)
    public static List<sObject> getObjectRecords(String objectApiName, String whereClause) {
        List<sObject> queryResults = new List<sObject>();
        try{
            if(objectApiName != null){
                switch on objectApiName {
                    when 'Core_MDF_CCP_Country_Geo_Mapping__mdt' {
                        String queryString = 'SELECT Id, Label, DeveloperName, MasterLabel, Core_MDF_Code_2_Digits__c, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c,Core_MDF_Blocked_in_UI_ind__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt';
                        if (whereClause.trim() != '') {
                            String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                            queryString += ' WHERE ' + sanitizedWhereClause;
                        }
                        queryResults = Database.query(queryString);
                    }

                when 'CCP_Activity_Type_dependent_fields__mdt' {
                        String queryString = 'SELECT Core_MDF_Object_API_Field_Name__c, Core_MDF_Manadatory_Ind__c, Core_MDF_Program_Txt__c, Core_MDF_Activity_Type_Txt__c, Core_MDF_Activity_Category_Txt__c, Core_MDF_Activity_Subtype_Txt__c,  Core_MDF_Module__c, Core_MDF_Picklist_ind__c, Core_MDF_Is_Proposal_Based_Ind__c, Core_MDF_Is_Account_Based__c, Core_MDF_Is_Inactive_For_Activity_Ind__c, Core_MDF_Is_Inactive_For_Claim_Ind__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Is_EOLed_Ind__c  FROM CCP_Activity_Type_dependent_fields__mdt';
                        if (whereClause.trim() != '') {
                            String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                            queryString += ' WHERE ' + sanitizedWhereClause;
                    }
                    queryResults = Database.query(queryString);
                }
                    
                when 'Core_MDF_ClaimActAllocRecTypeMapping__mdt' {
                    String queryString = 'Select id,Label,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c,Core_MDF_Payment_RecordType_txt__c,Core_MDF_Channel_Program_txt__c,Core_MDF_ClaimStage_RecordType_txt__c,Core_MDF_Activity_Close_Days__c,Core_MDF_Internal_Master_Group_Name_Txt__c,Core_MDF_External_Master_Group_Name_Txt__c,Core_MDF_Region_cd__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_isProgramBased_Ind__c,Core_MDF_Budget_Cap_RecType_DevName_Txt__c,Core_MDF_isProposalBased__c  from Core_MDF_ClaimActAllocRecTypeMapping__mdt';
                        if (whereClause != null && whereClause.trim() != '') {
                            String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                            queryString += ' WHERE ' + sanitizedWhereClause;
                    }
                    queryResults = Database.query(queryString);
                    }

                    when 'Core_MDF_BudgetType_Benefit_Mapping__mdt' {
                        String queryString = 'Select Id, MasterLabel, Core_MDF_RecordType__c,Core_MDF_Record_Developer_Nm__c,Core_MDF_Budget_Type__c,Core_MDF_Partner_Benefit__c from Core_MDF_BudgetType_Benefit_Mapping__mdt';
                        if(whereClause != null && whereClause.trim() != ''){
                            String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                            queryString += ' Where '+sanitizedWhereClause;
                        }
                        queryResults = Database.query(queryString);
                    }
                }
             }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
    }


    /***************************************************************************************************** 
Method Name   :        getCountryGeoMappingMdt
@return       :        List
@parameters   :        whereClause
Description   :        To return metadata records.
Added By      :        Accenture - Sandesh - 19/02/2024
Modified By   :        Date:       		Changes: 
******************************************************************************************************/ 

    @AuraEnabled(cacheable=true)
    public static List<sObject> getCountryGeoMappingMdt(String whereClause) {
        List<sObject> queryResults = new List<sObject>();
        try{
            String queryString = 'SELECT Id, Label, DeveloperName, MasterLabel, Core_MDF_Code_2_Digits__c, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c,Core_MDF_Blocked_in_UI_ind__c,Core_MDF_Geo_Code_cd__c,Core_MDF_Geo_Sales_Org_Code_cd__c   FROM Core_MDF_CCP_Country_Geo_Mapping__mdt';
            if (whereClause != null && whereClause.trim() != '') {
                String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                queryString += ' WHERE ' + sanitizedWhereClause;
            }
            if(String.isNotBlank(queryString)){
                queryResults = Database.query(queryString);
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
    }

    /***************************************************************************************************** 
Method Name   :        getActivityTypeDependentFieldsMdt
@return       :        List
@parameters   :        whereClause
Description   :        To return metadata records.
Added By      :        Accenture - Sandesh - 19/02/2024
Modified By   :        Date:       		Changes: 
******************************************************************************************************/ 

    @AuraEnabled(cacheable=true)
    public static List<sObject> getActivityTypeDependentFieldsMdt(String whereClause) {
        List<sObject> queryResults = new List<sObject>();
        try{
            String queryString = 'SELECT Core_MDF_Object_API_Field_Name__c, Core_MDF_Manadatory_Ind__c, Core_MDF_Program_Txt__c, Core_MDF_Activity_Type_Txt__c, Core_MDF_Activity_Category_Txt__c, Core_MDF_Activity_Subtype_Txt__c,  Core_MDF_Module__c, Core_MDF_Picklist_ind__c, Core_MDF_Is_Proposal_Based_Ind__c, Core_MDF_Is_Account_Based__c, Core_MDF_Is_Inactive_For_Activity_Ind__c, Core_MDF_Is_Inactive_For_Claim_Ind__c, Core_MDF_Sort_Order_Nbr__c  FROM CCP_Activity_Type_dependent_fields__mdt';
            if (whereClause != null && whereClause.trim() != '') {
                String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                queryString += ' WHERE ' + sanitizedWhereClause;
            }
            if(String.isNotBlank(queryString)){
                queryResults = Database.query(queryString);
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
    }

    /***************************************************************************************************** 
Method Name   :        getClaimActAllocRecTypeMappingMdt
@return       :        List
@parameters   :        whereClause
Description   :        To return metadata records.
Added By      :        Accenture - Sandesh - 19/02/2024
Modified By   :        Date:       		Changes: 
******************************************************************************************************/ 

    @AuraEnabled(cacheable=true)
    public static List<sObject> getClaimActAllocRecTypeMappingMdt(String whereClause) {
        List<sObject> queryResults = new List<sObject>();
        try{
            String queryString = 'Select id,Label,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c,Core_MDF_Payment_RecordType_txt__c,Core_MDF_Channel_Program_txt__c,Core_MDF_ClaimStage_RecordType_txt__c,Core_MDF_Activity_Close_Days__c,Core_MDF_Internal_Master_Group_Name_Txt__c,Core_MDF_External_Master_Group_Name_Txt__c,Core_MDF_Region_cd__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_isProgramBased_Ind__c,Core_MDF_Budget_Cap_RecType_DevName_Txt__c,Core_MDF_isProposalBased__c  from Core_MDF_ClaimActAllocRecTypeMapping__mdt';
            if (whereClause != null && whereClause.trim() != '') {
                String sanitizedWhereClause = String.escapeSingleQuotes(whereClause).replaceAll('\\\\','');
                queryString += ' WHERE ' + sanitizedWhereClause;
            }
            if(String.isNotBlank(queryString)){
                queryResults = Database.query(queryString);
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return queryResults;
    }
    
/***************************************************************************************************** 
Method Name   :        getRecordType
@return       :        RecordType
@parameters   :        RecordTypeName Label and Object Name
Description   :        To accept the ChannelProgram and Object Name to return RecordType Data. 
Added By      :        Accenture - Sandesh - 23/01/2024
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    
    @AuraEnabled (cacheable=true)
    public static RecordType getRecordTypeId(String RecordTypeName, String objectName){ // RecordTypeName
        try {
           RecordType recordTypeId = [Select Id,Name,DeveloperName, Description from RecordType where SobjectType =: objectName and Name =: RecordTypeName limit 1];
           return recordTypeId;
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
            throw new AuraHandledException ( e.getMessage() );
        }
    }
}