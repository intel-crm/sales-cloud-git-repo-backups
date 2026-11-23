/********************************************************************************************************************************************************************
Apex Class Name:  Core_OppProdConcatenationt_Schedule
Version     : 1.0 
Created Date: 10/12/2020
Function    : Schedule class for Core_OppProductConcatenatedFieldUpdBatch batch class

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree               10/12/2020               Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class Core_OppProdConcatenationt_Schedule  implements Schedulable { //TWC3123-5376: code scan fix
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_OppProductConcatenatedFieldUpdBatch(), 200);
    }
}