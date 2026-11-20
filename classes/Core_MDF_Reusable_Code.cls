/* Generic Class for reusable code */
public class Core_MDF_Reusable_Code {
    /** */
    public static final string EQUAL = 'Equal';
    /** */
    public static final string NOTEQUAL = 'Not Equal';
    /** */
    public static final string INOPERATOR = 'In';
    /** */
    public static final string NOTIN = 'Not In';
    /* Validate whether a given given matches a criteria rule */
    public static boolean validateRule(validateRuleParams inputParam) {
        String stringType = 'REFERENCE;STRING;BOOLEAN;EMAIL;PICKLIST;PHONE;ENCRYPTEDSTRING;TEXTAREA;URL';
        String numberType = 'CURRENCY;DOUBLE;PERCENT';
        String dateType = 'DATE;DATETIME;TIME';
        String multiSelectType = 'MULTIPICKLIST';
        boolean result = false;

        if(String.isBlank(inputParam.crtValue) &&
            ((inputParam.operator == EQUAL &&  String.isBlank(inputParam.recValue)) || 
            (inputParam.operator == NOTEQUAL && !(String.isBlank(inputParam.recValue))) ||
            (inputParam.operator == INOPERATOR && String.isBlank(inputParam.recValue)) ||
            (inputParam.operator == NOTIN && !String.isBlank(inputParam.recValue)))) {
                result= true;
        }
        if(String.isBlank(inputParam.recValue) &&
            ((inputParam.operator == equal &&  String.isBlank(inputParam.crtValue)) || 
            (inputParam.operator == NOTEQUAL && !(String.isBlank(inputParam.crtValue))) ||
            (inputParam.operator == INOPERATOR && String.isBlank(inputParam.crtValue)) ||
            (inputParam.operator == NOTIN && !String.isBlank(inputParam.crtValue)))) {
                result = true;
        }
        if(String.isBlank(inputParam.crtValue) || String.isBlank(inputParam.recValue)) {
            result = false;
        }

        if(stringType.contains(inputParam.fieldType)) {
            result = stringComp(inputParam);
        }
        else if(numberType.contains(inputParam.fieldType)) {
            result = numberComp(inputParam);
        }
        else if(dateType.contains(inputParam.fieldType)) {
            result = dateComp(inputParam);
        }
        else if(multiSelectType.contains(inputParam.fieldType)) {
            result = multiComp(inputParam);
        }

        return result;
    }

    /** */
    public static boolean stringComp(ValidateRuleParams inputParam) {
        boolean result = false;
         
       	inputParam.recValue = (inputParam.recValue == null ||String.isBlank(inputParam.recValue))  ? '' : inputParam.recValue;
        inputParam.crtValue = (inputParam.crtValue == null|| String.isBlank(inputParam.crtValue)|| inputParam.crtValue.toLowerCase() == 'null' )? '' : inputParam.crtValue;
           
        if((inputParam.operator == NOTEQUAL && inputParam.recValue != inputParam.crtValue && inputParam.recValue!=null && inputParam.crtValue!=null ) || (inputParam.operator == EQUAL && inputParam.recValue == inputParam.crtValue)) {            
       
            result= true;
        }
        //In and Not In operators when criteria value is singular
        else if(inputParam.operator == INOPERATOR && inputParam.recValue.toLowerCase() == inputParam.crtValue.toLowerCase() && !inputParam.crtValue.toLowerCase().contains(';')) {
            result= true;
        }
        else if(inputParam.operator == NOTIN && inputParam.recValue.toLowerCase()!=inputParam.crtValue.toLowerCase() && !inputParam.crtValue.toLowerCase().contains(';')) {
            result= true;
        } 
        //In and Not In operators when criteria value is multiple
        else if(inputParam.crtValue.toLowerCase().contains(';')) {
            list<String> criteriaString = inputParam.crtValue.toLowerCase().split(';');
            for(String str: criteriaString) {
                if(inputParam.operator == INOPERATOR && inputParam.recValue.toLowerCase()==str.trim()) {
                    result = true;
                }
                else if(inputParam.operator == NOTIN && inputParam.recValue.toLowerCase()!=str.trim()){
                    result = true;
                    
                }
                else if (inputParam.operator == NOTIN && inputParam.recValue.toLowerCase()==str.trim()){
                    result = false;
                    break;
                }
            }   
        }
        return result;
    }

