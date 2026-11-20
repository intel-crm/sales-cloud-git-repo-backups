trigger PricingIQREventTrigger on Pricing_IQR_Event__e (after insert) {
    new PricingIQREventTriggerHandler().run();
}