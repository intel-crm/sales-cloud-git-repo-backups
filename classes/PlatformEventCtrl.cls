public with sharing class PlatformEventCtrl {
    public static void publishEvent(){
       Techdicer_Event__e event = new Techdicer_Event__e();
       Integer countSuccess=0,countFail=0;
    //    for(string str:statusLst){
    //     if(str=='Completed'){
    //         countSuccess=countSuccess+1;
    //     }
    //     else{
    //         countFail=countFail+1;
    //     }
    //    }
    //    if(countSuccess>0 && countFail>0){
    //     event.status__c='Failedstatus';
    //    }
    //    else if(countSuccess==0 && countFail>0){
    //     event.status__c='Failedstatus';
    //    }
    //    else if(countSuccess>0 && countFail==0){
    //     event.status__c='Success';
    //    }
    //    else{
    //     event.status__c='Failedstatus';
    //    }
    event.status__c='abc';
    event.isLoading__c=true;
        EventBus.publish(event);
    }
}