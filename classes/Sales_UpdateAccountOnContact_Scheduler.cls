/*********************************************************************************************************************
Class Name    : Sales_UpdateAccountOnContact_Scheduler
Version       : 1.0
Created Date  : June 2022
Function      : This Scheduler class will Schedule a batch job to pick and update all those Contacts which were created 3 months prior to the current System date and check if there are 
                no Licenses, Hosts and Delegate Admin relation associated to them (identifying as a stale contact) and will move them to another Stale Account

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Bharath Kumar           13-June-2022            TWC3144-429 Card in Jira
* *********************************************************************************************************************/
public without sharing class Sales_UpdateAccountOnContact_Scheduler implements Schedulable {

     public void execute(SchedulableContext sc) {
     
      List<Contact> staleContacts = [Select Id,Name,Email,CreatedDate, LastModifiedDate from Contact where Account.Name = 'FPGA Licensing Account'and CreatedDate != LAST_90_DAYS  ];
     
       if(!staleContacts.isEmpty()){
         
       }
     
     }
}