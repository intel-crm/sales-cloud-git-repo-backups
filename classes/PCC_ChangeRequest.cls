/**
     * Developer - Dinesh
     * Date Created - 7/11/24
     * Description -
     * PCC_ChangeRequest class provides functionalities for handling PCC Change Requests, including fetching field mappings,
     * retrieving records, creating change requests, and building SOQL queries.
     *
     * This class is designed to support operations related to PCC Change Requests, including:
     * - Fetching field mappings for columns.
     * - Retrieving records based on these mappings.
     * - Creating change requests and their line items.
     * - Building dynamic SOQL queries based on the field mappings.
     *
     * Methods:
     * - getColumns: Retrieves the active field mappings for the partner screen.
     * - getRecords: Retrieves records based on the opportunity ID and field mappings.
     * - createChangeRequest: Creates a new change request and links associated files.
     * - createChangeRequestLine: Creates new change request line items.
     * - buildSOQL: Constructs a SOQL query based on the field mappings.
     * - returnFilter: Constructs the filter part of the SOQL query based on the provided criteria.
     */
    public without sharing class PCC_ChangeRequest {
        
        /**
         * get products ids from deal products
         *
         */
        @AuraEnabled
        public static map<Id, Id> getProductsIds(List<Id> ids){
            Map<Id, Id> mapping = new Map<Id, Id>();
            try {
                for(Product_Additional_Attribute__c paa : [select Id, Product__c from Product_Additional_Attribute__c where id in :ids ]){
                    mapping.put(paa.Id, paa.Product__c);
                }
                
                return mapping;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        
        /**
         * Retrieves the active field mappings for the partner screen.
         *
         * @return List of PCC_Change_Request_Field_Mapping__c records.
         */
        @AuraEnabled(cacheable = true)
        public static List<PCC_Change_Request_Field_Mapping__c> getColumns(String url) {
            String featurename = url.contains('site')?'%partnerscreen%':'%psamcreatescreen%';
            try {
                return getNewColumns(featurename);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /**
         * getNewColumns
         *
         */
        @AuraEnabled(cacheable = true)
        public static List<PCC_Change_Request_Field_Mapping__c> getNewColumns(String featurename) {
            try {
                return [SELECT Id,Name,  PCC_Field_API_Name__c, PCC_Active__c,resizable__c, PCC_Object_Name__c, FieldType__c, Label__c, UseFieldName__c, initialWidth__c,  wrapText__c, cellClass__c, EditColumn__c, Enable_for_Partner__c, Enable_for_PSAM__c, Disabled__c, Enable_on_Partner_Screen__c, Enable_for_PSAM_Screen__c, isParent__c, Enable_for_Query__c, WrapperFieldName__c, Partner_Screen_Column_Order__c, PSAM_Screen_Column_Order__c, actions__c, cellAttributes__c, editable__c, fieldName__c, fixedWidth__c, hideDefaultActions__c, iconName__c, sortable__c, typeAttributes__c, DataTableAttributeName__c, DisableDefaultValue__c, EditDefaultValue__c, FieldAPIName__c, Parent_Object_API_Name__c, Child_Object_API_Name__c, Enable_for_Filter__c, Filter_Criteria__c, Filter_Criteria_Sequence__c, Object_Field_Data_Type__c, FeatureName__c, ByPassSoqlValueMappping__c
            FROM PCC_Change_Request_Field_Mapping__c 
            WHERE PCC_Active__c = true AND FeatureName__c like :featurename
            ORDER BY Partner_Screen_Column_Order__c ASC];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /**
         * Retrieves records based on the opportunity ID and field mappings.
         *
         * @param OpportunityId The ID of the Opportunity record.
         * @return List of maps where each map represents a record with field mappings applied.
         */
        @AuraEnabled
        public static List<Map<String, String>> getRecords(Id OpportunityId, String url) {
            try {
                List<PCC_Change_Request_Field_Mapping__c> fieldMappingsList = getColumns(url);
                Opportunity opp = Database.query(buildSOQL(fieldMappingsList));
                System.debug('Opportunity -->' + JSON.serialize(opp));
                
                Set<String> childObjects = new Set<String>();
                for (PCC_Change_Request_Field_Mapping__c crrecord : fieldMappingsList) {
                    if (!String.isBlank(crrecord.Child_Object_API_Name__c) && opp.getPopulatedFieldsAsMap().keySet().contains(crrecord.Child_Object_API_Name__c)) {
                        childObjects.add(crrecord.Child_Object_API_Name__c);
                    }
                }
                
                System.debug('childObjects' + JSON.serialize(childObjects));
                List<Map<String, String>> fieldMappings = new List<Map<String, String>>();
                for (String child : childObjects) {
                    if (!String.isBlank(child)) {
                        fieldMappings.addAll(FieldMappingService.createObjectWrapper(fieldMappingsList, child, opp));
                    }
                }
                
                if(childObjects.size() == 0){
                    fieldMappings.addAll(FieldMappingService.createObjectWrapper(fieldMappingsList, '', opp));
                }
                
                System.debug('fieldMappings -->' + JSON.serialize(fieldMappings));
                
                return fieldMappings;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /**
         * Creates a new change request and links associated files.
         *
         * @param changeHeaderPayload JSON string representing the change request header.
         * @param fileIds JSON string representing the list of file IDs to be linked.
         * @return The created PCC_Deal_Change_Request__c record.
         */
        @AuraEnabled
        public static PCC_Deal_Change_Request__c createChangeRequest(String changeHeaderPayload) { //, String fileIds
            try {
                System.debug('Change Request  -->' + JSON.serialize(changeHeaderPayload));
                PCC_Deal_Change_Request__c changeRequestRecords = (PCC_Deal_Change_Request__c) JSON.deserialize(changeHeaderPayload, PCC_Deal_Change_Request__c.class);
                // List<String> documentIds = (List<String>) JSON.deserialize(fileIds, List<String>.class);
                
                System.debug('Change Request Header -->' + JSON.serialize(changeRequestRecords));
                insert changeRequestRecords;
                
                // List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                // for (String id : documentIds) {
                    //     ContentDocumentLink docLink = new ContentDocumentLink();
                    //     docLink.ContentDocumentId = id;
                    //     docLink.LinkedEntityId = changeRequestRecords.Id;
                    //     docLink.ShareType = 'V';
                    //     docLink.Visibility = 'AllUsers';
                    //     links.add(docLink);
                // }
                
                // if (links.size() > 0) {
                    //     insert links;
                // }
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting change request for approval.');
                req1.setObjectId(changeRequestRecords.id);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setProcessDefinitionNameOrId('PCC_Change_Request_Approval');
                Approval.ProcessResult result = Approval.process(req1);
                
                return changeRequestRecords;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /**
         * Creates new change request line items.
         *
         * @param changeLinePayload JSON string representing the change request line items.
         * @return Boolean indicating success or failure of the operation.
         */
        @AuraEnabled
        public static Boolean createChangeRequestLine(String changeLinePayload) {
            try {
                System.debug('Change Request Payload -->' + changeLinePayload);
                
                List<PCC_Deal_Change_Request_Line_Item__c> changeRequestLineItemsRecords = (List<PCC_Deal_Change_Request_Line_Item__c>) JSON.deserialize(changeLinePayload, List<PCC_Deal_Change_Request_Line_Item__c>.class);
                insert changeRequestLineItemsRecords;
                
                return true;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /**
         * Constructs a SOQL query based on the field mappings.
         *
         * @param changeRequestRecords List of PCC_Change_Request_Field_Mapping__c records that define the field mappings.
         * @return The constructed SOQL query as a string.
         */
        @AuraEnabled
        public static String buildSOQL(List<PCC_Change_Request_Field_Mapping__c> changeRequestRecords) {
            String query = 'Select ';
            List<String> parentFields = new List<String>();
            List<String> ChildFields = new List<String>();
            String parenObjectAPIName = '';
            String childObjectAPIName = '';
            String subQuery = ', (select ';
            String childFilter = '';
            String parentFilter = '';
            
            Map<Integer, String> filterQueryMap = new Map<Integer, String>();
            
            for (PCC_Change_Request_Field_Mapping__c cr : changeRequestRecords) {
                if (cr.Name.contains('ParentQueryFilter')) {
                    parentFilter = cr.PCC_Field_API_Name__c;
                }
                if (cr.Name.contains('ChildQueryFilter')) {
                    childFilter = cr.PCC_Field_API_Name__c;
                }
                if (cr.Enable_for_Filter__c) {
                    filterQueryMap.put(Integer.valueOf(cr.Filter_Criteria_Sequence__c), cr.Filter_Criteria__c);
                }
                if (cr.isParent__c && cr.Enable_for_Query__c) {
                    parenObjectAPIName = cr.PCC_Object_Name__c;
                    parentFields.add(cr.PCC_Field_API_Name__c);
                }
                if (!cr.isParent__c && cr.Enable_for_Query__c) {
                    childObjectAPIName = cr.Child_Object_API_Name__c;
                    ChildFields.add(cr.PCC_Field_API_Name__c);
                }
            }
            
            if (String.isBlank(childObjectAPIName)) {
                subQuery = '';
            } else {
                subQuery += ' ' + String.join(ChildFields, ',') + ' from ' + childObjectAPIName + ' ' + returnFilter(childFilter, filterQueryMap) + ')';
            }
            
            query += String.join(parentFields, ',') + subQuery + ' from ' + parenObjectAPIName + ' ' + returnFilter(parentFilter, filterQueryMap);
            List<String> stages = new List<String>{'Define','Design','Qualify', 'Develop'};
            // query += 'and StageName in :'+stages;
            System.debug(query);
            
            return query;
        }
        
        /**
         * Constructs the filter
        
        part of the SOQL query based on the provided criteria.
             *
         * @param logicExpression The logical expression for the filter.
         * @param filterQueryMap Map of filter criteria.
         * @return The constructed filter part of the SOQL query as a string.
         */
        public static String returnFilter(String logicExpression, Map<Integer, String> filterQueryMap) {
            System.debug('filterQueryMap -->'+JSON.serialize(filterQueryMap));
            String filter;
            if (!String.isBlank(logicExpression)) {
                for (Integer id : filterQueryMap.keySet()) {
                logicExpression = logicExpression.replace('{' + id + '}', filterQueryMap.get(id));
            }
        }
        filter = logicExpression;
        return String.isEmpty(filter) ? filter : 'Where ' + filter;
    }
    
    
    /**
     * check existin change request records
     * @param opportunityId - accepts the opportunity id
     */
    @AuraEnabled
    public static List<PCC_Deal_Change_Request__c> getExistingChangeRequest(String opportunityId){
        List<PCC_Deal_Change_Request__c> pendingChangeRequest  = [select id, Name from PCC_Deal_Change_Request__c where PCC_Opportunity__c = :opportunityId and  (PCC_Approval_Status__c ='Submitted' or PCC_Approval_Status__c ='Review in Progress') order by createddate desc];
        return pendingChangeRequest;
    }
    
    
    // DRP creation method and rolling back transaction
    @AuraEnabled
    public static ResponseWrapper createDRP(String recordDetails){
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('Record Details -->'+recordDetails);
            Core_Design_Registration_Product__c product = (Core_Design_Registration_Product__c) JSON.deserialize(recordDetails, Core_Design_Registration_Product__c.class);
            // product.Core_Target_Resale_Amt__c=0;
            Database.SaveResult[] result =  Database.insert(new List<Core_Design_Registration_Product__c> {product}, false);
            System.debug('result -->'+JSON.serialize(result));
            List<ErrorWrapper> errors = new List<ErrorWrapper>();
            for(Database.SaveResult sr : result){
                if(!sr.isSuccess()){
                    ErrorWrapper err;
                    for(Database.error error : sr.getErrors()){
                        err = new ErrorWrapper();
                        err.fieldName = error.getFields();
                        err.message = error.getMessage();
                        err.statusCode = error.getStatusCode();
                        errors.add(err);
                    }
                }
            }
            // get the inserted product details
            
            List<Core_Design_Registration_Product__c> productDetails = [select  Name, RecordTypeId, Core_Design_Registration_Id__c, Core_Design_Product_Status_Nm__c, Core_Design_Registration_Line_Id__c, Core_Full_Year_Qty__c, Core_Full_Year_Value_Amt__c, Core_Intel_Technical_Owner_Email_Txt__c, Core_Locked_Ind__c, Core_Opportunity_Product_Id__c, Core_Partner_Tracking_Cd__c, Core_Product_Id__c, Core_Retired_As_Of_Dt__c, Core_Target_Resale_Amt__c, Core_Design_Registration_Stage_Id__c, Core_Comment_Txt__c, Core_Product_List_Price_Amt__c, Core_Design_Registration_Nm__c, Core_Design_Registration_Owner_Nm__c, Core_End_Customer_Account_Nm__c, Core_End_Customer_City_Nm__c, Core_End_Customer_Country_Subdivision_Nm__c, Core_End_Customer_Nm__c, Core_Intel_Technical_Owner_Nm__c, Core_Opportunity_Nm__c, Core_Partner_FAE_Nm__c, Core_Active_Status__c, Core_DR_Eligible_Status__c, core_cpq_OPN_Concatenation_txt__c, core_cpq_product_hierarchy_txt__c, DDR_Target_Resale_Price_Note__c, Core_External_Id__c, Core_Submission_Type__c, PCC_Total_Design_Registration_Price__c, PCC_Additional_Comments__c, PCC_Competitor_Name__c, PCC_Competitor_OEM_Name__c, PCC_Competitor_Product__c, PCC_Competitor_System_Model__c, PCC_Competitor_Write_In_OEM_Name__c, PCC_Form_Factor__c, PCC_OEM_Name__c, PCC_Product_Additional_Attribute__c, PCC_Quote_Line_Pricing_End_Date__c, PCC_Quote_Line_Pricing_Start_Date__c, PCC_System_Model__c, PCC_Write_In_Competitor_Product__c, PCC_Write_In_OEM_Name__c, PCC_Competitor_Product_Provider__c, PCC_Deal_Eligible_Status__c, PCC_Programs_Eligible__c from Core_Design_Registration_Product__c  where id = :product.id];
            
            ResponseWrapper resp = new ResponseWrapper();
            resp.wrapperLst = errors;
            resp.saved = errors.size()>0?false:true;
            resp.product = productDetails.size()>0?productDetails[0]:null;
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }finally{
            Database.rollback(sp);
        }
    }
    
    public class ResponseWrapper{
        @AuraEnabled public List<ErrorWrapper> wrapperLst{get;set;}
        @AuraEnabled public boolean saved{get;set;}
        @AuraEnabled public Core_Design_Registration_Product__c product{get;set;}
        
    }
    
    public class ErrorWrapper{
        @AuraEnabled public List<String> fieldName{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public StatusCode statusCode{get;set;}
    }

    
}