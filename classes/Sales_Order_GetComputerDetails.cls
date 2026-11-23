@isTest
public with sharing class Sales_Order_GetComputerDetails {
    /*public class OrderOutput {
        @InvocableVariable(required=true)
        public String License_Type_Computer;
        @InvocableVariable(required=true)
        public String Computer_Type;
    }
    public class OrderInput {
        @InvocableVariable(required=true)
        public String Computer_Name;
    }
    @InvocableMethod(label='Get Computer Details')
    public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs) {
        Set<String> computerNumbers = new Set<String>(); 
        for (OrderInput orderInput : orderInputs) {
            computerNumbers.add(orderInput.Computer_Name);
        }
        List<Sales_Host__c> hostinfo = [SELECT Sales_Computer_Name_Txt__c,Sales_Computer_Type__c,Sales_License_Type__c
                                        FROM Sales_Host__c where Sales_Computer_Name_Txt__c in :computerNumbers];
        Map<String, Sales_Host__c> mapNameStatus = new Map<String, Sales_Host__c>(); 
        if (hostinfo.size() > 0) {
            for (Sales_Host__c host : hostinfo) {
                mapNameStatus.put(host.Sales_Computer_Name_Txt__c, host);
            }
        }
        List<OrderOutput> orderOutputs = new List<OrderOutput>();
        for (OrderInput orderInput : orderInputs) {
            OrderOutput orderOutput = new OrderOutput();
            if (mapNameStatus.containsKey(orderInput.Computer_Name)) {
                orderOutput.License_Type_Computer = mapNameStatus.get(orderInput.Computer_Name).Sales_License_Type__c;
                orderOutput.Computer_Type = mapNameStatus.get(orderInput.Computer_Name).Sales_Computer_Type__c;
            } else {
                orderOutput.License_Type_Computer = 'License Details not Found';
                orderOutput.Computer_Type = 'Computer Type not Found';
            }
            orderOutputs.add(orderOutput);
        }
        return orderOutputs;    
    }*/
}