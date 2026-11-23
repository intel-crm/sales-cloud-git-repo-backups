/******************************************************************************************************
* Class Name  : Core_MDF_ActivityTypePicklist 
* Version     : 1.0 
* Created Date: 11-Dec-2019
* Modification Log :
* Developer           Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - VD     11-Dec-2019        
*******************************************************************************************************/    

public without sharing class Core_MDF_ActivityTypePicklist {

/***************************************************************************************
Class Name:         ActivityTypeWrapper
Description:        This wrapper class will hold the values of all the variables
Added By: VD        Accenture - 11-Dec-2019 
Modified By:        Date:      Changes: 
****************************************************************************************/
    public without sharing class ActivityTypeWrapper{
        @AuraEnabled
        public String actType;
        @AuraEnabled
        public String fieldDatatype;
        @AuraEnabled
        public String defaultValue;
        @AuraEnabled
        public String fieldlabel;
        @AuraEnabled
        public Boolean isFieldReqd;
        @AuraEnabled
        public String helpText;
        @AuraEnabled
        public Decimal maxlength;
        @AuraEnabled
        //public Map<String,List<String>> picklistValuesMap = new Map<String,List<String>>();
        public List<String> picklistValues = new List<String>();
    }
    
    /*********************************************************************************************************
Method Name:        fetchActivityTypeDependentFieldsFrmMdt
@parameters:        selected activity type
@return  :          List of wrapper
Description:        
Added By: VD        Accenture - 11-Dec-2019
Modified By:        Date:      Changes: 
*********************************************************************************************************
    @AuraEnabled
    public static List<ActivityTypeWrapper> fetchActivityTypeDependentFieldsFrmMdt(String selectedActCat , String selectedActType){        
        List<ActivityTypeWrapper> listActwrapper = new List<ActivityTypeWrapper>();
        
        for(CCP_Activity_Type_dependent_fields__mdt actTypemdtlst:[select Core_MDF_Activity_Type_Txt__c,Core_MDF_Data_type_Txt__c,Core_MDF_Default_Value_Txt__c,Core_MDF_Field_Name_Txt__c,
                                                                   Core_MDF_Manadatory_Ind__c,Core_MDF_Help_Text_Txt__c,Core_MDF_Sort_Order_Nbr__c,Core_MDF_Max_Length_Nbr__c,Core_MDF_Picklist_Values_nm__c
                                                                   from CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Activity_Type_Txt__c=:selectedActType AND Core_MDF_Activity_Category_Txt__c=:selectedActCat
                                                                   AND Core_MDF_Program_Txt__c=:Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Channel_Program_Name') order by Core_MDF_Sort_Order_Nbr__c asc]){
            
            system.debug('metadata - '+actTypemdtlst.Core_MDF_Field_Name_Txt__c);
            ActivityTypeWrapper actWrapper = new ActivityTypeWrapper();
            actWrapper.actType = actTypemdtlst.Core_MDF_Activity_Type_Txt__c;
            actWrapper.fieldDatatype = actTypemdtlst.Core_MDF_Data_type_Txt__c;
            actWrapper.fieldlabel = actTypemdtlst.Core_MDF_Field_Name_Txt__c;
            actWrapper.defaultValue = actTypemdtlst.Core_MDF_Default_Value_Txt__c;
            actWrapper.isFieldReqd = actTypemdtlst.Core_MDF_Manadatory_Ind__c;
            actWrapper.helpText = actTypemdtlst.Core_MDF_Help_Text_Txt__c;
            actWrapper.maxlength = actTypemdtlst.Core_MDF_Max_Length_Nbr__c;
                                                                       
            if(actTypemdtlst.Core_MDF_Data_type_Txt__c=='Picklist' && actTypemdtlst.Core_MDF_Picklist_Values_nm__c!=''){
                //List<String> picklistValuesLst = new List<String>();
                actWrapper.picklistValues = actTypemdtlst.Core_MDF_Picklist_Values_nm__c.split(';');
               /* for(String picklistVal : actTypemdtlst.Core_MDF_Picklist_Values_nm__c.split(';')){
                    picklistValuesLst.add(picklistVal);
                    if (actWrapper.picklistValuesMap.containsKey(actWrapper.fieldlabel) && (!actWrapper.picklistValuesMap.get(actWrapper.fieldlabel).Contains(picklistVal))) {
                        actWrapper.picklistValuesMap.get(actWrapper.fieldlabel).add(picklistVal);
                    } else {
                        actWrapper.picklistValuesMap.put(actWrapper.fieldlabel, picklistValuesLst);
                    }
                    system.debug('Map'+actWrapper.picklistValuesMap);
                }
            } 
            listActwrapper.add(actWrapper);
            system.debug('listActwrapper - '+listActwrapper);
        }
        return listActwrapper;
    }*/
    /*********************************************************************************************************
Method Name:        fetchActivityTypeDependentFieldsFrmMdt
@parameters:        selected activity type
@return  :          List of wrapper
Description:        
Added By: VD        Accenture - 11-Dec-2019
Modified By:        Date:      Changes: 
*********************************************************************************************************

    public static List<String> fetchLabel(){
        List<String> listLabels = new List<String>();
        //listLabels = [Select]
        return listLabels;
    }*/
    
}