/*********************************************************************************************************************
Class Name  : TriggerHandler_Test
Version     : 1.01
Created Date: JUN 2018

Function    : Test class for the trigger framework

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Dave H/Arun G             06/12/2018              Copied from Kevin O'Hara's GitHub repository
* Dave Hood                 07/06/2018              Added test code to cover the Intel-added code. Also cleaned up
*                                                   formatting so it works better with Developer Console auto-formatting.
*********************************************************************************************************************/
@isTest
private class TriggerHandler_Test {
    
    private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';
    
    private static String lastMethodCalled;
    
    private static TriggerHandler_Test.TestHandler handler;
    
    static {
        handler = new TriggerHandler_Test.TestHandler();
        // override its internal trigger detection
        handler.isTriggerExecuting = true;
    }
    
    /***************************************
    * unit tests
    ***************************************/
    
    // contexts tests
    
    @isTest
    static void testBeforeInsert() {
        beforeInsertMode();
        handler.run();
        System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
    }
    
    @isTest
    static void testBeforeUpdate() {
        beforeUpdateMode();
        handler.run();
        System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
    }
    
    @isTest
    static void testBeforeDelete() {
        beforeDeleteMode();
        handler.run();
        System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
    }
    
    @isTest
    static void testAfterInsert() {
        afterInsertMode();
        handler.run();
        System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
    }
    
    @isTest
    static void testAfterUpdate() {
        afterUpdateMode();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
    }
    
    @isTest
    static void testAfterDelete() {
        afterDeleteMode();
        handler.run();
        System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
    }
    
    @isTest
    static void testAfterUndelete() {
        afterUndeleteMode();
        handler.run();
        System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
    }
    
    @isTest 
    static void testNonTriggerContext() {
        try{
            handler.run();
            System.assert(false, 'the handler ran but should have thrown');
        } catch(TriggerHandler.TriggerHandlerException te) {
            System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
        } catch(Exception e) {
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }
    
    // test bypass api
    
    @isTest
    static void testBypassAPI() {
        afterUpdateMode();
        
        // test a bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
        
        // clear that bypass and run handler
        TriggerHandler.clearBypass('TestHandler');
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
        
        // test a re-bypass and run handler
        TriggerHandler.bypass('TestHandler');
        handler.run();
        System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
        System.assertEquals(true, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
        
        // clear all bypasses and run handler
        TriggerHandler.clearAllBypasses();
        handler.run();
        System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
        System.assertEquals(false, TriggerHandler.isBypassed('TestHandler'), 'test handler should be bypassed');
        resetTest();
    }
    
    // instance method tests
    
    @isTest
    static void testLoopCount() {
        beforeInsertMode();
        
        // set the max loops to 2
        handler.setMaxLoopCount(2);
        
        // run the handler twice
        handler.run();
        handler.run();
        
        // clear the tests
        resetTest();
        
        try {
            // try running it. This should exceed the limit.
            handler.run();
            System.assert(false, 'the handler should throw on the 3rd run when maxloopcount is 3');
        } catch(TriggerHandler.TriggerHandlerException te) {
            // we're expecting to get here
            System.assertEquals(null, lastMethodCalled, 'last method should be null');
        } catch(Exception e) {  
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
        
        // clear the tests
        resetTest();
        
        // now clear the loop count
        handler.clearMaxLoopCount();
        
        try {
            // re-run the handler. We shouldn't throw now.
            handler.run();
            System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
        } catch(TriggerHandler.TriggerHandlerException te) {
            System.assert(false, 'running the handler after clearing the loop count should not throw');
        } catch(Exception e) {  
            System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
        }
    }
    
    @isTest
    static void testLoopCountClass() {
        TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
        System.assertEquals(5, lc.getMax(), 'max should be five on init');
        System.assertEquals(0, lc.getCount(), 'count should be zero on init');
        
        lc.increment();
        System.assertEquals(1, lc.getCount(), 'count should be 1');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');
        
        lc.increment();
        lc.increment();
        lc.increment();
        lc.increment();
        System.assertEquals(5, lc.getCount(), 'count should be 5');
        System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');
        
        lc.increment();
        System.assertEquals(6, lc.getCount(), 'count should be 6');
        System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
    }
    
    // private method tests
    
    @isTest 
    static void testGetHandlerName() {
        System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
    }
    
    // test virtual methods
    
    @isTest
    static void testVirtualMethods() {
        TriggerHandler h = new TriggerHandler();
        h.beforeInsert();
        h.beforeUpdate();
        h.beforeDelete();
        h.afterInsert();
        h.afterUpdate();
        h.afterDelete();
        h.afterUndelete();
    }
    
    /************* INTEL CODE **************/
    @isTest
    static void testIsActive() {
        
        // NOTE: metadata cannot currently be deployed from within a test class, so we need to
        // rely on test entries in the custom metadata, instead of adding them here
        System.assertEquals(true, TriggerHandler.isActive('Test_Active_Functionality'));
        System.assertEquals(false, TriggerHandler.isActive('Test_Inactive_Functionality'));
        System.assertEquals(false, TriggerHandler.isActive('Test_No_Entry'));
        
    }
    
    @isTest
    static void testConsolidatedDML() {
        
        beforeUpdateMode();
        
        // TO DO:
        // 1. Create a record to insert
        // 2. Pull some records to update & delete
        // 3. Add to condolidated DML collections
        // 4. Run the trigger handler
        // 5. Check to ensure the records were inserted/updated/deleted
        
        //TriggerHandler.sObjectsToInsert.add();
        //TriggerHandler.sObjectsToUpdate.put();
        //TriggerHandler.sObjectsToDelete.put();
       handler.run();
    }
    /************* /INTEL CODE *************/
    
    /***************************************
    * testing utilities
    ***************************************/
    
    private static void resetTest() {
        lastMethodCalled = null;
    }
    
    // modes for testing
    
    private static void beforeInsertMode() {
        handler.setTriggerContext('before insert', true);
    }
    
    private static void beforeUpdateMode() {
        handler.setTriggerContext('before update', true);
    }
    
    private static void beforeDeleteMode() {
        handler.setTriggerContext('before delete', true);
    }
    
    private static void afterInsertMode() {
        handler.setTriggerContext('after insert', true);
    }
    
    private static void afterUpdateMode() {
        handler.setTriggerContext('after update', true);
    }
    
    private static void afterDeleteMode() {
        handler.setTriggerContext('after delete', true);
    }
    
    private static void afterUndeleteMode() {
        handler.setTriggerContext('after undelete', true);
    }
    
    // test implementation of the TriggerHandler
    
    private class TestHandler extends TriggerHandler {
        
        public override void beforeInsert() {
            TriggerHandler_Test.lastMethodCalled = 'beforeInsert';
        }
        
        public override void  beforeUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'beforeUpdate';
        }
        
        public override void beforeDelete() {
            TriggerHandler_Test.lastMethodCalled = 'beforeDelete';
        }
        
        public override void afterInsert() {
            TriggerHandler_Test.lastMethodCalled = 'afterInsert';
        }
        
        public override void afterUpdate() {
            TriggerHandler_Test.lastMethodCalled = 'afterUpdate';
        }
        
        public override void afterDelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterDelete';
        }
        
        public override void afterUndelete() {
            TriggerHandler_Test.lastMethodCalled = 'afterUndelete';
        }
        
    }
    
}