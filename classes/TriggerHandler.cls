/*********************************************************************************************************************
Class Name  : TriggerHandler
Version     : 1.01
Created Date: JUN 2018

Function    : BASE CLASS for the trigger framework we are implementing across our enterprise orgs.  Based on 
              following blog post and github repository:
              - https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices
              - https://github.com/kevinohara80/sfdc-trigger-framework
              Consult documentation posted in EBS SFDC Tech Governance repository for how to implement.

To Do       : Refactor to use new Summer '18 feature: Trigger.OperationType:
              - https://developer.salesforce.com/blogs/2018/05/summer18-rethink-trigger-logic-with-apex-switch.html

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Dave H/Arun G             06/12/2018              Copied from Kevin O'Hara's GitHub repository
* Dave Hood                 07/05/2018              Added collections & code for consolidated DML. Also cleaned up
*                                                   formatting so it works better with Developer Console auto-formatting.
*********************************************************************************************************************/

public virtual without sharing class TriggerHandler {

    /************* INTEL CODE **************/
    // Collections for optional consolidated DML at the end of trigger execution
    public static List<sObject>   sObjectsToInsert = new List<sObject>();
    public static Map<Id,sObject> sObjectsToUpdate = new Map<Id,sObject>();
    public static Map<Id,sObject> sObjectsToDelete = new Map<Id,sObject>();
    private static Boolean consolidatedDMLDone = false;
    /************* /INTEL CODE *************/
    
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public TriggerHandler() {
        this.setTriggerContext();
    }



    /***************************************
    * public instance methods
    ***************************************/
    
    // main method that will be called during execution
    public void run() {
        
        if(!validateRun()) return;
        
        addToLoopCount();
        system.debug('TriggerHandler -inside run()');
        // dispatch to the correct handler method
        if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            system.debug('TriggerHandler - After update');
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
        
        /************* INTEL CODE **************/
        performConsolidatedDML();
        /************* /INTEL CODE *************/
    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }
    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
    
    /***************************************
    * public static methods
    ***************************************/
    
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }
    
    /************* INTEL CODE **************/
    public static Boolean isActive(String functionalityName) {
        
        // Note: querying custom metadata is faster than normal SOQL, since it's cached,
        // and it doesn't count towards SOQL limits
        List<Trigger_Execution__mdt> executionEntries = [
            select Active__c, Inactive_for_Profile__c, Inactive_for_User__c
            from Trigger_Execution__mdt
            where DeveloperName = :functionalityName limit 1];
        
        // Check for trigger execution entry
        if (!executionEntries.isEmpty()) {
            // Check to see if the trigger functionality is active
            if (executionEntries[0].Active__c == true) {
                // Check for the user override to make it inactive for this profile or user
                if ((executionEntries[0].Inactive_for_Profile__c == UserInfo.getProfileId()) ||
                    (executionEntries[0].Inactive_for_User__c == UserInfo.getUserId())) {
                    return false;
                }
                // Trigger is on and not inactive for this user
                else return true;
            }
            // Trigger is inactive
            else return false;
        }
        // No trigger execution entry
        else return false;
    }
    /************* /INTEL CODE *************/

    /***************************************
    * private instancemethods
    ***************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
    
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
           (ctx != null && ctx == 'before insert')) {
               this.context = TriggerContext.BEFORE_INSERT;
           }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')) {
                    this.context = TriggerContext.BEFORE_UPDATE;
                }
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
                    this.context = TriggerContext.BEFORE_DELETE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
                    this.context = TriggerContext.AFTER_INSERT;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
                    this.context = TriggerContext.AFTER_UPDATE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
                    this.context = TriggerContext.AFTER_DELETE;
                }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
                    this.context = TriggerContext.AFTER_UNDELETE;
                }
    }
    
    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if(TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }
    
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /************* INTEL CODE **************/
    @TestVisible
    private void performConsolidatedDML() {
        
        if (!consolidatedDMLDone) {
            consolidatedDMLDone = true;
            
            // Perform any inserts, updates, and deletes, if we have any records
            if (sObjectsToInsert.size() > 0) {
                insert sObjectsToInsert;
            }
            if (sObjectsToUpdate.size() > 0) {
                update sObjectsToUpdate.values();
            }
            if (sObjectsToDelete.size() > 0) {
                delete sObjectsToDelete.values();
            }
        }
    }
    /************* /INTEL CODE *************/

    /***************************************
    * context methods
    ***************************************/
    
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
    @TestVisible
    protected virtual void testingbeforeUpdate(){}
    
    /***************************************
    * inner classes
    ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    // exception class
    public class TriggerHandlerException extends Exception {}
    
}