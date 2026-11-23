public class Core_XML_generator {
    
    public static void Publish_Account_Details(){
        
        List<Account> accountList= [Select Id, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet, Core_Account_Legal_Name__c, Core_CIM_ID__c, Core_Deactivated__c, Core_Deactivation_Reason__c, Core_Sales_Group__c, Core_Sales_Segment__c, Fax, Name, Phone, RecordTypeId, Type from Account where id='0012D00000Ok5bjQAB' ];
        List<String> fields = new List<String>{'Id', 'BillingCity', 'BillingCountry', 'BillingCountryCode', 'BillingPostalCode', 'BillingState', 'BillingStateCode', 'BillingStreet', 'Core_Account_Legal_Name__c', 'Core_CIM_ID__c', 'Core_Deactivated__c', 'Core_Deactivation_Reason__c', 'Core_Sales_Group__c', 'Core_Sales_Segment__c', 'Fax', 'Name', 'Phone', 'RecordTypeId', 'Type'};
            String objName='Account';
        Map<String, Schema.sObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        Map<String, String> fieldMap = new Map<String, String>();
        
        for(Schema.SObjectField sfield: sObjectFieldMap.Values()){
            Schema.DescribeFieldResult fieldDesc = sfield.getDescribe();
            if(fields.contains(String.valueOf(fieldDesc.getName()))){
                fieldMap.put(fieldDesc.getName(), fieldDesc.getType().name());
            }
        }
        
        String soapNS = 'sf:'+objName;
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String serviceNS = 'urn:sobject.enterprise.soap.sforce.com';
        String outboundNS = 'http://soap.sforce.com/2005/09/outbound';
        
        
        Dom.Document doc = new Dom.Document();
        
        Dom.Xmlnode rootNode = doc.createRootElement('Notification', outboundNS, '');
        
        rootNode.addChildElement('Id', null, null)
            .addTextNode(accountList[0].Id);
        sObject sObj=accountList[0];
        
        dom.XmlNode body = rootNode.addChildElement('sObject', null, null);
        body.setNamespace('sf', serviceNS);
        body.setNamespace('xsi', xsi);
        body.setAttributeNS('type', soapNS, xsi, null);
        
        for(String field: fieldMap.keySet()){
            //Dom.Xmlnode accountNode = new ;
            //rootNode.addChildElement('sf', null, null);
            //rootNode.addChildElement('sObject', serviceNS, 'sf');
            //addChildElement('category', serviceNS, null);
            
            if(sObj.get(field) != null){
                //accountNode.setAttribute(field, String.ValueOf(sObj.get(field)));
                body.addChildElement(field, serviceNS, 'sf')
                    .addTextNode(String.ValueOf(sObj.get(field)));
                
                
            }
            
        }        
        
        system.debug(doc.toXmlString());
        
    }
}