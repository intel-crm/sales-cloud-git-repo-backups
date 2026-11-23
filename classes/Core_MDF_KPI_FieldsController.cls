/**
 * * Controller class to pull the KPI details by using the category, type from custom meta data
 * ? Method created by Sridahron 17-FEB-2020
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
            try {
                Map<String, Object> queryVariabels = (Map<String, Object>) JSON.deserializeUntyped(inputValues);
                string program = (string)queryVariabels.get('program');
                string category = (string)queryVariabels.get('activityCategory');
                string type = (string)queryVariabels.get('activityType');
                string objectName = (string)queryVariabels.get('objName');
                Id recordId = (Id)queryVariabels.get('recordId');
            
                if (objectName != null && program != null && category != null && type != null){
                    List<CCP_Activity_Type_dependent_fields__mdt> metaDataValues = [SELECT Core_MDF_Object_API_Field_Name__c
                                FROM CCP_Activity_Type_dependent_fields__mdt 
                                WHERE Core_MDF_Program_Txt__c =: program
                                AND Core_MDF_Activity_Category_Txt__c =:category
                                AND Core_MDF_Activity_Type_Txt__c =: type
                                AND Core_MDF_Object_API_Field_Name__c != NULL
                                AND Core_MDF_Module__c =: objectName
                                Order by Core_MDF_Sort_Order_Nbr__c
                        ];
                    if (metaDataValues != null){
                        kpiAttrs = getKPIWrapper(recordId,objectName,metaDataValues);
                    }
                }
            } catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        }

        return kpiAttrs;
    }

    /**
     * * Method to fetch the KPI wrapper method
     * * Input params - recordId,objectName and custom meta data values
     * ? Created by Sridhar on 17-FEB-2020
    */
    private static KPIAttributes getKPIWrapper(id recordId, string objectName,List<CCP_Activity_Type_dependent_fields__mdt> metaDataValues){

        KPIAttributes kpiAttrs = new KPIAttributes();
        Map<String,Schema.SObjectField> mfields = null;
        SObject recordObject = null;

        Map<String, Object> mfieldsValues = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.recordValue));
        Map<String, Object> mfieldVisibility = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.visibility));
        Map<String, Object> mfieldPicValues = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.picValues));
        Map<String, Object> mfieldLabes = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(kpiAttrs.labels));
        
        if (recordId != null){
            recordObject = readRecordValues(recordId,mfieldsValues,objectName);
        }
        
        mfields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        //System.debug('mfields->' + mfields);
        if (mfields != null){
            
            for(CCP_Activity_Type_dependent_fields__mdt metaData : metaDataValues){
                Schema.SObjectField objectField = mfields.get(metaData.Core_MDF_Object_API_Field_Name__c);
                if (objectField != null){
                    Schema.DescribeFieldResult fieldResult = objectField.getDescribe();
                    String fieldName = fieldResult.getName();
                    Schema.DisplayType dsplyType = fieldResult.getType();
                                        
                    List<KPIArray> pickListValuesList= new List<KPIArray>();
                    /*if (dsplyType == Schema.DisplayType.PICKLIST){
                        pickListValuesList = loadPickLists(fieldResult);
                    }*/
                    
                    //Assign piclist values,label values and set visibility
                    mfieldVisibility.put(fieldName.replace('__c', ''),true);
                    mfieldLabes.put(fieldName.replace('__c', ''),fieldResult.getLabel());

                    //System.debug('fieldName->' + fieldName + ':: Label->' + fieldResult.getLabel());
                    /*if (dsplyType == Schema.DisplayType.PICKLIST){
                        mfieldPicValues.put(fieldName.replace('__c', ''),pickListValuesList);
                    }*/

                    //Set the saved values from the record
                    set<String> keys = mfieldsValues.keySet();
                    if (recordObject != null && keys.contains(fieldName.replace('__c', ''))){
                        mfieldsValues.put(fieldName.replace('__c', ''),recordObject.get(fieldName));
                    }
                }
            }
        }
        
        String parseValues = JSON.serialize(mfieldsValues);
        String parseVisibility = JSON.serialize(mfieldVisibility);
        String parsePicValues = JSON.serialize(mfieldPicValues);
        String parseLabels = JSON.serialize(mfieldLabes);
        kpiAttrs.recordValue = (SelectedValues)JSON.deserialize(parseValues, SelectedValues.class);
        kpiAttrs.picValues = (SetPicValues)JSON.deserialize(parsePicValues, SetPicValues.class);
        kpiAttrs.visibility = (SetVisibility)JSON.deserialize(parseVisibility, SetVisibility.class);
        kpiAttrs.labels = (LabelValues)JSON.deserialize(parseLabels, LabelValues.class);

        system.debug('kpiAttrs->' + kpiAttrs);
        return kpiAttrs;
    }