    /** */
    public static boolean numberComp(ValidateRuleParams inputParam) {
        boolean result = false;

        switch on inputParam.operator {
            when 'Not Equal'{
                result = Decimal.valueof(inputParam.recValue) == Decimal.valueof(inputParam.crtValue)? false : true;
            }
            when 'Equal'{
                result = Decimal.valueof(inputParam.recValue) == Decimal.valueof(inputParam.crtValue)? true : false;
            }
            when 'Greater Than'{
                result = Decimal.valueof(inputParam.recValue) > Decimal.valueof(inputParam.crtValue)? true: false;
            }
            when 'Greater Than or Equal'{
                result = Decimal.valueof(inputParam.recValue) >= Decimal.valueof(inputParam.crtValue)? true: false;
            }
            when 'Less Than'{
                result = Decimal.valueof(inputParam.recValue) < Decimal.valueof(inputParam.crtValue)? true: false;
            }
            when 'Less Than or Equal'{
                result = Decimal.valueof(inputParam.recValue) <= Decimal.valueof(inputParam.crtValue)? true: false;
            }
        }

        return result;
    }

    /** */
    public static boolean dateComp(ValidateRuleParams inputParam) {
        boolean result = false;

        switch on inputParam.operator {
            when 'Not Equal'{
                result = Date.valueof(inputParam.recValue) == Date.valueof(inputParam.crtValue)? false : true;
            }
            when 'Equal'{
                result = Date.valueof(inputParam.recValue) == Date.valueof(inputParam.crtValue)? true : false;
            }
            when 'Greater Than'{
                result = Date.valueof(inputParam.recValue) > Date.valueof(inputParam.crtValue)? true: false;
            }
            when 'Greater Than or Equal'{
                result = Date.valueof(inputParam.recValue) >= Date.valueof(inputParam.crtValue)? true: false;
            }
            when 'Less Than'{
                result = Date.valueof(inputParam.recValue) < Date.valueof(inputParam.crtValue)? true: false;
            }
            when 'Less Than or Equal'{
                result = Date.valueof(inputParam.recValue) <= Date.valueof(inputParam.crtValue)? true: false;
            }
        }
        return result;
    }

    /** */
    public static boolean multiComp(ValidateRuleParams inputParam) {
        boolean result = false;
        list<String> mainString = inputParam.crtValue.toLowerCase().trim().split(';'); 

        switch on inputParam.operator {
            when 'Not Equal'{                 
                for(String str: inputParam.recValue.split(';')) {
                    if(!mainString.contains(str.toLowerCase().trim())) {
                        result = true;
                    }
                }
            }
            when 'Equal'{
                if(inputParam.crtValue.split(';').size() == inputParam.recValue.split(';').size()) {
                    result = true;
                }
                for(String str: inputParam.recValue.split(';')) {
                    if(!mainString.contains(str.toLowerCase().trim())) {
                        result = false;
                    }
                }
            }
            when 'In'{
                for(String str: inputParam.recValue.toLowerCase().split(';')) {  
                    if(!mainString.contains(str.toLowerCase().trim())) {
                        result= false;
                    }
                }
            }
            when 'Not In'{
                for(String str: inputParam.recValue.toLowerCase().split(';')) {                 
                    if(mainString.contains(str.toLowerCase().trim())) {
                        result = false;
                    }
                }
            }
        }
        return result;
    }

    /* Get data type of any field by passing the Object and Field Name (API Names) */
    public static string getDataTypeOfField(string objectName, string field) {
        Schema.DescribeSObjectResult sObjRes;
        Schema.DescribeFieldResult sObjField;
        
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        sObjRes = sObj.getSObjectType().getDescribe(); 
        sObjField = sObjRes.fields.getMap().get(field).getDescribe();
        return string.valueOf(sObjField.getType());   
    }
    
    public static Map<string,Map<string,SObjectField>> getDataTypeOfFieldsMap(SObject sObj) {
        Map<string,Map<string,SObjectField>> objNameToApiNameToType = new Map<string,Map<string,SObjectField>>();

        DescribeSObjectResult sObjRes = sObj.getSObjectType().getDescribe(); 
        Map<String,SObjectField> objectFieldMap = sObjRes.fields.getMap();
        objNameToApiNameToType.put(sObjRes.Name, objectFieldMap);
        
        return objNameToApiNameToType;
    }

    /* Wrapper class the store the input parameters for validateRule() */
    public class ValidateRuleParams {
        /** */
        public string recValue {get;set;}
        /** */
        public string crtValue {get;set;}
        /** */
        public string operator {get;set;}
        /** */
        public string fieldType {get;set;}
    }

}