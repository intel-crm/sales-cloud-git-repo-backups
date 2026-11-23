/**************************************************************************************
Apex Class Name:  Core_OpportunitySearchController
Version     : 1.0 
Created Date: 10 OCT 2014
Function    : Apex Class (Controller) for Core_OpportunitySearch Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             10/10/2014             Original Version
* Harshith M L             02/17/2015             Added code for optimizing Search ( Line No - 429,482,491-497,500,642-698)
* Harshith M L             02/17/2015             Added code for Exception handling ( Line No - 666 - 670)
* Brian Matthews           03/09/2015             Clone Cleanup
* Brian Matthews           06/18/2015             Opportunity Partner Search
* Ashwin Dash              06/20/2017             US67789: Commenting the existing sending mail to Owner and adding a path to a new vfpage where we can submit for approval
*************************************************************************************/
public without sharing class Core_OpportunitySearchController {//TWC3123-5338 Added without sharing keyword to fix code scan issue


    private static final String  DEFAULT_SORT_FIELD   = 'Core_Intel_Platform__c';
    private static final String  FIVE_SPACES          = '     ';
    private static final integer MAX_ACCESS_RECORDS   = 200;
    private static final String  NONE_SELECTED        = '--None--';
    private static final String  OPPORTUNITY_OBJECT   = 'Opportunity';
    private static final String  OPPORTUNITY_RELATION = 'Core_Opportunity__r';
    private static final String  PARTNER_FIELDS       = 'Core_Partner_Type__c';
    private static final String  PARTNER_OBJECT       = 'Core_Opportunity_Partner__c';
    private static final String  RISK_REASON_FIELD    = 'Core_Risk_Reason__c';
    
    // To store opportunity fields added to the feild set
    private List<Schema.FieldSetMember> lstOpportunityFieldSetMembers = SObjectType.Opportunity.FieldSets.Core_GlobalOpportunitySearch.getFields();
    private List<Schema.FieldSetMember> lstPartnerFieldSetMembers     = SObjectType.Core_Opportunity_Partner__c.FieldSets.Core_OpportunityPartnerSearch.getFields();

    public List<Core_FieldSetWrapper> lstOpportunityFieldSetWrapper { get; set; }   // List to store fieldset and its value for searching
    public List<Core_FieldSetWrapper> lstPartnerFieldSetWrapper     { get; set; }   // List to store fieldset and its value for searching

    private Boolean bWhereClauseSet { get; set; }                        // Flag to check whether user has entered anything for search criteria
    private Integer iTotalNoOfRecs;                                      // To store total number of records
    
    // To store schema of all the objects
    private Map < String, Schema.SObjectType> mapSchemalabelSobjecttype = Schema.getGlobalDescribe();
    public  Map < id, WrapperClass> mapOpportunityidWrapperclass { get; set; } // List to store opportunities and user access details 
    
    Public List<WrapperClass> lstSearchOpportunities { get; set; }       // List to store opportunities and user access details

    public SET < ID> setOpportunityIds { get; set; }                     // Set to store the opportunity records for which access request is sent

    public Id selectedOpportunityId { get; set; }                        // To store Opportunity Id used for sending email
    public Boolean bEmployeeAccessCode { get; set; }                     // Flag to check whether user is having access to view the page
    public Boolean bErrorMessage { get; set; }                           // Flag to render error message if user didn't enter value for search criteria
    public Boolean bMoreRecords { get; set; }                            // Flag to render message if there are more than 1000 records
    public Boolean bMultiselectPresent { get; set; }                     // Flag to check multiselect picklist present in the field set
    public Boolean bOpportunitiesPresent { get; set; }                   // Flag to check whether opportunities are present for the search criteria 
    public Boolean bAccountCreateable { get; set; }                      // Flag to check whether account can be created
    public Integer iEmailSentCount { get; set; }                         // Integer to store the count of emails sent
    public Integer iPageSize { get; set; }                               // To store page size
    public Integer iNoOfPages { get; set; }                              // Keep track of total number of pages
    public Integer iPageNumber { get; set; }                             // Store Page Number
    public String sBaseURL { get; set; }                                 // To store base URL of Salesforce instance
    public String sColumnSize { get; set; }                              // To store the column size of the table
    public String partnerName { get; set; }                              // Content of Partner Name field
    public String partnerType {get; set; }                               // Content of Partner Type field 
    public transient String sCurrentPageNo { get; set; }                 // Store the current page number


    private Boolean partnerSearchOverride = false;


    public String partnerFields {
        get {
            return PARTNER_FIELDS;            
        }
    }                                  


    public Boolean isPartnerSearch {
        get {    
                if (partnerSearchOverride)
                    return true;
                    
                if (String.isNotBlank(partnerName))
                    return true;
                            
                if (String.isNotBlank(partnerType) && (partnerType != NONE_SELECTED))
                    return true;
        
                for (Core_FieldSetWrapper fieldSet : lstOpportunityFieldSetWrapper)
                    if (fieldSet.fieldName == RISK_REASON_FIELD)
                    {
                       
                        return (fieldSet.chosenItems.size() > 0);
                    }
                    
                return false;
        }
    }

    public Core_SortedGrid_ColumnHeader sortHeader 
    {
        get 
        {
             if (sortHeader == NULL)
                 sortHeader = new Core_SortedGrid_ColumnHeader(DEFAULT_SORT_FIELD);
                 
             return sortHeader;                
        }        
        set
        {
             sortHeader = value;       
        }
    }
     
                
    // UI Input sObject
    public Opportunity inputOpp { 
        get 
        {
            if (inputOpp == NULL) 
                inputOpp = new Opportunity(CloseDate=NULL);                                            
                                      
            return inputOpp;
        } 
                                  
        set 
        {
            inputOpp = value;
        }                             
    }

    // Constructor
    public Core_OpportunitySearchController() {

        // Setting email sent count to 0
        iEmailSentCount = 0;
        
        // Setting up the Employee Access Code flag to false
        bEmployeeAccessCode = false;
        
        // Fetching Current user details 
        User currentUserInfo = [SELECT Id, Name, Core_Employee_Type_Code__c FROM User Where Id = : userInfo.getUserId()];
        
        // Validating whether user is having access to the page
        if (currentUserInfo.Core_Employee_Type_Code__c != NULL && (currentUserInfo.Core_Employee_Type_Code__c == System.Label.Core_Employee_Type)) {
        
            // Updating the flag since user is having access to the page
            bEmployeeAccessCode = true;
            
            // Flag to identify whether multiselect picklist is present in field set 
            bMultiselectPresent = false;
            
            // Checking whether user is having access to create opportunity
            bAccountCreateable = Schema.sObjectType.Opportunity.isCreateable();
            
            // List to hold wrapper instances
            lstOpportunityFieldSetWrapper = new List<Core_FieldSetWrapper>();
            lstPartnerFieldSetWrapper     = new List<Core_FieldSetWrapper>();

            // Calling populate field set method which populates fields on page driven by the field set
            populateFieldSet(OPPORTUNITY_OBJECT, lstOpportunityFieldSetMembers, lstOpportunityFieldSetWrapper);            
            renameOpportunityFields();

            populateFieldSet(PARTNER_OBJECT, lstPartnerFieldSetMembers, lstPartnerFieldSetWrapper);                        
            renamePartnerFields();
            
            // Setting the flag to false which is used for identifying whether user entered any value before searching
            bWhereClauseSet = false;
            
            // Setting the Page size for pagination
            iPageSize = 50;
            
            // Setting the current page to 1
            sCurrentPageNo = '1';
            
            // Setting the current page to 1
            iPageNumber = 1;
            
            // Setting the total number of pages to 1
            iNoOfPages = 0;
            
            // Setting the flag to false which is used for showing info message if there are more than 1000 records retrived for the search criteria
            bMoreRecords = false;
            
            // Setting the flag to false which is used for showing error message if there are no records retrived for the search criteria
            bErrorMessage = false;
            
            // Setting the column size of the columns displayed in the table 
            sColumnSize = String.valueOf(100 / lstOpportunityFieldsetmembers.size());
            
            // Setting the flag to false which is used for showing error message if there are no records retrived for the search criteria
            bOpportunitiesPresent = true;
            
            // Setting the list to NULL
            lstSearchOpportunities = NULL;
            
            // Fetching the base URL of Salesforce instance
            sBaseURL = System.Label.Core_IPS_Notification_Internal_URL;
            
            // Intializing set of Ids
            setOpportunityIds = new SET < ID>();
        }

    }


    private void renameOpportunityFields()
    {
        for (Core_fieldSetWrapper fieldSetInstance : lstOpportunityFieldSetWrapper)
            if (fieldSetInstance.fieldLabel == 'Opportunity (U)')
                fieldSetInstance.fieldLabel = 'Amount';    
    }
    
    private void renamePartnerFields()
    {
        for (Core_fieldSetWrapper fieldSetInstance : lstPartnerFieldSetWrapper)
            if (fieldSetInstance.fieldLabel == 'Account Name')
                fieldSetInstance.fieldLabel = 'Partner Name';    
    }
    

    /*
     * Method name  : populateFieldSet
     * Description  : Puts the fields on the UI from the field set.
     * Return Type  : VOID
     * Parameter    : None
     */
    public void populateFieldSet(String ObjectName, List<Schema.FieldSetMember> lstFieldSetMembers, List<Core_fieldSetWrapper> lstFieldSetWrapper) {

        for (Schema.FieldSetMember fieldSetMember: lstFieldSetMembers) {
            
            
            
            // Checking the data type of the fields from the field set
            if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('STRING') || 
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('DOUBLE') || 
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('CURRENCY') || 
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('DATE') || 
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('PICKLIST') || 
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('MULTIPICKLIST') ||
                String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('REFERENCE')) {
                //Initialize fieldset wrapper instance and set the label, API Name and data type
                Core_fieldSetWrapper fieldSetInstance = new Core_fieldSetWrapper();
                fieldSetInstance.fieldName = fieldSetMember.getFieldPath();
                fieldSetInstance.fieldLabel = fieldSetMember.getLabel();
                
                // If field set member is the field from related object then capture related object and field details
                if (fieldSetMember.getfieldPath().contains('.')) {
                    Integer pos = fieldSetMember.getfieldPath().indexOf('.');
                    fieldSetInstance.relatedObject = fieldSetMember.getfieldPath().substring(0, pos);
                    fieldSetInstance.relatedField = fieldSetMember.getfieldPath().substring(pos + 1, fieldSetMember.getfieldPath().length());
                }

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('DOUBLE'))
                    fieldSetInstance.dataType = 'DOUBLE';

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('CURRENCY'))
                    fieldSetInstance.dataType = 'DOUBLE';

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('STRING'))
                    fieldSetInstance.dataType = 'STRING';

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('DATE'))
                    fieldSetInstance.dataType = 'DATE';

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('REFERENCE')) {
                    fieldSetInstance.dataType = 'REFERENCE';
                    if (bAccountCreateable)
                        fieldSetInstance.opportunityInstance = new Opportunity();
                } else if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('PICKLIST')) {
                    fieldSetInstance.picklistValues = new List<SelectOption>();
                    List<Schema.PicklistEntry> picklistValues;

                    //Populating the picklist values of the opportunity field
                    if (!(String.valueOf(fieldSetMember.getfieldPath()).contains('.'))) {
                        picklistValues = mapSchemalabelSobjecttype.get(ObjectName).
                                         getDescribe().fields.getMap().get(fieldSetMember.getFieldPath()).getDescribe().getPicklistValues();
                        fieldSetInstance.picklistValues.add(new SelectOption(System.Label.Core_None_Value, System.Label.Core_None_Value));
                        for (Schema.PicklistEntry picklist: picklistValues) {
                            fieldSetInstance.picklistValues.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
                        }
                    } else {
                        //Populating the picklist values of the related object's picklist field
                        Integer objectIndex = String.valueOf(fieldSetMember.getfieldPath()).indexOf('.');
                        String fieldName = String.valueOf(fieldSetMember.getfieldPath());
                        picklistValues = mapSchemalabelSobjecttype.get(fieldName.subString(0, objectIndex)).
                                         getDescribe().fields.getMap().get(fieldName.subString(objectIndex + 1, fieldName.length())).getDescribe().getPicklistValues();
                        fieldSetInstance.picklistValues.add(new SelectOption(System.Label.Core_None_Value, System.Label.Core_None_Value));
                        for (Schema.PicklistEntry picklist: picklistValues) {
                            fieldSetInstance.picklistValues.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
                        }
                    }
                }

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('PICKLIST')) {
                    fieldSetInstance.isPicklist = true;
                    fieldSetInstance.dataType = 'PICKLIST';
                    fieldSetInstance.selectedPicklistValue = System.Label.Core_None_Value;
                }

                if (String.ValueOf(fieldSetMember.getType()).equalsIgnoreCase('MULTIPICKLIST')) {
                    fieldSetInstance.isMultiSelectPicklist = true;
                    fieldSetInstance.dataType = 'MULTIPICKLIST';
                    bMultiselectPresent = true;

                    fieldSetInstance.allOptions = new List<SelectOption>();
                    fieldSetInstance.allOptionsMap = new Map < String, String>();
                    List<Schema.PicklistEntry> picklistValues;

                    //Populating the multi-select picklist values of the opportunity field
                    if (!(String.valueOf(fieldSetMember.getfieldPath()).contains('.'))) {
                        picklistValues = mapSchemalabelSobjecttype.get(ObjectName).getDescribe().
                                         fields.getMap().get(fieldSetMember.getFieldPath()).getDescribe().getPicklistValues();
                        for (Schema.PicklistEntry picklist: picklistValues) {
                            fieldSetInstance.allOptions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
                            fieldSetInstance.allOptionsMap.put(picklist.getLabel(), picklist.getValue());

                        }
                    } else {
                        //Populating the multi-select picklist values of the related object's picklist field
                        Integer objectIndex = String.valueOf(fieldSetMember.getfieldPath()).indexOf('.');
                        String fieldName = String.valueOf(fieldSetMember.getfieldPath());
                        picklistValues = mapSchemalabelSobjecttype.get(fieldName.subString(0, objectIndex)).
                                         getDescribe().fields.getMap().get(fieldName.subString(objectIndex + 1, fieldName.length())).getDescribe().getPicklistValues();
                        for (Schema.PicklistEntry picklist: picklistValues) {
                            fieldSetInstance.allOptions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
                            fieldSetInstance.allOptionsMap.put(picklist.getLabel(), picklist.getValue());
                        }
                    }
                    fieldSetInstance.availableItems = fieldSetInstance.allOptions;
                    fieldSetInstance.chosenItems = new List<SelectOption>();
                }
                lstFieldSetWrapper.add(fieldSetInstance);
            }
        }
    }


    /*
     * Method name  : buildQuery
     * Description  : Method to build the SELECT Statement adding the fields from the field set
     */
    private String buildQuery() {
    
        // Building query with the fields from the field set
        String query = 'SELECT ';
        for (Schema.FieldSetMember fieldSetMember: lstOpportunityFieldsetmembers) {
            query += fieldSetMember.getFieldPath() + ', ';
        }

        // We don't want the UI to add these so they are being added outside of the fieldset.        
        query += 'Core_Opportunity_Geo_ASMO__c, Core_Opportunity_Geo_EMEA__c, Core_Opportunity_Geo_APJ__c, CRM_Opportunity_Geo_INDIA__c,Core_Opportunity_Geo_PRC__c, '; 
        query += 'Owner.Name, Name, Account.Name, toLabel(Account.BillingCountryCode) ';
        query += ' FROM OPPORTUNITY ';        
        
        return query;
    }


    /*

* Method name  : comparisonOperator
     * Description  : Method to add the search parameter with the operator based on the data type of the field
     * Return Type  : String
     * Parameter    : String,String
     */
    private String comparisonOperator(String dataType, String searchValue) {
        String searchParameter = '';

        // Building the query with the value of parameter based on data type
        If(datatype.equalsIgnoreCase('STRING'))
            searchParameter = ' LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
        else if (datatype.equalsIgnoreCase('DATE'))
            searchParameter = ' = ' + searchValue.replace('/', '-') + ' ';            
        else if (dataType.equalsIgnoreCase('REFERENCE') || dataType.equalsIgnoreCase('PICKLIST'))
            searchParameter = ' = \'' + String.escapeSingleQuotes(searchValue) + '\'';

        return searchParameter;
    }


    /*
     * Method name  : getWhereClause
     * Description  : Method to add the where clause part based on the value provided by user.
     * Return Type  : VOID
     * Parameter    : String
     */
    private String getWhereClause(String fieldPrefix) {
        String whereClause = ' ';
        bWhereClauseSet = false;
        
        if (String.isBlank(fieldPrefix))
            fieldPrefix = '';  // Make sure it is a concatenatable string
        else
            fieldPrefix += '.';    

        // Iterating over the fieldset and checking whether user has entered any search criteria
        for (Core_fieldSetWrapper fieldSetInstance: lstOpportunityFieldSetWrapper) {
            Boolean bMultiSelectPicklistWhereClauseSet = false;

            // if user has entered search value for String fields it will added to the query here
            if (fieldSetInstance.dataType.equalsIgnoreCase('STRING') && !(fieldSetInstance.textValue.equalsIgnoreCase(''))) {
                whereClause += fieldPrefix + fieldSetInstance.fieldName + comparisonOperator(fieldSetInstance.dataType, String.escapeSingleQuotes(fieldSetInstance.textValue)) + ' AND ';
                bWhereClauseSet = true;

            }

            else if (fieldSetInstance.dataType.equalsIgnoreCase('DATE')) {
                String strDate = String.valueOf(inputOpp.CloseDate);
                
              
                if (String.isNotBlank(strDate))
                {
                    whereClause += fieldPrefix + fieldSetInstance.fieldName + comparisonOperator(fieldSetInstance.dataType, strDate) + ' AND ';
                    bWhereClauseSet = true;
                }
            }


            else if (fieldSetInstance.dataType.equalsIgnoreCase('REFERENCE') &&
                (fieldSetInstance.fieldName.equalsIgnoreCase('AccountId')) && bAccountCreateable) {
                String temp = '' + fieldSetInstance.opportunityInstance.AccountId;
                if (temp.length()>= 15) {
                    whereClause += fieldPrefix + fieldSetInstance.fieldName + comparisonOperator(fieldSetInstance.dataType, fieldSetInstance.opportunityInstance.AccountId) + 
                                ' AND ';
                    bWhereClauseSet = true;

                }
            }


            // if user has entered search value for Picklist fields ( if not none ) it will added to the query here
            else if (fieldSetInstance.dataType.equalsIgnoreCase('PICKLIST') && (fieldSetInstance.isPicklist) && 
                    fieldSetInstance.selectedPicklistValue != System.Label.Core_None_Value) {
                whereClause += fieldPrefix + fieldSetInstance.fieldName + comparisonOperator(fieldSetInstance.dataType, String.escapeSingleQuotes(fieldSetInstance.selectedPicklistValue)) + ' AND ';
                bWhereClauseSet = true;



            }

            // if user has entered search value for mutli-select picklist fields it will added to the query here
            else if (fieldSetInstance.dataType.equalsIgnoreCase('MULTIPICKLIST') && (fieldSetInstance.isMultiSelectPicklist)) {
                String searchString = '';
                for (SelectOption picklistValue: fieldSetInstance.chosenItems) {
                    // Validating whether user has selected other than NONE_SELECTED
                    if (picklistValue.getValue() != NONE_SELECTED) {
                        // Escaping single quotes to avoid SOQL Injection and adding all the chosen items to form a query
                        searchString += '\'' + String.escapeSingleQuotes(picklistValue.getValue()) + '\',';
                        bWhereClauseSet = true;
                        bMultiSelectPicklistWhereClauseSet = true;

                    }
                }
                if (bMultiSelectPicklistWhereClauseSet) {
                    // Removing extra ',' and adding it to where clause
                    searchString = searchString.substring(0, searchString.length() - 1);
                    whereClause += fieldPrefix + fieldSetInstance.fieldName + ' INCLUDES (' + searchString + ')' + ' AND ';
                }
            }
        }
        
        

        String geoCriteria = '';
        
        // Apex passes strings by reference . . .
        geoCriteria = checkGEOField(inputOpp.Core_Opportunity_Geo_APJ__c,  fieldPrefix + 'Core_Opportunity_Geo_APJ__c',  geoCriteria);                   
        geoCriteria = checkGEOField(inputOpp.Core_Opportunity_Geo_ASMO__c, fieldPrefix + 'Core_Opportunity_Geo_ASMO__c', geoCriteria);                   
        geoCriteria = checkGEOField(inputOpp.Core_Opportunity_Geo_EMEA__c, fieldPrefix + 'Core_Opportunity_Geo_EMEA__c', geoCriteria);                   
        geoCriteria = checkGEOField(inputOpp.Core_Opportunity_Geo_PRC__c,  fieldPrefix + 'Core_Opportunity_Geo_PRC__c',  geoCriteria);                   
        geoCriteria = checkGEOField(inputOpp.CRM_Opportunity_Geo_INDIA__c, fieldPrefix + 'CRM_Opportunity_Geo_INDIA__c',geoCriteria);
                      
         
                                      
        // The calling program truncates 5 characters off the end of the string, so add them.           
        
        if (geoCriteria.length() > 0)
        {
            whereClause += ' ( ' + geoCriteria + ' ) ' + FIVE_SPACES;
            bWhereClauseSet = true;
        }    
        
        return whereClause;
    }


    private static String checkGEOField(Boolean includeGEO, String geoField, String geoCriteria)
    {
        if (includeGEO)
        {
            if (geoCriteria.length() > 0)
                geoCriteria += ' OR ';
                
            geoCriteria += geoField + ' = true '; 
        }    
        
                         
        return geoCriteria;
    }


    /*
     * Method name  : Search
     * Description  : Method to search opportunity records when users enters the search criteria to search.
     * Return Type  : None
     * Parameter    : PageReference
     */
    Public PageReference search() {
        
        iEmailSentCount        = 0;        // Initializing email sent count to zero
        iPageNumber            = 1;            
        bErrorMessage          = false;    // Settting flag to false which will be used to show error on page                
        bMoreRecords           = false;    // Setting the flag to false which is used for showing info message if there are more than 1000 records retrived for the search criteria                
        lstSearchOpportunities = null;     // Setting list of opportunity to NULL

        partnerSearchOverride  = false;    // Reset the override

        if (isPartnerSearch)
            partnerSearch(true);
        else
            opportunityOnlySearch(true);

        return null;
    }


    Public PageReference autoPartnerSearch() {
        
        iEmailSentCount        = 0;        // Initializing email sent count to zero
        iPageNumber            = 1;            
        bErrorMessage          = false;    // Settting flag to false which will be used to show error on page                
        bMoreRecords           = false;    // Setting the flag to false which is used for showing info message if there are more than 1000 records retrived for the search criteria                
        lstSearchOpportunities = null;     // Setting list of opportunity to NULL

        partnerSearchOverride  = true;     // Used by the VForce Page to display partner search layout
        partnerSearch(true);
        return null;
    }


    private void partnerSearch(Boolean firstCall)
    {
       

        String partnerQuery = 'SELECT Id, Core_Partner__r.Id FROM Core_Opportunity_Partner__c ';    
        partnerQuery += getPartnerWhereClause(OPPORTUNITY_RELATION);

        if (firstCall)
        {
            iPageNumber   = 1;            
            partnerQuery += ' ORDER BY ' + getPartnerOrderByField(sortHeader.sortExpression) + ' ' + sortHeader.sortDirection + ' LIMIT 2000';        
        }
        else
        {
            Integer iOffset = iPageSize * (iPageNumber - 1);
            
            partnerQuery += ' ORDER BY ' + getPartnerOrderByField(sortHeader.sortExpression) + ' ' + sortHeader.sortDirection + ' LIMIT ' + iPageSize + ' Offset ' + iOffset;
        }


        

        // Get the Search Criteria Applied to a data set, ready for pre-qualification.
        // Apply Opportunity related criteria here, to further reduce the partner population
        List<Core_Opportunity_Partner__c> lstOppPartners = Database.query(partnerQuery);
        
        Map<Id, Id> oppPartnerAccountMap = new Map<Id, Id>();
        Map<Id, Id> queryMap             = new Map<Id, Id>();
        
        for (Core_Opportunity_Partner__c oppPartnerObj : lstOppPartners)
        {
            
            queryMap.put(oppPartnerObj.Id, oppPartnerObj.Core_Partner__r.Id);
            
            if (queryMap.size() == MAX_ACCESS_RECORDS)
            {
                checkRecordEditAccess(queryMap, oppPartnerAccountMap);                       
                queryMap.clear();            
            }  
        }
        

        if (queryMap.size() > 0)        
        {
            checkRecordEditAccess(queryMap, oppPartnerAccountMap);       
            queryMap.clear();            
        }

        Set<Id> oppPartnerSet = oppPartnerAccountMap.keySet();
        

        // Use pre-qualified list of partners as a search criteria.  
        //
        // A partner (Account) may have multiple opportunities, so the opportunity criteria needs to be re-applied here as well.
        // There's performance benefits in applying the opportunity and opportunity partner criteria twice.
        // 
        partnerQuery = 'SELECT Core_Partner__r.Id, ' +
                              'Core_Opportunity__r.Id, ' + 
                              'Core_Opportunity__r.Core_Intel_Platform__c, ' + 
                              'Core_Opportunity__r.Owner.Name, ' + 
                              'Core_Opportunity__r.Account.Name, ' + 
                              'toLabel(Core_Opportunity__r.Account.BillingCountryCode), ' + 
                              'Core_Opportunity__r.StageName, ' + 
                              'Core_Opportunity__r.CloseDate, ' +
                              'Core_Opportunity__r.Core_Product_Segment__c, ' + 
                              'Core_Opportunity__r.Core_Product_Application__c, ' + 
                              'Core_Opportunity__r.Core_Consumption_Market__c, ' + 
                              'Core_Opportunity__r.Core_Opportunity_Type__c, ' + 
                              'Core_Opportunity__r.Core_Opportunity_Geo__c, ' +  
                              'Core_Opportunity__r.Core_Opportunity_Country__c, ' +
                              'Core_Opportunity__r.Core_Risk_Reason__c, ' +  
                              'Core_Opportunity__r.Core_Solution_Focus__c, ' + 
                              'Core_Opportunity__r.Amount, ' +   
                              'Core_Opportunity__r.Core_Opportunity_Geo_ASMO__c, ' + 
                              'Core_Opportunity__r.Core_Opportunity_Geo_EMEA__c, ' + 
                              'Core_Opportunity__r.Core_Opportunity_Geo_APJ__c, ' + 
            		      'Core_Opportunity__r.CRM_Opportunity_Geo_INDIA__c,' +
                              'Core_Opportunity__r.Core_Opportunity_Geo_PRC__c, ' + 
                              'Core_Partner__r.Name, ' +
                              'toLabel(Core_Partner__r.BillingCountryCode), ' + 
                              'Core_Partner_Role__c, ' + 
                              'Core_Partner_Type__c ' + 
                       'FROM Core_Opportunity_Partner__c ';

        // second parameter "true" - use previously acquired Partner Ids to throttle the output of the query
        String whereClause = getPartnerWhereClause(OPPORTUNITY_RELATION);
        if (String.isBlank(whereClause)) 
            whereClause = 'WHERE Id IN :oppPartnerSet ';
        else
            whereClause += ' AND Id IN :oppPartnerSet ';           

        partnerQuery += whereClause;

        // limit not neeed as Partner Ids drive query content
        partnerQuery += ' ORDER BY ' + getPartnerOrderByField(sortHeader.sortExpression) + ' ' + sortHeader.sortDirection;        
                          
        


				lstOppPartners = Database.query(partnerQuery);
    
            
    
    
            if (firstCall)
            {
                bOpportunitiesPresent = !lstOppPartners.isEmpty();
                if (!bOpportunitiesPresent)
                    return;
                                
                bMoreRecords = (lstOppPartners.size() > 1000);                            // Setting the flag to display message on page if query returns more than 1000 records    
                
                iNoOfPages = Integer.valueOf(lstOppPartners.size() / iPageSize);          // Total no of pages to be displayed on page            
                if (iNoOfPages != 0 && Math.mod(lstOppPartners.size(), iPageSize)> 0)
                    iNoOfPages++;
                    
                if (iNoOfPages == 0)
                    iNoOfPages++;
            }

                
            // New list of wrapper class instances
            lstSearchOpportunities = new List<WrapperClass>();
            
            // Map to keep track of opportunities for which user is having access
            mapOpportunityidWrapperclass = new Map < Id, WrapperClass>();
    
            // Determing the page size. If there are more than 50 records then 50 records will be displayed if not then actual size 
            Integer iSearchResultSize = (lstOppPartners.size() >= 50 ? 50 : lstOppPartners.size());
        
            Set<Id> oppSet   = new Set<Id>();
            Set<Id> querySet = new Set<Id>();
                                    
            Core_Opportunity_Partner__c oppPartnerObj;
            
            // Adding retrieved records to wrapper 
            for (Integer iRecordIndex = 0; iRecordIndex < iSearchResultSize ; iRecordIndex++) {
                oppPartnerObj = lstOppPartners.get(iRecordIndex);
                querySet.add(oppPartnerObj.Core_Opportunity__r.Id);
                mapOpportunityidWrapperclass.put(oppPartnerObj.Core_Opportunity__r.Id, new WrapperClass(oppPartnerObj.Core_Opportunity__r, oppPartnerObj));
            }
                                                
            checkRecordReadAccess(querySet, oppSet);                        
                        
            // Filtering the records for which user is having  access and setting the bUserAccesspresent flag
            for (Id oppId: oppSet) {
                if (mapOpportunityidWrapperclass.containsKey(oppId)) {
                    mapOpportunityidWrapperclass.get(oppId).bUserAccessPresent = true;
                }
            }
            
            // Filtering the records for which user has already requested record access
            if (!setOpportunityIds.isEmpty()) {
                for (Id requestSentId: setOpportunityIds) {
                    if (mapOpportunityidWrapperclass.containsKey(requestSentId))
                        mapOpportunityidWrapperclass.get(requestSentId).bRecordAccessRequestSent = true;
                }
            }

            if (!mapOpportunityidWrapperclass.isEmpty())
                lstSearchOpportunities = mapOpportunityidWrapperclass.values();


    }


    private String getPartnerOrderByField(String fieldName)
    {
        
        if (fieldName.contains('Core_Partner__r.'))
            return fieldName;
        
        if (fieldName == 'Core_Partner_Role__c')
            return 'Core_Partner_Role__c';    

        if (fieldName == 'Core_Partner_Type__c')
            return 'Core_Partner_Type__c';    

        if (fieldName == 'AccountId')
            return 'Core_Opportunity__r.Account.Name';    

        if (fieldName == 'OwnerId')
            return 'Core_Opportunity__r.Owner.Name';

        return OPPORTUNITY_RELATION + '.' + fieldName;

    }
    

    private void checkRecordEditAccess(Map<Id, Id> queryMap, Map<Id, Id> partnerMap)
    {
        // Need to know if Accounts have Read-Write access.  This goes beyond what "WITH SHARING" offers.
        // UserRecordAccess Object only supports 200 records at a time.
        List<UserRecordAccess> lstAccountAccess = [SELECT RecordId 
                                                   FROM UserRecordAccess              
                                                   WHERE UserId = :UserInfo.getUserId()
                                                     AND RecordId IN :queryMap.values()
                                                     AND HasEditAccess = TRUE];
            
        // Rifle through the Account records and obtain their associated Opportunity_Partner Ids.    
        for (UserRecordAccess recordAccess : lstAccountAccess) // Account Ids
            for (Id mapKey : queryMap.keySet())
                if (queryMap.get(mapKey) == recordAccess.RecordId)
                    partnerMap.put(mapKey, queryMap.get(mapKey));     // Opportunity_Partner & Account Id onto result.

    }


    private void checkRecordReadAccess(Set<Id> queryIds, Set<Id> objIds)
    {
        // Need to know if objects have Read-Write access.  This goes beyond what "WITH SHARING" offers.
        // UserRecordAccess Object only supports 200 records at a time.
        
        List<UserRecordAccess> lstAccountAccess = [SELECT RecordId 
                                                   FROM UserRecordAccess              
                                                   WHERE UserId = :UserInfo.getUserId()
                                                     AND RecordId IN :queryIds
                                                     AND HasReadAccess = TRUE];
            
        for (UserRecordAccess recordAccess : lstAccountAccess)
            objIds.add(recordAccess.RecordId);     

    }


    private String getPartnerWhereClause(String fieldPrefix) {

        String whereClause = getWhereClause('Core_Opportunity__r');
        if (bWhereClauseSet)
            whereClause = ' WHERE ' + whereClause.subString(0, whereClause.length() - 5);
                    
        if (String.isNotBlank(partnerName) && partnerName != NONE_SELECTED)
        {
            if (String.isBlank(whereClause))
                whereClause = 'WHERE ';
            else
                whereClause += ' AND ';
                
            whereClause += ' Core_Partner__r.Name LIKE \'%' + String.escapeSingleQuotes(partnerName) + '%\' ';
        } 
            
        if (String.isNotBlank(partnerType) && partnerType != NONE_SELECTED)
        {
            if (String.isBlank(whereClause))
                whereClause = 'WHERE ';
            else
                whereClause += ' AND ';
                
            whereClause += 'Core_Partner_Type__c = \'' + partnerType + '\' ';
        }

        // Make sure both REFERENCES are loaded.  Avoid subtle bug.    
        if (String.isBlank(whereClause))
            whereClause = 'WHERE ';
        else
            whereClause += ' AND ';
                
        whereClause += 'Core_Opportunity__c != \'\' AND Core_Partner__c != \'\' ';

        

        return whereClause;        
    }


    private void opportunityOnlySearch(Boolean firstCall) {

        List<Opportunity> lstOpportunitiesQueried;

        if (firstCall) 
        {
            iPageNumber = 1;            
            lstOpportunitiesQueried = queryByPageSizeAndOffset(2000, 0);
            bOpportunitiesPresent = !lstOpportunitiesQueried.isEmpty();
            if (!bOpportunitiesPresent)
                return;
                        
            bMoreRecords = (lstOpportunitiesQueried.size()> 1000);                          // Setting the flag to display message on page if query returns more than 1000 records    
            
            iNoOfPages = Integer.valueOf(lstOpportunitiesQueried.size() / iPageSize);       // Populating total no of pages to be shown on page
            if (iNoOfPages != 0 && Math.mod(lstOpportunitiesQueried.size(), iPageSize) > 0)
                iNoOfPages++;
                
            if (iNoOfPages == 0)
                iNoOfPages++;
        }
        else    
        {
            Integer iOffset = iPageSize * (iPageNumber - 1);
            lstOpportunitiesQueried = queryByPageSizeAndOffset(iPageSize, iOffset);
        }    

        
                    
        wrapAndCheckAccess(lstOpportunitiesQueried);
            
    }


    private List<Opportunity> queryByPageSizeAndOffset(integer pPageSize, integer pOffset) {

        // Building query and adding the where clause part to the query
        String query = buildQuery();
        
        // Getting the where clause part of the query
        String whereClause = getWhereClause('');
        if (!bWhereClauseSet)
        {
            bErrorMessage = true;
            return new List<Opportunity>();
        }
            
        // Adding where clause part to the query
        query += ' WHERE ' + whereClause.subString(0, whereClause.length() - 5);

        List<Opportunity> lstOpp;
        
        try {
        
            String queryWithOrderBy = query + ' ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' LIMIT ' + pPageSize + ' Offset ' + pOffset;
            lstOpp = Database.query(queryWithOrderBy);
            
        } catch (Exception err) {
            ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
            ApexPages.addMessage(pageMessage);

            
            
            lstOpp = new List<Opportunity>();
        }
                
        return lstOpp; 
    }


    public void wrapAndCheckAccess(List<Opportunity> lstOpportunitiesQueried) {

        // New list of Wrapper Class instances
        lstSearchOpportunities = new List<WrapperClass>();
        
        // Map to store Opportunities Ids for which user is having access
        mapOpportunityidWrapperclass = new Map < Id, WrapperClass >();

        try {
            // Determing the page size. 
            // If there are more than 50 records then 50 records will be displayed if not then actual size 
            //
            Integer iSearchResultSize = (lstOpportunitiesQueried.size() >= 50 ? 50 : lstOpportunitiesQueried.size());
            
            SET<ID> setOpportunityRecordIds = new SET<ID>();
    
            // Adding retrieved records to wrapper 
            for (Integer iRecordIndex = 0; iRecordIndex < iSearchResultSize ; iRecordIndex++) {
                setOpportunityRecordIds.add(lstOpportunitiesQueried.get(iRecordIndex).Id);
                mapOpportunityidWrapperclass.put(lstOpportunitiesQueried.get(iRecordIndex).Id, new WrapperClass(lstOpportunitiesQueried.get(iRecordIndex)));
            }

            
            // Fetching opportunity records for which user is having access 
            List<Opportunity> userOpportunityRecords = Core_SearchUsersOpportunityRecords.doQuery('SELECT Id FROM Opportunity ', setOpportunityRecordIds);
           
            
    
    
            // Filtering the records for which user is having  access and setting the bUserAccesspresent flag
            for (Opportunity opportunityInstance: userOpportunityRecords) {
                if (mapOpportunityidWrapperclass.containsKey(opportunityInstance.Id)) {
                    mapOpportunityidWrapperclass.get(opportunityInstance.Id).bUserAccessPresent = true;
                }
            }
            
            // Filtering the records for which user has already requested record access
            if (!setOpportunityIds.isEmpty()) {
                for (Id requestSentId: setOpportunityIds) {
                    if (mapOpportunityidWrapperclass.containsKey(requestSentId))
                        mapOpportunityidWrapperclass.get(requestSentId).bRecordAccessRequestSent = true;
                }
            }
    
            if (!mapOpportunityidWrapperclass.isEmpty())
                lstSearchOpportunities = mapOpportunityidWrapperclass.values();
    
        } catch (Exception err) {
            ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
            ApexPages.addMessage(pageMessage);

           
            
        }
    }


    /*
     * Method name  : SendEmail
     * Description  : Method to send an email to opportunity owner to request access for opportunity record
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference SendEmail() {
        WrapperClass selectedOpp = mapOpportunityidWrapperclass.get(selectedOpportunityId);
        //START - US67789: Commenting the existing sending mail to Owner and adding a path to a new vfpage where we can submit for approval -- Ashwin
        /*if (iEmailSentCount < 10) {
            // Fetching the opportunity record for which access request is submitted
            WrapperClass selectedOpp = mapOpportunityidWrapperclass.get(selectedOpportunityId);
            //selectedOpp.bUserAccessPresent = true;
            selectedOpp.bRecordAccessRequestSent = true;
            setOpportunityIds.add(selectedOpportunityId);

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Setting the email id for which access request will be sent
            mail.setTargetObjectId(selectedOpp.opportunityInstance.ownerId);
            mail.saveAsActivity = false;

            // Setting the email body, subject and sending an email
                mail.setHTMLBody(System.Label.Core_Email_Template_Part1 + ' ' + selectedOpp.opportunityInstance.owner.Name + ',' 
                            + System.Label.Core_HTML_Line_Break + System.Label.Core_HTML_Line_Break + UserInfo.getName() + 
                            ' ' + System.Label.Core_Email_Template_Part2 + System.Label.Core_HTML_Link_Start 
                            + sBaseURL + '/' + selectedOpp.opportunityInstance.Id + System.Label.Core_HTML_Link_End + 
                            System.Label.Core_Email_Template_Part3);
            mail.setSubject(System.label.Core_Access_Request_Email_Subject);
            emailList.add(mail);
            Messaging.sendEmail(emailList);
        }
        iEmailSentCount++;*/
        //return null;
        PageReference newPage = new PageReference('/apex/Core_OpportunityTeamAccessReq?id='+selectedOpp.opportunityInstance.Id+'&usr='+selectedOpp.opportunityInstance.ownerId);
        return newPage;
        //END - US67789: Commenting the existing sending mail to Owner and adding a path to a new vfpage where we can submit for approval -- Ashwin
    }


    /*
     * Method name  : next
     * Description  : Method to populate the next set of opportunity records
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference next() {
        if (iPageNumber == 0) {
            iPageNumber += 2;
        } else {
            iPageNumber += 1;
        }

        // Fetching next set of records
        if (isPartnerSearch)
            partnerSearch(false);
        else    
            opportunityOnlySearch(false);

        return null;
    }

    /*
     * Method name  : previous
     * Description  : Method to populate the previous set of opportunity records
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference previous() {
        iPageNumber--;
        if (iPageNumber < 0)
            return null;

        if (iPageNumber == 0)
            iPageNumber = 1;

        // Fetching previous set of records
        if (isPartnerSearch)
            partnerSearch(false);
        else    
            opportunityOnlySearch(false);

        return null;
    }

    /*
     * Method name  : first
     * Description  : Method to go to the first page
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference first() {
        iPageNumber = 1;

        // Fetching first set of records
        // Reset the query by calling with a "true" parameter.
        if (isPartnerSearch)
            partnerSearch(true);
        else    
            opportunityOnlySearch(true);

        return null;
    }

    /*
     * Method name  : last
     * Description  : Method to go to the last page
     * Return Type  : None
     * Parameter    : PageReference
     */
    public PageReference last() {
        iPageNumber = iNoOfPages;
 
        // Fetching last set of records
        if (isPartnerSearch)
            partnerSearch(false);
        else    
            opportunityOnlySearch(false);
            
        return null;
    }


    public pagereference clearFilters() {
        PageReference pageRef = Page.Core_OpportunitySearch;
        pageRef.setRedirect(true);
        return pageRef;
    }


    // Wrapper Class to store Opportunity and user Access details
    public class WrapperClass {
        
        public Boolean bRecordAccessRequestSent { get; set; }   // Flag to check if user has request access for the record 
        public Boolean bUserAccessPresent { get; set; }         // Flag to set if user is having access to opportunity record
        public Opportunity opportunityInstance { get; set; }    // To store opportunity which was fetched based on search criteria

        public String strOpportunityGEO { get; set; } 

        public Core_Opportunity_Partner__c partnerInstance { get; set; }

        // Constructor for Partner Wrapper Class
        public WrapperClass(Opportunity opp, Core_Opportunity_Partner__c partner) {
        
            if (String.isblank(opp.Core_Opportunity_Country__c))
                if (!String.isblank(opp.Account.BillingCountryCode))  
                    opp.Core_Opportunity_Country__c = opp.Account.BillingCountryCode;
        
            opportunityInstance      = opp;
            partnerInstance          = partner;
            
            bUserAccessPresent       = false;            
            bRecordAccessRequestSent = false;
                        
            strOpportunityGEO        = geoFromOpportunity(opp);            
        }


        // Constructor for Opportunity Wrapper Class
        public WrapperClass(Opportunity opp) {

            if (String.isblank(opp.Core_Opportunity_Country__c))
                if (!String.isblank(opp.Account.BillingCountryCode))
                    opp.Core_Opportunity_Country__c = opp.Account.BillingCountryCode;
        
            opportunityInstance      = opp;
            bUserAccessPresent       = false;            
            bRecordAccessRequestSent = false;            
            
            strOpportunityGEO        = geoFromOpportunity(opp);            
        }
                
        
        private String geoFromOpportunity(Opportunity opp) {
        
            String result = '';
        
            if (opp.Core_Opportunity_Geo_ASMO__c)
                result += 'ASMO, ';
    
            if (opp.Core_Opportunity_Geo_EMEA__c)
                result += 'EMEA, ';
    
            if (opp.Core_Opportunity_Geo_APJ__c)
                result += 'APJ, ';
    
            if (opp.Core_Opportunity_Geo_PRC__c)
                result += 'PRC, ';
            if(opp.CRM_Opportunity_Geo_INDIA__c)
                result += 'INDIA, ';
                                                
            result = result.removeEnd(' ');
            result = result.removeEnd(',');
           
            return result;   
        }    
        
    }
}