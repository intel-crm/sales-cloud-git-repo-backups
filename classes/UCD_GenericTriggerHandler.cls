public virtual class UCD_GenericTriggerHandler {
    private static Set<String> bypassedHandlers = new Set<String>();
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    public UCD_GenericTriggerHandler() {
        this.setTriggerContext();
    }

    public void run() {
        if (UCD_GenericTriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return;
        }
        // dispatch to the correct handler method
        switch on this.context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    @TestVisible
    private void setTriggerContext() {
    this.setTriggerContext(null);
    }

    @TestVisible
    private void setTriggerContext(String ctx) {
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            (ctx != null && ctx == 'before insert')) {
          this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            (ctx != null && ctx == 'before update')){
          this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            (ctx != null && ctx == 'before delete')) {
          this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            (ctx != null && ctx == 'after insert')) {
          this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            (ctx != null && ctx == 'after update')) {
          this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            (ctx != null && ctx == 'after delete')) {
          this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            (ctx != null && ctx == 'after undelete')) {
          this.context = TriggerContext.AFTER_UNDELETE;
        }
      }

    

    /***************************************
    * context methods
    ***************************************/
    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert() {}

    @TestVisible
    protected virtual void beforeUpdate() {}

    @TestVisible
    protected virtual void beforeDelete() {}

    @TestVisible
    protected virtual void afterInsert() {}

    @TestVisible
    protected virtual void afterUpdate() {}

    @TestVisible
    protected virtual void afterDelete() {}

    @TestVisible
    protected virtual void afterUndelete() {}

    /***************************************
    * possible trigger contexts
    ***************************************/
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }
    /***************************************
    * public static methods
    ***************************************/
    public static void bypass(String handlerName) {
        UCD_GenericTriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        UCD_GenericTriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return UCD_GenericTriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        UCD_GenericTriggerHandler.bypassedHandlers.clear();
    }

    @TestVisible
    private String getHandlerName() {
        System.debug('!!!==>'+ String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
}