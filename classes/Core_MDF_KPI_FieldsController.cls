/**
 * * Controller class to pull the KPI details by using the category, type from custom meta data
 * ? Method created by Sridahron 17-FEB-2020
 * Class Name -Core_MDF_KPI_FieldsController
 * Test Class Name - Core_MDF_KPI_FieldsTest
 * Modification Log -
 * 
 * Developer                    Date                Desc
 *
 * Ganapati                 30-05-2021              US1017582: Technical: [RMF] - [Activity] - Metrics to be made optional
 */
public with sharing class Core_MDF_KPI_FieldsController {

    /**
     * * Method to fetch the KPI Attributes method
     * * Input params - recordId,program,category,type and object name
     * ? Created by Sridhar on 17-FEB-2020
    */
    @AuraEnabled(cacheable = true)
    public static KPIAttributes getKPIValues(String inputValues) {

        KPIAttributes kpiAttrs = new KPIAttributes();

        if (inputValues != null){
                Map<String, Object> queryVariabels = (Map<String, Object>) JSON.deserializeUntyped(inputValues);
                string program = (string)queryVariabels.get('program');
                string category = (string)queryVariabels.get('activityCategory');
                string type = (string)queryVariabels.get('activityType');
                 
                string subType = '';
                List<String> subTypeList = new list<String>();
                String subtypeListStr = '';
                String multiSubType ='';
                // Subtype dependency only applicable for RMF
                if(Label.Core_MDF_Retail_Program_Name.equalsIgnoreCase(program)) {
                    subType = (string)queryVariabels.get('activitySubType');
                }
                //changes for IPA KPI Metrics
                else if(Label.Core_MDF_IPA_Program_Name.equalsIgnoreCase(program)) {
                    subTypeList = (List<String>) JSON.deserialize(JSON.serialize(queryVariabels.get('activitySubType')), List<String>.class);
                    if(subTypeList != null && !subTypeList.isEmpty()){
                        subtypeListStr ='(\'' + String.join(subTypeList, '\', \'') + '\')';
                        multiSubType = String.escapeSingleQuotes(subtypeListStr).replaceAll('\\\\','');
                    }
                }
                

                string objectName = (string)queryVariabels.get('objName');
                Boolean isProposal = false;
                String propStr = '';
                //US - TWC702-14285: Flatten nested IFs (no logic change)
                if(program == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM){
                    isProposal = queryVariabels.get('isProposalBased') != null ? (Boolean)queryVariabels.get('isProposalBased') : false; //Ayush - added null check as 'isProposalBased' was returning null if campaign is removed from Activity while cloning.
                    propStr = isProposal ? 'Core_MDF_Checkbox_Field_2_Ind__c = true' : 'Core_MDF_Checkbox_Field_5_Ind__c = true';
                    system.debug('propStr---'+propStr);
                }
                Id recordId = (Id)queryVariabels.get('recordId');
                Id activityId = (Id)queryVariabels.get('activityId');//Added by VB - KPI Metrics Changes
                string sectionTitle = (string)queryVariabels.get('title');
            
                if (objectName != null && program != null && category != null && type != null){



                    String categoryName = 'KPI';

                    String whereClause = 'Core_MDF_Program__c = \'' + program + '\' ' + 'AND Core_MDF_Field_1_txt__c = \'' + category + '\' ' + 'AND Core_MDF_Field_2_txt__c = \'' + type + '\' ' + 'AND Core_MDF_Category__c = \'' + categoryName + '\' ';

                    if(subtype != null && subtype != '') {
                        whereClause += 'AND Core_MDF_Field_3_txt__c = \'' + subtype + '\' ' + 'AND Core_MDF_Field_4_txt__c != NULL ' + 'AND Core_MDF_Sub_Category__c = \'' + objectName + '\' ';
                    }
                    //changes for IPA KPI Metrics
                    else if(multiSubType!= null && multiSubType != ''){
                        whereClause += 'AND (Core_MDF_Field_3_txt__c IN ' + multiSubType  + ' OR Core_MDF_Field_3_txt__c = null) AND Core_MDF_Field_4_txt__c != NULL ' + 'AND Core_MDF_Sub_Category__c = \'' + objectName + '\' ';
                    }
                     else {
                        whereClause += 'AND Core_MDF_Field_4_txt__c != NULL ' + 'AND Core_MDF_Sub_Category__c = \'' + objectName + '\' ';
                    }
                    //US - TWC702-14285: Flatten nested IFs (no logic change)
                    if (objectName == 'PartnerFundClaim') {
                        String baseStart = ' AND Core_MDF_Checkbox_Field_4_Ind__c = false';
                        String baseEnd = ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
                        String propCondition = String.isNotBlank(propStr) ? ' AND ' + propStr : '';
                        whereClause = whereClause + baseStart + propCondition + baseEnd;
                    }
                    else if(objectName == 'PartnerFundRequest') {
                        if(propStr != '') {
                            //changes for IPA KPI Metrics
                            if(Label.Core_MDF_IPA_Program_Name.equalsIgnoreCase(program)){
                                whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND '+propStr+ ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Field_3_txt__c, Core_MDF_Sort_Order_Nbr__c';
                            }
                            else{
                                whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND '+propStr+ ' AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
                            }
                        } else {
                            //changes for IPA KPI Metrics
                            if(Label.Core_MDF_IPA_Program_Name.equalsIgnoreCase(program)){
                                whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Field_3_txt__c, Core_MDF_Sort_Order_Nbr__c';
                            }
                            else{
                                whereClause = whereClause + ' AND Core_MDF_Checkbox_Field_3_Ind__c = false AND Core_MDF_Is_Active_Ind__c = True Order by Core_MDF_Sort_Order_Nbr__c';
                            }
                        }
                    }
                    List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);
                    if (metaDataValues != null){
                        // ATHR Avoid long parameter lists - US 14285 - Indira
                        KPIWrapperParams p = new KPIWrapperParams();
                        p.recordId = recordId;
                        p.objectName = objectName;
                        p.metaDataValues = metaDataValues;
                        p.activityId = activityId;
                        p.sectionTitle = sectionTitle;
                        kpiAttrs = getKPIWrapper(p);
                    }
                }
                // try-catch intentionally removed to allow exceptions to propagate to LWC for client-side handling and logging 
        }

        return kpiAttrs;
    }

    /**
     * * Method to fetch the KPI wrapper method
     * * Input params - wrapped to avoid long parameter list
     * ? Created by Sridhar on 17-FEB-2020 | Refactored: wrap params and unpack locally
    */
    // ATHR Avoid long parameter lists - US 14285 - Indira
    private static KPIAttributes getKPIWrapper(KPIWrapperParams params){
        // ATHR Avoid long parameter lists - US 14285 - Indira
        // unpack wrapper into local variables
        Id recordId = params.recordId;
        String objectName = params.objectName;
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues = params.metaDataValues;
        Id activityId = params.activityId;
        String sectionTitle = params.sectionTitle;

        KPIAttributes kpiAttrs = new KPIAttributes();
        Map<String,Schema.SObjectField> mfields = null;
        SObject recordObject = null;
        SObject activityRecObject = null;
        Map<String, Object> mfieldsValues = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.recordValue));
        Map<String, Object> activityFieldValues = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.recordValue));
        Map<String, Object> mfieldVisibility = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.visibility));
        Map<String, Object> mfieldPicValues = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.picValues));
        Map<String, Object> mfieldLabes = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.labels));
        
        if (recordId != null){
            recordObject = readRecordValues(recordId,mfieldsValues,objectName);
        } 

        if(sectionTitle == System.Label.Core_MDF_ActualKPILabel && activityId != null && objectName == 'PartnerFundClaim'){
            activityRecObject = readRecordValues(activityId,mfieldsValues,'PartnerFundRequest');
        }
        
        // ATHR Fix: Replace Schema.getGlobalDescribe() with describeSObjects()
        Schema.DescribeSObjectResult[] describeResult = Schema.describeSObjects(new List<String>{objectName});
        if(describeResult != null && !describeResult.isEmpty()){
            mfields = describeResult[0].fields.getMap();
        }
        
        if (mfields != null){
            
            for(Core_MDF_CCP_Custom_Metadata_Utility__c metaData : metaDataValues){
                Schema.SObjectField objectField = mfields.get(metaData.Core_MDF_Field_4_txt__c);
                if (objectField != null){
                    Schema.DescribeFieldResult fieldResult = objectField.getDescribe();
                    String fieldName = fieldResult.getName();
                    Schema.DisplayType dsplyType = fieldResult.getType();
                                        
                    List<KPIArray> pickListValuesList= new List<KPIArray>();
                    if (dsplyType == Schema.DisplayType.PICKLIST){
                        pickListValuesList = loadPickLists(fieldResult);
                    }
                    
                    //Assign piclist values,label values and set visibility
                    mfieldVisibility.put(fieldName.replace('__c', ''),true);
                    mfieldLabes.put(fieldName.replace('__c', ''),fieldResult.getLabel());

                 
                    if (dsplyType == Schema.DisplayType.PICKLIST){
                        mfieldPicValues.put(fieldName.replace('__c', ''),pickListValuesList);
                    }

                    //Set the saved values from the record
                    set<String> keys = mfieldsValues.keySet();
                    if (recordObject != null && keys.contains(fieldName.replace('__c', ''))){
                        mfieldsValues.put(fieldName.replace('__c', ''),recordObject.get(fieldName));
                    }

                    set<String> actKeys = activityFieldValues.keySet();
                    if (activityRecObject != null && actKeys.contains(fieldName.replace('__c', ''))){
                        activityFieldValues.put(fieldName.replace('__c', ''),activityRecObject.get(fieldName));
                    }
                }
            }
        }
        
        String parseValues = JSON.serialize(mfieldsValues);
        String parseActivityValues = JSON.serialize(activityFieldValues);
        String parseVisibility = JSON.serialize(mfieldVisibility);
        String parsePicValues = JSON.serialize(mfieldPicValues);
        String parseLabels = JSON.serialize(mfieldLabes);
        kpiAttrs.recordValue = (SelectedValues)JSON.deserialize(parseValues, SelectedValues.class);
        kpiAttrs.picValues = (SetPicValues)JSON.deserialize(parsePicValues, SetPicValues.class);
        kpiAttrs.visibility = (SetVisibility)JSON.deserialize(parseVisibility, SetVisibility.class);
        kpiAttrs.labels = (LabelValues)JSON.deserialize(parseLabels, LabelValues.class);
        kpiAttrs.activityRecValue = (SelectedValues)JSON.deserialize(parseActivityValues, SelectedValues.class);
        kpiAttrs.metaDataValues = metaDataValues;
        return kpiAttrs;
    }

    private static List<KPIArray> loadPickLists(Schema.DescribeFieldResult fieldResult){

        List<KPIArray> pickListValuesList= new List<KPIArray>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            KPIArray pickListValue = new KPIArray();
            pickListValue.label = pickListVal.getLabel();
            pickListValue.value = pickListVal.getValue();
            pickListValuesList.add(pickListValue);
        }  
        return pickListValuesList;
    }

    /**
     * * Method to fetch the record values
     * * Input params - recordId,objectName and field names which needs to fetch
     * ? Created by Sridhar on 17-FEB-2020
    */
    private static SObject readRecordValues(Id recordId, Map<String, Object> mfieldsValues,string objectName){
        String queryFields = '';
        string querystr = '';

        queryFields = (String.join(new List<String>(mfieldsValues.keySet()), '__c,')) + '__c';
        querystr = String.format(
            'SELECT {0} FROM {1} where id = {2} ',
            new List<String>{
                String.escapeSingleQuotes(queryFields),
                String.escapeSingleQuotes(objectName),
                '\'' + recordId + '\''
            }
        );
        return Database.query(querystr);
    }

    /**
     * * Wrapper class with visibility, record and pick list value variables
     * ? Created by Sridhar on 17-FEB-2020
    */
    
    @TestVisible public class KPIAttributes{

        KPIAttributes(){
            recordValue = new SelectedValues();
            recordValue.Core_MDF_Estimated_Ad_Size_nbr = null;
            recordValue.Core_MDF_Magazine_Newspaper_txt = '';
            recordValue.Core_MDF_Type_of_Page_txt = '';
            recordValue.Core_MDF_NoOfImpressions_Nbr = null;
            recordValue.Core_MDF_Number_of_Clicks_nbr = null;
            recordValue.Core_MDF_URL_txt = '';
            recordValue.Core_MDF_Number_of_RSPs_nbr = null;
            recordValue.Core_MDF_Where_to_take_place_txt = '';
            recordValue.Core_MDF_Number_of_Stores_nbr = null;
            recordValue.Core_MDF_Number_of_Delivered_nbr = null;
            recordValue.Core_MDF_No_of_Emails_Opened_nbr = null;
            recordValue.Core_MDF_TV_Channel_s_txt = '';
            recordValue.Core_MDF_Time_video_to_last_txt = '';
            recordValue.Core_MDF_Frequency_txt = '';
            recordValue.Core_MDF_How_many_screens_nbr = null;
            recordValue.Core_MDF_Runs_per_hour_nbr = null;
            recordValue.Core_MDF_Distribution_txt = '';
            recordValue.Core_MDF_Number_of_Circulation_nbr = null;
            recordValue.Core_MDF_No_Dedicated_Resources_nbr = null;
            recordValue.Core_MDF_Type_of_Resource_txt = '';
            recordValue.Core_MDF_Placement_txt = '';
            recordValue.Core_MDF_Metrics_txt = '';
            recordValue.Core_MDF_Lead_Quantity_nbr = null;
            recordValue.Core_MDF_Deployment_Quantity_nbr = null;
            recordValue.Core_MDF_Other_Quantity_nbr = null;
            //US917622 - opal changes potential winner/number of expected -start 
            recordValue.Core_MDF_Num_of_Potential_Winners_nbr = null;
            recordValue.Core_MDF_No_of_Expected_Participants_nbr =null;
    	    //US917622 -opal changes potential winner/number of expected - end
            // New RMF metric fields
            recordValue.Core_MDF_Number_of_Attendees_Nbr = null;
            recordValue.Core_MDF_Number_of_Distributed_Nbr = null;
            recordValue.Core_MDF_Number_Sold_Nbr = null;
            recordValue.Core_MDF_Number_of_Locations_Nbr = null;
            recordValue.Core_MDF_Number_of_Promoter_days_Nbr = null;
            recordValue.Core_MDF_No_of_Visits_Nbr = null;
            recordValue.Core_MDF_No_of_Zones_Nbr = null;
            recordValue.Core_MDF_No_of_End_caps_Nbr = null;
            recordValue.Core_MDF_No_of_placemats_Nbr = null;
            recordValue.Core_MDF_No_of_stores_with_video_Nbr = null;
            recordValue.Core_MDF_No_of_video_impressions_Nbr = null;
            recordValue.Core_MDF_No_of_Risers_Nbr = null;
            recordValue.Core_MDF_No_of_Signages_Nbr = null;
            recordValue.Core_MDF_No_of_screens_with_con_IPOS_Nbr = null;
            recordValue.Core_MDF_No_of_screens_with_IPOS_Nbr = null;
            recordValue.Core_MDF_Number_of_Reviews_nbr=null;

            // changes for IPA KPI Metrics
            recordValue.Core_MDF_No_of_Recipients_nbr = null;
            recordValue.Core_MDF_No_of_Page_Views_nbr = null;
            recordValue.Core_MDF_No_of_Leads_nbr = null;
            recordValue.Core_MDF_No_of_Units_Sold_nbr = null;
            recordValue.Core_MDF_No_of_Design_Wins_nbr = null;
            recordValue.Core_MDF_No_of_Deals_Registered_nbr = null;
            recordValue.Core_MDF_No_of_Contacts_Reached_nbr = null;
            recordValue.Core_MDF_No_of_Dedicated_Personnel_nbr = null;
            recordValue.Core_MDF_No_of_Trainings_Completed_nbr = null;
            recordValue.Core_MDF_No_of_Deployments_nbr = null;
            recordValue.Core_MDF_No_of_Unique_Visitors_nbr = null;
            recordValue.Core_MDF_No_of_Conversions_nbr = null;
            recordValue.Core_MDF_Cost_Per_Lead_amt = null;
            recordValue.Core_MDF_No_of_Views_nbr = null;
            recordValue.Core_MDF_No_of_Downloads_nbr = null;
            recordValue.Core_MDF_Revenue_of_Units_Sold_amt = null;
            recordValue.Core_MDF_No_of_Placements_nbr = null;
            recordValue.Core_MDF_No_of_Individuals_Trained_nbr = null;
            recordValue.Core_MDF_Average_time_on_Page_nbr = null;
            recordValue.Core_MDF_Social_Media_Engagements_nbr = null;
            recordValue.Core_MDF_Average_View_Time_nbr = null;
            recordValue.Core_MDF_Intel_Speakerships_Sessions_nbr = null;
            recordValue.Core_MDF_No_of_Unique_Listeners_nbr = null;
            recordValue.Core_MDF_ASP_Growth_amt = null;
            recordValue.Core_MDF_No_of_Trainees_nbr = null;
            recordValue.Core_MDF_No_of_ActivatedInstance_nbr = null;
            recordValue.Core_MDF_No_of_Instance_nbr = null;
            recordValue.Core_MDF_No_of_Calls_nbr = null;
            recordValue.Core_MDF_No_of_Days_nbr = null;
            recordValue.Core_MDF_Others_txt = '';

 

           	visibility = new SetVisibility();
            visibility.Core_MDF_Estimated_Ad_Size_nbr = false;
            visibility.Core_MDF_Magazine_Newspaper_txt = false;
            visibility.Core_MDF_Type_of_Page_txt = false;
            visibility.Core_MDF_NoOfImpressions_Nbr = false;
            visibility.Core_MDF_Number_of_Clicks_nbr = false;
            visibility.Core_MDF_URL_txt = false;
            visibility.Core_MDF_Number_of_RSPs_nbr = false;
            visibility.Core_MDF_Where_to_take_place_txt = false;
            visibility.Core_MDF_Number_of_Stores_nbr = false;
            visibility.Core_MDF_Number_of_Delivered_nbr = false;
            visibility.Core_MDF_No_of_Emails_Opened_nbr = false;
            visibility.Core_MDF_TV_Channel_s_txt = false;
            visibility.Core_MDF_Time_video_to_last_txt = false;
            visibility.Core_MDF_Frequency_txt = false;
            visibility.Core_MDF_How_many_screens_nbr = false;
            visibility.Core_MDF_Runs_per_hour_nbr = false;
            visibility.Core_MDF_Distribution_txt = false;
            visibility.Core_MDF_Number_of_Circulation_nbr = false;
            visibility.Core_MDF_No_Dedicated_Resources_nbr = false;
            visibility.Core_MDF_Type_of_Resource_txt = false;
            visibility.Core_MDF_Placement_txt = false;
            visibility.Core_MDF_Metrics_txt = false;
            visibility.Core_MDF_Lead_Quantity_nbr = false;
            visibility.Core_MDF_Deployment_Quantity_nbr = false;
            visibility.Core_MDF_Other_Quantity_nbr = false;
            //US917622 - opal changes potential winner/number of expected -start 
            visibility.Core_MDF_Num_of_Potential_Winners_nbr=false;
            visibility.Core_MDF_No_of_Expected_Participants_nbr = false;
            //US917622 - opal changes potential winner/number of expected -end 


            // New RMF metric fields
            visibility.Core_MDF_Number_of_Attendees_Nbr = false;
            visibility.Core_MDF_Number_of_Distributed_Nbr = false;
            visibility.Core_MDF_Number_Sold_Nbr = false;
            visibility.Core_MDF_Number_of_Locations_Nbr = false;
            visibility.Core_MDF_Number_of_Promoter_days_Nbr = false;
            visibility.Core_MDF_No_of_Visits_Nbr = false;
            visibility.Core_MDF_No_of_Zones_Nbr = false;
            visibility.Core_MDF_No_of_End_caps_Nbr = false;
            visibility.Core_MDF_No_of_placemats_Nbr = false;
            visibility.Core_MDF_No_of_stores_with_video_Nbr = false;
            visibility.Core_MDF_No_of_video_impressions_Nbr = false;
            visibility.Core_MDF_No_of_Risers_Nbr = false;
            visibility.Core_MDF_No_of_Signages_Nbr = false;
            visibility.Core_MDF_No_of_screens_with_con_IPOS_Nbr = false;
            visibility.Core_MDF_No_of_screens_with_IPOS_Nbr = false;
            visibility.Core_MDF_Number_of_Reviews_nbr=false;

            //changes for IPA KPI Metrics
            visibility.Core_MDF_No_of_Recipients_nbr = false;
            visibility.Core_MDF_No_of_Page_Views_nbr = false;
            visibility.Core_MDF_No_of_Leads_nbr = false;
            visibility.Core_MDF_No_of_Units_Sold_nbr = false;
            visibility.Core_MDF_No_of_Design_Wins_nbr = false;
            visibility.Core_MDF_No_of_Deals_Registered_nbr = false;
            visibility.Core_MDF_No_of_Contacts_Reached_nbr = false;
            visibility.Core_MDF_No_of_Dedicated_Personnel_nbr = false;
            visibility.Core_MDF_No_of_Trainings_Completed_nbr = false;
            visibility.Core_MDF_No_of_Deployments_nbr = false;
            visibility.Core_MDF_No_of_Unique_Visitors_nbr = false;
            visibility.Core_MDF_No_of_Conversions_nbr = false;
            visibility.Core_MDF_Cost_Per_Lead_amt = false;
            visibility.Core_MDF_No_of_Views_nbr = false;
            visibility.Core_MDF_No_of_Downloads_nbr = false;
            visibility.Core_MDF_Revenue_of_Units_Sold_amt = false;
            visibility.Core_MDF_No_of_Placements_nbr = false;
            visibility.Core_MDF_No_of_Individuals_Trained_nbr = false;
            visibility.Core_MDF_Average_time_on_Page_nbr = false;
            visibility.Core_MDF_Social_Media_Engagements_nbr = false;
            visibility.Core_MDF_Average_View_Time_nbr = false;
            visibility.Core_MDF_Intel_Speakerships_Sessions_nbr = false;
            visibility.Core_MDF_No_of_Unique_Listeners_nbr = false;
            visibility.Core_MDF_ASP_Growth_amt = false;
            visibility.Core_MDF_No_of_Trainees_nbr = false;
            visibility.Core_MDF_No_of_ActivatedInstance_nbr = false;
            visibility.Core_MDF_No_of_Instance_nbr = false;
            visibility.Core_MDF_No_of_Calls_nbr = false;
            visibility.Core_MDF_No_of_Days_nbr = false;
            visibility.Core_MDF_Others_txt = false;


            picValues = new setPicValues();
            picValues.Core_MDF_Type_of_Page_txt = new List<KPIArray>();
            picValues.Core_MDF_Where_to_take_place_txt = new List<KPIArray>();
            picValues.Core_MDF_Distribution_txt = new List<KPIArray>();
            labels = new LabelValues();
            labels.Core_MDF_Estimated_Ad_Size_nbr = '';
            labels.Core_MDF_Magazine_Newspaper_txt = '';
            labels.Core_MDF_Type_of_Page_txt = '';
            labels.Core_MDF_NoOfImpressions_Nbr = '';
            labels.Core_MDF_Number_of_Clicks_nbr = '';
            labels.Core_MDF_URL_txt = '';
            labels.Core_MDF_Number_of_RSPs_nbr = '';
            labels.Core_MDF_Where_to_take_place_txt = '';
            labels.Core_MDF_Number_of_Stores_nbr = '';
            labels.Core_MDF_Number_of_Delivered_nbr = '';
            labels.Core_MDF_No_of_Emails_Opened_nbr = '';
            labels.Core_MDF_TV_Channel_s_txt = '';
            labels.Core_MDF_Time_video_to_last_txt = '';
            labels.Core_MDF_Frequency_txt = '';
            labels.Core_MDF_How_many_screens_nbr = '';
            labels.Core_MDF_Runs_per_hour_nbr = '';
            labels.Core_MDF_Distribution_txt = '';
            labels.Core_MDF_Number_of_Circulation_nbr = '';
            //US917622 - opal changes potential winner/number of expected -start 
            labels.Core_MDF_Num_of_Potential_Winners_nbr = '';
            labels.Core_MDF_No_of_Expected_Participants_nbr= '';
            //US917622 - opal changes potential winner/number of expected -end 
            labels.Core_MDF_No_Dedicated_Resources_nbr = '';
            labels.Core_MDF_Type_of_Resource_txt = '';
            labels.Core_MDF_Placement_txt = '';
            labels.Core_MDF_Metrics_txt = '';
            labels.Core_MDF_Lead_Quantity_nbr = '';
            labels.Core_MDF_Deployment_Quantity_nbr = '';
            labels.Core_MDF_Other_Quantity_nbr = '';

            // New RMF metric fields
            labels.Core_MDF_Number_of_Attendees_Nbr = '';
            labels.Core_MDF_Number_of_Distributed_Nbr = '';
            labels.Core_MDF_Number_Sold_Nbr = '';
            labels.Core_MDF_Number_of_Locations_Nbr = '';
            labels.Core_MDF_Number_of_Promoter_days_Nbr = '';
            
            labels.Core_MDF_No_of_Visits_Nbr = '';
            labels.Core_MDF_No_of_Zones_Nbr = '';
            labels.Core_MDF_No_of_End_caps_Nbr = '';
            labels.Core_MDF_No_of_placemats_Nbr = '';
            labels.Core_MDF_No_of_stores_with_video_Nbr = '';
            labels.Core_MDF_No_of_video_impressions_Nbr = '';
            labels.Core_MDF_No_of_Risers_Nbr = '';
            labels.Core_MDF_No_of_Signages_Nbr = '';
            labels.Core_MDF_No_of_screens_with_con_IPOS_Nbr = '';
            labels.Core_MDF_No_of_screens_with_IPOS_Nbr = '';
            labels.Core_MDF_Number_of_Reviews_nbr='';
            
            //changes for IPA KPI Metrics
            labels.Core_MDF_No_of_Recipients_nbr = '';
            labels.Core_MDF_No_of_Page_Views_nbr = '';
            labels.Core_MDF_No_of_Leads_nbr = '';
            labels.Core_MDF_No_of_Units_Sold_nbr = '';
            labels.Core_MDF_No_of_Design_Wins_nbr = '';
            labels.Core_MDF_No_of_Deals_Registered_nbr = '';
            labels.Core_MDF_No_of_Contacts_Reached_nbr = '';
            labels.Core_MDF_No_of_Dedicated_Personnel_nbr = '';
            labels.Core_MDF_No_of_Trainings_Completed_nbr = '';
            labels.Core_MDF_No_of_Deployments_nbr = '';
            labels.Core_MDF_No_of_Unique_Visitors_nbr = '';
            labels.Core_MDF_No_of_Conversions_nbr = '';
            labels.Core_MDF_Cost_Per_Lead_amt = '';
            labels.Core_MDF_No_of_Views_nbr = '';
            labels.Core_MDF_No_of_Downloads_nbr = '';
            labels.Core_MDF_Revenue_of_Units_Sold_amt = '';
            labels.Core_MDF_No_of_Placements_nbr = '';
            labels.Core_MDF_No_of_Individuals_Trained_nbr = '';
            labels.Core_MDF_Average_time_on_Page_nbr = '';
            labels.Core_MDF_Social_Media_Engagements_nbr = '';
            labels.Core_MDF_Average_View_Time_nbr = '';
            labels.Core_MDF_Intel_Speakerships_Sessions_nbr = '';
            labels.Core_MDF_No_of_Unique_Listeners_nbr = '';
            labels.Core_MDF_ASP_Growth_amt = '';
            labels.Core_MDF_No_of_Trainees_nbr = '';
            labels.Core_MDF_No_of_ActivatedInstance_nbr = '';
            labels.Core_MDF_No_of_Instance_nbr = '';
            labels.Core_MDF_No_of_Calls_nbr = '';
            labels.Core_MDF_No_of_Days_nbr = '';
            labels.Core_MDF_Others_txt = '';

            activityRecValue = new SelectedValues();
            }
        @AuraEnabled public SetVisibility visibility{get;set;}
        @AuraEnabled public SetPicValues  picValues{get;set;}
        @AuraEnabled public SelectedValues recordValue {get;set;}
        @AuraEnabled public LabelValues labels{ get;set;}
        @AuraEnabled public List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues { get;set;}
        @AuraEnabled public SelectedValues activityRecValue {get;set;}
    }

    /**
     * * Parameter wrapper to avoid long parameter list for getKPIWrapper
     */
    // ATHR Avoid long parameter lists - US 14285 - Indira
    @TestVisible private class KPIWrapperParams {
        public Id recordId;
        public String objectName;
        public List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues;
        public Id activityId;
        public String sectionTitle;
    }

    /**
     * * Class to build the picklist labels and values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class KPIArray{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    /**
     * * Class with all KPI propertirs to set the saved values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class SelectedValues {
        @AuraEnabled public Decimal Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public String Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public String Core_MDF_URL_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Where_to_take_place_txt{get;set;}
        
        @AuraEnabled public Decimal Core_MDF_Number_of_Stores_nbr{get;set;}
       @AuraEnabled public Decimal Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Emails_Opened_nbr{get;set;}
        @AuraEnabled public String Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public String Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public String Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public String Core_MDF_Placement_txt{get;set;}
        @AuraEnabled public String Core_MDF_Metrics_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Lead_Quantity_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Deployment_Quantity_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Other_Quantity_nbr{get;set;}
        //US917622 - opal changes potential winner/number of expected -start 
        @AuraEnabled public Decimal Core_MDF_Num_of_Potential_Winners_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Expected_Participants_nbr{get;set;}
        //US917622 - opal changes potential winner/number of expected -end 

        // New RMF metric fields
        @AuraEnabled public Decimal Core_MDF_Number_of_Attendees_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Distributed_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_Sold_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Locations_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Promoter_days_Nbr{get;set;}
        
        @AuraEnabled public Decimal Core_MDF_No_of_Visits_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Zones_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_End_caps_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_placemats_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_stores_with_video_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_video_impressions_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Risers_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Signages_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_screens_with_con_IPOS_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_screens_with_IPOS_Nbr {get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Reviews_nbr {get;set;}

        //changes for IPA KPI metrics
        @AuraEnabled public Decimal Core_MDF_No_of_Recipients_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Page_Views_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Leads_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Units_Sold_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Design_Wins_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Deals_Registered_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Contacts_Reached_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Dedicated_Personnel_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Trainings_Completed_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Deployments_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Unique_Visitors_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Conversions_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Cost_Per_Lead_amt{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Views_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Downloads_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Revenue_of_Units_Sold_amt{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Placements_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Individuals_Trained_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Average_time_on_Page_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Social_Media_Engagements_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Average_View_Time_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Intel_Speakerships_Sessions_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Unique_Listeners_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_ASP_Growth_amt{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Trainees_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_ActivatedInstance_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Instance_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Calls_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_of_Days_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Others_txt{get;set;}

         }

    /**
     * * Class with all KPI propertirs to set the saved values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class LabelValues {
        @AuraEnabled public string Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public String Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public String Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public String Core_MDF_URL_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Stores_nbr{get;set;}
       @AuraEnabled public String Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Emails_Opened_nbr{get;set;}
        @AuraEnabled public String Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public String Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public String Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public String Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public String Core_MDF_Placement_txt{get;set;}
        @AuraEnabled public String Core_MDF_Metrics_txt{get;set;}
        @AuraEnabled public String Core_MDF_Lead_Quantity_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Deployment_Quantity_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Other_Quantity_nbr{get;set;}
        //US917622 - opal changes potential winner/number of expected -start 
        @AuraEnabled public String Core_MDF_Num_of_Potential_Winners_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Expected_Participants_nbr{get;set;}
	//US917622 - opal changes potential winner/number of expected -start 
        // New RMF metric fields
        @AuraEnabled public String Core_MDF_Number_of_Attendees_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Distributed_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_Number_Sold_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Locations_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Promoter_days_Nbr {get;set;}
       
        @AuraEnabled public String Core_MDF_No_of_Visits_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_Zones_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_End_caps_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_placemats_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_stores_with_video_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_video_impressions_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_Risers_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_Signages_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_screens_with_con_IPOS_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_No_of_screens_with_IPOS_Nbr {get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Reviews_nbr {get;set;}

        //changes for IPA KPI Metrics
        @AuraEnabled public String Core_MDF_No_of_Recipients_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Page_Views_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Leads_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Units_Sold_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Design_Wins_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Deals_Registered_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Contacts_Reached_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Dedicated_Personnel_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Trainings_Completed_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Deployments_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Unique_Visitors_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Conversions_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Cost_Per_Lead_amt{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Views_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Downloads_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Revenue_of_Units_Sold_amt{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Placements_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Individuals_Trained_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Average_time_on_Page_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Social_Media_Engagements_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Average_View_Time_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Intel_Speakerships_Sessions_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Unique_Listeners_nbr{get;set;}
        @AuraEnabled public String Core_MDF_ASP_Growth_amt{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Trainees_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_ActivatedInstance_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Instance_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Calls_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_of_Days_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Others_txt{get;set;}        

         }

    /**
     * * Class with all KPI propertirs to set the visibility of the fields
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class SetVisibility{
        @AuraEnabled public Boolean Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_URL_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Stores_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Emails_Opened_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Placement_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Metrics_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Lead_Quantity_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Deployment_Quantity_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Other_Quantity_nbr{get;set;}
        //US917622 - opal changes potential winner/number of expected -start 
        @AuraEnabled public Boolean Core_MDF_Num_of_Potential_Winners_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Expected_Participants_nbr{get;set;}
        //US917622 - opal changes potential winner/number of expected -end 
        // New RMF metric fields
        @AuraEnabled public Boolean Core_MDF_Number_of_Attendees_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Distributed_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_Sold_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Locations_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Promoter_days_Nbr {get;set;}
        
        @AuraEnabled public Boolean Core_MDF_No_of_Visits_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Zones_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_End_caps_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_placemats_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_stores_with_video_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_video_impressions_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Risers_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Signages_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_screens_with_con_IPOS_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_screens_with_IPOS_Nbr {get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Reviews_nbr {get;set;}

        //Changes for IPA KPI Metrics
        @AuraEnabled public Boolean Core_MDF_No_of_Recipients_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Page_Views_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Leads_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Units_Sold_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Design_Wins_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Deals_Registered_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Contacts_Reached_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Dedicated_Personnel_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Trainings_Completed_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Deployments_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Unique_Visitors_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Conversions_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Cost_Per_Lead_amt{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Views_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Downloads_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Revenue_of_Units_Sold_amt{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Placements_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Individuals_Trained_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Average_time_on_Page_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Social_Media_Engagements_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Average_View_Time_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Intel_Speakerships_Sessions_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Unique_Listeners_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_ASP_Growth_amt{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Trainees_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_ActivatedInstance_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Instance_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Calls_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_of_Days_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Others_txt{get;set;}        
        
    }

    /**
     * * Class with all applicable KPI propertirs to set pick list values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class SetPicValues{
        @AuraEnabled public List<KPIArray> Core_MDF_Type_of_Page_txt{get;set;}
         @AuraEnabled public List<KPIArray> Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public List<KPIArray> Core_MDF_Distribution_txt{get;set;}
    }

}