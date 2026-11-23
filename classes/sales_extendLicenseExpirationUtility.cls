public with sharing class sales_extendLicenseExpirationUtility {
    @AuraEnabled(cacheable=true)
    public static list<Order> getOrdersList(string searchKey) {
                string searchKeyword = '%' + searchKey + '%';
                
               // create contact list to store search result 
                list<Order> orderListRecord = new list<Order>();
             
               // query contact records
               /* for(Order ordObj : [Select id, OrderNumber,AccountId,EffectiveDate,Status
                                    From Order
                                    WHERE OrderNumber LIKE : searchKeyword]){

                    orderListRecord.add(ordObj);
                }
                
                 if(orderListRecord.size() == 0){
                    throw new AuraHandledException('No Record Found..'); 
                 }
        		System.debug('orderListRecord==>'+orderListRecord);*/
                return orderListRecord;
            }
        }