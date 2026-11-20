trigger Pricing_QuoteLetter_Event on Pricing_Quote_Letter_Event__e (after insert) {
	new Pricing_QuoteLetter_Event_Handler().run();
}