trigger Pricing_PermissionSet_Assignment_Event on Pricing_PermissionSet_Assignment_Event__e (after insert) {
    new Pricing_PermissionSet_Assignment_Handler().run();
}