/*
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
*/
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
            /*recordValue.Core_MDF_Estimated_Ad_Size_nbr = null;
            recordValue.Core_MDF_Magazine_Newspaper_txt = '';
            recordValue.Core_MDF_Type_of_Page_txt = '';
            recordValue.Core_MDF_NoOfImpressions_Nbr = null;
            recordValue.Core_MDF_Number_of_Clicks_nbr = null;
            recordValue.Core_MDF_URL_txt = '';
            recordValue.Core_MDF_Number_of_RSPs_nbr = null;
            recordValue.Core_MDF_Where_to_take_place_txt = '';
            recordValue.Core_MDF_Collateral_txt = '';
            recordValue.Core_MDF_Number_of_Stores_nbr = null;
            recordValue.Core_MDF_Percentage_of_Intel_Devices_pct = null;
            recordValue.Core_MDF_URLs_w_Live_CPU_Badges_nbr = null;
            recordValue.Core_MDF_ROAS_txt = '';
            recordValue.Core_MDF_CPA_txt = '';
            recordValue.Core_MDF_Number_of_Recipient_nbr = null;
            recordValue.Core_MDF_Number_of_Delivered_nbr = null;
            recordValue.Core_MDF_Open_Rate_nbr = null;
            recordValue.Core_MDF_CTA_txt = '';
            recordValue.Core_MDF_TV_Channel_s_txt = '';
            recordValue.Core_MDF_Time_video_to_last_txt = '';
            recordValue.Core_MDF_Frequency_txt = '';
            recordValue.Core_MDF_How_many_screens_nbr = null;
            recordValue.Core_MDF_Runs_per_hour_nbr = null;
            recordValue.Core_MDF_Distribution_txt = '';
            recordValue.Core_MDF_Number_of_Circulation_nbr = null;
            recordValue.Core_MDF_Number_of_Devices_nbr = null;
            recordValue.Core_MDF_No_Dedicated_Resources_nbr = null;
            recordValue.Core_MDF_Type_of_Resource_txt = '';
            recordValue.Core_MDF_Placement_txt = '';
            */
            recordValue.Core_MDF_Metrics_txt = '';
            visibility = new SetVisibility();
            /*
            visibility.Core_MDF_Estimated_Ad_Size_nbr = false;
            visibility.Core_MDF_Magazine_Newspaper_txt = false;
            visibility.Core_MDF_Type_of_Page_txt = false;
            visibility.Core_MDF_NoOfImpressions_Nbr = false;
            visibility.Core_MDF_Number_of_Clicks_nbr = false;
            visibility.Core_MDF_URL_txt = false;
            visibility.Core_MDF_Number_of_RSPs_nbr = false;
            visibility.Core_MDF_Where_to_take_place_txt = false;
            visibility.Core_MDF_Collateral_txt = false;
            visibility.Core_MDF_Number_of_Stores_nbr = false;
            visibility.Core_MDF_Percentage_of_Intel_Devices_pct = false;
            visibility.Core_MDF_URLs_w_Live_CPU_Badges_nbr = false;
            visibility.Core_MDF_ROAS_txt = false;
            visibility.Core_MDF_CPA_txt = false;
            visibility.Core_MDF_Number_of_Recipient_nbr = false;
            visibility.Core_MDF_Number_of_Delivered_nbr = false;
            visibility.Core_MDF_Open_Rate_nbr = false;
            visibility.Core_MDF_CTA_txt = false;
            visibility.Core_MDF_TV_Channel_s_txt = false;
            visibility.Core_MDF_Time_video_to_last_txt = false;
            visibility.Core_MDF_Frequency_txt = false;
            visibility.Core_MDF_How_many_screens_nbr = false;
            visibility.Core_MDF_Runs_per_hour_nbr = false;
            visibility.Core_MDF_Distribution_txt = false;
            visibility.Core_MDF_Number_of_Circulation_nbr = false;
            visibility.Core_MDF_Number_of_Devices_nbr = false;
            visibility.Core_MDF_No_Dedicated_Resources_nbr = false;
            visibility.Core_MDF_Type_of_Resource_txt = false;
            visibility.Core_MDF_Placement_txt = false;
            */
            visibility.Core_MDF_Metrics_txt = false;
            picValues = new setPicValues();
            /*
            picValues.Core_MDF_Type_of_Page_txt = new List<KPIArray>();
            picValues.Core_MDF_Percentage_of_Intel_Devices_pct = new List<KPIArray>();
            picValues.Core_MDF_Where_to_take_place_txt = new List<KPIArray>();
            picValues.Core_MDF_Distribution_txt = new List<KPIArray>();
            */
            labels = new LabelValues();
            /*
            labels.Core_MDF_Estimated_Ad_Size_nbr = '';
            labels.Core_MDF_Magazine_Newspaper_txt = '';
            labels.Core_MDF_Type_of_Page_txt = '';
            labels.Core_MDF_NoOfImpressions_Nbr = '';
            labels.Core_MDF_Number_of_Clicks_nbr = '';
            labels.Core_MDF_URL_txt = '';
            labels.Core_MDF_Number_of_RSPs_nbr = '';
            labels.Core_MDF_Where_to_take_place_txt = '';
            labels.Core_MDF_Collateral_txt = '';
            labels.Core_MDF_Number_of_Stores_nbr = '';
            labels.Core_MDF_Percentage_of_Intel_Devices_pct = '';
            labels.Core_MDF_URLs_w_Live_CPU_Badges_nbr = '';
            labels.Core_MDF_ROAS_txt = '';
            labels.Core_MDF_CPA_txt = '';
            labels.Core_MDF_Number_of_Recipient_nbr = '';
            labels.Core_MDF_Number_of_Delivered_nbr = '';
            labels.Core_MDF_Open_Rate_nbr = '';
            labels.Core_MDF_CTA_txt = '';
            labels.Core_MDF_TV_Channel_s_txt = '';
            labels.Core_MDF_Time_video_to_last_txt = '';
            labels.Core_MDF_Frequency_txt = '';
            labels.Core_MDF_How_many_screens_nbr = '';
            labels.Core_MDF_Runs_per_hour_nbr = '';
            labels.Core_MDF_Distribution_txt = '';
            labels.Core_MDF_Number_of_Circulation_nbr = '';
            labels.Core_MDF_Number_of_Devices_nbr = '';
            labels.Core_MDF_No_Dedicated_Resources_nbr = '';
            labels.Core_MDF_Type_of_Resource_txt = '';
            labels.Core_MDF_Placement_txt = '';
            */
            labels.Core_MDF_Metrics_txt = '';
        }
        @AuraEnabled public SetVisibility visibility{get;set;}
        @AuraEnabled public SetPicValues  picValues{get;set;}
        @AuraEnabled public SelectedValues recordValue {get;set;}
        @AuraEnabled public LabelValues labels{ get;set;}
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
        /*@AuraEnabled public Decimal Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public String Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public String Core_MDF_URL_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public String Core_MDF_Collateral_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Stores_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Percentage_of_Intel_Devices_pct{get;set;}
        @AuraEnabled public Decimal Core_MDF_URLs_w_Live_CPU_Badges_nbr{get;set;}
        @AuraEnabled public String Core_MDF_ROAS_txt{get;set;}
        @AuraEnabled public String Core_MDF_CPA_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Recipient_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Open_Rate_nbr{get;set;}
        @AuraEnabled public String Core_MDF_CTA_txt{get;set;}
        @AuraEnabled public String Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public String Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public String Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_Number_of_Devices_nbr{get;set;}
        @AuraEnabled public Decimal Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public String Core_MDF_Placement_txt{get;set;}
        */
        @AuraEnabled public String Core_MDF_Metrics_txt{get;set;}
    }

    /**
     * * Class with all KPI propertirs to set the saved values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class LabelValues {
        /*@AuraEnabled public string Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public String Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public String Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public String Core_MDF_URL_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public String Core_MDF_Collateral_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Stores_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Percentage_of_Intel_Devices_pct{get;set;}
        @AuraEnabled public String Core_MDF_URLs_w_Live_CPU_Badges_nbr{get;set;}
        @AuraEnabled public String Core_MDF_ROAS_txt{get;set;}
        @AuraEnabled public String Core_MDF_CPA_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Recipient_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Open_Rate_nbr{get;set;}
        @AuraEnabled public String Core_MDF_CTA_txt{get;set;}
        @AuraEnabled public String Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public String Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public String Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public String Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Number_of_Devices_nbr{get;set;}
        @AuraEnabled public String Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public String Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public String Core_MDF_Placement_txt{get;set;}
        */
        @AuraEnabled public String Core_MDF_Metrics_txt{get;set;}
    }

    /**
     * * Class with all KPI propertirs to set the visibility of the fields
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class SetVisibility{
        /*@AuraEnabled public Boolean Core_MDF_Estimated_Ad_Size_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Magazine_Newspaper_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_NoOfImpressions_Nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Clicks_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_URL_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_RSPs_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Collateral_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Stores_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Percentage_of_Intel_Devices_pct{get;set;}
        @AuraEnabled public Boolean Core_MDF_URLs_w_Live_CPU_Badges_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_ROAS_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_CPA_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Recipient_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Delivered_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Open_Rate_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_CTA_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_TV_Channel_s_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Time_video_to_last_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Frequency_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_How_many_screens_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Runs_per_hour_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Distribution_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Circulation_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Number_of_Devices_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_No_Dedicated_Resources_nbr{get;set;}
        @AuraEnabled public Boolean Core_MDF_Type_of_Resource_txt{get;set;}
        @AuraEnabled public Boolean Core_MDF_Placement_txt{get;set;}
        */
        @AuraEnabled public Boolean Core_MDF_Metrics_txt{get;set;}
    }

    /**
     * * Class with all applicable KPI propertirs to set pick list values
     * ? Created by Sridhar on 17-FEB-2020
    */
    @TestVisible private class SetPicValues{
        /*@AuraEnabled public List<KPIArray> Core_MDF_Type_of_Page_txt{get;set;}
        @AuraEnabled public List<KPIArray> Core_MDF_Percentage_of_Intel_Devices_pct{get;set;}
        @AuraEnabled public List<KPIArray> Core_MDF_Where_to_take_place_txt{get;set;}
        @AuraEnabled public List<KPIArray> Core_MDF_Distribution_txt{get;set;}
        */
    }

}