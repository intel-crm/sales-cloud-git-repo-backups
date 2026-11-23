@isTest
public without sharing class Sales_HostTriggerUtilityhostInfoCheck {
    /*public static boolean duplicateCheck=false;
    public static boolean hostinfoCheck(Map<Id,Sales_Host__c> oldHostMap,List<Sales_Host__c> hostList,String check){  
        Map<String,Sales_Host__c> HostMap=new Map<String,Sales_Host__c>();
        Map<String,Sales_Host__c> HostMap1=new Map<String,Sales_Host__c>();
        Set<Id> primaryAdminSet= new Set<Id>();
        boolean errorMsgCheck=false;
        Set<Id> hostIdSet = new Set<id>();
        boolean validatehost;
        for(Sales_Host__c h: hostList){ 
            h.name = h.name?.toUppercase();
            primaryAdminSet.add(h.Sales_Contact__c);                                       
            hostIdSet.add(h.id);
        }
        for(Sales_License_Admin_Delegate__c delgadmin : [SELECT Id,     Sales_License_PrimaryAdmin_Contact__c, Sales_License_DlgAdmin_Contact__c  
                                                         FROM Sales_License_Admin_Delegate__c WHERE Sales_License_isActive__c=true and (Sales_License_DlgAdmin_Contact__c IN:primaryAdminSet)])
        {primaryAdminSet.add(delgadmin.Sales_License_PrimaryAdmin_Contact__c);
        }
        for(Sales_Host__c h1: hostList){  
            if (h1.name != null) {
                HostMap.put(h1.Sales_Computer_Name_Txt__c,h1);
                HostMap1.put(h1.Name.toLowerCase(),h1);
            }
        }
        if(oldHostMap==null){ 
            for(Sales_Host__c host1:[Select Sales_Computer_Name_Txt__c,Name,Sales_isActiveHost__c,Sales_Contact__c from Sales_Host__c where Sales_Computer_Name_Txt__c!=null and Name!=null and (Sales_Computer_Name_Txt__c IN:HostMap.keySet() or  Name In:HostMap1.keySet()) and (Sales_Contact__c IN:(primaryAdminSet))]){
                if((HostMap.size()>0 || HostMap1.size()>0)){    
                    HostMap1.get(host1.Name.toLowerCase())?.addError(System.label.Sales_DuplicateHost1);
                    HostMap.get(host1.Sales_Computer_Name_Txt__c)?.addError(System.label.Sales_DuplicateHost1);
                    errorMsgCheck=true;
                    duplicateCheck=true;
                }
            }
        }else{ 
            for(Sales_Host__c host1:[ Select id,Sales_Computer_Name_Txt__c, Name,Sales_isActiveHost__c,Sales_Contact__c 
                                     FROM Sales_Host__c where Sales_Computer_Name_Txt__c != null AND Name!=null 
                                     AND (Sales_Computer_Name_Txt__c IN:HostMap.keySet() OR  Name In:HostMap1.keySet()) 
                                     AND Sales_Contact__c IN:primaryAdminSet 
                                     And id NOT IN :hostIdSet 
                                    ]){
                                        if((HostMap.size()>0 || HostMap1.size()>0) && (primaryAdminSet.contains(host1.Sales_Contact__c)) ){
                                            if(check=='chatbot'){
                                                errorMsgCheck=true;
                                            }else{
                                                duplicateCheck=true;
                                                HostMap1.get(host1.Name.toLowerCase())?.addError(System.label.Sales_DuplicateHost1);
                                                HostMap.get(host1.Sales_Computer_Name_Txt__c)?.addError(System.label.Sales_DuplicateHost1);
                                            }
                                        }
                                    } 
        }
        validatehost = true;
        return errorMsgCheck;
    }*/
}