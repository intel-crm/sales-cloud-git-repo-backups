import { LightningElement, track, api } from "lwc";
//import CustomLabel from "c/customLabel";
//
import PRM_Reject_Message from "@salesforce/label/c.PRM_Reject_Message";
import PRM_Reject_Confirmation from "@salesforce/label/c.PRM_Reject_Confirmation";
import PRM_Reject from "@salesforce/label/c.PRM_Reject";
import PRM_Cancel_ButtonLabel from "@salesforce/label/c.PRM_Cancel_ButtonLabel";
//

export default class ConfirmationMessageDialog extends LightningElement {
	@api showmodel = false;
	@api registrationRequest;
	formLabels = {
		PRM_Reject_Message,
		PRM_Reject_Confirmation,
		PRM_Reject,
		PRM_Cancel_ButtonLabel
	};


	closeModal() {
		this.showmodel = false;
		const cancelEvent = new CustomEvent("cancel", { detail: this.showmodel });
		// Dispatches the event.
		this.dispatchEvent(cancelEvent);
	}

	saveMethod() {
		this.showmodel = false;
		const rejectEvent = new CustomEvent("reject", { detail: this.registrationRequest.RecordId });

		// Dispatches the event.
		this.dispatchEvent(rejectEvent);
	}
}