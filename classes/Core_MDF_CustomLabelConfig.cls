/****************************************************************************************************************************************
* Class Name  : Core_MDF_CustomLabelConfig 
* Version     : 1.0   
* Created Date: 28/06/2021 
* Modification Log :
* Developer                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Nirmala     		28/06/2021                    Class contains all the methods supporting String,Integer,Boolean,
Double,List,Map Data types of Metadata
*****************************************************************************************************************************************/
public class Core_MDF_CustomLabelConfig{
    
    /***************************************************************************************************** 
Method Name   :        getTextValues
@return       :        String
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    public class CustomException extends Exception{}
    @AuraEnabled
    public static String getTextValues(String label){       
        String fieldValue;
        try{
            //checks Label is not empty
            if(String.isNotEmpty(label)){                
                //retrieving the instance of metadata for the given metadata record
                Core_MDF_Custom_Label_Configration__mdt metadata = Core_MDF_Custom_Label_Configration__mdt.getInstance(label.trim());
                //checking the value is not org specific
                String temp='';
                if(metadata != null){ 
                    if(!metadata.Core_MDF_Org_Specific_Ind__c){
                        if(metadata.Core_MDF_Value_Txt__c!=null){
                            temp+=metadata.Core_MDF_Value_Txt__c;
                            if(metadata.Core_MDF_Value2_Txt__c!=null){
                                temp+=metadata.Core_MDF_Value2_Txt__c;
                                if(metadata.Core_MDF_Value3_Txt__c!=null){
                                    temp+=metadata.Core_MDF_Value3_Txt__c;
                                    if(metadata.Core_MDF_Value4_Txt__c!=null){
                                        temp+=metadata.Core_MDF_Value4_Txt__c; 
                                    }
                                }
                            }
                        }
                        fieldValue=temp;
                    }
                } 
            }else throw new CustomException('Key is empty');
           // system.debug('value is : '+fieldValue);
            return fieldValue;
        }Catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;}
    }
    /***************************************************************************************************** 
Method Name   :        getIntegerValues
@return       :        Integer
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static Integer getIntegerValues(String label){
        String fieldValue=getTextValues(label);
        //returns the value in Integer datatype
        return Integer.valueOf(fieldValue);
    }
    /***************************************************************************************************** 
Method Name   :        getBooleanValues
@return       :        Boolean
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is  
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static Boolean getBooleanValues(String label){
        String fieldValue=getTextValues(label);
        //returns the value in Boolean datatype
        return Boolean.valueOf(fieldValue);
    }
    /***************************************************************************************************** 
Method Name   :        getDoubleValues
@return       :        Double
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/    
    @AuraEnabled
    public static Double getDoubleValues(String label){
        String fieldValue=getTextValues(label);
        //returns the value in Double datatype
        return Double.valueOf(fieldValue);
    }
    /***************************************************************************************************** 
Method Name   :        getTextList
@return       :        List<String>
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<String> getTextList(String label){
        String value=getTextValues(label);
        List<String> fieldValueList=value.split(';');
        //returns the List of values in String type
        return fieldValueList;
    }
    /***************************************************************************************************** 
Method Name   :        getTextList
@return       :        List<String>
@parameters   :        Label, Seperator 
Description   :        To accept the String type metadata record and returns its value if the value is  
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<String> getTextList(String label,String seperator){
        String value=getTextValues(label);
        List<String> fieldValueList=value.split(seperator);
        //returns the Seperator List of values in String type
        return fieldValueList;
    }
    /***************************************************************************************************** 
Method Name   :        getIntegerList
@return       :        List<Integer>
@parameters   :        Label 
Description   :        To accept the String type metadata record and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<Integer> getIntegerList(String label){
        String value=getTextValues(label);
        List<String> fieldValueList=value.split(';');
        List<Integer> intList=new List<Integer>();
        for(String st:fieldValueList ){
            intList.add(Integer.valueOf(st));
        }
        //returns the List of values in Integer type
        return intList;
    }
    /***************************************************************************************************** 
Method Name   :        getIntegerList
@return       :        List<Integer>
@parameters   :        Label,Seperator 
Description   :        To accept the String type metadata record and returns its value if the value is  
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<Integer> getIntegerList(String label,String seperator){
        String value=getTextValues(label);
        List<String> fieldValueList=value.split(seperator);
        List<Integer> intList=new List<Integer>();
        for(String st:fieldValueList ){
            intList.add(Integer.valueOf(st));
        }
        //returns the Seperator List of values in String type
        return intList;
    }
    /***************************************************************************************************** 
Method Name   :        getBulkTextValues
@return       :        Map<String,String>
@parameters   :        LabelList 
Description   :        To accept the List of String type metadata records and returns its value if the value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 28/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getBulkTextValues(List<String> labelList){
        Map<String,String> keyValueMap =new Map<String,String>();
        List<String> finalLabelList = new List<String>();
        system.debug('List values are'+labelList);
        try{
            if(!labelList.isEmpty()){
                for(String st : labelList){
                    finalLabelList.add(st.trim());
                }
                //Iterating over List of metadata records
                for(Core_MDF_Custom_Label_Configration__mdt mdtRec:[SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Org_Specific_Ind__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE DeveloperName IN:finalLabelList]){
                    //Adding the records if the value is not org specific
                    String temp='';
                    if(mdtRec!=null){
                        if(!mdtRec.Core_MDF_Org_Specific_Ind__c){
                            if(mdtRec.Core_MDF_Value_Txt__c!=null){
                                temp+=mdtRec.Core_MDF_Value_Txt__c; 
                                if(mdtRec.Core_MDF_Value2_Txt__c!=null){
                                    temp+=mdtRec.Core_MDF_Value2_Txt__c;
                                    if(mdtRec.Core_MDF_Value3_Txt__c!=null){
                                        temp+=mdtRec.Core_MDF_Value3_Txt__c;
                                        if(mdtRec.Core_MDF_Value4_Txt__c!=null){
                                            temp+=mdtRec.Core_MDF_Value4_Txt__c;
                                        }
                                    }
                                }
                            }
                            keyValueMap.put(mdtRec.DeveloperName,temp);
                        }
                        //returns null if meatadata is org specific
                        else keyValueMap.put(mdtRec.DeveloperName,null);
                    }
                }  
            }else throw new CustomException('Key is empty'); 
        }Catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;}
        System.debug('Values are'+keyValueMap);
        system.debug('the count is'+limits.getQueries());
        //Returns map of records which are not org specific from input list
        return keyValueMap;
    }
    /***************************************************************************************************** 
Method Name   :        getBulkTextValuesByCategory
@return       :        Map<String,String>
@parameters   :        Category 
Description   :        To accept the category string and returns meatada record map with its value if value is 
not OrgSpecific
Added By      :        Accenture - Nirmala - 01/07/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getBulkTextValuesByCategory(String category){
        Map<String,String> keyValueMap =new Map<String,String>();
        try{
            if(!String.isEmpty(category)){
                String finalCategoryVal = category.trim();
                //Iterating over category value to fetch its related metadata records
                for(Core_MDF_Custom_Label_Configration__mdt mdtRec:[SELECT DeveloperName, Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c,Core_MDF_Category_Txt__c, Core_MDF_Org_Specific_Ind__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE Core_MDF_Category_Txt__c =: finalCategoryVal]){
                    //Adding the records into map if the value is not org specific
                    String temp='';
                    if(mdtRec!=null){
                        if(!mdtRec.Core_MDF_Org_Specific_Ind__c){
                            if(mdtRec.Core_MDF_Value_Txt__c!=null){
                                temp+=mdtRec.Core_MDF_Value_Txt__c; 
                                if(mdtRec.Core_MDF_Value2_Txt__c!=null){
                                    temp+=mdtRec.Core_MDF_Value2_Txt__c;
                                    if(mdtRec.Core_MDF_Value3_Txt__c!=null){
                                        temp+=mdtRec.Core_MDF_Value3_Txt__c;
                                        if(mdtRec.Core_MDF_Value4_Txt__c!=null){
                                            temp+=mdtRec.Core_MDF_Value4_Txt__c;
                                        }
                                    }
                                }
                            }
                            keyValueMap.put(mdtRec.DeveloperName,temp);
                        }
                        //returns null if meatadata is org specific
                        else keyValueMap.put(mdtRec.DeveloperName,null);
                    }
                }
            }else throw new CustomException('Category is empty'); 
        }Catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;}
        System.debug('Values are'+keyValueMap);
        //Returns map of records which are not org specific from input list
        return keyValueMap;
    }     
}