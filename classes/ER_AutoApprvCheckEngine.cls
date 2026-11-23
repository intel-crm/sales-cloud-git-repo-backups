public class ER_AutoApprvCheckEngine {
    public static void parseJson(string jsonInput) {
        String json=		'{'+
		'    "criteria": ['+
		'        {'+
		'            "rulename": "Rule1",'+
		'            "objectname": "Account",'+
		'            "field": "Core_CIM_ID__c",'+
		'            "value": "",'+
		'            "operator": "",'+
        '    		 "wherefield": "Id",'+
        '    		 "wherevalue": "request.PRM_Salesforce_ID__c",'+    
		'            "hasvaluecheck": true'+
		'        },'+
		'        {'+
		'            "rulename": "Rule2",'+
		'            "objectname": "PRM_AccountChannelMembership__c",'+
		'            "field": "PRM_Channel_Program_Level_Id__r.Name",'+
		'            "value": "Gold",'+
		'            "operator": "=",'+
		'            "hasvaluecheck": false'+
		'        },'+
		'        {'+
		'            "rulename": "Rule3",'+
		'            "objectname": "PRM_AccountChannelMembership__c",'+
		'            "field": "PRM_Status_Nm__c",'+
		'            "value": "Approved",'+
		'            "operator": "=",'+
		'            "hasvaluecheck": false'+
		'        }'+
		'    ],'+
		'    "Expression": "Rule1 OR (Rule2 AND Rule3)"'+
		'}';
        ER_AutoApprvCheckModel model = ER_AutoApprvCheckModel.parse(json);
        system.debug('json - '+json);
        Map<string, boolean> ruleSuccessMap = new Map<string, boolean>();
        PRM_Registration_Request__c request = new PRM_Registration_Request__c();
        request.PRM_Salesforce_ID__c = 	'0018A00000UG0QSQA1';
        
        for(ER_AutoApprvCheckModel.Rule ctr : model.criteria) {
            system.debug('ctr - '+ctr);
            string value = string.valueof(ctr.wherevalue);
            system.debug('value '+value);
            string query = 'SELECT ' +ctr.field + ' FROM '+ ctr.objectname + ' WHERE '+ ctr.wherefield+' = :'+ctr.wherevalue;
            system.debug('query '+query);
            //List<sobject> objects = Database.query(query);
            //system.debug('objects'+objects);
            break;
        }
    }
}