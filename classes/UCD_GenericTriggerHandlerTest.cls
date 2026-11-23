@isTest
private class UCD_GenericTriggerHandlerTest {
    private static String lastMethodCalled;
    private static UCD_GenericTriggerHandlerTest.TestGenericHandler handler;

  static {
    handler = new UCD_GenericTriggerHandlerTest.TestGenericHandler();
  }

    static testMethod void testBeforeInsert() {
    beforeInsertMode();
    handler.run();
    System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
  }

  static testMethod void testBeforeUpdate() {
    beforeUpdateMode();
    handler.run();
    System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
  }

  static testMethod void testBeforeDelete() {
    beforeDeleteMode();
    handler.run();
    System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
  }

  static testMethod void testAfterInsert() {
    afterInsertMode();
    handler.run();
    System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
  }

  static testMethod void testAfterUpdate() {
    afterUpdateMode();
    handler.run();
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
  }

  static testMethod void testAfterDelete() {
    afterDeleteMode();
    handler.run();
    System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
  }

  static testMethod void testAfterUndelete() {
    afterUndeleteMode();
    handler.run();
    System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
  }

  static testMethod void testGetHandlerName() {
    System.assertEquals('TestGenericHandler', handler.getHandlerName(), 'handler name should match class name');
  }

  // test virtual methods
  
  static testMethod void testVirtualMethods() {
    UCD_GenericTriggerHandler h = new UCD_GenericTriggerHandler();
    h.beforeInsert();
    h.beforeUpdate();
    h.beforeDelete();
    h.afterInsert();
    h.afterUpdate();
    h.afterDelete();
    h.afterUndelete();
  }

  /***************************************
   * testing utilities
   ***************************************/

  private static void resetTest() {
    lastMethodCalled = null;
  }

  // modes for testing

  private static void beforeInsertMode() {
    handler.setTriggerContext('before insert');
  }

  private static void beforeUpdateMode() {
    handler.setTriggerContext('before update');
  }

  private static void beforeDeleteMode() {
    handler.setTriggerContext('before delete');
  }

  private static void afterInsertMode() {
    handler.setTriggerContext('after insert');
  }

  private static void afterUpdateMode() {
    handler.setTriggerContext('after update');
  }

  private static void afterDeleteMode() {
    handler.setTriggerContext('after delete');
  }

  private static void afterUndeleteMode() {
    handler.setTriggerContext('after undelete');
  }

  // test implementation of the TriggerHandler

  private class TestGenericHandler extends UCD_GenericTriggerHandler {

    public override void beforeInsert() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'beforeInsert';
    }

    public override void  beforeUpdate() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'beforeUpdate';
    }

    public override void beforeDelete() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'beforeDelete';
    }

    public override void afterInsert() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'afterInsert';
    }

    public override void afterUpdate() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'afterUpdate';
    }

    public override void afterDelete() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'afterDelete';
    }

    public override void afterUndelete() {
        UCD_GenericTriggerHandlerTest.lastMethodCalled = 'afterUndelete';
    }
  }
}