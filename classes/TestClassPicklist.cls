public class TestClassPicklist {
/*Summary : Code snippet to access picklist value set */

public static String getGlobalPickList() {

//Define table name that has picklist value set fields

String objectName = 'Contact';

//Define controlling picklist value field

String controllingField = 'Core_Country_Region__c';

//Define dependent picklist value field

String dependentField = 'Core_IPS_State__c';

//Declare map variable to store list of dependent value for controlling field

Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

//Get the type being dealt with

Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

Schema.DescribeSObjectResult  describeResult = objType.getDescribe ();

//Get controlling field values

Schema.DescribeFieldResult  controllingFieldInfo = describeResult.fields.getMap().get (controllingField).getDescribe ();

//Get dependent field values

Schema.DescribeFieldResult  dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe ();

List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();

List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    for(Schema.PicklistEntry dep : dependentValues) {
        System.debug(JSON.serialize(dep));
    }
//Get the label for controlling picklist value set

For(Schema.PicklistEntry currControllingValue  :  controllingValues)  {
    System.debug(JSON.serialize(currControllingValue));
controllingInfo.put(currControllingValue.getLabel () , new List<String>()) ;

}
    return JSON.serialize(controllingInfo);
}
}